# battle assembly — 統合設計 draft（2026-08-30・boss1）

**code 0 行。** 構成 = **(a)(b) = worker1 `ASSY_A_B_DESIGN_worker1_2026-08-30.md`（`cf4b23b`・359 行）**／
**(d) = worker3 `ASSY_D_DESIGN_worker3_2026-08-30.md`（`8fe1399`・339 行）**／**(c)(e) ＋ 統合 = 本 doc。**

> **★終着★ = ★user 実機で faithful な戦闘を見る = そこで初めて完成★。**
> **それまで完成とは書かない。headless 緑も codex LGTM も根拠にならない。**

---

## 0. ★boss1 の誤り 3 件（worker1 の差し戻し・★boss1 が再走して全件確認★）★

| # | boss1 が dispatch で書いたこと | 実測 | 直した所 |
|---|---|---|---|
| 1 | 「base_stats = `0x8013A924` stride 52」から stat を積む | **★`0x8013A924` は 名前表★** — row0..5 の `+0x00` が cp932 で **しゅじんこう / ボタモン / コロモン / アグモン / ベタモン / グレイモン**。**live の味方 stat（83/61/71/74）を持つ row は ★200 row 中 0 件★**。同表が持つのは **名前 ＋ 属性 3 本（`+0x1E..0x20`）＋ 技 id** | **本 doc §1** |
| 2 | live snapshot「7 run」 | **★5 run★**（`raw` は 7 本だが `DUMP` を持つのは 5 本） | `CLOSEOUT`（`7d27d7d`） |
| 3 | 「script を起こした actor の remake 対応物が **未定**」 | **★半分だけ正しい★** — **番地が同一の器は main に既に在る**（`GameState.cs:491 RawE12C, RawE104` ／ `DialogueRuntime.cs:709 if (_sceneWire) RawE104 = RawDF70`） | 本 doc §2 |

> **★型★** = **私は「持っている材料」を確かめずに dispatch に書いた**。**worker1 は自分の器で数え直して差し戻した**。
> **数が worker の観測と食い違ったら worker を優先** という規範が**実際に効いた 3 例目**。

---

## 1. (a) actor stat の配線 — ★表が 2 つある★（worker1 の設計を採用）

- **表 S = `0x8013A924` / stride 52 / image 内** = **名前・属性 3 本・技 id 16 slot**。**戦闘 stat は持たない。**
- **表 E = `0x801460C8` / stride 12 / ★image の外（BSS）★** = **8 つの stat 欄の源**。**静的に値が読めない。**
- **表 E は「積む」でなく ★育つ★** — worker1 の全数走査（母数 = main EXE 177,664 命令）で
  **lui+即値 offset の store = 0 件 / register 基底の store = ★6 件★**（`0x80116660` 他・形は `表E[i] += 0x80145F20[i]`）。
  > **★「①が 0 件」を『誰も書かない』と読むのは 私が登録した型そのもの★**（`[[feedback_closure_needs_three_edge_kinds]]`）。**②で 6 件出た。**
- **静的と live が独立に一致** = 味方の 8 欄が run 間で単調増加（80→83 / 60→61 / 70→71 / 70→74 / 800→802 / 600→603）／**敵は 5/5 で完全同一**。

### 設計の結論（採用）

1. **表 E は静的 asset にできない**（image に無い）⇒ **save / 育成 state として持つ**
2. **味方と敵は畳まない**（§8.15 = HP/MP の宛先が違う）
3. **育つ側は本 phase で配線しない**（加算元 `0x80145F20` も image の外 = 源が未同定）
4. **敵の `+0x48/+0x4A` は決め打たない** = **未設定 ＋ loud**（G1 = 書く site が census に無いのに live では 5/5 で 300/600）

### ★★最小 slice で 走らせる stat の源（PRESIDENT #927-D (1) の確認・boss1 が明示する）★★

**表 E は BSS ＝ image に無く、育つ側も本 phase で配線しない。** ⇒ **走らせる 2 体の stat をどこから得るかを ここで決める。**

> **★決め★ = ★live snapshot（actor record snapshot を持つ 5 run）の実値を ★固定の test stat★ として使う★。**
> **★`field → battle` の stat population は ★本 phase では defer★★**（= **戦闘の入口で 実 state から積まない**）。

- **使う実値**（`battle3/raw_*.log` の `DUMP_B084` / `DUMP_B104` を boss1 が decode 済）:
  **味方** `+0x38..0x3E` = `83 / 61 / 71 / 74`・`+0x48..0x4E` = `802 / 603 / 417 / 30`（`195331` の run）
  **敵** `110 / 100 / 100 / 100`・`300 / 600 / 300 / 600`（**5/5 run で完全同一**）
- **なぜ固定値でよいか** = **本 phase の目的は「走って画面に出る」こと**であって **stat の由来を確かめることではない**。
  **damage 式は live 確定**なので、**この stat を入れれば 出る数値も live と突き合わせられる**。
- **★偽らないための札★** = **この 2 体は ★実 save から積んだものではない★**。
  **画面に出た数値が正しくても「stat の配線が正しい」ことにはならない。** **札 = 材料（表 E の中身が未同定）。**
- **defer した先** = **表 E を save/育成 state として持つ設計**（§1 の結論 1）＋ **育つ側（`0x80145F20`）の源の同定**。

### ★remake の受け皿は 依頼が想定するより進んでいる★

`ApplyEntryStats` / `ApplyEntryStatsAlly` / `ISpeciesRecordTable` / `BattleWazaResolver` / `AttributeMatrix` は **既に在る**。
**無いのは表 E の中身そのもの。** ⇒ **重複実装しない。**

---

## 2. (b) field → battle の繋ぎ（worker1 の設計を採用）

- **入口** = `#921-C ■1` の形のまま、`if (GateEnabled)` の中に **4 段**（counter +1 → slot 番号 → 戦闘 → 3 値適用）。
- **★設計判断（採用）★** = **`BattleEntry` は env gate を見ない**。**`GateEnabled` 判定は呼び手に留め、slot は引数で受け取る。**
  **理由** = **(A) で採った一般則と同型** = **battle の起動が別 feature の env に従属するのを構造で防ぐ**。
- **「script を起こした actor」** = **★決められない・候補 3 個★**（`RawE104` / `RawCurSlot` / 新しい口）。
  **推奨 = 候補 1 を値の出所にするが `_sceneWire` に従属させない・`RawE104` が 0（未 populate）なら止めずに loud log。**
  **★0 を「slot 0」として黙って通さない★**（`[[feedback_retreat_must_not_encode_as_pass]]`）。**同値かは実機札。**
- **戻り** = `NormalizeResult` / `ApplyResult` は **既に在る**。**`-1` と `0` の別は未決ゆえ care 増減は配線しない**
  （配線時は必ず `ClampCare`・`0x80141D42` は `−100..+100`）。
- **勝敗 flag** = **remake は持つ（`IBattleStats.NotWon`）。但し読み手が remake に無いので「書くだけ」で置き loud に記録。**
- **field state** = **原盤に「入る前の位置を退避して戻す」機構は無い（§7 確定）⇒ remake も退避しない。**

### ★★最初に衝突するもの = 戦闘回数 counter が 2 つ★★（worker1 の発見・**本 phase の最優先**）

| | main | branch |
|---|---|---|
| 変数 | `GameState.RawE12C` ＋ `SceneDriverCounterInc()` | `IBattleStats.Battles` ＋ `BattleEntry.AdvanceBattleCounter()` |
| 番地 / 飽和 | `0x8013E12C` / `0x270f` | 同 `0x8013E12C` / `9999` |
| 出所 | EXE `0x800EE740` | **同じ `0x800EE740` の `slti`** |

**⇒ 同一の 1 命令を 2 つの変数が別々にモデルしている ⇒ 両 gate ON で原盤 1 回の counter が remake では 2 箇所進む。**

> **★決め（採用）★ = `RawE12C` を単一権威にし、`AdvanceBattleCounter` は残すが実装側が `RawE12C` へ委譲する。**
> **★器で 2 重加算を不可能にする★**（**呼び手の規律に頼らない**）。

**★付記（未検証・畳まない）★** = main には別に `GameState.Wins, Battles`（save `0x1D8`/`0x1DA`）が在り、
FOUNDATION は `gp-0x6ce0` が `save+0x266` に載ると書く。**別 offset なので同じものと決めない（札 = 材料）。**

---

## 3. (d) real-time ループと描画（worker3 の設計を採用）

- **(d-1)** 戦闘 1 frame は **`DialogueRuntime.Tick()` の中**（= `0x66` case が持つ driver）。
  **新 MonoBehaviour は 描画/入力の `BattleView` 1 本だけ・logic 側は増やさない。**
  **前例** = **`0x67` の frame-yield（`DialogueRuntime.cs:1391` = 第 3 の exit）** ⇒ **新概念ゼロ。**
  **副次** = `BattleRuntime` は UnityEngine 非依存 ⇒ **Editor harness が `rt.Tick()` を回すだけで 1 戦完走できる（画面なしで 3 値が取れる）**。
  **step は Unity frame でなく固定 step accumulator**（`FieldManager.cs:283 TickClock` と同型）。**1 frame の実時間は未検証 = 札。**
- **(d-2)** **戦闘中 VM は止まるが `Finished` にはしない** = `State=Running` のまま `_pc` を `0x66` に据え置いて `return`、
  終わった tick で epilogue → **現行と同じ `EmitPage`/`Finished`（idle_stop）に合流**。
  **park は VM の内側に持つしかない**（`TextboxView.cs:257` が `GameFlow` と無関係に毎 frame `_rt.Tick()` を呼ぶため）。
  **★失敗形 4 つを名指し★**（再入 guard の位置で `E12C` が毎 frame 進み数十 frame で飽和／`Finished` にすると
  `FieldState:587` で `InputLocked=false` = **戦闘中に player が歩く**／`_pc` 前進／`WaitingFrames` 流用）。
- **(d-3)** 最小の描画 **P0 4 件** = ①画面占有 ②2 体と水平距離（`dx²+dz²`・Y 未使用）
  ③**HP を 2 値で**（表示 = `Hp4C` は drain で段階減／判定 = `Hp4C − DamageAccum2E` は即時 ⇒ **KO は当たった瞬間に決まりバーが後から追いつく**）
  ④**damage 数値（live 確定している唯一の量）**。P1 = 指示表示 / 決着（**3 値のまま・名前を当てない**）。P2 = 演出・BGM・見た目。
  **★忠実の線★** = **(α) 数と時間は忠実に作る／(β) 画面の構図は忠実を主張しない**
  （**原盤の battle 画面を誰も 1 枚も見ていない**・探索の枠つき）。
- **(d-4)** 入力 = **←/→ の 2 キーだけ・移動なし（user 実測）**。
  **どの命令 slot を選ぶかは ◆前提つき◆** ⇒ **index を 0..2 で回して表示するだけ**にし、戦闘に効かせるのは (a)/(b) と繋がってから。
  **逃走の入力は作らない**（`-1` と `0` の別が未決 = **作ると未決を実装で埋めることになる**）。
- **(d-5)** 終了 = 3 値を **VM の epilogue が受けて `BattleEntry` の既存 API へ**。
  **`result 1` だけ map 再読込 ＋ 勝利数 +1 ／ `0`・`-1` は再読込しない** ⇒ **戦闘の入口/出口で `TeardownField` を呼ばない**。

---

## 4. ★(c) 技の効果 = stub（boss1 の裁定）★

- **前提（確定）** = **効果器は演出だけ**（FOUNDATION）。**⇒ mini-VM は要らない。**
- **★裁定★ = 本 phase では ★技の効果を 1 つも実装しない★。**
  **`0x66` の seam から起動する戦闘は「damage が出て HP が減り 3 値で終わる」までを回す。**
- **理由** = **damage 式は live 確定・効果は未 live**。**混ぜると「どこまでが確かめた形か」が言えなくなる。**
- **stub の置き方** = **差替可 ＋ 札**。**`BattleWazaResolver` に「効果 = 未実装」を loud に出す口を 1 つ置く**
  （**黙って no-op にしない** = `[[feedback_retreat_must_not_encode_as_pass]]`）。
- **札** = **材料**（効果器の中身は読んでいない）。**mini-VM か hand-expand かの裁定（#907-A）は ★本 phase では不要になった★**
  — **効果を実装しないので、その選択が発生しない。****次 phase に送る。**

## 5. ★(e) gate（boss1 の裁定）★

- **`DEGIMON_BATTLE_SLICE` は ★既定 OFF 維持★。テスト時のみ ON。**
- **`DEGIMON_SCENE_DRIVER` との関係** = **`0x66` case の中で seam は両 gate より上・戦闘本体は `if (GateEnabled)` の中**
  （`#921-C ■5` の印）。**⇒ 戦闘は `DEGIMON_SCENE_DRIVER` に従属しない。**
- **worker1 の設計を採用** = **`BattleEntry` は env を見ない**（判定は呼び手・slot は引数）。
  **⇒ gate の読み口は `DialogueRuntime` の 1 箇所だけ。**
- **OFF の時に何が不変か（★次元を名指しする★）** = **VM の観測可能 state と text 出力**。
  **`SeamHitLog` は process state として伸びる**（既知・`#921-A2 ■2(a)` の是正案は **実装時に入れる**）。

---

## 6. ★実装に入る前に 決まっていなければならないもの（順序つき）★

| # | 項目 | 状態 | 誰が |
|---|---|---|---|
| **1** | **戦闘回数 counter の 2 重モデル** | **決め済（`RawE12C` 単一権威・器で 2 重加算を不可能に）** — **実装の 1 番目** | 実装者 |
| **2** | **`BattleRuntime.cs:89` と `:181` の index ずれ**（終了判定 = `actor[1]` か index 0 か） | **★未決★** — **決着表示に直結**。worker3 が指摘、**btl_rel の loop 先頭を誰も読んでいない** | **worker1（(a)/(b) の一部として）** |
| **3** | 「script を起こした actor」= 候補 3 個 | **決められない**（推奨 1 つ ＋ loud log で進める） | 実装時に推奨で進め、**同値かは実機札** |
| **4** | 表 E（`0x801460C8`）の中身 | **image の外 ⇒ 静的に読めない** | **save/育成 state として持つ・育つ側は配線しない** |
| **5** | 敵の `+0x48/+0x4A` | **書く site が census に無い（G1）** | **未設定 ＋ loud** |
| **6** | `-1` と `0` の別 | **未決（実機札）** | **care 増減も逃走入力も作らない** |

## 7. ★札の総数（推測で埋めていない）★

**worker1 = 未決 12（材料 9 / 実機 3 / 原理 0）・★札の無い ④ は 0 件★**
**worker3 = 8（D-1..D-8）**
**boss1（本 doc） = (c) の 1（材料）**
⇒ **合計 21。** **すべて札つき。**

## 8. 不変

**push HOLD** ／ **gate 既定 OFF** ／ **完成 claim 凍結（user 実視覚まで）** ／ **実機に接続しない** ／
**main 未変更** ／ **凍結 8 値 不動** ／ **RE 忠実 = 推定で埋めない・stub は差替可 ＋ 札**。
