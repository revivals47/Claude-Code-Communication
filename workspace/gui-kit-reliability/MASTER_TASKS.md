# プロジェクト: hayate-ui (GUI_kit) 信頼性向上 5トラック並列実行

## 目標 (PRESIDENT 要求)
dogfood (hayate-freecell / hayate-notepad) で連発した構造的問題を解消し、
「速さがアイデンティティ」の前提となる基礎信頼性を底上げする。

**リポジトリ**: `~/Documents/GUI_kit` (revivals47/GUI_kit, branch=main)
**全体納期**: 2026-05-05 (1 週間以内)
**各トラック納期**: 2〜3 日

---

## 進捗ダッシュボード (5/5 トラック未着手)

### 🔴 Track 1: clip 適用バグ systematic audit (worker1) [優先度: 最高]
- 担当: worker1
- 状態: 🔄 着手予定
- 対象: `src/render/mod.rs` (1088 行) の全 paint primitive
- 完了条件:
  - [ ] (a) 全 paint primitive が CPU path で `cpu_apply_clip_only` 経由
  - [ ] (b) `push_clip` 効果の integration test を追加
  - [ ] (c) `cargo clippy` で warning 増やさない
- 漏れ候補: `fill_rounded_rect` (L253), `fill_rounded_rect_with_border` (L623),
  `fill_rounded_rect_with_shadow` (L689), `fill_gradient_v/h/radial` (L772/828/881),
  `draw_text` 系 (L373/403/441/479)

### 🟡 Track 2: Widget trait inject_X 伝播の仕組化 (worker3) [優先度: 高]
- 担当: worker3
- 状態: 🔄 着手予定
- 対象: `src/widget/mod.rs` (Widget trait), `WindowFrame`/`Notepad`
- 完了条件:
  - [ ] (a) `children_mut()` 必須化 OR `composite_widget!` マクロで自動 forward
  - [ ] (b) 既存手書き forward (WindowFrame など) を消しても挙動変わらず
  - [ ] (c) 既存テスト全パス

### 🔴 Track 3: text_area.rs 分割 + text_editor.rs 統合 (worker2) [優先度: 高・最重]
- 担当: worker2 (専念)
- 状態: 🔄 着手予定
- 対象: `src/widget/text_area.rs` (1328 行), `src/specialized/text_editor.rs` (587 行)
- 完了条件:
  - [ ] (a) 全ファイル 500 行以下
  - [ ] (b) 既存テスト (cargo test) 全パス
  - [ ] (c) hayate-notepad で長文日本語タイプ → 視覚退行なし
  - [ ] (d) 機能後退ゼロ (Ctrl+C/V/Z, word wrap, 横スクロール, bitmap font)

### 🟡 Track 4: Theme propagation 一元化 (worker1) [優先度: 中]
- 担当: worker1 (Track 1 完了後)
- 状態: ⏸ Track 1 後着手
- 対象: `src/app.rs`, Theme と AppTheme の関係
- 完了条件:
  - [ ] (a) `App::with_theme(&WIN95_THEME)` だけで `AppTheme::win95()` も自動連動
  - [ ] (b) hayate-notepad の main.rs で `with_app_theme` を消しても bitmap font が出る
  - [ ] (c) 既存 dogfood アプリで win95 表示退行なし

---

## 📌 PRESIDENT 予約トラック (現行 5 トラック全完了後に着手)

### Track 6: 外部ユーザ向けドキュメント整備 [Pending — trigger: 全 5 PR main マージ]
- 担当推奨: worker1
- 納期: Track 1〜5 全完了から 1 週間以内
- 成果物:
  - 全 public API rustdoc (cargo doc --no-deps で warning 0)
  - docs/widget-author-guide.md (Track 2 children_mut 規約必須)
  - docs/theme-system.md (Track 4 完了後)
  - docs/clipboard-and-ime.md (Track 3 完了が望ましい)
  - README.md を 5 分で読める分量に再編
  - HANDOFF-*.md / IMPLEMENTATION_REPORT.md 等 ~10 個を archive/ に移動
- 完了条件: 新規ユーザが README → widget-author-guide だけで Hello World widget 作成可、全公開 API doc 完備
- ⏰ boss1 手隙時間に archive/ 移動候補リスト事前作成 OK (実害ゼロ)

### Track 7: キーボードナビ + 視覚アクセシビリティ [Pending — trigger: 全 5 PR main マージ]
- 担当推奨: worker2 (A+C) / worker3 (B)
- 納期: 1〜2 週間
- 成果物 A: Focus traversal — WidgetEvent::FocusNth 規律確立、core widget 8 種で focus ring、Tab 巡回、examples/keyboard_nav_demo.rs
- 成果物 B: 視覚テーマ拡張 — Theme::with_high_contrast()、AppTheme::font_scale: f32
- 成果物 C: screen reader L1 — Widget trait に accessibility() 追加、8 widget で role+name、examples/accessible_demo.rs
- 完了条件: hayate-notepad で Tab 巡回 / shortcut 確実、HAYATE_DARK_HC で読みやすい、font_scale 1.5 で破綻しない、Orca で hayate-notepad 読み上げ可
- 非ゴール: Mac/Win 対応、Canvas a11y、認知 a11y
- 着手 trigger: boss1 → PRESIDENT に『現行全完了、Track 6/7 着手 GO 判断要請』を 1 行で

### 依存マスト
- Track 6 widget-author-guide.md ← Track 2 完了必須
- Track 6 theme-system.md ← Track 4 完了必須
- Track 6 clipboard-and-ime.md ← Track 3 完了が望ましい
- Track 7 全体 ← 現行 5 全完了 (Theme/render/widget API 固定) 必須

---

### 🟡 Track 6: 運用プロトコル改訂 (boss1) [優先度: 中・即対応]
- 担当: boss1 (PRESIDENT 即対応指示)
- 状態: ✅ 完了 (2026-04-28 17:30)
- 完了内容:
  - [x] instructions/boss.md '作業ディレクトリ管理' に worktree 隔離プロトコル追加
  - [x] CLAUDE.md (Claude-Code-Communication) に worktree 隔離指示を追記
  - [x] ブランチ名命名規則 (track{N}/[topic]) を boss.md に固定
  - [x] 事故時リカバリ手順 (worker2 実例) を boss.md に明記

### 🟡 Track 5: golden test + bench harness (worker3) [優先度: 中・並列可]
- 担当: worker3 (Track 2 と並走可)
- 状態: 🔄 着手予定
- 対象: `examples/widget_showcase.rs`
- 完了条件:
  - [ ] (a) `cargo test --features visual` で showcase が pixel-stable
  - [ ] (b) `cargo bench` で 1 frame の draw call 数 / shape cache hit rate 計測
  - [ ] (c) Track 1〜4 完了後に 1 件 regression を検出した実績

---

## Worker 別タスクキュー

### Worker1 (render / theme)
- 🔄 現在: Track 1 — clip audit
- 📋 次1: Track 4 — Theme propagation 一元化
- 📋 次2: Track 1〜4 完了後の改善タスク (reserve)

### Worker2 (text_area refactor 専念)
- 🔄 現在: Track 3 — text_area.rs 分割 + text_editor.rs 統合
- 📋 次1: Track 3 完了後 hayate-notepad での dogfood 確認
- 📋 次2: ベンチで text_area の draw call 数測定 (Track 5 連携)

### Worker3 (trait 設計 / テスト基盤)
- 🔄 現在: Track 2 — inject_X 伝播の仕組化
- 📋 次1: Track 5 — golden test + bench harness (並走可)
- 📋 次2: Track 1〜4 の regression を golden test で実証

---

## 完了基準 (= プロジェクト完了判定)
- [ ] 5 トラックの PR 全部 main マージ済
- [ ] hayate-notepad で長文日本語タイプ視覚退行なし
- [ ] text_area.rs が 500 行以下
- [ ] golden test 動作 + 1 件 regression 検出実績
- [ ] bench で draw call 数の baseline がレポートに残る

## 報告フロー
- 各 worker → 30 分ごとに進捗報告 (boss1 へ)
- boss1 → 21:00 に PRESIDENT へ統合進捗報告
- ブロッカーは 5 分以内に報告 / 30 分以内に判断

---

## PRESIDENT 判断確定事項 (2026-04-28 16:50)

### Track 2 設計方針 (確定)
- **ハイブリッド**: children_mut() を Widget trait デフォルト機構 + composite_widget! マクロを sugar
- 副作用付き inject_X (status_bar.rs:720 の win95 panel/grip 自動有効化) は override で残す
- 関連テスト inject_theme_win95_auto_enables_panels_and_grip (status_bar.rs:962) を絶対に壊さない

### 提出物 (21:00 統合報告に同梱)
- worker1: `docs/rfc-track1-clip-audit.md` (漏れ調査リスト + 修正方針 + test 設計)
- worker2: `docs/rfc-track3-text-area-split.md` (engine/render/widget 責務 + text_editor 重複 API)
- worker3: `docs/rfc-track2-widget-children.md` (trait シグネチャ + マクロ + 副作用 override 一覧)

### スコープ削減ライン (緊急時のみ)
1. Track 5 の cargo bench を後回し (golden test は残す)
2. Track 4 を 'with_app_theme 削除可能化' から 'warning ログ追加' に縮小
3. Track 3 の text_editor.rs 統合を後回し (text_area 分割だけ完遂)
- Track 1 / Track 2 は削れない (基礎信頼性の根幹)

### 次回チェックポイント
- 17:20 頃 (30分後): worker1 の漏れ調査リスト A セクション、worker3 の RFC、worker2 の責務マップ
- 21:00: PRESIDENT へ統合進捗報告 (3 RFC を束ねて提出)

---

## 🚨 17:30 重大運用インシデント (修復済)

### 概要
3 worker が同一 working tree (~/Documents/GUI_kit) を共有していたため、互いの未コミット変更が混入。worker2 が step 1 着手時に検出・即修復。実害ゼロ。

### worker2 のリカバリ
- stash@{0}: stray-render-text-edit-from-worker1-track1 (worker1 の text.rs 編集)
- stash@{1}: stray-other-worker-edits-preserved-by-worker2 (worker3 の 6 ファイル WIP)
- track3 に 387e51e を cherry-pick → 12fcb15 として正しく着地
- track2 を main HEAD にリセット
- cargo test --lib: 1103 passed 緑維持

### 根本対策: worktree 隔離プロトコル (即発効)
- worker1: ~/Documents/GUI_kit-track1 (stash@{0} 復元後に作成)
- worker2: ~/Documents/GUI_kit-track3 (推奨)
- worker3: ~/Documents/GUI_kit-track2 (既に採用済)
- 共有 ~/Documents/GUI_kit には今後触らない

### 残課題 (5/5 後)
- boss.md / CLAUDE.md に worktree 隔離プロトコルを正式記載

---

## Track 2 Phase 計画 (worker3 提出, boss1 承認済)

| Phase | 納期 | 内容 | 削除 fn (累計) |
|-------|------|------|---------------|
| Phase 1 | 4/29 EOD | core.rs default + macros.rs + win95_frame 手書き削除 | 2 (2) |
| Phase 2 | 4/30 EOD | window_frame に composite_widget!(content: optional) 適用 | +1 (3) |
| Phase 3 | 5/2 EOD ※条件付 | shortcut_layer transparency 解消 (5/1 副作用調査次第、中止可) | +2 (5) |
| Phase 4 | 5/4 EOD | VStack/HStack/Padding/GridLayout 24 行 cosmetic 適用 | (5) |
| Phase 5 | 5/5 | 統合検証 + Track 5 連携 + CHANGELOG | — |

5/5 までの削除 fn = 3〜5 個 (Phase 3 採否次第)。最低 3 個確定。
