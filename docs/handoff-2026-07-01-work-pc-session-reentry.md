# Handoff 2026-07-01 (work-PC) — セッション再開ポインタ (今日3件の束ね)

home-PC 再開用の consolidated ポインタ。work-PC (tlcr-X99E) で本日 3 件完遂。各詳細は個別 handoff doc、本 doc は再開手順 + 現 HEAD + memory mirror 補完。

## ★現 HEAD (home-PC で pull して一致確認)
- **GUI_kit** main = **`fb9191a`** (revivals47/GUI_kit)
- **hayate-kit-testruct** main = **`c4a16d6`** (revivals47/hayate-kit-testruct)
- **Claude-Code-Communication** = 本 doc commit 後の HEAD (★userfork=revivals47 から pull、origin=Akira-Papa は read-only、`git push userfork main`)

## ★home-PC 再開手順
1. 3 repo を pull (revivals47/userfork): GUI_kit→`fb9191a` / testruct→`c4a16d6` / comms→userfork 最新。
2. **env-drift**: home-PC は別 fontconfig。golden fail が出ても env-drift (canonical=work-PC、[[feedback_golden_env_drift]])、盲目 bless しない。非 golden fail のみ regression。
3. **memory mirror**: 下記「memory mirror」節 + 個別 handoff の memory 節を home-PC の `~/.claude/projects/.../memory/` へ反映。
4. PRESIDENT/boss1/worker は home-PC で fresh spawn (context は本 doc + 個別 handoff + memory)。

## 本日の 3 件 (work-PC、詳細は個別 handoff)
1. **朝: #313 font golden 再bless** (GUI_kit、home-PC が #313 で home-PC bless した text golden 12 件を work-PC canonical で再検証→env-drift 確定した 4 件を再 bless、PR#315)。+ 昨夜 home-PC 分 (#68/#73/#74/#313/#314) の memory mirror。
2. **フォント複数化 F1-F5 全完遂** → `docs/handoff-2026-07-01-testruct-font-multiplexing.md` (詳細)。3 family(角ゴ Noto Sans JP/丸ゴ Zen Maru Gothic/明朝 Noto Serif JP)×R/B、per-element FontPicker、screen↔PDF real Bold 一貫。testruct e331e97→(text-edit で c4a16d6)。
3. **text 編集 overlay バグ修正 3 症状 closure** → `docs/handoff-2026-07-01-testruct-text-edit-overlay-fix.md` (詳細)。G1/G2/G1b/G2b、TextInputWidget style API 追加 (GUI_kit fb9191a) + begin_edit 配線 (testruct c4a16d6)。

## ★memory mirror (canonical=work-PC、home-PC 反映用)
本日更新した work-PC canonical memory (個別 handoff の memory 節 + 下記で完全):
- **`reference_guikit_font_resolution.md`** (新規、朝作成 + フォント複数化で更新): GUI_kit 非バンドル OS 解決 (既定 sans=Inter Variable/mono=JetBrains Mono/CJK=Noto、golden drift 源) + #313 draw_text 既定 SansSerif 統一 + testruct は同梱 6 face (3 family×R/B) 上書き。
- **`project_hayate_kit_testruct.md`** に 2 大エントリ追記 (canonical、home-PC は full body を work-PC からコピー推奨): (a) ★フォント複数化 F1-F5 (sha chain F1 dd10b8c/F2 3c938db/F3 5c51104/F5a f300a09/F5b e331e97、SSOT BUNDLED_FONTS/FONT_CHOICES 分離、map_family 単一 choke point、RIBBI Bold、reframe parity) (b) ★text 編集 overlay 修正 G1-G2b (sha chain G1 424ce15/G2 0f43f6f/G1b fb9191a/G2b c4a16d6、TextInputWidget style API gap 還元、alignment split、click-N/A premise 訂正、IME candidate side-retrofit)。
- **`MEMORY.md`** 索引: `reference_guikit_font_resolution` 行追加済 (+朝の #315 系)。
- **`reference_dual_pc_setup.md`**: comms repo push 先 = `git push userfork main` の追補 (前回 f10f340 で mirror 済、home-PC 確認のみ)。
- ※フォント複数化 memory は `16ab310` handoff §memory、text-edit memory は `f0d8a47` handoff §memory にも要点あり。本 reentry note は canonical 所在の索引。

## backlog / open items (user trigger 待ち)
- ★**複数行 text 編集** (TextInputController single-line ゆえ大 track、text-edit fix の残)。
- フォント: woff2 圧縮 / italic 軸 / SVG font limitation / pdf_font BaseFont mislabel / FontPicker (B)自作dropdown・(C)GUI_kit DropdownWidget。
- text-edit: IME 他症状 (未確認、要 user 再洗い) / click-to-caret 不在 (forward-note 済)。
- 既存大物 (docs/REMAINING-TASKS.md): 解答用紙ビルダー対話 UI / zoom 絶対モデル化 / P1.1 モデルパリティ。
- design-system: P4-3 toolbar polish (backlog) / GUI_kit global default dark→light 反転 (将来②)。

## 設計レビュー画像 (work-PC ローカル、git 外)
`~/Documents/testruct-design-review/` (font_F1-F5/textedit_* 等)。home-PC で要れば HAYATE_SCREENSHOT で再生成。
