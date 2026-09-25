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
# ★★行番号は 書かない（2026-08-29 の教訓）★★
#   本 header は かつて「順序は send_message(L130) → log_send(L133)」と書いていたが、
#   ★log_attempt を足した後 更新されず★、読んだ人(PRESIDENT #924-A)を誤らせた。
#   ★私(boss1)は それを直す編集で 自分が書いた行番号を 自分の編集で ずらした★(1 分で再発)。
#   ⇒ ★参照は 関数名で行う★。行番号が要る時は ★その場で grep -n する★。
#     確認コマンド = grep -n 'log_attempt \|send_message \|log_send ' agent-send.sh
#
# 【欠陥 1】log の SENT は送信の ground truth ではない(false negative が在る)
#   ★2026-08-29 訂正: 本項の記述が 実装と食い違っていた★。
#     旧記述 = 「順序は send_message(L130 付近) → log_send(L133 付近)。∴ 切れると log 行は 1 行も残らない」
#     ★これは log_attempt を足す前の記述で、足した後 更新されていなかった★。
#     ⇒ ★『log 行は 1 行も残らない』は 偽★。★ATTEMPT は 残る★。
#   ★現在の main() の順序(実測)★ = log_attempt → send_message → log_send（行番号は下記の注を見よ）。
#   ∴ 送信の途中で process/turn が切れると ★SENT は残らないが ATTEMPT は残る★。
#   ∴ 「log に SENT が無い」は「送っていない」を意味しない(送信途中で切れた可能性)。
#   ★★∴ ATTEMPT の有無が「この script を通ったか」の discriminator★★:
#     ・ATTEMPT 有 / SENT 無 = ★この script を通ったが 送信の途中で切れた★
#     ・ATTEMPT 有 / SENT 有 = ★送信処理は最後まで走った★(届いた保証ではない。欠陥 2 を見よ)
#     ・★ATTEMPT 無★        = ★この script を 1 度も通っていない★
#                              (= 受信側の入力欄に文が在っても、それは ★人が直接打った文★)
#   実例(2026-08-10) = boss1 → worker1 の 1 通が log に無いまま受信側の入力欄に残った。
#     ★但し これは log_attempt を足す前の事象★ゆえ、今 同じことが起きれば ATTEMPT が残る。
#   実例(2026-08-29) = worker1/worker3 の入力欄に文が残っていたが ★ATTEMPT も SENT も 0 件★
#     ⇒ ★この script を通っていない = 人が pane に直接打った文★ と判別できた。
#
# 【欠陥 2】送信は「入力欄に入れる」と「submit する」の 2 段で、間に 2 秒の窓が在る
#   send_message() は ★send-keys C-c → sleep 0.3 → send-keys 本文 → sleep 2 → send-keys C-m★ の順。
#   ★★本文の前に C-c が入る★★ ⇒ ★受信側の入力欄に前の文が残っていても 連結されない★
#     (2026-08-29 実測: 文が残った 2 pane に送信し、受信 transcript は 送った本文のみ・混入 0)。
#   ∴ この 2 秒の窓で切れると ★本文は入力欄に残るが submit されず、誰にも届かない★。
#   受信側は「何も来ていない」ので沈黙し、送信側は成功したと思う。両側に error が出ない。
#   実例: 上記と同一事象。受信側 worker1 の context に当該 message は存在しなかった。
#         その 1 通の不着が worker1 の 45 分の完全停止を生んだ。
#   ★止まった便は 復旧不能★: 入力欄に残った文は、後から C-m を送っても submit されない。
#   C-c で消してから入力し直す通常経路でのみ動く。∴ 復旧は不可能で、★再送しか無い★。
#   関連: 第 2 引数を二重引用符で囲まないと word splitting で最初の 1 語に切り詰められる
#         (main() は $# -lt 2 しか見ないため欠落を検出しない)。呼ぶ側は必ず "$(cat file)" の形で。
#
# 【∴ 運用】ground truth は ★受け手が返す通番 echo だけ★。送り手側の log は補助。
#           各便に通し番号を付け、受け手は返信の冒頭に受領した最後の番号を書く。
#           ★応答が無い = 作業中 とは限らない★。送信後 5 分で応答が無ければ
#           tmux capture-pane で受信側の入力欄を確認する。2026-08-10 は「届いたつもりで
#           止まっていた」が 4 件 発生し、うち 1 件は受信側の 45 分の完全停止を生んだ。
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

# ログ記録(送信前)。2026-08-11 追加。
# 目的: send_message の途中(本文 send-keys 後・C-m 前の 2 秒窓など)で process/turn が
#       切れると、従来は log 行が 1 行も残らず「送っていない」と誤読された。
#       ATTEMPT を先に書くことで「撃った形跡」が必ず残る。
#       ATTEMPT が在り SENT が無い = ★送信の途中で切れた★ = composer に残留している疑い。
log_attempt() {
    local agent="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    mkdir -p logs
    echo "[$timestamp] $agent: ATTEMPT - \"$message\"" >> logs/send_log.txt
}

# ログ記録(送信後)。SENT の行形式は従来どおり(既存の grep 互換)
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
    
    # 同じ宛先への送信は 1 本ずつ（2026-09-25 PRESIDENT）。
    # 以前は先頭に C-c を送っていたが、C-c は作業中の相手の turn を中断し、
    # 待機中の相手に 2 本の便が数秒以内に続くと 2 回目の C-c で Claude Code が終了する
    # （2026-09-25 boss1 が 3 回落ちた時刻は、どれも boss1 宛の便が 0〜1 秒差で続いた時刻と一致:
    #  06:29:31・09:01:40・13:34:30/31。13:57 には worker1 の regress_all が中断された）。
    # ⇒ C-c をやめ、入力欄は C-u（行の消去、作業を中断しない）を複数回で消す。
    local lock="/tmp/agent-send-$(echo "$target" | tr ':.' '__').lock"
    exec 9>"$lock"
    flock -w 30 9

    # 入力欄に残った文を消す（複数行でも消えるよう回数を多めに）
    for _ in $(seq 1 30); do tmux send-keys -t "$target" C-u; done
    sleep 0.3

    # メッセージ送信
    tmux send-keys -t "$target" "$message"
    sleep 2

    # エンター押下
    tmux send-keys -t "$target" C-m
    sleep 1.5
    exec 9>&-
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
    # ログ記録(送信前 = ATTEMPT)。途中で切れても痕跡が残る
    log_attempt "$agent_name" "$message"

    # メッセージ送信
    send_message "$target" "$message"
    
    # ログ記録
    log_send "$agent_name" "$message"
    
    echo "✅ 送信完了: $agent_name に '$message'"
    
    return 0
}

main "$@" 