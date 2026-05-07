# Agent Communication System

## エージェント構成
- **PRESIDENT** (別セッション): 統括責任者
- **boss1** (multiagent:0.0): チームリーダー
- **worker1,2,3** (multiagent:0.1-3): 実行担当

## あなたの役割
- **PRESIDENT**: @instructions/president.md
- **boss1**: @instructions/boss.md
- **worker1,2,3**: @instructions/worker.md

## メッセージ送信
```bash
./agent-send.sh [相手] "[メッセージ]"
```

## 基本フロー
PRESIDENT → boss1 → workers → boss1 → PRESIDENT

## 並走時の worktree 隔離（必須）
複数 worker が同一プロジェクトで並走する場合、git working tree の共有は禁止。各 worker は `git worktree add ../[project]-track{N} track{N}/[topic]` で別ディレクトリに隔離して作業する。詳細は @instructions/boss.md の '作業ディレクトリ管理 / worktree 隔離プロトコル' を参照。