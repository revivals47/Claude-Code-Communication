#!/bin/bash
# §7.56 positive control (worker3, PRESIDENT 07:0x): S1 build + IKADA_ROD_NUDGE_Z_M=-4.29e-6, seed 20260925, live_08 vs the S1 baseline.
set -u
T=$HOME/Documents/ikada-unity-track3; D=$(cd "$(dirname "$0")" && pwd); SH=/home/ken/Documents/Claude-Code-Communication/workspace/ikada-unity/shots/player_live
export LIVE_BASELINE=perseed LIVE_BASE_20260925=$SH/ae3b5c4_s20260925_231126 LIVE_SEEDS=20260925 IKADA_ROD_NUDGE_Z_M=-4.29e-6
cd "$T" || exit 1; O=$T/Logs/regress/09330dd_062303/nudge
[ "$(git status --porcelain | wc -l)" = 0 ] || { echo "tree not clean - stop"; exit 1; }
git checkout -q track3/s1-measure && [ "$(git rev-parse --short HEAD)" = 3fed721 ] || { echo "checkout failed - stop"; exit 1; }
python3 tools/check_scene_embeds.py > /dev/null 2>&1 || { echo "embeds FAILED - stop"; exit 1; }
s=$(date +%s); tools/unity-batch.sh exec Ikada.EditorTools.BuildScript.BuildPerf > "$D/nudge_build.out" 2>&1; echo "== build rc=$? $(grep 'error CS lines' "$D/nudge_build.out") wall $(( $(date +%s) - s )) s"
tools/live_regress.sh "$O" > "$D/nudge_live.out" 2>&1; echo "== live rc=$? nudge env seen: $(grep -c 'IKADA_ROD_NUDGE' "$O/seed_20260925/live.log")"
rm -f Assets/Scripts/Render/RodStateDump.cs.meta; git checkout -q track3/rodhold-s2; echo "== back on $(git rev-parse --short HEAD) porcelain $(git status --porcelain | wc -l)"
python3 - "$SH/ae3b5c4_s20260925_231126/live_08.png" "$O/seed_20260925/live_08.png" <<'PY'
import sys, numpy as np; from PIL import Image
a=np.asarray(Image.open(sys.argv[1]).convert('RGB'),dtype=np.int16); b=np.asarray(Image.open(sys.argv[2]).convert('RGB'),dtype=np.int16)
d=np.abs(a-b).max(axis=2); d[726,697]=0; v=d[d>0]; m=d>0
nb=sum(np.roll(np.roll(m,dy,0),dx,1) for dy in (-1,0,1) for dx in (-1,0,1) if (dy,dx)!=(0,0))
ys,xs=np.nonzero(m)
print(f'== shape: px {len(v)} | 1-level {int((v==1).sum())} | >=2 {int((v>=2).sum())} | max {int(v.max()) if len(v) else 0} | isolated {int((m&(nb==0)).sum())} | box x {xs.min() if len(xs) else "-"}..{xs.max() if len(xs) else "-"} y {ys.min() if len(ys) else "-"}..{ys.max() if len(ys) else "-"}')
print('   in rod box (x550-1050,y550-890):', int(((xs>=550)&(xs<=1050)&(ys>=550)&(ys<=890)).sum()) if len(xs) else 0)
PY
