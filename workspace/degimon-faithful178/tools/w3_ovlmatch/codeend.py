import struct,collections
P='/home/ken/Desktop/vise/extracted/slps_017_97.bin'
d=open(P,'rb').read(); BASE=0x80090800; SIZE=len(d)
n=SIZE//4; words=struct.unpack('<%dI'%n,d[:n*4])
# jr $ra = 0x03E00008 : real code has these densely; data does not
jrra=[BASE+4*i for i,w in enumerate(words) if w==0x03E00008]
print("jr $ra count=%d  first=0x%08X  last=0x%08X"%(len(jrra),jrra[0],jrra[-1]))
print("last 12 jr $ra:", " ".join("0x%08X"%x for x in jrra[-12:]))
# density per 0x1000 page near the tail
c=collections.Counter(x>>12 for x in jrra)
tail=sorted(c)[-24:]
print("\npage(>>12): jr$ra count  (tail)")
print("  "+"  ".join("%05X:%d"%(p,c[p]) for p in tail))
