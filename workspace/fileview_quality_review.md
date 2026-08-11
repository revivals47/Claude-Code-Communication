# fileview品質レビュー報告

**レビュー日**: 2026-03-28
**レビュー者**: worker3
**対象**: hayate-linux-fileview フェーズB+C全変更

---

## 1. 行数制限 ✅ 全ファイル500行以内

| ファイル | 行数 | 状態 |
|----------|------|------|
| file_list.rs | 496 | ✅ (余裕4行) |
| three_pane.rs | 447 | ✅ |
| file_ops.rs | 323 | ✅ |
| keybindings.rs | 302 | ✅ |
| state.rs | 253 | ✅ |
| sidebar.rs | 249 | ✅ |
| breadcrumb.rs | 231 | ✅ |
| preview.rs | 220 | ✅ |
| watcher.rs | 179 | ✅ |
| context_handler.rs | 176 | ✅ |
| entry.rs | 153 | ✅ |
| config.rs | 134 | ✅ |
| rename_ui.rs | 133 | ✅ |
| status_bar.rs | 112 | ✅ |
| scroll.rs | 98 | ✅ |
| main.rs | 68 | ✅ |

---

## 2. unsafe使用箇所の安全性レビュー

### watcher.rs — inotify syscalls (9箇所)

**fd/wdリーク分析:**
- `inotify_init1` 失敗時(L88): 即return。リークなし ✅
- `inotify_add_watch` 失敗時(L94-97): `close(fd)`を呼んでからreturn ✅
- 正常終了パス(L125-128): `inotify_rm_watch` + `close` ✅
- `stop_flag`によるスレッド停止時: whileループ脱出 → L125-128のクリーンアップ実行 ✅

**スレッド終了時のリソース解放:**
- `FsWatcher::drop()`(L64-71): `stop_flag.store(true)` → `thread.join()` — 確実にスレッド終了を待つ ✅
- `watch()`でのスレッド切り替え(L47-60): 旧スレッドをjoin()してから新スレッド起動 ✅

**潜在的問題:**
- `libc::poll`のpfdがスタック変数 — 問題なし。100msタイムアウトで定期的に`stop_flag`チェック ✅
- `CString::new`失敗時(L132-134): wd=-1を返し、L94で`close(fd)`して安全にreturn ✅

**判定: 安全** — 全パスでfd/wdが正しく解放される。

### entry.rs + file_ops.rs — libc::localtime_r (2箇所)

- `mem::zeroed::<libc::tm>()`: POD型のゼロ初期化、安全
- `localtime_r`: スレッドセーフ版、出力バッファはスタック上

**判定: 安全**

---

## 3. エラーハンドリングの妥当性

### 良い点
- `file_ops::copy_to`, `trash`, `rename_file`: 全てResult返却、呼び出し側でeprintln+継続 ✅
- `config::load()`: パース失敗時はデフォルト値にフォールバック ✅
- `config::save()`: `let _ = fs::write()` — 設定保存失敗は非致命的、適切 ✅
- `watcher::add_watch`: CString変換失敗で-1返却、上位でclose(fd)してreturn ✅

### 改善検討事項（非ブロッカー）
- **P3**: keybindings.rs L197の`paste_request`アクセスパターン:
  ```rust
  } else if let Some(ref pr) = w.state.borrow().paste_request {
      pr.set(true);
      w.pending_file_paste = true;
  }
  ```
  `borrow()`のスコープが`if let`のブロック末まで続くが、このブロック内でborrow_mut()は呼ばれないので安全。ただし意図が不明確。
  → **現状問題なし**。prのRc<Cell>はborrow中にset可能（Cellはコピーセマンティクス）。

---

## 4. Rc<RefCell>/Rc<Cell>の借用パニック可能性

### 分析手法
全ての`borrow()`/`borrow_mut()`呼び出しを追跡し、同一スコープで二重借用がないか検証。

### 結果

**安全パターン（全箇所で確認済み）:**
- `borrow()` → データ読み取り → `drop(state)` → `borrow_mut()` — 明示的drop後の再借用 ✅
  - keybindings.rs L17-23 (quit_flag)
  - keybindings.rs L163-177 (Ctrl+C)
  - keybindings.rs L206-211 (Delete)
  - context_handler.rs L55-61 (action_open)
  - context_handler.rs L72-85 (action_copy)
  - context_handler.rs L107-112 (action_delete)
  - context_handler.rs L124-128 (action_rename)
  - rename_ui.rs L86-91 (start_rename)

**注意パターン:**
- three_pane.rs L176-180: `borrow_mut()` → `state.refresh()` → `drop(state)` → rebuild等
  - refresh()内部でborrow_mut不使用（selfの&mutメソッド）→ 安全 ✅

- context_handler.rs L158-159: engine.borrow_mut() + text_cache.borrow_mut() 同時
  - 異なるRefCell → パニックなし ✅

**潜在的リスク（現状問題なし）:**
- file_list.rs paint()内でengineをborrow_mut → drop → rename_ui paint → TextInputWidget.paint()がengineを内部で再borrow_mut
  - rename_ui.rs L73-75: `self.widget.paint(canvas, rect, stride)` — TextInputWidgetが内部でengineをborrow_mutする
  - file_list.rs L345: `drop(engine)` が先に実行されている → 安全 ✅

**判定: パニックリスクなし** — 全箇所で借用規律が守られている。

---

## 5. ファイル間の依存関係の整合性

### 依存グラフ
```
main.rs → config, state, three_pane, App
three_pane.rs → breadcrumb, sidebar, file_list, preview, status_bar, state
file_list.rs → state, keybindings, rename_ui, context_handler, file_ops, watcher(indirect)
keybindings.rs → file_list, config, file_ops, rename_ui, entry
context_handler.rs → file_list, file_ops, rename_ui
rename_ui.rs → file_list, file_ops
config.rs → entry, state
state.rs → entry, watcher
watcher.rs → (standalone, libc only)
```

### 循環依存チェック
- `file_list ↔ keybindings`: file_list→keybindings(handle_key_event), keybindings→file_list(FileListWidget) — 相互参照だがRust modulesで問題なし ✅
- `file_list ↔ rename_ui`: 同上パターン ✅
- `file_list ↔ context_handler`: 同上パターン ✅

### API整合性
| hayate-ui API | 注入元(main.rs) | 格納先(state.rs) | 使用箇所 |
|---|---|---|---|
| quit_flag | L46 | L31 | keybindings.rs L20 |
| title_buffer | L47 | L32 | state.rs navigate/go_back/go_forward |
| clipboard_copy_buffer | L48 | L33 | keybindings.rs L170, context_handler.rs L78 |
| clipboard_paste_request | L49 | L34 | keybindings.rs L197, context_handler.rs L100 |
| cursor_shape_buffer | L62 | three_pane直接 | three_pane.rs (divider hover) |
| sidebar_ratio/preview_ratio | L57-58 | L35-36 | config.rs L130-131, three_pane.rs |

全て整合 ✅

---

## 6. テスト結果

```
test result: ok. 7 passed; 0 failed; 0 ignored
```
- file_ops: 5テスト（URI parse, percent decode, unique path）
- watcher: 2テスト（file creation detection, directory switch）

---

## 7. 未使用コード警告（12件、全て既存）

将来使用予定のAPIスタブ:
- `FileOpResult`, `move_to`, `delete`, `copy_batch`, `move_batch`, `handle_uri_drop`, `run_batch` (file_ops.rs)
- `ScrollableWidget` + methods (scroll.rs)
- `FileViewState::new`, `clear_error`, `visible_entries` (state.rs)
- `DirEntry::mode`, `format_mode` (entry.rs)

→ 未使用を#[allow]するか削除するかはプロジェクト方針次第。現時点では問題なし。

---

## 8. 総合判定

| 観点 | 判定 |
|------|------|
| 行数制限 | ✅ 全ファイル500行以内 |
| unsafe安全性 | ✅ fd/wdリークなし、全パスで解放確認 |
| エラーハンドリング | ✅ 適切（非致命エラーは継続、致命エラーはearly return） |
| 借用パニック | ✅ リスクなし（全箇所で明示的drop後の再借用） |
| 依存関係整合性 | ✅ API注入→格納→使用の全パイプライン確認済み |
| テスト | ✅ 7/7パス |
| ビルド | ✅ 成功（新規警告なし） |

**結論: 品質問題なし。リリース可能。**
