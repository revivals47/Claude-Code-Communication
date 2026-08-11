import struct,sys
B=open('/home/ken/Desktop/vise/extracted/slps_017_97.bin','rb').read()
T=0x80090800
R=['zero','at','v0','v1','a0','a1','a2','a3','t0','t1','t2','t3','t4','t5','t6','t7',
   's0','s1','s2','s3','s4','s5','s6','s7','t8','t9','k0','k1','gp','sp','fp','ra']
OP={0x02:'j',0x03:'jal',0x04:'beq',0x05:'bne',0x06:'blez',0x07:'bgtz',0x08:'addi',
    0x09:'addiu',0x0a:'slti',0x0b:'sltiu',0x0c:'andi',0x0d:'ori',0x0e:'xori',0x0f:'lui',
    0x20:'lb',0x21:'lh',0x23:'lw',0x24:'lbu',0x25:'lhu',0x28:'sb',0x29:'sh',0x2b:'sw'}
FN={0x00:'sll',0x02:'srl',0x03:'sra',0x04:'sllv',0x06:'srlv',0x08:'jr',0x09:'jalr',
    0x10:'mfhi',0x12:'mflo',0x18:'mult',0x19:'multu',0x1a:'div',0x1b:'divu',
    0x20:'add',0x21:'addu',0x22:'sub',0x23:'subu',0x24:'and',0x25:'or',0x26:'xor',
    0x27:'nor',0x2a:'slt',0x2b:'sltu'}
def dis(va,n=24):
    out=[]
    for k in range(n):
        a=va+4*k; off=a-T
        if off<0 or off+4>len(B): out.append(f"{a:08x}  <out of range>"); continue
        w=struct.unpack('<I',B[off:off+4])[0]
        op=w>>26; rs=(w>>21)&31; rt=(w>>16)&31; rd=(w>>11)&31; sa=(w>>6)&31; fn=w&63
        imm=w&0xffff; simm=imm-0x10000 if imm&0x8000 else imm
        if op==0:
            m=FN.get(fn,f'?fn{fn:02x}')
            if m in('sll','srl','sra'): s=f"{m} {R[rd]},{R[rt]},{sa}"
            elif m=='jr': s=f"jr {R[rs]}"
            elif m=='jalr': s=f"jalr {R[rd]},{R[rs]}"
            elif m in('mfhi','mflo'): s=f"{m} {R[rd]}"
            elif m in('mult','multu','div','divu'): s=f"{m} {R[rs]},{R[rt]}"
            elif w==0: s="nop"
            else: s=f"{m} {R[rd]},{R[rs]},{R[rt]}"
        elif op in(2,3):
            s=f"{OP[op]} 0x{((a+4)&0xf0000000)|((w&0x3ffffff)<<2):08x}"
        elif op==1:
            s=f"{'bltz' if rt==0 else 'bgez'} {R[rs]},0x{a+4+simm*4:08x}"
        elif op in(4,5): s=f"{OP[op]} {R[rs]},{R[rt]},0x{a+4+simm*4:08x}"
        elif op in(6,7): s=f"{OP[op]} {R[rs]},0x{a+4+simm*4:08x}"
        elif op==0x0f: s=f"lui {R[rt]},0x{imm:04x}"
        elif op in(0x20,0x21,0x23,0x24,0x25,0x28,0x29,0x2b):
            s=f"{OP[op]} {R[rt]},{simm}({R[rs]})"
        elif op in OP: s=f"{OP[op]} {R[rt]},{R[rs]},{simm if op in(8,9,0x0a,0x0b) else hex(imm)}"
        else: s=f"?op{op:02x} .word 0x{w:08x}"
        out.append(f"{a:08x}  {w:08x}  {s}")
    return "\n".join(out)
if __name__=='__main__':
    print(dis(int(sys.argv[1],16), int(sys.argv[2]) if len(sys.argv)>2 else 24))
