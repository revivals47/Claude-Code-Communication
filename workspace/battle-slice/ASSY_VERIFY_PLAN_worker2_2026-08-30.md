# battle assembly — ★実装検証の計画（worker2）★ 2026-08-30

**役 = 実装検証・照合。** **base = `integration/p2-battle-v2`（`ea600ab5`）／worktree = `degimon_world_remake-assy`。**
**★私は tree に 書いていない★**（本 doc と `tools/` は **comms repo 側**）。

> **★この doc で 私が 実際に 走らせた もの★** = ① 生成器 `gen_obs_from_events.py` の 再実行、
> ② `git show ea600ab5:` からの baseline 再採取、③ 自作 2 器の self-test。
> **★私は Unity を 1 度も 起動していない★**（同時 1 本の規範 ⇒ boss1 の ack 待ち）。
> **∴ 本 doc 中の `SEAM66` / `CUTSCENE178` の 数は ★boss1 の実走の 引用★ であって 私の観測ではない。**

---

## 1. ★verify の baseline を 固定する（依頼 (1)）★

### 1-1. 器 = `tools/w2_assy_gate.sh`（**生成器**）／`ASSY_GATE_LEDGER.tsv`（**生成物・手で編集しない**）

```
./tools/w2_assy_gate.sh --selftest            # Unity 不要。parser の 陽性対照
./tools/w2_assy_gate.sh --run <label>         # 2 本を 順に 回して ledger に 1 行 足す
./tools/w2_assy_gate.sh --parse <seam.log> <cut.log> <label>
```

**★「緑になった/赤のまま」を 書かない★** — **`--run` は 常に ★同じ 10 欄★ を 1 行 足すだけ**で、
**判定は ★前後の 行を 並べて 目で 引き算する★。**

| 欄 | 出所（逐語 grep） |
|---|---|
| `SEAM66_RESULT` / `textIdentical` / `OFFgated` / `ONgated` / `reach` | `[SEAM66] RESULT=…(textIdentical=… OFFgated=… ONgated=… reach=…)` |
| `SEAM66_SYNTH` | `[SEAM66] RESULT=…(SYNTH)` |
| `CUT178_pages` / `CUT178_chars` / `CUT178_termPc` | `[CUTSCENE178] BASELINE-CHECK pages=…/… chars=…/… termPc=…/…` |
| `CUT178_RESULT` | `[CUTSCENE178] RESULT=…` |

### 1-2. ★器の 自己検定（5/5 OK・Unity 不要で 再現可）★

| # | 何を 検めたか | なぜ 要るか |
|---|---|---|
| 1 | 既知 baseline の 逐語行から 4 値を 取り出す | 抽出が 効いていること |
| 2 | **log が 無い ⇒ 全欄 `MISSING`** | **★退路を true で 返さない★**（`0` にも `OK` にも 畳まない） |
| 3 | **行は 在るが 値が 欠ける ⇒ その欄だけ `MISSING`** | 部分欠損を **埋めない** |
| 4 | 値が 動いた log は **動いたと 出る** | **baseline を parser に 焼き付けていない**（陰性対照） |
| 5 | **`RESULT=` 2 行（PLAY / SYNTH）を 別欄で 保つ** | **★私が 実際に 踏んだ穴★**（`tail -1` で **SYNTH を 主結果と 誤読**していた）の 回帰 |

### 1-3. ★baseline 行（ledger 1 行目・出所は boss1）★

```
label                                                   SEAM66  txtId  OFFg ONg reach SYNTH    pages  chars    termPc        CUT178
step0_BASELINE_ea600ab5(出所=boss1実走・worker2未実走)  GREEN   True   0    7   7     MISSING  0/66   0/1601   0x1A/0x1315   FAIL
```

**逐語は `baseline_quote_boss1/*.md` に file 化し、★表は そこから 機械 parse★**
（**★手で 表に 書き写さない★** = 転記の 穴を 1 箇所に 閉じる）。**file 冒頭に「worker2 が走らせた log ではない」と 明記。**

### 1-4. ★各 step 後の 手順（これを そのまま 回す）★

1. **boss1 に 1 行 ack**（**Unity 同時 1 本**）→ 許可を 待つ。
2. `./tools/w2_assy_gate.sh --run step<N>_<sha先頭8>` — **label に ★commit sha★ を 入れる**（**「いつの状態か」が 言える**）。
3. **器が 自動で 見るもの**: **`error CS` 合計**／**assy tree の `git status --porcelain` の sha256 が run 前後で 不変**
   （**★私の run が tree を 汚していないことを 数で 示す★**）。
4. **ledger を 前行と 並べる。★動いた欄だけ★ を 報告する。**

### 1-5. ★判定の 書き方（固定文）★

- **`CUT178` 3 値が `0/66・0/1601・0x1A/0x1315` の まま** ⇒ **「この RED から ★非退行★」**。
  **★「GREEN に 戻った」は 本 phase の 目標では ない★／★戻っても それ自体は 合格条件では ない★**（別要因の 混入を 疑う）。
- **`SEAM66` が `GREEN(True,0,7,7)` の まま** ⇒ **seam は 非退行**。
- **どれか 1 欄でも 動いたら ⇒ ★battle 起因の 候補★** として **step を 名指しで 報告**（原因は 別途）。
- **`MISSING` が 出たら ⇒ ★合格でも 不合格でも ない★。器の 不成立として 先に 直す。**

---

## 2. ★step ごとの 照合の観点（依頼 (2)・★実装が 出る前に 書く★）★

**★行番号は 書かない★**（§11 の規範）。**参照は 関数名 / 定数名**、位置は **その場で `grep -n`**。
**以下の 現状は ★私が `ea600ab5` の git object で 直に 読んだ★**（tree からではない）。

### step 1 — counter が **1 回だけ** 進むか

**現状（私が 数えた）**: 加算の 書き手は **系統 A = `BattleEntry.AdvanceBattleCounter`（`stats.Battles += 1`）**、
**系統 B = `GameState.SceneDriverCounterInc`（`RawE12C++`）** の **各 1 件**。

**★観点★**
- **`0x66` は battle gate の 後も scene-driver B2 に 進む** ⇒ **★park / 再入で B の `++` が 毎 frame 走らないか★**。
  **§11-5 のとおり `_pc` を `0x66` に 据え置く** ⇒ **★再入 guard が `SceneDriverCounterInc` より ★前★ に 在ること★** を 式で 確かめる。
- **A の 加算が 消えたこと**は **★下の 規則で★** 数える（§2-末の 器）。
- **`IBattleStats.Battles`（save `+0x1DA`）と `RawE12C` は ★別 counter★** ⇒ **畳んで 1 つに していないか**。

### step 2 — 終了判定が **味方**を 読むか ＋ `Result` が `Zero` 固定でないか

**現状**: `BattleRuntime.IsPartnerDown()` は **`_actors[1].IsDown()`** を返し、**`_actors.Count < 2` で throw（loud）**。
`Tick()` は 終了時に **`Result = BattleResultCode.Zero;`** を **固定で** 入れる（**STUB 注記つき**）。

**★観点★**
- **`_actors` は ★登録順 = 空間 A・味方は index 0★** ⇒ **終了判定が 読む index が 味方に なったか**。
- **`IndexEveryFrame`（= 0）を 使う 他 3 箇所（`BattleAi` の AI 対象 / `Tick` の 毎 frame tick / 末尾）も ★同時に★ 見る**
  — **index の 意味を 動かすなら 片側だけ 直すと ★毎 frame tick が 敵に 移る★。**
- **`Result`**: **§9 で ★0 = 逃走★** ⇒ **KO で `Zero` は ★意味が 反転★**。**`-1` / `1` に 写っているか**、
  **かつ ★写像の 根拠が §9（味方 `+0x4C == 0` なら `-1`）で あって 発明で ないか★**。
- **★`0` を 返す 経路が 残っていたら bug★**（逃走は 本 phase で 入力を 作らない）⇒ **`0` が 出たら loud に 落ちるか**。

### step 3 — `RawE104` が `0` の時に **黙って 通していないか**

**現状（私が 読んだ）**: `0x66` の **B4** は **WIRE OFF 側 = `Debug.LogWarning`（`arg E104=0x…（未 populate）→ 成功系`）を ★無条件で★ 出す**、
**WIRE ON 側 = form が gap の とき `LogWarning`**。**∴ 実装前は ★既に loud★。**

**★観点★**
- **battle 経路を 足した後も ★この loud 行が 0x66 進入ごとに 出続けるか★**（**battle が B4 を 迂回して 消していないか**）。
- **★loud を 値で 条件づけていないか★**（`E104 != 0` の 時だけ 出す 形に すると **`0` こそ 見えなくなる**）。
- **`sdResult` の 成功系 固定（`0`）が ★battle の 結果コードと 混ざっていないか★**（**別の 0**）。

### step 4 — stat が **固定 test 値**か

**現状**: `BattleRuntime.ApplyEntryStatsAlly` は **表の 6 欄を `H48/H4A/H38/H3A/H3C/H3E` に 書く**。
**★味方の `+0x4C`（＝ 終了判定が 読む 現在 HP）は ここでは 埋まらない★**（原盤も 別関数・**未 RE・札=材料**）。

**★観点★**
- **live snapshot の 実値**（**味方 83/61/71/74・802/603/417/30 ／ 敵 110/100/100/100・300/600/300/600**）が
  **★入っているなら「live snapshot から 積んだ」と 書いてあるか★**。
- **★「実 save から 積んだ」と 書いていないか★** — **save 経路は 通していない**（**書いたら 期待値を 観測扱い**）。
- **★`ApplyEntryStatsAlly` が 味方の `+0x4C` を 埋めていないか★** — **埋めたら ★発明★**
  （**原盤では 表の 値は `+0x48/+0x4A` へ 行く**。畳むと **現在 HP が 表の値で 上書きされる 別物**に なる）。
- **敵と味方で ★初期化が 分かれているか★**（**畳んでいないか**）。

### step 5 — 敵 `+0x48/+0x4A` が **未設定 ＋ loud** か

**現状**: **敵の 入場は 1 欄目 → `+0x4C` / 2 欄目 → `+0x4E`**（**味方だけが `+0x48/+0x4A`**）。
**∴ 敵の `+0x48/+0x4A` は ★誰も 書かない★** のが 原盤どおり。

**★観点★**
- **敵の `H48/H4A` を ★既定値 0 の まま 黙って 使っていないか★** ⇒ **読み手（`BattleAi` の 4 本組の外 参照）で ★loud★ に なるか**。
- **`BattleAi` の 注記（「原盤は `+0x48` を 読むが slice では 真似ない」）と ★実装が 一致しているか★**
  — **doc が「真似ない」で code が 読んでいたら 乖離**。
- **★0 を「値」として 扱っていないか★**（**未設定と 値 0 を 区別できる 形か**）。

### ★step 1 の 完了条件は ★規則を 名指しで★ 書く（器 = `tools/w2_counter_census.sh`）★

**boss1 と 私で ★数が 割れました★**（`ea600ab5`・同じ commit）。
**★どちらが 正しいかでは なく 何を 数えた数か★**（worker3 の型）:

| 規則 | 系統 A | 系統 B | 割れの 中身 |
|---|---:|---:|---|
| **R1 = 識別子が 現れる 行** | **7** | **6** | **boss1 の B = 4** — **comment 1 行 と `Debug.Log` 1 行を 数えていない**。**★両方 正しい（規則が 違う）★** |
| **R2 = 宣言 / 定数 / field** | 4 | 2 | |
| **★R3-inc = 加算の 書き手★** | **1** | **1** | **★ここは 完全一致★** |
| R3-reset（`= 0`） | 1 | 0 | |

**★∴ §11-2 の 完了条件は 「系統 A が 0 件」では ★曖昧★★** — **どの規則の 0 かで 意味が 変わる**。**私の 提案（boss1 の 裁定を 求めます）**:

> **完了条件 = ★系統 A の R3-inc == 0★ かつ ★系統 B の R3-inc == 1★。**
> **★R1 == 0 は 条件に しない★** — **§11-2 自身が 「`IBattleStats.Battles` の 実装先は 未定」と している**ので、
> **field / interface が 残っても 加算の 口が 1 つなら 条件を 満たす**。
> **★R1 を 条件に すると 正しい実装を 不合格に し、逆に 宣言だけ 消して 加算が 残った実装を 見逃す★。**

**陽性対照は 器に 内蔵**（**系統 B が 0 件 なら ★系統 A の 0 件を 主張せず exit 4★**）。
**boss1 の「0 件 を 書く前に 系統 B を 確かめる」を ★人の手順では なく 器の 分岐★ に した**
（**[[feedback_norms_need_pre_registration]]** — **配るだけでは 発火しない**）。

---

## 3. ★生成器 → 生成物（依頼 (3)）★

**★該当する 生成物は 在りました★**（**「無ければ無い」で 返すつもりでしたが 在ります**）。

| | |
|---|---|
| 生成器 | `workspace/battle-slice/gen_obs_from_events.py` |
| 入力 | `degimon_world_remake-assy:workspace/live/battle_2026-08-27/events4.jsonl`（**tracked**・私の 保全 commit `0785b549` / `4f02c681`） |
| 生成物 | `workspace/battle-slice/obs_battle2_2026-08-27.txt` |

**★再実行と 生成物の 一致（数で）★**

```
再実行  sha256 88f59c2ced7b3d24 / 77 行
生成物  sha256 88f59c2ced7b3d24 / 77 行     ⇒ ★byte 一致（diff 0 行）★
適用条件（生成器が 先に 検査）= ally 束内最大 0.058s / 発間最小 2.497s、enemy 0.061s / 2.664s ⇒ 成立
```

- **生成物を 手で 編集していない**ことは **上の 一致が 示す**（**編集していたら ずれる**）。
- **実行は ★scratchpad へ 出力★**。**assy tree には 1 byte も 書いていない**（`git status --porcelain` = 空 を 確認）。
- **★この phase で 新しく 出す 表（ledger / census）も 同じ扱い★** = **生成器つき・手編集禁止**。

### ★私が 途中で 踏んだ 穴（記録・型として）★

**`events*.jsonl` を `find -maxdepth 4` で 探して ★0 件★ を 得た** — **入力は 深さ 5 に 在った**。
**★打ち切った list の 不在は 否定では ない★**（[[feedback_absence_in_truncated_list]]）。
**★しかも 私は そのとき 陽性対照を 誤った 場所に 当てていた★**（**comms repo に 在る file を Desktop 側の 探索の 対照に した**）
⇒ **★陽性対照は ★探した その 母数の 中に★ 実在する file で 立てる★**。**深さ 制限を 外して 再探索して 見つかった。**

---

## 4. ★私が していないこと（範囲申告）★

- **Unity を 起動していない** ⇒ **`SEAM66` / `CUTSCENE178` の 数は ★私の観測では ない★**（boss1 実走の 引用）。
  **器 `--run` は ★未実走★**（`--selftest` と `--parse` のみ 実走・5/5 OK）。
- **assy tree を 読んだだけ**（`git show` / `git grep`）。**書いていない。**
- **`CutsceneVerify178` の RED の 原因を 追っていない**（**本 phase の 目標外**・登録済 follow-up）。
- **step 1〜5 の ★実装を 見ていない★**（**まだ 出ていない**）。**上は ★観点★ であって 判定では ない。**
- **damage 式の うち ★live 確定は 主要式 ＋ 属性表の寄与だけ★** — **SITE B / 迎撃 / MP / 系統 A / 他 44 cell /
  乱数分布 / 命中 / bonus は ★未 live = RE grade★**（FOUNDATION §9.6）。**照合で これらに 依存しない。**
- **★最終 verify は user 実視覚★** — **本 doc の どの数も 完成の 根拠に ならない**（**我々 3 人とも GUI の視覚 verify 不可**）。

---

## 5. ★step 1（`011238c6`）の 照合結果 — ★Unity を 使わない 範囲だけ★★（追記 2026-08-30）

**★Unity は worker1 が 使用中（boss1 通知 #1）★ ⇒ 私は 起動していない。**
**以下は すべて `git show` / `git grep` を ★commit object に 当てた★ 静的照合。**
**∴ ★`SEAM66` / `CUTSCENE178` の 4 値は 未取得★（`ledger` は `step0` の 1 行のまま）。**

### 5-1. counter の 口（§11-2）= ★条件を 満たしている★

| 規則 | `ea600ab5`（実装前） | `011238c6`（step1） | 判定 |
|---|---:|---:|---|
| 系統 A `R3-inc`（加算の書き手） | **1** | **★0★** | **(i) 満たす** |
| 系統 B `R3-inc` | 1 | **1** | **(ii) 満たす** |
| **系統 B `R4`（★呼び出し site★）** | 1 | **★1★** | **(ii) 満たす** |
| 系統 A `R1`（識別子行） | 7 | 5 | **条件では ない**（field / interface は 残ってよい） |

**陽性対照** = 同じ器・同じ母数で **系統 B が 6 行 見つかる** ⇒ **★系統 A の 0 件は 意味を持つ★。**

### 5-2. ★§11-5 の 順序（guard が 加算より 上か）= 満たしている★

**`011238c6` の `DialogueRuntime.cs`（★行番号は 今 数え直した値★・doc に 固定しない）:**

```
1983  if (_battle != null)          ← ★再入 guard★
1992  SeamReachCount++              ← guard の 下（gate 非依存の 器の性質が 保たれる）
1998  bool battleGate = GateEnabled ← ★snapshot（§11-1）★
2007  _gameState.Advance0x66Counter()  ← ★加算は guard の 下★
```

**⇒ ★park 中の 再入では 加算に 到達しない★**（worker3 の 失敗形 1 を 踏んでいない）。
**★但し これは 静的な 前後関係★** — **「実際に 1 回だけ 進む」は ★走らせるまで 言えない★**
（**`ParkTicks` を 増やしながら 加算に 来ないこと**は **実走の `E12C` で 見る**）。**Unity 待ち。**

### 5-3. ★★私の器の 穴（v1）— 記録して 型に する★★

**v1 の `w2_counter_census.sh` は counter の method 名を ★hardcode★ していた**（`SceneDriverCounterInc`）。
**worker1 が `Advance0x66Counter` に ★改名★ した途端、★呼び出し site が 器から 消えた★。**
**それでも v1 は 「系統 B = 加算 1 件」で ★合格を 出した★** — **宣言（`RawE12C++` の 行）は 名前に 依らず 残るため。**

> **★型★ = ★名前で 探す 器は 改名で 黙って 盲になる。しかも 宣言だけ 見ていると 合格が 出続ける★。**
> **remedy = ★変異（`RawE12C++`）から 出発して 包む method 名を 導き、その 名前で 呼び出し site を 数える★。**
> **★宣言の 存在は 口の 数では ない★** — **v2 で `R4`（呼び出し site）を 別の 規則として 足した。**
> **同型** = [[feedback_zero_count_needs_emitter_census]]（**0 件は emitter 全列挙とセット**）／
> [[feedback_pgrep_guard_self_match]]（**名前で 当てる guard は 改名で 外れる**）。

**★v2 では 除いた行も 数で 出す★**（`宣言行=1 / comment 行=1`）= **黙って 落とさない。**

### 5-4. ★私が step 1 について ★言っていない★ こと★

- **`BattleSession` / `BeginBattleAtomic` / `EndBattleAtomic` の ★挙動★ は 見ていない**（**構造を 読んだだけ**）。
- **`FieldState.Exit()` の lock 解除と teardown の 原子性（§11-1）は ★未照合★。**
- **`warp pending` invariant（§11-3(1)）が ★実際に loud に 落ちるか★ は 未実走。**
- **step 2〜5 は **実装が 出ていない** ⇒ **§2 の 観点の まま。**

---

## 6. ★step 1 の 実走（`011238c6`）— ★4 値を 採った★★（追記・boss1 #929-W2c の GO 後）

**Unity GO を 受けて 実走。★終了後 ps で Unity 残 0 件・assy tree は `011238c6` / porcelain 0 = 汚していない★。**

### 6-1. ledger（★生成物・手で編集しない★）

```
label                                    SEAM66  txtId OFFg ONg reach SYNTH   pages  chars   termPc       CUT178  tree            harness_sha   gate_sha
step0_BASELINE_ea600ab5(逐語引用・未実走) GREEN   True  0    7   7     ABSENT  0/66   0/1601  0x1A/0x1315  FAIL    QUOTE           QUOTE         QUOTE
step1_011238c6                            GREEN   True  0    7   7     ABSENT  0/66   0/1601  0x1A/0x1315  FAIL    011238c6+clean  fed57f47bbb4  00ce90e1b741
```

**★数値 10 欄が 全て 同一★ ⇒ ★step 1 は この baseline から 非退行★。`error CS = 0`（両 log）。**
**母数** = `entries 225/225`・`sections 1556` → **★実行到達 666（打ち切りなし）★**／`SITE 0x00 以外 = 0 件`。

### 6-2. ★出所欄（boss1 #929-W2c ■4 の依頼）★

**`compile_gate.sh` が 凍結 tree を hardcode し ★4 日間 偽 GREEN を 出していた★** ⇒
**★「その行を 出した器の 版」を 欄に 持つ★**:

| 欄 | 中身 | なぜ |
|---|---|---|
| `tree(HEAD+dirty)` | `011238c6+clean` | **★Unity が 読むのは commit ではなく working tree★** ⇒ **HEAD sha だけでは 足りない**。**dirty 件数を 併記。** |
| `harness_sha` | `fed57f47bbb4` | harness 2 本（`BattleSeamVerify66.cs` ＋ `CutsceneVerify178.cs`）の sha |
| `gate_sha` | `00ce90e1b741` | 同居する `compile_gate.sh` の sha（**この行を 出した器一式の 版**） |

**出所は ★run 時に `provenance.txt` へ 固める★**（**後から 採り直すと 別の tree を 刻みかねない**）。

### 6-3. ★★自己申告 = 不在を 1 種類に 畳んでいた★★

**`SEAM66_SYNTH` が 両行とも 空だったが ★意味が 違う★:**
**step0 = ★boss1 の 逐語引用に その行が 無い★／step1 = ★実 log に SYNTH が 1 件も 出ていない（`grep` 0 件）★。**

> **★型★ = ★不在は 1 種類では ない★。「器が 見ていない」と「実機が 出さなかった」を 同じ記号に 畳むと、
> ★後者を 前者だと 読んで 見逃す★**（**[[feedback_retreat_must_not_encode_as_pass]] の 親戚** —
> **`true` に 畳まなくても ★2 つの 不在を 1 つに 畳めば 同じ穴★**）。

**remedy（実装済）** = **`NOLOG`（log file が 無い）／`ABSENT`（log は 在るが 行が 無い）に 分けた。**
**読み方** = **`tree` 欄が `QUOTE` の行の `ABSENT` は「引用に 無い」**／**実 tree の行の `ABSENT` は「★出なかった★」。**
**`SYNTH` は 合否条件外** ⇒ **4 値の 判定には 影響しない。**

**併せて** = **raw log 168MB を gzip（3.5MB）。★`f()` は `.gz` も 同じ file として 読む★**
（**★保管の都合で 不在が 増える★ のを 防ぐ** = **圧縮したら `NOLOG` になる、では 器が 壊れる**）。

### 6-4. ★step 1 の 判定（確定）★

| 条件 | 結果 |
|---|---|
| §11-2 (a) 系統 A の `R3-inc == 0` | **満たす**（1 → 0） |
| §11-2 (b) 系統 B の `R3-inc == 1` | **満たす** |
| §11-2 (c) 系統 B の `R4`（呼び出し site）`== 1` | **満たす** |
| §11-5 guard が 加算より 上 | **満たす**（guard < SeamReach < gate snapshot < 加算） |
| verify 2 本 の 10 欄 | **★baseline と 全欄 同一 = 非退行★** |

**★監視のみ（合否条件外・boss1 ■2）★** = `系統 A R1 = 5`／`系統 B R1 = 11`（**`ea600ab5` では 7 / 6**）。

**★まだ 言えないこと★** = **「counter が ★実際に 1 回だけ★ 進む」**。
**静的順序は ★順序の証拠であって 回数の証拠では ない★**（boss1 ■3 と同意）。
**`ParkTicks` が 増える間 `E12C` が 動かないこと**は **★戦闘が 実際に 走る step まで 保留★。**

---

## 7. ★step 2（`6506ea33`）の 静的照合 — ★Unity Editor は 起動していない★★（追記・#929-W2d）

**器の素性** = `HEAD=6506ea33` / **dirty=1（`compile_gate.sh` のみ）**。
**★step5 の 入力 10 file は 全て clean★**（1 件ずつ `git status --porcelain` で確認）⇒ **測ったのは `6506ea33` の内容**。
**★使ったのは `mcs` + `mono` だけ★**（`run_step5.sh`）。**Unity Editor は 起動していない**（実行前後 `ps` = 0 件）。

### 7-1. ★boss1 の 3 点を 私の器で 裏取り★

| # | boss1 の申告 | 私の測定 | 一致 |
|---|---|---|---|
| (1) index | `_actors[BattleIndex.Ally.Value]` に直り、型で 2 空間を分離 | **`IsAllyDown()` が `BattleIndex.Ally.Value`**／`BattleIndexSpaces.cs` に **`BattleIndex`（空間 A）と `ActorSlot`（空間 B）**、**★変換関数を 置いていない★** | **一致** |
| (2) 写像 | `Minus1` 代入 1 件 / `Zero` 代入 0 件 | **`Minus1`=1・`Zero`=0・`Win`=0**（母数 `unity/Assets/Scripts`） | **一致** |
| (3) Win 0 件 | 欠陥でなく **未到達** | **同意**（下記 3 欄で出す） | **一致** |

### 7-2. ★★boss1 ■2(3) の形 = 0 を 畳まない 3 欄★★（器 = `tools/w2_result_census.sh`）

```
rev=ea600ab5   Minus1 代入=0   Zero 代入=1   Win 代入=0
rev=011238c6   Minus1 代入=0   Zero 代入=1   Win 代入=0
rev=6506ea33   Minus1 代入=1   Zero 代入=0   Win 代入=0
```

**陽性対照** = 同じ器・同じ母数で `BattleResultCode` が **6 行** 出る ⇒ **★空振りの 0 では ない★。**

| 数 | **読み方（★同じ記号に 畳まない★）** |
|---|---|
| `Zero = 0` | **★良い 0★** = §11-7 のとおり **消した**（`0 = 逃走` を KO で返すと 意味が反転する） |
| `Win = 0` | **★まだの 0★** = **未配線・damage 着弾の step 待ち**（**欠陥ではない**） |
| `Minus1 = 1` | **★書かれているが game path から 未到達★**（下記 7-4） |

### 7-3. ★私が 足した 2 つの 検め★

**(a) `Zero` を 消しただけでは 閉じない — ★enum の 既定値★が `Zero = 0`。**
**⇒ `BattleResultCode Result` が ★非 nullable の field★ なら 代入 0 件でも ★既定で 逃走★ になる。**
**測定** = **`public BattleResultCode? Result { get; private set; }` = ★nullable★** ⇒ **既定は `null`。★穴は塞がっている★。**
**さらに** = **`??` / `GetValueOrDefault` で `null` を 0 に 畳む形は ★0 件★**（母数 `Battle` ＋ `Dialogue`）。
**結果適用の口** = **`HasApplicableResult` が真なら ★`NotImplementedException` で loud に 落ちる★**（**黙って適用しない**）。

**(b) ★`Minus1` の 1 は 「動いている 1」では ない★。**
**`new BattleRuntime` = ★`unity/Assets/Scripts` で 0 件★**（**陽性対照** = 同じ器・同じ母数で
**`new DialogueRuntime` が ★39 件（21 file）★** ⇒ 器は効いている。
**★`new BattleActor` は この母数では 0 件★** — **私が 当初 対照として 並べたのは 誤り**、§7-6 参照）。
**別母数 `workspace` = `BattleActor` 48 / `BattleRuntime` 12 / `BattleSession` 3。**
**⇒ ★戦闘の object graph が 丸ごと 未構築★**（**boss1 #929-W2e ■3 の一般形を採用** —
**`BattleRuntime` だけの話では ない**）。**駆動しているのは verify harness だけ。**

> **★型（3 つ目の 数の 読み方）★** = **`1` にも 2 種類ある** —
> **★実行されている 1★ と ★書かれているが 未到達の 1★。**
> **`Zero=0` / `Win=0` を 分けたのと 同じ理由で、`Minus1=1` も ★「直った」と 読ませない★。**
> **step2 が 直したのは ★写像の 定義★ であって ★写像が 通ること★ では ない。**

### 7-4. ★■3 = `expected_counts.txt` `5=81 → 84`（+3）の 中身★

**★追認では ありません★。実測して 中身を 引きました:**

- **`Check(` の 呼び出し数** = **`011238c6` = 81 → `6506ea33` = 84**（**expected と 一致**）。
- **内訳** = **★消えた 2 本★**（`R3 終了判定`＝`IsPartnerDown` 版／`R4' 終了で止まる`＝`Frame == 45` 版）
  **＋ ★足した 5 本★** ⇒ **net +3**。
- **★実測（`mcs`+`mono` で 実行）★** = **`PASS = 84` / `FAIL = 0` / `RESULT=GREEN`** ⇒ **expected と 一致。**

**足した 5 本（逐語の要点）**:

| test | 何を assert しているか |
|---|---|
| `R3 終了判定は 味方(空間A の 0)を見る` | **味方 HP100・敵 KO で `IsAllyDown()=False`** ⇒ **★旧 `_actors[1]` 実装なら True＝決着が反転していた★** |
| `R3b 味方 KO で終了` | 味方 KO・敵生存 → `True` |
| `R3c 未決は null・KO は −1` | **開始前 `null`／KO 後 `Minus1`** = **★`0=逃走` に 畳まない★** |
| `R4' 敵 KO では 止まらない` | **★陰性対照★** — 敵 KO 後も `Finished=False`（**旧実装なら ここで 止まっていた**） |
| `R4'' 味方 KO で 止まる` | `Finished=True` / `Result=Minus1` / frame 不変（終了判定は loop 先頭） |

> **★追認かどうかの 見分け方（私の判断根拠）★** = **足した test が ★step2 が変えた当のもの★ を assert し、
> かつ ★旧実装なら落ちる★ 形（`R3` と `R4'`）を 含んでいる**。
> **★expected を 実測に 合わせただけなら、旧実装で 落ちる test は 生まれない★。**
> **∴ `+3` は ★追認では なく 検め の 増加★ と 読める。**（**★但し これは 私の 読み★ — worker1 の 意図は 確認していない。**）

### 7-5. ★step 2 について 私が 言っていないこと★

- **`f_80057C00` の ★222 命令は 私も 読んでいない★**（worker1 自身が 範囲申告済 = **exit arm 1 本だけ**）。
  **⇒ ★原盤の 終了条件の 全部が これだ とは 言えない★。**
- **`ActorSlot.Ally = 1` / `Enemy = 2` は ★FOUNDATION §8.14 からの 引用★**（**worker1 も 実行時の中身は 見ていない**）。
  **私も 見ていない。**
- **verify 2 本（`SEAM66` / `CUT178`）の 4 値は ★step2 では 未採取★**（**Unity の GO 待ち**）。
- **`Win` 経路・damage 着弾・`HasApplicableResult` が 真になる path は ★まだ 存在しない★。**

---

## 8. ★step 2 の 実走（`a88ac2dd`）★ ＋ ★★§7-3(b) の 訂正（私の 陽性対照が 半分 空だった）★★

### 8-1. 3 段 そろった ledger（★生成物★）

```
label                                     SEAM66 txtId OFFg ONg reach SYNTH   pages chars   termPc       CUT178 tree            harness_sha   gate_sha
step0_BASELINE_ea600ab5(逐語引用・未実走)  GREEN  True  0    7   7     ABSENT  0/66  0/1601  0x1A/0x1315  FAIL   QUOTE           QUOTE         QUOTE
step1_011238c6                             GREEN  True  0    7   7     ABSENT  0/66  0/1601  0x1A/0x1315  FAIL   011238c6+clean  fed57f47bbb4  00ce90e1b741
step2_a88ac2dd                             GREEN  True  0    7   7     ABSENT  0/66  0/1601  0x1A/0x1315  FAIL   a88ac2dd+clean  fed57f47bbb4  99b5e5ff7766
```

**★10 欄すべて 同一★ ⇒ ★step1・step2 とも この RED から 非退行★。`error CS = 0`（両 log）。**
**終了後 `ps` で Editor 0 件・tree `a88ac2dd` / dirty 0 = ★汚していない★。**

**★出所欄が 初めて 仕事をした★** = `gate_sha` が **`00ce90e1b741` → `99b5e5ff7766`**。
**`a88ac2dd`（compile_gate に 陽性対照を 常設）の 変更が 欄に 出た** ⇒
**★「同じ数でも 出した器が 違う」ことが 後から 判る★**（**これが 出所欄の 目的**）。

### 8-2. ★★訂正 — §7-3(b) の 陽性対照は 半分が 空だった★★（boss1 #929-W2e ■3）

**私が 書いたもの** = 「陽性対照 = 同じ母数で **`new BattleActor` / `new DialogueRuntime` が 複数件**」。
**測り直し（母数 = `unity/Assets/Scripts`・語ごと）**:

| 語 | `unity/Assets/Scripts` | `workspace`（harness） |
|---|---:|---:|
| `new DialogueRuntime` | **39 件（21 file）** | — |
| **`new BattleActor`** | **★0 件★** | 48 |
| `new BattleRuntime` | 0 | 12 |
| `new BattleSession` | 0 | 3 |

**★∴ `new BattleActor` は 私が 探した母数では 0 件★。★対照として 並べたのは 誤り★。**
**結論（`new BattleRuntime` = 0）は ★`DialogueRuntime` 39 件 だけで 対照が 立つ★ ので 維持されるが、
★私が示した根拠は 半分 空だった★。§7-3(b) の 本文を 直した（★前置きの訂正では 本文が 古いまま 読まれる★）。**

### 8-3. ★★重なった 2 つの型（1 つは 今朝 私が 立てた型の 再発）★★

1. **★OR で 束ねた 陽性対照は 対照に なっていない★** — `A\|B` で数えて「A / B が 複数件」と書いた。
   **★OR は 片方だけで 満たされる★** ⇒ **★対照は 語ごとに 分けて 数える★。**
2. **★`head -5` で 打ち切った★** ⇒ **表示された 5 行が すべて `DialogueRuntime` 側 file だったことが 見えなくなった。**
   **[[feedback_absence_in_truncated_list]] の 再発**（**今朝 §3 で 自分で 立てた型**）。

> **★型を 1 段 強める★** = **今朝の「陽性対照は ★探した その母数の中で★ 立てる」を、
> ★母数だけでなく ★語★ にも 適用する★** ⇒
> **★★陽性対照は「その母数で・その語が」出ることを ★語ごとに★ 示す★★。**
> **★束ねた対照・打ち切った対照は 対照ではない★。**

### 8-4. ★boss1 の 一般形を 採る★

**私の (b) は `BattleRuntime` に限った書き方だった。**
**boss1 の測定** = **`new BattleSession` も `new BattleActor` も scripts 母数で 0 件**
⇒ **★戦闘の object graph が 丸ごと 未構築★**。**こちらが 正確なので 採用する。**
**∴ ★`Minus1 = 1` は 「書かれているが 未到達の 1」★** の根拠は **1 つの型ではなく object graph 全体**で立つ。
