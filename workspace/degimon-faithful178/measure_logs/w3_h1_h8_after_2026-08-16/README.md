# h-1 + h-8 の ★after★ 実測 7 本（worker3 / #441-C）2026-08-16

★before★ = `../w3_h1_h8_before_2026-08-16/`（README + PREREG_after.md）
★事前登録★ = before dir の `PREREG_after.md`（★run より前に commit 済 = `b4edb42`★）

## 0. ★結論を先に★

★★`WARP_DEST(0x4B menu-idx)` 経路は before/after で ★測定値が 全項目 一致★ しました★★
= ★★これが 正しい結果です★★（★事前登録 P1-P6 のとおり★）。
∵ ★この経路は before で h-8 が ★出ていなかった★★（counter=20 到達 / rt# 不変）
⇒ ★∴ 修正で ★変わるものが 無い★★ ⇒ ★★「変わらなかった」ことを 申告します★★。
★差が出ていたら それは 修正の 副作用でした★。★出ていません★。

★★観測器が 合流で 落ちていないことを 実行時に 照合済★★（§4）= ★偽 GREEN の 入口を 塞ぎました★。

## 1. ★持ち込み方の記録（★HEAD を取ったのでは ありません★）★

★h-8 修正は p2w1 に land し integ には未反映★ ゆえ、★file を 名指しで 持ち込みました★。
★持ち込んだのは `8c2623b6`（修正 commit）が触った 3 file の diff★（`git apply --3way`）。
★`15c66826`（follow-up）は この 3 file を 触っていません★ — ★blob 一致を 実測で 確認済★。

★① 持ち込み前（= p2w1 `8c2623b6` 時点）★

| file | sha256 | git-blob |
|---|---|---|
| `Dialogue/DialogueRuntime.cs` | `6ce0b8549be0283a10441a837dce76a07552159ff33af3c98d54114291027eee` | `41e90e3540503f10a819bef39d20360aab1f7cbe` |
| `Dialogue/TextboxView.cs` | `7765051f5bce78e010b4b0134f903dae565c0e47c24469fbeb8b237fb9062089` | `96c6ca38d9b9aeaeb85014765feb8c80016b7f5a` |
| `State/GameState.cs` | `4ffbe3af31a220d0c20e1274c0e6aa3da80a1bd7b28ee1067059483ce5da92fc` | `4f5790431ae0059f8e64620b7cf3d3627ecaaa56` |

★② ★合流後の実物★（= ★これが「何を測ったか」★。★合流で 中身が 変わるので ① ≠ ②★）★

| file | sha256 | git-blob |
|---|---|---|
| `Dialogue/DialogueRuntime.cs` | `3549dee2f23957e1bec7deabde6ebf32322cc35490f2bbdae57b928459cc66f2` | `53f8844037a80ceefa3f29326465886530dcf355` |
| `Dialogue/TextboxView.cs` | `bfda054b9f6cdab7fa78cf19c026d027b2e034b4be80504afe85715e08d47d15` | `5066a8b000810d1a7e956a08784280eba78a9719` |
| `State/GameState.cs` | `4ffbe3af31a220d0c20e1274c0e6aa3da80a1bd7b28ee1067059483ce5da92fc` | `4f5790431ae0059f8e64620b7cf3d3627ecaaa56` |

★`GameState.cs` だけ ① == ②★ = ★観測 patch が この file を 触っていない★ から（★衝突しなかった★）。

★③ 土台★ = integ `901efaad` ＋ 観測器 commit ★`76b5159f`★（before と同じ）。

★★④ 衝突は 予告どおり 起きました★★ = `DialogueRuntime.cs` で ★5 hunk★。
`TextboxView.cs` / `GameState.cs` は ★clean 適用★。
解決方針 = ★★修正版を 土台に 観測印字を 再適用★★（marker を 手で 削るより 安全）。
★観測は `_warpPendCounter` → `gs.WarpPendCounter` へ ★読み替え★★（★state が GameState へ移ったため★）。

## 2. ★撮った 7 本（before と 同じ枠・同じ呼び方・同じ env・同じ順）★

| # | log | before との差 |
|---|---|---|
| 01 | `01_ctl_tile110.log` | ★なし★ `queued frame=5 → fire frame=6 / Δ(frame)=1` |
| 02 | `02_A_tile110_gates_on.log` | ★なし★ 同上 / WARP_PENDING 0 / H8 0 |
| 02b | `02b_Aprime_tile110_repeat.log` | ★なし★（★反復対照も after で 撮りました★） |
| 03 | `03_B_tile51_route1.log` | ★数は 全項目 一致・§3★ |
| 03b | `03b_Bprime_tile51_route1_repeat.log` | ★03 と 一致★ |
| 04 | `04_C_route2_cutscene.log` | ★撮れず・★止まった場所も 同一★★ §5 |
| 05 | `05_C2_route2_cutscene_neverstop.log` | ★撮れず・§5★ |

log の sha256:
```
b7a7d9c732702e61cacde8ec6df371a1323b3dc0391443ba4e3b3c4ae59fe0f2  01_ctl_tile110.log
6bd4f41cd435e7294251397ceb67462d77b770b214ffc6340f0c9471a126abee  02_A_tile110_gates_on.log
dfb82d45bb031f106c2c453c3e5fcaa5b8185dc8b2329b9dc347410d55c2d645  02b_Aprime_tile110_repeat.log
d6cdfa072da2e89a16cf8b04176c0579173c73594606b9d8742049d98d97bb0c  03_B_tile51_route1.log
17acfc9f3ed5eb318c7d8337f046b168ecaa53133f16aebefc81fab0291ad7cc  03b_Bprime_tile51_route1_repeat.log
78546a954e7dcee854e7b7e1f25e55fa0c9f56965e55f7c76cf68d305236371c  04_C_route2_cutscene.log
d1e3c652f6f298a10e975a12a03c7a07ad96a631addc957184c287e2af57612e  05_C2_route2_cutscene_neverstop.log
```

## 3. ★`WARP_DEST(0x4B menu-idx)` = ★全項目 一致★★

| 測った量 | before | after | 判定 |
|---|---|---|---|
| queue の frame(`Time.frameCount`) | 14 | ★14★ | 一致 |
| queue 時の counter | 0 | ★0★ | 一致 |
| pump の 行数 | 20 | ★20★ | 一致 |
| counter の 推移 ↔ frame | 1..20 ↔ 15..34（★1 tick / 1 frame★） | ★同一★ | 一致 |
| fire の counter 読み値 | 20 | ★20★ | 一致 |
| tick 序数（queue tick を 1） | 21 | ★21★ | 一致 |
| `[SCRIPTWARP] fire` の frame / Δ | 35 / Δ=1 | ★35 / Δ=1★ | 一致 |
| `[H8] ★到達★` | 1 件 | ★1 件★ | 一致 |
| ★`★★落ちた★★` / `★★差し替わった★★`★ | ★0 件★ | ★0 件★ | 一致 |
| `rt#` の 通し番号 | 3 | ★3★ | 一致 |
| ★counter の ★名前★★ | `_warpPendCounter` | ★`gs.WarpPendCounter`★ | ★★これだけ 変わった★★ |

⇒ ★★保持者が instance field → GameState へ 移ったのに、★数は 1 つも 動きませんでした★★★
　= ★b-1 の 移設が ★この経路の 挙動を 変えていない★ ことの 実測★。

★(A) 自動 warp★ = before/after とも `queued frame=5 → fire frame=6 / Δ(frame)=1`（01/02/02b の ★3 本とも★）。
★反復対照★ = after でも ★A/A' 一致・B/B' 一致★。
★object-identity hash は 比べていません★（run 跨ぎで 無意味 — before README §6 の申告どおり）。

## 4. ★★観測器が 落ちていないことの 実行時 照合（偽 GREEN の 入口）★★

★焼いた hash は 「合流前」しか 保証しません★（★合流後に 印字行が 落ちたかは hash では 判らない★）
⇒ 器 = `degimon_world_remake-integ/workspace/m437c/w3_tagset_cmp.py`
★算法★ = 各 log の ★行頭 `[NAME]` を 全数抽出して 集合比較★（★filter を 増やすほど 見逃す穴が 増える★ため ★Unity boilerplate も 落とさず 全数★）。

```
★★全体（和集合）★★ before 32 種 / after 32 種
★★before に在って after に無い（= 観測器が落ちた 疑い）★★ = なし
★★after にだけ在る（= 修正が足した印字の可能性）★★     = なし
★判定 = OK★（exit 0）
```
★file 単位の 差は 1 件だけ★ = `05` に after のみ `LIVEBOOT`。
★これは 挙動差では ありません★ = ★before の 05 は 私が run を 打ち切ったため 終了 log に 到達しなかった★（§5）。

## 5. ★撮れなかったもの（before と 同じ・理由も 同じか 確かめました）★

★`WARP_DEST(0x4B faithful)`（SceneCutscene の `QueueWarpPending`）= after も ★判定不能★★

- ★04（gate 既定）= ★止まった場所が before と 逐語 同一★★:
  `[VM-GATE] UNSUPPORTED ★op=0x6C★ len=8 entry=178 ★pc=0x1A★ prevOp=0xFE ⇒ ★停止(初回)★`
  ⇒ ★理由は 変わっていません★（★変わっていたら 発見でしたが、変わりませんでした★）。`WARP_DEST` 0 / `[H8]` 0。
- ★05（`W1_GATE_NEVERSTOP=1`）= ★到達せず★。`WARP_DEST` 0 / `[H8]` 0。
  ★但し before と 枠が 違います（申告）★:
  ・before = ★私が run を 打ち切った★（`Shutdown` 行 ★0 件★ / page 9 / entry=178 の pc 最大 ★0x2A4★）
  ・after  = ★最後まで 走り 正常終了★（`Shutdown` 行 ★2 件★ / page 22 / entry=178 の pc 最大 ★0x55A★）
  ⇒ ★★∴ 「after の方が 先へ進んだ」は 修正の効果では ありません★★ = ★before を 私が 早く切っただけ★。
  ⇒ ★どちらも 0x4B（@0x7c8）に 届いていません★ ⇒ ★撮れない という 結論は 同じ★。
  ⇒ ★`NEVERSTOP` は 挙動を変える env★ ゆえ、★仮に 届いても production gate 下の 到達を 意味しません★。

★b-2（`_rt==null` 枝の 駆動）★ = ★after の 7 本すべてで ★1 度も 回っていません★★
（`driver=_rt==null枝` が ★0 本★ / B の 段 2 は ★全 20 tick とも `driver=rt#3`★）。
⇒ ★∴ b-2 の 経路が 効くことは ★この 7 本では 示せていません★★。★「直った」とは 書きません★。
　★札 = 材料★（★`_rt` が null になる 筋書きが 要る★ — 本便の env では 起きませんでした）。

## 6. ★事前登録（`PREREG_after.md`）との 突合★

| # | 予想 | 結果 |
|---|---|---|
| P1 | `落ちた` は after も 0 件 | ★的中★（0 件） |
| P2 | counter 1→20 で 到達 | ★的中★ |
| P3 | 20 / 21 は 不変 | ★的中★ |
| P4 | queue frame=14 / fire frame=34 / Δ=1 | ★的中★ |
| P5 | (A) は Δ(frame)=1 のまま | ★的中★ |
| P6 | `rt#` は 3 のまま | ★的中★ |
| P7 | C/C2 は 同じ理由で 撮れない | ★C は 逐語 同一で 的中★ / ★C2 は 「届かない」は 同じだが ★枠が 違った★（§5）★ |
| P8 | tag 集合は 同一 | ★的中★（32/32・失われた tag なし） |

★★8 件中 7 件 完全的中・1 件（P7 の C2）は 部分的中★★
⇒ ★★∴ この回に H4 側の 前進は ありません★★（★予想の外は 出ませんでした★）。
★それ自体を 申告します★ — ★的中は 前進では ない★ ので、★次は 予想が 割れる所を 撮るべきです★
（= ★`WARP_DEST(0x4B faithful)` の 到達性★ / ★`_rt==null` 枝が 回る 筋書き★）。

## 7. ★この 7 本が 見ていない場所（母数の申告）★

1. ★`s_h8Reported` の cap★ = ★run に 1 回では なく ★pending 1 episode に つき 1 回★★。
   ⇒ 答えられるのは ★「その pending の間に ★少なくとも 1 回★ 差し替わったか」★。★「何回」は 答えられません★。
2. ★地図は `mayo00` 1 本だけ★（残り 241 地図は 撮っていません）。
3. ★`WARP_DEST(0x4B faithful)` / `[STEP3-TRACE]` の 3 site は ★1 度も 実行されていません★★。
4. ★`_rt==null` 枝（b-2）は ★1 度も 回っていません★★。
5. ★user の 実視覚は 経ていません★ ⇒ ★完成 claim は していません★。
6. ★`workspace/build/` は 不可触を 保ちました★ = 939 file の ★sha の sha★ が
   `2ee4f9e5e0f91a87b55178c6ea37e54344c5d202df35fa0a4d0b55cdba4e3d85` で ★build 前後 一致★
   ＋ 器側に ★配下なら `Exit(2)` の 安全弁★。
