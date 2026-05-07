---
name: 副次変更で latent race / pre-existing 不具合に同時対処してよい
description: テスト追加で発覚した既存 race / 潜在不具合は、同一 commit で同パターンを既存箇所にも retrofit してよい。message に独立段落で明示すれば scope creep にならない
type: feedback
originSessionId: 6214d47c-f869-415a-80d7-217d5ad9b6a2
---
新規 test 追加で global state の race / latent bug が顕在化したとき、同じ修正パターンを既存箇所にも同 commit で retrofit してよい。

**Why:** 2026-04-28 の Track 7-C V3 PR #57 で、新 font_scale test が `ACTIVE_THEME` global を触り cargo の並行 test runner で race を起こした。原因は theme.rs 既存 2 test も同 global を触っていて lock 機構が無かったこと。`ACTIVE_THEME_TEST_LOCK` Mutex を新設して新 test 群に取らせるだけでも race は解消するが、既存 2 test の latent race (互いに rare ながら衝突しうる) はそのまま残る。両方を同 commit に含めて message で独立段落として正当化したところ、boss1 から「pre-existing race を併せて修正した点は健全な scope。新 test の race 解消が主目的、既存 test の修正も同一 lock 取得で統一されており scope creep ではない」と評価された。

逆パターン: 同 commit に含めず別 PR に切り出すと、reviewer が同じ 2 行を再度 review する無駄 + lock 取得規約が一貫しない (新コードと既存コードで作法が違う) 期間が発生する。

**How to apply:**
1. 主目的とは別の修正は commit message に独立段落 (`Side change:` などの見出し) を立てて記述
2. 「なぜ同梱するのが reviewer 工数最小か」を 1-2 文で添える (同一 lock 規約の統一 / 同 2 行の再 touch 回避 など)
3. PR description にも同じ独立セクションを切る (commit message と同じ語彙で)
4. ただし主目的と無関係な機能追加 / 大規模 refactor は別 PR (this rule はあくまで「同種の latent issue を同パターンで修正」する場合)
5. 適用すべきでない例: 主目的が docs 修正なのに既存 prod code の bug fix を同梱 / scope が異なる Track の修正同梱
