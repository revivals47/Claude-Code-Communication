#!/usr/bin/env bash
# 3 戦目 ① — これ 1 つを実行するだけ。★読むだけで ゲームは書き換えません★。
# ★止める時は 別の端末で ./stop.sh を実行してください★（Ctrl-C では止まらないことを実測で確認済）。
set -u
cd "$(dirname "$0")"
STAMP=$(date '+%Y%m%d_%H%M%S')
RAW="raw_${STAMP}.log"; RES="result_${STAMP}.txt"
echo "つないでいます…（DuckStation を先に起動して ゲームを動かしておいてください）"
gdb -q -nx -batch -x capture.gdb < /dev/null > >(tee "$RAW" | python3 -u verdict.py | tee "$RES") 2>&1 &
WRAP=$!
trap './stop.sh >/dev/null 2>&1' INT TERM
wait "$WRAP" 2>/dev/null
sleep 1
echo
echo "終わりました。 $RES に残っています。★このファイルを渡してください★。"
