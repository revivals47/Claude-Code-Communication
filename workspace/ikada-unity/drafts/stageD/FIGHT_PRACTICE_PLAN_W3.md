# D ファイトの練習の案（worker3、boss1 18:22・PRESIDENT 18:3x。★案だけ・code なし★、依頼者が戻ってから決めてもよい案。ikada-sim main d0118ce を git show で読んだ、2026-09-29 18:3x）

- 読んだ: codex の第二意見 2 つ = CODEX_PRACTICE_OPINION.txt の 5（ファイト練習は「掛けた状態から始め、1 つの課題に絞る」、竿先を読む力は補えない、操作中のスローは入れない）と CODEX_NEXT_PRIORITIES_0929.txt の D（1 技能に絞る、魚の状態を竿先より先に知らせない採点、操作感は夜）。13 §9.1（13_desktop_mode.md:684-685）= 1 魚の体力は出さない（HUD は「???」）・2 穂先より先にアタリを知らせない。

## 1. 1 技能（推奨 1 つ）= ★「糸を切らさず・外さず 浮かせる」★（取り込みまで持っていく）
- 理由: 失敗の形が 全部 logic の記録に在る（下の §2）= 採点が 測りだけで閉じる。切れる（張力・擦れ・巻かれ）／外れる（糸ふけ・首振り・口切れ）の分かれが そのまま答え合わせの言葉になる。ドラグの出し入れは この 1 技能の中の手の 1 つ（ドラグが滑った時間を 答え合わせに 1 行出すだけ、採点しない）= 2 技能に割らない。
- 候補の外: 「ドラグの出し入れ」単独（良い出し入れの基準が 魚の走りの内の値に依る = 事後でも 魚の内を見せる量が増える）。

## 2. 今の logic の記録（観測、file:行 は ikada-sim main d0118ce）
| 欲しい物 | 在るか | 所 |
|---|---|---|
| ファイトの終わり方 | ★在る★ | `FightEnd { Landed 1, PullSlack 2, PullShake 3, BreakTension 4, BreakWear 5, Wrapped 6, Abort 8, MouthTear 9 }`（Ikada.Logic/Fight/FightParams.cs:11-15）。日誌 `FightRecord(Species, EndCause, HookLoc, Seconds)`（JournalTypes.cs:66-80）= 1 ファイト 1 行、★時間の中の記録は無い★ |
| ファイト中の張力・糸ふけ・ドラグ | ★報告ごとに在る（貯めていない）★ | 装置の報告 `FightReport`（FightParams.cs:57-72）= `TWorldN`・`TWorldPeakN`（世界の張力と その間の最大）・`SlackMs`（糸ふけの時間）・`SlipOutM`（ドラグで出た糸）・`ReelInM`・`Wear`・`LoadNs`・`TautS`・`Events`（`FightEvents` :27-31 = SlackStart/End・DragSlipStart/End・LimitHit・HarisuBreak・HookPulled・ShakeEnd）。FishingSession.Fight.cs:128-150 の FightTick が 毎 tick 読む（`FightSlackM` などに使うだけ、列に貯めない） |
| 魚の内の値 | 在る（出さない物） | `FightAi.Stamina`・`Phase`（FightAi.cs:104-106、`FightPhase { Run, Pause, Turn, Dive, Side, Surfacing, Landing }` FightParams.cs:8）。F1 の DebugView だけに出る（RenderContract DebugView.FightPhase） |
| HUD に今出ている物 | 在る（出してよい物） | 張力のゲージ（HudView.TensionN、13 §9.1 の「張力は装置の推定値そのもの」）|
| 掛けた状態から始める口 | ★在る（試験だけ）★ | `FishingSession.StartScenarioFight(sp, lengthCm, loc, shallow, fightSeed)`（Fight.cs:78-87、internal、日の乱数を引かない）= 練習の組の中から同じ口を使える（同じ assembly） |

## 3. 採点（13 §9.1 に触れない形 = A と同じ考え）
- ★ファイト中は 新しい物を何も出さない★（今の HUD の張力のゲージだけ = 今と同じ）。★体力は 事後にも出さない★（1 は「常に ???」）。
- ★事後の答え合わせ（ファイトが終わった後だけ、次の投で消す）★: 張力の線（報告ごとの `TWorldN`、ファイトの秒の軸）に ハリスの強さの線（FightParams.HarisuN を世界の N に）を重ね、その上に 印 = 糸ふけの間（SlackStart〜End）・ドラグが滑った間（DragSlipStart〜End）・限界に当たった点（LimitHit）。下に分けた 3 つの言葉 = ★終わり方★（取り込んだ／張りすぎて切れた〔BreakTension〕／擦れて切れた〔BreakWear〕／巻かれた〔Wrapped〕／糸ふけで外れた〔PullSlack〕／首振りで外れた〔PullShake〕／口が切れた〔MouthTear〕）・★糸ふけの時間★（秒）・★ハリスの 8 割を越えた時間★（秒）。総合点なし。
- 魚の走り（Phase）を 事後に帯で出すかは ★決め★（出せば「なぜその時 張ったか」が分かる、ただし魚の内の値 = A の状態の帯と同じ扱いにするか PRESIDENT の決め）。推す = 事後だけ出す（A と同じ）、体力は出さない。

## 4. 練習の組 B の形に載せられるか
- ★載せられる見込み★: B の組（Drill.Miokuri・Winter、Practice.cs:32-33・:61-62・:96-97、10 投、先回り IkadaSession.LeadIn）と同じ形で `Drill.Fight`（「ファイトの組」）= 10 本、各本は 投げて着底したら 先回りで `StartScenarioFight`（魚の大きさ・掛かり所を 組の乱数 RngStream.PracticeSet で混ぜる = 40〜55 cm・閂／唇、【仮定】）→ 依頼者が取り込むか 切れる・外れるまで → 答え合わせ。組の終わりのまとめ（C の PracticeSummaryView の行）= 取り込んだ n/10・張りすぎで切れた n・糸ふけで外れた n・糸ふけの時間の中央値（前の組と並べる）。
- 物語の日は通らない（Drill.None）= RefCheck 不変の見込み。

## 5. logic の足し（案）と 版
- `FightRecorder`（練習の時だけ、PracticeStrike と同じ置き方）= 報告ごとの (秒, TWorldN, SlackMs, Events) を貯め、終わった時に `RenderSnapshot.FightReview`（`FightReviewView?` = Seq・EndCause・Seconds・HarisuN・`List<FightSample>`〔秒・張力〕・`List<BiteSpan 形の帯>`〔糸ふけ・ドラグ・（決めなら）Phase〕・3 つの言葉）。★Stamina の欄は作らない★。= API MINOR（0.23.0 見込み）。
- FishingSession に 読む口 1 つ（その tick の FightReport、読むだけ）= A の `TickHooksets` と同じ形。

## 6. 試験の案と予測
- F1 ファイト中の全 frame で FightReview == null、終わった frame から非 null（A の T1 と同じ形 ＋ 陽性対照 = 途中で入れる写しの期待で赤）。
- F2 EndCause が 日誌の FightRecord と同じ（出所 1 つ）、Seconds が FightAi.TimeS と同じ。
- F3 糸ふけの帯の長さの和 = 報告の SlackMs の和（±1 報告）。
- F4 物語の日（4/20）で 1 frame も非 null にならない ＋ RefCheck 11 値 #13。
- F5 契約の一覧に `Stamina` の語が 新しい欄として無い（13 §9.1 1 を形で守る試験）。
- 予測: 組の 10 本 = AutoPilot（今の巻きの手）で 取り込み 6〜9 本（今の FishSideTests・FightSlackTests の取り込み率から、推論）、切れ・外れの内訳は回してから。

## 7. 決めてほしい所
- 1 技能 = 「切らさず・外さず浮かせる」で良いか（ドラグの出し入れは その中の 1 行）。
- 事後に魚の走り（Phase）の帯を出すか（体力は出さない）。
- 組にするか（10 本）、1 本ずつの練習（B の前の A と同じ）から始めるか。推す = 1 本ずつの答え合わせを先（F1〜F5）、組は後。
