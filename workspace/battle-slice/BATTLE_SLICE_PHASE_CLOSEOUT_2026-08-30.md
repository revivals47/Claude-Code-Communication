# battle slice — phase closeout（2026-08-30・user 裁定 (B) = checkpoint）

**この phase をここで締める。battle assembly は ★次 phase として登録・即開始しない★。**

> **★格の原則★** = 本 doc の主張は **live 確定 / RE grade（未 live） / 引用（boss1 未再走）** の 3 段に分ける。
> **「式が検証された」とは書かない。**

---

## (a) 達成したこと

### A-1. 戦闘系の RE（静的・コード直読）

`damage` ／ `hit` ／ `迎撃` ／ `SITE B` ／ `MP` ／ `AI 3 段 fallback` ／ `接近` ／ `狙い 4 系統` ／
`RNG 2 形` ／ `技 id 帯` ／ `効果器 = 演出だけ` ／ `state = 進行列` ／ `勝敗 3 値` ／ `actor struct 帯`

**出所** = `BATTLE_SLICE_RE_FOUNDATION_2026-08-26.md`（3 track の doc から boss1 が集約・codex 査読反映済）。

### A-2. Unity 実装

**branch `track1/battle-slice-impl`** ／ **gate `DEGIMON_BATTLE_SLICE` は既定 OFF**。

> **★引用（worker1 の報告・boss1 は再走していない）★** = **173 本 GREEN** ／ **SEAM66 GREEN** ／
> **CutsceneVerify178 非退行 bit 一致**。**これらの数は boss1 の器では確かめていない。**

**★boss1 が実測した値★**:
- `track1/battle-slice-impl` の tip = **`a86e1b2b`**（2026-08-29 16:41 に凍結記録・**以後 不動**）
- **user 申告の `7f9dc0c8` は tip ではない** — **同 branch の祖先**（2026-08-26・`is-ancestor` = YES）。
  **食い違いではなく、参照点が違う。**

### A-3. ★主要 damage 式 ＋ 属性表 7×7 = 実機 live 確定★

- **決め手** = `dmg=398 / skill=20 / elem=4 / atk=140 / def=60 / species=3 / attr=[0,255,1]`
  **表あり予測 `329〜402` に入り、表なし予測 `219〜268` では説明できない** = **discriminating match**
- **予測は ★撃つ前に固定★**（`verdict.py` ＋ `BATTLE3_STEP1_PREREG_2026-08-29.md`）
- **★循環していない★** = 予測は我々のモデル、照合先は **実機が出した数値**（独立 oracle）
- **記録** = `BATTLE_SLICE_RE_FOUNDATION_2026-08-26.md` **§9.6**（commit `ce6020d`）
- **併せて確定した `eff_sum`** = `elem 0 × species 3` = **35**（観測 9 発・全 16 候補中 1 個）／
  `elem 2` = **40**（観測 2 発）／`elem 4` = **[45, 50]**（観測 2 発・`55` は `398` で落ちた）

---

## (b) ★格の区別 — live 確定 と「ほぼ合っている前提」★

| 項 | 格 |
|---|---|
| **主要 damage 経路（系統 B・相手 → 味方）** | **★live 確定★** |
| **属性表の寄与**（`eff_sum` が式に効くこと） | **★live 確定★** |
| 属性表の **個別 cell** | **49 セル中 ★5 個★ が live で示せた**（`[0][1]` `[2][0]` `[2][1]` `[4][0]` `[4][1]`）／位置として触れたのは 8 |
| **SITE B**（もう一方の damage 経路） | **未 live**（RE grade） |
| **迎撃 / カウンター** | **未 live** |
| **MP 消費** | **未 live** |
| **系統 A（味方 → 相手 の攻撃）** | **未 live** — 捕まえたのは **相手 → 味方** だけ（HP 収支で確認） |
| **属性表の他 44 cell**（`×0.5` / `×2.0` の帯） | **未 live** |
| **乱数項の分布** | **未 live**（幅と両立しただけ・分布は測っていない） |
| **命中判定 / bonus** | **未 live** |

> **★∴「主要式は実機確定・残りは ほぼ合っている前提」と書く。★**
> **★観測数には必ず「観測 N 発」と冠する★** — `HIT` 行は **受けた攻撃の全数ではない**
> （HP 収支で **掛けられた 7 段のうち 2 件の欠落**を検出）。**「何発起きたか」「何割」は書けない。**

---

## (c) 次 phase = battle assembly 配線（★再開 ready・即開始しない★）

### 在るもの

| | |
|---|---|
| **式** | **live 確定**（上記 A-3） |
| **属性表** | **5 cell が live**／残り 44 は表の値（未 live） |
| **技表** | `wazaTbl 0x801325C0` stride 16（`+0x04` power / `+0x09` element は live 一致） |
| **actor record** | 両 104 byte の **live snapshot × ★5 run★**（`battle3/raw_*.log` の `DUMP_B084` / `DUMP_B104`）<br>**★2026-08-30 訂正（2 段）★**<br>**① 初版の「7 run」は この欄では誤り** — **`DUMP` を持つのは ★5 本★**（worker1 #927-W1a の差し戻し・boss1 再走で確認）。<br>**② ★但し「7 が誤りで 5 が正しい」ではない — 7 と 5 は数えている対象が違う★**（worker3 #927-W3b・boss1 再走で確認）:<br>**★7 = capture run（`raw` log）の本数★／★5 = actor record snapshot を持つ run の本数★**<br>⇒ **本 doc で 5 と書くときは 必ず「actor record snapshot を持つ run」と冠する。**<br>**★注意★ = `raw_20260829_195615` は `HIT` を 5 行持つのに snapshot は 0** ⇒ **「`HIT` の在る run」と「snapshot の在る run」を同じ集合として join するとずれる。** |
| **勝敗 flag** | `0x8013E088`（u8）= **書き手 6 / 読み手 1**（EXE 全走査・下界）。敗北 `0x800AEDB0` と `1->0` `0x800E0A1C` は **live 観測** |

### 要るもの（**#907-A の材料札のまま・未着手**）

1. **actor の stat を `base_stats` から積む配線**
2. **field → battle の繋ぎ** = 「**script を起こした actor**」（`gp-0x6d08` = `0x8013E104`）の **remake 側の対応物**
3. **技の効果の裁定** = **mini-VM か hand-expand か**（`0x66` の case は現在 **seam のみ・STUB**）

### 未決のまま残す open（推測を書かない）

- **勝利 site `0x800AEEC8` は 1 度も live で通っていない**。理由は **未検証**。
  **(c) 専用の器は用意済（`capture_c.gdb` ほか・撃っていない）** — **勝利数 `0x80141D6C` の変化を見張る形**。
- **pad `0x8013E2C0`** = **入力で動くことは確定**（`PAD_CHANGE` 13 本）。**bit ↔ ボタンの対応は未検証**（3 つ目の札）。
- **`HIT` 行の欠落**（+12 / +6）の原因 = **(α) damage watchpoint も値変化でしか止まらない / (β) `pc` 限定 / (γ) 攻撃以外の減り** = **未検証**。

---

## (d) 不変 8 値 と 捕獲 harness の在処

### ★凍結 8 値（2026-08-30 21:0x 再採取・着手前と同一）★

| 対象 | 値 |
|---|---|
| `track1/battle-slice-impl` | `a86e1b2b` |
| `track2/battle-re-damage` | `4f02c681` |
| `track3/battle-re-ai` | `f7d60c27` |
| `live_compare.cs` | `4dc3fb8f18d2dfef` |
| `expected_counts.txt` | `73485518b9bf93a4` |
| `live_obs_template.txt` | `0356363db519e98b` |
| `run_step7.sh` | `c020a581eca4fe12` |
| `W1_RUNBOOK_BATTLE3_2026-08-27.md` | `23814247c21878b5` |

### 捕獲 harness

`comms:workspace/battle-slice/battle3/` = `capture.gdb` ／ `verdict.py` ／ `run.sh` ／ `stop.sh` ／
`README_user.md` ／ `COVERAGE.md` ／ **(c) 専用** `capture_c.gdb` ／ `run_c.sh` ／ `stop_c.sh` ／ `verdict_c.py` ／ `README_c_user.md`
＋ **live log 7 run**（`raw_*.log` / `result_*.txt`）＋ `attribute_matrix.json`

- **使ったのは data watchpoint（`watch` = remote Z2/Z3）のみ** — `break`/`hbreak`/`tbreak` は **0 件**（機械確認）。
  **7 run すべてで DuckStation の再起動は発生していない = 安定**。**`hbreak`(Z1) で 3 回落ちた 2026-08-21 とは別系統。**
- **2026-08-30 に detach 済** = watchpoint 全解除 ＋ `continue` ＋ gdb close。
  **detach 後 CPU 313 tick/3 秒 = 動作中・実 gdb 0 件。★実機には再接続しない★。**

### 器の在処（git の外）

**`p2w2:workspace/slps_disasm.txt` は untracked・6.4 MB**（`.gitignore:97`）⇒ **p2w2 を掃除すると消える**。**退避は未決。**

---

## worktree 掃除（本 checkpoint）

- **`-bisect178` は ★存在しなかった★**（`git worktree list` に 0 件・filesystem にも無し）。
- **除去したのは `degimon_world_remake-integp2b` の 1 本**（**boss1 の一時 integration worktree**）。
  **branch `integration/p2-battle-v2`（`ea600ab5`）は残した** = **commit は 1 つも失っていない**。除去前 **未 commit 0 行**。
- **worktree 11 → 10。** **凍結 3 本（`-p2w1` / `-p2w2` / `-p2w3`）は残置・tip 不動。**

## team stand down

**worker1 / worker2 / worker3 とも idle。新 dispatch は出さない。**

## 不変

**push HOLD**（push は user 指示まで）／**gate 既定 OFF**／**完成 claim 凍結（user 実視覚まで）**／
**実機再接続なし**／**main 未変更**／**凍結 8 値 不動**。
