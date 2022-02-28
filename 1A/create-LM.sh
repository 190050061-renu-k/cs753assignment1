#! /bin/bash

#../kenlm/build/bin/lmplz -o 3 < cleaned_corpus.txt.bz2 > L.arpa
#echo "LM building done"

arpa2fst L.arpa > L.fst
fstarcsort L.fst L.fst