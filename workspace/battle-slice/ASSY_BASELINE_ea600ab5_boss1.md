# 実装前 baseline（boss1 が 自分の器で 採取）— base = ea600ab5

★採取元 = git object（`git show ea600ab5:<path>`）★。★working tree ではない★
（実装開始後の tree は worker1 が 書き換え中で 混在状態のため、
 ★比較の基準は commit から 採る★。tree から採ると「いつの状態か」が 言えない）。

採取時刻 = 2026-08-30 22:32 頃 / 採取者 = boss1 / worktree = degimon_world_remake-assy

## 1. file の 大きさ（実装後に 同じ形で 再採取して 並べる）

| file | 行 | sha256(先頭16) |
|---|---:|---|
| unity/Assets/Scripts/Battle/BattleRuntime.cs | 368 | a7f0eb37c81be515 |
| unity/Assets/Scripts/Battle/BattleEntry.cs | 219 | 1eee285736ce388a |
| unity/Assets/Scripts/State/GameState.cs | 914 | 8f1cdc7d19c90677 |
| unity/Assets/Scripts/Dialogue/DialogueRuntime.cs | 3160 | cbea7e19452128f6 |

## 2. counter の 加算 site = ★実装前は 2 系統 在る★（§11-2 の 前提が 成立していることの 確認）

- 系統 A（BattleEntry 側・★§11-2 で 消す対象★）
  - `BattleEntry.cs:32` `int Battles { get; set; }`（IBattleStats）
  - `BattleEntry.cs:43` `BattlesCap = 9999`
  - `BattleEntry.cs:89` `AdvanceBattleCounter(IBattleStats stats)`
  - `BattleEntry.cs:92` `if (stats.Battles < BattlesCap) stats.Battles += 1;`
  - `BattleEntry.cs:212` `AdvanceBattleCounter(stats);  // ★戦闘に入る前★`
  - `GameState.cs:104` `public int Wins, Battles;  // 0x1D8 / 0x1DA 戦績`
  - `GameState.cs:190` reset で `Battles = 0`
- 系統 B（scene-driver 側・★§11-2 で 唯一の権威に する側★）
  - `GameState.cs:491` `public int RawE12C, RawE104;`
  - `GameState.cs:585` `SceneDriverCounterInc()` / `:587` `if (RawE12C < 0x270f) { RawE12C++; return false; }`
  - `DialogueRuntime.cs:1937` `bool sdSaturated = _gameState.SceneDriverCounterInc();`（0x66 の B2）

★∴ 実装前の 事実 = 「戦闘回数」を 名乗る 加算が 2 箇所 在る★。
★§11-2 の 完了条件 = 系統 A が 消え、加算は DialogueRuntime.cs の 0x66 初回入場 1 箇所だけ に なること★。
★照合の 形 = 上の grep を そのまま 再実行し、系統 A の 行が 0 件 に なることを 見る★
（★0 件 を 書く前に 同じ grep で 系統 B が 見つかることを 確かめる = 陽性対照★）。

  確認 cmd（assy worktree で）:
  `git grep -n -E 'Battles|AdvanceBattleCounter|RawE12C|SceneDriverCounterInc' -- unity/Assets/Scripts`

## 3. index の 誤り（§11 step2 の 前提）

- `BattleRuntime.cs:34` `public const int IndexEveryFrame = 0;`
- `BattleRuntime.cs:96` `IsPartnerDown()` / `:100` `return _actors[1].IsDown();` ← ★相手を 読んでいる★
- `BattleRuntime.cs:112` `if (IsPartnerDown())` / `:117` `Result = BattleResultCode.Zero;`
- 参考 = `BattleAi.cs:206` / `BattleRuntime.cs:122,335` も `IndexEveryFrame` を 使う
  ⇒ ★index の 意味を 動かすなら この 3 箇所も 同時に 見る★

★§9 = 結果コード 0 は 逃走★ ⇒ ★KO で Zero を 返すと 意味が 反転する★（§11-7）。

## 4. 使い方（worker2 へ）

- ★これは 私（boss1）の 器で 採った 数です★。★あなたの器で 採り直して 一致を 見てください★
  （一致しなければ ★どちらが 正しいかでなく 何を数えた数か★ を 先に 決める）。
- ★verify 2 本の baseline★（別便で 渡した通り）:
  - BattleSeamVerify66 = ★GREEN★（textIdentical=True OFFgated=0 ONgated=7 reach=7）
  - CutsceneVerify178 = ★RED★（pages 0/66・chars 0/1601・termPc 0x1A/0x1315）
    = ★戻すのは 本 phase の 目標では ない★／★動いたら battle 起因★
