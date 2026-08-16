# ★#477-C の 事前登録★（worker3）— ★撮る前に 書きます★

## ★(3) 3 つ ON の 画で 何が 写るか（★事前登録★）★

env = `twna01 / VISE_NPC_MODE=on / DEGIMON_VISE_VILLAGE=1 / DEGIMON_FIELD_MODELS=1 / avatar 既定 ON`

| # | 予想 |
|---|---|
| P1 | ★村人 = ★3 体★★（TOKO / YURA / TANE）= ★固定 world 座標★ (-13.72,0,-29.91) / (-1.03,0,-16.23) / (7.98,0,-16.56) |
| P2 | ★`FIELD_MODELS` 由来の NPC = twna01 の json `digimon` の 数だけ★（★数は 撮る前に 数えます★ = 下記） |
| P3 | ★boy が 3D で 立つ★（avatar 既定 ON） |
| P4 | ★`VISE_NPC_MODE=on` を 足しても 村人は 出る★（= ★(A) の 相互排他が 直っている★） |
| P5 | ★map を 跨いだ 後も 村人は 出る★（= ★latch 撤去が 効いている★ / ★`_placeCount` が 2 以上★） |

★★P4 と P5 が 本便の 本題★★（★P1-P3 は 前便で 既に 出ている★）。

## ★外れたら 前進（H4）★
・★P4 が 外れる★ ⇒ ★相互排他が 別の 場所にも 在る★
・★P5 が 外れる★ ⇒ ★`GameObject.Find` の 名前が map 跨ぎで 一致しない★（= 私の 述語の 誤り）
・★P1 が 3 でない★ ⇒ ★prefab load 失敗★（(C) の 再試行が 見える はず）

★P2 の 母数（撮る前に 数えました）★ = twna01 の  entry = ★7 件★
