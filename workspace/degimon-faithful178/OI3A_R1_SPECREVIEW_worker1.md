# OI-3a R1 spec 照合 review — worker1

**date**: 2026-07-19 / worker1 / ★read-only(f1b 非編集)★
**対象**: f1b trackF1B/event-oracle — r1=9e15368 / r2=3dc46d1 / r3=6c2f1a9 / r4=7d3bc55
**設計正本**: OI3A_Q2_DESIGN(§1 対応表 / §2 R1 / §4 prereg g1(i)-(iii))
**RE正本**: OI3_SELECTOR_RE_worker1.md §9-5c(私の全分岐 disasm)+ boss1 0x80105be4 直読
**手法**: 全 path trace(1 path OK 判定禁止)。DIFF=実 code paste。

---

## 判定: ★APPROVE(条件付き)★ — 全観点 PASS、blocker 0、★verbatim-fidelity finding 1件(two-slot collapse=要確認/文書化)★+ verification-dependency(g1/g2/g3 Unity-run)

r1-r4 は §1 対応表・供給鎖・resolver・OFF-inert・switcher で spec-compliant、byte-table 45 entry bit 一致。★1件、EXE の 2-slot 構造(0x73 check=現slot / range=E104-slot)を C# が E104-slot 1本に collapse している=verbatim 逸脱(R1 state-machine scope では非 hard-blocker だが要確認)★。

---

## 観点1: §1 verbatim 性(6条件順序/境界 + byte-table bit 一致)

### byte-table(SceneVariantTable、GameState.cs:506-510)★bit 一致確認★
私の §9-5c disasm 実読(0x801389E8、45 entry)と 1:1 突合:
```
form 0x43-0x51: 02 02 02 02 02 01 02 02 02 01 02 02 02 02 02  ← C#/§9-5c 一致(01@0x48,0x4C)
form 0x52-0x60: 02 02 02 01 02 02 01 01 01 01 01 02 02 02 02  ← 一致(01@0x55,0x58-0x5C)
form 0x61-0x6F: 02 02 02 01 02 02 02 01 01 01 02 01 02 02 02  ← 一致(01@0x64,0x68-0x6A,0x6C)
```
→ ★45 entry 全 bit 一致(例外 01=13件: form 0x48/4C/55/58-5C/64/68-6A/6C)★=verbatim。

### 6条件分岐順序/境界(SelectSceneVariant、GameState.cs:524-536)
| # | C# | EXE disasm | 裁定 |
|---|---|---|---|
| 1 | `if form==0x73 return 3` | 0x80105C4C(top、slot range 前) | ★順序一致★ |
| 2 | `if slot∈[2,0xa) & flag==1 return 0` | 0x80105C9C | ✓ |
| 3 | `form<0x43 or form>=0x70 return 1` | 0x80105D6C(境界 0x43/0x70) | ✓ |
| 4 | `return SceneVariantTable[form-0x43]` | 0x80105D44 | ✓ |
| 5/6 | slot 範囲外: flag==1→0 / else→1 | 0x80105D94/DAC | ✓ |

→ 分岐順序・境界(0x43/0x70/[2,0xa)/flag/0x73)は EXE と一致。

### ★finding-1: two-slot 構造の collapse(verbatim 逸脱)★
- ★EXE 0x80105be4★: 0x73 check は **現 slot**(`struct[gp-0x6dec]+0x66d` の descriptor first word)、range は **E104-slot**(a0)= **2つの別 slot**。
- ★C#★: `SelectSceneVariant(slot, form, flag)` の form = ResolveSlotForm(**E104-slot**)。0x73 check(526)も range(531)も **同一 E104-slot の form** を使用=★現 slot(struct+0x66d)の form を読まず、E104-slot に collapse★。
- ★影響★: 現 slot form==0x73 かつ E104-slot(partner)form!=0x73 の時、EXE→variant 3 / C#→range-variant=divergence。
- ★verbatim IFF 現 slot(struct+0x66d)==E104-slot(=2)が 0x66 path で成立★(未確認=struct+0x66d の populate RE or v2 oracle で要確定)。設計 §1 が『現 slot form==0x73』と明記(≠E104-slot)ゆえ、C# は設計 §1 からも逸脱。
- ★severity★: R1=state-machine model(v2 oracle=fidelity gate)+ 設計 §0 が両 check を『slot N(partner)』と frame ゆえ **hard-blocker でない**。但し ★(a)現 slot==E104 の確認 or (b)現 slot 0x73 check を別 slot form で model、のいずれかを R1 land 前 or v2 oracle で要決着★。現 oracle(§4 g1、form12→variant1 のみ 10 event)は 0x73 case 未観測=本 divergence を現状 catch できない=honest gap。

---

## 観点2: 供給鎖(E104=DF70 転写、直接 set shortcut 不在)

- 位置(DialogueRuntime.cs:510): ★`Begin(entry); _pc=off; ...; if(_sceneWire) RawE104=RawDF70`★=PlaySection 開始点(section-init)。EXE 0x800F0188(section-init が DF70→E104 転写、10 caller)の位置に対応。✓
- ★直接 set shortcut 不在★: `RawE104 = RawDF70`(=const 2 経由)であって `RawE104 = 2` の発明的直接 set でない=DF70→E104 転写機構を model(gate④ 教訓遵守)。✓
- ★RawDF70=const 2(GameState.cs:501、field-init)★: OI-1 実測(writer 0x800AE4E0 常時 2、130/130)に接地した const-model。★注記: 動的 field-write(field-side 0x800AE4E0)の model でなく const 固定=OI-1 の 130/130 一様性ゆえ妥当だが、field-side が 2 以外を書く path があれば乖離(OI-1 で 130/130=一様確認済ゆえ現状問題なし)★。

## 観点3: resolver(slot→form 3分岐 + gap)

- ResolveSlotForm(GameState.cs:513-518): slot1→CareFormIndexGlobal(B084)/slot2→DigimonId(B104)/他→-1(gap)。✓ 3分岐 + gap。
- caller(DialogueRuntime.cs:1157): `if(form<0) [SCENE-WIRE] gap loud log→scene 切替せず / else SelectSceneVariant`。✓ gap は loud log + 非切替(発明せず)。

## 観点4: OFF-inert(WIRE=0)

- ★E104 非改変★: RawE104=RawDF70 は `if(_sceneWire)`(510)gated。WIRE=0→RawE104 未 populate(0)維持=従来 stub と同一。✓
- ★B4 stub=c3 原文維持★: WIRE=0 の else 枝(1171-1174)= c3 原文の `[SCENE-DRIVER][0x66] B4 selector STUB(宣言gap)` log。✓ 文言不変。
- ★[SCENE-SWITCH] 0件★: 全 [SCENE-SWITCH] log(1164/1166/1168)は `if(_sceneWire)`(1152)内。WIRE=0→0件。grep 全列挙=1164/1166/1168 のみ、全 WIRE-gated。✓
- ★WIRE 単独 ON=loud no-op★: DEGIMON_SCENE_WIRE=1 & DRIVER≠1 → (455-456)loud warning `[SCENE-WIRE] ...B4 実配線 no-op`。かつ 0x66 case は `if(!_sceneDriver) break`(step5 c1、WIRE block より前)ゆえ WIRE block 非到達=実 no-op。✓ 実配線確認。

## 観点5: switcher same-scene no-op + r4 harness

- ★no-op 条件★(SceneSwitch、GameState.cs:543-547): `record==RawE06A && variant==RawE06C → 1(no-op)`=★record AND variant 両一致★。EXE 0x800cfdf0: `s0==[gp-0x6da2] && s1==[gp-0x6da0]`(cur_record + cur_variant 両一致)= ★同型★。✓
- range check: `record<=0 || record>=0x22 → 0(invalid)`=EXE `blez s0`/`slti 0x22`。✓
- switched: RawE06A/E06C 更新(teardown/CD load/finalize=R2 gap、log のみ)。✓
- ★r4 harness(scene_wire_verify.cs)★: 6条件 variant(byte-table 例外 0x48/0x4C/0x6C 含む)+ switcher(invalid/no-op/switched + 現 scene 更新)+ resolver(slot1/2/3)を leaf 実 assert。★g1(EXE oracle diff)/g2(OFF bit)/g3(非退行)は §Unity-run + worker3 EXE probe へ明示委譲=偽green 無し★。★観点1 finding(two-slot)は harness も E104-slot 1本前提ゆえ未 cover(harness 限界=同 finding)★。

---

## 6. verification-dependency + finding まとめ
- ★finding-1(two-slot collapse)★: R1 non-hard-blocker だが要決着=(a)struct+0x66d==E104(0x66 path)確認 or (b)現 slot 0x73 check の別 model。v2 oracle が 0x73-form case を採取できれば behavioral 確定(現 oracle は form12 のみ=未 cover)。
- g1(v2 EXE oracle diff、per-event rule 整合)/g2(OFF bit 不変)/g3(非退行)= worker3 Unity-run + EXE probe(設計 §4)。
- 完成 claim=v4(user live、R2 後)まで凍結。R1=state+log 忠実まで。

## 6bis. r5 差分 review(finding-1 解消確認、2026-07-19、f1b HEAD=04e5d96)★finding-1 RESOLVED★

boss1 裁定 (b) 構造分離の r5(04e5d96)を差分 review。

| 確認点 | 結果 | 根拠 |
|---|---|---|
| (1)0x73 check=curSlotForm / range=eForm 分離が EXE 0x80105be4 と 1:1 | ★PASS★ | `SelectSceneVariant(slot, eForm, curSlotForm, flag)`: `if(curSlotForm==0x73)return 3`(現 slot、0x80105C40 struct+0x66d 対応)/ `slot∈[2,0xa)` range は eForm(E104-slot、a0 対応)。★2 slot 独立読取=collapse 解消★ |
| (2)RawCurSlot=宣言gap(default 0)扱い + log 可視化 | ★PASS★ | RawCurSlot 新設(GameState、default 0、populate=gap writer 未RE=OI-9)。DialogueRuntime B4: `curSlot=RawCurSlot; curSlotForm=ResolveSlotForm(curSlot)`。ResolveSlotForm(0)=-1(gap)ゆえ populate まで 0x73 special-case は非 fire=honest。★`[SCENE-WIRE] two-slot: E104-slot=.. eForm=.. curSlot(0x66d)=.. curForm=..(populate=gap default0=−1)` で両 slot 実値 loud 可視化★ |
| (3)divergence 2-case assert 正当(特に逆方向) | ★PASS★ | harness: 順方向 `SelectSceneVariant(2,0x50,0x73,0)=3`(curForm=0x73&eForm≠0x73→3=0x73 は curSlot)/ ★逆方向 `SelectSceneVariant(2,0x73,0x50,0)=1`(eForm=0x73&curForm≠0x73→range: eForm 0x73>=0x70→1、**NOT 3**)★=collapse 修正の決定的 assert(eForm=0x73 が誤って 3 を返さないことを固定)。25/25 GREEN |
| (4)OFF-inert 不変 | ★PASS★ | SelectSceneVariant caller=DialogueRuntime:1166 のみ(WIRE gate 内)。RawCurSlot 参照=1158(WIRE 内)のみ。signature 変更は harness(leaf)+WIRE-gated caller のみ=OFF path 不変。byte-table/6条件境界/switcher/供給鎖=r1-r4 の PASS 維持(r5 は 0x73 check の slot 源分離のみ) |

★finding-1 = RESOLVED★: two-slot collapse は curSlotForm(現 slot)/eForm(E104-slot)の構造分離で解消、設計 §1『現 slot form==0x73』と整合回復。等価仮定(現 slot==E104)は先取りせず RawCurSlot gap model + OI-9(current-slot writer RE)へ起票=gate④ 教訓遵守。残 DIFF=0。

## 7. 総括
- ★APPROVE(条件付き)★: byte-table bit 一致・6条件順序・供給鎖(DF70→E104 転写 model、直接 set 無)・resolver・OFF-inert(E104/stub/[SCENE-SWITCH]/WIRE 単独 no-op)・switcher no-op(record&variant 両一致)・r4 harness(網羅 + scope 明示)= 全 spec-compliant。
- ★finding-1=two-slot collapse(0x73 check=E104-slot vs EXE 現 slot)★: verbatim 逸脱、R1 scope では非 hard-blocker だが ★land 前 or v2 oracle で現 slot==E104 の確認 or 別 model 化を要決着(発明ゼロ厳密化)★。
- blocker=0、finding=1、verification-dependency=g1/g2/g3 Unity-run。
