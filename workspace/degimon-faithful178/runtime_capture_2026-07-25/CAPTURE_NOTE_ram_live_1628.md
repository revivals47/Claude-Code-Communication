# ram_live_1628_{1,2,3}.bin — 採取メモ（worker1、2026-07-25）

- 採取時刻: 16:28:19 / 16:28:22 / 16:28:25（3 秒間隔）
- 手法: 非侵襲 `/proc/<pid>/mem` read のみ。入力送信 / state 変更 / watchpoint / BP は一切なし
- pid 45756（duckstation-qt、flatpak/bwrap 配下）
- host mapping 同定: rw 領域を EXE 署名（slps_017_97.bin 先頭 0x400 B）で照合 →
  host base `0x7fd4cddff000`（size 0x800000）の +0x90800 が一致 = guest VA 0x80090800
  ⇒ file offset 0 = VA 0x80000000（2 MB 切り出し）
- context 自己判定: **mayo00**（entity 配列 lattice で position 5/5 一致、2 位 twnb24 3/8。母集団 211 map）
- churn-verify: 3 snapshot 間で entity 配列 record 0–4 は全 halfword 不変（game 静止）。
  RAM 全体の sha256 は 3 件とも相異（他領域は動いている）＝ read 自体は生きた RAM
- 用途: `docs/RE_field_entity_array_rebase_2026-07-25.md`（worktree fnl / track1）
