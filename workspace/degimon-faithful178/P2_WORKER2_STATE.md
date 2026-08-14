# P2 worker2 STATE（★先頭 30 行 = 現在地★ / ★以降 = 索引★）

★worktree★ = `~/Desktop/Digimon/degimon_world_remake-p2w2` ／ ★branch★ = `track2/trace-oracle` ／ ★HEAD★ = `3964a63a03b3ce19`
★共有 docs★ = `Claude-Code-Communication/workspace/degimon-faithful178/`（★書込 可・#269 で 境界 固定★）
★不変★ = push しない／完成 claim 凍結／★degimon の 共有 tree は 読取のみ★／worker 間 直送 禁止／★STATE は 送信ごと★

## ① 今 何を 追って いるか（1 文）
★原盤の 実行標本 3 本（runA / v5a / v5b）を ★28 命令の 列★ と 突き合わせ、★時間軸（滞在の 下界）★ を 出す★ — ★その 前に 自分の 器の 沈黙（`2>/dev/null`）を 直す★。

## ② まだ boss1 に 出して いない 観測
★★現時点で ★0 件★★★ = ★#275 までの 観測は ★全部 送信済★（★#276 の 便は ★私に 届いて いません★ = 未着手★）
★引用 5 点の 形★ = `path / worktree / branch / sha / 算法` ⇒ ★以後の 新観測は この 形で 本 file の §索引に 追記★

## ③ 3 標本の 現在地（★entry 別・標本数★）
| 標本 | sha256[:16] | byte | 標本行 | entry 147 | entry 177 | t の 幅 |
|---|---|---|---|---|---|---|
| `runA.jsonl` | `788af8e90acd1512` | 22,492 | 23 | ★0★ | 23 | 8.870 s |
| `v5a.jsonl` | `b208fa4810dbd880` | 28,397 | 29（+footer 1） | 5 | 24 | 9.071 s |
| `v5b.jsonl` | `31b467ec3feb4118` | 34,222 | 35（+footer 1） | 5 | 30 | 7.481 s |
★算法★ = `pc − base` を entry 内 offset として 読む ／ ★header の `hz`=1000 は ★取得の 刻み★・★記録の 刻みでは ない★★
★★∴ ★3 本とも ★2 標本以上 = 8 pc★ ⇒ ★位置は 揃う / ★値（下界）は 揃わない★★★

## ④ 私の 器 と 信用度
| 器 | 用途 | ★信用度★ |
|---|---|---|
| `w2_cov.walk` | 到達枠の 本体（台帳 8 個の 出所） | ★恣意 4 件を 開示済★（GUARD=2048 / SWITCH_CAP=256 / dedup / 起点）＋★打ち切り 4 欄を 印字★ |
| `scn_core.escscan` | text 終端 | ★終端規則 = EXE 接地（中継）★ / ★★歩幅 2 byte は 裏付け なし★★ |
| `scn_walk_w2.load_len` | `Len[]` 256 | ★TSV guard つき（hash + 値・落ちる ことを 実測）★ / ★写し 154 項は 裏付け なし★ |
| `frame_w3mech` | 整列-静的枠 | ★worker3 の code の 逐語 再実装★ = ★★一致では なく 再現★★ |
| `exedis` | EXE disasm | ★素の 1 発は 94.1% 打ち切り★（実測）／`iter_insns` は 100% |
| ★`tools/send_verified.sh:60`★ | 送信前の 残留捕獲 | ★★★危険（沈黙を 測定に して いる）= ★未修正★★★★ |

## ⑤ 未解決の 問い（★答えでは なく 問い★）
1. ★`escscan` の 歩幅（2 byte）は 原盤の renderer と 同じか★ — ★摂動（1 byte 刻みで +3.4%）しか 持って いません★
2. ★到達枠の 偽 site 率は どれくらいか★ — ★#251 で 9/9 が 偽と 出た が ★母数 4,522 の 残りは 未読★★
3. ★`0x2D` の e149 の 連なり（58 個の 2 byte 対）は 何か★ — ★私は 分類して いません★
4. ★band 外 244 件（0x81 が 113）は 何か★ — ★1 件も 開いて いません★
5. ★時間軸の 下界が ★値で 揃わない★ 理由★ — ★候補 3（標本の 粗さ / host 実時間 / 人手操作）を 切り分けて いません★
6. ★`entries()` の 単調性判定で 止まる 位置は 原盤と 同じか★ — ★証人 = 私 1 + worker3 1（同じ file）★

---

# 索引（★以降は 追記★ / ★1 便 1 行★）

- ★#276 まで★: 詳細は worktree の `workspace/WORKER2_STATE.md`（★通番 -78 まで★）と `workspace/exchange/`（★103 file★）
- ★直近の 出力★: `exchange/dwell_3runs.txt`（3 標本の 下界）/ `exchange/devnull_three.txt`（私の 沈黙 4 行）/ `exchange/runA_vs_ref28.txt`（23 標本 × 28 命令）
