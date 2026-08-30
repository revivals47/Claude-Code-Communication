#!/usr/bin/env bash
# ★止める時は これを実行してください★（run.sh を動かしたのとは 別の端末で）。
# 実体が gdb のものだけを止めます（名前だけの一致では止めません）。
# ★ゲームが止まったままにならないよう、止めた後に 動かし直して 確かめます★。
#   （※ gdb を切ると止まったままになる、は ★理屈としては在り得るが 観測していません★＝予防措置です）
cd "$(dirname "$0")"

kill_gdb() {
  local sig="$1" n=0 p e
  for p in $(pgrep -f 'capture_c\.gdb' 2>/dev/null); do
    e=$(readlink -f "/proc/$p/exe" 2>/dev/null)
    case "$e" in */gdb|*/gdb-multiarch) kill "-$sig" "$p" 2>/dev/null; n=$((n+1)) ;; esac
  done
  echo "$n"
}

cpu_delta() {   # $1 = pid, $2 = 秒
  local p="$1" s="$2" a b c d
  read a b < <(awk '{print $14, $15}' "/proc/$p/stat" 2>/dev/null)
  sleep "$s"
  read c d < <(awk '{print $14, $15}' "/proc/$p/stat" 2>/dev/null)
  echo $(( (c + d) - (a + b) ))
}

a=$(kill_gdb TERM); sleep 1
b=$(kill_gdb KILL); sleep 1
rm -f .gdb.pid

# ★ゲームを動かし直す★（gdb の detach はこの相手に効かないので continue を送って抜ける）
gdb-multiarch -q -nx -batch < /dev/null 2>/dev/null \
  -ex 'set confirm off' -ex 'set pagination off' \
  -ex 'target remote 127.0.0.1:2345' -ex 'delete' -ex 'continue &' -ex 'quit' >/dev/null 2>&1
sleep 1

# ★動いていることを 外から確かめる（つなぎ直さずに CPU 時間で見る）★
PID=$(ss -ltnp 2>/dev/null | grep ':2345' | grep -oP 'pid=\K[0-9]+' | head -1)
if [ -n "$PID" ]; then
  D=$(cpu_delta "$PID" 3)
  if [ "$D" -gt 100 ]; then
    echo "止めました。★ゲームは動いています★（$D）。"
  else
    echo "止めました。★ゲームは動いていないようです（$D）★。"
    echo "  あなたが 一時停止していれば それが理由です（その時は 何もしなくて大丈夫）。"
    echo "  一時停止していないのに動かない時だけ、画面で 再開してください。"
  fi
else
  echo "止めました。（ゲームの様子は確認できませんでした）"
fi
