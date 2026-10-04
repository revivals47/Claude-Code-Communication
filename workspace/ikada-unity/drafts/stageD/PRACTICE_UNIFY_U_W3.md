# 練習を 1 つにまとめる 案 — Unity の節（worker3。boss1 10:31・10:36: PRACTICE_UNIFY_PLAN.md は worker1 だけが書く、この file の字を worker1 が PLAN.md の U の〔〕に入れる。★案だけ・code は PRESIDENT が読んでから★）
- 決め・logic の節 = PRACTICE_UNIFY_PLAN.md（worker1）。codex の第二意見 = CODEX_PRACTICE_UNIFY.txt。
- 事故の記録: 10:3x に私が PLAN.md を上書きし worker1 の L の節（未 commit）を消した（無いのを見てから Write までの再確認を怠った）→ path を空け worker1 に作り直しを頼んだ（boss1 10:36）。

## 2. Unity の節（worker3, source = ikada-unity master c5125b3・ikada-sim 2750f49 を git show で読んだ）

### 2.1 今の形（観測）
- 練習の選びの頁 = Page.PracticeSelect（ikada-sim GameFlow.cs:101-108）= PanelView Kind Prep、Title「練習：数字を見ながら、ひとつずつ」、Note「練習では、毎投かならず魚が寄ってきて食ってきます」、Lines =「練習　<8 つの名>　⟦LeftRight⟧」「はじめる」→ Screen.Prep = 07（LiveScreens.cs:21）。07 は Lines を汎用に描く（Prep07.cs:104-127: 行の間 = min(80, 320/n)、題の帯 = Title の「：」より前、Note は板の下, ⟦Pause⟧ の印も置き換え :128）= ★07 は行の数・字に依らず描ける（Unity の練習の専用の code は 07 に無い）★。
- 06 の練習の部品 = PracticeParts（PracticeReviewPanel.cs:17-）: ① 課題の帯 = HudView.Drill（x 520–1460, y 170, h 36、2 行まで折り返し h 62 = drillDrop 26, :19-22・FitDrill）② アワセの答え合わせ = StrikeReview（帯の下 y 214–410, 時の帯 4 色・▼・時機／ストローク／結果, drillDrop の分だけ下へ :74-78）。FightReviewParts（FightReviewPanel.cs:25: X 520, Y 214, H 320 = y 214–534）= ファイトの答え合わせ。★2 つとも同じ置き場（上の中央）で、FishingHud.cs:93-94 が別々に Refresh★ = 今は 練習が 1 つずつ（StrikeReview = Drill.Strike だけ、FightReview = drill 7 だけ）なので重ならない。カードが開いている時（06C: EdgePanel x 1432–）は 右を 1420 で止める（:21・CardOpen）。英語なし（:28 BandWord）。
- 組のまとめ = PracticeSummary（Screens/PracticeSummary.cs: Page.Info の間だけ、Journal0J が Info の行の代わりに描く表、今回／前回／差）。
- 一時停止 = P1（Pause01.cs）= logic の Panel（Screen.Pause・Kind Pause）の Title と Lines を汎用に描く（行 76 px、板の高さ = 560 − (5 − n)×76 = 7 行まで足の帯にかからない :24・:40、⟦…⟧ の印を置き換え）。P2 設定（Settings02.cs）は ★Unity の mock の行（MockPause.Settings）を描く画面 = logic の状態を持たない★ = 練習の設定（logic の振る舞いを替える）の置き場には向かない。

### 2.2 07 の練習の選びの頁をどう替えるか
- ★worker1 の L: 選ぶ頁は無くなる（題の「練習」で すぐ練習の日）★ = 07 の練習の頁は出なくなる = ★Unity の code の替わり 0★（07 は汎用に描くだけ, Prep07.cs:104-127 = 頁が来なければ何も描かない）。
- 失う物 = 今の Note「練習では、毎投かならず魚が寄ってきて食ってきます」（#28, 依頼者）と「設定は ⟦Pause⟧ から」の案内 → ★置き場の案: 練習の日の最初の 06 の帯（HudView.Drill, 結果の帯と同じ所）に 最初の投までだけ 1 行★（logic の字, §1）= Unity の替わり 0。

### 2.3 練習の設定の板（一時停止から）
- ★推奨: 一時停止（P1）に 1 行「練習の設定」を足し、決定で ★同じ P1 の描き方で★ 設定の頁へ（logic が Title と Lines を替える = P2 のような Unity だけの画面は作らない）★ = Unity の code の替わり 0（Pause01.cs は Lines を汎用に描く、6 行 = 板の高さ 636 px = y 250–886、足の帯の上に収まる :24）。
- 行と字（英語なし、logic の字, §1 で決める。値は ⟦LeftRight⟧ で替える = 07 の形）:
  | 行 | 値 |
  |---|---|
  | 割れの目標（30±10 秒） | 入　／　切 |
  | ストロークの帯 | 入　／　切 |
  | 季節 | 春　／　冬（もたれ） |
  | はじまり | ふつうに落とす　／　アタリの前から |
  | 10 投のまとめ | 入　／　切 |
  | もどる | – |
- 題 =「練習の設定（次の投から）」。「アタリの前から」の時は 底取り・割れは数えない（codex）= その一言は logic の Note か行の後ろに（§1）。P1 は Note を描かない（Pause01.cs に Note の部品なし）= ★Note が要るなら Unity に 1 部品（板の下の 1 行, 07 の Note と同じ形）を足す = 小★。
- 「練習の板」（決め (3) の 2 つ目の入口）: 06 の中の板を新しく作るのは 画面の部品が増える = ★推奨は 一時停止の 1 か所★（入口が 2 つあると どちらで替えたか迷う）。板が要ると決まれば 06C の EdgePanel の行（ダンゴの札の行の並び）に足すのが近い（別の案）。

### 2.4 結果の 1 枚（今の答え合わせの置き場, 重ねない）
- 置き場は今のまま = 上の中央 x 520–1460（カードの時 1420 まで）、帯 y 170 ＋ その下の欄。★1 枚 = 直近の出来事 1 つの結果だけ★（新しい出来事が来たら前のは消える）:
  | 出来事（後だけ） | 帯（1〜2 行, logic の字） | 欄 | 消える時 |
  |---|---|---|---|
  | 着底 | 底を取れたか（例: 底を取れた） | なし | 次の出来事・次の投 |
  | 割れ | 割れの秒（着底から, 例: 割れ 28.4 秒）、補助 入なら ＋ 目標 30±10 の判定 | なし | 同上 |
  | 合わせた後／魚が離れた後（答えが閉じた後） | 一言（結果） | アワセの答え合わせ（今の StrikeReview の欄 y 214–410）。★ストロークの帯 切 = logic が Stroke を空・Band を −1★ → Unity は Band < 0 なら ▼ の横の語を描かない（今もそう :32）、Stroke が空なら「ストローク」の行を描かず「結果」を上へ詰める（今は空でも「ストローク　」を描く :37 = (c) の直し） | 次の投（今と同じ） |
  | ファイトの後（記帳の後） | 一言（終わり方） | やり取りの答え合わせ（今の FightReview の欄 y 214–534） | 次の投（今と同じ） |
  | 10 投の組の終わり（まとめ 入） | – | J の組のまとめの頁（今の PracticeSummary のまま） | 決定 |
- ★Unity の替わり（小, 06 の部品の中だけ）★: (a) FightReviewParts を 帯が 2 行の時に drillDrop だけ下げる（今は Y 214 固定 = FightReviewPanel.cs:25 = 帯の 2 行目 y 196–232 と重なる。PracticeParts は下げている :78）、(b) 守り = StrikeReview と FightReview が同時に来たら ファイトの方だけ描く（★worker1 の L: logic が新しい方だけを入れ古い方を null = (b) は通常は通らない守り, 1 行★）、(c) Stroke が空なら ストロークの行を描かない（上）。
- 帯の字（割れの秒・底取り・一言）は logic の 1 つの欄（今の HudView.Drill を「直近の結果」として使う か 新しい欄、§1・§3）。Unity は今の帯をそのまま使う（FitDrill の 2 行折り返し）。
- 穂先が先（13 §9.1-2）: どれも出来事の後だけ = logic の欄が出来事の前は null（今の StrikeReview・FightReview と同じ約束）= Unity は欄が null なら描かない（今のまま）。

### 2.5 試験の器（Unity 側）
- LivePractice（Live/LivePractice.cs:10-）は 07 の行 0 の名を ▶ で選ぶ（:50）= 選びが無くなるので ★-ikadaLivePractice の意味を「練習をはじめる ＋ 設定」へ替える★（例: `-ikadaLivePractice set`＝ アタリの前から＋10 投 = 旧 見送りの組、`winter`＝ 冬＋10 投、なし＝ 既定）= 一時停止の行を入力で進める（今の ▶ と同じ形）。撮りの名（06_review1・06_fight1・J_sum1/2）はそのまま使える。
- mock（MockPracticeReview・MockFightReview・MockPause）: 結果の 1 枚の形（帯＋欄）と 設定の頁の行を mock で撮れるよう 1 つずつ足す（IKADA_MOCK_PRACTICE の変種に「設定の頁」）。

### 2.6 撮りの予測（code の後, 回す前にもう一度登録する）
- 07: 行 1 つ「はじめる」・Note 2 文、題の帯「練習」（Title の「：」より前）。
- P1 → 練習の設定: 6 行、板 y 250–886、行の枠 y 420・496・…・800（76 px）、⟦LeftRight⟧ が ◀▶ に、英語なし。
- 06 の結果の 1 枚: 着底の後 = 帯だけ（h 36）、割れの後 = 帯だけ（補助 入で 2 行なら h 62）、合わせの後 = 帯 ＋ 答え合わせの欄（y 214–410、帯 2 行なら +26）、ファイトの後 = 帯 ＋ やり取りの欄（y 214–534、帯 2 行なら +26 = (a) の直しの陽性）、06C（カード開き）で右が 1420。★2 つの欄が同時に出る frame = 0★（(b) の守りの陽性 = mock で両方渡して ファイトの欄だけ）。穂先の絵（x ≤ 503）・ゲージ（x ≥ 1657）・3D の穂先（y 620–660）・字幕の帯（y 880 付近）と重ならない。
- J: 10 投 入 の組の終わりに 今のまとめの頁（変わらない）。
- regress: 練習の mock の撮り（06 の練習・P1）は基準と違う（結果の 1 枚・設定の行）、他は 0 px（推論）。

## 3. 境の 1 行（worker1 の案に合意 = この字を worker1 が PLAN.md に）
- ★logic = 何を いつ 出すか（どの欄を null にするか・新しい結果だけを入れ古い方を null・設定の行の字と値）を決める。Unity = 渡された欄を 1 枚の置き場（上の中央 x 520–1460・帯 y 170 ＋ 欄）と 一時停止の頁に描くだけで、出すかどうかを計算し直さない（守りは 欄が 2 つ来た時に新しい方〔ファイト〕だけ描く 1 行のみ）。★

## 4. code（PRESIDENT 10:4x GO, track3/practice-unify = master c5125b3 から, PR の撮りの木とは別）— 予測（code の前, 動かさない）
- (a) FightReviewParts.Refresh(s, drop): 欄の根を (0, −drop) へ（PracticeParts と同じ手, PracticeReviewPanel.cs:78）、drop = PracticeParts の帯が出ている時の drillDrop（2 行で 26 px, 1 行・無しで 0）。(b) FishingHud: fightOn = FightReviewParts.Has(s) を先に取り、PracticeParts.Refresh(s, fightOn) は fightOn なら アワセの欄を描かない。(c) PracticeParts.Build: Stroke が空なら「ストローク」の行を描かず「結果」を 28 px 上へ。mock: MockPracticeReview に変種 S（Variant(1) と同じで Stroke ""・Band −1）。
- 予測:
  - ★今の 15 本の regress の基準は 0 px★（今の mock: IKADA_MOCK_FIGHT の撮りは帯なし = drop 0 で同じ位置、IKADA_MOCK_PRACTICE 1/2/3/L/D は Stroke が空でなく ファイトの欄なし = 同じ）。
  - 陽性 (a)+(b): IKADA_MOCK_PRACTICE=L ＋ IKADA_MOCK_FIGHT=1 の 06 の mock = 帯 2 行（y 170–232）・★アワセの欄は無く★ やり取りの欄だけ y 240–560（214+26）、帯と欄の重なり 0 px。陰性 = 今の code（c5125b3）で同じ env = 2 つの欄が重なる（アワセ y 240–436 と やり取り y 214–534）＋ やり取りの欄の頭 y 214 が 帯の 2 行目（y 196–232）と重なる。
  - 陽性 (c): IKADA_MOCK_PRACTICE=S = 時機・結果の 2 行（結果が ストロークの所 = 28 px 上）、▼ の横の語なし。陰性 = 今の code で S = 「ストローク　」の空の行あり（Band −1 で ▼ の横の語は今も無い）。
  - Roslyn 0、RuntimeRod 等 06 の外の file は触らない。
- LivePractice の扉: worker1 の版（設定の板の入口・行の字）が main に入るまで ★字の表は L1 の表の字で仮置き★（worker1 に (1) 入口の字と開き方 (2) 行の頭と値の語 (3) 題の「練習」の後の頁 を 10:39 に聞いた）= 走らせる確かめは worker1 の版の後。
- code 済（観測, track3/practice-unify, push なし, Roslyn 0）: bd777d6 = (a)(b)(c)＋ mock S ＋ MockPrep の practice0 が「なし」を自分で書く（PracticeDrills.Names が消えても compile が通る, 今の画は同じ字 = 0 px）、次の commit = LivePractice の扉（worker1 10:39 の字: 一時停止の 5 行目「練習の設定（次の投から）」→ 同じ Panel が 5 行、決定 = ▶、BackLong で戻る、PauseLong で閉じる; 字は file の頭の 1 表）。★今の pin 2750f49 では 一時停止に その行が無い = 扉は 900 frame で諦めの 1 行を出し run は続く = 走らせる確かめは worker1 の版の pin の後★。§2.3 の「6 行（もどる）」は worker1 の決めで ★5 行・もどるの行なし（BackLong）★ に替わった（この節の 2.3 の表は 6 行のまま = 下の決めが正）。
