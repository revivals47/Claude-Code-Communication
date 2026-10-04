# 練習を 1 つにまとめる — 案（boss1 10:31 / PRESIDENT 10:1x の決め。★案だけ、code は PRESIDENT が読んでから★）

依頼者の原文（PRESIDENT 10:1x）: 「今練習モード、底取りとか季節だとか色々別れてますが、本当に分ける必要ありますか？練習内の機能で調整したほうがいいのでは？」。codex の第二意見 = drafts/stageD/CODEX_PRACTICE_UNIFY.txt（統合を推す）。

決め: (1) 入口は「練習をはじめる」1 つ (2) いつも出す = 済んだ操作の短い結果（出来事の後だけ = 13:685 のまま）(3) 練習の中の設定（一時停止か練習の板から、次の投から効く）= 補助（割れの目標・ストロークの帯）と条件（季節・はじまり・10 投のまとめ）(4) 結果は 1 枚、重ねない。

- logic の節 = worker1（この file の持ち主、boss1 10:36）。Unity の節 = worker3 の別 file（下の U）。境の 1 行 = 2 人の合意。
- 出所 = ikada-sim origin/main `2750f49`（API 0.24.0）。行番号は `git show 2750f49:` で読んだ物。
- 〔10:3x、作り直し〕worker3 の上書きで 1 度消えた（worker3 の連絡 10:36）→ worker1 が同じ中身で作り直した。

---

## L. logic の節（worker1）

### L0. 今の形（source）
- 8 つの選び: `enum Drill { None, Bottom, Break5, Bands, Strike, Miokuri, Winter, FightReview }`（Practice.cs:13）、名 = `PracticeDrills.Names`（:17）。練習を選ぶ頁 = GameFlow.cs:101-107（板）・:183-201（入力、`Drill = (Drill)_drill` :199）。
- 1 つの日に 1 つの Drill（`DayPlan.Drill` DayFlow.cs:54 → `new PracticeDrills(plan.Drill)` :121）。何を数え 何を出すかは Drill ごとの switch（Practice.cs:74-131）と 出す所の門:
  - アワセの答え合わせ `Review` = Strike か 組の時だけ（Practice.cs:30）。
  - やり取りの答え合わせ `FightReview` = FightReview の時だけ（:36）。
  - 組 `IsSet` = Miokuri・Winter（:32）→ `PracticeSetPlan`（DayFlow.PracticeSet.cs:14-15）。
  - HUD の 1 行 `Text` = 目標 ＋ 直前の結果 ＋（n/m）（:44-46）→ `HudView.Drill`（HudBuilder.cs:35）。
- 組と冬: `PracticeSetKind { None, Miokuri, Winter }`（PracticeSetPlan.cs:18）。10 投 = 本アタリ 6・触るだけ 3・来ない 1（:23）。冬 = 味見 2〜4 回・HOLD 3〜8 s・HOLD から TAKE へ 0.5（:27-29）。
- ★アタリの前から（lead-in）は 組の中にしか無い★: `LeadIn => _eco.Set != null && …`（FishingSession.PracticeSet.cs:18）、手渡しの時 = `SetCast.HandOverS`（:24）。★冬の HOLD も 組の魚にしか無い★（EcoSim.Practice.cs PracticeSetCast の `PracticeHoldMinS/MaxS/TakeP`、自由な練習の魚 PracticeCast には無い）。
- 自由な練習の魚 = チヌ 70・クロ 10・餌取り 20 %、割れの 10〜40 s 後（EcoSim.Practice.cs:23-27・PracticeCast）。
- 組の数の記録 = practice.json（PracticeHistory.cs、`format ikada-practice`・`version 1`・`kind` = PracticeSetKind の数、最新 20 組）。

### L1. Drill の 8 値をどう畳むか（推奨 1 つ）
- 1 日 1 つの Drill をやめ、★練習の日は いつも同じ 1 つの「練習」＋設定の組★にする。設定（新しい `PracticeOptions`、DayFlow が持つ、★次の投を落とす時に読む★）:

| 設定 | 値 | 前の Drill との対応 |
|---|---|---|
| 補助: 割れの目標 | 切／入（入 = 30±10 の よし・早い・遅い を足す） | Break5 の判定 |
| 補助: ストロークの帯 | 切／入（入 = 答え合わせに 弱い／ちょうど／強い の行） | Bands |
| 条件: 季節 | 春／冬（冬 = 冬のもたれ） | Winter の魚 |
| 条件: はじまり | ふつうに落とす／アタリの前から | 組の lead-in |
| 条件: 10 投のまとめ | 切／入（入 = 組のまとめの頁） | Miokuri・Winter の数え |

- ★いつも出す（Drill に依らず、練習の日なら）★:
  - 着底の後 = 底を取れたか（今の Bottom の字、Practice.cs:79-91）。
  - 割れた後 = 割れの秒（着底から、Break5 の秒の部分）。
  - 合わせた後・魚が離れた後 = アワセの答え合わせ（StrikeRecorder、今の Review の門 :30 を「練習の日」に広げる）。
  - やり取りの後 = やり取りの答え合わせ（FightRecorder、:36 の門を広げる）。
- 消えるもの:
  - 練習を選ぶ頁（GameFlow.cs:101-107・:183-201）。題の「練習」で すぐ練習の日へ。
  - `PracticeDrills.Names` の 8 つの名（設定の行の字に置き換え）。
  - 「なし」= 補助を全部 切 にした形。
  - 練習を選ぶ頁の Note（「練習では毎投 魚が寄ってきます。割れてから 30〜40 秒は…」、yaritori 254b7f3）も頁と一緒に消える → ★練習の日の最初の投まで `HudView.Drill` の 1 行に出す（logic の字、worker3 10:37 の案）★:「練習では毎投 魚が寄ってきます。割れてから 30〜40 秒は 穂先を見て待ちましょう。設定は ⟦Pause⟧ から」。1 投目を落としたら 消えて 結果の行に替わる。
- ★はじめの段は「今ある物の組み直し」だけにする（推奨）★:
  - 「アタリの前から」と「冬」は 10 投のまとめ 入 の時だけ選べる（行に「（10 投のまとめの時）」と出す）= 今の Miokuri（春）・Winter（冬）の組をそのまま使う。
  - 新しい魚の作りは 0。
  - 自由な練習（まとめ 切）での 冬・アタリの前から は ★新しい logic★: 自由な練習の魚に冬の HOLD を付ける、組でない投の lead-in。次の段として PRESIDENT が決める。
  - 理由: lead-in と冬の HOLD は 今 組の中にしか無い（L0）。
- 次の投から効く: DayFlow の Drop（FishingSession.Drop が投を作る所）で その時の PracticeOptions を読む。投の途中で替えても その投は替わらない。まとめを 入 にした時は 次の投から新しい組（今の StartPracticeSet、DayFlow.PracticeSet.cs）。まとめを 切 にしたら 途中の組は数えずに捨てる（今の「途中で終えた組は数えない」GameFlow.Practice.cs の注と同じ）。

### L2. PracticeSetPlan と冬の値
- PracticeSetPlan・冬の値（PracticeSetPlan.cs:23-29）・組の乱数 `RngStream.PracticeSet` は ★替えない★。まとめ 入 ＋ 春 = Miokuri、まとめ 入 ＋ 冬 = Winter を そのまま作る。
- 自由な練習の魚（PracticeCast）・その乱数 `RngStream.Practice` も替えない = まとめ 切・春・ふつう の練習は 今の自由な練習と同じ（PracticeBiteTests はそのまま通る見込み）。

### L3. セーブ（practice.json）の互換
- 読める: `kind` の数（Miokuri = 1・Winter = 2、PracticeSetPlan.cs:18）を替えないので、古い practice.json はそのまま読める（PracticeHistory.Read は format と version 1 だけを見る）。前の組との比べ（`Previous(sets, kind)`）も同じ kind で続く。
- 書く形も同じ（はじめの段では新しい kind を作らない）。次の段で まとめ 入 ＋ ふつう のような新しい組を数えるなら、kind 3 を足しても 古い版の読み手は「知らない kind」を数として読むだけ（Read は enum に cast するだけで弾かない、PracticeHistory.cs:73）【試験で確かめる】。
- 物語のセーブ（SaveGame）は練習では書かない（WriteLiveSave は Story だけ）= 触らない。練習の設定を覚えるなら practice.json か Unity の設定（PlayerPrefs）= 推奨は「覚えない」（はじめの段）。

### L4. 照合（RefCheck）不変の予測と訳
- 予測: ★11 本とも #15 のまま★。
- 訳: RefCheck は 11 本とも物語（AutoPilot Mode = "ストーリー"、ReferenceRun.cs:70）。物語の日の DayFlow は `PracticeDrills(Drill.None)` で、L1 の門は全部 `Plan.Mode == GameMode.Practice` の時だけ。練習の頁も通らない。
- 動く試験（直す物）:
  - Drill を名で選ぶ試験 4 file（FightReviewTests・PracticeSetFlowTests・PracticeStrikeTests・PracticeWordsTests、Drill の参照 9 か所）。
  - 練習を選ぶ頁を通る試験（PracticeFlowTests の Note・BackToTitleTests の練習・PracticeLeadInTests の入り方）。
  - 試験の数は 回す前に grep で数え直す。
- 古い録画（ReplayPlayer）: 練習の頁の押しを録った録画は 頁が無くなると押しがずれる。repo の試験の録画は 自由釣りと続きから だけ（15 の ReplayTests の行）= 0 の見込み。依頼者の手元の録画は 未確認。
- ★注（codex の指摘を source で確かめた）★: PracticeDrills は 物語の日にも作られ 毎 tick 呼ばれる（DayFlow.cs:121・:394、None は switch のどれにも当たらない = 何もしない）。だから「いつも出す」の記録係（StrikeRecorder・FightRecorder・着底・割れ）は ★`Plan.Mode == GameMode.Practice` を門にして回す★（Drill の値でなく）。門を付け忘れると 物語の日も答え合わせを作り、RefCheck は動かなくても（hash の行に入らない、ReferenceRun.cs:87）物語の画に答え合わせが出る。

codex 済（要点）: L0〜L4 の主張 6 つを 2750f49 で確かめ = lead-in は組だけ（FishingSession.PracticeSet.cs:18）・冬の HOLD は組の魚だけ（EcoSim.Practice.cs:114、自由な魚は :97 で Committed だけ）・Drill の enum は公開の listing に無い（api_contract.txt:184 は string、ApiListing.cs:29 が Flow をたどらない）・practice.json の kind は数を cast するだけ（PracticeHistory.cs:73）・物語の日は Drill.None で何もしない（上の注）・答え合わせを練習の日に広げても 物語と RefCheck は不変（門が Practice なら）。

### L5. 公開の形（ContractTests）の変わり
- ★推奨 = 公開の形を変えない（0.24.0 のまま）★:
  - Drill の enum は公開の listing に無い（api_contract.txt に Drill の型の行なし、`HudView.Drill` は string、api_contract.txt:184）。
  - 設定の行 = PanelView の行（字と ◀▶、今の板と同じ）。
  - 結果 1 枚 = logic が新しい方だけを入れる（下）。
  - ストロークの帯 切 = `StrikeReviewView.Stroke` を "" ★と `Band` を −1★（worker3 10:37 の頼み: Band ≥ 0 だと ▼ の横の語が出る = PracticeReviewPanel.cs:32）。−1 は 今も「none」の値（RenderContract.cs:214 `0 WEAK / 1 OK / 2 STRONG / 3 SLOW, -1 = none`）= 値の意味は替わらない。★注: 10 投のまとめは 記録の Band で「ちょうど」を数える（PracticeSetSummary.cs:38 `r.Band == 1`）= −1 にするのは 画へ渡す写しだけ、記録係（StrikeRecorder.Reviews）の Band は替えない★。
- 結果 1 枚（決め (4)）:
  - logic が決める = その時の一番新しい結果の欄だけを入れ、古い方は null。例: やり取りの答え合わせが出たら StrikeReview を null。
  - `HudView.Drill` の 1 行は「直前の結果」の短い字だけ（目標の字と（n/m）は 補助が入の時の 1 行目だけ）。
  - = 描く側で どれを出すか計算しない（同じ判断を 2 経路で作らない）。
- 変わるのは 欄の中身の門（いつ null でないか）だけ = ContractTests の listing は不変の見込み。帯の入り切りを Unity が別の欄で知りたいなら `StrikeReviewView.ShowStroke`（bool）の足し = MINOR 0.25.0（推奨しない）。

### L6. 規模の見込み【推論】
- logic: Practice.cs の switch を「いつも出す ＋ 補助」に組み直す。PracticeOptions と設定の板の行（DayFlow の新しい partial、500 行の目安）。練習を選ぶ頁を消す（GameFlow）。試験 約 10 file を直す・足す。
- はじめの段に 新しい魚の作りは無い。

### L7. code の前の予測（PRESIDENT 10:4x GO、branch ikada-sim-w1 yaritori の上。登録 2026-10-04 10:41:03）
- 字の決め（worker3 へ 10:39 に送った物）: 一時停止の 5 行目（練習の日だけ）「練習の設定（次の投から）」→ 同じ板が 設定の 5 行に替わる（戻るの長押しで戻る）。行 =「割れの目標（30±10秒）　入|切」「ストロークの帯　入|切」「10 投のまとめ　入|切」「季節　春|冬」（まとめ 切 の時「季節　春（冬は 10 投のまとめの時）」= 選べない理由を字で出す）・「はじまり」（まとめ 入 =「アタリの前から（10 投のまとめの時）」、切 =「ふつうに落とす（アタリの前からは 10 投のまとめの時）」）。替えられる行だけ ⟦LeftRight⟧。既定 = 補助 切・まとめ 切・春・ふつう。題の「練習」→ すぐ 07 支度。
- P1 RefCheck 11 本 = #15 のまま（物語だけ。新しい記録係・HUD の字・結果 1 枚は GameMode.Practice を門に）。
- P2 ContractTests = 不変（0.24.0）。Page.PracticeSelect の値は Unity の LivePractice が使うので 値は残し 使う code を消す（worker3 の替えの後に値を消す = 持ち主 worker1）。
- P3 自由な練習の魚・組・冬の値・乱数は替えない = PracticeBiteTests・PracticeLeadInTests は 直さずに通る見込み。直す試験 = PracticeStrikeTests・FightReviewTests・PracticeSetFlowTests（drill を反射で選ぶ所 → 設定へ）・PracticeWordsTests（Drill の名 → 設定の行の字）・PracticeFlowTests（選ぶ頁の Note → HUD の最初の 1 行）。BackToTitleTests は 通る見込み（練習の一時停止は 5 行、題へは 4 行目のまま）。
- P4 新しい試験 PracticeUnifyTests: 題→練習で選ぶ頁なし・1 投目までの 1 行・Drill なしで 答え合わせ 2 つ・結果 1 枚（やり取りの答え合わせが出たら StrikeReview は null）・設定の板の行と替え・次の投から効く（投の途中で替えても その投は替わらない）・まとめ 入 → 次の投から見送りの組（冬なら冬の組）・帯 切 → 画の Stroke "" ・Band −1、記録の Band はそのまま・物語の日は全部 null。全部 緑の見込み。

---

## U. Unity の節（worker3）
- ★別の file★ = [drafts/stageD/PRACTICE_UNIFY_U_W3.md](PRACTICE_UNIFY_U_W3.md)（804ba6a、§2 = Unity の節 2.1〜2.6。worker3 が持つ。boss1 10:36 = この PLAN.md の持ち主は worker1 1 人、U は分ける）。

## 境の 1 行（worker1・worker3 の合意。字 = PRACTICE_UNIFY_U_W3.md §3（804ba6a）をそのまま）
- ★logic = 何を いつ 出すか（どの欄を null にするか・新しい結果だけを入れ古い方を null・設定の行の字と値）を決める。Unity = 渡された欄を 1 枚の置き場（上の中央 x 520–1460・帯 y 170 ＋ 欄）と 一時停止の頁に描くだけで、出すかどうかを計算し直さない（守りは 欄が 2 つ来た時に新しい方〔ファイト〕だけ描く 1 行のみ）。★

### L8. 結果（4c7151f、2026-10-04 11:05〜11:24、drafts/stageD/unify_dotnet/run.log）
- build 警告 0・エラー 0。練習の試験（ContractTests・PracticeUnify 5・Strike・Fight・Set・Words・Flow・Bite・LeadIn・BackToTitle・Chum）= 64 本とも成功 = P2・P3・P4 当たり（ContractTests 不変 = 0.24.0 のまま）。
- RefCheck 11 本とも #15 = P1 当たり。
- ★外れ 1 つ★: 全試験 915 中 合格 909・失敗 1・スキップ 5。失敗 = ActionTokensTests.PracticeMarksAreWordsNotSymbols（Practice.cs の source を読んで `"よし"` の字を探す試験、ActionTokensTests.cs:46）。私が `"　よし"` と区切りの空白ごと書いたので字が見つからなかった（画の字は「よし」のまま）= 予測の「直す試験の list」から漏れていた（source を読む試験を grep していなかった）。→ 1502b30 で 区切りを字の外へ（`"　" + (ok ? "よし" : …)`）。この 1 本の回し直しは dotnet の合図で。
