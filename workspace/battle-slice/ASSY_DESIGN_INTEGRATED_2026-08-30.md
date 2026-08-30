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
  **前例** = **`0x67` の frame-yield（`DialogueRuntime` の `0x67` case = 第 3 の exit・**行番号は書かない／`grep -n OP_FRAME_YIELD` で引く**）** ⇒ **新概念ゼロ。**
  **副次** = `BattleRuntime` は UnityEngine 非依存 ⇒ **Editor harness が `rt.Tick()` を回すだけで 1 戦完走できる（画面なしで 3 値が取れる）**。
  **step は Unity frame でなく固定 step accumulator**（`FieldManager.cs:283 TickClock` と同型）。**1 frame の実時間は未検証 = 札。**
- **(d-2)** **戦闘中 VM は止まるが `Finished` にはしない** = `State=Running` のまま `_pc` を `0x66` に据え置いて `return`、
  終わった tick で epilogue → **現行と同じ `EmitPage`/`Finished`（idle_stop）に合流**。
  **park は VM の内側に持つしかない**（`TextboxView.Update()` が `GameFlow` と無関係に毎 frame `_rt.Tick()` を呼ぶため）。
  **★失敗形 4 つを名指し★**（再入 guard の位置で `E12C` が毎 frame 進み数十 frame で飽和／`Finished` にすると
  `FieldState` の `OnFinished` 経路で `InputLocked=false` = **戦闘中に player が歩く**／`_pc` 前進／`WaitingFrames` 流用）。
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
| **2** | **`BattleRuntime.cs:89` と `:181` の index ずれ** | **★2026-08-30 解決（worker1 追補 A・`1412e0b`）★** — **下記** | **実装時に直す（4 点）** |
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

## 9. ★§6 #2 の決着 — index ずれは ★実装の bug★ だった（worker1 追補 A・2026-08-30）★

### 読む前に base VA を assert（§8.11「sidecar を信用しない」の実行）

`btl_rel.txt` の **`Load Address: 0x80010000` は誤り**。**prologue 着地率**（母数 = `jal` 1,174 件）:
**`0x80052AE0` = 372/380 = ★97.9%★** ／ 陰性対照 `0x80010000` **0.0%** ・`0x80053800` **0.3%** ・`0x80070000` **1.4%** ・**±4/±16 = 0.0%**
⇒ **base = `0x80052AE0` で確定。**

### 回答 = 終了判定が見ているのは ★battle 側の index 0（＝味方）★

- **逐語**（`f_80057C00` の exit arm）= `0x80057C38 lh v1,46(B)`（**添字なし ＝ `S = B + 360*i` の `i = 0`**）／
  `0x80057C40 lh v0,0x8016B0D0`（**味方 record `0x8016B084` + `0x4C`**）／`sub` → `blez` で継続 ／ `v0=1` で **loop 脱出**
- **不在の census（母数つき）** = `f_80057C00` **全 222 命令**の **`lui` 基底の絶対番地参照 全件**で
  **敵 record `0x8016B104..` への参照は ★0 件★**（味方 `+0x4C` が 2 件・`+0x53` が 1 件）
- **★worker1 が自分で潰した早合点★** = 同関数内に `360*i` の idiom が **5 件**あるが、
  **全て `s0` を 0 から回す後始末 loop** で **HP 判定はその中に無い**。**「index 0 だけを見る」と書きかけて 5 件で止めた。**

### ★ずれの正体 = index 空間が 2 つ在る★

| 空間 | 形 | 味方 |
|---|---|---|
| **A** | `B + 360*i` の `i`（`ApplyEntryStats` の index と同じ） | **0** |
| **B** | `actorTable 0x8013CDB4[slot]`（`slot = *(u8*)(B + i + 0x66C)` で A から写像） | **1** |

⇒ **`:89` の「partner（`actor[1]`）」も `:181` の「index 0 = 味方」も ★どちらも味方を指しており 註としては誤りではない★。**

> **★但し 実装は 1 つずれている★** — **boss1 も直読で確認**:
> `BattleRuntime.cs:36` `readonly List<BattleActor> _actors` ／ `:63` `_actors.Add(a)`（**登録順 ＝ 空間 A**）／
> `:100` `return _actors[1].IsDown();` ／ **`:34` `IndexEveryFrame = 0`**
> ⇒ **空間 A で味方 = 0 なのに `IsPartnerDown()` は `_actors[1]` を読む ＝ ★敵を読む★** ⇒ **★決着表示が反転し得る★**。
> **worker3 の指摘は 実装の bug を当てていた。**

### 直し方（★実装 GO 後★・4 点）

1. **`IsPartnerDown()` は `_actors[0]` を読む**（`_actors[1]` は空間違い）
2. **より忠実にするなら index を介さず「味方 record の `+0x4C`」を見る**（原盤は 2 箇所とも literal で味方に届いている）
3. **★名前も直す★** — 原盤の arm 1 は「倒れたら出る」ではなく **生きていれば出る（`> 0` で return 1）**。
   **`IsPartnerDown` のままだと極性まで誤読される。**
4. **空間 A の index と 空間 B の slot を 同じ `int` で渡さない（型で分ける）** — **註でなく器で防ぐ**（counter 2 重モデルと同じ形）

### ★副産物 — §7 の未決「`-1` と `0` のどちらが敗北か」が閉じた★

loop 直後 18 命令の逐語 = `0x8005CB28 lh v0,0x8016B0D0`（味方 `+0x4C`）→ **`== 0` なら `v0 = −1`** ／
**`!= 0` かつ `b64e == 1` → `0`** ／ **`!= 0` かつ `b64e != 1` → `1`**
⇒ **★`-1` = 敗北（味方の `+0x4C` が 0）／`0` = 逃走 ／`1` = 勝利★**

**★独立の整合★** = field 側の罰は `-1` が `−30/−20`・`0` が `−10/−6`【引用 §7】= **重い方が敗北** で **逐語と一致**。

> **★格（worker1 の申告をそのまま）★** = **「`+0x4C == 0` ＝ 敗北」は 1 段の推論**（「HP 0 = 負け」は逐語に無い）。
> **★2 系統が一致した★ までは書ける。** **`b64e == 1` が「逃走」は引用であって逐語ではない。**
> **`actorTable[1] = 味方` は §8.14 の引用**（静的値は 8 entry とも 0 = 実行時 populate【worker1 実測】）。

**⇒ §6 の #6（`-1` と `0` の別）も ★これで閉じる★。**
**但し ★care 増減の配線と逃走入力は 本 phase では作らない★**（**閉じたのは「どちらが敗北か」であって、罰の配線の是非ではない**）。

### していないこと（worker1 の範囲申告・そのまま）

**`f_80057C00` の 222 命令を全部は読んでいない**（読んだのは exit arm 1 の逐語・絶対番地参照の全数 census・`360*i` 5 件の用途）
⇒ **「exit する条件を全部列挙した」とは書かない**（**arm 1 以外の return 経路は未読 = 札 = 材料**）。
**overlay は `btl_rel` 1 本のみ**（他 15 は未走査）。**compile も実行も live 採取もしていない。**

## 10. ★codex 設計査読の findings — ★boss1 が全件 裏取りしてから 載せた★（2026-08-30）★

**発注** = 問い 5 点／**source は貼らず** `src/`（統合 branch から抽出した 7 file）を読ませた。
**★findings は鵜呑みにしない★** — **下は boss1 が自分で該当行を読んで確認したものだけ**。

### codex の判定（要約）

| 問い | codex |
|---|---|
| (i) counter 単一権威 | **要修正**（方向は妥当・**委譲だけでは足りない**） |
| (ii) 配置と State/PC 方針 | **妥当。ただし条件付き** |
| (ii) 失敗形 4 つは尽きるか | **★要修正。尽きていない★** |
| (iii) 最小 slice の scope | **妥当** ／ 忠実の線引き = **要修正** |
| (iv) stub と index gate | **妥当。ただし責務分離が必要** ／ gate 化は **妥当・必須** |
| (v) 統合 risk | **要修正**（7 件） |

### ★boss1 が裏取りして CONFIRMED になったもの★

| # | finding | boss1 の確認 |
|---|---|---|
| **A** | **`AdvanceBattleCounter` を `RawE12C` に委譲するだけでは、battle 側と既存 B2 の ★2 回加算★ が残る** | **CONFIRMED** — `0x66` は battle gate 処理の後も scene-driver B2 に進む。**⇒ 委譲では足りない** |
| **B** | **`BattleEntry.RunToCompletion` / `RunOnce` は ★同期完走 API★** — per-frame 設計と不整合 | **CONFIRMED** — `BattleEntry.cs:193` `RunToCompletion(rt, maxFrames = 60*60*10)` ／ `:210` `RunOnce` が内部で呼ぶ |
| **C** | **battle 本体が ★現状 終了不能★・`Result` が ★常に `Zero`★** | **CONFIRMED** — `BattleRuntime.cs:110-117` = 終了条件は `IsPartnerDown()` のみ・`Result = BattleResultCode.Zero` 固定（STUB）。**★§9 で `0` = 逃走 と確定したので、KO でも「逃走」を返すことになる★** |
| **D** | **`Tick()` は state 判定より前に `PumpWarpPending()` を実行** ⇒ **park 中も pending warp が進む** | **CONFIRMED** — `Tick()` 冒頭に在る（原盤 `0x800F02B8` が VM 呼び出しの冒頭で見る形の移植） |
| **E** | **`GateEnabled` は ★毎回 env を読む property★** ⇒ 途中 OFF で park が解ける | **CONFIRMED** — `BattleEntry.cs:54-59` getter が毎回 `GetEnvironmentVariable`。**⇒ session 開始時に snapshot する** |
| **F** | **stall 診断の誤検知** — park 中は `(State, Pc, pages)` 不変 ⇒ **90 frame で必ず stall log** | **CONFIRMED** — `TextboxView.cs:266` が 3 つ組で判定 |
| **G** | **`0x67` は ★return 前に `_pc` を前進させる★** | **CONFIRMED** — `DialogueRuntime.cs:1839` `_pc += len;`（明示 comment つき）。**⇒ 「`0x67` が前例」は ★State の扱いは同じ・`_pc` の扱いは逆★ と書き分ける** |
| **H** | **slot 0 の fail-open**（`RawE104` は未 populate でも `0`） | **CONFIRMED** — `GameState.cs:491` は素の `int`。**★設計は既に「0 を黙って通さない」と書いている★が、器で強制する必要が在る** |

### ★boss1 の判定が codex と割れたもの★

| # | codex | boss1 |
|---|---|---|
| **I** | **入力の所有権** — `TextboxView.Update()` は battle 中も dialogue advance / menu 入力判定を通る | **★部分的★** — 該当経路は **State で gate されている**（`:232` は `WaitingAdvance` 必須・menu は `WaitingChoice`）。**park は `Running` を保つので advance/menu は ★inert★**。**★但し codex の懸念自体は残る★** = **←/→ を battle 中に誰が読むか**（`BattleView` の所有）は**設計に書いていない** ⇒ **明記する** |

### ★設計に反映すること（実装の前）★

1. **counter の mutation を `0x66` 初回進入の 1 箇所だけにする**（**委譲ではなく ★口を 1 つにする★**）
   ＋ **`BattleEntry` から `Battles` / `AdvanceBattleCounter` を外す** ＋ **`RunOnce` は real-time では使わない**
2. **★battle session lifecycle を導入する★** = `BeginBattle()` は `_battle == null` の時だけ session を作り、**その時だけ加算**
   ＋ **`GateEnabled` を session 開始時に snapshot** ＋ **例外 / disable / state exit 時の teardown を原子的に**
3. **park の invariant を 2 つ足す** = **戦闘開始時に warp pending 不在** ／ **battle 完了 tick が既存 B2〜B6 を通るのか epilogue が置換するのかを明示**
4. **stall 診断に battle-active の除外を入れる**（**でなければ 90 frame ごとに 偽の stall log**）
5. **`0x67` を前例として引くときは ★`_pc` の扱いが逆★ と書く**
6. **←/→ の所有を `BattleView` に置くと明記**
7. **`Result` を `Zero` 固定のままにしない**（**§9 で `0` = 逃走 と確定したので、KO で `Zero` を返すと ★意味が反転する★**）

> **★arch レベルの 1 件★ = **`BattleEntry` の既存同期 API（`RunToCompletion` / `RunOnce`）は per-frame 設計と両立しない**。
> **設計の方向（loop を `Tick()` 内に置く）は codex も妥当としたが、★既存 API を使わない・session lifecycle を足す★ ことになる。**
> **⇒ PRESIDENT に上げてから実装に入る。**

### codex が指摘した doc の腐り

**設計 doc の参照行が既にずれている**（`0x67` は `DialogueRuntime.cs:1835` 付近・`InputLocked=false` は `FieldState.cs:599`）
⇒ **`[[feedback_number_without_frame]]` の行番号版**。**行番号は書かず、関数名で引く**（`agent-send.sh` header で採った remedy と同じ）。

## 11. ★★決定した設計（実装はこれに従う）— PRESIDENT #928-B 承認★★

**§10 の 7 点 ＋ arch（battle session lifecycle）を 反映した ★確定版★。実装はここを読む。**

> **★行番号は書かない★** — 参照は **関数名 / 定数名**で行い、位置が要る時は **その場で `grep -n` する**。
> （codex が **本 doc の参照行が既にずれている**ことを指摘。`[[feedback_cite_which_worktree]]` ＋ `agent-send.sh` header と同じ remedy。）

### 11-1. ★battle session lifecycle（arch・承認済）★

- **`BattleEntry` の既存同期 API（`RunToCompletion` / `RunOnce`）は ★使わない★**（per-frame 設計と両立しない）。
- **`BeginBattle()` は `_battle == null` の時だけ session を作る。**
  **★session 生成の その時だけ★ counter を加算する（atomic）。**
- **`GateEnabled` は ★session 開始時に snapshot★**（**property は毎回 env を読むので、途中 OFF で park が解ける**）。
- **teardown を原子的に** — **例外 / disable / state exit のいずれでも
  「`BattleView` 破棄 ＋ session 破棄 ＋ lock 復帰 ＋ 結果適用の有無」を ★1 つの単位★ で扱う。**
  （`FieldState.Exit()` は **無条件に lock を解除する**ため、**片方だけ起きる形を作らない**。）

### 11-2. ★counter は 口を 1 つに（委譲ではない）★

- **mutation は `DialogueRuntime` の `0x66` ★初回進入の 1 箇所★ だけ。**
- **`BattleEntry` から `Battles` / `AdvanceBattleCounter` を ★外す★**（**戦闘開始後は counter に一切触れさせない**）。
- **★委譲では足りない★理由** = **`0x66` は battle gate 処理の後も scene-driver B2 に進む**ので、
  **battle 側と B2 の 2 回加算が残る**（codex A・boss1 確認済）。
- **`IBattleStats.Battles` の実装先は未定** — **`PartnerState.Battles`（save `+0x1DA`）は ★別 counter★。畳まない（札 = 材料）。**

### 11-3. ★park の invariant 2 つ★

1. **戦闘開始時に ★warp pending 不在★ を invariant にする**
   （`Tick()` は **state 判定より前に `PumpWarpPending()` を実行する**ので、**park 中も pending warp が進み map change を emit し得る**）。
   **不在でなければ ★loud に落とす★**（**黙って進めない**）。
2. **★battle 完了 tick が 既存 B2〜B6 を通るのか、battle epilogue が置換するのかを 明示する★。**
   **本設計 = ★epilogue が置換する★**（**通さない**）。**理由 = 通すと counter と scene 処理が二重に走る。**

### 11-4. ★stall 診断に battle-active 除外★

**park 中は `(State, Pc, EmittedPages.Count)` が不変** ⇒ **既存の stall 診断が 90 frame ごとに必ず出る。**
⇒ **battle-active の間は stall 判定を抑止する**（**抑止したことが log で判る形にする** — **黙って消さない**）。

### 11-5. ★`0x67` を前例として引くときの書き分け★

**`0x67` frame-yield は ★`State=Running` を保つ点は同じ★／★`return` 前に `_pc` を前進させる点は 逆★。**
**battle park は `_pc` を `0x66` に据え置く** ⇒ **毎 tick 同じ case に再入する** ⇒ **★再入 guard の位置が効く★**
（**guard を counter 加算より後に置くと counter が毎 frame 進む** = worker3 の失敗形 1）。

### 11-6. ★入力の所有★

- **`TextboxView` の advance / menu 入力は ★State で gate されている★**（`WaitingAdvance` / `WaitingChoice`）
  ⇒ **park は `Running` を保つので ★inert★**（**boss1 が確認・codex とはここで判定が割れた**）。
- **★但し ←/→ は `BattleView` が所有すると 明記する★**（**設計に無かった穴**）。
  **戦闘中に `←/→` を読むのは `BattleView` だけ。** **`TextboxView` は読まない。**

### 11-7. ★`Result` を `Zero` 固定にしない★

**現状 `BattleRuntime.Tick()` は終了時に `Result = BattleResultCode.Zero` を固定で入れる。**
**§9 で ★`0` = 逃走★ と確定したので、★KO でも「逃走」を返す＝意味が反転する★。**
⇒ **最小 slice でも ★KO は `-1` / `1` のどちらかに写す★**（**どちらかは §9 の写像に従う = 味方 `+0x4C == 0` なら `-1`**）。
**★逃走 `0` は 入力を作らないので 本 phase では発生しない★** ⇒ **`0` を返す経路が在ったら それは bug。**

### 11-8. ★終了条件を有限にする★

**行動と damage が stub のままだと ★誰の HP も減らず 戦闘が終わらない★**（codex C・boss1 確認済）。
⇒ **最小 slice では ★damage が必ず入る経路を 1 本 通す★**（**live 確定した式で 敵 → 味方 の 1 発**）。
**★「終わらない」を silent に作らない★** — **上限 frame に達したら loud に落とす。**

---

## 12. ★実装 phase で 設計を 動かした もの（boss1 が doc 側に 書き戻す・2026-08-30 夜）★

**この節が要る理由** = **doc の外に出た claim は doc の中を直しても閉じない**。
逆も真で、**実装で決め直したことを doc に書き戻さないと、次に読む人は撤回前の doc を読む**。

### 12-1. ★★撤回 = 「BATTLE_SLICE=1 でも SCENE_DRIVER の bit は不変」は もう 成り立たない★★

- **撤回の対象** = `#921-A1` の「**`break` しない**」= 当時の seam は **log だけ**だったので、
  通り抜けても B1–B6 の bit は動かなかった。§5 の「OFF の時に何が不変か」も、その前提で読まれ得た。
- **今** = **park する**ので、**battle epilogue が B2–B6 を置換する（通さない）**（§11-3(2)）。
  **⇒ `DEGIMON_BATTLE_SLICE=1` のとき、SCENE_DRIVER の bit は BATTLE_SLICE に依らず不変 ではない。**
  **これは事故ではなく、設計としてそう決めた。**
- **`DEGIMON_BATTLE_SLICE=0` のときは 従来どおり不変**（`BattleSeamVerify66` の OFF 側が それを毎回 測っている）。
- 出所 = worker1 の step1 報告（自己申告）。**code の comment 側にも同文が入っている**（doc と code の 2 箇所）。

### 12-2. ★検査の器が 別の tree を見ていた（4 日間）★

- `workspace/battle-slice-verify/compile_gate.sh` は `ea600ab5` の **7 行目**で
  `P=/home/ken/Desktop/Digimon/degimon_world_remake-p2w1/unity` を **hardcode**（override 引数なし）。
  **p2w1 は凍結・clean** ⇒ **assy で何を壊しても `GATE=GREEN` が出る**。
- 窓 = `e061d978`（08-26 03:28）→ `011238c6`（08-30 22:34）。**発見・修正とも worker1 の自己申告**。
- **範囲（boss1 が全数で確認）** — **`222 standalone` は影響を受けない**:
  `run_all.sh` / `run_step{2,3,4,5,6a,6b,7}.sh` / `run_live_compare.sh` は全部
  `R=$(cd "$(dirname "$0")/../.." && pwd)` で **script 自身の場所から repo を出す**。固定 path は 1 つも無い。
  **repo 内で `compile_gate.sh` を呼ぶ script は 0 件**（`f1b_accept.sh:48` / `f1b_diff_selftest.sh:40` の
  `_compile_gate ()` は **同名の別物** = file 内 shell 関数。**名前の一致は同一物の証拠ではない**）。
  ⇒ **露出は「人が手で叩いた run」だけ**。
- **陽性対照の常設**（PRESIDENT 指示）= **既知 bad 状態 → `GATE=RED` を確認する口を script 自身に持たせる**。
  叩き台 = `--selftest`（対象 tree に一時 CS error を置き、RED が出なければ script 自身が非 0 で落ちる）＋ **gate 自身の sha を印字**。
  **これが無かったから「正しい tree を見ているか」を 1 度も検定していなかった。**

### 12-3. ★land 記録（実装 base = `integration/p2-battle-v2` = `ea600ab5`）★

| step | commit | 内容 | SEAM66 | CUT178 |
|---|---|---|---|---|
| 実装前 | `ea600ab5` | base | GREEN(True/0/7/7) | RED(0/66・0/1601・0x1A/0x1315) |
| step1 | `011238c6` | counter 単一権威 ＋ session lifecycle | 同左（逐語一致） | 同左（3 値同値） |
| step2 | `6506ea33` | index ずれ修正 ＋ `Result` を §9 の写像に ＋ index 空間を型で分離 | 同左 | 同左 |

- **`CutsceneVerify178` の RED は本 phase の目標ではない**。**baseline として使う**（3 値が動いたら battle 起因）。
- **`expected_counts` `5=81 → 84`** の +3 は **旧実装なら落ちる差分 test**（R3 / R3b / R3c / R4' / R4''）。
  **実測に合わせた追認ではない。** `R3c` は **null / −1 / 0 の 3 値**で「未決」を「0」に畳んでいない。

### 12-4. ★まだ言えないこと（実装が進んでも 据え置き）★

- **「counter が実際に 1 回だけ進む」は未証明** — **静的な順序は順序の証拠であって回数の証拠ではない**。
  **戦闘が実際に走る step まで保留。**
- **`Win` を立てる経路は 0 件** — **欠陥ではなく未到達**（damage 着弾 step 待ち）。
  **`Zero` の 0 件（良い 0）と同じ記号に畳まない。**
- **画面には何も出ていない。完成 claim はゼロ。** 最終 verify は **user 実視覚**（我々 3 人とも GUI 視覚 verify は不可）。
