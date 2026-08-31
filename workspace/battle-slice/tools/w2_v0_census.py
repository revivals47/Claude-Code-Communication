#!/usr/bin/env python3
"""w2_v0_census.py — ★戻り値 v0 を 決める site を 全数 数える★（worker2・2026-08-31・#930-W2a (1) 補）

★なぜ 2 本目が 要るか★ = 1 本目（w2_exit_census.py）の 定義「制御が 出る site」では ★1 件★ しか 出ない
  （＝ ★jr ra が 1 つ = 出口は 1 つ★）。★勝ち negative／負け の 別は 出口の 数では 表れない★。
  ⇒ ★別の 定義で もう 1 本 数える★: ★出口に 届く 戻り値 v0($2) を 書く site★。
★定義★ = 範囲内で ★$2 を 書く命令★:
  W1 addiu/addu/ori/li 系で rt/rd == 2       （即値・レジスタから 作る）
  W2 lw/lh/lhu/lb/lbu で rt == 2             （memory から 読む）
  W3 その他 R 形式で rd == 2
★数えないもの★ = $2 を ★読むだけ★ の命令／jal の 戻り値としての $2（★呼び出し直後の $2 は 呼び先が 決める★＝別関数）
★母数★ = offset [0x5120,0x5498) の 222 命令。★VA = 0x80052AE0 + offset★。
"""
import struct, sys
BASE_VA = 0x80052AE0
START, END = 0x5120, 0x5498
def va(o): return BASE_VA + o

# rt を書く I 形式（opcode → 名前）
IT_WRITE_RT = {0x08:'addi',0x09:'addiu',0x0A:'slti',0x0B:'sltiu',0x0C:'andi',0x0D:'ori',0x0E:'xori',0x0F:'lui',
               0x20:'lb',0x21:'lh',0x23:'lw',0x24:'lbu',0x25:'lhu'}
# rd を書く R 形式（funct → 名前）
RT_WRITE_RD = {0x20:'add',0x21:'addu',0x22:'sub',0x23:'subu',0x24:'and',0x25:'or',0x26:'xor',0x27:'nor',
               0x2A:'slt',0x2B:'sltu',0x00:'sll',0x02:'srl',0x03:'sra',0x04:'sllv',0x06:'srlv',0x07:'srav',
               0x10:'mfhi',0x12:'mflo'}

def main(path):
    d = open(path,'rb').read()
    n = (END-START)//4
    hits=[]; reads=0; jal=0
    for k in range(n):
        off = START+k*4
        w = struct.unpack_from('<I', d, off)[0]
        op = w>>26; rs=(w>>21)&31; rt=(w>>16)&31; rd=(w>>11)&31; fn=w&0x3F
        imm=w&0xFFFF; simm = imm-0x10000 if imm&0x8000 else imm
        if op==3 or (op==0 and fn==0x09): jal+=1; continue
        if op in IT_WRITE_RT and rt==2:
            hits.append((off,w,"%s $2,%s(0x%X)" % (IT_WRITE_RT[op], "$%d"%rs, imm), simm))
        elif op==0 and fn in RT_WRITE_RD and rd==2:
            hits.append((off,w,"%s $2,$%d,$%d" % (RT_WRITE_RD[fn], rs, rt), None))
        elif rs==2 or rt==2:
            reads+=1
    print("# 母数 offset [0x%X,0x%X) = %d 命令 / VA [0x%08X,0x%08X)" % (START,END,n,va(START),va(END)))
    print("\n★$2(v0) を 書く site = %d 件★" % len(hits))
    for off,w,txt,simm in hits:
        extra = ""
        if simm is not None and txt.startswith(('addiu','addi','ori','lui')):
            extra = "  ← ★即値 %d (0x%X)★" % (simm, simm & 0xFFFF)
        print("   off=0x%04X VA=0x%08X  %08x  %s%s" % (off, va(off), w, txt, extra))
    print("\n★数えなかったもの★: $2 を 読むだけ = %d 件 / jal・jalr = %d 件" % (reads, jal))
    print("★陽性対照★: 読むだけ %d 件 が 出ている ⇒ ★register の 突き合わせは 効いている★" % reads)

main(sys.argv[1] if len(sys.argv)>1 else '/home/ken/Desktop/vise/extracted/btl_rel.bin')
