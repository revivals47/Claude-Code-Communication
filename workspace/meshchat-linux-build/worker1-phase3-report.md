# Worker1 フェーズ3調査レポート: パッケージング検証
**日時**: 2026-03-15
**対象**: /home/ken/Documents/meshchat-desktop-Rust

---

## タスク3-1: debパッケージ設定の調査

### 現在のbundle設定

```json
"bundle": {
    "active": true,
    "targets": ["deb", "appimage"],
    "icon": ["icons/icon.png"],
    "resources": [],
    "copyright": "Copyright 2026 MeshChat Contributors",
    "category": "Productivity"
}
```

### Tauri 2.0で利用可能なdeb設定項目（`bundle.linux.deb`）

| フィールド | 型 | 現在の設定 | 状態 |
|-----------|---|-----------|------|
| `depends` | `Vec<String>` | 未設定 | **要検討** |
| `recommends` | `Vec<String>` | 未設定 | 任意 |
| `provides` | `Vec<String>` | 未設定 | 任意 |
| `conflicts` | `Vec<String>` | 未設定 | 任意 |
| `replaces` | `Vec<String>` | 未設定 | 任意 |
| `section` | `String` | 未設定 | **要設定** |
| `priority` | `String` | デフォルト`"optional"` | OK |
| `files` | `HashMap` | 未設定 | 任意 |
| `desktopTemplate` | `PathBuf` | 未設定（自動生成） | OK |
| `changelog` | `PathBuf` | 未設定 | 任意 |
| `preInstallScript` | `PathBuf` | 未設定 | 任意 |
| `postInstallScript` | `PathBuf` | 未設定 | 任意 |
| `preRemoveScript` | `PathBuf` | 未設定 | 任意 |
| `postRemoveScript` | `PathBuf` | 未設定 | 任意 |

### bundle共通フィールドの不足項目

| フィールド | 型 | 現在の設定 | 状態 |
|-----------|---|-----------|------|
| `shortDescription` | `String` | 未設定 | **要設定**（.desktopのComment、パッケージ概要に使用） |
| `longDescription` | `String` | 未設定 | **推奨**（パッケージ詳細説明に使用） |
| `license` | `String` | 未設定 | **推奨**（SPDXライセンス識別子） |
| `licenseFile` | `PathBuf` | 未設定 | 任意 |
| `homepage` | `String` | 未設定 | **推奨** |
| `publisher` | `String` | 未設定 | 任意 |

### 不足している設定のリストと推奨値

#### 必須レベル（P1）

1. **`shortDescription`** — パッケージ概要と.desktopファイルのCommentに使用
   - 推奨値: `"Decentralized P2P Chat Application"`

2. **`section`** — Debianアーカイブのサブセクション
   - 推奨値: `"net"`（ネットワーク系アプリ）または `"comm"`（通信系アプリ）

3. **`depends`** — ランタイム依存パッケージ
   - Tauriが自動追加するもの: `libwebkit2gtk-4.1-0`, `libgtk-3-0`
   - 手動追加推奨:
     ```json
     "depends": [
       "libssl3",
       "libasound2",
       "libayatana-appindicator3-1"
     ]
     ```
   - 注意: Tauriは基本的な依存を自動検出するが、アプリ固有の依存（ALSA、AppIndicator等）は明示が安全

#### 推奨レベル（P2）

4. **`longDescription`** — パッケージ詳細説明
   - 推奨値: `"MeshChat is a decentralized peer-to-peer chat application with end-to-end encryption, voice/video calls, and volunteer super peer architecture."`

5. **`license`** — SPDXライセンス識別子
   - Cargo.tomlに`"MIT OR Apache-2.0"`と記載あり → `"MIT OR Apache-2.0"`

6. **`homepage`** — アプリケーションURL
   - 推奨値: MeshChatの公式URLを設定

### dpkg -I 検査チェックリスト

ビルド後に以下を検証:

```bash
# 1. パッケージ基本情報
dpkg -I target/release/bundle/deb/mesh-chat_0.1.0_amd64.deb

# チェック項目:
# [ ] Package名が正しい（mesh-chat）
# [ ] Version: 0.1.0
# [ ] Architecture: amd64
# [ ] Maintainer: が設定されている
# [ ] Description: が空でない
# [ ] Section: が設定されている（net または comm）
# [ ] Depends: にlibwebkit2gtk-4.1-0が含まれる
# [ ] Installed-Size: が妥当（通常10-50MB）

# 2. パッケージ内容
dpkg -c target/release/bundle/deb/mesh-chat_0.1.0_amd64.deb

# チェック項目:
# [ ] /usr/bin/ にバイナリが存在
# [ ] /usr/share/applications/ に.desktopファイルが存在
# [ ] /usr/share/icons/ にアイコンファイルが存在
# [ ] 不要なファイルが含まれていない

# 3. .desktopファイル検証
dpkg -c ... | grep .desktop
# 展開して内容確認:
# [ ] Name= が "MeshChat"
# [ ] Exec= がバイナリパスを指す
# [ ] Icon= が正しいアイコン名
# [ ] Categories= が設定されている
# [ ] Terminal=false

# 4. インストールテスト（安全な環境で）
sudo dpkg -i target/release/bundle/deb/mesh-chat_0.1.0_amd64.deb
# [ ] インストールエラーなし
# [ ] 依存関係エラーなし
which mesh-chat || which tauri_app
# [ ] バイナリにPATHが通る
# [ ] アプリケーションメニューに表示される
```

---

## タスク3-2: AppImage設定の調査

### Tauri 2.0 AppImage設定（`bundle.linux.appimage`）

| フィールド | 型 | 現在の設定 | 説明 |
|-----------|---|-----------|------|
| `bundleMediaFramework` | `bool` | 未設定(デフォルト`false`) | GStreamer依存をバンドル。音声/動画再生に必要な場合のみ |
| `files` | `HashMap` | 未設定 | AppImage内に追加ファイルを含める |

現在の設定ではAppImage固有の設定は一切なし。基本的なAppImage生成には問題ないが、以下の点を調査。

### libfuse2依存問題

#### Ubuntu 24.04での状況

```
libfuse2t64:amd64  2.9.9-8.1build1  ✅ インストール済み
libfuse3-3:amd64   3.14.0-5build1   ✅ インストール済み
fuse3              3.14.0-5build1   ✅ インストール済み
libfuse-dev:amd64  2.9.9-8.1build1  ✅ インストール済み
```

#### 問題分析

| Ubuntu版 | libfuse2 | 状態 |
|---------|----------|------|
| 20.04 | `libfuse2` デフォルトインストール | 問題なし |
| 22.04 | `libfuse2` デフォルトインストール | 問題なし |
| 24.04 | `libfuse2t64` に名前変更、**デフォルトではインストールされない** | **要注意** |

- Ubuntu 24.04ではFUSE 3がデフォルト。FUSE 2は`libfuse2t64`パッケージとして提供されるが、明示的インストールが必要
- **現環境では`libfuse2t64`がインストール済み**のため、AppImageの実行は可能
- しかし、ユーザーの環境ではインストールされていない可能性がある

#### AppImageの実行方式

AppImageには2つの実行方式がある:

1. **FUSEマウント方式（デフォルト）**: `libfuse2`が必要。ファイルシステムとしてマウントして実行
2. **extract-and-run方式（フォールバック）**: `--appimage-extract-and-run`フラグ、または環境変数`APPIMAGE_EXTRACT_AND_RUN=1`で実行。FUSEが不要

#### 推奨対応

```bash
# ユーザー向けドキュメントに記載すべき内容:

# 方法1: libfuse2をインストール（推奨）
sudo apt install libfuse2t64  # Ubuntu 24.04
sudo apt install libfuse2     # Ubuntu 22.04以前

# 方法2: FUSEなしで実行（代替）
./MeshChat.AppImage --appimage-extract-and-run

# 方法3: 環境変数で恒久設定
export APPIMAGE_EXTRACT_AND_RUN=1
./MeshChat.AppImage
```

### サンドボックス制約の調査

AppImageはサンドボックスを持たない（通常のネイティブアプリと同等の権限で動作）。ただし以下の制約が存在:

1. **Firejail/Bubblewrap連携**: 一部ディストリビューションではAppImageをサンドボックス内で実行する設定が可能だが、Tauri側で特別な対応は不要

2. **Snap/Flatpak環境との競合**: Snap/Flatpakで配布されたアプリからAppImageを呼び出す場合、サンドボックスによるファイルアクセス制限がありうる。MeshChatの場合は直接実行が前提なので問題なし

3. **AppArmor**: Ubuntu 24.04のAppArmorポリシーはAppImageの実行を通常ブロックしない。ただし`unprivileged_userns_clone`が制限されている環境では一部機能に影響しうる

4. **ネットワークアクセス**: AppImage自体にはネットワーク制限なし。MeshChatのP2P通信（WebSocket、HTTP）は通常通り動作

### MeshChat固有の注意点

MeshChatは音声/動画機能を持つため、`bundleMediaFramework`の設定を検討:
- 現時点では`WebRTC`はブラウザ（WebKitGTK）内で処理されるため、追加のGStreamerバンドルは不要と推定
- ただし、ネイティブの音声処理が必要になった場合は`true`に変更が必要

---

## タスク3-3: アイコン・デスクトップ統合の調査

### 現在のアイコン状況

| 項目 | 値 |
|------|---|
| ファイル | `icons/icon.png` |
| サイズ | 128x128 px |
| ファイルサイズ | 1,387 bytes (1.4KB) |
| フォーマット | PNG, 8-bit/color RGBA, non-interlaced |
| 色深度 | 32bit (8bit x RGBA) |
| 内容 | 青い吹き出しに白い "M" の文字 |

### Tauri 2.0が要求するアイコンフォーマット・サイズ

| ファイル名 | サイズ | 用途 | 現状 |
|-----------|--------|------|------|
| `32x32.png` | 32x32 px | タスクバー・小サイズ表示 | **未作成** |
| `128x128.png` | 128x128 px | 標準アプリケーションアイコン | ✅ 存在（icon.pngとして） |
| `128x128@2x.png` | 256x256 px | HiDPI表示 | **未作成** |
| `icon.png` | 512x512 px以上推奨 | マスターアイコン・ストア用 | **⚠️ 128x128しかない** |

### 問題点

1. **マスターアイコンが小さすぎる（重大）**
   - 現在128x128px、推奨は512x512px以上（理想は1024x1024px）
   - 128pxから32pxへの縮小は問題ないが、512pxへの拡大は画質劣化
   - ストア掲載やHiDPIディスプレイでぼやけて表示される

2. **複数サイズ未生成**
   - `tauri icon`コマンドで自動生成可能だが、ソースが128pxでは品質不足
   - 設定の`"icon": ["icons/icon.png"]`は単一ファイル指定のみ

3. **ファイルサイズが極端に小さい（1.4KB）**
   - 128x128 RGBAのPNGとしては非常に小さい（通常5-20KB）
   - シンプルなデザインのため圧縮率が高いが、品質は限定的

### Tauri アイコン生成コマンド

```bash
# 高解像度ソースアイコン（512x512以上）から全サイズを自動生成
cargo tauri icon path/to/source-icon-512.png

# 生成されるファイル:
# icons/32x32.png
# icons/128x128.png
# icons/128x128@2x.png
# icons/icon.png (512x512)
# icons/icon.icns (macOS用)
# icons/icon.ico (Windows用)
```

### .desktopファイルの自動生成

Tauriはdebパッケージ生成時に`.desktop`ファイルを自動生成する。

**自動生成される内容（推定）**:
```ini
[Desktop Entry]
Categories=Office;
Exec=mesh-chat
Icon=com.meshchat.app
Name=MeshChat
Terminal=false
Type=Application
```

**現在の設定から生成される値**:
| フィールド | ソース | 値 |
|-----------|--------|---|
| `Name` | `productName` | `MeshChat` |
| `Exec` | バイナリ名 | `tauri_app`（※要確認）|
| `Icon` | `identifier` | `com.meshchat.app` |
| `Categories` | `bundle.category` = `"Productivity"` | `Office;`（freedesktopマッピング） |
| `Comment` | `bundle.shortDescription` | **未設定（空）** |

**注意点**:
- `Comment`が空になる — `shortDescription`を設定すべき
- `Categories`が`"Productivity"` → `"Office;"`にマッピングされるが、チャットアプリとしては`"Network;InstantMessaging;"`が適切
- `Exec`がバイナリ名`tauri_app`になる可能性 — `productName`から`mesh-chat`等に変換されるか要検証
- カスタム`.desktop`テンプレートで`MimeType=x-scheme-handler/meshchat`を追加すればカスタムURLスキーム対応も可能

### Linux各ディストロでのアイコン表示要件

| ディストリビューション | デスクトップ環境 | アイコンテーマ | 最低サイズ | 推奨サイズ |
|---------------------|----------------|--------------|-----------|-----------|
| Ubuntu 22.04/24.04 | GNOME 42/46 | Yaru | 48x48 | 256x256+ |
| Fedora 39/40 | GNOME 45/46 | Adwaita | 48x48 | 256x256+ |
| Linux Mint 21/22 | Cinnamon | Mint-Y | 48x48 | 256x256+ |
| Debian 12 | GNOME 43 | Adwaita | 48x48 | 256x256+ |
| KDE Plasma 6 | KDE | Breeze | 48x48 | 256x256+ |

共通要件:
- **最低**: 48x48px（アプリケーションメニューで識別可能な最小サイズ）
- **推奨**: 256x256px以上（HiDPI対応、アプリグリッド表示）
- **理想**: 512x512px（将来のHiDPIスケーリングに対応）
- **フォーマット**: PNG（RGBA、透過対応）

---

## タスク3-4: updaterプラグインの状態確認

### 現在の設定

```json
"plugins": {
    "updater": {
        "endpoints": [
            "https://updates.meshchat.app/{{target}}/{{arch}}/{{current_version}}"
        ],
        "dialog": false,
        "pubkey": ""
    }
}
```

### 設定分析

| 項目 | 値 | 状態 |
|------|---|------|
| `endpoints` | `https://updates.meshchat.app/...` | **エンドポイントURL未稼働の可能性大** |
| `dialog` | `false` | OK（カスタムUI使用） |
| `pubkey` | `""` (空文字列) | **⚠️ 要対応** |

### pubkeyが空の状態でのビルドへの影響

1. **ビルド自体は成功する** — `pubkey`が空でもコンパイルエラーにはならない
2. **実行時の動作**:
   - `tauri-plugin-updater`プラグインは初期化される（main.rsの295行目で`.plugin(tauri_plugin_updater::Builder::new().build())`）
   - `check_for_updates`コマンド呼び出し時、エンドポイントへのリクエストは試行される
   - エンドポイントが存在しない場合: HTTPエラーが返り、`"Update check failed"`エラーとしてフロントエンドに伝播
   - エンドポイントがレスポンスを返した場合: `pubkey`が空だとアップデートの署名検証に失敗する可能性がある

3. **Tauri 2.0のupdater署名検証**:
   - Tauri 2.0では更新パッケージの署名検証が**必須**
   - `pubkey`が空の場合、updaterの初期化時にwarningが出る可能性はあるが、check/installを呼ばなければ問題にならない
   - `dialog: false`なので自動ダイアログは出ない → フロントエンドが明示的に呼び出さない限り影響なし

### updater実装の状態確認

**updater.rs** (`crates/meshchat-desktop/src/bin/tauri_app/updater.rs`):
- 3つのIPCコマンドが実装済み:
  - `check_for_updates`: エンドポイントにアップデート確認
  - `get_current_version`: 現在のバージョン取得
  - `install_update`: ダウンロード＆インストール（進捗イベント付き）
- `PendingUpdate`ステートでアップデート情報を保持する設計
- エラーハンドリングあり（失敗時にStringエラーを返す）

**capabilities/default.json**:
- `"updater:default"` パーミッションが設定済み → IPCからupdater機能へのアクセスは許可されている

**main.rs**:
- `tauri_plugin_updater::Builder::new().build()` でプラグイン登録済み
- `updater::PendingUpdate` ステートも登録済み

### Linux版自動更新の仕組み

#### AppImage更新

Tauri 2.0のupdaterはLinuxではAppImageの更新をサポート:

1. エンドポイントからJSON応答を受信:
   ```json
   {
     "version": "0.2.0",
     "url": "https://releases.meshchat.app/MeshChat_0.2.0_amd64.AppImage.tar.gz",
     "signature": "Base64エンコードされた署名",
     "notes": "リリースノート"
   }
   ```

2. AppImage.tar.gzをダウンロード
3. 署名を`pubkey`で検証
4. 現在のAppImageを置換
5. アプリを再起動

#### deb更新

- Tauri 2.0のupdaterは**debパッケージの自動更新をサポートしない**
- debの場合はAPTリポジトリ経由が一般的
- debユーザーへの更新はリポジトリ設定またはWebサイトからのダウンロードが必要

### 推奨対応

| 優先度 | 対応 | 理由 |
|--------|------|------|
| **P2** | `pubkey`を設定するか、updater設定を一時的に無効化 | 空のpubkeyは本番品質として不適切 |
| **P3** | エンドポイントURLの有効性確認 | `updates.meshchat.app`が実在するか |
| **P3** | updater機能の段階的実装計画 | v0.1.0では無効化し、v0.2.0以降で正式対応も選択肢 |

#### updater無効化の方法（v0.1.0リリース時の暫定対応案）

方法1: tauri.conf.jsonからplugins.updaterセクションを削除
方法2: フロントエンドからcheck_for_updatesを呼ばない
方法3: エンドポイントを空配列にする → `"endpoints": []`

※方法2が最も低リスク（設定変更不要、フロントエンド側のみ）

---

## 総合まとめ

### 優先度順の対応事項

| 優先度 | 問題 | カテゴリ | 修正工数 |
|--------|------|---------|---------|
| **P1** | マスターアイコンが128x128で小さすぎる | アイコン | デザイナー作業（30分〜） |
| **P1** | `shortDescription`未設定 → .desktopのComment空 | deb設定 | 2分 |
| **P1** | `bundle.category`が`"Productivity"`→チャットアプリに不適切 | deb設定 | 2分 |
| **P2** | `section`未設定（deb） | deb設定 | 1分 |
| **P2** | `depends`の明示的設定なし | deb設定 | 5分 |
| **P2** | `pubkey`が空のままupdater有効 | updater | 10分 |
| **P2** | 複数アイコンサイズ未生成（32x32, 256x256） | アイコン | 5分（ソースがあれば） |
| **P3** | `longDescription`未設定 | deb設定 | 2分 |
| **P3** | `license`未設定（Cargo.tomlには記載あり） | deb設定 | 1分 |
| **P3** | AppImage libfuse2依存のドキュメント作成 | AppImage | 10分 |
| **P4** | `bundleMediaFramework`の必要性判断 | AppImage | 調査5分 |

### 推奨するtauri.conf.json bundle設定（修正案）

```json
"bundle": {
    "active": true,
    "targets": ["deb", "appimage"],
    "icon": [
        "icons/32x32.png",
        "icons/128x128.png",
        "icons/128x128@2x.png",
        "icons/icon.png"
    ],
    "resources": [],
    "copyright": "Copyright 2026 MeshChat Contributors",
    "category": "Network",
    "shortDescription": "Decentralized P2P Chat Application",
    "longDescription": "MeshChat is a decentralized peer-to-peer chat application with end-to-end encryption, voice/video calls, and volunteer super peer architecture.",
    "license": "MIT OR Apache-2.0",
    "linux": {
        "deb": {
            "section": "net",
            "depends": [
                "libssl3",
                "libasound2"
            ]
        },
        "appimage": {
            "bundleMediaFramework": false
        }
    }
}
```

### dpkg -I 検査チェックリスト（ビルド後に実行）

```
[ ] Package名が正しい
[ ] Version: 0.1.0
[ ] Architecture: amd64
[ ] Section: net
[ ] Description: が空でない
[ ] Depends: にlibwebkit2gtk-4.1-0が含まれる
[ ] /usr/bin/ にバイナリが存在
[ ] /usr/share/applications/ に.desktopファイルが存在
[ ] /usr/share/icons/ にアイコンファイルが存在
[ ] .desktopファイルのCategories, Name, Execが正しい
[ ] インストール・起動テスト成功
```

### AppImage検証チェックリスト（ビルド後に実行）

```
[ ] AppImageファイルが生成されている
[ ] 実行権限が付与されている（chmod +x）
[ ] FUSEマウント方式で起動可能
[ ] --appimage-extract-and-run で起動可能（FUSEフォールバック）
[ ] アプリが正常に動作する（ウィンドウ表示、ネットワーク通信）
[ ] ファイルサイズが妥当（通常50-150MB）
```
