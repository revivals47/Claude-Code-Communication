#!/bin/bash
# 📄 file の中身をそのまま送る送信口（backtick 事故の構造的な封じ手）
#
# ============================================================================
# なぜ在るか
# ============================================================================
# backtick(`) を含む本文を  ./agent-send.sh boss1 "...`foo`..."  の形で送ると、
# ★caller の shell が command substitution として評価し、その部分が消える★。
# 2026-08-15 だけで boss1 が 2 回踏み、PRESIDENT も過去に踏んでいる。
#
# ★重要★: この破壊は ★agent-send.sh が起動する前★ に caller の shell で起きる。
#   ∴ agent-send.sh の中にどんな検査を足しても ★原理的に検出できない★
#     (受け取った時点で既に消えているため)。
#   ∴ 「backtick 禁止」と手順書に書くのは段 2(書式)にすぎず、実際 20 分後に再発した。
#
# ∴ 段 3(器が強制する) = ★本文を argument に載せない★。file から読む。
#   file の中身は shell を通らないので、backtick も $() も ★literal のまま★運ばれる。
#
# ★agent-send.sh 自体は変更していない★ = 「今依存している通信路を、依存しながら
#   書き換えない」という記録済みの判断(agent-send.sh L9)を尊重する。これは追加の口。
#
# 使い方:
#   cat > /tmp/msg.txt <<'EOF'      ← ★quoted 'EOF' ゆえ heredoc 内も評価されない★
#   本文(backtick を含んでよい)
#   EOF
#   ./agent-send-file.sh boss1 /tmp/msg.txt
# ============================================================================

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ $# -lt 2 ]]; then
    cat << 'USAGE'
📄 file の中身を送る

使用方法:
  ./agent-send-file.sh [エージェント名] [file path]

エージェント: president / boss1 / worker1 / worker2 / worker3

例:
  cat > /tmp/msg.txt <<'EOF'
  本文
  EOF
  ./agent-send-file.sh boss1 /tmp/msg.txt
USAGE
    exit 1
fi

agent="$1"
msg_file="$2"

if [[ ! -f "$msg_file" ]]; then
    echo "❌ file が在りません: $msg_file"
    exit 1
fi

if [[ ! -s "$msg_file" ]]; then
    echo "❌ file が空です: $msg_file(空送信は事故のもと)"
    exit 1
fi

# ★観測して知らせるだけ★: 送信は止めない(backtick は literal で正しく運ばれる)。
# 目的は「この便には backtick が在る」を送信側の目に触れさせること。
bt=$(grep -c '`' "$msg_file" || true)
if [[ "$bt" -gt 0 ]]; then
    echo "ℹ️  backtick を $bt 行で検出 — ★この口なら literal のまま運ばれます★"
fi

bytes=$(wc -c < "$msg_file")
lines=$(wc -l < "$msg_file")
echo "📄 $msg_file → $agent（${lines} 行 / ${bytes} B）"

# ★★cwd を repo 直下に固定する★★(2026-08-15 boss1 実測の根本原因)
#   agent-send.sh は log を ★相対 path `logs/send_log.txt`★ で開く。∴ cwd が repo 直下で
#   ないまま呼ぶと ★`workspace/degimon-faithful178/logs/send_log.txt`(2026-07-19 の古い同名
#   file)に書かれる★。送信自体は成功するので ★誰も気づかない★ うえ、検証の grep は本物の
#   log を見るため「送れているのに送れていない」と判定される(boss1 が 3 回踏んだ)。
#   ∴ ★caller の cd 規律に依存しない★ = この口が自分で保証する。
cd "$SCRIPT_DIR" || { echo "❌ repo 直下へ cd できません: $SCRIPT_DIR"; exit 1; }

# ★本文は $(cat) で argument に載せるが、caller の shell を通らないので
#   backtick は再評価されない(argument の中身は展開対象にならない)。
exec "$SCRIPT_DIR/agent-send.sh" "$agent" "$(cat "$msg_file")"
