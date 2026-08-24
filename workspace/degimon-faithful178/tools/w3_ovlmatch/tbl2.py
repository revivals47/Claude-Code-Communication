import struct
P='/home/ken/Desktop/vise/extracted/slps_017_97.bin'
d=open(P,'rb').read(); BASE=0x80090800; END=BASE+len(d)
def w(va): return struct.unpack('<I',d[va-BASE:va-BASE+4])[0]
def cs(va):
    o=va-BASE; e=d.index(b'\0',o); return d[o:e].decode('ascii','replace')
print("-- words around the ALPHABETICAL name blob 0x80125938..0x80125A18 --")
for va in range(0x801258C0,0x80125A60,4):
    v=w(va); s=''
    if BASE<=v<END:
        try:
            t=cs(v)
            if t.isprintable() and 2<len(t)<30: s=repr(t)
        except Exception: pass
    print("  0x%08X  0x%08X %s"%(va,v,s))
print("\n-- search whole image for any word == 0x80125938 (ptr to the alpha blob) --")
tgt=0x80125938
for i in range(len(d)//4):
    if struct.unpack('<I',d[4*i:4*i+4])[0]==tgt: print("   ref at 0x%08X"%(BASE+4*i))
