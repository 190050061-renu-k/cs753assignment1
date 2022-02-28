import sys
s="<s> "
for i in range(1,len(sys.argv)):
    s+=sys.argv[i]+" "
s+=" </s>"
F_fst = open("F_txt.fst","w")
isyms = open("isyms.txt","r")
state=0
Lines = isyms.readlines()
for word in s.split():
    if word!="XXX":
        F_fst.write(str(state)+" "+str(state+1)+" "+word+" "+word+"\n")
    else:
        for line in Lines:
            token = line.strip().split()[0]
            if token not in ["<eps>","<s>","</s>"]:
                F_fst.write(str(state)+" "+str(state+1)+" "+word+" "+token+"\n")
    state+=1

F_fst.write(str(state)+"\n")
F_fst.close()
count = len(Lines)
isyms.close()

isyms = open("isyms.txt","a")
isyms.write("XXX "+str(count)+"\n")

isyms.close()
