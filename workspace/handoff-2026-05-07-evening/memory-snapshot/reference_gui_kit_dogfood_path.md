---
name: GUI_kit dogfood depends on shared working tree path
description: Dogfood projects pin hayate-ui via `path = "../GUI_kit"`, so verifying a track worktree requires temporarily repointing Cargo.toml
type: reference
originSessionId: b25e767b-5b93-44a6-a060-1a51ea148df8
---
GUI_kit を依存にしている dogfood は 2026-04-28 時点で 8 件 (hayate-notepad / hayate-freecell / hayate-solitaire / hayate-pinball / hayate-linux-gallery / hayate-agents-linux / hayate-agents-linux-v2 / hayate-gpu-furnace) ですべて `hayate-ui = { path = "../GUI_kit", ... }` と共有 working tree を直接参照している。hayate-agents-linux-v2 は workspace で `crates/hayate-ui-frontend` 配下から `path = "../../../GUI_kit"`、hayate-gpu-furnace は workspace で `crates/s01_/s02_/s03_ × cpu/vk variants` (合計 5 sub-crate) が `path = "../GUI_kit"` 参照。canonical 一覧は今後 `docs/dogfood-canonical.md` (boss1 起票予定) を一次ソースに、無ければ `~/Documents/*/Cargo.toml` および `~/Documents/*/crates/*/Cargo.toml` への `grep -l "hayate-ui.*path.*GUI_kit"` で再導出。

worker は `~/Documents/GUI_kit-track{N}/` worktree で作業するため、track の変更が dogfood の cargo check に反映されるかを確かめるには:

1. dogfood の Cargo.toml の `path = "../GUI_kit"` を `path = "../GUI_kit-track{N}"` に sed 編集
2. `cargo check` を実行
3. `git checkout Cargo.toml` で必ず元に戻す (dogfood リポジトリを汚さない)

事前に `git diff --stat Cargo.toml` でクリーンを確認してから編集すること。`[patch]` セクションでは path dependency の上書きが効きにくいので、直接 path を書き換えるのが最短。

完了基準として「dogfood cargo check 緑」を要求された場合、この一時書換 → 検証 → revert を必ず実施する。

なお main HEAD merge 後の dogfood regression check (worktree repoint 不要、main 直参照) は `cargo test --all-targets --no-fail-fast -j1` を 8 件直列で回す (16GB OOM 配慮)。worker 単独想定で軽い 5 (notepad / freecell / solitaire / pinball / linux-gallery) → 経過報告 → 重い 3 (agents-linux / agents-linux-v2 / gpu-furnace) の split が boss1 規範 (2026-04-28 PR #55 dogfood regression run で確立)。
