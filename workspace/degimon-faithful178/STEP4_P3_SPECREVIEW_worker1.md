# STEP4 (p3) spec 照合 review — worker1

**date**: 2026-07-19 / worker1 / ★read-only(f1b 非編集)★
**対象**: f1b trackF1B/event-oracle — k1=a69a76e / k2=a104260 / k3=0b7ab36 / k4=548fa99
**設計正本**: STEP4_P2_DESIGN(§1 A1-A5 / §2 D1-D4 / §3 prereg e1-e4)
**RE正本**: STEP4_P1_RE_worker1.md(handler 全長RE + corpus 実 byte)+ STEP4_P1_XCHECK_worker2.md
**手法**: 全 path trace(1 path OK 判定禁止)。DIFF=実 code paste。

---

## 判定: ★APPROVE★(全 5 観点 PASS、blocker 0、verification-dependency=設計既定の e1/e3/e4 Unity-run)

k1-k4 は EXE p1 RE(0x46=0x800ED480 / 0x79=0x800EF190、registry @0x80164098 add/remove dual)+ p2 設計(A1-A5/D1-D4/e1-e4)に spec-compliant。★0x46/0x79 の A5=通常 break は EXE 忠実(両 handler が b epilogue=dispatch 復帰、0x66 の idle_stop とは別)= 実装者が正しく区別★。発明ゼロ・OFF-inert・0x47 非改変を全 path trace で確認。

---

## 観点1: A1-A5 が EXE 実測 1:1 か(全 path trace)

handler=DialogueRuntime.cs:1045-1076(case OP_REGISTRY_ADD/REMOVE 共有)。

| block | 実装(行) | EXE 実測 | 裁定 |
|---|---|---|---|
| A1 operand fetch | `ReadByte(_pc+1)`(1055)、両 opcode 共通、Len=2 で PC 前進 | 0x800f0edc 1byte(0x800ED484 / 0x800EF194) | ★1:1★ |
| A2 REGISTRY_ADD | `RegistryAdd`(1060)=GameState.cs:512-517 **昇順走査 first -1→格納**、満杯=-1 | 0x800f1590: `s0=0..8、*[base+s0*4]==-1 で store、else s0++` | ★1:1(探索 order 昇順・満杯 no-op まで一致)★ |
| A3 REGISTRY_REMOVE | `RegistryRemove`(1069)=GameState.cs:523-528 **昇順走査 first 一致→-1**、不在=-1 | 0x800f1850: `s0=0..8、s1==*[base+s0*4] で -1、else s0++` | ★1:1★ |
| A4 activate/deactivate | 宣言gap: loud log(id 実値付き、"gap" 明示)1062/1071 | 0x800bb518→0x800a1348 / 0x800bb968(actor 実体) | ★宣言gap(発明ゼロ、log のみ)★ |
| A5 exit | 単一 `break`(1075)→ _pc+=2 | 両 handler `b epilogue`(0x46→0x800edd5c / 0x79→0x800ef318)=dispatch 復帰 | ★1:1(通常 break=EXE epilogue 復帰。★0x66 の idle_stop 化(c5)と別扱い=正しい区別★)★ |

**registry model 1:1(GameState.cs、実 paste)**:
```
505  int[] ActorRegistrySlots = {-1×8}          ; EXE 8-slot @0x80164098 sentinel -1
514  for i in 0..7: if slots[i]==-1 {slots[i]=id; return i}  return -1   ; = 0x800f1590 昇順 first-empty/満杯no-op
525  for i in 0..7: if slots[i]==id {slots[i]=-1; return i}  return -1   ; = 0x800f1850 昇順 first-match/不在no-op
```
**全 path 列挙**: OFF→break / ON-ADD{格納 slot≥0 log / 満杯 -1 log}→break / ON-REMOVE{clear slot≥0 log / 不在 -1 log}→break。全 path 単一 break(1075)収束=4 分岐全 trace 済。

---

## 観点2: OFF-inert([ACTOR-REG] log/副作用が全て gate 後か、grep 全列挙)

- ★gate=case 冒頭(1049 `if(!_actorRegistry) break;`)= 最初の実行文★。
- [ACTOR-REG] log 全 grep=1062/1064/1071/1073 = ★全て gate(1049)より後★。副作用(`RegistryAdd`/`RegistryRemove`)も gate 後(1060/1069)。漏れ 0。
- ★Len[0x46]=2 / Len[0x79]=2 は k1-k4 で不変★(diff に Len 表変更なし、既存値=row50 idx6 / row51 idx9)。
- 0x46/0x79 ∉ JumpOps(={0x13,14,16,17,18}) → OFF-new(`case: !_actorRegistry break`)== OFF-old(default 非jump break、_pc+=2)= ★bit 同一★。
- new-game reset(GameState.cs:748 全 -1 fill)は OFF 時 no-op(未 populate ゆえ既に全 -1)= OFF-inert(k2 comment 明示)。
- ⇒ ★OFF-inert 成立★。

---

## 観点3: 0x47 非改変 + 隣接 decode

- ★0x47(OP_MAP_CHANGE)path は k1-k4 diff に **変更なし**★(全 diff grep: 0x47 言及は comment のみ、code 変更ゼロ)。0x47 handler(既存 MAP_CHANGE、C# 実装済)不触。
- ★隣接 decode 正当(e1)★: 0x46 case は `ReadByte(_pc+1)`(read のみ)+ break→_pc+=2。→ 次 iteration が _pc+2=0x47 を **独立 opcode** として dispatch(0x46 は 0x47 の byte を消費しない)。corpus [46 XX][47 XX NN 00] で 0x46=Len2 で止まり 0x47=MAP_CHANGE emit=p1 実 byte と整合。

---

## 観点4: 発明ゼロ(activate 実体/id 空間 semantic が gap 宣言に留まるか)

- A4 activate(0x800bb518→0x800a1348)/ deactivate(0x800bb968)= ★log のみ(Debug.Log/LogWarning、"gap" 明示、id 実値付き)、実動作 未実装★。
- ★id 空間 semantic 非実装★: registry は operand を raw int として格納するのみ。0x46 operand==0x47 map id の 6/6 一致(p1 §6bis id 空間観測)を「recruit→map 遷移」等の semantic に配線せず=🅰 保留を実装で遵守。
- registry=raw int[8] model(GameState.cs:503 comment『semantic 未同定=発明しない』)、actor/model 解釈なし。
- ⇒ ★semantic すり替え 0★。

---

## 観点5: k4 harness(registry_verify.cs)の緑が e2 前哨として何を assert するか

- **e2 registry state(leaf assert)**: sentinel(fresh 全 -1)/ ADD 昇順 first-empty(0x9a→slot0…)/ REMOVE id 一致→-1 + ★穴 昇順再利用(REMOVE 0x50→slot1、ADD 0x63→slot1)=探索 order 昇順の load-bearing 実証★/ REMOVE 不在=-1 / ★入替 pattern(corpus (151,60) REMOVE 0x01→ADD 0x75=slot0 再利用)★/ overflow(8 満杯→ADD -1 no-op)/ ClearScriptState 全 -1 reset / ★corpus ADD 列(170-173,51)=0x50/0x44/0x63/0x5d→slot0-3★。
- ★scope 明記が模範(feedback_state_which_dimension / feedback_verify_what_green_asserts)★: §Unity-run で ★e1(walker desync/0x47 隣接 decode)/ e3(OFF bit 不変)/ e4(非退行)は DialogueRuntime/Unity 依存ゆえ Unity-run corpus 6 + full sweep で判定★と明示除外。→ ★偽green なし★(GREEN は e2 registry state のみ assert、e1/e3/e4 を assert したと詐称しない)。

---

## 6. verification-dependency(blocker でなく設計 §3 既定の empirical gate)
- e1(corpus 6 walker desync 0 + 0x47 隣接 decode)/ e2(ON corpus run で [ACTOR-REG] op 列が実 byte と 1:1)/ e3(OFF [ACTOR-REG] 0 + bit 不変)/ e4(care 3系統 + CutsceneVerify178 + full sweep desync 0 + ON warning⊆OFF)= worker3 Unity-run で empirical 確認(設計 §3)。
- ★step5 と違い 0x46/0x79 は A5=通常 break が EXE 忠実(idle_stop でない)ゆえ d2 型 exit gap なし=exit 忠実度 finding は本 step に無い(positive)★。

---

## 7. 総括
- ★APPROVE★: k1-k4 は EXE p1 RE + p2 設計に spec-compliant。A1-A5 1:1(A2/A3 昇順走査 order を実 paste で EXE 0x800f1590/0x800f1850 と照合)、OFF-inert(gate 冒頭+Len 不変+bit 同一)、0x47 非改変+隣接 decode 正当、発明ゼロ(activate/id 空間 gap)、k4 緑=e2 registry state のみ assert(e1/e3/e4 Unity-run 明示除外=偽green なし)。
- blocker=0。verification-dependency=e1-e4 worker3 Unity-run(設計既定)。
- 完成 claim=user live(ON 側可視挙動)まで凍結。
