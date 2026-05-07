---
name: User machine has 16GB RAM, OOM-prone under parallel rustc
description: 2026-04-28 ユーザー共有。16GB RAM 構成。CPU は十分だが rustc + 4 tmux Claude pane + 自セッションで OOM クラッシュ実例あり。並行 cargo test --all-targets は要分散
type: reference
originSessionId: c054fc13-9497-44a9-b4e8-c96d60187076
---
ユーザーマシンは RAM 16GB のみ搭載。CPU は rustc 用途で十分、メモリだけが律速。

**Why:** 2026-04-28 セッションが途中クラッシュ、本人が「メモリ不足だろう、16GB しか載せてない」と root cause を共有。rustc は CPU 余裕でもメモリは食う。

**How to apply:**
- 4 worker (boss1 + worker1/2/3) が同時に cargo test --all-targets --no-fail-fast を走らせると合計 4 worktree × 数 GB = OOM 直撃。並行 dispatch では検証コマンドの起動タイミングを分散させる
- 規範化済 cargo test --all-targets --no-fail-fast (memory: feedback_cargo_test_no_fail_fast.md) はトラックごとに必須だが、boss1 から 3 worker 同時 GO は避け、報告受領 → 次 worker GO の逐次運用 or 「cargo check で先行確認 → cargo test は順次」二段運用が安全
- ローカル開発で `cargo test --all-targets` より `cargo check --all-targets` を先打ちする方が早く軽い (test バイナリ link を省略)
- tmux multiagent ペイン 4 個 + president ペイン + Claude Code 自セッション = 6 Claude プロセス常駐。Claude 1M context 利用時はベース 1-2 GB、Opus フル context だと 4-6 GB に伸びるので残り余裕は数 GB しかない
- クラッシュ後の復帰は worktree commit + memory + ログから状態復元可能 (実例: 2026-04-28 復帰成功)
- ハード増設提案は不要 (ユーザー認知済の制約)
