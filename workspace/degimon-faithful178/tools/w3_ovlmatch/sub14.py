import struct,collections
P='/home/ken/Desktop/vise/extracted/slps_017_97.bin'
d=open(P,'rb').read(); BASE=0x80090800; SIZE=len(d); END=BASE+SIZE
n=SIZE//4; words=struct.unpack('<%dI'%n,d[:n*4])
def w(va): return words[(va-BASE)//4]
# 1) table extent: keep reading while value looks like a code pointer in 0x800Exxxx..
T=0x8011B2BC; ents=[]
i=0
while True:
    v=w(T+4*i)
    if not (0x800A0000<=v<0x8012F000): break
    ents.append(v); i+=1
print("sub table entries until first non-code word = %d (first bad = 0x%08X at idx 0x%02X)"%(len(ents),w(T+4*len(ents)),len(ents)))
print("distinct arm entries = %d ; min=0x%08X max=0x%08X"%(len(set(ents)),min(ents),max(ents)))

# 2) all below-image jal sites, grouped, inside the arm-body region
lo=min(ents); hi=max(ents)
print("\n-- below-image jal sites in 0x%08X .. 0x800EF000 --"%lo)
hits=[]
for k in range((lo-BASE)//4, (0x800EF000-BASE)//4):
    x=words[k]
    if (x>>26)==3:
        pc=BASE+4*k; t=(pc&0xF0000000)|((x&0x03FFFFFF)<<2)
        if t<BASE: hits.append((pc,t))
print("count sites=%d  distinct targets=%d"%(len(hits),len(set(t for _,t in hits))))
# attribute each site to the arm whose entry is the greatest entry <= site
se=sorted(set(ents))
def arm_of(pc):
    c=[e for e in se if e<=pc]
    return max(c) if c else None
idx=collections.defaultdict(list)
for j,v in enumerate(ents): idx[v].append(j)
for pc,t in hits:
    a=arm_of(pc)
    print("  site 0x%08X -> 0x%08X   arm_entry=0x%08X  sub_ids=%s"%(pc,t,a,[hex(x) for x in idx.get(a,[])]))
