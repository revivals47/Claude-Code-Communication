# Handoff 2026-07-01 — home-PC: GUI_kit arch-debt land + UI フォント統一 + メニュー修正 + testruct ネイティブファイル選択 + 初期表示 100%

home-PC session (2026-06-30〜07-01)。work-PC の GUI_kit 大規模改修を main へ land し、その上で UI フォント統一・メニュー折返し修正・testruct のネイティブファイル選択・初期表示 100% を実装。全て land 済み。
**work-PC で唯一の actionable = §D-1 の #313 フォント golden を work-PC canonical で検証 / 必要なら再 bless**（home-PC で bless したため）。

---

## §A. 本 session でやったこと

### 1. GUI_kit arch-debt 改修 (arch-debt/r0-perf-baseline、41 commits) を main へ land — ✅
- work-PC で作った R0-R5/S4/S6 perf+render 改修 (Vulkan partial damage / record→replay / layout cache / dirty-contract 等) を **fast-forward** で main へ (main は直系祖先、線形保存)。main `a59a6ef`(#305) → `05522e3`、branch 削除。
- land 前検証: platform lib **986/0**(debug)。kit lib は label premise 2 件 fail が出たが **main でも同じく fail = home-PC フォント env-drift の pre-existing**(`real==estimate` 43.2)、改修起因でないことを実証。release で should_panic(debug_assert) 1 件は artifact。→ 改修起因の新規 fail ゼロ。

### 2. 別 session の theme/layout 作業を pull — ✅ (情報)
- testruct #71(panel surface theme) / #72(P3b inspector spacing + Mac 実測 + 固定幅 inspector)、GUI_kit #309-312(SplitView divider/fixed-pane + SurfaceTheme + Divider/Section/Panel primitives)。全て他 session で land 済、本 session は pull して build 緑確認しただけ。

### 3. GUI_kit #313 — UI フォントを SansSerif に統一 — ✅ (main b7360b5)
- 原因: `Renderer::draw_text`(family 引数なし、kit widget の大半が使用) の既定が **Monospace** で、タイトルバー/ツールバー/ボタン/ラベル等が JetBrains Mono だった (menu_bar だけ明示 SansSerif)。user「メニューバーのフォントに統一して」。
- 修正: `draw_text` 既定を **SansSerif** に反転 + 明示 Monospace の UI サイト(label/button/title_bar/toolbar/spin_button/color_picker)を SansSerif に。**意図的等幅は維持**(terminal_widget=明示 Monospace 固定、rich_paragraph の `code` run)。
- ⚠ **golden 12 件を home-PC で再 bless**(titlebar×5 / win10 button・label・spin・vstack / win95 spin / xp_luna checkbox・radio)。→ §D-1。
- 副次効果: home-PC の label premise 2 fail が SansSerif 化で green に。

### 4. GUI_kit #314 — メニュードロップダウン末尾文字の折返し修正 — ✅ (main 8b5b5e3)
- 症状: ファイルメニューで「PNG にエクスポート」の「ト」が改行。原因 = ①幅を `bitmap_font::measure_label_width` で測る一方 cosmic 描画は SansSerif(#313 後) = measure/draw フォント不一致で和文過小評価、②内側 draw rect が枠 4px + `max_w` の pad 控除で `max_w` がラベル幅をわずかに下回る (#313 の厳密フィットで露呈)。
- 修正: `measure_label`(描画と同じフォントで測る) + 枠 inset 余白(INNER_SLACK=6px)。

### 5. testruct #73 — ネイティブファイル選択 (portal + 自作フォールバック) — ✅ (main 7c5d66c)
- 自作 modal `FileDialog` ホストを撤去し GUI_kit `PlatformServices` 経由に。xdg-desktop-portal があればネイティブ GTK chooser、無ければ App-driven な in-process ダイアログに自動フォールバック (`detect_services`)。
- Cargo に `portal` feature(ashpd/zbus)、`main.rs` で `detect_services(app.service_context())`→canvas 注入、`file_io_wire.rs` は非同期コールバック→`file_results` キュー→`update` drain で読込/保存/書出。canvas 自作モーダルの host/paint/event-gate は撤去 (fallback は App modal slot、portal は別サーフェス)。

### 6. testruct #74 — 初期表示 100% 実寸・上揃え (原本準拠) — ✅ (main 593f762)
- 起動/open 直後を fit-whole(〜80%、見にくい) → 100% 実寸に。`pending_initial_view` フラグで初回 paint(fit 判明時)に `user_scale=1/fit`(→zoom=1.0)+左上寄せ。ツールバー zoom 表示も **絶対倍率**(mapper.zoom)に変更 → open 直後 100% 表示。fit-whole は Ctrl+0 に残置。

### 7. フォント事実の訂正 (重要)
- 当初 user に「アプリのフォント = Inter Variable」と回答したが**誤り**。testruct は `main.rs` で `with_font_data(font::BUNDLED_SANS) + with_sans_serif_family("Noto Sans JP")` し **同梱 Noto Sans JP** で SansSerif を上書きする。Inter Variable は GUI_kit 既定で、testruct は不使用。原因 = `with_sans_serif_family` を `sans_family` grep で取りこぼし。memory 訂正済 (§C)。

---

## §B. git state (全て origin push 済・clean)

- **GUI_kit** (revivals47/GUI_kit): main = `8b5b5e3`(#314)。#313/#314 land、arch-debt branch 削除済。
- **hayate-kit-testruct** (revivals47/hayate-kit-testruct): main = `593f762`(#74)。#73/#74 land。
- **Claude-Code-Communication** (comm): 本 handoff を commit + push。`.claude/settings.local.json` の M と `section/`(untracked) は本 session 無関係、commit しない。

---

## §C. memory mirror (work-PC `~/.claude/projects/-home-ken-Documents-Claude-Code-Communication/memory/`)

memory は PC ローカル。work-PC で以下を反映 (home-PC 本文をコピーが確実):
- **新規** `reference_guikit_font_resolution.md` — GUI_kit はフォント非バンドル・OS 解決 (既定 sans=Inter Variable / mono=JetBrains Mono / CJK=Noto)。**testruct は同梱 Noto Sans JP で上書き**。#313 で draw_text 既定 SansSerif 統一、terminal/code run のみ等幅。
- **更新** `project_testruct_mac_convergence.md` — #68(プロット/ページ操作)・#73(ネイティブ picker)・#74(初期 100%)・#313(フォント統一)・#314(メニュー修正)・フォント訂正を追記。残タスクに zoom 絶対モデル化を追加。
- **更新** `MEMORY.md` — reference_guikit_font_resolution の index 行追加。

---

## §D. 次 PC (work-PC) reentry checklist / open items

### D-1. ★最優先: #313 フォント golden を work-PC canonical で検証 (work-PC でのみ可)
#313 のフォント変更で text を含む golden 12 件を **home-PC で bless** した。golden 正本は **work-PC** (`feedback_golden_env_drift`, #235)。work-PC でフォント描画がドリフトすると mismatch する。手順:
```
cd ~/Documents/GUI_kit && git fetch origin && git checkout main && git pull --ff-only
cargo test -j1 -p hayate-kit --test golden_widgets -- --test-threads=1
cargo test -j1 -p hayate-kit --test golden_systemlike_chrome -- --test-threads=1
# 緑ならそのまま (home-PC bless が work-PC でも一致 = ドリフトなし)。
# fail (pixel mismatch) なら work-PC で再 bless:
#   GOLDEN_BLESS=1 cargo test -j1 -p hayate-kit --test golden_widgets -- --test-threads=1
#   GOLDEN_BLESS=1 cargo test -j1 -p hayate-kit --test golden_systemlike_chrome -- --test-threads=1
#   git add crates/hayate-kit/tests/goldens && git commit -m "test(golden): re-bless #313 font goldens on work-PC (canonical)" && push
```
対象 golden: titlebar_default/macos9/macos_big_sur/win95/win95_inactive、win10 button_default/label_default/spin_button_default/vstack_default、win95 spin_button_default、xp_luna checkbox/radio。

### D-2. 開始前の同期確認
両 repo を pull → testruct を `cargo build --release -j1` で drift 確認 (GUI_kit が他 session でも動くため)。

### D-3. open items / 次の大物 (testruct convergence、user 選択待ち)
docs/REMAINING-TASKS.md が source of truth。残る大物 (いずれもスコープ大):
- **解答用紙ビルダー対話 UI** — コア生成は完成、GUI 編集画面が未実装。実用インパクト最大。
- **フォント複数化** (FontPicker + 複数 bundle)。現状は同梱 Noto Sans JP 単一。
- **描画 fidelity** — グラデ(K4)/半透明(K8/K9)/shadow blur (テスト用紙では低価値・見送り推奨)。
- **zoom 絶対モデル化** — 今は fit 相対(user_scale)で初回のみ 100% 適用。原本は絶対 zoom (Cmd+0=100% / Cmd+9=fit)。Ctrl+0=100% + 別 fit コマンドに揃えると完全一致。

### D-4. 継続的な他 session 並行
別 session が testruct theme/layout (track-light-theme 等) + GUI_kit P4 surface primitives を進めている。pull 時に新 PR を確認し overlap 注意。

---

## §F. 教訓 (本 session)
1. **override の grep 漏れに注意** — `with_sans_serif_family` を `sans_family` パターンで取りこぼし、フォントを誤回答。`with_*`/builder 経由の override は `with_` 接頭辞でも grep する。事実回答前にコード確認。
2. **measure-with-the-font-you-draw-with** — メニュー幅を bitmap_font で測りつつ cosmic で描いて折返し。レイアウト幅は実描画と同じフォントで測る。`feedback_verify_reused_mechanism_behavior` の幅版。
3. **golden env-drift は bit 比較で切り分け** — kit lib の label premise 2 fail を「main でも同じ fail」で改修起因否定 (pre-existing 確定)。land 前ゲートは現 main と比較。
4. **fit 相対 zoom と絶対 zoom は別物** — 初期表示要望は「絶対 100%」だが testruct は fit 相対モデル。フラグで初回のみ絶対適用 + 表示を mapper.zoom(絶対) に。完全な原本一致は絶対モデル化が要る (D-3)。
5. **GUI アプリ detached 起動の exit 144** — `setsid … & disown` + 同一コマンド内 `sleep; pgrep`、`dangerouslyDisableSandbox: true`。1 回 144 で死んでも再試行で生存することが多い。
