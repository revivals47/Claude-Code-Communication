# Handoff 2026-07-03 — home-PC: GTK4版比較で testruct fidelity 3層改善 (UI文字/数式serif/SDF大文字くっきり) 全 land+push

GTK4版 testruct (別実装) を並べて実機比較し、text fidelity の差を 3 層に切り分け → 全て land + push。特に SDF 修正は GUI_kit (L1) ゆえ全 Hayate アプリに波及。

## §A. 本 session でやったこと

### 0. pull + cargo test -j1 緑確認 — ✅
- GUI_kit `8b5b5e3`→`5a08e7a` (#315-#321、Lucide vector icon/#319、resizable pane/#320-321、text_input align/#316-317)。testruct `593f762`→`c4e41cc` (#75-#84、font 複数化/text_edit/resizable sidebar)。
- lib 緑: hayate-kit 1189 / hayate-platform 992 / testruct-core 212 / testruct-ui 115。
- golden 4件 FAIL = work-PC bless #313 font golden の cross-PC フォント差 (titlebar delta2-4=vector, spin_button delta92-132=text glyph)。**コード回帰でない** ([reference_wayland… 参照は別件]、既知の env-drift)。

### 1. GTK4版 testruct との実機比較調査 — ✅
- `testruct_Desktop_V2` (GitHub private、Rust+gtk4 0.9、~22k行) を clone→ビルド→起動 (WhiteSur スキン下)。gtk 版は SIGSEGV 実績 (`gtk_gesture_is_active` assert、破棄済 gesture access)。
- Explore agent ×2 で両実装の実解決フォントを code-grounded 特定 + codex 3回相談。3層に切り分け:
  - 層1 小UI文字 hinting、層2 フォント選択 (数式/CJK)、層3 SDF ラスタライズ品質。

### 2. testruct #1 — UI文字サイズ +1px — ✅ (main `4ea5abf`)
- GTK は全UIラベル 11pt(≈14.7px) 均一、Hayate は 11-14px でバラつき・小さめ (右inspector最も)。inspector/presets/layers/pages のラベルを一律+1px (ヒエラルキー維持)。

### 3. testruct #2 — 数式 serif+変数italic — ✅ (main `4ea5abf`)
- 旧: 数式=直立サンス (FontFamily::SansSerif)。GTK=serif+変数italic (数学組版慣習)。
- **Noto Serif (Latin、実 Italic 面あり) を同梱** (`FAMILY_MATH`)。同梱 CJK serif は Italic 面無く cosmic-text/swash は oblique 非合成ゆえ実 face 必須 (verify-the-mechanism で no-op 回避)。
- math_render がトークンを文字クラス分割: ASCII letter=italic-serif / digit・operator=roman-serif。screen (draw_text_with_axes) + PDF (shape_math_run) 両対応。

### 4. GUI_kit #3 — SDF 大文字くっきり化 — ✅★ (main `dcdd0ab`、L1)
- 真因: text は font_size で分岐。≥32px=SDF経路が canonical_size=clamp(48,96) でラスタライズ→表示時 scale倍で拡大 (LINEAR sampler)。**SDF band 内 (scale=1) でも距離場 threshold 復号が bitmap coverage AA より本質的に甘い** (codex確認)。<32px=bitmap は実サイズでくっきり。GTK/Cairo は毎回実サイズ再ラスタライズ。
- instrument_runtime で確定: 305% zoom 時 数式 fs=92.8 = SDF band 内 → 全 bitmap 強制テスト → user「めっちゃくっきり。これよ」→ GTK 遜色なし。
- 修正: `use_bitmap_path(fs)=fs<=BITMAP_MAX_SIZE(256)`。256px 以下=全て実サイズ bitmap、256超=SDF フォールバック (extreme zoom で drop 回避)。旧 BITMAP_TEXT_THRESHOLD(32) 撤廃。
- codex review: HIGH= bitmap atlas は 2048 止まり (4096 は SDF 側の誤認)→上限 512→**256 に下げ修正**。Medium 2 (>256px rich SDF exact-size drop / 256境界メトリクス差) は DTP 範囲外 follow-up。
- ★L1 修正 = draw_text/draw_text_family/draw_rich 共有経路ゆえ **全 Hayate アプリが GUI_kit 再ビルドで自動くっきり化** (platform_principle の配当)。

## §B. git state (全て origin push 済・clean)
- GUI_kit main = `dcdd0ab` (fix(text): exact-size bitmap ≤256px)。worktree GUI_kit-sdf + branch 掃除済。
- hayate-kit-testruct main = `4ea5abf` (feat(ui+math): larger panel text + serif-italic math)。branch 掃除済。
- 両 repo とも `## main...origin/main` 同期。golden は CPU 経路ゆえ Vulkan SDF 変更に非影響 (cpu_golden_cannot_verify_vulkan)。

## §C. memory mirror (work-PC `~/.claude/projects/-home-ken-Documents-Claude-Code-Communication/memory/`)
新規/更新した memory:
- `feedback_hayate_vs_gtk_live_compare.md` (★本 session の中核。3層切り分け+codex補正+landing SHA)
- `reference_guikit_sdf_large_text_blur.md` (SDF真因+RESOLVED dcdd0ab)
- `reference_wayland_stuck_grab_vt_switch.md` (アプリ終了後の grab 残留=VT切替で解消、非決定的)
- work-PC で本 session 反映には memory dir を pull/mirror。

## §D. 次 PC / 次 session reentry checklist / open items
### D-1. cross-PC でも #3 の恩恵確認 (dogfood)
- notepad/imageview/sysmon 等を GUI_kit 最新 (`dcdd0ab`) で再ビルド → 大きい文字くっきり化を目視。
### D-2. codex Medium follow-up (優先低、>256px 稀域)
- draw_rich の SDF fallback を exact-size→canonical に統一 (>256px rich の atlas drop 回避)。
- 256px 境界の metrics-parity テスト追加 (bitmap exact ↔ SDF canonical の shape size 切替)。
### D-3. gamma 非対応 (別軸、残る質の差)
- GPU パスは B8G8R8A8_UNORM (非sRGB) で線形補正なしブレンド。エッジの太り。codex 優先度3。大文字は #3 で解決済ゆえ優先低。
### D-4. #315 font golden の work-PC canonical 検証 (前 handoff からの持越し、work-PC でのみ可)
- home-PC で 4件 mismatch (titlebar/spin_button) 観測 = cross-PC env-drift。work-PC で緑なら OK、fail なら re-bless。
### D-5. testruct 本来の残タスク (mac convergence)
- 解答用紙ビルダー対話UI / グラデ半透明 fidelity 等 (project_testruct_mac_convergence)。

## §E. プロセス教訓 (memory 化済)
- instrument_runtime_when_fixes_miss: 「fs=92.8=SDF」を計装で暴き、96閾値の空振り検出。
- consult_codex + verify-the-mechanism: italic は実 face 必須 (合成しない) を事前確認、no-op 回避。codex が atlas 2048 上限を catch。
- platform_principle: fidelity 修正を app でなく L1 に入れ全アプリ波及。
