#!/usr/bin/env python3
"""PBR Phase 0 — placement re-baseline 機械判定 (worker2, 2026-08-08)

read-only。RAM (生 2MB dump / DuckStation savestate) の field entity 配列を
extracted/maps/<map>/<map>.json の digimon 配列と照合し、shift 仮説を判定する。

判定は「どちらが正しいか」でなく ★「RAM bytes が何と一致したか」★ の形で出す。
shift 量 k を全走査するので H4 (どの k でも不成立) が明示的な outcome になる。

usage:
  pbr_p0_adjudicate.py <ram.bin|state.sav> [mapname] [repo]
    mapname 省略時 = 全 map 走査で同定を試みる

spec 出所【観測 = 他 worker の RE, a6fbcb6 docs/RE_field_entity_loader_2026-08-08.md】:
  loader 0x800bae54 / 配列 base 0x80145608 / stride 0xC4 / 容量 8 record
  type@+0x00 (u16, clear=0xFFFF) / pos.x,y,z@+0xA8,+0xAA,+0xAC (s16)
  rot_y@+0xB0 (s16) / ai_type@+0xBC (s8) / +0xBE
  clear ルーチン 0x800BB994 の loop 上限 s0<8 = 容量 8【観測 = worker1 disasm】

★誤 base 0x80147358 + type@+0x22 (7/23) は使わない。savestate prefix 0x1A62 の
  未補正に起因する測定 artifact であり、本 script の判定対象そのもの★
"""
import glob
import json
import os
import struct
import subprocess
import sys

RAM_BASE = 0x80000000
ARRAY_VA = 0x80145608
STRIDE = 0xC4
CLEAR_SENTINEL = 0xFFFF
# ★配列容量 = 8 record。index 8 以降は配列外 = 別データ構造で、「stale 残骸」ですらない★
CAPACITY = 8

OFF_TYPE, OFF_POSX, OFF_ROTY, OFF_AI, OFF_BE = 0x00, 0xA8, 0xB0, 0xBC, 0xBE

# DuckStation savestate 用 anchor (= gp-0x6cf8 の固定ポインタ 5 連)。
# 出所 = workspace/tools/savestate_ram.py
ANCHOR = bytes([0x84, 0x97, 0x15, 0x80, 0x84, 0xF7, 0x15, 0x80, 0x84, 0x17, 0x16, 0x80,
                0x84, 0x37, 0x16, 0x80, 0x20, 0x3A, 0x16, 0x80])
# ★生 2MB dump (ram_A.bin) 内の ANCHOR 実測 offset【観測】。savestate の prefix は
#   この既知値との差で「実測」する。推測で埋めると 7/23 と同じ穴に落ちる★
ANCHOR_RAM_OFF = 0x13E114
ZMAGIC = b"\x28\xb5\x2f\xfd"


# ---------------------------------------------------------------- RAM loading
def _decompress(data):
    pos = [i for i in range(len(data) - 4) if data[i:i + 4] == ZMAGIC]
    out = []
    for p, e in zip(pos, pos[1:] + [len(data)]):
        r = subprocess.run(["zstd", "-d", "--stdout", "-q"], input=data[p:e],
                           capture_output=True)
        if r.stdout:
            out.append(r.stdout)
    return out


def load_ram(path):
    """生 2MB dump と DuckStation savestate の両方を受ける。→ (buf, prefix)"""
    with open(path, "rb") as f:
        raw = f.read()
    if len(raw) == 2 * 1024 * 1024:
        return raw, 0
    if raw[:4] != b"DUCC":
        raise SystemExit(f"{path}: 2MB 生 dump でも DUCC savestate でもない")
    blob = None
    for fr in sorted(_decompress(raw), key=len, reverse=True):
        if ANCHOR in fr:
            blob = fr
            break
    if blob is None:
        raise SystemExit(f"{path}: anchor を含む展開 frame 無し = prefix 決定不能")
    prefix = blob.find(ANCHOR) - ANCHOR_RAM_OFF
    if prefix < 0:
        raise SystemExit(f"{path}: prefix 負 (0x{prefix:x}) = anchor 同定失敗")
    return blob, prefix


def read_records(buf, prefix=0, n=CAPACITY):
    out = []
    for i in range(n):
        b = prefix + (ARRAY_VA - RAM_BASE) + i * STRIDE
        r = buf[b:b + STRIDE]
        if len(r) < STRIDE:
            break
        out.append({
            "idx": i,
            "type_raw": struct.unpack_from("<H", r, OFF_TYPE)[0],
            "type": struct.unpack_from("<h", r, OFF_TYPE)[0],
            "ai": struct.unpack_from("<b", r, OFF_AI)[0],
            "pos": struct.unpack_from("<hhh", r, OFF_POSX),
            "roty": struct.unpack_from("<h", r, OFF_ROTY)[0],
            "be": struct.unpack_from("<H", r, OFF_BE)[0],
            "raw": r,
        })
    return out


def live_count(recs):
    """先頭から最初の clear sentinel までの record 数。→ (n, saturated)

    ★entity 数の権威ではない★。権威は生 .map 先頭 halfword と loader disasm。
    count == CAPACITY では sentinel が現れず、この rule は下限を上限に見せる
    (= 打ち切られた list の不在を否定として扱う誤り)。saturated=True で明示する。
    """
    n = 0
    for r in recs[:CAPACITY]:
        if r["type_raw"] == CLEAR_SENTINEL:
            return n, False
        n += 1
    return n, True


# ---------------------------------------------------------------- self-check
def self_check(buf, prefix, path):
    """権威測定の前に script 自身を既知値で検証する (feedback_audit_your_own_tool)。"""
    lines, ok = [], True
    recs = read_records(buf, prefix)
    lines.append(f"C1 record 数 = {len(recs)} / 容量 {CAPACITY}")
    ok &= len(recs) == CAPACITY

    sent = [r["idx"] for r in recs if r["type_raw"] == CLEAR_SENTINEL]
    lines.append(f"C2 clear sentinel 0xFFFF@+0x00 の index = {sent}"
                 f"{'  ★飽和 = sentinel 皆無★' if not sent else ''}")

    # C3 反証テスト: base を stride 半分ずらすと sentinel/構造が崩れるか
    bad = sum(1 for i in range(CAPACITY)
              if struct.unpack_from("<H", buf, prefix + (ARRAY_VA - RAM_BASE)
                                    + i * STRIDE + STRIDE // 2)[0] == CLEAR_SENTINEL)
    lines.append(f"C3 base を +stride/2 ずらした時の sentinel hit = {bad} "
                 f"(< {len(sent)} なら位相が正しい側にいる)")
    ok &= bad < len(sent) or not sent

    # C4 pos.y は field entity では 0 が支配的、rot_y は 0..4095 に収まるはず
    live, sat = live_count(recs)
    ybad = [r["idx"] for r in recs[:live] if not -64 <= r["pos"][1] <= 64]
    rbad = [r["idx"] for r in recs[:live] if not 0 <= r["roty"] < 4096]
    lines.append(f"C4 live {live} record の pos.y 逸脱={ybad} rot_y 範囲外={rbad}")
    ok &= not ybad and not rbad

    lines.insert(0, f"self-check [{'PASS' if ok else 'FAIL'}] {os.path.basename(path)}"
                    f"  prefix=0x{prefix:x}  live={live}"
                    f"{' ★cap 飽和 = 件数は下限★' if sat else ''}")
    return ok, lines, live, sat


# ---------------------------------------------------------------- json side
def load_maps(repo):
    """→ {mapname: [entity,...]}。digimon 0 件の map も残す (母集団を数えるため)"""
    out = {}
    for d in sorted(glob.glob(f"{repo}/extracted/maps/*/")):
        n = os.path.basename(d.rstrip("/"))
        p = f"{d}{n}.json"
        if not os.path.exists(p):
            continue
        with open(p) as f:
            doc = json.load(f)
        # ★dispatch 文言は "npcs" だが実 file の key は "digimon"★
        g = doc.get("digimon", doc.get("npcs")) or []
        out[n] = [{
            "idx": i, "type": e["type"], "ai": e["ai_type"],
            "pos": tuple(e["position"]), "roty": e["rotation"][1],
            "script_id": e.get("script_id"),
        } for i, e in enumerate(g)]
    return out


# ---------------------------------------------------------------- hypotheses
def shift_scan(recs, maps, live, ks=range(-2, 4)):
    """shift 量 k を全走査。pos は json[i]、type は json[i+k] と照合。

    ★k を 0/1 に閉じない = 仮説空間の開放 (H4/H5)。どの k でも 0 件なら
      「3 説とも棄却」が bytes に基づく結論として出る★
    """
    res = {}
    for k in ks:
        hits = []
        for m, g in maps.items():
            if not g:
                continue
            n = 0
            for r in recs[:live]:
                i = r["idx"]
                if i < len(g) and 0 <= i + k < len(g) \
                        and r["type"] == g[i + k]["type"] and r["pos"] == g[i]["pos"]:
                    n += 1
            if n == live:
                hits.append(m)
        res[k] = hits
    return res


def full_field_scan(recs, maps, live):
    """index join + 4 field (type/pos/ai/rot_y) 全一致で map を同定"""
    hits = []
    for m, g in maps.items():
        if len(g) < live:
            continue
        n = sum(1 for r in recs[:live]
                if r["type"] == g[r["idx"]]["type"] and r["pos"] == g[r["idx"]]["pos"]
                and r["ai"] == g[r["idx"]]["ai"] and r["roty"] == g[r["idx"]]["roty"])
        if n == live:
            hits.append(m)
    return hits


def poskey_join(recs, g, live):
    """H-poskey: index を捨て position 完全一致で対応付けてから type 照合。

    ★使う前に座標重複度を数える★。重複があると対応が ill-defined になるので
    AMBIGUOUS として明示し、黙って片方を採らない。
    """
    from collections import defaultdict
    bypos = defaultdict(list)
    for j in g:
        bypos[j["pos"]].append(j)
    dup = sum(1 for v in bypos.values() if len(v) > 1)
    rows = []
    for r in recs[:live]:
        c = bypos.get(r["pos"], [])
        if not c:
            rows.append((r["idx"], r["pos"], r["type"], "NO-MATCH", None, False))
        elif len(c) == 1:
            rows.append((r["idx"], r["pos"], r["type"], f"json[{c[0]['idx']}]",
                         c[0]["type"], r["type"] == c[0]["type"]))
        else:
            rows.append((r["idx"], r["pos"], r["type"],
                         "AMBIGUOUS json[" + ",".join(str(x['idx']) for x in c) + "]",
                         sorted({x["type"] for x in c}),
                         r["type"] in {x["type"] for x in c}))
    return rows, dup


# ---------------------------------------------------------------- main
def main():
    if len(sys.argv) < 2:
        print(__doc__)
        return 2
    path = sys.argv[1]
    mapname = sys.argv[2] if len(sys.argv) > 2 and sys.argv[2] != "-" else None
    repo = sys.argv[3] if len(sys.argv) > 3 else \
        "/home/ken/Desktop/Digimon/degimon_world_remake"

    buf, prefix = load_ram(path)
    ok, lines, live, sat = self_check(buf, prefix, path)
    for l in lines:
        print(l)
    print()
    if not ok:
        print("★self-check FAIL — 権威測定に使わない★")
        return 1

    recs = read_records(buf, prefix)
    print(f"RAM entity 配列 (base 0x{ARRAY_VA:08X} stride 0x{STRIDE:X} 容量 {CAPACITY}):")
    for r in recs:
        tag = "  <clear>" if r["type_raw"] == CLEAR_SENTINEL else ""
        print(f"  [{r['idx']}] type={r['type_raw']:6} ai={r['ai']:4} pos={r['pos']} "
              f"ry={r['roty']:6}{tag}")
    print()

    maps = load_maps(repo)
    nz = {m: g for m, g in maps.items() if g}
    print(f"母集団: 全 map={len(maps)} / digimon>=1={len(nz)} / 総 entry={sum(map(len, nz.values()))}")
    print()

    ff = full_field_scan(recs, maps, live)
    print(f"[map 同定] index join + 4 field 全一致 {live}/{live}: "
          f"全 {len(nz)} 中 ★{len(ff)} 件★ {ff}")
    sc = shift_scan(recs, maps, live)
    for k, hits in sc.items():
        tag = {0: "H-unshifted", 1: "H-shifted"}.get(k, f"H5(k={k:+})")
        print(f"[shift k={k:+}] {tag:12}: pos=json[i] & type=json[i+k] が {live}/{live} "
              f"= 全 {len(nz)} 中 {len(hits)} 件 {hits}")
    if not any(sc.values()):
        print("  ★どの k でも 0 件 = H4 (全 shift 説の棄却)★")
    print()

    target = mapname or (ff[0] if len(ff) == 1 else None)
    if target and target in maps:
        g = maps[target]
        rows, dup = poskey_join(recs, g, live)
        print(f"[H-poskey] {target}: json 座標重複 = {dup} 組"
              f"{' → position join 可' if dup == 0 else ' ★→ ill-defined、index join を優先★'}")
        agree = sum(1 for r in rows if r[5])
        for idx, pos, t, tgt, jt, a in rows:
            print(f"    RAM[{idx}] pos={pos} type={t} -> {tgt} json_type={jt} 一致={a}")
        amb = sum(1 for r in rows if str(r[3]).startswith("AMBIGUOUS"))
        print(f"  → {len(rows)} 件中 {agree} 件 type 一致 (うち一意対応 {len(rows) - amb} 件 / "
              f"座標重複ゆえ一意化不能 {amb} 件)")
        # ★食い違い = 「不一致」のこと。曖昧さは食い違いではないので別建てで報告する
        #   (両者を混ぜると mayo00 が偽の要調査に化ける)★
        if agree < len(rows):
            print("  → ★index join と position join が食い違う = ここが本当の発見★")
        elif amb:
            print(f"  → 食い違いなし。ただし {amb} 件は座標重複で position join が"
                  f" ill-defined = この map では index join のみが有効な key")
        else:
            print("  → 2 key 一致・曖昧さゼロ = position join も独立 cross-check として成立")
    return 0


if __name__ == "__main__":
    sys.exit(main())
