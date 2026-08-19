# W3_584C — ★worker2 の 設計を main/integ で 受ける 形（静的設計）★ ＋ ★var[110] の 捕獲★（worker3）

★受領番号★ = ★#584-C★ ／ ★背景 job = 0 本★
★land しません・push しません・user を 呼びません★／★「完成」「arc 完了」とは 書きません★
★★Unity compile も DISPLAY=:1 も 使って いません★★（token は worker1・使う段で 1 行 出します）
★本便は ★file を 1 つも 変更していません★★ = ★設計と 測定の doc だけ★

---

## 0. ★★一行 ＋ ★危険 1 件★★★

> ★★(A) の 答★★ = ★受け形は 組めます★。★但し ★「`null` = 退路 ゆえ 常に `true`」だけでは ★挙動不変に なりません★★★。
> ★★∵ 呼び元（`EntityPlacer.cs:370-381`）では ★`Passes == true` は「除外する」を 意味します★★★
> ⇒ ★★∴ ★表に 新しい map が 載った 瞬間に その map の 体が 減ります★★（★型では 止まりません★）
> ⇒ ★推奨（1 つ）★ = ★★呼び元に ★述語 gate★ を 足す★★ = ★『1 段 かつ Flag のみ』★
>   ★実測★ = ★その 述語は ★現行 landed の 9 map と 過不足なく 一致★★（§3）

> ★★(B) の 答★★ = ★★今日の 器では 捕まえられません★★ = ★`var_w` の gate（`TraceEnabled`）は
> ★Editor からしか true に なりません★★（★player build では 常に false★・§7）⇒ ★★compile token 待ち★★。
> ★静的な 上界★ = ★枠なし 生 byte で ★94 候補★★ ⇒ ★★0 では ないので 静的には 閉じません★★。

---

# ★(A) 受け形の 静的設計★

## 1. ★私が 読んだ もの（★器を 先に★）★

| 対象 | 実測 |
|---|---|
| `main:.../EntityPlacer.cs` | ★474 行★（boss1 の 値と 一致）／ 私の branch = 478 行（印字 gate 既定 ON の 2 commit ぶん）／ `origin/main` = 318 行 |
| `main:.../TimeGatePreGate.cs` | ★79 行★・`AnyOf` の key = ★9★・`ElsePlace` の key = ★9★（下に 列挙） |
| `p2w2:.../TimeGatePreGate.cs` | ★265 行★・sha256 頭 `a998f397…`・`Stages` の key = ★12★・`ElsePlace`（段ごと）の key = ★12★・`Hold` = ★4★ |
| 呼び元 | `EntityPlacer.cs` ★80 行（`PreGateHold`）／ 102 行（`CurrentFlagGetter`）／ 370-381 行（段の 判定）★ |

```
  main の 9 map = gias02 gias03 gias04 koda00 mayo00 mist02 mist04 mist07 trop04
  p2w2 の 12 map = 上の 9 ＋ ★fact02 fact04 stic02★
  p2w2 の Hold  = ★frzl08 gias04 mist03 trop04★（★4 本★）
```
★★申告 1★★ = ★boss1 の 本文は 「worker2 の Hold（器が出す gias04/trop04）」と 書いて います★ が
★実際の 生成物の `Hold` は ★4 本★★（`frzl08` `mist03` が 増えて います）。★私の器で 数えました★。

## 2. ★★型で 守れる こと / 守れない こと（★分けて 書きます★）★★

### ★型で 守れる（＝ compile が 落ちる ので 気づけます）★
```
  ① `ElsePlace` の 型 = `Dictionary<string,(int species,int slot)[]>` を ★変えない★
     ⇒ 呼び元 375 行 `out var elsePairs` と 377 行 `pair.slot` が ★そのまま 通ります★
  ② `Passes(string, Func<int,bool>)` の ★2 引数 overload を 残す★
     ⇒ 呼び元 378 行 `TimeGatePreGate.Passes(map.Name, getFlag)` が ★そのまま 通ります★
  ③ `ElsePlaceStages` は ★新しい 名前★ で 足す ⇒ ★既存の 名前解決に 一切 触れません★
```

### ★★型では 守れない（＝ ★data の key 集合★ に 依存します）★★
```
  ★`ElsePlace` に ★どの map が 載って いるか★★ = ★型に 現れません★
  ⇒ ★生成器が `ElsePlace` を 12 map で 出し直した 瞬間★ に 呼び元の 挙動が 変わります（§3）
```

## 3. ★★★危険 1 件 — ★『退路 = true』は 呼び元では 『除外する』★★★★

★呼び元の 現行 code（`main:EntityPlacer.cs:370-381`・逐語）★:
```csharp
if (TimePlacement && !PreGateHold.Contains(map.Name))
{
    var getFlag = CurrentFlagGetter();
    if (getFlag != null
        && TimeGatePreGate.ElsePlace.TryGetValue(map.Name, out var elsePairs))
    {
        var slots = new HashSet<int>();
        foreach (var pair in elsePairs) slots.Add(pair.slot);
        if (TimeGatePreGate.Passes(map.Name, getFlag)) elseOnlySlots = slots;   // ★通った ⇒ else 専用 slot を ★置かない★★
        else elseSlots = slots;                                                 // ★通らない ⇒ else の slot ★だけ★ 置く★
    }
}
```
★そして 置きの loop（392-394 行）★:
```csharp
if (elseSlots != null && !elseSlots.Contains(i)) { preGated++; continue; }
if (elseOnlySlots != null && elseOnlySlots.Contains(i)) { preGated++; continue; }   // ★★除外★★
```

⇒ ★★∴ ★`Passes == true`（= 退路）は ★『従来どおり 全部 置く』では ありません』★★★
⇒ ★★∴ ★`ElsePlace` に `fact02` / `fact04` / `stic02` が 載った 瞬間★★:
```
    getVar / getClock = null ⇒ Passes = true（退路）
      ⇒ elseOnlySlots = その map の else slot 集合
      ⇒ ★その slot の 体が 置かれなく なります★  ← ★★landed の 挙動が 動きます★★
```
★★これは ★型でも `null` 退路でも 止まりません★★★ = ★★`ElsePlace` の key 集合だけが 効いて います★★
★★∴ 『新しく 載る 3 map は 旧口から 常に true ゆえ 1 bit も 動かない』は ★`Passes` については 真★ですが
　★呼び元まで 含めると 成り立ちません★★（★私の 読み・code は 上に 逐語で 貼りました★）

## 4. ★★推奨（1 つ）= 呼び元に ★述語 gate★ を 足す★★

```csharp
// ★旧口（Flag だけ）で 受けられる map か★ = ★1 段 かつ 全項が Flag★
static bool LegacyFlagOnly(string map)
{
    if (!TimeGatePreGate.Stages.TryGetValue(map, out var stages)) return false;
    if (stages.Length != 1) return false;
    foreach (var t in stages[0]) if (t.Kind != PreGateKind.Flag) return false;
    return true;
}
```
★呼び元は 1 行だけ 増えます★:
```csharp
if (TimePlacement && !PreGateHold.Contains(map.Name)
                  && !TimeGatePreGate.Hold.Contains(map.Name)      // ★§5★
                  && LegacyFlagOnly(map.Name))                     // ★★これ★★
```

### ★★述語が 現行 9 map と 一致する ことの 実測★★（★記憶では なく 生成物を 構文解析★）
```
  対象 = p2w2 の 生成物（sha256 頭 a998f397…・265 行）
  Stages の key = 12 本
  ★『1 段 かつ Flag のみ』を 満たす = 9 本★
      gias02 gias03 gias04 koda00 mayo00 mist02 mist04 mist07 trop04
  ★満たさない = 3 本★
      fact02  段数=1  種={Flag, Var}
      fact04  段数=5  種={Clock, Flag}
      stic02  段数=1  種={Flag, Var}
  ⇒ ★★満たす 9 本 = `main` の `AnyOf` / `ElsePlace` の key と ★過不足なく 同じ★★★
```
⇒ ★★∴ この 述語なら ★生成器が `ElsePlace` を 何 map で 出そうと★ 旧口が 触るのは ★現行 9 map だけ★★
⇒ ★★∴ ★『載っても 動かない』を ★data では なく 派生（計算可能な 性質）で★ 保証できます★★
⇒ ★退路の 二重化★ = ★生成器側で `ElsePlace`（平坦）を 9 map に 留める★ のも ★併せて お願いします★
　（★但し それは ★data の 約束★ ゆえ ★述語の 代わりには なりません★★）

## 5. ★★`PreGateHold`（呼び元・80 行）と worker2 の `Hold`（生成物）の 関係★★

| | 中身 | ★意味★ |
|---|---|---|
| `EntityPlacer.PreGateHold` | `gias04` `trop04` | ★block ごと skip★ ⇒ `elseSlots` も `elseOnlySlots` も ★null のまま★ = ★従来どおり 全部 置く★ |
| `TimeGatePreGate.Hold` | `frzl08` `gias04` `mist03` `trop04` | ★`TryEvaluate` が ★`true` を 返す★★ ⇒ ★呼び元は `elseOnlySlots` を 立てます★ = ★★除外が 起きます★★ |

⇒ ★★∴ ★同じ 「Hold」という 名前で ★逆の 効果★ に なります★★★
- ★どちらが 勝つか★ = ★呼び元の `PreGateHold` が 先★（`if` の 左）⇒ ★`gias04` / `trop04` は 救われます★
- ★重複しないか★ = ★`gias04` `trop04` は 2 重★（★無害★・両方 とも 「触らない」に 落ちる）
- ★★危ないのは `frzl08` / `mist03`★★ = ★呼び元の `PreGateHold` に 在りません★
　 ⇒ ★今は `Stages` にも `ElsePlace` にも 載って いない ので `TryGetValue` が false で 救われます★
　 ⇒ ★★= また ★data の key 集合だけが 効いて います★★★
- ★推奨★ = ★呼び元に `!TimeGatePreGate.Hold.Contains(map.Name)` を 足して ★2 つの Hold を 同じ 意味（block skip）に 揃える★★（§4 の code に 入れて います）

## 6. ★★`getClock` の 口 — ★`-1` を そのまま 流さない★★★

★差し替え(2)★ = ★`getClock(Hour)` は 生の `gs.Clock.Hour` でなく `EntityPlacer.CurrentHour()` を 通す★ ⇒ ★受けます★。
★但し ★`CurrentHour()` は 時計に 届かない とき ★`-1`★ を 返します★★（`main:EntityPlacer.cs:98`・逐語で 確認）
```
  ★もし -1 を そのまま `getClock` から 返すと★
     fact04 段1 「Hour != 11」 ⇒ ★-1 != 11 = true★  ← ★★『判定しない』では なく 『通る』に なります★★
  ⇒ ★★∴ ★-1 の ときは `getClock` 自体を `null` で 渡す★（= 退路）★★
```
★受け形（案）★:
```csharp
static Func<PreGateClockField, int> CurrentClockGetter()
{
    int h = CurrentHour();
    if (h < 0) return null;                                  // ★★退路★★
    var gs = GameManager.Instance?.Session?.GameState;
    if (gs == null) return null;
    return f => f switch {
        PreGateClockField.Hour   => h,                        // ★DEGIMON_START_HOUR を 尊重★
        PreGateClockField.Minute => gs.Clock.Minute,          // ★override は 在りません★
        PreGateClockField.Day    => gs.Clock.Day,
        _                        => gs.Clock.Month,
    };
}
```
★★申告★★ = ★`Minute` に override が 無い★ため ★`DEGIMON_START_HOUR` を 使うと Hour だけ 人工・Minute は 実時計★
　= ★混ざった 時刻★ に なります。★`fact04` は 「Hour と Minute の 対」で 判定する 唯一の map★ ゆえ
　★★`fact04` を 旧口で 受けない（§4 の 述語で 落ちる）ことが ★この 混ざりの 影響も 消して います★★★。

## 7. ★★worker2 の 推論 1 件（「通った時に 除く slot = ★全段の 腕の 和★」）★★

- ★私の器で 測れるか★ = ★★測れません★★（★原盤の 復号は worker2 の 座・私の DuckStation 器では
  `frzl08` `mist03` `fact04` へ 到達する state を 持って いません★）
- ★★但し ★本便の 受け形では ★その 推論は 一度も 使われません★★★:
```
  2 段以上の map = frzl08(2) / mist03(2) / fact04(5)  ← ★実測（§4 の 構文解析）★
    frzl08 / mist03 = ★`Hold`（かつ `Stages` に そもそも 載って いない）★
    fact04          = ★§4 の 述語で 落ちる（段数 != 1）★
  1 段の map では ★「全段の 腕の 和」= その 1 段の 腕★ ⇒ ★現行と 同じ★
```
- ⇒ ★★∴ ★札に します★★（★測らずに 済ませるのでは なく ★使われないので 今は 効かない★ という 形★）
```
  ★札★ = 「2 段以上の map で 各段の 腕が ★else 側 専用★ か」は ★未測★
  ★効き始める 条件★ = ★`0x1C` / `0x1E` / `0x25` の 復号が 進み `Hold` が 外れた とき★
                    ＋ ★§4 の 述語を 緩めた とき★
  ★閉じ方（材料）★ = ★原盤で 2 段 map の 各段の 腕を 別々に 走らせて slot を 突き合わせる★
                    （= #577-C で `mayo00` に 対して やった ことの 2 段版）
```

## 8. ★★∴ 既存 9 map が 1 bit も 動かない ことの 示し方（★型と code の 両方★）★★
```
  ★型★  ① ElsePlace の 型 不変 ⇒ 375/377 行が 通る
        ② Passes 2 引数 overload 存置 ⇒ 378 行が 通る
        ③ 新設は 新しい 名前（ElsePlaceStages）⇒ 既存の 名前解決に 触れない
        ⇒ ★compile が 通る＝呼び元の 式が 1 つも 書き換わって いない★
  ★code★ ④ 述語 `LegacyFlagOnly` = 1 段 かつ Flag のみ  ⇒ ★実測で 現行 9 map と 一致★
        ⑤ 2 つの Hold を block skip に 揃える          ⇒ ★frzl08 / mist03 が data に 載っても 触らない★
        ⑥ getClock は -1 で null（退路）                ⇒ ★時計に 届かない ときに 『通る』に ならない★
  ⇒ ★★∴ 旧口が 触る 集合 = ★{1 段 かつ Flag のみ} − {PreGateHold} − {Hold}★★
       = ★★現行 9 map − {gias04, trop04}★★ = ★★今 実際に 効いて いる 7 map と 完全一致★★
```
★★これでも ★compile と live で 検収するまでは 「動かない」と 書きません★★★（検収は boss1 指定の 私の build + live）。

---

# ★(B) `var[110]` の 捕獲★

## 9. ★★捕獲の 器が 何を 見るか（★先に 書きます★・boss1 指定）★★
```
  ★問い★    = ★remake で var[110] が ★実際に 書かれる★ か★
  ★見るもの★ = ★`GameState.ScriptVars[110]` へ 値が 入る ★瞬間★★（★読みでは ありません★）
  ★器 1（静的・全 sink 列挙）★ = ★`SetVar(` の 呼び出しを 1 つ 残らず 数える★
  ★器 2（動的・framed）★     = ★remake 自身の VM が 走った ときの `TraceFx{T="var_w", I=110}`★
  ★器 3（静的・上界）★       = ★枠を 仮定しない 生 byte 走査★（★下界では なく 上界★）
```

## 10. ★★器 1 = sink 全列挙（★分岐だけ 見ない★）★★

```
$ grep -rn "SetVar(" unity/Assets --include=*.cs        （main/integ・私の branch = 同じ）
  Editor/EventOracle.cs:98,155              ← ★Editor 専用★（player build に 入りません）
  Flow/FieldState.cs:288                    ← idx = ★VarEvolveTargetId = 0xfe(254)★（定数・110 に なりません）
  Dialogue/DialogueRuntime.cs:1040          ← ★0x1E SET_VAR★  idx = ★script の byte★
  Dialogue/DialogueRuntime.cs:1046          ← ★0x1F VAR_ADD★  idx = ★script の byte★
  Dialogue/DialogueRuntime.cs:1053          ← ★0x20 VAR_SUB★  idx = ★script の byte★
  Dialogue/DialogueRuntime.cs:2012          ← public 透過（`SetVar(idx,val)`）
  State/GameState.cs:841                    ← ★DailyAllowanceVars = {0x1c,0x1d,0x1e,0x1f}★（110 に なりません）
  Audio/V4PlaySectionHook.cs:80             ← ★env `DEGIMON_V4_SETVAR` の ★注入口★★（自然な 経路では ありません）
$ grep -rn "ScriptVars" unity/Assets --include=*.cs | grep -v GameState.cs
  （出力なし）                               ← ★配列への 直書きは GameState の 外に 在りません★
```
⇒ ★★∴ ★自然に var[110] を 書ける 経路は ★DG.SCN の opcode 0x1E / 0x1F / 0x20 だけ★★★
⇒ ★★∴ ★『remake が 0x25 を 実装して いない』は ★var[110] に 効く 論点では ありません★★★
　（★var[110] は `0x25` の 時計写しの 範囲 105-108 の ★外★★ = worker2 の A=105 の 表より）

## 11. ★★器 3 = 上界（★これで 閉じたかった のですが 閉じません★）★★

```
  対象 = unity/Assets/StreamingAssets/dialogue/DG.SCN
         ★692,224 byte / sha256 4d776b2c99755328652d015a1aecf9185ff8612a0de6494cbbe6a6546cbc5e5b★
  ★remake の 実装★ = SetVar(ReadByte(_pc+2), ReadByte(_pc+3)) ⇒ ★byte 並び = OP ?? IDX VAL★
  ★枠を 仮定せずに★ `OP ?? 0x6E` を 数える:
       0x1E SET_VAR : 候補 3375（相異なる idx 94）… ★idx=0x6E は 94 件★
       0x1F VAR_ADD : 候補  859（相異なる idx 45）… ★idx=0x6E は  0 件★
       0x20 VAR_SUB : 候補  567（相異なる idx 56）… ★idx=0x6E は  0 件★
  ★合計 = 94 件★
  ★器が 盲目で ない こと★: idx=0x1F → 44 / idx=0x1C → 22 / idx=0x4A → 3 / idx=0x6F → 5 / ★idx=0x6D → 0★
       （★0 を 返す idx も 在る★ = ★何を 入れても 非 0 を 返す 器では ありません★）
```
⇒ ★★∴ ★上界 94 ≠ 0★★ ⇒ ★★静的には 閉じません★★
⇒ ★★∴ ★94 は 『書かれる』の 証拠では ありません★★ = ★枠（opcode 境界）を 仮定して いない ★候補★★
　（★もし 上界が 0 だったら それは 不在の 証明に なりました★ = ★0 でなかった ので 次の 器が 要ります★）

## 12. ★★器 2 が 今日 使えない 理由（★実測★）★★

```
$ grep -rn "TraceEnabled *=" unity/Assets --include=*.cs
  Editor/EventOracle.cs:187,387,445,498       ← ★全部 Editor★
  Editor/W1GateCensus.cs:25                   ← ★Editor★
  Editor/W1FbMapWireCheck.cs:28  (= false)    ← ★Editor★
  （★player の 経路で `TraceEnabled = true` に する code は ★1 件も ありません★★・env gate も 無し）
  `DialogueRuntime.cs:320` = `public bool TraceEnabled;  // ★既定 false = 完全に無コスト・無影響★`
```
⇒ ★★∴ ★built player を いくら headless で 走らせても `var_w` は ★1 行も 出ません★★★
⇒ ★★∴ ★私が 持っている #582-C-R の build（`w3_build582r`）では 捕獲 できません★★
⇒ ★★∴ ★器 2 は ★Unity Editor batchmode（= compile token）★ が 要ります★★

## 13. ★★∴ 今 出せる 判定と、要求★★

```
  ★今 言えること★
    (a) ★自然な 書き手は DG.SCN の 0x1E/0x1F/0x20 だけ★（sink 全列挙・器 1）
    (b) ★静的な 上界は 94（≠0）★ ⇒ ★『書かれない』とは 言えません★
    (c) ★『書かれる』とも 言えません★ ⇒ ★★どちらも まだ 言えない★★
  ★言っていないこと★
    ・「fact02 / stic02 を 載せてよい / いけない」の 判断（= boss1 / PRESIDENT の 座）
    ・「94 件の どれかが 実際に 走る」（★到達可能性は 別問題★）
```
★★要求（1 行）★★ = ★★compile token を 1 回★★（★Editor batchmode を 1 本・DISPLAY は 不要★）
```
  ★撃つ もの★ = ★`TraceEnabled = true` の Editor harness で DG.SCN を framed に 歩き
                 `var_w` の I を 全部 数える★（★到達可能性は 別に 分けて 印字★）
  ★先に 決める 判定★:
      ★捕まる（I=110 の var_w が 1 件以上）★ ⇒ ★fact02 / stic02 は 載せる 側の 材料★
      ★捕まらない（0 件）＋ ★陽性対照（I=0x1F など）が 非 0★★ ⇒ ★★frzl08 と 同じ 保留の 箱★★
      ★陽性対照も 0★ ⇒ ★★器を 疑う（数を 出しません）★★
```

## 14. ★母数 / 切ったもの / 不変★
- ★読んだ file = 4 本★（main の EntityPlacer / TimeGatePreGate、p2w2 の TimeGatePreGate、worker2 の 設計 doc）
- ★grep = 5 本 / 構文解析 = 1 本 / byte 走査 = 1 本★ ／ ★★file 変更 = 0★★
- ★切ったもの★ = ★実装（compile が 要る）★ / ★live 検収★ / ★原盤の 2 段 map の 腕の 突合（§7 の 札）★ /
  ★94 候補の framed 判定（§13 の token 待ち）★ / ★`0x25` を 実装すべきか の 判断★
- ★push なし・land なし・`git add -A` 不使用・savestate と `.bak` は 触って いません★
- ★出力先は `/tmp` 配下では ありません★（本 doc は repo 内）

---

# ★(B) 続き — ★compile token を 1 回 使って 撃ちました★（01:47-01:49）★

## 15. ★撃った もの（★§9 / §13 で 先に 登録した とおり★）★

```
  器 = ★新規 Editor script `W3Var110Census.cs`（115 行）★
       ★player build に 入らない Editor assembly 側★ ⇒ ★`Assembly-CSharp.dll` を 触りません★
       ★写し★ = `workspace/degimon-faithful178/W3_584C_var110_census_harness.md`（本 repo に 保存・★`.gitignore` が `*.txt` を 弾くので `.md` で 置きました★）
       ★走り終えた後 Unity tree から 撤去★ ⇒ ★untracked `.cs` は 元どおり 1 本★・★HEAD = 152885f9 不動★
  実行 = Unity 6000.4.11f1 -batchmode -nographics -quit -executeMethod …W3Var110Census.Run
         ★DISPLAY なし・窓なし★ ／ ★error CS = 0 件★（build log を grep -c）
  出力 = /home/ken/Desktop/Digimon/w3_584c/{census.txt, unity_census.log, W3Var110Census.cs}（★/tmp 配下では ない★）
  ★引き渡し build は 無傷★ = `Assembly-CSharp.dll` sha256 `98ae1499…3032` / mtime 08/20 00:51（★変わって いません★）
```

## 16. ★★結果★★

| pass | 歩き方 | entry | ★打ち切り★ | step | var_w | ★idx=110★ | ★陽性対照★ |
|---|---|---|---|---|---|---|---|
| ★L★ | jump fall-through | 225/225 | op0 / content0 / tick0 / ★WaitingChoice 37★ | 8,314 | 183 | ★★0 件★★ | `0x6F=2` `0xFE=12` `0x1F=0` `0x1C=0` |
| ★B★ | `BehavioralMode=true`（jump take） | 225/225 | op0 / content0 / tick0 / ★WaitingChoice 57★ | 14,111 | 600 | ★★0 件★★ | ★`0x1F=1` `0x1C=4`★ `0x6F=2` `0xFE=16` |

⇒ ★★∴ ★登録した 判定の 2 番目★ = ★`idx=110` が 0 件 かつ 陽性対照が 非 0★★
⇒ ★★∴ ★`fact02` / `stic02` は ★`frzl08` と 同じ 保留の 箱★★★

## 17. ★★★この 0 が 言って いないこと（★被覆の 限定★）★★★

★★これは 「site が 無い」では ありません★★ = ★★「この 歩き方では 踏まなかった」★★:
```
  ① ★WaitingChoice で 止まった entry が 37 / 57 本★ ⇒ ★選択肢の 先は 歩いて いません★
  ② ★入口は 各 entry の body 先頭だけ★ ⇒ ★section 表（`FB`/(scn,key)）経由の 入口は 踏んで いません★
  ③ ★state は 既定（`new GameState()`）★ ⇒ ★flag 依存の 腕は 片側しか 通りません★（pass B）
```
★★∴ この 0 は ★下界（実行された 回数）★ であって ★site の census では ありません★★

### ★★校正（★器が 盲目で ない ことの 別の 出し方★）★★
```
  ★生 byte 上界★ と ★枠つき walk★ を 同じ 形で 並べます:
      idx=0x6F(111) : 生 byte 候補 ★3 件★（entry 0 に 1・entry 67 に 2） → ★walk は 2 件 捕まえた★
      idx=0x6E(110) : 生 byte 候補 ★94 件★                              → ★walk は 0 件★
  ⇒ ★★∴ ★候補が 実際の opcode site で 歩いた 範囲に 在れば walk は 拾えて います★★（0x6F で 2/3）
```
★★94 件の 置き場所（★私の器で 数えました★）★★:
```
  entry 0:1 / 135:2 / 136:2 / 137:2 / 148:1 / ★154:48★ / ★175:24★ / ★176:14★   ← ★8 entry に 集中★
  ⇒ ★86 / 94 が 3 entry に 固まって います★ ⇒ ★text / data の 偶然一致（枠外）を 強く 疑います★
  ⇒ ★★但し ★疑うだけで 確かめて いません★★★（★枠を 与えられるのは VM だけ★）
```

## 18. ★★∴ 出す 答 と 出さない 答★★
```
  ★出す★   ★remake が var[110] を 書くのを ★私は 1 度も 捕まえられませんでした★★
           ⇒ ★登録どおり ★保留の 箱★（`fact02` / `stic02` は `frzl08` と 同じ 扱い）★
           ⇒ ★向きは 安全側★（★落とした方が 無害・載せる方が 有害★ = boss1 §1(B)）
  ★出さない★ 「remake は var[110] を ★書かない★」 ← ★★被覆が 足りません★★
           「94 件は 全部 false positive」        ← ★★疑いまで★★
```
★★閉じ方の 札（★材料★）★★:
```
  (a) ★選択肢を 自動応答して 先へ 歩く★（`DEGIMON_DIALOGUE_CHOICE` 相当）
  (b) ★section 表の 全 (scn,key) を 入口にして 歩く★（= `DumpJsonlSections` の 形）
  (c) ★entry 154 / 175 / 176 を 名指しで 枠つき decode★（★94 件の 86 件が そこ★）
  ⇒ ★どれも Editor batchmode 1 本で 足ります★（★token を もう 1 回 いただければ 撃ちます★）
```
