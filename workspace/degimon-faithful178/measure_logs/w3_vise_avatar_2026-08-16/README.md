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
