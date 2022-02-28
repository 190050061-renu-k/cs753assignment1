#! /bin/bash

fstprint --save_isymbols=isyms.txt --save_osymbols=osyms.txt ../1A/L.fst L.txt
python3 build_T1.py $1 $2
python3 build_T2.py 2 $3
python3 build_T2.py 3 $4

fstcompile --isymbols=isyms.txt --osymbols=osyms.txt T1_txt.fst T1.fst
fstcompile --isymbols=isyms.txt --osymbols=osyms.txt T2_txt.fst T2.fst
fstcompile --isymbols=isyms.txt --osymbols=osyms.txt T3_txt.fst T3.fst

fstarcsort T1.fst T1.fst
fstarcsort T2.fst T2.fst
fstarcsort T3.fst T3.fst
fstintersect T1.fst T2.fst Tx.fst
fstintersect Tx.fst T3.fst T.fst
fstarcsort T.fst T.fst
fstintersect T.fst ../1A/L.fst 1B.fst
fstshortestpath 1B.fst out.fst
output=$(farprintstrings out.fst)
python3 print_string.py $output
rm T* 1B.fst isyms.txt osyms.txt out.* L.txt