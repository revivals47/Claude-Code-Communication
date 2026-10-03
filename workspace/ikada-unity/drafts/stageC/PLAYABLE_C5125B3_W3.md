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

## playable_build.sh の dry（観測, 04:35:45, worktree = ikada-unity-track3〔track3/pr-capture, porcelain 0〕）
- rc 0: HEAD IdleHint=no LockedHint=no・Runner.Worker 0・load 0.95・df 33.6 GB・DRY-RUN、master = c5125b3…、pin #2750f491…、陽性対照 = ikada-play/2cb67ab の folder sha 75dc972e…（記録どおり）、would 1) detach 2) BuildPerf 3) cp + diff -rq + 数・bytes・folder sha 4) 起動の確かめ（25 s HostInput・SessionProbe・AutoPilot の 1 日）。worktree の branch は track3/pr-capture のまま（触っていない）。

## StoryRun S0〜S7 を 2750f49 で（観測, 04:36:32〜04:42:39, drafts/stageC/storyrun_2750f49/）
- ★S0〜S6 = 418b374 の summary と行が全部同じ★（diff 0 行: 365/365 順・章の頁の順・各章の終わりの頁の最初と最後の行・場所・課題の見出しと頁の数 83/88/84/83・S5 4 か所 OK・RodLent/RodGiven 真）。storyrun.log 737 行も 頭の行（head sha・api・時刻）だけが違う = 日と頁の並びは 1 行も違わない。
- ★S7 = 外れ 2 つ★: sim 220040 s（予測 219814 s、+226 s = 0.1%）= ★種類: 通しの sim の秒の合計だけ（日・頁・場所・課題の行は同じ）★、どの日で延びたかは log に秒が無いので 未特定（推論: 題へ戻る道・一時停止の頁の足しで 画面の間の秒が延びた）。wall 6.0 分（前 13.6 分）= 私の起動に -c Release を付けた（前の起動の形は未記録, 推論）。
- = 遊べる版の 物語の通しは 418b374 と同じ並び（日・章・場所・課題）、秒の合計だけ +226 s。

## worker2 track2/okiami-word 130435a の読み（RodHand に Rest, boss1 04:41）
- 当たり（source, ikada-sim 2750f49 FishingSession.cs）: 底では Rest は Bottom と同じ frame（:246-247）= Set は同じ状態なら何もしない＝2 度目の替わり無し。Bottom・Rest とも ★State が InWater の時だけ★（:243 `if (State != RigState.InWater) continue;`）= ファイト中に受けへ戻る漏れは無い。lead-in の中の Rest は Bottom と同じく吸われるが RodHand は lead-in で受け＝重なりなし。
- 残る件: Rest は 1 投に 1 回（TRest < 0 の時だけ, :247・:288）＝ ★宙で止めた後に放して沈め直した投は 受けのまま沈む★（沈み直しの event が無い）。直すなら logic に「沈み直し」の event（Drop と同じ扱いで 手へ）が要る＝ RodHand だけでは閉じない。

## --apply の結果（観測, 04:44:22-04:46:21, rc 0）
- build Succeeded errors 0（17.5 s）→ ★ikada-play/c5125b3 = 176 file・744,021,999 bytes★（予測 176・744,002,735 ＋ 数 KB〜100 KB → +19,264 bytes = ★当たり★）、folder sha256 729dea51a22a51f606bc7034a15453c898687dd429906b6b67d5a9d90dbc6f0d、Ikada.x86_64 sha256 a9a83136f9f1e9bb13e145b651e13a947bbff6d6a9281f92f0791afc397104cb（e41e21c と同じ）。DoNotShip 抜き・diff -rq 0。陽性対照 2cb67ab の folder sha は記録どおり。
- 起動の確かめ: 4a〜4c の前後とも player 0、[Live] start api 0.24.0 | SessionProbe RESULT ok=True api=0.24.0 abi=3 screen=Title | [Live] RESULT ok=True steps=539333 simS=8989.1 page=Info、セーブの dir は前後で同じ（無し）。閉じた後 --check-players 0・/proc/exe で player・Unity 0。worktree は track3/pr-capture に戻った。
- e41e21c との差（sha256 で全 file）: 11 file = Managed の 5 dll（Assembly-CSharp・Ikada.Game・Ikada.Logic・Ikada.Desktop・Ikada.Native）・boot.config・globalgamemanagers・globalgamemanagers.assets・level0・resources.assets・sharedassets0.assets。予測との照合: 「変わる」6 つ ★当たり★、「変わりうる」level0・sharedassets0 = 変わった、★Ikada.Logic/Desktop/Native.dll は source が変わっていないのに変わった = 「決定的な compile なら同じ」は外れ★（Unity の compile は byte で再現しない見込み, 推論; e41e21c と ba3de36 の差も同じ 11 file の形）。同じ = Ikada.x86_64・UnityPlayer.so・libdecor 2 つ・libikd（★当たり★）。
