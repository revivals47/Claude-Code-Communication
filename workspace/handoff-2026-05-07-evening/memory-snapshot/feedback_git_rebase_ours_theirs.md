---
name: rebase の --ours/--theirs は merge と意味が逆転する
description: git rebase 中の conflict 解決で `--ours` は「rebase 先 (main 等)」、`--theirs` は「適用するコミット側」。merge と逆。誤ると古い版を取り込んで regression を起こす。
type: feedback
originSessionId: e54d352b-4883-48fc-8f0b-6a734ada169c
---
git の `--ours` / `--theirs` セマンティクスは **merge と rebase で逆転する**。

| コマンド | --ours | --theirs |
|---|---|---|
| `git merge X` | 現ブランチ (cur) | X (取り込み元) |
| `git rebase X` | **X (rebase 先 = 新 base)** | **現ブランチの replay 中コミット** |

**Why:** 2026-04-28 の GUI_kit PR #39 rebase で間違えた。track2/window-frame-macro を main に rebase する際、`docs/rfc-track2-widget-children.md` で add/add conflict 発生。「main の最新版を残したい」ので reflexively `git checkout --theirs` したら、**rebase の --theirs = 古い 50da151 側 (464 行) を採用**してしまい、main の §9.9 セクション (86 行) を削除する commit になりかけた。fix(rebase) コミットで救済できたが、squash-merge 直前で気づかなかったら main の RFC が regression していた。

**How to apply:**
- rebase で「rebase 先 (main 等) の版を残す」 → **`git checkout --ours <file>`** を使う
- rebase で「現ブランチの replay 中の版を残す」 → `git checkout --theirs <file>` を使う
- merge と逆なので、迷ったら `wc -l` 等でファイル長を確認してから commit する
- conflict 解決後に必ず `git diff <upstream-branch>` で差分を確認 (期待しない deletions(-) が見えたら逆転している)
- 特に長い docs ファイルや RFC のような「main 側が常に正」のファイルでは要注意
- rebase の代わりに `git merge` を選べる場面 (squash-merge の最終結果が同じになる時) では merge の方が事故率が低い
