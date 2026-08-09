# STEP5 d1 reconcile — parse claim 独立 x-check(worker1)

**date**: 2026-07-19 / worker1 / ★read-only、blind 手順★
**入力(自前 parse)**: worker3 sweep — census artifact `workspace/f1c/real_traces/sweep_225.jsonl.gz`(1278 launch)+ live ON run `workspace/f1c/step5_on_census.log`([SCENE-DRIVER])。worker3 result=STEP5_SWEEP_RESULT.md(input、可)。
**規律**: worker2 の STEP5_D1_RECONCILE_worker2.md §結論を精読する前に Q1-Q3 を自前 parse で固定(STEP A)→ 後で unblind 突合(STEP B)。Q4=コード直読。

---

## STEP A(blind、固定=以下確定。ここまで worker2 reconcile doc 未開封)

### 自前 parse 方法
sweep_225.jsonl.gz = stream(launch→op records(t 無)→entry_done)。python で launch 境界毎に op=0x66(102)出現を segment。live=step5_on_census.log の [SCENE-DRIVER] B1/B4/B6 grep。

### Q1. 実 launch 境界(Begin/PlaySection、live ON run step5_on_census.log)の 0x66 到達 + 分布 【実測固定】
- [SCENE-DRIVER][0x66] **B1=500 / B4=500 / B6=500**(=0x66 実行 500 回)。
- distinct entry(@entry=N)= **115**。
- ★launch あたり到達回数分布★: **per-launch=1 回**(各 launch-instance は 0x66 を 1 回のみ実行)。但し **per-entry は多重**(同一 @entry index が最大 **8 回**=entry 再 launch。500/115≈4.3 平均/entry)。
- → 「500 実行」= 500 launch-instance が各 1 回 0x66 到達、それらが 115 distinct entry に集約。

### Q2. census 側 artifact(sweep_225.jsonl.gz)の 0x66 到達 launch + 1 回/launch 性 【実測固定】
- 総 launch=1278 / ★0x66 到達 launch=**444**★ / 非到達=834。
- ★1 回/launch 性=**444/444 完全**★: 到達 launch は全て 0x66 を **正確に 1 回**実行(0 回超過なし)。かつ ★0x66 は到達 444 launch 全てで **最終 op**(直後 op 無し=444/444)★、reason=**全 idle_stop(444/444)**。
- distinct(req_scn,req_key)到達=443 / distinct req_scn 到達=**104**。
- → census artifact は「0x66=launch 終端・1 回/launch・idle_stop」を 444 launch で示す。

### Q3. census 非到達 launch(834)の離脱 op 分布 【実測固定】
- reason 分布: **return_fe=467 / idle_stop=358 / truncated_cap=5 / terminal_ff=4**。
- last_op 分布: 0xFE=467 / 0x4B=158 / 0x1A=62 / 0x4A=53 / 0x67=43 / 0x64=25 / 0x10=7 / 0x46=6 / 0xFF=4 / 0x00=4 / 0x48=3 / 0x80=1。
- ★focus 0x19/0x17/0x18 の件数 = **0 / 0 / 0**★(jump 系 0x13/14/16/17/18/19 いずれも last_op=0)。
  → ★非到達 launch は jump op で離脱していない★。離脱は return_fe(section 正常終端で 0x66 不在)/ idle_stop(他 op で idle、last_op 主に 0x4B warp/0x1A)/ truncated/terminal_ff。**「0x19/0x17/0x18 で離脱」という前提は sweep_225 では成立しない(実測 0)**。

### Q4. remake dispatch loop の 0x66 後継続構造 vs census idle_stop(コード直読、d2 独立判定)【固定】
- コード(DialogueRuntime.cs):
  - loop=`while (_pc < _body.Length)`(L533)→ byte 読取→ switch dispatch。
  - `case OP_SCENE_DRIVER`(L1034): ON 全 path(set/clear/-1)が単一 `break`(L1085)→ post-switch `_pc += len(=2)`→ **loop 継続=次 byte を op として実行**。
  - 終端は 0xFE(SECTION_RETURN→Finished)/ 0xFF / content_end_guard / op_guard / _pc≥body 末尾 のいずれか。0x66 自身は terminate しない。
- census(sweep_225): 0x66=到達 444 launch 全てで最終 op・reason idle_stop=★VM は 0x66 で停止(直後 op 非実行)★。
- ★独立判定: 差=**固着 prereg d2『直後 op 非実行』は c3 で構造的に未充足**★。remake は 0x66 後に `_pc+=2` して直後 byte を op 実行(loop 継続)する一方、census は 0x66 で idle_stop(直後 op 無し)。両者の exit 意味論が構造的に相違。
  - 帰結の限定: 直後 byte が 0xFE/end なら remake も即終端=挙動上は benign(idle と近似)。直後 byte が実 op なら remake は census に無い追加 op を実行=divergence。sweep_225 は 0x66 で記録停止ゆえ「直後 byte が何か」は census から不明=body 直読 or ON run の 0x66 後挙動測定が要(honest gap)。
  - → worker3 boss1 note「d2 未充足/reconcile」+ 私の p3 verification-dependency(clear 枝 break=YIELD だが EXE fall-through 非再現)と同根。

---

## STEP B(unblind、STEP A 固定後に worker2 reconcile read → per-item 裁定)

対象=STEP5_D1_RECONCILE_worker2.md。私の blind parse(sweep_225 + step5_on_census.log)と per-item 突合。

### per-item CONFIRM/DIFF

| # | worker2 claim | worker1 blind 実測 | 裁定 |
|---|--------------|-------------------|------|
| Q1 | 500 launch が 0x66 到達・各 1 回。『115』= `_curEntry.Index`(section 内 local=非 unique)の artifact | B1=B4=B6=500 / distinct @entry=115 / per-launch 1 回 / per-entry 最大 8(再launch) | ★**CONFIRM**★(500・per-launch 1 回・115=非 unique index artifact 完全一致。@entry=1 が 8=別 launch も一致) |
| Q2 | census sweep_225 = 444 launch × 1 回、0x66=最終 op(idle_stop)、直前 op=0x67 444/444 | 444 launch / 1 回 444/444 / 0x66 最終 op 444/444 / reason idle_stop 444/444 / ★直前 0x67=444/444(独立検証)★ | ★**CONFIRM**★(完全一致) |
| Q2-note | census doc 464/463 vs sweep_225 444 = final_run.jsonl 未取得 honest gap | 手元 sweep_225=444(final_run 非取得) | ★**CONFIRM**★(両者 sweep_225=444、final_run 未取得を共有) |
| Q3 | 非到達 834 が **含む**(occurrence): 0x19=426 / 0x17=27 / 0x18=4。到達 444 の 0x19=8 | ★独立 parse: 0x19=426 / 0x17=27 / 0x18=4、到達 0x19=8 完全一致★ | ★**CONFIRM(occurrence 次元)**★ + ★metric 差の明示(下記)★ |
| Q4 | remake は 0x66 後 0xFE まで継続実行、census は 0x66 で idle_stop=exit 忠実度 gap。post-0x66 byte=0x1c(SetFlag)418/0xFE 16/0x1D 9 | コード直読: break→_pc+=2→loop 継続で直後 byte を op 実行 / census 0x66=最終 op idle_stop 444/444 | ★**CONFIRM**★(構造・census idle_stop 完全一致。worker2 の post-byte 分布=0x1c 418 が私の判定を具体化) |

### ★Q3 metric 差の reconcile(矛盾でなく相補)★
- 私の blind Q3 = **last_op(終端 op)次元**: 0x19/0x17/0x18 が非到達 launch の**最終 op**である件数 = **0/0/0**(jump/branch は終端でない)。
- worker2 §3-2 = **occurrence(含有)次元**: 非到達 launch が 0x19/0x17/0x18 を**含む**件数 = 426/27/4。
- ★両立=非矛盾★: 非到達 launch は 0x19 条件分岐で **0x66 手前で分岐離脱**(occurrence 426)し、その後 **0xFE(467)/0x4B(158)/0x1A 等で終端**(私の last_op 分布)。つまり「離脱の機構 op=0x19(mid-trace 分岐、worker2)」+「終端 op=0xFE/0x4B(私)」。task の『離脱op』= worker2 の occurrence 読みが load-bearing(Δ 機構の核)。私の last_op=0 は「jump は終端でなく mid-trace 分岐」を裏付ける相補所見。

### reconcile 核心 claim の独立検証結果
- ★『115』= 非 unique `_curEntry.Index` artifact(launch 数でも site 数でもない)★ = CONFIRM(私も distinct @entry=115 だが per-launch 1 回・500 実行を確認)。
- ★真の比較=remake 500 vs census 444 launch(remake が +56 **over-reach**、under-coverage の逆)★ = CONFIRM(独立 parse で 500/444 一致)。
- ★boss1 前提『463 vs 115=d1 under-coverage』は誤り★ = CONFIRM(115 は artifact、実 500 over-reach、coverage 不足でない)。
- ★Δ+56 機構=jump-mode(narrow fall-through)+ fresh state(flag=0)で 0x19 が 0x66 側へ★ = CONFIRM 方向(非到達の 0x19 occurrence=426 が state 駆動分岐を実証。到達側 0x19=僅か 8)。
- ★decode/実装バグ否定(desync 0・1 回/launch・0x67 固定ペア・Len=2 忠実)★ = CONFIRM(私の parse も 1 回/launch 444/444・直前 0x67 444/444、p3 review で desync/Len 確認済)。

### 総括
★worker2 d1 reconcile は Q1-Q4 本体で worker1 blind と一致(独立 2 経路で cross-check 成立)。DIFF は Q3 の metric 次元差(last_op vs occurrence)のみ=矛盾でなく相補(離脱機構=0x19 分岐 / 終端=0xFE/0x4B)★。
- reconcile 結論(115=artifact / 500 vs 444 over-reach / d1 は decode 次元で判定 / decode バグ否定)= 妥当。
- ★Q4 の d2『直後op非実行』未充足★は worker2 §4 と一致し、post-0x66 byte=0x1c(SetFlag)418 ゆえ ★remake は ON 時 0x66 後に SetFlag を実行(census idle_stop は非実行)= 実 op divergence(benign でない)★。ただし ★これは linear walker の pre-existing 性質(step5 非導入、OFF 時も従来から 0x66 後継続)★=step5 回帰でない。exit 忠実化(0x66 で State=Finished 化)は PRESIDENT 裁定の別 finding。
- prereg d1 の literal『463 launch cover』は cross-mode(narrow vs jump-taken)で達成不能=worker2 の「decode 次元で判定」推奨に同意(prereg 改訂は PRESIDENT 裁定)。
