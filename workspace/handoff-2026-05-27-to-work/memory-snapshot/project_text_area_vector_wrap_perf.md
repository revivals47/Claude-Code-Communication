---
name: project_text_area_vector_wrap_perf
description: TextArea vector フォントの重さ。O(N²) growing-prefix re-shape(wrap 計算)は
metadata: 
  node_type: memory
  type: project
  originSessionId: 98d781a1-a05c-4df7-8911-6ed20b1560fd
---

notepad/TextArea で vector フォント(Sans Serif 等)に切替えると resize/編集/paste が固まる問題の追跡。

**主因 = 根治済 (#192、GUI_kit main 38f9ea8、2026-05-27)**: vector path の growing-prefix re-shape **O(N²)**(フォント切替後 hang の核心)を `wrap_offsets`(cosmic 1-shape-pass O(N))に。fix 機構と bidi gotcha の詳細は [[reference_cosmic_wrap_and_bidi_gotchas]]。user live verify「だいぶマシ・実用的な範囲」PASS(2026-05-27)。

**残 follow-up (b) = resize 時の per-segment cold re-shape**(別 cycle、root-fix 予定): resize で wrap 位置が変わる → 各 visual セグメントの**文字列が変わる** → paint 側 `draw_text_cached_clipped` の shape cache(cosmic `shape_cached` は segment 文字列 key)が miss → **全セグメントを毎フレーム cold で再 shape** = O(total segments)。bitmap は `text_width`(shaping 不要)ゆえ resize が「吸い付く」が、vector は「確実に遅れてリサイズがかかる」(user 2026-05-27、「人によってはめちゃくちゃ気にすると思うぜ」)。**root-fix 方針(バンドエイド禁、[[feedback_platform_principle]])= 論理行を 1 回だけ shape し、その glyph run を visual 行ごとに slice して描画**(resize で再 shape せず再 slice のみ)。wrap_offsets が wrap 計算を 1-shape-pass 化したのと同発想を paint 側に通す。codex 2nd-opinion で secondary cost として識別。

**その他 tracked**: (a) cross-app paste の blocking read_to_string → calloop fd 非ブロッキング化([[reference_wayland_self_source_pipe_deadlock]])。Find dialog 表示位置バグ(rect-based centering、parent_w/h が layout() のみ set で modal は stale 0.0、`find_replace.rs`+`file_dialog.rs`、queue)。
