---
name: agent-send.sh messages must not contain bash-interpretable code snippets
description: Inline `let X = ...` / `()` / `;` in code snippets get evaluated by bash before reaching tmux, mangling the message
type: feedback
originSessionId: b25e767b-5b93-44a6-a060-1a51ea148df8
---
agent-send.sh "..." の引数文字列内に Rust の `let t = active_theme();` のような snippet を含めると、bash の `let` 組み込みコマンドが先に走って構文エラーになり、メッセージが途中で切れる (PR #53 報告で実害あり)。

**Why:** agent-send.sh は受け取った文字列を bash 経由で tmux send-keys に渡すため、ダブルクォート内でも `()` `;` `=` の組合せは command substitution / arithmetic / variable assignment として再評価される余地がある。

**How to apply:**
- 報告メッセージに code snippet を含める時は、PR body / commit message に書いて URL で参照させる (本文は URL + 要点のみ)
- どうしてもインラインで送る場合は code 部分を完全に避けるか、シングルクォートで囲った literal にする
- 再送する場合は最初から code snippet を含めない簡潔版にする (前回はそれで成功)
- **2026-05-07 追加教訓 (再発防止)**: agent-send.sh の引数文字列は **必ず single-quote で囲む** (double-quote は backtick が command substitution として評価される)。double-quote + 内部 backtick で `field_name` 等が空文字に置換される実害を 2 度発生。code snippet (struct field 名 / fn signature / namespace) は backtick 不使用で記号化 (例: `range` → range、`fn::path()` → fn::path 関数名のみ) するか single-quote literal で送る。code 含む長文は file 化して commit + push、agent-send は file path + commit hash 参照のみで送る方が安全
