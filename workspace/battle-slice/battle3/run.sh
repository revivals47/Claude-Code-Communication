#!/usr/bin/env bash
# 3 戦目 ① — これ 1 つを実行するだけ。★読むだけで ゲームは書き換えません★。
# 止める時は Ctrl-C。記録は raw_*.log と result_*.txt に残ります。
set -u
cd "$(dirname "$0")"
STAMP=$(date '+%Y%m%d_%H%M%S')
echo "つないでいます…（DuckStation を先に起動して ゲームを動かしておいてください）"
gdb -q -nx -x capture.gdb 2>&1 | tee "raw_${STAMP}.log" | python3 -u verdict.py | tee "result_${STAMP}.txt"
echo
echo "終わりました。 result_${STAMP}.txt に残っています。"
