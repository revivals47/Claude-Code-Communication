# 3 gate 1 batch の 個別検証（worker3 / #461-C）2026-08-16

★★見せるのは 1 回・検証は 1 つずつ★★（boss1 裁定）。★本 doc は ★検証の 側★★。
★user は 呼んでいません★ / ★「arc 完了」と 書きません★。

## 0. ★★既定は ★実測で★ 決めました（演算子から 読んでいません）★★

★何も 設定せずに 走らせた 実測★:

| tag | 行数 |
|---|---|
| `[VISE_BOOTSTRAP]` | ★3★（= ★avatar は 既定 ON★ = #460-C の 反映） |
| `[FIELD-MODEL]` | ★0★ |
| `[VISE_NPC]` / `[VISE_EMIT]` | ★0★ |
| `[SCENE-AUDIO]` / `[AUDIO-PLAY]` | ★0★ |

⇒ ★★∴ 3 gate は 実測でも 既定 OFF★★（boss1 の code 読解と 一致）。

## 1. ★★測定器の 検算を 先に（★これが 無いと 数が 読めません★）★★

★★反復対照（同一 env・別 run）★★:
・★歩行あり × game camera★ = ★★80.678%★★ ⇒ ★★雑音が 信号を 上回る = 判定に 使えません★★
・★★歩行なし × game camera（`POSTCUT_WALK` 無し・`CAPSEC=20`）★★ = ★★0.001%（4 px）★★ ⇒ ★これを 使いました★
⇒ ★★∴ 最初の 測定（歩行あり）で 出た 23.948% は ★雑音の 中★ でした★★
　= ★反復対照が 無ければ 「FIELD_MODELS は 効く」と 誤報していました★

★★私の 測定の 誤り 2 件（自己申告）★★:
1. ★tag を `[A-Z0-9_]` で 抽出し ★`[FIELD-MODEL]`（ハイフン）を 取り零した★★ ⇒ 直して 再測
2. ★`npc-model` を log で 探した★ が ★それは GameObject 名で log ではない★ ⇒ 無意味な 検索だった

## 2. ★① 反転（未設定 vs ON）★

| gate | 次元 | 反転 | 数 |
|---|---|---|---|
| ★`DEGIMON_FIELD_MODELS`★ | 画面 | ★★OK★★ | ★1.935%（5943 px）★ 対 雑音 0.001% ／ 新規 tag `[FIELD-MODEL]` |
| ★`DEGIMON_VISE_VILLAGE`★ | 画面 | ★★OK★★ | ★0.115%（352 px）= 雑音の 100 倍★ ／ 新規 tag `[VISE_NPC]` `[VISE_EMIT]` |
| ★`SCENE_DRIVER`+`WIRE`+`AUDIO`★ | ★音★ | ★★NG★★ | ★★RMS 0.000000 = 1 sample も 鳴らない★★（§3） |

★`FIELD_MODELS` の 画★ = `f_fm.png` = ★★3D の digimon が 2 体 立っています★★（黄 = AGUM 系 / 緑 = 別種）
★対照★ = `f_none.png`（marker のみ）

## 3. ★★③ 音は ★音で★ 判定しました（log で 済ませていません）★★

★算法★ = ★PipeWire の sink monitor を `parec` で 録音し RMS / peak を 出す★

| run | RMS | peak |
|---|---|---|
| 音 gate なし | ★0.000000★ | 0.000000 |
| ★`DRIVER`+`WIRE`+`AUDIO`=1★ | ★★0.000000★★ | ★★0.000000★★ |
| ★★録音器の 陽性対照★★（既知 wav を 同 sink へ 流す） | ★★0.072942★★ | ★0.999969★ |
| ★`+ DEGIMON_SCENE_AUDIO_EXERCISE=1`★ | ★★0.022865★★ | ★0.180908★ |

⇒ ★★録音器は 生きています★★（陽性対照 RMS>0）⇒ ★★∴ 上の 0 は ★本当に 無音★★★
⇒ ★★∴ `DRIVER+WIRE+AUDIO` の 3 つを ON に しても ★この筋書きでは 音は 鳴りません★★★
　（log も ★`SCENE-AUDIO` 0 行★ = ★audio path に 到達していない★）
⇒ ★★但し `EXERCISE=1` なら 鳴ります★★ = `[AUDIO-PLAY] scene33_v0(vol=0.625、len=77.76s)` ＋ ★RMS 0.0229★
　★★但し exerciser 自身が 申告しています★★:
　「★scope=asset 検証のみ / ★0x66 到達は 非検証★★」
　⇒ ★★∴ ★asset と pipeline は 生きている★ が ★実 game path では 鳴っていない★★★

## 4. ★★音源の 母数（★user への 説明に そのまま 使えます★）★★

★wav = 4 本★ = ★`scene33_v0` / `v1` / `v2` / `v3`★
⇒ ★★∴ 「4 場面」では ありません = ★scene 33 という ★1 場面★ の 4 variant★★★
⇒ ★★∴ 音を ON に しても ★鳴り得るのは scene 33 だけ★★★
⇒ ★★「音が 出た」と「音が 揃った」は 別★★（boss1 の 語）= ★材料の 問題であって bug では ない★

## 5. ★② 退路★
・`FIELD_MODELS` / `VISE_VILLAGE` = ★未設定が そのまま OFF★（= 上表の 対照 run）
・音 = ★未設定で RMS 0★

## 6. ★見ていないこと（母数の 申告）★
1. ★地図は mayo00 のみ★（残り 241）⇒ 札 = 材料
2. ★★scene 33 に 到達する 筋書きは 未特定★★ ⇒ ★これが 音の 律速★ ⇒ 札 = 材料
3. ★`VISE_VILLAGE` の 0.115% は 小さい★ = ★この地点では 村人が 遠い 公算★（★別地点 未測定★）⇒ 札 = 材料
4. ★user 実視覚 / 実聴取 は 未★

---

# ★#472-C = 村 map の 特定 ＋ 3 つ ON の 1 枚★

## 7. ★★`VISE_VILLAGE` は ★map gate では ありません★★★

★逐語★ = `ViseNpcBootstrap.cs:56-70` の `PlaceVillage` は
★★固定 world 座標★★ に 置きます（★worker1 の RAM 実測値★）:
```
  TOKO (-13.72, 0, -29.91) facing 315°
  YURA ( -1.03, 0, -16.23) facing 342.8°
  TANE (  7.98, 0, -16.56) facing 45°
```
⇒ ★★∴「村 map で ON にする」gate では なく ★どの map でも その 座標に 置く★★★
　= ★座標の 出所が ★twna01 の 村★★ ゆえ ★twna01 でないと 意味の ある 位置に なりません★
★発火条件★ = `village && !_attached && Camera.allCamerasCount > 0 && _t > 1.5f`
⇒ ★★`_t > 1.5f` に 届く前に run が 終わると 1 行も 出ません★★（★「0 行」の 説明に なり得ます★）

★★申告★★ = boss1 は「PRESIDENT が mayo00 で ON にして ★0 行★」と 伝えられましたが、
★私の mayo00 実測では ★`[VISE_NPC]` `[VISE_EMIT]` の 2 tag が 出ました★★（#461-C）。
⇒ ★★0 行では ありません★★ ⇒ ★差は ★run の 長さ（`_t > 1.5f`）★ の 公算★（★私は 断定しません★）。

★twna01 での 実測★ = ★3 体とも 配置★（renderers 139 / 154 / 132）／ 画面差 ★1.069%★

## 8. ★★3 つ ON の 1 枚 = `all3b.png`★★

env（★`[RUNBY]` に 全部 印字済★）:
`DEGIMON_BOOT_MAP=twna01 / DEGIMON_FIELD_MODELS=1 / DEGIMON_VISE_VILLAGE=1 /`
`VISE_AVATAR_MODE=（未設定 = 既定 ON）/ DEGIMON_VISE_NOFRAME=1 / CAPSEC=26 / WALK_DIR=0,1`

★写っているもの★:
・★boy（3D・黄の 上着）★ が ★緑の tunnel 建物の 前★（= ★原盤 screenshot と 同じ 場所★）
・★Mojyamon 風（角と 白毛）★ / ★Tokomon 風（白・耳）★ / ★Tanemon 風（緑・葉）★ = ★3D model★
・★街の 造作（tunnel 小屋 / 青い 遊具 / 花壇）★

★`all3.png`★ = 同 env・`WALK_DIR=0,-1`・CAPSEC=32 の 別枚（★村人 4 体以上が 広く 写る★ / boy は 画角外）

## 9. ★見ていないこと★
1. ★どの 個体が `FIELD_MODELS` 由来で どれが `VISE_VILLAGE` 由来かは ★画では 分けていません★★
　（★log では 分かれています★: village = TOKO/YURA/TANE の 3 体固定）⇒ 札 = 自分の器
2. ★★他の player run が 3 本 走っていました★★（`/tmp/degimon_user3.log` 等 = ★PRESIDENT 側・私は 触っていません★）
　⇒ ★同一 GPU / 同一 sink を 共有していた★ ⇒ ★★#461-C の 音の 測定に 影響した 可能性は 否定できません★★
　（★但し 陽性対照は 同じ条件で RMS>0 を 出しています★）⇒ 札 = 材料
3. ★既定 ON にできるかの 3 条件（②）は ★本便では 撃っていません★★ ⇒ ★画を 先に 出しました★

---

# ★#477-C = latch 撤去（(A)(B)(C)）＋ 真因の 特定★

## 10. ★★(2) `VISE_NPC_MODE` は ★設定していませんでした★（実物で 回答）★★

★早期 return（`ViseNpcBootstrap.cs:19-23`）★ = `mode` / `shot` / `gallery` の ★3 つとも 空なら return★
★私の mayo00 run（#461-C `d_vil.log`）★ = ★`VISE_NPC_MODE` 未設定★ ／ ★`DEGIMON_VISE_SHOT` は 設定★
⇒ ★★∴ 早期 return を 迂回したのは ★`DEGIMON_VISE_SHOT`★ でした★★
★証拠（log 行）★ = `[VISE_NPC] screenshot -> …`（= `ViseNpcBootstrap` の Runner が 生きていた）
⇒ ★★これが「PRESIDENT は 0 行・私は 2 tag」の 食い違いの 説明です★★

## 11. ★★§5 = 真因は ★早期 return★（fix 前に 1 度だけ 測りました）★★

| run | env | village place |
|---|---|---|
| `x_a` | VILLAGE + SHOT | ★3 行★ |
| `x_b` | VILLAGE + SHOT + `VISE_NPC_MODE=on` | ★3 行★ |
| ★`x_c`★ | ★VILLAGE ★のみ★（SHOT も MODE も 無し）★ | ★★0 行★★ |

⇒ ★★∴ 真因 = ★早期 return★★★

★★但し (A) は ★測れていません★（0 を 埋めません）★★ =
`x_b` は `VISE_NPC_MODE=on` を 足しましたが ★`VISE_NPC_PREFAB` / `VISE_NPC_SCRIPT` を 渡していない★ ため
★marker 差替の 枝（`:137` の `anchor != null && prefabPath != ""`）が ★自分の 前提で 成立せず★★
⇒ ★★`_attached` の 奪い合いに ならなかった = (A) の 検定に なっていません★★

## 12. ★(1) latch 撤去 = ★直す前に 落ちる test を 先に 置きました★★

器 = `p2w3/workspace/tools/★w3_visenpc_latch_tests.py★`（★(A)(B)(C) を 別々の test★）

| | 直す前 | 直した後 |
|---|---|---|
| (A) 1 latch が 複数機構の gate | ★FAIL（`!_attached` 3 件）★ | ★PASS（0 件）★ |
| (B) 逆向き 2 意味の 同居 | ★FAIL（否定 3 / 肯定 3）★ | ★PASS★ |
| (C) prefab 失敗でも latch | ★FAIL（1 件）★ | ★PASS（0 件）★ |
| 合計 | ★★0 / 3 PASS★★ | ★★3 / 3 PASS★★ |

★被覆を 印字しています★ = 実 code 217 行 →（修正後）226 行 を 走査 / 内訳も 印字。

★置換の 形（★use ごとに★・一律に 消していません）★:
・village = `!VillagePlaced()` / gallery = `!GalleryPlaced(gallery)` / 差替 = `!NpcPlaced(scriptId)`
　⇒ ★機構ごとに ★別の 問い★ = ★(A) の 相互排他も 同時に 解けます★
・撮影の 前提（`:148` / `:189`）= ★`AnythingPlaced` に 置換して ★残しました★★（(B)）
・`prefab == null` では ★数えません★（(C)）／ ★`_placeCount` を 印字★

## 13. ★★P4 = 的中 / P5 = ★外れました★（事前登録どおり 報告します）★★

★P4（`VISE_NPC_MODE=on` を 足しても 村人が 出る）★ = ★★的中★★（village place ★3 行★）
⇒ ★(A) の 相互排他は 直っています★

★★P5（map を 跨いだ 後も 出る / `_placeCount` ≥ 2）= ★外れました★★★
　`p5b.log` = ★TWNB01 到達 = 189 行★ ／ ★その後の village place = ★0 行★★

★★外れた 理由（★私の 予想の 前提が 誤り★）★★:
　★再配置しなかったのは ★述語が「今 在るか」を 訊いて ★在ると 答えた★★ から★
　⇒ ★★∴ ★村人は map を 跨いでも 破棄されていません★★★
　（★village は `Instantiate(prefab, pos, …)` で ★親が 居ない★★ = `[Player]` の 子である avatar と 違う）
⇒ ★★∴ P5 の 予想は ★latch の 話と 取り違えていました★★★ = ★私の 誤り★

★★但し これは ★log からの 論理★ であって ★直接 見ていません★★★:
　★撮影経路が 撮った 1.5s 後に Quit する★ ため ★warp 後の 画が 撮れませんでした★（2 度 試行）
⇒ ★★札 = 材料★★（★warp 後に 村人が TWNB01 に 居るかの 画は 未取得★）
⇒ ★★かつ 新しい 問いが 立ちました★★ = ★★村人が map を 跨いで 残るのは 正しいのか★★
　（座標は twna01 由来ゆえ ★別 map では 宙に 浮く 公算★）⇒ ★これは latch とは 別の 論点★

## 14. ★(5) gate の 依存関係 列★ = `GATE_DEPENDENCY.md`（★値の 出所を file:行 で 各行に★）

---

# ★#480-C = 村人を 属する map の 外へ 持ち出さない★

## 15. ★★実測で 前提が 壊れました（★これが 本便の 収穫★）★★

★私は `VillageMap = "twna01"` と 書いて 撃ちました ⇒ ★P1（twna01 で 3 体）が 外れ 0 行★★
⇒ ★2 度 外したので 推測を やめ ★診断を 印字★ しました★:
```
[VISE_NPC] ★診断★ GameManager=True Session=True
   CurrentMapName='topn01' 属する map='twna01' 一致=False cams=1 t=1.71
```
⇒ ★★`DEGIMON_BOOT_MAP=twna01` で 起動しても intro 後の session map は ★`topn01`★★★
⇒ ★成功した 全 run が `TWNA01` → `TOPN01` と 遷移★／★村人が 正しく 見えた 画（`all3b.png`）は その topn01 上★

★★∴ 記録と runtime が 食い違います★★:
・★doc（`CAMERA_FIDELITY_RE` 系）★ = 座標の 出所は ★twna01★
・★runtime★ = 置かれて 正しく 見えるのは ★topn01★
⇒ ★★私は 解消しません★★（★どちらが 正しいかは 私には 決められません★）
⇒ ★既定は ★実測値 `topn01`★★ ／ ★`DEGIMON_VISE_VILLAGE_MAP` で 差し替え可★ = ★後で 訂正できる形★

## 16. ★事前登録（`PREREG_480C.md` / commit `e281b05`）との 突合★

| # | 予想 | 結果 |
|---|---|---|
| P1 | 属する map で 3 行 | ★的中★（`r1` = 3 行） |
| P2 | 属さない map（mayo00）で 0 行 | ★的中★（`r2` = 0 行） |
| P3 | warp を 跨いでも 0 行のまま | ★的中★ |
| ★P4★ | ★属する map を 出ると despawn 1 回★ | ★★的中★★（下記） |
| P5 | 戻れば また 置く | ★未検定★（★戻る 筋書きを 作れていません★）⇒ 札 = 材料 |

★★P4 の 生行★★（`r3` = 属する map を `mayo00` に 差し替えて 撃った）:
```
  189 行: [MapLoader] loaded 'TWNB01'
  200 行: [VISE_NPC] ★village despawn = 3 体★ / 今の map='twnb01' 属する map='mayo00'
           / frame(Time.frameCount)=35 ⇒ ★戻れば また 置きます（latch していません）★
```
⇒ ★★despawn は warp の ★後★★★（200 > 189）

★★P1 の 初回の 外れは 「予想」でなく 「実装」の 誤りでした★★（★定数が 実際の map と 違った★）
⇒ ★doc に 残します★（★消しません★）= ★★「座標の 出所」と「runtime の map 名」は 別★★

## 17. ★★P5（#477-C）の 外れを 消さずに 残します★★

★#477-C の P5「map 跨ぎで 再配置される」は ★外れました★★。
★理由★ = ★★村人は 破棄されていなかった★★（述語が「今 在るか」に ★在る★ と 答えた）
⇒ ★★「latch の 寿命」と「村人の 寿命」は ★別の 話★★★:
・★latch の 寿命★ = ★process★（#477-C で 撤去済）
・★村人の 寿命★ = ★★map★ で あるべき★（#480-C で 与えた）
⇒ ★私は latch を 直しに 行って ★別の 寿命★ を 見つけました★。★後世が この 2 つを 混ぜないように★。

## 18. ★★(次) 撮影器の 欠陥を 直しました — ★2 度の 失敗の 真因は こちら★★

★欠陥★ = ★「1 枚 撮ったら 1.5s 後に Quit」★ ⇒ ★warp 後の 画が 2 度 撮れなかった★
★★真因（実測）★★ = ★`ViseAvatarBootstrap` を 直しても まだ 撮れませんでした★
⇒ ★★落としていたのは ★`ViseNpcBootstrap` 側の Quit（2 箇所）★★★
　（★`DEGIMON_VISE_SHOT` を ★両方の bootstrap が 読む★ ため★ = ★依存列に 書いた とおり★）

★処方★ = ★`DEGIMON_VISE_SHOT_AT="18,40"`（秒・複数）★
・avatar 側 = ★指定時刻ごとに 撮り、★最後の 1 枚まで Quit しません★★
・NPC 側 = ★`SHOT_AT` が 在るときは ★Quit しません★★（★時刻管理は avatar 側が 持つ★）
・★未指定なら 従来どおり 1 枚で Quit★（★既定は 1 bit も 変えません★）

★★結果 = 同じ run で 2 枚 ＋ warp ＋ despawn が 全部 撮れました★★:
```
  [VISE_BOOTSTRAP] screenshot … two.png   (frame=56)
  [VISE_BOOTSTRAP] screenshot … two_1.png (frame=122)
  191 行: [MapLoader] loaded 'TWNB01'
  despawn = 1 行
```

★★∴ #477-C の 札（warp 後の 画が 未取得）が 閉じました★★:
・`warp_before.png` = ★warp 前（mayo00・村人 在り）★
・★`warp_after.png` = ★warp 後（TWNB01）= ★村人は 1 体も 居ません★★★
⇒ ★★「log からの 論理」だった ものが ★直接 見た★ に なりました★★
