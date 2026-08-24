import struct,sys
P='/home/ken/Desktop/vise/extracted/slps_017_97.bin'
d=open(P,'rb').read(); BASE=0x80090800
R=['zero','at','v0','v1','a0','a1','a2','a3','t0','t1','t2','t3','t4','t5','t6','t7',
   's0','s1','s2','s3','s4','s5','s6','s7','t8','t9','k0','k1','gp','sp','fp','ra']
SP={0:'sll',2:'srl',3:'sra',4:'sllv',6:'srlv',7:'srav',8:'jr',9:'jalr',0x10:'mfhi',0x12:'mflo',
    0x18:'mult',0x19:'multu',0x1a:'div',0x1b:'divu',0x20:'add',0x21:'addu',0x22:'sub',0x23:'subu',
    0x24:'and',0x25:'or',0x26:'xor',0x27:'nor',0x2a:'slt',0x2b:'sltu'}
OP={2:'j',3:'jal',4:'beq',5:'bne',6:'blez',7:'bgtz',8:'addi',9:'addiu',10:'slti',11:'sltiu',
    12:'andi',13:'ori',14:'xori',15:'lui',0x20:'lb',0x21:'lh',0x23:'lw',0x24:'lbu',0x25:'lhu',
    0x28:'sb',0x29:'sh',0x2b:'sw'}
def dec(pc,w):
    op=w>>26
    if op==0:
        f=w&0x3f; s,t,dd,sh=(w>>21)&31,(w>>16)&31,(w>>11)&31,(w>>6)&31
        m=SP.get(f,'sp?%02x'%f)
        if f==0 and w==0: return 'nop'
        if f in (0,2,3): return '%-6s $%s,$%s,%d'%(m,R[dd],R[t],sh)
        if f==8: return 'jr     $%s'%R[s]
        if f==9: return 'jalr   $%s,$%s'%(R[dd],R[s])
        if f in (0x10,0x12): return '%-6s $%s'%(m,R[dd])
        if f in (0x18,0x19,0x1a,0x1b): return '%-6s $%s,$%s'%(m,R[s],R[t])
        return '%-6s $%s,$%s,$%s'%(m,R[dd],R[s],R[t])
    m=OP.get(op,'op?%02x'%op)
    if op in (2,3): return '%-6s 0x%08X'%(m,(pc&0xF0000000)|((w&0x03FFFFFF)<<2))
    s,t=(w>>21)&31,(w>>16)&31; im=w&0xffff; si=im-0x10000 if im>0x7fff else im
    if op in (4,5): return '%-6s $%s,$%s,0x%08X'%(m,R[s],R[t],pc+4+si*4)
    if op in (6,7): return '%-6s $%s,0x%08X'%(m,R[s],pc+4+si*4)
    if op==15: return '%-6s $%s,0x%04X'%(m,R[t],im)
    if op>=0x20: return '%-6s $%s,%d($%s)'%(m,R[t],si,R[s])
    return '%-6s $%s,$%s,%d'%(m,R[t],R[s],si)
a,b=int(sys.argv[1],16),int(sys.argv[2],16)
for pc in range(a,b,4):
    w=struct.unpack('<I',d[pc-BASE:pc-BASE+4])[0]
    print("0x%08X  %08x  %s"%(pc,w,dec(pc,w)))
