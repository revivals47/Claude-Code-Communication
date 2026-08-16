# 3 gate 既定 ON の flip 検証（worker3 / #442-C）2026-08-16

★★これは「③ 完了」の宣言では ありません★★ = ★flip の 受理条件を 撃った 記録★ です。
★user の 実視覚は 経ていません★ ⇒ ★完成 claim は していません★。

## 0. ★★数える前に 枠を 書く★★（本 README の 全ての 数に 掛かります）

| 語 | ★本 README での 定義★ |
|---|---|
| ★run★ | `workspace/build_m437c/DegimonLive` を `DISPLAY=:1` で 1 回 起動したもの |
| ★tag★ | log の ★行頭★ `[NAME]` の `NAME`（★Unity boilerplate も 含む★・filter しない） |
| ★tag 集合★ | ★1 dir 内の 全 log の 和集合★（★file 単位は 参考★） |
| ★frame★ | `Time.frameCount` の 読み値（★絶対値★） |
| ★counter★ | `gs.WarpPendCounter` = ★0 起点★・★fire 判定の 前に ++★ ⇒ ★読み値 N ＝ tick 序数 N+1★ |
| ★機構の数★ | ★同一 env の 別 run で 一致した 数★ |
| ★タイミングの数★ | ★同一 env の 別 run で ずれた 数★（★after と 比べても 意味を 持たない★） |
| ★hash★ | ★`sha256` と `git-blob`(sha1) は 別の 目盛り★。★裸の「sha」と 書きません★ |

## 1. ★3 gate の 決定 site（実物で 確認）★

| gate | 決定 site（★integ の 行番号★） | 形 | 担当 |
|---|---|---|---|
| `DEGIMON_TILE_5179` | `Flow/TileBand5179.cs:25` | ★`!= "0"`★ | ★worker3（本便で flip）★ |
| `DEGIMON_MAP_LOADER` | `Flow/MapLoaderBinding.cs:34` | `!= "0"` | 着地済（変更なし） |
| `DEGIMON_WARP_EMIT` | `Dialogue/DialogueRuntime.cs:628` | ★`!_warpEmit && ... != "0"`★ | worker1（blob で 持ち込み） |

★★worker1 の 形を 守りました★★ = ★`_warpEmit` への 代入は ★条件付き `= true` の 2 site だけ★★
（`:628` env gate / `:1835` menu）／ ★`= false` は 0 件★ ／ ★`= env != "0"` の 代入形は 0 件★。
★母数★ = `_warpEmit|WarpEmit` が ★29 行★（★env 名でなく ★field★ で grep★）。

## 2. ★持ち込みと 合流後の 実物 hash★

★持ち込み★ = p2w1 `9869ccc4` の `DialogueRuntime.cs`
（★git-blob `f394e20fc33e1e3523c40996337b45fb7f4f2920` / sha256 `e849d6ee652ceb69644c772f1eecf9593d6ac8285903a6ba1f85224a48a0a01d`★
= ★私が `git rev-parse` と `sha256sum` で 独立に 検算し boss1 申告と 一致★）。

★★合流後の 実物（= これが「何を 測ったか」）★★

| file | sha256 | git-blob |
|---|---|---|
| `Dialogue/DialogueRuntime.cs` | `8bf02d2eff2547db5e9612d01a54f61067573ebe704bc68085796c0fab940f3a` | `ae1d5dd6e1c077ece458c45ec3861380e658817e` |
| `Flow/TileBand5179.cs` | `bdccd7111dcb8c698092d31d94678f21c5c0d2d0243f696446b1c8fe2cacfe35` | `2df0651fe8de703456b7d02f779f3c69696de757` |
| `Flow/FieldState.cs` | `d4d82039581098d0d8a6320ceecfb95a0905342623c8d56b603198499813537c` | `677144c2f60f36a24760a626cb2fda199ef4031b` |

★合流直後に 静的 test を 走らせました★（★Unity を 起こさず・build 前に 壊れが 判る★）
= `w1_h8_frame_tests.py --root <integ>/unity/Assets` ⇒ ★T1-T4 4/4 PASS★（★T4 = 代入形でないこと★）。

## 3. ★受理条件 ①: env を 1 つも 設定しない run が env=1 と 一致するか★

| run | gate env | TILE5179 | MAPLOADER | H8 | ★TWNB01 到達★ | counter | tick 序数 | pump |
|---|---|---|---|---|---|---|---|---|
| F1 | ★1 つも 設定しない★ | 4 | 5 | 22 | ★1★ | ★20★ | ★21★ | ★20★ |
| F1b | ★F1 の 反復★ | 4 | 5 | 22 | ★1★ | ★20★ | ★21★ | ★20★ |
| F2 | `=1` を 明示 | 4 | 5 | 22 | ★1★ | ★20★ | ★21★ | ★20★ |
| F2b | ★F2 の 反復★ | 4 | 5 | 22 | ★1★ | ★20★ | ★21★ | ★20★ |

★`Δ(frame)` は 4 本とも 1★。★∴ 照合 B（主要数値）= ★一致★★。

★★反復対照が 効きました（申告）★★:
★absolute frame は F1=211 / F1b=211 / ★F2=212★ / F2b=211★
⇒ ★★F2 だけが 外れ値★★ = ★env の 差では なく ★run 間の ±1 揺らぎ★★
⇒ ★∴ 絶対 frame は ★タイミングの数★★（★after と 比べても 意味を 持ちません★）。
⇒ ★★F2b を 撮っていなければ 「env=1 は 1 frame 遅い」と 誤報していました★★。

## 4. ★受理条件 ②: 陰性（退路）★

| run | gate env | TILE5179 | MAPLOADER | H8 | WARP_DEST | TWNB01 |
|---|---|---|---|---|---|---|
| F3 | ★全部 `=0`★ | ★0★ | ★0★ | ★0★ | ★0★ | ★0★ |

⇒ ★★`=0` で 従来の OFF 挙動へ 戻ります★★ = ★退路 在り★。

## 5. ★受理条件 ③: log 専用 site を 実効値 印字へ★

`Flow/FieldState.cs` の 2 site（`GateShow` / `GateShowUnreadable` を 新設）。
★★決定 site の static を 借りて 渡します（式を 写しません）★★。
★決定 site の static が 無い gate（`_warpEmit` = instance gate）は ★「読めない」と 書きます★（★OFF と 書きません★）。

★★実測（F4 = betl01 / `DEGIMON_FIELDSCRIPT=1`）★★:
```
[VERIFY] driving player to SCRIPT trigger tile world=(6.50, 0.00, -37.50) tile=81
  (menu path: DEGIMON_WARP_EMIT=(unset)⇒実効は★ここからは読めません★(決定=DialogueRuntime の _warpEmit(instance gate))
             DEGIMON_TILE_5179=(unset)⇒ON(既定) …)
```
⇒ ★flip 後も 「(unset)」だけを 出して 「OFF だった」と 読ませる ことは ありません★。

★★但し 2 site のうち 1 site しか 実行していません（申告）★★:
・`[VERIFY] driving player…` = ★実測済（上記）★
・`[BINDING] menu row…` = ★未実行★ = ★field-script warp が 発火した 場合にのみ 通る★。
  betl01 では ★15s 以内に 発火せず★ / mayo00・twna01 は ★81-86 帯を 持たない★。
  ⇒ ★札 = 材料★（★warp が 発火する 81-86 帯の 地図が 要る★）。★「直っている」とは 書きません★。

## 6. ★受理条件 ④: 引き渡し前 check を 器に★

`degimon_world_remake-integ/workspace/tools/★w3_handoff_gate_check.sh★`
・★`strings -e l`（UTF-16LE）★ = ★.NET の literal は #US heap に UTF-16 ⇒ ascii grep では 原理的に 当たらない★
・★陽性対照 `FieldManager`★（出なければ exit 2 = ★器が 信用できない★）
・★陰性対照 `DEGIMON_NOT_A_GATE`★（出たら exit 2 = ★器が 何でも 当てている★）
・3 gate が 揃わなければ ★exit 1 = 渡せない★

★★器の 検算（否定側も 実物で 撃ちました）★★:
| 対象 | 結果 |
|---|---|
| 測定 build（`build_m437c`） | ★exit 0 / 3 gate 在り★ |
| ★陽性対照を わざと 外す★ | ★exit 2★（= 器が 自分の 故障を 申告） |
| ★引き渡し済 build 5 worktree の 全数★ | ★下記★ |

★★引き渡し済 build の 全数走査（母数の 申告）★★
★母数★ = `*/workspace/build/**/Assembly-CSharp.dll` = ★7 本★（item22 は build 候補が 2 つ）

| worktree | 結果 |
|---|---|
| integ | ★3/3 在り（exit 0）★ |
| p2w3 | ★3/3 在り（exit 0）★ |
| ★item22（2 本とも）★ | ★★1/3（exit 1）★★ 不在 = `DEGIMON_TILE_5179` / `DEGIMON_MAP_LOADER` |
| ★p2w1★ | ★★1/3（exit 1）★★ 同上 |
| ★pbr★ | ★★1/3（exit 1）★★ 同上 |

⇒ ★★「引き渡し済 5 本が 2 gate 不在」は ★5 本ではなく 3 worktree / 4 dll★★★（★数を 訂正します★）。
⇒ ★これが 器の ★実物での 否定対照★ にも なりました★（★不在を 実際に 検出できる★）。

## 7. ★b-2（★2 行に 分けて 書きます★）★

・★b-2 = ★構造★ では 直っています★ = `TextboxView.cs:198-206` の `_rt == null` 枝で 段 2 を 回す
  （★静的 test T2 が PASS★ = pump が 早期 return の 枝の 中に 在る）。
・★b-2 = ★挙動★ では ★0 本 = 未実行★★ = 本便 6 run を 含む ★これまでの 全 run で `driver=_rt==null枝` が 0 本★。
  ⇒ ★「挙動で 直った」とは 書きません★。★札 = 材料★（★`_rt` が null になる 筋書きが 要る★）。

## 8. ★この 6 本が 見ていない場所（母数の申告）★

1. ★地図は mayo00（F1-F3）と betl01・twna01（F4）だけ★。残り 239 地図では 撮っていません。
2. ★`[BINDING]` site は 未実行★（§5）。
3. ★`s_h8Reported` の cap = pending 1 episode に 1 回★ ⇒ ★「少なくとも 1 回」しか 言えません★。
4. ★器は literal の 有無だけ★ = ★在ることは 配線されていることを 意味しません★ / ★既定値は 判定していません★。
5. ★user 実視覚 未★ ⇒ ★完成 claim は していません★。
6. ★`workspace/build/` 不可触★ = 939 file の ★sha の sha★ が `2ee4f9e5…` で ★前後一致★
   ＋ 器側に ★配下なら `Exit(2)`★。

## 9. ★本便で 私が 出した 誤りと その 訂正（★訂正版こそ 未検証★ ゆえ 検算つきで 残します）★

1. ★「before/after の log が tracked 0 本」と 測った★ ⇒ ★誤り★。
   実際は ★PRESIDENT が `d4670ed`(12:59) で 14 本 保全済★。
   ★原因★ = ★私の 測定時刻が d4670ed より 前★（道具の バグでは ない = ★同じ command を 再実行して 7/7 を 得た★）。
   ⇒ ★重複 commit を しませんでした★。
2. ★「81-86 帯を 持つ 地図 = 0」と 出した★ ⇒ ★★誤り（壊れた parser の 産物）★★。
   ★tilemap は `base64-raw-u8`★ で、私の parser は ★list を 期待して 0 件を 返していた★。
   ⇒ ★★陽性対照（mayo00 の 帯 51-79 = 56・tile 110 = 26）で 器を 検めてから★★ 走り直し ⇒ ★★95 地図★★。
   ⇒ ★教訓 = ★0 を 出したら まず 器を 疑う★（★既知の 値で 陽性対照を 撃つ★）。
