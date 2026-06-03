---
name: feedback_verify_fn_scope_by_lexical_range
description: where-baked claim (symbol inside/outside fn X) は fn の lexical 範囲 (次 top-level fn) で確認、近接 comment は scope 証拠でない
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 3dbf9b0d-04e8-41e9-b05e-d813a6c036ca
---

「symbol が fn X の内側/外側で代入される」型の where-baked claim を verify する時、対象行の周辺を孤立 read したり近接する code comment を根拠にしてはならない。**fn X の lexical 範囲を必ず確定する** = fn 開始行 + 次の同 indent (top-level) fn / 閉じ括弧の位置を実 read して、対象行がその範囲内かを機械的に確認する。

**Why:** 2026-06-02 S5b design draft review で発生。worker1 が「quit_flag/title_buffer/window_size は build_window **外** (run/別経路) で焼く」と §0.2 で訂正、boss1 が spot-check で app.rs:2648-2655 を孤立 read し、近接 comment (「cloning here is behaviourally identical to the pre-S4 move」) を「build_window 外」の根拠と誤読 → 訂正を「正当」と endorse。実際は build_window = app.rs 1810-2659 (次 top-level fn alloc_window_id が 2660)、代入 2650-2652 は **build_window 末尾・内側**。PRESIDENT 独立 grep + 直 read が誤りを catch。comment は semantics を述べるだけで lexical scope を意味しない。

**How to apply:** where-baked / scope claim verify 時は (1) `grep -n 'fn '` 等で対象 fn の開始 + 直後の同 indent fn を特定 → 範囲確定、(2) 対象行番号が範囲内か確認、(3) comment は scope 証拠として採用しない (semantics 説明にすぎない)。[[feedback_verify_before_recommending]] の fn-scope 版。relay summary だけでなく authoritative 直 verify でも、read 範囲が狭いと誤る ([[feedback_memory_index_staleness]] と同系の「証跡の射程不足」)。
