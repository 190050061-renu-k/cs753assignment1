#!/bin/bash

# initialization PATH
. ./path.sh  || die "path.sh expected";
# initialization commands
. ./cmd.sh

stage=0
rm -rf out.wav
# transcripts="data/train/text"
# echo $@ | python wol_index.py --transcripts $transcripts

if [ $stage -le 0 ]; then
    # compute cmvn stats 
    x=train
    steps/make_mfcc.sh --nj 8 --cmd "$train_cmd" data/$x exp/make_mfcc/$x mfcc
    steps/compute_cmvn_stats.sh data/$x exp/make_mfcc/$x mfcc
fi;

if [ $stage -le 1 ]; then
    # align data
    steps/align_si.sh --cmd "$train_cmd" data/train lang exp/mono exp/2D
fi;

if [ $stage -le 2 ]; then
    # extract alignments
    for i in exp/2D/ali.*.gz;
    do
        $KALDI_ROOT/src/bin/ali-to-phones --ctm-output exp/2D/final.mdl \
        ark:"gunzip -c $i|" -> ${i%.gz}.ctm;
    done;
fi;

if [ $stage -le 3 ]; then
    # concatenate CTM files
    cd exp/2D
    cat *.ctm > merged_alignment.txt
    cd ../..
fi;

if [ $stage -le 4 ]; then 
    # get occurences
    echo $@ | python3 merge_phones.py \
        --phones lang/phones.txt \
        --lexicon lang/lexicon.txt \
        --alignment exp/2D/merged_alignment.txt \
        --spk2utt data/train/spk2utt \
        --wavscp data/train/wav.scp \
        > snips.txt
fi;

if [ $stage -le 5 ]; then 
    count=0
    while IFS= read -r line; do
        tokens=( $line )
        sox ${tokens[0]} in$count.wav trim ${tokens[1]} ${tokens[2]}
        (( count++ ))
    done < snips.txt;
    rm snips.txt
fi;

if [ $stage -le 6 ]; then
    sox *.wav out.wav
    rm -rf in*.wav
fi;