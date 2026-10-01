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
- ★StoryRun 418b374 の結果（観測, 04:4x-05:0x, drafts/stageC/storyrun_418b374/summary.txt）★: S7 13.6 分・sim 219814 s・ended。S0 365/365 順・missing []。S1 予測どおりの順（第1章の頁なし）。S2 4 章の頁の最初と最後の行 = GameFlow の字。S3 予測どおり。S4 4 章とも課題の見出しが全部（課題1〜4 / 2-1〜2-4 / 3-1〜3-4 / 4-1・4-2・4-4）、頁の数 83・88・84・83。S5 4 か所 OK。S6 RodLent・RodGiven 真・closed。= ★S0〜S7 とも予測どおり★。但し「課題の済みの日が早まる向き」は 比べる前の通しの summary が手元に無い（d0118ce は 60 s の煙だけ）= 未確認のまま。

## §2 の 4・4b・5・6（観測, 04:58-05:01, 同じ木の player = ikada-unity-stage5/Builds/Linux 82d6de2 04:31, 木 = e41e21c の木を確かめ, drafts/stageC/e41_story_days.sh, shots/e41_story_days_0458）
- 4 ★当たり★: 4 日とも rc 0・Exception 0・5 枚。07 = 前夜の宿 9月1日 / 10月15日 / 12月10日 / 1月20日、筏 島の筏 / 瀬戸の筏 / 湾のカセ / 湾のカセ。06C・06 の見出しの場所 = 八代海・御所浦 / 八代海・樋島 / 大分南部・蒲江 / 大分南部・蒲江、章の帯 第3章 島の秋 ×2・第4章 冬のカセ ×2、遠景 = 御所浦・樋島の秋・蒲江の冬、手前 = 9/1・10/15 筏の板、12/10・1/20 カセの舟べり（1/20 は曇りで灰色に見えるが同じ舟 = 拡大で確かめ）。04 の場所 = 御所浦・港・夕方 / 樋島・港・夕方 / 蒲江・港・夕方 ×2。1/20 の竿 = [Gear] look rod=2（上級）・穂先 StiffTitanium。港の言葉は 418b374 で too_few でなくなった（9/1「割れが早か。…あと二十二秒…」・10/15「宙で割れよる…」・12/10・1/20「こげな日もある…」= 記録の直しの向きどおり）。
- 4b ★未のまま★: 本物の日の 03 = 取り込みの時 = この 4 日は釣れない（AutoPilot は投げて上がる）。芦北の日の 03 は mock の決め打ちの字（八代海・芦北）と見分けられない = 第3・4章の日で釣れる種を探す必要（種の走査 = 別の番）。
- 5 ★当たり（D6 の線）★: 1/20 = [Tip] kind SoftGlass -> StiffTitanium at T=0.080N, casts today=0, rig=Card（その日の最初の投の前 = ev4.tip）。曲がり 前 3 frame 0.004379 / 0.004443 / 0.004507 m → 後 0.004419 / 0.004092 / 0.003633 m: 切り替えの frame の |Δ| 0.000088 ≤ 前後の |Δ| の最大 0.000459 = 跳びなし。T = 0.080 N > 0 = 後の下がりは竿を替えた分（T/80 → T/120 の向き, worker2 の注のとおり）。
- 6 数え（Unity なし, 観測）: Unity = git log --first-parent 2cb67ab..e41e21c = 27 個、logic = 2cb67ab の pin 7fe4233..418b374 の first-parent = 63 個（API 0.14.0 → 0.23.0）。c30 §12 の下書きは worker1 の file = この数を boss1 経由で渡す（私は直さない）。
