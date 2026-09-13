#!/usr/bin/env python3
"""PRESIDENT 側の器 — cut178 の 11 opcode を ★depth 1★ で機械判定する（2026-09-13）。

出すもの: band 表 base（router 直読）/ handler VA と lexical 終端 / 命令数 /
          yield(jal 0x800913C0) の有無 / gp-relative flow cell への store。
★器の検定★ = anchor 5 件（0x6C/0x4D/0x56/0x4F/0x4A）と一致しなければ ★数を出さない★。
★限界の明示★ = handler body のみ = 閉包なし ⇒ 『0 件』は (A) の ★下界★ であって演出の証明ではない。
換算 = base 0x80090800 / file_off = ram - base / image sha256 db26754d97f4673f881bd52494c29fbfafa9cdeed32817db76bc1465565c3e27
"""
import struct, sys, capstone

IMG = sys.argv[1] if len(sys.argv) > 1 else \
    '/home/ken/Desktop/Digimon/degimon_world_remake/extracted/slps_017_97.bin'
BASE = 0x80090800
YIELD, SETJMP = 0x800913C0, 0x800913B0
# router 0x800F0744 の range 分岐を直読して得た band → sub-interpreter（★推定していない★）
BANDS = {0x10: (0x27, 0x800EC4AC), 0x28: (0x3F, 0x800ECAB4),
         0x46: (0x58, 0x800ED434), 0x64: (0x7E, 0x800EDE88)}
ANCHOR = {0x6C: 0x800EEB40, 0x4D: 0x800ED864, 0x56: 0x800EDC84,
          0x4F: 0x800ED994, 0x4A: 0x800ED53C}
# gp の絶対値は ★既登録 fact『gp-0x6d08 = 0x8013E104』から導出★（独立計測ではない）
GP = 0x8013E104 + 0x6D08
FLOW = {-0x6cbc: 'mode(router 先頭 0x800F0748 が読む)', -0x6cb0: 'stop flag',
        -0x6cc8: 'script PC cell', -0x6d00: '0x4A の翻訳値 slot', -0x6d08: 'script 起点 actor'}

img = open(IMG, 'rb').read()
md = capstone.Cs(capstone.CS_ARCH_MIPS, capstone.CS_MODE_MIPS32 + capstone.CS_MODE_LITTLE_ENDIAN)
word = lambda a: struct.unpack_from('<I', img, a - BASE)[0]
dis = lambda a, n: list(md.disasm(img[a - BASE:a - BASE + n * 4], a))

tables = {}
for lo, (hi, fn) in BANDS.items():
    hi_lui = base = None
    for i in dis(fn, 40):
        if i.mnemonic == 'lui':
            hi_lui = int(i.op_str.split(', ')[1], 16)
        elif i.mnemonic in ('addiu', 'ori') and hi_lui is not None:
            try: imm = int(i.op_str.split(', ')[2], 16)
            except Exception: continue
            cand = (hi_lui << 16) + (imm if imm < 0x8000 else imm - 0x10000)
            if 0x80110000 <= cand < 0x80120000:
                base = cand; break
    tables[lo] = (hi, fn, base)
    print(f"band 0x{lo:02X}-0x{hi:02X}  sub=0x{fn:08X}  table base(site 直読)=0x{base:08X}")

def handler(op):
    for lo, (hi, fn, base) in tables.items():
        if lo <= op <= hi:
            return word(base + 4 * (op - lo)), lo, hi, base
    raise KeyError(op)

print("\n=== 器の検定（anchor）===")
ok = True
for op, exp in ANCHOR.items():
    got = handler(op)[0]
    ok &= got == exp
    print(f"  0x{op:02X}: 器=0x{got:08X} / anchor=0x{exp:08X}  {'OK' if got == exp else '★NG★'}")
if not ok:
    sys.exit("★検定 FAIL = 数を出してはいけない★")
print("  ⇒ 検定 PASS")

CNT = {0x56: 87, 0x29: 58, 0x4C: 10, 0x34: 8, 0x4D: 4, 0x4A: 3, 0x4F: 2,
       0x6C: 1, 0x2B: 1, 0x23: 1, 0x22: 1}
print("\nop   件数 handler      終端       命令数 yield flow-cell store（★depth 1・閉包なし★）")
for op in (0x6C, 0x4D, 0x4C, 0x56, 0x4F, 0x4A, 0x22, 0x34, 0x29, 0x2B, 0x23):
    h, lo, hi, base = handler(op)
    ends = sorted({word(base + 4 * i) for i in range(hi - lo + 1)} | {0x80100000})
    end = min([e for e in ends if e > h], default=h + 0x200)
    ins = dis(h, (end - h) // 4)
    y = sum(1 for i in ins if i.mnemonic == 'jal' and int(i.op_str, 16) == YIELD)
    fl = set()
    for i in ins:
        if i.mnemonic in ('sb', 'sh', 'sw') and '($gp)' in i.op_str:
            d = int(i.op_str.split(', ')[1].split('(')[0], 16)
            d = d if d < 0x8000 else d - 0x10000
            if d in FLOW:
                fl.add(f"gp{d:+#x}(=0x{GP + d:08X}) {FLOW[d]}")
    print(f"0x{op:02X} {CNT[op]:4d} 0x{h:08X} 0x{end:08X} {len(ins):5d} "
          f"{'★'+str(y)+'★' if y else '  0  '}  {', '.join(sorted(fl)) or '-'}")

j = 0x0C000000 | ((YIELD >> 2) & 0x03FFFFFF)
hits = [BASE + o for o in range(0, len(img) - 3, 4) if struct.unpack_from('<I', img, o)[0] == j]
print(f"\nyield の口 census = jal 0x{YIELD:08X} 全走査(4byte 整列) = {len(hits)} 件")
print("  " + " ".join(f"0x{a:08X}" for a in hits))
