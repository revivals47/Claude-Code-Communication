---
name: revivals47 GitHub Actions has no credit
description: revivals47 アカウントは Actions のクレジット切れ (2026-04-28 ユーザー確認)。PR の CI status check は workflow setup レベルで即死するため独立検証に使えず、マージ判断はローカル cargo check で代替する。
type: reference
originSessionId: e54d352b-4883-48fc-8f0b-6a734ada169c
---
revivals47/GUI_kit (および同オーナーの他リポジトリも可能性大) は GitHub Actions クレジット切れで、PR の CI が **workflow setup レベルで即死** する (run 全体 4 秒、各 job 2-3 秒、`steps` 配列空、checkout すら走らない)。

**Why:** 2026-04-28 ユーザー直接確認: 「あれはクレジットがない」。Free 枠を超過したか課金が切れている。

**How to apply:**
- PR のマージ判断時、CI status check の FAILURE は **コード品質の証拠として読まない** (環境問題、CI が一切実行されていない)
- 代わりに該当 worktree でローカル `cargo check --all-targets --features <matrix>` を実行して代替検証する
- `mergeStateStatus: UNSTABLE` は仕様 (status check FAILURE だが `mergeable: MERGEABLE`)
- "unconditional GO" を出す前にローカル検証を必須にする
- CI 復旧 (Actions 課金復活) は GUI_kit プロジェクトのスコープ外 — ユーザー側の対応事項
- worker への指示時には「CI は使えないのでローカル検証で確証を取れ」を明示する
