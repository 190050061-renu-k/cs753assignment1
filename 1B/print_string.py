import sys
symbols=[]
for i in range(1,len(sys.argv)):
    symbols.append(sys.argv[i])
isyms=open("isyms.txt","r")
sym_dict={}
for line in isyms.readlines():
    token,symbol = line.strip().split()
    sym_dict[symbol]=token
out_list=[]
for s in symbols:
    if sym_dict[str(s)] not in ['<s>','</s>','<eps>']:
        out_list.append(sym_dict[s])

print(*out_list,sep=' ')