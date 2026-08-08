#!/usr/bin/env python3
"""PBR Phase 0 — oracle 監査 / 補助判定 (worker2, 2026-08-08)

pbr_p0_adjudicate.py が「mayo00 と一致」と出した時、それが
★mayo00 だから一致したのか、たまたま緩い照合で誰にでも一致するのか★ を切り分ける。

機能:
  A. 全 map の JSON に対して RAM record 0..live_n-1 を照合し、母集団つきで順位を出す
     (= map 同定の一意性テスト。feedback_verify_the_oracle_not_just_the_match)
  B. 複数 RAM dump 間で record 0..N が bit-exact かを確認
  C. clear sentinel (type=0xFFFF) だが pos が構造化されている record の由来探索
     (= 前 load の残骸なら別 map の JSON に position が居るはず)
  D. 1 record の raw 0xC4 byte 内に JSON の一意 scalar (script_id/hp/offense 等) が
     居るかを全 offset 探索 → per-record fingerprint で pairing を裏取り
"""
import glob
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from pbr_p0_adjudicate import (  # noqa: E402
    load_ram, read_records, load_json_entities, probe_scalar, CLEAR_SENTINEL,
)


def all_maps(repo):
    out = []
    for d in sorted(glob.glob(f"{repo}/extracted/maps/*/")):
        name = os.path.basename(d.rstrip("/"))
        p = f"{d}{name}.json"
        if os.path.exists(p):
            out.append(name)
    return out


def score_map(recs, js, live_n):
    """RAM record 0..live_n-1 と json[i] の (type,pos,ai,roty) 4 field 完全一致数"""
    n = 0
    for r in recs[:live_n]:
        i = r["idx"]
        if i >= len(js):
            break
        j = js[i]
        if (r["type"] == j["type"] and r["pos"] == j["pos"]
                and r["ai"] == j["ai"] and r["roty"] == j["roty"]):
            n += 1
    return n


def cmd_A(repo, ram_path, live_n):
    buf = load_ram(ram_path)
    recs = read_records(buf, 32)
    maps = all_maps(repo)
    print(f"[A] map 同定の一意性テスト — 母集団 = 全 {len(maps)} map")
    print(f"    照合 = RAM record 0..{live_n - 1} vs json[i] の 4 field "
          f"(type/pos/ai/rot_y) 完全一致数")
    rows = []
    for m in maps:
        try:
            _, _, js = load_json_entities(repo, m)
        except SystemExit:
            continue
        rows.append((score_map(recs, js, live_n), len(js), m))
    rows.sort(reverse=True)
    for s, njs, m in rows[:8]:
        print(f"    {s}/{live_n} 一致  {m}  (json 母集団 {njs} 件)")
    top = [r for r in rows if r[0] == rows[0][0]]
    print(f"    → 最高スコア {rows[0][0]}/{live_n} を取る map は {len(top)} 件: "
          f"{[t[2] for t in top]}")
    nonzero = [r for r in rows if r[0] > 0]
    print(f"    → 1 件以上一致した map は全 {len(maps)} 中 {len(nonzero)} 件")
    print()


def cmd_B(ram_paths, n=24):
    print(f"[B] 複数 RAM dump 間の record bit-exact 比較 ({len(ram_paths)} file)")
    bufs = {os.path.basename(p): load_ram(p) for p in ram_paths}
    names = list(bufs)
    ref = names[0]
    refrecs = read_records(bufs[ref], n)
    for nm in names[1:]:
        recs = read_records(bufs[nm], n)
        diff = [i for i in range(n) if recs[i]["raw"] != refrecs[i]["raw"]]
        same = [i for i in range(n) if i not in diff]
        print(f"    {ref} vs {nm}: raw 0xC4 byte 完全一致 = {len(same)}/{n} record"
              f"  差分 index={diff}")
    print()


def cmd_C(repo, ram_path):
    """type=0xFFFF だが pos が構造化されている record の position を全 map から探す"""
    buf = load_ram(ram_path)
    recs = read_records(buf, 24)
    targets = [r for r in recs
               if r["type_raw"] == CLEAR_SENTINEL and r["pos"] != (0, 0, 0)]
    print(f"[C] cleared(type=0xFFFF) だが pos 非ゼロな record = {len(targets)} 件の由来探索")
    maps = all_maps(repo)
    for r in targets:
        hits = []
        for m in maps:
            try:
                _, _, js = load_json_entities(repo, m)
            except SystemExit:
                continue
            for j in js:
                if j["pos"] == r["pos"]:
                    hits.append((m, j["idx"], j["type"], j["ai"], j["roty"]))
        print(f"    RAM[{r['idx']}] pos={r['pos']} ai={r['ai']} ry={r['roty']}"
              f" → 全 {len(maps)} map 中 hit {len(hits)} 件: {hits[:6]}")
    print()


def cmd_D(repo, ram_path, mapname, live_n):
    """per-record 一意 scalar が RAM record 内に居るか → pairing の独立裏取り"""
    buf = load_ram(ram_path)
    recs = read_records(buf, 32)
    _, _, js = load_json_entities(repo, mapname)
    print(f"[D] per-record fingerprint 探索 ({mapname})")

    # 候補 field: record 間で値が異なる = 一意性がある scalar のみ使う
    cand = ["script_id", "hp", "mp", "offense", "defense", "speed", "brains",
            "bits", "tracking_range"]
    useful = []
    for c in cand:
        vals = [j["raw"].get(c) for j in js]
        if len(set(vals)) > 1:
            useful.append((c, vals))
    print(f"    record 間で値が割れる field = {[u[0] for u in useful]}")

    for c, vals in useful:
        # 全 record 共通の offset で、その record の期待値が読める offset を求める
        common = None
        for r in recs[:live_n]:
            i = r["idx"]
            if i >= len(js):
                break
            offs = set()
            for w in (1, 2):
                for sg in (False, True):
                    for o in probe_scalar(r["raw"], vals[i], w, sg):
                        offs.add((o, w, sg))
            common = offs if common is None else (common & offs)
        common = sorted(common or [])
        tag = "★一致 offset あり★" if common else "(共通 offset なし)"
        print(f"    {c}: 全 {live_n} record で成立する (offset,width,signed) = "
              f"{[(hex(o), w, s) for o, w, s in common][:8]} {tag}")
    print()


def main():
    repo = "/home/ken/Desktop/Digimon/degimon_world_remake"
    cap = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                       "runtime_capture_2026-07-25")
    rams = sorted(glob.glob(f"{cap}/ram_*.bin"))
    ram_a = f"{cap}/ram_A.bin"
    live_n = 5
    cmd_A(repo, ram_a, live_n)
    cmd_B(rams)
    cmd_C(repo, ram_a)
    cmd_D(repo, ram_a, "mayo00", live_n)


if __name__ == "__main__":
    main()
