import sys

w1=sys.argv[1]
w2=sys.argv[2]

T1_fst = open("T1_txt.fst","w")
isyms = open("isyms.txt","r")
Lines = isyms.readlines()

T1_fst.write("0 1 <s> <s>\n")
for line in Lines:
    token = line.strip().split()[0]
    if token not in ["<eps>","<s>","</s>"]:
        T1_fst.write("1 1 "+token+" "+token+"\n")
T1_fst.write("1 2 "+w1+" "+w1+"\n")
for line in Lines:
    token = line.strip().split()[0]
    if token not in ["<eps>","<s>","</s>"]:
        T1_fst.write("2 2 "+token+" "+token+"\n")
T1_fst.write("2 3 "+w2+" "+w2+"\n")
for line in Lines:
    token = line.strip().split()[0]
    if token not in ["<eps>","<s>","</s>"]:
        T1_fst.write("3 3 "+token+" "+token+"\n")
T1_fst.write("3 4 </s> </s>\n")

T1_fst.write("4\n")
T1_fst.close()
isyms.close()
