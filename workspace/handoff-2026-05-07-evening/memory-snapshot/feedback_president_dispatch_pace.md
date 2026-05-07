---
name: PRESIDENT dispatch pace — 軸合致は即送信、major decision のみ確認
description: 2026-05-07 ユーザー確定。PRESIDENT (work-PC Claude Code instance) の boss1 dispatch 運用、軸合致した判断は user 確認なしで即送信、major decision のみ user 確認 escalate
type: feedback
originSessionId: 1035e373-fb86-4a60-805f-eb292e2c50a1
---
PRESIDENT (work-PC で動作する Claude Code instance) が boss1 へ dispatch する際のペース運用ルール (2026-05-07 ユーザー指示で確定)。

**Why:** 5 連続 PR merge milestone (track-ime + track-golden + Stage 3 + track-pp1a + spec v1.0) 進行中、毎回「ドラフト提示 → user OK → 送信」サイクルが冗長。ユーザーが ロードマップ全体を把握しており、軸合致した判断は user 確認不要と明示。

**How to apply:**

**即送信 OK (user 確認不要):**
- boss1 推奨 + worker 多者一致 (worker1 + worker2 + worker3 のうち 2 名以上同じ方向) + memory 規範 (feedback_*.md / project_*.md と整合) の 3 軸合致
- PR review 結果が boss1 で全項目 pass で PRESIDENT 最終確認のみ求められる場合
- 既 PRESIDENT 確定方針 (v1-v8 bundle 等) の追認確認のみ
- merge 完了通知 trigger による memory 更新と短い完了報告

**user 確認 escalate (即送信せず ユーザーに draft 提示):**
- codex 第二意見が必要な major decision (rescore v3 → v6 のような score 影響大 + 設計判断)
- PRESIDENT 認識相違 escalate (boss1 が「PRESIDENT 認識相違あれば即報告」明示している場合、認識相違の有無を確認)
- scope 大幅変更 (例: 10 commits 1 PR → 40 commits 1 PR、O1/O2/O3 のような構造選択)
- premise 認識訂正 (例: dual-PC → single-PC) のような前提条件覆し
- 採用方針候補が 3+ ある中の選択 (memory feedback_measure_first_rescope.md "scope 不確実は計測ファースト → 多択で再相談" 規範)

**運用変更後の boss1 への伝達:**
本 feedback 確定後 boss1 へ「PRESIDENT bundle 確認は軸合致は即追認、major decision のみ user 確認」を周知済 (2026-05-07 PR #76 merge 完了通知後の dispatch で明示)。

**memory 更新運用 (継続):**
- merge 完了通知 trigger で project memory + MEMORY.md index 反映 (PRESIDENT 側で実施、boss1 側 memory 化なし)
- 反映内容は main HEAD update / PR 累計 / track 完遂 / rescore 推移 / Stage 状況
- 軸合致即送信運用でも memory 反映自体は省略しない (将来 session の context 確保)

**memory 関連:**
- `feedback_codex_second_opinion.md`: major decision で codex 第二意見、迷ったら user 相談 (本規範の major decision 判定軸の 1 つ)
- `feedback_measure_first_rescope.md`: scope 不確実時の多択 escalate (本規範の major decision 判定軸の 1 つ)
- `feedback_memory_first_source.md`: クラッシュ復帰 / 認識合わせで MEMORY.md 初手確認 (即送信運用でも memory 反映継続の根拠)
