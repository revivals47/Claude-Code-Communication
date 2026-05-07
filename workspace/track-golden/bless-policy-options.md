# track-golden-rebless — bless 採用方針 candidates 影響評価 (work-PC 単独 finding ベース)

base: track-golden/rebless @ origin/main 64fb117 起点
date: 2026-05-07
status: **draft (work-PC 単独 finding)、PRESIDENT 判断 + ken 受領後 dual-PC 化**

## 前提整理

### 確定事実 (step 1 / 2 完了)
- 5/5 consumer (label / button / vstack / window_frame_w10 / window_frame_w95) の work-PC tlcr 現観測 = PR #70 commit f4d563e 記載の bless 前数値と完全一致
- renderer = CPU rasterizer (cosmic-text 0.18.2 + swash + tiny-skia 0.11)、Vulkan path 不通過
- work-PC tlcr の `NotoSansCJK-Regular.ttc` sha256 = `b76b0433203017ca80401b2ee0dd69350349871c4b19d504c34dbdd80541690a` (file size 19,484,784、fontversion 131334、fonts-noto-cjk apt 1:20230817+repack1-3)

### 認識相違 escalation 中 (2026-05-07)
- memory `reference_dual_pc_setup.md` v1.3 = home-PC ken 実在前提 + worker3 = home-PC 動作前提
- 実態 = 全 worker (worker1/2/3) が tlcr で動作中、ken 実在性未確認
- boss1 candidates: (X) memory 訂正 + work-PC 単独運用、(Y) ken machine 整備、(Z) ssh alias 整備

## bless 採用方針 4 候補

### (a) lenient threshold (mismatch / max delta 上限緩和)
**実装**: `src/testing/golden.rs:148` の `if ref_pixels != pixels` 直比較を、各 channel delta が threshold (例: max 8) 未満なら ok にする tolerance 比較に変更。

**Pros**:
- 単一 golden で両 env (tlcr / 仮 ken) を緑化可能
- bless 1 回で済み、re-bless 循環なし

**Cons**:
- 観測値 = max delta 178 / 192 / 250 の高さ。tolerance 8-32 級では 5/5 全件依然 fail
- tolerance を 200+ にすると glyph 全体が許容、anti-alias 細線が失われても fail 検知できず → test sensitivity 大幅低下
- `golden_widgets` の主目的 (paint regression 早期検知) が形骸化

**実現性**: ❌ 観測 max delta 178-250 が tolerance 許容範囲外。lenient threshold は本問題には機能しない。

### (b) env-specific golden subset (各 PC 専用 golden)
**実装**: `tests/goldens/win10/button_default.golden` を `tests/goldens/win10/button_default.{env_id}.golden` のように分岐、`GoldenSnapshot` で env 検出 (e.g. `NotoSansCJK-Regular.ttc` sha256 を hash key)。

**Pros**:
- 両 env (tlcr / 仮 ken) で ground truth を保持、test sensitivity 維持
- bless 時に env_id を明示、誤 bless 防止可能
- env ごとの paint regression を独立検知

**Cons**:
- golden 数 = 5 widgets × env 数。env 増加で linear 増
- env_id の決定方法に discipline 要 (sha256 完全一致でない near-equiv env で重複)
- bless 手順が `env_id 確定 → bless` の 2 step、開発者向け doc 整備要
- `revivals47 GitHub Actions credit 不在` memory 既登録 = CI gate 不在、両 env のローカル運用前提
- ken 実在性 escalation 中に最終仕様化は時期尚早

**実現性**: ✅ 技術的に可能、ただし ken 実在性確定後 (Y/Z 採用時) に意味を持つ。(X) 採用なら不要。

### (c) work-PC default 再 bless (tlcr で GOLDEN_BLESS=1)
**実装**: `cd ~/Documents/GUI_kit-track-golden && GOLDEN_BLESS=1 cargo test --test golden_widgets --no-fail-fast` 実行 → `.golden` 5 件更新 commit + PR + merge。

**Pros**:
- 単 commit、scope 小、PR template 単純
- (X) 採用 = work-PC 単独運用なら golden の "正しい env" 確定で safe
- step 4 即実行可能

**Cons**:
- ken 実在 (Y/Z 採用) の場合、bless 後 ken 側で再 mismatch = 循環 (loop 化)
- PR #70 (home-PC で bless と推定) の 5 件 bless 努力が上書きされる、bless 履歴が tlcr/ken で交互する可能性
- 本問題の本質 (env-specific rendering) を解決せず、後続の bless 担当者に同一問題を再発させる

**実現性**: ✅ (X) 採用前提でのみ妥当。(Y)/(Z) 採用なら避けるべき。

### (d) home-PC default 維持 (PR #70 状態 hold + work-PC で env を home-PC 側に揃える)
**実装**: golden は不変、tlcr 側で fonts-noto-cjk を home-PC 同 version に揃える + fontconfig 設定を同期 + ttc sha256 一致を保証。

**Pros**:
- golden の安定性最優先、bless 履歴を不変に保つ
- env 統一の規律確立 = 将来の env 差問題予防
- test sensitivity 完全維持

**Cons**:
- ken 実在性 escalation 中で ken 側 env が未取得、揃え先 spec 不明
- tlcr 側で apt source 制限 / kernel 制限 / GPU driver 等で完全一致不能の可能性
- 環境揃えのコストが大、daily 開発と競合する可能性

**実現性**: ⚠️ ken env 確定 (Y/Z 採用 + ken factor 取得) 完了後にのみ評価可能。escalation 解決前は判断不能。

## 候補の整合性 / boss1 candidate との対応

| boss1 候補 | 採用可能 bless 方針 |
|---|---|
| (X) memory 訂正 + work-PC 単独運用 | (c) で確定 (tlcr で再 bless)、または (a)(b) は non-trivial で過剰 |
| (Y) ken machine 整備 | (b) または (d)。(a)(c) は循環 / sensitivity 低下で非推奨 |
| (Z) ssh alias 整備 (ken 物理存在前提) | (b) または (d)。(Y) と同等 |

## 推奨 (worker2 暫定、PRESIDENT 判断後 fix)

(X) 採用が最終確定する場合: **(c) work-PC default 再 bless** が即実行可能、scope 最小で track-golden を即完遂。

(Y)/(Z) 採用 = ken 実在化の場合: **(b) env-specific golden subset** か **(d) env 統一** の二択。技術投資量と將来 env 増加リスクの trade-off で PRESIDENT 判断。

## step 4 実行手順 (PRESIDENT 判断後)

### (c) 採用時
1. `cd ~/Documents/GUI_kit-track-golden && GOLDEN_BLESS=1 cargo test --test golden_widgets --no-fail-fast` (boss1 GO + worker3 verify cadence と分散後)
2. 5 件 `.golden` の更新を `git diff --stat` で確認 (binary 5 件のみ)
3. commit message: bless 経緯 + tlcr env factor (sha256, fontversion 等) 記載
4. PR 化 + boss1 review + merge

### (b) 採用時
1. `src/testing/golden.rs` に env_id 検出 logic 追加 (sha256 hash 経由、起動時 1 回のみ)
2. golden filename naming 改修 (`<name>.<env_id>.golden`)
3. tlcr / ken 双方で env_id 別 bless 実行
4. CI gate 不在のため両 env での bless が完了するまで PR 化保留 (= ken 受領タイミング依存)

### (d) 採用時
1. ken env factor 取得 (前提)
2. tlcr 側で apt + fontconfig 設定を ken に揃える
3. ttc sha256 一致確認
4. 不変 golden で `cargo test --test golden_widgets` 緑確認
5. 揃え手順を `docs/dev-env-spec.md` (新規) として記録、track-golden を quote-resolve で close

## 補助資料 / 関連 file

- workspace/track-golden/step1-finding.md (PR #70 メタデータ + 5/5 完全一致 finding)
- workspace/track-golden/step2-finding.md (renderer path + work-PC env + 仮説 H1-H4)
- workspace/track-golden/collect-env.sh (両 PC で同手順実行できる env collector script、79 行 dump 出力)
- workspace/track-golden/env-tlcr-20260507.txt (tlcr 実 dump、ken 受領時 diff 比較用)
