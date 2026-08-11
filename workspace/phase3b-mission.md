# Phase 3b ミッション: GUI_kit 全テーマ忠実度実装（OS スキン再現）

PRESIDENT → boss1。本ファイルが boss1 への一次指示書。worker への分解は boss1 が行う。

## 背景・現状
- hayate-kit-settings のテーマ切替「機構」は完成済（PR #19、`set_bundle` で base palette + per-widget AppTheme + 背景が一緒に変わる、実機確認済）。
- 次フェーズ = 各 OS スキンの「実物らしさ（トーン）」の作り込み。
- **user 評価**: 「win95 以外はゴミ品質。win95 ですら詰める余地が多数」。
- ゴール = user が「実物っぽい」と認める品質。これは視覚判定なので最終評価者は user（後述）。

## 対象テーマ（5 OS クローン）
1. Windows 95 — refine（最もマシ、98.css とほぼ一致だが詰める）
2. Windows XP Luna — rebuild
3. Windows 10 (Fluent) — rebuild
4. macOS Big Sur — rebuild
5. Mac OS 9 (Platinum) — rebuild

（HAYATE Original は OS クローンでなく独自 identity 案件。本ミッションのスコープ外、別途。）

## 定義ファイル（GUI_kit = /home/ken/Documents/GUI_kit）
- base palette: `crates/hayate-kit/src/style/theme.rs`（`WIN95_THEME` 等 6 定数 = `Theme` struct）
- sub-theme builders: `crates/hayate-kit/src/style/widget_theme_presets/` 配下 16 widget ファイル（button.rs / input.rs / check.rs / radio.rs / switch.rs / slider.rs / dropdown.rs / tab.rs / progress.rs / spin.rs / menu.rs / tooltip.rs / group_box.rs / scroll_bar.rs / titlebar.rs）。各ファイルに skin 別 builder（例: `button_theme_win95()` / `button_theme_xp_luna()` …）
- 組立: `widget_theme_presets/app.rs` の `app_theme_win95()` 等（sub-theme を AppTheme にまとめる）
- titlebar: `widget_theme_presets/titlebar.rs`（`titlebar_theme_win95()` 等、**全 6 skin 分そろっている**）
- consumer: hayate-kit-settings = /home/ken/Documents/hayate-kit-settings（テーマ切替 UI。platform 直 dep 禁止、hayate-kit 経由）

## 最優先制約（順守必須・違反は差し戻し）
1. **記憶ベース実装は厳禁**。各 OS の実物スクショ + 既存実装を必ず web 調査してから着手。出典 URL を doc に残す。
   - Windows 95/98: 98.css (jdan/98.css)、Chicago95
   - Windows XP: xp.css、実物 Luna スクショ
   - Windows 10: Fluent Design、WinUI
   - macOS Big Sur / Mac OS 9: Apple HIG、Aqua、Platinum 資料
   - 過去 Win95 Solitaire が「実物っぽくもない創造」で user に却下された前例あり。調査なしの実装は即却下。
2. **cargo は -j1 厳守、並行起動禁止**（home-PC で GNOME/dock 応答悪化の実績）。build/test の起動は boss1 が直列制御。実装作業（編集）は並行可、cargo verify は順次（option C）。
3. **視覚確認は AI 不可**。worker も PRESIDENT も GUI を見られない。見た目の最終判定は user。実装は research 根拠で行い、build 後に PRESIDENT 経由で user が実機確認 → 反復。worker は GUI interactive verify を成果条件にしない。
4. **agent-send メッセージにバッククォート・ドル記号を入れない**（command substitution で消える/化ける）。長文・コード参照は workspace doc に書いて「読め」で渡す。
5. **共有 worktree 衝突回避**: テーマ work は同じ widget ファイル群を触るので、(a) widget ファイル単位で worker 分担して同一ファイル同時編集を避ける、または (b) worker 専用 worktree。3 worker 並走 + commit 想定なら専用 worktree を早めに検討。pathspec 指定 commit + workerN/ prefix。
6. platform 提供原則・1ファイル500行目安（cohesion 優先）・抜本解決/負債先送り禁止を順守。

## 役割分担
- **PRESIDENT（私）が直接担当**: 横断課題 = skin 連動タイトルバー（下記ギャップ）の settings + framework 対応、codex 査読、cargo 直列の最終調停、user への視覚確認依頼の中継。
- **boss1 + workers**: 各テーマの実物調査 + palette/sub-theme 改訂案 + 実装。

## 第1波（実装前の「調査 + ギャップ + 改訂提案」フェーズ）
各 worker に 1〜2 テーマの調査 doc を `workspace/phase3b/<theme>-research.md` として作らせる（**まだ実装しない**。cargo 不要、完全並行可）。

推奨割り当て:
- worker1: Windows XP Luna + Windows 10
- worker2: macOS Big Sur + Mac OS 9
- worker3: Windows 95 深掘り refine（下記 PRESIDENT 調査済データを基点）

各 doc 必須項目:
- 実物の色実値（hex 一覧: window/surface, button face/highlight/shadow, title bar active/inactive, text, selection, accent）
- font（名称・サイズ・太さ）
- 角丸 radius / border / bevel 構成（raised/sunken の各層の色とオフセット）
- title bar の見た目（色・グラデ・ボタン形状）
- 既存実装の出典 URL
- 現 GUI_kit 定義（theme.rs の該当定数 + 主要 sub-theme builder）との差分一覧
- 改訂案（palette 定数の新値 + 主要 sub-theme の新値 + titlebar）

完成ごとに PRESIDENT に1行で報告（doc パス + 要点）。

## PRESIDENT 調査済データ（Windows 95、98.css 照合済 = worker3 の基点）
- palette 実値: surface #c0c0c0 / button-face #dfdfdf / button-highlight #ffffff / button-shadow #808080 / window-frame #0a0a0a / dialog-blue(title active) #000080 / dialog-gray(inactive) #808080 / text #000000(98.cssは#222) / link #0000ff
- raised button bevel(4層 inset): 外TL #ffffff, 外BR #0a0a0a, 内TL #dfdfdf, 内BR #808080
- pressed button: 上記反転
- sunken input bevel: 外TL #808080, 外BR #ffffff, 内TL #0a0a0a, 内BR #dfdfdf
- font: MS Sans Serif 11px（UI）/ 12px（本文）
- 現 GUI_kit 評価: WIN95_THEME palette と button_theme_win95 のベベルは 98.css とほぼ一致（button 外BR が #000 vs #0a0a0a の微差のみ）。**つまり Win95 のパレット/ベベルは既に高忠実**。
- **最大ギャップ（全テーマ横断）**: settings が `titlebar_theme_hayate_original()` 固定で、各 skin の title bar（Win95 の象徴 = 紺バー+白文字）が一度も表示されていない。GUI_kit に `titlebar_theme_win95` 等 全 skin 分あり、`TitleBar::set_theme` も存在 → **PRESIDENT が settings + framework で skin 連動 titlebar を実装する**（worker は触らなくてよい）。
- font 制約: GUI_kit に MS Sans Serif ビットマップは無く、現状 `LEGACY_JP_16_PROP`（16px 日本語）使用。MS Sans Serif 系アセットの要否は worker3 が調査 doc で論点化（新規アセットは重いので別判断）。

## 進め方（全体）
1. 第1波 = 各 worker の調査 doc（並行、cargo 不要）→ PRESIDENT 報告。
2. PRESIDENT が codex で各調査/改訂案を査読 + user に方針確認。
3. 第2波以降 = 承認された改訂を **1 テーマずつ**実装（widget ファイル単位で worker 分担、cargo -j1 直列 verify）→ build → user 視覚確認 → 反復。1 テーマ「実物っぽい」確定で次へ。

## 報告
- 各 worker の調査 doc 完成ごとに PRESIDENT へ報告（agent-send president、1行、バッククォート禁止）。
- ブロッカー・cargo 競合は即 PRESIDENT 相談。
- まず 10 分以内に worker への割り当て + 第1波着手。

---

# 第2波（実装準備フェーズ・worker は cargo-free、PRESIDENT がタイトルバー機構を cargo 付きで並行実装）

第1波 調査 5 本完了（win95-refine / winxp-luna / win10 / macos-bigsur / macos9）。横断パターン確定: **色はどのテーマもほぼ正しい。真のギャップは (a) タイトルバー/chrome と (b) 描画プリミティブ（多stopグラデ/vibrancy/soft shadow/破線/角丸/縞）と (c) 個別の構造バグ（Mac OS 9 button が System7 で別物）**。

## cargo 直列ルール（厳守）
PRESIDENT がタイトルバー機構を GUI_kit で cargo -j1 実装中。**この間 worker は cargo を一切起動しない**（j1 + CPU 飽和回避）。worker は調査/grep/ドラフト doc のみ。PRESIDENT が「titlebar cargo 完了」を通知したら、boss1 が worker の実装(cargo)を順次 1 人ずつ解禁。

## worker 第2波タスク（全て cargo-free のドラフト/調査）
- **worker2 = Mac OS 9 Platinum button 修正案ドラフト**（最優先 per-theme）: 現 `button_theme_mac_classic`（System7風）を Platinum 3D ベベルに置換する正確な builder 案を `workspace/phase3b/macos9-button-fix-draft.md` に。win95 の bevel 機構（ButtonTheme::bevel 4層）を流用し、Platinum グレー実値（platinum.css + Inside Macintosh 出典）で。raised/pressed 各層の色を明記。cargo はまだ。
- **worker3 = Win95 フォント案Bの実現性調査**: `hayate_platform::render::bitmap_font` を grep し、11-12px 級の既存ビットマップフォント定数が存在するか確認（cargo 不要、grep のみ）。結果と、案B採用時の win95 builder 群の font 差替 + TITLE/MENU 高さ native 化の具体案を `workspace/phase3b/win95-font-draft.md` に。フォント字形の最終可否は user 視覚確認事項として明記。
- **worker1 = 色微修正バッチ案ドラフト**: 低リスク色補正の正確な対象（file:line + 新旧値）を `workspace/phase3b/color-tweaks-draft.md` に。対象候補: tooltip win95 #FFFFE1→#FFFFC0 / Big Sur warning →#FF9500 / Big Sur button radius 8→6 / Win10 bg_primary F3F3F3→F0F0F0 / XP selection →#316AC5。**button.rs は worker2 が触る可能性があるので worker1 は button.rs を避け、theme.rs と tooltip.rs 等に限定**（ファイル競合回避）。cargo はまだ。

## user 判断待ち（PRESIDENT が後で確認）
- Win95 フォント方針（案A/B/C、第一候補B）
- Win10 button rest 背景: 白(UWP) か 淡灰#E1E1E1(native dialog) か
- Big Sur vibrancy/blur の投資是非（GPU プリミティブ大工事）
- Win95/各タイトルバー グラデ可否（Win95 はソリッド紺が忠実）

## PRESIDENT 並行作業（titlebar 機構、codex 査読反映）
1. ChromeAdapter に titlebar theme 差替 capability 追加（Custom は明示的に capability doc or bool）
2. ThemeBundle に titlebar_theme: Option 追加、apply_theme_bundle で反映 + needs_layout
3. startup も build_systemlike 経由に一本化（with_titlebar_theme 段階廃止、codex High 指摘）
4. forward 漏れ回帰テスト 4 本（SystemLike 高さ変動 / dirty repaint / Custom no-op / startup==runtime）
5. settings: titlebar_theme_for(id) + theme_bundle_for 同梱 + startup

---

# 第3波（behavioral state 研究 + golden 検証設計・cargo-free）

user 確定方針: 「ぱっと見」の静止 rest は改善したが、各OSの本質は**挙動（press/hover/focus/disabled の state 仕様 + 空気感）**。user は「ボタンの挙動を見ないと Win 系を評価できない」。よって次は behavioral fidelity = state 層に踏み込む。

評価サーフェス: PRESIDENT が hayate-linux-gallery を各テーマで起動（user が実際に widget を押下/hover/focus して評価）。PRESIDENT は次に gallery のランタイムテーマ切替化も検討（set_bundle 流用）。

## worker 第3波（研究のみ、実装は user 評価後。cargo-free・出典必須・記憶ベース禁止）
各 worker は担当OSの **widget state 挙動の「仕様」** を references から調査し `workspace/phase3b/<os>-behavior-research.md` に。

- worker1 = Windows 95 + XP Luna の state 仕様: button(rest/hover/press/focus/disabled)、Win95 は press でベベル反転(sunken)+text 1px沈み+hover無し+破線(dotted)focus rect+既定ボタン外周黒枠、XP は hover 発光+press 暗化+focus。出典 98.css/xp.css の :active/:focus/:disabled、実OS。現 GUI_kit の ButtonState(button.rs:17)/widget が各 state をどう描くか + ギャップ。
- worker2 = Mac OS 9 + Big Sur の state 仕様: Mac OS 9 default ボタン脈動/強調、press 反転、Big Sur は hover/press の subtle 変化 + focus ring。出典 Inside Macintosh/Aqua HIG。
- worker3 = Windows 10 の state 仕様 + **golden state テスト設計**: Win10 hover/press/focus。加えて GUI_kit 既存 golden 画像フレームワークを調査し、widget × state × theme をバッファ描画 → 実物参照画像と比較する golden 整備の設計案を `workspace/phase3b/golden-state-design.md` に（参照画像の作り方/比較方式/既存 golden_widgets との統合）。

## 全体の狙い（user 合意済の3層）
- (A) 挙動「仕様」= 研究+実装可（見なくても）
- (B) state 見た目検証 = golden 画像で決定論的に（AI が見られない問題を体系的に解消）
- (C) 真の空気感/timing = milestone で user が触って承認（人間不可分）

実装は user の gallery 評価フィードバック後に優先度付けして dispatch。

---

# 第4波: gallery 機能を settings に統合（L2 widget showcase section）

user 方針: gallery(L1-direct) を L2 移植せず、**gallery の widget showcase 機能を settings に統合**。→ settings が「L2 クリーン + ランタイムテーマ切替 + 全 widget 評価 + 実プロダクト」を兼ねる唯一の正準サーフェスに。

## 目的
settings に新 section「Widgets」を追加し、全 widget を state 込みで並べる。user が press/hover/focus + disabled を実機評価できる場（Phase 3b behavioral 評価サーフェス）。**disabled を並べることで Gap B(無効が通常と同じ)も視覚的に露呈**し、user 確認 → 実装 → golden bless の loop が settings 内で完結。

## 制約（厳守）
- **L2 厳守**: hayate-kit のみ、hayate_platform 直 dep 禁止（settings 規範）。gallery の demos(L1)は参考にしつつ hayate-kit 公開 API で再実装。不足 API は hayate-kit に re-export 追加 PR。
- theme 切替は settings の set_bundle が全 tree 自動再theme（showcase も連動、追加配線不要）。
- 1ファイル500行目安、cargo -j1 直列、出典不要（自作 UI だが既存 settings/gallery パターン踏襲）。

## 設計（settings アーキ準拠）
1. **scaffolding（共有ファイル、1 owner 先行で競合回避）**: `SectionId::Widgets` 追加（sections/mod.rs enum + from_tree_path nav mapping）+ main.rs build_detail に `SectionId::Widgets => sections::widgets::build(...)` + sidebar nav entry。
2. **`src/sections/widgets/` module + widget group 別サブファイル（競合回避）**:
   - `buttons.rs`: ButtonWidget を normal / disabled / (default) で並べる（Gap B 可視化）
   - `selections.rs`: Checkbox / Radio / Switch（checked/unchecked/disabled）
   - `inputs.rs`: Input / Slider / Dropdown / SpinButton
   - `feedback.rs`: Progress / Tooltip
   - `containers.rs`: Tab / GroupBox / ScrollBar
   - `mod.rs`: build() coordinator が各 group を VStack 等で縦に並べ、group 見出し label を付ける
3. 各 widget は label 付き（例「Button: normal / disabled」）で interactive に配置。

## worker 割当案（boss1 調整）
- scaffolding 先行（1人、例 worker3）: SectionId + nav + build_detail + widgets/mod.rs skeleton。完了を待って他 worker が group 追加（mod.rs の group 登録は競合点なので順次 or worker3 が集約）。
- worker1: buttons.rs + selections.rs / worker2: inputs.rs + feedback.rs / worker3: scaffolding + containers.rs

## 完了後
PRESIDENT が settings 再ビルド → user が Widgets section でテーマ切替しながら全 widget 挙動を評価 → behavioral 実装(Gap A/B 等)の優先度確定 → golden bless。

---

# 第5波: settings UI 修正 2 件（user 指摘、cargo -j1 直列）

theme swap は root-fix 済（6d6f8ba: SplitView inject_theme forward + win95 dither guard + reactive_dirty）。user が実機で次の2 UI bug を指摘:

## Task A: 左上「Search settings」検索窓がタイトルバーに重なる
- 症状(PRESIDENT screenshot 精査): タイトルバー(全幅, y≈0-12) の左部に sidebar 先頭の Search settings 検索窓(y≈0-32)が被る。detail pane(外観 y≈30) は chrome 下に正しく出るのに、sidebar の検索窓は y≈0。
- PRESIDENT 調査: app.rs paint_with_csd は root を `with_translate(0, csd_h)` で chrome 高さ分下げて描画(app.rs:607-622)、csd_h = csd_height()。本来 sidebar も detail も chrome 下になるはず。
- 調査ポイント: (1) csd_height() の値 vs HAYATE Original タイトルバーの実描画高さ(title bar が csd_h より高く描画して body に食い込む?)、(2) SplitView の sidebar pane / search widget(settings src/search.rs)の配置が translate を無視していないか、(3) 検索窓が overlay/絶対座標で描かれていないか。
- 修正: 検索窓含む body 全体がタイトルバー下に出るように。framework(app.rs chrome offset)起因なら GUI_kit track-theme/phase3b、settings 起因なら settings 側。
- 視覚確認は PRESIDENT(screenshot)+user。

## Task B: detail pane にスクロールバー追加（長いセクションをスクロール可能に）
- 症状: Widgets 等の長いセクションが viewport を超えるのにスクロールできない。
- 部品: GUI_kit に ScrollView あり(crates/hayate-kit/src/widget/scroll_view.rs)。
- 修正: settings の detail pane の中身(build_detail が返す section、または DetailContainer.inner)を ScrollView でラップし、縦スクロール + スクロールバーを出す。L2 厳守(hayate-kit 経由)。ScrollView の API(content セット/viewport)を確認して正しくラップ。
- 注意: 先の win95 dither overflow は「unbounded layout の横向き ScrollBar」起因。ScrollView ラップ時も子に unbounded constraint を渡さないこと(detail pane 幅は bound されている前提)。
- 視覚確認は PRESIDENT(screenshot)+user。

## 進め方
cargo -j1 直列(1人ずつ)。Task A(調査含む)と Task B は独立ファイル想定なら並行編集可・cargo は順次。各完了で PRESIDENT 報告 → PRESIDENT が settings 再ビルド → user 視覚確認。
