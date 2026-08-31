#!/usr/bin/env python3
"""w2_mips_dis.py — btl_rel の 指定範囲を 逐語で 逆アセンブルする（worker2・2026-08-31）
★意味を書く前に 命令列を 引くための 器★。未知 opcode は ★.word で そのまま出す（推測で埋めない）★。
"""
import struct, sys
BASE=0x80052AE0
R=['zero','at','v0','v1','a0','a1','a2','a3','t0','t1','t2','t3','t4','t5','t6','t7',
   's0','s1','s2','s3','s4','s5','s6','s7','t8','t9','k0','k1','gp','sp','s8','ra']
IT={0x08:'addi',0x09:'addiu',0x0A:'slti',0x0B:'sltiu',0x0C:'andi',0x0D:'ori',0x0E:'xori'}
LS={0x20:'lb',0x21:'lh',0x22:'lwl',0x23:'lw',0x24:'lbu',0x25:'lhu',0x28:'sb',0x29:'sh',0x2B:'sw'}
RT={0x00:'sll',0x02:'srl',0x03:'sra',0x04:'sllv',0x06:'srlv',0x07:'srav',0x08:'jr',0x09:'jalr',
    0x10:'mfhi',0x11:'mthi',0x12:'mflo',0x13:'mtlo',0x18:'mult',0x19:'multu',0x1A:'div',0x1B:'divu',
    0x20:'add',0x21:'addu',0x22:'sub',0x23:'subu',0x24:'and',0x25:'or',0x26:'xor',0x27:'nor',
    0x2A:'slt',0x2B:'sltu'}
def dis(w, va):
    if w==0: return 'nop'
    op=w>>26; rs=(w>>21)&31; rt=(w>>16)&31; rd=(w>>11)&31; sa=(w>>6)&31; fn=w&0x3F
    imm=w&0xFFFF; s=imm-0x10000 if imm&0x8000 else imm; tg=w&0x03FFFFFF
    if op==0:
        n=RT.get(fn)
        if n is None: return '.word 0x%08x'%w
        if n=='jr': return 'jr %s'%R[rs]
        if n=='jalr': return 'jalr %s'%R[rs]
        if n in ('sll','srl','sra'): return '%s %s,%s,%d'%(n,R[rd],R[rt],sa)
        if n in ('mfhi','mflo'): return '%s %s'%(n,R[rd])
        if n in ('mult','multu','div','divu'): return '%s %s,%s'%(n,R[rs],R[rt])
        if n=='addu' and rs==0 and rt==0: return 'move %s,zero   ★= %s に 0★'%(R[rd],R[rd])
        if n in ('addu','or') and rt==0: return 'move %s,%s'%(R[rd],R[rs])
        return '%s %s,%s,%s'%(n,R[rd],R[rs],R[rt])
    if op==2: return 'j 0x%08X'%(((va+4)&0xF0000000)|(tg<<2))
    if op==3: return 'jal 0x%08X'%(((va+4)&0xF0000000)|(tg<<2))
    if op==4: return ('b 0x%08X'%(va+4+(s<<2))) if rs==0 and rt==0 else 'beq %s,%s,0x%08X'%(R[rs],R[rt],va+4+(s<<2))
    if op==5: return 'bne %s,%s,0x%08X'%(R[rs],R[rt],va+4+(s<<2))
    if op==6: return 'blez %s,0x%08X'%(R[rs],va+4+(s<<2))
    if op==7: return 'bgtz %s,0x%08X'%(R[rs],va+4+(s<<2))
    if op==1: return '%s %s,0x%08X'%({0:'bltz',1:'bgez',16:'bltzal',17:'bgezal'}.get(rt,'b?%d'%rt),R[rs],va+4+(s<<2))
    if op==0x0F: return 'lui %s,0x%04X'%(R[rt],imm)
    if op in IT: return '%s %s,%s,%d'%(IT[op],R[rt],R[rs],s if op in (0x08,0x09,0x0A,0x0B) else imm)
    if op in LS: return '%s %s,%d(%s)'%(LS[op],R[rt],s,R[rs])
    return '.word 0x%08x'%w
def main(path,a,b):
    d=open(path,'rb').read()
    for o in range(a,b,4):
        w=struct.unpack_from('<I',d,o)[0]; va=BASE+o
        print('%04X  %08X  %08x  %s'%(o,va,w,dis(w,va)))
main(sys.argv[1] if len(sys.argv)>1 else '/home/ken/Desktop/vise/extracted/btl_rel.bin',
     int(sys.argv[2],16) if len(sys.argv)>2 else 0x5120,
     int(sys.argv[3],16) if len(sys.argv)>3 else 0x5498)
