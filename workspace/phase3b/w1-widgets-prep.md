# Phase 3b 第4波 PREP: settings Widgets showcase — buttons.rs + selections.rs

担当: worker1 / 2026-05-20 / **PREP（調査・ドラフトのみ）。cargo 不使用・settings live ファイル不編集**。
実装は worker3 scaffolding 完了 → boss1 解禁後。出典不要（自作 UI、既存 settings/gallery パターン踏襲）。

> スコープ: 第4波 worker1 = `src/sections/widgets/buttons.rs`（ButtonWidget normal/disabled/(default)、Gap B 可視化）+ `selections.rs`（Checkbox/Radio/Switch の checked/unchecked/disabled）。本 doc = 調査結果 + 不足 API list + 両ファイル中身ドラフト。

---

## 0. 調査対象（読んだもの）

| 対象 | パス | 用途 |
|------|------|------|
| gallery demos (L1) | `hayate-linux-gallery/src/demos/{button,checkbox,radio,switch}.rs` | widget 組み立て参考 |
| L2 公開 API | `GUI_kit/crates/hayate-kit/src/{lib.rs,prelude.rs,widget/mod.rs}` | re-export 確認 |
| widget impl | `GUI_kit/crates/hayate-kit/src/widget/{button,checkbox,switch,radio_button}.rs` | disabled/state API 有無 |
| 既存 settings section | `hayate-kit-settings/src/sections/{mod.rs,appearance.rs}` | build シグネチャ + row パターン |

---

## 1. gallery の組み立て方（参考・L1）

```rust
// button.rs
ButtonWidget::new("Primary").on_click(|| ...)       // normal
ButtonWidget::new("Disabled").disabled()            // disabled ✅ ボタンのみ存在
HStack::new(8.0).add(Box::new(primary)).add(Box::new(off))

// checkbox.rs
CheckboxWidget::new("Option A")                     // unchecked
CheckboxWidget::new("Option B (on)").checked(true)  // checked
VStack::new(6.0).add(...).add(...)

// radio.rs
RadioGroupWidget::new(&["Small","Medium","Large"])  // ★ group widget（個別 radio でない）
    .with_engine(ctx.engine.clone()).with_selected(1).on_change(|i| ...)

// switch.rs
SwitchWidget::new(false).on_toggle(|v| ...)         // off。new(true)=on。label 内蔵なし
HStack(label, switch)                                // label は別 LabelWidget で添える
```

**注意（gallery と settings の差）**: gallery は `ctx.engine.clone()` を `with_engine` で明示注入。**settings は build 時に engine を渡さず、tree mount 時の `inject_engine` で tree 全体に注入**（appearance.rs は LabelWidget/ComboBox 等に `with_engine` を一切呼ばない）。→ **showcase でも `with_engine` は呼ばず inject_engine 依存にする**（settings 規範）。

---

## 2. L2 公開 API surface（settings 規範: hayate-kit only）

### 2a. 型の re-export = **全て充足（追加 PR 不要）**
`hayate_kit::prelude::*`（prelude.rs）が以下を flat re-export 済 → settings から hayate-kit only で reach 可（hayate_platform 直 dep なし）:

| 型 | prelude 行 | 用途 |
|----|-----------|------|
| `ButtonWidget` | 75 | buttons.rs |
| `CheckboxWidget` | 105 | selections.rs |
| `RadioGroupWidget` | 110 | selections.rs |
| `SwitchWidget` | 83 | selections.rs |
| `LabelWidget` | 78 | group 見出し / switch label |
| `HStack` / `VStack` | 79 | 横/縦並べ |
| `FormLayout` | 77 | label + widget row |
| `GroupBoxWidget` | 107 | （任意）group 枠 |
| `Widget` (trait) | 139 | `Box<dyn Widget>` 戻り |

→ **buttons.rs / selections.rs とも `use hayate_kit::prelude::*;` 1 行で型は揃う**。`Widget` も `hayate_kit::Widget`(lib.rs:123) で reach。**型レベルの re-export PR は不要**。

### 2b. settings section の build パターン（appearance.rs 実測）
```rust
pub fn build(strings: &'static Strings, state: &AppStateHandles) -> Box<dyn Widget> {
    let heading = LabelWidget::new(strings.section_appearance, 18.0);   // 見出し
    let form = FormLayout::new()
        .row("Font size scale", font_scale)   // row(label, impl Widget)
        .row("Color mode", color_mode);
    let mut stack = VStack::new(16.0);
    stack = stack.add(Box::new(heading));
    stack = stack.add(Box::new(form));
    Box::new(stack)
}
```
- `FormLayout::row(label: impl Into<String>, field: impl Widget + 'static)`（form_layout.rs:126）= label 文字列 + 任意 widget。**field に HStack を渡せる**ので「normal / disabled を横並び」の行が作れる。
- showcase は persistence 不要なので `state` は使わない見込み（`_state`）。**build シグネチャは worker3 scaffolding が確定**（§5 調整点）。

---

## 3. 🚨 不足 API list（PRESIDENT 報告事項・phase 2 で対応要）

型 re-export は充足だが、**disabled showcase に必須の「メソッド」が widget 本体に存在しない**。これは re-export でなく **hayate-kit widget 本体への追加**（= framework が capability を提供、consumer 側 band-aid 禁止 = platform 原則）。

| # | widget | 不足 | 現状 | 影響 | 対応 |
|---|--------|------|------|------|------|
| API-1 | **CheckboxWidget** | `disabled()` builder + `set_enabled()` | `disabl/enabl` 参照ゼロ（checkbox.rs grep 確認） | checked/unchecked は出せるが **disabled 状態を作れない** | hayate-kit に追加（ButtonWidget と同形: `disabled`/`set_enabled`/`is_disabled` + event swallow + paint greying） |
| API-2 | **SwitchWidget** | `disabled()` + `set_enabled()` | 同上（switch.rs grep ゼロ） | off/on は出せるが disabled 不可 | 同上 |
| API-3 | **RadioGroupWidget** | `disabled()`（group 単位 or 個別 option） | 同上（radio_button.rs の disabl 一致は無関係: hover_bg_enabled / key-nav） | 選択は出せるが disabled group 不可 | 同上（group 全体 disable で可） |
| API-4 | **ButtonWidget default button** | 既定ボタン styling（`.default()` 等） | `default/primary/accent` メソッドなし | (default) showcase が**実体なし** | wave-3 win95-behavior G1（既定ボタン外周黒枠）と同件。phase 2 では (default) は省略 or label のみ。実装は別途 |

> **Gap B との関係**: API-1〜3 が無いため selections は **そもそも disabled 状態を表示できない**（= Gap B より深刻）。button は `.disabled()` 有り（API-4 の default 除く）なので normal/disabled は出せ、非 bevel テーマで「disabled が normal と同じ見た目」= Gap B が露呈する（wave-3 winxp-behavior G4: etched は bevel 限定）。
>
> **phase 2 の前提**: selections.rs の disabled 行を出すには **API-1/2/3 の追加が先行依存**。boss1/PRESIDENT 判断で (a) API 追加を phase 2 に含める か (b) 暫定で checked/unchecked のみ出して disabled は API 追加後に足す か を決める必要あり（§4 ドラフトは API 有り前提 + fallback 併記）。

---

## 4. ファイル中身ドラフト

> 共通: `use hayate_kit::prelude::*;`。engine は `with_engine` を呼ばず tree inject_engine 依存（settings 規範 §1）。build シグネチャは scaffolding 確定待ち（暫定 `build() -> Box<dyn Widget>`、state 不要）。group 見出しは LabelWidget 16px。

### 4a. `src/sections/widgets/buttons.rs`（ButtonWidget、Gap B 可視化）

```rust
//! Widgets showcase — Buttons group.
//!
//! ButtonWidget を normal / disabled で並べ、user が press/hover/focus を
//! 実機評価できる場。disabled を normal と横並びにすることで「無効が通常と
//! 同じ見た目」(Gap B、modern skin で顕著) を視覚的に露呈させる。
use hayate_kit::prelude::*;

pub fn build() -> Box<dyn Widget> {
    let heading = LabelWidget::new("Buttons", 16.0);

    // normal と disabled を横並び（Gap B: 無効が通常と区別つくか user 確認）
    let normal = ButtonWidget::new("Normal").on_click(|| println!("showcase btn: normal"));
    let disabled = ButtonWidget::new("Disabled").disabled();   // ✅ ButtonWidget は disabled() 有り
    let mut state_row = HStack::new(8.0);
    state_row = state_row.add(Box::new(normal));
    state_row = state_row.add(Box::new(disabled));

    // press/hover/focus を触って評価する単体（disabled と挙動比較）
    let interactive =
        ButtonWidget::new("Press / Hover / Focus").on_click(|| println!("showcase btn: interactive"));

    let form = FormLayout::new()
        .row("State (Gap B): normal vs disabled", state_row)
        .row("Interactive", interactive);
        // NOTE (default): ButtonWidget に既定ボタン styling API が無い（不足API-4）。
        // 実装され次第 .row("Default button", ButtonWidget::new("OK").default()) を追加。

    let mut stack = VStack::new(12.0);
    stack = stack.add(Box::new(heading));
    stack = stack.add(Box::new(form));
    Box::new(stack)
}
```

### 4b. `src/sections/widgets/selections.rs`（Checkbox / Radio / Switch）

```rust
//! Widgets showcase — Selections group (Checkbox / Radio / Switch).
//!
//! 各 widget を checked/unchecked(+ selected) と disabled で並べる。
//! disabled 行は不足API-1/2/3（CheckboxWidget/SwitchWidget/RadioGroupWidget の
//! disabled()）の追加が前提。API 未追加時は [FALLBACK] 行を使い disabled を省く。
use hayate_kit::prelude::*;

pub fn build() -> Box<dyn Widget> {
    let heading = LabelWidget::new("Selections", 16.0);

    // ── Checkbox: unchecked / checked / disabled ──
    // checkbox は label 内蔵 → VStack に直接（FormLayout だと二重 label になる）
    let cb_label = LabelWidget::new("Checkbox", 13.0);
    let mut cb_col = VStack::new(6.0);
    cb_col = cb_col.add(Box::new(CheckboxWidget::new("Unchecked")));
    cb_col = cb_col.add(Box::new(CheckboxWidget::new("Checked").checked(true)));
    cb_col = cb_col.add(Box::new(CheckboxWidget::new("Disabled").disabled())); // ← 不足API-1 待ち
    // [FALLBACK] API 未追加なら上行を削除（unchecked/checked のみ）

    // ── Radio group: 選択 + disabled group ──
    let radio_label = LabelWidget::new("Radio group", 13.0);
    let radio = RadioGroupWidget::new(&["Small", "Medium", "Large"]).with_selected(1);
    let radio_disabled =
        RadioGroupWidget::new(&["A", "B", "C"]).with_selected(0).disabled(); // ← 不足API-3 待ち
    // [FALLBACK] API 未追加なら radio_disabled を省く

    // ── Switch: off / on / disabled（label 内蔵なし → FormLayout.row で label 付け）──
    let switch_form = FormLayout::new()
        .row("Switch: off", SwitchWidget::new(false))
        .row("Switch: on", SwitchWidget::new(true))
        .row("Switch: disabled", SwitchWidget::new(false).disabled()); // ← 不足API-2 待ち
    // [FALLBACK] API 未追加なら最終行を省く

    let mut stack = VStack::new(12.0);
    stack = stack.add(Box::new(heading));
    stack = stack.add(Box::new(cb_label));
    stack = stack.add(Box::new(cb_col));
    stack = stack.add(Box::new(radio_label));
    stack = stack.add(Box::new(radio));
    stack = stack.add(Box::new(radio_disabled));
    stack = stack.add(Box::new(switch_form));
    Box::new(stack)
}
```

> on_click/on_toggle/on_change は showcase では println デバッグ程度（評価対象は見た目/挙動）。persistence は不要。

---

## 5. 実装時の調整点（worker3 scaffolding 依存・boss1 経由）

1. **build シグネチャ**: worker3 の `widgets/mod.rs` coordinator が各 group の `build()` をどう呼ぶか（引数 `strings`/`state` 有無）に合わせる。本ドラフトは引数なし `build()` 想定。scaffolding 確定後に整合。
2. **mod.rs への group 登録は競合点**: mission §2「mod.rs の group 登録は順次 or worker3 集約」。worker1 は buttons.rs/selections.rs の**中身のみ**を作り、`mod buttons; mod selections;` + coordinator への追加は worker3 集約 or 順次（共有ファイル衝突回避、feedback_shared_wt_commit_hygiene）。
3. **engine 注入**: showcase は `with_engine` を呼ばず settings tree の inject_engine に依存（§1）。phase 2 着手時に Checkbox/Radio/Switch が inject_engine を propagate するか cargo build で確認（PREP では cargo 不可のため未検証）。
4. **不足 API（§3）**: API-1/2/3（Checkbox/Switch/Radio の disabled）の追加可否を boss1/PRESIDENT が決定。追加するなら hayate-kit 側 widget 変更（worker 割当 + cargo -j1 直列）。未追加なら selections.rs は [FALLBACK]（disabled 省略）で着手し、Gap B 露呈は button のみで先行。
5. **theme 連動**: settings の set_bundle が tree 全体を自動 re-theme（showcase も追加配線不要、mission §143）。

---

## 6. PREP 完了サマリ

- 型 re-export: **充足**（prelude が Button/Checkbox/Radio/Switch/Label/HStack/VStack/FormLayout/Widget を flat 提供、追加 PR 不要）。
- **不足 API（要対応）**: CheckboxWidget / SwitchWidget / RadioGroupWidget の **`disabled()` + `set_enabled()` が皆無**（disabled showcase の前提）。ButtonWidget の既定ボタン API も無し（(default) 省略）。
- buttons.rs / selections.rs の中身ドラフト記載済（disabled 前提版 + [FALLBACK] 併記）。
- 実装は scaffolding 完了 + boss1 解禁後。cargo 未起動・settings live 不編集を厳守。
