# 遊べる版 e41e21c の支度（worker3, boss1 04:40。master = e41e21c8a8d002feae32b7b2fe1ce6f081d232c0 = 82d6de2 の木、pin ikada-sim 418b374 = API 0.23.0 ＋ 宙止めの記録の直し, RefCheck #14）

## PLAYABLE_NEXT.md §2 をこの sha に当てた表（観測 = 読んだ物、未 = まだ誰も見ていない）
| # | 項目 | この sha での状態 |
|---|---|---|
| 1 | regress 15/15 | ★済★ ikada-unity-stage5/Logs/regress/82d6de2_043124 = PASS 15/15（木 = master の木, rev-parse tree 一致）|
| 2 | input_test | ★済★ 同じ run で checks 91・failures 0・unevaluated 0（focus あり）|
| 3 | StoryRun S0〜S7（pin の logic で 365 日, 約 14 分, dotnet）| ★未★ 最後の StoryRun は d0118ce（drafts/stageD/storyrun_rebase）= 418b374（宙止めの記録の直し = 課題・港の言葉が替わりうる）では誰も回していない。要 dotnet 約 14 分 |
| 4 | (E) の 4 日（9/1・10/15・12/10・1/20）の画と見出し・地図・港と着いた頁 | 未（この sha で撮っていない、Unity）|
| 4b | 本物の日の 03 の上の帯の場所の字 | 未（Unity）|
| 5 | D6（ev4.tip の 1 frame の跳び）| 未（この sha では未確認、Unity）|
| 6 | c30 §12 の数え直し | 未（build の sha で、Unity なし・依頼者の頁）|

## playable_build.sh の dry（観測, 04:41:14, worktree = track3〔pr-capture, porcelain 0〕）
- master = e41e21c・pin 418b374、folder sha の陽性対照 2cb67ab = 記録どおり、df 17.6 GB（> 12 GB）、錠なし・Runner.Worker 0 → 行く手 = detach → BuildPerf → cp -a（DoNotShip を外す）→ 起動。dry の後 track3 は pr-capture のまま。

## --apply の予測（回す前, 動かさない）
- 出来る dir = ikada-play/e41e21c。★file 176・bytes 744,002,735 ± 数 KB★（同じ木の build = ikada-unity-stage5/Builds/Linux 04:31 の DoNotShip 抜きの数）。前の版 ba3de36 = 176 file・743,932,319 bytes = ★file 数は同じ、+約 70 KB★。Ikada.x86_64・UnityPlayer.so・libdecor の 2 つは ba3de36 と同じ sha256（Unity の版が同じ, 推論）、違うのは Ikada_Data の中（Managed の dll・resources・font）。
- 起動（step 4）: [Live] start api 0.23.0 の行・Exception: 0・SessionProbe ok・AutoPilot の 1 日 RESULT ok=True・simS < 9200・[Speakers] missing=[]・save の表 前後同じ。

## StoryRun S0〜S7 を 418b374 で（boss1 04:42: --apply の前）— 予測（回す前, 動かさない）
- S0 例外 0・365 日が順に 1 回ずつ（missing []）。S1 章の頁 = 第1章 おわり → 第2章 → 第2章 おわり → 第3章 → 第3章 おわり → 第4章 → 第4章 おわり（「第1章」の頁なし）。S2 各章の終わりの最初と最後の行 = GameFlow の字のまま（五月が終わった… / 八月… / 十一月… / 一年…）。S3 場所 = 3〜8 芦北・9 御所浦・10〜11 樋島・12〜1 蒲江（湾のカセ）・2 芦北。S5 章の境 4 か所の続きから = 通しの次の日と同じ。S6 RodLent 真・RodGiven 真。S7 約 14 分（前回 13.8〜14.1）。
- ★動く向き（418b374 = 宙止めの記録の直し）★: S4 の課題の進みの頁は 4 章とも課題の行が全部出る（見出しの集合は d0118ce と同じ）が、★課題の済みの日・頁の数は 替わりうる★（底置きが記録される = 底の課題・握りの速さの確かめが 前より早く済む向き, 推論）。港の言葉（too_few → faster/slower 等）は summary に出ない = ここでは見ない。照合の numbers（RefCheck の hud の hash）は記録の直しで不変の見込み（418b374 の message は events だけ固定し直し = 推論）= StoryRun の外。
