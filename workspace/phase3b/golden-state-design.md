# Phase 3b 第3波 設計 — golden state テスト整備 (worker3)

作成: 2026-05-20 / 担当: worker3 / 状態: 設計のみ（実装なし・cargo 未起動）
狙い: AI が GUI を見られない問題を golden 画像で決定論的に解消する層（ミッション 3層モデルの (B)）。実装は user 評価後。

## 0. 結論サマリ

GUI_kit には既に **完全一致 BGRA golden framework**（`GoldenSnapshot` + `WidgetTestHarness`）があり、`golden_widgets.rs` で widget × theme を rest 状態のみ snapshot 済。これを **widget × state(rest/hover/press/focus/disabled) × theme** に拡張する。設計の要点 3 つ:

1. **決定論性の最大の敵は (a) アニメーション と (b) cosmic-text fallback の環境 drift**。対策: (a) state を event で駆動後 `update(大dt)` で tween を settle、(b) **state golden は空ラベル(text なし)で描画**し chrome ピクセルのみ比較 → cosmic-text を踏まない → 全テーマで完全一致が成立。
2. **golden は「実物 OS との自動 pixel diff」ではなく「user 承認済みの見た目を決定論的に lock する回帰防止」**。bless は user が gallery で承認した後に行う（ミッション層 C → B の橋渡し）。
3. cosmic-text を含むテキスト付き golden は **別 test target + 環境 gate** に分離（既知の work-PC fontconfig drift を決定論スイートから隔離）。

---

## 1. 既存 golden framework の調査結果

### 1-A. core: `crates/hayate-platform/src/testing/golden.rs`
- `GoldenSnapshot::new(name).check(&harness)` — harness canvas を参照画像と**完全一致**比較（`ref_pixels != pixels` でパニック、許容差なし）。
- 参照ファイル: `tests/goldens/<name>.golden`、独自バイナリ（magic "GLDN" + version + w + h + format=BGRA8 + raw pixels）。
- 再生成: 環境変数 `GOLDEN_BLESS=1`（or `true`）で現 render を参照として書き込み。
- diff サマリ: 差分ピクセル数 + 最大チャネル差（`pixel_diff_summary`）。
- 寸法不一致 / 参照欠如 / フォーマット不一致は専用パニック。
- **比較は exact のみ。許容差(tolerance)モードは未実装。**

### 1-B. harness: `crates/hayate-platform/src/testing/mod.rs`
- `WidgetTestHarness::new(widget, w, h)` → `layout()` / `paint()` / `render()`（layout+paint）。
- 入力注入: `click(x,y)` / `pointer_enter()` / `pointer_leave()` / `focus()` / `blur()` / `type_text` / `press_key` / `send_event(&WidgetEvent)`。
- `MockTimeSource`（advance/set）あり = 決定論時間。
- **重要: `render()` は animation を tick しない**。tween 前進は widget の `update(dt)`（Widget trait method）経由のみ。harness に update ラッパは無いが `widget_mut()` で `&mut dyn Widget` を取り `update(dt)` を直接呼べる。

### 1-C. 既存 golden テスト: `crates/hayate-kit/tests/golden_widgets.rs`
- カバー: Button / Label / VStack / SpinButton × win95 / win10、**いずれも `_default`(rest) のみ**。
- 構成: engine + AppTheme を inject → `render()` → `GoldenSnapshot::new("<theme>/<widget>_default").check()`。
- **state(hover/press/focus/disabled) 次元と win95/win10 以外のテーマは未カバー。**
- 既知の注記: WindowFrame golden は Window decoration Phase 2 で廃止、chrome は golden_a11y_chrome.rs 等へ移行。

### 1-D. 関連 golden 群
golden_smoke.rs / golden_systemlike_chrome.rs / golden_a11y_chrome.rs / golden_a11y_focus_scale.rs / golden_widgets.rs。`tests/goldens/` 配下に参照。

---

## 2. 決定論性の課題と対策（設計の核心）

### 2-A. アニメーション（最重要）
button の `bg_value` は `bg_tween` 補間（hover→1.0 / press→2.0、hover_duration ベース）、さらに `appear_tween`（appear_opacity 0.7→1.0）も存在。`render()` だけでは tween 未前進 → 中間値が混入し非決定的になりうる。

**対策（state 駆動シーケンス）:**
```
1. h = harness(widget, theme)            // engine + theme inject
2. h.render()                             // 初回 layout+paint で last_rect 確定(hit-test 用)
3. 状態駆動:
     focus  : h.focus()
     hover  : h.pointer_enter(); h.send_event(PointerMove{x,y in rect})
     press  : (hover後) h.send_event(PointerPress{x,y in rect, button:1})
     disabled: 構築時に ButtonWidget::new(..).disabled()
4. h.widget_mut().update(LARGE_DT)        // 全 tween を settle(bg_tween + appear_tween)
5. h.paint()                              // settle 後の確定状態を描画
6. GoldenSnapshot::new("<theme>/<widget>_<state>").check(&h)
```
- `update(dt>=duration)` で duration ベース tween は finished → **target に正確に収束**（spring easing も固定 duration なので overshoot は残らない）。LARGE_DT = 例 10.0 で十分。
- appear_tween も update で 1.0 に settle（= 完全不透明の確定見た目）。既存 rest golden は appear=0.7 で bless 済だが、state golden は settle 方針で統一（rest も settle 版を別途用意 or 既存と整合させる方針を実装時に確定）。

### 2-B. cosmic-text fallback の環境 drift（既知問題）
- bitmap font テーマ（win95 = LEGACY_JP_12/16_PROP）は整数スナップ・AA なし → **決定論的**。
- modern テーマ（win10 / xp_luna / macos 等）のラベルは `BitmapTextStyle::new()`（空）→ cosmic-text fallback → **環境(fontconfig)でグリフ AA が drift**（既知: work-PC track-golden 5 fail、home-PC 0 fail = feedback_golden_env_drift）。
- **対策（state golden に限定して根本回避）: state golden は空ラベル widget で描画する。**
  - state(hover/press/focus/disabled) の判別ピクセルは bg / border / bevel / focus ring であり、**glyph は state と無関係**。
  - `ButtonWidget::new("")`（空文字）で描けば glyph 描画ゼロ → cosmic-text を一切踏まない → **全テーマで完全一致が成立**（win10 含む）。
  - これにより state 検証は環境非依存・bitmap/cosmic 区別不要の単一決定論スイートにできる。

### 2-C. テキスト付き golden が必要な場合（state とは別軸）
ラベル字形そのものを検証したいケース（フォント回帰等）は state golden と分離:
- **Tier D1（決定論）**: bitmap font テーマ(win95)のみ。完全一致。
- **Tier D2（環境依存）**: cosmic-text テーマ。**別 test target（例 golden_text_cosmic.rs）+ 環境 gate**（例 env `HAYATE_GOLDEN_COSMIC=1` の時のみ実行、または `#[ignore]` 既定）にして、決定論スイート(CI/routine)から隔離。home-PC で bless、work-PC では skip。
- これで feedback_golden_env_drift の「env 差を bisect 前に切り分け」を構造化（drift する層を物理的に別ファイル + gate に隔離）。

### 2-D. その他の非決定要因チェックリスト
- `active_theme()`（draw_focus_ring が参照）はグローバル状態 → テストで set_active_theme を明示 or テスト間 lock（既存 ACTIVE_THEME_TEST_LOCK パターン）で固定。
- 乱数 / 時刻依存描画は button には無い（MockTime で時間も固定）。
- canvas サイズは固定指定（widget × state で同一 w×h）。

---

## 3. golden state matrix 設計

### 3-A. 次元
- **widget**: 第一弾 = Button（state が最も豊富）。続いて Checkbox / Radio / Dropdown / SpinButton / Tab / Slider 等へ拡張。
- **state**: rest / hover / pressed / focused / disabled（widget が持つ state のみ）。
- **theme**: win95 / win10（既存）+ xp_luna / macos_big_sur / macos9 / hayate_original（順次）。

命名規約（既存に倣う）: `tests/goldens/<theme>/<widget>_<state>.golden`
例: `win10/button_hover.golden` / `win95/button_pressed.golden` / `win10/button_disabled.golden`

### 3-B. テスト構造（提案: 新ファイル golden_widget_states.rs）
- 既存 `golden_widgets.rs`(rest 専用) は維持し、state 拡張は別ファイルに分離（cohesion + 既存 bless 非破壊）。
- ヘルパで matrix を回す:
```
fn render_state(widget_factory, theme, state, w, h) -> WidgetTestHarness
   // 2-A シーケンスを内包: render→drive(state)→update(LARGE_DT)→paint
```
- 各 (widget, theme, state) で `render_state` → `GoldenSnapshot::new(name).check()`。
- state golden は **空ラベル widget**（2-B）を使い全テーマ決定論化。

### 3-C. 比較方式
- **既定 = 完全一致**（既存 framework のまま）。空ラベル + tween settle で全テーマ exact 達成可能なため、当面 tolerance 不要。
- 将来テキスト付き(Tier D2)で必要なら **許容差モードを framework に追加**（`GoldenSnapshot::with_tolerance(max_channel_delta, max_diff_ratio)`）。`pixel_diff_summary` が既に差分px数 + 最大チャネル差を算出済 → これを閾値比較に流用すれば小改造で実装可。ただし tolerance は「どの程度の drift を許すか」の主観が入るため、決定論スイートは exact 維持を推奨し tolerance は隔離 target 限定。

---

## 4. 参照画像の作り方（重要な区別）

### 4-A. golden = 「user 承認済みの見た目」の回帰 lock（推奨運用）
- `GOLDEN_BLESS=1` は **GUI_kit 自身の現 render** を参照に焼く（実 OS スクショではない）。
- よって golden test は本質的に **回帰防止**（一度承認した見た目が後の変更で崩れたら検知）であり、**実物 OS との fidelity を自動判定するものではない**。
- 正しい運用フロー（ミッション 3層と整合）:
  1. state 実装（win10 disabled/focus 等、別 doc win10-behavior-research.md の改訂案）。
  2. PRESIDENT が gallery 起動 → **user が視覚承認**（層C = 人間不可分）。
  3. 承認された見た目を `GOLDEN_BLESS=1` で bless（層B = 決定論 lock 化）。
  4. 以降 routine `cargo test` が回帰を検知。意図的変更時のみ再 bless + commit。
- = **golden は「user が OK と言った state の見た目」を凍結する**。AI が見られない問題は「一度 user が見て承認→以降は pixel で機械検証」で解消。

### 4-B. 実物 OS 参照との直接 diff（任意・将来・高コスト、非推奨で注記）
- 実 OS スクショを crop → 同寸法に量子化 → expected として保存し diff する案は理論上可能だが:
  - AA / DPI スケール / サブピクセル / フォント差で**ほぼ必ず不一致**になり tolerance 必須 → 決定論が崩れる。
  - 取得・前処理コスト高、ライセンス(OS スクショ)懸念。
- → **採用しない**。fidelity 判定は 4-A の user 承認に委ね、golden は回帰 lock に徹する。この区別を doc で明示するのが本設計の肝。

---

## 5. 既存 golden_widgets との統合方針
- `golden_widgets.rs`（rest 専用、既 bless 済）は**そのまま維持**（破壊しない）。
- state 拡張は新 `golden_widget_states.rs` に置く（cohesion、bless 単位を分離）。
- 共通の `render()` ヘルパ思想（engine+theme inject）は流用しつつ、state 駆動 + update settle を足した `render_state()` を新設。
- 参照ディレクトリは同じ `tests/goldens/<theme>/` を共有（命名で衝突回避: `_default` vs `_hover` 等）。
- cosmic-text テキスト golden（Tier D2）は更に別 target + 環境 gate（§2-C）。

## 6. 実装時 TODO（user 承認後・cargo 解禁後）
1. `WidgetTestHarness` に `update(dt)` 薄ラッパ追加（任意、`widget_mut().update()` で代替可）。
2. `golden_widget_states.rs` 新設 + `render_state()` ヘルパ + Button 5 state × win95/win10 から開始。
3. 空ラベル方針で全テーマ exact 確認 → `GOLDEN_BLESS=1` で初回 bless（**ただし win10 disabled/focus は別 doc の改訂実装後に bless**、現状の欠陥を凍結しない）。
4. 必要なら framework に tolerance モード（§3-C）+ cosmic Tier D2 target を追加。
5. -j1 厳守、bless は home-PC（cosmic drift 回避）。

## 7. 制約遵守メモ
- cargo 未起動（設計 + 既存コード grep のみ）。記憶ベースなし、framework 仕様は実コード(golden.rs / testing/mod.rs / golden_widgets.rs / button.rs)から。
- 視覚最終判定は user(gallery)。golden は user 承認の凍結であり実物自動判定ではない旨を明記（§4）。
- 既知 env drift(feedback_golden_env_drift) を §2-C で構造的に隔離する方針を設計に内包。
