# ★昼と 夜で 出る デジモンが 変わる★ — 見ていただく 手順（★draft・査読前★）

★★これは draft です★★ = ★boss1 と PRESIDENT の 査読を 経てから お渡しする 想定★
★★見ていただくのは ★`mayo00`（迷いの森）1 map だけ★ です★★（★理由は §5★）
作成 = worker3 ／ 元 ticket = #581-C

---

## 1. ★何を 見ていただくか★

★同じ場所（`mayo00`）に 入るのに ★時刻で 立っている デジモンが 変わる★★ — その 1 点です。

| state | 昼（07:00–18:59） | 夜（19:00–06:59） |
|---|---|---|
| ★新規開始（物語 序盤）★ | ★1 体（species 3）★ | ★同じ 1 体★ ＝ ★★変わりません★★ |
| ★進行後★ | ★2 体（species 83 が 2 体）★ | ★2 体（species 74 が 2 体）★ ＝ ★★入れ替わります★★ |

★★「序盤は 変わらない」ことも 仕様です★★（★原盤が そう なっています・§4★）

## 2. ★build★

| 項目 | 値 |
|---|---|
| 出力 | `<scratchpad>/build581/DegimonLive/DegimonLive.x86_64` |
| ★`Assembly-CSharp.dll`★ | ★257,536 byte / sha256 `32695e919af59e95e26394faba60de4bfa9deabf615c948442234901dd5d7a25`★ |
| 元 branch | `track3/w3-578c-measure-flagport` / HEAD ★`616418ae`★ |
| ★main との 差★ | ★`11df0b88`（land 済）＋ 4 commit★ |

★★⚠ この build に 入っている ★main に 無い もの★（★申告★）★★:
1. ★`DEGIMON_PLACE_SPECIES` を ★既定 ON★ にした 差分★（`9c1f23da`）= ★★本 README の 目的そのもの★★
2. ★測定専用の flag 口 `W3_MEASURE_FLAGS`★（`90926aba` / `b0dcfcab`）= ★★env を 設定しなければ 1 回も 動きません★★
　⇒ ★★user 向けとしては 2 が 余分です★★ ⇒ ★★2 を 抜いた build が 要るかは ★PRESIDENT の 判断★★★（★私は 決めません★）

## 3. ★起動手順★

```bash
# ★昼★（新規開始のまま = 変わらないことの 確認）
DISPLAY=:1 DEGIMON_BOOT_MAP=mayo00 DEGIMON_INTRO_ENTRY=101 DEGIMON_AUTOBOOT=1 \
  DEGIMON_START_HOUR=12 \
  <build>/DegimonLive.x86_64 -logFile /tmp/degimon_day.log

# ★夜★
DISPLAY=:1 DEGIMON_BOOT_MAP=mayo00 DEGIMON_INTRO_ENTRY=101 DEGIMON_AUTOBOOT=1 \
  DEGIMON_START_HOUR=22 \
  <build>/DegimonLive.x86_64 -logFile /tmp/degimon_night.log
```

★log の 見かた★（★既定で 出ます★ = ★#581-C で 既定 ON に しました★）:
```
[PLACE-SPECIES] map=mayo00 idx=109 rec=2 print_i=0 type=3 script_id=6 ps1=(-226,1688)
[PLACE-SPECIES] map=mayo00 ★合計 1 体★(…)
```
- ★`rec=`★ = ★原盤の 枠（slot）番号★ / ★`type=`★ = ★species★
- ★印字を 止めたい とき★ = `DEGIMON_PLACE_SPECIES=0`

★★進行後の 絵を 見る には★★ = ★物語を 進める か ★`W3_MEASURE_FLAGS=203`★ を 付ける★
　（★後者は ★測定用の 近道★ で ★製品の 挙動では ありません★）

## 4. ★★根拠 3 系統★★

| 系統 | 何を 見たか | 出典 |
|---|---|---|
| ★① 原盤の byte★ | `DG.SCN` の `mayo00` section を 逐語 復号（`19 00 01 00 CB 00` = 条件 / `18 00 96 18` = 偽跳び / `46 03 47 03 02 01` = species 3 を slot 2 / `25 69` = 時計 / 昼 `47 53 03 01` `47 53 04 01` / 夜 `47 4A 00 01` `47 4A 01 01`） | ★#571-C / #572-C★ |
| ★② 実機（DuckStation）★ | savestate を load して ★その section を 実際に 走らせ★ 昼 = slot 3,4 に 83 / 夜 = slot 0,1 に 74 / 序盤 = slot 2 に 3 | ★#566-C / #580-C★ |
| ★③ 我々の 実装★ | 同じ 3 つの 絵が ★remake の log で 出る★（rec 番号まで 一致） | ★#578-C★ |

## 5. ★★限定（★同じ頁に 焼きます★）★★

1. ★★`mayo00` 以外の map は 出しません★★
　 ⇒ ∵ ★他 6 map で 我々が 確かめたのは ★実装が ★我々の 表★ どおりに 動く★ ことまで★
　 ⇒ ★★= 自己整合であって 原盤との 突合では ありません★★（13/13 という 数は ★その 次元★）
2. ★★原盤と ★枠（slot）単位★ で 突き合わせたのは ★`mayo00` だけ★★★
3. ★★「進行後 = 2 体」の 母数 — ★次元を 分けます★★★:
　 ```
　 ★『2 体』の ★直接証拠★ は なお ★n = 1★ / ★間接（script が `0x47` を 実行した）★ が ★n = 2★
　 ```
　 ・★script が `0x47` を ★同じ species・同じ slot★ で 2 回 実行した 次元 = ★2 本★（`_9` / `_4`）
　 ・★★entity 配列に ★残っていた★ 次元 = ★1 本のまま★★★（#566-C）
　 ・★`bit203` が 1 であることは ★挙動で 判定★★（★savestate から 直読する 道具を 持っていません★）
　 ・★★かつ ★`_4` は 無作為の 1 本では ありません★★★
　 　 = ★本命は `_3` で・それが 落ちたので `_4` で 撃ち直しました★（★除外理由 = ★欠測★★）
　 　 ★`_3` は ★反証を 出したのでは なく 何も 出しませんでした★★ ⇒ ★除外は 妥当だと 考えます★
4. ★★`_3` が 落ちた ときの 形（★もし 同じ 落ち方を 見かけたら お知らせください★）★★
　 ```
　 excode 4 / epc 0x8009BAF4(昼)・0x8009806C(夜) / badv 0x8011DABF・0x0000001E / frame 266
　 ```
　 ★★これは 実機（DuckStation）側で 起きたもので ★理由は まだ 判っていません★★★
　 ⇒ ★★∴ ★この build で 似た 落ち方が 出たら それは ★我々の bug の 候補★ です★★
5. ★★「完成」とは 書きません★★ = ★見ていただいて 初めて 判ることが 残っています★

## 6. ★お願い（★boss1 / PRESIDENT へ★）★
- ★§2 の ⚠2（測定専用 口を 抜くか）★ の 判断
- ★user に お渡しするか どうか★ = ★★PRESIDENT★★（★worker3 も boss1 も user を 呼びません★）
