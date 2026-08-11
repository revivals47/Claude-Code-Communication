# Phase 3b 第4波 PREP: settings Widgets showcase — inputs.rs + feedback.rs

worker2 / 2026-05-20。**PREP のみ（cargo 不使用・settings live 非編集）**。scaffolding(worker3) 完了後に実装。
担当 = `src/sections/widgets/inputs.rs`（Input/Slider/Dropdown/SpinButton）と `feedback.rs`（Progress/Tooltip）。

---

## 0. 結論サマリ + 重要 finding

- **L2 公開 API はほぼ充足**。inputs/feedback で使う widget は **TooltipWidget 以外すべて prelude 済**。
- **不足 API（phase 2 で re-export PR 1 件）**: **`TooltipWidget` が prelude に無い**。現状 `hayate_kit::widget::tooltip::TooltipWidget`（full path）でのみ到達（`widget` も `tooltip` も pub mod ゆえ到達は可能、ハード blocker ではない）。composition-ready（`new(Box<dyn Widget>, &str)`）なので prelude 追加が妥当。
- **disabled 状態は inputs/feedback の 6 widget には API が無い**（`pub fn disabled` 等が存在しない、grep 確認）。`.disabled()` を持つのは **ButtonWidget のみ**（+ 選択系は worker1 確認）。→ **inputs.rs/feedback.rs では disabled を並べられない**。Gap B(無効が通常と同じ)の視覚露呈は **buttons.rs(worker1)** が担う。input/feedback への disabled 追加は別 framework タスク（後述 §6）。

---

## 1. widget API リファレンス（gallery demos + ソース grep で確認）

| widget | 型 / 到達 | constructor + 主メソッド | disabled |
|--------|----------|--------------------------|----------|
| Input | `TextInputWidget`（prelude ✓）| `::new().with_placeholder(&str).with_width(f32)` | ✗ 無 |
| Slider | `SliderWidget`（prelude ✓）| `::new(min, max, value).with_step(f32).on_change(\|v\|)` | ✗ 無 |
| Dropdown | `DropdownWidget`（prelude ✓）| `::new(Vec<String>).with_selected(usize).on_select(\|i,&s\|)` | ✗ 無 |
| SpinButton | `SpinButtonWidget`（prelude ✓）| `::new(min, max, value, step).on_change(\|v\|)` | ✗ 無 |
| Progress | `ProgressBarWidget`（prelude ✓）| `::new(f32 0..1)` / `::indeterminate()` / `.set_value(f32)` | ✗ 無 |
| Tooltip | `TooltipWidget`（**prelude ✗** / full path 可）| `::new(Box<dyn Widget>, impl Into<String>)` | ✗ 無 |

補助（全て prelude ✓）: `FormLayout::new().row(label: impl Into<String>, field: impl Widget+'static)`、`LabelWidget::new(&str, f32)`、`VStack::new(gap)`/`.add(Box<dyn Widget>)`、`HStack`、`ButtonWidget::new(&str)`、`Widget`（Box<dyn Widget> 戻り型）。

注: `TextInputWidget` の TextEngine は framework の inject pass が tree 走査で注入（section build は `::new()` 構築のみで可、general.rs の ComboBox/Switch と同様）。

---

## 2. settings section build パターン（既存 general.rs / appearance.rs 準拠）

- import: `use hayate_kit::prelude::*;`
- section entry: `pub fn build(strings: &'static Strings, state: &AppStateHandles) -> Box<dyn Widget>`
- 構造: `VStack { LabelWidget(heading) + FormLayout { rows } }` を `Box::new` で返す。
- HAYATE Original aesthetic は `active_theme()` 既定で自動適用（`.with_color` override 不要）。theme 切替は settings の set_bundle が tree 全体を自動再theme（showcase も追加配線なしで連動）。
- showcase は**永続化しない**（persistence/debouncer 不要）。callback は表示確認用に no-op か println 相当で可（settings 本体の apply_* helper は不要）。

### group ファイルの signature（scaffolding=worker3 が確定。下記は想定）
mod.rs coordinator が各 group を縦に並べる設計（mission §2）。group builder は `pub fn build() -> Box<dyn Widget>`（showcase は state 不要）を想定。
**worker3 の widgets/mod.rs skeleton が決める signature に合わせる**（`build(strings, state)` で来ても showcase 側は両者を無視可）。本ドラフトは引数なし版で記述、解禁時に skeleton へ追従。

---

## 3. inputs.rs ドラフト（Input / Slider / Dropdown / SpinButton）

```rust
//! Widgets showcase — Inputs group (TextInput / Slider / Dropdown / SpinButton)。
//!
//! Phase 3b 第4波: behavioral 評価サーフェス。各 widget を label 付きで interactive
//! に並べる。テーマ切替は settings set_bundle が自動再theme（追加配線なし）。
//! 注: これら 4 widget は disabled API を持たない（hayate-kit 未提供）。
//! Gap B(無効視覚)の露呈は buttons.rs(ButtonWidget.disabled())が担う。

use hayate_kit::prelude::*;

/// Build the Inputs showcase group: heading + one row per input widget.
pub fn build() -> Box<dyn Widget> {
    let heading = LabelWidget::new("Inputs", 16.0);

    // Text input — placeholder + fixed width (gallery text_input.rs 準拠)
    let text_input = TextInputWidget::new()
        .with_placeholder("Type here...")
        .with_width(240.0);

    // Slider — continuous（0–100, value 30）
    let slider = SliderWidget::new(0.0, 100.0, 30.0)
        .on_change(|_v| { /* showcase: no-op（評価は視覚/触感）*/ });

    // Slider — stepped（0–10, step 1）で挙動差を見せる
    let slider_step = SliderWidget::new(0.0, 10.0, 5.0).with_step(1.0);

    // Dropdown — 4 項目、初期選択 0
    let dropdown = DropdownWidget::new(vec![
        "Apple".to_string(),
        "Orange".to_string(),
        "Grape".to_string(),
        "Strawberry".to_string(),
    ])
    .with_selected(0)
    .on_select(|_i, _s| { /* showcase: no-op */ });

    // SpinButton — 0–100, value 10, step 1
    let spin = SpinButtonWidget::new(0.0, 100.0, 10.0, 1.0)
        .on_change(|_v| { /* showcase: no-op */ });

    let form = FormLayout::new()
        .row("Text input", text_input)
        .row("Slider (continuous)", slider)
        .row("Slider (stepped)", slider_step)
        .row("Dropdown", dropdown)
        .row("Spin button", spin);

    let mut stack = VStack::new(16.0);
    stack = stack.add(Box::new(heading));
    stack = stack.add(Box::new(form));
    Box::new(stack)
}
```

---

## 4. feedback.rs ドラフト（Progress / Tooltip）

```rust
//! Widgets showcase — Feedback group (Progress / Tooltip)。
//!
//! Phase 3b 第4波。Progress は determinate 2 段 + indeterminate、Tooltip は
//! Button を hover で説明表示。disabled API は両 widget とも無し。

use hayate_kit::prelude::*;
// TooltipWidget は prelude 未収録のため full path（phase 2 で prelude 追加 PR 推奨、§6）。
use hayate_kit::widget::tooltip::TooltipWidget;

/// Build the Feedback showcase group: progress bars + a tooltip-wrapped button.
pub fn build() -> Box<dyn Widget> {
    let heading = LabelWidget::new("Feedback", 16.0);

    // Progress — determinate 25% / 60% + indeterminate（gallery progress_bar.rs 準拠）
    let progress_25 = ProgressBarWidget::new(0.25);
    let progress_60 = ProgressBarWidget::new(0.60);
    let progress_busy = ProgressBarWidget::indeterminate();

    // Tooltip — Button を包み、hover で説明表示（gallery tooltip.rs 準拠）
    let tip_button = Box::new(ButtonWidget::new("Hover over me"));
    let tooltip = TooltipWidget::new(tip_button, "This is a tooltip");

    let form = FormLayout::new()
        .row("Progress 25%", progress_25)
        .row("Progress 60%", progress_60)
        .row("Progress (indeterminate)", progress_busy)
        .row("Tooltip", tooltip);

    let mut stack = VStack::new(16.0);
    stack = stack.add(Box::new(heading));
    stack = stack.add(Box::new(form));
    Box::new(stack)
}
```

---

## 5. 参考にした gallery demos（L1-direct、L2 で hayate-kit API 再実装）

- `text_input.rs`: `TextInputWidget::new().with_placeholder().with_width()`
- `slider.rs`: `SliderWidget::new(min,max,val).on_change()` / `.with_step()`、VStack 並置
- `dropdown.rs`: `DropdownWidget::new(items).with_selected().on_select()`
- `spin_button.rs`: `SpinButtonWidget::new(min,max,val,step).on_change()`
- `progress_bar.rs`: `ProgressBarWidget::new(frac)` / `::indeterminate()`、VStack 並置
- `tooltip.rs`: `TooltipWidget::new(Box<child>, tip)`、HStack 包み
- gallery は `hayate_platform::widget::core::Widget` 直 import（L1 許容）。settings は L2 ゆえ `hayate_kit::prelude::*` の `Widget` を使用（直 platform dep 禁止）。

---

## 6. 不足 API リスト（phase 2 で hayate-kit re-export PR）

| 項目 | 現状 | 推奨 | 必須度 |
|------|------|------|--------|
| `TooltipWidget` | prelude 未収録、`hayate_kit::widget::tooltip::TooltipWidget` で到達可 | prelude に `pub use crate::widget::tooltip::TooltipWidget;` 追加 | 中（full path で回避可、但し L2 整合のため追加が綺麗）|

→ **inputs.rs/feedback.rs 実装に必須の re-export は無し**（Tooltip も full path で動く）。Tooltip prelude 追加は cleanliness。

### framework タスク（showcase スコープ外、Gap B 関連）
- **input/feedback widget に disabled API 追加**: TextInput/Slider/Dropdown/SpinButton/Progress に `disabled()` / `set_enabled()` が無い。disabled 状態を showcase で並べるには platform 側で各 widget に disabled 対応が要る（[[feedback_platform_principle]] 整合、consumer fake 禁止）。第3波 Gap B（modern 経路 disabled dim 不在）と同根。優先度は user 評価後。

---

## 7. scaffolding(worker3) 解禁後の確認事項
1. group builder の signature（`build()` vs `build(strings, state)`）を widgets/mod.rs skeleton に合わせる。
2. mod.rs coordinator が group をどう登録するか（VStack 縦並び + group 見出し）— heading を coordinator 側で付けるなら group 側 heading は外す。
3. showcase の callback を no-op で良いか（評価は視覚/触感）、それとも値表示 label が要るか（user 評価補助）。
4. 1ファイル500行目安に対し inputs+feedback は十分小さい（各 ~60 行）。問題なし。

実装・cargo は boss1 解禁通知後。本 doc は review 用 PREP。
