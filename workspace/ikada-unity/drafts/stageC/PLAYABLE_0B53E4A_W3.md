# 遊べる版 0b53e4a の build（worker3, boss1 23:51）
master = 0b53e4a3b5618963b1d0e5e7df4f1f1951039f51（track3/rod-default b763128 の --no-ff）、木 2a10a3c4 = b763128 の木（rev-parse で同一, 観測）= regress b763128_233732 16/16。pin ikada-sim b80715f（manifest の行, 観測）= 521a92c と同じ。

## StoryRun は回さない（理由, 観測）
- 521a92c → 0b53e4a の差 = 13 file（Assets の竿の描き・撮りの道具だけ）、Packages・ProjectSettings の差 0、pin 同じ b80715f = logic は同じ = StoryRun は 521a92c の b80715f の run（a8cca9e と全部同じ, S7 213468 s）と同じ見込み。要るなら boss1 の指示で。

## 予測（回す前, 動かさない）
- dry: rc 0（陽性 = 2cb67ab の folder sha 一致）→ ★観測 rc 0・陽性 一致（23:51）★。
- ★build: ~/Documents/ikada-play/0b53e4a = file 176（521a92c と同じ: 足した file は RodRest2.cs = dll の中, 新しい file なし）・bytes 744,094,379 ＋ 0〜200 KB（竿の code・撮りの道具 = Managed の dll の中, material は実行時に作る = asset なし）★、Ikada.x86_64 の sha256 = ★a9a83136…（521a92c と同じ）★、folder sha は替わる、DoNotShip 抜き・diff -rq 空。
- 起動の確かめ（script の 4a〜4c）: 前後とも player 0、[Live] start api 0.25.0・SessionProbe ok=True api=0.25.0 abi=3 screen=Title・AutoPilot の 1 日 RESULT ok=True（steps・simS は 521a92c と同じ 539333・8989.1 の見込み = logic 同じ）・セーブの dir 不変・Exception 0。-ikadaDev: 閉じ = 表示なし、-ikadaDevOpen = 開発の表示が出る（521a92c と同じ）。

## build の結果（観測, 23:52:47-23:54:44, rc 0, 木 ~/Documents/ikada-unity = master 0b53e4a に戻った・porcelain 0）
- build Succeeded errors 0（17.5 s）→ ★~/Documents/ikada-play/0b53e4a = 176 file・744,103,759 bytes★（521a92c から ＋9,380 = 予測 0〜200 KB ★当たり★, file 数 ★当たり★）、folder sha256 ★745e15a8665c396db89a79968cecd9885c4f51cfa82a58bca67ace81ec52f6b7★、Ikada.x86_64 sha256 ★a9a83136f9f1e9bb13e145b651e13a947bbff6d6a9281f92f0791afc397104cb★（521a92c と同じ = ★当たり★）。DoNotShip 抜き・diff -rq 空（script の step 3）。
- 起動の確かめ（script の 4a〜4c）: 前後とも player 0、[Live] start api 0.25.0 | SessionProbe ok=True api=0.25.0 abi=3 screen=Title | [Live] RESULT ok=True ★steps=539333 simS=8989.1★（521a92c と同じ = ★当たり★）page=Info、セーブの dir 不変、Exception 0（script の stop の行なし）。
- -ikadaDev（play_0b53e4a_dev/abs_closed・abs_open, 種 26 の 06）: 閉じ = Exception 0・open=True の行 0、-ikadaDevOpen = 「-ikadaDevOpen: F1 sent」・open=True・画に「開発の表示（F1 で閉じる）張力 0.1 N ドラグ 3.0 N・ダンゴ 沈み・サシエ 付いている（6/6）・魚 —・+0.0 秒 落とした」、Exception 0 → ★当たり★。画では 竿は手元（落とす = 手）、縁の受け 2 つが後ろに見える。
- ★自分の誤り（記録）★: 最初の -ikadaDev の 2 本を 相対 path（-logFile / -ikadaLiveShot）で起こした → player は相対 path を exe の側で解く = ★log 2 つが ~/Documents/ikada-play/0b53e4a/play_0b53e4a_dev/ に入った★（画は入らず = 撮りは失敗）。★外へ移し（play_0b53e4a_dev/from_build_dir/）、folder sha を script と同じ式で測り直して 745e15a8… ・176 file に一致★ = 渡す folder は元どおり。絶対 path で 2 本を撮り直した（上の abs_*）。
- FREE 前 Unity・player・VBCS 0（build 中に出た自分の VBCS 1192578 を kill）、master porcelain 0・0b53e4a。
