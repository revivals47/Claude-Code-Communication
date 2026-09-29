# 練習 A「合わせの答え合わせ」の logic の案（worker3、boss1 12:11・PRESIDENT 12:0x。★案だけ・code なし・dotnet なし★、ikada-sim main 777950e を git show で読んだ、2026-09-29 12:2x）

## 1. 今の logic に在る物・無い物（観測、file:行 は ikada-sim main 777950e）
| 欲しい物 | 在るか | 所 |
|---|---|---|
| 魚の状態（CONTACT/TASTE/HOLD/TAKE） | ★在る（今の状態だけ）★ | `ChinuMode { Near, Contact, Taste, Hold, Take, Reject, Cooldown }`（Ikada.Logic/Ecology/ChinuAgent.cs:11）、状態の移り = ChinuAgent.cs:71-98。FishingSession は 毎 tick 全部の魚を回す（FishingSession.cs:320-339）が、残すのは TASTE の数（`_rec.Tastes`、:329）と 最後の TAKE の時刻（`TakeAtS`、:333）だけ |
| ★状態の区間（始まりと終わりの時刻）★ | ★無い★ | どこにも貯めていない（F1 の DebugView.FishState・StateCue は今の値だけ、RenderContract.cs:146・152、F1 のみ） |
| 合わせの時刻 | 在る（数だけ） | Hooksets()（FishingSession.Fight.cs:23-58）で `HooksetCount++`、時刻は残していない（NowS を読めば取れる） |
| 合わせた時の魚の状態 | ★在る★ | `McuHookset.fish_state`（装置が返す、Fight.cs:28 の文字の中に st{h.fish_state}） |
| ストロークの帯 | 在る | `LastBandId`（0 WEAK・1 OK・2 STRONG・3 SLOW）・`LastHookV`・`LastHookA`（Fight.cs:34） |
| 結果 | 在る（分かれ道） | `HookOutcome`：Hooked/Shallow → StartFight（:38-41）、Break → アワセ切れ（:43-45）、他 = 空振り（:47-55、Early の flag と EarlyConseq） |
| 魚が離れた（合わせなし） | ★無い★ | TAKE/HOLD から Reject・Cooldown・Near への移りを 誰も見ていない（ChinuAgent の Mode を読めば取れる） |
| 穂先の動きの記録 | ★無い（logic に）★ | 穂先の曲がりは Unity が RenderSnapshot（TensionN ほか）から描く = 再生は Unity が snapshot を貯める形が小さい（logic は区間の時刻を出すだけ） |

## 2. 足す所（案）
- ★記録は練習の時だけ★: `PracticeDrills`（Practice.cs）に 1 つの記録係（例 `BiteReview`）。DayFlow.cs:404 の `Drills.Tick(s)` は 全部の日に毎 tick 呼ばれるが、物語・自由の日は `Drill.None`（DayFlow.cs:120 `new PracticeDrills(plan.Drill)`、plan.Drill の既定 None）= switch に入らない（Practice.cs:32-35）= ★物語の日は通らない★。新しい Drill = `Drill.Strike`（「アワセの答え合わせ」、練習の選びに 1 行、GameFlow.cs:105・186）。
- FishingSession に ★読むだけの口★ を 1 つ: 今の魚ごとの (Id, Mode) と NowS（乱数を引かない・状態を変えない）。記録係は 毎 tick それを見て、状態が変わった時に区間を閉じる。
- 区間の始まり = 最初の CONTACT（★ダンゴが割れた後だけ★ = 穂先に出るのは割れた後、BiteCues は !DangoIntact の時だけ送る = FishingSession.cs:324-326。割れる前の CONTACT を区間に入れるかは 決め）。
- 閉じる時 = ①合わせ（HooksetCount が増えた、その時の fish_state・帯・v・a・結果）か ②魚が離れた（TASTE 以上まで行った魚が Reject/Cooldown/Near に戻り、合わせなし）。閉じた時にだけ 下の欄に入れる。
- 合わせの結果の言葉: 「掛かった」「浅い掛かり」「アワセ切れ」「空振り」「合わせずに離れた」。

## 3. RenderSnapshot に出す欄の形（API 0.21.0 見込み = MINOR、足すだけ）
```
public StrikeReviewView? StrikeReview;   // 練習（Drill.Strike）の時だけ、答え合わせが閉じた後だけ非 null（13 §9.1 2 を形で守る）
public sealed class StrikeReviewView {
    public int Seq;                       // 閉じるたびに +1（新しい答え合わせ）
    public List<BiteSpan> Spans;          // 区間の列、時刻は 最初の CONTACT = 0 からの秒
    public float StrikeAtS;               // 合わせの時刻（同じ時刻の軸）、合わせなし = -1
    public int StrikeState;               // 合わせた時の魚の状態（FishState の値、装置の fish_state）、合わせなし = -1
    public int Band; public float V, A;   // ストローク（0 WEAK・1 OK・2 STRONG・3 SLOW、-1 = 合わせなし）
    public string Timing = "", Stroke = "", Result = "";   // 分けた 3 つの言葉（時機・ストローク・結果、採点は混ぜない）
}
public struct BiteSpan { public int State; public float FromS, ToS; }   // State = FishState の値（Contact/Taste/Hold/Take）
```
- ★13 §9.1 2（13_desktop_mode.md:685「穂先より先にアタリを知らせる表示は出さない」）を形で守る★: 区間は ★閉じた後にだけ★ まとめて入る = 生の状態は欄に 1 度も出ない（アタリの途中は null か前の答え合わせのまま）。値は すでに穂先に出た過去だけ。
- 次の投で消す（投げたら null）か、次の答え合わせまで残すか = Unity の描き方の決め（案: 投げたら null）。
- 時機の言葉は 状態の名そのもの（例「TASTE で合わせた」「HOLD で合わせた」「TAKE で合わせた」「合わせずに TAKE が過ぎた」）。★HOLD で合わせたのを誤りとしない★（HOLD 40%・TAKE 85% は結果の率 = 言葉は「早い／遅い」の採点にしない、PRESIDENT の決め・codex 2 と同じ）。

## 4. RefCheck が動かない見込み（根拠の行）
- ReferenceRun は ★物語の日★（ReferenceRun.cs:66 StoryFrom・:70 AutoPilot Mode「ストーリー」）= Drill.None = 記録係は動かない（§2）。
- events の hash に入るのは page・say（字幕）・ev（RenderEvent）・hookset の帯（ReferenceRun.cs:86-96）、numbers は HUD の数（:98-103）= ★新しい欄 StrikeReview は どちらにも入らない★。FishingSession の読む口は 乱数も状態も変えない。
- = 予測 R0: RefCheck 5 日 ＋ 種 1〜3 とも events・numbers とも #13 と同じ（1 文字も動かない）。
- 契約: ContractTests の一覧 = `+ RenderSnapshot.StrikeReview`・`+ StrikeReviewView` の欄・`+ BiteSpan` の欄 = 足すだけ = MINOR 0.21.0。

## 5. 試験の案と予測（回す前に登録する形）
- T1 練習（Drill.Strike）で 決めた種の 1 投: アタリの途中の全部の frame で StrikeReview == null（13:685 の形の試験 = 陽性対照: わざと途中で入れる写しの期待で赤）、合わせた frame の後に 非 null、Spans が CONTACT から時刻の順・重ならない・StrikeAtS が最後の区間の中。
- T2 合わせの時の StrikeState が 装置の fish_state と同じ、Band が LastBandId と同じ（同じ 1 つの出所 = Fight.cs:34）。
- T3 合わせずに離れた投: StrikeAtS = -1・Result「合わせずに離れた」。
- T4 物語の日（4/20 の ReferenceRun と同じ種）で StrikeReview が 1 frame も非 null にならない ＋ RefCheck の値が #13 と同じ。
- T5 HOLD で合わせた時の Timing の言葉に「早い」「誤り」が入らない（字の試験）。
- 予測（数は code の後、回す前に埋める）: R0（上）、全体の試験 = 今の 839 ＋ 新しい 5 本、落ちるのは ContractTests（一覧 +3 の形）だけ → 書き直しで通る。

## 6. 決めてほしい所
- 区間を 割れる前の CONTACT から入れるか（穂先に出ない所を区間に入れない案 = 割れた後だけ）。
- 次の投で StrikeReview を消すか残すか。
- 1 投に 2 尾が寄った時（別の Id が CONTACT）= 合わせた魚（h.fish_id）の区間だけ出す案。

## 7. GO（boss1 12:15・PRESIDENT 12:2x）の後の形と予測 — ★code の前に登録★（12:2x）
- 決め: (1) 区間は割れた後から (2) 次の投で消す (3) 2 尾なら合わせた魚／離れた魚だけ。worker2 の要望: 投の種類・合わせごとの fish_state・band・outcome・Silent を A の記録に（ChinuAgent を 2 経路で読まない = B・C は A の記録だけを読む）。
- 木: ikada-sim-w3、branch `practice-a`（origin/main 777950e4ee1bc0572bbafe9bbf5de881eb992fc5 から）、A だけで 1 commit。
### 欄（API 0.21.0、MINOR）
```
RenderSnapshot.StrikeReview : StrikeReviewView?   // 練習の Drill.Strike の時だけ、答え合わせが閉じた後から 次の投まで非 null
StrikeReviewView {
  int Seq;               // 閉じるたびに +1（1 日の中で）
  int CastIndex;         // その投の番号（CastRecord.Index、1 始まり）= B の「投の種類」は この番号に B が付ける（A は種類を作らない）
  List<BiteSpan> Spans;  // 割れた後の その魚の区間、時刻は 最初の区間の始まり = 0 の秒
  float StrikeAtS;       // 合わせの時刻（同じ軸）、合わせなし = -1
  int StrikeState;       // 合わせた時の魚の状態 = 装置の fish_state（FishState の値 0 None・1 Contact・2 Taste・3 Hold・4 Take・5 Reject）、合わせなし = -1
  int Band;              // 0 WEAK・1 OK・2 STRONG・3 SLOW、合わせなし = -1
  float V, A;            // 合わせの速さ・加速（v_r_peak・a_r_peak）
  int Outcome;           // 装置の outcome（HookOutcome の値）、合わせなし = -1
  bool Silent;           // HooksetLedger.Silent（魚なし・arm なし・ダンゴの道 = 空合わせ）
  string Timing, Stroke, Result;   // 分けた 3 つの言葉
}
BiteSpan { int State; float FromS, ToS; }   // State = FishState の値（1〜4）
```
- 閉じる時: ①合わせ 1 回ごと（Silent も含む = 空合わせは Spans 空・Result「魚はいなかった」）②割れた後に TASTE 以上まで行った魚が 合わせなしで Reject/Cooldown/Near に戻った時（Result「合わせずに離れた」）。★どちらも 閉じた後にだけ 欄に入る★。
- 記録の本体 = `PracticeDrills.Reviews`（1 日の List<StrikeReviewView>、C の集計の出所）。FishingSession の読む口 = 今の tick の合わせの報告の列 と ChinuAgent の列（読むだけ、乱数・状態は変えない）。
### 予測
- Q1 RefCheck 5 日 ＋ 種 1〜3: events・numbers とも #13 と 1 文字も同じ（物語の日は Drill.None）。
- Q2 ContractTests の一覧の差 = `+ StrikeReview` と StrikeReviewView・BiteSpan の欄だけ（消える行 0）→ MINOR 0.21.0。
- Q3 全体の試験 = 839 ＋ 新しい 5 本、落ちる試験 0（ContractTests は書き直しの後）。
- Q4 T1: 練習の 1 日で 全部の答え合わせについて「閉じる前の frame では 欄が 前の答え合わせのまま か null」、閉じた frame から非 null、Spans は時刻の順・重ならない・割れた後だけ、StrikeAtS は最後の区間の終わりと同じ。陽性対照 = 閉じる前に入れる写しで赤。
- Q5 T4: 物語の日（ReferenceRun と同じ 4/20・種 20260925）で 欄が 1 frame も非 null にならない。
