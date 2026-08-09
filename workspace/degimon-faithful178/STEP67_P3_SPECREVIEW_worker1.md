# 0x67 (p3) spec 照合 review — worker1

**date**: 2026-07-19 / worker1 / ★read-only(f1b 非編集)★
**対象**: f1b trackF1B/event-oracle — y1=57c6321 / y2=8cc9f2e / y3=8e358ca / y4=83c1874
**設計正本**: STEP67_P2_DESIGN(§1 frame yield 決着根拠 / §2 実装形 / §3 prereg f1-f4)
**RE正本**: OI2_0x67_RE_worker1.md + OI2_0x67_OPTRACE(worker3 11/11)+ boss1 VM loop disasm(三重接地)
**手法**: 全 path trace(1 path OK 判定禁止)。DIFF=実 code paste。

---

## 判定: ★APPROVE★(全 5 観点 PASS、blocker 0、verification-dependency=f1/f3/f4 Unity-run)

y1-y4 は 三重接地確定 spec(0x67=Len4 u16-set + frame-yield、reader#2 動的DEAD)に spec-compliant。★frame-yield=第3の exit(State=Running 維持 + PC+4 + return)を EXE RestoreState ret=2(VM run 関数 return=tick 終了・次 tick 再開)の忠実 model として実装、Finished(0x66 c5 launch 停止)/plain break(同 tick 継続)と明確区別★。f3(b)の resume は code 構造で保証。

★特記: 本 review の OI-2 で私が挙げた候補仮説(a)『0x800913c0 BIOS 非通常 return→reader#2 未到達』が worker3 OPTRACE + boss1 disasm で確定(RestoreState longjmp ret=2)。静的/動的乖離は『longjmp で reader#2 が動的 DEAD』で決着=measure-first の結実。★

---

## 観点1: Y1-Y3 が EXE 実測 1:1 か(全 path trace)

handler=DialogueRuntime.cs:1056-1076。

| block | 実装(行) | EXE 実測 | 裁定 |
|---|---|---|---|
| Y1 u16 fetch | `ReadU16(_pc+2)`→`RawE164`(1065-66) | reader#1 0x800f0e6c=PC+1 skip + 0x800f1038 u16 read → [gp-0x6ca8]=0x8013E164 | ★1:1(u16 位置=opcode+2=skip1 後、Len4 反映)★ |
| Y2 marker | `RawE150=0x67`(1068) | sb 0x67 → [gp-0x6cbc]=0x8013E150(handler 共通 last-op marker) | ★1:1★ |
| Y3 ★frame-yield(第3 exit)★ | `_pc += len(4); return;` **State 不変=Running**(1073-75) | RestoreState(A0:0x14)ret=2=VM run 関数 return=this tick 終了、次 tick 再開(PC は 0x67 消費後=次 op) | ★1:1★(§観点3 で resume 構造確認) |

**★3種 exit の峻別(実 code)★**:
- Finished(0x66 c5 型 launch 停止): `State = DialogueState.Finished`(例 1166/1176)。
- plain break(同 tick 継続): `break;`→ post-switch `_pc+=len`→ while 継続(0x46/0x79/OFF)。
- ★frame-yield(0x67 ON): `_pc+=len; return;` **State=Running 維持**★=while を抜けるが State は Running ゆえ次 Tick 再開。→ 3種が code 上明確に別物。

## 観点2: OFF-inert([OP67] log/副作用が全て gate 後、Len4 既存)

- ★gate=case 冒頭(1059 `if(!_op67) break;`)= 最初の実行文★。[OP67] log(1074)+ 副作用(RawE164/RawE150 set 1066/1068)は全て gate 後。漏れ 0。
- ★Len[0x67]=4 は y1-y4 で不変★(y1 diff に Len 表変更なし、faithful-178 既存値)。0x67 ∉ JumpOps。
- OFF-new(`case: !_op67 break`)→ `_pc+=4`→ while 継続 == OFF-old(default 非jump break、_pc+=4、同 tick 継続)= ★bit 同一★。
- ★ON(yield=return)と OFF(break=継続)は tick 挙動が異なるが、OFF-inert の要件は『OFF==pre-step』であり OFF=old default ゆえ成立★(ON の yield は新規・gated)。

## 観点3: ★f3(b)前提=return 後に次 tick で継続する構造(永久停止の構造的可能性)★

実 code trace(Tick 545-556):
```
545 public void Tick()
547   if (State == WaitingFrames) { if(--_waitFrames>0) return; State=Running; }   ; 0x67 は非該当
552   if (State != Running) return;                                                ; 0x67 yield 後=Running ゆえ pass
555   while (_pc < _body.Length) { ... }                                           ; _pc(=+4)から再開
```
- ★0x67 yield: `_pc+=4; return;` で State=Running 維持(handler は State 非変更、Tick entry 552 で Running 確定済)★。
- ★次 Tick: 547 skip(WaitingFrames でない)→ 552 pass(Running)→ 555 while が **_pc(=+4=次 op)から再開**★。→ resume 構造成立。
- ★caller(TextboxView.cs:225 `_rt.Tick()`)= 毎 frame **無条件**呼出★(menu 分岐後に必ず到達)。GameFlow.cs:82 も同様。→ State=Running の間 Tick が毎 frame 呼ばれる=yield は次 frame で確実 resume。
- ★永久停止の構造的可能性=無し(0x67 固有では)★: resume は「VM が driven される限り」保証。0x67 は State=Running を維持するのみで、新たな stall 要因を導入しない(=通常の Running state と同じ「tick され続ける限り進む」性質)。EXE も RestoreState ret=2 で per-frame driver へ return→再入と同型。
- hang guard 整合: `ops` は Tick ローカル(555 手前で 0 初期化)→ yield-return で次 Tick に reset。多数 0x67 yield でも MaxOpsPerTick 非誤発火。✓
- ★f3(b)の positive resume assert 自体は worker3 Unity-run(実 Tick 2 回で直後 op 実行確認)が authoritative。code 構造は本節で成立確認★。

## 観点4: reader#2 非実装の根拠 + 発明ゼロ

- ★reader#2 非実装の根拠コメント(1119)適正★: 「reader#2=動的DEAD(OPTRACE 11/11、longjmp 後不到達=実装しない)」。三重接地(OI-2 静的 + worker3 OPTRACE + boss1 RestoreState ret=2 longjmp disasm)で dynamic DEAD 確定ゆえ非実装は正当(発明でなく、実行されない code を実装しない)。
- 発明ゼロ: Y1(u16→RawE164 raw 格納、値の semantic 解釈なし)+ Y2(marker)+ Y3(yield)のみ。u16 値の意味(E164 slot semantic)は 🅰 保留(raw slot、消費側 RE 後)。0x800f0910 側 [gp-0x6cb0] 付随処理=VM run 機構(opcode 実装でない)=scope 外で不実装(設計 §2)。

## 観点5: y4 harness(op67_verify.cs)が何を assert し何を除外するか

- ★REAL assert(実成果物 GameState)★: fresh RawE164/E150=0、Y1 RawE164=0x1234 round-trip、Y2 RawE150=0x67。
- ★yield-resume=『契約 model 前哨』と明示ラベル★: `ModelYieldResume` は pc+4/Running/resume の invariant を最小 proxy で記述。★harness 自身が「実 walker でない」「spec の invariant 記述であって実装コピー実行でない」「真裏取りは Unity-run(§f3)」「stub-green を完成扱いしない」と明記★(feedback_derisk_against_real_artifact_not_stub + feedback_state_which_dimension 遵守)。
- §Unity-run: f1(decode desync0/Len4)/f3(a)(b)(c)(d)実 tick-yield/f4 非退行 = authoritative と明示除外。
- ★偽green なし★: GREEN は「GameState raw slot 実 assert + yield 契約 model(前哨)」のみを主張し、実 tick-yield を verify したと詐称しない。
- ★観察(blocker でない)★: `ModelYieldResume` は arithmetic 恒真(pc=0x10+4=0x14、running=true を構築)=実装を test せず spec 再述に近い。但し「前哨/model」と honest ラベル済ゆえ偽green でない。実 f3 検証は 100% Unity-run へ委譲(model の verification value は最小=文書化相当)。

---

## 6. verification-dependency(blocker でなく設計 §3 既定)
- f1(full sweep desync0 + Len4 OFF 不変)/ f2(ON 固定 10 site で u16 実値 1:1)/ f3(a-d tick-yield 実挙動、特に(b)next-tick resume の positive assert)/ f4(OFF bit 不変 + care + CutsceneVerify178 + ON⊆OFF)= worker3 Unity-run。
- ★f3(b)は code 構造で成立(観点3)、実 positive assert は Unity-run★。

## 7. 総括
- ★APPROVE★: y1-y4 は 三重接地 spec に spec-compliant。Y1-Y3 1:1(u16 位置/E164/E150、frame-yield=State=Running+PC+4+return=RestoreState ret=2 忠実、3種 exit 峻別)、OFF-inert(gate 冒頭+Len4 不変+bit 同一)、f3(b)resume 構造成立(State=Running 維持+caller 無条件 Tick、永久停止の構造的可能性なし)、reader#2 非実装根拠適正(動的DEAD 三重接地)+発明ゼロ、y4=raw slot 実 assert + yield 契約 model を honest 前哨ラベル(偽green なし)。
- blocker=0。verification-dependency=f1/f3/f4 worker3 Unity-run(設計既定)。
- 完成 claim=user live(ON 側)まで凍結。
