# battle slice RE foundation（格是正版）— 2026-08-26

RE 先行段（**code 0 行 / push HOLD / read-only 静的 RE**）の集約。boss1 が 3 track の doc から
**確定・範囲つきの不在・札つきの未決**だけを引いた。★codex 査読（2026-08-26）の是正を反映済★。

- 出典 = worker1 `p2w1 / track1-battle-re-0x50`（`caf1aa4a`）／worker2 `p2w2 / track2-battle-re-damage`（`3f8466f0`）／
  worker3 `p2w3 / track3-battle-re-ai`（`15fa422d`）。**push は 1 件もしていない**。
- 素材 = `vise/extracted/slps_017_97.bin`（text raw・**VA = 0x80090800 + file offset**）／`vise/extracted/btl_rel.bin`（sha `fafd9bd2…`）。
- ★**boss1 裏取り済**★ の印がある行は、boss1 が自分の器で独立に再測した。

## 0. ★読む人への注意（本フェーズで 4 回踏んだ型）★
1. **数は枠を確かめてから使う** — `95`（先行 md の表の行数）/`124`（blob の行数 = 関数 96 + 変数 28）/`346`（`battle_functions.json` の関数入口 VA 数）は**別の物を数えた数**。比較不能。
2. **sidecar を権威にしない** — `extracted/*_rel.txt` の `Load Address: 0x80010000` は **RAW format の既定値**であって計測値ではない（btl/std/vs/mov が同値）。
3. **overlay は同一 VA 帯に排他的に載る** — ∴「他 overlay から btl 帯への jal」は btl を呼んだ証拠にならない（自分自身を呼んでいる）。外部 caller の候補は main EXE 由来のみ（distinct 47 / 68 site・**それも overlay slot の entry かもしれず未閉**）。
4. **`lui` の符号拡張で番地が 0x10000 ずれる** — `lui 0x8017` ＋ `lh -0x4F30` は **0x8016B0D0**（低位を目で or すると +0x10000 になる）。
   本フェーズで **4 種 6 表記**が実際にずれた（worker3 が自己発見）。★boss1 が全 `lui` ペアを走査して裏取り済★:
   materialize される回数 = `0x8013A924` **106** / `0x8014A924` **0**、`0x8013CDB8` **106** / `0x8014CDB8` **0**、
   `0x8016B0C2` **11** / `0x8017B0C2` **0**、`0x8016B104` **37** / `0x8017B104` **0**。
   ⇒ **目で足さない**（EXE が実際に materialize するかを機械で照合する）。
5. **不在は走査範囲の宣言とセットでのみ言える** — `gp` は global ゆえ overlay も同じ slot を読み書きする。resident だけを走査して「全数」と言うと落ちる（実例 = §5.2）。

## 1. 戦闘の入口 —【確定・範囲つき】
```
VM opcode 0x66 (handler 0x800EE72C)
  → 0x800AECA8            戦闘に入る直前の準備（view 注視点を主人公へ ほか）
  → 0x80105BE4 → 0x80105DD8  jal 0x801044AC (a0 = 1)   ← ★boss1 裏取り済★
  → loader: index = a0 − 1 ⇒ VAtab[0] = 0x80052AE0 / name[0] = "BTL_REL.BIN"  ← ★boss1 裏取り済★
  → jal 0x8005CA7C         btl_rel へ制御移譲（= battle main loop の入口）
```
- **BTL_REL.BIN を積む site は 1 箇所のみ**（`0x80105DD8`）。**範囲 = resident ＋ 16 overlay の全数走査**
  （overlay からの `jal 0x800AECA8` = 0 件 / `jal 0x80105BE4` = 0 件 / loader 呼び手は resident 17 ＋ overlay 2 = **19 site**、K=1 は依然 1 箇所）。
- 戦闘引数 `gp-0x6d08` = **script を起こした field actor の slot 番号**（slot = actor index + 2 が独立に一致）。
  「それが対戦相手か」は◆前提つき◆。

## 2. opcode 0x50 は BATTLE_START ではない —【確定】
- 実体 = **slot 10（singleton）に command tag 7 を投函する非ブロッキング命令**。handler `0x800ED9FC`（13 命令・分岐ゼロ）。
- **主証拠**（codex 是正後）= ①tag7 consumer を**完走**した（`0x800EFDB4 → 0x800E362C → 0x800E342C`／`0x800E3550` ラッチ ＋ task 0xFB1 → callback `0x800E2B28` → **GTE RTPS → 2D view offset 更新**）＝ **経路上に overlay load も戦闘 flag も戦績更新も現れない** ②**戦闘は 0x66 の別経路で始まる**（§1）。
  （「handler 13 命令 ＋ length 4」は**補助**であって主証拠ではない。）
- length = **4**（`50 <ignored> <id> <param>`）。**独立 2 系統**（EXE helper の `+1/+3` ／ runtime `Len[]`）＋ **仮定を共有する 3 つ目**（DG.SCN census は runtime `Len[]` で境界を歩く）。
- 戻り値の枠 = ①通常の ABI 戻り値は無い ②interpreter への結果は **LongJmp code 1** ③非同期の完了可否は executor の 0/1。
- **名前表の提案** = `DialogueRuntime.cs:72` の `{0x50,"BATTLE_START"}` は誤り。**0x66 に BATTLE_START** を、0x50 は `VIEW_FOCUS_ENTITY`、0x4F は `VIEW_FOCUS_XZ`（"CAMERA" とは断定しない）。
- 0x66 の operand 1 byte = **消費されるが一度も読まれない**【確定・不在主張として成立】
  （関数範囲を実測 `0x800EDE88..0x800EF34C` → `0x43()` 参照 86 箇所を全数 → 区間内 read 0 件 → 外部からの制御流入 0 件、**jump-table entry 1 件が出たこと自体が陽性対照**）。

## 3. btl_rel の base —【確定・三重】
- **0x80052AE0**。①loader VA 表直読 ②内部 jal の自 image 内着地が prologue = **185/190 = 97.4%**（陰性対照 `0x80010000` = **0 個**／`0x80053800` 0.5%／`0x80070000` 1.0%／±4・±16 = 0.0%）③`battle_functions.json` の 346 entry に実在。
- code 域 = `0x80056CA8..0x8007B52C`。MWo1 header の `load_va 0x80056C68` / `size 0x24884`(=149,636 B) は**正しい**（survey の数と枠違いなだけ）。
- **属性相性 8x8 表** = `btl_rel.bin` **file offset 0x60..0xA0 の 64 byte**が `attribute_table.json` の `effectiveness_matrix` と **byte 完全一致**（row0 = `ff ff ef ff ef ff ff ff`）← ★boss1 裏取り済★。
  枠 = raw dump の file offset ＝ **VA 0x80052B40** ＝ **MWo1 payload（file 0x41C8 = VA 0x80056CA8）の外**。
  **持ち主は決まらない**（同 64 byte を同 offset に持つのは btl/std/vs の 3 本のみ・`btl_code.bin` と main EXE には無し・btl_rel code から当該 VA を作る `lui` 0 件〈陽性対照 12 件〉・main EXE 側に 5 件・**実行時に pointer を渡される経路は静的に否定できない**）。

## 4. 戦闘 model は real-time —【確定】
- **battle main loop = `0x8005CA7C`**（overlay 内 caller 0 件 = 入口）。1 frame = 初期化 → `{終了判定 → AI → … → frame counter++}`。
  ★**「ターン制でない」は symbol 名ではなく loop 構造で示した**★（survey §5 の結論は維持・根拠を差し替え）。
- **接近** = 距離は**水平のみ**（`dx²+dz²`、Y は未使用）。許容半径 = `(stats[a].h18 + stats[b].h18 + 200)²`。
  3 分岐（離脱 / 接近 / 向くだけ）。near/far 実値 = 既定 `near=0, far=480000`、motion `0x23/0x24` の間だけ `near=160000(=400²), far=320000`。
- **行動選択** = 候補列挙 → 最近接 → **反復回避**（直近 2 件の ring、index を `(x+1) and 1` でトグル、初期 0xFF）。
  発火 gate = `20*(P.h06/2+1)` frame ごとに `rand(100) < 70 − X`。◆前提つき◆ = `X = *(s16*)0x80141D40` の**値域が未測定**（X<0 なら 70 超、X>70 なら発火しない）。
- **技発動** = 状態 8/9/10 が command slot 0/1/2。MP コスト = `wazaTbl[waza].b06 × 3`、味方側のみ `0x8016B0C2` の s16 で **4 段階割引**（700/800/900/999 で −5/−10/−15/−20%）、`0x80141D18 & 0x60` が非 0 なら **+50%**、`self->h4e < cost` で不可 ⇒ **MP = actor+0x4E**（HP +0x4C の隣）。
  ◆前提つき◆ `0x8016B0C2` を「親密度」と読むのは未成立。

## 5. ダメージと命中 —【確定】＋【範囲つきの不在】
- 8/08 doc §2 の式は**別 base で逐語再現・差分ゼロ**。`getDamagePoint = 0x8005D44C`。
- `getHitRate = 0x8005D0AC`（**名前ではなく呼び出し位置で同定** = 戻り値が直後に `rand(100)` と `slt` 比較）。
  必中 return の口は **6 本**（全列挙）。
- 乱数 = `0x800A4A74 = (N * raw()) >> 15`、`raw = 0x80091480` = **BIOS A(0xA0) table func 0x2F**。
  ★**これは先行 doc（`docs/RE_0x24_rng_2026-07-12.md` / `docs/RE_resident_helper_dict_2026-06-18.md`）の再確認であって新発見ではない**★（両 track とも当該 doc を引かずに書いたため「独立到達」に読める形になっていた。**codex が割り、boss1 が裏取りした**）。
  BIOS ROM は素材に無く**逐語不能**（札 = 原理）。
  **「一様」ではない** = multiply-high ゆえ `rand(100)` は bucket size **328 が 68 値 / 327 が 32 値**（最大偏り ≒ 0.3%）⇒ **「ほぼ一様（±1 bucket）」**。
- **`a0` / `a1` = 攻撃側 / 防御側**：★**役割の別は式の符号で確定**★／★**`+0x3C` `+0x38` `+0x3A` の stat 名は未同定**★（2 つを畳まない）。
- **クリティカル** = ★「**確認した 1-hit SITE A の既知経路には post-return の分岐倍率を発見できない**」★
  閉じた範囲 = 既知 `getDamagePoint` への直接 jal / resolver の local slot `sp+0x3C` / 既知表示関数内の dmg touch。
  **未閉 6 項** = 間接呼出（jalr・表引き）／別 damage sink／inline／二打目／呼出前後の stat・flag 補正／**`s_checkDouble` 未同定**。
  （「戦闘全体で会心的な増幅が無い」とは**主張しない**。）
- **SITE B** = 命中を外し、かつ `skill.byte[0x08]==1` の技だけが与える **10〜30%** の削り（`2 回目 getDamagePoint × (rand(21)+10)/100`）。**迎撃と SITE B は排他**。
- **迎撃** = `rand(100) < s1.half[0x3C] / species[s1.id].byte[0x1D]`（防御側が反撃）。前段 gate と 4 slot の loop（`0xFF` は**終端記号ではなく空 slot の番兵**）。
- `s_damage` 系の HP ドレイン表示 = `0x80102F1C`（>=1000 → −900 / >=100 → −80 / >=10 → −6 / >0 → −1）。

## 6. 技表 —【確定】＋【未決】
- **`wazaTbl = 0x801325C0`（stride 16）が戦闘側の技表**（参照 = btl_rel 43 件 ＋ main EXE 9 件）。
- `params` の**実基底は `0x801304AC`**（`0x80130494` は 3 entry 手前）。`names 0x80130BD4` を指す参照は**1 件も無い**【未決】。
- field = `+0x00` u32（110 entry 中 **90 が完全平方・20 が 0**・平方根は全て 100 の倍数）／`+0x06` MP／`+0x08` 種別 `{1:15,2:71,3:19,4:5}`／`+0x0B` 命中素点／`+0x0D` 対象 flag。
  `+0x00` が**距離² 次元**である逐語証拠 2 本（2 乗値に加算する／装備 4 枠の最大を unsigned 比較）。◆推論◆ = 射程の 2 乗（**「射程」という語はどの逐語にも現れない**）。
- **3 表が同一 index 空間かは未確定**（同一 index で 2 表以上を引く code を未発見）。

## 7. 勝敗と復帰 —【確定】
- btl_rel の戻り値は field 側で**下位 8bit 符号拡張**され **3 値（-1 / 0 / 1）**として処理、**4 値目は無言で捨てられる**。
  ★battle 側が本当に 3 値しか返さないかは **未確認**（worker2 が同定中。「定数を v0 に置いて jr ra する site」の 16/14 件は**別の枠の数**であり戦闘の戻り値ではない）★。
- `result 1`（勝利路のみ）= section/script 再開（`gp-0x6c9e`）→ **map file 再読込**（`gp-0x6d90` = 現在 map id、表 `0x8013541C`、loader と同じ `0x800A46DC`）→ 注視点を主人公へ → transition(+1) → `0x80141D6C += 1`。
  ⇒ ★**「入る前の位置を退避して戻す」機構は無い**★（`0x80141FD8/DC/E0` は退避先ではなく **field view の注視点**）。
- `result -1` = `0x80141D42 -= 30` / `0x80141D40 -= 20` / **遷移状態を clear**（type = −1 は `sltiu 0x10` を通らず no-op arm へ落ちる ＝ **遷移なしの番兵**）。
  `result 0` = `-= 10` / `-= 6` / `0x80141D3A += 2` / **`transition_begin` を呼びもしない**（状態は前のまま）。
  `result 1` のみ **transition type 1** を開始（table `0x8011AF50`・16 entry）。
  ★boss1 註: 初出時に「−1 と 1 で異なる type を開始」と書いたのは worker1 が自己訂正済★。
  ★どちらが逃走でどちらが敗北かは**未決**（観測できるのは「−1 の方が罰が重い」「1 だけが勝利処理を持つ」まで）★。
- `0x80141D6C` = **勝利数**（全域 5 参照・+1 は勝利路のみ）。`gp-0x6ce0` = **累計戦闘回数**（0x66 ごと +1・上限 9999・**save+0x266 に載る**）。
- `gp-0x6b26` = **scene-mode jump table `0x8011AF38` の index**（bound 6・`0x800E9A5C` で `jr table[mode]`）。
  **6 entry は 3 群に潰れる** = `0`→field tick `0x800E9B2C` ／ `1/2/3`→`0x800E9AF8`（共有）／ `4/5`→`0x800E9B0C`（共有・**overlay 領域の VA `0x8006E520` を呼ぶ**）。
  0 = field 側 / 1 = 戦闘直前【確定】。**1/2/3 は arm が同一ゆえ この経路だけでは原理的に分離不能**（未決）。
  **4/5 を書くのは std_rel / vs_rel だけ**という writer 分布と、**4/5 の arm が overlay 内 VA を呼ぶ**ことが独立に整合。
  writer = **resident 6 ＋ overlay 14 = 20**（btl 2 / std 8 / vs 4、他 13 overlay は 0）。
  ★**resident だけを走査して「全数」と書くと、resident に書き手が無い値 4 を「起きない」と誤断できた**★（§0-4 の実例）。

## 8. 未決の一覧（札つき）
| 件 | 札 | 誰の領域 |
|---|---|---|
| ダメージ式の**数値 end-to-end 照合** | **実機**（育成途中の save が要る＝user 1 session） | 全 track 共通・mark 済 |
| `result -1` と `0` の意味／battle 側が 3 値か | 材料（戦闘結果を書く 1 箇所の機能同定） | worker2 |
| `s_checkDouble`（二打目）／R7 `0x8013CDB4[]` の index 意味 | 材料 | worker2 |
| 属性表の持ち主 | 材料 ＋ 実機 | worker3 |
| `names` 表の位置／3 表の index 空間同一性 | 材料 | worker3 |
| `f_80062510` 全長・`f_80058990`・`f_80104250`（cmd→技 id） | 材料（時間のみ） | worker3 |
| `gp-0x6b26` の 2..5 の意味 | 材料（overlay 側 writer の所属 fn 同定） | worker2 / worker3 |
| `result 0 / -1` の map 復帰（`0x800EBD48` type ±1 の consumer） | 材料 | worker1 |
| name → address の対応 | **原理**（blob 単体からは 0 件。MWo1 第 3 領域 0x3284 は未検分） | — |
| BIOS A(0x2F) の逐語 | **原理**（BIOS ROM が素材に無い） | — |

## 9. 最小実装（縮退 slice）へ渡せるもの / 渡せないもの
- **渡せる（式と機構が確定）** = ダメージ式本体／命中率式と必中 6 口／迎撃の確率式と排他／SITE B の条件／MP コストと 4 段階割引／接近の 3 分岐と near/far／行動選択の周期と反復回避／状態列の作られ方／勝敗 3 値と勝利路の復帰手順／戦闘入口 1 本と戦闘回数・勝利数の更新。
- **渡せない（実装前に決めが要る）** = ①**乱数の同値性**（BIOS rand を再現するか、`(N*raw)>>15` の bucket 偏りまで真似るか）②`result -1 / 0` の意味 ③技表 3 種の index 空間 ④属性表の持ち主（データの置き場所） ⑤`gp-0x6b26` の 2..5。
- **数値照合は user 1 session 待ち**（式が正しくても定数の当てはめは実機で確認する）。

## 10. ★他 doc への申し送り（boss1 は他 track の doc を書き換えていない）★
- `0x8014A924` / `0x8014CDB8` を引いている先行 doc が在る（`p2w1,p2w2:docs/RE/s01_evolution_conditions_final.md`、
  `p2w2:docs/RE/BINARY_ANALYSIS_MASTER.md`、`comms:workspace/degimon-faithful178/P2_VALLEY6_worker2.md`）。
  **本フェーズの走査では、この 2 つの VA を materialize する `lui` ペアは EXE に 0 件**（対する `0x8013A924` / `0x8013CDB8` は各 106 件）。
  ⇒ ★同じ `lui` 符号拡張の穴に落ちている可能性が高いが、**別の調査の doc ゆえ boss1 は書き換えない**★。
  札 = **材料**（各 doc の持ち主が、当該行の VA を materialize 照合してから直す）。
