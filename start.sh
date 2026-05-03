#!/bin/bash

# Multi-Agent オーケストレーション ワンコマンド起動
# Usage:
#   ./start.sh           全セットアップ+起動+presidentにアタッチ
#   ./start.sh --stop    全セッション終了
#   ./start.sh --status  セッション状況確認

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# --- Stop ---
if [[ "$1" == "--stop" ]]; then
    echo "全セッション終了..."
    tmux kill-session -t multiagent 2>/dev/null && echo "  multiagent 終了" || true
    tmux kill-session -t president 2>/dev/null && echo "  president 終了" || true
    rm -f "$SCRIPT_DIR/tmp/worker"*_done.txt 2>/dev/null
    echo "完了"
    exit 0
fi

# --- Status ---
if [[ "$1" == "--status" ]]; then
    echo "=== tmux sessions ==="
    tmux ls 2>/dev/null || echo "(なし)"
    exit 0
fi

# --- 既にセッションがある場合はアタッチだけ ---
if tmux has-session -t president 2>/dev/null && tmux has-session -t multiagent 2>/dev/null; then
    echo "既存セッション検出。アタッチします。"
    echo "  Ctrl+b d でデタッチ"
    echo "  tmux attach -t multiagent で部下画面"
    sleep 1
    exec tmux attach-session -t president
fi

# --- セットアップ ---
echo "=== Multi-Agent 環境構築 ==="

# クリーンアップ
tmux kill-session -t multiagent 2>/dev/null || true
tmux kill-session -t president 2>/dev/null || true
mkdir -p "$SCRIPT_DIR/tmp" "$SCRIPT_DIR/logs"
rm -f "$SCRIPT_DIR/tmp/worker"*_done.txt 2>/dev/null

# multiagentセッション (4ペイン: boss1 + worker1,2,3)
tmux new-session -d -s multiagent -n agents -c "$SCRIPT_DIR"
tmux split-window -h -t "multiagent:0" -c "$SCRIPT_DIR"
tmux select-pane -t "multiagent:0.0"
tmux split-window -v -c "$SCRIPT_DIR"
tmux select-pane -t "multiagent:0.2"
tmux split-window -v -c "$SCRIPT_DIR"

# ペイン設定
NAMES=("boss1" "worker1" "worker2" "worker3")
COLORS=("31" "34" "34" "34")  # boss=赤, worker=青

for i in {0..3}; do
    tmux select-pane -t "multiagent:0.$i" -T "${NAMES[$i]}"
    tmux send-keys -t "multiagent:0.$i" "export PS1='(\[\033[1;${COLORS[$i]}m\]${NAMES[$i]}\[\033[0m\]) \w\$ '" C-m
done

# presidentセッション
tmux new-session -d -s president -c "$SCRIPT_DIR"
tmux send-keys -t president "export PS1='(\[\033[1;35m\]PRESIDENT\[\033[0m\]) \w\$ '" C-m

echo "  tmuxセッション作成完了"

# --- Claude起動 ---
echo "  Claude起動中..."

# 全ペインでclaude起動
tmux send-keys -t president 'claude --dangerously-skip-permissions' C-m
sleep 0.3

for i in {0..3}; do
    tmux send-keys -t "multiagent:0.$i" 'claude --dangerously-skip-permissions' C-m
    sleep 0.3
done

echo "  全エージェント起動コマンド送信完了"
echo ""
echo "=== 準備完了 ==="
echo "  presidentセッションにアタッチします"
echo "  Ctrl+b d  → デタッチ"
echo "  tmux attach -t multiagent → 部下画面"
echo ""
echo "  使い方: PRESIDENTに「あなたはpresidentです。[指示]」と入力"
sleep 1

exec tmux attach-session -t president
