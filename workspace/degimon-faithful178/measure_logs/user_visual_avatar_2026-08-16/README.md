# ★user 実視覚 PASS（avatar 4 件）★ 2026-08-16 夕

★★これは「field-character arc 完了」の宣言ではありません★★（未了は §4）。

## 1. 何を見せたか
build = `degimon_world_remake-integ/workspace/★build_m437c★/DegimonLive`（16:44 build / integ `4c8d2afa` 系）
env = `VISE_AVATAR_MODE=on` ＋ boot 補助（`AUTOBOOT/BOOT_MAP=mayo00/INTRO_ENTRY=101/POSTCUT_WALK/WALK_DIR=1,-1`）
起動 = PRESIDENT / 目視 = user

## 2. user の申告（逐語）
「★かなり良くなったと思う★」
（直前の所見 4 件 = ① TWNB で白カプセルに戻る / ② 向きが逆 / ③ 暗い / ④ ズーム過多）

## 3. 対応と根拠
| 件 | 処置 | 根拠 |
|---|---|---|
| ① map 跨ぎで消える | ★直した★（`_attached` latch 撤去 → 今の `[Player]` から引く） | 同 run の log: TWNB01(180 行)の★後★に `attach 回数=2 playerId=-73` / 修正前 = 0 行 |
| ② 向きが逆 | ★直した★（移動 delta から yaw・`YawBase` は offset） | 真因 = ★向きを決める logic が存在しない★（rotation/forward/facing = 0 件・設定は instantiate 時 1 回）⇒ 定数を替えても半分の方向で逆になる |
| ③ 暗い | ★直した★（unlit 側へ・material instance・退路 `DEGIMON_VISE_LIT=1`） | ★実体は輝度でなく彩度★: 上着 彩度 原盤 0.62 / lit 0.39 → ★unlit 0.62★（輝度 178.2 → 149.4、原盤 132.1 の方向）。★輝度低下は退行ではない★ |
| ④ ズーム過多 | ★直さない（仕様）★ | `viewer_distance` は map ごと（242/242・52 種）。mayo00 H=1511 → fov 9.08°。k=1.03 は phase1 DuckStation calibration（原盤 0.290 / remake 0.281）由来で、旧値 0.2 は機序つきで debunk 済 |

## 4. ★未了（user に見えない分）★
- 彩度の測定は ★上着 1 部位のみ★
- `Default-Material` 13 個（Blender 由来 icosphere）= ★可視性 0.000%（陽性対照 6.646%）ゆえ除去せず★・出所は変換 script 側
- scale calibration は ★twna01 で実施・mayo00 では未確認★
- ★既定 ON はまだしていない★（`VISE_AVATAR_MODE` 未設定 = no-op のまま）

## 5. PRESIDENT の誤り（この arc 中）
- 「頭部が灰白 ⇒ material 欠け」= ★誤り★（白 13 は body でなく icosphere）
- 「勾配が見えない ⇒ 陰影なし」= ★誤り★（勾配は原盤の方が大きい。正しい根拠は★符号が揃わない★）
- 「BOYS 3.55 対 Capsule 2.0 ⇒ 人が大きい」= ★誤り★（Capsule は placeholder で基準ではない）
⇒ 3 件とも ★worker3 が測定で覆した★。結論のうち残ったのは ③ の方向のみで、根拠は差し替わった。
