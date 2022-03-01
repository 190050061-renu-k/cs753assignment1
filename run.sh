#!/bin/bash

# This script trains + decodes a baseline ASR system for Wolof.

# initialization PATH
. ./path.sh  || die "path.sh expected";
# initialization commands
. ./cmd.sh

[ ! -L "steps" ] && ln -s ../wsj/s5/steps

[ ! -L "utils" ] && ln -s ../wsj/s5/utils

###############################################################
#                   Configuring the ASR pipeline
###############################################################
stage=0    # from which stage should this script start
nj=8        # number of parallel jobs to run during training
test_nj=2    # number of parallel jobs to run during decoding
# the above two parameters are bounded by the number of speakers in each set
###############################################################

# Stage 1: Prepares the train/dev data. Prepares the dictionary and the
# language model.
if [ $stage -le 1 ]; then
  echo "Preparing lexicon and language models"
  local/prepare_lexicon.sh
  local/prepare_lm.sh
fi

# Feature extraction
# Stage 2: MFCC feature extraction + mean-variance normalization
if [ $stage -le 2 ]; then
   for x in train dev test; do
      steps/make_mfcc.sh --nj 8 --cmd "$train_cmd" data/$x exp/make_mfcc/$x mfcc
      steps/compute_cmvn_stats.sh data/$x exp/make_mfcc/$x mfcc
   done
fi

# Stage 3: Training and decoding monophone acoustic models
if [ $stage -le 3 ]; then
  ### Monophone
    echo "Monophone training"
	steps/train_mono.sh --nj "$nj" --cmd "$train_cmd" data/train lang exp/mono
    echo "Monophone training done"
    (
    echo "Decoding the test set"
    utils/mkgraph.sh lang exp/mono exp/mono/graph
  
    # This decode command will need to be modified when you 
    # want to use tied-state triphone models 
    steps/decode.sh --nj $test_nj --cmd "$decode_cmd" \
      exp/mono/graph data/test exp/mono/decode_test
    # steps/decode.sh --nj $test_nj --cmd "$decode_cmd" \
    #   exp/mono/graph data/test exp/mono/decode_test
    echo "Monophone decoding done."
    ) &
fi

# Stage 4: Training tied-state triphone acoustic models
if [ $stage -le 4 ]; then
  ### Triphone
    echo "Triphone training"
      steps/align_si.sh --nj $nj --cmd "$train_cmd" \
      data/train lang exp/mono exp/mono_ali
	steps/train_deltas.sh --boost-silence 1.25 --cmd "$train_cmd"  \
	  1000 10000 data/train lang exp/mono_ali exp/tri1
    echo "Triphone training done"
	# Add triphone decoding steps here #
  (
    echo "Decoding the test set[B]"
    utils/mkgraph.sh lang exp/tri1 exp/tri1/graph 

    steps/decode.sh --nj $test_nj --cmd "$decode_cmd" \
      exp/tri1/graph data/test exp/tri1/decode_test

    echo "Triphone Decoding done[B]"
  ) &
fi

if [ $stage -le 5 ]; then
  ### Augmentation
  echo "Data Augmentation"
  rm -rf data/train_sp3
  utils/data/perturb_data_dir_speed_3way.sh data/train data/train_sp3
  
  steps/make_mfcc.sh --nj 8 --cmd "$train_cmd" data/train_sp3 exp/make_mfcc/train_sp3 mfcc
  steps/compute_cmvn_stats.sh data/train_sp3 exp/make_mfcc/train_sp3 mfcc
  
  steps/align_si.sh --nj $nj --cmd "$train_cmd" \
      data/train_sp3 lang exp/tri1 exp/tri1_ali
	steps/train_deltas.sh --boost-silence 1.25 --cmd "$train_cmd"  \
	  1000 10000 data/train_sp3 lang exp/tri1_ali exp/trisp3
  echo "Data Augmentation Done"
  (
    echo "Decoding the test set[C]"
    utils/mkgraph.sh lang exp/trisp3 exp/trisp3/graph 

    steps/decode.sh --nj $test_nj --cmd "$decode_cmd" \
      exp/trisp3/graph data/test exp/trisp3/decode_test

    echo "Triphone Decoding done[C]"
  ) &
fi

if [ $stage -le 6 ]; then
  ### innovation
  echo "Innovation"
  steps/align_fmllr.sh  --nj $nj --cmd "$train_cmd" data/train_sp3 lang exp/trisp3 exp/trisp3_ali;
  # steps/train_lda_mllt.sh  --boost-silence 1.25 --cmd "$train_cmd" 6000 10000 data/train lang  exp/trild_ali exp/tri_lda;
  steps/train_sat.sh --boost-silence 1.25 --cmd "$train_cmd" 1000 10000 data/train_sp3 lang exp/trisp3_ali exp/trisatsp3; 
  echo "SAT training done."
  (
    echo "Decoding the test set[D]"
    utils/mkgraph.sh lang exp/trisatsp3 exp/trisatsp3/graph 

    # steps/decode.sh --nj $test_nj --cmd "$decode_cmd" \
    #   exp/tri_lda/graph data/dev exp/tri_lda/decode_dev
    # steps/decode.sh --nj $test_nj --cmd "$decode_cmd" \
    #   exp/tri_lda/graph data/test exp/tri_lda/decode_test

    steps/decode_fmllr.sh --nj $test_nj --cmd "$decode_cmd" \
      exp/trisatsp3/graph data/test exp/trisatsp3/decode_test

    echo "Triphone Decoding done[D]"
  ) &
fi

wait;
#score
# Computing the best WERs
for x in exp/*/decode*; do [ -d $x ] && grep WER $x/wer_* | utils/best_wer.sh; done

