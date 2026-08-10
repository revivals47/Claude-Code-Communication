# Phase 2-C 事前調査 — マルチウィンドウ/ポップアップ

worker1 / 2026-04-14
対象コミット: `feature/bidi-rtl-verification` tip (src/ snapshot 後)
深掘り対象: worker2 `p1-next-phase-survey.md` §2-C

---

## 1. `src/platform/multi_window.rs` 責務マップ (254 LOC)

### レイヤー位置
**純粋な記帳 (bookkeeping) 層**。Wayland サーフェス生成とは完全分離。
モジュール冒頭コメントに明記: *"Actual wl_surface creation is deferred to the Wayland integration layer; this module manages IDs, configuration, and lifecycle state."*

### 型と責務
| 型 | 役割 | 外部I/Oの有無 |
|---|---|---|
| `WindowId(pub usize)` | インデックス型、HashMap キー | なし |
| `WindowConfig` | `title/width/height/resizable/decorations` の POD 設定 | なし |
| `WindowState` | `Pending/Active/CloseRequested/Closed` の4状態 | なし |
| `ManagedWindow` | `id+config+state+width+height` のエントリ | なし |
| `WindowManager` | `HashMap<WindowId, ManagedWindow>` + `next_id` | なし |

### API 表面（`WindowManager`）
```rust
new() / default()
create_window(WindowConfig) -> WindowId
activate(WindowId) / request_close(WindowId) / close_window(WindowId)
gc()                           // Closed エントリを削除
resize(WindowId, u32, u32)
get(WindowId) / get_mut(WindowId) -> Option<&ManagedWindow>
windows() -> impl Iterator
count() / active_count() / has_open_windows()
```
計 14関数、全て同期 + 純粋関数またはHashMap操作のみ。

### テスト
ユニット6件（`create_and_lookup / lifecycle / resize / multiple_windows / has_open_windows_false_when_all_closed / config_builder`）。実Wayland無しで完結。

### ギャップ
- `src/app.rs` / `examples/` で一切参照なし（grep 0件）。
- 実際の `wl_surface` / `xdg_surface` を **誰が** 生成して `ManagedWindow` と結び付けるかが未定義 → **Wayland 統合層が空白**。
- `WaylandWindow`（platform 本体）は単一ウィンドウ前提。`WindowManager` とのバインディングコードが存在しない。
- リサイズ/close は `WaylandWindow` 側コールバック経由で通知する想定だがコールバック結線未実装。

---

## 2. `src/platform/popup.rs` API 表面 (296 LOC)

### 型
```rust
pub enum Anchor { TopLeft, Top, TopRight, Left, Center, Right,
                  BottomLeft, Bottom, BottomRight }          // 9値
pub enum Gravity { 同上 }                                     // 9値
pub struct PopupConfig { x, y, width, height,
                          anchor: Anchor, gravity: Gravity,
                          anchor_rect: (i32, i32, i32, i32) }
pub struct PopupWindow { surface, xdg_surface, popup,
                          width, height, dismissed: bool }
```

### `PopupConfig` コンストラクタ
| 関数 | Anchor | Gravity | 用途 |
|---|---|---|---|
| `at(x,y,w,h)` | TopLeft | BottomRight | 任意位置 |
| `tooltip(x,y)` | BottomLeft | BottomRight | カーソル下 tooltip |
| `dropdown(rect..., w, h)` | BottomLeft | BottomRight | アンカー矩形下 |
| `context_menu(x,y,w,h)` | Center | BottomRight | 右クリック位置 |

### `PopupWindow`
```rust
create(compositor, wm_base, parent_xdg_surface, &PopupConfig, &QueueHandle) -> Self
surface() -> &wl_surface::WlSurface
is_closed() -> bool
size() -> (i32, i32)
close()                  // popup/xdg_surface/surface を destroy
```

### Constraint Adjustment
`create` 内で一律 `SlideX|SlideY|FlipX|FlipY` をハードコード。`ResizeX/Y` は未使用。
→ **Constraint の組合せ軸が 1パターン固定**。PopupConfig から選べない。

### Dispatch
- `xdg_popup::Event::Configure` → no-op（`x/y/width/height` 全て `_` で捨てている）
- `xdg_popup::Event::PopupDone` → no-op（**dismissed フラグを立てていない**）
- `xdg_positioner` → no-op（positioner は stateless なのでOK）

### ギャップ（重大）
1. **`PopupDone` で `self.dismissed = true` していない** → `is_closed()` が compositor 通知を反映しない。現状 `close()` を明示呼び出ししない限り永久に false。
2. **`Configure` の `x/y/width/height` を保持していない** → compositor 側でリポジショニング/リサイズされても `PopupWindow.width/height` が更新されない。
3. **parent 側で `xdg_wm_base.pong` やポジショニング再計算を行うフック無し**。
4. widget 層で `PopupWindow` を使っているものは**ゼロ**。

### テスト
5件（`popup_config_at / popup_config_dropdown / anchor_to_xdg / popup_config_tooltip / popup_config_context_menu`）、**全て PopupConfig 構築の静的確認のみ**。Wayland を一切叩かない。

---

## 3. `xdg_positioner` 16+α 組合せ 未検証リスト

### Anchor × Gravity のマトリクス
Anchor 9値 × Gravity 9値 = **81 組合せ** が原理的に可能。
（task instructions の "16 組合せ" は 4×4 = 主要な anchor/gravity を指すと解釈）

#### 4×4 主要マトリクス（画面端クリッピング検証対象）
```
         │ Grav TL │ Grav TR │ Grav BL │ Grav BR │
─────────┼─────────┼─────────┼─────────┼─────────┤
Anc TL   │    ?    │    ?    │    ?    │    ?    │
Anc TR   │    ?    │    ?    │    ?    │    ?    │
Anc BL   │    ?    │    ?    │ ✓static │    ?    │  ← PopupConfig::dropdown等
Anc BR   │    ?    │    ?    │    ?    │    ?    │
```
`?` = 実機検証実施形跡なし（grep でテストファイルゼロ、examples もゼロ）。
`✓static` = `popup_config_dropdown` で PopupConfig のフィールド比較のみ。

### Constraint Adjustment 8組合せ
```
SlideX  SlideY  FlipX  FlipY  ResizeX  ResizeY
```
- 現状 `SlideX|SlideY|FlipX|FlipY` 固定 → **5/8 は1パターンのみ検証**
- `ResizeX/Y` 系は一切使用されておらず、サポート可否が不明
- compositor（Mutter / KWin / sway / Hyprland）毎の `Flip` 実装差は未確認

### 画面端 edge case
- 右端 anchor → popup が FlipX でウィンドウ左に回り込む挙動
- 下端 anchor → FlipY で上に反転
- anchor_rect が親 surface 外座標（CSD header 上など）だった場合の compositor 挙動
- 複数ディスプレイ跨ぎ（primary 1x + external 2x）時の座標系
- これら全て **実機テスト無し**。

---

## 4. Phase 1 `translate_stack` の popup 座標系への応用可能性

### 現状の座標系（popup 周辺）
- `xdg_positioner.set_anchor_rect(x, y, w, h)` の `(x, y)` は **parent surface のローカル座標**
- CSD を有効にした場合、parent の widget は `translate_stack::push_translate(0, csd_h)` 下で描画される
- しかし popup を開くコード（存在しない）は `anchor_rect` を widget-local で渡したいはずだが、xdg_positioner 側は surface-absolute を期待

### 具体的な応用箇所
**箇所 A**: widget が popup を開く API（未実装）
```rust
// 想定: ContextMenuWidget::on_right_click(pos_in_widget: (f32, f32))
// widget-local 座標 → surface 座標へ変換が必要
let (surface_x, surface_y) = translate_stack::transform_point(pos_in_widget.0, pos_in_widget.1);
let config = PopupConfig::context_menu(surface_x as i32, surface_y as i32, w, h);
```
→ `translate_stack::transform_point` を呼ぶだけで CSD オフセット吸収完了。

**箇所 B**: dropdown が list_rect を popup に渡す場合（現状は in-surface overlay）
```rust
// src/widget/dropdown.rs:235 の list_rect は widget-local
let anchor_rect = translate_stack::transform_rect(header_rect);
let config = PopupConfig::dropdown(
    anchor_rect.x as i32, anchor_rect.y as i32,
    anchor_rect.width as i32, anchor_rect.height as i32,
    list_w as i32, list_h as i32,
);
```

**箇所 C**: popup 内部の描画
- popup は**別 surface** なので内部は原点 (0, 0) からリセット
- 既存 `translate_stack` を popup 描画コンテキストで `reset()` してから使う
- `Renderer` インスタンスを popup 用に独立作成する設計になれば自然に分離

### 注意点
- popup 自体の `xdg_surface` は parent とは別の local origin を持つ → **translate_stack は per-surface**
- 現在 thread_local Vec なので surface ごとの切替は reset + push の責務を呼び出し側が管理
- Phase 2-C 着手時は `translate_stack::scoped_push()` 的な RAII ガードを検討する価値あり

### 応用度評価
- **箇所 A (widget→popup 変換): 即座に有効**。1行変更で CSD 対応完成
- **箇所 B (dropdown 統合): 有効**、ただし popup 化自体が別課題
- **箇所 C (popup 内部描画): 構造次第**。reset+push の規律で対応可能

---

## 5. `dropdown_demo` での popup 使用有無

### 結論: **使用していない**

- `examples/dropdown_demo.rs` は `DropdownWidget` を単に `VStack` に追加するのみ
- `src/widget/dropdown.rs:235` の `list_rect` は widget 自身の `rect` 内に描画される **in-surface overlay**
- grep で `popup|Popup|xdg_popup` は `dropdown.rs` / `dropdown_demo.rs` に 0件

### 同様に in-surface 実装の widget 群
| widget | popup 実装 | 備考 |
|---|---|---|
| `dropdown.rs` | ❌ in-surface | list_rect を親内に描画 |
| `context_menu.rs` | ❌ in-surface | コメントで "Popup" と書いてあるが実装は overlay |
| `combo_box.rs` | ❌ in-surface | dropdown ベース |
| `menu_bar.rs` | ❌ in-surface | |
| `color_picker.rs` | ❌ in-surface | |
| `alert_dialog.rs` | ❌ in-surface | Modal overlay |
| `tooltip` (widget無し) | ❌ | 実装なし |

### インパクト
- `src/platform/popup.rs` は **完全に孤立した scaffolding**
- Phase 2-C は「既存 popup を検証」ではなく「まず接続する」フェーズになる
- 2-B のアニメーション統合（dropdown open/close フェード）と強く連動

---

## 6. `examples/` 追加必要性の判定

### 判定: **最小 4本を推奨**（いずれも 50-120 LOC想定）

#### 6.1 `examples/multi_window_smoke.rs` — L1
**目的**: `WindowManager` + 2つの `WaylandWindow` 実接続の最初の1歩
**内容**: メイン 800x600 + セカンダリ 400x300 の二枚を立て、片方をクローズして gc() で消える事を確認
**ブロッカー**: `WaylandWindow` を `WindowManager` と結合するコード（platform 層に未実装）
**見積**: 1日（Wayland 結合実装 + example）

#### 6.2 `examples/popup_anchor_matrix.rs` — L2
**目的**: 4×4 anchor×gravity マトリクスを 1画面で可視化
**内容**: 中央にボタン、押すと選択した (anchor, gravity) で popup を開く。画面端近くに配置して Flip/Slide 発火確認
**ブロッカー**: 
- `PopupConfig` に `anchor`/`gravity` を直接受ける公開コンストラクタ無し → `PopupConfig { anchor, gravity, ...}` を `pub` struct なので直接構築可能
- PopupDone の dismissed フラグ未更新バグがある状態では "閉じてもcloseしない" 誤動作
**見積**: 0.5日（popup.rs Configure/PopupDone 修正込み）

#### 6.3 `examples/popup_constraint_matrix.rs` — L3
**目的**: 8 constraint adjustment の個別確認
**内容**: `SlideX`, `SlideY`, `FlipX`, `FlipY`, `ResizeX`, `ResizeY`, なし, 全部入り の 8ボタン
**ブロッカー**: `PopupConfig` に constraint フィールド追加必須（現状ハードコード）
**見積**: 0.5日

#### 6.4 `examples/dropdown_popup_migration.rs` — L4
**目的**: 既存 in-surface dropdown を xdg_popup 版に差し替えた PoC
**内容**: `DropdownWidget` を `PopupDropdownWidget`（新規）にリプレイス、translate_stack で座標変換
**ブロッカー**: `PopupWindow` を widget 描画サイクルに組み込むアーキテクチャ確定が先
**見積**: 2日

### 追加せず議論で済ませる項目
- DPI mixed 検証（compositor 設定変更が必要、CI 化困難）
- 複数ディスプレイ跨ぎ（同上）
→ 実機マニュアル検証チェックリストで代替

---

## 7. サマリと着手順序提案

### 発見された主要ブロッカー（優先度順）
1. 🔴 `PopupWindow::Dispatch` が `PopupDone` を無視 → **修正必須**（数行）
2. 🔴 `PopupWindow::Dispatch` が `Configure` の `width/height` を保持しない → **修正必須**（数行）
3. 🟡 `PopupConfig` constraint が固定 → **API 拡張必要**
4. 🟡 `WindowManager` と `WaylandWindow` の結合コード不在 → **統合層実装必要**
5. 🟡 widget 層が in-surface overlay なので popup 統合は別設計が必要（Phase 2-B と連動）

### Phase 2-C 着手順序（提案）
```
1. popup.rs の Dispatch 修正 (PopupDone / Configure)          [30分, 独立]
2. PopupConfig に constraint: ConstraintAdjustment 追加       [30分, 独立]
3. examples/popup_anchor_matrix.rs                            [0.5日, 1+2依存]
4. examples/popup_constraint_matrix.rs                        [0.5日, 2依存]
5. WaylandWindow <-> WindowManager 結合                       [1日, 独立]
6. examples/multi_window_smoke.rs                             [5に続く]
7. Phase 2-B と連動して examples/dropdown_popup_migration    [2-B 方針決定後]
```

### Phase 1 知見の活用
- `translate_stack::transform_point` は widget→surface 座標変換で即利用可
- `debug_assert(!empty)` パターンは popup の `push/close` 対称性確認に応用
- `analyze + diagnostic_dump` パターン（bidi_harness）を popup dispatch のトレース実装にも応用可能

### 独立着手可能なタスク（待機中に手を付けられる）
- popup.rs Dispatch 修正 2件 + テスト（`PopupDone` でフラグ立つユニットテストはWayland mock必要→要検討）
- `PopupConfig` コンストラクタに `with_constraint(ConstraintAdjustment)` builder 追加
- worker2 の 2-A bidi_smoke 拡張完了 / worker3 の統合テスト完了を待つ間、これらの前倒し可

---

## 8. worker3 への引き継ぎ事項（ARCHITECTURE.md 追記案）

> ### Popups (Phase 2-C, deferred)
>
> `src/platform/popup.rs` provides `PopupWindow` over `xdg_popup`. As of
> 2026-04-14 no widget uses it — dropdowns, combo boxes, context menus and
> alert dialogs all render as in-surface overlays. Porting them to
> real `xdg_popup` surfaces is Phase 2-C work and will require:
> 1. Fixing `Dispatch<xdg_popup>` to honour `Configure` / `PopupDone`.
> 2. Exposing `ConstraintAdjustment` through `PopupConfig`.
> 3. Coordinate translation through `translate_stack` — the popup's
>    anchor_rect is parent-surface-local, so widget-local clicks need
>    `transform_point` before being passed to `xdg_positioner`.

---

(end of survey)
