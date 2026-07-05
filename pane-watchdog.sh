#!/bin/bash
# pane-watchdog.sh v2 — multiagent pane の stuck 入力を「再送」で復旧する watchdog
#
# 背景: agent-send.sh(C-c→type→C-m)の C-m が稀に確定せず、メッセージが composer に
#       未確定のまま残る。★Enter/C-m/KPEnter の後押しでは確定しない。KPEnter は
#       submit でなく composer を「破棄」する(2026-07-05 実証: 送信履歴に残らず消失)★。
#       唯一信頼できる復旧 = 全文を取り込み C-c でクリアして agent-send 同一手順で再送。
#
# v2 動作: idle pane(esc to interrupt 非表示)の composer に非空テキストが 30s 同一残存
#   → capture-pane -J(折返し結合)で全文取得 → C-c → send-keys -l 再タイプ → C-m
#   → 5s 後に composer 空を確認。空にならなければ ALERT 記録(破壊的操作はしない)。
#   同一 pane への再送後は 300s cooldown(loop 防止)。
#
# 停止: kill $(grep START logs/pane-watchdog.log | tail -1 | grep -o 'pid=[0-9]*' | cut -d= -f2)
#       ※ pkill -f は自シェル self-match で exit144 する罠あり、pid 指定で殺すこと。
# ログ: logs/pane-watchdog.log

exec 9>/tmp/pane-watchdog.lock
flock -n 9 || { echo "pane-watchdog already running"; exit 1; }

LOG="$(dirname "$0")/logs/pane-watchdog.log"
mkdir -p "$(dirname "$LOG")"
echo "$(date '+%F %T') START watchdog-v2 pid=$$" >> "$LOG"

nbsp=$(printf '\302\240')
declare -A COOLDOWN

extract_input() {
  # composer の全文(折返し結合済み snapshot から ❯ 行を取り、prompt/NBSP/前後空白を剥がす)
  grep "^❯" | tail -1 | sed "s/^❯//; s/$nbsp/ /g; s/^[[:space:]]*//; s/[[:space:]]*$//"
}

while true; do
  for pane in multiagent:0.0 multiagent:0.1 multiagent:0.2 multiagent:0.3; do
    now=$(date +%s)
    [ -n "${COOLDOWN[$pane]}" ] && [ $((now - COOLDOWN[$pane])) -lt 300 ] && continue
    snap=$(tmux capture-pane -t "$pane" -p -J 2>/dev/null) || continue
    echo "$snap" | grep -q "esc to inte" && continue
    input=$(echo "$snap" | extract_input)
    [ -z "$input" ] && continue
    sleep 30
    snap2=$(tmux capture-pane -t "$pane" -p -J 2>/dev/null) || continue
    echo "$snap2" | grep -q "esc to inte" && continue
    input2=$(echo "$snap2" | extract_input)
    { [ -z "$input2" ] || [ "$input" != "$input2" ]; } && continue
    # stuck 確定 → agent-send 同一手順で再送(全文は -J 取得済)
    tmux send-keys -t "$pane" C-c
    sleep 0.5
    tmux send-keys -t "$pane" -l "$input2"
    sleep 2
    tmux send-keys -t "$pane" C-m
    sleep 5
    after=$(tmux capture-pane -t "$pane" -p -J 2>/dev/null | extract_input)
    if [ -z "$after" ]; then
      echo "$(date '+%F %T') RESEND-OK $pane :: ${input2:0:80}" >> "$LOG"
    else
      echo "$(date '+%F %T') ALERT resend-failed $pane :: ${after:0:80}" >> "$LOG"
    fi
    COOLDOWN[$pane]=$(date +%s)
  done
  sleep 90
done
