import struct, collections, json
P='/home/ken/Desktop/vise/extracted/slps_017_97.bin'
d=open(P,'rb').read(); BASE=0x80090800; SIZE=len(d); END=BASE+SIZE
n=SIZE//4; words=struct.unpack('<%dI'%n, d[:n*4])
jal=collections.defaultdict(list)
for i,w in enumerate(words):
    if (w>>26)==3:
        pc=BASE+4*i
        jal[(pc & 0xF0000000)|((w&0x03FFFFFF)<<2)].append(pc)
below={t:v for t,v in jal.items() if t<BASE}
sites=sorted(s for v in below.values() for s in v)
print("BELOW-image: distinct targets=%d  sites=%d"%(len(below),len(sites)))
print("target min=0x%08X max=0x%08X"%(min(below),max(below)))
print("site   min=0x%08X max=0x%08X"%(min(sites),max(sites)))
# distribution of sites by 0x10000 bucket
b=collections.Counter(s>>16 for s in sites)
print("site buckets:", " ".join("%04X:%d"%(k,v) for k,v in sorted(b.items())))
json.dump({("0x%08X"%t):["0x%08X"%s for s in sorted(v)] for t,v in sorted(below.items())},open('below.json','w'),indent=0)
