# 同じ step の 2 回目の Say が 1 回目を黙って上書きする口の全数（worker3、boss1 04:27・PRESIDENT 04:3x。source を読むだけ・dotnet なし）

- 木: ikada-sim main `58eb57b` と worker1 の作業木 `~/Documents/ikada-sim-w1`（HEAD 58eb57b ＋ 未 commit の DayCast の直し、04:2x に読んだ）。行番号は 作業木（main と違う所は括弧）。

## 0. Say の中身（1 行）
★`LineSlot.Say`（LineTiming.cs:63-72、両木で同じ）= 字幕の置き場は 1 つ、「新しい行が勝つ」: Speech・Story は いつでも前の行を上書き、Status は Speech/Story の残り > 1 s の時だけ譲る = ★同じ step の 2 回目の Speech/Story は 1 回目を描かれる前に消す（列でない）★。★置き場は 2 つ★: `FishingSession.Lines`（状況の字）と `DayFlow.Lines`（NPC・物語）、画は session の字幕があればそれ、無ければ DayFlow の（SnapshotBuilder.cs:125-126）= DayFlow の行は session の字の下で時間が進む（DayFlow.cs:354 の Tick）= 覆われて消えることもある（2 つ目の形）。

## 1. 器（母数）
- `\bSay\(|SayStory\(` の呼び = 両木とも DayFlow*.cs 18 ＋ GameFlow.cs 1・FishingSession*.cs 13・ChapterTasks の Say（字幕でない、Emit = 日誌）8・他 0（定義・Mentor.Say・注の行を除いた数、grep で数え直した）。字幕の Speech/Story を出す DayFlow の口（下の表）を、1 つの step の中の呼びの順（DayFlow の ctor・StartSession・Tick・Pickup）で並べた。
- ★陽性対照: worker1 の G の 3500 の口（GameFlow の課題の行、直す前 = 話し手ごとに SayStory を回した形）= 下の規則「1 つの呼びの道の中で Speech/Story の Say が 2 回以上」に 入る★（直した形 GameFlow.cs:241 は 1 回 = 入らない。ただし ctor の宿の行と 同じ step = 表の 1 行目で残る）。

## 2. 表（同じ step に並びうる組）
| 組（同じ step の中の順） | 口 | 並ぶ条件（source から） | 消える方 | 証拠 |
|---|---|---|---|---|
| ★日の始め★ GameFlow.NextStoryDay: StartDay → `new DayFlow` の ctor が `Say(inn, Story, 30f)`（DayFlow.cs:125、StoryHooks.Fire(Lodging)）→ 戻って `SayStory(課題の行)`（GameFlow.cs:241〔main :233〕） | 125 → 241 | 宿の出来事（ev3.eve・ev4.eve など Lodging）と 課題を渡す日が同じ（章の最初の日 = 両方立つ） | ★宿の行（inn）★ | ★観測: F（10/15 種 1）・G（12/10 種 1）の RefCheck の log に ev3.eve「秋は島の筏に行くぞ…」・ev4.eve の字は 0 件、3500 の say は課題の行だけ★（log は字幕の変わりだけ = 消えた行は出ない、推論で閉じる） |
| ★舟の上の始め★ StartSession: `SayFastTide`（DayFlow.cs:272 → CardRows.cs:79〔main :78〕）→ `Say(boat, Story)`（:284、StoryHooks.Fire(BeforeFirstCast)） | 79 → 284 | 潮の速い日（current ≥ FastTideMps、物語の 1 日目でない）で 朝の物語の出来事が立つ日（第3章の ev3.dawn・ev3.fast など） | ★潮の速い日の一言★ | 推論（F は 1 日目で SayFastTide が出ない = log では見えない） |
| ★Tick の中★ `TideLine`（:363 → Diel.cs:32〔main :31〕）→ DangoWait（:375）→ 回収（:381 → :383）→ 昼（:395）→ 船（:403）→ `Pickup()` | 363・375・381・383・395・403 | 同じ step に 2 つ（例: 回収の step で 師匠の回収の一言 :381 と 回収の物語の出来事 :383 = ★同じ if の中で続けて呼ぶ = 両方あれば必ず並ぶ★、潮の一言と回収、昼と船の時刻が同じ step） | 先の方 | :381→:383 は source の形で確か、他は時刻の重なり次第（推論） |
| ★迎え★ `Pickup()`: `Say(迎えの一言)`（:422）→ `Say(pk)`（:424、Fire(Pickup)）→ `Say(after, Story)`（:436、Fire(AfterReturn)） | 422・424・436 | 迎えの一言（師匠の pickup.*）と 迎え・帰りの物語の出来事が同じ日（例: 大物の日の ev3.big_chinu・ev4.big（AfterReturn）＋ pickup） | ★先の 1 つか 2 つ★（最後の 1 行だけ残る） | 推論（F・G は AfterReturn が立たない日） |
| 覆い（置き場 2 つ） | session の Status（例「回収」FishingSession）の下の DayFlow の Speech | session の字幕がある間は DayFlow の行が画に出ない（SnapshotBuilder.cs:125）、DayFlow の時間は進む | 短い行は 覆われたまま終わりうる | 推論 |
- FishingSession 系（置き場 = session、ほとんど Status 同士）: Status は Status を上書き = 同じ step の 2 つ（例: ファイトの終わり Fight.cs:149 と 取り込みでバレた Landing.cs:103）も先が消える形。字幕の字の重さは Speech より低い（今回の数には入れない、表の外として書く）。

## 3. 数
- ★同じ step に 2 回呼ばれうる Speech/Story の組 = 4 か所（日の始め・舟の上の始め・Tick・迎え）★、うち ★source の形だけで確かに並ぶ = 2（日の始めの 125 → 241、回収の :381 → :383）★、log で消えた証拠がある = 1（日の始め、F・G で宿の行 0 件）。main 58eb57b も同じ形（行番号だけ違う）。
- 試験の案（worker1 の commit に 1 本）: 「章の最初の物語の日（宿の出来事と課題が同じ日）に、宿の行（例 ch3.shisho.eve）が 1 frame 以上 字幕に出る」= ★今は赤の見込み★（直す形は worker1・PRESIDENT: 宿の行と課題の行を 1 つの Say に束ねる〔3500 の直しと同じ形〕か、LineSlot を列にする）。
