# ★引き渡し build★（worker3 / #444-C）2026-08-16

★★これは「③ 完了」の宣言では ありません★★ / ★user の 実視覚は まだ 経ていません★ ⇒ ★完成 claim は していません★。

## 0. ★数える前に 枠を 書く★

| 語 | 定義 |
|---|---|
| ★4 数★ | 1 つの log 中の ★行頭 tag `[H8]` / `[TILE5179]` / `[MAPLOADER]` / `[BINDING]` の 行数★ |
| ★TWNB01 到達★ | 同 log 中の `MapLoader] loaded 'TWNB01'` の 行数 |
| ★counter★ | `gs.WarpPendCounter` = ★0 起点★・★fire 判定の 前に ++★ ⇒ ★読み値 N ＝ tick 序数 N+1★ |
| ★比べてよい数★ | ★Δ（差分）と 序数★ のみ |
| ★比べてはいけない数★ | ★絶対 frame★ と ★object-identity hash★（★どちらも「機構の数に 見える タイミングの数」★） |
| ★build を 数える単位★ | ★dll★（★worktree 名では ない★ = 1 worktree に 2 build が 在り得る） |

## 1. ★渡す build★

| 項 | 値 |
|---|---|
| path | `degimon_world_remake-integ/workspace/★build_handoff_444c★/DegimonLive/DegimonLive.x86_64` |
| ★`workspace/build/` では ない★ | ★不可触★。器の ★`Exit(2)` 安全弁★ は そのまま |
| build 元 | integ ★`f5924776`★（branch `track/measure-fade-tile`）／ ★Scripts の 未 commit 変更 = 0 件★ |
| 中身 | ★h-8 修正（worker1 8c2623b6）★ ＋ ★3 gate 既定 ON★ ＋ ★★計測 patch 込み★★ |
| ★なぜ 計測 patch 込みか★ | ★clean build では `[H8]`/`[TILE5179]`/`[MAPLOADER]` が ★必ず 0★ = ★「gate が 効いていない」に 見える★★（★印字が 無いことを 0 と 読む★）。★patch は 観測専用★（対象 field への 書き込み 0 件・boss1 が 23 行 全数分類で 追認済） |
| Unity | `6000.4.11f1` / StandaloneLinux64 / `result=Succeeded errors=0 warnings=0` |

★実物の hash★

| 対象 | sha256 |
|---|---|
| `Assembly-CSharp.dll` | `4277d706976d0cfdab3562e30b5f45723ad1899a6aef996d4ffd1643074c2d0c` |
| `DegimonLive.x86_64` | `a9a83136f9f1e9bb13e145b651e13a947bbff6d6a9281f92f0791afc397104cb` |

★source の 実物 hash（★合流後 = これが「何を 焼いたか」★）★

| file | sha256 | git-blob |
|---|---|---|
| `Dialogue/DialogueRuntime.cs` | `8bf02d2eff2547db5e9612d01a54f61067573ebe704bc68085796c0fab940f3a` | `ae1d5dd6e1c077ece458c45ec3861380e658817e` |
| `Flow/TileBand5179.cs` | `bdccd7111dcb8c698092d31d94678f21c5c0d2d0243f696446b1c8fe2cacfe35` | `2df0651fe8de703456b7d02f779f3c69696de757` |
| `Flow/MapLoaderBinding.cs` | `9a1364299af8d542bf171e66736ce4888d4533f4eb147a8bd3d678dd83b2ee27` | `a0ce4830c4d74a8c9f02abe3018f2197940a0591` |
| `Flow/FieldState.cs` | `d4d82039581098d0d8a6320ceecfb95a0905342623c8d56b603198499813537c` | `677144c2f60f36a24760a626cb2fda199ef4031b` |

★計測 patch★ = `integ/workspace/m437c/measure_patch_437c.diff`
（`sha256:a0971ff068690f01d29c6543e5a6aace50e6d64d7bc7098d857fd65432e2a907`）
＋ `after_merged_patch_441c.diff`
（`sha256:249e2de4fb2ccb996111bf8e3edfdf2bdaeb18c641169997d8e2115a68db328a`）
⇒ ★どちらも git に 在ります★（integ `76b5159f` / `09a1da27`）= ★再現は git が 保証★。

## 2. ★★② この build 自身で 撮りました（★literal が 在ることは 配線を 意味しない★ ゆえ）★★

★gate env は ゼロ★（`DEGIMON_AUTOBOOT` 等の ★boot 補助のみ★）:
`DEGIMON_AUTOBOOT=1 DEGIMON_AUTOBOOT_SEC=30 DEGIMON_BOOT_MAP=mayo00 DEGIMON_INTRO_ENTRY=101 DEGIMON_POSTCUT_WALK=1 DEGIMON_WALK_DIR=1,-1`

| run | H8 | TILE5179 | MAPLOADER | BINDING | ★TWNB01★ | counter | tick 序数 | pump | Δ(frame) |
|---|---|---|---|---|---|---|---|---|---|
| ★F1（測定 build `build_m437c`）★ | 22 | 4 | 5 | 0 | ★1★ | 20 | 21 | 20 | 1 |
| ★H1（★引き渡し build★）★ | ★22★ | ★4★ | ★5★ | ★0★ | ★1★ | ★20★ | ★21★ | ★20★ | ★1★ |

⇒ ★★全項目 一致★★。★絶対 frame は 突き合わせていません★（★F2 が 212 の 外れ値だった件★）。
log = `H1_handoff_env_unset.log`（`sha256:a20693e3193342dd5b4b62a0990c9722380d0bd0e10ac6d9ae3329eab986c602`）

★★枠の 相違を 申告します★★: boss1 の表では integ の `[H8]`=6 / `[BINDING]`=1 でした。
★私の 枠★ = ★1 log 中の 行数★（`[H8]` は pump 20 行 ＋ queue/到達 2 行 = 22）。
★`[BINDING]` は 私の run では 0★ = ★この site は field-script warp が 発火した 場合のみ 通る★（§4-1）。
⇒ ★★同じ語で 別の 数を 数えている 可能性が 在ります★★ ⇒ ★★突き合わせる前に 枠を 揃えてください★★。

## 3. ★★③ 引き渡し前 check（器）= exit 0★★

`integ/workspace/tools/w3_handoff_gate_check.sh <build>`

```
★陽性対照★ 'FieldManager'        = 在り（OK）
★陰性対照★ 'DEGIMON_NOT_A_GATE'  = 無し（OK）
★在り★ DEGIMON_TILE_5179 / DEGIMON_MAP_LOADER / DEGIMON_WARP_EMIT
★OK★  ⇒ ★exit 0★
```

★★申告★★: 最初 `| head -9` を 通して `exit=141`（SIGPIPE）を 読み違えました。
★pipe せず 直接 採り直して 0★。= ★★自分で 立てた型（pipe に流さない）を 自分で 踏みました★★。

★器が 見ていない場所★ = ★literal の 有無だけ★ / ★配線は 見ない★ / ★既定値は 判定しない★ /
★`Assembly-CSharp.dll` 1 本だけ★。⇒ ★だから §2 で 実際に 撮りました★。

## 4. ★この build が 抱えている 未了（札つき）★

1. ★`[BINDING]` site は 未実行★（log の 文面の 話・★user の 観測には 影響しません★）⇒ 札 = ★材料★
2. ★b-2 = ★構造★ では 直っている★（静的 T2 PASS）
   ★b-2 = ★挙動★ では ★0 本 = 未実行★★（全 run で `driver=_rt==null枝` が 0 本）⇒ 札 = ★材料★
3. ★地図は mayo00 ほか 3 本だけ★（残り 239）⇒ 札 = ★材料★
4. ★user 実視覚 未★ ⇒ ★★完成 claim は していません★★

## 5. ★私の 誤り 3 件（本便・自分から 申告します）★

1. ★★build の 数を worktree 単位で 数えた★★ ⇒ `find | head -1` で ★1 worktree 1 本★ しか 見ず、
   ★p2w3 の 2 本目（`DegimonLive.old-2313`）を 落としていた★。
   ★dll 単位で 数え直し★ ⇒ ★★不在 5 / 7★★（= ★PRESIDENT の 元の「5 本」が 正しい★）。
   ⇒ ★★1 worktree に 2 build が 在る事実が、名で 数えると 消える★★。★以後 build は dll 単位★。
2. ★literal check の exit を pipe 越しに 読んだ★（SIGPIPE の 141 を 判定と 誤読）⇒ ★取り直して 0★。
3. ★この README を 最初 ★非 quoted heredoc★ で 書き、backtick が command substitution として 走った★
   ⇒ ★★禁止していた形を 自分で 踏みました★★ ⇒ ★hash を 先に 変数へ 採り、quoted heredoc ＋ placeholder で 書き直し★。
