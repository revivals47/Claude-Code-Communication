# ★user 実視覚 PASS — 時刻による NPC 出し分け★（2026-08-18）

★★これは「arc 完了」ではありません★★（未了は §4）。★gate は依然 既定 OFF★。

## 1. user の申告（★逐語★）
「★★入れ替わっています。昼はモドキベタモンで、夜はドクネモンです。★★」

⇒ ★★= 入れ替わりの確認 ＋ ★向きの確認★ が 同時に取れました★★
⇒ ★★向きは これで 3 系統★★ = ★① worker1 の EXE 逐語（script）★ / ★② worker3 の実機（RAM）★ / ★③ user の目★

## 2. 何を走らせたか
build = `scratchpad/build553/DegimonLive/DegimonLive.x86_64`（11:43 生成・land 済 main `be1912b6` 由来）
起動 = PRESIDENT / 目視 = user / ★2 run の差は `DEGIMON_START_HOUR` だけ★
```
DEGIMON_TIME_PLACEMENT=1 DEGIMON_START_HOUR=12|22 DEGIMON_FIELD_MODELS=1 VISE_AVATAR_MODE=on
DEGIMON_INTRO_ENTRY=101 DEGIMON_BOOT_MAP=mayo00 DEGIMON_AUTOBOOT=1 DEGIMON_AUTOBOOT_SEC=25
DEGIMON_VISE_SHOTDIST=90
```
log = `USER_day_h12.log` / `USER_night_h22.log`（★昼 `field-model=3/3体`★）

## 3. 原盤側の機構（★これの説明が付いた★）
```
  0x002096  25 69                        HOUR → var[107]
  0x002098  var[107] >= 7 AND < 19  → 偽なら 0x0020B6
  0x0020A8  47 53 03 01 / 47 53 04 01    昼 = 83 モドキベタモン
  0x0020B6  47 4A 00 01 / 47 4A 01 01    夜 = 74 ドクネモン
```
★07:00-18:59 = 83 / 19:00-06:59 = 74★ ／ ★slot が `MAYO00.MAP` の record と 5/5 一致★

## 4. ★未了（★user に見えない分 ＋ 見える分★）★
- ★gate は 既定 OFF★（`DEGIMON_TIME_PLACEMENT == "1"` のときだけ）⇒ 既定 ON は PRESIDENT の別判断
- ★★夜側の model が 昼側の約 58% の大きさ★★ = ★model は出ている（marker ではない・陽性対照で確認）★ が
  ★★その大きさが原盤に忠実かは ★未測定★★★ ⇒ ★別の軸・別便★
- ★未説明の同座標対 37 組★（(i) 腕が覆わない 15 /(ii) site 無し 22）⇒ 第 2 の軸の有無は未決
- ★species 3 の第 2 の軸（flag 203）★ = 門は逐語で読めた / ★立てる者は未確定★
- ★実機の再入場は launch 経路★（歩いての入場と同一かは未確認）
- ★114 site のうち実機で確かめたのは MAYO00 の 1 本★

## 5. 経緯（1 行）
★user の「モドキベタモンとドクネモンは同時間帯には出てきません」（8/16）★ から始まり、
★原盤 disc の `.MAP` → script の条件式 → 実機 RAM → remake 実装 → user 実視覚★ まで繋がりました。
