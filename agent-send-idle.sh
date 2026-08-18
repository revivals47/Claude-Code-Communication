#!/bin/bash
# 🚦 ⓪ を器で強制する送信口 — ★相手が idle のときだけ送る★
#
# ============================================================================
# なぜ在るか (2026-08-18・PRESIDENT が script を読んで確定)
# ============================================================================
# agent-send.sh は send_message() の冒頭で ★必ず C-c を打つ★(L116)。
#   :116  tmux send-keys -t "$target" C-c
#   :120  tmux send-keys -t "$target" "$message"
#   :124  tmux send-keys -t "$target" C-m
# C-c の目的は ★composer 残留を消す★ ことで、これは正当。
# ★但し 相手が走行中に打つと ★その turn が中断される★★ = 目的外の害。
#
# ∴ 配達 oracle は 5 段に成った:
#   ★⓪ 送る前に相手が idle か★ / ① SENT 行 / ② 本文の実内容 / ③ 相手の応答開始 / ④ 同一宛への間隔
#
# 本 script は ⓪ を ★器の側で強制する★(段 3)。
# ★agent-send.sh も agent-send-file.sh も 1 行も変更していない★
#   = 「今 依存している通信路を、依存しながら書き換えない」(agent-send.sh L9) を尊重する。これは追加の口。
#
# 使い方:
#   ./agent-send-idle.sh worker1 /tmp/msg.txt          # busy なら送らず exit 3
#   ./agent-send-idle.sh --wait 300 worker1 /tmp/msg.txt  # idle に成るまで最大 300 秒待つ
# ============================================================================

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

WAIT=0
if [[ "${1:-}" == "--wait" ]]; then WAIT="${2:-0}"; shift 2; fi

if [[ $# -lt 2 ]]; then
    echo "使用方法: $0 [--wait 秒] [エージェント名] [file path]"
    exit 1
fi

agent="$1"; msg_file="$2"

case "$agent" in
    president) target="president" ;;
    boss1)     target="multiagent:0.0" ;;
    worker1)   target="multiagent:0.1" ;;
    worker2)   target="multiagent:0.2" ;;
    worker3)   target="multiagent:0.3" ;;
    *) echo "❌ 不明なエージェント: $agent"; exit 1 ;;
esac

[[ -f "$msg_file" ]] || { echo "❌ file が在りません: $msg_file"; exit 1; }
[[ -s "$msg_file" ]] || { echo "❌ file が空です: $msg_file"; exit 1; }

# ⚠★★2026-08-18 追記(PRESIDENT の実測): `capture-pane` は ★空の箱に 古い frame を 残したまま返す★ ことが在る★★
#   実例 = 箱を C-c で空にした後も 4 回連続で ★同じ文字列★ が返り、`ZZTEST` と 1 文字打って初めて
#          ★最初の C-c で既に空だった★ と判った。∴ ★「変化しない」は「効いていない」ではない★。
#   本 script への含意 = ★idle 判定が ★古い frame★ を読む可能性が在る★:
#     ・古い frame が busy を示す → ★送らない(安全側)★
#     ・古い frame が idle を示す → ★送ってしまい turn を殺す(危険側)★  ← ★★この穴は 塞げていません★★
#   確実にしたいときの手 = ★1 文字 印字させてから読む★(send-keys 'Q' → capture → BSpace)。
#   ★本 script は それをしていません★(打鍵が 相手の composer を汚すため)。∴ ★限定として明記する★。
#
# ★idle 判定★ = pane 末尾に 'esc to interrupt' が無いこと。
#   ⚠ これは ★見た目の判定★ であって turn 状態の直読ではない(TUI の表示に依存する)。
#      表示が変われば黙って壊れる ⇒ 壊れたら ★busy 側に倒れる★ 向きに書いてある(grep 不発 = idle 判定に成るため
#      逆向き)。∴ 表示変更時は ★この 1 行を必ず見直す★。
is_idle() {
    local pane
    # ★capture の成否を先に見る★ = ★陰性対照で見つけた穴★:
    #   pipe で繋ぐと capture の失敗が握り潰され、★存在しない pane が idle と判定される★。
    pane="$(tmux capture-pane -p -t "$target" 2>/dev/null)" || return 1
    [[ -n "$pane" ]] || return 1
    ! printf '%s\n' "$pane" | tail -3 | grep -q 'esc to interrupt'
}

# ★★marker 自体の生存確認（PRESIDENT (2385) の指摘）★★
#   限定「表示が変われば黙って壊れる」の ★帰結★ = ★表示が変わると 全 pane が idle に見え、
#   器は何も拒否しなくなり ★旧挙動に黙って戻る★★ = ★「無出力は合格でなく異常」の この器版★。
#   ∴ ★どの pane にも marker が 1 度も見つからないなら 異常として止める★。
#   ⚠ 4 pane 全部が同時に idle は ★起こり得る★ ゆえ、「今 idle か」ではなく
#     ★『marker という文字列が どの pane にも 1 度も現れない』★ で判定する。
#     busy な pane が 1 つでも在れば marker は必ず現れる ⇒ 全部 idle のときだけ この検査は素通りする。
#     その素通りを ★沈黙させない★ ため、全部 idle のときは ★1 行 警告を出す★(送信は止めない)。
marker_alive() {
    local p out found=0 anyidle=0
    for p in president multiagent:0.0 multiagent:0.1 multiagent:0.2 multiagent:0.3; do
        out="$(tmux capture-pane -p -t "$p" 2>/dev/null)" || continue
        [[ -z "$out" ]] && continue
        anyidle=1
        printf '%s\n' "$out" | grep -q 'esc to interrupt' && { found=1; break; }
    done
    if [[ "$anyidle" -eq 0 ]]; then
        echo "🚨 ★異常★: どの pane も capture できません — ★idle 判定は信用できません★" >&2
        return 1
    fi
    if [[ "$found" -eq 0 ]]; then
        echo "⚠️  ★marker 'esc to interrupt' が ★どの pane にも在りません★★" >&2
        echo "    = ★全員 idle★ か ★TUI の表示が変わって器が壊れた★ かの ★どちらかです（区別していません）★" >&2
        echo "    → 表示が変わっていた場合、この口は ★何も拒否しません★。疑わしければ手で確かめてください。" >&2
    fi
    return 0
}
marker_alive || exit 4

waited=0
while ! is_idle; do
    if (( waited >= WAIT )); then
        echo "🚦 ★送りませんでした★: $agent は ★走行中★ です(⓪ 不成立)"
        echo "   ∵ agent-send.sh は本文の前に C-c を打つため、★送ると相手の turn を殺します★"
        echo "   → idle に成ってから再実行するか、--wait 秒 を付けてください"
        exit 3
    fi
    sleep 5
    waited=$((waited + 5))
done

[[ "$waited" -gt 0 ]] && echo "🚦 ⓪ 成立(${waited} 秒待機) — 送信します"
exec "$SCRIPT_DIR/agent-send-file.sh" "$agent" "$msg_file"
