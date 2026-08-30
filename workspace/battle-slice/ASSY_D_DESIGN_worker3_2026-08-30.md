# battle assembly (d) — real-time ループと 描画 の設計（worker3・2026-08-30）

**便 #927-W3a の (d) だけ**を書く。**(a)(b) = worker1 ／ (c)(e) ＋ 統合 = boss1**。
**★code 0 行★**（本 doc は設計のみ・tree は 1 file も編集していない・worktree を新設していない）。

---

## §0 この doc の枠（先に）

### 0-1 ★私が読んだもの（tree / file / 行を添える）★

| 何 | どこ（★tree を明記★） |
|---|---|
| VM の tick / exit の形 | `degimon_world_remake` の **`main`（`228bc914`）**：`unity/Assets/Scripts/Dialogue/DialogueRuntime.cs` `:756`(Tick) `:1391`(0x67 frame-yield) `:1431-1529`(0x66 case) |
| VM の毎 frame 駆動主 | 同 `main`：`Dialogue/TextboxView.cs` `:187`(Update) **`:257 _rt.Tick();`** |
| flow の骨格 | 同 `main`：`Flow/GameFlow.cs` `:43-48`(IGameState) `:80-82`(Update→Tick) `:85-87`(OnGUI→DrawGui) |
| field の毎 frame gate | 同 `main`：`Field/FieldManager.cs` `:174`(Update) **`:236 if (GameManager.Instance != null && GameManager.Instance.InputLocked) { … return; }`**、`:22-30`(RuntimeInitializeOnLoadMethod 自己生成 idiom)、`:476 BuildField` / `:556 TeardownField` |
| 戦闘 logic の現物 | 同 repo の **branch `track1/battle-slice-impl`（`a86e1b2b`・★worktree には入らず `git show` で読んだ★）**：`Battle/BattleRuntime.cs` `:104 Tick()`、`Battle/BattleActor.cs` `:508 IsDown()` `:514-529 DrainDamage()`、`Battle/BattleEntry.cs` `:全`（gate / counter / IBattleStats） |
| RE の出所 | `comms:workspace/battle-slice/BATTLE_SLICE_RE_FOUNDATION_2026-08-26.md` §1 / §4 / §5 / §7 / §8.28 / §8.51 / §9.6、`BATTLE_SLICE_PHASE_CLOSEOUT_2026-08-30.md` |

### 0-2 ★この doc が主張しないこと★

- **★原盤の battle 画面を 私は 1 枚も見ていない★**。
  ★探し方の枠★ = `Desktop/Digimon` / `Desktop/vise` / comms を **★file 名に `battle` を含む画像★で切って 0 件**。
  **★これは「無い」の証明ではない★**（**別名で在りうる**）⇒ **★『手元に無い』ではなく『私は見つけていない』と書く★**（`[[feedback_absence_in_truncated_list]]` / 名前で切った census の穴）。**在るなら 出してください＝§6 D-7 が消えます**。
  ⇒ **§3 の「何を出すか」は ★機構から導いた最小★ であって ★見た目の忠実ではない★**。**「原盤に似ている」とは 1 行も書かない。**
- **式の格は §9.6 のまま**：**主要 damage 経路 ＋ 属性表の寄与だけが live 確定**、**SITE B / 迎撃 / MP / 系統 A / 他 44 cell / 乱数分布 / 命中 / bonus は 未 live**。
  本 doc は **★「式が検証された」とは書かない★**。
- **実機に接続していない**／**凍結 3 本（`-p2w1` `-p2w2` `-p2w3`）に触っていない**／**main を変えていない**。

---

## §1 (d-1) 1 frame の real-time ループを どこで回すか

### 1-1 ★結論（単一推奨）★

> **★戦闘 1 frame を回すのは ★`DialogueRuntime.Tick()` の中★（= VM の 0x66 case が持つ driver）★。**
> **★新しい MonoBehaviour は「描画と入力」の 1 本だけ（`BattleView`）★で、★logic 側は 1 つも増やさない★。**
> **★step は Unity の frame ではなく 固定 step accumulator で刻む★。**

### 1-2 ★なぜ VM の中か（原盤の形との対応）★

原盤（FOUNDATION §1 / §8.28）:

```
VM opcode 0x66 handler (0x800EE72C)
   → 0x800AECA8 → 0x80105BE4 → 0x800AED48 ★jal 0x8005CA7C★   ← battle main loop へ入る
        0x8005CA7C..0x8005CABC = 開始処理（0x8005CAAC jal 0x80056CA8 / 0x8005CAB4 jal 0x800574EC）
        ★0x8005CABC = loop head★（0x8005CB0C の b が ここへ戻る）= ここから per-frame
   → 0x800AED50 戻り値の下位 8bit 符号拡張 = ★3 値(-1/0/1)★
```

⇒ **★原盤では battle main loop は VM handler の call stack の中で回っており、VM は戦闘が終わるまで 1 命令も進まない★**。
remake は blocking できない。**その形に最も近いのは「VM の Tick が 戦闘 1 frame ぶんを回して return する」**。

**★前例が既に在る★** = **`0x67` の frame-yield**（`DialogueRuntime.cs:1391-1397`）＝
**「この tick の VM 実行を終了・次 tick に `_pc` から再開・`State` は `Running` のまま」= ★第 3 の exit★**。
**戦闘はこの exit の 長時間版**にすぎない。**新しい概念を 1 つも足さずに済む。**

**副次だが大きい利点** = **★戦闘が harness だけで完走できる★**。
`Editor/CutsceneVerify178.cs:47` / `W1GateCensus.cs:28` などは **`rt.Tick()` を回すだけ**の器で、
戦闘を VM の中に置けば **★Unity の画面なしで 1 戦を最後まで走らせて 3 値を取れる★**（＝ **live に触らずに 回帰 test が書ける**）。
**`BattleRuntime` は既に `UnityEngine` 非依存**（worker1 の file 冒頭に明記）ゆえ **この性質を壊さない**。

### 1-3 ★採らなかった案と その理由★

| 案 | 採らない理由 |
|---|---|
| **`GameFlow` に `BattleGameState : IGameState` を足す**（scene-mode jump table `gp-0x6b26` の対応物に見える） | ①**`GameFlow.ChangeState` は必ず `Exit()` を呼ぶ**（`GameFlow.cs:73`）⇒ **`FieldState.Exit()` が走る**（`FieldState.cs:603` = InputLocked 解除 ＋ 購読解除）。②**`result 0 / −1` は ★map 再読込をしない★**（§7）＝ **戦闘前の field をそのまま生かして戻す必要が在る** ⇒ **state を降りる形と噛み合わない**。③**原盤の battle loop は scene-mode の arm ではなく ★VM handler の中★** で回っている（§8.28 の線） |
| **`BattleRuntime` を MonoBehaviour にして `Update()` で回す** | **`UnityEngine` 非依存を捨てる** ＝ **headless verify を失う**。**worker1 が明示的に守っている性質**を壊す |
| **coroutine（`StartCoroutine`）** | remake の VM は **coroutine を 1 本も使っていない**（`grep IEnumerator` = 0 件）。**周囲の書き方と違う形を 1 本だけ入れる理由が無い** |

### 1-4 ★固定 step（ここは 明確に決めが要る）★

`BattleRuntime` は **frame を数える**（`BattleRuntime.cs`）:
- `Frame++`（loop 末尾） / **20 frame 周期 tick**（`Frame % PeriodicTickFrames == 0`） / **ゲージは 2 frame に 1 回**（`(Frame & 1) == 0`）

**Unity の `Update` は可変**ゆえ **★`Update` 1 回 = 戦闘 1 frame にすると 機械の速さで戦闘の速さが変わる★**。

**推奨** = **実時間 accumulator で刻む**（**`FieldManager.cs:283 TickClock` と同じ書き方**＝`_clockAccum` の idiom が既に在る）:

```
_accum += Time.deltaTime;
int steps = 0;
while (_accum >= BattleFrameSeconds && steps < MaxStepsPerUpdate) { battle.Tick(); _accum -= BattleFrameSeconds; steps++; }
if (_accum >= BattleFrameSeconds) { _accum = 0f; ★log(捨てた step 数)★ }   // ★黙って落とさない★
```

- **`BattleFrameSeconds` の値** = **★未検証★**。**原盤の battle main loop が 1 frame = 1/60 s か 1/30 s かを 私は測っていない**。
  ⇒ **定数 1 本に名前を付けて置き、doc に ★札（実機）★ を立てる**。**「60 だから 1/60」と書かない。**
- **`MaxStepsPerUpdate`（例 4）で頭打ちにする**が、**★頭打ちに掛かった回数を必ず印字する★**
  （**打ち切りを黙って 0 件に見せない** = `[[feedback_zero_count_needs_emitter_census]]` の型）。

### 1-5 ★原盤の 1 frame ↔ remake の対応（並べたもの）★

| 原盤（1 frame の中） | remake の対応 | 格 |
|---|---|---|
| 終了判定（loop 先頭） | `BattleRuntime.Tick()` 冒頭の `IsPartnerDown()` → `Finished` / `Result` | **実装済**（worker1）・**結果コードの出し分けは STUB** |
| 毎 frame tick `0x80057F78`（index 0） | `TickEveryFrame` | **実装済（中身は STUB）** |
| 行動 timer の前進 `f_8005907C`（gate 付き） | `AdvanceFrameTimer(ActionTimerGateOf(a))` | **実装済** |
| 20 frame 周期 tick `0x80058990`（全 actor） | `TickPeriodic` | **実装済（発火の先は STUB）** |
| ゲージ増加（2 frame に 1 回・`0x8005C1DC`） | `GaugeGain(0)` | **実装済（式の相手 field は STUB）** |
| frame counter++ | `Frame++` | **実装済** |
| **HP drain `f_80102F1C`** | **`BattleActor.DrainDamage()`** | **実装済・★本 slice の 描画で 効く（§3-3）★** |
| 接近 3 分岐 / ターゲット選択 / 技発動 | **未実装（STUB）** | **札 = 材料**（worker1 の step⑥ 以降） |

> **★私が (d) で足すのは 上表に 1 行も足さない★** — **足すのは「誰が Tick を呼ぶか」と「何が見えるか」だけ**。

---

## §2 (d-2) VM（DialogueRuntime）との関係

### 2-1 ★結論★

> **★戦闘中 VM は止まる（ただし `Finished` にはしない）★** = **`State = Running` のまま `_pc` を `0x66` に据え置いて `return` する**
> （**`0x67` frame-yield と ★同じ第 3 の exit★**）。**戦闘が終わった tick で epilogue を実行し、★現行と同じ exit（`EmitPage()` → `Finished` = idle_stop）に合流する★。**

### 2-2 ★なぜ VM 側に park を持たせるのか（見落とすと壊れる点）★

**★`TextboxView.Update` は `GameFlow` と無関係に 毎 frame `_rt.Tick()` を呼ぶ★**（`TextboxView.cs:257`・`State` を見ずに呼ぶ）。
⇒ **★戦闘中に「VM を止める」を VM の外（flow / 呼び手）で表現しても 止まらない★**。**park は `Tick()` の内側に持つしかない。**

### 2-3 ★park / resume の手順（擬似コード・形だけ）★

```
case OP_SCENE_DRIVER:                       // 0x66
    if (!_sceneDriver) break;               // ★既定 OFF = 現行 bit 不変（不変）★

    // ★(0) 再入 guard = ★最初に見る★★
    if (_battleActive) {                    // 戦闘中の 2 回目以降の Tick
        if (BattleTickAndDrain()) return;   // ★まだ続く = State は Running のまま return（frame-yield と同型）★
        RunBattleEpilogue(_battle.Result);  // ★終わった = 3 値の後処理（§5）★
        _battleActive = false;
        // ↓ 現行の exit にそのまま合流
        EmitPage(); State = DialogueState.Finished; return;
    }

    … B1 operand / ★B2 counter（E12C++、9999 飽和）★ / B3 / B4 / B5 / B6 …   // ★現行のまま・1 回だけ★

    if (BattleEntry.GateEnabled) {          // ★DEGIMON_BATTLE_SLICE=1 のときだけ★
        _battle = BuildBattle(…);           // actor 2 体（(a) の成果物を受ける）
        _battleActive = true;
        return;                             // ★State=Running のまま park。次 Tick から (0) に入る★
    }
    EmitPage(); State = DialogueState.Finished; return;   // ★gate OFF = 現行と 1 mm も違わない★
```

### 2-4 ★具体的な失敗形（先に名指ししておく）★

1. **★B2 counter が毎 frame 進む★** — 再入 guard を **B2 より後**に置くと、**戦闘中の全 frame で `E12C++`** が走り
   **★数十 frame で 9999 に飽和する★**。⇒ **guard は `case` の ★先頭★**（上の (0)）。
2. **★`Finished` にして戦闘を別 state で回す★** — `FieldState.OnDialogueFinished`（`FieldState.cs:556`）が走り
   **`InputLocked=false`**（`:587`）⇒ **★戦闘中に field の player が歩く★**。⇒ **park 中は `Finished` にしない**。
3. **★park 中に `_pc` を進める★** — 次 Tick で **0x66 の次の op を実行**してしまう。⇒ **`_pc` は 0x66 の位置に据え置く**
   （**現行 exit も「`_pc` は 0x66 位置のまま」と書いてある**＝`DialogueRuntime.cs:1525` の註と同じ扱い）。
4. **★`WaitingFrames` を流用する★** — `Tick()` 冒頭で `--_waitFrames` が回り **`Running` に戻る**（`:778-780`）＝
   **戦闘の長さを frame 数で先に宣言することになる**。**戦闘の長さは戦闘が決める**ゆえ **使わない**。

### 2-5 ★field 側を止める手（既存の gate をそのまま使う）★

- **`FieldManager.Update` の `:236`**：`if (GameManager.Instance != null && GameManager.Instance.InputLocked) { … return; }`
  ⇒ **★戦闘中は `InputLocked = true` を維持する★**（0x66 は dialogue 実行中に来るので **既に true**＝`FieldState.cs:552`）。
  **∴ 追加の凍結機構は要らない。**
- **★但し これは「歩かない」だけで「見えない」ではない★** — field の camera / backdrop / entity は **GameObject として描かれ続ける**。
  **見えなくする側は §3-1。**
- **★副作用として game-clock も止まる★**（`FieldManager.cs:250 TickClock` は同じ gate の下）。
  **★原盤が戦闘中に game 時計を進めるかは 私は測っていない★** ⇒ **札（実機）**。**「止まるのが忠実」とは書かない**（**既存 gate の再利用から落ちてくる挙動**であって、**確かめた挙動ではない**）。

---

## §3 (d-3) 最小の描画 — 「何を出せば 戦闘に見えるか」

### 3-0 ★描画の置き場★

> **★`BattleView : MonoBehaviour`（`OnGUI` 描画 ＋ 入力）を 1 本だけ足す★。`BattleRuntime` は read-only で読むだけ。**
> **理由 = ★既に同じ対（logic / 描画）が在る★** ： `DialogueRuntime`（非 Unity）↔ `TextboxView : MonoBehaviour`（`OnGUI` 描画 ＋ 送り入力）。
> **生成は `RuntimeInitializeOnLoadMethod` の自己生成 idiom**（`FieldManager.cs:22` / `ViseAvatarBootstrap`）で、
> **★`DEGIMON_BATTLE_SLICE=1` のときだけ生成する★**（**未設定なら component すら作らない = 最強の OFF-inert**）。

### 3-1 ★優先順（P0 = これが無いと「戦闘」に見えない）★

| # | 出すもの | なぜ最小に要るか | 出所 |
|---|---|---|---|
| **P0-1** | **画面を戦闘面が占有する**（全画面 box を `OnGUI` で描く・`GUI.depth` で textbox より前面） | **field が描かれ続ける**（§2-5）ため、**これが無いと「field の上で数字が動くだけ」に見える** | — |
| **P0-2** | **2 体（味方 = index 0 / 相手 = index 1）と ★水平距離★** | 原盤の接近は **`dx²+dz²`（★Y は未使用★）** ＝ **戦闘の空間は実質 水平のみ** ⇒ **最小は 1 次元（横）に 2 体・距離が毎 frame 動く**。**★動きが在ることが「real-time である」の唯一の視覚証拠★** | FOUNDATION §4 |
| **P0-3** | **HP を ★2 つの数で★ 出す**：**表示 = `Hp4C`（drain で段階的に減る）／判定 = `Hp4C − DamageAccum2E`（即時）** | **★drain（`f_80102F1C`）は `HP` と `pending` から ★同量★ を引くので 実効値を変えない★**（§8.51・worker1 の test が自分の claim を落として確定）。⇒ **★KO は当たった瞬間に決まり、バーは後から追いつく★**。**この 2 値を 1 つに畳むと 原盤と別物になる** | FOUNDATION §8.51 ／ `BattleActor.cs:508/514-529` |
| **P0-4** | **ダメージ数値**（1 発ごと） | **★live で確定している唯一の量★**（§9.6 の `dmg=398`）。**出せば 実機 log と直接突き合わせられる** | FOUNDATION §9.6 |

| # | P1（在ると 戦闘として成立する） | 註 |
|---|---|---|
| **P1-5** | **今の「指示」表示 ＋ ←/→ で変わること** | **入力が効いている証拠**（§4） |
| **P1-6** | **決着表示（3 値）→ field へ戻る** | **★-1 / 0 の意味は未決★ゆえ ★名前を当てず 3 値をそのまま出す★**（§5） |

| # | P2（★最小の外★・本 slice では作らない） | 札 |
|---|---|---|
| P2-7 | 技のモーション / エフェクト | 材料（効果器 20 モジュール = 演出側・格は **前提つき**） |
| P2-8 | 戦闘 BGM / SE | 材料（scene 音声の機構は別 track に在るが battle は未同定） |
| P2-9 | **原盤の背景・配置・font・見た目** | **★材料（原盤の battle 画面の静止画/動画が 手元に 1 枚も無い）★** |
| P2-10 | sprite / model の忠実 | 材料（field-char RE 後） |

### 3-2 ★忠実の線を どこに引くか（私の判断）★

> **(α) ★数と時間は忠実に作る★** = damage 式・属性表の寄与・drain の 4 段（900/80/6/1）・終了判定（`≤ 0`・等号を含む）・
>   20 frame 周期・2 frame ゲージ・frame counter。**ここは ★RE 済のものを そのまま動かすだけ★ で、発明が要らない。**
> **(β) ★画面の構図は忠実を主張しない★** = 配置・色・font・演出。**★私は原盤の画面を見ていない★**（§0-2）。
>   ⇒ **★後で丸ごと差し替えられる形にしておく（`BattleView` 1 file に閉じる）★** ＋ **doc に札を立てる**。
>
> **★この線を引く理由★** = **(α) を間違えると「戦闘の中身が別物」になり、(β) を間違えても「見た目が違う」で済む**。
> **★見た目の忠実を先に追うと、確かめられない主張（「原盤に似ている」）を doc に書くことになる★** — それは避ける。

### 3-3 ★drain が描画に効くこと（見落としやすいので単独で書く）★

- **`DrainDamage()` は 1 回で `pending` を 900 / 80 / 6 / 1 ずつ 4 段階で流す**（`BattleActor.cs:525-528`）。
  ⇒ **★どこで これを呼ぶかで バーの減り方（＝画面の見え方）が決まる★**。
- **★原盤で drain を呼ぶ周期を 私は同定していない★**（`f_80102F1C` の呼び手側を読んでいない）⇒ **札 = 材料**。
  **∴ 本 slice では「毎 frame 1 回」を ★仮に置き、doc に 仮であることを書く★**（**「毎 frame が原盤」とは書かない**）。
- **★判定（`Hp4C − DamageAccum2E ≤ 0`）は drain と無関係に成立している★** ので、
  **★drain の周期を間違えても 勝敗は変わらない★**（**バーの速さだけが変わる**）＝ **仮置きの被害範囲が閉じている**。

---

## §4 (d-4) 入力 — 最小では 何が要るか

### 4-1 ★結論★

> **★←/→ の 2 キーだけ★。「今の指示」を `0..2` で回す。★決定キーもキャンセルも要らない★。移動入力は ★無い★。**

- **移動が無いこと** = **user 実測**（便 #927-W3a）。**私は独立に確かめていない**（**user の観測をそのまま採る**）。
- **←/→ で「命令」が変わること** = **user 実測**。

### 4-2 ★ここで 名前を当てない★

- 原盤の命令 slot は **actor `+0x44` / `+0x45` / `+0x46`**（`BattleStateSequence.cs` の append が見る 3 本・**`+0x47` は入らない**）で、
  **発動 slot は state 8/9/10 = command slot 0/1/2**（`BattleRuntime.FiringSlotOf`）。
- **★「←/→ が この 3 本の どれを選ぶか」は 私の推測であって RE ではない★** ⇒ **◆前提つき◆**。
  ⇒ **最小実装は ★index を 0..2 で回して 表示するだけ★** にし、**★その index が戦闘に効く配線は (a)/(b) と繋がってから★**。
- **pad の bit ↔ ボタン対応は 未検証**（closeout (c) の 3 つ目の札）。**remake は Unity の key を直接読むので この未検証には触れない**
  （**＝ 原盤の pad 配線を再現しているとは 書かない**）。

### 4-3 ★逃走の入力は 作らない★

**`result 0` / `result −1` の どちらが 逃走で どちらが 敗北かが 未決**（FOUNDATION §7・「観測できるのは −1 の方が罰が重い / 1 だけが勝利処理を持つ」まで）。
⇒ **★入力から「逃げる」を作ると 未決を実装で埋めることになる★** ⇒ **作らない**（札 = 実機 ＋ 材料）。

---

## §5 (d-5) 終了 — 3 値で どう抜けて field に戻るか

### 5-1 ★私が決めるのは「誰が いつ 呼ぶか」まで★（**戻り先の中身は worker1 (b)**）

```
BattleRuntime.Result (-1 / 0 / 1)
   → ★VM の epilogue（§2-3 の RunBattleEpilogue）★ が受ける
   → BattleEntry の既存 API（AdvanceBattleCounter / IBattleStats.Wins / .NotWon）へ
   → ★result 1 のときだけ★ field の rebuild を要求
   → EmitPage(); State = Finished;   // ★現行と同じ idle_stop に合流★
```

### 5-2 ★3 値ごとの 描画側の帰結（★ここが (d) の担当★）★

| result | field をどうするか | 出所 | 札 |
|---|---|---|---|
| **1** | **★map を再読込する★**（同 map id・原盤は `0x800A46DC` / remake は **既存の `FieldManager.HandleMapLoaded` → `BuildField`** に載せる）＋ 注視点を主人公へ ＋ transition(+1) ＋ **勝利数 +1** | FOUNDATION §7 | — |
| **0** | **★再読込しない★**（原盤は `transition_begin` を呼びもしない＝**状態は前のまま**）⇒ **戦闘面を閉じて `InputLocked` を戻すだけ** | FOUNDATION §7 | — |
| **−1** | **★再読込しない★** ＋ 遷移状態 clear | FOUNDATION §7 | — |

> **★この表が §1-3 の「`GameFlow` の state にしない」理由の実体★** =
> **`0` / `−1` は ★戦闘前の field が そのまま生きていること★ を要求する** ⇒ **★戦闘中に field を teardown しない★**
> （**`FieldManager.cs:556 TeardownField` を 戦闘の入口/出口で 呼ばない**）。

### 5-3 ★再現しないと決めたもの（札つき）★

- **敗北/逃走 flag（`gp-0x6d84` = `IBattleStats.NotWon`）を読む側**（原盤 `0x800E1680`）が **どこかで map 再読込を起こす**のは
  **★構造上の要請として示されているが、どの site が起こすかは未決★**（FOUNDATION §7）。
  ⇒ **★本 slice では 再現しない★**（**flag は立てる・その先は繋がない**）。**札 = 実機 ＋ 材料。**
- **`−1` と `0` の意味（敗北 / 逃走）** ⇒ **★3 値のまま持ち回り、画面にも `-1 / 0 / 1` と出す★**（**名前を当てない**）。**札 = 実機。**

---

## §6 札の一覧（★推測で埋めていない所★）

| # | 埋まっていないもの | 札 | 影響範囲（★被害が閉じているか★） |
|---|---|---|---|
| D-1 | **原盤 battle loop の 1 frame の実時間**（1/60 か 1/30 か・実効は落ちるか） | **実機** | **戦闘の速さだけ**。定数 1 本に隔離 |
| D-2 | **drain（`f_80102F1C`）の呼び出し周期** | **材料**（呼び手側 未読） | **バーの減る速さだけ**（★勝敗は判定式が独立に決める★・§3-3） |
| D-3 | **戦闘中に game-clock が進むか** | **実機** | 既存 `InputLocked` gate の再利用から落ちる挙動＝**確かめた挙動ではない**（§2-5） |
| D-4 | **←/→ が どの命令 slot を選ぶか** | **材料 ＋ 実機** | index を回して表示するだけ＝**戦闘に効かせない**（§4-2） |
| D-5 | **`−1` と `0` の意味** | **実機** | 3 値のまま出す（§5-3） |
| D-6 | **`result 0 / −1` 後の map 再読込 site** | **実機 ＋ 材料** | 再現しない（§5-3） |
| D-7 | **原盤の battle 画面の構図** | **材料**（静止画/動画が手元に 0 件） | **§3 の (β) 全部**。`BattleView` 1 file に閉じる |
| D-8 | **技発動 / 接近 / ターゲット選択の中身** | **材料**（worker1 step⑥ 以降） | **(d) の外**。ただし **P0-2（距離が動く）は 接近が入るまで 見た目が静止する**（下記 §7-2） |

---

## §7 他 track への申し送り（★私が読んで 気づいたこと 3 件★）

### 7-1 ★`IsPartnerDown()` の index を もう一度 確かめてほしい（worker1 (a)/(b)）★

`track1/battle-slice-impl` の `BattleRuntime.cs`:
- `:89` 註 = **「終了判定 = ★partner（actor[1]）が倒れたか★」** ／ 実装 `:96-100` も **`_actors[1].IsDown()`**
- 一方 同 file `:181`（`ApplyEntryStats` の註）= **「★index 0 は 6 欄コピーを飛ばす（味方は別経路 `f_801162B0`）★」** ＝ **index 0 が味方**

⇒ **★「partner」を 味方の意味で読むと index が 1 つずれる★**。**私は btl_rel の loop 先頭を自分で読んでいないので どちらが正しいかは書かない**
（**★これは指摘であって 判定ではない★**）。**(d) には効く** = **「倒れたら勝ちなのか負けなのか」が 画面の決着表示に直結する**。

### 7-2 ★P0-2 は 接近（D-8）が入るまで 静止画になる★

**現 `BattleRuntime.Tick()` に 位置も移動も無い**（接近 3 分岐は STUB）。
⇒ **★「2 体が近づく」は (d) だけでは 出せない★**。**(d) 側は「距離を読んで描く」までを用意し、★距離が動かない間は それが判る印字を出す★**
（**★動いていないものを 動いているように描かない★**）。

### 7-3 ★FOUNDATION §8.51 の 本文が 訂正前のまま残っている（boss1 へ）★

`BATTLE_SLICE_RE_FOUNDATION_2026-08-26.md` の §8.51 は、**冒頭の引用 block で「HP は減らない は誤り」と訂正**しているのに、
**その直下の本文に ★「`h4C` を減らす code は両 blob に存在しない」「`h4C` = 戦闘中 不変の上限」★ が そのまま残っている**（`:423` / `:426`）。
**`track1` の `BattleActor.cs:194-204` は #914-A で ★同じ番地を `base = actor+0x38` の offset `0x14` で書いていた★ と決着済**。
⇒ **★頭に訂正を足しても 本文は古いまま読まれる★**（`[[feedback_prepended_correction_leaves_body_claims]]`）。
**★doc の書き換えは boss1 の領域ゆえ 私は触っていない★**（**指摘のみ**）。

---

## §8 (a)(b)(c)(e) との境界（重ならないように）

| 私が決めた（(d)） | 私が決めていない（他） |
|---|---|
| **誰が 戦闘 1 frame を回すか**（VM の中・固定 step） | **actor 2 体を どう組むか**（stat の積み方・敵の選び方）= **(a)** |
| **VM の park / resume の形**（第 3 の exit・再入 guard） | **3 値を受けた後の 戦績・flag・map 復帰の中身** = **(b)** |
| **何を描くか / 描かないか と その優先順** | **技の効果の裁定（mini-VM か hand-expand か）** = **(c)/(e)** |
| **入力の最小（←/→ の 2 キー）** | **命令 index が 戦闘に効く配線** = **(a)/(b) と繋がってから** |
| **戦闘中に field を teardown しない という制約**（§5-2 から導出） | **その制約を満たす実装の割り当て** = **boss1 の統合** |

---

## §9 不変（本 doc の作業で 破っていないこと）

- **code 0 行**（`unity/` 以下を 1 file も編集していない）／**worktree を作っていない**／**凍結 3 本に触っていない**
- **main 未変更**／**push しない**／**実機に接続していない**
- **`DEGIMON_BATTLE_SLICE` 既定 OFF 維持**（§2-3 の擬似コードは **gate ON の枝の中だけ**を足す形）
- **完成 claim 凍結** — **本 doc は 1 行も「動いた」と書いていない**（**★私は GUI の視覚 verify ができない★**）
