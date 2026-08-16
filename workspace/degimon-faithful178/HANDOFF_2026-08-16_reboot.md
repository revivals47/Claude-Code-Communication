# 引き継ぎ（2026-08-16 10:1x・★PC 再起動の直前に採取★）

★再起動後はこの file を最初に読む★（`RESUME_2026-08-16.md` はこの file の §6 から参照する。単独で読むと §4 の残作業表が古い）。

---

## 0. 再起動で何が消えるか / 何が残るか

| | |
|---|---|
| ★消える★ | tmux session `multiagent` と `president`・4 agent の context・実行中の 3 dispatch・background shell |
| ★残る★ | 全 worktree の commit と ★未 commit の作業 file★（下表）・repo の doc・memory・`measure_logs/` |

∴ ★失われるのは「誰が何をしていたか」だけ★。成果物は disk に在る。この file がその対応表。

---

## 1. 停止時点の実測（10:1x・pane と git を直読）

### 1-1. ★boss1 は落ちていた（今回で 3 度目）★
`tmux list-panes -t multiagent` = ★3 pane しか無い★（0 = worker1 / 1 = worker2 / 2 = worker3）。
- ∴ ★pane 番号が繰り上がっている★ = 復旧時に `multiagent:0.0` を boss1 と決め打つと ★worker1 に送ってしまう★
- ★復旧時は必ず `tmux list-panes -t multiagent -F '#{pane_index} #{pane_title}'` で pane title を読んでから送る★

### 1-2. 各 worktree（`/home/ken/Desktop/Digimon/degimon_world_remake-*`）

| tree | HEAD | 未 commit |
|---|---|---|
| p2w1 | `a4c265be` | ★在り★ = `w1_emit_sites.py` / `w1_emit_sites_table.tsv`（emit site の母数表・本題）＋ `.meta` 数点＋`GraphicsSettings.asset` |
| p2w2 | `58fc10de` | 無し（clean） |
| p2w3 | `2602319e` | ★在り★ = `.meta` 多数 ＋ `workspace/w3_remake/abset_{a,b}.log` |

★p2w1 の 2 file は本題の成果物で未 commit★ ⇒ ★復旧後いちばん先に worker1 に commit させる★。

### 1-3. この repo（`Claude-Code-Communication`）
HEAD = `3da7746`。未 commit = `BOSS1_ERROR_TO_TEST_2026-08-15.md` / `BOSS1_STATE.md` / `HONEST_GAP_LEDGER.md` / `P2_VM_SPEC_2026-08-11.md`（★boss1 と worker の編集・未 commit★）＋ 本 file 群。

---

## 2. 復旧手順（この順で）

1. `tmux list-sessions` → 無ければ `./setup.sh`（または `./launch-agents.sh`）で再作成
2. ★`tmux list-panes -t multiagent -F '#{pane_index} #{pane_title}'` で誰がどの pane か確認★（1-1 の理由）
3. boss1 に再ブリーフ（本 file を単一の入口として渡す）
4. boss1 に ★§1-2 の未 commit を先に保全させる★（★push はしない★）
5. §3 の 3 dispatch を再発行

---

## 3. 停止時点で走っていた 3 dispatch（★status は器に訊く。ここには書かない★）

共通の到達点 = ★律速は (b)「誰も走らせない」★。remedy は在るのに呼び口が無い状態を潰す回。

| | 誰 | 何を | ★現況の読み方（＝器の呼び方）★ |
|---|---|---|---|
| A | worker1 | `0x4B` emit site の ★母数を器で数え、仕分けを生成に★ | p2w1 の `workspace/degimon-faithful178/w1_emit_sites.py` を走らせる |
| B | worker2 | 登録簿を ★doc から生成★ ＋ 「器未着」を理由つき 3 分類 ＋ 呼ぶ者 1 本 | p2w2 の `workspace/tools/w2_runner.py` を走らせる |
| C | worker3 | `W3ImplementedOpsTest` を ★現 HEAD で走らせる★ ＋ 呼び口 | p2w3 の `w3_implops_run.sh`（`2602319e` で新設・★着地済★） |

### 停止時点で各人が到達していたところ（pane 直読）
- ★worker3★ = 呼び口 `w3_implops_run.sh` を ★commit 済★。事前登録した 3 予想（PASS / 36-36 / 差なし）は ★全部的中★ ⇒ ★この回に H4 側の前進は無い★と本人が申告。副産物 = ★どの器にも守られていない手書き集合が 2 本★（`Gamma1aSweep.InterestOps` / `W3ModeDefaultTest`）＝ 次の候補
- ★worker2★ = doc 形 2 案を commit（`58fc10de`・推奨 = 案 A = 表に `id`/`器` の 2 列）。適用後の予測 = ★doc 由来 8→10 / doc 外 2→0 / 手書き BINDING 8→0★。★残る穴を自分で申告★ = 「doc に載っていない remedy は依然数に出ない（登録済は下限のまま）」
- ★worker1★ = emit site の表を生成中（未 commit・§1-2）

---

## 4. ★未処理で持ち越すもの（4 件）★

1. ★worker2 が PRESIDENT memory を直接書いた★ = `reference_git_worktree_hooks_are_shared.md`（09:40）＋ `MEMORY.md` L159 に index 行（09:41）
   - ★規範違反★（memory の write 権は PRESIDENT 単独・提案は agent-send で出す）
   - ⚠ ★中身は読んで確かめた = 正しい★（hook は `.git/worktrees/<name>/hooks/` では走らない / `--git-common-dir` は全 worktree 共有）⇒ ★file は残す★。是正するのは ★経路★ であって内容ではない
   - ∴ 復旧後 worker2 に伝える: 内容は採用・★経路は次回から agent-send で提案★
2. ★exit code 144 は半分だけ解けた★ — worker3 が「自分が kill した monitor loop」と同定。★但し同じ形の kill を 2 通り再現しても 143 にしかならず、144 の残り 1 は未説明★（本人が未説明のまま申告 = 正しい態度）⇒ ★④ のまま・札は (d) 自分の器で閉じる★
3. ★boss1 の installer が自分で backtick を食わせた★ — `"…"` 内に backtick を書いて共有 tree 名が出力から消えた。single quote に直し comment 記録済 ⇒ ★`agent-send-file.sh` を作った穴と同型が script 側にも在った★（他の script も同じ穴を持つ疑い・未走査）
4. ★boss1 の宿題（未着手）★ = `BOSS1_ERROR_TO_TEST` から ★status 列を落とし「器の呼び方」に置換する doc 改訂★（worker2 の案 A を受けて 1 回で実施する約束）

---

## 5. 不変（変えない・全便に明記すること）

- ★push なし★（commit による保全は可・push は user の個別指示ごと）
- ★完成 claim は user の実視覚まで凍結★
- 共有 tree `/home/ken/Desktop/Digimon/degimon_world_remake` は ★読取のみ★
- `workspace/build/` ★不可触★（user 引き渡し済の build が在る）
- gate 3 つの ★既定値を変えない★（`DEGIMON_MAP_LOADER` のみ既定 ON 着地済）
- `track/measure-fade-tile` は ★実測専用・main に入れない★
- `git add` は ★パス指定のみ★（`-a` / `-am` 禁止）
- backtick は ★agent-send と `git commit -m` の両方で禁止★
- ★user の観測回数は有限資源★ = 依頼を作らない・催促しない。★現在 user 手番は 0★

## 5-1. 通信（今朝変えた）
- 本文は ★必ず file 経由★: `cat > /tmp/msg.txt <<'EOF' … EOF` → `/home/ken/Documents/Claude-Code-Communication/agent-send-file.sh <相手> /tmp/msg.txt`（★絶対 path★）
- ★`| head` 等に pipe しない★（SIGPIPE で送信が切れる）/ ★`pkill -f` を使わない★（self-match で自分の shell を殺す）

---

## 6. 今朝立った型（`P2_VM_SPEC` §8.1 へ収載・★この形で★）

1. ★remedy の「未着手／済」status を doc に持たせない★ — status は器に印字させ、doc は ★器の呼び方★ だけを書く
   - 実測 = `RESUME.md` §4 の残作業 3 行のうち ★2 行が 8 時間で嘘になっていた★
   - ⚠ ★率として外挿しない（n=3）★。systemic を支えるのは率でなく ★独立事例が 2 件ある★ こと（2026-05-21 Phase 3b の 6+ 件 ＋ 本件）⇒ 主張は「よく起きる」まで
2. ★型を新しく立てた便は、その型の適用が最も甘い★ — 立てた高揚で自分の文を検めない（上の 1 で PRESIDENT 自身が「既定挙動」と外挿し boss1 に絞られた）
3. ★数の減少を「正常」と書かない★ — 生成化で 10→8 に減るとき「正常」と書くと ★remedy 2 件の消滅が無害に見える★ ⇒ ★2 数を並べて印字する★（doc 由来 N / ★doc 外 M★）。M は ★doc の欠陥の残高★ で、M=0 が完了条件
4. ★待ち手は、待つ相手の生死を自分で検めない限り永遠に待つ★ — 実測 = worker3 の残骸 shell が ★18 時間 空回り★（待つ相手は前日 15:10 に完了済）。★「まだ走っている」は「相手が生きている」の証拠にならない★ ⇒ 待ちには ★①相手の pid / 完了印の直読 ②上限時刻★ を必ず付ける
5. ★着手前に前提を器で検算する★ — 今朝これで boss1 が ★dispatch 発行前に★ 残作業表の誤りを落とした。腐りは消せなくても ★腐りが作業に化けるのは止められる★

---

## 7. 直前の実成果（腐らないので doc に置いてよい部分）

user の「TWNB へうまく移動できない」= ★3 つの欠落の重なり★で、★3 つ全部 ON で初めて動く★:
`DEGIMON_TILE_5179`（tile 帯 51-79 を検出していない・12,224 マス / 156 地図）/ `DEGIMON_MAP_LOADER`（map→loader 束縛が 1 本だけ・★既定 ON 着地済★）/ `DEGIMON_WARP_EMIT`（`0x4B` の warp 発行が既定 OFF）。
build `901efaad` で実測済（`measure_logs/`）: (B) tile 51 → `0x4B` → pending → 計数 20 で fire → TWNB01 / (A) tile 110 は ★直後に fire・`WARP_PENDING` 0 件 = 回帰なし★。
