# caretick_verify 5 FAIL — OI triage(stale-harness drift)worker1

**date**: 2026-07-19 / worker1 / ★read-only 分析 + 修正設計(適用=boss1 承認後)★
**手法**: 実 compile+run で 5 FAIL 再baseline(derived doc でなくコード実測)+ git log --all で drift 起点特定。
**規範**: 「緑が何を assert するか」を保つ修正を選ぶ(feedback_verify_what_green_asserts)。f1b/f1c/o2 非編集。

---

## 0. 結論(単一)

- ★5 FAIL は全て **単一 refactor commit `b358bb4`(2026-07-15 03:53「③step2 seed 移送(A)— NewGame zero-init + hatch で seed 適用」)** からの drift★(+ 追従 `d9be75c` seed=20 確定)。
- ★drift 機構★: b358bb4 は **code + harness を atomic 更新**(GameState/NameInputState + caretick_verify の Hatch/T1a/T1b 追加)。しかし f1c は unity/ code のみ `acb1b79`(2026-07-16 tree 丸ごと取込)で受領、**workspace/caretick_verify.cs は 07-12 stale のまま**取り残された → old-harness(NewGame 即時 baby-init 期待)vs new-code(NewGame=pending)で 5 FAIL。
- ★pre-existing 確定★: worker3 O2 baseline 再現 + 本 triage の独立 compile 実測(f1c harness × f1c code = 5 FAIL)で二重確認。step5 起因でない。
- ★単一推奨 = Option B(期待値を two-phase pending/post-hatch 基準へ更新)★=b358bb4 が既に実施した形。fix は **f1b 現行 caretick_verify.cs(b358bb4+d9be75c、実測 ALL PASS)** を stale location へ port。Option A(Hatch 前置のみ)は pending-NewGame の assertion を失い不可(§3)。

---

## 1. 5 FAIL 実測(f1c old-harness × f1c code、roslyn compile 実行)

```
FAIL baby form: max/閾値/減衰=0/0/0(=25/6/3)
FAIL init seed: 満腹=0(=25) おなか=0(=50) げんき=0(=50)
FAIL init: CareIndex=-1(baby=1)
FAIL 1h Fullness decay 25→0(-3、rng 非依存)
FAIL FeedPartner 回復: 満腹=0(=12) おなか=6(=6)
```

| # | FAIL | old-harness 期待 | 現行 code 実測 | 直接原因 |
|---|------|-----------------|---------------|---------|
| 1 | baby form | max/thr/decay=25/6/3(NewGame で form 確立) | 0/0/0 | NewGame が form を確立しない(pending) |
| 2 | init seed | 満腹25/おなか50/げんき50(NewGame で seed) | 0/0/0 | seed が hatch 経路へ移送 |
| 3 | CareIndex | 1(baby、NewGame で) | -1(no-form sentinel) | pending sentinel 導入 |
| 4 | 1h decay | 25→22(seed25 起点) | 25→0(実際は Fullness=0 起点で floor 0) | seed 無ゆえ減衰の起点が無い |
| 5 | FeedPartner | 満腹=12 | 満腹=0 | FeedPartner の満腹 clamp=FullnessMax(=0、form 未確立)ゆえ 0 clamp |

★5 件とも根は 1 つ=「NewGame が baby form を即時 init する」前提★。#4/#5 は #1/#2/#3(form/seed 未確立)の派生(decay 起点無・clamp 上限 0)。

---

## 2. drift 起点(git log --all、コードへ re-baseline)

- ★refactor commit = `b358bb4`(2026-07-15 03:53)「feat(care): ③step2 seed 移送(A)— NewGame zero-init + hatch で seed 適用」★。
  - 触った file(atomic): `GameState.cs`(NewGameInit→CareIndex=-1/FullnessMax=0 pending、SeedNewGameCare を hatch 側へ)+ `NameInputState.cs`(hatch=BindCareForm+SeedNewGameCare)+ ★`workspace/caretick_verify.cs`(Hatch() helper + T1a/T1b split + T7/T8 Hatch 前置を同時追加=harness も一緒に直した)★。
- 追従 `d9be75c`(2026-07-15 06:23)「③step2(4)確定 — Fullness seed=20 独立定数(FullnessMax=25 と別値)」= seed 値 25→20 訂正(#2/#4 の期待値も 20 基準へ)。
- ★f1c への波及経路★: `acb1b79`(2026-07-16 04:05)「import(runtime): f35f0ee unity/ tree 丸ごと取込」= f1c は unity/ code(pending 込み)を import したが **workspace/ は import 対象外** → f1c の caretick_verify.cs は 07-12(b358bb4 前)stale のまま = drift 発生。
- ∴ 全 5 FAIL の drift 起点 = ★b358bb4(+d9be75c)★。それ以前(07-12 harness)の期待値が新 code と乖離。

**現況(全 worktree の harness 状態、Hatch 有無 grep)**:
- ★fix 済(Hatch 有=b358bb4 反映)★: f1b(ALL PASS 実測)/ o2(worker3 更新 07-19)/ offinert。
- ★stale(Hatch 無=5 FAIL)★: f1c(07-12)/ 主 repo degimon_world_remake(06-23)/ f1a/e152a-c/sp3 系(過去 fork)。

---

## 3. 修正方針の単一推奨(Option A vs B、「緑が何を assert するか」基準)

### Option A: hatch 呼出を harness setup へ前置(旧期待値維持)
- 内容: 各 test 冒頭に `Hatch(p)` を足し、旧 T1(NewGame=baby form/seed 期待)をそのまま通す。
- ★不可★: (i) 旧 T1 は「NewGame ITSELF が baby form」を assert していた → Hatch 前置後は「Hatch 後 = baby form」を見るだけで、★NewGame=pending(新 contract)を assert しなくなる=退行的に緑の意味が痩せる★。(ii) 旧 seed 期待(満腹=25)は d9be75c で 20 に訂正済 → Option A でも #2 は 25≠20 で FAIL 継続=そもそも直りきらない。

### ★Option B(単一推奨): 期待値を two-phase(pending / post-hatch)基準へ更新★
- 内容(=b358bb4 が既に実施): T1 を ★T1a(NewGame 直後=pending: care 全ゼロ + CareIndex=-1 + FullnessMax=0 を assert)★ と ★T1b(Hatch 後=form 25/6/3 + seed 20/50/50 + CareIndex=1 を assert)★ に分割。form 依存 test(T2 decay/T7 FeedPartner/T8 clock decay)は Hatch(p) を setup として前置。seed=20 基準へ。
- ★推奨理由★: 緑が ★refactor 後の実 contract(NewGame=pending という新仕様 AND hatch=form+seed 確立)を両方 assert★=「緑が何を assert するか」を最も忠実に保つ。Option A が失う pending-NewGame の検証を T1a が明示保持。実測で ALL PASS(f1b)=正しさ実証済。

→ ★単一推奨 = Option B★。これは b358bb4 が atomic に行った正しい形であり、f1c/主 repo の stale harness に **未 port** なだけ。

---

## 4. 修正 diff 案(適用=boss1 承認後。f1c 読取専用ゆえ内容は f1b 現行 = 実証済 fix)

★fix = f1b 現行 `workspace/caretick_verify.cs`(b358bb4+d9be75c、実測 ALL PASS)を stale location(適用先=boss1 判断: f1c workspace or verify suite が読む canonical)へ port★。b358bb4 の caretick_verify 差分(=そのまま適用可能な proven diff):

```diff
--- old(07-12 stale)
+++ fixed(b358bb4+d9be75c)
@@ T1(単一 NewGame 即時init 期待)を分割 @@
+    // T1a: NewGame 直後 = partner pending = care 全ゼロ
+    var gs = new GameState(); gs.NewGame(); var p = gs.Partner;
+    Check(p.Fullness==0 && p.Stomach==0 && p.Condition==0 && p.StatusWord==0 && p.HungerAccum==0, "NewGame=care 全ゼロ");
+    Check(p.CareIndex==-1 && p.FullnessMax==0, "NewGame=form pending: CareIndex=-1 FullnessMax=0");
+    Check(!p.IsHungry && !p.CareLatched && !p.IsStarving && p.CareMistakes==0, "NewGame: flags clear");
+    // T1b: hatch 後 = form 確立 + seed
+    Hatch(p);
+    Check(p.FullnessMax==25 && p.HungerThreshold==6 && p.FullnessDecayPerHour==3, "hatch baby form 25/6/3");
+    Check(p.Fullness==20 && p.Stomach==50 && p.Condition==50, "hatch seed 20/50/50");   // ★seed=20(d9be75c)★
+    Check(p.CareIndex==1, "hatch CareIndex=1");
-    Check(p.CareIndex == 1, "init: CareIndex=1");   // 旧: NewGame で即 baby=誤前提
@@ T2 1h decay 起点 25→20 @@
-    Check(p.Fullness == 22, "1h decay 25→22");
+    Check(p.Fullness == 17, "1h decay 20→17(seed20 起点)");
@@ T7 FeedPartner: form 依存 clamp ゆえ Hatch 前置 @@
+    Hatch(p);   // FeedPartner の満腹 clamp=FullnessMax → hatch で form 確立必要
@@ T8 clock decay: Hatch 前置 @@
+    Hatch(p);   // fresh NewGame=care 全ゼロ → hatch で form/満腹確立
```
+ Hatch() helper(SetCareForm(1,25,6,3,-1)+SeedNewGameCare())を追加(f1b:29-33)。

- ★検証★: 本 diff 適用後、f1b で ALL PASS(35 assert)を実測済。stale location への port も同結果見込み(code は同一 pending refactor)。
- ★適用先 = boss1 判断★: f1c は read-only 指定ゆえ本 triage では非適用。canonical verify suite の caretick_verify(主 repo or f1c workspace)へ port する形を推奨。golden37/bulk89 は vector 直接 set ゆえ本 drift 無関係(PASS 維持)。

---

## 4bis. 適用結果(boss1 GO 2026-07-19、f1c 1 file 限定例外)★ALL PASS★

Option B 承認 + f1c caretick_verify.cs 1 file 限定編集 GO を受け適用:
1. ★stale 保全★: `f1c/workspace/caretick_verify.cs` → `.bak`(sha256 先頭=`05f81432…`)。
2. ★fix port★: f1b 現行版(b358bb4+d9be75c、ALL PASS 実証済)を byte-copy → f1c(sha256 先頭=`bb664a1e…`、cmp IDENTICAL)。
3. ★f1c 現行 code で実 run(f1b code の PASS を外挿せず)★: f1c の GameState/DcRandom/SceneTransition(O2+p3 sync 済)+ 移植 harness を roslyn compile+run:
   - ★結果 = ✅ ALL PASS / 36 assert / 0 FAIL★(旧: 5 FAIL)。5 FAIL(baby form/init seed/CareIndex/1h decay/FeedPartner)全解消。
   - ★f1c 固有 code で検証済★=drift 是正が f1c の実 code contract と整合(two-phase pending/post-hatch を f1c code が満たす)。
4. f1c 他 file 不触(1 file 限定)。golden37/bulk89 は本 drift 無関係で不変。

→ ★caretick_verify drift(OI)= CLOSED★(f1c で ALL PASS 36 assert 実測)。

★literal 突合注記(35 vs 36、boss1 指摘)★: p3 review の『f1b ALL PASS(35 assert)』は実 grep count でなく概数引用だった。実測 `grep -c '  ok   '` = f1b/f1c とも **36**(harness sha 両者一致 bb664a1e=byte 同一ゆえ assert 数も同一)。+1 差は ★count 方法差(概数→実 grep)であって code 差でない★。正=36。

## 5. honest 注記
- 本 triage は f1c old-harness × f1c code の実 compile で 5 FAIL 再現(推測でなく実測)。root=b358bb4 は git log --all -S で特定。
- fix は既存(b358bb4 実装、f1b/o2 で稼働)ゆえ「新規実装」でなく「stale copy への port」。over-engineering 回避。
- 完成 claim(harness 緑)は進捗であって user live 完成でない(care は既 land 済機構=本件は harness drift の是正のみ)。
