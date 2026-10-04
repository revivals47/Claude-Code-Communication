# 遊べる版 521a92c の build（worker3, boss1 20:02）
master = 521a92c8b5e11f8317c9ba8bf4267992891880d8（dev-pin025 3f7ac9a と track3/rod-build a1f841d の --no-ff）、木 68d9b0e3 = integ/next-build 506dfab の木（rev-parse で同一, 観測）= regress 16/16（boss1）。pin ikada-sim b80715f（API 0.25.0）。build の木 = ~/Documents/ikada-unity（master, 編集・commit なし）。

## 予測（回す前, 動かさない）
- ★StoryRun（b80715f, -c Release）: S0〜S7 とも a8cca9e と ★全部同じ★（summary の全行 ＋ S7 sim 213468 s）★。訳（source, git diff a8cca9e b80715f の 10 file）: 足し = 開発の表示の読み出しだけ（EcoSim の BaitHpStart / LastBaitPecker「no rule uses them」、FishingSession の CastS / BreakAgoS / SashieWord、RenderContract / SnapshotBuilder の DebugView の欄）、Page.PracticeSelect の値の消し、ApiVersion 0.25.0、★GameClock.NextTideTurnH の式を DielTide へ（時間の飛ばし「次の潮の変わり目まで」= プレイヤーの時間の行 DayFlow.cs:112 だけが使う = AutoPilot の物語の日は押さない見込み）★。外れたら 時間の飛ばしを AutoPilot が通るかを log で。wall 5〜8 分。
- dry: rc 0（陽性 = 2cb67ab の folder sha 一致）。
- ★build: ~/Documents/ikada-play/521a92c = file 176（0d13af2 と同じ）・bytes 744,034,287 ＋ 0〜200 KB★（竿 V4 の code・material RodGold・logic の DebugView の欄 = level / sharedassets / dll の中、新しい file なし）、Ikada.x86_64 の sha256 = 0d13af2 と同じ（a9a83136…）。0d13af2 との差の file = Managed の dll・boot.config・globalgamemanagers(.assets)・level0・resources.assets・sharedassets0.assets（前の 2 回と同じ種類）。
- 起動の確かめ: 4a〜4c の script の確かめ ＋ -ikadaDev（閉じ・-ikadaDevOpen で開き = 開発の表示に 今回の足し BaitOn / Fish / Stealers / 投の秒が出る見込み）、Exception 0、player 0。

## StoryRun S0〜S7 を b80715f で（観測, 20:03:50〜20:09:52, drafts/stageC/storyrun_b80715f/, ikada-sim-w3 を b80715f に detach → w3/koaji-selfhook に戻した）
- ★S0〜S6 = a8cca9e と summary の行が全部同じ・storyrun.log も頭の 3 行の後 diff 0・S7 sim 213468 s（同じ）・wall 5.9 分★ → ★予測 全部 当たり★（時間の飛ばしの潮の式の替わりは 物語の通しに効かない = AutoPilot は押さない、の読みと合う）。
- 後: build-server shutdown、dotnet 0・VBCS 0（pgrep / ps で確認）。
