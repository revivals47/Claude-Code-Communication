#!/usr/bin/env python3
"""§7.50 (worker3, PRESIDENT 03:0x GO): the mock baseline's 06S_A_sans / 06S_B_serif swapped in place in shots/player/a9106ea_234105
(the default baseline, tools/regress_all.sh BASELINE). Source = the player shots of regress f2b113b_021733 (shots/player/f2b113b_022239).
Old kept as pre-stance_<name> (tools/baseline_pin.sh counts <ID>_A_sans / <ID>_B_serif only). Default = dry (prints, moves nothing);
--apply: every sha checked against WANT first (nothing moved if one differs), rename, copy, check new = source and pre-stance_ = old,
then one NOTE section appended to NOTE_baseline.md. Any failed check stops before the NOTE."""
import hashlib, os, shutil, sys, time
S = '/home/ken/Documents/Claude-Code-Communication/workspace/ikada-unity/shots/player/'
BASE, SRC, TAG = S + 'a9106ea_234105', S + 'f2b113b_022239', 'pre-stance'
def sha(p): return hashlib.sha256(open(p, 'rb').read()).hexdigest()
def main():
    apply = '--apply' in sys.argv
    rows = []
    for n in ('06S_A_sans.png', '06S_B_serif.png'):
        b, s, old = os.path.join(BASE, n), os.path.join(SRC, n), os.path.join(BASE, f'{TAG}_{n}')
        if os.path.exists(old): sys.exit(f'[mock_apply] {old} exists already - nothing moved')
        rows.append((n, b, s, old, sha(b), sha(s)))
    for n, b, s, old, hb, hs in rows: print(f'{n}: base {hb}  source {hs}  {"same" if hb == hs else "changed"}')
    if not apply: print('[mock_apply] dry run - nothing moved'); return
    want = dict(l.split()[:2] for l in open(os.path.join(os.path.dirname(__file__), 'mock_apply_want.md')) if l.strip())
    for n, b, s, old, hb, hs in rows:
        if want.get(n) != f'{hb}:{hs}': sys.exit(f'[mock_apply] {n}: now {hb}:{hs} != want {want.get(n)} - nothing moved')
    for n, b, s, old, hb, hs in rows:
        os.rename(b, old); shutil.copy2(s, b)
        if sha(b) != hs or sha(old) != hb: sys.exit(f'[mock_apply] {n}: sha check after the move failed - NOTE not written')
    note = [f'\n## {time.strftime("%Y-%m-%d %H:%M")} worker3: 06S swapped in place (PRESIDENT 2026-10-06 03:0x GO via boss1; ROD_REST_A_W3.md §7.50)',
            '- why: the sinking stance by default (the client 02:0x「3.09mのほうが迫力があっていい」, c206 left): the rod 3.09 m turned 25.9 deg about the butt, the butt 1.0 m above the deck (0.65 up / 1.39 forward); the window unchanged',
            f'- source: the player shots of regress f2b113b_021733 ({SRC}), tree track3/sink-stance-default f2b113b, logic pin unchanged = b80715f']
    for n, b, s, old, hb, hs in rows: note.append(f'- {n}: sha256 {hb[:16]} -> {hs[:16]} (= source); old kept as {TAG}_{n}')
    note.append('- the other 28 pictures untouched (0 px in that regress); PIN: rewritten by tools/baseline_pin.sh after the regress that sees 30/30 0 px')
    open(os.path.join(BASE, 'NOTE_baseline.md'), 'a').write('\n'.join(note) + '\n')
    print('[mock_apply] applied: 2 changed, new = source, pre-stance_ = old, NOTE appended')
main()
