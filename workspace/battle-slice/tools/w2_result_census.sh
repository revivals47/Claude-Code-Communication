#!/usr/bin/env bash
# w2_result_census.sh — ★戦闘結果コードの 代入 site を ★3 欄で★ 数える★（worker2・2026-08-30・#929-W2d ■2(3)）
#
# ★boss1 の指摘★: 「Zero が 残っていないか」だけで 閉じてはいけない。
#   ★Minus1 = 1 件 / Zero = 0 件 / Win = 0 件★ のとき、
#   ★Zero の 0 は「良い 0」（消した）／Win の 0 は「まだの 0」（未配線・step 待ち）★。
#   ★同じ 0 を 同じ意味で 読むと、未配線を 完了と 読み違える★
#   （= NOLOG / ABSENT で 立てた型と 同じ = ★2 つの不在を 1 記号に 畳まない★）。
#
#   使い方: ./w2_result_census.sh <commit|WORKTREE> [<commit2> ...]
set -u -o pipefail
cd /home/ken/Desktop/Digimon/degimon_world_remake-assy || exit 3
P='unity/Assets/Scripts'
g() { local r="$1"; shift
      if [ "$r" = WORKTREE ]; then git grep -n -E "$1" -- $P; else git grep -n -E "$1" "$r" -- $P | sed "s/^$r://"; fi; }

# ★代入★ だけを 数える（比較 == や enum 宣言行は 数えない）
ASSIGN='(Result|result) *= *(BattleResultCode\.)?'
row() { # row <rev>
  local r="$1" m z w tot decl
  m=$(g "$r" "${ASSIGN}Minus1"  | grep -vc '^\s*$' || true)
  z=$(g "$r" "${ASSIGN}Zero"    | grep -vc '^\s*$' || true)
  w=$(g "$r" "${ASSIGN}Win"     | grep -vc '^\s*$' || true)
  tot=$(g "$r" 'BattleResultCode' | wc -l)
  echo "  rev=$r  ★Minus1 代入=$m★  ★Zero 代入=$z★  ★Win 代入=$w★   （BattleResultCode の 出現 全体=$tot・合否条件外）"
  g "$r" "${ASSIGN}(Minus1|Zero|Win)" | sed 's/^/      assign> /'
}

echo "=== 戦闘結果コードの 代入 census（母数 = $P）==="
for r in "$@"; do row "$r"; done

echo
echo "=== ★陽性対照★（0 件 を 書く前に・同じ器 同じ母数で 何かが 見つかるか）==="
for r in "$@"; do
  n=$(g "$r" 'BattleResultCode' | wc -l)
  if [ "$n" -gt 0 ]; then echo "  OK  rev=$r : BattleResultCode = $n 行 ⇒ ★器は 効いている★"
  else echo "  ★NG rev=$r : 母数が 空 ⇒ 0 件を 主張してはいけない★"; exit 4; fi
done

echo
echo "=== ★0 の 読み方（★畳まない★）★ ==="
echo "  ★Zero の 0★  = ★良い 0★ = §11-7 のとおり 消した（0 = 逃走 ゆえ KO で返すと 意味が反転する）。"
echo "  ★Win の 0★   = ★まだの 0★ = ★未配線★（勝利は damage が 着弾する step を 待つ）。★欠陥ではなく 未到達★。"
echo "  ⇒ ★この 2 つを 同じ『0 件』として 報告しない★。★Win が 0 のままなのは 想定どおり★ と 明記する。"
