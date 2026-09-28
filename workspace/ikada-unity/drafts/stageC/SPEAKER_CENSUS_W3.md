# 話し手の決め打ちの全数（worker3、boss1 03:43、第二の読み手の前段。dotnet なし・git grep だけ）

- 器: `git grep -nE 'Speaker\.(Shisho|Aniki|Captain|Passerby|Regular|IslandCaptain)\b' <ref> -- pc/src`（enum の全 6 つ = MentorLines.cs:9）＋ 別の形 `(Speaker)`・`default(Speaker)`・`Speaker x =`・`SpeakerName(`。ref = ikada-sim pin 55ddd942aa11ec6d488ae70efdbe28099d0fd739 と main 58eb57b0eaef2f5acb20eade3937d40290d2d2a1。
- ★全数: 両 ref とも 214 行（199 = new LineDef の台詞の表・15 = それ以外）、行の中身は両 ref で同じ（diff 0）★。

## LineDef 以外の 15 行（58eb57b、両 ref で同じ）
```
pc/src/Ikada.Game/Flow/DayFlow.CardRows.cs:78:            Say(MentorLines.SpeakerName(Speaker.Captain) + "：" + MentorLines.Get("captain.fast_tide_gan").Text, LineKind.Speech);
pc/src/Ikada.Game/Flow/DayFlow.Dialogue.cs:27:                v.Lines.Add(new DialogueLine { Speaker = MentorLines.SpeakerName(Speaker.Shisho), Text = talk.Text });
pc/src/Ikada.Game/Flow/GameFlow.cs:233:                Day!.SayStory(MentorLines.SpeakerName(Speaker.Shisho) + "：" + string.Join("　／　", texts));
pc/src/Ikada.Logic/Mentor/HarbourScene.cs:103:            book.AddQuote(new Quote(MentorLines.SpeakerName(Speaker.Shisho), t.LineId, t.Text));
pc/src/Ikada.Logic/Mentor/HelperEngine.cs:67:            if (scene == Scene.Lunch || scene == Scene.Pickup) who = Speaker.Captain;
pc/src/Ikada.Logic/Mentor/HelperEngine.cs:68:            else if (scene == Scene.PassingBoat) who = Speaker.Passerby;
pc/src/Ikada.Logic/Mentor/HelperEngine.cs:73:            if ((cause == HelpCause.ChumAfterFight || cause == HelpCause.SettleAfterFight) && who != Speaker.Captain)
pc/src/Ikada.Logic/Mentor/HelperEngine.cs:79:            string id = (who == Speaker.Captain ? "captain.help." : "passerby.help.") + key;
pc/src/Ikada.Logic/Mentor/MentorConditions.cs:49:                        e.History.Totals.TryGetValue((e.Active == Speaker.Shisho ? "shisho." : "aniki.") + "morning", out int said);
pc/src/Ikada.Logic/Mentor/MentorEngine.cs:37:        public Speaker Active = Speaker.Shisho;
pc/src/Ikada.Logic/Mentor/MentorEngine.cs:64:            string prefix = Active == Speaker.Shisho ? "shisho." : "aniki.";
pc/src/Ikada.Logic/Mentor/MentorLines.cs:182:            => s == Speaker.Shisho ? "師匠" : s == Speaker.Aniki ? "兄弟子" : s == Speaker.Captain ? "船長"
pc/src/Ikada.Logic/Mentor/MentorLines.cs:183:               : s == Speaker.Regular ? "常連" : s == Speaker.IslandCaptain ? "島の船長" : "通りすがりの釣り人";   // 島の船長 【仮】
pc/src/Ikada.Logic/Save/SaveGame.cs:80:        public Speaker ActiveMentor = Speaker.Shisho;
pc/src/Ikada.Logic/Story/Chapter4Lines.cs:5:// angler on the next カセ speaks as Speaker.Passerby (PRESIDENT 18:4x: no new speaker). Ids "ch4.<speaker>.<topic>" (harbour:
```

## 分け（推論、code を読んで）
- ★話し手を決め打ちして 名を出す所（4）★: DayFlow.CardRows.cs:78（Captain、潮の速い日の一言）・DayFlow.Dialogue.cs:27（Shisho、港の会話）・GameFlow.cs:233（Shisho、課題を渡す朝の言葉）・HarbourScene.cs:103（Shisho、港の言葉の日誌の引用）。
- ★場面で話し手を選ぶ所（1）★: HelperEngine.cs:67-68（Lunch・Pickup = Captain、PassingBoat = Passerby。:73・:79 はその結果の分岐）。
- 状態（師匠か兄弟子か）: MentorEngine.cs:37・:64、MentorConditions.cs:49、SaveGame.cs:80、SaveCodec.cs:64（(Speaker) の cast）。
- 決めでない: MentorLines.cs:182-183（名の表）、Chapter4Lines.cs:5（注）。
- 台詞自身の話し手を使う所（決め打ちでない）: DayFlow.Dialogue.cs:30・DayFlow.cs:413・StoryHooks.cs:39・:65・HelperEngine.cs:82・MentorEngine.cs:98。

## 見つけた食い違い（観測）
- ★GameFlow.cs:233 は 渡す課題の台詞を全部「師匠：」で出すが、第4章の課題の台詞 task4_1・task4_2・task4_4 の issue／done は LineDef で Speaker.Aniki（兄弟子、大分の言葉）★。照合の足す日 G（12/10 種 1）の log の 4 行目で 観測:「師匠：…／前アタリじゃ合わせんでええ。もう一回入るまで待っちょき／穂先がもたれるか、本アタリが来たら、一回で掛けるん…」= 兄弟子の台詞が 師匠の名で出ている。
- DayFlow.CardRows.cs:78 の「船長」は 台詞の LineDef（MentorLines.cs:52 captain.fast_tide_gan = Captain）と合う。ただし 場所を見ない = 第3章の島（島の船長 IslandCaptain が居る所）・蒲江でも「船長」と出る形（推論、SayFastTide の条件 DayFlow.CardRows.cs:77（method は :75）に場所が無い）。HelperEngine.cs:67 の Captain（昼・迎え）も同じ形。

## 話し手を名で出す口の全数（boss1 03:45 の穴を埋めた版、ikada-sim main 58eb57b、git grep だけ）
- 器: `git grep -nE <pat> 58eb57b -- pc/src`、pat = `SpeakerName\(`（11 行 = 定義 1 ＋ 呼び 10）・`Spoken\(`（7 = 定義 1 ＋ 呼び 6）・`MentorLines\.Get\(`（7）・`\.Emit\(`（4）・`Mentor\.Say\(|Helper\.Say\(|\.Say\(Scene`（3）・`\bSay\(|SayStory\(`（50 = 呼び 46 ＋ 定義など）。Say の 46 のうち 話し手の名が付くのは 下の表の物だけ、他は 状況の字（「回収」「ダンゴがもうない」「アワセ切れ」「セーブした」など、名なし）。
- ★陽性対照: DayFlow.Diel.cs:31（boss1 の指摘の口、Speaker.X が行に出ない）と GameFlow.cs:233 が 表に出る = 出た★（前の 15 行の器は Diel.cs:31 を落としていた = 器の穴）。

| 口（file:行） | 何の字幕・日誌 | 話し手の来る所 | 場所・章を見るか |
|---|---|---|---|
| DayFlow.Diel.cs:31（TideLine :24-31） | 潮の動き出し（Speech） | ★id 決め打ち captain.tide_start → LineDef の Speaker（Captain）★ | 見ない（:26 は 練習・ファイトだけ） |
| DayFlow.CardRows.cs:78（SayFastTide :75-78） | 潮の速い日のガン玉（Speech） | ★名も id も決め打ち（Speaker.Captain・captain.fast_tide_gan）★ | 見ない（:77 は 練習・物語の 1 日目・潮の速さだけ） |
| GameFlow.cs:233（:224-233） | 課題を渡す言葉（Story） | ★名を決め打ち Speaker.Shisho、台詞は id ごとの Text だけ★ = 第4章の task4_1/4_2/4_4（LineDef は Aniki）も「師匠：」 | 見ない（章は台詞の id で、名は見ない） |
| DayFlow.Dialogue.cs:27 | 港の会話（log から、HarbourScene.Talk） | ★名を決め打ち Speaker.Shisho★ | 見ない |
| HarbourScene.cs:103 | 港の言葉の日誌の引用 | ★名を決め打ち Speaker.Shisho★ | 見ない（:79 の Placement はダンゴの置き方、場所ではない） |
| DayFlow.cs:395・:403 ← HelperEngine.Advise → Spoken | 昼（Lunch）・船が通る（PassingBoat）の助言 | ★場面で決め打ち★ HelperEngine.cs:67-68（Lunch・Pickup = Captain、PassingBoat = Passerby）→ id "captain.help."/"passerby.help." → LineDef の Speaker | 見ない（:132 の day.Chapter >= 2 は 助言の中身の分岐、話し手でない） |
| HelperEngine.cs:82 | 助言の日誌の引用 | LineDef の Speaker（上の決め打ちの結果） | 見ない |
| DayFlow.cs:373・:381・:422 ← MentorEngine.Say → Spoken | ダンゴ待ち・回収・迎え の 師匠／兄弟子の一言 | LineDef の Speaker、id の頭は MentorEngine.Active（:37 既定 Shisho・:64 shisho./aniki.、SaveGame.cs:80 ActiveMentor） | 見ない（MentorEngine に場所・章の語 0 件） |
| MentorEngine.cs:98 | 師匠の言葉の日誌の引用（ChapterTasks.cs:248 の Emit も ここ） | LineDef の Speaker | 見ない |
| StoryHooks.cs:39・:65 → DayFlow.cs:125・:284・:375・:383・:395・:403・:424・:436 | 物語の出来事（宿・朝・ダンゴ待ち・回収・昼・船・迎え・帰り） | LineDef の Speaker（章ごとの出来事の表の台詞） | ★章は見る★（StoryHooks.cs の IsChapter2/3 = 日付の章で表を選ぶ、:27・:51）・場所は表の中の出来事の条件次第 |
| DayFlow.Dialogue.cs:30（:430 の Emit） | 物語の港の会話 | LineDef の Speaker（#36） | 章は出来事の表で |

- ★決め打ちの口 = 6★（Diel.cs:31・CardRows.cs:78・GameFlow.cs:233・Dialogue.cs:27・HarbourScene.cs:103・HelperEngine.cs:67-68）。前の 15 行の器の「5」は Diel.cs:31 を落としていた。
- 3 つの場所（推論、code から。表の案が来たら突き合わせる）: ★第3章の島★ = Diel.cs:31・CardRows.cs:78・HelperEngine の昼 が「船長」（島の船長が居る所）。★2 月の芦北★ = 第4章の日だが 芦北の筏 = 「船長」で合う見込み、課題の言葉（GameFlow.cs:233）は第4章の課題が兄弟子の台詞なのに「師匠」。★自由釣りの蒲江★ = 物語の出来事は無い（StoryHooks は Story だけ、:26）が Diel.cs:31・CardRows.cs:78・HelperEngine は自由釣りでも出る（Diel.cs:23 の注「story and free days」）=「船長」。
