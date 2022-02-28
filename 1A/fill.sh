#! /bin/bash

fstprint --save_isymbols=isyms.txt --save_osymbols=osyms.txt L.fst L.txt
python3 build_F.py $@

fstcompile --isymbols=isyms.txt --osymbols=osyms.txt F_txt.fst F.fst
fstcompose F.fst L.fst 1A.fst
fstshortestpath 1A.fst out.fst
fstprint --isymbols=isyms.txt --osymbols=osyms.txt < out.fst > out.txt
grep 'XXX' out.txt| awk  '{print $4}'
rm out.* isyms.txt osyms.txt 1A.fst L.txt F_txt.fst