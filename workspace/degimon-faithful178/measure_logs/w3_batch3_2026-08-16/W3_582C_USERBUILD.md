# W3_582C — ★口を 抜いた user build★（worker3 / #582-C）

事前登録 = `66dcba3`（★撃つ前★）／★land しません・push しません・user を 呼びません★
★「完成」「arc 完了」とは 書きません★／★`_3` の 材料（④ の 札）は ★撃っていません★（boss1 指定）

## 1. ★branch（★口を 含まない★）★
★`track3/w3-582c-userbuild`★ = ★`11df0b88`（main）＋ ★2 commit★★
| sha | 内容 |
|---|---|
| `179ae865` | 印字 gate を ★既定 ON★（`== "1"` → `!= "0"`） |
| `152885f9` | 直上 comment の 同期（挙動 不変） |
★差分★ = ★`EntityPlacer.cs` ★1 file・6 行 追加 / 2 行 削除★★

## 2. ★★口が 無いことの 実測（★grep の 実行行と 件数を そのまま★）★★
```
$ git grep -n "W3_MEASURE_FLAGS\|W3MeasureApplyFlags" -- unity/Assets
  件数 = 0

$ grep -rn "W3_MEASURE_FLAGS\|W3MeasureApplyFlags" unity/Assets --include=*.cs
  件数 = 0        ← ★untracked も 含む（Unity は filesystem discovery）★

$ grep -c "MakeGameState\|W3Measure" unity/Assets/Scripts/Boot/GameSession.cs unity/Assets/Scripts/State/GameState.cs
  unity/Assets/Scripts/Boot/GameSession.cs:0
  unity/Assets/Scripts/State/GameState.cs:0
```
★★陽性対照（★grep 自体が 効くことの 確認★）★★:
```
$ git grep -c "W3_MEASURE_FLAGS" track3/w3-578c-measure-flagport -- unity/Assets
  track3/w3-578c-measure-flagport:unity/Assets/Scripts/Boot/GameSession.cs:1
  track3/w3-578c-measure-flagport:unity/Assets/Scripts/State/GameState.cs:1
```
⇒ ★★∴ ★同じ command が 口の 在る branch では 2 件 出る★★ = ★0 件は ★器の 沈黙では ありません★★

## 3. ★compile★ = ★`result=Succeeded` / `error CS` ★0 件★★
★`Assembly-CSharp.dll`★ = ★256,512 byte / sha256 `98ae149939343d8958933aa21ac46e8be38cef6557247425f0fe8b32cbaf3032`★
（★口が 在る build581 は 257,536 byte ⇒ ★1,024 byte 小さい★★ = ★抜けたことの 傍証★）

## 4. ★★検収 = 5 / 5（★前 build の 引き写しでは ありません = 全部 撃ち直しました★）★★

| # | 予測 | 実測 | |
|---|---|---|---|
| S1 | 未設定で 印字・1 体 `rec=2` `type=3` | ★2 行印字・`rec=2 print_i=0 type=3 script_id=6`★ | ★PASS★ |
| S2 | `=0` で 0 行・`[PLACE]` 同一 | ★0 行★・★`[PLACE]` 逐字同一★ | ★PASS★ |
| S3 | h3 / h12 / h22 とも 同じ | ★3 点とも 1 体 `rec=2` `type=3`★ | ★PASS★ |
| S4 | `=1` 明示が 未設定と 同一 | ★逐字同一★ | ★PASS★ |
| ★★S5★★ | ★`W3_MEASURE_FLAGS=203` で ★何も 起きない★★ | ★★`[W3-MEASURE-FLAG]` 0 行★・★`PLACE-SPECIES` 全行 S1 と 逐字同一★・★`[PLACE]` も 同一★★ | ★★PASS★★ |

★外れ方 5 つ（甲乙丙丁 ＋ ★戊 = 抜き漏れ★）★ = ★★どれも 起きず★★

## 5. ★★実 GUI（★次元を 先に 固定した とおり★）★★

★実施★ = `DISPLAY=:1` ＋ `DEGIMON_BOOT_MAP=mayo00` ＋ `DEGIMON_START_HOUR=12` で ★1 回 起動★
| 見たもの | 結果 |
|---|---|
| ★窓が 出るか★ | ★★出ました★★（`wmctrl -l` = `0x01600008 … unity`） |
| ★`[PLACE-SPECIES]` が 出るか★ | ★★出ました★★ = `map=mayo00 idx=109 rec=2 print_i=0 type=3 script_id=6`・★合計 1 体★ |
| 画面 | ★`w3_582_gui_mayo00.png`（1,032,382 byte）★ |

★★これは ★絵の 忠実さの 検証では ありません★★★ = ★★「user が 起動して 何も 出ない」を 潰す ためだけ★★
★画面には ★1 体★ 描かれていました★ ⇒ ★★何かの 同定は しません★★（★同定は 我々が 一度 誤りました★）

★★器の 限定★★ = ★`import -window root` / `xwd -root` は ★BadMatch で 撮れません★★
　⇒ ★`import -window 0x01600008`（★窓 id 指定★）で 撮りました★ = ★★画面全体では なく ★その窓★★★

## 6. ★README 更新★ = `USER_RUN_README_581C_DRAFT.md`（`a730924`）
- §2 = ★新 hash / 新 branch / ★main に 無いものは 1 つだけ★★ ＋ ★grep 0 件（陽性対照つき）★
- §3 = ★`W3_MEASURE_FLAGS=203` の 行を ★落としました★★
- §6 = ★★残るお願いは ★user に 渡すかの PRESIDENT 判断★ だけ★★
- §7（新設）= ★私が 確かめた 範囲★（★窓と 印字・★絵の 検証では ない★・★同定 しない★）

## 7. ★母数 / 切ったもの★
- ★build 1 本★ / ★run 7 本★（S1 / S2 / S4 / S3h3 / S3h22 / S5 / GUI 1）
- ★★切ったもの★★ = ★他 map★ ／ ★絵の 忠実さ★（★user / PRESIDENT の 座★）／ ★`_3` の 材料（④ の 札のまま）★
- ★land・push していません★ / ★savestate・`.bak` 不触★ / ★`git add -A` 不使用★
