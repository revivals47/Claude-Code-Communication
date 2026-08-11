# Worker1 フェーズ1調査レポート: ビルド環境の正常化
**日時**: 2026-03-15
**対象**: /home/ken/Documents/meshchat-desktop-Rust

---

## タスク1-1: beforeDevCommand クロスプラットフォーム対応分析

### 2つのtauri.conf.jsonの差分

| 項目 | ルート (`/tauri.conf.json`) | crates側 (`/crates/meshchat-desktop/tauri.conf.json`) |
|------|---------------------------|------------------------------------------------------|
| beforeDevCommand | `nohup bash ./start-static-server.sh > /tmp/http-server.log 2>&1 & sleep 1` | `nohup bash /Users/ken/Desktop/meshchat-desktop-Rust/start-static-server.sh > /tmp/http-server.log 2>&1 & sleep 2` |
| frontendDist | `./src-tauri-ui` | `../../src-tauri-ui` |
| sleep値 | 1秒 | 2秒 |
| その他 | 全項目同一 | 全項目同一 |

### 問題点

1. **Mac絶対パスのハードコード（重大）**
   - crates側6行目: `/Users/ken/Desktop/meshchat-desktop-Rust/start-static-server.sh`
   - Linux環境では該当パスが存在せず、`cargo tauri dev`時にbeforeDevCommandが失敗する
   - Mac環境でもディレクトリ移動すれば壊れるため、根本的に不適切

2. **frontendDistパスの不整合**
   - ルート: `./src-tauri-ui`（ルート基準の相対パス）
   - crates: `../../src-tauri-ui`（crates/meshchat-desktop基準の相対パス）
   - 実質同じ場所を指すが、どちらのconfigが使われるかで解決先が変わる

3. **sleep値の差異（軽微）**
   - ルート: 1秒、crates: 2秒。機能上の問題は少ないが統一すべき

### 修正方針
- **ルート側を正とする** — 相対パスで記述されており、環境非依存
- crates側は削除し、Tauri CLIがルート側のみ参照する構成に統一

---

## タスク1-2: tauri.conf.json 二重定義問題の調査

### Tauri CLIの設定ファイル解決ロジック（v2）

Tauri v2では設定ファイルの参照元が**2箇所**あり、それぞれ異なるタイミングで読まれる:

| フェーズ | 実行者 | 参照する設定ファイル |
|---------|--------|---------------------|
| CLIコマンド実行時 | `cargo tauri dev/build` | カレントディレクトリの`tauri.conf.json`を優先。なければTauriクレートのディレクトリを探索 |
| Rustコンパイル時 | `tauri_build::build()` (build.rs) | Cargo.tomlがあるクレートディレクトリ (`crates/meshchat-desktop/tauri.conf.json`) |

### 現状の動作確認

`cargo tauri info`をプロジェクトルートで実行した結果:
```
frontendDist: ./src-tauri-ui
```
→ **ルート側の設定を読んでいる**ことを確認

しかし、`tauri_build::build()`はコンパイル時に`crates/meshchat-desktop/tauri.conf.json`を読む。これにより:
- **CLIレベル**: ルートのconfigが使われる（beforeDevCommand等）
- **ビルドレベル**: cratesのconfigが使われる（CSPやウィンドウ設定の埋め込み）

### 問題点

1. **設定の二重管理** — 変更時に両方更新する必要があり、不整合のリスクが常に存在
2. **ビルドとDevで異なるconfig** — CLIがルートを、build.rsがcratesを読むため、挙動の差異が発生しうる
3. **beforeDevCommandの不整合** — CLIはルート側を実行するが、cratesのbuild.rsにはMac絶対パスが残る

### ルート側を正とした場合の統一手順（提案）

**方法A: crates側を削除し、symlinkで置換（推奨）**
```bash
cd /home/ken/Documents/meshchat-desktop-Rust
rm crates/meshchat-desktop/tauri.conf.json
ln -s ../../tauri.conf.json crates/meshchat-desktop/tauri.conf.json
```
- メリット: 設定ファイルが物理的に1つになり、不整合が原理的に発生しない
- 注意: `tauri_build::build()`がsymlinkを正しく辿れるか要検証（通常は問題なし）
- 注意: frontendDistのパスはルート基準(`./src-tauri-ui`)だが、build.rsはcrates基準で解決するため、`../../src-tauri-ui`とする必要がある可能性あり → symlinkだとパス解決が変わりうるので検証必須

**方法B: crates側を削除し、CLIの`--config`オプションで明示指定**
```bash
cd /home/ken/Documents/meshchat-desktop-Rust
rm crates/meshchat-desktop/tauri.conf.json
# dev/buildコマンドに--configを付与
cargo tauri dev --config ./tauri.conf.json
cargo tauri build --config ./tauri.conf.json
```
- メリット: 明示的で確実
- デメリット: 毎回オプション指定が必要（スクリプト化で緩和可能）

**方法C: ルート側を削除し、crates側を修正して唯一の正とする**
```bash
rm /home/ken/Documents/meshchat-desktop-Rust/tauri.conf.json
# crates側のbeforeDevCommandを相対パスに修正
# frontendDistは ../../src-tauri-ui のまま
```
- メリット: Tauri標準の配置に準拠（クレートディレクトリに配置）
- デメリット: beforeDevCommandの相対パスがcrates基準になり、やや非直感的

**推奨: 方法A（symlink）を第一候補、動作検証で問題があれば方法Bにフォールバック**

### Cargo.toml関連設定の確認結果

- **ワークスペースCargo.toml** (`/Cargo.toml`): `[workspace]`定義のみ、Tauri固有設定なし
- **クレートCargo.toml** (`/crates/meshchat-desktop/Cargo.toml`):
  - `tauri = { version = "2.0" }` — Tauri v2
  - `tauri-build = { version = "2.0" }` (build-dependencies)
  - バイナリ: `tauri_app` (`src/bin/tauri_app/main.rs`)
- **Tauri.toml**: 存在しない（追加設定なし）
- **.cargo/config.toml**: 存在しない

---

## タスク1-3: start-static-server.sh Linux互換性確認

### スクリプト内容分析

```bash
#!/bin/bash
cd "$(dirname "$0")"
lsof -ti:8001 | xargs kill -9 2>/dev/null || true
sleep 0.5
cd src-tauri-ui
python3 -c "..." &
```

### Linux互換性チェック結果

| 項目 | 状態 | 詳細 |
|------|------|------|
| `lsof -ti:8001` | **要注意** | Linuxでは動作するが、出力フォーマットがMacと若干異なる場合あり。ただし`-t`(tidのみ出力)と`-i:port`はLinuxでも正常動作を確認 |
| `xargs kill -9` | OK | Linux標準で問題なし |
| `sleep 0.5` | OK | GNU coreutilsは小数対応 |
| `python3` | OK | `/usr/bin/python3` (3.12.3)存在確認済み |
| `cd "$(dirname "$0")"` | OK | POSIX互換、Linux問題なし |
| `http.server` / `socketserver` | OK | Python標準ライブラリ、追加インストール不要 |

### Linux環境での検証結果
```
lsof: /usr/bin/lsof (version 4.95.0) ✅
python3: /usr/bin/python3 (3.12.3) ✅
```

### 潜在的問題点

1. **lsofの`-t`オプション** — Linux版lsof 4.95.0では正常動作するが、一部の古いLinuxディストリビューション(lsof 4.87以前)では`-t`の挙動が異なる可能性あり。現環境では問題なし。

2. **ポートが使われていない場合** — `lsof -ti:8001`が空出力 → `xargs kill -9`が引数なしで実行されるが、`2>/dev/null || true`で安全にスキップされる。OK。

3. **代替案（より堅牢）** — `fuser`コマンド使用:
   ```bash
   fuser -k 8001/tcp 2>/dev/null || true
   ```
   `fuser`はLinuxの`psmisc`パッケージに含まれ、ポート指定のプロセスkillに特化。ただし現状のlsof方式でも動作するため必須ではない。

4. **python3存在確認の改善案** — 現スクリプトにはpython3の存在チェックがない。万一python3がない環境でサイレントに失敗する:
   ```bash
   command -v python3 >/dev/null 2>&1 || { echo "python3 is required"; exit 1; }
   ```

### 結論
**現状のstart-static-server.shはLinux環境（Ubuntu 24.04）でそのまま動作可能。** 致命的な互換性問題はなし。

---

## タスク1-4: ローカルLinuxビルドの可否確認

### build-ubuntu.shの内容確認

スクリプトは以下のステップを実行:
1. `apt-get`で依存パッケージインストール
2. Rustインストール（未導入時）
3. Tauri CLIインストール（未導入時）
4. `cargo tauri build`
5. 成果物表示

### 依存パッケージのインストール状況

| パッケージ | 必要 | インストール済み | バージョン |
|-----------|------|-----------------|-----------|
| build-essential | ✅ | ✅ | 12.10ubuntu1 |
| libssl-dev | ✅ | ✅ | 3.0.13-0ubuntu3.7 |
| libgtk-4-dev | ✅ | ✅ | 4.14.5+ds-0ubuntu0.7 |
| libadwaita-1-dev | ✅ | ✅ | 1.5.0-1ubuntu2 |
| libwebkit2gtk-4.1-dev | ✅ | ✅ | 2.50.4-0ubuntu0.24.04.1 |
| libjavascriptcoregtk-4.1-dev | ✅ | ✅ | 2.50.4-0ubuntu0.24.04.1 |
| libsoup-3.0-dev | ✅ | ✅ | 3.4.4-5ubuntu0.7 |
| libasound2-dev | ✅ | ✅ | 1.2.11-1ubuntu0.2 |
| libayatana-appindicator3-dev | ✅ | ✅ | 0.5.93-1build3 |
| librsvg2-dev | ✅ | ✅ | 2.58.0+dfsg-1build1 |
| patchelf | ✅ | ✅ | 0.18.0-1.1build1 |
| curl, wget, file | ✅ | ✅ | （標準インストール済み） |

### ツールチェーン状況

| ツール | 必要 | 状態 | バージョン |
|--------|------|------|-----------|
| rustc | ✅ | ✅ | 1.90.0 |
| cargo | ✅ | ✅ | 1.90.0 |
| tauri-cli | ✅ | ✅ | 2.9.4（最新: 2.10.1） |
| node | 任意 | ✅ | 22.14.0 |
| python3 | ✅(dev用) | ✅ | 3.12.3 |

### cargo tauri info による環境検証結果
```
[✔] Environment
    ✔ webkit2gtk-4.1: 2.50.4
    ✔ rsvg2: 2.58.0
    ✔ rustc: 1.90.0
    ✔ cargo: 1.90.0
```
→ **全項目グリーン（✔）。環境は正常。**

### ビルド前提条件の充足状況

| 前提条件 | 状態 | 備考 |
|---------|------|------|
| 全依存パッケージ | ✅ 充足 | build-ubuntu.shの全パッケージがインストール済み |
| Rust toolchain | ✅ 充足 | stable-x86_64-unknown-linux-gnu |
| Tauri CLI | ✅ 充足 | v2.9.4（若干古いが動作可能） |
| フロントエンドアセット | ✅ 存在 | src-tauri-ui/にHTML/JS/CSSあり |
| アイコンファイル | ✅ 存在 | icons/icon.png (1387bytes) |
| tauri.conf.json | ⚠️ 二重定義 | タスク1-2で報告した問題あり |

### ビルド阻害要因

1. **tauri.conf.json二重定義問題（要修正）** — タスク1-2で報告済み。crates側のMac絶対パスがbuild.rsで読まれる可能性。ただし`beforeDevCommand`はbuild時には使われないため、`cargo tauri build`は成功する可能性が高い。`cargo tauri dev`は影響を受ける。

2. **Tauri CLIバージョンのマイナー差異（低リスク）** — 2.9.4 vs crateの2.9.4。同バージョンなので問題なし。ただしTauri crateは2.9.4、最新は2.10.3。アップデートは任意。

3. **`@tauri-apps/api` 未インストール（要確認）** — `cargo tauri info`で`not installed!`と表示。フロントエンドがJSのTauri APIを使用している場合は問題だが、`src-tauri-ui/tauri-api.js`が独自実装であれば不要。

### 結論
**ローカルLinux環境でのビルドに必要な依存パッケージ・ツールチェーンは全て揃っている。** tauri.conf.json二重定義問題を解消すれば、`cargo tauri build`は実行可能と判断する。

---

## 総合まとめ

### 優先度順の対応事項

| 優先度 | 問題 | 影響 | 修正工数 |
|--------|------|------|---------|
| **P1** | crates側tauri.conf.jsonのMac絶対パス | `cargo tauri dev`がLinuxで失敗 | 5分 |
| **P1** | tauri.conf.json二重定義 | 設定不整合リスク | 10分 |
| **P3** | start-static-server.shのpython3存在確認なし | エラーメッセージ不親切 | 2分 |
| **P4** | Tauri CLI/crateのマイナーバージョン差 | 機能的影響なし | 5分 |

### 推奨アクション
1. crates側`tauri.conf.json`を削除し、ルート側へのsymlinkに置換（パス解決の検証を含む）
2. symlink方式でfrontendDistのパス解決に問題がある場合は、`--config`オプション方式にフォールバック
3. start-static-server.shにpython3存在チェックを追加（任意）
4. ビルド実行テスト（`cargo tauri build`）で最終確認
