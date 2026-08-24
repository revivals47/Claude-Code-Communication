import struct
P='/home/ken/Desktop/vise/extracted/slps_017_97.bin'
d=open(P,'rb').read(); BASE=0x80090800; SIZE=len(d); END=BASE+SIZE
def w(va): return struct.unpack('<I',d[va-BASE:va-BASE+4])[0]
T=0x8011B2BC
print("-- table @0x%08X, 64 words --"%T)
for i in range(64):
    v=w(T+4*i)
    tag='CODE' if 0x800A0000<=v<0x8012F000 else ('img' if BASE<=v<END else 'OUT')
    print("  [0x%02X] 0x%08X %s"%(i,v,tag))
