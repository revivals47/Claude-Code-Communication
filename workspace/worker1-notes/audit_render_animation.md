# Codex 再 audit — render / animation (Phase 2-E Step 1)

worker1 / 2026-04-14
対象: `feature/codex-audit-2026-04-14` tip (origin/main = 163b490)
スコープ: `src/render/translate_stack.rs` / `src/animation/` / widget 統合 (Switch / Dropdown / Toast / TabView / Button / Checkbox)
スコープ外: logic 変更 (audit のみ)

テストベースライン: `cargo test --lib` → 820 passed (retained)

Phase 2 前 Codex 評価 5/10 との差分で語る。P1 を優先順位、件名、file:line、根拠、提案 (Phase 2-E Step 2 候補として) の順に並べる。

---

## P1 (critical) — 3件

### P1-1. `ToastWidget::tick` が Widget trait 経由で呼ばれない → トースト動かない

**File**: `src/widget/toast.rs:106`

```rust
// ToastWidget 内にだけ存在する独立メソッド
pub fn tick(&mut self, dt: f32) { ... }
```

対して `impl Widget for ToastWidget` (src/widget/toast.rs:137-176) に
`fn update(&mut self, dt: f32)` が **無い**。`App::root.update(dt)` は
コンテナ forward で Widget trait の `update` を呼ぶため、toast の `tick`
は発火しない。

根拠:
- `grep -rn 'toast\.tick\|Toast.*tick' src/ examples/` 結果ゼロ (test 以外)
- `grep -rn 'ToastWidget' examples/` 結果ゼロ → 本番でまだ使われていない
  のでバグが顕在化していないだけ。最初にトーストを使うアプリが書かれた
  瞬間にアニメ停止

**影響**: appear (spring_bouncy) も dismiss も動かず、トースト相当物
を使うアプリでアニメ静止＋フェード無し。ARCHITECTURE.md の Animation
節「Widget integration status 表」が Toast を ✅ としているが実態と
食い違い。

**提案 (Step 2)**:
```rust
impl Widget for ToastWidget {
    fn update(&mut self, dt: f32) { self.tick(dt); }
    fn dirty(&self) -> bool {
        !self.toasts.is_empty()   // 意味的等価だが dirty 基準を
                                   // "アニメ中" に狭めるならさらに良い
    }
    // ...
}
```
`pub fn tick` を消して `update` 一本化するか、public API として残すなら
`#[doc(alias = "update")]` で役割を明示。

### P1-2. `Button::clear_dirty` がハードコード `0.016` で tween を tick → frame-rate 依存

**File**: `src/widget/basic.rs:480-488`

```rust
fn clear_dirty(&mut self) {
    if !self.bg_tween.is_finished() {
        self.bg_value = self.bg_tween.tick(0.016);   // <-- 固定 dt
    }
    if let Some(ref mut t) = self.appear_tween {
        self.appear_opacity = t.tick(0.016);         // <-- 固定 dt
        if t.is_finished() { self.appear_tween = None; }
    }
    self.is_dirty = false;
}
```

さらに `impl Widget for ButtonWidget` には `fn update(&mut self, dt)`
が無い (`grep -c "fn update" awk /ButtonWidget/,/CheckboxWidget/` → 0)。
ARCHITECTURE.md Animation 節の「canonical pattern = update(dt) で
tween.tick(dt)」に正面から違反。

**影響**:
- vsync off / 120 Hz / フレームドロップで bg / appear の進行速度が狂う
- clear_dirty は paint **後** に呼ばれるので値は 1 フレーム遅れ
  (paint 時点の bg_value は前フレームの値)
- 他 widget (Switch / Dropdown / Checkbox / TabView) と pattern 不一致

**提案 (Step 2)**: clear_dirty から tick を剥がし `fn update(&mut self, dt: f32)`
に移設。Checkbox の実装 (src/widget/basic.rs:1063-1068) がそのまま雛形。

### P1-3. `paint_with_csd` の push/pop が panic-safe ではない

**File**: `src/app.rs:125-127`

```rust
renderer.push_translate(0.0, csd_h);
self.root.paint(renderer, root_rect);   // panic すると pop 行かない
renderer.pop_translate();
```

ARCHITECTURE.md Coordinate System 節は「push/pop は線形フロー (early
return / `?` なし) なので pop 忘れリスクはない」と書いているが、child
widget の paint が panic した場合カバーされない。フレーム callback 側は
panic を catch せずそのまま reset_cpu_stacks も走らない場合がある
(GPU/Vulkan 経路)。

加えて `reset_cpu_stacks()` は **CPU フォールバック経路だけ** で呼ばれる
(`src/app.rs:610`)。GPU/Vulkan 経路 (line 503 / 548) では呼ばれないため、
前フレームで push が漏れた状態が次フレームへ引き継がれる。

**影響**: release では `debug_assert!` が無音、深い stack の取りこぼし
が発生しても検知できない。デバッグで見つけても再現条件が限定的。

**提案 (Step 2)**:
1. `push_translate` を RAII ガードにする: `let _g = renderer.push_translate_scoped(0.0, csd_h);`
   ガード drop で pop、paint panic を unwind しても復旧
2. 全 paint 経路 (CPU / GPU / Vulkan) 直前で `reset_cpu_stacks()` を呼ぶ
   共通関数を `paint_with_csd` の冒頭に噛ませる。現状 CPU 経路だけなのは
   歴史的理由で本来全経路で必要

---

## P2 (improvement) — 4件

### P2-1. `Tween::from_velocity` が `Easing::spring()` を呼ばずマジックナンバー直書き

**File**: `src/animation/mod.rs:169-175`

```rust
pub fn from_velocity(start: f32, end: f32, velocity: f32) -> Self {
    ...
    Self::new(start, end, duration)
        .with_easing(Easing::Spring { damping: 5.0, stiffness: 4.0 })   // <-- 重複
}
```

`Easing::spring()` が存在し同じ値を返すのに直書きしているため、
`spring()` のパラメータを動かすと from_velocity が取り残される。Spring
preset の「default 凍結契約」ユニットテスト (spring_preset_defaults_preserve_original_params)
は from_velocity 側を保証していない。

**提案**: `.with_easing(Easing::spring())` に置換。1 行。

### P2-2. Pre-prime の tick 引数が `0.01` と `1.0` で不統一

**File**:
- `src/widget/switch.rs:76` → `ft.tick(1.0);`
- `src/widget/switch.rs:64` → `t.tick(0.01);` (main tween)
- `src/widget/basic.rs:561,562` → `Tween::new(1.0, 1.0, 0.001); bg_tween.tick(0.01);`
- `src/widget/dropdown.rs:119,131` → `tick(1.0)` 両方
- `src/widget/tab_view.rs:349` → `finished_tween` ヘルパーで `tick(1.0)`

バグではない (duration 0.001 なのでどちらも finish する) が、意図が読み
取りにくい。`tick(1.0)` のほうが「any dt beyond duration で確定終了」
の意図が明瞭。

**提案**:
1. `Tween::prime_finished()` ヘルパーを動画 API に追加: `Self::new(...).prime_finished()`
   内部で `tick(self.duration)` する
2. 既存 `tick(0.01)` / `tick(1.0)` を全て置換
3. ARCHITECTURE.md Animation 節のコードサンプルも合わせて更新

### P2-3. `FocusTransition::new()` が初期 is_animating() == true

**File**: `src/animation/mod.rs:324-326`

```rust
pub fn new() -> Self {
    Self { tween: Tween::new(0.0, 0.0, 0.1), focused: false }
}
```

`Tween::new` は `finished = false` で始まるため、construction 直後に
`is_animating()` が true を返す → widget dirty ラッチ false positive
→ 全 focusable widget が 100 ms 間 false-dirty する。回避に
`ft.tick(1.0);` を毎箇所で書かせているのが現行 (dropdown/switch)。

**提案**: `FocusTransition::new()` 内で自ら pre-prime する:
```rust
pub fn new() -> Self {
    let mut tween = Tween::new(0.0, 0.0, 0.1);
    tween.tick(tween.duration);   // start in finished state
    Self { tween, focused: false }
}
```
呼び出し側 (src/widget/switch.rs:75-77, src/widget/dropdown.rs:118-120)
の `ft.tick(1.0)` 数行を削除できる。Phase 2-E で
`AnimatedFocusRing` に折り畳む前の最小改善として有効。

### P2-4. `AnimationGroup` の実装が `Vec<(String, Tween)>` で O(n)、ARCHITECTURE.md は「HashMap」と記述

**File**:
- 実装: `src/animation/mod.rs:224` → `tweens: Vec<(String, Tween)>`
- doc: `ARCHITECTURE.md` Animation 節
  `AnimationGroup    HashMap<&str, Tween> for orchestrating named channels`

実測上 5〜10 tween で O(n) は問題ないが、docstring とコードが矛盾。
呼び出し側 (現状 tree 内ゼロ) が将来 100 tween 投げたときに surprise が
起きる。

**提案**: いずれか
- A: 実装を `HashMap<String, Tween>` に置換 (String を 2 コピーする
  `add` はそのまま)。`tick(&mut self, dt)` の iterate 順が非決定に
  なるが、artistic order は既に入力順保証していない
- B: doc を `Vec<(String, Tween)>` に直す (実装踏襲)
- 優先度低い、Phase 2-E では B を即コミット + 実装置換は後回しでも可

---

## P3 (nice-to-have) — 4件

### P3-1. `Tween` pub フィールドが `duration.max(0.001)` 防壁をバイパス可

**File**: `src/animation/mod.rs:97-105`

`Tween::new` で `duration = duration.max(0.001)` するが、同じ field は
pub なので `t.duration = 0.0` で後から上書き可能 → value() で
`elapsed / 0.0 = NaN` → Easing::apply(NaN) → clamp が NaN を返す。

**提案**: duration を `pub(crate) set_duration()` 経由に降格、または
`#[cfg(test)]` で代入元がないことを assert するテスト追加。

### P3-2. `translate_stack::reset()` は thread_local 全消去。フレーム境界以外から呼ぶと危険

**File**: `src/render/translate_stack.rs:65-67` + `src/platform/popup_tests.rs:127,136`

```rust
pub fn reset() { STACK.with(|s| s.borrow_mut().clear()); }
```

ユニットテストが `reset()` を呼んでいる (正当)。doc コメントが
"Call at the start of each frame" と書いてあるが enforce なし。
将来 popup の中間 renderer が保持する stack を誤って触ると悪夢。

**提案**: `reset()` を `pub(crate)` に降格 + `#[doc(hidden)]`。
テストは `push/pop` の対称呼び出しで代替可。

### P3-3. `Easing::Spring` の `apply(t)` が NaN/負値入力で clamp 後 cos 計算で OK だが明示なし

**File**: `src/animation/mod.rs:67-91`

`t.clamp(0.0, 1.0)` は NaN を「other operand」として返す仕様 (`f32::clamp`
は両端のいずれかに折る、NaN 入力では NaN を返す)。apply(NaN) の結果は
現状 NaN。Spring 分岐だと `(- NaN * PI).exp() * (NaN * PI).cos() = NaN`
→ `1.0 - NaN = NaN`。下流が NaN を受けたときの挙動は保護されていない。

**提案**: apply の冒頭で `if !t.is_finite() { return 0.0; }` を
追加。1 行。ユニットテスト 1 件で挙動契約化。

### P3-4. Widget::dirty() の基準が widget 間で不統一

- Button: `is_dirty || !bg_tween.is_finished() || appear_tween.is_some_and(|t| !t.is_finished())`
- Switch: `is_dirty || !tween.is_finished() || focus_ring.is_animating()`
- Dropdown: `is_dirty || !open_tween.is_finished() || focus_ring.is_animating()`
- Checkbox: `is_dirty` のみ (tween は update 内で is_dirty=true を毎フレーム
  立てる → 実質等価だが遅延 1 フレーム)
- Toast: `has_visible()` (tween 状態を見ない → 停止中も dirty 永続)
- TabView: `is_dirty || indicator_x/w tween 未完 || child.dirty()`

**影響**: メンタルモデル統一してない。P1-1 で Toast を update(dt) 化
するタイミングで「dirty() の canonical formula = `is_dirty ||
any_tween_unfinished || any_focus_ring_animating`」に揃えると
ARCHITECTURE.md と整合。

**提案**: ヘルパー trait `trait AnimatedWidget { fn is_any_tween_live(&self) -> bool }`
または `WidgetDirty` 構造体で集約。Phase 2-E の
`AnimatedFocusRing` 横展開と同時期に着手するのが経済的。

---

## Positive / Phase 2 以前との差分

以下は Phase 前評価 5/10 時点には無かった / 悪かった要素。Codex スコアが
7/10 に上がる根拠となる点:

- ✅ `translate_stack` が自己完結 176 行・7 テスト (CSD 往復含む) で
  Phase 1 の約束通り。`push_translate` / `pop_translate` / `current`
  / `transform_point` / `transform_rect` / `reset` / `depth` の 7 関数
  に絞った surface area
- ✅ Spring preset 4 種 (default / subtle / bouncy / gentle) が
  doc-driven で duration band 込みで提示、preset の parameter 値が
  `spring_preset_defaults_preserve_original_params` ユニットテストで
  凍結契約化
- ✅ Widget update(dt) の canonical pattern が Switch / Dropdown /
  TabView / Checkbox で一貫 (P1-1/P1-2 を除く)
- ✅ Toast の catch-up (retroactive dismiss seed) パターンが `tick(past)`
  で正確に elapsed を埋める (tick logic 自体は正しい)
- ✅ `animation_tests.rs` に test 分離、mod.rs を 350 行以下に抑える
  1-ファイル-500-行規約 compliance
- ✅ `crate::animation` 単一 home、旧 `crate::style::animation` と
  `crate::animation::{keyframe,transition}` の二重実装が解消

---

## Step 2 タスク候補 (優先度順)

| # | Task | 根拠 | 工数 |
|---|---|---|---|
| 1 | Toast に Widget::update(dt) を追加 | P1-1 | 20 分 |
| 2 | Button::clear_dirty の tick を update(dt) に移設 | P1-2 | 30 分 |
| 3 | paint_with_csd を RAII ガード化 + 全 paint 経路で reset_cpu_stacks | P1-3 | 45 分 |
| 4 | FocusTransition::new() を pre-primed に変更 + 呼び出し側 tick(1.0) 削除 | P2-3 | 20 分 |
| 5 | Tween::from_velocity → Easing::spring() 呼び出しに | P2-1 | 5 分 |
| 6 | Tween::prime_finished() ヘルパー追加 + 既存 tick(0.01)/(1.0) 置換 | P2-2 | 30 分 |
| 7 | ARCHITECTURE.md AnimationGroup doc 実装と整合 | P2-4 | 5 分 |
| 8 | AnimatedFocusRing 横展開 (Slider / SpinButton / ComboBox / NavigationList) | Phase 2-B 残件 | 2 時間 |
| 9 | Widget::dirty canonical formula ヘルパー | P3-4 | 1 時間 |
| 10 | Tween pub field 降格 / NaN ガード / translate_stack::reset visibility 整理 | P3-1/2/3 | 30 分 |

合計 ~6 時間分。並列化可。worker2 / worker3 が別領域の P1 を潰しに
行くのと独立に進められる。

---

## Codex 評価ベクトル

Phase 前 5/10 → Phase 2-E Step 1 完了時点の自己評価 **7/10** 相当。

| 軸 | 前 | 現 | 根拠 |
|---|---|---|---|
| 設計健全性 | 4/10 | 8/10 | translate_stack 集約、Animation 一本化、pattern 文書化 |
| バグ精査 | 5/10 | 7/10 | P1 3件残存だが test 820 passed、境界は網羅 |
| API 一貫性 | 5/10 | 7/10 | Spring preset 命名、Widget update pattern |
| 罠の回避 | 5/10 | 7/10 | Toast catch-up / pre-prime / dual dirty 文書化済 |

P1 3 件すべて潰すと 8/10 視野。Phase 2-B 横展開 (task #8) 完了で
9/10 に届く見込み。

---

(end of audit)
