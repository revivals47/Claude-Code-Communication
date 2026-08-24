import struct,collections,json,os
P='/home/ken/Desktop/vise/extracted/slps_017_97.bin'
d=open(P,'rb').read(); BASE=0x80090800; SIZE=len(d); END=BASE+SIZE
n=SIZE//4; words=struct.unpack('<%dI'%n,d[:n*4])
CODE_END=0x8011A000     # last jr$ra = 0x80119E5C ; page-aligned cutoff (disclosed)
jal=collections.defaultdict(list)
for i,x in enumerate(words):
    if (x>>26)==3:
        pc=BASE+4*i
        if pc>=CODE_END: continue
        jal[(pc&0xF0000000)|((x&0x03FFFFFF)<<2)].append(pc)
below={t:v for t,v in jal.items() if t<BASE}
sites=[s for v in below.values() for s in v]
print("CODE-REGION ONLY [0x%08X,0x%08X):"%(BASE,CODE_END))
print("  below-image jal: distinct targets=%d  sites=%d"%(len(below),len(sites)))
print("  min=0x%08X  max=0x%08X"%(min(below),max(below)))
NAMES=['BTL','STD','FISH','EVL','KAR','VS','MOV','DOO2','DOOA','TRN','SHOP','DGET','TRN2','MURD','ENDI','EAB']
VAT=0x80138870
va=[struct.unpack('<I',d[VAT-BASE+4*i:VAT-BASE+4*i+4])[0] for i in range(16)]
sz=[os.path.getsize('/home/ken/Documents/Claude-Code-Communication/workspace/degimon-faithful178/disc_rel/%s_REL.BIN'%NAMES[i]) for i in range(16)]
h=collections.Counter()
none=[]
for t in sorted(below):
    ov=[NAMES[i] for i in range(16) if va[i]<=t<va[i]+sz[i]]
    h[len(ov)]+=1
    if not ov: none.append(t)
print("  multiplicity histogram:",dict(sorted(h.items())))
print("  targets in NO overlay span:",["0x%08X"%t for t in none])
uniq=[(t,[NAMES[i] for i in range(16) if va[i]<=t<va[i]+sz[i]]) for t in sorted(below)]
print("\n  uniquely determined (N==1):")
for t,ov in uniq:
    if len(ov)==1: print("    0x%08X -> %s   sites: %s"%(t,ov[0]," ".join("0x%08X"%s for s in below[t])))
