# W3_581C — ★印字 gate 既定 ON ＋ user build 準備★（worker3 / #581-C）

事前登録 = `6fd0c0c`（★撃つ前★）／★land しません・push しません・user を 呼びません★

## 1. ★差分（★私の branch のみ★）★
| sha | 内容 |
|---|---|
| ★`9c1f23da`★ | `DEGIMON_PLACE_SPECIES` を ★`== "1"` → `!= "0"`★（★既定 ON・明示 `=0` の 退路は 残す★） |
| ★`616418ae`★ | ★直上の comment が「既定 OFF」のまま 残り gate と 矛盾★ ⇒ 同期（★挙動 不変★） |

★branch★ = `track3/w3-578c-measure-flagport`（★#578-C / #580-C と 同じ・新規に 切っていません★）

## 2. ★compile★ = ★`result=Succeeded` / `error CS` 0 件★（`build581`）

## 3. ★★検収 = 4 / 4（外れ方 4 つは どれも 起きず）★★

| # | 予測 | 実測 | |
|---|---|---|---|
| S1 | 未設定で 印字・1 体 `rec=2` `type=3` | ★`rec=2 print_i=0 type=3 script_id=6`・合計 1 体★ | ★PASS★ |
| S2 | `=0` で 0 行・`[PLACE]` は 同一 | ★0 行★・★`[PLACE]` 行 逐字同一★ | ★PASS★ |
| S3 | h3 / h12 / h22 とも 変わらない | ★3 点とも 1 体 `rec=2` `type=3`★ | ★PASS★ |
| S4 | `=1` 明示が 未設定と 同一 | ★`[PLACE-SPECIES]` 全行 逐字同一★ | ★PASS★ |

★★(丁)（印字 既定 ON で ★置きが 変わる★）が 起きていないこと★★ = ★4 条件とも `[PLACE]` 既存行が S1 と 逐字同一★

## 4. ★README draft★ = `workspace/degimon-faithful178/USER_RUN_README_581C_DRAFT.md`（`f8a9045`）
- ★build hash★ = `Assembly-CSharp.dll` ★257,536 byte / sha256 `32695e91…`★ / branch HEAD `616418ae`
- ★起動手順★ = `DISPLAY=:1` ＋ `DEGIMON_BOOT_MAP=mayo00` ＋ `DEGIMON_START_HOUR=12 / 22`
- ★根拠 3 系統★ = 原盤 byte（#571-C / #572-C）／実機（#566-C / #580-C）／我々の実装（#578-C）
- ★見せるのは `mayo00` だけ★ ／ ★限定を 同じ頁に 焼きました★（自己整合の 13/13・slot 突合は mayo00 だけ・母数 2 の 次元）

## 5. ★★申告（★判断は 求めません★）★★
★この build には ★main に 無い もの が 2 つ★ 入っています★:
1. ★印字 既定 ON★（★本件の 目的★）
2. ★測定専用 flag 口 `W3_MEASURE_FLAGS`★（#577-C・★env 未設定なら 1 回も 動きません★）
⇒ ★★user 向けとしては 2 が 余分です★★ ⇒ ★★抜いた build を 作るかは boss1 / PRESIDENT の 判断★★

## 6. ★母数 / 切ったもの★
- ★build 1 本★ / ★run 5 本★（S1 / S2 / S4 / S3h3 / S3h22）
- ★★切ったもの★★ = ★他 map の 検収★（★見せるのは `mayo00` だけ★）／ ★実 GUI（`DISPLAY=:1`）での 目視★
  ⇒ ★★∵ ★私は headless で しか 撃っていません★★ = ★★画面に 出るかは 本便では 測っていません★★
- ★user を 呼んでいません★ / ★land・push していません★ / ★`git add -A` 不使用★
