#!/bin/bash

# 🚀 Agent間メッセージ送信スクリプト
#
# ============================================================================
# ⚠️ 既知の failure mode 2 件(2026-08-11 記録。★挙動は変更していない★)
# ============================================================================
# 本 script には構造上の欠陥が 2 つ在り、どちらも 2026-08-10 に実際に発生した。
# 直していないのは「今 依存している通信路を、依存しながら書き換えない」という判断による。
# 使う人は、以下を前提に読むこと。
#
# 【欠陥 1】log は送信の ground truth ではない(false negative が在る)
#   main() の順序が send_message(L130 付近) → log_send(L133 付近) である。
#   ∴ 送信処理の途中で process/turn が切れると、★log 行は 1 行も残らない★。
#   ∴ 「log に SENT が無い」は「送っていない」を意味しない。
#   実例: 2026-08-10、boss1 → worker1 の 1 通が log に無いまま受信側の入力欄に残った。
#
# 【欠陥 2】送信は「入力欄に入れる」と「submit する」の 2 段で、間に 2 秒の窓が在る
#   send_message() は  send-keys 本文(L72) → sleep 2(L73) → send-keys C-m(L76)  の順。
#   ∴ この 2 秒の窓で切れると ★本文は入力欄に残るが submit されず、誰にも届かない★。
#   受信側は「何も来ていない」ので沈黙し、送信側は成功したと思う。両側に error が出ない。
#   実例: 上記と同一事象。受信側 worker1 の context に当該 message は存在しなかった。
#         その 1 通の不着が worker1 の 45 分の完全停止を生んだ。
#   関連: 第 2 引数を二重引用符で囲まないと word splitting で最初の 1 語に切り詰められる
#         (main() は $# -lt 2 しか見ないため欠落を検出しない)。呼ぶ側は必ず "$(cat file)" の形で。
#
# 【∴ 運用】ground truth は ★受け手が返す通番 echo だけ★。送り手側の log は補助。
#           各便に通し番号を付け、受け手は返信の冒頭に受領した最後の番号を書く。
#
# 【未実施の修正案(挙動を変えるため保留)】
#   ① log を send より前に書く ② 送信後に完了行を追記 ③ 2 行の対でどこで切れたか判る
# ============================================================================

# エージェント→tmuxターゲット マッピング
get_agent_target() {
    case "$1" in
        "president") echo "president" ;;
        "boss1") echo "multiagent:0.0" ;;
        "worker1") echo "multiagent:0.1" ;;
        "worker2") echo "multiagent:0.2" ;;
        "worker3") echo "multiagent:0.3" ;;
        *) echo "" ;;
    esac
}

show_usage() {
    cat << EOF
🤖 Agent間メッセージ送信

使用方法:
  $0 [エージェント名] [メッセージ]
  $0 --list

利用可能エージェント:
  president - プロジェクト統括責任者
  boss1     - チームリーダー  
  worker1   - 実行担当者A
  worker2   - 実行担当者B
  worker3   - 実行担当者C

使用例:
  $0 president "指示書に従って"
  $0 boss1 "Hello World プロジェクト開始指示"
  $0 worker1 "作業完了しました"
EOF
}

# エージェント一覧表示
show_agents() {
    echo "📋 利用可能なエージェント:"
    echo "=========================="
    echo "  president → president:0     (プロジェクト統括責任者)"
    echo "  boss1     → multiagent:0.0  (チームリーダー)"
    echo "  worker1   → multiagent:0.1  (実行担当者A)"
    echo "  worker2   → multiagent:0.2  (実行担当者B)" 
    echo "  worker3   → multiagent:0.3  (実行担当者C)"
}

# ログ記録
log_send() {
    local agent="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    mkdir -p logs
    echo "[$timestamp] $agent: SENT - \"$message\"" >> logs/send_log.txt
}

# メッセージ送信
send_message() {
    local target="$1"
    local message="$2"
    
    echo "📤 送信中: $target ← '$message'"
    
    # Claude Codeのプロンプトを一度クリア
    tmux send-keys -t "$target" C-c
    sleep 0.3
    
    # メッセージ送信
    tmux send-keys -t "$target" "$message"
    sleep 2

    # エンター押下
    tmux send-keys -t "$target" C-m
    sleep 0.5
}

# ターゲット存在確認
check_target() {
    local target="$1"
    local session_name="${target%%:*}"
    
    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        echo "❌ セッション '$session_name' が見つかりません"
        return 1
    fi
    
    return 0
}

# メイン処理
main() {
    if [[ $# -eq 0 ]]; then
        show_usage
        exit 1
    fi
    
    # --listオプション
    if [[ "$1" == "--list" ]]; then
        show_agents
        exit 0
    fi
    
    if [[ $# -lt 2 ]]; then
        show_usage
        exit 1
    fi
    
    local agent_name="$1"
    local message="$2"
    
    # エージェントターゲット取得
    local target
    target=$(get_agent_target "$agent_name")
    
    if [[ -z "$target" ]]; then
        echo "❌ エラー: 不明なエージェント '$agent_name'"
        echo "利用可能エージェント: $0 --list"
        exit 1
    fi
    
    # ターゲット確認
    if ! check_target "$target"; then
        exit 1
    fi
    
    # メッセージ送信
    send_message "$target" "$message"
    
    # ログ記録
    log_send "$agent_name" "$message"
    
    echo "✅ 送信完了: $agent_name に '$message'"
    
    return 0
}

main "$@" 