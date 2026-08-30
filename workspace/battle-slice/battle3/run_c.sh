#!/usr/bin/env bash
# 3 戦目 (c) 専用 — これ 1 つを実行するだけ。★読むだけで ゲームは書き換えません★。
# ★止める時は 別の端末で ./stop_c.sh★（Ctrl-C では止まりません）。
set -u
cd "$(dirname "$0")"
STAMP=$(date '+%Y%m%d_%H%M%S')
RAW="rawc_${STAMP}.log"; RES="resultc_${STAMP}.txt"
echo "つないでいます…（DuckStation を先に起動して ゲームを動かしておいてください）"
gdb-multiarch -q -nx -batch -x capture_c.gdb < /dev/null > >(tee "$RAW" | python3 -u verdict_c.py | tee "$RES") 2>&1 &
WRAP=$!
trap './stop_c.sh >/dev/null 2>&1' INT TERM
wait "$WRAP" 2>/dev/null
sleep 1
echo
echo "終わりました。 $RES に残っています。★このファイルを渡してください★。"
