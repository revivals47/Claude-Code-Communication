---
name: reference_cosmic_wrap_and_bidi_gotchas
description: cosmic-text 折返しの 2 gotcha — 手書き growing-prefix 測定は O(N^2)(vector で hang)、LayoutRun.rtl は base direction のみで embedded RTL を取りこぼす(intra-run glyph.start 昇順 check が真の signal)
metadata: 
  node_type: memory
  type: reference
  originSessionId: bba0eb80-c5e4-4310-a4ee-8daaac9203de
---

GUI_kit vector wrap O(N) 修正 (2026-05-27 ★MERGED PR #192、main 38f9ea8) で確立した cosmic-text 折返しの 2 gotcha:

**1. 手書き growing-prefix 折返しは O(N^2)、vector で hang。** TextAreaWidget の旧 compute_visual_lines は 1 文字ごとに prefix(seg_start..next) を measure。bitmap は text_width=advance 和で安価だが、vector は measure_text_width→shape_cached が growing prefix 毎回 unique key=cache-miss→full cosmic shape。viewport に収まる行(break 無し)でも prefix 1..N を N 回 → 600 char で 3.5 秒 freeze (Format>Font hang の root)。★fix= cosmic native wrap (TextEngine::wrap_offsets が Buffer.set_size+set_text+shape 1 pass で layout_runs から visual-row byte 範囲を partition、O(N)/行)。600char 3.53s→11ms。partition は row start で境界定義 (collapse trailing ws は次 row start 境界で上 row 末尾吸収=全 byte カバー)。

**2. LayoutRun.rtl は『行の base direction』のみ、embedded RTL を取りこぼす。** LTR-base 行に embedded RTL ("hello "+Hebrew+" world") があっても ★run.rtl=false。run.rtl だけで bidi 検出すると embedded RTL が素通り。★真の signal = run 内 glyph.start が非昇順 (Hebrew row は cosmic 0.18.2 dump 実測で starts=[12,10,8,6] 降順、LTR row は昇順)。bidi 検出は `run.rtl || run 内 glyph.start 非昇順` の OR にする。検出時は [start,end] per-row partition が disjoint logical span を表現不能ゆえ fallback (旧手書き loop)。LayoutGlyph.start/.end = 'index of cluster in original line' = line 相対 byte offset・cluster(char)境界。

cosmic-text 0.18.2。partition gate logic は pure fn 抽出で font 非依存 unit-test 化可 (非単調/overlap arm は実 cosmic で run.rtl が先 fire ゆえ defensive redundancy)。関連 [[reference_bitmap_font_fractional_scroll_y]] [[feedback_verify_before_recommending]]
