# ★★VISE_AVATAR_MODE=on で ★少年が 立ちました★★★（worker3 / #454-C）2026-08-16

## 0. ★★答（1 行）★★

★★立った物 = ★少年★★★（★digimon では ありません★ / ★何も出ない でも ありません★）
⇒ ★★「BOYS = player」の 裏づけ★★。

## 1. ★`ViseAvatarBootstrap.cs` の 逐語（★推測していません★）★

`VISE_AVATAR_MODE`（:3 の comment と :15-56 の 実体）:

| 値 | 挙動 |
|---|---|
| ★未設定★ | ★完全 no-op★（component 不在・★1 bit も 動かない★） |
| ★`inert`★ | attach ＋ ★`useViseModel=false`★（component は 在るが model を 出さない） |
| ★`on`★ | attach ＋ ★BOYS 表示★ |

`DEGIMON_VISE_SHOT`（:4, :92）= ★★screenshot 出力 path★★（★名前どおり★ / 3 mode 共通の pixel 比較用）
＋ `DEGIMON_VISE_CAPSEC`（撮影時刻 override）/ `DEGIMON_VISE_NOFRAME=1`（★framing cam を作らず game camera★）
／ `DEGIMON_VISE_GAMECAM=1`（game camera projection の 複製）
／ ★`DEGIMON_VISE_SHOTDIST`（本便で 私が 足した・既定 2.2 = 従来値）★

★model の 出所★ = `Resources.Load<GameObject>("ViseAvatar/BOYS_Avatar")`（:54）
⇒ ★`Assets/Resources/ViseAvatar/BOYS_Avatar.prefab` 実在★ ／ ★`Resources/ViseNpc/*.prefab` = 136 本★

## 2. ★★撮った 3 枚（★対を 揃えました★）★★

| png | mode | camera | 立った物 |
|---|---|---|---|
| ★`vise_inert.png`★ | ★`inert`（対照）★ | ★game camera★ | ★白 Capsule のみ★ |
| ★★`vise_on_noframe.png`★★ | ★`on`★ | ★★game camera（★同一★）★★ | ★★白 Capsule ＋ ★少年★★★ |
| `vise_wide.png` | `on` | framing cam（`SHOTDIST=9`） | ★少年の 全身★（判別用） |

★★∴ 対は ★上 2 枚★★（★同じ camera・env だけ 違う★）
⇒ ★★gate を `on` にすると 少年が 出る / `inert` では 出ない★★ = ★★配線は 生きています★★

★`vise_wide.png` の 見え★ = ★灰/銀の 帽子・黄橙の ベスト（丸い 意匠）・藤色の ズボン・白い 靴・
腰に 黄土色の 鞄★ ⇒ ★★人型の 少年★★（★digimon の 特徴は 見当たりません★）。

## 3. ★★併せて 判った こと（★これが 本当の gap★）★★

★★白 Capsule は 消えていません★★ = ★少年と ★並んで 立ちます★★（★boss1 の 指示どおり 消していません★）
★かつ 位置が ずれています★ = ★少年は Capsule の ★すぐ上（奥）★ に 立つ★
⇒ ★★∴ 残る 仕事は 「branch の merge」でも「model の 用意」でも なく★★
　★★① gate の 既定（今は 未設定 = no-op）★★ ＋ ★★② Capsule の 撤去★★ ＋ ★★③ 位置合わせ★★

## 4. ★★見ていないこと（母数の 申告）★★

1. ★★game camera scale では 少年は ★小さい★★★ = ★`vise_gamecam.png`（fov 7.57 / 深度 117 の 複製）では
   ★Capsule しか 見えませんでした★★ ⇒ ★★複製 camera と 実 game camera は 別物★★（★本 README の 対は ★実 game camera★★）。
2. ★歩行 anim / Idle anim は 見ていません★（★静止 1 枚のみ★）⇒ 札 = ★材料★
3. ★NPC 136 種は 出していません★（本便は ★player の BOYS だけ★）⇒ 札 = ★材料★
4. ★user 実視覚は 経ていません★ ⇒ ★★完成 claim では ありません★★・★「③ 完了」とも 書いていません★

## 5. ★run の 出所（`[RUNBY]`）★
`[RUNBY] who=worker3/454-C/… build='…/build_m437c/DegimonLive' / TILE_5179=ON / MAP_LOADER=ON`
⇒ ★user の 観測と 取り違えない ため★（★本日 実際に 起きた 事故の remedy★）。

★sha256★
```
9bf4b5e4741396282616abf34e1f9c15e2de7184b619493774b0f32138abad0c  vise_inert.png
a4d7ec57fea8d2d8360b122f53de6a25f32941535f14d81eb4b95b9f6a8d590f  vise_on_noframe.png
6e191f00808347935a28436f76d26b895ca4af52ea79b14ba9179430b4eca382  vise_wide.png
```

---

# ★#455-C = user の 2 件を 直しました★

## 6. ★① map を跨ぐと 白 Capsule に戻る = ★直った★★

★真因★ = `ViseAvatarBootstrap.cs` の ★`bool _attached` = ★process 生存の 1 度きり latch★★
⇒ ★map 変更で field が rebuild され `[Player]` は ★別の GameObject に 入れ替わる★★
⇒ ★★latch の 寿命（process）と 追跡対象の 寿命（map ごとの rebuild）が 違う★★ = ★★h-8 と 同型★★

★fix★ = ★★latch を 撤去し「★今の `[Player]` に component が 付いているか★」で 判定★★
　（= ★本日の「焼かずに引く」を そのまま 当てただけ★）

★★受理条件（boss1 指定）= 満たしました★★ — `cross_map.log`:
```
  171 行目: [MapLoader] loaded 'TWNB01'          ← ★map 跨ぎ★
  182 行目: [VISE_BOOTSTRAP] attach [Player] … ★attach 回数=2★ frame=233 playerId=-690
  183 行目: [VISE_CTRL] BOYS instantiated: worldPos=(-27.30, 0.00, 5.93) renderers=27
```
★★TWNB01 到達行より ★後★ の `VISE_*` = 2 行★★（★修正前は 0 行★）
★playerId が `-254` → `-690`★ = ★★別の GameObject に 付き直した★★ ことが 数で 見えます。

## 7. ★② 向きが逆 = ★実測してから 直しました★★

★★決めつけていません★★ — ★先に 数えました★:

| 実測 | 結果 |
|---|---|
| `Scripts/Field/` ＋ `ViseAvatar/` の rotation site 全数 | grep で 列挙 |
| ★`PlayerController.cs` の rotation / forward / facing★ | ★★0 件★★ ⇒ ★player は 回らない★ |
| 向きを 決める site | ★`ViseAvatarController.cs:51` の ★1 箇所だけ★★ |
| その site の 更新 | ★★instantiate 時の 1 回だけ★★（`Update()` は Speed しか 触らない） |

⇒ ★★∴ 「向きが 逆」の 実体 = ★向きを 決める logic が ★存在しない★★★★
　= ★歩く方向に かかわらず ★固定 180°★ を 向き続ける★
　（★user の「アニメーションは 正しい」と 整合★ = Speed 駆動の anim は 効いていた）
⇒ ★★∴ 定数を 別の 定数に 替えても 直りません★★（★どの値でも 半分の 方向で 逆になる★）

★fix★ = ★★移動 delta から yaw を 引く★★（★`Update()` が Speed 用に 既に 計算している 量★ = 新しい入力を 増やさない）
　＋ ★`YawBase`（従来 180° を 既定）を offset として 残す★（★env `DEGIMON_VISE_YAWBASE` で 実測可★）
　＋ ★停止中は 最後の 向きを 保つ★

★★「別の 固定値に なっただけ」で ない ことの 対照★★:

| png | 歩行方向 | 見え |
|---|---|---|
| ★`vise_yaw.png`★ | ★`WALK_DIR=1,-1`（camera へ 近づく）★ | ★★顔が こちらを 向く★★（帽子の goggles・黄の 上着の 意匠・顔が 見える） |
| ★`vise_yaw_away.png`★ | ★`WALK_DIR=0,1`（camera から 離れる）★ | ★★背中★★（帽子の 後ろ・上着の 背・顔は 見えない） |

⇒ ★★∴ yaw は ★移動方向に 追従★ しています★★（★固定値なら 両方 同じ 見えに なります★）
★参考★ = ★修正前の `vise_wide.png` は ★同じ `WALK_DIR=1,-1` で 背中★★ ⇒ ★★逆だった★★。

## 8. ★まだ 見ていないこと（母数の 申告）★

1. ★★`YawBase` の 値が 忠実かは 決めていません★★ = ★既定 180° は ★従来値を 残しただけ★★。
   ★原盤の 向きとの 突合は 未実施★ ⇒ 札 = ★材料★（env で 振れる形には しました）。
2. ★斜め歩行の 中間角は 見ていません★（★2 方向だけ★）⇒ 札 = ★材料★
3. ★NPC 136 種は 未実施★ / ★anim の Idle/Run 遷移は 未確認★ ⇒ 札 = ★材料★
4. ★`VISE_AVATAR_MODE` は ★既定 OFF のまま★★（★PRESIDENT 裁定どおり 既定 ON に していません★）
5. ★`FieldManager.cs` の Capsule は ★消していません★★（★判別を 残すため★）
6. ★★user 実視覚 未★★ ⇒ ★完成 claim では ありません★・★「③ 完了」とも 書いていません★

---

# ★#456-C = ③ material / ④ 切り分け(a)★

## 9. ★★③ material は lit か unlit か（★逐語★）★★

★★lit です★★ — ★但し boss1 の 推定した 経路とは 違いました★:

| 見たもの | 実測 |
|---|---|
| `ViseAvatar` 配下の `.mat` | ★★0 件★★（boss1 の 申告と 一致） |
| `BOYS.fbx.meta` の importer | `materialImportMode: 2` / `materialName: 0` / `materialSearch: 1` / `materialLocation: 1` |
| ★★prefab の `m_Materials`★★ | ★★`{fileID: 10303, guid: 0000000000000000f000000000000000, type: 0}`★★ |

★`guid: 0000…f000…` = ★Unity 内蔵 resources★ / `fileID: 10303` = ★★`Default-Material`（Standard shader）★★
⇒ ★★∴ ★lit★★（★白 Capsule の `Unlit/Color` と 対照的★）

★★訂正 1 点★★ = boss1 は「material は ★FBX import 由来★」と 推定されましたが、
★実測では ★import された material は 1 つも 作られておらず（`.mat` 0 件）★、
prefab は ★Unity 内蔵の `Default-Material` を 直接 指しています★★。
⇒ ★★結論（lit）は 同じ / 経路が 違います★★。

★★∴ 「光源 0 の field に lit の model」は 整合します★★（暗いことの 説明として）。

### ★原盤の 陰影を 見る 手順の 提案（★決め打ちません★）★
★★screenshot で 暗さを 確認しない★★ = `ViseAvatarBootstrap.cs:89-90` の Directional Light は
★`mode=="on" && (gameCam || !noFrame)` のときだけ 作られる★ ⇒ ★撮影経路が 光源を 足す★。
提案（★安い順★）:
1. ★DuckStation で 原盤の 同一 map・同一 時間帯を 出し、★同一 pixel 位置の 明度を 数で★ 比べる★
   （★「明るい/暗い」でなく ★数★★ = memory `reference_duckstation_live_ram_capture` の 経路）
2. ★原盤に ★時間帯で 明度が 変わるか★ を 見る★ ⇒ ★変われば 光源が 在る / 変わらねば baked★
3. ★1-2 の 結果で ★unlit に 寄せるか 光源を 足すか★ を PRESIDENT が 決める★
⇒ ★★私は どちらにも 寄せていません★★（★code を 触っていません★）。

## 10. ★★④ 切り分け (a) = avatar を付けずに 同じ map・同じ地点★★

| png | `VISE_AVATAR_MODE` | 見え |
|---|---|---|
| ★`vise_off.png`★ | ★未設定（= avatar OFF）★ | ★★草地が 画面いっぱいに 広がる★★ / ★白 Capsule は 小さい★ |
| `vise_on_noframe.png` | `on` | ★同じ 広さ★ ＋ ★小さい 少年★ |

★★∴ ★avatar 無しでは 「ズームされ過ぎ」に 見えません★★★
⇒ ★boss1 の 判定規則に 当てると ★「人が 大きい」側★★。

★支える 数★:
・★BOYS `boundsSize.y = 3.55`★（log 実測）対 ★Capsule = `localScale=(0.6, 1.0, 0.6)` の 既定 capsule = ★高さ 2.0★★
　⇒ ★★約 1.78 倍★★
・★`modelScale` の 既定 = ★1.03★★（comment に ★faithful=1.03★ と 在る）
　⇒ ★★∴ scale 1.03 の まま 3.55 になる = ★model 自体の 素の 高さが 3.45 相当★★★
　⇒ ★「1.03 が 忠実」と ★3.55 が 大き過ぎる★ は ★両立しません★★ ⇒ ★どちらかの 前提が 誤り★

★★但し 私は ここで 止めます★★ = ★「見た目で 調整」しない★（PRESIDENT 裁定）
⇒ ★次は ★原盤の 人の高さ ÷ 画面の高さ★ の 比で 合わせる★ ⇒ ★DuckStation 比較が 要る★ ⇒ 札 = ★実機★

★★抜き取り検算（全数は 再測していません）★★ = `mayo00` の `viewer_distance` を 1 件だけ 読み直し
⇒ ★`H=1511` / `fov = 2·atan(120/1511) = 9.08°`★ = ★★boss1 申告と 一致★★。

★sha256★
```
bcadd2ad945e4ca88b0eff6c6cc14fec79a07dab111cc2ee2d94129b5017d48b  vise_off.png
```

---

# ★#458-C = ③ を 数で 測りました（★2 件とも 前提が 変わります★）★

## 11. ★★(a) 陰影 = ★結論は 支持・根拠は 違う★★★

★測ったもの★ = `VISE_AVATAR_scale_ORIG_vs_gamecam_k1.png`（★撮り直していません★）
★★上下勾配は 部位の 固有色に 支配されるので 陰影の 指標に なりません★★
⇒ ★★同一部位の 中での 上下差★★ で 測り直しました:

| 部位 | 上 | 下 | 差 |
|---|---|---|---|
| ★原盤★ 黄フード | 131.9 | 180.5 | ★−48.6★ |
| ★原盤★ 灰の頭 | 112.2 | 86.4 | +25.9 |
| ★原盤★ 黄上着 | 144.2 | 119.9 | +24.2 |
| remake 灰兜 | 153.5 | 139.6 | +13.9 |
| remake 黄上着 | 197.7 | 202.8 | −5.1 |
| remake ズボン | 130.7 | 123.8 | +6.9 |

★★∴ PRESIDENT の 結論（方向性の 陰影は 認められない）は ★支持されます★★★
★但し 根拠が 違います★:
・★「勾配が 小さい」からでは ありません★ = ★原盤の 勾配（24〜49）は remake（5〜14）より ★大きい★★
・★★支持する 根拠は ★符号が 揃わない★ こと★★ = ★フードだけ −48.6 で 他は +★
　⇒ ★単一光源なら 全部位で 符号が 揃うはず★ ⇒ ★★揃わない = 陰影でなく 固有色/texture★★

## 12. ★★「remake が 暗い」は ★輝度では 逆★★★

| 部位 | 原盤 輝度 | remake 輝度 | 原盤 彩度 | remake 彩度 |
|---|---|---|---|---|
| 上着 | 132.1 | ★200.4★ | ★0.62★ | ★0.35★ |
| 頭 | 99.3 | ★146.5★ | 0.04 | 0.08 |
| ズボン | 92.7 | ★127.2★ | 0.17 | 0.22 |

★★∴ remake は ★全部位で 明るい★★★ ⇒ ★「暗い」は 輝度では 支持されません★
★★∴ 支持されるのは ★彩度の 低下★★★（上着 0.62 → 0.35）
⇒ ★★user の「暗い」は ★くすみ（彩度）★ の 可能性が 高い★★
⚠ ★交絡★ = ★原盤 boy は ★小屋の 陰の 中★・remake は ★日向★★ ＋ ★原盤は 224p の 拡大★
　⇒ ★輝度の 直接比較は 場面差を 含みます★（★彩度差は 場面差では 説明しにくい★）

## 13. ★★(b) 13/27 = ★部位では ありませんでした★★★

★prefab の 全 27 renderer を 名前つきで 数えました★:

| 群 | 数 | material |
|---|---|---|
| ★`Mesh_0` 〜 `Mesh_13`★ | ★★14★★ | ★fbx 埋め込み material（全部 当たっている）★ |
| ★`ICO球` 〜 `ICO球.012`★ | ★★13★★ | ★内蔵 `Default-Material`★ |

★★∴ 「13/27 が material 欠け ⇒ 頭部が 白い」は 成立しません★★:
・★body mesh は `Mesh_0..13` の 14 個で ★全部 material が 当たっています★★
・★白の 13 は ★`ICO球` = Blender の icosphere★★ = ★★body の 部位では ありません★★
・★∴ 頭部は 含まれません★

### ★なぜ 14 と 13 に 割れたのか（★逐語で 追いました★）★
・`RIG_ANALYSIS.md:10` = ★glTF は ★14 mesh★★
・`RIG_ANALYSIS.md:57` = ★Unity import 後 ★27 MeshRenderer★★
・`PROVENANCE.md:31` = 変換 chain に ★`vise glb_to_fbx.py`（Blender、+Armature wrapper）★
・★fbx の raw byte 検索★ = ★`ICO` 26 回 / `球`(UTF-8) 26 回 / `Mesh_N` 14 種★
　（★= 13 個 × 2（Model + Geometry）★）
⇒ ★★∴ 13 個の icosphere は ★fbx に 実在★ = ★glb(14 mesh) → fbx の Blender 変換で 混入★★
⇒ ★★∴ material 割当の 失敗では ありません★★
　= ★★そもそも material を 持たない ★非 game-derived の object★ が 13 個 入っている★★
⇒ ★★∴ 直し方は「material を 与える」ではなく ★除去★ の 公算★★（★判断は PRESIDENT★）

★★記録に 数は 在ったのに 突き合わされていませんでした★★ =
`RIG_ANALYSIS` が ★glb 14 mesh★ と ★Unity 27 renderer★ を ★別々の 節に 書いており★、
★14 → 27 の 差 13 を 誰も 引いていません★（★lossless 検査は ★bone 数 17★ だけ 見ていた★）。

## 14. ★見ていないこと（母数の 申告）★
1. ★13 個の icosphere が ★画面に 見えているか★ は 未測定★（active=1 / localScale=1.0 は 確認済）
　⇒ ★安い 検め方★ = ★13 を 無効化して 前後の pixel 差を 取る★ ⇒ 札 = ★自分の器★
2. ★私は ③ の code を 触っていません★（★診断が 変わったため 先に 報告★）
3. ★輝度比較は 場面差（陰 vs 日向）を 含みます★ ⇒ ★同一場面での 比較は 未実施★ ⇒ 札 = ★材料★

---

# ★#459-C = (b)① 可視性 / (a) unlit★

## 15. ★★(b)① 13 個の icosphere は ★1 pixel も 見えていません★★★

★手で 消していません★ = ★env gate（`DEGIMON_VISE_HIDE_PREFIX`）で ★隠すだけ★・既定 OFF★。

| run | 隠した renderer | base との pixel 差 |
|---|---|---|
| ★`ICO` を隠す★ | ★13 個★ | ★★0 / 307200 = 0.000%（bbox = None）★★ |
| ★★陽性対照: `Mesh_` を隠す★★ | ★14 個★ | ★★20416 / 307200 = 6.646%（bbox = (288,110,439,401) = boy 領域）★★ |

⇒ ★★∴ 器は 生きています★★（★見える物を 隠せば 差が 出る★）
⇒ ★★∴ 13 個の icosphere は ★画面に 寄与していません★★★
⇒ ★boss1 の 規則より ★除去は 見た目に 効かない ⇒ 今は 除去しない★★（★見た目の gap では ない★）
　★但し★ = ★★非 game-derived の object が 13 個 混入している★★ 事実は 残ります（下記 §17）。

## 16. ★★(a) unlit = ★受理条件 充足★★★

★★目的は「明るくする」では ありません★★（★実測で remake は 全部位で 明るい★）
= ★★彩度の 回復★★。★光源は 足していません★。

| | 輝度 | ★彩度★ |
|---|---|---|
| lit（従来） | 178.2 | ★0.39★ |
| ★★unlit（本便）★★ | 149.4 | ★★0.62★★ |
| ★原盤 上着（参考）★ | 132.1 | ★0.62★ |

⇒ ★★受理条件「彩度が 原盤 0.62 に 近づく」= ★一致（0.62）★★★
⇒ ★★輝度は 178.2 → 149.4 と ★下がりました★ = ★原盤 132.1 の 方向★ = ★正しい 動き★★
　★★⚠ 「暗くなった = 退行」と 読まないでください★★（★受理条件に 明記★）

★機序（PRESIDENT の 読み・★私の 測定の 符号と 一致★）★ =
★lit ＋ 光源ゼロ ⇒ ambient のみ ⇒ 全方向 一様 ⇒ ★輝度は 上がり 彩度は 落ちる★★
⇒ ★unlit なら texture 固有色が そのまま 出る ⇒ 彩度が 戻る★
⇒ ★★実測が この 符号どおりに 動きました★★（★輝度 ↓ / 彩度 ↑★）

★副作用の 確認★ = ★切替 14 個 / ★texture 無しの 13 個（= ICO球）は 据え置き★★
　（`Unlit/Texture` は build の Always Included Shaders に 既に 在り）
★退路★ = ★`DEGIMON_VISE_LIT=1` で 従来の lit へ★（★実測で 0 行 = 効いています★）
★asset を 汚していません★ = `rn.material`（instance）に 対して 切替。

★png★ = `boy_unlit.png`（本便）/ `boy_lit.png`（従来・A/B）/ `ctl_mesh.png`（陽性対照）

## 17. ★台帳に 1 行（★収載しません★）★

★`RIG_ANALYSIS.md` が ★:10 glTF 14 mesh★ と ★:57 Unity 27 MeshRenderer★ を ★別々の 行に 書き、
★27 − 14 = 13 を 誰も 計算していませんでした★★
＋ ★lossless 検査は ★bone 数 17★ だけ 見ており ★mesh 数を 射程に 含めていません★★
⇒ ★★= 数は 記録に 在ったのに 突き合わされなかった 実例★★。

## 18. ★見ていないこと（母数の 申告）★
1. ★彩度は ★上着 1 部位★ で 判定★（★他部位は 未測定★）⇒ 札 = ★材料★
2. ★輝度の 直接比較は 場面差（原盤 = 小屋の 陰 / remake = 日向・原盤は 224p 拡大）を 含みます★
　⇒ ★★だから 判定は 彩度で 行いました★★（交絡の 申告）
3. ★13 個の 除去は ★していません★★（見た目に 効かないため）。★変換 script 側の 扱いは 未着手★ ⇒ 札 = ★材料★
4. ★user 実視覚 未★ ⇒ ★「③ 完了」と 書いていません★
