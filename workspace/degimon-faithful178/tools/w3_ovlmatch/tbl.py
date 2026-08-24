import struct
P='/home/ken/Desktop/vise/extracted/slps_017_97.bin'
d=open(P,'rb').read()
BASE=0x80090800
SIZE=len(d)
END=BASE+SIZE
def rd(va,n):
    o=va-BASE
    assert 0<=o and o+n<=SIZE, hex(va)
    return d[o:o+n]
def w(va): return struct.unpack('<I',rd(va,4))[0]
def cstr(va):
    o=va-BASE
    e=d.index(b'\0',o)
    return d[o:e].decode('ascii','replace')
print("image span = 0x%08X .. 0x%08X  (size %d = 0x%X)"%(BASE,END,SIZE,SIZE))
VAT=0x80138870
NPT=0x80138990
print("\n-- raw VA table @0x%08X (24 words) --"%VAT)
for i in range(24):
    print("  [%2d] 0x%08X"%(i,w(VAT+4*i)))
print("\n-- raw name-ptr table @0x%08X (24 words) --"%NPT)
for i in range(24):
    p=w(NPT+4*i)
    s=''
    if BASE<=p<END:
        try: s=cstr(p)
        except Exception as e: s='<err>'
    print("  [%2d] 0x%08X  %r"%(i,p,s))
