# MeshChat Linux版 本番品質化 — 統合調査レポート

**報告者**: boss1
**日時**: 2026-03-16
**状況**: 全4フェーズの調査完了

---

## 全体サマリー

全Worker（Worker1/2/3）による調査が完了。Linux版を本番品質にするために必要な変更点を優先度順に整理した。

## 発見事項の統合優先度マトリクス

### CRITICAL（ビルド/動作を阻害する問題）

| # | 問題 | 発見元 | 修正工数 |
|---|------|--------|---------|
| C1 | CIにwebkit2gtk-4.1-dev/soup-3.0-dev/jscoregtk-4.1-dev不足 | Worker2 | 5分 |
| C2 | tauri.conf.json二重定義（crates側にMac絶対パス） | Worker1 | 10分 |
| C3 | cargo test コンパイルエラー2件（dev-deps不足: rand, tempfile） | Worker3 | 15分 |

### HIGH（本番品質に必須）

| # | 問題 | 発見元 | 修正工数 |
|---|------|--------|---------|
| H1 | bundle.shortDescription未設定 → .desktopのComment空 | Worker1 | 2分 |
| H2 | bundle.category "Productivity" → "Network"が適切 | Worker1 | 2分 |
| H3 | アイコン128x128px → 512x512px以上のソース必要 | Worker1 | デザイン作業 |
| H4 | GTK4/libadwaita-1-dev指定が不要の可能性（Tauri 2.0はGTK3ベース） | Worker2 | 調査10分 |
| H5 | libxdo-devが両方(CI/build-ubuntu.sh)から欠落（Tauri公式要件） | Worker2 | 5分 |
| H6 | meshchat-libのテストモジュールパス不整合（リファクタ後未修正） | Worker3 | 30分 |

### MEDIUM（品質向上・安定性）

| # | 問題 | 発見元 | 修正工数 |
|---|------|--------|---------|
| M1 | CSPにipc:スキーム未記載 → Linux/macOSでIPC不安定の可能性 | Worker2 | 5分 |
| M2 | deb section/depends未設定 | Worker1 | 5分 |
| M3 | updater pubkey空 → v0.1.0では呼び出さない暫定対応推奨 | Worker1 | 10分 |
| M4 | Ubuntu 24.04でlibfuse2デフォルト未インストール → ドキュメント必要 | Worker1 | 10分 |
| M5 | Wayland環境でWebRTC非動作 → X11推奨の文書化 | Worker2 | 10分 |
| M6 | CIにlinux-bundleジョブ未設定 | Worker3 | 20分 |
| M7 | CIにJSテスト(npm test)未統合 | Worker3 | 10分 |

### LOW（改善推奨）

| # | 問題 | 発見元 | 修正工数 |
|---|------|--------|---------|
| L1 | longDescription/license/homepage未設定 | Worker1 | 5分 |
| L2 | start-static-server.shにpython3チェック追加 | Worker1 | 2分 |
| L3 | Rust cacheをCI全ジョブに導入 | Worker3 | 10分 |
| L4 | Docker E2EテストのCI統合（リソース制約の解決必要） | Worker3 | 1日 |

---

## 推奨実行計画

### Step 1: ビルド阻害要因の除去（C1-C3、30分）
1. crates/meshchat-desktop/tauri.conf.json → 削除してルートへのsymlink
2. CI依存パッケージリスト統一
3. dev-dependencies追加（rand, rand_chacha, tempfile）

### Step 2: bundle設定の修正（H1-H2, M1-M2、15分）
1. shortDescription, category, section, depends設定
2. CSPにipc:スキーム追加

### Step 3: 初回Linuxビルド実行（30分）
1. cargo tauri build でdeb/AppImage生成
2. dpkg -I チェックリスト実行
3. AppImage起動テスト

### Step 4: CI強化（M6-M7, L3、30分）
1. linux-bundleジョブ追加（Worker3のYAML設計案ベース）
2. JSテストジョブ追加
3. Rust cache導入

### Step 5: 残課題（H3, H4等）
1. アイコン高解像度版の作成
2. GTK4/libadwaita依存の精査
3. Waylandドキュメント整備

---

## 重要な技術的知見

1. **Ubuntu 22.04ビルドを配布用にすべき** — glibc互換性のため、22.04でビルドすれば22.04以降で動作する。24.04ビルドは22.04では動作しない
2. **WebRTCはX11環境必須** — WaylandではWebKit2GTKのWebRTCが正常動作しない報告あり
3. **Tauri 2.0はGTK3ベース** — GTK4/libadwaita-1-devの指定は不要の可能性が高い
4. **テストスイートは大規模（Rust 2,918 + JS 19ファイル）** — ただしコンパイルエラーで一部ビルド不可

---

## 成果物一覧

| ファイル | 担当 | 内容 |
|---------|------|------|
| worker1-phase1-report.md | Worker1 | ビルド環境正常化調査 |
| worker1-phase3-report.md | Worker1 | パッケージング検証調査 |
| worker2-phase2-report.md | Worker2 | Linux固有問題調査 |
| worker3-phase4-report.md | Worker3 | テスト戦略・CI強化設計 |
| MASTER_TASKS.md | boss1 | タスク管理 |
| CONSOLIDATED-REPORT.md | boss1 | 本統合レポート |
