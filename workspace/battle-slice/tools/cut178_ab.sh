#!/usr/bin/env bash
# cut178 A/B — ★gate の停止が RED の唯一の原因か★ を 1 変数だけ変えて測る。
#   control   = 既定（gate ON）        … 器と tree が step2 と同じ地面に在ることの ★陽性対照★
#   treatment = W1_GATE_NEVERSTOP=1    … 停止を外す（= 9d90aabf 以前の「黙って len consume」と同形）
# ★変えるのは env 1 つだけ・code も tree も触らない★
set -u
UNITY=/home/ken/Unity/Hub/Editor/6000.4.11f1/Editor/Unity
ASSY=/home/ken/Desktop/Digimon/degimon_world_remake-assy
OUT=/home/ken/Documents/Claude-Code-Communication/workspace/battle-slice/logs/cut178_ab_20260913

unity_busy() { ps -eo comm= | grep -qx 'Unity'; }   # ★pgrep -f は self-match するので comm を見る★
unity_busy && { echo "★中止: Unity が既に走っている（同時 1 本）★"; exit 3; }
[ -x "$UNITY" ] || { echo "★中止: Unity binary 不在★"; exit 3; }

{ echo "date=$(date -Iseconds)"
  echo "assy_HEAD=$(cd "$ASSY" && git rev-parse --short HEAD)"
  echo "assy_branch=$(cd "$ASSY" && git rev-parse --abbrev-ref HEAD)"
  echo "assy_dirty_lines=$(cd "$ASSY" && git status --porcelain | wc -l)"
  echo "assy_dirty_sig=$(cd "$ASSY" && git status --porcelain | sha256sum | cut -c1-16)"
  echo "DG.SCN_sha256=$(sha256sum "$ASSY/unity/Assets/StreamingAssets/dialogue/DG.SCN" | cut -d' ' -f1)"
  echo "CutsceneVerify178.cs_sha256=$(sha256sum "$ASSY/unity/Assets/Scripts/Editor/CutsceneVerify178.cs" | cut -d' ' -f1)"
  echo "DialogueRuntime.cs_sha256=$(sha256sum "$ASSY/unity/Assets/Scripts/Dialogue/DialogueRuntime.cs" | cut -d' ' -f1)"
  echo "unity=$("$UNITY" -version 2>/dev/null | head -1)"
  echo "env_DEGIMON_FAITHFUL_BODYSTART=${DEGIMON_FAITHFUL_BODYSTART:-unset}"
  echo "env_DEGIMON_W3_PASSTHRU=${DEGIMON_W3_PASSTHRU:-unset}"
  echo "env_DEGIMON_BATTLE_SLICE=${DEGIMON_BATTLE_SLICE:-unset}"
} > "$OUT/provenance.txt"
cat "$OUT/provenance.txt"

run() { # run <label> [env...]
  local L="$1"; shift
  echo "=== [$L] start $(date +%T) ==="
  env "$@" "$UNITY" -batchmode -quit -nographics -projectPath "$ASSY/unity" \
      -executeMethod DigimonWorld.EditorTools.CutsceneVerify178.Run -logFile "$OUT/$L.log"
  echo "=== [$L] exit=$? $(date +%T) ==="
}
run control   W1_GATE_NEVERSTOP=
run treatment W1_GATE_NEVERSTOP=1
echo "ALL DONE $(date +%T)"
