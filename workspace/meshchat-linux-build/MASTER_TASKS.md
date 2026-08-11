# MeshChat Linux版 本番品質化プロジェクト
## 目標: Linux版(deb/AppImage)を本番品質にする

### 作業対象リポジトリ: /home/ken/Documents/meshchat-desktop-Rust

---

## フェーズ1: ビルド環境の正常化 (4/4) ✅ 完了 - Worker1担当
- [x] 1-1. beforeDevCommand クロスプラットフォーム対応分析
- [x] 1-2. tauri.conf.json二重定義問題の調査・解消方針策定
- [x] 1-3. start-static-server.sh Linux互換性確認
- [x] 1-4. ローカルLinuxビルド可否確認（全依存パッケージ✅、ツールチェーン✅）

## フェーズ2: Linux固有問題の洗い出し (5/5) ✅ 完了 - Worker2担当
- [x] 2-1. CIとbuild-ubuntu.shの依存パッケージ差異分析 → CRITICALパッケージ3個不足発見
- [x] 2-2. GTK/WebKit2GTKバージョン整合性調査 → 22.04/24.04とも問題なし
- [x] 2-3. Wayland vs X11対応状況調査 → WebRTCはX11必須、xvfb-runは妥当
- [x] 2-4. オーディオサブシステム検証 → PipeWire+ALSA構成、WebRTCはGStreamer経由
- [x] 2-5. CSP connect-src確認 → ipc:スキーム追加推奨

## フェーズ3: パッケージング検証 (4/4) ✅ 完了 - Worker1担当
- [x] 3-1. debパッケージ設定調査 → shortDescription/section/depends未設定
- [x] 3-2. AppImage調査 → libfuse2問題あり(Ubuntu 24.04)、フォールバック文書化必要
- [x] 3-3. アイコン・デスクトップ統合 → 128x128は小さい、512x512以上必要
- [x] 3-4. updaterプラグイン状態確認 → pubkey空、v0.1.0では呼び出さない暫定対応推奨

## フェーズ4: テスト戦略 (4/4) ✅ 完了 - Worker3担当
- [x] 4-1. GTKテスト問題調査 → コンパイルエラー2件(dev-deps不足)が先決、#[ignore]78個
- [x] 4-2. テストレイヤー整理 → Rust2918テスト+JS19ファイル、統合66ファイル717テスト
- [x] 4-3. CI linux-bundleジョブ設計 → YAML設計案完成、22.04ビルドを配布用推奨
- [x] 4-4. E2Eテスト基盤調査 → Docker Compose 7サービス構成、CI統合にはリソース制約あり

---

## コード修正フェーズ（Step 1〜4）✅ 全完了

### Step 1: CRITICAL 3件 ✅
- [x] C1: CIパッケージリスト統一 → 10パッケージに拡充（Worker2）
- [x] C2: tauri.conf.json二重定義解消 → crates側を正、ルート側削除（Worker1）
- [x] C3: dev-deps修正 → discovery/coreコンパイル成功（Worker3）

### Step 2: bundle設定+CSP修正 ✅
- [x] category=SocialNetworking, shortDescription, section=net, depends設定（Worker1）
- [x] CSPにipc: http://ipc.localhost追加（Worker1）

### Step 3: 初回Linuxビルド ✅
- [x] deb: MeshChat_0.1.0_amd64.deb (14.9MB) 生成成功（Worker1）
- [x] AppImage: MeshChat_0.1.0_amd64.AppImage (84.1MB) 生成成功（Worker1）
- [x] dpkg -I検証: Package/Version/Section/Depends/Description全項目OK

### Step 4: CI強化 ✅
- [x] linux-bundleジョブ追加（Ubuntu 22.04/24.04 matrix、artifact upload）（Worker2）
- [x] frontend-testジョブ追加（Jest）（Worker2）
- [x] Rust cache追加（check/clippy/test 3ジョブ）（Worker2）
- [x] ci.yml: 181行→269行（8ジョブ構成）

### 追加成果物
- [x] build-ubuntu.sh更新（libxdo-dev追加+ビルドコマンド修正）（Worker2）
- [x] docs/LINUX-INSTALL.md作成（Worker2）
- [x] tauri.conf.json一本化（.bak削除、cargo tauri info動作確認）（Worker2）
- [x] meshchat-libテストコンパイルエラー修復（Worker3）

---

## 進捗ログ
| 日時 | Worker | 内容 |
|------|--------|------|
| 03/16 12:11 | Worker1 | フェーズ1完了。P1: tauri.conf.json二重定義、全依存パッケージ✅ |
| 03/16 12:11 | Worker1 | フェーズ3（パッケージング調査）に着手 |
| 03/16 12:17 | Worker1 | フェーズ3完了。deb設定不足6項目、アイコン128px問題、updater pubkey空 |
| 03/16 12:17 | Worker2 | フェーズ2完了。CI依存3パッケージCRITICAL不足、GTK4不要疑惑、CSP ipc:未記載 |
| 03/16 12:17 | Worker3 | フェーズ4完了。テスト2918個、コンパイルエラー2件先決、linux-bundle YAML設計完了 |
| 03/16 20:06 | Worker1 | Step1(C2)+Step2完了。symlink→独立config方式に変更✅ |
| 03/16 20:06 | Worker2 | Step1(C1)+Step4完了。CIパッケージ統一✅、3ジョブ追加✅ |
| 03/16 20:06 | Worker3 | Step1(C3)完了。dev-deps追加✅ |
| 03/16 20:22 | Worker1 | **Step3完了。deb+AppImage生成成功✅** |
| 03/16 20:22 | Worker2 | build-ubuntu.sh更新+LINUX-INSTALL.md+config一本化✅ |
| 03/16 20:22 | Worker3 | meshchat-libテストコンパイルエラー修復完了✅（use文をcrate絶対パスに修正） |

## PRESIDENT決定事項
1. tauri.conf.json → 実装結果: crates側を正に変更（symlink不可のため）。ルート側は削除
2. 対象: Ubuntu 22.04 + 24.04。Fedora/Archは可能であれば
3. Voice/Videoバグ → 別トラック。ALSA/PulseAudio部分のみフェーズ2で検証
4. セキュリティ → v1.0.0ターゲット。CSPハードコードIPのLinux動作はフェーズ2で確認
