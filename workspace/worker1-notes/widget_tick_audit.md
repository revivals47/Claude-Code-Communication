# Widget::tick(dt) 経路監査 — Phase 2-B widget統合の前提確認

worker1 / 2026-04-14
対象: feature/animation-unification-w1 tip (b6d1575)
目的: worker3 の FocusRing Step 6 着手前に「widget が毎フレーム dt を受け取れるか」「追加 API が必要か」を確定。

---

## 1. 結論（先に）

**追加 API は不要**。すでに以下の経路が完全に繋がっている:

```
calloop frame callback  (src/platform/wayland.rs)
  └─ app.rs:492 / 533 / 591 で `app.root.update(dt)` を毎フレーム呼ぶ
      └─ Widget::update(dt) default impl あり（no-op）
          └─ Container widgets が子に forward（下記「2. 網羅状況」）
              └─ leaf widget の update(dt) が tween.tick(dt) する
```

Switch / Button で既に実績のあるパターン:

```rust
// src/widget/switch.rs:412
fn update(&mut self, dt: f32) {
    if !self.tween.is_finished() {
        self.progress = self.tween.tick(dt);
        self.is_dirty = true;
    }
}
```

FocusRing も全く同じ構造で書ける。`draw_focus_ring_ex(..., alpha: u8)`
のオーバーロードもすでに存在するので、`(opacity * 255.0) as u8` を渡せば
アニメ付きフォーカスリングになる。

---

## 2. Widget trait 現状 (src/widget/core.rs:248-295)

```rust
pub trait Widget {
    fn layout(&mut self, constraints: &Constraints) -> Size;
    fn paint(&mut self, renderer: &mut Renderer, rect: ItemRect);
    fn event(&mut self, event: &WidgetEvent) -> EventResponse { ... }
    fn focusable(&self) -> bool { false }
    fn dirty(&self) -> bool { false }
    fn clear_dirty(&mut self) { }
    fn dirty_rect(&self) -> Option<ItemRect> { ... }

    /// Data update phase, called before layout/paint each frame.
    /// Container widgets should forward to children.
    fn update(&mut self, dt: f32) { let _ = dt; }

    fn inject_engine(&mut self, _engine: Rc<RefCell<TextEngine>>) { }
    fn children(&self) -> &[Box<dyn Widget>] { &[] }
    // ...
}
```

- `update(&mut self, dt: f32)` 公式に存在、default は no-op。
- Doc コメントで "Container widgets should forward to children." と明記済。

### App → root のルート呼び出し
`src/app.rs` の 3 箇所（492 / 533 / 591 行目）で毎フレーム `app.root.update(dt)` を呼ぶ。
`dt` は `Instant::duration_since(last_frame_time).as_secs_f32()`。

---

## 3. Container による forward 網羅状況

`grep -rn "\.update(dt" src/widget` から確認。

| Container | update→children forward | 備考 |
|---|---|---|
| `flex_layout.rs:208` | ✅ `for child in children { child.widget.update(dt) }` | |
| `tab_view.rs:250` | ✅ `tab.content.update(dt)` | 全 tab.content forward。Step 5 で Tween 追加時にこの経路経由で動く |
| `split_view.rs:283-284` | ✅ first/second 両方 | |
| `color_picker.rs:190-192` | ✅ r/g/b_slider 3つ | |
| `window_frame.rs:626` | ✅ child 1個 forward | |
| `overlay.rs:298-300` | ✅ base + 各 entry | |
| `layout.rs:237` | ✅ 各 child | VStack/HStack/Padding/Stack共通 |
| `style/styled.rs:303` | ✅ inner forward | StyledWidget |

**8 コンテナ全てが forward 済み**。欠落ゼロ。

### leaf widget で update を実装しているもの
```
src/widget/basic.rs:1063   Button (bg_tween + appear_tween + check_tween forward)
src/widget/switch.rs:412   Switch (tween tick + is_dirty set)
```

Phase 2-B で Dropdown / Toast / TabView / FocusRing が同パターンを追加する形になる。

---

## 4. FocusRing Step 6 に向けた具体レシピ（worker3 向け）

### パターン A: widget 内部で FocusTransition を持たせる

`FocusTransition` は既に `crate::animation` から利用可能（移設済）。

```rust
use crate::animation::FocusTransition;

pub struct SomeFocusableWidget {
    // ...
    focused: bool,
    focus_transition: FocusTransition,   // 新規フィールド
}

impl Widget for SomeFocusableWidget {
    fn update(&mut self, dt: f32) {
        if self.focus_transition.is_animating() {
            self.focus_transition.tick(dt);
            self.is_dirty = true;
        }
    }

    fn event(&mut self, event: &WidgetEvent) -> EventResponse {
        // ... focus 変化検出時:
        self.focus_transition.set_focused(self.focused);
        // ...
    }

    fn paint(&mut self, renderer: &mut Renderer, rect: ItemRect) {
        // ... widget 本体描画 ...
        let alpha_f = self.focus_transition.opacity();
        if alpha_f > 0.01 {
            let alpha = (alpha_f * 255.0) as u8;
            crate::widget::focus::draw_focus_ring_ex(
                renderer, rect, theme.border_radius, theme,
                /* offset */ 2.0, /* width */ 2.0, alpha,
            );
        }
    }
}
```

### パターン B: 全 focusable widget を一括で差し替える場合

現状 7 widget（slider / dropdown / spin_button / combo_box / switch /
navigation_list 等）が `draw_focus_ring(..., 200 alpha 固定)` を呼んでいる。
一度に置換するのは変更面が広いので、Step 6 は **試験導入（1-2 widget）**
→ 次 PR で横展開が安全。

推奨試験対象:
1. Switch — 既に tween を持っているので `update` 追加コストが最小
2. Dropdown — Step 3 で Tween を足すので同時にやれる

---

## 5. 「draw_focus_ring Renderer ヘルパー」要否

### 結論: **新規不要**

既存:
- `draw_focus_ring(renderer, rect, radius, theme)` — alpha=200 固定
- `draw_focus_ring_ex(renderer, rect, radius, theme, offset, width, alpha)` — 全パラメータ可変

`_ex` 版の `alpha: u8` が opacity animation の出力先として既に機能する。
新しい helper を足しても `(opacity * 255.0) as u8` の変換を別の場所で書くだけで、
意味のある抽象化にならない。

### 例外: もし "widget-local な FocusTransition を自動配線する" 層が欲しい場合

たとえば以下のような helper 構造体を用意して focusable widget の定型コード
を畳める可能性はある:

```rust
// 提案（実装しない、Step 6 着手時に必要性再評価）
pub struct AnimatedFocusRing {
    transition: FocusTransition,
}
impl AnimatedFocusRing {
    pub fn set_focused(&mut self, f: bool) { ... }
    pub fn tick(&mut self, dt: f32) -> bool { ... }
    pub fn paint(&self, renderer: &mut Renderer, rect: ItemRect, theme: &Theme, radius: f32) { ... }
}
```

ただし Phase 2-B のスコープ外。**Step 6 は既存 API で完結可能。**
横展開時（Phase 2-E 以降）に重複コードが目立ってきたら検討。

---

## 6. worker2/3 への連携メモ

### worker2（Step 3 Dropdown / Step 5 TabView）
- `update(dt)` のコンテナforward は TabView で確認済（`tab.content.update(dt)`）
- Dropdown が popup を別 surface として開く場合、popup 側の update 経路は **未整備**。
  現状 in-surface overlay 前提で十分。popup 化は Phase 2-C 応用作業として別PR。
- Step 3 のオープンアニメ中 `is_dirty = true` を忘れると tween が止まって見える。
  Switch の例（`src/widget/switch.rs:412-416`）をそのまま真似れば OK。

### worker3（Step 4 Toast / Step 6 FocusRing）
- Toast は既存 `ToastWidget` が `update` を持たない（`grep -c "fn update" src/widget/toast.rs` = 0）。
  Step 4 で `fn update(&mut self, dt: f32)` を追加する形が自然。
- FocusRing はパターン A で 1-2 widget 先行、残りは次PR推奨。

---

## 7. リスク（既知）

| 項目 | 影響 | 対処 |
|---|---|---|
| Widget が `update` を実装し忘れる | アニメが止まる | Switch/Button例をdoc化、Step 3/4 PR でコードレビュー時に確認 |
| `is_dirty = true` set 漏れ | 描画が追従しない | `tween.tick` と同じ関数内で必ず set、unit test で確認 |
| Container が新 child を追加したが forward 忘れ | 子の tween 停止 | 新 container 追加時のレビュー項目（現状 8 コンテナ全て forward 済なので当面ゼロ） |

---

(end of audit)
