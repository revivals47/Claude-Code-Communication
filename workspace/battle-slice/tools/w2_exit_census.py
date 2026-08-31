#!/usr/bin/env python3
"""w2_exit_census.py — ★f_80057C00 の 「戻る経路」を 全数 数える★（worker2・2026-08-31・#930-W2a (1)）

★定義（数える前に 書く）★ — 「戻る経路」= ★この関数の 命令列から 制御が 出て 二度と 戻らない site★。
  E1 ★jr ra★            = 0x03E00008（標準の return）
  E2 ★jr rs (rs != ra)★ = 分岐表 / 関数 pointer 呼び出しの 形（★戻るとは限らない★ ので 別に 数える）
  E3 ★j target（tail）★ = 無条件 j で ★範囲外★ へ飛ぶ（jal は 戻ってくるので ★数えない★）
  E4 ★条件分岐で 範囲外★ = beq/bne/blez/bgtz/... の 着地が ★範囲外★
★数えないもの（明記）★
  ・jal / jalr（★呼んで 戻ってくる★）
  ・範囲内へ 飛ぶ 分岐（loop / 内部 arm）
  ・delay slot の 命令そのもの（★但し E1-E4 の 直後 1 命令は delay slot として 併記する★）
★母数★ = file offset [START, END) を 4 byte ずつ 線形 decode（★命令境界は 4 byte 固定 = MIPS★）。
★VA = 0x80052AE0 + offset★（btl_rel の base）。
"""
import sys, struct

BASE_VA = 0x80052AE0
START, END = 0x5120, 0x5498          # ★両端は base assert で 裏を取った★

def va(off): return BASE_VA + off

def rn(i): return "$%d" % i

def decode(w):
    op = w >> 26
    rs = (w >> 21) & 31; rt = (w >> 16) & 31; rd = (w >> 11) & 31
    fn = w & 0x3F; imm = w & 0xFFFF
    simm = imm - 0x10000 if imm & 0x8000 else imm
    tgt = w & 0x03FFFFFF
    return op, rs, rt, rd, fn, imm, simm, tgt

def main(path):
    data = open(path, 'rb').read()
    n = (END - START) // 4
    print("# file=%s  母数 offset [0x%X,0x%X) = %d byte = ★%d 命令★" % (path, START, END, END-START, n))
    print("# VA [0x%08X, 0x%08X)" % (va(START), va(END)))
    exits = {"E1": [], "E2": [], "E3": [], "E4": []}
    branch_in = 0; jal_cnt = 0
    for k in range(n):
        off = START + k*4
        w = struct.unpack_from('<I', data, off)[0]
        op, rs, rt, rd, fn, imm, simm, tgt = decode(w)
        nxt = struct.unpack_from('<I', data, off+4)[0] if off+4 < END else None
        note = "delay=%08x" % nxt if nxt is not None else "delay=★範囲外★"
        if op == 0 and fn == 0x08:                       # jr
            (exits["E1"] if rs == 31 else exits["E2"]).append((off, w, rs, note))
        elif op == 0 and fn == 0x09:                     # jalr = 呼び出し
            jal_cnt += 1
        elif op == 3:                                    # jal
            jal_cnt += 1
        elif op == 2:                                    # j
            dst = ((va(off) + 4) & 0xF0000000) | (tgt << 2)
            if not (va(START) <= dst < va(END)): exits["E3"].append((off, w, dst, note))
            else: branch_in += 1
        elif op in (1, 4, 5, 6, 7) or op in (0x14, 0x15, 0x16, 0x17):   # 分岐系
            dst = va(off) + 4 + (simm << 2)
            if not (va(START) <= dst < va(END)): exits["E4"].append((off, w, dst, note))
            else: branch_in += 1
    for k in ("E1","E2","E3","E4"):
        print("\n★%s = %d 件★" % (k, len(exits[k])))
        for e in exits[k]:
            if k in ("E1","E2"):
                off, w, rs, note = e
                print("   off=0x%04X VA=0x%08X  %08x  jr %s   %s" % (off, va(off), w, rn(rs), note))
            else:
                off, w, dst, note = e
                print("   off=0x%04X VA=0x%08X  %08x  → 0x%08X（範囲外）  %s" % (off, va(off), w, dst, note))
    tot = sum(len(v) for v in exits.values())
    print("\n★合計 = %d 件★（E1=%d / E2=%d / E3=%d / E4=%d）"
          % (tot, len(exits['E1']), len(exits['E2']), len(exits['E3']), len(exits['E4'])))
    print("★数えなかったもの★: 範囲内へ飛ぶ分岐 = %d 件 / jal・jalr = %d 件（★戻ってくるので 出口でない★）"
          % (branch_in, jal_cnt))
    print("★陽性対照★: 範囲内分岐 %d 件 と jal %d 件 が 出ている ⇒ ★decoder は 命令を 読めている★"
          % (branch_in, jal_cnt))

if __name__ == '__main__':
    main(sys.argv[1] if len(sys.argv) > 1 else '/home/ken/Desktop/vise/extracted/btl_rel.bin')
