# 最小スライス実装設計（★draft・code 0 行★）— 2026-08-26

★user 決定 = A（最小実装へ）★を受けた**設計のみ**。**この doc の時点で code は 1 行も書いていない**。
実装着手は ①本 draft の land ②**codex の戦略査読**（PSY-Q 前提アプローチ）③codex の設計査読 ④user への提示 を経てから。

- 前提 = `workspace/battle-slice/BATTLE_SLICE_RE_FOUNDATION_2026-08-26.md` **§9「渡せる / 渡せない」**。
- ★**推定で埋めない**★ — foundation の「渡せる」に無いものは **stub**にし、**stub と明記**する。

## 1. 置き場所（★既存構造に合わせる・新規 namespace は 1 つだけ★）
実測した既存構造（`p2w1:unity/Assets/Scripts`・全 64 file）:
`Dialogue/DialogueRuntime.cs`(2,502 行) `State/GameState.cs`(893) `Flow/FieldState.cs`(693) `Field/FieldManager.cs`(662)
`Data/DataRegistry.cs`(271) `Editor/EventOracle.cs`(570) `Editor/CruxM3Gate.cs`(462)。
namespace は `DigimonWorld.Dialogue` / `.State` / `.Flow` / `.Field` / `.Data`。

**新規 = `Assets/Scripts/Battle/`（namespace `DigimonWorld.Battle`）**。1 file 500 行以内（既存規範）:

| file | 責務 | foundation の対応 |
|---|---|---|
| `BattleEntry.cs` | field → battle の入口と復帰。**戦闘結果 3 値**と勝利数・累計戦闘回数の更新 | §1・§7 |
| `BattleRuntime.cs` | **1 frame の tick を 2 本立て**（毎 frame ＝ index 0 用／20 frame 周期 ＝ index 1..N 用）。終了判定 | §4・§8.5 |
| `BattleActor.cs` | actor record（HP `+0x4C` / MP `+0x4E` / **`+0x3E`（gate 周期と狙い方を同時に決める s16）** / 狙い `b37` / 状態列） | §4・§8.5 |
| `BattleFormulas.cs` | damage 本体・命中率・迎撃・SITE B・SITE C・MP コスト | §5 |
| `BattleAi.cs` | 接近 3 分岐・**狙い 4 系統**・発火 gate | §4・§8.5 |
| `BattleRng.cs` | **BIOS rand の忠実再現**（§3） | §5 |
| `Data/BattleTables.cs`（`DataRegistry` に相乗り） | 属性表 7×7・技表参照 | §3・§6 |
| `Editor/BattleOracle.cs` | **数値照合 checkpoint**（`EventOracle` / `CruxM3Gate` と同型の Editor harness） | §5・実機 |

## 2. 入口は**既に在る**（★新規 opcode 実装は不要★）
`DialogueRuntime.cs` は既に **`0x66 = SCENE_DRIVER`（EXE handler `0x800EE72C`・`Len=2`）**を実装し、
`DEGIMON_SCENE_DRIVER=1` / `DEGIMON_SCENE_WIRE=1` の **env opt-in gate** で配線している（実測・L118 / L1364 / L589）。
⇒ ★**battle は「0x66 の下に生える」**★。新しい入口を作らない。
- ★名前表の訂正★ = `DialogueRuntime.cs:72` の `{0x50,"BATTLE_START"}` は**誤り**（foundation §2）。
  **0x50 → `VIEW_FOCUS_ENTITY`／0x4F → `VIEW_FOCUS_XZ`／0x66 に `BATTLE_START` を付ける**。
  ★ただし `Len[0x50]=4` は正しいので **length 表は触らない**★（挙動を変えない訂正だけ先に入れられる）。
- gate 名は既存流儀に合わせ **`DEGIMON_BATTLE_SLICE=1`**（既定 OFF ＝ 既存挙動不変）。

## 3. BIOS rand の忠実再現（★ここが設計上いちばん微妙★）
foundation §5 の確定 = `rand(N) = (N * raw()) >> 15`、`raw = BIOS A(0xA0) func 0x2F`。
**BIOS ROM は素材に無く逐語不能**（札 = 原理）。∴ 3 案と線引き:

| 案 | 内容 | 判定 |
|---|---|---|
| R-a | `raw()` を PS1 BIOS の LCG（**乗数 `0x41C64E6D` / 加算 `0x3039` / `(seed>>16)&0x7FFF`**）で再現 | ★推奨★。**先行 doc（`RE_0x24_rng_2026-07-12`）で seed cell `0x80009010` まで確定済**。ただし ★**BIOS ROM で逐語検証していない**★ と明記する |
| R-b | `System.Random` 等で置換 | ✗ **量子化（`(N*raw)>>15`）の偏りが消える** ＝ 忠実性を落とす |
| R-c | 実機 dump した BIOS の rand を移植 | 素材が無い。将来 BIOS が手に入れば R-a を差し替え |

★**必ず保つもの**★ = ①`(N * raw) >> 15` の**形**（bucket 偏り ±1 が構造的に残る。`rand(100)` は **328 が 68 値 / 327 が 32 値**）
②**呼び出し順序**（damage 系統 B は clamp 後・乗算前に引く。getDamagePoint 内 3 本・resolver 内 3 本）。
★**目標にしないもの**★ = 実機との **seed 系列一致**（BIOS 実体が未検証ゆえ、一致を主張できない）。
⇒ ★API は `BattleRng.Next(int n)` の 1 本にして、`raw()` の供給元を差し替え可能にする★（R-c への移行路を残す）。

## 4. 属性表 49 byte の持ち込み
- 出所 = **main EXE VA `0x801322F4..0x80132324`（7×7）／file offset `0xA1AF4`**、値 `{2,5,10,15,20}`、`/30` で `x0.2..x2.0`。
- ★`data/battle_attribute_matrix.json` を新規 provision★（既存の `data/*.json` は **repo 直下 tracked → `StreamingAssets/data/` へ prep script で provision** という既存 plumbing に乗る＝`DataRegistry.cs` L8-12 の実測）。
- ★`_source` 欄に **VA と file offset と抽出日** を必ず書く★（★`attribute_table.json` が出所欄を持たなかったせいで循環に気づけなかった★＝本フェーズの教訓）。
- 引き方 = `m[i] = (col == 0xFF) ? 10 : matrix[row*7 + col]`（row = 技 element = skill `byte9`／col = 防御側 species の属性 id）。
- ★`attribute_table.json`（8×8・値 255/239）は **使わない**★。**削除もしない**（別用途の可能性）が、**battle からは参照しない**と doc に明記。

## 5. 敵 1 体・技 1 個の縮退 — ★何を再現し 何を stub するか★
| 項 | 最小 slice | 根拠 / 備考 |
|---|---|---|
| damage 本体・属性補正 3 本・命中率・必中 6 口 | ★再現★ | foundation §5（逐語） |
| 迎撃・SITE B・SITE C | ★再現★ | 排他条件と確率式まで確定済 |
| MP コスト（4 段階割引・+50%） | ★再現★ | §4 |
| 接近 3 分岐・near/far 実値 | ★再現★ | §4 |
| 狙い 4 系統 | ★**再現（1 系統に畳まない**）★ | ★「最近接」に一本化すると忠実でなくなる（worker3 申し送り）★。敵 1 体でも **`+0x3E` の 3 段切替は実装する** |
| tick 2 本立て | ★再現★ | index 0 用と 1..N 用は**中身が別**（Jaccard 0.35 で実測） |
| 技表 105/119/122 の全体 | ✗ **stub**（技 1 個ぶんだけ table 実値を置く） | 3 表の index 空間が未確定（§6） |
| 報酬（exp / bits / drop） | ✗ **stub** | survey §4-4 が未 RE（worker2 が着手予定） |
| result −1 / 0 の別（逃走 / 敗北） | ✗ **stub**（両方「負け扱い」で 1 本） | ★実機 1 session で決まる★ |
| 敗北後の map 復帰 | ✗ **stub**（勝利路のみ実装） | U6 = 3 択・実機 1 回で決まる |
| 演出（ダメージ数字 pop・カメラ・SE） | ✗ **stub** | RTPS 射影は §2 に在るが視覚は user 手番 |

★**stub の条件**★ = 「後で本実装に差し替えるとき **呼び出し側を書き換えなくて済む形**」＝ interface か 1 関数に閉じる。
★stub には `// STUB(未 RE): <何が未確定か> / 札 = <実機 or 材料>` を必ず書く★（負債を可視のまま置く）。

## 6. 数値照合 checkpoint（★実機 1 session を無駄にしないため 先に置く★）
- `Editor/BattleOracle.cs`（`EventOracle` 同型）に **golden vector の受け皿**を先に作る。
- ★user の実機 1 session で採るもの（既に 1 行化済）★:
  ① **ダメージ式の数値**（育成途中 save が要る。全カンストだと被ダメが 1 に潰れる）
  ② **`gp-0x6d84`（VA `0x8013E088`）が 1 → 0 に変わる瞬間の PC**（U6 = 3 択を 1 つに決める）
  ⇒ ★**同じ 1 session に相乗りできる**★。
- ★照合が通るまで「忠実」と書かない★。

## 7. 段取り（★小 commit・各 step で headless verify・broken state ゼロ★）
1. 名前表の訂正のみ（0x50/0x4F/0x66 の名前・**length は触らない**）→ 既存 test 緑を確認
2. `BattleRng` ＋ その単体 verify（bucket 分布 328/327 を assert）
3. `data/battle_attribute_matrix.json` provision ＋ `BattleTables` 読み込み verify
4. `BattleFormulas`（damage / hit）＋ 手計算 vector で verify
5. `BattleActor` / `BattleRuntime` の骨格（tick 2 本立て・終了判定）
6. `BattleAi`（接近・狙い 4 系統）＋ `BattleEntry`（0x66 gate の下に配線）
- ★Unity ゆえ cargo 規範は非適用★。verify は **batchmode headless**。
- ★**headless 緑は完成の根拠にならない**★（★見た目 PASS ≠ 忠実★）。中間報告では **「headless 緑・user 実視覚待ち」**と書く。
  ★完成 claim は user の実視覚まで凍結★（AI worker は GUI 視覚 verify 不可 ＝ capability 境界）。

## 8. worker 構造（boss1 裁定）
- ★凝集した slice ゆえ **focused / 直列** を推奨★（覚醒 cutscene で実証済）。並列にするなら **worktree 隔離必須**。
- 現時点の分担案 = ★実装は 1 worker が直列★／他 2 名は **RE の残り（worker2 = 勝敗・報酬、worker3 = AI の未読分）を継続**し、
  ★実装が必要とする穴を先回りで埋める★（実装を止めない）。

## 9. ★codex 戦略査読の反映（2026-08-26 03:11）— ★結論 = アーキ組み替えは不要★★
順位づけ = **(b) compiler idiom / ABI = 高（最も即効）** ／ **(d) SDK format 意味論 = 高** ／
**(c) `.c` 分割 = 中（責務地図に限定）** ／ **(a) `.SYM` で name→address = 低（現素材では解けない）** ／ **(e) stage gate = 高**。
★**boss1 の実物 1 点検証**★ = (a) を codex 指定の打ち切り手（blob 先頭の `"MND",01h`）で撃った ⇒ **magic 無し**
（blob 先頭 = `20 20 20 20 20 20 20 32 31 5d …`）・**file 全域で `MND` 0 件**（main EXE の 1 件は `MND.TIM` という**ファイル名**）・
**disc / extracted に `.SYM` も linker `.MAP` も 0 件** ⇒ ★**(a) は打ち切り**★。
MWo1 第 3 領域 = **[binary 4,928 B（btl_rel span の VA 195 語 ＋ 小整数 ＋ SJIS）] ＋ [psylink text 8,008 B]**。
**address 側と名前側が同じ region に在るが、結合表は無い**。ただし blob は `"<name> (local|global) defined in <file>"` 形式で
**name → source file は取れる**（boss1 の strict parse で **28 件 / 10 source file**: result.c 8 / OVL1__AF_paral2.c 6 / charge.c 4 / … / s_battle.c 1 / camera.c 1）。

⇒ ★**§1 の file 分割表はそのまま**（機能で同定した関数を単位に写す）★。`.c` 分割は
**provenance / domain ownership / golden test の配置単位**にだけ使い、**1999 年の `.c` 1 個を Unity の class 1 個へ機械的に写さない**。

### 9.1 ★設計に足す 3 点★
1. ★**typed MIPS address evaluator を RE 側の共通器として先に入れる（手計算を禁止）**★ — ★これは解析器で、実装 code ではない★。
   - `lui + addiu` ⇒ low16 は **signed**（HI16 を carry 補正）／`lui + ori` ⇒ low16 は **unsigned**（単純連結）／`load/store` ⇒ `base + signed 16-bit disp`
   - ★**「0 件」を主張するときは site だけでなく ★命令の形★ も列挙する**★
     （実測 = 本 session で lui 系の誤読 **6 回**。直近 1 件は「**絶対アドレス形 `lui+sh` を形の列挙から落としていた**」＝ worker3 の自己発見）
   - profile 化 = load delay / branch delay slot / `div` の trap sequence / `$gp` と `-G` / `lb`・`lh` の signedness / switch jump table / struct・bit-field の ABI layout
2. ★**format parser は SDK を「仕様書」として使い、SDK struct を C# に marshal しない**★ — little-endian 固定幅 read ／ offset と pointer を区別 ／
   TIM は **VRAM 幅と表示 pixel 幅を区別**。検証手 = **TIM を 1 個 parse して各 block length と消費 byte が file 境界に完全一致すること**
   （btl_rel 先頭で **CLUT 76 = 12+16*2*2 / image 3276 = 12+34*48*2** は確認済）。
3. ★**golden trace を忠実性の固定点にする stage gate**★ — ①仮説は **1 点実証**するまで深掘りしない ②compiler archaeology は
   「誤読クラスを 1 つ潰す」か「関数同定を 1 つ確定する」ときだけ ③固定小数 / GTE / HW 挙動は **golden trace に差が出る境界だけ**再現する。

### 9.2 ★実装に直結する追補（worker3・03:10-03:12）★
- `actorTable[1] = 0x8016B084` を置くと散在していた絶対番地が **6/6 で field に一致**:
  **`+0x3E` = AI パラメータ ★かつ★ MP 割引変数（同一 field）** ／ `+0x44..46` = command slot ／
  **`+0x4C` = partner HP（battle main loop の終了判定）** ／ `+0x4E` = MP。
- `+0x3E` の出所 = **save record の stat 4 つ組の 4 番目**（`0x801460D2`・writer 1 件）＝ **stat id 3**（先行 doc = worker1 の 0x19 stat accessor 表）。
  id 0..2 は item で **+30% / 999 cap** を受けるが **id 3 は受けない**（item 説明文にも「かしこさアップ」が無い＝別系統の噛み合い）。
  ★**名前（攻/防/速/賢）は当てない**★ — 「stat id 3 / h3E」と呼ぶ。
- ⇒ ★**実装でも 1 パラメータに保つ**★（**特殊行動 gate の周期・狙い方の 3 段切替・MP コストの 4 段階割引を同時に支配する**。3 つに分けると原盤とずれる）。
