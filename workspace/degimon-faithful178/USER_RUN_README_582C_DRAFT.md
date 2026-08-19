# ★昼と 夜で 出る デジモンが 変わる★ — 見ていただく 手順（★draft・査読前★）

★★これは draft です★★ = ★boss1 と PRESIDENT の 査読を 経てから お渡しする 想定★
★★見ていただくのは ★`mayo00`（迷いの森）1 map だけ★ です★★（★理由は §5★）
作成 = worker3 ／ ★本 README の ticket = #582-C★（★#582-C-R で 撃ち直し（2026-08-20 00:5x）★）
　※ ★実装差分そのものの 出所は #581-C★（下の §2・§3 に 出てくる `#581-C` は ★その commit の 出所★ の意味です）
　※ ★file 名が `..._581C_...` だったのは 誤りでした★ ⇒ ★`USER_RUN_README_582C_DRAFT.md` に 改名しました★

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
| ★出力（★絶対 path★）★ | ★`/home/ken/Desktop/Digimon/w3_build582r/DegimonLive/DegimonLive.x86_64`★ |
| build log | `/home/ken/Desktop/Digimon/w3_build582r/unity_build_582cr.log` |
| ★`Assembly-CSharp.dll`★ | ★256,512 byte / sha256 `98ae149939343d8958933aa21ac46e8be38cef6557247425f0fe8b32cbaf3032`★ |
| compile | `result=Succeeded` ／ ★`error CS` = 0 件★（★build log を grep -c した実測★） |
| 元 branch | `track3/w3-582c-userbuild` / HEAD ★`152885f9`★ |
| ★`main` との 差★ | ★`11df0b88`（★ローカル `main`＝`6980befd` に 入っています★）＋ 2 commit（★同じ 1 file だけ★）★ |

★★★出力先について（★2026-08-20 の 作り直しの 理由★）★★★
- ★前の build は `/tmp` 配下に 置いていて ★OS 再起動（00:40:57）で 消えました★★（`find /tmp /home/ken/Desktop -maxdepth 6 -name 'build58*'` = ★0 件★）
- ⇒ ★★今回は `/tmp` 配下に 置いていません★★（上の 絶対 path）。★`workspace/build/` と `build_handoff_444c/` には 1 byte も 書いていません★

★★★`main` の 二義性に 枠を 添えます★★★（★これを 書かないと 検算できません★）
```
  ローカル main      = 6980befd  ⇒ ★11df0b88 は ★この main に 入っています★★
  origin/main        = ca34f972  ⇒ ★こちらには 入っていません★（★push していません★）
```
⇒ ★∴ 上の 表の「`main` との 差」は ★ローカル `main`（`6980befd`）を 基準★★ に 書いています。

★★`sha256` が 前回と 一致したこと について★★
- ★前回（#582-C・消えた器）と ★同じ 256,512 byte / 同じ sha256★ が 出ました★
- ★但し これは ★傍証★ であって ★証明では ありません★★ = ★Unity 生成物の byte 再現性を 我々は 測っていません★
- ★挙動の 側は 別に 撃ち直しています★（★S1-S5 = 下の §7★）

★★main に 無いものは ★1 つだけ★ です★★:
- ★`DEGIMON_PLACE_SPECIES` を ★既定 ON★ にした 差分★（= ★本 README の 目的そのもの★）

★★以前の draft に 入っていた ★測定用の 近道（`W3_MEASURE_FLAGS`）は ★抜きました★★★★
　★理由★ = ★測定用の 口が 同居していると ★何を 見た 結果か★ が 割れるため★

★実測（★今回 build した source に 対して 撃ち直し・実行行と 件数を そのまま★）★:
```
$ git rev-parse HEAD
152885f9aa79071b9f9c87b1470421f54aec7e0b

$ git grep -n "W3_MEASURE_FLAGS\|W3MeasureApplyFlags" -- unity/Assets
（出力なし・exit=1）                                         → ★件数 = 0★

$ grep -rn "W3_MEASURE_FLAGS\|W3MeasureApplyFlags" unity/Assets --include=*.cs
（出力なし・exit=1）                                         → ★件数 = 0★（★untracked 込み★）

$ grep -rn "W3-MEASURE-FLAG" unity/Assets --include=*.cs | wc -l
0                                                            → ★印字側の marker も 0★
```
★★陽性対照（★口が 在る branch で 同じ command が 何件 出るか★）★★:
```
$ git grep -c "W3_MEASURE_FLAGS\|W3MeasureApplyFlags" track3/w3-578c-measure-flagport -- unity/Assets
track3/w3-578c-measure-flagport:unity/Assets/Scripts/Boot/GameSession.cs:1
track3/w3-578c-measure-flagport:unity/Assets/Scripts/State/GameState.cs:3
                                                             → ★2 file / 計 4 行★

$ git grep -c "W3-MEASURE-FLAG" track3/w3-578c-measure-flagport -- unity/Assets
track3/w3-578c-measure-flagport:unity/Assets/Scripts/Boot/GameSession.cs:1
track3/w3-578c-measure-flagport:unity/Assets/Scripts/State/GameState.cs:1
                                                             → ★2 file / 計 2 行★
```
⇒ ★★∴ 上の 0 件は ★器の 沈黙では ありません★★（★同じ command が 口の 在る branch では 拾えています★）
　 ★filesystem discovery の 分も 見ました★ = ★`unity/Assets` 配下の untracked `.cs` は 1 本のみ（`Scripts/Editor/W3ViseNpcConvert.cs`＝Editor 専用）★

## 3. ★起動手順★

```bash
EXE=/home/ken/Desktop/Digimon/w3_build582r/DegimonLive/DegimonLive.x86_64

# ★昼★（新規開始のまま = 変わらないことの 確認）
DISPLAY=:1 DEGIMON_BOOT_MAP=mayo00 DEGIMON_INTRO_ENTRY=101 DEGIMON_AUTOBOOT=1 \
  DEGIMON_START_HOUR=12 DEGIMON_AUTOBOOT_SEC=60 \
  "$EXE" -logFile ~/degimon_day.log

# ★夜★
DISPLAY=:1 DEGIMON_BOOT_MAP=mayo00 DEGIMON_INTRO_ENTRY=101 DEGIMON_AUTOBOOT=1 \
  DEGIMON_START_HOUR=22 DEGIMON_AUTOBOOT_SEC=60 \
  "$EXE" -logFile ~/degimon_night.log
```

★★★`DEGIMON_AUTOBOOT_SEC` を 足しました（★2026-08-20 の 実測で 判ったこと★）★★★
```
  ★`DEGIMON_AUTOBOOT=1` だけだと ★3 秒で 窓が 自分から 閉じます★★
    実測 = log に  [LIVEBOOT] field reached via real boot path; ran 3.0s — … Quitting.
  ⇒ ★見ていただく 用途では 短すぎる★ ので ★`DEGIMON_AUTOBOOT_SEC=60` を 付けています★
  ★申告★: ★`=30` を 付けた 私の run は 77 秒 経っても 終了行を 出しませんでした★
          ⇒ ★★秒数どおりに 終わるか どうかは 確かめられていません★★（★理由も 判っていません★）
          ⇒ ★∴ 見終わったら ★窓を 閉じるか Ctrl-C で 止めてください★（★放置すると 残ります★）
```

★log の 見かた★（★既定で 出ます★ = ★#581-C で 既定 ON に しました★）:
```
[PLACE-SPECIES] map=mayo00 idx=109 rec=2 print_i=0 type=3 script_id=6 ps1=(-226,1688)
[PLACE-SPECIES] map=mayo00 ★合計 1 体★(…)
```
- ★`rec=`★ = ★原盤の 枠（slot）番号★ / ★`type=`★ = ★species★
- ★印字を 止めたい とき★ = `DEGIMON_PLACE_SPECIES=0`

★★この build で 見ていただくのは ★新規開始の `mayo00`★ です★★
　（★進行後の 絵は ★物語を 進めた 先★ に 在ります・★近道の 口は 入れていません★★）

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

## 6. ★お願い★
- ★★user に お渡しするか どうか★★ = ★★PRESIDENT の 判断★★（★worker3 も boss1 も user を 呼びません★）

## 7. ★★私（worker3）が 確かめた 範囲（★2026-08-20 に 撃ち直し★）★★

★★(1) log の 検収 = 5 本（★全部 この build で 撃ち直しました★）★★

| # | 撃ったもの | 結果 |
|---|---|---|
| S1 | `DEGIMON_PLACE_SPECIES` 未設定 | ★印字 あり・`合計 1 体`・`rec=2 type=3`★ |
| S2 | `DEGIMON_PLACE_SPECIES=0` | ★`[PLACE-SPECIES]` = 0 行★ ／ ★`[PLACE]` 3 行は S1 と 逐字同一★ |
| S3 | `DEGIMON_START_HOUR` = 3 / 12 / 22 | ★3 点とも 逐字同一★（＝ ★序盤は 入れ替わらない★） |
| S4 | `DEGIMON_PLACE_SPECIES=1`（明示） | ★S1 と 逐字同一★ |
| S5 | `W3_MEASURE_FLAGS=203` | ★`[W3-MEASURE-FLAG]` = 0 行★ ／ ★`[PLACE]` `[PLACE-SPECIES]` 全行 S1 と 逐字同一★ |

★log 全文の 差分の 在り処★（★sha256 は run ごとに 違います・その 中身★）:
```
  S1 vs S4 / S1 vs S5 の 全文 diff = ★2 行だけ★
    1 行目  Processor: … 8 core(s) @ 3948 MHz  ⇔  @ 3924 MHz / @ 3839 MHz   ← ★CPU の 実測 clock★
    29 行目 UnloadTime: 0.362748 ms            ⇔  0.376880 / 0.377731 ms     ← ★所要時間★
  ⇒ ★★game の 挙動を 書いた 行は 1 つも 違いません★★
```

★★(2) 実 GUI = 1 回 起動しました★★
```
  起動前 の 台数 = ★0★ ／ 起動中 = ★1★（pid 57829）／ 停止後 = ★0★
  ★台数の 数え方★ = ★`/proc/<pid>/exe` の 実体一致★
    ∵ ★`pgrep -f` は ★自分自身に 当たります★★ ／ ★`comm` は `Unity Main Thre` に 化けます★
      （★`DegimonLive` で `comm` を 探すと ★0 台と 出て 見逃します★ = ★私は 一度 これで 外しました★）
  窓 = ★出ました★ ／ ★窓 id = `0x00e00008`（`unity`・1920x1080）★
  ★器の 限定★ = ★`import -window root` は BadMatch で 撮れません★ ⇒ ★窓 id 指定で 撮りました★（★画面全体では ありません★）
  絵 = ★workspace/degimon-faithful178/w3_582cr_gui3_engine.png（556,190 byte・engine 側の ScreenCapture・doc と 一緒に commit）★
       ／ /home/ken/Desktop/Digimon/w3_build582r/w3_582cr_gui3_window.png（2,155,821 byte・窓 id 指定の X 撮影）
  log = [PLACE-SPECIES] map=mayo00 idx=109 rec=2 print_i=0 type=3 script_id=6 ／ ★合計 1 体★
```
- ★★これは ★絵の 忠実さの 検証では ありません★★★ = ★★「起動して 何も 出ない」を 潰す ためだけ★★
- ★画面には 描画体が 在り ★黒画面では ありません★★ ⇒ ★★それが 何かの 同定は しません★★（★同定は 我々が 一度 誤りました★）

★★(3) 私が ★確かめられていないこと★★★
- ★`DEGIMON_AUTOBOOT_SEC` の 秒数どおりに 終わるか★（§3 の 申告）
- ★build log の summary が `errors=3` と 出ている ★その 3 件の 中身★★
　（★`error CS` は 0 件★・log 中の `Error` 表記は ★Licensing の 1 行だけ★ ／ ★残りが 何かは 判っていません★・★build は `Succeeded`★）
