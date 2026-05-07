---
name: Rust #[deprecated] attribute は private items / trait method override で effective でない
description: 2026-05-07 GUI_kit pp1d 計測で確定。private inherent fn / private const / trait method override (paint_overlay 等) に #[deprecated] attribute を付けても warning が出ず、cargo check で 'useless [deprecated] attribute' warning + 未来 hard error 化、技術負債回避のため別の deprecation 手段を採用
type: feedback
originSessionId: 1035e373-fb86-4a60-805f-eb292e2c50a1
---
Rust の `#[deprecated]` attribute は public API での deprecation シグナルとして有効だが、以下の場所では effective でない (warning が発生せず、cargo は 'useless [deprecated] attribute' を返す):

**effective でないケース:**
- private inherent fn (`fn`, `pub(crate) fn` 等)
- private const
- trait method の override (impl 側で override する method、e.g. `Widget::paint_overlay` の override)
- cfg-gated method 内部 (compile されない code path)

**Why:** `#[deprecated]` は外部 caller への warning シグナルが本旨、private items は外部 caller がいないため warning 不要 = useless 判定。trait method override も trait 定義側のみ effective、override 側 attribute は無意味。

**実例 (GUI_kit pp1d、2026-05-07):**
- popup-legacy feature gate 経由の cfg-gated method (DropdownWidget paint_overlay override 等) に `#[deprecated]` 追加 → cargo check --features popup-legacy で 'useless [deprecated] attribute' warning + 'will become a hard error in a future release'
- 未来 hard error 化 risk = 技術負債

**How to apply:**
- `#[deprecated]` を public API (pub fn / pub struct / pub trait method 定義側) のみに使用、private / override では使わない
- private items の deprecation 通知が必要な場合の代替手段:
  1. **Cargo.toml description / features description** に DEPRECATED note (cargo features で visible)
  2. **doc comment / // DEPRECATED comment** に明示 (人読み)
  3. **migration guide doc** (docs/migration-*.md) で external user adaptation guide
  4. **PR description / commit message** で計測 fact + 制約説明
- これらの組み合わせで「人読み deprecation」を構築、machine-enforced warning は public API 側のみで使う

**事例: GUI_kit pp1d (PR #80、2026-05-07):**
- 当初設計 (P23) で `#[deprecated]` attribute 採用方向 → worker1 計測で 'useless [deprecated] attribute' warning 検出 → reverse escalate (P24) で人読み deprecation 4 ソース構築 (Cargo.toml + // DEPRECATED comment + migration guide doc + PR description) 採用、warning 0 + 技術負債回避

**関連 memory:**
- `feedback_measure_first_rescope.md`: 計測ファースト規範 (本制約発見の根拠)
- `feedback_president_dispatch_pace.md`: deep argument (計測 fact) による reverse escalate 機構
- project `project_gui_kit_reliability.md` (P21 案 Z / (P23)→(P24) 経緯)
