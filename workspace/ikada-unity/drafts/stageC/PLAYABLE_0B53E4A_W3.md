# 遊べる版 0b53e4a の build（worker3, boss1 23:51）
master = 0b53e4a3b5618963b1d0e5e7df4f1f1951039f51（track3/rod-default b763128 の --no-ff）、木 2a10a3c4 = b763128 の木（rev-parse で同一, 観測）= regress b763128_233732 16/16。pin ikada-sim b80715f（manifest の行, 観測）= 521a92c と同じ。

## StoryRun は回さない（理由, 観測）
- 521a92c → 0b53e4a の差 = 13 file（Assets の竿の描き・撮りの道具だけ）、Packages・ProjectSettings の差 0、pin 同じ b80715f = logic は同じ = StoryRun は 521a92c の b80715f の run（a8cca9e と全部同じ, S7 213468 s）と同じ見込み。要るなら boss1 の指示で。

## 予測（回す前, 動かさない）
- dry: rc 0（陽性 = 2cb67ab の folder sha 一致）→ ★観測 rc 0・陽性 一致（23:51）★。
- ★build: ~/Documents/ikada-play/0b53e4a = file 176（521a92c と同じ: 足した file は RodRest2.cs = dll の中, 新しい file なし）・bytes 744,094,379 ＋ 0〜200 KB（竿の code・撮りの道具 = Managed の dll の中, material は実行時に作る = asset なし）★、Ikada.x86_64 の sha256 = ★a9a83136…（521a92c と同じ）★、folder sha は替わる、DoNotShip 抜き・diff -rq 空。
- 起動の確かめ（script の 4a〜4c）: 前後とも player 0、[Live] start api 0.25.0・SessionProbe ok=True api=0.25.0 abi=3 screen=Title・AutoPilot の 1 日 RESULT ok=True（steps・simS は 521a92c と同じ 539333・8989.1 の見込み = logic 同じ）・セーブの dir 不変・Exception 0。-ikadaDev: 閉じ = 表示なし、-ikadaDevOpen = 開発の表示が出る（521a92c と同じ）。
