import sys

n=sys.argv[1]
w=sys.argv[2]

Tn_fst = open("T"+n+"_txt.fst","w")
isyms = open("isyms.txt","r")
Lines = isyms.readlines()

Tn_fst.write("0 1 <s> <s>\n")
for line in Lines:
    token = line.strip().split()[0]
    if token not in ["<eps>","<s>","</s>"]:
        Tn_fst.write("1 1 "+token+" "+token+"\n")
Tn_fst.write("1 2 "+w+" "+w+"\n")
for line in Lines:
    token = line.strip().split()[0]
    if token not in ["<eps>","<s>","</s>"]:
        Tn_fst.write("2 2 "+token+" "+token+"\n")
Tn_fst.write("2 3 </s> </s>\n")

Tn_fst.write("3\n")
Tn_fst.close()
isyms.close()
