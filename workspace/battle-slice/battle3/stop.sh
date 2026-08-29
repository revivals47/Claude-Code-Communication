#!/usr/bin/env bash
# ★止める時は これを実行してください★（run.sh を動かしたのとは 別の端末で）。
# 実体が gdb のものだけを止めます（名前だけの一致では止めません）。
cd "$(dirname "$0")"
kill_gdb() {
  local sig="$1" n=0 p e
  for p in $(pgrep -f 'capture\.gdb' 2>/dev/null); do
    e=$(readlink -f "/proc/$p/exe" 2>/dev/null)
    case "$e" in */gdb|*/gdb-multiarch) kill "-$sig" "$p" 2>/dev/null; n=$((n+1)) ;; esac
  done
  echo "$n"
}
a=$(kill_gdb TERM); sleep 1
b=$(kill_gdb KILL); sleep 1
c=$(kill_gdb 0)
rm -f .gdb.pid
if [ "$c" = "0" ]; then
  echo "止めました。"
else
  echo "まだ $c 件 残っています。もう一度 実行してください。"
fi
