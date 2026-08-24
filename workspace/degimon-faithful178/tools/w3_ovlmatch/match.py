import struct, collections, json, os
EXE='/home/ken/Desktop/vise/extracted/slps_017_97.bin'
d=open(EXE,'rb').read(); BASE=0x80090800; SIZE=len(d); END=BASE+SIZE
n=SIZE//4; words=struct.unpack('<%dI'%n,d[:n*4])
jal=collections.defaultdict(list)
for i,w in enumerate(words):
    if (w>>26)==3:
        pc=BASE+4*i
        jal[(pc&0xF0000000)|((w&0x03FFFFFF)<<2)].append(pc)
below={t:v for t,v in jal.items() if t<BASE}

NAMES=['BTL','STD','FISH','EVL','KAR','VS','MOV','DOO2','DOOA','TRN','SHOP','DGET','TRN2','MURD','ENDI','EAB']
VAT=0x80138870
va=[struct.unpack('<I',d[VAT-BASE+4*i:VAT-BASE+4*i+4])[0] for i in range(16)]
V='/home/ken/Desktop/vise/extracted/%s_rel.bin'
C='/home/ken/Documents/Claude-Code-Communication/workspace/degimon-faithful178/disc_rel/%s_REL.BIN'
sz_v=[os.path.getsize(V%NAMES[i].lower()) for i in range(16)]
sz_c=[os.path.getsize(C%NAMES[i]) for i in range(16)]
print("%-5s %-12s %9s %9s  %-22s"%("i","name","size(vise)","size(disc)","span [VA, VA+size_disc)"))
for i in range(16):
    print("%-5d %-12s %9d %9d  0x%08X..0x%08X  delta=%d"%(i,NAMES[i],sz_v[i],sz_c[i],va[i],va[i]+sz_c[i],sz_c[i]-sz_v[i]))
lo=min(va); hi=max(va[i]+sz_c[i] for i in range(16))
print("\nunion of all 16 spans: 0x%08X .. 0x%08X"%(lo,hi))

def owners(t,sz):
    return [NAMES[i] for i in range(16) if va[i]<=t<va[i]+sz[i]]

print("\n%-12s %5s  %-3s  %s"%("target","hits","N","overlays whose span contains it (size=disc_rel)"))
nz=0; multi=collections.Counter()
rows=[]
for t in sorted(below):
    ov=owners(t,sz_c); ov_v=owners(t,sz_v)
    flag='' if ov==ov_v else '  <<64B-BAND-DIFF>>'
    rows.append((t,len(below[t]),ov))
    multi[len(ov)]+=1
    print("0x%08X  x%-4d %-3d  %s%s"%(t,len(below[t]),len(ov),(",".join(ov) if ov else "-- NONE --"),flag))
print("\nhistogram of #overlays containing a target:", dict(sorted(multi.items())))
json.dump([["0x%08X"%t,c,ov] for t,c,ov in rows], open('match.json','w'), indent=0)
