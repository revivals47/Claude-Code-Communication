# Handoff 2026-07-02 (work-PC) — セッション再開ポインタ (今日の全成果を束ねる)

**★user は今日から3日間このPC(work-PC)を使わない。home-PC で引き継ぐ想定。漏れなきよう本 doc に全集約。**

work-PC (tlcr-X99E) で crash 復帰後の長時間 session。testruct のデザイン/UX を一気に前進させ、全て land 済。詳細は個別 handoff 3 本、本 doc は再開手順 + 現 HEAD + memory mirror 完全版。

## ★現 HEAD (home-PC で pull して一致確認)
- **GUI_kit** main = **`5a08e7a`** (revivals47/GUI_kit)
- **hayate-kit-testruct** main = **`c4e41cc`** (revivals47/hayate-kit-testruct)
- **Claude-Code-Communication** = 本 doc commit 後の HEAD (★`git push userfork main`、origin=Akira-Papa は read-only)

## 今日 land した成果 (時系列、全て test緑 + codex + GPU実機確認済)
1. **メニューバー上端テキスト修正** (GUI_kit PR#318 `3dcc9e4`) → `docs/handoff-2026-07-02-testruct-menubar-vcenter.md`。cap_v_metrics 中央寄せ、live-Vulkan 限定バグ。
2. **面階層 + Lucide AA アイコン** (GUI_kit PR#319 `4bfd194` / testruct PR#82 `7ce8032`) → `docs/handoff-2026-07-02-testruct-design-lucide-icons.md`。matte/panel コントラスト + 上部chrome白統一 + `draw_vector_icon` パイプライン(CPU/Vulkanパリティ) + SVGパーサ + widget::lucide 19 icon + ToolbarWidget 配線。
3. **P2掃除 + 幅可変パネル** (GUI_kit PR#320 / testruct PR#83)。recessed 245→235 + border 214,218,226→207,212,222 一掃。SplitView `with_*_fixed_resizable` 新設 (ドラッグで固定幅変更、window resize でも維持)、左サイドバー(120/90-280)+右inspector(300/280-520)可変。
4. **divider リサイズカーソル** (GUI_kit PR#321 `5a08e7a` / testruct PR#84 `c4e41cc`)。SplitView `with_cursor_buffer` で hover/drag 時 ColResize、ペイン移動で Default 復帰。
5. **★アコーディオン = 試作したが user 判断で撤回** (main 未反映、ブランチ破棄、CHEVRON_DOWN も取下げ)。理由=現 inspector の情報量では恩恵薄い。**再導入しない (inspector プロパティが大幅増まで)**。

## ★memory mirror (canonical=work-PC、home-PC の `~/.claude/projects/-home-tlcr-Documents-Claude-Code-Communication/memory/` へ反映)

今日の memory 変更は **3 件**。うち 2 件は前 handoff で verbatim mirror 済、1 件(initiative 追記)は本 doc に verbatim。

### (A) 新規 `feedback_gpu_text_vcenter_cap_band.md`
→ **verbatim は `docs/handoff-2026-07-02-testruct-menubar-vcenter.md` の memory 節にあり**。home-PC は同 doc からファイル作成 + MEMORY.md 索引追加。要点: live-Vulkan の text 縦位置バグは HAYATE_SCREENSHOT(CPU) で再現不可、bar/row text は cap_v_metrics で中央寄せ。

### (B) 新規 `reference_guikit_vector_icon_pipeline.md`
→ **verbatim は `docs/handoff-2026-07-02-testruct-design-lucide-icons.md` の memory 節にあり**。home-PC は同 doc からファイル作成 + MEMORY.md 索引追加。要点: draw_vector_icon = tiny-skia AA→draw_image で CPU/Vulkan パリティ、Lucide SVG を widget::lucide に写す、ImageKey 非重複配置。

### (C) 編集 `project_testruct_design_system_initiative.md` — 本 session で 2 段落追記
- 第1段落「**2026-07-02 work-PC 続伸**」(面階層+アイコン) は前 handoff `..lucide-icons.md` で既知。
- 第2段落「**2026-07-02 続伸2**」(幅可変+カーソル+アコーディオン撤回+P2完了) が **NEW = 下記 verbatim を「決定保留」段落の直前に挿入**:

```markdown
**2026-07-02 続伸2 (同 session、user「左右パネルがペラペラ」)**: ③**P2 掃除完了** = recessed surface-base 245→235 (scrollbar/progress/spin/tab-bar) + border-subtle 214,218,226→207,212,222 を preset dir 一括 sed (~25 箇所)、ライトテーマの orphan 値一掃 (GUI_kit PR#320)。④**幅可変パネル** = SplitView に `with_first_fixed_resizable`/`with_second_fixed_resizable` 新設 (fixed-pin をドラッグで px 変更可、window resize でも幅維持、pane_sizes で non-pinned min 尊重。GUI_kit PR#320)。testruct = 左 pages サイドバー(120/90-280) + 右 inspector(300/280-520) 両方可変、PagesSidebar layout をペイン幅追従に (testruct PR#83)。⑤**divider リサイズカーソル** = SplitView `with_cursor_buffer` (App cursor cell 共有) で hover/drag 時 ColResize/RowResize、ペイン移動で Default 復帰。testruct 両 SplitView に注入 (GUI_kit PR#321 / testruct PR#84)。**land HEAD: GUI_kit main `5a08e7a`、testruct main `c4e41cc`、全 codex 済 (resizable の non-pinned min 割れ根治)、test 2467緑、GPU 実機で幅可変+カーソル user 確認済**。⑥**アコーディオン = ★試作したが user 判断で撤回** (inspector を折りたたみグループ化したが「効果が分からない/情報量が少なく恩恵薄い」→ ブランチ破棄、main 未反映、CHEVRON_DOWN も取下げ)。**教訓: 現 inspector の情報量ではアコーディオンは過剰。inspector のプロパティ群が大幅に増えるまで再導入しない**。
```

※ MEMORY.md 索引は初期化イニシアチブ行が既存ゆえ追加不要 (本文追記のみ)。reference_guikit_vector_icon_pipeline の索引行は (B) の handoff で追加済。

## ★home-PC 再開手順
1. 3 repo pull (revivals47/userfork): GUI_kit→`5a08e7a` / testruct→`c4e41cc` / comms→userfork 最新。
2. memory 反映: 上記 (A)(B) は各 handoff から、(C) 第2段落は本 doc から。**今日の handoff 3 本全て確認**。
3. env-drift: home-PC は別 fontconfig。golden fail は env-drift の可能性 ([[feedback_golden_env_drift]])、盲目 bless しない。非 golden fail のみ regression。
4. PRESIDENT/boss1/worker は home-PC で fresh spawn (context = 本 doc + 個別 handoff + memory)。

## backlog / open items (user trigger 待ち)
- **design-system 残**: 旧 IconCommand editor 定数 (icon.rs UNDO/CUT 等) の dead cleanup / window control アイコン(titlebar min/max/close)の Lucide 化 / GUI_kit global default dark→light 反転 (将来②)。
- **P4/framework**: SectionWidget/ButtonWidget font-family override (SansSerif app で primitive 使う時の gap) / P4-3 toolbar separator styling。
- **testruct 機能大物** (docs/REMAINING-TASKS.md): 複数行 text 編集 (TextInputController single-line ゆえ大 track) / 解答用紙ビルダー対話 UI / zoom 絶対モデル化 / P1.1 モデルパリティ。
- **フォント**: woff2 圧縮 / italic 軸 / FontPicker を GUI_kit DropdownWidget 化 / pdf_font BaseFont mislabel。

## 設計レビュー画像 (work-PC ローカル、git 外)
`/tmp/.../scratchpad/` に本 session の before/after 多数 (面階層/アイコン gallery/toolbar 比較)。恒久保存が要れば home-PC で HAYATE_SCREENSHOT 再生成可 (面塗り色・アイコンは CPU screenshot で再現可、text 縦位置と幅可変ドラッグは GPU 実機要)。
