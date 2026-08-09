# OI-1: DF70(0x8013DF70)reader census — worker1

**date**: 2026-07-19 / worker1 / ★read-only RE(コード変更ゼロ)★
**起票元**: STEP5_P1(OI-1)。0x66=DF70 直接消費は REFUTE 済(Q3、handler+1段に非アクセス)。本 census=真の reader 全列挙。
**target**: 0x8013DF70 = gp-rel **−0x6E9C**(gp=0x80144E0C)。field-side writer 0x800AE4E0 が byte 書込(census 実測値=2、130/130)。
**手法**: (i) gp-rel −0x6e9c 全 load 型走査(lw/lb/lbu/lh/lhu/lwl/lwr)+ (ii) 絶対 lui 0x8014+(−0x2090)合成 + (iii) pointer-base ori/addiu 0xdf70 best-effort。EXE 全 disasm(177,664 行)grep。

---

## 0. 結論(単一)

- ★DF70 の直接アクセス = **4 件のみ**(全 disasm gp-rel −0x6e9c 全型走査)★: reader(lb)2 + writer(sb)2。
- ★reader 2 件★:
  1. **0x800AE4FC**(fn 0x800AE3DC)= DF70 を **struct-array index**(base 0x8016B104、stride 104、field +0x65)に使用。
  2. **0x800F0214**(fn 0x800F0188)= DF70 を **E104(0x8013E104=scene selector arg)へ copy**(writer 0x800F021C)。→ ★DF70 は section-init で E104 に載り、間接的に 0x66 B4 scene selector へ供給★(0x66 直接非アクセス=Q3 REFUTE と矛盾せず、供給は section-init 経由)。
- ★絶対 lui 合成 = 0 件 / pointer-base ori 構築 = 0 件★。
- ★未カバー面(開示)★: base-register-from-memory 経由の間接 read(struct field が DF70 の絶対 address を保持し、その reg で load)は静的 offset 走査で検出不能(ovldis pointer-base 盲点)。best-effort 2 経路(絶対 lui/ori)で非検出=直接構築は無い、が間接は残存 gap。

---

## 1. 直接アクセス全列挙(gp-rel −0x6e9c、実 paste)

```
30521:800AE4E0  sb $v0, -0x6e9c($gp)   ; writer#1
30528:800AE4FC  lb $v0, -0x6e9c($gp)   ; reader#1
44710:800BC294  sb $v0, -0x6e9c($gp)   ; writer#2
97926:800F0214  lb $v0, -0x6e9c($gp)   ; reader#2
```
load 型は 2 件とも `lb`(signed byte load)= writer の `sb`(store byte)と型整合(DF70=符号付き byte slot)。

---

## 2. reader 各文脈(1 行 + 機構)

### reader#1: 0x800AE4FC / fn 0x800AE3DC 【観測】
- ★1 行★: DF70 を struct-array index に使い entity/scene param を引く(同 fn が DF70 を書きもする scene 設定系)。
- 機構(実 paste):
  ```
  800AE4FC  lb   $v0, -0x6e9c($gp)      ; v0 = DF70
  800AE504  addi $v1, $v0, -2           ; v1 = DF70 - 2
  800AE508-518 sll/add 連鎖             ; index = v1 * 104(=0x68 stride)
  800AE51C  lui  $v0, 0x8017
  800AE520  addiu $v0, $v0, -0x4efc     ; table base = 0x8016B104
  800AE524  addu $v0, $v0, (v1*104)
  800AE528  lbu  $a1, 0x65($v0)         ; struct[DF70-2].field(+0x65) を読む
  800AE534  jal  0x800f0188            ; → reader#2 の fn を call(同 chain)
  ```
- ∴ DF70 = 0x8016B104 起点 stride104 struct 配列の **index**(−2 bias)。同 fn 0x800AE3DC は writer#1(0x800AE4E0)も持つ=DF70 を set してから自身/下流で index に使う scene/entity setup。

### reader#2: 0x800F0214 / fn 0x800F0188 【観測】★核心★
- ★1 行★: section/entry init で DF70 を **E104(scene selector arg)へ転写**=DF70→scene 機構の橋渡し。
- 機構(実 paste):
  ```
  800F01F4-210  script-VM PC 系 slot 群を 0/1 init(-0x6cbc/-0x6cbb/-0x6cb8/-0x6cb4/-0x6cb0/-0x6d10)
  800F0214  lb $v0, -0x6e9c($gp)       ; v0 = DF70
  800F021C  sh $v0, -0x6d08($gp)       ; ★E104(0x8013E104)= DF70★(writer 0x800F021C)
  ```
- ★E104 = 0x66(SCENE_DRIVER)B4 の scene selector arg(0x800aeca8 の a0、STEP5 §2-2)★。fn 0x800F0188 は **10 caller**(0x800AB32C/0x800AB3F4/0x800AE534/0x800AE5E4/0x800AE6C8/0x800AE720/0x800BC2C8/0x800CD39C/0x800F0168/0x800FF0E8)= section-load/scene 遷移各所から呼ばれる init。
- ∴ ★DF70 は「誰が読むか」= section-init(fn 0x800F0188)が読んで E104 に載せ、以降 0x66 の scene selector がその E104 を消費★。0x66 が DF70 を **直接** 読まない(Q3 REFUTE)のは正しく、供給は **section-init 経由の間接**。step5 census の『DF70 消費』は挙動として E104 経由で scene に効くが、機構 label(warp/直接消費)は誤=本 census が真経路(DF70→E104→scene selector)を確定。

---

## 3. writer(参考、census の write 側)

```
800AE4E0  sb (sra(s1<<24)>>24), -0x6e9c($gp)   ; writer#1 fn 0x800AE3DC(s1 の符号 byte)
800BC294  sb (sra(s2<<24)>>24), -0x6e9c($gp)   ; writer#2 fn 0x800BBEA8(s2 の符号 byte、直後 (s2-2)*104 index=reader#1 同型)
```
- 両 writer とも書込後 (value−2)*104 で同 struct 配列を引く=DF70 は scene/entity struct の選択子。census 実測で値=2(130/130)だが code 上は s1/s2 byte(2 は corpus 頻値)。

---

## 4. 未カバー面 / blindspot(開示、打切)

- ★絶対 lui 0x8014+(−0x2090)=0x8013DF70 合成 = 0 件★(全 disasm、offset −0x2090/0xdf70 の load/store なし)。
- ★pointer-base ori/addiu 0xdf70 構築 = 0 件★(lui+ori で 0x8013DF70 の pointer を作る箇所なし)。
- ★残 blindspot(ovldis pointer-base、memory reference_ovldis_xref_absolute_blindspot)★: struct field 等が 0x8013DF70 の **絶対 address を値として保持**し、その reg 経由で load する間接 reader は静的 offset 走査で **検出不能**。gp-rel が主 access 様式(gp 域内 slot)ゆえ間接 pointer 化の蓋然性は低いが、ゼロ証明は不可=honest gap。
- ★打切★: 直接(gp-rel)+ 絶対 lui + ori 構築の 3 経路を走査(2-3 反復規範内)。間接 pointer-base は best-effort 非検出で打切+開示。

---

## 5. OI-1 到達点
- ★DF70 reader = 直接 2 件確定★: fn 0x800AE3DC(struct index)+ fn 0x800F0188(→E104→scene selector、10 caller の section-init)。
- ★step5 との整合★: 0x66 直接非消費(Q3 REFUTE)は正。DF70 は section-init で E104 に転写され、0x66 B4 scene selector が間接消費 = 『DF70 が scene に効く』挙動観測は真、機構は warp でなく scene-selector-arg 供給。
- ★残 open(別 arc)★: (a) fn 0x800AE3DC/0x800BBEA8 の struct 配列(0x8016B104 stride104)の意味論(scene/entity param table)、(b) DF70 の write 値決定ロジック(s1/s2 の由来)、(c) pointer-base 間接 reader(blindspot、gp 域ゆえ低蓋然)。
