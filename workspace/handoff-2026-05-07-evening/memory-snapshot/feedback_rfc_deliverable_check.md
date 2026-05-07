---
name: 完了宣言前に RFC の全 deliverable 項目を機械的にチェックする
description: 2026-04-28 教訓。worker から follow-up 整理が来ても rubber-stamp せず、RFC のスコープ定義 (F1-Fn / V1-Vn 等) を 1 項目ずつ src grep で実装確認してから完了宣言する
type: feedback
originSessionId: 894b93ff-e8db-4f9b-a616-814f85ab325c
---
worker から PR 完了報告 + follow-up 整理を受けたとき、boss1 は **RFC のスコープ定義を 1 項目ずつ独立検証**してから完了宣言する。worker の follow-up 整理 (scope refinement) を rubber-stamp すると重大な見逃しが発生する。

**Why:** 2026-04-28 GUI_kit Track 7-A+C で worker2 が PR #52 完了時に F1/F2/F3/V1 の 4 項目達成 + 3 follow-up に scope refinement したと報告。boss1 はそれを accept し 'Track 7-A+C メインスコープ完遂' と宣言した。しかし worker2 RFC の V2 (font_scale App level) + V3 (App::with_font_scale builder + Widget::inject_font_scale 配線) は明記されていたのに follow-up 3 件に含まれず、boss1 も RFC deliverable の機械的チェックを怠った結果、完全未実装のまま完了宣言してしまった。codex セカンドオピニオン経由のユーザー指摘で発覚し、Track 7-A+C 完遂を撤回して font_scale 実装の追加 PR が必要になった。

**How to apply:**
- worker から PR 完了報告 + 'follow-up に分離' の整理を受けたら、まず **RFC の deliverable 項目 (F1, F2, ..., V1, V2, ... 等) を全列挙**
- 各項目について **src/ + tests/ で grep** して実装の有無を確認 (例: 'font_scale' で grep 0 ヒット = 未実装)
- worker の follow-up 整理に項目が含まれていない場合、'なぜ含まれていないか' を worker に確認 (意図的 deferral か見逃しか)
- 全項目が **実装済 OR 明示的に follow-up に整理** であることを確認してから完了宣言する
- 大きな RFC ほど機械的チェックが効果的。codex セカンドオピニオンを併用するとさらに堅実 (関連: feedback_codex_second_opinion.md)
- 完了宣言の文言は '** スコープ達成' でなく '主要項目達成、残 X/Y は follow-up 整理済' のように厳密に
