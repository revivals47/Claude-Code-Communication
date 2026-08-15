#!/usr/bin/env bash
# boss1_send.sh — boss1 の送信を「器」で包む(段 3)
#
# ★2026-08-15 16:4x 改訂 — 私が引いた線自体が誤りだった★
#   初版は「本文に backtick があれば送らない」にした。★これは誤り★:
#   検定すると "$(cat file)" は ★結果を再スキャンしない★ ので、file 経由なら backtick も $() も
#   ★literal のまま byte 一致で運ばれる★(PRESIDENT #389 (1936) の陽性/陰性対照と同じ結論)。
#   ⇒ ∴ 初版は ★安全な本文を誤って拒む★ 器だった。
#
#   ★真の不変条件は「backtick を使わない」ではなく「本文を argument に直接書かない」★。
#   壊れるのは ★caller の shell が本文を parse する瞬間★ であって、
#   agent-send.sh の中では ★既に消えた後★ = 中に検査を足しても原理的に検出できない((1934))。
#
# 使い方:
#   boss1_send.sh <相手> <本文 file>
#
# 効き方:
#   ・本文は ★必ず file 経由★(argument に載せない) ⇒ 記号が壊れない
#   ・agent-send.sh / log は ★絶対 path 固定★(cwd に依存しない)
#   ・送信後に ★SENT 行を数えて増えたか確認★ ⇒ 増えていなければ ★落ちる★(exit 3) = 無音失敗の検出

set -u

ROOT=/home/ken/Documents/Claude-Code-Communication
LOG="$ROOT/logs/send_log.txt"
SEND_FILE="$ROOT/agent-send-file.sh"   # PRESIDENT #389 で追加された口(本文を file から読む)
SEND_INLINE="$ROOT/agent-send.sh"      # 従来の口(fallback)

if [ $# -ne 2 ]; then
  echo "usage: boss1_send.sh <相手> <本文 file>" >&2
  exit 64
fi
TARGET=$1
BODY=$2
[ -f "$BODY" ] || { echo "★本文 file が見つかりません: $BODY★" >&2; exit 66; }

BEFORE=$(grep -c "SENT" "$LOG" 2>/dev/null || echo 0)

if [ -x "$SEND_FILE" ]; then
  "$SEND_FILE" "$TARGET" "$BODY" >/dev/null 2>&1
else
  # fallback: "$(cat …)" は結果を再スキャンしないので記号は保たれる(上の改訂注記)
  [ -x "$SEND_INLINE" ] || { echo "★送信口が両方ありません★" >&2; exit 66; }
  "$SEND_INLINE" "$TARGET" "$(cat "$BODY")" >/dev/null 2>&1
fi

# ★SENT 行は送信呼び出しの ~3 秒後に書かれる(ATTEMPT → SENT)★
#   初版は直後に 1 回だけ数えて ★偽陽性(送れているのに「送れていない」)★ を出した。
#   ⇒ ∴ 数え直しを ★最大 8 秒待つ★。これも「通すべきものを通すか」の検定側の穴だった。
AFTER=$BEFORE
for _ in 1 2 3 4 5 6 7 8; do
  sleep 1
  AFTER=$(grep -c "SENT" "$LOG" 2>/dev/null || echo 0)
  [ "$AFTER" -gt "$BEFORE" ] && break
done
if [ "$AFTER" -le "$BEFORE" ]; then
  echo "★★送信されていません = SENT 行が増えていません($BEFORE → $AFTER)★★" >&2
  echo "⇒ 相手名 / pane を確認してください: $TARGET" >&2
  exit 3
fi

grep -n "$TARGET: SENT" "$LOG" | tail -1 | cut -c1-120
