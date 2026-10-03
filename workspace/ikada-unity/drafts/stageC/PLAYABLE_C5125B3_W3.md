# 遊べる版 c5125b3 の支度（worker3, boss1 04:34 / PRESIDENT 04:3x GO。master = c5125b3b15cee8b713d476536ddfa2997397c69b = e41e21c ＋ track2/rod-combined 30f0fa6 --no-ff、木 75bf492b = 30f0fa6 の木（観測, rev-parse）、pin ikada-sim 2750f49 = API 0.24.0）

## PLAYABLE_NEXT.md §2 をこの sha に（観測 = 読んだ物）
| # | 確かめ | この sha で | 根拠 |
|---|---|---|---|
| 1 | regress 15/15 | ★済★ = 30f0fa6_042532 15/15（boss1 04:34）、木が同じ（75bf492b, 観測） | 同じ木 = 同じ build の中身 |
| 2 | input_test | ★済★ = 同じ run（boss1 04:34） | 同上 |
| 3 | StoryRun S0〜S7 | ★要る（推奨）★ = logic が 418b374 → 2750f49（6 commit）で 物語の流れの file が変わった: GameFlow.cs・GameFlow.Title.cs（新, 題へ戻る道）・DayFlow.cs・DayFlow.Pause.cs（新）・DayFlowPanels.cs・FishingSession.cs・IkadaSession.cs・RenderContract.cs（Rest）= ★365 日の通しが同じかは回すまで分からない★（git diff --name-only 418b374 2750f49, 観測）。約 14 分、dotnet の合図で。予測 = 418b374 の結果（storyrun_418b374/summary.txt: S7 13.6 分・sim 219814 s・S0〜S6 全部当たり）と同じ（推論: 題へ戻る道は 一時停止の頁から入る道 = StoryRun の手は通らない、Rest は描きの出来事）。 | |
| 4・4b・5・6 | (E) の 4 日の画・03 の帯の字・D6・c30 §12 | e41e21c で済（PLAYABLE_E41E21C_W3.md §2）。この版で変わったのは竿（受け・手・握り・糸・外巻き）と題へ戻る道と字の焼き = 場所の字・地図・D6 の穂先の切り替えの道は変えていない（git diff e41e21c c5125b3 の file = Render 10・UI 6・Fonts 3・Live 2・Packages 2・tools 2、観測）= 回し直さない（推論） | |

## --apply の予測（回す前, 動かさない）
- 出来る dir = ikada-play/c5125b3。★file 176★（e41e21c と同じ = 足した script は dll の中、新しい file は無い）、★bytes 744,002,735 ＋ 数 KB〜100 KB★（字の asset の source +4.1 KB = 3 字 消画語 の焼き足し、竿の code・Ikada.Game の code が増えた分, 推論）。
- e41e21c との差（sha256 で全 file）: ★変わる = Managed/Assembly-CSharp.dll・Ikada.Game.dll・boot.config・globalgamemanagers・globalgamemanagers.assets・resources.assets（字）★、変わりうる = level0・sharedassets0.assets（場面の参照）・Ikada.Logic/Desktop/Native.dll（source は 2750f49 の Runtime で Game だけ変わった = 決定的な compile なら同じ, 未確認）。★同じ = Ikada.x86_64・UnityPlayer.so・libdecor 2 つ・libikd（C は 418b374→2750f49 で 0 file, 観測）★。
- 起動の確かめ: 自分たちの起動で 05 の題が出る・[Live] でなく普通の起動の log に Exception 0・閉じた後 --check-players 0。
