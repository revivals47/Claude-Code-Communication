# OI-2: opcode 0x67 全長RE(worker1)

**date**: 2026-07-19 / worker1 / ★read-only RE(コード変更ゼロ)★
**material**: EXE=slps_017_97.bin(base 0x80090800)、tool=exedis.py。DG.SCN=unity/…/dialogue/DG.SCN。gp=0x80144E0C。
**手法**: handler(0x800EE994、step5 二次表 idx3 確認済)+ 呼出先1段 全長RE → premise-check(両説とも未検証扱い、H4 開放、EXE直読=oracle)。
**規律**: 観測(disasm/raw byte paste)/推論 区分。promote 禁止。★静的 disasm と動的(OPTRACE/stream)が乖離する箇所は両方 honest 提示し、片方に強制収束させない(measure-first)★。

---

## 0. 結論(単一表)

| 項目 | 判定 | 次元 |
|---|---|---|
| 0x67 handler entry | ★0x800EE994★(band 0x800ede88[0x64,0x7f)→table 0x8011B3A0 idx3) | 観測(step5 anchor 済 table) |
| handler 範囲 | 0x800EE994..0x800EE9F8(`b 0x800ef318`、0x800EE9FC=次 handler 0x68) | 観測 |
| exit | b epilogue 0x800ef318(=jr ra で dispatch 復帰、idle_stop でない=0x66 c5 と別) | 観測 |
| 07-09『WAIT-N-FRAMES(u16 countdown)』 | ★REFUTE★(countdown/wait loop 皆無、frame 待ち機構なし) | 観測 |
| 07-09後段『u16 set + YIELD』 | ★PARTIAL-CONFIRM★(u16 read→gp slot=一致 / YIELD=b epilogue の dispatch 復帰意味では一致。但し 2nd reader+BIOS call を含み『u16 set』は不完全) | 観測+推論 |
| ★Len 静的/動的 乖離★ | ★未解決 honest gap★: 静的 handler=operand **6 byte**(reader 2個)/ stream+OPTRACE=**4 byte**(Len[0x67]=4)。要 dynamic OPTRACE | 観測(両次元)+未解決 |
| 0x66 clear 枝 fall-through 実体 | 0x800EE994(本 handler)へ流入=u16 read+marker=0x67+条件 store。step5 Option S gap の実体 | 観測 |

---

## 1. handler 0x800EE994 全長disasm(観測)

```
800EE994  addiu $a0, $gp, -0x6ca8    ; a0 = &[0x8013E164]
800EE998  jal 0x800f0e6c             ; ★reader#1(§2-1): PC+1 skip + u16→[gp-0x6ca8](PC+2)= 計 3 byte★
800EE9A0  addiu $v0, $zero, 0x67
800EE9A4  sb $v0, -0x6cbc($gp)       ; opcode marker [0x8013E150] = 0x67
800EE9A8  lui/addiu $a0, 0x80164068 ; 800EE9B0 a1=2
800EE9B4  jal 0x800913c0             ; ★BIOS A0 thunk(§2-3、yield でない)★
800EE9BC  addiu $a0, $sp, 0x43
800EE9C0  addiu $a1, $sp, 0x44
800EE9C4  jal 0x800f0ff0             ; ★reader#2(§2-2): PC+1 skip + 2×1byte→sp(PC+2)= 計 3 byte★
800EE9CC  lbu $v0, 0x43($sp) ; 800EE9D4 sb $v0,-0x6cbf($gp)   ; [0x8013E14D]=[sp+0x43]
800EE9D8  lbu $v0, 0x43($sp) ; 800EE9E0 bne $v0, 2, 0x800ef318 ; [sp+0x43]!=2 → exit
800EE9E8  lbu $v0, 0x44($sp) ; 800EE9F0 sb $v0,-0x6c94($gp)   ; ([sp+0x43]==2 のみ)[0x8013E178]=[sp+0x44]
800EE9F4  b 0x800ef318              ; exit epilogue(dispatch 復帰)
```
- ★countdown/frame-wait 機構は皆無★=WAIT-N-FRAMES 反証。
- reader#1/#2 の間に条件分岐なし(0x800913c0 は jal だが §2-3 で BIOS thunk=通常 return 前提)→ 静的には reader#1+#2 両方実行(operand 6 byte)。

## 2. 呼出先1段 全長RE(観測)

### 2-1. 0x800f0e6c = 1byte skip + u16 read(PC-advance)
```
800F0E80 PC+=1(skip 1 byte) ; 800F0E8C jal 0x800f1038(a0)
0x800f1038: 800F104C lhu [PC] ; 800F1054 sh→[a0] ; 800F1060 PC+=2
```
→ ★PC 前進=3 byte(1 skip + u16)、u16 を [gp-0x6ca8] へ格納★。

### 2-2. 0x800f0ff0 = 1byte skip + 2×1byte read(PC-advance)
```
800F1008 PC+=1 ; 800F1014 jal 0x800f0edc(a0=sp+0x43、+1) ; 800F1020 jal 0x800f0edc(a1=sp+0x44、+1)
```
→ ★PC 前進=3 byte(1 skip + 2 byte)★。0x800f0edc=既知 1byte reader(lbu[PC];PC+1)。

### 2-3. 0x800913c0 = BIOS A0 thunk(yield でない)
`addiu t2,0xa0; jr t2;(delay addiu t1,0x14)` = 物理 0xa0(PSX A0 BIOS vector)へ t1=関数番号で jump。utility call(a0=0x80164068,a1=2)。★yield/wait でない=reader#2 を gate しない(通常 return)★。

---

## 3. ★Len 静的 vs 動的 乖離(未解決 honest gap、measure-first)★

- ★静的(handler disasm)★: reader#1(3B)+ reader#2(3B)= operand **6 byte** → Len 7 相当。
- ★動的/stream★: **Len[0x67]=4**(op+3 operand)。根拠2つ:
  1. worker2 OPTRACE(runtime PC trace、旧 7→4 訂正、25ed350):0x67@0x12ca の次 op が +4。
  2. DG.SCN raw byte(本 RE 実測):
     - (129,6)@0x1A8: `67 00 05 00 | 1b fd | 1a 00 | 81 75…` → Len4 で次 `1b`(SET_SPEAKER)clean。
     - (170,51)@0x18: `67 00 14 00 | 4e 06 0b fe 04 fe 00 00 | …` → ★Len4 で次が clean 0x4E(Len8)。Len7 だと section 中に spurious `fe`(SECTION_RETURN)=誤終端★=Len4 を強く支持。
- ★乖離★: 静的 handler が operand 6 byte 消費するのに、runtime/stream は 4 byte。★reader#2(0x800f0ff0)が runtime で PC を伸ばしていない(=標準 0x67 で不実行 or 非advance)公算だが、静的には無条件 call ゆえ理由が説明できない★。
- ★判定: 動的(OPTRACE+stream 二証)を decode の authority とし Len[0x67]=4 は維持妥当。但し静的 2nd reader の不発火機構は未解明=★dynamic OPTRACE(0x800EE994 実行時の PC 追跡 + reader#1/#2 各到達確認)で要決着★。片方へ強制収束させない(promote 禁止)。★
- ★候補仮説(H4、未検証)★: (a) 0x800913c0 の BIOS call が非通常 return(longjmp 等)で reader#2 未到達 / (b) reader#2 は 0x66 fall-through 文脈専用 / (c) 標準 0x67 と fall-through で挙動差。いずれも dynamic 測定必須。

---

## 4. premise-check(H4 開放、EXE直読 oracle)

| 説 | 出所 | 裁定 | 根拠 |
|---|---|---|---|
| 0x67=WAIT-N-FRAMES(u16 countdown) | 07-09 worker1(訂正 25ed350) | ★REFUTE★ | handler に countdown/frame-wait loop 皆無。u16 は [gp-0x6ca8] へ set するのみ(消費でなく格納) |
| 0x67=u16 set + YIELD | 07-09後段 worker2 | ★PARTIAL-CONFIRM★ | u16 read→[gp-0x6ca8]=一致(reader#1)。YIELD=b epilogue の dispatch 復帰意味で一致(0x46/0x79 型、frame-wait でない)。★但し reader#2(条件 2byte)+ BIOS call + marker set を含み『u16 set』単独では不完全★ |

★H4 所見★: 0x67 = 『u16(reader#1)を gp slot へ set + textbox/state 系 BIOS call + 条件付き 2byte store + dispatch 復帰』。両説とも部分的(WAIT は誤、u16-set は核だが全容でない)。semantic(gp-0x6ca8/gp-0x6c94 slot の意味、0x800913c0 BIOS 関数)は 🅰 保留。

---

## 5. 0x66 clear 枝 fall-through の実体(step5 Option S gap、観測)

- step5: 0x66 clear 枝(flag#1 clear)が 0x800EE994 へ構造 fall-through。
- 流入時に実行される 0x67 body = 本 handler: reader#1(u16→[gp-0x6ca8])+ marker=0x67 上書き + 0x800913c0 + reader#2 条件 store + b epilogue。
- ★step5 の『0x67-body 実行=宣言gap』の実体 = 上記(u16 set + BIOS call + 条件 store)★。step5 c3/c5 は 0x66 で idle_stop 化(clear 枝も 0x67 body を実行せず)ゆえ、この fall-through body は remake で未実装(Option S gap のまま=設計どおり)。0x67 を ladder 次段で実装する際に本 body が対象。

---

## 6. 未確定残(promote 禁止・honest gap)
- ★Len 静的6 vs 動的4 の乖離(§3)= 最重要未解決。dynamic OPTRACE で reader#2 到達可否を要測定★。
- 0x800913c0 BIOS A0(t1=0x14)関数の実体(通常 return か)= §3 候補(a)の裏取り。
- gp slot 0x8013E164(-0x6ca8、reader#1 u16 dest)/ 0x8013E178(-0x6c94)/ 0x8013E14D(-0x6cbf)の semantic = 2段以深 + 消費側 RE。
- 0x67 の C# Len=4 は動的 authority ゆえ現状維持妥当だが、handler 実挙動(reader#2)の忠実実装は §3 決着後(ladder 次段 0x67 実装時)。
