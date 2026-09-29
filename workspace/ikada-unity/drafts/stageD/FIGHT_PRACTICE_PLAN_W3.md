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

## 8. GO（boss1 18:25・PRESIDENT 18:4x）の後 — ★code の前に登録（18:3x）★
- 決め: (1) 切らさず・外さず浮かせる (3) 1 本ずつが先 (2) ★事後に 魚の動きの区間（走る・止まる・首振り・突っ込み ほか）の帯は出す、体力は出さない★、ファイト中は何も足さない。
- ★全部の魚で動きの区間を記録する形（足した 1 行）★: 動きの区間は FightAi の中の Phase を直に読まず、★logic が装置へ送る FightParams（毎 tick の送り、`Phase`・首振りの `ShakeMs`、FightAi.cs:366-392 の Build）の列から作る★ = 種（チヌ・クロ・ボラ・餌取りの掛かり）に依らず 同じ 1 つの道で 全部のファイトに付く。首振り = Pause の始めに送る ShakeMs の長さ（FightAi.cs:384）。
- 木: ikada-sim-w3、branch `fight-review`（origin/main d0118ce から、ローカル）。版 0.23.0。
### 欄（API 0.23.0、MINOR）
```
RenderSnapshot.FightReview : FightReviewView?   // 練習の新しい Drill.FightReview（「ファイトの答え合わせ」）だけ、1 本のファイトが日誌に書かれた時から 次の投まで
FightReviewView {
  int Seq; int CastIndex;
  int EndCause;          // 日誌の FightRecord.EndCause と同じ（FightEnd の値、1 取り込んだ・2 糸ふけ・3 首振り・4 張りすぎ・5 擦れ・6 巻かれ・8 やめた・9 口切れ）
  float Seconds;         // 日誌の FightRecord.Seconds と同じ
  float HarisuN;         // ハリスの強さ（世界の N）
  List<FightSample> Tension;   // FightSample { float S, N } = 装置の報告ごとの 世界の張力（TWorldN）、S = ファイトの秒
  List<FightSpan> Moves;       // FightSpan { int Kind, float FromS, ToS }: Kind = FightPhase の値（1 走る・2 止まる・3 向きを変える・4 突っ込み・5 横へ・6 浮く・7 寄る）
  List<FightSpan> Shakes;      // 首振り（Kind 0）
  List<FightSpan> Slack;       // 糸ふけ（報告の SlackStart〜SlackEnd）
  List<FightSpan> DragSlip;    // ドラグが滑った（DragSlipStart〜End）
  float SlackS, OverS;         // 糸ふけの秒（報告の SlackMs の和）・ハリスの 8 割を越えた秒
  string End, SlackWord, OverWord;   // 分けた 3 つの言葉（総合点なし）
}
```
- ★Stamina の欄は無い★（契約の一覧に Stamina の語が増えないことを試験で見る）。
### 予測
- Q1 RefCheck 5 日 ＋ 種 1〜3 の 11 値とも #13（照合は物語の日 = Drill.None、読む口は乱数・状態を変えない）、5 日の log は byte で同じ。
- Q2 ContractTests の一覧の差 = 版の行 ＋ `FightReview`・`FightReviewView`・`FightSample`・`FightSpan` の欄だけ（消える行 0）、`Stamina` の語は 足しの中に 0。
- Q3 練習（Drill.FightReview、種 20260925、AutoPilot、1800 s）で ファイト 2 本以上、各本で F1（ファイト中の全 frame で null、日誌に書かれた frame から非 null）・F2（EndCause・Seconds が日誌と同じ）・F3（糸ふけの帯の和 と SlackS の差 ≤ 報告 1 つ分 0.1 s × 本数ではなく 1 本あたり ≤ 0.25 s）・Moves は時刻の順・重ならない・最初の区間は 0 から。
- Q4 F4: 物語の 4/20 で 1 frame も非 null にならない。全体の試験 = 今の数 ＋ 新しい試験、落ちる 0（ContractTests は書き直しの後）。

## 9. 新しい試験の結果（観測、18:3x〜18:4x）と 外れ・私の誤り
- FightReviewTests 3/3（F1〜F3・F4・F5）。練習 1800 s（種 20260925）で ファイト 5 本、5 本とも 取り込んだ（EndCause 1）、区間の例 #1 = 走る・止まる を 6 回 繰り返し 45.4 s から 浮く、首振り 9、ドラグが滑った 4。
- ★私の誤り 2 つ（直した）★: ①次の投で消す を「CastRecord が替わった時」で書いた = 取り込んだ投は 日誌に書いた直後に Current が null になる = 1 frame も出なかった（F1 の陽性対照が i > 0 で落ちて見つけた）→ ★null でない新しい投の時だけ消す★ ②`SlackMs` を「報告ごとの時間」と読んで 足した = ★定義は 今の糸ふけが続いている長さ（C の slack_s は糸ふけの間 += dt、終われば 0、core/ikd_fight_risk.c:73-80・protocol/ikd_fight_msg.c:41,51）★= 足すと重ねて数える（F3 で 帯 0.30 s に対し 1.83 s）→ 1 回の糸ふけの最後の値を 1 度だけ足す形に（直した後 #3 = 帯 2 つ 0.26 s、#5 = 帯 5 つ 0.87 s、F3 の ≤ 0.25 s に入る）。
- ★予測の外れ 2 つ★: 最初の動きの区間は「0 から」（予測）→ 0.11 s（観測 = FightAi.PeriodS 0.1 ＋ 1 tick 0.01、5 本とも）。1 度目の直しで PeriodS と読んだのも外れ（2 度目）→ 測った形（PeriodS ＋ Dt）で assert。
- ★陽性の無い所（未閉）★: OverS（ハリスの 8 割を越えた秒）は 5 本とも 0.0 = AutoPilot の巻きでは 張りすぎが起きない = 0 でない値の試験が無い。切れた・外れた本も 0 本 = EndCause の 1 以外の言葉は この run で出ていない。物語の 4/20 の 1800 s は ファイト 0 本（F4 は 物語の日に欄が出ない形の試験だけ）。

## 10. 陽性の無い所を埋める 2 本（boss1 18:48、★回す前に登録★、18:5x）
- 形: 練習（Drill.FightReview）の日、AutoPilot で 仕掛けが底に着いたら `StartScenarioFight`（FightSlackTests.cs と同じ口）、その後は試験の手で:
  - F6 切れ: チヌ 55 cm・閂、★巻きを最大（Reel 1）・ドラグを上げ続ける（DragUp を毎 0.2 s）★ = 張りすぎ。予測 = EndCause 4（張りすぎて切れた）か 5（擦れて切れた）、End の言葉がそのどちらか、★OverS > 0★、日誌の FightRecord と同じ終わり方。
  - F7 外れ: チヌ 40 cm・閂、★巻かない・親指も離す（Reel 0・Thumb 0 = FightSlackTests の FreeLetGo）★ = 糸ふけ。予測 = ★SlackS > 0・Slack の帯が 1 つ以上★、終わり方は 2（糸ふけで外れた）の見込み。ただし 外れの閾値は ファイトごとに引く `pull_slack_ms`（0xFFFF = 外れない、core/ikd_fight.h:109）= 種によっては外れずに取り込み・切れになる → ★種を 1〜5 で回し 最初に EndCause 2 が出た種を 試験に固定★（その種の値を回した後に書く）。5 種とも 2 が出なければ 外れの陽性は この口では作れない = 記録して SlackS > 0 だけ assert。
- 全体を回し直す（FloatChainGuard の直しの後）: 予測 = 全体 877 ＋ 2 = 879、失敗 0、RefCheck 11 値 #13。

## 11. 陽性の 2 本の結果（観測、18:5x〜19:0x）
- F7 ★当★: 種 1 で 糸ふけで外れた（EndCause 2、糸ふけ 65.0 s、帯 1 つ）。
- F6 ★予測『切れる』は 2 回外れた★: ①ドラグを ファイト中に上げる形 = DayFlow.CanChangeDrag がファイト中 false（DayFlow.cs:174、DragStep.cs:33-37）= 上がらない、55 cm は取り込み（219 s、ドラグが 80 回滑った、8 割を越えた 0.0 s）②ファイトの前に ごく強く（8.0 N）にしても 種 3 は取り込み（最大 18.0 N、8 割を越えた 6.3 s）→ ★推論をやめ 種 1〜6 を測る形に★ = 種 1 で 張りすぎて切れた（11.6 s、最大 18.0 N、8 割を越えた 2.3 s）= 陽性。
- ★【訂正 19:1x = 単位違いの誤り、下の行は誤り】ドラグは装置の N（VirtualReel.cs:83 の t = DesktopRig.cs:45 の装置への指令 F）、張力とハリスは世界の N、GT = 世界 1 N あたりの装置の N（既定 0.5）= 8.0 N（装置）≒ 世界 16 N > ハリス 11.6 N = ドラグが効く前に 8 割を越えうる★。（誤りの元の行）設計への気づき: ドラグのいちばん強い 8.0 N は ハリスの 8 割（9.3 N）より下 = ドラグが効いている間は 8 割を越えない、越えるのは 衝撃の山（報告の TWorldN の瞬間値）だけ = OverS は「ドラグを強くして 巻き続けた」時にしか 0 でなくならない。OverS の線（8 割）を ドラグに合わせて変えるかは PRESIDENT の決め（今は変えていない）。
- 全体（全部の変更の後）879 = 合格 874・失敗 0・スキップ 5 = 予測どおり、RefCheck を最後の code で回し直し 11 値 #13・5 日の log byte 同じ。amend = ikada-sim-w3 fight-review a9b7b6447e2bc3ede90376437998222ce0b4db8e。

## 12. ドラグの線の欄（PRESIDENT 19:1x、★code の前に登録★、19:1x）
- 欄 = `FightReviewView.DragN`（float、★世界の N★ = DragSteps.ToNewtons(その日のドラグの段) ÷ FightParams.GT、ドラグが滑り出す力。ファイト中は変わらない = DayFlow.CanChangeDrag、1 つの値）。記録係へは DayFlow が今の段の N を渡す（DayFlow.cs:404 の Drills.Tick の行に引数 = 行数を増やさない）。
- 予測: ContractTests の差 = `+ field Single DragN` の 1 行（版は 0.23.0 のまま = 同じ commit に amend）。F1〜F7 はそのまま通る、足す assert = 既定のドラグ（中ほど 3.0 N・GT 0.5）の日の DragN = 6.0 N（±0.01）、F6 の ごく強く（8.0 N）の日 = 16.0 N、F6 の切れた種 1 の最大張力 18.0 N > DragN 16.0 N（ドラグの線を越えた山がある）。全体 879 ＋ 0 本（assert を足すだけ）= 879、失敗 0。RefCheck 11 値 #13。

## 13. 単位の直し（boss1 19:09-19:10・PRESIDENT 19:1x、★code の前に登録★、19:1x）
- ★単位の表（source の行、世界の N／装置の N）★: ハリス 2 号 = 世界 23.1 N（HarisuTable.cs:12-13）= 装置換算 11.57 N（FightAi.cs:146 = × GT、送る時 ÷ g FightAi.cs:429-438）。8 割 = 世界 18.5 N。ドラグ最強 = 装置 8.0 N（DragStep.cs:23、装置の F と比べる VirtualReel.cs:83・DesktopRig.cs:45）= 世界 16.0 N（÷ g_T、core/ikd_fight_risk.c:148）。★19:08 の私の訂正 1 は 世界と装置換算を混ぜた誤り（取り消し）、19:06 の気づきは 装置どうしで正しかった★。§11 の数（ハリス 11.6 N・8 割を越えた 2.3 s・6.3 s）は 記録係の誤り（装置換算のハリスを 世界の張力と比べた、PracticeFight.cs:60）の上の数 = 読まないこと。
- 形: ①`FightUnits.WorldN(deviceN, gT)`（gT > 0 なら deviceN / gT、float の割り 1 回 = 今の `m.X /= g` と同じ bit）と `FightUnits.DeviceN(worldN, gT)`（× gT）を Ikada.Logic.Fight に 1 か所、呼ぶ所 = grep の全数（FightAi.cs:146・:438-439・:445、FightAi.Rest.cs:48 は double の掛け = `DeviceScale` を足して同じ式）②記録係: HarisuN = 送る値そのまま（世界）、DragN = WorldN(ToNewtons(段), GT)、FightSample に PeakN（報告の TWorldPeakN、世界）を足す。
- 予測: RefCheck 11 値 #13・log byte 同じ（割り・掛けの bit は変わらない）。HarisuN = 23.1 N（世界、±0.05）= 陽性対照。DragN = 中ほど 装置 3.0 → 世界 6.0、ごく強く 装置 8.0 → 世界 16.0（陽性対照、GT 0.5）、GT を 0.25 にすると 32.0（値が GT で動く）。★F6（ごく強く・巻き最大、種 1〜6）で OverS > 0（世界 18.5 N を越える報告の値）の種は 0 の見込み★（種 1 の最大 18.0 N、世界）= その時は OverS > 0 の assert を外し、切れの形を「山（PeakN）の最大 か 衝撃」で書く = 決めの材料として 種ごとの 最大 N・最大 PeakN・終わり方 を並べる。全体 = 879 ＋ 新しい試験、失敗 0。
- 足し（PRESIDENT 19:2x、回す前）: 種 1 の切れの前 10 s の 3 本（世界の張力 N・名目の 8 割 18.5 N・強さ S）の表と線の画。★S = H × (1 − 衝撃) × (1 − 擦れ) のうち 擦れ は報告の Wear で読める、衝撃（C で dT/dt > shock_rate の時 × (1 − shock_gain)、core/ikd_fight_risk.c:93-94）は 報告に無い = 記録係から読めない★ → 表は H × (1 − Wear)（衝撃なしの S）と 山 PeakN を出し、衝撃の分は「読む口を足す案」= C の報告に その時の S_eff（または衝撃の 0/1）を 1 欄足す（ABI の変更 = PRESIDENT の決め）。予測: 種 1 の切れの時 PeakN の最大 ≥ H × (1 − Wear) × (1 − ShockGain)（衝撃で下がった S を山が越えた）、Wear は 0.1 未満。

## 14. 線の決め（PRESIDENT 19:3x）の後 — ★code の前に登録★（19:3x）
- 決め: 線 = 名目の 8 割・ドラグ の 2 本 ＋ 跳ねの ▲ ＋ 終わり方「衝撃で切れた」（張りすぎで切れた かつ 最後が跳ね）、ABI 不変。
- ★(1) C の定数を写さない★: 衝撃の閾値と 3 割は C の `ikd_fight_preset`（core/ikd_fight_draw.c:75-103、:102 shock_gain 0.3・:103 shock_rate_Nps 200〔PC の装置換算〕）が FightParams に入れ（NativeFight.cs:22 の P/Invoke）、FightAi が送る（:421 ShockGain、:440 ShockRateNps は WorldN で世界へ）= ★記録係は 送った FightParams の ShockGain・ShockRateNps を読む = C の値の 1 か所から★（C# に 400・0.3 の数字を書かない）。掛かりの 0.3 s は 送る ShockGain が 0（FightAi.cs:421）= ▲ を付けない。
- 欄 = `FightReviewView.Jolts`（List<float>、▲ の秒 = 報告どうしの張力の上がる速さ〔世界の N/s〕が 送った ShockRateNps〔世界〕を越えた報告の時刻、送った ShockGain > 0 の時だけ）。終わり方の言葉 = EndCause 4 かつ 最後の報告に ▲ → 「衝撃で切れた」、ほかの 4 は 「張りすぎて切れた」のまま。
- 予測: (2) 陽性 = 種 1（F6）の ▲ = 11.57 s の 1 つ（最後の報告、6.73 → 16.31 N/10 ms = 958 N/s > 400 N/s）、End = 「衝撃で切れた」。陰性 = F1 の取り込みの 5 本は ▲ 0（巻きの揺れは ±2.5 N・約 1.4 Hz = 約 22 N/s ≪ 400 N/s、観測の画 c163 の 2.6〜6.1 s から）。(3) 種 1〜20 の F6（ごく強く・巻き最大）で EndCause 4 のうち 最後に ▲ が無い件数 = ★0 の見込み、ただし C の速さは 1 ms ごと・報告は 10〜20 ms ごと = 平らに均されて見落とす件が出うる★（出たら 言葉は ▲ に頼らない字へ = PRESIDENT の条件）。RefCheck 11 値 #13。全体 = 880 ＋ 新しい試験、失敗 0。契約の差 = + `Jolts` の 1 行。

## 15. ▲ の結果（観測、19:3x）
- (1) ★当★: 記録係が読む 衝撃の値 = 送った FightParams = 世界 400 N/s・0.3、C の ikd_fight_preset = 200（PC の装置換算）・0.3 = WorldN(200, 0.5) = 400 で同じ（F10）。
- (2) ★当★: 陽性 = 種 1 の ▲ は 11.57 s の 1 つ（切れの報告）。陰性 = F1 の取り込み 5 本は ▲ 0。
- (3) ★外れ（予測 0）★: 種 1〜20（ごく強く・巻き最大）で 張りすぎの切れ 18、★最後の報告に ▲ が無い 4（種 4・5・11・17）★ = 報告の列（10〜20 ms）が C の 1 ms ごとの跳ねを均して見落とす。18 とも 最後の張力 16.20〜16.47 N（世界）< 新しいハリス 23.13 N = 全部 衝撃で下がった強さ（16.19 N）を越えた切れ。取り込み 2（種 3・9）は ▲ があっても切れなかった（▲ 3・1）。→ ★PRESIDENT の条件どおり 言葉は ▲ に頼らない = 張りすぎの切れ（EndCause 4）は 全部「急に強く引かれて切れた」、▲ は描く★（「衝撃で切れた」「張りすぎて切れた」は使わない）。
- ★足し（boss1 19:33、回す前）★: 張りすぎの切れの言葉 = 最後の張力（世界 N）と 新しいハリス H（世界 N）の比べ（どちらも見える値）: < H =「急に強く引かれて切れた」・≥ H =「張りすぎて切れた」。F11 = ごく強く ＋ 親指 1（VirtualReel.cs:83 = クラッチが入っている時 滑り出す力 = ドラグ ＋ 親指、:17 ThumbMaxN 装置 6.0 N）＋ 巻き最大、種 1〜10。★予測: 滑り出す力 = 装置 8.0 ＋ 6.0 = 14.0 N = 世界 28 N > H 23.13 N = H を越える切れが 1 つ以上（最後の張力 ≥ 23.13）★。0 なら「越えない」を数で書き 言葉は 1 つのまま。

### F11 の結果（観測, 20:0x）と 次の予測（回す前）
- 観測: 最強ドラグ + 親指 1 + 巻き最大, 55 cm, 種 1〜10: 切れ 9（end 4）/ 取り込み 1（種 9）. 切れの最後の張力 16.34〜16.62 N（世界の N）, 全 fight の最大 18.57 N（種 9 取り込み）< H 23.13 N. **H 以上の切れ 0 件 = 予測（≥ 1 件）は外れ**。
- 推論: 滑り力（device 14.0 = world 28.0）は張力の上限であって, 魚の引きが H に届く前に 衝撃で下がった S（23.13 × 0.7 = 16.19 N）を越えて切れる。道具の強さでは H 越えの切れは起きない。
- 同時に見つけた bug（観測, PracticeFight.cs:117）: comment が BreakWear と Wrapped の 2 行を飲み込み, 擦れ・巻かれの切れが「終わった」になっていた（この版の前の commit 3d5b23a には無い = 本日の編集で入った）。直して F12（全 end が固有の言葉・None だけ 終わった）を足す。
- 次の予測（大きい魚 80 cm, 同条件, 種 1〜10, 回す前に書く）: 分からない。魚の引きが大きくなれば H 越えがありうる。0 件なら「道具最強・80 cm でも H を越える切れは 0」を数で書く。
- 80 cm の結果（観測, 19:4x）: 切れ 5, H 以上 1（種 10, 最後 23.17 N ≥ 23.13 N → 「張りすぎて切れた」= 陽性あり, 余裕は 0.04 N）。F11 は over ≥ 1 を assert に。5 本が やめた（Abort, 3.6〜6.2 s, 最後 0.16 N）= 原因未調査（④ 札: 材料 = Abort を出す口の全列挙）。
- 全体（Runner.Worker 0）: 884 = 879 合格 / 0 失敗 / 5 スキップ。RefCheck 11/11 = #13, 5 日の log は byte 一致。sha 661f934（fight-review, local, push しない）。

## §16 やめた（Abort）の訳（boss1 20:03 / PRESIDENT 20:1x）— source で読んだ事（観測）と 計測の前の予測

### 誰が Abort を出すか（source, 観測）
- C で ABORT を作る口は 1 つ: mcu/ikd_vdev.c:222-224（最後に受けた 0x05 の valid_until+hold から 1000 ms 新しい 0x05 が無い, :78）。ikd_fight_abort の呼び元はここだけ（grep）。PC は device の EndCause をそのまま記録（FightAi.cs:194-197 → FishingSession.Fight.cs:161）。
- 0x05 を device が取らない口は 3 つ（mcu/ikd_vdev_rx.c）: REJECTED（ikd_fight_params_invalid, :105-107, limit_flags に REQ_CLAMP）/ IGNORED（ikd_fight_update が 0, :111,122）/ STALE（seq, :158）。
- PC はその結果を 3 か所で捨てる: pc/src/Ikada.Game/IkadaSession.cs:221（lockstep）と pc/src/Ikada.Desktop/DeviceThread.cs:114（本物の device thread）。 と pc/src/Ikada.Logic/Story/RivalFight.cs:64（ライバルの fight, 長さ無し = 比 1）。
- 訂正（20:04 の便）: 「PC は毎 tick 送る」は誤り。FightAi.Tick は dirty か PeriodS 経過の時だけ送る（FightAi.cs:222）。

### 種ごとの長さの幅（source の表, 観測）と 戦いの大きさの比 L / L_ref（FightSize.RefCm）
| 種 | 掛かる長さの出所 | 幅 [cm] | L_ref [cm] | 最大の比 |
|---|---|---|---|---|
| チヌ（物語・自由） | EcoSim.cs:399 Range(30,50) | 30–50 | 40（EcoSpecies.cs:38） | 1.25 |
| チヌ（冬 12/1/2 月） | Chapter4Season.cs:18-20,42 | 30–52/53/51 | 40 | 1.325（1 月 53） |
| チヌ（練習） | EcoSim.Practice.cs:96 | 30–50 | 40 | 1.25 |
| クロ | EcoSim.Kuro.cs:21 | 20–45 | 26（EcoSpecies.cs:47） | **1.73** |
| クロ（練習） | EcoSim.Practice.cs:96 | 22–32 | 26 | 1.23 |
| キビレ | FishingSession.Kibire.cs:20 | 25–46 | 35（FightSize.cs:23） | 1.31 |
| エサ取り 8 種 + 夏 2 種（EcoSim.cs:76-80） | 長さ無し → FishingSession.Fight.cs:103-106 = l0 × [0.85, 1.15] | 例 ボラ 38.3–51.8 | l0 と同じ | 1.15 |
| 真鯛 | 行が無い（EcoSpecies default 15 cm, arr 0）・Stealers にも Places.Targets（Places.cs:27,80,83,87）にも無い | 掛からない（推論: 生む口が無い） | 40（FightSize.cs:23） | — |
- 真鯛 〜79 cm（27 §3）は 設計の表で 実装に生む口が無い（grep Species.Madai: DielTide / SpeciesHooking / FightSpecies / FightSize / SmallMadai のみ）。

### 計測の前の予測（回す前, 動かさない）
- 境は 比 1.375（チヌ 55 cm, 0/10）と 2.0（80 cm, 5/10）の間。遊びで入りうる最大の比は **クロ 45 cm = 1.73** → この間 = 読みでは決まらない = 計測で決める。
- 80 cm 種 1 の最初に取られなかった 0x05: 種類は REJECTED と予測（IGNORED/STALE でない）、時刻は Abort の 3.6 s − 約 1.0 s 前後。欄は分からない（静的 2 回外し: shake 3.0 cap / F_floor 0.3）。残る候補 F_bias×g ≤ F_limit / x_anchor_max ≤ 50 / yield ≤ 10 / tow ≤ 10 / slack_N×g ≤ 2.0 のどれか。
- 計測: (a) 取られなかった 0x05 を 新しい Vdev に 1 欄ずつ 直前の取られた値へ戻して push → Ok に変わる欄 = 拒んだ欄（C の検査そのもの, 定数を C# に写さない）。(b) 境: クロ 45 cm 種 1〜10 / チヌ 53 cm 種 1〜10 の 取られなかった 0x05 の数。0 なら「遊びでは起きない」を数で。

### §16 計測の結果（観測, 20:1x-20:2x, ikada-sim-w3 fight-review 661f934 + 試験だけ FightRejectTests.cs, logic 不変）
- 器: 送った 0x05 を 0.01 s 刻みで全部集め 新しい Vdev(null) に push（C の検査）。陽性陰性 M0 緑（preset = Ok / fight_id 0 = Rejected, 犯人に FightId）。
- 器の穴 1 つ（1 回目で見つけて直した）: 着いた後の END（Flags 20）を 新しい device は IGNORED で返す（END は生きた fight しか終わらせない, ikd_vdev_rx.c:109-111）= 再生の artefact。拒みの数から除いて別に数える。
- M1 チヌ 80 cm 種 1: 送った 63 通のうち REJECTED 13。最初 = pause（phase 2）の **YieldN 10.40 N（世界）> C の yield_N ≤ 10（core/ikd_fight.c:58）**、直前の取られた値 0。予測（REJECTED・欄は候補のうち）は当たり、欄は yield（候補に挙げたうちの 1 つ）。
- M2 クロ 45 cm 種 1〜10: REJECTED 0/10, やめた 0。YieldN 最大 0.00（rest model はチヌだけ, FightAi.Rest.cs:25）。
- M2 チヌ 53 cm 種 1〜10: REJECTED 0/10, やめた 0。YieldN 最大 4.56 N（世界）。
- 法則（推論, 2 点で合う）: YieldN 最大 = 2.6 × a（世界 N）, a = (L/40)²（FightAi.Rest.cs:30,83）。53 cm: 4.56 / 80 cm: 10.40, 比 0.438 = (53/80)² 0.439。10 を越えるのは **チヌ L > 78.4 cm** だけ。
- 遊びの見積もり: 遊びのチヌの最大は 53 cm（冬 1 月）= 上限の 46 %。クロは yield を送らない。= 物語・自由釣りでは起きない（試験の scenario だけの大きさ）。ba3de36 の既知には入れない案。ただし 拒みを捨てる 3 か所は 訳と別に直す（PRESIDENT 20:1x (1)）。

### §17 拒みを捨てる 3 か所 → 1 つの記録 + 試験の赤（boss1 20:16 GO）— 予測（code の前, 動かさない）
- 形: Ikada.Logic.Fight.DeviceRxLog（1 class）。Note(返り, bytes, 時刻) を 3 か所（IkadaSession.cs:221 / DeviceThread.cs:114 / RivalFight.cs Push）が呼ぶ。Ok は割り当て無し（直前の取られた 0x05 を固定 buffer に写すだけ, DeviceThread の 「loop 内で割り当て無し」を守る）。Ok 以外だけ 1 行: 時刻・型・seq・返りの種類、0x05 の REJECTED は 欄と値（C の検査で 1 欄ずつ戻す = 計測と同じ, 読む側で計算）。DebugView に数と最後の 1 行（F1 のみ）。RivalDay の結果に拒みの行（足すだけ）。FightWire.TryDecodeFight を足す（Encode の鏡, 往復の試験 + CRC 壊しの陰性）。
- 予測 P1（陽性）: チヌ 80 cm 種 1（0.01 s 刻み）で session の記録 = REJECTED 13 行、最初の行の欄 = YieldN 10.4（取られた 0）、他の種類 0。試験はこれを赤にする形（「拒み 0」を assert する試験が落ちる）を 陽性対照として 1 本。
- 予測 P2（陰性）: チヌ 53 cm・クロ 45 cm 種 1〜10 = 記録 0 行（REJECTED も IGNORED も STALE も）。生の device は着いた後の END を取る（生きた fight）ので IGNORED は出ない、と読む（外れたら数える）。
- 予測 P3: 全体の試験は 緑のまま・RefCheck 11/11 不変（記録は読むだけ、送る物・順番を変えない）。ただし 既存の試験で わざと悪い message を push するもの（HookMessageTests / VdevNativeTests）は 自分の Vdev を直接使い session を通らない = 記録に来ない、と読む。
