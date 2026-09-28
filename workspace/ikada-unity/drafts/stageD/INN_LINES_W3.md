# 宿の課題の行を 字幕でなく PrepView の新しい欄へ（API 0.20.0）（worker3、boss1 07:23・PRESIDENT 07:3x 第 3 案。★code の前に登録★、2026-09-29 07:3x）

- 木: ikada-sim-w3、branch `inn-lines`（origin/main 3838e1096b43c6189832a7359fd953737d4f0117 から）。
## 形（決めた所）
- ★新しい欄★: `PrepView.InnLines`（`List<string>`、既定 空）= 07 の前夜の宿で読む行の列、上から順に 1 行 = 1 要素、字は「話し手：本文」（今の字幕と同じ形）。中身 = [宿の行（StoryHooks Lodging、あれば）] ＋ [その日に出す課題の行を 出す順に 1 つずつ（DayCast の話し手の名）]。★字幕（LineSlot）とは切り離し = 30 s で消えない、PrepView がある間（07 の配合の一覧、釣具屋に入ると PrepView ごと null = 今の決まり）ずっと同じ★。
- 宿の行は ★字幕にも今までどおり出す★（DayFlow.cs:125 の Say は残す = 06 の頭の字幕は今と同じ、差は課題の行だけ = boss1 の「差は say の課題の行だけ」に合わせた。宿の行を字幕から外す形は取らない = 別の決め）。
- 課題の行（GameFlow.cs:241 の SayStory）は ★字幕に出さない★、InnLines にだけ。
- 物語の日だけ（練習・自由は宿の行も課題も無い = 空）。
- API: 公開の項目が 1 つ増える = MINOR 0.19.0 → 0.20.0（ContractTests の一覧に 1 行足し）。
## 予測（回す前）
- P1 ContractTests: 一覧の差 = `+ PrepView.InnLines` の 1 行だけ（消える行 0）→ MINOR で通る。
- P2 RefCheck 5 日: events が 5 日とも動く、numbers は 5 日とも同じ。say の diff = ★課題の行の say が 1 行ずつ消えるだけ★（4-20 10483・7-20 22967・E′ 24083・F 23967・G 14967 ms）。ほかの say の時刻は同じ（課題の行は待ちから出ていた = 消えても 前後の行の時刻は変わらない、推論）。★ただし 課題の Story が出ていた間（4-20 3.9 s・E′ 0.35 s・7-20/F 20 s・G 12.3 s）に 譲って出なかった DayFlow の Status（ドラグ・休んだ 等）があれば 今度は出る = say が増える形がありうる（5 日で 0 の見込み、外れたら名指し）★。
- P3 LineSlotRefDaysTests の待ちの数 = 各日 1 つ減る: 4-20 1→0・7-20 2→1・E′ 1→0・F 1→0・G 1→0、捨て 0。
- P4 落ちる試験（書き直す）: DayCastTests（12/10 の字幕に「師匠（電話）」= :150）→ InnLines を見る形に。SameFrameSayTests（宿の行が字幕に出る）は通るまま。ChumTrailSessionTests・Chapter3DayTests・Chapter4ReferenceDayTests の events の pin は動く（#13 に）。ほかは通る。
- P5 新しい試験: 章の最初の日（9/1・12/1）と 4/20 の PrepView.InnLines = 宿の行 ＋ 課題の行（数と話し手）、字幕に課題の字が 1 度も出ない、練習の日は空。

## 足し（boss1 07:24・07:25 = worker2 の要件 2 つ、build の前に登録、07:3x）
- ★頁★: `PrepView.InnPage`（int、0 始まり）= ★InnLines の 1 要素 = 1 頁★（logic は画の幅を知らない = 行を束ねない。1 行は最長で 宿の行 約 50 字・課題の 1 行 約 40 字 = 07 の欄の 3 行に入る見込み、推論）。logic が持つ（07 の出入り・続きからで変わらない）。
- ★入力★: `InputFrame.AdviceNext`（bool、押した 1 frame）= 07 の配合の一覧で 頁を 1 つ進める、最後の次は最初（戻る方向の入力は無し）。釣具屋・他の画面では何もしない。キーは host が決める（worker2 の案 = N・△）。AutoPilot は false に落とす（ほかの鍵と同じ）。再生（replay）は名前で欄を合わせる（ReplayPlayer.cs:131 MapFields）= 古い再生 file は AdviceNext = 偽 で読める。
- ★日誌 J の頁は logic でなく Unity が持っている（観測: Journal0J.cs:30-34 `public static int Page`・◀▶ は ScreenHost）= 手本にはならなかった、07 の頁は logic が持つ新しい形★。
- P1 の直し: ContractTests の一覧の差 = `+ InputFrame.AdviceNext`・`+ PrepView.InnLines`・`+ PrepView.InnPage` の 3 行（消える行 0）→ MINOR 0.20.0。
- P6 新しい試験: AdviceNext を 1 回ずつ押すと InnPage が 0→1→…→N−1→0、07 を出て戻っても（釣具屋へ入って戻る）InnPage は同じ、宿の行も課題も無い日（練習）は InnLines 空・AdviceNext で InnPage 0 のまま。
- DayFlow.SayStory（GameFlow.cs:241 だけが呼んでいた）は呼び手 0 = 消した。

## 結果（観測、07:5x）
- P1 ★当★: ContractTests の一覧の差 = api 0.19.0→0.20.0・ApiVersion の定数・`+ field Boolean AdviceNext`・`+ field List<String> InnLines`・`+ field Int32 InnPage`（消える行 0）。
- P2 ★当★: RefCheck 5 日 = events が 5 日とも動いた（4/20 89bf92e4596b2e4b・7/20 1cd10aae7f794a68・E′ a79b688025c1dfdb・F 97d10bbfa62f948e・G 31fc7e069a8d5073）、★numbers は 11 とも #12 と同じ★（5 日 ＋ 種 1〜3 の 4/20・7/20）。log の diff（3838e10 の log と）= ★5 日とも 課題の行の say が 1 行消えるだけ★（4/20 10483・7/20 22967・E′ 24083・F 23967・G 14967 ms）、増えた say 0（譲って出なかった Status が出る形は 0 件）。
- P3 ★当★: 待ちの数 4-20 0・7-20 1・E′ 0・F 0・G 0、捨て 0（1 回目の全試験の [lineslot] 行）。
- P4 ★当★: 1 回目の全試験（07:38、書き直し前）= 失敗 11 = 待ちの数 5・events の pin 5（ChumTrail 3・Chapter3Day・Chapter4Reference）・DayCastTests 1、ほか 819 合格。
- 訂正（boss1 への 07:26 の便）: 「InnPage は続きからで変わらない」は誤り = 日の途中の続きからは DayFlow の作り直し = 0 に戻る。07 と釣具屋の出入りでは変わらない（InnLinesTests で確かめる）。15 §11 の下書きは正しい形で書いた。
