#!/usr/bin/env python3
# 3 戦目 ① — capture.gdb の 1 行を 人の言葉に直す（判定は ★撃つ前に固定した式★ どおり）
# 入力 = 標準入力（gdb の出力をそのまま流す）／ 出力 = 攻撃 1 回につき 1 行
import sys, json, os, re

HERE = os.path.dirname(os.path.abspath(__file__))
MJ = os.path.join(HERE, "attribute_matrix.json")
M49 = json.load(open(MJ))["matrix"]          # 49 byte・row=技element / col=属性id
NO_ATTR, NO_ATTR_VAL, DIV = 255, 10, 30

def a1_of(power, atk, de):
    diff = max(-500, min(500, atk - de))
    q = power * diff
    q = int(q / 500)                          # 0 方向切り捨て（MIPS div）
    return power + q

def rng(base):
    return (base * 90 // 100, base * 110 // 100)

def eff_sum(elem, attrs):
    s = 0
    for a in attrs:
        s += NO_ATTR_VAL if a == NO_ATTR else M49[elem * 7 + a]
    return s

PAT = re.compile(
    r"HIT dmg=(\d+) skill=(\d+) elem=(\d+) atk=(\d+) def=(\d+) species=(\d+) "
    r"attr=(\d+),(\d+),(\d+) row=([0-9a-f]{32})")

n = 0
print("★準備できました。戦ってください。1 回 攻撃を受けるたび 1 行 出ます。★", flush=True)
for line in sys.stdin:
    m = PAT.search(line)
    if not m:
        continue
    n += 1
    dmg, skill, elem, atk, de, sps = (int(m.group(i)) for i in range(1, 7))
    attrs = [int(m.group(i)) for i in (7, 8, 9)]
    row = bytes.fromhex(m.group(10))
    power = int.from_bytes(row[4:6], "little", signed=True)   # ★仮説: +0x04(s16) = power★

    if elem > 6:
        print("%2d 回目: ダメージ %-4d ← ★この技は属性が %d で表の外です。判定できません★"
              % (n, dmg, elem), flush=True)
        continue

    A1 = a1_of(power, atk, de)
    M = eff_sum(elem, attrs)
    lo, hi = rng(M * A1 // DIV)
    nlo, nhi = rng(30 * A1 // DIV)            # 表を使わない場合（neutral）
    inside = lo <= dmg <= hi
    n_inside = nlo <= dmg <= nhi
    if inside and not n_inside:
        v = "★合っています（表を使った予測どおり・表を使わない予測では説明できません）★"
    elif inside and n_inside:
        v = "合っています（ただし ★表を使わない予測でも説明できる★ ので この 1 回では決まりません）"
    elif not inside and n_inside:
        v = "★★合っていません（表を使わない予測の側に入りました）★★"
    else:
        v = "★★どちらの予測にも入りません★★"
    print("%2d 回目: ダメージ %-4d 予測 %d〜%d ／ 表なしなら %d〜%d  %s"
          % (n, dmg, lo, hi, nlo, nhi, v), flush=True)
    print("        （技 %d 属性 %d ／ 攻撃 %d 守り %d 威力 %d ／ 相手 %d の属性 %s）"
          % (skill, elem, atk, de, power, sps, attrs), flush=True)
    if skill == 2 and power != 66:
        print("        ★注意: 技 2 の威力が 66 ではなく %d です。威力の列の見当が外れています。"
              "この行の予測は信用しないでください★" % power, flush=True)
