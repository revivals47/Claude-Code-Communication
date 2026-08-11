# Worker3: meshchat-lib テスト修復レポート

**作成日**: 2026-03-15
**対象**: `/home/ken/Documents/meshchat-desktop-Rust/crates/meshchat-lib`

---

## 問題の概要

`cargo test --lib -p meshchat-lib --no-run` で以下の6つのコンパイルエラー:
- `mesh_ack_tracker_tests.rs`: `super::mesh_ack_tracker`, `super::sp_message_sync`, `super::vsp_metrics` が未解決 (3エラー)
- `vsp_write_proxy_tests.rs`: `super::vsp_write_proxy`, `super::sp_message_sync`, `super::vsp_metrics` が未解決 (3エラー)

## 根本原因

テストファイルの**インクルード方法**と**use文のパス**の不整合。

### インクルード構造

両テストファイルは、親モジュールファイルから `#[path]` でインクルードされている:

```
mesh_ack_tracker.rs (line 357-359):
  #[cfg(test)]
  #[path = "mesh_ack_tracker_tests.rs"]
  mod tests;

vsp_write_proxy.rs (line 318-320):
  #[cfg(test)]
  #[path = "vsp_write_proxy_tests.rs"]
  mod tests;
```

### `super::` の解決先

`#[path]` でインクルードされた場合:
- `mesh_ack_tracker_tests.rs` 内の `super` → `mesh_ack_tracker` モジュール
- `vsp_write_proxy_tests.rs` 内の `super` → `vsp_write_proxy` モジュール

しかし、テストコード内の `use super::mesh_ack_tracker::...` は `super` = `super_peer` を想定。
つまり `mesh_ack_tracker::mesh_ack_tracker::MeshAckTracker` を探そうとして失敗していた。

## 修正内容

### アプローチ: use文をcrate絶対パスに修正

`#[path]` インクルードを維持（テストからprivateフィールドへのアクセスを保持）しつつ、
use文を正しいパスに変更。

### 1. `mesh_ack_tracker_tests.rs` (lines 1-3)

```diff
-use super::mesh_ack_tracker::MeshAckTracker;
-use super::sp_message_sync::SpSyncMessage;
-use super::vsp_metrics::VspMetrics;
+use super::MeshAckTracker;
+use crate::super_peer::sp_message_sync::SpSyncMessage;
+use crate::super_peer::vsp_metrics::VspMetrics;
```

### 2. `vsp_write_proxy_tests.rs` (lines 1-3)

```diff
-use super::vsp_write_proxy::VspWriteProxy;
-use super::sp_message_sync::SpSyncMessage;
-use super::vsp_metrics::VspMetrics;
+use super::VspWriteProxy;
+use crate::super_peer::sp_message_sync::SpSyncMessage;
+use crate::super_peer::vsp_metrics::VspMetrics;
```

### 3. `discovery_status_tests.rs` の重複インクルード修正 (前回Step 1で対応済み)

`lib.rs` から `mod discovery_status_tests;` を削除。
（`discovery_status.rs` 内の `#[path]` が正しいインクルード先）

## 検証結果

```
$ cargo test --lib -p meshchat-core -p meshchat-discovery -p meshchat-lib --no-run

Finished `test` profile [unoptimized + debuginfo] target(s) in 9.57s
Executable unittests src/lib.rs (meshchat_core-2431abc60702975f)
Executable unittests src/lib.rs (meshchat_discovery-fb21cca55ac0ade8)
Executable unittests src/lib.rs (meshchat_lib-a8b11db47e30031f)
```

**3クレート全てコンパイル成功（エラー0件）**

## 残存Warning (4件, 非致命的)

- `unused import: super::*` (reactions.rs:200) - 未使用import
- `unused import: VspStatusResponse` (vsp_client/tests.rs:7) - 未使用import
- `function strip_to_host_port is never used` (service_provider.rs:30) - デッドコード
- `field data_cache is never read` (vsp_server/core.rs:144) - 未使用フィールド

---

*報告者: Worker3*
