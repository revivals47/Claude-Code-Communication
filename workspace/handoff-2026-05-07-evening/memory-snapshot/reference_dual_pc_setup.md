---
name: GUI_kit single-PC operation (work-PC tlcr) — 段階 a/b は role/cadence 区別
description: 2026-05-07 認識訂正 (旧 dual-PC 撤回): 全 worker (boss1/worker1/worker2/worker3) が work-PC tlcr で動作中、ken machine への ssh access 不能。Stage 3 verify v1.3.1 の段階 a/b 区別は物理 machine ではなく role/cadence (高頻度 build smoke vs 低頻度厳格 test) で意味分化
type: reference
originSessionId: 1035e373-fb86-4a60-805f-eb292e2c50a1
---
GUI_kit 開発環境は 2026-05-07 認識訂正後、**single-PC 運用** (work-PC tlcr) で確定。旧 dual-PC 仕様 (work-PC tlcr + home-PC ken) は実態と乖離していたため撤回。

**Why:** 2026-05-07 track-golden-rebless step 1 進行中に boss1 が whoami で確認、全 worker が tlcr machine 動作 + ken への ssh access 不能 (worker2 ssh ken / ssh home-pc 失敗、~/.ssh/config 不在) を実証。memory `feedback_codex_second_opinion.md` 規範の codex 第二意見で Stage 3 verify protocol v1.3 の根拠とした「multi-environment 反証レイヤ」は失効、ただし段階 a/b 区別は role/cadence で意味分化により維持。

**運用環境:**
- machine: work-PC、user `tlcr`、`/home/tlcr/Documents/`
- all worker (boss1/worker1/worker2/worker3): tlcr 上の tmux multiagent pane で動作
- GitHub origin: `git@github.com:revivals47/GUI_kit.git`、push/pull で同期 (single-PC 内 git operation)
- ken machine 物理存否: 不明 (PRESIDENT 直接確認未回答)、ssh access 不能、現運用には不影響

**dogfood 所在 (single-PC):**
- hayate-notepad: work-PC tlcr 上の `~/Documents/hayate-notepad` (HEAD `f6b6c20 feat: Edit > Word Wrap toggle`、origin と完全同期)、TextAreaWidget の唯一の外部 caller、段階 b retained check の対象
- 他 6 consumer (freecell / solitaire / pinball / linux-gallery / agents-linux × 2): work-PC 上に同居、いずれも `path = "../GUI_kit"` 依存

**段階 a/b 区別 = role/cadence 区別 (物理 machine ではない):**

| 段階 | role/cadence | 対象 | 実行者 | 頻度 | gate |
|------|-------------|------|--------|------|------|
| 段階 a (高頻度 build smoke) | 中間 commit ごと | 7 consumer (notepad + 6 consumer) | worker3 自動、`bash scripts/run_consumer_regression.sh --diff` | 中間 commit ごと | build_error=0 + ABORT=0 + new red=0、test count exact match (notepad のみ)、test count 不一致 info (他 6) |
| 段階 b (低頻度厳格 test、retained check) | final candidate / API surface 変更時のみ | hayate-notepad 単独 | worker3 (work-PC tlcr) で `cd ~/Documents/hayate-notepad && cargo test --jobs 1`、boss1 review → PRESIDENT 最終確認 | 1-2 回/Stage | TextAreaWidget public API caller (notepad src/main.rs:26) の cargo test 全 PASS + new red 0 + ABORT 0 |

**段階 b retained check の役割定義 (2026-05-07 codex 監査反映、3 点で独立価値維持):**
- (1) public API 唯一 caller (hayate-notepad) の実 consumer sentinel
- (2) integration smoke sentinel (段階 a の build smoke を超えた動作確認、build OK だけでなく runtime test もパス)
- (3) Stage 4 以降の API drift 検知 (final candidate / API surface 変更 commit の慎重 verify、低頻度高密度 gate)
- multi-environment 反証 (旧 codex 第二意見の根拠の一部) は (X) 採用で失効、上記 3 点で独立価値維持

**baseline 取得 flow (single-PC):**
- work-PC で `bash scripts/run_consumer_regression.sh --baseline` 実行 → `tests/regression_baseline/<consumer>_${DATE}.{log,summary}` 生成 → git commit で永続化
- 旧 dual-PC で要求された scp + ssh alias は不要

**How to apply:**
- 段階 a/b 区別を物理 machine ではなく role/cadence で記述すること
- 段階 b retained check の意義を「multi-env 反証」ではなく「TextAreaWidget public API 唯一 caller での厳格 test」と framing
- ssh alias 整備は不要、ken machine の物理存在を仮定しない
- track-golden-rebless 等で「PR #70 bless 元 env」を追跡する場合は (X) 採用前提で single-PC 上の env 履歴 (過去の異 fontconfig / ttc 設定 / 過去 ken machine 物理存在仮説 / CI 環境) を bless source 候補とする

**関連:**
- 旧 dual-PC 仕様撤回経緯: 2026-05-07 boss1 escalation (track-golden-rebless step 1 中)、PRESIDENT (P1) (X) 採用確定
- v1.3 protocol → v1.3.1 補正履歴 6 で baseline HEAD 67a4273 → 57ae576 化が確定済、本訂正で物理 machine 区別の追加修正
- 関連 memory: project_text_core_migration.md (Stage 3 verify v1.3.1 構成、role/cadence 区別反映済)、reference_user_machine_16gb_oom.md (16GB RAM 制約、single-PC で全 worker cargo test 並走の OOM リスク維持)
