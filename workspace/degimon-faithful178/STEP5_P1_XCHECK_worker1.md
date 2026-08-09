# STEP5 (③ladder 0x66) blind x-check — worker1

**date**: 2026-07-19 / worker1 / read-only(コード変更ゼロ)
**material**: EXE=slps_017_97.bin(RAM image、base 0x80090800)、tool=workspace/tools/exedis.py(capstone MIPS)
**anchors**: band dispatch=0x800F0780 / gp=0x80144E0C / Q3 target=0x8013DF70
**規律**: STEP A=他成果物 non-read で EXE 直読のみ独立解答→本節で固定。STEP B=固定後に worker2 doc を read し per-item CONFIRM/DIFF。

観測(disasm paste)/推論を区分。lui 符号拡張・+shift 事故は table anchor cross-check で防御。

---

## STEP A(blind、固定=以下確定。ここまで worker2 doc 未開封)

### 導出の土台: band dispatch(0x800F0780、観測)
```
800F0780  lw   $v1, -0x6cc8($gp)     ; v1 = script PC ptr (*[gp-0x6cc8]=*[0x8013E144])
800F0788  addiu $v0, $v1, 1
800F078C  sw   $v0, -0x6cc8($gp)     ; PC += 1 (opcode 消費)
800F0790  lbu  $v0, ($v1)            ; opcode byte
800F0798  andi $s0, $v0, 0xff
```
以降 band 化(sltiu 二重比較で range 判定→ band handler jal)。0x66 該当 band(観測):
```
800F0878  sltiu $at, $s0, 0x64 ; bnez 0x8a4   ; s0<0x64 → 除外
800F0884  sltiu $at, $s0, 0x7f ; beqz 0x8a4   ; s0>=0x7f → 除外
800F0890  move $a0, $s0
800F0894  jal  0x800ede88                       ; band[0x64,0x7f) handler、a0=opcode
```
→ 0x66∈[0x64,0x7f) ゆえ band handler=**0x800ede88**(a0=0x66)。

band handler 内 jump table(観測 0x800EDEA4-0x800EDED8):
```
800EDEAC  addi  $v0, $v0, -0x64          ; idx = opcode-0x64
800EDEB0  sltiu $at, $v0, 0x1b ; beqz 0x800ef318  ; idx>=0x1b(27) → error/epilogue
800EDEBC  lui   $v1, 0x8012
800EDEC0  addiu $v1, $v1, -0x4c60        ; table base = 0x80120000-0x4c60 = 0x8011B3A0
800EDEC4  sll   $v0, $v0, 2              ; idx*4
800EDEC8  addu  $v0, $v0, $v1
800EDECC  lw    $v0, ($v0)               ; handler = *[base + idx*4]
800EDED4  jr    $v0
```
table anchor cross-check(+shift 事故防御): table[0]=*[0x8011B3A0]=**0x800EDEDC**=jr 直後の inline code(0x64 handler)と一致 → base 正(shift ずれなし)。

table 実値(EXE 直読、little-endian):
```
op 0x64 idx0 @0x8011B3A0 -> 0x800EDEDC
op 0x65 idx1 @0x8011B3A4 -> 0x800EE6F4
op 0x66 idx2 @0x8011B3A8 -> 0x800EE72C   ★
op 0x67 idx3 @0x8011B3AC -> 0x800EE994
```

### Q1. 0x66 handler entry address = ★**0x800EE72C**★
導出: band dispatch(0x800F0780)→ 0x66∈[0x64,0x7f)→ jal 0x800ede88 → idx=0x66-0x64=2、range<0x1b OK → jump table base 0x8011B3A0(lui0x8012+(-0x4c60))、entry=base+2*4=0x8011B3A8 → *[0x8011B3A8]=0x800EE72C。anchor(idx0=0x800EDEDC=inline)で base 検算済。

### Q2. operand 長(総 opcode 長)= ★**2 byte**(opcode 1 + operand 1)★
- PC-advance operand reader は **0x800f0edc** のみ(観測: 0x800f0edc は `lw v0,-0x6cc8(gp); lbu v0,(v0); sb v0,(a0); PC+=1` = script byte 1 個読取+PC 前進)。
- 0x66 handler 内で 0x800f0edc call は **1 回のみ**(0x800EE730、a0=sp+0x43)→ operand 1 byte。総長=opcode(band で+1)+operand(1)=**2**。
- 非消費の確認: 0x800f0ac8(0x800EE75C/0x790 で call)は `lw base,-0x6cec(gp); lbu v0,0x159(base+id)` = data table lookup で **PC 非前進**(operand 非消費)。
- ★観測注記(honest)★: 0x800EE730 で読んだ operand byte は [sp+0x43] に格納後、0x800EE768 で 0x800f0ac8 結果に上書きされ値は破棄される(PC 前進のみ有効)。
- ★path 依存の注記(Q4 と連動)★: v0==0 exit path は 0x67 handler(0x800EE994)へ fall-through し、そこで 0x800f0ff0 が operand 2 byte を追加読取(PC 前進)。この path のみ PC 消費が増える。**0x66 単体(proper)の operand=1、総長 2** が nominal 解。

### Q3. 0x66 handler + 呼出先1段 は 0x8013DF70 を read/write するか = ★**NO(しない)**★
- 走査法(両面): 
  - gp 相対: 0x8013DF70 − gp(0x80144E0C) = **−0x6E9C** → `-0x6e9c($gp)` を全 disasm grep。
  - 絶対 lui: 0x8013DF70 は lui 0x8014 + offset −0x2090(=raw 0xDF70)でのみ到達(lui 0x8013+0xDF70 は sign-ext で 0x8012DF70=不可)。`0xdf70`/`-0x2090` offset を grep → **0 hit**。
- `-0x6e9c($gp)` 全 hit = 4 箇所、所属関数(直前 prologue 後方探索):
  - 0x800AE4E0(sb)/0x800AE4FC(lb) ∈ fn 0x800AE3DC
  - 0x800BC294(sb) ∈ fn 0x800BBEA8
  - 0x800F0214(lb) ∈ fn 0x800F0188
- 0x66 handler(0x800EE72C-0x800EE990)本体に −0x6e9c 参照なし(観測)。
- handler 直接 callee(jal target)14 個: 0x800913c0 / 0x800aeca8 / 0x800bd820 / 0x800cfec4 / 0x800f0988 / 0x800f0a4c / 0x800f0ac8 / 0x800f0c74 / 0x800f0cd0 / 0x800f0d58 / 0x800f0edc / 0x800f2b78 / 0x800f50a8 / 0x800fa7a8。
- 4 hit の所属関数(0x800AE3DC / 0x800BBEA8 / 0x800F0188)は **どれも callee list に非該当** → handler+1段 callee は 0x8013DF70 非アクセス。
- ★scope 注記★: Q3 spec どおり 1 段 callee のみ検証。2 段以深は未走査(scope 外、honest gap)。

### Q4. exit path 構造(全出口 + 隣接 fall-through)
shared epilogue=**0x800ef318**(観測: `...jal 0x800913c0; lw ra,0x28(sp); lw s3/s2/s1/s0; addiu sp,0x48; jr ra` = band handler frame 復元→caller 復帰)。
出口列挙:
- **E1**: 0x800EE888 `b 0x800ef318`。path=s2==−1(0x800EE820 bne s2,−1 不成立)→ 0x828-0x884 で `sw v0,-0x6cc8(gp)`(PC を 0x800f0a4c 算出値へ redirect=goto/abort)→ epilogue。
- **E2**: 0x800EE940 `b 0x800ef318`。path=0x800f0c74 が v0!=0(0x800EE920 beqz 不成立)→ 0x928-0x938(jal 0x800bd820 / 0x800f2b78)→ epilogue。
- **E3(★隣接 handler への構造的 fall-through=有り★)**: v0==0 path(0x800EE948-0x800EE990)は終端 branch/return **なし**。0x800EE98C `jal 0x800913c0`/0x990 nop の後、そのまま **0x800EE994 へ落下**。0x800EE994 は **table idx3=0x67 handler entry**(観測: 0x800EE9A0 `v0=0x67; sb v0,-0x6cbc(gp)`=opcode marker を 0x67 に書換、0x800f0ff0 で operand 2 byte 読取、最終 `b 0x800ef318`)。
  → 0x66 の v0==0 path は 0x67 handler body を実行して epilogue へ至る = **隣接 0x67 への構造 fall-through 実在**。
- 全出口は最終的に epilogue 0x800ef318 経由(E1/E2 は直接 b、E3 は 0x67 body 経由)。handler 自身に独立 jr ra なし(band handler frame を共有、epilogue で一括復元)。

---

## STEP B(unblind、STEP A 固定後に worker2 doc read → per-item 裁定)

対象=`/home/ken/Documents/Claude-Code-Communication/workspace/degimon-faithful178/STEP5_P1_RE_worker2.md`
(初回 find が game-repo 側 root 相対で外した。boss1 提示の絶対 path で read)。

### per-item CONFIRM/DIFF(Q1-Q4 本体=主)

| Q | worker2 | worker1(blind) | 裁定 |
|---|---------|----------------|------|
| Q1 | 0x800EE72C(table 0x8011B3A0[idx2]、anchor idx0=0x800EDEDC) | 0x800EE72C(同) | ★**CONFIRM**★(値・導出・anchor 検算 完全一致) |
| Q2 | operand 1 byte / 総長 2(reader 0x800f0edc、0x800f0ac8=非消費、0x800f0a4c=PC seek) | operand 1 / 総長 2(同 reader 同定) | ★**CONFIRM**★(完全一致) |
| Q3 | NO(gp-rel -0x6e9c + 絶対 lui 両走査 0 件、handler+14 callee、scope=1段) | NO(同手法、同 scope、4 hit は無関係 fn) | ★**CONFIRM**★(結論・手法・scope 注記 一致) |
| Q4 | 2×`b 0x800ef318` + 0x800ee948→0x800EE994 fall-through(§7-4) | E1/E2 epilogue + E3 0x800EE990→0x800EE994 fall-through | ★**CONFIRM**★(出口構造・隣接 fall-through 一致) |

**DIFF = ゼロ**(Q1-Q4 全 CONFIRM)。

### 相互 enrichment(矛盾でなく補完)
- **Q4 gate 意味論(worker2 §8-1 addendum、私の blind scope 外)を独立 disasm で裏取り**:
  私の E3 は「v0==0(0x800f0c74 の戻り)で fall-through」まで(0x800f0c74 の中身は未同定)。worker2 §8-1=「0x800f0c74=event-flag bit test、gate=flag#1 clear」。
  → 独立検証(私が今 disasm):
  ```
  800F0C90  jal 0x800f191c            ; (id=1, &ptr=sp+0x18, &mask=sp+0x1f)
  800F0CA0  lbu $v0, ($v0)            ; *ptr (flag byte)
  800F0CB4  and $v0, $s0, $v0         ; flag & mask
  800F0CB8  sltu $v0, $zero, $v0      ; return (flag&mask)!=0
  800F1940  andi $v0, $v1, 7          ; bit = id & 7
  800F1968  sra  $t9, $v0, 3          ; byteidx = id >> 3   (base=mem[gp-0x6cec])
  ```
  = ★worker2 §8-1 を CONFIRM★: 0x800f0c74 は bit-flag test。よって私の E3 fall-through gate = **event-flag#1 clear**(set=0x800bd820+0x800f2b78+epilogue / clear=0x800ee948→0x67 fall-through)。私の Q4「fall-through 実在」に gate 条件を付加。
- **Q2 の私の path 注記(v0==0 で 0x67 側が +2 byte)**は worker2 §7-4/§8 の fall-through 記述と整合。0x66 単体 nominal=2 は一致、path 依存の追加消費は Q4 の fall-through に帰属(Q2 nominal 判定に影響なし)。
- worker2 §5-4=07-09 台帳『0x800EE948=0x66 entry』は STALE(内部 block 誤ラベル)と裁定 → 私の「entry=0x800EE72C、0x800EE948 は v0==0 の内部分岐先」と整合。
- worker2 §6=DF70 slot は 0x8013DF70(task の 0x8016DF70 は boss1 誤展開、gp±0x8000 range 外で構造的アクセス不能)。私の Q3 は task 提示の 0x8013DF70 で走査済ゆえ整合。writer 0x800AE4E0(=私の 4 hit の 1 つ、fn 0x800AE3DC)も一致。

### 総括
★worker2 の (p1) RE は Q1-Q4 本体で worker1 blind と完全一致(DIFF ゼロ)、独立 2 経路で cross-check 成立★。
addendum(§8-1 gate=flag#1 / §8-2 StartScript CONFIRM 昇格)は私の blind scope 外だが、§8-1(Q4 gate)は独立 disasm で CONFIRM した。
残 honest gap(両者一致): 1段 callee scope(2段以深未測、promote 禁止)/ flag#1 の event 意味論未同定 / DF70 reader census(§6 open item、pointer-base 盲点ゆえ gp-rel -0x6e9c 全域走査は別途要)。
