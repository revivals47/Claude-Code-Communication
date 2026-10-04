#!/usr/bin/env python3
"""Every place Unity draws a logic text field that can carry ⟦tokens⟧ (ikada-sim b80715f: ActionTokens.Of reaches PanelView.Lines
(DayFlowPanels, TackleShop, GameFlow.Free, PracticeOptions), PanelView.Note (DayFlow.LeaveHint, DayFlowPanels.cs:74) and HudView.Drill
(Practice.Intro) only), and whether ButtonGlyphs.ReplaceTokens is applied within 6 lines before (or on) the line. usage: token_mouths.py <git rev> [repo]
worker2, boss1 19:1x / PRESIDENT 19:2x (DEV_VIEW_W2.md §14)."""
import re, subprocess, sys
rev = sys.argv[1]; repo = sys.argv[2] if len(sys.argv) > 2 else '/home/ken/Documents/ikada-unity-track2'
files = [f for f in subprocess.run(['git', '-C', repo, 'ls-tree', '-r', '--name-only', rev, 'Assets/Scripts'], capture_output=True, text=True).stdout.split()
         if f.endswith('.cs') and '/Perf/' not in f and '/Tests/' not in f and '/Mocks/' not in f]
pat = {'PanelView.Lines': re.compile(r'\b(p|Panel|s\.Panel|panel)\??\.Lines\b(?!\.Count)'),
       'PanelView.Note': re.compile(r'\b(p|Panel|s\.Panel|panel)\??\.Note\b'),
       'HudView.Drill': re.compile(r'\bHud\??\.Drill\b')}
rows = []
for f in files:
    src = subprocess.run(['git', '-C', repo, 'show', f'{rev}:{f}'], capture_output=True, text=True).stdout.split('\n')
    for i, l in enumerate(src):
        s = l.strip()
        if s.startswith('//'): continue
        for k, p in pat.items():
            if p.search(l.split('//')[0]):
                ctx = '\n'.join(src[max(0, i - 6):i + 1])
                rows.append((k, f.replace('Assets/Scripts/', ''), i + 1, 'ReplaceTokens' in ctx, s[:110]))
for r in rows: print(f"{r[0]:16} {r[1]}:{r[2]}  {'通る' if r[3] else '★通らない★'}  {r[4]}")
print(f"[mouths] {rev}: {len(rows)} lines, through ReplaceTokens {sum(r[3] for r in rows)}, not {sum(not r[3] for r in rows)}", file=sys.stderr)
