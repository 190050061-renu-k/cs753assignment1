import argparse,os

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--transcripts',type=str)

    args = parser.parse_args()
    return args.transcripts

def find(dictionary,words):
    occurences = [None]*len(words)
    count = 0
    for key, value in dictionary.items():
        for idx in range(0,len(words),1):
            if(occurences[idx]==None):
                try:
                    t_idx = value.index(words[idx])
                    occurences[idx] = key+" "+str(t_idx)
                    count += 1
                except:
                    pass
    return occurences

if __name__ == "__main__":
    text_dir = parse_args()
    translate = input()
    dictionary = {}
    with open(text_dir,"r") as ftext:
        lines = ftext.readlines()
        for line in lines:
            tokens = line.split()
            dictionary[tokens[0]] = tokens[1:]

    words = translate.split()
    occurences = find(dictionary,words)
    print(occurences)