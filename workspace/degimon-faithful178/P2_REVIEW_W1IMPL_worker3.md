# ★worker1 実装 `0e164135` の 査読★（boss1 #442-C / worker3）

★★5 点様式★★ = ★対象★ `~/Desktop/Digimon/degimon_world_remake-p2w1` / branch `track1/vm-spec-impl` / ★sha `0e164135`★（★行番号は この sha の `git show` 出力★）
★私の 側★ = `~/Desktop/Digimon/degimon_world_remake-p2w3` / `track3/p2-script-walk` / sha `f972bc71`
★算法★ = ★source 直読（`git show <sha>:<path>`）＋ 呼び元の 全数 grep★ / ★彼の harness は 再実行して いません（意味が 無い ため）★ / ★★実装して いません★★
★★LGTM は 書きません★★ = ★1 項目ずつ 根拠★

---

## 1. ★★★① 本体 = ★tile 110-119 に 待ちが 付いたか★★★★ ⇒ ★★付いて いません★★

```
★★∴ 経路は ★別の class で 分かれます★★（★逐語★）:
　★auto-warp（tile 110-119）★ = `FieldManager.DetectWarpTrigger` → ★`FieldManager._warpPending` ＋ `_pendingFrame`★
　　→ `FieldManager.Update` の `if (_warpPending && Time.frameCount > _pendingFrame)` → `WarpRequested?.Invoke` → `GameManager.HandleWarp`
　　⇒ ★★この 経路は `DialogueRuntime` を ★1 度も 通りません★★★
　★w1 の 段 2★ = `DialogueRuntime.Tick()` の 冒頭 `PumpWarpPending()`（sha `0e164135` の diff）
　　→ 走るのは ★`_warpPendingTag == 0x4B` の ときだけ★ / その tag を 立てるのは ★`QueueWarpPending` の 1 経路だけ★
　　→ その 唯一の 呼び元 = ★0x4B arm の `else if (_warpEmit && !_mapChangeEmitted)` の 中★（同 sha `:1124`）
⇒ ★★★∴ ★auto-warp に 20 の 待ちは 付きません★★★ = ★★回帰 なし★★
★★⚠ 但し ★合成の 枠★ を 1 件★★ = ★0x4B の 側は ★20（VM tick）＋ 1（FieldManager の 次 frame flush）★ に なります★
　（`GameManager.OnScriptWarp` → `FieldPresenter.QueueWarp(...)` → ★FieldManager の 1 frame queue★ を ★必ず 通る★）
　⇒ ★★∴ 質問 = ★原盤の 20 は ★この +1 を 含む 数★ ですか★★（★含むなら 19 が 正・含まないなら 20 で 正★）= ★★私には 決められません★★
```

## 2. ★★★② ★同じ opcode が 2 つの 形で 動きます（★最大の 指摘★）★★★★

```
★`0x4B` に 関わる emit site を ★全数 数えました★（sha `0e164135` の `git show` 出力・`OnMapChangeRequested?.Invoke` を grep）:
　★:1081★ = `0x4B` FIELD map-warp（`FaithfulScenarioZero` path）= ★★即時の まま★★
　★:1108★ = `0x4B` faithful（cutscene path）= ★★即時の まま★★
　★:1124★ = `0x4B` 非 cutscene（selector path）= ★★pending 化 済（今回の 変更）★★
　★:1718★ = `ConfirmMenuSelection`（menu 確定 = 0x4B の dest 表から）= ★★即時の まま★★
⇒ ★★∴ ★4 箇所 中 ★1 箇所★ だけが 2 段★★ = ★★∴ ★同じ `0x4B` が ★経路によって 20 待つ／待たない★★★
⇒ ★★∴ 指摘★★ = ★『0x4B を pending 形に した』と ★commit message に 書くと 枠が 広すぎます★★（★実際は ★1 経路★★）
　★★∴ 私の 提案（★実装しません★）★★ = ★① 残り 3 経路も 同じ 形に する★ ★or★ ★② comment と commit に ★どの 経路か★ を 明記★
　★★∴ 今夜の live で 動いた 経路★★ = ★`WARP_DEST(0x4B menu-idx)` = ★:1124 = ★変換された 側★★★ ⇒ ★★∴ ★次の live で 20 待ちが 出ます★★
```

## 3. ★★★③ ★pending の 寿命の 枠が 違います★★★★

```
★原盤★ = `[gp-0x6cbb]` = ★★global な cell★★（★VM の 呼び出しを 跨いで 残る★・だから 次の 呼び出しの 冒頭で 拾える★）
★w1 の 実装★ = ★`DialogueRuntime` の ★instance field★★（`_warpPendingTag` 他）
★★∴ 差が 出る 条件★★ = ★`TextboxView.StartSection` は ★毎回 `new DialogueRuntime()`★ を 作り ★成功時に `_rt = rt` で 差し替え★ます（p2w1 同 sha）
　⇒ ★★∴ ★pending が 立って いる 間に 別の section が 始まると ★その pending は 消えます★★★（★原盤は 消えません★）
　⇒ ★★∴ ★= 『移動が 落ちる』★（★遅れる では なく ★起きない★★）
★★∴ 但し ★今 それが 起きるか は 私には 言えません★★ = ★20 tick の 間に 別 section が 始まる 経路が 在るか を ★測って いません★★
　⇒ ★★∴ ★指摘は『枠が 違う』まで★★ / ★★『bug が 出る』とは 書きません★★
```

## 4. ★★∴ ④ 独立に 当てた もの★★

```
★(a) 『20』の 単位が ★差し替えられる 形か★★ = ★★充足★★
　★`WARP_FADE_ARG` / `WARP_WAIT_THRESHOLD` / `WARP_MID_STAGE` の ★3 本が 別々に 名前つきで 1 箇所★★（同 sha `:436-438` 付近）
　★★∴ 同じ 値 20 を ★1 つに まとめて いない★ のが 正しい★★（★値の 正しさは 未決 = w2 の scheduler 待ち★）
　★★∴ 単位の 前提★★ = ★『Tick() 1 回 = 1 frame』★ は ★`TextboxView.Update` が `_rt != null` の とき ★無条件に 1 回 `_rt.Tick()` を 呼ぶ★★ ことに 依存
　　⇒ ★同 sha `:225` を 直読して ★成立★ を 確認しました★（★State に 依らず 呼ばれます★）
★(b) ★入口を 増やして いないか★★ = ★★充足★★ = ★diff は ★2 file のみ★（`DialogueRuntime.cs` ＋ 新 `W1WarpPendingVerify.cs`）★
　⇒ ★`0x58` / `0x66` の arm に ★1 行も 触れて いません★★（`git show --stat` ＋ 本文 grep）
★(c) ★gate-OFF 不変★★ = ★★構造的にのみ 確認★★（★★runtime では 確認して いません★★）
　★構造★ = ★`QueueWarpPending` の 呼び元は ★1 箇所★ で ★`_warpEmit` 分岐の 内側★★ ⇒ ★OFF なら tag は 立たず `PumpWarpPending` は 1 行目で return★
　★★∴ 正直に★★ = ★★彼の tree で Unity を 起動して いません★★（★project lock ＋ 他 worker の Library を 触る ため★）
　　⇒ ★★∴ ★『独立な runtime 確認』は ★未実施★★★ = ★指示が 在れば 走らせます★
```

## 5. ★★∴ ③ 条件 7（境界 12/12 不変）★★

```
★★⚠ ★彼の tree では ★測定できません★★★ = ★`p2w1` に ★`W3TileBandTest.cs` が 存在しません★★ /
　★`MapData.cs` に `IsImmediateScriptTile` が ★0 件★★（= ★私の #714 は track3 にしか 在りません★・共通祖先 `c3a3c20a`）
★★∴ 代わりに 2 つ 出します★★:
　★① ★私の tree で 再実測★★ = ★`W3TileBandTest` = ★PASS（判定 12 = 個別 11 ＋ 総括 1）★★（sha `f972bc71`・env 未設定）
　★② ★彼の diff が 境界に 触れて いない ことの 構造的 確認★★ = ★変更 file は ★2 本だけ★ で ★`MapData.cs` は 含まれません★★
⇒ ★★∴ ★『彼の 実装が 境界を 壊して いない』は ★構造で 言えます★★★ / ★★∴ ★『彼の tree で 12/12 が 通る』は ★言えません（test が 無い）★★★
```

## 6. ★★∴ まとめ（★指摘 4 件・うち 要対応 2 件★）★★

```
★要対応★ ① ★4 経路 中 1 経路だけが 2 段★ ⇒ ★commit / comment の 枠を 直すか 残りも 揃える★
★要対応★ ② ★pending の 寿命が instance★（原盤は global）⇒ ★section 差し替えで 落ちる 形★
★質問★　 ③ ★20 は FieldManager の +1 を 含むか★
★申告★　 ④ ★gate-OFF の 独立 runtime 確認は ★未実施★★ / ★条件 7 は ★彼の tree では 測定不能★★
★★∴ 値は 1 つも 疑って いません★★ = ★本日の 5 例と 同じく ★割れるのは 接合部★ ゆえ ★枠だけ 見ました★
```

---

# ★★★追記（boss1 #442-C 差し替え・査読の 本体を ★実測★ へ）★★★

★測定時点 = 2026-08-16 00:5x（`date` 実測）★

## 7. ★★★∴ 結論 = ★★撮れませんでした★★★★★（★『読んだ 限り 載って いない』で 代替しません★）

```
★★止まった 場所を 名指しします★★:
　★(B) 0x4B が tick 21 で fire★ = ★★撮れます★★ = ★彼の harness と 同じ 形で ★`new DialogueRuntime()` ＋ `for (t=1..N) rt.Tick()`★ で 足ります★
　　⇒ ★但し ★彼の code は p2w1 にしか 在りません★★ ⇒ ★★∴ ★p2w1 で Unity を 起動する 許可が 要ります★★（★私は まだ 起動して いません★）
　★★(A) auto-warp（tile 110-119）が 次 tick で fire★★ = ★★撮れません★★
　　★理由（逐語）★ = `FieldManager.cs:23` = ★`[RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]`★
　　　⇒ ★★この 属性は ★play mode / player build でしか 走りません★★★（★Editor の `-executeMethod` batchmode では ★Bootstrap が 呼ばれず FieldManager が 生成されません★★）
　　⇒ ★かつ 判定の 本体 = ★`Update()` の `if (_warpPending && Time.frameCount > _pendingFrame)`★ = ★★player loop が 要る★★
　　⇒ ★★∴ ★reflection で 私が 手で 呼ぶのは ★『読解』を 手続きに 変えただけ★★★ = ★★やりません★★
★★∴ ∴ ★『同じ 1 run で (A) と (B)』は ★player build（または play mode）が 要ります★★★
　⇒ ★★∴ ★私は build しない 規律の 下に 在ります★★ ＋ ★★対象は 他 worker の worktree★★ ⇒ ★★∴ ★私の 手では 撮れません★★
```

## 8. ★★∴ 撮る ための 手順（★build 権限を 持つ 側へ★・★私が 書けるのは ここまで★）★★

```
★対象★ = ★p2w1 / `track1/vm-spec-impl` / sha `0e164135`★（★私の tree では 彼の 実装が 入って いません★）
★env★ = ★`DEGIMON_WARP_EMIT=1`★（(B) に 必須）＋ ★`DEGIMON_BOOT_MAP=<110-119 tile を 踏める 地図>`★
　★※ 既定値には 触らない★（gate 3 つ 現状維持・env は ★test-scoped の 一時 ON★）
★踏む もの★ = ★(A) tile 110-119 の マス★ / ★(B) 0x4B を 通る section★
★受理（肯定）★ = ★(A) の `[WARP] queued …` の ★次 frame★ に `[WARP] fire …` が 出る★ ／ ★(B) の `[WARP_PENDING] tag=0x4B …` の ★21 tick 目★ に `[WARP_PENDING] fire …` が 出る★
★★受理（否定・これが 本体）★★ = ★★(A) の fire が ★tick 21 では ない★★★ / ★★(A) の log に `[WARP_PENDING]` が ★1 行も 出ない★★★
★★∴ 併せて 撮れる もの★★ = ★(A) は `DEGIMON_WARP_EMIT` に 依らない★ ⇒ ★★env なしの run でも (A) だけは 出る★★（= ★経路が 別だ という 実測★）
```

## 9. ★★∴ 他の 査読項目の 現況（★⑤ そのまま★）★★

```
★条件 7（境界 12/12）★ = ★★私の tree で 実測 PASS★★（sha `f972bc71` / 判定 12 = 個別 11 ＋ 総括 1 / env 未設定）
　★★但し 彼の tree では ★測定不能★★★（`W3TileBandTest.cs` 不在 / `IsImmediateScriptTile` 0 件）= ★★§5 の とおり★★
★gate-OFF 不変（独立の 器で）★ = ★★未実施★★ = ★彼の tree で Unity を 起動して いない ため★（★構造的 確認は §4(c)★）
★定数が 1 箇所・名前つき・差し替え可★ = ★★充足★★（§4(a)）
★入口（0x58 / 0x66）に 手が 入って いないか★ = ★★充足★★（§4(b)・diff は 2 file のみ）
★★∴ ∴ ★私が 出した 指摘 4 件（§6）は ★実測が 撮れても 撮れなくても 立ちます★★★（★どれも 経路の 数と 場所の 話★）
```
