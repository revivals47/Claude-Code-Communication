#!/usr/bin/env bash
# w2_counter_census.sh — ★counter の 口を 数える★ 器（worker2・2026-08-30・v2）
#
# ★v1 の 穴（自分で 踏んだ）★: 名前を hardcode していた（SceneDriverCounterInc）ため、
#   ★worker1 が Advance0x66Counter に 改名した 途端 呼び出し site が 器から 消えた★。
#   それでも v1 は 「B の 加算 = 1 件」と ★合格を 出した★ = ★宣言だけ 見て 呼ばれ方を 見ていない★。
#   ⇒ ★★名前で 探さない。★変異（RawE12C++ / Battles += 1）から 出発して 包む method 名を 導き、
#      その 名前で 呼び出し site を 数える★★（[[feedback_zero_count_needs_emitter_census]] / [[feedback_pgrep_guard_self_match]] と同型）。
#
#   規則（1 つの数に 畳まない）:
#     R1 = 識別子が 現れる 行 / R2 = 宣言・定数・field
#     R3-inc = ★変異の 書き手★（値を 動かす 行）      R3-reset = reset(=0)
#     ★R4 = 変異を 包む method の ★呼び出し site★★ … ★これが 「口の 数」★
#
#   使い方: ./w2_counter_census.sh <commit|WORKTREE>   （既定 = ea600ab5）
set -u -o pipefail
cd /home/ken/Desktop/Digimon/degimon_world_remake-assy || exit 3
REV="${1:-ea600ab5}"
P='unity/Assets/Scripts'
g() { if [ "$REV" = WORKTREE ]; then git grep -n -E "$1" -- $P; else git grep -n -E "$1" "$REV" -- $P | sed "s/^$REV://"; fi; }
cat_at() { if [ "$REV" = WORKTREE ]; then cat "$1"; else git show "$REV:$1"; fi; }

# 変異行 → 包む method 名を ★上に遡って★ 導く（名前を hardcode しない）
enclosing_method() { # <file> <line>
  cat_at "$1" | head -n "$2" | grep -oP '^\s*(public|private|internal|protected)\s+(static\s+)?[A-Za-z0-9_<>\[\]]+\s+\K[A-Za-z0-9_]+(?=\s*\()' | tail -1
}

census() { # <系統名> <識別子 regex> <変異 regex>
  local sys="$1" ID="$2" MUT="$3"
  local r1 r2 rst; r1=$(g "$ID" | wc -l)
  r2=$(g "$ID" | grep -E '(public|private|const|int) ' | grep -vE '(\+\+|\+= *1)' | wc -l)
  rst=$(g "$ID" | grep -E '= *0[;,]' | wc -l)
  local muts; muts=$(g "$MUT")
  local ninc; ninc=$(printf '%s' "$muts" | grep -c . )
  # ★#929-W2c ■2: R1 は 合否条件に しないが ★必ず 印字する★★
  #   （★条件から 外した数を 見えなくすると、増えたことに 誰も 気づけない★ = boss1 が 何度も 踏んだ型）
  echo "系統 $sys : ★R1=$r1（合否条件外・監視のみ）★  R2=$r2（合否条件外）  ★R3-inc=$ninc★  R3-reset=$rst（合否条件外）"
  [ "$ninc" -eq 0 ] && { echo "    （変異 0 件 ⇒ 包む method も 呼び出し site も 無い）"; return; }
  local m ln f name allnames=""
  while IFS= read -r m; do
    f=${m%%:*}; ln=$(echo "$m" | cut -d: -f2)
    name=$(enclosing_method "$f" "$ln")
    echo "    inc> $m"
    echo "         包む method = ★${name:-★導出できず★}★  ($f)"
    [ -n "$name" ] && allnames="$allnames|$name"
  done <<< "$muts"
  allnames=${allnames#|}
  [ -z "$allnames" ] && { echo "    ★R4 = 導出できず（method 名が 取れない）= 合否を 出さない★"; return; }
  # R4 = 呼び出し site（宣言行 と comment 行 を 除く）
  # ★宣言行 と comment 行 を 除いて 数える★。除いた分も ★数で 出す★（黙って 落とさない）。
  local hits decl calls n4 ndecl ncmt
  hits=$(g "($allnames) *\(")
  ncmt=$(printf '%s\n' "$hits" | grep -c -E ':[0-9]+: *//' || true)
  decl=$(printf '%s\n' "$hits" | grep -E '(public|private|internal|protected)[[:space:]]')
  ndecl=$(printf '%s' "$decl" | grep -c . || true)
  calls=$(printf '%s\n' "$hits" | grep -vE ':[0-9]+: *//' | grep -vE '(public|private|internal|protected)[[:space:]]')
  n4=$(printf '%s' "$calls" | grep -c . || true)
  echo "    ★R4(呼び出し site)=$n4★  （除いた内訳: 宣言行=$ndecl / comment 行=$ncmt）"
  printf '%s\n' "$calls" | grep . | sed 's/^/         call> /'
  printf '%s\n' "$decl"  | grep . | sed 's/^/         decl> /'
}

echo "=== rev = $REV / 母数 = $P ==="
census A 'Battles|AdvanceBattleCounter' '(stats\.)?Battles *(\+\+|\+= *1)'
echo
census B 'RawE12C|SceneDriverCounterInc|Advance0x66Counter' 'RawE12C *(\+\+|\+= *1)'

echo
echo "=== ★陽性対照★（0 件 を 書く前に・器が 効いていることを 同じ母数で）==="
nb=$(g 'RawE12C' | wc -l)
[ "$nb" -gt 0 ] && echo "  OK  系統 B の 識別子 = $nb 行 ⇒ 器は 効いている" || { echo "  ★NG 母数が 空 ⇒ 系統 A の 0 件 を 主張してはいけない★"; exit 4; }
echo "  ★改名 検知★: 旧名 SceneDriverCounterInc = $(g 'SceneDriverCounterInc' | grep -vE ':\s*//' | wc -l) 行（0 でも 異常では ない = 上の R4 が 本体）"

echo
echo "=== ★§11-2 / §11-5 の 完了条件（規則を 名指しで）★ ==="
echo "  ★boss1 #929-W2c ■2 で 確定★（R1 は 合否に 使わないが 上に 必ず 出す）:"
echo "  (i) ★系統 A の R3-inc == 0★（戦闘側から counter を 触らない）"
echo "  (ii) ★系統 B の R3-inc == 1 かつ R4 == 1★（★口が 1 つ★ = 宣言も 呼び出しも 1 つ）"
echo "  ★R1 == 0 は 条件に しない★（§11-2 は IBattleStats.Battles の 実装先を 未定と している）。"
echo "  ★R4 を 見ないと 『宣言だけ 在って 呼ばれていない』『2 箇所から 呼ばれている』を 見逃す★（v1 の 穴）。"
echo "  ※ ★guard が 加算より 上か（§11-5）は 行番号の 前後で 見る = 下の step1 判定 script 側★"
