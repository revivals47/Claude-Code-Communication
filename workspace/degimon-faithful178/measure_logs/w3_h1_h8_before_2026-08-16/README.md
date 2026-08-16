# h-1 + h-8 の ★before★ 実測 7 本（worker3 / #437-C）2026-08-16

★これは before です★。★after は 修正 land 後に 同じ patch を当てた実物で撮ります★。

## 1. ★何を build して 何を測ったか（4 点 pinning・★hash は 関数名つき★）★

★裸の「sha」と書きません★ — ★`sha256` と `git-blob`(sha1) は 別の目盛りで、両方 正しい数★。

| 項 | 値 |
|---|---|
| ★① build 元 HEAD★ | integ `901efaad`（worktree `degimon_world_remake-integ` / branch `track/measure-fade-tile`） |
| 参考 | p2w1 `5f1e327e`（`track1/vm-spec-impl`）/ p2w3 `932c9ac1`（`track3/p2-script-walk`） |
| ★観測器 commit★ | integ ★`76b5159f`★（★after は「同じ HEAD」でなく ★この commit の実物★ で撮る★） |
| Unity | `6000.4.11f1` / player build / `DISPLAY=:1`（★batchmode Editor ではない★） |
| 出力先 | `workspace/build_m437c/`（★`workspace/build/` は 不可触・下記 §7★） |

★② 測定対象 file の HEAD 版★

| file | sha256 | git-blob |
|---|---|---|
| `Dialogue/DialogueRuntime.cs` | `878b00c10b578118c42e3c50d3ef89cfe448a13044db635678809337de0fa4a4` | `700c445a3df051328596d8abee60b3812ff97b35` |
| `Field/FieldManager.cs` | `9046d5de51c454daee4084bc95eec52e3a6262bfaac681a2017f84bead62b4d2` | `6667a6093296a5bd7ee708bcf8086f392e859038` |

★③ ★build した実物★（= HEAD ＋ 測定用の印字。★これが「何を測ったか」の唯一の数★）★

| file | sha256 | git-blob |
|---|---|---|
| `Dialogue/DialogueRuntime.cs` | `ef374c654009f4bba4e5f6e5d9e316a5b200361e4befae9100bd8f5b3ecefc33` | `2c8ab3483d012214d2a6a1cef34e1b9d5c2e512d` |
| `Field/FieldManager.cs` | `f9ad9517414d6ce0a655fdfd04b648ab16dbb162f3f4694378b2985752453004` | `ddc105acc96ba22553d15745f298ac325b4e434d` |
| `Editor/W3MeasureBuild437C.cs` | `a1231101ef3621604c259c2dcb9a094598c4da752f31322a472542237af7468c` | `5941a117a2a4d0b90852f79d1a1e7bf268b5fed0` |

★④ 測定用 patch★ = `degimon_world_remake-integ/workspace/m437c/measure_patch_437c.diff`（110 行）
`sha256:a0971ff068690f01d29c6543e5a6aace50e6d64d7bc7098d857fd65432e2a907`
⇒ ★after で 同じ印字を 再現するために 要ります★。★git に在る（76b5159f）ので 再現は git が保証します★。

★1 行★: ★p2w3 の `DialogueRuntime.cs` は 別 blob（`git-blob:7b6760e98e9a61852fccde9e78d3cb006816eb34`）で ★測定対象外★★
（build 元は integ ゆえ）。★3 点目が違うことは 異常では ありません★。

★交絡★: ★p2w1 の HEAD は 57f57a8e → 5f1e327e に 動きましたが、`DialogueRuntime.cs` の
git-blob は `700c445a` のまま = integ HEAD と 同一★ ／ ★p2w1 の .cs WIP = 0 件★
⇒ ★測定対象は 無傷★。★HEAD が動いたことは 測定の無効を 意味しません★（HEAD は doc/器 でも動く別の軸）。

## 2. ★観測器が 対象を 変えていないことの 検算★

patch の追加行から comment と `Debug.Log` を除いた ★残り 全数★ を列挙した結果、
★観測専用 field（`s_instSeq` / `s_pendSeq` / `s_openPendingInst` / `s_openPendId` / `s_h8Reported` /
`_instId` / `_pendId` / `Ident()` / `RtGs` / `InstId`）と、それらへの 代入と、log を出すだけの `if` 1 個★ のみ。
★`_warpPendingTag` / `_warpPendCounter` / `_warpPendMap` / 制御フロー への 書き込みは 0 件★
（`_warpPendCounter + 1` は ★読みのみ★）。★boss1 が独立に 23 行を数えて 追認済★。

## 3. ★撮った 7 本★

env は全て `DEGIMON_AUTOBOOT=1`。★gate 既定値は 変えていません★（env による一時 ON のみ）。

| # | log | env（既定からの差分） | 結果 |
|---|---|---|---|
| 01 | `01_ctl_tile110.log` | ★なし（対照）★ + BOOT_MAP=mayo00 / INTRO_ENTRY=101 / POSTCUT_WALK=1 / WALK_DIR=0,1 | `queued frame=5 → fire frame=6` ★Δ(frame)=1★ / WARP_PENDING ★0★ / TILE5179 ★0★ / MAPLOADER ★0★ |
| 02 | `02_A_tile110_gates_on.log` | 上記 + ★TILE_5179=1 + WARP_EMIT=1★ | ★同一★（frame 5→6 / Δ=1）/ WARP_PENDING ★0★ / H8 ★0★ / TILE5179 3 / MAPLOADER 4 |
| 02b | `02b_Aprime_tile110_repeat.log` | ★02 と同一 env・別 run（反復対照）★ | ★02 と 完全一致★ |
| 03 | `03_B_tile51_route1.log` | 02 + WALK_DIR=1,-1 + AUTOBOOT_SEC=30 | ★下記 §4★ |
| 03b | `03b_Bprime_tile51_route1_repeat.log` | ★03 と同一 env・別 run（反復対照）★ | ★03 と 完全一致★ |
| 04 | `04_C_route2_cutscene.log` | AUTOBOOT_SEC=150 + DIALOGUE_AUTOADVANCE=1（★gate 既定★） | ★★撮れず★★ §5 |
| 05 | `05_C2_route2_cutscene_neverstop.log` | 上記 + ★`W1_GATE_NEVERSTOP=1`★ | ★★撮れず（未完）★★ §5 |

log の sha256:
```
678fd850836f5fe67f491be991df1a2a7d1d3ad8a8da67ddf24088f712dd232f  01_ctl_tile110.log
394b70dacc53c4650cd1b68257f7c13d20093eb10bafcd14055b945adccc1a4c  02_A_tile110_gates_on.log
160e4fb3ee5d7ab249b13960a542aa672ac4ee183e0f57d9f95a1ec47b957b90  02b_Aprime_tile110_repeat.log
dc878fe8ced6d037624a7b6d26e9cf6009f1329a0464fdc86e0529a3b77487c9  03_B_tile51_route1.log
10d6f6af48ee0d49847d97cefd92e5f8d3faa823a6be055b0dd76c2dffd3d236  03b_Bprime_tile51_route1_repeat.log
94780b08eb4b25f62d35d18445d0138ce06a45b209b143fd0aecf8aa5ba77a7f  04_C_route2_cutscene.log
a6f30dfc5937fad9fba83608c821c60bb650a0c962a44c57045a001115989b83  05_C2_route2_cutscene_neverstop.log
```

## 4. ★h-1 と h-8 の 実測（★経路は 番号でなく log の文面で 呼びます★）★

### (A) 自動 warp（tile 110-119）= ★受理条件の 肯定が ★初めて 測定されました★★

```
[WARP] queued frame(Time.frameCount)=5 trigger=110 exitId=0 -> map=112 spawn=0
[WARP] fire   frame(Time.frameCount)=6 queued(_pendingFrame)=5 ★Δ(frame)=1★ src=Auto -> map=112
```
⇒ ★「queued の 次 frame に fire」= ★満たす★★。
★★なぜ 撮り直したか★★ = ★既存 3 本（A_run / B_run / ctl_run）は ★frame 番号を 1 行も 持たない★★
（`grep frame=` が 3 本とも ★0 件★）⇒ ★「直後に fire」は ★log 行の 隣接からの 推論★ で、★測定では ありませんでした★★。
★順序は 測度では ない★ ⇒ ★同一 counter(`Time.frameCount`)の 2 読み値の 差★ を 出しました。

★否定側★ = 02 の `[WARP_PENDING]` ★0 件★ / `[H8]` ★0 件★（01 対照も 0 件）。
★対照★ = 01（gate 既定・env なし）でも ★(A) は 出る★ ⇒ ★(A) は `WARP_EMIT` に 依らない★。

### (B) `WARP_DEST(0x4B menu-idx)` = ★queue する 経路★

```
[DIALOGUE][SCRIPT] WARP_DEST(0x4B menu-idx) destIdx=0(sel=0) @pc=0x5B8 map=180 spawn=0 returnKey=0xFF
[H8] queue pend-id=1 rt#3/… gs#… root=NpcSection dest=180 counter(_warpPendCounter)=0 frame=14
[H8] pump  … counter=1/20  ＝ tick 序数 2  frame=15
   …（★1 tick / 1 frame で 連続★ frame 15..34）…
[H8] pump  … counter=20/20 ＝ tick 序数 21 frame=34
[WARP_PENDING] fire dest=180 counter=20
[H8] ★到達★ … counter=20 == 閾値 20 ＝ tick 序数 21 frame=34
[SCRIPTWARP] fire frame=35 queued(_pendingFrame)=34 Δ(frame)=1 src=Script -> map=180
```

★★±1 は 食い違いでは なく 単位です★★:
★`_warpPendCounter` は queue tick で 0、`PumpWarpPending` が ★fire 判定の 前に ++★★
⇒ ★読み値 N ＝ tick 序数 N+1（queue tick を 1 と 数える）★
⇒ ★「counter=20」と「21 tick 目」は ★同一事象の 別目盛り★★。★どちらも 正しい★。

★h-8 の判定★ = ★★出ませんでした★★（`[H8] ★★落ちた★★` が ★0 件★ / `rt#3` が queue から 到達まで ★不変★）。
⇒ ★worker1 の反証子 ★F3（fire は出るが rt# が最後まで同一）★ は ★この経路で 成立★★。
★私は 彼の予想を 読んだ上で 撮っています★ ⇒ ★合わせていません。出たものを 出しました★。

### ★b-2（駆動の寿命）★ = ★この経路では 出ませんでした★

`03_B` の行順（実測）= ★`[DIALOGUE] scenario finished`(:137) / `dialogue finished`(:138) の ★後★ に
`[H8] pump counter=1`(:140) から 20 まで 回っています★。
⇒ ★dialogue が 終わっても Tick は 続き、pump は 回りました★
（`TextboxView` の `if (_rt == null) return;` は 通っていない = ★`_rt` が null に ならない★）。
⇒ ★∴ b-2 の 破綻形は before では ★観測されません★★。★構造として在ることは 否定していません★。

## 5. ★★撮れなかったもの = 止まった場所を 名指しします（0 を埋めません）★★

### `WARP_DEST(0x4B faithful)`（= ★`Root == RootInvoke.SceneCutscene` の `QueueWarpPending`★）

★★判定不能★★ = ★到達していません★。「落ちなかった」とは ★言えません★。

- ★04（gate 既定）★: SceneCutscene には ★入りました★ —
  `[DIALOGUE] PlaySection entry=178 section=254 ★root=SceneCutscene★ → pc=0x10 contentEnd=0x1316`
  ★止まった場所★ = `[VM-GATE] UNSUPPORTED ★op=0x6C★ len=8 entry=178 ★pc=0x1A★ prevOp=0xFE ⇒ ★停止(初回)★`
  ⇒ ★0x4B は @0x7c8 = はるか先★。`WARP_DEST` ★0 件★ / `[H8]` ★0 件★。
- ★05（`W1_GATE_NEVERSTOP=1`）★: ★★これは 挙動を 変える env です★★
  （code の comment に「gate 自身の停止で 既存 gate が FAIL するため ★回帰比較のときだけ★ 外す」）
  ⇒ 進みはしましたが ★page 9 / pc=0x1B8 で run が 外部から 落ちました★
  （★crash signature なし・shutdown 行 0 件★ = ★私の run の 打ち切り★。★player の異常では ありません★）
  ⇒ ★到達率 ≈ 3 fps で、pc=0x7c8 到達には field 時間 350-400s 相当が要ります★。
- ★★∴ 私の判断★★ = ★`NEVERSTOP` 下で 届いても、それは ★production の gate 下で 届くこと★ を 意味しません★
  ⇒ ★before/after の 対としては 弱い★ ⇒ ★★「撮れない」で 確定させ、理由を ここに 焼きます★★。
  ★札 = 材料★（op=0x6C の実装、または ★到達性を 変えない 撮り方★ が 要る）。

### ★`faithful` という語は ★2 site に 現れます★（★規約への 追補★）★

★log 文面で呼ぶ規約は 正しいですが、★`faithful` 単独では 一意に なりません★★。
器から全数列挙した ★0x4B を名乗る log 行 = 5 本★ と、`QueueWarpPending` の ★call site = 2 箇所★（:1167 / :1183）:

| log 文面（★行 prefix まで 含めた 全体★） | queue するか | 本便で 出たか |
|---|---|---|
| `[DIALOGUE][SCRIPT] WARP_DEST(0x4B menu-idx)` :1176→:1183 | ★する★ | ★03 / 03b で 各 1 回★ |
| `[DIALOGUE][SCRIPT] WARP_DEST(0x4B faithful)` :1160→:1167 | ★する★（= SceneCutscene） | ★0 件（到達せず）★ |
| `[STEP3-TRACE] 0x4B faithful warp → scenario-0 §N` :1148 | ★しない★（`PendingScenarioLoad` を立てて Finished） | ★0 件★ |
| `[STEP3-TRACE] 0x4B FIELD map-warp emit` :1123 | ★しない★（即時 invoke） | ★0 件★ |
| `[STEP3-TRACE] 0x4B push kind=4` :1117 | ★しない★（return-stack push） | ★0 件★ |

⇒ ★★∴ boss1 の表の「faithful（未測定）」と「SceneCutscene QueueWarpPending（判定不能）」は
   ★`WARP_DEST(0x4B faithful)` を指すなら 同じ 1 site★ です★★
   （★`[STEP3-TRACE] 0x4B faithful warp` を指すなら ★別 site で、queue しない ⇒ h-8 該当せず★）。
⇒ ★∴ 呼ぶときは ★`[TAG] を含む 行 prefix まで★ 添えてください★。★語だけでは 衝突が 残ります★。

## 6. ★反復対照（同一条件を 変えなければ 変わらないか）★

★B と B'（同一 build / 同一 env / 別 run）★:
★queue frame=14 / counter=20 / tick 序数=21 / fire frame=34 / pend-id=1 / rt#3 が ★全部 一致★★
★A と A'★: ★frame 5→6 / Δ(frame)=1 が 一致★
⇒ ★∴ これらは ★機構の数★ であって ★タイミングの数★ では ありません★ ⇒ ★after と 比較できます★。

★★但し 1 つ 一致しません（申告）★★:
★object-identity hash★ は run ごとに 変わります（`rt#3/DEEF3D5A`→`E056795A` / `gs#20A41C38`→`875D9A38`）。
`RuntimeHelpers.GetHashCode` は ★process 内でのみ 意味を持つ★。
⇒ ★★after で hash の 値そのものを 突き合わせないでください★★。
　★比べてよいのは ★同一 run 内での 同一性（変わったか / 変わらなかったか）★ と ★rt# の 通し番号★ だけ★。

## 7. ★`workspace/build/` 不可触の 検算★

★build 前後で 939 file の ★sha の sha★ = `2ee4f9e5e0f91a87b55178c6ea37e54344c5d202df35fa0a4d0b55cdba4e3d85` ★一致★★。
加えて ★器の側で 守れないようにしました★ = `W3MeasureBuild437C` は
★出力先が `workspace/build/` 配下なら `EditorApplication.Exit(2)` で 中止★。

## 8. ★この 7 本が 見ていない場所（母数の申告）★

1. ★`s_h8Reported` の cap★ = ★run に 1 回では なく ★pending 1 episode に つき 1 回★★（pending が開くたび再武装）。
   ⇒ ★∴ この log が 答えられるのは 「その pending の間に ★少なくとも 1 回★ 差し替わったか」★。
   ★「何回」は 答えられません★。★回数を 書きません★（★cap 飽和下で 数を 語らない★）。
2. ★地図は `mayo00` 1 本だけ★。他 241 地図では 撮っていません。
3. ★`WARP_DEST(0x4B faithful)` / `[STEP3-TRACE]` の 3 site は ★1 度も 実行されていません★★（§5 の表）。
4. ★user の 実視覚は 経ていません★ ⇒ ★完成 claim は していません★。
5. ★05 は 私が run を 打ち切った★ もので、★player が 落ちたのでは ありません★（shutdown 行 0 件が その印）。
