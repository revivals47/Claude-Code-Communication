# MeshChat VSP-Centric 設計実装 セッション記録
**日付**: 2026-02-22
**VPS**: さくらVPS 133.167.108.151 (1GB RAM / 2コア / Ubuntu 24.04)
**SSH**: claude@133.167.108.151 (ユーザー: claude)

---

## 1. 本日の実施内容と状態

| 作業 | 状態 | コミット |
|------|------|---------|
| VSP活性化バイナリのVPS本番デプロイ | 完了 | (前セッション) |
| state sync 401エラー修正 | 完了 | 458af3f8に含む |
| MASTER_TASKS.md設計修正 (3層パイプラインに変更) | 完了 | — |
| Phase 1: ハートビートオフロード | **完了** | `458af3f8` |
| Phase 2: NAT Traversal via VSPs | **完了** | `8fab4b0a` |
| Phase 3: Discovery Server Slimming | **未着手** | — |
| VPSデプロイ (Phase 1+2) | **未実施** | — |

---

## 2. git状態

```
96fa8cf7 VPSデプロイスクリプト追加
8fab4b0a Phase 2: NAT Traversal via VSPs — ホールパンチ仲介 + UDPリレー
458af3f8 Phase 1: ハートビートオフロード — 3層パイプライン実装
e96d0f50 SP overlay強化
```

- **ブランチ**: master
- **リモート**: https://github.com/revivals47/meshchat-desktop-Rust.git
- **テスト**: 2615 passed, 0 failed
- **全pushずみ**

---

## 3. 3層アーキテクチャ（重要）

```
Client → VSP (WebSocket) → CoreSP (/api/sp/metrics) → Discovery (/api/torus/sp/bulk-heartbeat)
```

- VSPはDiscoveryに直接通信しない（CoreSP経由のみ）
- CoreSPが集約レイヤー
- 詳細: リポジトリ内ソースのコメント参照
  - `src/super_peer/torus_client.rs` 冒頭コメント (lines 1-26)

---

## 4. Phase 1 完了内容 (458af3f8, +1718行)

Client→VSP→CoreSP→Discoveryのハートビートパイプライン:
- `vsp_heartbeat_aggregator.rs` (新規): クライアントHB集約
- `SpMetricsEntry.client_heartbeats`: VSP→CoreSPメトリクスに統合
- `BulkHeartbeatRequest.client_heartbeats`: CoreSP→Discoveryに統合
- `tauri_app.rs`: VSP Aggregator経由 + Discoveryフォールバック

## 5. Phase 2 完了内容 (8fab4b0a, +2042行)

VSP経由のNAT traversal:
- `vsp_punch_mediator.rs` (新規): パンチセッション管理 (最大64同時)
- `vsp_relay.rs` (新規): UDPリレー (最大5セッション, 120sタイムアウト)
- `sp_message_sync.rs`: PunchRequest/PunchResponse追加
- `nat_traversal.rs`: VSP優先ルーティング (Symmetric NAT→リレー優先)
- `handlers/mod.rs`: Discovery punch_hole deprecation警告

## 6. Phase 3 (未着手) — 計画のみ

詳細: MASTER_TASKS.md の Phase 3 セクション

概要:
- 不要エンドポイント削除 (`/api/peers/{id}/heartbeat`, `/api/volunteer/heartbeat`等)
- ルームクエリのキャッシュ化 (Cache-Control, ETag)
- VSPがルームディレクトリをキャッシュ配信

---

## 7. VPS現在の状態（Phase 1+2未デプロイ）

```
全サービス healthy (2026-02-22 12:55 JST デプロイ版)
- meshchat-discovery   (state sync対応済みだが、Phase 1+2未反映)
- meshchat-core-1      (VSP活性化済みだが、Phase 1+2未反映)
- meshchat-db          (PostgreSQL 15-alpine)
- meshchat-redis       (Redis 7-alpine)
- meshchat-api         (Desktop API)
```

### VPS上の構成ファイル
```
/home/claude/
├── meshchat/          # docker-compose.yml
├── Dockerfile.sp-quick3      # バイナリ差し替え用 (super_peer_server_new → super_peer_server)
├── Dockerfile.disc-quick     # バイナリ差し替え用 (discovery_server_new → discovery_server)
├── sp-entrypoint.sh          # SP起動スクリプト
├── super_peer_server_new     # ← ここにバイナリを配置
└── discovery_server_new      # ← ここにバイナリを配置
```

---

## 8. デプロイ手順

### Linuxデスクトップからのデプロイ（推奨）

```bash
# 前提: VPSへのSSH鍵が設定済み
# 前提: リポジトリをgit clone/pull済み

# 全自動デプロイ
./scripts/deploy-to-vps.sh

# 個別デプロイも可能
./scripts/deploy-to-vps.sh sp           # super_peer_serverのみ
./scripts/deploy-to-vps.sh discovery    # discovery_serverのみ
./scripts/deploy-to-vps.sh --build-only # ビルドのみ
```

スクリプトが行うこと:
1. `cargo build --release` (ネイティブx86_64、クロスコンパイル不要)
2. SCP転送 (`super_peer_server_new`, `discovery_server_new`)
3. VPS上でDockerイメージ再ビルド
4. `docker compose up -d --force-recreate`
5. ヘルスチェック (15秒後に確認)

### Macからのデプロイ（クロスコンパイル）

```bash
# docker buildxでlinux/amd64ビルド（約25分）
docker buildx build --platform linux/amd64 -f docker/Dockerfile.super_peer -t meshchat-core-sp:latest --load .
docker buildx build --platform linux/amd64 -f docker/Dockerfile.discovery -t meshchat-discovery:latest --load .

# バイナリ抽出 → SCP → VPS再ビルド（scripts/deploy-to-vps.shと同じ手順）
```

---

## 9. 次のアクション（Linux引き継ぎ用）

### 優先度1: VPSデプロイ
```bash
# 1. VPSへのSSH設定
ssh-keygen -t ed25519  # (なければ)
ssh-copy-id -i ~/.ssh/id_ed25519.pub claude@133.167.108.151

# 2. リポジトリclone
git clone https://github.com/revivals47/meshchat-desktop-Rust.git
cd meshchat-desktop-Rust

# 3. デプロイ
./scripts/deploy-to-vps.sh
```

### 優先度2: Phase 3実装（任意）
- MASTER_TASKS.md の Phase 3 セクション参照
- 不要エンドポイント削除 + キャッシュ化
- Phase 1+2が本番で安定動作してから着手推奨

### 確認コマンド
```bash
# テスト実行
cargo test --lib

# VPSサービス状態
ssh claude@133.167.108.151 "docker ps --format 'table {{.Names}}\t{{.Status}}' | grep meshchat"

# VPSログ確認
ssh claude@133.167.108.151 "docker logs meshchat-core-1 2>&1 | tail -30"
ssh claude@133.167.108.151 "docker logs meshchat-discovery 2>&1 | tail -30"
```
