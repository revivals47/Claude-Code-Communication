# Worker3 フェーズ4: テスト戦略・CI強化 調査・設計レポート

**作成日**: 2026-03-15
**対象リポジトリ**: `/home/ken/Documents/meshchat-desktop-Rust`

---

## タスク4-1: GTKテスト問題の調査・解決方針策定

### 1.1 Rustテスト全量

`cargo test --lib --all-features -- --list` の実行結果: **コンパイルエラーにより全量リスト取得不可**

テストアノテーション `#[test]` / `#[tokio::test]` のgrep集計による推定テスト数:

| クレート | テスト数（推定） |
|---|---|
| `crates/meshchat-lib` | 1,615 |
| `crates/meshchat-core` | 241 |
| `crates/meshchat-discovery` | 287 |
| `crates/meshchat-desktop` | 58 |
| `tests/` (統合テスト) | 717 |
| **合計** | **2,918** |

### 1.2 コンパイルエラーの詳細

`cargo test --lib --all-features` 実行時に **2つのクレートでコンパイルエラー** が発生:

#### (A) `meshchat-discovery` (8エラー)
- `discovery_auth_manager.rs` テスト: `rand`, `rand_chacha` クレートが未リンク (dev-dependenciesに未追加)
- `ecdsa_verifier.rs` テスト: 同上
- `discovery_status_tests.rs`: `StatusManager`, `PeerStatus` が未import (`use crate::discovery_status::StatusManager` が必要)

**原因**: `[dev-dependencies]` セクションに `rand` と `rand_chacha` が記載されていない。テストファイルの `use` 文が不完全。

#### (B) `meshchat-lib` (9エラー)
- `mesh_ack_tracker_tests.rs`: `mesh_ack_tracker`, `sp_message_sync`, `vsp_metrics` モジュールが `super` に存在しない
- `vsp_write_proxy_tests.rs`: 同様のモジュール解決エラー
- `integration_tests/mod.rs`, `dm_store_tests.rs`, `peer_identity.rs`: `tempfile` クレートが未リンク (dev-dependenciesに未追加)

**原因**: テストファイルが参照するモジュールがリファクタリングで移動/削除されたが、テスト側が未修正。`tempfile` がdev-dependenciesに未追加。

### 1.3 `#[ignore]` マーカー付きテスト

`tests/` ディレクトリ内に **78個** の `#[ignore]` 付きテストが存在。

主なファイルと理由:

| ファイル | ignore数 | 理由 |
|---|---|---|
| `integration_nat_detection.rs` | 13 | Docker環境が必要 |
| `integration_hole_punching.rs` | 11 | Docker環境が必要 |
| `e2e_api_test.rs` | 9 | 稼働中サーバーが必要 |
| `phase3f_real_http_integration_test.rs` | 9 | Discovery Server + PostgreSQL + Redis が必要 |
| `sp_user_sync_integration_test.rs` | 7 | クラスター環境が必要 |
| `phase3g_advanced_verification_test.rs` | 5 | 稼働中サーバーが必要 |
| `sp_multi_sp_stress_test.rs` | 5 | クラスター環境が必要 |
| `failover_e2e_test.rs` | 3 | クラスター環境が必要 |
| `integration_connectivity_matrix.rs` | 8 | 環境依存 |
| `integration_discovery_relay_super_peer.rs` | 3 | SuperPeerRelayManager未export |
| `tauri_security_integration.rs` | 2 | Tauriランタイム必要 |
| `load_test_integration.rs` | 1 | 手動実行用 |

### 1.4 headless環境(xvfb-run)でのSIGSEGV原因分析

**現在のCIでの実行方法**: `xvfb-run -a cargo test --lib --all-features`

**SIGSEGV発生の想定原因**:

1. **GTK/WebKit初期化の競合**: `meshchat-desktop` クレートがTauri経由でGTK4/WebKit2GTK-4.1を使用。テストランナーがGTKを初期化する際、xvfb上でもWebKitGTKのプロセス分離やGPUアクセスでクラッシュする可能性がある。

2. **WebKit2GTKのマルチプロセスモデル**: WebKitGTKはWebProcessとNetworkProcessを分離起動する。xvfb上ではGPUバッキングストアの初期化に失敗し、SIGSEGVとなる。

3. **並列テスト実行**: `cargo test` はデフォルトで並列実行するが、GTKはスレッドセーフではない。複数テストが同時にGTK APIを呼ぶとクラッシュする。

4. **現在のコンパイルエラーが先に発生**: 上記1.2のエラーにより、そもそもテストバイナリのビルドが完了しない。SIGSEGVの問題はビルドエラー修正後に発生するはず。

### 1.5 解決方針

#### 短期（即効性あり）
1. **コンパイルエラーの修正**:
   - `meshchat-discovery/Cargo.toml` の `[dev-dependencies]` に `rand` と `rand_chacha` を追加
   - `meshchat-lib/Cargo.toml` の `[dev-dependencies]` に `tempfile` を追加
   - `discovery_status_tests.rs` に `use crate::discovery_status::{StatusManager, PeerStatus};` を追加
   - `mesh_ack_tracker_tests.rs`, `vsp_write_proxy_tests.rs` のモジュールパスを修正、または壊れたテストに `#[ignore]` を付与

2. **GTK依存テストの分離**:
   - `meshchat-desktop` クレートのテストを `--exclude meshchat-desktop` でCI上では除外
   - または `#[cfg(not(ci))]` フラグでGTK依存テストをCI上でスキップ

3. **CIテストコマンドの修正**:
   ```bash
   # GTK不要なクレートのみテスト（推奨）
   xvfb-run -a cargo test --lib -p meshchat-core -p meshchat-lib -p meshchat-discovery
   ```

#### 中期
4. **テストのレイヤー分離**:
   - `cargo test --lib` (ユニットテストのみ、GTK不要クレート)
   - `cargo test --test '*' -- --ignored` (統合テスト、Docker環境有りの場合のみ)

5. **xvfb設定の改善**:
   ```bash
   xvfb-run -a --server-args="-screen 0 1280x1024x24" cargo test ...
   ```

6. **並列度制限**: GTKテストのみ `--test-threads=1` で実行

---

## タスク4-2: テストレイヤー整理

### 2.1 Unit (Rust) - crates/ 配下

#### meshchat-core (241テスト)
主要テストファイルとテスト数:
- `error/handler_tests.rs`: 24 (エラーハンドリング)
- `network/address.rs`: 19 (ネットワークアドレス解析)
- `crypto/keys.rs`: 18 (暗号鍵管理)
- `crypto/hashing.rs`: 13 (ハッシュ関数)
- `crypto/e2e_message.rs`: 13 (E2E暗号化メッセージ)
- `crypto/e2e_config.rs`: 13 (E2E設定)
- `auth/session_manager.rs`: 12 (セッション管理)
- `crypto/encryption.rs`: 11 (暗号化)
- `crypto/auth.rs`: 11 (認証暗号)
- `auth/refresh_token.rs`: 11 (トークンリフレッシュ)
- `config/`: 21 (設定関連)
- `persistence/`: 15 (永続化レイヤー)

**特徴**: 純粋なロジックテストが中心。外部依存なし。CIで安全に実行可能。

#### meshchat-lib (1,615テスト) ⚠ コンパイルエラーあり
主要テストファイル (上位):
- `super_peer/unicode_safety.rs`: 31 (Unicode安全性)
- `super_peer/video_booster_tests.rs`: 27 (ビデオブースター)
- `direct_msg/dm_manager_tests.rs`: 26 (DM管理)
- `friends/friend_mgr_tests.rs`: 24 (フレンド管理)
- `super_peer/integration_tests/core_tests.rs`: 23 (SP統合)
- `super_peer/ws_flood_protection_tests.rs`: 22 (WebSocket flood防御)
- `p2p/nat_traversal/tests.rs`: 22 (NAT traversal)
- `direct_msg/dm_connection_tests.rs`: 22 (DM接続)
- `security/encryption_enhanced_tests.rs`: 21 (強化暗号化)
- `friends/friend_request_tests.rs`: 21 (フレンドリクエスト)

**特徴**: 最大のテストスイート。302ファイルに `#[cfg(test)]` ブロックあり。一部テストにtempfile依存あり。

#### meshchat-discovery (287テスト) ⚠ コンパイルエラーあり
主要テストファイル:
- `discovery/tls_integration_tests.rs`: 28 (TLS統合)
- `discovery_server/sp_health_checker_tests.rs`: 23 (SPヘルスチェック)
- `discovery/health_checker.rs`: 22 (ヘルスチェッカー)
- `discovery_server/sp_public_key_manager.rs`: 14 (SP公開鍵管理)
- `discovery/integration_security_tests.rs`: 13 (セキュリティ統合)

**特徴**: rand/rand_chacha不足でコンパイル不可。修正は容易。

#### meshchat-desktop (58テスト)
- `voice/signaling_tests.rs`: 18 (音声シグナリング)
- `video/video_stream.rs`: 11 (ビデオストリーム)
- `vsp_capability.rs`: 10 (VSP機能判定、GTK参照あり)
- `video/codec.rs`: 10 (ビデオコーデック)
- `voice/ice_candidate.rs`: 9 (ICE候補)

**特徴**: GTK/Tauri依存の可能性があるクレート。CIでのSIGSEGVリスクあり。

### 2.2 Unit (JS) - src-tauri-ui/ 配下

**テストランナー**: Jest (package.jsonの `test` スクリプト)
**テストファイル数**: 19ファイル（node_modules除外）

#### `__tests__/` ディレクトリ (7ファイル)
| ファイル | test/it呼出数 | 内容 |
|---|---|---|
| `frontend-backend-integration.test.js` | 66 | フロント・バック統合 |
| `frontend-integrity.test.js` | 54 | フロント整合性 |
| `security-settings.e2e.test.js` | 45 | セキュリティ設定E2E |
| `video-booster.test.js` | 72 | ビデオブースター |
| `video-voice-integration.test.js` | 13 | ビデオ・音声統合 |
| `integration.test.js` | 13 | 統合テスト |
| `load-test.js` | (負荷テスト) | 負荷テスト |

#### `modules/__tests__/` ディレクトリ (12ファイル)
| ファイル | test/it呼出数 | 内容 |
|---|---|---|
| `dm-shared-utilities.test.js` | 68 | DM共通ユーティリティ |
| `voice-chat.test.js` | 59 | 音声チャット |
| `video-chat-ui.test.js` | 54 | ビデオチャットUI |
| `video-chat.test.js` | 39 | ビデオチャット |
| `video-chat-media.test.js` | 37 | ビデオチャットメディア |
| `voice-chat-bugfix-regression.test.js` | 29 | 音声チャットバグ回帰 |
| `dm-message-sender.test.js` | 26 | DMメッセージ送信 |
| `dm-search.test.js` | 26 | DM検索 |
| `voice-video-integration.test.js` | 24 | 音声・ビデオ統合 |
| `dm-conversation-list.test.js` | 23 | DM会話リスト |
| `dm-status-manager.test.js` | 20 | DMステータス管理 |
| `dm-typing.test.js` | 20 | DMタイピング表示 |

### 2.3 Integration (Rust) - tests/ ディレクトリ

**66ファイル、717テスト、うち78テストが `#[ignore]`**

主要カテゴリ:

| カテゴリ | ファイル数 | テスト数 | ignore数 | 概要 |
|---|---|---|---|---|
| P2P基盤 | 6 | 86 | 24 | NAT検出、ホールパンチング、接続マトリクス |
| SP統合 | 12 | 95 | 18 | SPプロモーション、スコア更新、ストレス |
| Discovery | 5 | 49 | 14 | Discovery Server統合、高度検証 |
| E2E暗号化 | 2 | 37 | 0 | 暗号化フロー |
| チャットフロー | 4 | 42 | 9 | E2E API、シナリオ |
| セキュリティ | 5 | 78 | 2 | ファイアウォール、認証、Tauriセキュリティ |
| DM・フレンド | 3 | 55 | 0 | DM認証、フレンド統合 |
| メディア | 1 | 19 | 0 | SPメディアリレー |
| フェーズテスト | 13 | 144 | 0 | Phase1-13の機能テスト |
| パフォーマンス | 3 | 19 | 2 | 負荷、暗号負荷 |
| フェイルオーバー | 1 | 13 | 3 | フェイルオーバーE2E |
| その他 | 11 | 80 | 6 | DB、永続化、API統合等 |

### 2.4 E2E テスト

- **Bash E2E**: `scripts/docker-e2e-test.sh` (後述 タスク4-4で詳述)
- **JS E2E**: `src-tauri-ui/__tests__/security-settings.e2e.test.js`

---

## タスク4-3: CI linux-bundleジョブ設計

### 3.1 現在のCIジョブ構成

`.github/workflows/ci.yml` に以下6ジョブが定義済み:
1. `check` - cargo check
2. `fmt` - cargo fmt
3. `clippy` - clippy静的解析
4. `test` - xvfb-run cargo test
5. `security-audit` - cargo audit
6. `dependency-check` - cargo deny

`.github/workflows/security-weekly.yml` に週次セキュリティスキャン (cargo audit, cargo outdated, SBOM生成)

**不足しているもの**: Linux向けバンドルビルドジョブ

### 3.2 必要な依存パッケージ（build-ubuntu.sh参照）

```bash
sudo apt-get install -y \
  build-essential curl wget file \
  libssl-dev \
  libgtk-4-dev libadwaita-1-dev \
  libwebkit2gtk-4.1-dev \
  libjavascriptcoregtk-4.1-dev \
  libsoup-3.0-dev \
  libasound2-dev \
  libayatana-appindicator3-dev \
  librsvg2-dev \
  patchelf
```

### 3.3 CI linux-bundle ジョブ YAML設計案

```yaml
  # Linux バンドルビルド
  linux-bundle:
    name: Linux Bundle (${{ matrix.os }})
    runs-on: ${{ matrix.os }}
    strategy:
      fail-fast: false
      matrix:
        os: [ubuntu-22.04, ubuntu-24.04]
    needs: [check, fmt, clippy, test]  # 品質ゲート通過後のみ実行

    steps:
      - uses: actions/checkout@v4

      - name: Install Rust toolchain
        uses: dtolnay/rust-toolchain@stable

      - name: Rust cache
        uses: Swatinem/rust-cache@v2
        with:
          key: linux-bundle-${{ matrix.os }}

      - name: Install system dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y \
            build-essential curl wget file \
            libssl-dev \
            libgtk-4-dev libadwaita-1-dev \
            libwebkit2gtk-4.1-dev \
            libjavascriptcoregtk-4.1-dev \
            libsoup-3.0-dev \
            libasound2-dev \
            libayatana-appindicator3-dev \
            librsvg2-dev \
            patchelf

      - name: Install Tauri CLI
        run: cargo install tauri-cli --version "^2.0" --locked

      - name: Install frontend dependencies
        run: npm ci
        working-directory: .

      - name: Build Linux bundle
        run: cargo tauri build
        env:
          TAURI_SIGNING_PRIVATE_KEY: ""  # Skip signing for CI builds

      - name: List build artifacts
        run: |
          echo "=== .deb packages ==="
          find target/release/bundle/deb -name "*.deb" -exec ls -lh {} \; 2>/dev/null || echo "No .deb found"
          echo "=== AppImage ==="
          find target/release/bundle/appimage -name "*.AppImage" -exec ls -lh {} \; 2>/dev/null || echo "No .AppImage found"

      - name: Upload .deb artifact
        uses: actions/upload-artifact@v4
        with:
          name: meshchat-deb-${{ matrix.os }}
          path: target/release/bundle/deb/*.deb
          retention-days: 30
          if-no-files-found: warn

      - name: Upload AppImage artifact
        uses: actions/upload-artifact@v4
        with:
          name: meshchat-appimage-${{ matrix.os }}
          path: target/release/bundle/appimage/*.AppImage
          retention-days: 30
          if-no-files-found: warn
```

### 3.4 Ubuntu 22.04 vs 24.04 の注意点

| 項目 | Ubuntu 22.04 | Ubuntu 24.04 |
|---|---|---|
| GTK4 | 4.6.x | 4.14.x |
| WebKit2GTK-4.1 | 2.36.x | 2.44.x |
| libadwaita | 1.1.x | 1.5.x |
| OpenSSL | 3.0.x | 3.0.x |
| glibc | 2.35 | 2.39 |

**注意**: Ubuntu 22.04でビルドした.debは22.04以降で動作するが、24.04でビルドしたものは22.04では動作しない（glibc依存）。**最大互換性を得るためにはUbuntu 22.04ビルドを配布用にすべき**。

### 3.5 追加推奨ジョブ: JS テスト

```yaml
  # フロントエンドテスト
  frontend-test:
    name: Frontend Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm test
```

---

## タスク4-4: E2Eテスト基盤の現状調査

### 4.1 `scripts/docker-e2e-test.sh` の内容

**目的**: Docker Compose環境でのフルチャットフローE2Eテスト

**テストフェーズ**:

| フェーズ | 内容 | テスト項目 |
|---|---|---|
| Phase 0 | Docker Compose起動 | サービスのヘルスチェック待機（120秒タイムアウト） |
| Phase 1 | ヘルスチェック | Discovery Server, Core SP x2, Volunteer SP x2 の `/health` エンドポイント |
| Phase 2 | 認証フロー | Alice, Bob 2ユーザーのログイン、JWT取得 |
| Phase 3 | ルーム操作 | ルーム作成、ユーザー参加、メンバー確認 |
| Phase 4 | メッセージング | 直接送信、リレー送信、Store & Forward、メッセージ履歴取得 |
| Phase 5 | Cross-SP リレー | 異なるCore SP経由のメッセージリレー |
| Phase 6 | クリーンアップ | ルーム退出・削除、セッション終了 |

**テスト対象URL**:
- Discovery Server: `http://localhost:8080`
- Core SP 1: `http://localhost:9001`
- Core SP 2: `http://localhost:9002`
- Volunteer SP 1: `http://localhost:9004`
- Volunteer SP 2: `http://localhost:9005`

**検証方法**: curl + jq によるHTTP API呼出しとJSONレスポンス検証

**サマリー出力**: PASS/FAIL カウンターによるテスト結果集計

### 4.2 Docker Compose構成

**メインファイル**: `docker-compose.yml`

| サービス | イメージ/Dockerfile | ポート | メモリ制限 |
|---|---|---|---|
| `meshchat-db` | `postgres:15-alpine` | 5432 (内部) | 1GB |
| `meshchat-redis` | `redis:7-alpine` | 6379 (内部) | 512MB |
| `meshchat-discovery` | `docker/Dockerfile.discovery` | 8080 | 1GB |
| `meshchat-core-1` | `docker/Dockerfile.super_peer` | 9001 | 2GB |
| `meshchat-core-2` | `docker/Dockerfile.super_peer` | 9002 | 2GB |
| `meshchat-sp-1` (Volunteer) | `docker/Dockerfile.super_peer` | 9004 | 2GB |
| `meshchat-sp-2` (Volunteer) | `docker/Dockerfile.super_peer` | 9005 | 2GB |

**ネットワーク**: `meshchat-net` (bridge, IPv6対応 `fd00:dead:beef::/80`)

**依存関係チェーン**:
```
meshchat-db → meshchat-redis → meshchat-discovery → meshchat-core-1/2 → meshchat-sp-1/2
```

**環境変数**: `.env` ファイルで管理（POSTGRES_PASSWORD, REDIS_PASSWORD, JWT_SECRET, HMAC_KEY, API_KEY等）

**追加のDocker Compose構成** (`docker/` ディレクトリ):
- `docker-compose.discovery.yml` - Discovery単体
- `docker-compose.network-test.yml` - ネットワークテスト
- `docker-compose.nat-realistic.yml` - リアルNATテスト
- `docker-compose.volunteer-sp-test.yml` - VolunteerSPテスト
- `docker-compose.mesh-integration-test.yml` - メッシュ統合テスト
- `docker-compose.vsp-mesh-test.yml` - VSPメッシュテスト
- `docker-compose.network-test-full.yml` - フルネットワークテスト
- `docker-compose.local-dev.yml` - ローカル開発
- `docker-compose.dev.yml` / `docker-compose.prod.yml` - 開発/本番環境

### 4.3 E2Eテストの課題

1. **シークレット管理**: docker-compose.ymlが `.env` ファイルを要求するが、CIでは動的生成が必要
2. **ビルド時間**: Docker内でRustバイナリをビルドするため、キャッシュなしで30分以上かかる可能性
3. **リソース要件**: 全サービス合計約8.5GBメモリが必要。GitHub Actions標準ランナー(7GB RAM)では不足の可能性
4. **テスト安定性**: タイムアウトベースの待機（120秒）で、CI環境のリソース制約により不安定になりうる

---

## 総合所見と推奨アクション

### 優先度: 高（即対応）
1. **コンパイルエラー修正**: dev-dependenciesの追加とimportパスの修正で、テストスイートをビルド可能にする
2. **CIテストコマンドの分離**: GTK依存クレート(`meshchat-desktop`)をCIテストから除外

### 優先度: 中（1週間以内）
3. **linux-bundleジョブ追加**: 上記3.3のYAML設計に基づくジョブ追加
4. **JSテストのCI統合**: `npm test` をCIに追加
5. **Rust cacheの導入**: `Swatinem/rust-cache@v2` を全ジョブに追加（ビルド時間短縮）

### 優先度: 低（2週間以内）
6. **Docker E2EテストのCI統合**: シークレット管理とリソース制約の解決後
7. **テストカバレッジ計測**: `cargo-tarpaulin` 等の導入
8. **壊れたテストの修復**: `meshchat-lib` のモジュールパス不整合の修正

---

*報告者: Worker3*
*報告日時: 2026-03-15*
