# C-3 inotify ファイル監視 — アーキテクチャ設計案

**調査日**: 2026-03-28
**調査者**: worker3

---

## 1. hayate-uiイベントループ構造の調査結果

### calloopイベントループ (wayland.rs L216-300)
- `calloop::EventLoop<WaylandWindow>` を使用
- 唯一のイベントソース: `WaylandSource`（wayland-client→calloop統合）
- `event_loop.dispatch(Duration::from_millis(16), self)` で16msポーリング
- ループ内でquit_flag, title_buffer, clipboard等のRc<Cell/RefCell>共有バッファをチェック

### insert_sourceパターン (async_bridge.rs)
- `calloop::channel::channel()` でSender/Channelペア作成
- `handle.insert_source(channel, callback)` でcalloopに登録
- バックグラウンドスレッドからSender経由で即座にループをwake

### 重要な制約
- **App APIにLoopHandle公開メソッドがない**
- App::run()内でevent_loopが作成され、外部からinsert_source()不可
- fileview側から直接calloopにイベントソースを追加する手段がない

---

## 2. inotify統合アーキテクチャ — 3案の比較

### 案A: calloop Generic FDソース（最良、要API追加）
```
hayate-ui側変更:
  App::with_fd_source(fd, callback) → calloopのGeneric<Fd>ソースとして登録

fileview側:
  inotify fd → App::with_fd_source()で登録 → コールバック内でstate.refresh()
```
- **利点**: 遅延ゼロ、calloopの正統なパターン、CPU効率最良
- **欠点**: hayate-ui API追加が必要（breaking change相当）
- **推定工数**: 中（hayate-ui + fileview両方変更）

### 案B: 別スレッド + AtomicBoolフラグ（シンプル、即実装可能）★推奨
```
fileview側のみ:
  watcher.rs: std::thread::spawn → inotify(7)で監視 → Arc<AtomicBool>をtrue
  state.rs: fs_dirty: Arc<AtomicBool> フラグ追加
  メインループ: 16msごとにfs_dirty.load() → trueならrefresh() + dirty flag set
```
- **利点**: hayate-ui変更不要、既存パターンに一致、即実装可能
- **欠点**: 最大16ms遅延（体感不可）、ポーリングだがAtomicBoolチェックはns単位
- **推定工数**: 小

### 案C: calloop::channel経由（案Aと案Bの中間）
```
hayate-ui側変更:
  App::with_channel_source() → calloop::channelを登録

fileview側:
  watcher.rs: 別スレッドでinotify → Sender経由でメインスレッドにwake
```
- **利点**: calloopをwakeするので遅延ゼロ
- **欠点**: hayate-ui API追加が必要
- **推定工数**: 中

### 推奨: 案B（即実装可能、十分な性能）
- 16ms遅延は60fpsフレーム間隔と同じで体感不可
- hayate-ui変更不要なので他Workerの作業とコンフリクトしない
- 将来案Aに移行する場合もwatcher.rsの内部変更のみで済む

---

## 3. 案B 詳細設計

### 新規ファイル: `watcher.rs`（80-100行想定）

```rust
//! File system watcher using inotify(7) — background thread + AtomicBool.

use std::path::{Path, PathBuf};
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::Arc;
use std::thread;

/// Handle to the background watcher thread.
pub(crate) struct FsWatcher {
    /// Set to true when the watched directory has changed.
    pub(crate) dirty: Arc<AtomicBool>,
    /// Send a new path to watch (old watch is replaced).
    tx: std::sync::mpsc::Sender<WatchCmd>,
}

enum WatchCmd {
    Watch(PathBuf),
    Stop,
}

impl FsWatcher {
    pub(crate) fn new(initial_path: &Path) -> Self {
        let dirty = Arc::new(AtomicBool::new(false));
        let (tx, rx) = std::sync::mpsc::channel();

        let dirty_clone = Arc::clone(&dirty);
        let initial = initial_path.to_path_buf();

        thread::spawn(move || {
            watcher_thread(initial, rx, dirty_clone);
        });

        Self { dirty, tx }
    }

    /// Switch to watching a new directory.
    pub(crate) fn watch(&self, path: &Path) {
        let _ = self.tx.send(WatchCmd::Watch(path.to_path_buf()));
    }

    /// Check and clear the dirty flag.
    pub(crate) fn take_dirty(&self) -> bool {
        self.dirty.swap(false, Ordering::AcqRel)
    }
}

impl Drop for FsWatcher {
    fn drop(&mut self) {
        let _ = self.tx.send(WatchCmd::Stop);
    }
}

fn watcher_thread(
    initial: PathBuf,
    rx: std::sync::mpsc::Receiver<WatchCmd>,
    dirty: Arc<AtomicBool>,
) {
    // inotify初期化
    let fd = unsafe { libc::inotify_init1(libc::IN_NONBLOCK) };
    if fd < 0 { return; }

    let mut wd = add_watch(fd, &initial);
    let mut buf = [0u8; 4096];

    loop {
        // コマンドチェック（非ブロック）
        match rx.try_recv() {
            Ok(WatchCmd::Watch(path)) => {
                if wd >= 0 { unsafe { libc::inotify_rm_watch(fd, wd); } }
                wd = add_watch(fd, &path);
            }
            Ok(WatchCmd::Stop) => break,
            Err(_) => {}
        }

        // inotifyイベント読み取り（非ブロック）
        let n = unsafe {
            libc::read(fd, buf.as_mut_ptr() as *mut _, buf.len())
        };
        if n > 0 {
            dirty.store(true, Ordering::Release);
        }

        // 100msスリープ（デバウンス兼CPU節約）
        thread::sleep(std::time::Duration::from_millis(100));
    }

    if wd >= 0 { unsafe { libc::inotify_rm_watch(fd, wd); } }
    unsafe { libc::close(fd); }
}

fn add_watch(fd: i32, path: &Path) -> i32 {
    use std::ffi::CString;
    let c_path = CString::new(path.to_str().unwrap_or("/")).unwrap_or_default();
    let mask = libc::IN_CREATE | libc::IN_DELETE | libc::IN_MODIFY
        | libc::IN_MOVED_FROM | libc::IN_MOVED_TO | libc::IN_ATTRIB;
    unsafe { libc::inotify_add_watch(fd, c_path.as_ptr(), mask as u32) }
}
```

### デバウンス戦略
- inotify読み取りループは100msスリープ
- 100ms以内の連続変更は1回のdirty=trueに集約
- メインスレッドは16msポーリングでdirtyチェック → refresh()呼び出し
- 実効デバウンス: 100-116ms

### state.rs変更
```rust
pub(crate) fs_watcher: Option<crate::watcher::FsWatcher>,
```

### navigate()での監視切り替え
```rust
pub(crate) fn navigate(&mut self, path: PathBuf) {
    // ... 既存のnavigateロジック ...
    // 監視対象を新ディレクトリに切り替え
    if let Some(ref w) = self.fs_watcher {
        w.watch(&self.current_path);
    }
}
```
go_back(), go_forward()も同様。

### メインループでのダーティチェック
three_pane.rs の `dirty()` メソッドでwatcherのdirtyフラグをチェック:
```rust
fn dirty(&self) -> bool {
    let watcher_dirty = self.file_list.state().borrow()
        .fs_watcher.as_ref()
        .map(|w| w.take_dirty())
        .unwrap_or(false);
    if watcher_dirty {
        // state.refresh() + viewport再構築が必要
        // ただしdirty()は&selfなので直接refresh不可
        // → dirty()でフラグだけ立て、次のevent/layoutで実行
    }
    self.file_list.dirty() || self.sidebar.dirty() || self.preview.dirty()
}
```

**問題**: `dirty()`は`&self`なので`refresh()`を呼べない。
**解決**: stateに`fs_needs_refresh: Cell<bool>`を追加し:
1. `dirty()`でwatcher.take_dirty() → trueならfs_needs_refresh.set(true)、dirty=true返却
2. `layout()`（&mut self）でfs_needs_refresh.get()をチェック → refresh() + viewport再構築

### main.rs変更
```rust
let watcher = crate::watcher::FsWatcher::new(&path);
state.borrow_mut().fs_watcher = Some(watcher);
```

---

## 4. 依存関係

| 項目 | 状態 |
|------|------|
| libcクレート | ✅ 既にCargo.tomlに存在 |
| inotify syscall | ✅ libc経由で直接使用（追加クレート不要） |
| std::thread | ✅ 標準ライブラリ |
| Arc<AtomicBool> | ✅ 標準ライブラリ |
| hayate-ui変更 | ❌ 不要（案B） |

### Cargo.toml変更: なし
libc は既に依存関係に含まれている。

---

## 5. ファイル変更サマリ

| ファイル | 変更内容 | 推定行数 |
|----------|----------|----------|
| watcher.rs | 新規: FsWatcher構造体 + バックグラウンドスレッド | ~95行 |
| state.rs | fs_watcher + fs_needs_refresh フィールド追加 | +5行 |
| main.rs | FsWatcher作成・state注入 | +2行 |
| three_pane.rs | dirty()でwatcherチェック、layout()でrefresh | +8行 |

**合計追加行数**: ~110行
**新規クレート依存**: なし

---

## 6. リスク・注意事項

1. **inotify監視上限**: `/proc/sys/fs/inotify/max_user_watches`（デフォルト8192）。1ディレクトリのみ監視なので問題なし
2. **シンボリックリンク**: inotify_add_watchはシンボリックリンク先を監視。意図通り
3. **マウントポイント越え**: サブディレクトリ内の変更は通知されない（INは対象ディレクトリ直下のみ）。これは正しい動作（fileviewも1階層のみ表示）
4. **パーミッション**: 読み取り権限のないディレクトリはwatch失敗 → add_watchが-1を返す → 無視（安全）
5. **スレッド安全性**: Arc<AtomicBool>のみ共有。state/RefCellはメインスレッドのみ。安全
6. **日本語パス**: CStringへの変換はUTF-8バイト列。Linuxのパスはバイト列なので問題なし（ただし非UTF-8パスはto_str()でNoneになる可能性 → unwrap_or("/")でフォールバック）
