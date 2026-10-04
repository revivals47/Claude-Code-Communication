# 遊べる版 0d13af2 の build（worker3, boss1 15:38 / PRESIDENT 15:3x GO）
master = 0d13af262c60e39078eec9f86f86f4a3a899b496 = e0c3850（track3/logic-a8cca9e c8b3adc）＋ track2/dev-view 177002a --no-ff。木 187b8c76 = 177002a の木（rev-parse, 観測）。pin ikada-sim a8cca9e（API 0.24.0）。

## PLAYABLE_NEXT.md §2 をこの sha に（観測 = 読んだ物）
| # | 確かめ | この sha で | 根拠 |
|---|---|---|---|
| 1・2 | regress 15/15・input_test | ★済★ = 177002a_152845 15/15（boss1 15:38）、木が同じ（187b8c76） | 同じ木 = 同じ build の中身 |
| 3 | StoryRun S0〜S7 | ★要る★ = pin が 2750f49 → a8cca9e で 物語の日の logic が変わった（練習の統合 = GameFlow・DayFlow の練習の道、小アジの向こう合わせ = 物語の日のファイトが増える、やり取り・RigLost）= 365 日の並びが同じか 秒が動くかは回すまで分からない | ikada-sim git log 2750f49..a8cca9e |
| 4・4b・5・6 | 4 日の画・03 の帯の字・D6・c30 §12 | 場所の字・地図・穂先の切り替えの道は この区間で変えていない（e0c3850 の差 = 練習の板・一時停止の板・07 の Note・pin・字 標、177002a = DevView = -ikadaDev の時だけ）。c30 は worker2 の新しい下書き | git diff c5125b3 0d13af2 の file |

## 予測（回す前, 動かさない）
- StoryRun（a8cca9e, -c Release）: ★S0〜S6 = 2750f49 の summary と行が全部同じ★（365/365・章の頁の順・終わりの頁の行・場所・課題の見出しと頁の数 83/88/84/83・S5 4 か所・RodLent/RodGiven）。★S7 sim = 220040 s から動く見込み（小アジの向こう合わせで 物語の日のファイトが増える = 日の終わりの頃のファイトで日が延びうる）、帯 220040 ± 3000 s★、wall 5〜8 分。
- dry: rc 0（陽性 = ikada-play/2cb67ab の folder sha 75dc972e…）。
- --apply: ikada-play/0d13af2 = ★file 176★（c5125b3 と同じ = 足したのは code と字）、★bytes 744,021,999 ＋ 0〜200 KB★（DevView・練習の板・Note の code、字「標」、logic の Game/Logic dll の差）。c5125b3 との差の file: Managed の Assembly-CSharp・Ikada.Game・Ikada.Logic（＋ Desktop/Native は変わりうる）・boot.config・globalgamemanagers(.assets)・resources.assets（字）・level0/sharedassets0（変わりうる）。Ikada.x86_64 は c5125b3 と同じ sha256（a9a83136…）。
- 起動の確かめ: 4a ふだんの起動 = 題が出る・Exception 0、4b SessionProbe ok api 0.24.0、4c AutoPilot の 1 日 ok。★-ikadaDev★: ①-ikadaDev だけ（閉じた状態）= 開発の表示が出ない、②-ikadaDev -ikadaDevOpen（F1 を 1 回 = DebugToggle を 1 frame, LiveHost.cs:267）= 開発の表示が出る。★実の F1 の鍵を押す確かめは この環境に鍵を送る道具が無い（xdotool 等なし）= 未確認として書く★（F1 → DebugToggle は HostInput.cs:295, worker2 DEV_VIEW_W2.md:9 の観測）。閉じた後 player 0（/proc/<pid>/exe）。

## StoryRun S0〜S7 を a8cca9e で（観測, 15:41:24〜15:47:22, drafts/stageC/storyrun_a8cca9e/, ikada-sim-w3 を a8cca9e に detach → 後で w3/koaji-selfhook に戻した）
- ★S0〜S6 = 2750f49 の summary と行が全部同じ★（diff 0 行; 365/365・章の頁の順・終わりの頁の行・場所・課題の見出しと頁の数・S5 4 か所・RodLent/RodGiven）。storyrun.log 737 行も 頭の 3 行の後は diff 0 = 日と頁の並びは 1 行も違わない → ★当たり★。
- ★S7 = 外れ★: sim ★213468 s★（2750f49 220040 s から −6572 s = −3.0%、予測 帯 ±3000 s の外、向きも逆 = 延びる見込みと書いたが 縮んだ）。wall 5.8 分（予測 5〜8 分 当たり）。どの日で縮んだかは log に秒が無いので ★未特定★（推論: 小アジの向こう合わせで サシエを失う・仕掛けの在庫が早く尽きて 日が早く終わる日がある見込み = FishingSession.Stock / DayStock の道, 未確かめ）。
- 後片付け: dotnet の compile server（VBCSCompiler, StoryRun の build の残り）を build-server shutdown で止めた → dotnet 0。
