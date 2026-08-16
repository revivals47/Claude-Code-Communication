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

---

# ★#481-C = 座標の 帰属を ★突合で★ 決めた ＋ 3 つ ON の 画★

## 19. ★★(1) 帰属 = `twna01`（★人の 裁定を 要さず 測って 閉じました★）★★

★算法★ = 村人 3 体の ps1 座標 ＋ ★rotation★ を ★両 map の `digimon` record 全数★ と 照合
（★mayo00 で 通っている 手順を そのまま★ = ★その場で 新しい 走査器を 書いていません★）

★母数★ = topn01 ★8 件★ / twna01 ★7 件★ / ★完全一致（type+pos+rot）= 5 件★

| 村人 | ps1 / rot | topn01 | twna01 |
|---|---|---|---|
| TOKO | (-1372,-2991) rot 3584 | ★一致★ | ★一致★ |
| YURA | (-103,-1623) rot 3900 | ★一致★ | ★一致★ |
| ★TANE★ | ★(798,-1656) rot 512★ | ★★不一致★★ | ★★一致★★ |

★★∴ 決め手は TANE★★（topn01 の 対応個体は `(480,-1680) rot 0` = ★別物★）
⇒ ★★帰属 = `twna01`★★ ⇒ ★★doc が 正しく ★私の 実測ベースの 既定 `topn01` は 誤りでした★★★
⇒ ★既定を `twna01` に 訂正★（integ `11239ed2`）

★★∴ 残る 事実（★解消していません★）★★:
★session map は intro 後 `topn01`★ ⇒ ★★既定のままだと 村人は ★現 boot 経路で 1 度も 置かれません★★★
⇒ ★これは「村人の scope」の 問題では なく
　★★remake が twna01 の 代わりに topn01 に 居る★ 可能性を 開きます★★ ⇒ 札 = ★材料★
　（★topn01 と twna01 は ★record が 5/8・5/7 共通の 近縁 map★★ = ★取り違えても 気づきにくい★）

## 20. ★★(2) 3 つ ON の 画 = `three_on.png`★★

★事前登録★ = `PREREG_481C.md`（commit `c234acc`・★撮る前★）

| # | 予想 | 結果 |
|---|---|---|
| P1 | 村人 3 体 | ★的中★（`village place` 3 行） |
| P2 | ★数を 先に 埋めない★ | ★code 表 180 種 load★ / 画に ★Mojyamon 系 3 体 ＋ 他★ |
| P3 | boy が 3D | ★的中★ |
| P4 | despawn 0 | ★的中★ |
| P5 | 2 枚とも 撮れる | ★的中★（★直した 撮影器★） |

★env は 隠していません★ = ★`DEGIMON_VISE_VILLAGE_MAP=topn01` を ★明示★★
（★帰属は twna01 だが session は topn01 ゆえ★・★理由を 事前登録に 書きました★）

★★1 枚目の 試行では boy が 画角外でした★★（歩行で camera が 離れた）
⇒ ★歩かせずに 撮り直し★ ⇒ ★`three_on.png` = boy ＋ 村人 ＋ NPC が 同一画面★

## 21. ★未了（札つき）★
1. ★(3) `FIELD_MODELS` / `VISE_VILLAGE` の 既定 ON 3 条件 = ★未実施★★
2. ★(4) (A) の 検定 = ★未実施★★（律速でない・最後）
3. ★P5（戻れば また 置く）= 材料が 無く 本便でも 扱っていません★
4. ★★session map が topn01 である こと自体★★ ⇒ 札 = ★材料★（★本便で 開いた 新しい 問い★）

---

# ★#484-C = ★誰が topn01 へ 切り替えたか★（code で 読みました）★

## 22. ★★答 = ★script 由来★（hardcode では ありません）★★

★母数の 申告★ = `unity/Assets/Scripts` の `.cs` ★67 本★ ＋ `ViseAvatar` ★11 本★ を 走査
★① hardcode 検索★ = `topn01`（大小無視）⇒ ★runtime code に literal ★0 件★★
　（当たったのは ★私の comment★ と `Editor/W1FbMapWireCheck.cs:7` の ★comment★ のみ）

★② 実 log で 連鎖を 追いました★（`show2.log` の 87 → 122 行）:
```
  [FIELD] intro trigger → ScenarioVM.Boot()(data 駆動 master-walk)
  [SCENARIO-VM] Boot(…)=RunScene(238)(entry0.sec238 ACTIVATE 178 …)
  [DIALOGUE] PlaySection entry=0 section=238 → pc=0x3518
  ★[PROGRESSION][0xFB MAP] map index(op1)=238 → OnMapChangeRequested(spawn=0,mode=0)@pc=0x3518★
  [SCRIPTWARP] src=SCRIPT(0x47) request targetMap=238 → QueueWarp(deferred)
  [SCRIPTWARP] fire … -> map=238
  ★[MapLoader] loaded 'TOPN01'★
```

★★切替の site★★ = ★`Scripts/Dialogue/DialogueRuntime.cs:1897`★（`EmitMapChangeFromScenarioJump`）
★★分類★★ = ★★script（DG.SCN `entry0` の `section 238` の `0xFB` op1）★★
　= ★hardcode でも `.MAP` 由来でも ありません★

★index の 解決★（registry 実測）= ★`238` = `topn01`★ / ★`twna01` = `204`★
⇒ ★★∴ script が 指しているのは ★238 = topn01★ で、204(twna01) では ありません★★

## 23. ★★根拠の 強さ（★私の 判定★）★★

★code に 書かれた EXE 根拠★（`DialogueRuntime.cs:1880-1884` 逐語）:
・「★EXE 根拠★: `0x800EC448-0x800EC484` に 分岐なし ⇒ `lhu a0, gp-0x6CA6` → `jal 0x800DF7D0` は ★無条件★」
・「★spawn / mode は operand が 無い ⇒ 0★（EXE 側も 引数は map index 1 本 = ★捏造しない★）」

⇒ ★★∴「op1 = map index」は ★EXE 逐語で 接地されています★★★（★私の 推測では ありません★）
⇒ ★★∴ 分類は ★原盤の 筋★★★（remake の artifact では ない）

★★但し 私が 気づいた 1 点（申告）★★:
★同じ `op1=238` が ★2 つの 役で 使われています★★:
・`[PROGRESSION][0xFB MAP] map index(op1)=238` = ★map index★
・`[PROGRESSION] SCENARIO_JUMP(0xFB) … scenario(op0)=178 ctx(op1)=238` = ★scenario の ctx★
⇒ ★★1 つの operand が 2 つの 意味を 持つ★★
⇒ ★これが 正しいか（原盤も そうか）は ★私は 検めていません★★ ⇒ 札 = ★材料★
　（★`:1897` の comment は「旧 code は この値を `CurrentSection` に 入れ map 変更を 配線していなかった」と 書いており、
　　★かつて 別の 役で 使われていた★ ことが 判ります）

## 24. ★★∴ 村人の 帰属 との 関係★★
・★村人の 座標 = twna01(204) の record と 3/3 一致★（#481-C）
・★script は 238(topn01) へ 行く★（本節）
⇒ ★★∴ 2 つは ★矛盾しません★★★ = ★村人は twna01 の もの / game は topn01 へ 行く★
⇒ ★★∴「村人が 出ない」は ★正常★ です★★（★twna01 に 居ないから★）
⇒ ★★∴ 残る 問いは 「★原盤の intro も topn01 へ 行くのか★」★★ ⇒ 札 = ★材料★（★実機 or EXE★）

---

# ★#485-C = 残り 2 件（既定 ON 3 条件 ／ (A) の 検定）★

★事前登録★ = `PREREG_485C.md`（commit `610d9ba`・★撃つ前★）

## 25. ★★(1a) `DEGIMON_FIELD_MODELS` = ★既定 ON に できます★★★

反転 site = `Scripts/Field/EntityPlacer.cs:165`（`== "1"` → `!= "0"`）

| # | 条件 | 結果 |
|---|---|---|
| ★F④★ | ★反復対照（unset vs unset）★ | ★★0.000%★★ ← ★雑音の 基準★ |
| ★F①★ | ★unset vs `=1`★ | ★★0.000%（= 同じ）★★ |
| ★F②★ | ★`=0` で 従来へ 戻る★ | ★★1.930%（5930 px）変化 ＋ `[FIELD-MODEL]` 0 行★★ |
| ★F③★ | ★判定は 画面★ | ★満たす★（★log 行数では 判定していません★） |

⇒ ★★4 条件とも 的中★★（★事前登録どおり★）
★注★ = ★歩行を 止めて 撮っています★（★歩行つき game camera は 雑音 80% = #461-C の 実測★）

## 26. ★★(1b) `DEGIMON_VISE_VILLAGE` = ★既定 ON に しません★★★

★★理由 = ★満たしても 意味が 無い★ から★★（★条件を 満たせないから では ありません★）

★実測（`V①`）★:
```
  DEGIMON_VISE_VILLAGE=1 / BOOT_MAP=twna01 で 起動
  ⇒ ★village place = 0 行★
  ⇒ 診断: CurrentMapName='topn01' 属する map='twna01' 一致=False
```

★機構（#481-C / #484-C で 実測済）★:
・★村人の 座標は twna01(204) の record と 3/3 一致★
・★script（DG.SCN entry0 §238 の `0xFB` op1）は 238 = topn01 へ 行く★（★EXE 逐語で 接地★）
⇒ ★★∴ 既定 ON に しても ★1 体も 出ません★★★

★★∴ これは ★欠陥では なく 現時点の 正常★★★:
・★村人は twna01 の もの★ / ★game は topn01 に 居る★ ⇒ ★出ないのが 正しい★
・★私が #480-C で 与えた map scope は ★正しく 働いています★★

★★∴ 既定 ON に しない 判断の 理由★★ =
★★「出ない gate を 既定 ON に すると ★『効いていない』と 誤読される 装置★ に なる」★★
（★今日 何度も 踏んだ 型 = ★印字が 無いことを 0 と 読む★ の 逆向き★）
⇒ ★★既定 OFF の まま★★ ／ ★出す条件が 揃ったら（原盤の intro 行き先が 決まったら）改めて★

## 27. ★★(2) (A) の 検定 = ★今度は 検定に なりました★★★

★#477-C で 「測れていない」と 申告した 分★ =
★`VISE_NPC_PREFAB` / `VISE_NPC_SCRIPT` を 渡さず ★枝が 自分の 前提で 成立していなかった★★

★今回★ = `VISE_NPC_SCRIPT=5` / `VISE_NPC_PREFAB=ViseNpc/AGUM_Avatar` / `DEGIMON_FIELD_MODELS=0`
（★`FIELD_MODELS` を OFF に する 必要が あります★ = ★ON だと model が 置かれ ★marker が 作られない★★
　⇒ ★`anchor` が null に なり 枝が 成立しません★ = ★これも 依存関係★）

| # | 予想 | 結果 |
|---|---|---|
| ★A①★ | 差替の 枝が 成立する | ★★的中★★ `[VISE_NPC] attach script5 … prefab=ViseNpc/AGUM_Avatar renderers=17` |
| ★A②★ | ★village と 同時に 両方 動く★ | ★★的中★★（差替 1 行 ＋ ★village place 3 行★） |

⇒ ★★∴ #477-C の latch 撤去で ★相互排他は 解けています★★★（★(A) が ★実測で★ 閉じました★）
⇒ ★#477-C の「(A) は測れていない」札は ★本便で 閉じます★★

## 28. ★依存関係の 追補（`GATE_DEPENDENCY.md` へ）★
★`VISE_NPC_MODE` の marker 差替は ★`DEGIMON_FIELD_MODELS` が OFF で ないと 成立しません★★
（★ON だと model が 置かれ marker が 作られない★）= ★本便で 実測★

---

# ★#490-C = VM を 計測器に する★

## 29. ★★§2 の 検算 = ★boss1 の 主張は 正しい★★★

★code 直読★:
・`DialogueRuntime.cs:837` = ★`int len = OpcodeTable.Length(c);`★（★VM の pc 進行★）
・`DialogueRuntime.cs:94` = ★`public static int Length(byte op) => Len[op];`★
⇒ ★★∴ VM の pc 進行は `Len` 表に 依っています★★
⇒ ★★∴ ★`Len` の 正しさの oracle には なりません★★★（★boss1 の §2 は 額面どおり 正しい★）

## 30. ★★既存の 器が 在りました（新しく 作っていません）★★

★`DEGIMON_OPTRACE=1`★ = ★既に 実装済★（`:679` env 読取 / `:809` 印字 / ★既定 OFF★ / window `_LO` `_HI`）
⇒ ★boss1 の 規律「★その場で 走査器を 書かない・既存の 器を 通す★」に 従いました★
★私が 足したのは ★`entry` / `section` の 併記★ だけ★（★印字のみ★ = boss1 (2) の 要求分）

## 31. ★事前登録（`PREREG_490C.md` / `15eba90`）との 突合★

| # | 予想 | 結果 |
|---|---|---|
| ★O①★ | gate OFF で 0 行 | ★的中★（0 行） |
| ★O②★ | ★gate OFF/ON で 画が 1 bit も 変わらない★ | ★★的中（0.000%）★★ = ★挙動 不変★ |
| ★O③★ | `=1` で 行が 出る（★数は 先に 埋めない★） | ★的中★（★合計 80 行 / 相異 pc 78 点★） |
| ★O④★ | pc が body 長 以内 | ★的中★（0x10 - 0x3544 / entry 0 の len=24576 内） |
| ★★O⑤★★ | ★SJIS-text 行が 在る★ | ★★外れました（0 行）★★ |

★★O⑤ が 外れた 意味（★0 を 埋めません★）★★:
・★私が 走らせた 経路（entry 101 §51 / entry 178 §254 / entry 0 §238）は ★text を 1 byte も 実行していません★★
・⇒ ★★「text を 通る 経路を 私が 走らせていない」のか
　　「VM が text を trace 前に 消費する」のか ★私は 分けていません★★★ ⇒ 札 = ★自分の器★
・★但し これ自体が (A) の 側面を 支持します★ =
　★worker2 の「DG.SCN の 51.9% は SJIS text」★ に対し ★実行された 78 点は ★text を 含まない★★

## 32. ★★出力（worker2 へ）★★ = `W3_OPTRACE_for_worker2.tsv`

★列★ = `entry / section / pc_hex / opcode_hex / opcode_name / len / is_text / run`
★母数★ = ★80 行 / 相異 pc 78 点★

| entry / section | 行数 |
|---|---|
| 0 / 238 | 5 |
| 101 / -1（`Begin` 経由ゆえ section 不明） | 6 |
| 101 / 51 | 13 |
| 178 / 254 | 56 |

## 33. ★★限定（★これが 一番 大事です★）★★
1. ★★実行した 範囲しか 出ません★★ = ★全数では ありません★（★78 点は DG.SCN 全体の ごく一部★）
2. ★★`Len` の oracle では ありません★★（§29）
3. ★得られるのは ★どの byte 範囲が 実際に code として 実行されたか★ の ground truth★ = ★(A) のみ★
4. ★(B)（挙動が 正しい ⇒ 実行経路上の `Len` は 概ね 正しい）は ★弱い 証拠★★ =
　★間違った `Len` でも たまたま 動く 経路は 在り得ます★
5. ★`section=-1` は ★`Begin` 経由で section が 無い★ という 意味★（★捏造していません★）

---

# §34 — #496-C ★trace の被覆を上げる★（worker3）

★事前登録★ = `PREREG_496C.md` / ★commit `ae30191`（★撃つ前★）★
★梃子★ = ★既存器 `DEGIMON_DUMP_ENTRY` + `DEGIMON_DUMP_SECTIONS`（`DialogueRuntime.DumpSections` `:2427`）★
　⇒ ★新しい 走査器を 書いていません★ / ★headless★ ⇒ ★user を 呼んでいません★

## 34.1 ★対照（受理条件 (2)）★

| 対照 | 結果 |
|---|---|
| ★gate OFF で `[OPTRACE]` 行★ | ★0 行★ |
| ★gate OFF / ON の `[DUMP]` 271 行★ | ★sha256 完全一致 `72605a6d88ba0a82…`★ ⇒ ★★1 bit も 変わっていません★★ |
| ★反復対照（別 run・同一 gate）★ | ★778 行が 完全一致★ |

## 34.2 ★★母数（誰も 数えていなかった もの）★★

★entry 101（mayo00 の loader）の section 数 = ★8★★
　= `5, 6, 7, 8, 9, 51, 52, 254`

★★枠★★ = ★`sectionId` は ★U16★（`DialogueData.cs:181` = `ReadU16` / `0xffff` が sentinel）★
　⇒ ★★key 全域 0-65534 を 全数 掃きました★★（5 chunk に 分割。`E2BIG` ゆえ）
　⇒ ★実在 8 ＋ 不在 65527 = ★65535★★ = ★★漏れ ゼロ★★

★★自分の 誤りの 申告★★:
　★初回は key `0-255` だけを 掃いて 「8 section」と 数えかけました★。
　★`sectionId` が U16 と code で 確かめて ★打ち切りだった★ と 判り 全域へ 拡げました★。
　⇒ ★★「打ち切られた list の 不在は 否定でない」★★ に 自分で 掛かっていました。

## 34.3 ★事前登録との 突合★

| # | 予想 | 結果 |
|---|---|---|
| O① | `-executeMethod` で runtime class を 叩ける | ★的中★（rc=0） |
| O② | gate OFF で 0 行 ＋ `[DUMP]` 一致 | ★的中★ |
| O③ | 一部のみ 実在 | ★的中★（★8 / 65535★） |
| O④ | 相異 pc が 78 より 増える | ★的中★（★78 → 277★） |
| ★O⑤★ | `SJIS-text` 行が 出る | ★★また 外れました（0 行）★★ ⇒ §34.4 |
| ★O⑥★ | 一部は `WaitingChoice` で 止まる | ★★外れました（0 件）★★ = ★8 section とも 走り切りました★ |

## 34.4 ★★O⑤ の 2 択が 決まりました（★不利な 側です★）★★

#490-C で 私は ★「経路を 走らせていない」のか「VM が trace 前に 消費する」のか 分けていない★ と 書きました。
★本便で 分かれました★ = ★★後者★★。

★証拠★:
- ★section 5 は ★text を emit しています★★（`[DUMP] s5 p0 text='「し、知らないぞ！」'`）
- ★なのに `[OPTRACE]` は `pc=0xAE`(0x1A) の 次が ★`pc=0xC8`★★ = ★間の 0x18 byte を 印字せず 飛んでいる★
- ★code★ = `DialogueRuntime.cs:986-991` ★★「0x1A は text を operand に 持つ 可変長命令」★★
　（★実機 854/854 で 検証済 と 書かれています★ = ★私の 発見では ありません★）
- ⇒ ★∴ text は ★loop 先頭に 戻らず★ operand として 消費され ★印字点を 通りません★★

★★∴ #490-C の 私の 一文を 取り消します★★:
　★誤★ =「78 点に text が 無い ⇒ (A) を 支持する」
　★正★ = ★★この器は 構造上 text を 印字できません★★ ⇒ ★`is_text=NO` は 「text が 実行されていない」ことの 証拠に ★なりません★★
　（★worker2 が この列を 反証に 使うと 誤ります★ ⇒ ★tsv の 冒頭にも 書きました★）

## 34.5 ★★副産物: `Len` と 実測の 食い違い（★worker2 に 直接 効きます★）★★

★新列★ = `next_pc_hex` / `delta_pc` / `delta_ne_len`（★同一 (entry,section) 内の 実測 pc 差★）

| opcode | `delta != len` の 件数 | 私の 読み |
|---|---|---|
| ★`0x1A` DIALOG_ADVANCE★ | ★★13 / 13（全数・例外ゼロ）★★ 実測 18-42 byte（表は ★2★） | ★可変長 operand（§34.4）★ |
| `0x19` COND_BRANCH | 101 | ★分岐＝制御移動★（★可変長では ありません★） |
| 上記以外 | ★0 件★ | — |

★★worker2 への 含意★★ = ★`Len[0x1A] = 2` を そのまま pc 進行に 使う walker は ★対話の たびに ずれます★★。
★但し★ = ★ずれた先が SJIS run なら ★text skip で 復帰する★ 可能性が 在ります★（★私は 検証していません★ = 札=材料）

★★分けていない こと★★ = `delta_ne_len=YES` の 原因を ★器は 分けていません★
　（★可変長 operand / 分岐 / section 終端 の 3 つが 混ざります★。★上表の 読みは 私の 判断★）

## 34.6 ★出力★

`W3_OPTRACE_for_worker2.tsv` = ★858 行 / 相異 (entry,sec,pc) 843 / ★相異 pc 277★★
　（#490-C 分 80 行 ＋ #496-C 分 778 行）

★`run` 列で 分けています（★混ぜません★）★:
- ★`o_sec` / `o_beg` / `o_cut`★ = ★#490-C の ★live-walk★★（★実機で player が 到達した★）
- ★`h_dump`★ = ★#496-C の ★headless-dump★★（★section の 頭から 直接 叩いた★）
　⇒ ★★「叩いた」は 「実機で 踏んだ」では ありません★★ = ★到達可能性の 証拠には なりません★

## 34.7 ★落とした 梃子（「切った」と「出なかった」を 分ける）★

| 梃子 | 落とした 理由 |
|---|---|
| `DEGIMON_V4_PLAYSECTION` | ★F9 の 押下が 要る★ ⇒ ★headless 不可 = user を 呼ぶ★ |
| `DEGIMON_NPC_TEST` | ★NPC 接近＝player build と 歩行が 要る★ ⇒ ★窓を 出す run★ |
| tile 52 を 実機で 踏む | ★同上（窓を 出す run の 停止命令が 生きています）★ |

⇒ ★★これらは 「出なかった」のでは なく ★私が 切りました★★★。
⇒ ★★∴ entry 101 の 8 section は 全部 踏みましたが ★他 entry は 1 つも 見ていません★★★
　（★mayo00 の 画面上の 出来事が entry 101 だけで 閉じている とは ★誰も 示していません★★）

---

# §35 — #501-C ★remake の map parser は 可変長を 扱えるか★（worker3）

## 35.1 ★★答（1 行）= ★可変長★★★ = ★★11 度目の「既に在った」★★

## 35.2 ★実体（file:行・★推測していません★）★

★remake は `.MAP` を ★直読していません★★ ⇒ ★json 経由★（boss1 §4 の 通り）
⇒ ★∴ 「json を 作った 器」まで 辿りました★ = ★`dwr_RE/tools/convert_map.py`★

| 場所 | 何を している か |
|---|---|
| `convert_map.py:264` | ★個数 = u16★ |
| `convert_map.py:269-271` | ★`digimon, pos = self._parse_digimon(pos)`★ ⇒ ★★戻り値の `pos` で 進む★★ = ★固定 stride で 加算していません★ |
| `convert_map.py:275-337` | ★record 本体★ |
| `convert_map.py:324` | ★`waypoint_count` = u16★ |
| `convert_map.py:333-336` | ★`for i in range(waypoint_count)` ＋ ★`pos += 6`★★ |

★offset を 積んだ 結果★（★私が 足し算しました★）:
`type@+0x00` / `position@+0x04`（★x@+0x04・y@+0x06・z@+0x08★）/ `rotation@+0x0A` /
`tracking_range@+0x10` / `script_id@+0x14` / stats@+0x16 / `moves@+0x2C` / `flee@+0x3C` /
★★`waypoint_count@+0x42`★★ / `waypoint_speed@+0x44`（16 byte 固定）/ ★`waypoints@+0x54`（6N）★
⇒ ★★全長 = 84 + 6N★★

★★worker1 の layout と 完全一致★★（`+0x78` 個数 / `+0x42` N / `84 + 6N`）
= ★★別々に 出した 2 つが 合いました★★（★私は worker1 の 数を 見てから 足し算していません★ …
　★★正直に 言えば 見ていました★★ ⇒ ★∴ これは ★独立な 対照では ありません★★ = ★偶然の 一致とは 主張しません★）

★★`96` の 固定 stride は map pipeline に 在りません★★（`convert_map.py` / `validate_map_data.py` / `verify_deployed_maps.py` を grep・0 件）

## 35.3 ★species 突合（★条件 (3) は 固定の場合のみ ですが 撃ちました★）★

★理由★ = ★★parser の source が 可変長でも ★配備済 json が その版で 作られた 保証は 別★★★。

★TWNB01 の 8 体（配備 json の 並び順）★:

| # | type | remake の 名 | worker1 |
|---|---|---|---|
| 1 | 157 | バケモン | バケモン |
| 2 | 155 | シェルモン | シェルモン |
| 3 | 128 | ベタモン | ベタモン |
| 4 | 152 | クネモン | クネモン |
| 5 | 16 | ツノモン | ツノモン |
| 6 | 140 | エレキモン | エレキモン |
| 7 | 172 | メガドラモン | メガドラモン |
| 8 | 154 | オーガモン | オーガモン |

★★8 / 8 一致（★順序も★）★★（名前解決 = `dwr_RE/docs/進化roster_id_name_2026-06-13.md`）
★N★ = `4,1,1,1,4,1,1,8` = ★★worker1 の N と 一致★★
★座標★ = `[-862,0,813] [2097,0,-1194] [225,0,-143] [2132,0,848] [316,0,452] [-234,0,2509] [-148,0,-2892] [-55,0,-2051]`
　（★worker1 の 座標を 私は 持っていません★ ⇒ ★突合は worker1 側で★）

★★独立な 対照★★ = ★`/home/ken/Desktop/vise/extracted/maps/twnb01/twnb01.json`（★別系統の 抽出★）と
　★`digimon` 配列が ★完全一致（`==` が True）★★ ⇒ ★生成器の 素性が 裏づきました★
　（★file 全体の sha256 は 違います★ = ★差は `spawn_points` のみ★ ⇒ ★札=材料・本便の枠外★）

## 35.4 ★★96 固定だったら どれだけ 壊れていたか（母数・全数）★★

★枠★ = ★`StreamingAssets/maps/<dir>/<dir>.json` が 実在する dir★

| 量 | 値 |
|---|---|
| 地図（json 実在） | ★242★ |
| うち digimon record を 持つ | ★211★ |
| record 全数 | ★966★ |
| ★★N != 2 の record★★ | ★★833（86.2%）★★ |
| ★N != 2 を 1 件でも 含む 地図★ | ★200 / 211★ |
| N の 分布 | `0:1, 1:595, 2:133, 3:83, 4:108, 5:13, 6:8, 8:25` |

⇒ ★★96 固定なら 966 record 中 833 が ずれていました★★ = ★MAYO00 が N=2 なのは ★本当に 偶然★★

## 35.5 ★★別軸の 欠落（★見つけましたが 直していません★ = 受理条件 (4)）★★

★★Unity 側は `waypoints` を ★読みません★★★ = `MapData.cs:34`
　★「JsonUtility は未宣言を無視。jagged moves/waypoints は読まない」★ と ★宣言済★
⇒ ★★∴ parser（json 生成）は 可変長で 正しいが ★consumer（C#）が 巡回経路を 捨てています★★★
⇒ ★これは ★parser の 欠陥では ありません★★ = ★別の 枠の 話★（★NPC が 巡回しない★）
⇒ ★★直していません★★ / ★★worker1 の layout の 妥当性には 影響しません★★

★C# が 読む field★ = `type` / `position` / `rotation` / `script_id`（`MapData.cs:35-41`）
⇒ ★★boss1 が 見たかった species と 座標は ★読まれています★★★

## 35.6 ★切ったもの / 見ていないもの★

- ★原盤 `.MAP` を 私は 読んでいません★（`dwr_RE` 配下に ★実体が 在りません★）
　⇒ ★★∴ 「json が 原盤と 合っている」は 検証していません★★（★2 つの 抽出が 互いに 一致した★ だけ）
- ★他 210 地図の species は 突合していません★（★worker1 の 答が TWNB01 の 8 体だけ ゆえ★）
- ★`spawn_points` の 差★ = ★見ましたが 追っていません★

---

# §36 — #501-C 追補 ★PRESIDENT 仮説の検定★（worker3）

## 36.1 ★答 = ★(丙)★★ = ★★仮説の 前提から 倒れます★★

★`96 固定` は ★#501-C で 既に 否定済★★（`convert_map.py:269-271` が 戻り値 `pos` で 進む・`96` は pipeline に 0 件）
⇒ ★∴ boss1 の 算術（真 0/108/198/288/378/486/576/666 対 96 固定 0/96/192/288/384/480/576/672 ⇒ 一致 {0,3,6}）は
　★正しい 算術ですが ★前提が 成り立ちません★★

## 36.2 ★★おまけに 集合も 合いません（★(乙) 側★）★★

★静的に 引きました★ = `type → species_model_codes.json → Resources/ViseNpc/{code}_Avatar.prefab`
（★経路は `EntityPlacer.cs:161-198` の 逐字★）

| idx | type | 名 | code | prefab |
|---|---|---|---|---|
| 0 | 157 | バケモン | EBAK | × |
| 1 | 155 | シェルモン | ESHE | × |
| 2 | 128 | ベタモン | EBET | × |
| 3 | 152 | クネモン | EKUN | × |
| ★4★ | ★16★ | ★ツノモン★ | ★TUNO★ | ★★在★★ |
| 5 | 140 | エレキモン | EELE | × |
| 6 | 172 | メガドラモン | EMGD | × |
| 7 | 154 | オーガモン | EOGR | × |

⇒ ★★prefab が 在るのは ★index 4（ツノモン）1 件だけ★★★
⇒ ★★boss1 の 予測集合 {0,3,6}（バケモン/クネモン/メガドラモン）と ★1 つも 重なりません★★★

★★かつ 実測は `2/8` では なく `1/8` です★★
⇒ ★★boss1 が 自分で 付けた 限定「`2/8` の 数え方を 確かめていない」が ★当たりでした★★★

## 36.3 ★★器の 陽性対照（★数を 出す前に★）★★

★PRESIDENT の「TOPN01 は 全部 合った」を 私の 述語に 当てました★:

| map | record | ★prefab 在り★ |
|---|---|---|
| ★topn01★ | 8 | ★★8 / 8★★ |
| ★mayo00★ | 5 | ★★5 / 5★★ |
| twna01 | 7 | 7 / 7 |
| ★twnb01★ | 8 | ★★1 / 8★★ |

⇒ ★★述語は 「全部 合う」側を 再現します★★ ⇒ ★1/8 は 器の 故障では ありません★

★★合わない ところ（★papering しません★）★★ = ★PRESIDENT は TWNA01 を ★3/3★ と 仰いました★ が
　★配備 json の TWNA01 は ★record 7 件★★（types 117,30,117,117,43,30,44 / 相異 4 種）
　⇒ ★★`3` の 出所を 私は 説明できません★★ ⇒ 札=材料

## 36.4 ★★真因 = ★prefab 不在★・E 接頭辞に 集中★★

| code の 帯 | prefab 在り |
|---|---|
| ★`E` で 始まる code★ | ★★2 / 53★★ |
| それ以外 | ★122 / 127★ |

★TWNB01 の 8 体は ★ツノモン 以外 全部 `E` 始まり★★（EBAK/ESHE/EBET/EKUN/EELE/EMGD/EOGR）
★実例★ = ★`BAKE_Avatar` は ★在ります★★ が それは ★type 37★ で、
　★バケモン(157) の code は `EBAK`★ = ★★別 id・prefab 無★★

★★私の 推論（★測定では ありません★）★★ = ★`E***` は enemy variant の 命名で、
　vise 側の asset 集合に ★その帯が 入っていない★★
　（★但し 在る 2 件 `ELEC` / `ETEM` は ★名前が E で 始まるだけ★ の 公算★ ⇒ ★実質 0 / 51★）

## 36.5 ★影響の 母数（全数）★

★枠★ = 配備 json 242 地図 / digimon record ★966★
⇒ ★★prefab が 引けない record = 392（40.6%）★★ = ★marker fallback★

## 36.6 ★限定★

- ★★静的です★★ = ★prefab file の 実在を 見ただけ★（★live で 実際に 立つかは 別★）
- ★`Resources.Load` の 失敗（prefab 破損 等）は 見ていません★
- ★★直していません★★（受理条件 (4)）/ ★user を 呼んでいません★
