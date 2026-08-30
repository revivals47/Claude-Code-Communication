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
