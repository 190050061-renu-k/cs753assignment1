import argparse
from collections import defaultdict

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--phones',type=str)
    parser.add_argument('--lexicon',type=str)
    parser.add_argument('--alignment',type=str)
    parser.add_argument('--spk2utt',type=str)
    parser.add_argument('--wavscp',type=str)
    
    args = parser.parse_args()
    return args.phones, args.lexicon, args.alignment, args.spk2utt, args.wavscp

def phone2index(phone_txt):
    i2p = {}
    with open(phone_txt) as file:
        for line in file.readlines():
            tokens = line.split()
            i2p[tokens[1]] = tokens[0]
    return i2p

def lect_phones(alignment_txt):
    l2p = defaultdict(list)
    with open(alignment_txt) as file:
        for line in file.readlines():
            tokens = line.split()
            l2p[tokens[0]].append(tokens[1:])
    return l2p

def word2phone(lexicon_txt):
    s2w = {}
    with open(lexicon_txt,encoding="UTF-8") as file:
        for line in file.readlines():
            tokens = line.split()
            sequence = "".join(tokens[1:])
            s2w[sequence] = tokens[0]
    return s2w
   
def lect2spk(spk2utt):
    l2sp = {}
    with open(spk2utt) as file:
        for line in file.readlines():
            tokens = line.split()
            for tk in tokens[1:]:
                l2sp[tk] = tokens[0]
    return l2sp 

def wav_dir(wavscp):
    w2d = {}
    with open(wavscp) as file:
        for line in file.readlines():
            tokens = line.split()
            w2d[tokens[0]] = tokens[1]
    return w2d

def phone2word(ll,i2p,s2w,w2t,key,file):
    sequence = "";flag = False;start = 0
    for i in range(0,len(ll),1):
        ph = ll[i][3]
        Ls = i2p[ph].split('_')
        if(len(Ls)!=2):
            w2t['SIL'][key] = [file, float(ll[i][1]), float(ll[i][2])]
            continue
        if(Ls[1]=='B'):
            flag = True
            start = float(ll[i][1])
        if(flag):
            sequence += Ls[0]
            if(Ls[1]=='E'):
                end = float(ll[i][1]) + float(ll[i][2])
                w2t[s2w[sequence]][key] = [file, start, end - start] ## rewrites > 1 occurences
                flag = False;sequence = "";start = 0

if __name__ == "__main__":
    phone_txt, lexicon_txt, alignment_txt, spk2utt, wavscp = parse_args()
    i2p = phone2index(phone_txt)
    l2p = lect_phones(alignment_txt)
    s2w = word2phone(lexicon_txt)
    l2sp = lect2spk(spk2utt)
    w2d = wav_dir(wavscp)
    w2t = defaultdict(dict)
    for key, value in l2p.items():
        phone2word(value,i2p,s2w,w2t,l2sp[key],key)
    translate = input()
    words = translate.split()
    if(len(words) > 0):
        sorted_words = sorted([ list(w2t[word].keys()) for word in words ],
                            key=lambda x: x.__len__())
        min_occur = sorted_words[0]
        speaker = ""
        for x in min_occur:
            flag = False
            for y in sorted_words:
                if x not in y:
                    flag = True
                    break
            if not flag:
                speaker = x
                break
        word = "SIL"
        print(w2d[w2t[word][speaker][0]],w2t[word][speaker][1],w2t[word][speaker][2])
        for word in words:
            print(w2d[w2t[word][speaker][0]],w2t[word][speaker][1],w2t[word][speaker][2])
        word = "SIL"
        print(w2d[w2t[word][speaker][0]],w2t[word][speaker][1],w2t[word][speaker][2])