# ★worker1 の 差分表『判らない 5 行』を remake 側で 埋める★（boss1 #438-C ③）

★★5 点様式（§8.1）★★:
```
★worktree★ = `~/Desktop/Digimon/degimon_world_remake-p2w3`
★branch★  = `track3/p2-script-walk`
★sha★     = `30148149`（★本 doc の 全 引用は この sha 時点★）
★path★    = 各行に 明記
★算法★    = ★source 直読 ＋ grep（`OnMapChangeRequested?.Invoke` を ★全数★ 数える）★ / ★走らせて いません・実装して いません★
```
⚠ ★行番号は branch で 変わります★（★本件で 実証済 = honest-mark は p2w1 で :990 / p2w3 で :1383★）⇒ ★★行番号は ★sha 付きでのみ★ 引きます★★
★相手★ = `P2_0x4B_PENDING_DESIGN_worker1.md`（p2w1 / `7c45f2f6`）の ★#7〜#11★

---

## 1. ★★∴ 5 行の 判定★★

| # | 項目 | 原盤（w1 逐語） | ★remake（私の 実測）★ | ★判定★ |
|---|---|---|---|---|
| ★7★ | 移動前の 副作用 | `var[0] := [0x8013E14F]` / `[0x8013E0B2] := 0` | ★`DialogueRuntime.cs` に ★`SetVar(0, …)` の 実装 = 0 件★（grep `SetVar(0,` / `var[0]`）★ / `HandleWarp` は ★registry guard → `LoadById` → `HandleMapLoaded` だけ★ | ★★違う★★ |
| ★8★ | 引数の 幅 | A / B を ★16bit 符号拡張★ | ★`int wMap = _body[_pc + 1]` / `int wSpawn = _body[_pc + 2]`（`DialogueRuntime.cs:1435-1436`）= ★byte を そのまま★ = ★符号拡張 なし・0..255★ | ★★違う★★ |
| ★9★ | a2 = モード | `[0x8013E108]` を `bne $s1,1` で ★2 回 比較★ | ★`OnMapChangeRequested?.Invoke(wMap, wSpawn, ★0★)`（`:1402` / `:1429`）= ★常に 即値 0★・★cell を 読む 語 = 0 件★（0x47 は `mode` を carry するが ★consumer は log 1 行★） | ★★違う★★ |
| ★10★ | 移動後の 再入 | `jal 0x800AE3DC`（★tile handler を 呼び直す★） | ★呼び直しません★。`BuildField` は ★guard の 初期化だけ★ = `_onTriggerLastFrame = false` / `_onScriptTileLastFrame = IsScriptTile(arrival)` / `_warpPending = false`（`FieldManager.cs` 同 sha）⇒ ★次 frame の `Update` が 通常 検出★ | ★★違う（形）★★ ※ ★効果は 近い★ |
| ★11★ | 受け皿の 入口 | ★a1=3 の 3 入口（`0x4B` / `0x58` / `0x66`）が 同じ 受け皿★ | ★下の §2 = ★`0x58` は 実装なし / `0x66` は 実装済だが map を 動かさない★★ | ★★違う（新規 gap）★★ |

## 2. ★★∴ #11 の 実測（★boss1 の 問いへの 直答★）★★

```
★問い★ =『remake は 受け皿に ★0x4B しか 入れて いないのでは★』
★★答え = ★半分 当たり・半分 外れ★★★:
　★(a) ★原盤の 3 入口の うち remake に 在るのは ★0x4B だけ★★★
　　★`0x58`★ = ★`OpcodeTable.ImplementedOps` に ★在りません★★（`DialogueRuntime.cs` 同 sha の 宣言 35 種を 全数 確認）⇒ ★default で skip = ★移動を 起こせません★★
　　★`0x66`★ = ★実装済（`case OP_SCENE_DRIVER`）★ だが ★`OnMapChangeRequested` を ★1 度も 呼びません★★（counter / list の 更新と log のみ）
　★(b) ★但し remake には ★0x4B 以外の 入口も 在ります★★（★原盤の 受け皿とは ★別の 軸★★）:
　　★`OnMapChangeRequested?.Invoke` の ★全数 = 5 箇所★★ = ★`0x47`(:1353)★ / ★`0x4B`(:1402, :1429, :1441)★ / ★`0xFB`(:1474 → `EmitMapChangeFromScenarioJump` :2122)★ / ★`ConfirmMenuSelection`(:2066 = 0x4B の dest 表から)★
⇒ ★★∴ ★『0x4B しか』は ★受け皿の 軸では 正しい★ / ★remake 全体の 軸では 誤り★★★ = ★★∴ ★2 つの 軸を 分けて 書きます★★
⇒ ★★∴ ★新規 gap = ★`0x58` と `0x66` が 移動を 起こせない★★★（★原盤では 同じ 受け皿★）
```

## 3. ★★⚠ ∴ ★この 調査で ★私自身の #714 実装の 欠陥★ が 1 件 出ました★★★

```
★★`_onImmediateTileLastFrame`（51-79 の 再発火 guard）が ★`BuildField` で 初期化されて いません★★★
　★対照★ = ★`_onTriggerLastFrame` は `false` に / `_onScriptTileLastFrame` は ★arrival-aware に true/false★ を 入れて います★
　⇒ ★★∴ ★warp 直後に 51-79 の tile へ 着地すると ★前の 地図の 値が 残る★★★
　　 ★残値 true★ ⇒ ★★その tile を 一度 離れるまで 発火しません★★ / ★残値 false★ ⇒ ★着地 即 発火（chain の 恐れ）★
★★∴ 直し方（★1 行・但し 本便は 実装しない ので 出すだけ★）★★ =
　`_onImmediateTileLastFrame = MapData.IsImmediateScriptTile(_map.TriggerAtWorld(world));`（★`_onScriptTileLastFrame` の 直後・同じ 形★）
★★∴ 影響の 枠★★ = ★`DEGIMON_TILE_5179` が ON の ときだけ★（★既定 OFF ゆえ 現行の 既定挙動には 出ません★）
★★∴ 型★★ = ★★『2 つ 目の 器を 足す ときは ★1 つ 目の 初期化を 全部 数える★』★★（★私は detection と guard は 分けた が ★初期化は 分けそこねた★★）
```

## 4. ★★∴ #438-C ④ の 判断（★足すか どうか だけ★）★★

```
★boss1 の 問い★ = ★w2 の『10 の 段は 描かず・描く 者を 登録する』＋『region ごとに 別の 表を 引く』を ★差分表に 足して 良いか★★
★★私の 判断 = ★足して 良い★（★1 行・判定は「違う」★）★★
★理由★ = ★私の 遷移調査（`P2_REMAKE_FADE_SURVEY_worker3.md`・同 sha）で ★remake の 遷移器 = 0 件★ と 範囲申告つきで 出て います★
　⇒ ★★∴ ★『region ごとに 違う』以前に ★region に 依らない ものすら 在りません★★★ = ★★∴ 判定は ★違う★ で 確定★★
★★∴ 但し 書き方の 注文 1 つ★★ = ★★『10 の 段』を ★『中間の 段』(#4)と 同じ 行に 混ぜない★★★
　★理由★ = ★#4 は ★`[0x8013DF84] == 10` の 分岐★（★時点★）/ 今回のは ★描く 者の 登録先が region ごとに 違う★（★内容★）= ★★別の 量★★
```
