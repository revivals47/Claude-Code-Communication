import struct,collections,os
P='/home/ken/Desktop/vise/extracted/slps_017_97.bin'
d=open(P,'rb').read(); BASE=0x80090800; SIZE=len(d); END=BASE+SIZE
n=SIZE//4; W=struct.unpack('<%dI'%n,d[:n*4])
CODE_END=0x8011A000
def at(va): return W[(va-BASE)//4]
NAMES=['BTL','STD','FISH','EVL','KAR','VS','MOV','DOO2','DOOA','TRN','SHOP','DGET','TRN2','MURD','ENDI','EAB']
VAT=0x80138870
va=[at(VAT+4*i) for i in range(16)]
sz=[os.path.getsize('/home/ken/Documents/Claude-Code-Communication/workspace/degimon-faithful178/disc_rel/%s_REL.BIN'%NAMES[i]) for i in range(16)]

LOADER=0x801044AC
sites=[BASE+4*i for i,x in enumerate(W) if (x>>26)==3 and ((BASE+4*i)&0xF0000000|((x&0x03FFFFFF)<<2))==LOADER and BASE+4*i<CODE_END]
print("callers of loader 0x%08X : %d"%(LOADER,len(sites)))

def func_start(pc):
    # walk back to the instruction after the previous 'jr $ra' + delay slot
    k=(pc-BASE)//4
    while k>0:
        if W[k]==0x03E00008: return BASE+4*(k+2)
        k-=1
    return BASE
def func_end(pc):
    k=(pc-BASE)//4
    while BASE+4*k<CODE_END:
        if W[k]==0x03E00008: return BASE+4*(k+2)
        k+=1
    return CODE_END

for s in sites:
    fs,fe=func_start(s),func_end(s)
    # last  addiu $a0,$zero,K  before the jal, inside the function
    k=None
    for pc in range(fs,s,4):
        x=at(pc)
        if (x>>26)==9 and ((x>>21)&31)==0 and ((x>>16)&31)==4:   # addiu $a0,$zero,imm
            k=x&0xffff
    ovl = NAMES[k-1] if (k is not None and 1<=k<=16) else None
    # below-image jals anywhere in the same function
    outs=[]
    for pc in range(fs,fe,4):
        x=at(pc)
        if (x>>26)==3:
            t=(pc&0xF0000000)|((x&0x03FFFFFF)<<2)
            if t<BASE: outs.append((pc,t))
    print("\ncaller-site 0x%08X  func[0x%08X..0x%08X)"%(s,fs,fe))
    print("   literal $a0 before loader call = %s  -> index=%s -> overlay=%s"%(
        ('%d'%k) if k is not None else 'NONE(not a literal)', ('%d'%(k-1)) if k is not None else '-', ovl))
    for pc,t in outs:
        own=[NAMES[i] for i in range(16) if va[i]<=t<va[i]+sz[i]]
        off = ('0x%X'%(t-va[NAMES.index(ovl)])) if ovl else '-'
        print("   below-image jal @0x%08X -> 0x%08X  span-owners=%s  | offset-in-%s=%s"%(pc,t,",".join(own),ovl,off))
