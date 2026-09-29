# 案 1: 章の境のセーブ → 続きから で その章の課題の行を出す（worker3、boss1 16:09・PRESIDENT 16:1x GO。★code の前に登録★、2026-09-29 16:1x）

- 木: ikada-sim-w3、branch `border-issues`（af9cc7e7b73fa344ce8b6714f7833817d6db8a33 から、ローカル、origin に push しない）。版は 0.22.0 を最後の 2 の commit で 1 か所（この commit では ApiVersion を触らない）。原因と形 = NEXT_1_4_W3.md 案 1。
## 形（決めた所）
- `ChapterProgress.PendingIssues`（List<string>、新しい partial file）= 章の始め 3 つ（GameFlow.cs:363-364・Chapter3.cs:37-38・Chapter4.cs:45-46）が `StartChapter` の返す id を ここに入れる（GameFlow の memory の `_pendingIssues` を消す）。NextStoryDay は ★欠航の日の判じの後で★ 取り出して空にする（今は :210 で欠航の前に取り出す = 境の翌日が欠航なら 課題が出ずに消える = 同じ形の穴。欠航の日は 次の日まで持ち越す）。
- SaveCodec: `pendingIssues`（文字列の列）を ★空でない時だけ★ 書く・無ければ空で読む（RodLent・RodGiven と同じ = 他のセーブは byte が同じ、SaveCodec.cs:151-158 の決まり）。Version 1 のまま。
- ★(1a) 古いセーブを救う狭い規則（PRESIDENT の形）★: 続きからで読んだセーブで ① PendingIssues が空 ② Chapter ≥ 2 ③ 日誌に その章の日が 1 つも無い（= その章の初日の朝のセーブ、宿の頁は 1 度も出ていない）④ その章の課題に Active がある（= 出された印）の 4 つが揃った時だけ、その章の Active の課題の出す行を TaskId の順に 組み直す。新しい形の境のセーブは PendingIssues が空でない（第2章 task2_1・第3章 task3_1〜3・第4章 task4_1・4_2 は必ず出る = Unlock の無条件の行）= 規則に来ない。
## 予測（回す前）
- B1（陽性・境 3 つ）: StoryFrom 5/31・8/31・11/30（種 20260925、AutoPilot）を 境の頁（WriteSave の後の「第N章」の Info）まで回して 止め、同じセーブの path で 新しい session の 続きから → 最初の 07 の PrepView.InnLines = ★同じ種で 続きからをせずに通した時の その章の初日の InnLines と 同じ列★（宿の行 ＋ 課題の行）、課題の行が 1 つ以上。
- B1 の陽性対照: 今の af9cc7e の形（PendingIssues を消す = セーブから pendingIssues の鍵を外し 規則も無い）では 課題の行 0 = 赤。
- B2（1a の陽性）: B1 の境のセーブから pendingIssues の鍵を外した file（= 古い build の境のセーブ）で 続きから → 規則で組み直し = InnLines の課題の行が 通しの時と同じ（★外れうる所: 通しの時に StartChapter が 前の章の課題も出していれば その分は組み直さない = その差だけ違う、回した後に名指し★）。
- B3（1a の陰性）: 普通の日のセーブ（その章の初日を釣り終えた後の日の終わりのセーブ、鍵なし）で 続きから → 組み直さない（翌日の InnLines に その章の課題の行なし）。
- B4 普通の道: 今の InnLinesTests（9/1・12/1・4/20）がそのまま通る、日の終わりのセーブに pendingIssues の鍵なし（出した後）。
- RefCheck: 5 日 ＋ 種 1〜3 の 11 値とも #13（照合の日は通し、InnLines と セーブの中身は hash の外 ReferenceRun.cs:86-103。欠航の後へ取り出しを移しても 照合の日は欠航でない）。
- ContractTests: 変わらない（ChapterProgress・SaveGame は取り決めの外、公開の欄の変更なし）。全体の試験 = 今の数 ＋ 新しい試験、落ちる 0。

## 1 段目の結果（観測、16:1x、build と新しい試験だけ）
- build errors 0。BorderIssuesTests 3/3（境 3 つ）。★1 回目は 3 つとも落ちた = 私の誤り 2 つ★: ①日の終わりのセーブを写す時点が早かった（Flow.Day が替わった時 = AdvanceStory の WriteSave の前）→ DayIndex が増えた時に（GameFlow.cs:259-268 = DayIndex++ の後 同じ呼びで WriteSave）②B2 の assert を「通しと同じ」で書いた = 登録した『外れうる所』どおり、途中の日から始めた道では 前の章の課題（第1章 task1.issue = 底ば取れ、FishingDays ≥ 1 が条件 ChapterTasks.cs:163）も境で出る → 狭い規則は その章の課題だけ組み直す = assert を「その章の課題の数と通しの順」に直した。
- 境のセーブの pendingIssues（観測）: 第2章 = task1.issue,task2_1.issue（その章 1）・第3章 = task1.issue,task3_1〜3（3）・第4章 = task1.issue,task4_1・4_2（2）。B1 = 続きからの InnLines は 通しと同じ列（3 つとも）。B2 = 古い形（鍵なし）は 宿の行 ＋ その章の課題（1・3・2）を通しの順で。B3 = 日の終わりのセーブからの続きからは 課題の行 0（翌日の 07 の InnLines は空）。
