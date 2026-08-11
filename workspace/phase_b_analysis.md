# Phase B タスク（3-10）調査レポート

**調査日**: 2026-03-28
**調査者**: worker3
**対象リポジトリ**: hayate-linux-fileview
**hayate-ui パス**: `../GUI_kit`

---

## ファイル行数一覧（500行制限チェック）

| ファイル | 行数 | 状態 |
|----------|------|------|
| file_list.rs | 470 | ⚠️ 残り30行 — 追加はほぼ不可 |
| keybindings.rs | 289 | ✅ 余裕あり |
| main.rs | 47 | ✅ 余裕あり |
| file_ops.rs | 323 | ✅ 余裕あり |
| three_pane.rs | 304 | ✅ 余裕あり |
| breadcrumb.rs | 164 | ✅ 余裕あり |
| state.rs | 225 | ✅ 余裕あり |

---

## タスク3: DoubleClick統合

### 変更対象
- **file_list.rs L392-413**: 自前300msタイマーによるダブルクリック判定

### 現状コード
```rust
let is_double = match (self.last_click_time, self.last_click_idx) {
    (Some(t), Some(prev)) => prev == idx && t.elapsed().as_millis() < 300,
    _ => false,
};
self.last_click_time = Some(Instant::now());
self.last_click_idx = Some(idx);
```

### hayate-ui API（確認済み）
- `WidgetEvent::DoubleClick { x, y, button, modifiers }` — **存在する** (widget/core.rs L108)
- App側で300ms/5pxの判定を実施し、DoubleClickイベントとして配信 (app.rs L244)

### 移行方法
1. `WidgetEvent::PointerPress`内のL392-413のダブルクリック判定を**削除**
2. 新たに`WidgetEvent::DoubleClick`のmatchアームを追加
3. `last_click_time`, `last_click_idx`フィールドを`FileListWidget`から**削除**

### 推定工数: **小**（差し替えのみ）
### 依存関係: なし
### 並行作業: ✅ 可能

---

## タスク4: quit_flag統合

### 変更対象
- **keybindings.rs L15-21**: `std::process::exit(0)`

### 現状コード
```rust
if ke.modifiers.ctrl && ke.keysym == Keysym::q {
    let cfg = crate::config::Config::from_state(&w.state.borrow());
    cfg.save();
    std::process::exit(0);
}
```

### hayate-ui API（確認済み）
- `App::quit_flag() -> Rc<Cell<bool>>` — **存在する** (app.rs L125-126)
- `Cell::set(true)`でウィンドウが閉じる（wayland.rs L217で毎フレームチェック）

### 移行方法
1. `main.rs`で`app.quit_flag()`を取得し、`FileListWidget`（またはstate）に渡す
2. `keybindings.rs L20`の`std::process::exit(0)`を`quit_flag.set(true)`に変更
3. `main.rs`のApp構築を変更（`App::new()`後に`quit_flag()`取得→root widgetに注入）

### 課題
- 現在`main.rs`は`App::new().run(root)`の一行で完結しており、`quit_flag`をwidgetに渡すには`App`構築とwidget構築の間にフックが必要
- `App::new()`→`quit_flag()`取得→widget構築→`app.run(root)`の順に変更する必要あり

### 推定工数: **小〜中**（配管変更が必要）
### 依存関係: なし
### 並行作業: ✅ 可能

---

## タスク5: 動的タイトル統合

### 変更対象
- **main.rs L43-44**: 固定タイトル

### 現状コード
```rust
let title = format!("Hayate — {}", path.display());
if let Err(e) = App::new(title, cfg.window_width, cfg.window_height).run(root) {
```

### hayate-ui API（確認済み）
- `App::title_buffer() -> Rc<RefCell<Option<String>>>` — **存在する** (app.rs L130-131)
- `Some(new_title)`を書き込むとWaylandフレームループで自動反映 (wayland.rs L222-228)

### 移行方法
1. `main.rs`で`app.title_buffer()`を取得し、stateに渡す
2. `state.rs`のディレクトリ遷移時（`navigate()`等）に`title_buffer.replace(Some(new_title))`を呼ぶ
3. タスク4と同じ配管変更（App構築→共有オブジェクト取得→widget注入）

### 推定工数: **小〜中**
### 依存関係: タスク4と同じ配管変更を共有（同時実装が効率的）
### 並行作業: ✅ タスク4と**一緒に**実装推奨

---

## タスク6: FileDrop統合

### 変更対象
- **file_list.rs**: `WidgetEvent::FileDrop`のハンドラ追加（新規）

### hayate-ui API（確認済み）
- `WidgetEvent::FileDrop { uris: Vec<String>, x, y }` — **存在する** (widget/core.rs L121)
- Wayland DnD → WindowEvent::FileDrop → WidgetEvent::FileDrop のパイプライン完備 (wayland.rs L245, app.rs L301-302)

### file_ops API（確認済み）
- `file_ops::parse_uri_list(data: &str) -> Vec<PathBuf>` — URI解析済み
- `file_ops::copy_to(src: &Path, dest_dir: &Path) -> io::Result<PathBuf>` — コピー実装済み
- `file_ops::move_to(src: &Path, dest_dir: &Path) -> io::Result<PathBuf>` — 移動実装済み

### 移行方法
1. `file_list.rs`のevent()に`WidgetEvent::FileDrop`のmatchアームを追加
2. `uris`を`parse_uri_list`でPathBufに変換
3. 各パスに対して`copy_to(src, current_path)`を実行
4. state.refresh() + refresh_viewport()

### 注意: file_list.rsは470行で500行制限ギリギリ
- FileDropハンドラ追加で約15-20行増加 → **超過する**
- **対策**: タスク3でダブルクリック判定コード（約15行）を削除するため、先にタスク3を完了させれば収まる

### 推定工数: **小**
### 依存関係: タスク3の完了後が望ましい（行数制限）
### 並行作業: ⚠️ タスク3完了後に実施

---

## タスク7: システムクリップボード統合

### 変更対象
- **file_list.rs L51**: `pub(crate) clipboard: Vec<PathBuf>` — 内部バッファ
- **keybindings.rs L158-188**: Ctrl+C/V の処理

### 現状コード
```rust
// Ctrl+C: ファイルパスをVec<PathBuf>に格納（内部のみ）
w.clipboard = paths;

// Ctrl+V: 内部バッファから読み出してcopy_to
for src in &w.clipboard { ... }
```

### hayate-ui API（確認済み）
- `App::clipboard_copy_buffer() -> Rc<RefCell<Option<String>>>` — **存在する** (app.rs L140-142)
- Wayland clipboard連携済み (wayland.rs L229, platform/clipboard.rs)
- **注意**: このAPIは`String`（テキスト）のみ対応。ファイルパスリストはURI形式で格納する必要あり

### 移行方法
1. Ctrl+C: パスリストを`text/uri-list`形式の文字列に変換し`clipboard_copy_buffer`に書き込む
2. Ctrl+V: `clipboard_copy_buffer`から読み出し→`parse_uri_list`でPathBufに変換→`copy_to`
3. これにより、外部ファイルマネージャとのクリップボード共有が可能に

### 課題
- **フェーズA-2（clipboard paste）との関係**: hayate-uiの`clipboard_copy_buffer`は「送信」（copy to clipboard）のみ。**受信**（paste from clipboard）はWaylandのdata_offer経由で別APIが必要
- 現時点でhayate-uiに`clipboard_paste_buffer`（受信用）が存在するか要確認
- → **確認結果**: wayland.rsにclipboard_copy_bufferのみ。paste受信用のバッファは未確認

### 推定工数: **中**
### 依存関係: ⚠️ フェーズA-2（clipboard paste API）の完了が**前提条件**（送信のみなら即可能だが、外部からのペーストには受信APIが必要）
### 並行作業: ⚠️ 部分的に可能（送信側のみ先行実装可）

---

## タスク8: 右クリックコンテキストメニュー

### 変更対象
- **file_list.rs** または **three_pane.rs**: 右クリックハンドラ追加
- 新規コンテキストメニュー統合コード

### hayate-ui API（確認済み）
- `ContextMenu` ウィジェット — **存在する** (widget/context_menu.rs)
  - `ContextMenu::new(items: Vec<MenuItem>)`
  - `MenuItem::new(id, label)`
  - `show(x, y)` / `hide()` / `take_selected() -> Option<String>`
  - Widget trait実装済み（キーボードナビゲーション、ホバー、クリック対応）
- 右クリック検出: `WidgetEvent::PointerPress`のbutton値で判定（現在は`0x110`=左クリックのみハンドル）
  - 右クリックは`button: 0x111`（Wayland BTN_RIGHT）

### 移行方法
1. `FileListWidget`に`ContextMenu`フィールドを追加
2. `PointerPress { button: 0x111, .. }`で`context_menu.show(x, y)`
3. メニュー項目: Open, Copy, Paste, Delete, Rename, New Folder
4. `take_selected()`で選択されたアクションを既存のfile_ops関数に振り分け

### 注意
- ContextMenuのテキスト描画は親ウィジェット側で行う必要あり（context_menu.rs L139-140のコメント参照）
- file_list.rsの行数制限問題 → ContextMenu用のハンドラは別ファイル(例: `context_handler.rs`)に分離が望ましい

### 推定工数: **中〜大**
### 依存関係: なし（既存APIで実装可能）
### 並行作業: ✅ 可能

---

## タスク9: F2インラインリネーム（TextInputWidget使用）

### 変更対象
- **keybindings.rs L214-241**: 現在のF2リネーム処理

### 現状コード
```rust
// F2 → 自動的に "_renamed" サフィックスを付与（UIなし）
let new_name = format!("{}_renamed{}", stem, ext);
match crate::file_ops::rename_file(&old_path, &new_name) { ... }
```

### hayate-ui API（確認済み）
- `TextInputWidget` — **存在する** (widget/text_input_widget.rs)
  - `TextInputWidget::new(engine).with_placeholder(text).with_width(w)`
  - `text() -> &str` で入力テキスト取得
  - IME対応済み（日本語ファイル名OK）
  - Focus/Blur対応済み

### 移行方法
1. `FileListWidget`に`rename_input: Option<TextInputWidget>`とリネーム対象index/パスを追加
2. F2押下時: 現在のエントリ名でTextInputWidgetを初期化、リネームモードに入る
3. paint()でリネームモード時はエントリ行にTextInputWidgetをオーバーレイ描画
4. Enter確定 → `file_ops::rename_file`実行 → リネームモード解除
5. Escape → リネームモード解除

### 注意
- TextInputWidgetの表示位置をエントリ行に合わせる座標計算が必要
- file_list.rsの行数制限 → リネームUI用のロジックは別ファイル分離が望ましい

### 推定工数: **中〜大**
### 依存関係: なし（既存APIで実装可能）
### 並行作業: ✅ 可能

---

## タスク10: Ctrl+Lアドレスバー入力

### 変更対象
- **breadcrumb.rs** (164行): パンくずリスト表示 → テキスト入力モード切替
- **keybindings.rs**: Ctrl+L ハンドラ追加

### hayate-ui API（確認済み）
- `TextInputWidget` — **存在する**（タスク9と同じ）

### 移行方法
1. `breadcrumb.rs`にTextInputWidgetを組み込み、通常表示/入力モードの切替を実装
2. Ctrl+L押下 → breadcrumbが入力モードに遷移、現在のパスを初期値としてセット
3. Enter → 入力パスに遷移（state.navigate()）
4. Escape → 入力モード解除

### 注意
- breadcrumb.rsは164行なので行数に余裕あり
- TextInputWidgetとbreadcrumbの座標・サイズ合わせが必要

### 推定工数: **中**
### 依存関係: なし
### 並行作業: ✅ 可能

---

## まとめ: 推奨実装順序と並行計画

### 即座に実装可能（フェーズA不要）
| タスク | 工数 | 並行可 | 備考 |
|--------|------|--------|------|
| 3. DoubleClick統合 | 小 | ✅ | **最優先** — file_list.rsの行数を解放 |
| 4. quit_flag統合 | 小〜中 | ✅ | タスク5と同時実装推奨 |
| 5. 動的タイトル統合 | 小〜中 | ✅ | タスク4と配管共有 |
| 8. 右クリックメニュー | 中〜大 | ✅ | ContextMenu API完備 |
| 9. F2リネーム | 中〜大 | ✅ | TextInputWidget完備 |
| 10. Ctrl+Lアドレスバー | 中 | ✅ | TextInputWidget完備 |

### 依存関係あり
| タスク | 工数 | 依存先 | 備考 |
|--------|------|--------|------|
| 6. FileDrop統合 | 小 | タスク3（行数解放） | タスク3完了後に即実装可 |
| 7. クリップボード統合 | 中 | フェーズA-2 | 送信側のみ先行可能。受信（paste from external）はhayate-ui側のclipboard paste API完成待ち |

### 推奨並行作業グループ

**Wave 1**（同時着手可能）:
- Worker A: タスク3 → タスク6（直列、行数依存）
- Worker B: タスク4 + タスク5（配管共有、セット実装）
- Worker C: タスク8（独立、中〜大規模）

**Wave 2**（Wave 1完了後）:
- Worker A: タスク9（F2リネーム）
- Worker B: タスク10（Ctrl+Lアドレスバー）
- Worker C: タスク7（クリップボード統合 — フェーズA-2依存部分）

### 重要な注意事項
1. **file_list.rsが470行で限界** — タスク3のダブルクリック判定削除（-15行）を最優先で行い、タスク6,8のハンドラ追加余地を確保すること
2. **タスク4,5は配管変更が共通** — main.rsの`App`構築フローを変更して`quit_flag`と`title_buffer`を同時にwidgetに渡す設計にすべき
3. **タスク7のpaste受信はフェーズA-2待ち** — hayate-uiのclipboard_copy_bufferは送信のみ。Wayland data_offer経由のpaste受信APIが別途必要
4. **タスク8,9はfile_list.rs分割を検討** — コンテキストメニューとリネームUIのロジックを別ファイルに分離しないと500行制限を超過する可能性が高い
