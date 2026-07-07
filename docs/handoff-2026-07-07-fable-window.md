# Handoff 2026-07-07 — work-PC: Fable window session (multiline text edit 完遂 + K4→K8→K9 描画 fidelity 完遂)

> **status: 確定 (boss1、2026-07-07 window close 時点、live-verify finding 1-4 全 closure + finding 4 は user 実機 PASS 済)**。
> land 済み分から記載、`⏳追記待ち` マークは該当トラック land 次第 boss1/担当 worker が追記。
> 規範: in-head 判断を残さない (Fable window 規範 = モデル window 終了前の完全外部化)。

## §A. 本日 land 済み PR / sha 一覧

### worker1 (track1: multiline-text-edit → micro-PR → live-verify finding 1 + 3)
| # | repo / PR | merge 後 main | 内容 |
|---|---|---|---|
| 1 | testruct branch commit `14d1e04` | (#88 に同梱) | RFC-multiline-text-edit (Phase A、432 行)。Mac 正典 ee5f49a + Rust 13e4392 + kit の 3 面 grounding。PRESIDENT 裁定 4 件 = 案a TextAreaWidget / 方式(i) 中央 modal / B-1・B-2 受容 / 縦書き IN (横書き編集面) |
| 2 | GUI_kit **#323** | `5189ac1` | TextAreaWidget overlay-host 3 gap (K-a prelude export + FontFamilyOwned / K-b ImePreedit→ImeRect、paint anchor と式 lockstep / K-c pub set_focused、Blur parity)。codex LGTM (informational 1 のみ) |
| 3 | testruct **#88** | `094bb1c` | TextElement 複数行編集の中央 modal 化 (text_editor_dialog + wire 4 hook + text_edit.rs 表セル専用縮退)。test 380/0 緑、edit 系 19 本。codex High/Med finding 0 |
| 4 | GUI_kit **#325** | `f009af6` | vector_icon.rs:471 never_loop root-fix (while→get(i)?+if、bit-exact、net -2 行)。**workspace clippy blocker 解消** — 以後 clippy に -A/-p 回避不要 |
| 5 | GUI_kit **#328** | `85da719` | **finding 1 kit 分**: `RichTextAlign` を layout_rich (CPU/GPU 共通 choke point) に通す = 複数行の per-line 揃え (cosmic native)。Leading→cosmic None で golden 27/27 bit-exact。**K-g (Justified) の非編集描画分を無償 closure** (編集面 Justified = K-g 本体は依然 follow-up)。recording は RichCmd align field + replay 追随。codex LGTM High/Med 0 |
| 6 | testruct **#97** | `76d34e8` | **finding 1 配線**: Inspector の複数行揃えが canvas 反映されない bug の root-fix。screen_painter draw_text を単一行 (既存 align_offset 経路 bit-exact 温存) / 複数行 (`draw_rich_rgba_aligned` に委譲) で分岐、装飾は `rich_line_extents_aligned` 追従。壊れ挙動 assert の旧 test を正 3 本に置換。test 405/0 緑。PDF/SVG 経路の複数行揃えは positioned-glyph 別サブシステムで follow-up 起票済 |
| 7 | GUI_kit **#329** | `3cc13c0` | **finding 3 kit 分**: 縦書き回転字形。`needs_vertical_rotation` (ー30FC/〜301C/～FF5E/—2014/–2013/―2015/─2500) を分類し rotate flag を伝播、`draw_glyph_image` に 90° CW 回転を追加 (`draw_glyph_image_maybe_rot`、rotate=false ビット同一=golden 27/27) + セル中心の幅高入替配置。`positioned_glyphs` が rotate expose。案A (vert/vrt2 置換) follow-up trigger を doc comment に明記。codex LGTM High/Med 0 |
| 8 | testruct **#98** | `ffe308b` | **finding 3 配線**: PDF の複数行縦書き回転。`emit_text_glyphs` が rotate glyph の text matrix を 90° CW `[0,1,1,0]` に組む (通常字 bit-exact)。fixture `vertical_glyph_rotation.testruct` 新設。test 409/0 緑。**visual gate は非対称字 〜 で方向確認** (対称字 ー は CW/CCW/鏡映を区別できず偽陰性、boss1 指摘)。REMAINING に案A + 禁則・約物 spacing 紐付け |
| 9 | GUI_kit **#330** | `0e5e2b0` | **finding 4 (finding 3 の PDF 側 regression 修正、kit-only)**: PDF で回転字形がセル中心から swing・隣接字食い込み。root=positioned_glyphs の rotated baseline が回転非考慮の旧式。導出式 `baseline=(ink_x+ih-it, ink_y-il)` で pivot 補正 (rotate=true 分岐のみ、rotate=false bit-exact=golden 27/27)。**testruct #98 は無変更で自動的に正** (kit が pivot 補正 baseline を expose、Tm `[0,1,1,0,g.x,g.y]` に補正 g.x/g.y が渡るだけ = 平台 layer 統一 invariant)。数値契約 test 追加。codex LGTM High/Med 0 |

> **finding 1 (Inspector 文字揃えが複数行で canvas 非反映) = kit #328 + testruct #97 の 2-repo chain で closure**。断線点は発行経路でなく screen_painter の single-line-only 揃え適用 (#88 で複数行常態化して表面化した pre-existing gap)。
> **finding 3 (縦書き ー 等が横向き) = kit #329 + testruct #98 で screen/PDF 両経路 closure**。cosmic-text 0.18 が vert/vrt2 を引けないため描画時 90° 回転 (案B)。screen/PDF 共有の shape_vertical_glyphs 単一 choke point ゆえ 1 kit fix で両経路。方向 gate は非対称字 〜 で偽陰性を回避。
> **finding 4 (finding 3 PDF の配置 swing) = kit #330 で closure (kit-only、testruct 無変更)**。回転字形の PDF baseline を pivot 補正 = kit-SSOT (screen/PDF が同一 layout data 消費)。完了 gate = **fixture PDF を pdftoppm raster + screen `--export-png` を並置し boss1 が画像 view で方向+セル位置 both 判定** (content stream op assert のみでは不合格 = 前回 finding 3 gate の検証 gap 教訓、非対称字 + セル位置の両面で PASS)。

### worker2 (K4 gradient チェーン → K8/K9)
| # | repo / PR | merge 後 main | 内容 |
|---|---|---|---|
| 5 | GUI_kit **#324** | `a9d6c66` | K4: multi-stop linear/radial gradient fill primitive (CPU + Vulkan parity) |
| 6 | GUI_kit **#326** | `4bbe1aa` | K8 SaveLayer primitive (kit 側、真の alpha 合成の下地) |
| 7 | testruct **#94** | `57c1953` | K8 配線 (Shape opacity の真の SaveLayer 合成) + K4b closure (polygon gradient = SaveLayer + LayerMask::Polygon + 矩形 gradient の計画的合流、独立 primitive 不要) |
| 7b | GUI_kit **#327** | `d826caa` | K9 kit 側: text alpha 貫通 (IR rgba 化 + `*_rgba` variant、旧名 a=255 委譲 = golden で bit-exact 機械確認) + shadow Gaussian blur (LayerParams additive、CPU separable + VK は vk_blur 再利用)。**副次 root-fix**: vk_blur の h/v params UBO aliasing (全画面 blur が縦二重になる pre-existing 潜在バグ) を BlurRecordSet pool 化で根治 |
| 7c | testruct **#95** | `9b37287` | K9 配線: 影の Gaussian blur (`SHADOW_BLUR_TO_SIGMA = 0.5` 初期較正) + render_element generic wrap で全 leaf node 種 opacity layer 化 (Scene 経路 parity) + text 色 alpha 貫通。**K4→K8→K9 描画 fidelity トラック完遂** (worker2 全 7 PR 一発 LGTM) |

### worker3 (track3: 設計 doc → 公開 blocker チェーン → live-verify finding 2)
| # | repo / PR | merge 後 main | 内容 |
|---|---|---|---|
| 8 | testruct **#86** | `0449b44` | track3 設計 doc 3 本 (p0-2-format-compat-ci / release-quality-gaps / zoom-absolute-model)。zoom 二重構造 finding (fit 相対 user_scale + Ctrl+0 意味逆転) は boss1 → PRESIDENT 上申済 |
| 9 | testruct **#87** | `bb24ceb` | R-1 AppImage packaging v1 (.desktop / 暫定 icon = Pillow 生成器ごと commit / build-appimage.sh j1 / smoke-checklist.md)。AppImage 27MB 生成、headless smoke 4 項 PASS (フォント埋込・PDF subset・%f 経路・GUI 8s 生存)。副次 finding: 既定 kokugo fixture はテキスト無し空枠 (native と bit 一致 = packaging 起因でない、フォント目視は --answer-sheet fukuoka で) |
| 10 | testruct **#89** | `97dfa4f` | P0-2a: format_version (欠損0・lenient・writer 単一チョークポイント stamp) + Fill::Unknown (最狭境界 raw 保持、WireFill 委譲でワイヤ形 bit 不変、表示は白 degrade)。codex LGTM High/Med 0、239/0 緑 |
| 11 | testruct **#91** | `e62af2c` | P0-2e 縮退版: roundtrip_harness bin (emit basic/future/legacy + recode + dump) + cross-impl-roundtrip.sh (10 PASS/0 FAIL/2 SKIP、Swift/C# は SKIP 縮退) + disabled workflow (dispatch only) |
| 12 | testruct **#92** | `6bb34eb` | R-2 README 全面刷新 (教員向け冒頭 + AppImage 手順最上部 + 現コード grep 裏取り機能表 + 制限節の正直記載 + screenshot placeholder 3 枠) |
| 13 | testruct **#96** | `54d7309` | **finding 2**: 縦書き ⇔ 横書きトグルを Inspector に追加 (Mac parity、wire 変更なし = TextStyle.vertical は既存 field)。ShellAction::ToggleVertical 1 個、新 command 型なし (既存 TextStyleCommand 経由で undo 自動)。worker3 実装、worker1 finding 1 (#97) と inspector 系 file 区画分離で無競合 land |

> **finding 2 (縦書きトグル) = testruct #96 で closure** (worker3 実装)。finding 1 (#97) と同 session 並走、区画調整で inspector.rs / screen_painter.rs を分けて conflict ゼロ。

**repo HEAD 記録 (worker1 更新 20:40、finding 4 land 反映)**: GUI_kit main = `0e5e2b0` (#330 回転字形 pivot 補正) / testruct main = `ffe308b` (#98 縦書き回転 PDF 配線、finding 4 は kit-only ゆえ testruct 不変) / testruct-v3 master = `ee5f49a` (behind 47 を ff 済、Win 1.0.9 まで取込)。

## §B. user live-verify 残項目 (集約 — user 在席時にまとめて実施)

### B-1. multiline text edit (checklist 本体 = testruct `docs/rfc/multiline-live-verify-checklist.md`、main に耐久化済)
1. **IME 候補窓位置** — modal 内日本語入力で候補窓が caret 追従するか (= kit #323 K-b ImeRect 経路の**実機初検証**)
2. **R-1 観察点**: TextArea 自前候補ポップアップと fcitx5 システム候補窓の**二重表示にならないか** (二重なら TextInput の両立実装と突き合わせて kit fix)
3. **wrap 行 caret** — 長文で折返し + ↑↓ 破綻なし (※↑↓が論理行単位なのは仕様内 = K-h 未実装、RFC B-9)
4. **縦書き往復** — 縦書き要素を編集→改行→Ctrl+Enter→縦書き複数 column 再描画
5. **modal UI の user 実機確認 = 実質 veto 機会** (中央パネル+暗転+Enter 契約変更 B-1。違和感は v2 調整、方式 veto は PRESIDENT ③)
- 回帰スモーク: 表セル Enter=確定不変 / 数式エディタ従来どおり / Esc・click-away・Delete gate

### B-1b. finding 1/2/3 の再検証 (本 session live-verify 中に検出→修正済、再確認用)
> user の live-verify Part A 中に 3 件検出し同 session で root-fix land。**修正の再確認**を上記 B-1 と同枠で:
1. **finding 1 (複数行テキストの横揃え)** — 複数行 TextElement を選択 → Inspector で 中央/右 揃え → **canvas 上で per-line に揃うこと** (kit #328 + testruct #97、以前は Start へ fallback して無反応だった)。Justified も描画反映される (画面のみ、PDF/SVG は follow-up)。単一行の揃えは従来どおり不変。
2. **finding 2 (縦書きトグル)** — テキスト要素選択 → Inspector で 縦書き ⇔ 横書き トグル → 表示が切り替わること (testruct #96、Mac parity)。
3. **finding 3+4 (縦書き ー/〜/— 回転 + PDF 配置)** — fixture `crates/testruct-core/tests/fixtures/vertical_glyph_rotation.testruct` を開く → 縦書きの **長音符 ー・波ダッシュ 〜・ダッシュ — が縦向きに正立回転**していること (screen)。同 fixture を PDF export → **PDF でも同じく回転し、かつ各字がセル中心に均等 pitch で並ぶ**こと (kit #329 回転 + #330 pivot 補正 + testruct #98 配線、screen/PDF 完全一致)。★特に **〜 の波の向き**が正しいか (対称な ー でなく非対称な 〜 が方向確認の要) + 回転字形が隣セルへ食い込んでいないか (finding 4 = 修正前は PDF で右下 swing していた)。括弧類は従来どおり縦書き字形。**→ ✅ user 実機 PASS 済 (2026-07-07 window 内、判定『今度はバッチリ』— PDF 再出力で ー/〜 のセル位置・字送りとも screen 一致確認。screen 側 finding 3 分も同 session で PASS 済)。次 session での再確認は不要、regression 監視のみ。**
- 補足: finding 1 の GPU 実機反映は B-1 の live 目視で兼ねられる (cosmic per-line 揃えは CPU/Vulkan 共通 layout ゆえ両 backend で効く、実機初目視)。finding 3 も screen は GPU、PDF は positioned-glyph の別経路だが kit の単一 shape choke point 共有ゆえ整合。

### B-2. AppImage (worker3 track) — user live-verify 残 4 項 + screenshot 撮影
checklist 本体 = testruct `packaging/appimage/smoke-checklist.md` (main 耐久化済)。headless 可能分 (#2 フォント / #6 PDF / #8 %f / #1 近似) は worker3 実施済 PASS — 残りは GUI 実操作が要る 4 項:
1. **真のダブルクリック起動** — ファイルマネージャから AppImage をダブルクリック (実行権限付与の手順も体験確認)
2. **フォント picker 切替** — Inspector で 角ゴ → 丸ゴ → 明朝、書体が目視で変わるか
3. **保存往復** — 名前を付けて保存 → 終了 → 再起動 → 開く で同じ見た目
4. **印刷** — メニュー → 印刷 (PDF 生成 → xdg-open で viewer が開くか)

※ フォント目視は既定 fixture でなく `--answer-sheet fukuoka` の文書で (既定 kokugo はテキスト無し空枠、§A #9 の副次 finding)。
生成物: AppImage は `./scripts/build-appimage.sh` で随時再生成可 (appimagetool は work-PC ~/.local/bin 導入済)。

**あわせて README screenshot 3 枠の撮影** (R-2 #92 で placeholder path 確保済、live-verify と同枠で):
- `docs/images/main-window.png` — メイン画面 (解答用紙を開いた状態)
- `docs/images/answer-sheet-builder.png` — 解答用紙ビルダーのダイアログ
- `docs/images/pdf-export.png` — PDF 出力を PDF ビューアで開いた状態
撮影後、README の HTML コメントを外して画像を差し込む (docs-only PR)。

### B-3. gamma / font golden (2026-07-03b 持越し) — **worker1 実施済 2026-07-07 15:40、結果:**
- ✅ **#315 font golden work-PC 検証 PASS**: GUI_kit main f009af6 (worktree content 同一確認済) で golden 全 6 target (widgets/smoke/gradient/a11y_chrome/a11y_focus_scale/systemlike_chrome) = **27 passed / 0 failed**。work-PC canonical baseline (0 fail) 維持、bless 不要・bless 実施せず。
- ✅ **gamma ON smoke PASS (testruct)**: `HAYATE_LINEAR_BLEND=1` で testruct main 相当 bin (track1 = 094bb1c 同等 + GUI_kit f009af6) を 10 秒起動 → Vulkan renderer 初期化正常・panic/error 0・timeout kill まで安定稼働。log = scratchpad/gamma_on_testruct.log。
- ⬜ **残 (user 目視枠)**: gamma ON の**視覚品質判定** (AA エッジ/半透明の改善 or 破綻) は smoke では判定不能 — D-1 の default ON 化判断は user 目視 (gamma_test.testruct の α ランプパターン推奨) + notepad 等他アプリへの水平 dogfood が引き続き必要。§B-1 の live-verify batch と同枠で実施可。

### B-4. K-track (worker2) live-verify 3 項 (一次ソース = testruct `docs/REMAINING-TASKS.md` §3b、main 耐久化済)
1. **影 blur の実機較正** — `SHADOW_BLUR_TO_SIGMA = 0.5` (σ = blur/2 初期値) を Mac の CG setShadow と見比べて較正 → 確定値を定数 + doc comment に固定 (K9 裁定 #4)。影付き shape 入り .testruct で目視
2. **VK 実機 visual** — gradient (K4) / 半透明 overlap 合成 (K8) / blurred shadow + 半透明 text (K9) の 3 点を GPU で目視 (CI に GPU なし、CPU golden は全取得済: goldens/gradient/ + goldens/layer/ の 3 showcase)
3. **linear blend との相互作用** — `HAYATE_LINEAR_BLEND=1` では影 blur が skip され offset-only になる (blur render pass の UNORM 固定 = 既存全画面 blur と同制約)。**B-3 の gamma default ON 化判断に必ずこの制約を織り込むこと** (ON にすると影の blur が消える)

## §C. トラック別 残 backlog + 再開 trigger

### C-1. multiline text edit (worker1 track、実装完遂 — follow-up のみ)
| 項目 | 内容 | 再開 trigger |
|---|---|---|
| K-f | kit TextArea `with_text_color`/`with_font_weight`/`with_alignment` (ResolvedTextStyle plumbing 込) | kit 還元 land 時に testruct 側で B-5 (編集中テーマ色) / B-8 (揃え) 解消を再評価 (REMAINING-TASKS.md 起票済) |
| K-g | Justified (両端揃え) — kit 全体に不在、HAlign 3 値のまま | DTP north star の別 RFC 級。実文書で justify 編集需要が surface した時 |
| K-h | wrap 視覚行単位 caret ↑↓ + goal column (engine.rs 自身が TODO 明記) | B-9 の user 体感 complaint、または notepad/code_editor 側で同 gap surface 時 |
| K-i | TextArea ImeDeleteSurrounding (TextInput パリティ) | live-verify で IME 挙動差が観察された時 (B-10) |
| rich run/ruby 編集 | modal で B/I/U/波線/ルビ編集 (Mac §1.8 parity)。TextEditCommand v2 (runs/ruby 書き戻し) 要 | user 需要 or Mac 産 doc の runs 編集 workflow が Linux で必要になった時 |
| RFC 参照 | 設計判断の全 trail = testruct `docs/rfc/RFC-multiline-text-edit.md` (10 §、main 耐久化済) | — |

### C-2. K4→K8→K9 描画 fidelity (worker2 track) — **全 3 点完遂 (2026-07-07)**
- ✅ K4 primitive (#324) → K4b closure + K8 SaveLayer (#326 `4bbe1aa` + 配線 #94 `57c1953`) → **K9 land (#327 `d826caa` + 配線 #95 `9b37287`)**: text alpha 貫通 + 影 Gaussian blur + opacity layer 化全 node 種。REMAINING-TASKS §2 の描画 fidelity gap (グラデ/半透明/影 blur) は**全て解消**、残 = live-verify 3 項 (→ 本 doc §B-4 + `docs/live-verify-batch-2026-07-07.md`)。
- **設計判断ノート (後続 dispatch の再利用素材、各 RFC = GUI_kit docs/k{4,8,9}-*-rfc.md に裁定記録込みで耐久化済)**:
  - **K4b→K8 計画的合流**: polygon gradient は独立 primitive を作らず SaveLayer + `LayerMask::Polygon` + 矩形 gradient で吸収 (PRESIDENT 指示の再評価 trigger どおり)。「大きい機能の副産物として小さい gap を解く」構図の成功例
  - **canvas 同寸 scratch/offscreen** (K8): bounds 寸だと全 choke point に座標/clip/stride 再写像が要り off-by bug の温床 → canvas 同寸 + bounds 領域限定の zeroing/合成で「redirect のみ・描画 body 完全不変」。CPU/VK 対称の同一判断。bounds 寸最適化は nest 深化時の同 API 内 follow-up
  - **CPU choke point は 13 箇所** (CpuBackend::new 7 + fill_rect inline 1 + blit 2 + text pixels_mut 3)、`with_cpu_target` 1 関数に集約。網羅根拠 = Renderer::Cpu 全 mention の機械列挙 (GUI_kit dea6e06 の commit message に記録)
  - **premultiplied 蓄積の証明**: blend_at は透明 dst で premultiplied 蓄積になる (layer.rs module doc) — GPU 側も SRC_ALPHA blend + transparent clear で同型、composite は ×k の premultiplied-over 1 発
  - **vk_blur pooled record** (K9 retrofit): host-visible UBO は execution 時読取 → record 内/間の共有 UBO・set は最終書込みが勝つ。per-record 資源 pool が正形
- **既知 gap (再開 trigger 付き)**: VK pass 分割 scan の pure unit test (glyph cache 参照で抽出コスト高 — trigger = flush 再構成を再度触る時) / PDF・SVG backend の gradient・影 blur (fold/offset-only 継続 — trigger = export fidelity の user 需要)。

### C-3. P0 release (worker3 track)
P0-2 の Linux 完結分 (a/e 縮退) は本日全 land (§A #10/#11)。残りは全て **user@Mac 枠** (testruct-v3 変更、設計 doc `docs/design/p0-2-format-compat-ci.md` §6 が正):
- **P0-2b** (Mac): TestructDocument に `format_version` + `DocumentElement.unknown(JSONValue)` + `Fill.unknown` (JSONValue enum ~100 行の新設込み)。§3.2 仕様凍結表を WINDOWS_PARITY_TODO と同流儀で Mac 側 doc に起票してから
- **P0-2c** (Win): 同上の C# 追従 (CP-x 起票、`JsonElement` clone で raw 保持が最安)
- **P0-2d** (Mac repo 承認): Swift core Linux ビルド再適用 = canImport ガード (os.log 1 箇所 + CoreGraphics 3 file、適用時に再 grep) + CZlib system-library + Package.swift resources。handoff-2026-07-04 §B が一次ソース (stale branch は参照不能)
- 台帳: `FORMAT_VERSIONS.md` を testruct-v3 側に新設 (version bump 記録、設計 doc §7.3)

**cross-impl harness の縮退解除条件** (scripts/cross-impl-roundtrip.sh 冒頭コメントにも doc 化済):
- Swift segment: ①P0-2d land ②swift toolchain (work-PC 不在 / home-PC は swiftly 導入済) ③TestructCore 側 harness (emit/recode/dump 同仕様) land
- C# segment: ①dotnet 8 SDK (work-PC 不在) ②TestructWin.Tools に harness verb (TestructWin.Core は素の net8.0 で Linux 実行可 = 3 実装 1 台マトリクスが成立、設計 doc §5.1)

### C-4. その他持越し
- **zoom doc 完結** (boss1 言及分) ⏳boss1 追記。
- 2026-07-03b §D-2: gamma follow-up (vk_blur render_format 揃え / Color::lerp linear 化 / color font RGB 経路) — default ON 化の前提作業。
- 2026-07-04 LP series / 2026-07-05 分は各 handoff doc 参照 (本 doc に重複させない)。

## §D. 次 session 着手順 (worker1 提案、boss1/PRESIDENT が確定)

1. **user live-verify batch (§B 全部)** — user 在席が必要な項目を最初にまとめて消化 (multiline 5 項 + AppImage + gamma dogfood)。ここで出た fix が最優先 dispatch になる。
2. **K-f kit 還元** — 小粒 (TextInput の同名 API 移植 + plumbing)、B-5/B-8 解消で multiline UX が Mac 比フル fidelity に。#323 と同型の 1 PR で完結見込み。
3. **K8/K9 継続** (worker2 track の続き) — K4 で primitive 追加の型が確立済、同パターン。
4. **P0-2b-d** — user@Mac 枠が取れた session で。
5. **rich run/ruby RFC** — multiline modal が安定 (live-verify PASS + 数日 dogfood) してから。

## §E. プロセス記録 (本 session、worker1 分)

- **RFC→裁定→kit 先行→app の 4 段 chain が 1 日で完走** (Phase A 2h 納期 → PRESIDENT 裁定 → #323 → #88)。kit gap を RFC 段階で K-a〜K-j に列挙し「v1 必須 = 2 件だけ」と切ったのが本日 land の決め手。
- Mac 正典 grounding で **in-place 方式は Mac 自身が棄却済み** という正典コメントを発見 → surface 方式裁定の決定打 (追随せず一次ソースを読む価値の実例)。
- codex 査読 3 連続 (LGTM ×3、High/Med finding 0) — RFC 由来の契約 (focus-contract / burst / F2 / 排他 gate) を PR description に明示したことで査読が契約照合として機能。
- agent-send にコード断片を含めない (backtick がシェル評価される、既知規範の再確認 1 件)。

---
**End (worker1 起草 + worker2 追記済 17:05 = §A 7b/7c + HEAD 更新 + §B-4 + §C-2 完遂化)。残 ⏳ = boss1 追記分。commit は boss1 が session 末に。**
