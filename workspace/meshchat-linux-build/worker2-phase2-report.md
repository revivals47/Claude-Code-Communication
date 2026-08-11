# Worker2 フェーズ2レポート: Linux固有問題の洗い出し・検証

**調査日**: 2026-03-15
**調査環境**: Ubuntu 24.04.4 LTS (Noble Numbat), x86_64
**対象リポジトリ**: /home/ken/Documents/meshchat-desktop-Rust

---

## タスク2-1: CIとbuild-ubuntu.shの依存パッケージ差異分析

### 比較対象ファイル
- `.github/workflows/ci.yml`
- `scripts/build-ubuntu.sh`

### パッケージ比較表

| パッケージ | build-ubuntu.sh | CI (ci.yml) | 差異 |
|---|:---:|:---:|---|
| build-essential | YES | NO | **CI不足** |
| curl | YES | NO | CI不足(軽微) |
| wget | YES | NO | CI不足(軽微) |
| file | YES | NO | CI不足(軽微) |
| libssl-dev | YES | NO | **CI不足** |
| libgtk-4-dev | YES | YES | 一致 |
| libadwaita-1-dev | YES | YES | 一致 |
| libwebkit2gtk-4.1-dev | YES | NO | **CI不足(重大)** |
| libjavascriptcoregtk-4.1-dev | YES | NO | **CI不足(重大)** |
| libsoup-3.0-dev | YES | NO | **CI不足(重大)** |
| libasound2-dev | YES | YES | 一致 |
| libayatana-appindicator3-dev | YES | NO | **CI不足** |
| librsvg2-dev | YES | NO | **CI不足** |
| patchelf | YES | NO | CI不足(ビルド専用) |
| xvfb | NO | YES(testジョブのみ) | CI追加(テスト用) |
| tauri-cli | YES | NO | CIはビルドせずcheckのみのため不要 |

### CI不足パッケージの影響度と優先順位

#### 優先度: CRITICAL (CIがビルド失敗する可能性)

1. **libwebkit2gtk-4.1-dev** — Tauri 2.0の中核依存。`webkit2gtk-sys`クレートのコンパイルに必須。CIの`cargo check`がリンクエラーを起こす可能性が高い
2. **libjavascriptcoregtk-4.1-dev** — webkit2gtkの依存パッケージ。コンパイル時に必要
3. **libsoup-3.0-dev** — webkit2gtk-4.1が依存するHTTPライブラリ。ないとpkg-configが失敗する

#### 優先度: HIGH (特定のフィーチャーやテストに影響)

4. **libssl-dev** — `reqwest`クレート（rustls-tlsを使用中だが他の依存が要求する場合あり）
5. **libayatana-appindicator3-dev** — システムトレイ機能に必要。未使用なら影響なし
6. **librsvg2-dev** — SVGアイコン処理。バンドル生成時に必要

#### 優先度: LOW (ubuntu-latestにプリインストール済みの可能性)

7. **build-essential** — GitHub Actionsのubuntu-latestには通常プリインストール済み
8. **curl, wget, file** — 同上。GitHub Actionsランナーに標準搭載

#### 補足: CI特有の追加パッケージ

- **xvfb** — testジョブでのみ使用。ヘッドレスGUIテストに必要。build-ubuntu.shはローカル実行を想定しているため不要

### 推奨: CIに追加すべきパッケージ

```yaml
- name: Install system dependencies
  run: |
    sudo apt-get update
    sudo apt-get install -y \
      libgtk-4-dev \
      libadwaita-1-dev \
      libwebkit2gtk-4.1-dev \
      libjavascriptcoregtk-4.1-dev \
      libsoup-3.0-dev \
      libasound2-dev \
      libayatana-appindicator3-dev \
      librsvg2-dev \
      libssl-dev
```

### 重要な発見: GTK4 vs GTK3の不整合

**CIとbuild-ubuntu.shの両方で`libgtk-4-dev`と`libadwaita-1-dev`を指定しているが、Tauri 2.0はGTK3ベース**であり、GTK4は不要。公式ドキュメントでは以下が指定されている:

```bash
# Tauri 2.0公式の推奨パッケージ（Debian/Ubuntu）
sudo apt install libwebkit2gtk-4.1-dev build-essential curl wget file \
  libxdo-dev libssl-dev libayatana-appindicator3-dev librsvg2-dev
```

`libgtk-4-dev`/`libadwaita-1-dev`はプロジェクト固有の要件（Rustクレートの直接的なGTK4依存等）がない限り不要の可能性がある。Cargo.tomlを確認したところ、明示的なGTK4/libadwaita依存は見当たらない。

さらに、Tauri 2.0公式リストにある**libxdo-dev**が両方のファイルから欠落していることも発見。

---

## タスク2-2: GTK/WebKit2GTKバージョン整合性調査

### 現在の環境（Ubuntu 24.04）のバージョン

| ライブラリ | バージョン |
|---|---|
| GTK 3 (libgtk-3-0t64) | 3.24.41-4ubuntu1.3 |
| GTK 4 (libgtk-4-1) | 4.14.5+ds-0ubuntu0.7 |
| WebKit2GTK 4.1 (libwebkit2gtk-4.1-0) | 2.50.4-0ubuntu0.24.04.1 |
| JavaScriptCoreGTK 4.1 | 2.50.4-0ubuntu0.24.04.1 |
| libsoup 3.0 | 3.4.4-5ubuntu0.7 |
| GLib 2.0 | 2.80.0-6ubuntu3.8 |

### Ubuntu 22.04 vs 24.04でのwebkit2gtk-4.1提供状況

| ディストロ | パッケージ名 | バージョン | リポジトリ |
|---|---|---|---|
| Ubuntu 22.04 (Jammy) | libwebkit2gtk-4.1-dev | 2.50.4-0ubuntu0.22.04.1 | jammy-updates/main |
| Ubuntu 24.04 (Noble) | libwebkit2gtk-4.1-dev | 2.50.4-0ubuntu0.24.04.1 | noble-updates/main |

**結論**: 両バージョンともwebkit2gtk-4.1を提供しており、Tauri 2.0の要件を満たす。22.04のパッケージは初期リリース時はuniverse/universeリポジトリだったが、現在はmainに昇格しセキュリティアップデートも提供されている。

### Tauri 2.0が要求するGTK/WebKitの最低バージョン

| コンポーネント | 最低要件 | Ubuntu 22.04 | Ubuntu 24.04 | 判定 |
|---|---|---|---|---|
| WebKit2GTK | 4.1 API (libsoup3ベース) | 2.36.0+ (初期) → 2.50.4 (更新後) | 2.44.0+ → 2.50.4 | OK |
| GTK | 3.x | 3.24.33 | 3.24.41 | OK |
| GLib | 2.x | 2.72.x | 2.80.0 | OK |
| libsoup | 3.0 | 3.0.x | 3.4.4 | OK |

### リスク評価

- **Ubuntu 22.04**: webkit2gtk-4.1は利用可能だが、初期はuniverseリポジトリだったため、一部のCI環境では明示的にリポジトリを有効化する必要がある場合がある。CIで`ubuntu-latest`を使用している場合は問題なし（2026年3月時点でubuntu-latestは24.04）
- **Ubuntu 24.04**: 問題なし。mainリポジトリから直接提供
- **webkit2gtk-4.0 (旧API)**: Ubuntu 24.04/Debian 13では提供されていないため、Tauri 1.xはこれらのディストロではビルド不可。Tauri 2.0への移行は正しい判断

---

## タスク2-3: Wayland vs X11対応状況調査

### 現在のディスプレイサーバー環境

| 環境変数 | 値 |
|---|---|
| WAYLAND_DISPLAY | (空 = Waylandではない) |
| XDG_SESSION_TYPE | x11 |
| GDK_BACKEND | (未設定 = 自動選択) |
| XDG_CURRENT_DESKTOP | ubuntu:GNOME |
| loginctl Type | x11 |

**結論**: 現在の環境はX11セッションで動作中。

### Tauri 2.0のWayland対応状況

| 機能 | X11 | Wayland | 備考 |
|---|:---:|:---:|---|
| ウィンドウ表示 | OK | OK | 基本動作は両方サポート |
| ウィンドウドラッグ | OK | OK | tao 0.30.3で修正済み |
| ウィンドウリサイズ | OK | OK | tao 0.30.3で修正済み |
| システムトレイ | OK | 部分的 | Waylandではdeb/dev時にアイコン欠落の報告あり(Issue #14234) |
| WebRTC | OK | NG | GBMフォーマットエラーの報告あり |
| `tauri dev`起動 | OK | 問題あり | "Failed to initialize gtk backend!" エラーの報告(Issue #13414) |

### 既知のWayland問題

1. **システムトレイ**: AppImageでは動作するが、debパッケージとdev modeでアイコンが表示されない（X11では正常）
2. **GTKバックエンド初期化失敗**: Wayland環境で`tauri dev`実行時にGTKバックエンド初期化エラーが発生するケースあり
3. **WebRTC非対応**: WebKit2GTKのWebRTCはX11でのみ動作。Waylandではスクリーンキャプチャ等にPipeWire/XDG Desktop Portalを使用するが、getUserMediaのカメラ/マイクアクセスはX11前提

### CIでのxvfb-run使用の妥当性評価

**結論: 妥当である。**

理由:
1. **CIはヘッドレス環境**: GitHub ActionsのUbuntuランナーにはディスプレイサーバーがない。GTK依存のテストには仮想ディスプレイが必須
2. **X11が確実に動作**: Tauri 2.0のX11サポートは安定しており、xvfb-runでの仮想X11環境は信頼性が高い
3. **Waylandの代替は不成熟**: CI上でWaylandコンポジタ(weston等)をセットアップする方法は複雑で、テストの安定性が低い
4. **xvfb未インストール問題**: ただし、CI定義のcheck/clippyジョブにはxvfbが含まれていないため、GTK初期化が必要なテストがこれらのジョブに入った場合に失敗する

**推奨**:
- testジョブでxvfb-runを使用する現状は適切
- check/clippyジョブでもxvfbをインストールしておくと安全（GTKライブラリの初期化がチェック時に走る場合への備え）

---

## タスク2-4: オーディオサブシステム検証（Linux固有部分）

### 現在のオーディオスタック構成

```
アプリケーション
    │
    ├── PulseAudio API → pipewire-pulse (PulseAudio互換デーモン)
    │                          │
    ├── ALSA API ──────→ pipewire-alsa (ALSA互換プラグイン)
    │                          │
    └── JACK API ──────→ PipeWire (メディアフレームワーク)
                               │
                         ALSA カーネルドライバ
                               │
                         HDA Intel PCH (ALC887-VD)
```

### インストール済みパッケージ

| パッケージ | バージョン | 役割 |
|---|---|---|
| pipewire | 1.0.5-1ubuntu3.2 | メディアフレームワーク本体 |
| pipewire-pulse | 1.0.5-1ubuntu3.2 | PulseAudio互換レイヤー |
| pipewire-alsa | 1.0.5-1ubuntu3.2 | ALSA互換レイヤー |
| pipewire-audio | 1.0.5-1ubuntu3.2 | オーディオサポート |
| wireplumber | 0.4.17-1ubuntu4.1 | セッション/ポリシーマネージャ |
| libasound2t64 | 1.2.11-1ubuntu0.2 | ALSAランタイム |
| libasound2-dev | 1.2.11-1ubuntu0.2 | ALSA開発ヘッダ |
| libpulse0 | 16.1+dfsg1-2ubuntu10.1 | PulseAudioクライアントライブラリ |

### libasound2-devの役割とWebRTC getUserMediaとの関係

#### libasound2-devの役割
- **ALSA (Advanced Linux Sound Architecture)** のCヘッダとリンクライブラリを提供
- Rustクレート`cpal`（クロスプラットフォームオーディオライブラリ）や`rodio`等がLinuxでALSA APIを直接使用する際に必要
- コンパイル時のみ必要（ランタイムにはlibasound2のみ必要）

#### WebRTC getUserMediaとの関係

```
getUserMedia() 呼び出し
    │
    ▼
WebKit2GTK (WebRTC実装)
    │
    ├── GStreamerパイプライン
    │     ├── pulsesrc (PulseAudio経由の音声入力)
    │     └── v4l2src (カメラ入力)
    │
    ▼
PipeWire / PulseAudio
    │
    ▼
ALSA カーネルインターフェース
```

**重要な発見**:
1. **WebKit2GTKのWebRTC実装はGStreamer経由でオーディオにアクセス**する。直接ALSAを使用しない。したがって`libasound2-dev`はWebRTCのgetUserMediaには直接必要ない
2. ただし、MeshChatプロジェクトのRust側で独自のオーディオ処理（`cpal`クレート等）を使用している場合、`libasound2-dev`はコンパイルに必須
3. **CIでのlibasound2-dev**: 現在CIに含まれているのは妥当。Rustコードのコンパイルに必要な可能性がある

#### WebRTC getUserMediaの動作要件（Linux）

| 要件 | 状況 |
|---|---|
| WebKit2GTKのWebRTC有効化 | コンパイル時フラグ必要。Ubuntu標準パッケージでは**無効**の場合あり |
| GStreamer bad plugins | webrtcbin/webrtcdsp用に必要。`gst-plugins-bad`パッケージ |
| PulseAudio/PipeWire | 音声入力にpulsesrcが必要。現環境はPipeWire+pipewire-pulseで対応済み |
| パーミッションハンドラ | Tauri側で明示的な許可コードが必要（デフォルトは拒否） |
| X11環境 | Wayland環境ではWebRTCが正常動作しない報告あり |

**リスク**: Ubuntu標準のwebkit2gtkパッケージでWebRTCが有効かどうかは未確認。カスタムビルドが必要な場合、CIとデプロイの複雑さが大幅に増加する。

---

## タスク2-5: CSP connect-srcのLinux環境動作確認

### 現在のCSP設定（tauri.conf.json）

```
default-src 'self';
script-src 'self';
style-src 'self' 'unsafe-inline';
img-src 'self' data:;
connect-src 'self'
  http://127.0.0.1:8000
  ws://localhost:*
  wss://localhost:*
  https://localhost:*
  http://133.167.108.151:8080
  http://153.120.64.29
  http://153.120.64.29:80
  ws://153.120.64.29
  ws://153.120.64.29:80
  wss://*.because-and.com
  https://*.because-and.com;
font-src 'self' data:;
```

### tauri://localhost スキームのLinuxでの扱い

#### Tauri 2.0のIPC/カスタムプロトコル体系

| プラットフォーム | フロントエンドURL | IPCプロトコル |
|---|---|---|
| Windows | http://tauri.localhost/ | http://ipc.localhost/ |
| macOS | tauri://localhost/ | ipc://localhost/ |
| Linux | tauri://localhost/ (カスタムプロトコル) | ipc://localhost/ |
| Android | http://tauri.localhost/ | http://ipc.localhost/ |
| iOS | tauri://localhost/ | ipc://localhost/ |

#### Linux固有の考慮事項

1. **カスタムプロトコルIPC**: Tauri 2.0ではLinuxでもカスタムプロトコルIPCが標準で有効化されている（PR #10840）。以前はpostMessage経由のフォールバックが使われていた

2. **CSPにおける`'self'`の解釈**:
   - `'self'`はフロントエンドのオリジン（`tauri://localhost`）を指す
   - connect-srcの`'self'`によりTauriコマンド（IPC）への接続は許可される
   - ただし、**`ipc://localhost`が明示的にconnect-srcに含まれていない**

3. **潜在的なCSP問題**:
   - IPCが`ipc://localhost`を使用する場合、CSPの`connect-src`に`ipc:`スキームを追加する必要がある可能性がある
   - 現在の設定では`'self'`のみでIPC接続をカバーしている前提だが、エラー「Refused to connect to ipc://localhost/...」が発生するケースが報告されている（Issue #12835）

### CSP設定の評価

#### 問題点

| # | 問題 | 影響度 | 説明 |
|---|---|:---:|---|
| 1 | `ipc:` スキーム未記載 | MEDIUM | Linux/macOSでIPC通信がCSPでブロックされる可能性。`'self'`でカバーされる場合もあるが、明示的に追加した方が安全 |
| 2 | ハードコードされたIPアドレス | LOW | 133.167.108.151:8080, 153.120.64.29 がCSPに直接記載。環境依存でありLinux固有問題ではないが、デプロイ環境の差異に注意 |
| 3 | WebSocket通信のCSP | LOW | `ws://localhost:*`は開発用として妥当だが、本番ではwss://のみに制限すべき |

#### 推奨CSP修正（IPC関連のみ）

```json
"connect-src": "ipc: http://ipc.localhost 'self' http://127.0.0.1:8000 ws://localhost:* wss://localhost:* https://localhost:* ..."
```

`ipc:`と`http://ipc.localhost`を追加することで、Windows/macOS/Linux全プラットフォームでIPCが確実に動作する。

---

## 総括

### 発見事項の優先順位

| 優先度 | タスク | 発見 | 推奨アクション |
|---|---|---|---|
| CRITICAL | 2-1 | CIにwebkit2gtk/soup/jscoregtk不足 | 即座にCIのパッケージリストを更新 |
| HIGH | 2-1 | GTK4/libadwaita指定が不要の可能性 | Tauri 2.0はGTK3ベース。要確認の上削除検討 |
| HIGH | 2-1 | libxdo-dev が両方から欠落 | Tauri 2.0公式要件。追加を推奨 |
| MEDIUM | 2-5 | CSPにipc:スキーム未記載 | IPC通信の信頼性向上のため追加推奨 |
| MEDIUM | 2-3 | Wayland環境でのシステムトレイ/WebRTC問題 | 短期的にはX11推奨。長期的にWayland対応追跡 |
| MEDIUM | 2-4 | WebRTCのWebKit2GTK有効化状況が不明 | Ubuntu標準パッケージでの有効状況を実機テストで確認すべき |
| LOW | 2-3 | CIのxvfb使用 | 現状妥当。変更不要 |
| LOW | 2-2 | Ubuntu 22.04/24.04互換性 | 両方でwebkit2gtk-4.1利用可能。問題なし |

### 即座に対応すべき事項

1. **CIのパッケージリスト統一** — build-ubuntu.shと同等のパッケージをCI全ジョブに追加
2. **GTK4依存の確認** — 本当にlibgtk-4-dev/libadwaita-1-devが必要か、Cargo.tomlの依存ツリーで確認
3. **CSP設定へのipc:追加** — Linux/macOSでのIPC安定動作のため

---

*Report generated by Worker2 - Phase 2 Linux Investigation*
*Sources: Tauri 2.0 Documentation, Ubuntu Package Repositories, GitHub Issues*
