# VISMAP fix 設計 doc — 覚醒 field 視覚忠実度 bug(中間 loading map 可視化)修正(boss1 起案、2026-07-17 → PRESIDENT gate ①)

## 0. 位置づけ
- user live 実視覚で確定した field 視覚 bug(覚醒中に中間 loading map=TUNN07/MIST03 等が可視表示=「無茶苦茶」)の (ii)faithful-reduced 修正設計。
- PRESIDENT 裁定 = (ii)先行(hard-cut、fade は明示 honest-mark 後続 polish)。
- 材料(全て実測、boss1 直読裏取り済):
  - worker3 `VISMAP_ORACLE.md`(f1c `666716f`、frame-dump 実測): 非可視=全 0x47 emit 11/11(diff 0.0)+boot 0x4B(238)。可視=黒+地名 card→草原(178§254)→fade→ROOM08(0x4B218)→fade→twna01(terminal 0x4B204)+HUD。
  - worker2 step0/step0.5 audit(read-only): consumer 経路 + 判別 signal + fade 不在 + signal-bridge gap。
- ★VM chain(c8e2e32)は忠実で正しい。本修正は visual 層(field emit→render 方針)のみ。VM 非 touch★。

## 1. 確定機構(実測、実装前提に使える)
### 判別 signal(worker2 step0.5、DialogueRuntime.cs 実 code 同定)
- `DialogueState` enum: {Idle, Running, WaitingAdvance, WaitingFrames, WaitingChoice, Finished}。
- ★可視 map = VM が **settle**(Running→WaitingAdvance/WaitingChoice/Finished)する beat。非可視 warp = **Running**(opcode 実行中、即次 warp)★。
- opcode 種別だけでは不十分(boot 0x4B(238) が反例=0x4B だが非可視)。settle-state が boot 0x4B(238)[Running/transient] と 0x4B(218)/(204)[settle] を分ける。

### oracle frame-map への接地(推論でなく実測突合)
| beat | settle 点(VM) | 直前 0x4B(pending map) | oracle 可視 |
|---|---|---|---|
| 草原 | 178§254 body(WaitingAdvance) | 0x4B(238) → pending=238 | 草原 ✓ |
| ROOM08 | 163(dialogue settle) | 0x4B(218) → pending=218 | ROOM08 ✓ |
| twna01 | 149/IsFinished | terminal 0x4B(204) → pending=204 | twna01 ✓ |
- ★各 settle で render すべき map = 直前 0x4B の dest = oracle 可視 map と 1:1★。0x47 は pending を更新しない(草原 beat で 0x47(30)(117)(29) が pending=238 を上書きしないから草原=238 が出る、ROOM08 beat で 0x47-after-0x4B(218) が 218 を上書きしないから ROOM08 が出る)。

## 2. 修正機構: cutscene-active-gated coalesce-to-settle render
### ★gate 訂正(2 段、worker2 実 code 直読で捕捉、boss1 裏取り済)★
- ★訂正1(step1): 「IsCutsceneActive 単独」は誤り★: OFF 覚醒も RunScene(238)→ACTIVATE 178→SceneCutscene root ゆえ **IsCutsceneActive=true**。∴ 単独では OFF cutscene(830ac05b)も coalesce=OFF 保護不足。→ `FaithfulScenarioZero && IsCutsceneActive` へ。
- ★訂正2(step2 前 premise-check): 「FaithfulScenarioZero && IsCutsceneActive」も不足★: 覚醒 flow は root 混在 — §204(RunScene(204)→**PlayMapSection=NpcSection root**、boss1 直読確認)+ §238(0x4B(238)→scenario-0 §238、PendingScenarioActivate=false=**NpcSection root**)は **IsCutsceneActive=false**。∴ これらの 0x47(mist03/topn01/tunn07 由来)が gate 素通り→render(bug 残存)。SceneCutscene な §218/178§254 のみ ICA=true。
- ★正 gate = dedicated flag `AwakeningCutsceneActive`(worker2 option A)★: 覚醒 cutscene 全 span(Boot→twna01、NpcSection + SceneCutscene 混在)を cover。
  - **set**: ScenarioVM Boot の `if(FaithfulScenarioZero)` block(RunScene(204) 覚醒起点)。★OFF(RunScene(238))は set しない=OFF-inert★。
  - **clear**: 覚醒 terminal(c8e2e32 terminal 0x4B(204) LaunchDest=204→twna01 settle→idle。twna01 render 後)。★clear 後は field-nav 即 render 復帰★。
  - (B)FSZ && InputLocked = field NPC dialogue も InputLocked=true ゆえ field-nav 0x47 warp 誤 suppress=却下。

★gate=AwakeningCutsceneActive(dedicated flag、Boot(204) set / terminal clear)★ 背後で:
1. **0x4B warp**: pending field-map を更新するが **即 render しない**(現状の QueueWarp→次frame flush→BuildField を defer)。pending は次の 0x4B か settle まで保持。
2. **0x47 emit**: ★可視 pending を更新しない・render しない★(map-setup、非 field-scene)。= 中間 mist03/tunn07 可視化の直接封鎖。
3. **DialogueState settle 遷移**(Running→WaitingAdvance/WaitingChoice/Finished): pending map が現表示と異なれば BuildField(pending)。= 草原/ROOM08/twna01 の 3 render のみ、中間ゼロ。
4. **OFF cutscene(flag=false、AwakeningCutsceneActive 未 set)/ 通常 field-nav(terminal 後 clear 済)**: gate FALSE ゆえ現状の即 render を 1 bit も変えない。★OFF 覚醒は ICA=true でも AwakeningCutsceneActive 未 set(OFF は RunScene(238)、set 経路非通過)で除外(byte-identical 保護)★。

### signal-bridge(worker2 wiring 選択)
- FieldManager は現状 IsCutsceneActive のみ保持、DialogueState(settle-state)未接続。
- bridge = FieldManager が settle 遷移時に deferred pending を flush できるようにする(DialogueRuntime が settle event を push、または FieldManager flush が DialogueState を参照)。★wiring は worker2 が既存境界で選択、semantics は本 doc 固定★。

## 3. ★honest-mark(隠す shortcut でない、明示的 follow-up)★
- ★fade 未実装★: 実機は 0x4B(218)/(204) で fade(oracle 8040/10680)。本 (ii) は hard-cut(fade 無し)。★視覚完成でない=user 再視聴後に fade 要否判断→(i)full-fade は別 dispatch★。
- ★地名 card『はじまりの街』未実装★: oracle は boot 期に地名 card。発火 opcode 未同定(worker3 caveat)。honest-mark 後続。
- ★これらは fidelity 拡張として分離、core bug(中間 map 可視化)修正とは別★。cargo 緑/hard-cut land ≠ 視覚完成。

## 4. ★honest gap / 実装前 verify(premise 化しない)★
- ★実装時 dry-run trace で「各 settle の pending = oracle 可視 map(草原=238/ROOM08=218/twna01=204)」を実測確認してから land★。§1 表は oracle 接地だが、実装が実際にこの pending 列を産むか(0x47 が本当に pending 非更新か、map-id 一致か)を trace で確認=推論を実装に密輸しない。
- ★gate(A)coverage の実測確認(訂正2 由来、追加検証項目)★: (a)§204/§238 NpcSection の 0x47(mist03/topn01/tunn07 由来)も AwakeningCutsceneActive gate 内で **非 render**(ICA=false でも dedicated flag が cover)。(b)terminal twna01 render 後に flag clear→**field-nav 即 render 復帰**(flag 残留で field-nav 破壊しない)。(c)可視列=草原→ROOM08→twna01 の 3 render のみ、中間 0 件。
- 0x47 の非 field 意味(map-setup が何を set するか)= scope 外(可視 render を suppress するだけ、data-load 副作用があれば worker2 が実装時に保持判断)。

## 5. acceptance(gate ②-style、runtime)
- ★OFF-inert(最優先・単独 gate)★: flag OFF で追加 code 前後 byte-identical(前後 2 run、PRESIDENT construction 直読)。user PASS 済 OFF cutscene 視覚保護。
- ★通常 field-nav 非破壊★: transporter/tile warp の即 render 維持(IsCutsceneActive=false path 不変)。
- ★VM(c8e2e32)非退行★: STEP3-TRACE chain(204→149→238→178→218→163→0x17→204)不変。
- ★可視列一致(全数)★: worker3 再走で C# 可視 map load 列 = oracle 可視列 1:1(草原→ROOM08→twna01)、中間 load 0 件。粒度/形式は実装 land 後に worker3 が prereg 固定。
- ★user 再視聴 = 受理後、boss1 が実機可視列照合してから★(hard-cut=視覚完成でない明示)。

## 6. file 境界 / 実装分担
- worker2(DialogueRuntime.cs 0x4B/0x47 emit + FieldManager QueueWarp/flush/BuildField、IsCutsceneActive gate、既存境界): signal-bridge wiring + coalesce-to-settle + 0x47 suppress。着手前 step1=OFF-inert 単独 commit。
- worker3(DGFRAME/可視列 harness で C# 可視列を再走、oracle 1:1 突合)。

## 7. 実装順序
1. worker2: signal-bridge + coalesce-to-settle 設計を実 code 直読で確定(§4 dry-run trace で pending 列 verify)。
2. OFF-inert 配線(単独 commit)→ OFF byte-identical 実測。
3. cutscene-gate coalesce + 0x47 suppress 配線 → dry-run trace で可視列 = oracle 確認。
4. worker3 再走 → oracle 1:1 突合 → gate ② 上申。
5. user 再視聴 = boss1 実機可視列照合後(fade/card は honest-mark 後続)。

## 8. 規範
push ゼロ / OFF 保護(bit-identical)/ field-nav 非破壊 / VM 非退行 / 完成 claim 凍結(hard-cut=視覚完成でない明示、user 実視聴)/ honest-mark(fade・地名 card 分離)/ measure-first(§4 dry-run trace verify、推論を実装に密輸しない)/ memory 提案制。
