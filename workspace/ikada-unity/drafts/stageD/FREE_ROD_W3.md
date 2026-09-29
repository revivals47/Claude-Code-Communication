# 案 4: 譲られた竿を自由釣りで（worker3、boss1 16:59・PRESIDENT 16:1x GO。★code の前に登録★、2026-09-29 17:0x）

- 木: ikada-sim-w3、branch `free-rod`（worker2 の 4fa273d2cd0e012a79b4918eb1a34db0564c0bdd = 月、親 = 私の f53cc74 = 案 1、の上、ローカル）。行の順 = FREE_SELECT_ROWS.md（場所・月・今日の狙い・竿・出かける、竿は RodGiven の時だけ、選んだ竿は戻さない）。版は案 2 で 0.22.0（この段の ContractTests は worker2 の DayConfig.FreeMonth で赤のまま = 私の段では 型を増やさない）。
## 形
- GameFlow.Free.cs: `FreeRow.Rod`（出かける の直前、`_storyRodGiven` の時だけ）、行の字「竿　いつもの ◀▶」／「竿　兄弟子の竿 ◀▶」、◀▶ で `_givenRod` を切り替え、場所・月・狙いの ◀▶ では戻さない。
- `_storyRodGiven` = 題を作る時（BuildTitle、GameFlow.cs:57 の SaveCheck.TryLoad の読める物）の `Progress.RodGiven`。読めない・無い = false（行なし）。
- DayPlan に `GivenRod`（DayFlow.cs:54 の Drill の行に同じ行で = file の行数を増やさない、DayFlow.cs 496 行）。出かける時 = `_storyRodGiven && _givenRod`。
- TackleGrades.TodayRod に 3 つ目の引数 `freeGivenRod`（既定 false）= 同じ 1 行の式・同じ表の上の竿（2 つ目の道を作らない）。SnapshotBuilder.cs:111 は 自由釣りの日だけ Plan.GivenRod を渡す。判定は変わらない（描きの 2 欄だけ）。
## 予測
- R1（陽性）: RodGiven のセーブがある時 選びの頁の行 = 5（場所・月・今日の狙い・竿・出かける）、竿の行を ◀▶ で「兄弟子の竿」→ 出かけた日の snapshot = RodGrade 2・TipTitanium true（釣りの画面の最初と最後の frame）。
- R2（陽性・戻さない）: 兄弟子の竿を選んで 場所・月・狙いを ◀▶ で替えても 竿の行は「兄弟子の竿」のまま。
- R3（陰性）: RodGiven の無いセーブ・セーブなし = 行 4（竿の行なし、worker2 の頁と同じ）、出かけた日 RodGrade −1・TipTitanium false。「いつもの」を選んだ日も −1・false。
- R4: 物語の日は変わらない（RodFieldsTests がそのまま通る = TodayRod(false, true) は null のまま〔3 つ目の引数の既定 false〕）。
- RefCheck: 11 値とも #13（照合は物語の日、自由釣りの頁も TodayRod の物語の枝も通らない）。全体 = 今の数 ＋ 新しい試験、落ちる = ContractTests（worker2 の段からの赤、案 2 の版で緑）だけ。

## 結果（観測、17:2x）
- R1〜R4 ★当★: FreeRodTests 2/2（竿あり 5 行・兄弟子の竿 = 2/true・場所 月 狙いを替えても残る・いつもの = −1/false、竿なし・セーブなし = 4 行・−1/false）、RodFieldsTests 3/3。★1 回目の build は私の using 漏れ（GameDate）で落ちた = その時の試験の run は古い dll = 数えない★。
- 全体 874 = 合格 868・スキップ 5・失敗 1 = ContractTests（差 = `+ DayConfig.FreeMonth` の 1 行だけ = 案 3 の分、予測どおり、私の段は公開の欄を足していない）。RefCheck 11 値 #13・5 日の log byte 同じ。
- commit = ikada-sim-w3 free-rod 07d87a50ac14ea732499920136f9b02e5fd0c9ea（4fa273d の上、ローカル）。
