# CSPリレー Phase 4-8 タスク指示書

## 作業ディレクトリ
`/home/ken/Documents/meshchat-desktop-Rust`

## 完了済み（Phase 1-3）
1. `src/super_peer/sp_message_sync.rs` — RelayRequest, RelayAck, RelayClientFrame追加済み
2. `src/super_peer/csp_relay_registry.rs` — 新規作成済み（CspRelayRegistry + RELAY_REGISTRY）
3. `src/super_peer/csp_relay_ws.rs` — 新規作成済み（CspRelayWsSession + csp_relay_ws_handler）

---

## Worker1: Phase 4 — CSP側リレーフレーム処理

### ファイル: `src/super_peer/sp_ws_actor.rs`

### 変更1: handle_sync_message()に2つのmatchアームを追加

`"sp_dm_forward"` ケースの後、`_ =>` の前に追加:

```rust
"sp_relay_request" => {
    // VSPがCSPにリレーを要求
    if let Some(vsp_id) = value.get("vsp_id").and_then(|v| v.as_str()) {
        let capacity = value.get("capacity").and_then(|v| v.as_u64()).unwrap_or(50) as u32;
        info!("📡 Relay request from VSP {}: capacity={}", vsp_id, capacity);

        // CSPのアドレスを構築（overlay.sp_id()からではなく、リクエストのコンテキストから）
        // CSPの listen address を返す
        let local_sp_id = self.local_sp_id.clone();
        let overlay = self.overlay.clone();

        // RelayAckを返す — CSPのアドレスをrelay_addressとして返す
        // CSPのlistenアドレスはoverlay configから取得
        let relay_address = overlay.advertised_address().unwrap_or_else(|| "0.0.0.0:9001".to_string());

        let ack = super::sp_message_sync::SpSyncMessage::RelayAck {
            vsp_id: vsp_id.to_string(),
            relay_address,
            accepted: true,
        };
        if let Ok(json) = serde_json::to_string(&ack) {
            ctx.text(json);
        }
    }
}
"sp_relay_client_frame" => {
    // VSPからクライアントへのフレーム転送
    if let (Some(relay_session_id), Some(payload)) = (
        value.get("relay_session_id").and_then(|v| v.as_str()),
        value.get("payload").and_then(|v| v.as_str()),
    ) {
        let relay_session_id = relay_session_id.to_string();
        let payload = payload.to_string();
        actix_rt::spawn(async move {
            use super::csp_relay_registry::RELAY_REGISTRY;
            RELAY_REGISTRY.send_to_client(&relay_session_id, payload).await;
        });
    }
}
```

### 変更2: stopped()にVSPリレーセッションクリーンアップを追加

`stopped()`メソッド内の既存のunregister処理の後に追加:

```rust
// Clean up any relay sessions for this VSP
if let Some(ref sp_id) = self.remote_sp_id {
    let sp_id = sp_id.clone();
    actix_rt::spawn(async move {
        use super::csp_relay_registry::RELAY_REGISTRY;
        RELAY_REGISTRY.cleanup_vsp_sessions(&sp_id).await;
    });
}
```

### 注意: advertised_address()が存在しない場合
`OverlayIntegration`に`advertised_address()`メソッドがない場合、以下のいずれかで対処:
- 環境変数 `SP_ADVERTISED_ADDRESS` から取得
- または `overlay.sp_config()` から取得
- 最悪の場合、固定値 `"0.0.0.0:9001"` をフォールバックとして使用し、TODOコメントを残す

---

## Worker2: Phase 5+6 — VSPリレー要求とフレーム処理

### ファイル1: `src/super_peer/vsp_message_handler.rs`

### 変更1: VspMessageHandlerにrelay_ack通知チャネルを追加

```rust
// フィールド追加
pub(crate) relay_ack_tx: tokio::sync::watch::Sender<Option<String>>,
relay_ack_rx: tokio::sync::watch::Receiver<Option<String>>,
```

new()で初期化:
```rust
let (relay_ack_tx, relay_ack_rx) = tokio::sync::watch::channel(None);
```

### 変更2: handle_message()にRelayAckとRelayClientFrameの処理を追加

```rust
SpSyncMessage::RelayAck { vsp_id, relay_address, accepted } => {
    if accepted {
        info!("📡 Relay ack received: vsp={} relay_address={}", vsp_id, relay_address);
        let _ = self.relay_ack_tx.send(Some(relay_address));
    } else {
        warn!("📡 Relay request rejected for vsp={}", vsp_id);
        let _ = self.relay_ack_tx.send(None);
    }
    Ok(())
}

SpSyncMessage::RelayClientFrame { relay_session_id, vsp_id, room_name, user_id, frame_type, payload } => {
    match frame_type.as_str() {
        "connect" => {
            info!("📡 Relay client connected: session={} user={} room={}", relay_session_id, user_id, room_name);
        }
        "text" => {
            debug!("📡 Relay client frame: session={} user={} room={}", relay_session_id, user_id, room_name);
            // payloadをJSONパースしてprocess_client_messageで処理
            // 応答はRelayClientFrameとしてCSPに返送
            self.handle_relay_text_frame(&relay_session_id, &vsp_id, &room_name, &user_id, &payload).await;
        }
        "disconnect" => {
            info!("📡 Relay client disconnected: session={} user={} room={}", relay_session_id, user_id, room_name);
        }
        other => {
            warn!("Unknown relay frame_type: {}", other);
        }
    }
    Ok(())
}
```

### 変更3: handle_relay_text_frame()メソッドを追加

リレー経由のテキストフレームを処理し、応答をCSPに返送:
- payloadをJSONパース
- typeフィールドを見て ping/heartbeat/chat を処理
- 応答テキストをRelayClientFrameでcsp_senderを通してCSPに返送

### 変更4: relay_ack_rx()公開メソッドを追加
```rust
pub fn subscribe_relay_ack(&self) -> tokio::sync::watch::Receiver<Option<String>> {
    self.relay_ack_rx.clone()
}
```

---

### ファイル2: `src/super_peer/vsp_client.rs`

### 変更: join_cluster()の656行目付近を修正

現在:
```rust
} else {
    info!("VSP has no routable address — skipping Torus registration, outbound-only mode");
}
```

修正後:
```rust
} else {
    // NAT越え不可 → CSPリレーを要求してTorus登録
    info!("📡 VSP has no routable address — requesting CSP relay for Torus registration");

    // 1. RelayRequest送信
    if let Some(ref sender) = *self.csp_sender.read().await {
        let relay_req = SpSyncMessage::RelayRequest {
            vsp_id: self.config.local_sp_id.clone(),
            capacity: self.config.server_max_connections,
        };
        let _ = sender.send(relay_req).await;
    }

    // 2. RelayAck待機（10秒タイムアウト）
    let mut relay_ack_rx = self.message_handler.subscribe_relay_ack();
    let relay_address = tokio::time::timeout(
        std::time::Duration::from_secs(10),
        async {
            loop {
                relay_ack_rx.changed().await.ok()?;
                let val = relay_ack_rx.borrow().clone();
                if val.is_some() {
                    return val;
                }
            }
        }
    ).await.ok().flatten();

    // 3. リレーアドレスでTorus登録
    if let Some(relay_addr) = relay_address {
        let torus_address = format!("relay:{}:{}", relay_addr, self.config.local_sp_id);
        info!("📡 VSP registering in Torus with relay address: {}", torus_address);

        let torus = Arc::new(TorusClient::new(
            discovery_url.clone(),
            self.config.local_sp_id.clone(),
            torus_address,
            true,
        ));

        match torus.register().await {
            Ok(resp) => {
                info!("🔵 VSP registered in Torus ring via CSP relay: pos={:.4}", resp.position);
                // メトリクスタスク開始（同じパターン）
                // ... (既存のTorus登録成功後の処理をコピー)
                *self.torus_client.write().await = Some(torus);
            }
            Err(e) => {
                warn!("⚠️ Torus registration via relay failed: {}", e);
            }
        }
    } else {
        warn!("📡 CSP relay ack not received within timeout — staying outbound-only");
    }
}
```

---

## Worker3: Phase 7+8 — Torusアドレス構築とモジュール登録

### ファイル1: `src/super_peer/mod.rs`

追加（`pub mod vsp_write_proxy;`の後あたり）:
```rust
pub mod csp_relay_registry;
pub mod csp_relay_ws;
```

### ファイル2: `src/bin/super_peer_server.rs`

### 変更1: use文追加（ファイル先頭のimport部分）
```rust
use meshchat_desktop::super_peer::csp_relay_ws::csp_relay_ws_handler;
```

### 変更2: create_app()内のoverlay_data分岐にリレーエンドポイント追加

```rust
if let Some(ref overlay_data) = overlay_data {
    app = app
        .app_data(overlay_data.clone())
        .route("/ws/sp", web::get().to(sp_ws_handler))
        .route("/ws/relay/{vsp_id}/room/{room_name}", web::get().to(csp_relay_ws_handler));
}
```

### ファイル3: `src/discovery_server/torus/handlers/mod.rs`

### 変更: SPEndpoint構築でrelay:プレフィックスを検出

SPEndpointのws_url/http_url構築箇所（L135, L148, L159付近）でaddressがrelay:で始まる場合の処理を追加。

ヘルパー関数を追加:
```rust
/// Build SP endpoint URLs, handling relay: prefix for NAT'd VSPs
fn build_sp_urls(address: &str) -> (String, String) {
    if address.starts_with("relay:") {
        // Format: "relay:host:port:vsp_id"
        let parts: Vec<&str> = address.splitn(4, ':').collect();
        if parts.len() == 4 {
            let host = parts[1];
            let port = parts[2];
            let vsp_id = parts[3];
            (
                format!("{}://{}:{}/ws/relay/{}", crate::util::ws_scheme(), host, port, vsp_id),
                format!("{}://{}:{}", crate::util::http_scheme(), host, port),
            )
        } else {
            // Malformed relay address, fall back to direct
            (
                format!("{}://{}/ws", crate::util::ws_scheme(), address),
                format!("{}://{}", crate::util::http_scheme(), address),
            )
        }
    } else {
        (
            format!("{}://{}/ws", crate::util::ws_scheme(), address),
            format!("{}://{}", crate::util::http_scheme(), address),
        )
    }
}
```

全てのSPEndpoint構築箇所でこのヘルパーを使うようにリファクタ。

---

## 成功基準
- `cargo test --lib` 全テストパス
- `cargo build` ビルド成功
