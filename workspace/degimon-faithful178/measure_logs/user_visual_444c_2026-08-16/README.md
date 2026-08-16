# ★user 実視覚 PASS★（PRESIDENT 立会・2026-08-16 15:2x）

★★これで ③ の ★user 実視覚 gate★ だけが閉じました。「③ 完了」ではありません★★（未了は §4）。

## 0. 数える前に枠を書く
| 語 | 定義 |
|---|---|
| 4 数 | 1 log 中の行頭 tag `[H8]`/`[TILE5179]`/`[MAPLOADER]`/`[BINDING]` の行数 |
| TWNB01 到達 | 同 log 中 `MapLoader] loaded 'TWNB01'` の行数 |
| 比べてよい数 | Δ(差分) と 序数のみ（★絶対 frame と object-identity hash は run 跨ぎで比べない★） |

## 1. 実行（PRESIDENT が起動・user が画面を目視）
build = `degimon_world_remake-integ/workspace/build_handoff_444c/DegimonLive/DegimonLive.x86_64`
dll sha256 = `4277d706976d0cfdab3562e30b5f45723ad1899a6aef996d4ffd1643074c2d0c`
env（★gate env はゼロ★・boot 補助のみ・H1 と逐語同一）:
`DEGIMON_AUTOBOOT=1 DEGIMON_AUTOBOOT_SEC=30 DEGIMON_BOOT_MAP=mayo00 DEGIMON_INTRO_ENTRY=101 DEGIMON_POSTCUT_WALK=1 DEGIMON_WALK_DIR=1,-1`

## 2. 結果 — H1（引き渡し build 自身の事前実測）と★全項目一致★
| run | H8 | TILE5179 | MAPLOADER | BINDING | TWNB01 | Δ(frame) |
|---|---|---|---|---|---|---|
| H1（事前） | 22 | 4 | 5 | 0 | 1 | 1 |
| ★USER_VISUAL（本 run）★ | ★22★ | ★4★ | ★5★ | ★0★ | ★1★ | ★1★ |

絶対 frame は fire 231 / queued 230（H1 は 233 / 232）= ★突き合わせない★（Δ のみ対）。

逐語:
- `:117 [TILE5179] tile=51 map=mayo00 → section 起動(入力 bit を読まない帯)`
- `:134 [DIALOGUE][SCRIPT] WARP_DEST(0x4B menu-idx) destIdx=0 map=180`
- `:166 [SCRIPTWARP] fire frame=231 queued=230 Δ(frame)=1 -> map=180`
- `:167 [MapLoader] loaded 'TWNB01' from 'maps/twnb01/twnb01.json'`

## 3. user の申告（逐語）
「目視終わりました。問題ありません。」
＋ 別途「まだキャラクターの表示はできないんだね」
⇒ ★白 Capsule placeholder は意図的★（`FieldManager.cs:503` = sprite-exact は field-character RE 後の別 arc）。★gap ではなく別 arc の未着手★。

## 4. ★これで閉じていないもの（札つき）★
1. b-2 = ★構造では直っている / 枝は frame 1 で走るが pending を pump した記録 0 本 / 裁定 B 次第★（boss1 ack 27 で「0 本 = 未実行」表現を訂正）
2. `[BINDING]` site 未実行（本 run でも 0）= 材料
3. 地図は mayo00 / twnb01 ほか少数（★239 未検証★）= 材料
4. ④-h8r（`WARP_DEST(0x4B faithful)` 到達性）= ★判定不能★・札 = 材料（op=0x6C 実装）
5. ★手動操作での到達は未検証★（本 run は POSTCUT_WALK による自動歩行）

## 5. PRESIDENT の申告（自分の誤り 1 件）
run の途中（NAMEINPUT 通過直後）に 4 数を数え ★全部 0★ を得た。★これは失敗ではなく「まだ書かれていない」★。
⇒ ★★走行中の log を数えると、走り切っていない 0 を『0 件』と読む★★ = 本日の「印字が無いことを 0 と読む」の ★時間版★。
⇒ remedy = ★log を数える前に process の終了（と `Shutdown` 行）を確かめる★。
