# Phase 2-D 事前調査 — テストカバレッジ拡充

worker1 / 2026-04-14
対象: Codex 評価 5/10 → 7/10 目標
ベースライン: feature/multiwindow-popup-validation tip (d56ce6d)

---

## 1. 現状集計（手動 grep ベース）

tarpaulin 実測は CI コストが高いため `#[test]` 数 × LOC 比で代替。
関数網羅率の近似として見る。

### クレート合計
| 指標 | 値 |
|---|---|
| `src/` LOC | 50,124 |
| `src/` 内 `#[test]` 件数 | 838 |
| `tests/` 統合テスト件数 | 71 |
| 合計 | **909 テスト** |
| 平均 LOC/テスト | ~59 |

### モジュール別（`#[test]` 密度降順）
| モジュール | テスト | コメント |
|---|---|---|
| `src/widget/` | 401 | layout 43 / grid 20 / overlay 15 が頭打ち |
| `src/platform/` | 122 | popup 22・event 系は分散 |
| `src/render/` | 72 | GPU/Vulkan 系はゼロに近い |
| `src/scroll/` | 54 | physics 11 のみ、実動きの検証薄 |
| `src/style/` | 42 | 列挙値テスト主体 |
| `src/reactive/` | 20 | state 10 + effect 10、実統合ゼロ |
| `src/animation/` | 15 | keyframe 6 + transition 9 |
| `src/accessibility/` | 5 | a11y_bridge 移行でほぼ空洞化 |

### 統合テスト内訳
| ファイル | テスト数 |
|---|---|
| tests/popup_validation.rs | 27 |
| tests/bidi_rtl_verification.rs | 25 |
| tests/csd_coord_unification.rs | 19 |

---

## 2. Codex 指摘の 3 重点領域・現状

### 2-1. CSD 統合テスト
- `tests/csd_coord_unification.rs` **19件** あり（Phase 1 で充実）
- paint/event 同一座標系、translate_stack 応用、nested push、frame reset 等
- **評価**: 既に比較的厚い。追加はエッジケース（panic復帰・複数push順序差・RTL widget との相互作用）

### 2-2. スクロール物理
- `src/scroll/physics.rs` 509 LOC / **11 tests** — 薄い
- `src/scroll/viewport.rs` 255 LOC / 7 tests
- 既存テストは定常状態のみ。momentum decay・elastic boundary・touch flick・慣性スクロール中の resize・velocity 符号反転 等が抜け
- **評価**: 最大の空白ゾーン

### 2-3. リアクティブ更新
- `src/reactive/state.rs` 417 LOC / **10 tests**
- `src/reactive/effect.rs` 432 LOC / **10 tests**
- effect chain、circular dep 検出、state drop 時の dangling observer、batch update の順序保証が未検証
- `src/reactive/mod.rs` は `#[test]` ゼロ（publicAPI 統合ゼロ）
- **評価**: ユニット有りだが結合テスト欠如

---

## 3. カバレッジ向上候補 トップ10

選定基準: (LOC / tests 比) × 影響範囲 × 検証容易性。
Wayland 実サーバー必要なものは除外。

| # | ターゲット | 現状 | 推奨追加 | 理由 |
|---|---|---|---|---|
| 1 | `src/scroll/physics.rs` | 509 LOC / 11 | **+15** | momentum decay 曲線、elastic bounce、touch flick、velocity反転、over-scroll clamp |
| 2 | `src/reactive/effect.rs` | 432 LOC / 10 | **+10** | circular dep、drop後observer、batch順序、nested effect |
| 3 | `src/reactive/state.rs` | 417 LOC / 10 | **+8** | multiple observers、subscribe中のset、state drop時の通知 |
| 4 | `src/animation/keyframe.rs` | 253 LOC / 6 | **+8** | easing境界、non-monotone time、keyframe重複、empty animation |
| 5 | `src/animation/transition.rs` | 205 LOC / 9 | **+5** | cancel中再開、併走transition、from==to、delay負値 |
| 6 | `src/scroll/viewport.rs` | 255 LOC / 7 | **+5** | resize中スクロール、content=0、scroll方向逆転 |
| 7 | `src/text/bidi_harness.rs` | 461 LOC / 10 | **+5** | ZWJ emoji実機、Hebrew + Latin 混在、複数行BiDi、caret末尾、font欠如fallback |
| 8 | `src/platform/popup.rs` | 391 LOC / 22 (tests別ファイル) | **+3** | create_popup success path（mock window）、複数popup id独立 |
| 9 | `src/widget/dropdown.rs` | 425 LOC / 11 | **+5** | keyboard nav、open+resize、空list、single item |
| 10 | `src/render/translate_stack.rs` | 176 LOC / 7 | **+3** | 過剰push防御、pop balance detection、nested reset |

**合計追加候補: +67 テスト**

達成後: 909 → 976 テスト、重点3領域はすべて倍以上に厚み。

---

## 4. ゼロテストの目立つ in-source ファイル

ユニットテストを持たない hot-path 系:

| ファイル | LOC | 備考 |
|---|---|---|
| `src/app.rs` | 939 | ルート orchestration、callback 結線 |
| `src/platform/wayland.rs` | 945 | 実サーバー依存で追加困難。Dispatch ルーティングは unit 化可能 |
| `src/render/software.rs` | (要確認) | CPU rasterise。pixel-level golden test で拡充余地大 |
| `src/render/mod.rs` | 700+ | Renderer ディスパッチ、push_translate 等は unit 化容易 |

**注意**: `src/platform/popup.rs` は 0 に見えるが tests は `popup_tests.rs` に分離済（22件）。集計で過小評価しないよう注意。同パターン: `wgpu_backend`, `sdf_glyph_cache`, `gpu`, `gpu_text`, `text`, `vk_context`, `sdf_pipeline`, `blur_pipeline`, `translate_stack`, `sdf_atlas_packer` 等。

---

## 5. 推奨着手順序

### Wave A（Wayland 不要・即着手可・高 ROI）
1. **scroll/physics** 15件（最大空白、純粋関数中心で書きやすい）
2. **reactive/effect + state** 18件（結合テスト欠如の根治）
3. **animation/keyframe + transition** 13件（easing 境界の網羅）

小計 +46。これだけで 909 → 955、密度を 3 重点で倍化。

### Wave B（統合・実証）
4. **tests/scroll_physics_integration.rs** 新規（touch flick → momentum → settle を end-to-end）
5. **tests/reactive_effect_integration.rs** 新規（signal graph cycle / drop orders）
6. **tests/animation_lifecycle.rs** 新規（widget tween 連動）

小計 +15〜20。integration 層を強化。

### Wave C（周辺薄膜）
7. dropdown / popup / translate_stack / bidi_harness の追補 +16

累計 +77〜82。

---

## 6. Phase 2-D 着手時の前提・制約メモ

### 環境
- tarpaulin 実測は PR merge 時の CI で計測（ローカルは hot-path 体感でOK）
- fontsystem 初期化はテスト毎に重い → `static Mutex<FontSystem>` 共有（bidi_harness で実績あり）
- Wayland サーバー依存は原則避け、純粋関数と state machine に集中

### Codex 評価軸の補強点
- **関数ごとの happy path + 1 error path** を最低ライン
- **state machine の遷移網羅**: Pending → Active → CloseRequested → Closed 等
- **境界値**: 0, 1, max, overflow, 負値, NaN
- **相互作用**: 複数 widget 結合、signal graph、popup + window

### Phase 1/2-A/2-C からの再利用パターン
- `bidi_harness::diagnostic_dump` スタイルの **assert メッセージ埋め込み** で失敗原因特定容易化
- `translate_stack::debug_assert(!empty)` の **不変条件ガード** を他 stack 系にも適用
- Rc<Cell> によるコールバック発火順序保証（Commit 5 pattern）

### 既知の「書けない」領域
- GPU/Vulkan フレーム描画 — ドライバ依存、実機でしか出ない
- 実 wl_surface / xdg_popup の Configure 往復 — compositor 依存
- フォント環境依存テスト — CI ランナー差。`bidi_harness` 同様 font-missing auto-skip

---

## 7. worker2/3 への連携提案

- **worker2**: Wave B の integration tests を examples と対でペアリング（scroll_demo と連動した scroll 物理観察など）
- **worker3**: ARCHITECTURE.md に「テストカバレッジ方針」節を追加、Wave A/B/C 分類をドキュメント化

Phase 2-D 着手指示が来たら Wave A の最初の 15件（scroll/physics）を 90 分以内で完了する見積り。

---

(end of survey)
