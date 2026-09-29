# 錠が解けた時の player の番 — 3 つの順の表（worker3、boss1 15:58。★Unity なし・案と dry-run の script だけ★、2026-09-29 16:0x）

- 読んだ所（観測）: ikada-unity の branch = track1/practice ea3919f（master ba3de36 の上 8 commit、pin ikada-sim 22e566a = API 0.21.0、font 4f51f12）・track1/goal-band 67a65c4（ba3de36 の上 2 commit）・track2/input-us 2d51b94（ba3de36 の上 1 commit、pin は ba3de36 のまま 777950e = API 0.20.0）。3 つとも根は master ba3de36（behind 0）。予測の doc = worker1 `PRACTICE_REVIEW_UNITY_W1.md` §7〜§10（:55-89）・worker2 `HOSTINPUT_US_PLAN_W2.md`（U1〜U5・P0〜P5）・私の `GOAL_BAND_W3.md`（R1〜R3）・input_test の数 = `PREP_PAGES_W2.md:65`（T19 で 83 → 91、master ba3de36 に入っている）。
- ★file の重なり（git diff --name-only master...branch、merge-tree で試した）★: practice（20 file）∩ goal-band（4 file）= ScreenRegistry.cs・FishingHud.cs → ★merge-tree で ScreenRegistry.cs だけ衝突★（両方が mock の Entry を同じ所に足した: practice の PS1・PS2 と goal-band の 06G、:47-54）= 解き方 = 両方残す（和）。FishingHud.cs は自動で合う。practice ∩ input-us = 0・goal-band ∩ input-us = 0（input-us = LiveHost.cs・HostInput.cs だけ）。

## 順（推奨 1 つ）: practice → goal-band → input-us（★1 つの回帰で 1 つの変更だけ = bisect★）
| 段 | 木（何の上に何を） | すること | 予測（出所） | 止める線 | 見込みの時間 |
|---|---|---|---|---|---|
| 0 | — | 錠が解けた・Unity 0・Ikada 0・Runner.Worker 0・dotnet 0・3 つの worktree の porcelain 0・master = ba3de36（script の dry-run） | 全部 通る | どれか = 止める | 1 分 |
| 1 | ★track1/practice ea3919f そのまま★（= ba3de36 ＋ practice だけ） | 回帰 REGRESS_LIVE=1 | ★15/15★、mock 26/26 0 px（練習でない = StrikeReview・PracticeSummary・Drill null）、live 2 種 logic = 基準・画 0 px（照合の日は練習でない、pin 22e566a は RefCheck #13 と同じ = logic の並びは動かない）、input_test checks=91（T19 は master に在る）、font の欠け 0（4f51f12 の 会機組誤送離）（W1 :85・:88、INN_LINES / PRACTICE_A の RefCheck #13） | 15/15 でない = 止めて W1 へ | 回帰 約 8 分（b06ae24 06:38→06:46・e525868 06:57→07:05 の観測） |
| 1b | 同じ木 | 練習の日の live 1 本（-ikadaLive … 練習・Drill = 組、HostInput でなく AutoPilot）で HUD の「組 k/10」と 答え合わせ・まとめの頁 | 「組 k/10」は 練習の日だけ（W1 :85）、答え合わせは 閉じた後だけ（13:685、ikada-sim の PracticeStrikeTests T1 の形） | 例外 > 0 | 約 3 分（未計測、推論） |
| → merge 1 | master ← track1/practice（PRESIDENT GO の後） | | | | |
| 2 | ★master（= ba3de36 ＋ practice）に track1/goal-band を merge した木★（ScreenRegistry.cs の衝突 = 和で解く、1 commit） | 回帰 REGRESS_LIVE=1 ＋ editor の 06G ＋ player の G（12/10 種 1）・F（10/15 種 1）の 06 の撮り（長い課題） | ★15/15★（照合の live は 4/20 = 第1章 = 今日の狙い = 短い字 = 帯は今のまま）、mock 26/26 0 px（mock の Goal は 今日の狙い・魚が掛かった = 短い）、G・F の 06 の右上 = 帯が 字の左端 − 40 まで伸び 字の下が暗い（GOAL_BAND_W3.md R1〜R3） | 15/15 でない・短い字の画が動く | 回帰 8 分 ＋ 撮り 3 本 各 1 分弱（前の G の撮り = RESULT steps 212 の短い run） |
| → merge 2 | master ← (段 2 の木) | | | | |
| 3 | ★master（= practice ＋ goal-band）に track2/input-us を載せた木★（rebase か merge、衝突 0 の見込み = file が重ならない。pin は master の 22e566a に = worker2 の Roslyn は 22e566a でも errors 0 = HOSTINPUT_US_PLAN_W2.md の U1） | 回帰 REGRESS_LIVE=1 | ★live は FAIL の見込み = logic sequence differs★（pilotT が float の和 → frame/60.0、9000 s で 23.9 s の差 = W2 P2・U3）、mock 26/26 0 px（U4）、input_test 同じ本数（U2）、key の日は変わらない（U5） | ★mock・input_test が動いたら止める★（live の FAIL は予測どおり = 次へ） | 8 分 |
| 3b | 同じ木 | 基準の差し替えの dry-run（`drafts/stageC/live_rebase.py`〔ikada-unity の tools に無い、workspace に在る = 観測〕、tag pre-us_）→ 表を boss1 → 画を PRESIDENT → GO → --apply | 差し替える file の数は ★dry-run の表で数える★（前例 pre-0200_ = 4 file〔unity_lock.log 06:37 の worker2 の FREE の行〕= 動いた画だけ。input-us は logic sequence が動く = RESULT・log は 2 種とも、画は 動いた分）| GO なし = apply しない | dry-run 2 分・apply 2 分 ＋ PRESIDENT の待ち |
| 3c | 同じ木 | 回帰 2 回目 | 15/15（差し替えた基準と byte 同じ = 決定的、W2 の前例と同じ形） | 15/15 でない | 8 分 |
| 3d | 同じ木 | ★F の穴の確かめ★: live F（10/15 種 1、lockstep・AutoPilot・speed 300、-ikadaLiveQuitAfterS 2830）の字幕の列を RefCheck F の log（ikada-sim main、2812017 ms「通りすがりの釣り人：割れてから待ちすぎかも…」）と比べる | ★2812.5 s の字幕が RefCheck と同じ行になる★（今は live だけ「ダンゴ、沈む途中で割れてますね…」= SUB_WRAP_W1.md:16-20 の外れ、原因の仮説 = pilotT の float の積みの遅れ ≈ 2812 s で約 −1.7 s〔W2 P2 の 600 s −0.10・3600 s −2.79 の間、推論〕）。live の回収の時刻の列（[Live] の log）が RefCheck F の log の cast/回収の時刻と同じ | ★合わない = 穴は pilotT 以外（H4）★ = 止めて記録（W2 へ） | 約 2 分（2830 s の lockstep、推論） |
| → merge 3 | master ← (段 3 の木) | | | | |
- ★合計の見込み（推論）: Unity の時間 約 45 分（回帰 4 回 × 8 分 ＋ 撮りと確かめ 約 10 分 ＋ dry-run・apply 4 分）＋ PRESIDENT の GO の待ち 3 回（merge 1・merge 2・差し替え）★。

## この順にした理由
- ★基準（live）を動かすのは input-us だけ★ = 最後に 1 回だけ差し替える（前の 2 つの回帰は 今の基準で「動かない」を確かめられる = 予測が強い）。input-us を先にすると 差し替えた基準の上で practice・goal-band を見る = 差し替えの誤りが後の 2 つに紛れる。
- practice を goal-band より先: practice は pin（API 0.21.0）と font を変える = 大きい方を先に 今の基準で「動かない」と確かめる。goal-band は practice の上で 衝突を解いた木を回帰する（衝突の解きの誤りも その回帰が見る）。
- 1 つの回帰に 1 つの変更: 段 1 = ba3de36＋practice、段 2 = (1)＋goal-band、段 3 = (2)＋input-us。赤が出たら その段の 1 つの変更が原因（bisect が 1 段で閉じる）。

## 未閉・注
- 段 1b の練習の live の出し方（-ikadaLive の練習の口・組の選び）は Unity 側の引数が在るか 未確認（W1 に聞く）。無ければ段 1b は editor の mock（W1 の 06R・PS1・PS2、既に c158・c159）で代える。
- goal-band の worktree は無い（track1 = practice、track2 = input-us）= 段 2 は track3 を detach して使う案（私の worktree、porcelain 0 を見てから）。
- F の穴の確かめ（段 3d）は input-us の 前と後の 2 回 走らせると 原因の切り分けになる（前 = 今の master の build で 2812.5 s が「沈む途中で割れて」、後 = RefCheck と同じ）= 陽性対照。前の 1 回は 段 1 の build で足せる（＋2 分）。

## script = `drafts/stageD/unlock_turn.sh`（dry-run だけ、16:01 に回した、観測）
- 錠の間の素の run = 「STOP: the screen is locked」（rc 1）= 錠の見張りが効いている。`--rehearse`（錠と Runner.Worker の見張りだけ外す、行に「NOT a go signal」）= master ba3de36・3 つの branch の sha・master の上か・3 つの worktree の porcelain 0 が通り、merge-tree = practice＋goal-band が ScreenRegistry.cs だけ衝突、他の 2 組は 0（上の表どおり）、段を印字して rc 0。陰性対照 `--expect-goal 1234567` = 「STOP: track1/goal-band is 67a65c4, expected 1234567」rc 1。
