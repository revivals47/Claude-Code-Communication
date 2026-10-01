#!/usr/bin/env python3
"""【段 5 の写し（worker2, boss1 02:36）: drafts/stageC/live_rebase.py から 3 つ変えた = (1) 基準の dir は tools/regress_all.sh の
LIVE_BASE_<N> の既定（--project の regress_all.sh を読む、--base N=dir で上書き）= 種 26 の 5e50ac7_s26_014332 を含む、(2) AUDIO.txt も取る
（段 3 では手で足した = stage3_swap.sh の 2）、(3) 既定の種 = 20260925,1,26。--sheet <png> で changed / gone / added の画を 旧｜新 で並べた 1 枚。】
Live baseline re-take in one step (PRESIDENT 13:1x ②: the reference values will move again - agent2's step 1 fixes them
once more - so the live baselines are re-taken now and again later; this is the BC1_SWAP_TABLE / SKY_SWAP_TABLE procedure
as one tool). worker2, API090_PLAN_W2.md §C.

For each seed: baseline dir B = shots/player_live/ae3b5c4_s<seed>_231126 (regress_all.sh:69-70), source dir
S = <regress dir>/live/seed_<seed>. The files taken: every live_*.png in S or B, and RESULT.txt / live.log / ARGS.txt
(the logic sequence the live regress compares = RESULT's page= and screens=, tools/live_regress.sh:6-8).
  - changed (sha differs): old renamed to <tag>_<name>, the source copied in.
  - added (only in S): copied in (NOTE says "added").
  - gone (only in B): renamed to <tag>_<name> (live_regress counts live_*.png only, so it leaves the count).
  - same sha: untouched.
Default = dry run: prints the table (name, state, sha before, source sha) and writes it to --table; nothing is moved.
--apply: re-reads every sha, refuses if any differs from the table file given with --table (the table is the pre-check),
renames / copies, checks every new file's sha = source and every <tag>_ file's sha = the old one, then appends to each B's
NOTE_baseline_changes.md one line per file with the reason. Any failed check stops before the NOTE lines are written.
usage: live_rebase.py <regress dir> --tag pre090 --reason "..." --table <md> [--seeds 20260925,1] [--shots <dir>] [--apply]
"""
import argparse, hashlib, os, shutil, sys, time

def sha(p):
    return hashlib.sha256(open(p, 'rb').read()).hexdigest()

def plan(src, base, tag):
    names = sorted({n for d in (src, base) for n in os.listdir(d) if n.startswith('live_') and n.endswith('.png')})
    names += ['RESULT.txt', 'live.log', 'ARGS.txt', 'AUDIO.txt']
    rows = []
    for n in names:
        s, b = os.path.join(src, n), os.path.join(base, n)
        hs = sha(s) if os.path.exists(s) else None
        hb = sha(b) if os.path.exists(b) else None
        if hs and hb: state = 'same' if hs == hb else 'changed'
        elif hs: state = 'added'
        elif hb: state = 'gone'
        else: continue
        if state != 'same' and os.path.exists(os.path.join(base, f'{tag}_{n}')):
            sys.exit(f'[live_rebase] {base}/{tag}_{n} exists already: pick another --tag')
        rows.append((n, state, hb, hs))
    return rows

def sheet(plans, out, tag):
    """old | new for every picture that is not the same (gone: old | blank, added: blank | new); a label row per pair."""
    from PIL import Image, ImageDraw, ImageFont
    try: f = ImageFont.truetype('/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc', 22)
    except Exception: f = ImageFont.load_default()
    pairs = [(seed, n, st, os.path.join(base, n), os.path.join(src, n)) for seed, (src, base, rows) in plans.items()
             for n, st, hb, hs in rows if n.endswith('.png') and st != 'same']
    if not pairs: print('[live_rebase5] sheet: no picture differs - none written'); return
    W, H = 960, 540; im = Image.new('RGB', (W * 2, (H + 34) * len(pairs)), (20, 20, 24)); d = ImageDraw.Draw(im)
    for i, (seed, n, st, b, s) in enumerate(pairs):
        y = i * (H + 34); d.text((8, y + 4), f'seed {seed}  {n}  {st}   旧（今の基準）| 新（この回）', fill=(240, 224, 158), font=f)
        for j, p in enumerate((b, s)):
            if os.path.exists(p): im.paste(Image.open(p).convert('RGB').resize((W, H)), (j * W, y + 34))
    im.save(out); print(f'[live_rebase5] sheet {out}: {len(pairs)} pair(s)')

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('regress'); ap.add_argument('--tag', required=True); ap.add_argument('--reason', required=True)
    ap.add_argument('--table', required=True); ap.add_argument('--seeds', default='20260925,1,26')
    ap.add_argument('--shots', default='/home/ken/Documents/Claude-Code-Communication/workspace/ikada-unity/shots')
    ap.add_argument('--apply', action='store_true')
    ap.add_argument('--project', default='/home/ken/Documents/ikada-unity-stage5', help='the tree whose tools/regress_all.sh names the baselines')
    ap.add_argument('--base', action='append', default=[], help='N=dir: this seed\'s baseline dir (over regress_all.sh)')
    ap.add_argument('--sheet', help='png: old | new side by side for every changed / gone / added picture (dry run too)')
    a = ap.parse_args()
    import re
    ra = open(os.path.join(a.project, 'tools', 'regress_all.sh'), encoding='utf-8').read()
    over = dict(x.split('=', 1) for x in a.base)
    def basedir(seed):
        if seed in over: return over[seed]
        m = re.search(r'^export LIVE_BASE_' + seed + r'=\$\{LIVE_BASE_' + seed + r':-\$SHOTS/(\S+?)\}\s*$', ra, re.M)
        if not m: sys.exit(f'[live_rebase5] no LIVE_BASE_{seed} default in {a.project}/tools/regress_all.sh - give --base {seed}=<dir>')
        return os.path.join(a.shots, m.group(1))
    plans = {}
    for seed in a.seeds.split(','):
        src = os.path.join(a.regress, 'live', f'seed_{seed}'); base = basedir(seed)
        for d in (src, base):
            if not os.path.isdir(d): sys.exit(f'[live_rebase] no dir {d}')
        plans[seed] = (src, base, plan(src, base, a.tag))
    lines = [f'# live baseline re-take ({a.tag}) - {"APPLY" if a.apply else "dry run"} {time.strftime("%Y-%m-%d %H:%M")}',
             f'- reason: {a.reason}', f'- source regress: {a.regress}', '',
             '| seed | file | state | sha256 before (baseline) | sha256 source |', '|---|---|---|---|---|']
    for seed, (src, base, rows) in plans.items():
        for n, st, hb, hs in rows: lines.append(f'| {seed} | {n} | {st} | {hb or "-"} | {hs or "-"} |')
    counts = {st: sum(1 for _, (_, _, rs) in plans.items() for r in rs if r[1] == st) for st in ('changed', 'added', 'gone', 'same')}
    lines.append(f'- counts: {counts}')
    if a.sheet:
        sheet(plans, a.sheet, a.tag)
    if not a.apply:
        open(a.table, 'w').write('\n'.join(lines) + '\n'); print('\n'.join(lines)); return
    # apply: the table written by the dry run is the pre-check
    want = {}
    for l in open(a.table):
        p = [x.strip() for x in l.split('|')]
        if len(p) == 7 and p[1] not in ('seed', '---'): want[(p[1], p[2])] = (p[3], p[4], p[5])
    for seed, (src, base, rows) in plans.items():
        for n, st, hb, hs in rows:
            if want.get((seed, n)) != (st, hb or '-', hs or '-'):
                sys.exit(f'[live_rebase] seed {seed} {n}: now {st} {hb} {hs} != table {want.get((seed, n))} - nothing moved')
    if len(want) != sum(len(r) for _, _, r in plans.values()):
        sys.exit(f'[live_rebase] table has {len(want)} rows, now {sum(len(r) for _, _, r in plans.values())} - nothing moved')
    done = []
    for seed, (src, base, rows) in plans.items():
        for n, st, hb, hs in rows:
            b, old = os.path.join(base, n), os.path.join(base, f'{a.tag}_{n}')
            if st in ('changed', 'gone'): os.rename(b, old)
            if st in ('changed', 'added'): shutil.copy2(os.path.join(src, n), b)
            if st in ('changed', 'gone') and sha(old) != hb: sys.exit(f'[live_rebase] {old} sha != before')
            if st in ('changed', 'added') and sha(b) != hs: sys.exit(f'[live_rebase] {b} sha != source')
            done.append((seed, base, n, st, hb, hs))
    stamp = time.strftime('%Y-%m-%d %H:%M')
    for seed, (src, base, rows) in plans.items():
        note = [f'- {stamp} live_rebase.py ({a.tag}): {a.reason}', f'  - 新しい file の出所: {src}/。旧は {a.tag}_<名前>。表 = {a.table}。']
        for s2, b2, n, st, hb, hs in done:
            if s2 != seed: continue
            if st == 'changed': note.append(f'  - {n}: sha256 差し替え前 {hb} → 差し替え後 {hs}（出所と同じ）。旧 = {a.tag}_{n}。')
            elif st == 'added': note.append(f'  - {n}: 新しく足した（sha256 {hs}、出所と同じ）。')
            elif st == 'gone': note.append(f'  - {n}: 出所に無い → {a.tag}_{n} に移した（sha256 {hb}）。')
        same = [n for n, st, _, _ in rows if st == 'same']
        note.append(f'  - 替えていない（sha 同じ）: {", ".join(same) if same else "なし"}。')
        open(os.path.join(base, 'NOTE_baseline_changes.md'), 'a').write('\n'.join(note) + '\n')
    print(f'[live_rebase] applied: {counts}; every new file = source, every {a.tag}_ file = before; NOTE lines appended')

if __name__ == '__main__':
    main()
