#!/usr/bin/env bash
# w2_assy_gate.sh — battle assembly の ★各 step 後に 同じ形で 2 本回して 数を並べる★ 器（worker2・2026-08-30）
#
# ★これは 生成器★。生成物 = ASSY_GATE_LEDGER.tsv（★手で編集しない★）。
# ★数を並べる★のであって「緑/赤」を書かない。RESULT 語も 1 列として持つが、判定は ★4 値の 前後比較★。
#
#   使い方:
#     ./w2_assy_gate.sh --selftest              # Unity 不要。parser の陽性対照（既知の逐語行を食わせる）
#     ./w2_assy_gate.sh --run <label>           # Unity を 2 本 順に 回して ledger に 1 行 足す
#     ./w2_assy_gate.sh --parse <seam.log> <cut.log> <label>   # 既に在る log から 1 行 足す
#
# ★不変★
#   ・退路を true で返さない = 取れなかった値は ★MISSING★（OK でも NG でもない 第 3 値）。
#   ・assy tree に 書かない = run 前後で `git status --porcelain` の sha256 が 変わっていないことを assert。
#   ・Unity は 同時に 1 つ = 既に走っていたら ★落ちる★（黙って待たない）。
set -u -o pipefail

ASSY=/home/ken/Desktop/Digimon/degimon_world_remake-assy
UNITY=/home/ken/Unity/Hub/Editor/6000.4.11f1/Editor/Unity
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LEDGER="$HERE/../ASSY_GATE_LEDGER.tsv"
RUNDIR="${W2_RUNDIR:-$HERE/../logs/assy_gate}"

# ── parser: 取れなければ MISSING を返す（★空文字や 0 に畳まない★）
# ★不在は 1 種類では ない★（#929-W2c 自己申告）:
#   NOLOG  = ★log file 自体が 無い★（走っていない / 出力先が 違う）
#   ABSENT = ★log は 在るが その行が 出ていない★（★走ったが emit されなかった★）
#   ★これを 同じ記号に 畳むと「引用に無い」と「実機で出なかった」が 見分けられない★。
#   ★どちらも OK でも 0 でも ない★（退路を true で返さない）。
f() { # f <file> <regex-with-1-capture>
  #   ★raw log は 巨大（seam66 = 168MB）ゆえ gzip して置く★ ⇒ .gz も 同じ file として 読む
  #   （★圧縮したら 読めなくなって NOLOG になる★ = 保管の都合で 不在が 増えるのを 防ぐ）
  local src="$1"
  [ -f "$src" ] || { [ -f "$src.gz" ] && src="$src.gz" || { echo NOLOG; return; }; }
  local v
  case "$src" in *.gz) v=$(zgrep -aoP "$2" "$src" | tail -1) ;; *) v=$(grep -aoP "$2" "$src" | tail -1) ;; esac
  [ -n "$v" ] && echo "$v" || echo ABSENT
}
# ★#929-W2c ■4: 「その行を 出した器の 版」を 欄に 持つ★
#   ★出所の 書いていない 緑は 後から 検算できない★（compile_gate.sh が 凍結 tree を hardcode していた型）。
#   ★Unity が 読むのは commit ではなく ★working tree★★ ⇒ HEAD sha だけでは 足りない = dirty も 印字する。
provenance() { # → "<HEAD>+<dirty>" <harness_sha> <gate_sha>
  local h d hs gs
  h=$(cd "$ASSY" && git rev-parse --short HEAD 2>/dev/null || echo MISSING)
  d=$(cd "$ASSY" && git status --porcelain | wc -l)
  [ "$d" = 0 ] && d=clean || d="dirty${d}"
  hs=$(cat "$ASSY/unity/Assets/Scripts/Editor/BattleSeamVerify66.cs" \
           "$ASSY/unity/Assets/Scripts/Editor/CutsceneVerify178.cs" 2>/dev/null | sha256sum | cut -c1-12)
  gs=$(sha256sum "$ASSY/workspace/battle-slice-verify/compile_gate.sh" 2>/dev/null | cut -c1-12)
  echo "$h+$d ${hs:-MISSING} ${gs:-MISSING}"
}

parse_row() { # parse_row <seam.log> <cut.log> <label> [tree] [harness_sha] [gate_sha]
  local S="$1" C="$2" L="$3" TREE="${4:-QUOTE}" HSHA="${5:-QUOTE}" GSHA="${6:-QUOTE}"
  local sres stxt soff son sreach ssyn cpages cchars ctpc cres
  # ★SEAM66 は RESULT= を 2 度出す（PLAY と SYNTH）★ ⇒ tail -1 で拾うと SYNTH を主結果と誤読する。
  #   ⇒ ★textIdentical を伴う行★ を主結果、SYNTH は ★別欄★（落とさない）。
  sres=$(f  "$S" '\[SEAM66\] RESULT=\K[A-Z]+(?=\(textIdentical)')
  stxt=$(f  "$S" 'textIdentical=\K[A-Za-z]+')
  soff=$(f  "$S" 'OFFgated=\K[0-9]+')
  son=$(f   "$S" 'ONgated=\K[0-9]+')
  sreach=$(f "$S" 'RESULT=[^(]*\(textIdentical=[A-Za-z]+ OFFgated=[0-9]+ ONgated=[0-9]+ reach=\K[0-9]+')
  ssyn=$(f  "$S" '\[SEAM66\] RESULT=\K[A-Z]+\(SYNTH\)')
  cpages=$(f "$C" 'BASELINE-CHECK pages=\K[0-9]+/[0-9]+')
  cchars=$(f "$C" 'BASELINE-CHECK.* chars=\K[0-9]+/[0-9]+')
  cchars=${cchars:-MISSING}
  ctpc=$(f  "$C" 'termPc=\K0x[0-9A-Fa-f]+/0x[0-9A-Fa-f]+')
  cres=$(f  "$C" '\[CUTSCENE178\] RESULT=\K[A-Z]+')
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$L" "$sres" "$stxt" "$soff" "$son" "$sreach" "$ssyn" "$cpages" "$cchars" "$ctpc" "$cres" \
    "$TREE" "$HSHA" "$GSHA"
}
header() { printf 'label\tSEAM66_RESULT\ttextIdentical\tOFFgated\tONgated\treach\tSEAM66_SYNTH\tCUT178_pages\tCUT178_chars\tCUT178_termPc\tCUT178_RESULT\ttree(HEAD+dirty)\tharness_sha\tgate_sha\n'; }

# ── 陽性対照: ★boss1 が実走した逐語行★ を食わせて parser が 4 値を取り出せるか
selftest() {
  local t; t=$(mktemp -d); local ok=0 ng=0
  cat > "$t/seam.log" <<'L1'
[SEAM66] RESULT=GREEN(textIdentical=True OFFgated=0 ONgated=7 reach=7)
L1
  cat > "$t/cut.log" <<'L2'
[CUTSCENE178] DONE finished=True choiceBreak=False pages=0 termPc=0x1A(padding0x1316 手前=True) emittedChars=0 garble=0
[CUTSCENE178] BASELINE-CHECK pages=0/66(★NG★) chars=0/1601(★NG★) termPc=0x1A/0x1315(★NG★)
[CUTSCENE178] RESULT=FAIL
L2
  local got exp
  got=$(parse_row "$t/seam.log" "$t/cut.log" BASELINE_ea600ab5)
  exp=$'BASELINE_ea600ab5\tGREEN\tTrue\t0\t7\t7\tABSENT\t0/66\t0/1601\t0x1A/0x1315\tFAIL\tQUOTE\tQUOTE\tQUOTE'
  if [ "$got" = "$exp" ]; then echo "OK  1) 既知 baseline の 4 値抽出"; ok=$((ok+1)); else echo "NG  1) got=[$got] exp=[$exp]"; ng=$((ng+1)); fi
  # 2) ★log が 無い★ときに OK に畳まないこと（退路を true で返さない）
  got=$(parse_row "$t/nofile.log" "$t/nofile.log" ABSENT)
  if [ "$got" = $'ABSENT\tNOLOG\tNOLOG\tNOLOG\tNOLOG\tNOLOG\tNOLOG\tNOLOG\tNOLOG\tNOLOG\tNOLOG\tQUOTE\tQUOTE\tQUOTE' ]
    then echo "OK  2) log 不在 = 全欄 ★NOLOG★（0 でも OK でもない）"; ok=$((ok+1)); else echo "NG  2) got=[$got]"; ng=$((ng+1)); fi
  # 3) ★行が 在るのに 値が 欠ける★ときも MISSING（部分欠損を 埋めない）
  printf '[SEAM66] RESULT=GREEN(textIdentical=True)\n' > "$t/partial.log"
  got=$(parse_row "$t/partial.log" "$t/cut.log" PARTIAL)
  if [ "$(echo "$got" | cut -f4)" = ABSENT ] && [ "$(echo "$got" | cut -f2)" = GREEN ]
    then echo "OK  3) 部分欠損は その欄だけ ★ABSENT★（log は在る）"; ok=$((ok+1)); else echo "NG  3) got=[$got]"; ng=$((ng+1)); fi
  # 4) ★陰性対照★ = 値が動いた log を 動いたと読むか（parser が baseline を 焼き付けていない）
  printf '[CUTSCENE178] BASELINE-CHECK pages=66/66(OK) chars=1601/1601(OK) termPc=0x1315/0x1315(OK)\n[CUTSCENE178] RESULT=GREEN\n' > "$t/moved.log"
  got=$(parse_row "$t/seam.log" "$t/moved.log" MOVED)
  if [ "$(echo "$got" | cut -f8)" = 66/66 ] && [ "$(echo "$got" | cut -f11)" = GREEN ]
    then echo "OK  4) 値が動けば 動いたと出る（焼き付けなし）"; ok=$((ok+1)); else echo "NG  4) got=[$got]"; ng=$((ng+1)); fi
  # 5) ★回帰★ = SYNTH 行を 主結果と読まない（この器が 実際に 踏んだ穴）
  printf '[SEAM66] RESULT=GREEN(textIdentical=True OFFgated=0 ONgated=7 reach=7)\\n[SEAM66] RESULT=RED(SYNTH)\\n' > "$t/two.log"
  got=$(parse_row "$t/two.log" "$t/cut.log" TWO)
  if [ "$(echo "$got" | cut -f2)" = GREEN ] && [ "$(echo "$got" | cut -f7)" = 'RED(SYNTH)' ]
    then echo "OK  5) PLAY と SYNTH を 別欄で 保つ（後勝ちしない）"; ok=$((ok+1)); else echo "NG  5) got=[$got]"; ng=$((ng+1)); fi
  rm -rf "$t"; echo "selftest: OK=$ok NG=$ng"; [ "$ng" -eq 0 ]
}

# ── Unity 単一 slot の guard（★pgrep -f は self-match するので ps の comm を見る★）
unity_busy() { ps -eo comm= | grep -qx 'Unity' ; }
tree_sig() { (cd "$ASSY" && git status --porcelain | sha256sum | cut -c1-16); }

run_both() { # run_both <label>
  local L="$1"
  unity_busy && { echo "★中止: Unity が 既に 走っている（同時 1 本）★"; return 3; }
  [ -x "$UNITY" ] || { echo "★中止: Unity binary 不在 $UNITY★"; return 3; }
  mkdir -p "$RUNDIR/$L"
  # ★出所は ★走らせた時刻に★ 固めて run dir に残す★（後から採り直すと 別の tree を刻みかねない）
  provenance > "$RUNDIR/$L/provenance.txt"
  local before after; before=$(tree_sig)
  local S="$RUNDIR/$L/seam66.log" C="$RUNDIR/$L/cut178.log"
  "$UNITY" -batchmode -quit -nographics -projectPath "$ASSY/unity" \
     -executeMethod DigimonWorld.EditorTools.BattleSeamVerify66.Run -logFile "$S" ; echo "  seam66 exit=$?"
  "$UNITY" -batchmode -quit -nographics -projectPath "$ASSY/unity" \
     -executeMethod DigimonWorld.EditorTools.CutsceneVerify178.Run  -logFile "$C" ; echo "  cut178 exit=$?"
  after=$(tree_sig)
  [ "$before" = "$after" ] || echo "★★警告: assy tree の git status が 変わった（$before → $after）★★"
  local errs; errs=$(grep -c 'error CS' "$S" "$C" 2>/dev/null | awk -F: '{s+=$2} END{print s+0}')
  echo "  error CS 合計 = $errs"
  [ -s "$LEDGER" ] || header > "$LEDGER"
  # shellcheck disable=SC2046
  parse_row "$S" "$C" "$L" $(cat "$RUNDIR/$L/provenance.txt") >> "$LEDGER"
  column -t -s $'\t' "$LEDGER"
}

case "${1:---selftest}" in
  --selftest) selftest ;;
  --run)   [ $# -ge 2 ] || { echo "usage: --run <label>"; exit 2; }; run_both "$2" ;;
  --reparse) # 既に在る run dir から 採り直す（★出所は run 時に固めた provenance.txt を読む★）
           [ $# -ge 3 ] || { echo "usage: --reparse <rundir> <label>"; exit 2; }
           pv="UNKNOWN UNKNOWN UNKNOWN"; [ -f "$2/provenance.txt" ] && pv=$(cat "$2/provenance.txt")
           [ -s "$LEDGER" ] || header > "$LEDGER"
           # shellcheck disable=SC2086
           parse_row "$2/seam66.log" "$2/cut178.log" "$3" $pv >> "$LEDGER"; column -t -s $'\t' "$LEDGER" ;;
  --parse) [ $# -ge 4 ] || { echo "usage: --parse <seam.log> <cut.log> <label>"; exit 2; }
           [ -s "$LEDGER" ] || header > "$LEDGER"; parse_row "$2" "$3" "$4" >> "$LEDGER"; column -t -s $'\t' "$LEDGER" ;;
  *) echo "unknown: $1"; exit 2 ;;
esac
