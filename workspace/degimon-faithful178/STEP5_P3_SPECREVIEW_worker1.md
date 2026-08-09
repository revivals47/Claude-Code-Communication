# STEP5 (p3) spec 照合 review — worker1

**date**: 2026-07-19 / worker1 / ★read-only(f1b worktree 非編集)★
**対象**: f1b trackF1B/event-oracle 5 commits — c1=0bc6516 / c2=7bfbae1 / c3=863246e / c2訂正=a1c36cd / c4=3399135
**設計正本**: STEP5_P2_DESIGN_boss1_2026-07-19.md(§1 B1-B6 / §2 D1-D3 / §4 d1-d4 + PRESIDENT補足=clear枝 stub YIELD相当)
**RE正本**: STEP5_P1_RE_worker2.md + STEP5_P1_XCHECK_worker1.md(Q1-Q4 二重独立確定)
**手法**: 全 path trace(1 path OK 判定禁止)。DIFF は実 code paste。

---

## 判定: ★APPROVE★(全 5 観点 PASS、blocker 0、verification-dependency 1 件)

5 commits は設計正本(Option S / D2 gap / d1-d4)+ EXE p1 RE 仕様に spec-compliant。発明ゼロ・OFF-inert・YIELD 収束を全 path trace で確認。残 1 件は「設計が意図的に worker3 d1/d2 run へ委譲した empirical gate」であり code 欠陥でない(下記 §6)。

---

## 観点1: B1-B6 が EXE 実測仕様と 1:1 か(全 path trace)

handler=DialogueRuntime.cs:1034-1086(case OP_SCENE_DRIVER)。

| block | 実装(行) | EXE 仕様 | 裁定 |
|---|---|---|---|
| B1 operand fetch | `ReadByte(_pc+1)`(1048)、PC は Len=2 で post-switch 前進 | 0x800f0edc=1byte+PC++。値は EXE でも後続上書きで破棄 | ★1:1★(値 read のみ=semantic 未確定を honest 踏襲) |
| B2 counter | `SceneDriverCounterInc()`(1051)、飽和で loud log(1053) | 0x800EE740 `slti 0x270f`: `if E12C<0x270f: ++`、else cap | ★1:1★(§下 counter 検算) |
| B3 var-list | `GetVar(0xfa)` head 値のみ(1057)、semantic=gap(loud log) | var[0xfa]起点 0xfb.. 反復(register set 系) | ★構造 head+gap 宣言★(反復副作用 0x800f0cd0/0x800f50a8 未実装=発明ゼロ) |
| B4 selector | STUB(1063-65): `RawE104` loud log、`sdResult=0`(成功系固定) | 0x800cfec4→0x800aeca8(arg E104)→結果code | ★D2 宣言gap★(descriptor表/3段目 RE 未=配線せず、log で開示) |
| B5 −1枝 | `if(sdResult==-1)`(1068)=stub では非到達、到達時 loud log(1070) | retry--/座標reset/label 0x4de seek | ★skeleton★(成功系固定ゆえ非到達、raw slot+seek は未配線=gap 明示) |
| B6 非−1枝 flag#1 gate | `GetFlag(1)`(1076)、`if set→log SET / else→log CLEAR`(1077-82) | 0x800f0c74→0x800f191c flag#1 test。set=0x800bd820 action+exit / clear=scene init→0x67 fall-through | ★1:1(gate)★+ action/0x67-body=gap(Option S、loud log) |

**B2 counter 検算(EXE vs C#、実 paste)**:
```
EXE 0x800EE738  lh $v0,-0x6ce0($gp) ; 800EE740 slti $at,$v0,0x270f ; 800EE744 beqz→skip inc ; 800EE754 addi+1
C#  GameState.cs:499  if (RawE12C < 0x270f) { RawE12C++; return false; }  return true;
```
→ EXE『v0<0x270f で++、cap 0x270f』= C# 完全同型。飽和値=9999(0x270f)一致。**1:1**。

**B6 gate 排他性(d4)**: `if(sdFlag1) …SET; else …CLEAR;`(1077-83)= if/else ゆえ ★各実行で SET/CLEAR いずれか 1 本のみ★=両枝同時/無分類 構造的に不能。設計 d4 と一致。

**全 path 列挙**: OFF→break / ON:{B5(−1、非到達)→break} / {B6 set→log→break} / {B6 clear→log→break}。→ 全 path 単一 break(1085)収束。1 path でなく 4 path 全 trace 済。

---

## 観点2: OFF-inert(_sceneDriver gate 前に log/副作用漏れ無いか、[SCENE-DRIVER] log 全列挙)

- ★gate=case 冒頭(1037 `if(!_sceneDriver) break;`)= 最初の実行文★。log/副作用は全て gate の後。
- [SCENE-DRIVER] log 全 grep=1053/1059/1064/1070/1079/1082 = ★全て gate(1037)より後★(漏れ 0)。
- 副作用(`SceneDriverCounterInc`/`GetVar`/`GetFlag`)も全て gate 後。
- ★Len[0x66]=2 は c1 で変更していない(既存値、0x67 4byte fix 時確定)★=diff に Len 表変更なし → OFF decode 不変。
- 0x66∉JumpOps(={0x13,14,16,17,18})+ Len=2 既存 → OFF-new(`case: !_sceneDriver break`)== OFF-old(default 非jump break、_pc+=2)= ★bit 同一★。
- ⇒ ★OFF-inert 成立★(OFF=[SCENE-DRIVER] log 0 + 現行 bit 不変)。

---

## 観点3: exit 意味論=両枝とも YIELD 相当(hang/desync 構造なし、PRESIDENT補足)

- 全 path(OFF/−1/set/clear)が ★単一 `break`(1085)★ に収束 → post-switch `_pc += len(=2)`。return/goto/loop なし。
- clear 枝も break(0x67 body は実行せず=Option S gap)=set 枝と ★同一 exit★。→ 両枝 YIELD 相当(dispatch 継続 or last-op 自然 end-of-body)。
- hang guard: `MaxOpsPerTick=4096`(120)存在 → 無限loop 構造防止。`ReadByte`(1394)境界安全(範囲外=0)→ last-op 時も B1 安全。
- ⇒ ★PRESIDENT補足(clear枝 stub=YIELD相当、hang/desync なし)= code 上成立★(実 hang/desync 0 は worker3 d2 run で empirical 確認)。

---

## 観点4: 発明ゼロ(gap 宣言が semantic にすり替わっていないか)

- B3 list-loop=`GetVar(0xfa)` head 値 log のみ、反復未実装(1055-57 comment『発明しない』明示)。
- B4 selector=STUB(結果 code 固定 0、E104 未 populate)、scene 機構配線なし(1061-65、D2 gap)。
- B6 set-action(0x800bd820)/clear-scene-init(0x80163FD8)/0x67-body=全て log のみ、動作未実装(1078-82、Option S gap)。
- ⇒ ★semantic すり替え 0★。全 gap が loud log(Debug.LogWarning)で doc/log 両宣言=既存 disposition 様式踏襲。

---

## 観点5: raw slot 配置 + c4 harness が d3/d4 を実際に assert するか(緑の中身)

- **配置**: RawE12C/RawE104/SceneDriverCounterInc は ★GameState(script VM state)★ に在り(GameState.cs:491/497)、a1c36cd で PartnerState→GameState 移動済。PartnerState 残骸 grep=0(clean)。設計 D3『script-VM state であって care でない』と一致=正当。
- **c4 harness(scene_driver_verify.cs)が assert する『緑』の中身**:
  - d3 counter 1:1: 464 inc→E12C=464(30)、飽和なし(31)。
  - d3 飽和: 9998→9999(手前 false、37)/9999→cap(true=飽和 loud trigger、39)= EXE slti 0x270f と 1:1。
  - raw slot default: RawE12C/E104==0(baseline C 全ゼロ、23-24)。
  - d4 flag#1 read: default clear(43)/set 反映(45)。branch 排他は if/else 構造保証と注記。
- ★scope 明記が模範的(feedback_state_which_dimension / feedback_verify_what_green_asserts)★: harness §5-8 で ★d1(decode desync)/d2(idle_stop・hang)/d4(branch log 排他)は『DialogueRuntime=Unity 依存ゆえ leaf 不可→Unity full-sweep run で grep 判定』と明示除外★。→ ★偽green なし★(GREEN は d3+raw-slot+flag-read のみを assert、d1/d2 を assert したと詐称しない)。

---

## 6. verification-dependency(★blocker でなく、設計が worker3 run へ委譲した empirical gate★)

- **観測**: ON clear 枝は EXE の『0x67 fall-through で operand 2byte 追加消費(0x800f0ff0)』を ★再現しない★(break→_pc+=2 のみ)。これは D1 Option S(0x67 body=gap)の ★設計意図どおり★。
- **内部整合**: C# は decode-walk と ON-handler が ★同一 Len=2 前進★ゆえ内部 desync なし(自己整合)。
- **EXE 忠実度 gap(bounded)**: 実 EXE の clear 枝 0x66 が in-section で後続 op を持つ場合のみ、C#(2byte)と EXE(4byte fall-through)が乖離。census『0x66 idle_stop 464/464(=last op)』が真なら該当ゼロ。
- ⇒ ★d1(1278 entry decode desync 0)/d2(全 0x66 site YIELD・hang 0)を worker3 Unity full-sweep で empirical 確認必須★。これは設計 §4 d1/d2 が元々定めた gate ゆえ、review としては『code は設計に忠実、残 gap は既定の empirical gate 待ち』= APPROVE を妨げない。
  - ★worker3 run で万一 desync 検出時のみ blocker 化★(その場合 Len 可変長 or 0x67 pair 実装=Option P へ)。

---

## 7. 総括
- ★APPROVE★: 5 commits は EXE p1 RE + p2 設計に spec-compliant。B1-B6 1:1(B2 counter/B6 flag gate 実 paste 照合)、OFF-inert(gate 冒頭+Len 不変+bit 同一)、YIELD 収束(全 4 path 単一 break)、発明ゼロ(全 gap loud log)、raw slot=GameState 正当、c4 緑=正しく d3/raw/flag のみ assert(偽green なし)。
- blocker=0。verification-dependency=1(d1/d2 worker3 run、設計既定の empirical gate)。
- 完成 claim=user live まで凍結(headless/leaf 緑は進捗)。
