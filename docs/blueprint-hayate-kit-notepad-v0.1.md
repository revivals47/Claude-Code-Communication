# BLUEPRINT — hayate-kit-notepad v0.1（新世代 notepad リメイク）

- **status**: v0.2（user レビュー済 = repo 名 / DTP 布石深さ / R1 先行調査 確定。R1 解決 + hardening 先行を反映）
- **date**: 2026-06-11（work-PC、v0.1 起草 → v0.2 改訂）
- **位置付け**: GUI_kit 新世代 app 第 N 号。legacy `hayate-notepad`（dogfood 資産）の clean-slate リメイク。
- **依存規範**: `feedback_dogfood_legacy_new_apps_clean_slate` / `feedback_new_apps_depend_on_gui_kit_only` / north star = `project_dtp_app_roadmap`

---

## §0. なぜ今これか（起案の経緯）

2026-05-19 work-PC セッションで user が **「過去の資産に縛られない開発をしたい」** と明示。notepad で発見した 2 gap について **「notepad-side で fix せず、新アプリ起案を待つ」** stance を確定（`feedback_dogfood_legacy_new_apps_clean_slate`）。本 BLUEPRINT はその deferred 新アプリ起案 = **notepad リメイク**を起こすもの。

**2026-06-11 調査で確定した重要事実**: defer した 2 gap は両方とも GUI_kit 側で既に解決済 → リメイクは「framework を正しく使うだけ」で吸収。

| gap (2026-05-19) | 現状 (2026-06-11 grep) | リメイクでの解決 |
|---|---|---|
| 件 1: titlebar 閉じる/最大化ボタン不在 | hayate-kit が `Decorations` / `build_systemlike` / `TitleBarTheme` re-export 済（prelude 入り）。settings が初 SystemLike consumer 実証 | `Decorations::SystemLike` opt-in + `build_systemlike` chrome chain |
| 件 2: drag selection 不在 | `TextAreaWidget`（text_area/widget.rs）に `pointer_selecting` + PointerMove→selection extend 実装済 | `TextAreaWidget` を使うだけで取得 |

→ **clean-slate path の正当性の実証**: legacy patch ではなく新 app で「正しい opt-in pattern を hard-bake」する ROI が高いという 05-19 の判断が、framework 側準備済の今そのまま現実になる。

---

## §1. What / Why / Who（クイック分析）

- **What**: `hayate-kit` のみに依存する新世代 notepad アプリ。プレーンテキスト編集を MVP とし、**DTP（縦書き / ルビ / rich text）への布石を document model に hard-bake** した構造で起こす。
- **Why**:
  1. legacy notepad の 2 gap を clean-slate で解消（titlebar / drag selection）。
  2. GUI_kit text 系 widget（TextArea / CodeEditor / text_core）の新世代 dogfood として framework feedback loop を強化。
  3. **north star = DTP app への最短経路**。notepad は「縦書き / ルビ」が真の残課題（grep 0）の DTP に向けた最小実戦場（`project_dtp_app_roadmap` の「Phase 2 推定 = notepad-style editor」に一致）。
- **Who**: GUI_kit dogfood（framework 検証）+ 将来の DTP ユーザー（日本語テキスト編集）。

---

## §2. crate 構成（設計判断 D1）

DTP 布石を踏まえ **2-crate 構成**を推奨（settings は単一 crate、agents v3 は 3 crate。notepad は中間）:

```
hayate-kit-notepad/
├── crates/
│   ├── notepad-core/        # 非 GUI: document model（text buffer + 将来の rich-text span 層）
│   │   └── 依存: serde（永続化）/ なし（GUI 非依存を厳守）
│   └── notepad-ui/          # GUI: hayate-kit のみ依存、App 配線 + widget composition
│       └── 依存: hayate-kit, notepad-core, clap（safe-boot flag）
└── docs/                    # 本 BLUEPRINT が scaffolding 後ここへ移設
```

**なぜ core 分離か（DTP 布石の本体）**: DTP の rich-text（ルビ = base text + ruby annotation span、縦書き = layout direction）は document model 層の抽象に属する。これを最初から GUI 非依存の `notepad-core` に置けば、(a) MVP 時点ではプレーン `String` + cursor だが (b) DTP 拡張時に `Document` 型へ span 層を additive 拡張でき (c) GUI widget 側を巻き込まない。settings の単一 crate 構成では rich-text model が widget に癒着しやすい。

**代替案 D1-alt**: 単一 crate（settings 同型）。MVP は最速だが DTP 布石が弱い → user が「DTP 布石込み」を選択したため非推奨。

---

## §3. MVP スコープ（初期 deliverable）

「最小 MVP（テキスト編集 + titlebar + drag select）」に **DTP 布石**を足した範囲:

### M1. コア編集（notepad-ui + TextAreaWidget）
- [ ] `TextAreaWidget` ベースのプレーンテキスト編集（drag selection は framework 既存機能で自動取得）
- [ ] `Decorations::SystemLike` + `build_systemlike` で titlebar（閉じる/最大化/最小化ボタン）opt-in
- [ ] IME 入力（fcitx5 / Wayland text-input）— **R1 で hayate-kit 経由有効化を要確認**
- [ ] キーボード: Ctrl+A 全選択 / Ctrl+C/V/X / Ctrl+Z（undo は TextArea 提供範囲を確認）

### M2. ファイル I/O（notepad-core + hayate-kit FilePicker）
- [ ] 新規 / 開く / 保存 / 名前を付けて保存（hayate-kit の FilePicker / FileDialog 使用）
- [ ] UTF-8 読み書き、ダーティフラグ + 未保存時の確認ダイアログ（AlertDialog）

### M3. DTP 布石（notepad-core の model 設計のみ、UI は後続）
- [ ] `notepad-core::Document` を **将来 rich-text span を additive で持てる構造**で定義（MVP では plain text path のみ実装、span 層は型の placeholder + コメントで意図明示）
- [ ] 縦書き / ルビ は **本 MVP では実装しない**（grep 0 = framework 側に縦書き layout / ルビ primitive が無いため、別 RFC で GUI_kit 拡張から）。ここでは「拡張点を塞がない model 設計」のみを deliverable とする

### スコープ外（明示）
- 検索/置換（M2 後の wave）/ タブ複数ファイル / シンタックスハイライト（= CodeEditorWidget 領域）/ 縦書き・ルビの実装本体（別 RFC）

---

## §4. 主要リスク

| ID | リスク | 影響 | 対応 |
|---|---|---|---|
| **R1** | ~~IME(ibus) / a11y(AT-SPI) を hayate-platform 直 dep なしで hayate-kit 経由有効化できるか~~ | — | **✅ RESOLVED（2026-06-11、boss1 調査 結論 A）**: hayate-platform の default features = [vulkan, ibus, a11y]、hayate-kit は default-features 無効化せず継承 → settings は hayate-kit only でも ibus/a11y 到達済（cargo tree -e features 実証）。legacy notepad の direct dep features 指定は冗長だった。**hardening 先行（user 承認）**: 暗黙 default 継承への依存を消すため hayate-kit に ime/a11y passthrough feature を additive 追加（非破壊・Cargo.toml 2 行、Option X 型 framework PR 進行中）。notepad は features ime/a11y を明示 opt-in する |
| **R2** | `TextAreaWidget` の undo/redo・clipboard 提供範囲が MVP 要件を満たすか | M1 の一部が widget 不足で blocked | scaffolding dispatch 内で worker に widget API 棚卸しを先行させ、不足は GUI_kit 拡張 dispatch に分岐 |
| **R3** | DTP rich-text model を「拡張点を塞がない」形で設計するのは将来要件が未確定なため過剰設計に陥りやすい | core crate の YAGNI 違反 | MVP は plain text path のみ実装、span 層は**型の存在 + 意図コメント**に留め、実装は DTP RFC まで遅延（`feedback_root_cause_over_quick_fix` と YAGNI の両立 = 構造は開けるが中身は書かない） |

---

## §5. 進め方（user 選択 = BLUEPRINT 先行）

1. ~~本 v0.1 を user レビュー~~ ✅ 完了（repo 名 hayate-kit-notepad 確定 / DTP 布石 = 型 placeholder+コメントのみ / R1 先行調査 GO）
2. ~~R1 先行調査 dispatch~~ ✅ 完了（結論 A）→ ~~hardening PR~~ ✅ **land 完了（PR #238 squash、GUI_kit main HEAD = 895c440、2026-06-11 14:54）**。hayate-kit に ime/a11y passthrough feature 追加、暗黙 default 継承依存を解消
3. ~~scaffolding dispatch~~ ✅ **M1 land 完了（2026-06-11 15:26）**。repo = github.com/revivals47/hayate-kit-notepad（**PRIVATE**、genesis commit `466ef35`、10 files/+2707、SSH origin、default branch main）。全 gate pass（cargo check -j1 緑 warning 0 / notepad-core test 4 / HAYATE_SCREENSHOT 視覚確認 titlebar 3 ボタン+編集領域 / 新世代規範 self-check 緑 / codex LGTM finding 0）。**#238 ime/a11y passthrough feature の初 consumer**、legacy 2 gap（titlebar/drag-select）clean-slate 解消（titlebar 視覚実証済）
4. **次**: M1 の user live-verify（実機で起動・文字入力・drag-select・IME） → M2（file I/O 本体）wave dispatch → M3（DTP 布石は型のみ、実装は別 RFC）。`boss.md` dispatch design workflow patterns 準拠

---

## §6. 未確定の確認事項（user 判断待ち）

- repo 名: `hayate-kit-notepad` で確定でよいか（`hayate-kit-*` prefix 規範）
- M3 DTP 布石の深さ: 「型 placeholder + コメントのみ（R3 推奨）」で問題ないか
- R1（IME を hayate-kit 経由で有効化）を **scaffolding 前の先行調査**とするか、scaffolding と同時に走らせるか
