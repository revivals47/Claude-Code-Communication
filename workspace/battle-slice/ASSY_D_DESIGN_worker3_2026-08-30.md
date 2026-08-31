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

---
---

# 【追記】(d) ★実装 draft★（worker3・2026-08-30・便 #929-W3a 受領後）

> **★これは doc の中の code です。tree には 1 行も入れていません★**（**書き手は今 worker1・同一 tree の同時編集は禁止**）。
> **★compile していません★**（**Unity は同時に 1 つ・回す前に boss1 へ ack**）。**⇒ 本節の code は ★未検証★。**
> **従う設計** = `ASSY_DESIGN_INTEGRATED_2026-08-30.md` **§11（PRESIDENT #928-B 承認）**。**§11 と食い違ったら §11 が勝つ。**
> **★行番号は書かない★**（§11 の規範）。**参照は 関数名 / 定数名 で行い、位置が要るときは その場で `grep -n`。**

## D-A. 前提（★この draft が乗る base★）

| | |
|---|---|
| 器 | `/home/ken/Desktop/Digimon/degimon_world_remake-assy`（branch `track1/battle-assembly`・base **`ea600ab5`**） |
| 読んだ形 | **`git show ea600ab5:<path>`**（**worktree には入っていない**） |
| **前置き** | **★worker1 の step 1（counter 単一権威 ＋ session lifecycle）／step 2（index の直し）が 先に入る★** ⇒ **本 draft は ★その後★ に乗る** |
| 私が触る file | **新規 2**（`BattleSession.cs` / `BattleView.cs`）＋ **変更 2**（`DialogueRuntime.cs` の `0x66` case ／ `TextboxView.cs` の stall 診断 1 箇所） |
| 触らない | `BattleRuntime.cs` / `BattleActor.cs` / `BattleFormulas.cs` / `BattleEntry.cs`（**step 1-2 の担当**）・`FieldManager.cs` |

---

## D-B. ★★実装前に 1 件 足します — park 再入が汚すのは `E12C` だけではありません★★

**§11-5 は「guard を counter 加算より後に置くと counter が毎 frame 進む」と書いています。**
**★同じことが seam の観測器にも起きます★**（**§11 に無い・私が `0x66` case を読んで見つけました**）:

```
case OP_SCENE_DRIVER:
    BattleEntry.SeamReachCount++;                              // ← ★park 再入で 毎 frame 進む★
    BattleEntry.SeamHitLog.Add((_pc << 8) | ReadByte(_pc+1));  // ← ★static List が 毎 frame 伸びる★
    if (BattleEntry.GateEnabled) { BattleEntry.SeamGatedCount++; … }
```

- **`SeamReachCount` / `SeamGatedCount`** は **census が「1 回 / launch」であることを支えている数**
  ⇒ **park 中に進むと ★到達回数の意味が壊れる★**（**戦闘 600 frame = 到達 600 回に見える**）。
- **`SeamHitLog` は `static readonly List<int>`** ⇒ **★同じ `(pc, operand)` が数百件 積まれる★**
  （**doc に「間引かない＝延べで持つ」と書いてある器なので、読む側は これを 到達の延べと読む**）。**memory も伸びる。**
- ⇒ **★再入 guard は `case` の ★最初の 1 行★（`SeamReachCount++` より ★上★）に置く★**。
  **★これは「counter の 1 箇所化」（§11-2）とは別の穴です★** — **§11-2 は `E12C` の話で、seam counter は別の器。**

> **★格★** = **これは code を読んで書いた指摘**（`git show ea600ab5:…DialogueRuntime.cs` の `0x66` case 冒頭）。
> **★走らせて確かめてはいません★**（**park を実装していないので当然です**）⇒ **verify 項目に入れた**（D-G の V4）。

---

## D-C. 新規 ① `Battle/BattleSession.cs`（★UnityEngine 非依存★）

**役割** = **戦闘 1 回ぶんの器**。**`DialogueRuntime` が持ち、`BattleView` が read-only で覗く。**
**★`UnityEngine` を参照しない★**（**= headless harness がそのまま回せる・`BattleRuntime` の性質を壊さない**）。

```csharp
// BattleSession.cs — 戦闘 1 回の session（park 中の state・固定 step・強制 damage 経路）。
// ★UnityEngine 非依存★（dt は呼び手が渡す = Editor harness は 1/60 を pin できる）。
using System;

namespace DigimonWorld.Battle
{
    /// <summary>戦闘 session の終わり方。★「終わらなかった」を「終わった」に畳まない★（3 値ではなく 4 値で返す）。</summary>
    public enum BattleExit { Running, Completed, AbortedFrameCap, AbortedInvariant }

    public sealed class BattleSession
    {
        /// <summary>今走っている session（無ければ null）。★BattleView はこれだけを見る★。</summary>
        public static BattleSession Current;

        /// <summary>★原盤 1 frame の実時間は未検証★（札 D-1）。ここを 1 定数に隔離する。</summary>
        public const float FrameSeconds = 1f / 60f;

        /// <summary>1 回の Advance で進める上限（spiral 防止）。★頭打ちは黙って捨てない★（DroppedSteps）。</summary>
        public const int MaxStepsPerAdvance = 4;

        /// <summary>戦闘の上限 frame。★超えたら loud に落とす★（§11-8）。</summary>
        public const int FrameCap = 60 * 60;   // 1 分相当（FrameSeconds が未検証ゆえ「分」とは書かない）

        public readonly BattleRuntime Runtime;
        public readonly BattleActor Ally;     // ★空間 A の index 0★（§9）
        public readonly BattleActor Enemy;    // ★空間 A の index 1★
        public readonly bool GateSnapshot;    // ★session 開始時に snapshot★（§11-1・途中 OFF で park が解けない）

        public BattleExit Exit { get; private set; }
        public BattleResultCode Result { get; private set; }
        public int DroppedSteps { get; private set; }      // ★頭打ちで捨てた step 数（0 でも印字する）★
        public int LastDamage { get; private set; }        // 画面に出す 1 発（P0-4）
        public int CommandIndex { get; private set; }      // ←/→ で回る 0..2（★戦闘には効かせない★・§D-E）

        float _accum;

        public BattleSession(BattleRuntime rt, BattleActor ally, BattleActor enemy, bool gateSnapshot)
        {
            if (rt == null) throw new ArgumentNullException("rt");
            if (ally == null || enemy == null) throw new ArgumentNullException("actors");
            Runtime = rt; Ally = ally; Enemy = enemy; GateSnapshot = gateSnapshot;
            Exit = BattleExit.Running;
        }

        public void MoveCommand(int delta)
        {
            CommandIndex = ((CommandIndex + delta) % 3 + 3) % 3;
        }

        /// <summary>実時間 dt を渡す。★戦闘 frame は固定 step で刻む★。戻り = まだ続くか。</summary>
        public bool Advance(float dt)
        {
            if (Exit != BattleExit.Running) return false;
            _accum += dt;
            int steps = 0;
            while (_accum >= FrameSeconds)
            {
                if (steps >= MaxStepsPerAdvance)
                {
                    int dropped = (int)(_accum / FrameSeconds);
                    DroppedSteps += dropped;
                    _accum = 0f;
                    BattleLog.Warn($"[BATTLE] step 頭打ち: この Advance で {dropped} step 捨てた（累計 {DroppedSteps}）★戦闘は遅くなる・黙って落としていない★");
                    break;
                }
                _accum -= FrameSeconds;
                steps++;
                if (!StepOneFrame()) return false;
            }
            return true;
        }

        bool StepOneFrame()
        {
            // ★★slice-only の強制 damage 経路（§11-8）★★
            //   ★原盤の発動 path（接近 → ターゲット選択 → 技発動）は STUB★ ゆえ、
            //   ★これを入れないと 誰の HP も減らず 戦闘が終わらない★（codex C・boss1 CONFIRMED）。
            //   ★これは「原盤の再現」ではない★ = ★差替可 ＋ 札（材料: 発動 path 未 RE）★。
            if (Runtime.Frame > 0 && Runtime.Frame % ForcedHitPeriodFrames == 0)
                ForcedHit();

            bool cont = Runtime.Tick();

            // ★表示側の HP を進める（drain）★。★実効値は変えない = 勝敗に影響しない★（§3-3）。
            Ally.DrainDamage();
            Enemy.DrainDamage();

            if (!cont)
            {
                Exit = BattleExit.Completed;
                Result = ResolveResult();
                return false;
            }
            if (Runtime.Frame >= FrameCap)
            {
                Exit = BattleExit.AbortedFrameCap;
                BattleLog.Warn($"[BATTLE] ★上限 frame {FrameCap} に到達＝戦闘が終わらなかった★（Result は書かない・abort として扱う）");
                return false;
            }
            return true;
        }

        /// <summary>★§11-7: Zero 固定にしない★ — §9 の写像（味方 +0x4C == 0 なら −1・そうでなければ 1）。</summary>
        BattleResultCode ResolveResult()
        {
            // ★0（逃走）は 入力を作らないので 本 phase では発生しない★ ⇒ ★0 が出たら bug★（§11-7）。
            // ★enum の実名を 器で確認済★ = BattleResultCode { Minus1 = -1, Zero = 0, Win = 1 }（BattleActor.cs）。
            return Ally.Hp4C == 0 ? BattleResultCode.Minus1 : BattleResultCode.Win;
            // ★Zero（逃走）を返す経路は 本 phase に無い★ ⇒ Zero が出たら bug（§11-7）。
        }
    }
}
```

> **★`ForcedHit()` / `ForcedHitPeriodFrames` / `BattleLog` は D-F で定義する。★**
> **★`BattleLog` を別に立てる理由★** = **`BattleSession` を `UnityEngine` 非依存に保つため**
> （**`Debug.Log` を直接呼ぶと headless harness で `UnityEngine` に依存する**）。**`BattleLog` は 1 行の薄い口。**

---

## D-D. 変更 ① `DialogueRuntime` の `0x66` case（★park / resume★）

```csharp
case OP_SCENE_DRIVER:
{
    // ═══ (0) ★park 再入 guard = case の最初の 1 行★（D-B: seam counter より ★上★）═══
    if (_battle != null)
    {
        // ★invariant 2（§11-3 ①）を park 中も毎 tick 見る★:
        //   Tick() は state 判定より前に PumpWarpPending() を実行するので、park 中に pending が立つと map change が emit され得る。
        if (_gameState.WarpPendingTag != 0)
        {
            BattleAbort($"park 中に warp pending が立った（tag={_gameState.WarpPendingTag}）");   // ★loud + teardown★
            EmitPage(); State = DialogueState.Finished; return;
        }

        float dt = BattleDtOverrideForVerify ?? UnityEngine.Time.deltaTime;   // ★harness は 1/60 を pin できる★
        if (_battle.Advance(dt))
            return;                       // ★★park: State=Running のまま・_pc は 0x66 のまま★★

        // ═══ 完了 tick = ★epilogue が B2〜B6 を置換する（通さない）★（§11-3 ②）═══
        RunBattleEpilogue(_battle);       // 3 値の適用 ＋ teardown（原子的・§11-1）
        _battle = null; BattleSession.Current = null;
        EmitPage(); State = DialogueState.Finished; return;   // ★現行 0x66 と同じ exit（idle_stop）に合流★
    }

    // ═══ 以降 = ★初回進入のみ★（park 中は上で return 済ゆえ 1 launch に 1 回）═══
    BattleEntry.SeamReachCount++;                                   // ★意味が保たれる（1 回/launch）★
    BattleEntry.SeamHitLog.Add((_pc << 8) | ReadByte(_pc + 1));
    if (BattleEntry.GateEnabled)
    {
        BattleEntry.SeamGatedCount++;
        // ★invariant 1（§11-3 ①）= 戦闘開始時に warp pending 不在★
        if (_gameState.WarpPendingTag != 0)
        {
            Debug.LogError($"[BATTLE] ★戦闘に入れない: warp pending が在る（tag={_gameState.WarpPendingTag}）★ → 戦闘を起こさず seam のみで抜ける @pc=0x{_pc:X}");
            // ★退路を true で返さない★: 戦闘は起こさない・counter も進めない・log は loud。
        }
        else
        {
            // ★counter は step 1 の単一権威（RawE12C）を ★ここで 1 回だけ★ 進める（§11-2）★
            //   ※ 実際の呼び名は step 1 完了後に grep して合わせる（AdvanceBattleCounter は外れる予定）。
            bool saturated = _gameState.SceneDriverCounterInc();
            if (saturated) Debug.LogWarning("[BATTLE] 戦闘回数 counter 飽和（9999）");

            _battle = BeginBattle();                 // ★_battle == null の時だけ作る（§11-1）★
            BattleSession.Current = _battle;
            Debug.Log($"[BATTLE] session 開始 @pc=0x{_pc:X} gate=snapshot({_battle.GateSnapshot}) ★park に入る（State=Running / _pc 据え置き）★");
            return;                                   // ★park 開始★
        }
    }
    if (!_sceneDriver) break;    // ★以降 現行のまま（B1..B6 → idle_stop）★
    …
}
```

### D-D-1 ★`0x67` を前例として引くときの書き分け（§11-5・そのまま守る）★

| | `0x67` frame-yield | **battle park** |
|---|---|---|
| `State` | **`Running` を保つ** | **同じ（`Running` を保つ）** |
| `_pc` | **`_pc += len` してから `return`**（次の op へ進む） | **★据え置き（`0x66` のまま）★** ⇒ **毎 tick 同じ case に再入する** |
| 帰結 | 次 tick は **次の op** から | **★再入 guard の位置が効く★**（D-B / §11-5） |

### D-D-2 ★失敗形（前回の 4 つ ＋ 今回足した 2 つ）★

1. **guard を `E12C` 加算より後** → **counter が毎 frame 進む**（§11-5）
2. **`Finished` にする** → **`FieldState` の `OnFinished` 経路で `InputLocked=false`** = **戦闘中に player が歩く**
3. **`_pc` を前進させる** → 次 tick に **`0x66` の次の op を実行**
4. **`WaitingFrames` を流用** → `Tick()` 冒頭で **勝手に `Running` へ戻る**
5. **★新★ guard を `SeamReachCount++` より後** → **到達 census と `SeamHitLog` が汚れる**（D-B）
6. **★新★ `GateEnabled` を park 中に毎回読む** → **途中で env が変われば park が解ける**（§11-1・**snapshot で防ぐ**）

---

## D-E. 新規 ② `Battle/BattleView.cs`（★MonoBehaviour は これ 1 本だけ★）

```csharp
// BattleView.cs — 戦闘の描画と入力。★logic は持たない（BattleSession を read-only で覗くだけ）★。
// ★生成は DEGIMON_BATTLE_SLICE=1 のときだけ★（未設定なら component すら作らない = OFF-inert 最強）。
using UnityEngine;

namespace DigimonWorld.Battle
{
    public sealed class BattleView : MonoBehaviour
    {
        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]
        static void Bootstrap()
        {
            if (System.Environment.GetEnvironmentVariable(BattleEntry.GateEnv) != "1") return;   // ★退路 = 完全 no-op★
            var go = new GameObject("[BattleView]");
            DontDestroyOnLoad(go);
            go.AddComponent<BattleView>();
        }

        void Update()
        {
            var s = BattleSession.Current;
            if (s == null) return;
            // ★★←/→ を戦闘中に読むのは ここだけ（§11-6 = 入力の所有）★★。TextboxView は読まない。
            if (Input.GetKeyDown(KeyCode.LeftArrow))  s.MoveCommand(-1);
            if (Input.GetKeyDown(KeyCode.RightArrow)) s.MoveCommand(+1);
        }

        void OnGUI()
        {
            var s = BattleSession.Current;
            if (s == null) return;
            GUI.depth = -100;   // ★textbox より前面（IMGUI は 低い depth が上）★ ← ★視覚 verify は user★

            // P0-1 画面占有（field は描かれ続けるので 覆う側が要る）
            GUI.Box(new Rect(0, 0, Screen.width, Screen.height), GUIContent.none);

            // P0-2 2 体と ★水平距離★（原盤の接近は dx²+dz²・Y 未使用）
            //   ★接近は STUB ゆえ 距離は動かない★ ⇒ ★動かないことを 画面に書く（動いていないものを動いて見せない）★
            GUI.Label(new Rect(20, 40, 600, 20), $"距離(水平) = {DistanceLabel(s)}");

            // P0-3 HP を ★2 値★（表示 = Hp4C は drain で段階減／判定 = Hp4C − DamageAccum2E は即時）
            DrawActor(new Rect(20,  80, 400, 60), "味方(index 0)", s.Ally);
            DrawActor(new Rect(20, 160, 400, 60), "敵  (index 1)", s.Enemy);

            // P0-4 damage 数値（★live 確定している唯一の量★）
            GUI.Label(new Rect(20, 240, 600, 20), $"直近 damage = {s.LastDamage}");

            // P1-5 指示（★戦闘には効かせていない＝表示だけ★・§D-E-1）
            GUI.Label(new Rect(20, 280, 600, 20), $"指示 index = {s.CommandIndex} / 3 ★表示のみ（戦闘に効かせていない・札 D-4）★");

            // P1-6 決着（★3 値のまま・名前を当てない★）
            if (s.Exit != BattleExit.Running)
                GUI.Label(new Rect(20, 320, 600, 20), $"exit = {s.Exit} / result = {(int)s.Result}（-1 / 0 / 1）");

            GUI.Label(new Rect(20, 360, 900, 20),
                $"frame={s.Runtime.Frame} dropped={s.DroppedSteps} ★構図は原盤の忠実ではない（誰も原盤の画面を見ていない）★");
        }

        static void DrawActor(Rect r, string name, BattleActor a)
        {
            int eff = a.Hp4C - a.DamageAccum2E;
            GUI.Label(new Rect(r.x, r.y, r.width, 20), $"{name}  表示HP={a.Hp4C}（drain で段階減）");
            GUI.Label(new Rect(r.x, r.y + 20, r.width, 20), $"          判定HP={eff}（= Hp4C − pending {a.DamageAccum2E}・★KO は当たった瞬間に決まる★）");
        }

        static string DistanceLabel(BattleSession s)
        {
            // ★位置が実装されていない（接近 STUB）ゆえ 距離は出せない★ — ★0 と書かない★
            return "未実装（接近 path が STUB・札 D-8）";
        }
    }
}
```

### D-E-1 ★`←/→` の所有（§11-6）と 2 つの限定★

- **戦闘中に `←/→` を読むのは `BattleView` だけ**。**`TextboxView` は読まない**（**advance/menu は `State` gate で park 中 inert** = boss1 確認済）。
- **★index は戦闘に効かせない★**（**どの命令 slot を選ぶかは ◆前提つき◆・札 D-4**）⇒ **画面にも「表示のみ」と出す**。
- **`GUI.depth` の値は ★視覚 verify が要る★**（**我々は GUI の見た目を確かめられない**）⇒ **user 実視覚の項目に入れる**。

---

## D-F. ★終了を有限にする（§11-8）★ — 強制 damage 経路 1 本

```csharp
// BattleSession の中（D-C の続き）
/// <summary>強制 hit の周期。★原盤の発動周期ではない★（原盤は h1a == h18 で発動）＝ slice 専用。</summary>
public const int ForcedHitPeriodFrames = 20;

/// <summary>★verify 専用★の向き反転（既定 = live 確定した向き = 敵 → 味方）。</summary>
public static bool ForceAllyAttacksForVerify;

/// <summary>★強制 hit の仮値★（技表 / species 表を asset 化していない・札 D-10）。★log に必ず出す★。</summary>
public int ForcedSkillIndex, ForcedSkillPower, ForcedSkillElement;
public byte ForcedDefAttr0, ForcedDefAttr1, ForcedDefAttr2;

void ForcedHit()
{
    BattleActor atk = ForceAllyAttacksForVerify ? Ally  : Enemy;
    BattleActor def = ForceAllyAttacksForVerify ? Enemy : Ally;

    var inputs = new BattleFormulas.DamageInputs
    {
        SkillIndex   = ForcedSkillIndex,      // ★仮値★（技表を asset 化していない・札）
        SkillPower   = ForcedSkillPower,      // ★仮値★
        SkillElement = ForcedSkillElement,    // ★仮値★
        AtkStat38    = atk.H38,               // ★actor の実 snapshot 値（§1 の決め）★
        DefStat3A    = def.H3A,
        // ★★落とすと 黙って 0,0,0 になる欄（= 属性表の寄与が 別物になる）★★
        //   DamageInputs は DefAttr0/1/2（byte）を持つ。★未設定 = 既定 0 = 「属性 0」として通ってしまう★
        //   ⇒ ★退路を既定値で通さない★（[[feedback_retreat_must_not_encode_as_pass]]）:
        //     species 表を asset 化していないので ★仮値を 明示的に入れ、log にも出す★（札 D-10）。
        DefAttr0 = ForcedDefAttr0, DefAttr1 = ForcedDefAttr1, DefAttr2 = ForcedDefAttr2,   // ★仮値★
        AttackerIsPartner = ForceAllyAttacksForVerify,
    };
    int dmg = BattleFormulas.GetDamagePoint(inputs, Matrix, Rng);
    def.AddDamage(dmg);
    LastDamage = dmg;
    BattleLog.Info($"[BATTLE] ★強制 hit（slice 専用・原盤の発動 path ではない）★ {(ForceAllyAttacksForVerify ? "味方→敵" : "敵→味方")} dmg={dmg} 判定HP={def.Hp4C - def.DamageAccum2E}");
}
```

### D-F-1 ★この経路について 偽らないこと★

- **★これは原盤の発動 path ではありません★** — **接近 / ターゲット選択 / 技発動は STUB**（札 D-8）。
  **入れる理由は 1 つだけ = ★入れないと 誰の HP も減らず 戦闘が終わらない★**（codex C・boss1 CONFIRMED）。
- **`SkillIndex` / `SkillPower` / `SkillElement` は ★仮値★**（**`wazaTbl` を asset 化していない**）
  ⇒ **★画面に出る数値が live と一致しても「技表の配線が正しい」ことにはならない★**（**§1 の stat と同じ型の札**）。
- **★live との突合は 画面ではなく headless test で行う★** = **live sample の入力そのもの**
  （`skill=20 / elem=4 / atk=140 / def=60 / species=3 / attr=[0,255,1]`）を式に入れ、**`329〜402` の帯に入ることを assert**。
  **★画面の数値は 我々の 2 体の stat から出た別の数★** ⇒ **★2 つを混ぜて「live と一致した」と書かない★**。
- **★向きの既定は 敵 → 味方★**（**live で確定した系統 B の向き**）⇒ **最小 slice で通るのは ★`-1`（敗北）の path だけ★**。
  ⇒ **★勝利路（map 再読込 ＋ 勝利数 +1）は 1 度も走らない = 未 exercise★**
  **★★【2026-08-30 撤回（本文差し替え）】★★** — **ここに書いていた「`ForceAllyAttacksForVerify` で verify 時だけ 勝利路を通す」は ★成立しない★。**
  **実測 = ★敵の HP を 0 にしても 戦闘は 終わらない★**（**終了判定は 味方だけ = 原盤 `f_80057C00` の exit arm 1 本しか模していない**）
  ⇒ **★`Win` / `Zero` に至る経路は remake に 無い★**（**詳細 = §D-L-2 / 札 D-11**）。
  **flag 自体は残す**（**敵に damage が届くことの 陽性対照 ＋ 限界を固定する test に使う**）が、**★「勝利路を verify できる」とは 書かない★**。

---

## D-G. 変更 ② `TextboxView` の stall 診断除外（§11-4）

```csharp
// ★park 中は (State, Pc, pages) が不変ゆえ 90 frame で必ず stall log が出る（codex F・boss1 CONFIRMED）★
if (_rt != null && !_rt.IsFinished)
{
    if (DigimonWorld.Battle.BattleSession.Current != null)
    {
        // ★抑止したことが log で判る形にする（黙って消さない）★ — 1 戦につき 1 度だけ。
        if (!_stallSuppressedLogged)
        {
            _stallSuppressedLogged = true;
            Debug.Log("[STALL-DIAG] ★battle-active ゆえ stall 判定を抑止（park 中は State/Pc/pages が不変で当然）★");
        }
        _stallFrames = 0;
    }
    else
    {
        _stallSuppressedLogged = false;
        …（現行のまま）…
    }
}
```

---

## D-H. verify 計画（★headless で取れるものだけを headless と書く★）

| # | 何を | どう | 期待 |
|---|---|---|---|
| **V1** | **gate OFF の不変** | `DEGIMON_BATTLE_SLICE` 未設定で `BattleSeamVerify66` | **GREEN（現行と同じ）**・**`BattleView` の component が ★生成されない★** |
| **V2** | **baseline 3 値が動かないこと** | `CutsceneVerify178`（**この base では ★RED★**） | **`pages 0/66` / `chars 0/1601` / `termPc 0x1A/0x1315` が ★bit 同一★**。**★動いたら battle 起因★** |
| **V3** | **1 戦が有限で終わる** | **Editor harness で `rt.Tick()` を回すだけ**（`BattleDtOverrideForVerify = 1/60` を pin） | **`Exit == Completed`**・**`Result != Zero`**・**`Frame < FrameCap`** |
| **V4** | **★park 再入が観測器を汚さない（D-B）★** | 同 harness で **1 戦の前後の `SeamReachCount` / `SeamHitLog.Count` の差** | **★差 = 1★**（**戦闘 frame 数ではない**） |
| **V5** | **counter が 1 回だけ進む（§11-2）** | 同 harness で `RawE12C` の前後差 | **★差 = 1★** |
| **V6** | **damage の live 突合** | **live sample の入力を式に入れる**（**画面の数ではない**） | **`329〜402` に入る** |
| **V7** | ~~勝利路が通ること~~ **★撤回★ → ★勝利 arm が 無いことを 固定する★** | `ForceAllyAttacksForVerify = true` の harness run | **敵 HP 0 ＋ ★終わらない★ ＋ ★結果を書かない★**（**実測で 差し替え・§D-L-2**） |
| **V8** | **見た目**（P0 の 4 件が画面に出ている / `GUI.depth` が効いている / 文字が読める） | **★user 実視覚★** | **★我々には確かめられない★**（**完成 claim 凍結**） |

---

## D-I. 小 commit の刻み（★broken-state-zero★）

| # | commit | 単体で緑か |
|---|---|---|
| **0** | **★閉じた claim の 札を 直す（文だけ・値は変えない）★ = D-K の 5 箇所 ＋ 任意 3 行**。**★着手時に grep を再走してから★**（**古い census で直しに行かない**） | **緑**（**comment のみ ⇒ 挙動 bit 不変**） |
| 1 | `BattleSession.cs` 追加（**誰も呼ばない**） | **緑**（compile のみ・挙動不変） |
| 2 | `BattleView.cs` 追加（**`Current` が常に null ゆえ 完全 inert**） | **緑**（V1） |
| 3 | `0x66` case に **park guard ＋ session 開始**（**gate ON でだけ動く**） | **緑**（V1 / V2 / V4 / V5） |
| 4 | **強制 damage 経路 ＋ 上限 frame**（§11-8） | **緑**（V3 / V6） |
| 5 | `TextboxView` の stall 除外（§11-4） | **緑**（V2 再走） |
| 6 | `ForceAllyAttacksForVerify` の harness（**★V7 は 撤回 → 限界を固定する test★**） | **緑**（harness D3） |

**★各 commit の後で 1 度ずつ verify を回す★**（**Unity は同時に 1 つ ⇒ ★回す前に boss1 へ ack★**）。

---

## D-J. 札の更新

| # | 札 | 状態 |
|---|---|---|
| D-1 原盤 1 frame の実時間 | **実機** | **未閉**（`BattleSession.FrameSeconds` 1 定数に隔離） |
| D-2 drain の呼び出し周期 | **材料** | **未閉**（**毎 frame 1 回を仮置き**・**勝敗には影響しない**） |
| D-3 戦闘中の game-clock | **実機** | **未閉**（`InputLocked` gate の再利用から落ちる挙動） |
| D-4 `←/→` の意味 | **材料 ＋ 実機** | **未閉**（**表示のみ・戦闘に効かせない**） |
| D-5 `-1` と `0` の別 | — | **★閉じた★**（§9・`-1` 敗北 / `0` 逃走 / `1` 勝利） |
| D-6 `0`・`-1` 後の map 再読込 site | **実機 ＋ 材料** | **未閉**（**再現しない**） |
| D-7 原盤の battle 画面 | **材料** | **未閉**（**構図の忠実を主張しない**） |
| D-8 技発動 / 接近の中身 | **材料** | **未閉**（**強制 hit で迂回・距離は「未実装」と画面に書く**） |
| **D-9（新）** | **材料** | **★teardown の口を全列挙していない★** — 私が知っているのは **正常完了 / frame cap / invariant 違反 / `BattleView.OnDisable`** の 4 口。**`FieldState.Exit` など flow 側の口は数えていない**（`[[feedback_retreat_entry_points_and_compat_fold]]`） |
| **D-10（新）** | **材料** | **強制 hit の `SkillIndex/Power/Element` ＋ `DefAttr0/1/2` は仮値**（技表・species 表を asset 化していない）。★`DefAttr` は 未設定だと 黙って `0` になる欄★ ⇒ **明示代入 ＋ log** |


---

## D-K. ★閉じた claim の 札が code に 残っている箇所（census・便 #929-W3b/W3c）★

> **★枠（1 行）★** = **`ea600ab5` の `unity/**/*.cs` ★全数★ を grep・**該当は `Battle/` に ★5 件★**・**`md` / doc 側は数えていない**。
> **★boss1 が独立の grep で 全 5 件 一致（逐語）★**。**tip（`track1/battle-assembly`）は worker1 が動かしている ⇒ ★直す瞬間に再走する★。**

**閉じた claim** = **§9 で `-1` = 敗北 / `0` = 逃走 / `1` = 勝利 が確定した**（worker1 の逐語 ＋ field 側 penalty の大きさで独立に一致）。

### 直す（5 件・★値は変えない・文だけ★）

| # | 場所 | 今の文 | どう直すか |
|---|---|---|---|
| 1 | `Battle/BattleActor.cs:52` | enum summary「`−1` と `0` のどちらが逃走でどちらが敗北かは未決」 | **§9 の確定に差し替え** |
| 2 | `Battle/BattleEntry.cs:163` | `ApplyResult` doc・同文 | **同上** |
| 3 | `Battle/BattleEntry.cs:165` | care 未配線の **★理由★** =「未決ゆえ 3 分岐に割り当てられない」 | **★消さない = 理由の差し替え★**（下記） |
| 4 | `Battle/BattleEntry.cs:190` | `RunToCompletion` の札「／実機（`−1` と `0` の別）」 | **札から その 1 項を外す**（**他の札は残す**） |
| 5 | `Battle/BattleRuntime.cs:116` | `Result = Zero` 固定 STUB の同じ札 | **同上**（**§11-7 の直しと同じ箇所ゆえ 同じ commit で**） |

### ★#3 は 消すと 意味が 反転する★

- **§9 が閉じたのは「どちらが敗北か」であって ★「罰を配線してよいか」ではない★**（統合 doc §9 の但し書き）。
- **★「未決ゆえ配線しない」を ただ消すと、次の人は「決まったのだから配線してよい」と読む★。**
- **書き換え先（そのまま使う）** =
  **「`-1` = 敗北 / `0` = 逃走 は §9 で確定。★但し care 増減は 本 phase では配線しない（別の理由）★。
    配線するときは必ず `ClampCare` を通す = `0x80141D42` は `−100..+100`（0 下限にしない）」**
- **★これは boss1 の依頼文（「文だけ差し替え」）を そのまま実行すると 壊れる 1 件★** — **boss1 も同意（便 #929-W3c ■2）。**

### 直さない（★grep に掛かるが 誤りではない★）

- **`Battle/BattleEntry.cs:35`**「`result −1` と `0` で 1・勝利で 0」= **`NotWon` の説明として そのまま正しい**
  （**どちらが敗北かに依らない**）⇒ **★直しすぎない★**。

### 任意（★値は変えない・文だけ★・boss1 承認）

- enum の member 3 行（`Minus1` / `Zero` / `Win`）は **field 側の効果しか書いていない**
  ⇒ **`Minus1` = 敗北 / `Zero` = 逃走 / `Win` = 勝利 を 1 語ずつ足す**。
- **★但し 格を code 側にも残す★** = **「`味方 +0x4C == 0` が敗北」は ★1 段の推論★**
  （**「HP 0 = 負け」は逐語に無い**・worker1 の申告どおり）。**★逐語と推論を 同じ強さで書かない★。**

### ★母数の記録（boss1 の grep・私は挙げなかったもの）★

**boss1 の独立 grep には 他に 4 件 掛かった** = `DialogueRuntime.cs:100` / `W1GateCensus.cs:49` / `EntityPlacer.cs:137` / `GameState.cs:641`。
**これらは ★別の主題の「未決」★**（handler 名 / flag id / 対の総数）⇒ **本 census の対象外**（**boss1 も同判定**）。
⇒ **★「5 件」は `Battle/` の中の数であって、`unity/` 全体でも EXE 全体でもない★。**

---

# 【実装】(d) = ★-assy3 で land 済（3 commit）★ ＋ ★patch spec 2 件★（worker3・2026-08-30・便 #929-W3d）

## D-L. 実装した所（★私の tree = `degimon_world_remake-assy3` / branch `track3/battle-view` / base `a88ac2dd`★）

| commit | 何 | verify |
|---|---|---|
| `d8ebf374` | **段 0 = 閉じた claim の札を差し替え（comment のみ）** | **diff は comment 行のみ（非 comment の +/- = 0 行を機械確認）** ／ `run_step6b.sh` **GREEN** |
| `437791d3` | **`BattleSession` の loop 部**（固定 step / 強制 hit / 決着 / `Current`）＋ **harness 9 本** | **`run_step_d.sh` = GREEN (0 fail)** ／ 非退行 `run_step5.sh` `run_step6b.sh` **GREEN** |
| `5a02c1fe` | **`BattleView.cs`**（**MonoBehaviour はこの 1 本だけ**） | **`compile_gate.sh` = GATE=GREEN**・**CONTROL=OK**（陽性対照が赤）・**TREE=OK**（別 tree を見ていない） |

**★器 = `mcs` / `mono` / `csc` のみ。★Unity Editor は 1 度も起動していない★。**

### D-L-1 ★段 0 で 分かったこと（census 再走の効き目）★

**着手時に census を再走したら ★5 件のうち 2 件は step2 で既に直っていた★**（`BattleEntry:190` / `BattleRuntime:116`）
⇒ **残り 3 件だけを直した**。**★古い census で直しに行かない★ が 実際に効いた 1 例。**

### D-L-2 ★★実測で 予想が外れた 1 件（★勝利路は 通せない★）★★

**D-F-1 で「`ForceAllyAttacksForVerify` で verify 時だけ 勝利路を通す」と書いたが、★通らなかった★。**

- **`BattleRuntime.Tick()` の終了判定は ★味方が倒れたか だけ★**（`IsAllyDown`）＝ **原盤 `f_80057C00` の ★exit arm 1 本★しか模していない**。
- ⇒ **★敵の HP を 0 にしても 戦闘は 終わらない★**（**実測 = 敵 HP 0・frame は上限 3600 まで回り `Aborted`**）。
- ⇒ **★`Win` / `Zero` に至る経路は remake に 無い★** = **§11-7 の「KO を `-1` か `1` に写す」の ★`1` の側は 未到達★**。
- **やったこと** = **harness の D3 を「勝利路が通る」から ★現状の限界を固定する test★ に変えた**
  （**敵 HP 0 ＋ 終わらない ＋ 結果を書かない** を assert）。**★勝利 arm を読んで模した人が この test を書き換える★**（札 = 材料）。
- **★発明していない★** = **それらしい「敵が倒れたら勝ち」を足していない**（**原盤の arm を 読んでいないので**）。

## D-M. ★patch spec★（★私が触らない 2 file★・適用は worker1 か boss1）

> **★行番号ではなく 逐語の anchor で書く★**（§11 の規範）。**適用時に `grep -n` で位置を出すこと。**

### P-1. `DialogueRuntime.cs` — `case OP_SCENE_DRIVER` の **park 枝**（★2 行★）

**現状（逐語）**:
```csharp
                        if (_battle != null)
                        {
                            _battle.ParkTicks++;
                            if (!_battle.ShouldEndNow)
                                return;   // ★park 継続 = _pc を 0x66 に据え置いて この tick を終える（State=Running 維持）★
                            EndBattleAtomic(DigimonWorld.Battle.BattleEndKind.StubNoBattle);
                            break;        // ★0x66 の実行を 終える★ = post-switch で _pc += len(=2)
                        }
```
**適用後**:
```csharp
                        if (_battle != null)
                        {
                            _battle.ParkTicks++;
                            _battle.Advance(BattleDtOverrideForVerify ?? UnityEngine.Time.deltaTime);   // ★追加★
                            if (!_battle.ShouldEndNow)
                                return;
                            EndBattleAtomic(_battle.ExitKind);   // ★StubNoBattle 固定 → session が決めた 4 値★
                            break;
                        }
```
- **`BattleDtOverrideForVerify`** = **`static float?`（既定 null）**。**harness が `1f/60f` を pin して ★1 tick = 1 battle frame★ にするため。**
- **★順序の依存（大事）★** = **この 2 行を入れる commit には ★結果適用（下の P-2）も 同じ commit で★ 入れること。**
  **理由** = **`Advance` を繋いだ瞬間 `ExitKind` が `Decided` を返し得る** ⇒ **現行の `EndBattleAtomic` は
  `HasApplicableResult` で ★`NotImplementedException` を投げる★**（step1 の意図的な fail-loud）。**片方だけ入れると 例外で落ちる。**
- **★入れないうちは 何も起きない★** = **`Advance` の呼び手が 0 件のあいだ `ShouldEndNow` は step1 と bit 同一**
  （**harness D1 で固定済**）。

### P-2. `DialogueRuntime.cs` — `EndBattleAtomic` の **(1) 結果の適用**

- **`if (b.HasApplicableResult) throw new NotImplementedException(...)` を ★実際の適用に置き換える★**:
  **`BattleEntry.ApplyResult((int)b.Result.Value, stats)`**（**`stats` の出所 = `IBattleStats` の実装先で、★worker1 の領域★**）。
- **★`Result` が null の kind（`StubNoBattle` / `Aborted`）では 何も適用しない★**（**§11-7 = 「結果が無い」を `0`（逃走）に畳まない**）。
- **(2) view の破棄 = ★足さないでください★** — **`BattleView` は `BattleSession.Current` を見て 自分で消える**
  （**`Current` は `EndKind != Running` になった瞬間 null を返す**）。**★二重の破棄口を作らない★。**
- **(3) 入力 lock = ★足す必要が無い（と 私は読んでいる）★** — **戦闘後 VM は `Finished` に落ち、
  `TextboxView` の `OnFinished` → `FieldState.OnDialogueFinished` が `InputLocked=false` に戻す**。
  **★但し これは code を読んだだけで 走らせていない★**（**park を繋いでいないので当然**）⇒ **★P-1 適用後の run で 確かめること★。**

### P-3. `TextboxView.cs` — stall 診断の **battle-active 除外**（§11-4）

**現状（逐語）**:
```csharp
            if (_rt != null && !_rt.IsFinished)
            {
                if (_rt.State == _lastDiagState && _rt.Pc == _lastDiagPc && _rt.EmittedPages.Count == _lastDiagPages)
                {
                    if (++_stallFrames == 90)
                        Debug.Log($"[STALL-DIAG] 90 frame 停滞: state={_rt.State} pc=0x{_rt.Pc:X} pages={_rt.EmittedPages.Count} speaker={_rt.CurrentSpeaker}");
                }
                else { _stallFrames = 0; _lastDiagState = _rt.State; _lastDiagPc = _rt.Pc; _lastDiagPages = _rt.EmittedPages.Count; }
            }
```
**適用後**（**`_stallSuppressedLogged` を field に 1 本足す**）:
```csharp
            if (_rt != null && !_rt.IsFinished)
            {
                if (_rt.BattleActive)   // ★park 中は (State,Pc,pages) が不変で当然 = 誤検知★（§11-4）
                {
                    if (!_stallSuppressedLogged)
                    {
                        _stallSuppressedLogged = true;
                        Debug.Log("[STALL-DIAG] ★battle-active ゆえ stall 判定を抑止★（黙って消していない・1 戦につき 1 度）");
                    }
                    _stallFrames = 0;
                }
                else
                {
                    _stallSuppressedLogged = false;
                    …（現行のまま）…
                }
            }
```
- **`_rt.BattleActive` は ★既に public★**（`DialogueRuntime` の `BattleActive { get { return _battle != null; } }`）
  ⇒ **`TextboxView` から `BattleSession` を参照しない**（**依存を増やさない**）。

## D-N. verify の現況（★D-H の表を 実測で 埋めた★）

| # | 何を | 結果 |
|---|---|---|
| **V1** | gate OFF の不変 | **★PASS（2026-08-30 実測・-assy3 / Unity batchmode）★** = `RESULT=GREEN(textIdentical=True OFFgated=0 ONgated=7 reach=7)` = **baseline と同一**。**★`reach=7` が 膨らんでいない★**（park 再入で seam census が汚れていない・母数 = CENSUS 225 entry / SWEEP 1556 section 全数） |
| **V2** | baseline 3 値（`CutsceneVerify178`） | **★PASS（同 run）★** = `pages=0/66` `chars=0/1601` `termPc=0x1A/0x1315` = **★baseline と bit 一致 = 動いていない★**（**`RESULT=FAIL` は この base の baseline RED そのもの**・**★GREEN に戻すのは目標ではない★**） |
| **V3** | 1 戦が有限で終わる | **PASS**（`run_step_d.sh` D2 = `frame=60` / 強制 hit 3 発 / `result=Minus1`） |
| **V4** | park 再入が seam census を汚さない | **未実施**（**park を繋ぐ P-1 が入ってから**。★harness D1 は「未接続では step1 と同一」までを固定★） |
| **V5** | counter が 1 回だけ | **未実施**（同上・**step1 側の器で既に 1 箇所化済**） |
| **V6** | damage の live 突合 | **未実施**（**本 slice の画面数値とは 別物** = **live sample の入力を入れる test は 未作成**） |
| **V7** | 勝利路 | **★通せないことが判明★**（D-L-2）⇒ **D3 が 限界を固定する test に変わった** |
| **V8** | 見た目 | **★user 実視覚★**（**我々には確かめられない**） |

## D-O. 札の更新（実装で 増えた / 消えた）

| # | 札 | 状態 |
|---|---|---|
| **D-11（新）** | **材料** | **★勝利（`Win`）/ 逃走（`Zero`）に至る exit arm が remake に無い★**（`f_80057C00` は 222 命令中 arm 1 本しか読まれていない） |
| **D-12（新）** | **材料** | **強制 hit の `SkillPower` は ★出所なしの仮値★**（`wazaTbl` を asset 化していない）／敵が受け手のときの属性は **`0xFF×3` の仮値** |
| **D-13（新）** | **実機/材料** | **P-2 (3)「戦闘後に `InputLocked` が戻る」は ★code を読んだだけ★**（park を繋いだ run で確かめる） |
| D-2 | 材料 | **drain 周期 = 毎 frame 1 回を仮置き**（**勝敗には影響しない = 実効値を変えないため**・harness D7 で固定） |

---

# 【手空き分】(1) 材料の所在（地図だけ）／(2) 「未実装」表示の文言案（worker3・便 #929-W3f）

## D-P. `f_80057C00`（残り exit arm）の ★材料の所在★ — ★読解していません★

> **★これは 地図です★** = **「着手する人が 0 から探さない」ためだけの もの**。
> **★命令を 1 つも 解釈していません★**（**実装 phase の外**）。**確認したのは ★file の在処・大きさ・sha・offset の算術・prologue に着地すること★ だけ。**

| 項 | 値 |
|---|---|
| **image（一次）** | `/home/ken/Desktop/vise/extracted/btl_rel.bin` ／ **179,412 byte** ／ `sha256 = fafd9bd20356c193f085…` |
| **sidecar** | 同 dir の `btl_rel.txt` = **`Load Address: 0x80010000`** ⇒ **★誤り★**（§9 = **base は `0x80052AE0`**・prologue 着地率 372/380 = **97.9%**／陰性対照 `0x80010000` = **0.0%**） |
| **base（使う値）** | **`0x80052AE0`** |
| **関数の file offset** | **`0x80057C00 − 0x80052AE0` = ★`0x5120`★** |
| **範囲（222 命令）** | **888 byte = `0x378`** ⇒ **`0x5120 .. 0x5498`**（VA `0x80057C00 .. 0x80057F78`） |
| **直後の VA** | **`0x80057F78` = 毎 frame tick**（既知・`BattleRuntime.TickEveryFrame` の出所）⇒ **関数の終端と 整合** |
| **確認したこと** | `0x5120` が **関数の頭に 着地している**（**`addiu sp,sp,-0x20`**）。**★これ以上は 読んでいません★** |
| **★表記の向き（読む人の器に 合わせる）★** | **命令語 = `0x27BDFFE0`** ／ **★`xxd` で file を開いた人が 見るのは `e0 ff bd 27`★（little-endian の byte 順）**。**★同じものです★** — **「一致しない」と読まれないように 両方 書く**（boss1 #929-W3g ■2） |
| **第 2 の image** | `btl_code.bin`（**162,636 byte**・`sha256 = 32dc47e510445ba2989d…`）にも **同じ命令列**（**同 4 byte が offset `0xF98` に在る**） ⇒ **base が違う**（**MWo1 header の `load_va 0x80056C68`**） |
| **★取り違え注意★** | **同じ code が 2 image に在り base が違う** ⇒ **★どちらの file を 開いたかで offset が 変わる★**。**着手時に ★base assert（prologue 着地率）を 先に 通すこと★**（§9 の手順） |
| **既知の landmark** | **exit arm 1** = `0x80057C38`（file `0x5158`）／`0x80057C40`（file `0x5160`）= **worker1 が 逐語で読んだ 2 命令**（**残りの arm は 未読**） |

**★この地図で 埋まっていないもの★** = **「arm が いくつ 在るか」**（**★数えていません★** = **`jr ra` / return 経路の census は 未実施**）。
**⇒ 着手する人の 最初の 1 手 = ★`0x5120..0x5498` の 中で 戻る経路を 全数 数える★**（**それが §13 の 母数になる**）。

## D-Q. 「未実装」表示の 文言案（★1 案★・`BattleView` の `OnGUI`）

**要件（boss1 #929-W3f）** = **★user が「壊れている」と読まない★ かつ ★「出来ている」とも読まない★。**

**案（そのまま貼れる形）**:

```csharp
// ★決着の行の 下に 常時 出す（戦闘中も 出す = 後から 驚かせない）★
GUI.Label(new Rect(20, y, 1100, 20),
    "★ここまで作ってあります★：ダメージ計算 / HP の増減 / ★負けで終わる★ところまで");
GUI.Label(new Rect(20, y + 20, 1100, 20),
    "★まだ作っていません★：★勝ちで終わる処理★（原盤の該当箇所を まだ 読めていないため）"
  + " ⇒ ★敵の HP が 0 になっても 戦闘は 続きます（不具合ではなく 未実装です）★");
```

**★なぜ この 2 行か★**:

1. **★出来ている範囲を 先に 言う★** — 「未実装」だけ出すと **画面全部が 未完成に 見える**。
2. **★見える症状を 先回りして 名指しする★**（「敵の HP が 0 でも 続く」）— **★user が 発見する前に 書いてある★** なら
   **「壊れている」ではなく「そこまでの実装」と読める**。**★症状を 隠して 驚かせない★。**
3. **★理由を 1 句だけ 付ける★**（「原盤の該当箇所を まだ 読めていない」）— **★出来ない理由が 我々の怠慢ではなく 材料の不足★** だと判る。
   **★「未 RE」「exit arm」等の 内部語は 画面に 出さない★**（**user 向けの語彙にする**）。
4. **★「忠実」「再現」と 書かない★** — **構図の忠実は 主張しない**（§3-2 (β)）。

**★置き方（boss1 #929-W3g ■4 の追加）★**:

- **★「不具合ではなく 未実装です」の 後に 何も 足さない★** — **言い訳を足すと 未実装が 小さく見える**。
- ⇒ **既にある「★この画面の構図は 原盤の忠実ではない★」の行は ★この 2 行より 上★ に置く**（**最後の語を 未実装の宣言にする**）。

**★私が 決めないこと★** = **★そもそも この画面を user に 見せるか★**（**boss1 / PRESIDENT / user の判断**）。
**文言は ★見せると決まってから★ 効きます** — **★先に用意しておくだけ★。**

---

# 【事前登録】`f_80057C00` の ★戻る経路の 母数★ を 数える（worker3・2026-08-31・便 #930-W3a）

> **★数える前に 書いています★**（**まだ 1 度も 走らせていません**）。
> **★worker2 と 数を 交換していません★／★boss1 にも 予想を 聞いていません★**（**boss1 は 意図的に 数えていない**）。
> **★私は 数えるだけ★ = ★arm の 意味は 読みません★**（**意味を読むと「意味の在る分岐だけ」を数えてしまう**）。

## 1. 器（★私自身の器で 開く★・boss1 の数を 転記しない）

| | |
|---|---|
| file | `/home/ken/Desktop/vise/extracted/btl_rel.bin`（**read-only**） |
| base | `0x80052AE0`（**§9 の確定値**） |
| 範囲 | **file offset `0x5120` 以上 `0x5498` 未満**（VA `0x80057C00`..`0x80057F78`） |
| 読み方 | **4 byte little-endian で word 化**（**`xxd` の見え方 `e0 ff bd 27` = word `0x27BDFFE0`**） |

## 2. ★数える対象の 定義（先に 固定する）★

**「戻る経路」を ★4 分類で 別々に 数える★**（**畳まない**・**合計だけを出さない**）:

| 分類 | 定義（★word の 形だけで 決める★） |
|---|---|
| **(A) `jr ra`** | **word == `0x03E00008`**（= `jr $31`）**★これを 主たる母数とする★** |
| **(B) `jr` その他** | **op=0（SPECIAL）かつ funct=0x08 かつ rs≠31**（**jump table 等・★戻りとは限らない★**） |
| **(C) 範囲外への `j`** | **op=0x02 で、着地 VA が ★範囲外★**（**tail 的に 出ていく形**。`jal`(op=0x03) は ★呼び出し★ ゆえ **含めない**） |
| **(D) 範囲外への 分岐** | **op ∈ {0x01, 0x04, 0x05, 0x06, 0x07, 0x14, 0x15, 0x16, 0x17}** で **`pc+4+(simm16<<2)` が ★範囲外★** |

- **★(A) が 「戻る経路の数」の 一次の答★**。**(B)(C)(D) は ★別枠で 開示する★**（**★合計に 畳まない★**）。
- **★delay slot は 数えない★**（**分岐の 次の word は 独立に 分類しない**）。
- **★意味づけは しない★** = 「この arm は 勝利」等は **1 行も 書かない**。

## 3. ★器の 陽性対照（数を 出す前に 通す）★

| # | 対照 | 期待 |
|---|---|---|
| **C1** | `0x5120` の word | **`0x27BDFFE0`**（= `addiu sp,sp,-0x20`・**関数の頭**） |
| **C2** | `0x5498` の word | **`0x27BDFFB0`**（= `addiu sp,sp,-0x50`・**次の関数の頭**）★boss1 の base assert と 同じ値が 出るか★ |
| **C3** | `0x5494` の word | **`0x00000000`** |
| **C4** | `0x5158` の word（**worker1 が 逐語で読んだ landmark `0x80057C38 lh v1,46(B)`**） | **op = `0x21`（`lh`）** |
| **C5**（★陰性対照★） | `0x5000` の word | **`0x0C03272F`**（= `xxd` で `2f27 030c`）**★範囲外は 別の byte★** |
| **C6**（★器が 空振りしていない★） | **`btl_rel.bin` 全域の `jr ra` 件数** | **★0 件では ない★**（**0 なら 器が 壊れている**） |

**★C1..C6 が 1 つでも 外れたら 数を 出しません★**（**器を 直してから 数え直す**）。

## 4. ★私が やらないこと★

- **arm の 意味を 読まない**（**worker2 の分**）／**実装しない**／**実機に 繋がない**
- **★worker2 の数を 見てから 自分の数を 直さない★**（**突き合わせは boss1 が する**）
- **★「たぶん N 本」と 先に 書かない★**（**予想を 出すと 数が それに 寄る**）

---

# 【結果】`f_80057C00` の 母数（worker3・2026-08-31・便 #930-W3a ＋ #930-AXIS）

> **★worker2 の数は 見ていません／boss1 に 予想も 聞いていません★。事前登録 = commit `4e1d471`（★数える前に land★）。**

## R-0. ★#930-AXIS が 要求した 欄★

| 欄 | 中身 |
|---|---|
| **数えた 軸** | **★(a) = `jr ra` 命令の 数★**。**★(b)（相異なる 終局）は 数えていません★** ⇒ R-3 に **別軸の proxy を ★名前を変えて★ 開示** |
| **母数の 範囲** | `/home/ken/Desktop/vise/extracted/btl_rel.bin` ／ **179,412 byte** ／ sha256 **`fafd9bd20356c193f085c552471f23a2`**（**私の器で 取り直した**）／ **file `0x5120` 以上 `0x5498` 未満 = 222 word**（VA `0x80057C00`..`0x80057F78`） |
| **器の式** | **R-5 に 逐語**（★要約ではない★） |
| **除外** | R-2（**件数つき**） |
| **数えられなかったもの** | R-4（**★0 に 畳んでいない★**） |

## R-1. ★(a) の 結果（陽性対照 6/6 を 先に 通した）★

```
file=/home/ken/Desktop/vise/extracted/btl_rel.bin size=179412 sha256=fafd9bd20356c193f085c552471f23a2
  PASS C1 0x5120 = 0x27BDFFE0 : 0x27bdffe0
  PASS C2 0x5498 = 0x27BDFFB0 : 0x27bdffb0
  PASS C3 0x5494 = 0x00000000 : 0x0
  PASS C4 0x5158 の op = 0x21(lh) : op=0x21 word=0x8443002e
  PASS C5 0x5000 = 0x0C03272F(陰性) : 0xc03272f
  PASS C6 全域 jr ra が 0 件でない : 全域 jr ra=388 件
CONTROL=OK（6/6）

範囲 = file 0x5120..0x5498 (VA 0x80057C00..0x80057F78) / word 数 = 222
(A) jr ra            = 1 件 : ['0x5490(VA 0x80057F70)']
(B) jr その他(rs≠31) = 0 件 : []
(C) 範囲外への j     = 0 件 : []
(D) 範囲外への 分岐  = 0 件 : []
```

⇒ **★(a) = 1 件★**（VA `0x80057F70` / file `0x5490`）。**(B) jr その他 / (C) 範囲外への j / (D) 範囲外への分岐 は いずれも 0 件。**

**★範囲の 両端も 私の器で 確認★** = `0x5120`=`0x27BDFFE0`（関数の頭）／`0x5494`=`0x00000000`／`0x5498`=`0x27BDFFB0`（次の関数の頭）
= **boss1 の base assert（#930-BASE）と 同じ値**（**★転記ではなく 私の器で 出した★**）。**222 word = worker1 の「全 222 命令」と 独立に一致。**

## R-2. ★除外したもの（件数つき・★除外は 一番 検証されない★）★

| 除外 | 件数 | 理由 |
|---|---|---|
| `jal`（op=0x03） | **2 件**（VA `0x80057CCC`→`0x80078BB0` ／ `0x80057E74`→`0x80065794`） | **呼び出しであって 戻る経路ではない** |
| `jalr`（funct=0x09） | **0 件** | 同上（**0 件も 数えて 書く**） |
| delay slot | **数えない** | 事前登録どおり（分岐の次 word を 独立に分類しない） |
| **範囲内で 完結する 分岐** | **25 件** | **範囲外に出ないので (D) ではない**（**数だけ 開示**） |

## R-3. ★(b) ではない が 近い 軸（★別名で 出す★）= ★戻り block への in-edge★

**★これは (b)「相異なる 終局」では ありません★** — **結果コードの ★値ごとに★ 数えた ものでは ない**。
**私が 形だけで 出せるのは ★CFG 上の 合流の 形★ まで**（**意味を 読まないため**）。

```
★block 数=34★ / ★jr ra(VA 0x80057F70) を含む block の leader = VA 0x80057F5C (file 0x547C)★
★in-edge = 6 本★:
   ← VA 0x80057C54 (file 0x5174) branch
   ← VA 0x80057E90 (file 0x53B0) branch
   ← VA 0x80057E9C (file 0x53BC) branch
   ← VA 0x80057F04 (file 0x5424) branch
   ← VA 0x80057F4C (file 0x546C) branch
   ← VA 0x80057F58 (file 0x5478) fallthrough(straight)
★1 つ前の block（leader VA 0x80057F58 / file 0x5478）への in-edge = 2 本★:
   ← VA 0x80057F28 (file 0x5448) branch
   ← VA 0x80057F4C (file 0x546C) fallthrough
```

- **`jr ra` を含む block の leader = VA `0x80057F5C`** ／ **★in-edge = 6 本★**（branch 5 ＋ straight fallthrough 1）
- **1 つ前の block（VA `0x80057F58`）への in-edge = 2 本**
- **★別 census との 重なり（事実のみ・解釈しない）★** = in-edge 元の VA `0x80057C54` / `0x80057E90`、および `0x80057F58` は
  **★`addiu v0, r0, 1`（v0 に 即値 1 を置く命令）そのもの★**（v0 書き込み census で 独立に出た 3 site）。
  **★何を意味するかは 書きません★**（**worker2 の分**）。

### ★器の 自己申告（私の tool の bug）★

**初版は ★straight-line の fallthrough edge を 足していなかった★** ⇒ **in-edge を ★5 本★ と 出した**。**直した版が 6 本。**
**★数を 先に 出していたら 1 本 少ない 数が 流れていました★**（`[[feedback_audit_your_own_tool]]`）。
**気づいた理由 = 「`0x80057F58` へ 分岐が 来ているのに 次 block への 辺が 無い」という ★形の 不整合★**（**意味からではない**）。

## R-4. ★数えられなかったもの（★0 に 畳まない★）★

| 項 | 状態 |
|---|---|
| **(b) 相異なる 終局（結果コードごとの arm）** | **★未算出★** = **「0 件」でも「不明」でもなく ★私は 数えていない★**。必要な器 = **各 path で v0 に 最後に入る値を 追う dataflow** ⇒ **★意味を読む側（worker2）と 重なる★ ので 踏み込まなかった** |
| **呼び出し 2 件の 戻り値** | **v0 を 変えるが ★範囲内に 命令として 現れない★** ⇒ どの path の v0 に効くかは **未追跡** |
| **範囲の 外から 飛び込む edge** | **★数えていない★**（本 census は **範囲内から 出る 辺だけ**） |

## R-5. ★器（逐語・要約ではない）★

### (a) の器 = `count_exits.py`

```python
# f_80057C00 の 戻る経路の母数（worker3・事前登録 4e1d471 に従う）★意味は読まない★
import struct, hashlib, sys
P="/home/ken/Desktop/vise/extracted/btl_rel.bin"
BASE=0x80052AE0; LO=0x5120; HI=0x5498
d=open(P,"rb").read()
def w(off): return struct.unpack_from("<I", d, off)[0]
print("file=%s size=%d sha256=%s" % (P, len(d), hashlib.sha256(d).hexdigest()[:32]))

# ── 陽性/陰性対照（数を出す前）
ctrl=[]
ctrl.append(("C1 0x5120 = 0x27BDFFE0", w(0x5120)==0x27BDFFE0, hex(w(0x5120))))
ctrl.append(("C2 0x5498 = 0x27BDFFB0", w(0x5498)==0x27BDFFB0, hex(w(0x5498))))
ctrl.append(("C3 0x5494 = 0x00000000", w(0x5494)==0, hex(w(0x5494))))
ctrl.append(("C4 0x5158 の op = 0x21(lh)", (w(0x5158)>>26)==0x21, "op=0x%X word=%s" % (w(0x5158)>>26, hex(w(0x5158)))))
ctrl.append(("C5 0x5000 = 0x0C03272F(陰性)", w(0x5000)==0x0C03272F, hex(w(0x5000))))
allJr=sum(1 for o in range(0,len(d)-3,4) if w(o)==0x03E00008)
ctrl.append(("C6 全域 jr ra が 0 件でない", allJr>0, "全域 jr ra=%d 件" % allJr))
for n,ok,det in ctrl: print(("  PASS " if ok else "  FAIL ")+n+" : "+det)
if not all(ok for _,ok,_ in ctrl):
    print("CONTROL=FAIL ⇒ ★数を出しません★"); sys.exit(1)
print("CONTROL=OK（6/6）")

A=[];B=[];C=[];D=[]
BR={0x01,0x04,0x05,0x06,0x07,0x14,0x15,0x16,0x17}
for off in range(LO,HI,4):
    x=w(off); va=BASE+off; op=x>>26
    if x==0x03E00008: A.append((off,va)); continue
    if op==0 and (x&0x3F)==0x08: B.append((off,va,(x>>21)&31)); continue
    if op==0x02:
        tgt=((va+4)&0xF0000000)|((x&0x03FFFFFF)<<2)
        if not (BASE+LO<=tgt<BASE+HI): C.append((off,va,tgt))
        continue
    if op in BR:
        simm=x&0xFFFF; simm=simm-0x10000 if simm&0x8000 else simm
        tgt=va+4+(simm<<2)
        if not (BASE+LO<=tgt<BASE+HI): D.append((off,va,tgt))
print("\n範囲 = file 0x%X..0x%X (VA 0x%X..0x%X) / word 数 = %d" % (LO,HI,BASE+LO,BASE+HI,(HI-LO)//4))
print("(A) jr ra            = %d 件 : %s" % (len(A), ["0x%X(VA 0x%X)"%(o,v) for o,v in A]))
print("(B) jr その他(rs≠31) = %d 件 : %s" % (len(B), ["0x%X(VA 0x%X rs=%d)"%(o,v,r) for o,v,r in B]))
print("(C) 範囲外への j     = %d 件 : %s" % (len(C), ["0x%X(VA 0x%X→0x%X)"%(o,v,t) for o,v,t in C]))
print("(D) 範囲外への 分岐  = %d 件 : %s" % (len(D), ["0x%X(VA 0x%X→0x%X)"%(o,v,t) for o,v,t in D]))
```

### R-3 の器 = `cfg_inedge.py`（★fallthrough を 足した 直し版★）

```python
# ★戻り block への in-edge を数える器★（worker3）。★意味は読まない = 形だけ★
# ★注意★: 初版は straight-line の fallthrough edge を足しておらず 1 本少なかった（自己申告）。本版が直した版。
import struct
P="/home/ken/Desktop/vise/extracted/btl_rel.bin"; BASE=0x80052AE0; LO=0x5120; HI=0x5498
d=open(P,"rb").read(); w=lambda o: struct.unpack_from("<I",d,o)[0]
BR={0x01,0x04,0x05,0x06,0x07,0x14,0x15,0x16,0x17}
va0,vaN=BASE+LO,BASE+HI
def dec(va):
    x=w(va-BASE); op=x>>26
    if op in BR:
        s=x&0xFFFF; s=s-0x10000 if s&0x8000 else s
        return ("br", va+4+(s<<2))
    if op==0x02: return ("j", ((va+4)&0xF0000000)|((x&0x03FFFFFF)<<2))
    if op==0 and (x&0x3F)==0x08: return ("jr", None)
    return ("n", None)
lead={va0}
for va in range(va0,vaN,4):
    k,t=dec(va)
    if k in ("br","j","jr"):
        if t is not None and va0<=t<vaN: lead.add(t)
        if va+8<vaN: lead.add(va+8)          # delay slot の次 = leader
leads=sorted(lead)
def blk_of(va):
    lo=leads[0]
    for l in leads:
        if l<=va: lo=l
        else: break
    return lo
edges={}
for i,L in enumerate(leads):
    end=(leads[i+1]-4) if i+1<len(leads) else vaN-4
    term=None
    for va in (end-4, end):                  # terminator は 末尾 or その 1 つ前(delay slot 付き)
        if va<L: continue
        k,t=dec(va)
        if k in ("br","j","jr"): term=(va,k,t); break
    if term:
        va,k,t=term
        if k in ("br","j") and t is not None and va0<=t<vaN: edges.setdefault(t,[]).append((L,"branch"))
        if k=="br" and i+1<len(leads): edges.setdefault(leads[i+1],[]).append((L,"fallthrough"))
    else:
        if i+1<len(leads): edges.setdefault(leads[i+1],[]).append((L,"fallthrough(straight)"))
JR=0x80057F70; jrL=blk_of(JR); ins=edges.get(jrL,[])
print("★block 数=%d★ / ★jr ra(VA 0x%X) を含む block の leader = VA 0x%08X (file 0x%X)★" % (len(leads),JR,jrL,jrL-BASE))
print("★in-edge = %d 本★:" % len(ins))
for s,k in ins: print("   ← VA 0x%08X (file 0x%X) %s" % (s,s-BASE,k))
prev=leads[leads.index(jrL)-1]; pins=edges.get(prev,[])
print("★1 つ前の block（leader VA 0x%08X / file 0x%X）への in-edge = %d 本★:" % (prev,prev-BASE,len(pins)))
for s,k in pins: print("   ← VA 0x%08X (file 0x%X) %s" % (s,s-BASE,k))
```

---

# 【地図】勝利 path の 番地地図（worker3・2026-08-31・便 #930-W3b）

> **★地図です = 読解していません★**（**意味づけは worker2 / boss1 の分**）。
> **★boss1 の数を 転記していません★** — **★私の器で 検算した行には ◆検算◆ を付けました★**（**全部は 検算していません**）。
> **★格は 3 段★** = **確定（私が 器で 出した）／ 引用（他者の便が 出所・私は 未検算）／ 前提つき**。
>
> **★★換算の 宣言（読む人が offset を 再導出しても ずれないように）★★**（boss1 #930-W3c）
> **本地図の main EXE の file offset は ★`slps_017_97.bin`（★header 無し★・710,656 byte）★ 換算**:
> **`file offset = VA − 0x80090800`**
> **★`slps_017.97.orig`（712,704 byte）を 開く場合は ＋`0x800`★**（**PS-EXE header の分**）: **`file offset = 0x800 + (VA − 0x80090800)`**
> **★VA は どちらでも 同じ★**。
>
> **★私の器で 確かめました（転記していません）★** = **`.orig` − `.bin` = ★2,048 = 0x800★** ／ **★`.orig[0x800:] == .bin` が byte 完全一致★**
> ／ **`.orig` の `0x800+0xA1AF4` でも row0 = `[10,15,5,20,20,15,20]`**。
> **★陰性対照★** = **同 dir の `SLPS_017.97`（354,304 byte）は ★別 image★**（**`[0x800:]` は 一致しない**）
> ⇒ **★名前が 似ている 3 つ目が 在る★ = ★開く前に size と assert を 見る★**。

## M-0. ★器と 対照（数を 出す前に 通した）★

| image | 値 | base assert |
|---|---|---|
| `btl_rel.bin` | **179,412 byte** / sha256 `fafd9bd2…` | **`0x5120` = `0x27BDFFE0`（関数の頭）／`0x5498` = `0x27BDFFB0`（次の関数の頭）** ⇒ **base `0x80052AE0`** |
| `slps_017_97.bin`（main EXE・text raw） | **710,656 byte** | **★属性表 `0x801322F4` の row0 = `[10,15,5,20,20,15,20]`★（file `0xA1AF4`）= ★期待どおり★** ⇒ **base `0x80090800`** |

**★この 2 本の assert を 通してから 下の 番地を 触りました★**（**★別 image を 開いていない ことの 担保★**）。

## M-1. ★番地表★

| # | 番地 | 何（★boss1 の便の 言い方を そのまま★） | file offset | 出所 | 格 |
|---|---|---|---|---|---|
| 1 | **`0x80057C00`..`0x80057F78`** | 述語 `f_80057C00`（**222 word**） | **`0x5120`..`0x5498`**（btl_rel）**★`0x5120+0x378=0x5498` 一致★** | worker3 地図 ＋ boss1 base assert | **確定 ◆検算◆**（両端 ＋ 語数を 私の器で） |
| 2 | **`0x8005CABC`** | **呼び手**（`f_80057C00` を 呼ぶ） | `0x9FDC`（btl_rel） | boss1 #930-W3b | **確定 ◆検算◆** = **decode して `jal 0x80057C00`**。**★FOUNDATION §8.28 の「`0x8005CABC` = loop head」と 矛盾しない★**（**loop head に 在る命令が この `jal`**） |
| 3 | `0x8005CB14`..`0x8005CB90` | 分類 | `0xA034`..`0xA0B0` | boss1 #930-W3b | **引用**（**私は 未検算**） |
| 4 | **`0x80057F58`** | **arm #6（脱出＝敵全滅）** | `0x5478` | boss1（worker2 の読解） | **番地は 確定 ◆検算◆**（**私の CFG census で ★戻り block の 1 つ前の block leader★ かつ ★`addiu v0,r0,1` が在る site★ として 独立に出た**）／**「敵全滅」の意味は 引用** |
| 5 | **`0x80057F4C`** | **arm #5** | `0x546C` | 同上 | **番地は 確定 ◆検算◆**（**戻り block への in-edge 元の 1 つ**）／意味は **引用** |
| 6 | `0x80057EA8` | loop 開始 index | `0x53C8` | boss1 | **引用**（範囲内であることのみ 自明） |
| 7 | **`B[0x64E]`（逃走 flag）の 書き手 = 8 件** | btl_rel **5** ／ main EXE **3** | — | boss1 #930-W3b | **確定 ◆検算◆** = **私が 両 image を 全域走査**（`sb/sh/sw` で `imm==0x64E`）:<br>**btl_rel 5 件** = `0x800572F8` / `0x80057FDC` / `0x8005CB40` / `0x8005CB70` / `0x80065100`<br>**main EXE 3 件** = `0x80105E14` / **`0x80107D58`** / `0x80107F64` ⇒ **5+3 = ★8★ 一致** |
| 8 | `0x80107D58` | **「1 を書くのは ここだけ」** | `0x77558`（main EXE） | boss1 | **番地は 確定 ◆検算◆**（**上の 3 件に 含まれる・word = `0xA043064E` = `sb r3,0x64E(r2)`**）／**★「値が 1」は 未検算★**（**私は 値を 追っていない**） |
| 9 | `f_80107970` | 1 と 11 を 書き分ける | `0x77170` | boss1 | **引用**（未検算） |
| 10 | `B[0x650]` / `B+0x654` / `B+0x652` | 表を index で引く | — | boss1 | **引用**（未検算） |
| 11 | **`f_80102F1C`** | **drain（味方 rawHP を書く）** | `0x7171C`（main EXE） | FOUNDATION §5 ＋ boss1 | **呼び手を ◆検算◆** = **`0x8005ECC8` / `0x800683A8` の 2 site とも ★decode して `jal 0x80102F1C`★**（btl_rel file `0xC1E8` / `0x158C8`） |
| 12 | `0x8013CDB4` | actorTable base（`slot*4`） | — | FOUNDATION §5 | **引用**（**算術のみ確認** = `+4*1 = 0x8013CDB8` / `+4*2 = 0x8013CDBC`） |
| 13 | **`0x8016B084`** | 味方 record | — | FOUNDATION §8.15 | **引用** |
| 14 | **`0x8016B0D0`** | 味方 rawHP | — | 同上 | **確定（算術） ◆検算◆** = **`0x8016B084 + 0x4C = 0x8016B0D0`** |
| 15 | **`0x8016B0B2`** | 味方 `+0x2E` | — | boss1 | **確定（算術） ◆検算◆** = **`0x8016B084 + 0x2E = 0x8016B0B2`** |
| 16 | **`B + 360*i + 0x2E`** | **decay の `+0x2E`（★別番地★）** | — | boss1 ＋ §8.51 | **引用**（**★14/15 と 混ぜない★ = ★同じ `+0x2E` でも base が違う★**） |

## M-2. ★検算した / していない の 内訳（★数で★）★

- **◆検算◆ = 8 行**（#1 / #2 / #4 番地 / #5 番地 / #7 / #8 番地 / #11 呼び手 / #14・#15 の算術）
- **引用（未検算）= 8 行**（#3 / #6 / #8 の「値 1」/ #9 / #10 / #12 / #13 / #16）
- **★私が 出所を 確かめていない 主張★** = **「arm #6 = 敵全滅」「`f_80107970` が 1 と 11 を書き分ける」「`0x80107D58` が 1 を書く」**
  ⇒ **★これらは 地図の 座標としてのみ 使い、意味の 根拠には しないでください★。**

## M-3. ★私が 気づいた 1 点（事実のみ）★

**#2 は ★`jal` であって 分岐ではありません★** ⇒ **`f_80057C00` は ★loop head から 毎周 呼ばれる 関数★**。
**FOUNDATION §8.28 の「`0x8005CABC` が loop head」と ★同じことを 別の言い方で 述べている★**（**矛盾ではない**）。
**★これが 混乱の 種になり得る★**（**「loop head」と聞くと 分岐先だと 読む**）ので **地図に 明記しました**。
