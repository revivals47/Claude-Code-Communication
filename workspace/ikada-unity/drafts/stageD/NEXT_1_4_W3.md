# 案 1（章の境のセーブ→続きからで その章の課題の行が出ない）と 案 4（譲られた竿を自由釣りで）（worker3、boss1 16:03・PRESIDENT 16:3x、codex の第二意見 CODEX_NEXT_PRIORITIES_0929.txt の G・C。★案だけ・code・Unity・dotnet なし★、ikada-sim main 22e566a を git show で読んだ、2026-09-29 16:1x）

## 案 1: 章の境の続きから
### 原因（観測、file:行 は ikada-sim main 22e566a）
- 章の始め 3 つ（★実際の境の数 = 3★: 第2章 GameFlow.cs:357-372 StartChapterTwo・第3章 GameFlow.Chapter3.cs:31-39・第4章 GameFlow.Chapter4.cs:39-47）が 同じ形: `_pendingIssues.AddRange(s.Progress.StartChapter(n, s.Date))` → ★すぐ WriteSave()★ → 章の頁 → NextStoryDay。
- `StartChapter(n)` = Chapter を n に・`Unlock(date)`（ChapterTasks.cs:141-147）。Unlock は Locked の課題だけを Active にし その時だけ出す行の id を返す（:152-157 Activate）= ★1 回しか返さない★。
- 出す行は ★GameFlow の memory の `_pendingIssues`（GameFlow.cs:352）だけ★に在り、NextStoryDay が取り出す（:210）。
- = 境の WriteSave の後で やめて 続きから（:144 `Save = loaded; … NextStoryDay()`）= 新しい GameFlow の `_pendingIssues` は空・課題はセーブで Active = Unlock も返さない = ★その章の課題の行が 07 の InnLines に 1 つも出ない★（c30 の既知）。
- 4 つ目の WriteSave（GameFlow.Chapter4.cs:89 EpilogueFour）は 課題を出さない = 境ではない（第4章の終わり）。= ★境は 3★（「4 つ」は 3 に訂正を）。

### 形（推奨）: 出す行を セーブに持つ
- `ChapterProgress.PendingIssues`（List<string>、出す行の id）を足し、`StartChapter` が返す id を ここにも入れる（章の始めで 1 回）。GameFlow の `_pendingIssues` を この欄に置き換える（:210 は `s.Progress.PendingIssues` を取り出して空にする）。
- セーブ = SaveCodec に `pendingIssues`（空でない時だけ書く、無ければ空で読む = RodGiven・RodLent と同じ形 SaveCodec.cs:74-75・:157-158）= ★SaveCodec.Version は 1 のまま★（古いセーブは読める）。
- 載せる条件: 境のセーブに PendingIssues が在れば、続きからの最初の日の NextStoryDay で 今までどおり InnLines に（DayFlow の宿の行 = InnLines[0] の後、出す順）。取り出した日の終わりのセーブは空。
- どの課題: StartChapter(n) が返した id そのまま（第2章なら task2_1… 、途中の日から始める試験の口では前の章の分も = 今の通しと同じ）。
- ★古いセーブ（ba3de36 の遊べる版で 境で書かれた物、PendingIssues の鍵が無い）★: そのままでは出ない。救うなら 読んだ時に「今の章の日がまだ 0 日（その章で釣った日なし）・今の章の課題が Active」なら その章の Active の課題の出す行を並べ直す（1 行の規則）= ★決めてほしい（依頼者が境のセーブを持っていれば効く、持っていなければ不要）★。
- 字幕・宿の行は変わらない（InnLines だけ）。API = PrepView の型は同じ = ★公開の欄の変更なし（0.21.0 のまま）★、SaveGame は取り決めの外。
### 試験の案（T1〜T4）と予測
- T1〜T3（境 3 つ）: StoryFrom 5/31・8/31・11/30 の日を回して 境の頁で止め（WriteSave の後）、そのセーブの file から 新しい session で 続きから → 最初の 07 の PrepView.InnLines = 宿の行 ＋ その章の課題の行（第2章 = task2_1 の 1 行＝6/1 に出る分、第3章 = task3_1〜3、第4章 = task4_1・4_2〔4_4 は 12/15 から〕= Unlock の条件どおり、数は 回す前に source で数えて登録）。
- T4 普通の道（続きからをしない通し）: 6/1・9/1・12/1 の InnLines が 今と同じ（InnLinesTests がそのまま通る）＋ 1 日の終わりのセーブの PendingIssues が空。
- 陽性対照: 今の main で T1〜T3 を回すと 課題 0 行 = 赤（直す前に 1 回）。
- RefCheck の予測: ★不変★（照合の 5 日は 通しの日 = 出す順と中身が同じ、InnLines は hash に入らない、WriteSave の中身も入らない ReferenceRun.cs:86-103）= 11 値とも #13。
- 全体の試験 = 今の数 ＋ 4、落ちる試験 0。

## 案 4: 譲られた竿を自由釣りで（店は後）
### 今（観測）
- 竿は 描きだけ（判定は変わらない、TackleGrades.cs:44-47 の注「The given rod in free fishing waits for the shop / belongings decision. It changes no judgement」）。今日の竿 = `TackleGrades.TodayRod(storyDay, rodLent)`（:48）= 物語の日で RodLent の時だけ 上の竿（チタン）、呼び手は SnapshotBuilder.cs:111-112 だけ（RodGrade・TipTitanium）。
- 譲り = EpilogueFour（GameFlow.Chapter4.cs:84 `RodGiven = true` → :89 WriteSave）= 物語のセーブに在る。
- ★自由釣りは 新しい空の SaveGame で始まる★（GameFlow.cs:163 `Save = new SaveGame { SaveSeed = Cfg.Seed }`、書かない）= 物語のセーブの RodGiven が 自由釣りから見えない。
### 形（推奨）
- 自由釣りの選びの頁（FreeInput、GameFlow.cs:151-170、行 3 つ = 場所・狙い・決定）に ★RodGiven の時だけ 1 行「竿　いつもの ／ 兄弟子の竿」★（←→）。RodGiven は 物語のセーブを 題の画面で読む時（続きからの有無を見る所）に 1 回読んで持つ（SaveCheck.TryLoad、読めない・無い = 行なし）。
- 選んだら DayPlan に 1 つ（例 `GivenRod`）→ `TodayRod` に「自由釣りで GivenRod」の枝を 1 つ（同じ表の上の竿 = 2 つ目の道を作らない、PRESIDENT 22:3x）= RenderSnapshot.RodGrade 2・TipTitanium true。★判定は変わらない（描きだけ）★。
- API: 欄は既に在る（RodGrade・TipTitanium、0.19.0）= ★型の変更なし★。ただし 選びの頁の行が 3 → 4 になる（PanelView.Lines の中身）= Unity の自由釣りの選びの描きが 行の数で固定なら 1 行足す（Unity 側、未確認 = 読んでから）。
### 試験の案と予測
- T5 RodGiven のセーブが在る時: 選びの頁に竿の行、兄弟子の竿を選んだ自由釣りの日の snapshot = RodGrade 2・TipTitanium true、いつもの = −1・false。
- T6 RodGiven の無い・セーブの無い時: 行が出ない（今の 3 行と同じ）、RodGrade −1。
- T7 物語の日は変わらない（RodLent の枝だけ、今の RodFieldsTests がそのまま通る）。
- RefCheck: ★不変★（照合は物語の日、TodayRod の物語の枝は同じ、自由釣りを通らない）。

## 案 3（worker2 の月）と 案 4（竿）の 自由釣りの選びの頁の行（boss1 16:06、worker2 の FREE_MONTH_PLAN_W2.md を読んだ）
- ★行の順（推奨）= 場所 ／ 月 ／ 今日の狙い ／ 竿（RodGiven の時だけ）／ 出かける★。boss1 の見込み（場所・月・竿・狙い・出かける）と 竿と狙いの順を替えた理由: ①月は場所で決まり（worker2 §1 の表）、狙いは場所で決まり 月でも意味が変わる（例 蒲江 12 月は クロの密度 0 = Places の KuroByMonth、worker2 F4）= 場所 → 月 → 狙い の順に 上から決まる ②★出たり出なかったりする竿の行を 出かける の直前に置くと 上の 3 行（0 場所・1 月・2 狙い）の番号が 竿の有無で動かない★ = code の行の番号と試験（worker2 の F2 の行の番号）が 竿の有無で分かれない。竿は他の行に依らない。行の数 = 竿なし 4・竿あり 5。
- ★Unity の描きは行数固定でない（観測、ikada-unity master ba3de36）★: 自由釣りの選びの頁は `Screen.Prep`（GameFlow.cs:80-86 の `_ => Screen.Prep`）= Prep07 の一覧 = `ListLayout(n)`（Prep07.cs:49-57）で 行の数から間を決める（高さ 320 px、PitchMax 80・PitchMin 30、Prep07.cs:39-40）= 5 行 = 間 64 px・流しなし、行の数が変わると 作り直し（Prep07.cs:104-105 `n != count` → RebuildReason.Panel）= ★Unity の code の変更なしで 4・5 行とも描ける見込み★（画は錠の後）。今の 07 の宿の頁は 7 行。
- API: 月（worker2 の DayConfig.FreeMonth を足すなら MINOR）以外は 型の変更なし。竿は DayConfig に足さない（試験は頁の ◀▶ で動かす）案 = 版を月の 1 回にまとめられる。
