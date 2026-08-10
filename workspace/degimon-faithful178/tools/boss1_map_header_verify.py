#!/usr/bin/env python3
"""boss1 が 2026-08-10 に実行した .map header 照合の恒久化。

PRESIDENT (49)「閉じた と 道具が知っている は別」の適用。
handoff の「閉じた量」#2 と #6 の実装先が scratchpad の使い捨て script だったため恒久化する。

検定する命題(いずれも 2026-08-10 に反例 0 で通ったもの):
  R1: tilemap の実体 10,000 byte は raw .map 内に一意に存在する          期待 242/242、重複 0
  R2: header 語数 = word0/4、tilemap offset = header の最終語            期待 241/241
  R3: R2 で切り出した 10,000 byte が extracted json の tilemap と bit 一致 期待 242/242
  R4: widx(read6) = A + B + 3   (A=map表+0x0A, B=+0x0B、guard 時 widx=2)  期待 241/241
      ※ 同名 map が複数 table entry を持つ場合、いずれかの index で成立すれば可
      ※ 定数は 3。worker1 の初報 2 は read5 の数え落としで、boss1 実測が 27/241 で反証した

走査範囲:
  母集団 = raw .map と extracted json が両方在る map。mgen17 は map 表に名前が無いため R4 の対象外。
  根拠種別 = 機構(EXE の loader が読む単位)+ 全数照合。

使い方: python3 boss1_map_header_verify.py [--verbose]
"""
import glob
import json
import os
import struct
import sys
import base64
import collections

RAW_GLOB = '/home/ken/Desktop/Digimon/degimon/CD/DEGIMON/map/map*/*.map'
JSON_GLOB = '/home/ken/Desktop/Digimon/degimon_world_remake/extracted/maps/*/*.json'
EXE = '/home/ken/Desktop/Digimon/degimon_world_remake/extracted/slps_017_97.bin'
EXE_SHA256_HEAD = 'db26754d97f4673f'   # 3 path で一致を確認済(2026-08-10)
MAP_TABLE_VA = 0x8013541C
EXE_BASE_VA = 0x80090800
TILEMAP_BYTES = 100 * 100


def load_map_table(exe: bytes):
    """map 表を name -> [(idx, A, B, flags), ...] で返す。同名が複数 index を持つ。"""
    off = MAP_TABLE_VA - EXE_BASE_VA
    table = collections.defaultdict(list)
    for i in range(400):
        e = exe[off + i * 16: off + i * 16 + 16]
        if len(e) < 16:
            break
        raw = e[0:10].split(b'\x00')[0]
        try:
            name = raw.decode('ascii').lower()
        except UnicodeDecodeError:
            continue
        if not name or not name.replace('_', '').isalnum():
            continue
        table[name].append((i, e[10], e[11], e[12]))
    return table


def header_words(blob: bytes, n=12):
    return [struct.unpack_from('<I', blob, k * 4)[0] for k in range(n)]


def main(verbose=False):
    exe = open(EXE, 'rb').read()
    raws = {os.path.basename(p)[:-4].lower(): p for p in glob.glob(RAW_GLOB)}
    jsons = {os.path.basename(p)[:-5].lower(): p for p in glob.glob(JSON_GLOB)}
    table = load_map_table(exe)
    common = sorted(set(raws) & set(jsons))

    r1 = r2 = r3 = 0
    r4_hit = r4_guard = 0
    r4_pop = 0
    fails = collections.defaultdict(list)

    for name in common:
        blob = open(raws[name], 'rb').read()
        tile = base64.b64decode(json.load(open(jsons[name]))['tilemap']['data'])

        # R1: 一意存在
        pos = blob.find(tile)
        if pos < 0:
            fails['R1'].append((name, 'not found'))
            continue
        if blob.find(tile, pos + 1) >= 0:
            fails['R1'].append((name, 'duplicate'))
        else:
            r1 += 1

        # R2: header 語数 = word0/4、最終語が tilemap offset
        w0 = struct.unpack_from('<I', blob, 0)[0]
        if w0 % 4 == 0 and 2 <= w0 // 4 and (w0 // 4) * 4 <= len(blob):
            pred = struct.unpack_from('<I', blob, (w0 // 4 - 1) * 4)[0]
            if pred == pos:
                r2 += 1
                # R3: 切り出した内容が json と bit 一致
                if blob[pred:pred + TILEMAP_BYTES] == tile:
                    r3 += 1
                else:
                    fails['R3'].append((name, 'content mismatch'))
            else:
                fails['R2'].append((name, f'pred=0x{pred:X} true=0x{pos:X}'))
        else:
            fails['R2'].append((name, f'w0=0x{w0:X} 異常'))

        # R4: widx = 3 + A + B(いずれかの table index)、guard 時 widx = 2
        if name not in table:
            continue
        r4_pop += 1
        words = header_words(blob)
        widx = next((k for k in range(len(words)) if words[k] == pos), None)
        cands = [(A, B) for _, A, B, _ in table[name]]
        if any(widx == 3 + A + B for A, B in cands):
            r4_hit += 1
        elif widx == 2 and all(A + B == 0 for A, B in cands):
            r4_guard += 1
        else:
            fails['R4'].append((name, f'widx={widx} cands={cands}'))

    n = len(common)
    print(f'母集団 = raw と json が両方在る map: {n}   走査率 {n}/242 = {n/242*100:.1f}%')
    print(f'  R1 tilemap が raw 内に一意存在        {r1}/{n}')
    print(f'  R2 header 最終語 = tilemap offset      {r2}/{n}')
    print(f'  R3 切り出しが json と bit 一致          {r3}/{n}')
    print(f'  R4 widx = 3+A+B ({r4_hit}) + guard ({r4_guard}) = {r4_hit + r4_guard}/{r4_pop}'
          f'   ※ map 表に名前が無い map は対象外')
    bad = sum(len(v) for v in fails.values())
    print(f'  ★反例 合計 = {bad} 件★')
    if bad or verbose:
        for k in sorted(fails):
            for item in fails[k]:
                print(f'    {k}: {item}')
    return 0 if bad == 0 else 1


if __name__ == '__main__':
    sys.exit(main('--verbose' in sys.argv))
