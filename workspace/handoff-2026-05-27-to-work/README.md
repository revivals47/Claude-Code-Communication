# Handoff 2026-05-27 — 職場 PC 引き継ぎ用 snapshot

自宅 PC → 職場 PC への移動に伴う引き継ぎ。職場 PC の Claude (PRESIDENT) は新規 session 開始時にこの README + `memory-snapshot/` を Read して context 復元。

## 本セッション (2026-05-27) サマリ — notepad「固まる」系 3 件を root-cause 解消

GUI_kit (Hayate UI) の L2 consumer = **notepad** で残っていた「固まる/応答なし」系トラブルを、すべて根本解決で land。

| 件 | PR | merge sha | 内容 |
|----|----|-----------|------|
| 右クリックコンテキストメニュー | GUI_kit #190 / app #14 | (main 集約) | Cut/Copy/Paste/Delete/Select All。L2 mechanism + L3 policy 分離 |
| ペースト deadlock (Ctrl+V「クラッシュ」/「応答なし」) | GUI_kit #191 | `d35b718` | self-paste short-circuit + source-identity tracking。#185 DnD self-drag と同 deadlock class |
| vector フォント hang | GUI_kit #192 | `38f9ea8` | 折返し計算 O(N²)→O(N) (cosmic `wrap_offsets`、bidi→manual fallback) |

- **GUI_kit main HEAD = `38f9ea8`** (origin 同期済)
- **hayate-notepad app main HEAD = `0a7ef26`** (origin 同期済、#14 merged)
- 全件 codex gate (design + impl-review) + **user live verify PASS**。vector-wrap は user 評価「だいぶマシ・実用的な範囲」。

### merged-branch hygiene 済
- 削除済 (local+remote): `feat/clipboard-self-paste-fix` / `feat/vector-wrap-perf` (両 doc は main の `workspace/worker2-notes/` に保全)
- **保持**: `diag/select-paste-crash` (`0da0725`、crash 再発時の backtrace 用)
- 旧 `feature/*` 等の branch backlog は別 hygiene triage (本 session scope 外)

## 残 follow-up (debt 化せず tracked、別 cycle) — 職場 PC で再開する候補

1. **(b) vector リサイズの引っかかり ★次 cycle 第一候補**
   - 症状: default(bitmap) フォントは「吸い付く」リサイズだが、vector フォントに切替えると「確実に遅れてリサイズがかかる」。user「人によってはめちゃくちゃ気にすると思う」。
   - 原因: resize で wrap 位置が変わる → 各 visual セグメント文字列が変わる → paint 側 `draw_text_cached_clipped` の shape cache (segment 文字列 key) が miss → 全セグメント毎フレーム cold 再 shape = O(total segments)。bitmap は `text_width` で shaping 不要ゆえ軽い。
   - **root-fix 方針 (バンドエイド禁)**: 論理行を 1 回だけ shape し、その glyph run を visual 行ごとに **slice** して描画 (resize で再 shape せず再 slice のみ)。#192 wrap_offsets が wrap 計算を 1-shape 化したのと同発想を paint 側に通す。
   - 詳細: `memory-snapshot/project_text_area_vector_wrap_perf.md`
2. **(a) cross-app ペーストの blocking read** → calloop fd 非ブロッキング化 (event loop が clipboard I/O で一切 block しない真の根治)。詳細: `memory-snapshot/reference_wayland_self_source_pipe_deadlock.md`
3. **Find dialog 表示位置バグ** (rect-based centering、`parent_w/h` が `layout()` でしか set されず modal で stale 0.0、`find_replace.rs` + `file_dialog.rs`、queue)

## 職場 PC 引き継ぎ手順

```bash
# GUI_kit (本体、両修正集約先)
cd ~/Documents/GUI_kit
git fetch origin && git pull --ff-only origin main   # → 38f9ea8

# notepad app (../GUI_kit path dep ゆえ GUI_kit pull 後に build すれば両修正込み)
cd ~/Documents/hayate-notepad-l2
git fetch origin && git pull --ff-only origin main    # → 0a7ef26

# この repo (handoff doc + memory snapshot)
cd ~/Documents/Claude-Code-Communication
git fetch origin && git pull --ff-only origin main
# workspace/handoff-2026-05-27-to-work/ を参照

# notepad live verify (任意): cargo build -j1 後 target/debug/hayate-notepad 起動
```

## memory snapshot (職場 PC で Read 推奨、優先順)

職場 PC の Claude memory が本セッション差分を持たない場合に備え、今 session で新規/更新した 6 file を `memory-snapshot/` にコピー。

1. `MEMORY.md` — index (全 memory entry 俯瞰、末尾 3 行が本 session 追加分)
2. `project_text_area_vector_wrap_perf.md` — ★follow-up (b) 再開の核 (root-fix 方針)
3. `reference_cosmic_wrap_and_bidi_gotchas.md` — #192 の wrap O(N²)→O(N) + bidi gotcha 機構
4. `reference_wayland_self_source_pipe_deadlock.md` — #191/#185 self-source deadlock class (再利用 reference)
5. `reference_clipboard_self_paste_deadlock.md` — #191 clipboard 個別 instance
6. `project_notepad_l2_phase2_resume.md` — notepad L2 rebuild 全体の state

## 再開時の次アクション

- 新 initiative なし、boss1 は standby 中。
- user が follow-up を再開する場合、**(b) vector リサイズ根治が第一候補** (優先度高め、root-fix 方針上記)。
- 再開フロー: PRESIDENT → boss1 へ dispatch (codex design-gate → in-house 実装 → live verify → merge)。in-house 実装が原則 (codex は review/第二意見)。
