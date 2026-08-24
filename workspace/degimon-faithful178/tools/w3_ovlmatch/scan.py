import struct, collections
P='/home/ken/Desktop/vise/extracted/slps_017_97.bin'
d=open(P,'rb').read()
BASE=0x80090800; SIZE=len(d); END=BASE+SIZE
n=SIZE//4
words=struct.unpack('<%dI'%n, d[:n*4])
jal=collections.defaultdict(list)   # target -> [site,...]
jr_ra=0
for i,w in enumerate(words):
    pc=BASE+4*i
    if (w>>26)==3:                       # jal
        t=(pc & 0xF0000000) | ((w & 0x03FFFFFF)<<2)
        jal[t].append(pc)
tot=sum(len(v) for v in jal.values())
out={t:v for t,v in jal.items() if not (BASE<=t<END)}
below={t:v for t,v in out.items() if t<BASE}
above={t:v for t,v in out.items() if t>=END}
print("jal total sites=%d  distinct targets=%d"%(tot,len(jal)))
print("image-OUTSIDE: sites=%d distinct=%d   (below=%d distinct, above=%d distinct)"%(
      sum(len(v) for v in out.values()), len(out), len(below), len(above)))
print("min=0x%08X  max=0x%08X"%(min(out),max(out)))
import json
json.dump({hex(t):[hex(s) for s in sorted(v)] for t,v in sorted(out.items())}, open('outside.json','w'), indent=0)
print("\n-- all image-outside targets, ascending --")
for t in sorted(out):
    print("  0x%08X  x%d  sites: %s"%(t,len(out[t]), " ".join("0x%08X"%s for s in sorted(out[t])[:6]) + (" ..." if len(out[t])>6 else "")))
