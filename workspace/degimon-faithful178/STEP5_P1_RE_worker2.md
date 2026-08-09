# STEP5 (p1) opcode 0x66 全長RE — worker2

2026-07-19。**read-only RE(コード変更ゼロ)**。EXE=SLPS_017.97(RAM image slps_017_97.bin、base 0x80090800)、
tool=exedis.py(capstone 5.0.7)。gp=**0x80144E0C**(既存3系統収束値、本doc内でmem[0x80119E68]直読=0x80144E0C 再確認済)。
観測(disasm paste)/推論/仮定を区別。lui符号拡張・ovldis pointer-base盲点を明示処理。

---

## 0. 結論サマリ(単一表)

| 項目 | 判定 | 次元/scope |
|---|---|---|
| 0x66 handler entry | ★0x800EE72C★(band[0x64,0x7f)→jump table 0x8011B3A0[idx2]) | 観測(直読+cross-check) |
| operand 長 | ★1 byte(opcode総長2、Len[0x66]=2)★ | 観測(0x800f0edc=PC前進fetch) |
| 07-09『scene selector 0x800aeca8』 | ★CONFIRM★(handler直接jal) | 観測 |
| 07-09『StartScript』 | PARTIAL-CONFIRM(scene selector内2段目 0x80107258/0x80105be4=script/scene init) | 観測(2段目)+推論 |
| 07-09『conditional pan』 | PARTIAL-CONFIRM(selector==-1枝で座標調整0x80141D40/D42) | 観測 |
| census『DF70消費』 | ★REFUTE★(handler+呼出先1段でDF70=0x8013DF70アクセス無し) | 観測(scope=1段) |
| census『warp class』 | REFUTE方向(map-warp機構=MAPHEAD/scene-id write 無し。実体=scene/camera selector+script-seek) | 観測+推論 |
| census『直後op続かず idle_stop 464/464』 | CONFIRM(挙動)(handler出口=共有epilogue 0x800ef318 / -1枝=PC seek) | 観測 |
| DF70 address | ★真slot=0x8013DF70(gp-0x6e9c)、task記載0x8016DF70は誤展開★ | 観測(writer直読、boss1帰属確認済) |
| 07-09『0x800EE948=0x66分岐先』 | STALE(内部block を entry と誤ラベル、別経路無し) | 観測 |
| H4 | 有(下記§5)。実機構は両source labelより richな『scene遷移/story前進 driver』 | 推論 |

---

## 1. dispatch → handler 入口の同定(直読evidence)

### 1-1. band dispatch 0x800F0780(opcode fetch + range band)【観測】
```
800F0790  lbu $v0, ($v1)          ; v1=PC(mem[gp-0x6cc8])、opcode読取
800F0798  andi $s0, $v0, 0xff     ; s0 = opcode
...各band: sltiu LO;bnez→skip / sltiu HI;beqz→skip = [LO,HI)...
800F0878  sltiu $at, $s0, 0x64     ; band [0x64,0x7f)
800F087C  bnez  $at, 0x800f08a4    ;   op<0x64 → skip
800F0884  sltiu $at, $s0, 0x7f
800F0888  beqz  $at, 0x800f08a4    ;   op>=0x7f → skip
800F0894  jal 0x800ede88           ; ★0x66(=102)∈[0x64,0x7f) → jal 0x800ede88★
```
0x66=0x66 は [0x64,0x7f) に属す → band handler **0x800ede88**。

### 1-2. band handler 0x800ede88 = jump table dispatch【観測】
```
800EDEA0  sw $a0, 0x48($sp)        ; a0=opcode
800EDEAC  addi $v0, $v0, -0x64      ; index = op - 0x64
800EDEB0  sltiu $at, $v0, 0x1b      ; index < 0x1b(0x64..0x7e)有効
800EDEB4  beqz $at, 0x800ef318      ;   範囲外→共有exit
800EDEBC  lui  $v1, 0x8012
800EDEC0  addiu $v1, $v1, -0x4c60   ; ★table base = 0x80120000 - 0x4c60 = 0x8011B3A0★(符号拡張OK)
800EDEC4  sll  $v0, $v0, 2          ; index*4
800EDEC8  addu $v0, $v0, $v1
800EDECC  lw   $v0, ($v0)           ; table[index]
800EDED4  jr   $v0                  ; handler へ
```
- table base 0x8011B3A0 = census『二次表0x8011b3a0』と一致【観測confirm】。
- ★+0x0C shift事故の検証(過去前科)★: table[0](idx0=op0x64)=**0x800EDEDC** = `jr $v0` 直後の実命令位置(0x800EDEDC)と**bit一致** → table基底が正しく整列、shift無し【観測cross-check】。

### 1-3. jump table 0x8011B3A0 実読(生word)【観測】
```
idx0 op0x64 = 0x800EDEDC   (anchor=jr直後と一致)
idx1 op0x65 = 0x800EE6F4
idx2 op0x66 = ★0x800EE72C★  ← 0x66 handler entry
idx3 op0x67 = 0x800EE994    (固定ペア相手、handler域の上限画定に使用)
```
⇒ ★0x66 handler entry = 0x800EE72C、handler域 = [0x800EE72C, 0x800EE994)★。

---

## 2. handler 0x800EE72C 全長 + 意味論【観測=disasm、意味論=推論明示】

### 2-1. operand 長【観測】
入口 `800EE72C addiu $a0,$sp,0x43 / 800EE730 jal 0x800f0edc`。
0x800f0edc = `lbu [PC=mem[gp-0x6cc8]] → *a0; PC += 1`(全長RE §3-a)= ★script stream から1 byte消費+PC前進★。
→ **0x66 operand = 1 byte、opcode総長 = 2**。以降の 0x800f0ac8 は table読取(stream非消費)、0x800f0a4c は PC seek(制御流)。

### 2-2. 制御流(block 単位、意味論は推論)
1. **operand fetch**(0x800f0edc)→ sp[0x43]。
2. **progress counter++**: `lh gp-0x6ce0(=0x8013E12C); slti 0x270f; +1 store` = 9999 飽和counter【観測】。
3. **script var 読取 + list loop**: `0x800f0ac8(a0=0xfa)`→sp[0x43]。非0なら sp[0x43]=0xfb で loop
   (0x800ee78c..0x800ee7e8、`0x800f0ac8`で byte取得→`0x800f50a8`変換→`0x800f0cd0(a0,a1)`)。
   loop条件 `sltiu 0xfe`。= script var表(mem[gp-0x6cec]+idx+0x159)の 0xfb..0xfd を反復処理【観測+推論】。
4. `jal 0x800cfec4`(引数無)→ **scene selector**: `lh a0, gp-0x6d08(=0x8013E104); jal 0x800aeca8`
   → 戻り値を s2 に sign-extend【観測】。★0x8013E104 = transfer run の非vacuity control slot(writer 0x800F021C)と同一★。
5. `andi a1,s2,0xff; addiu a0,0xff; jal 0x800f0cd0`(選択結果を register 系へ)【観測】。
6. **分岐 `bne $s2, -1, 0x800ee890`**:
   - **s2 == -1(scene未選択/失敗)枝** [0x800ee828..0x800ee888]:
     `jal 0x800fa7a8` → retry counter 減算(`lb 0x8016B100; -1; sb`)→ 0 なら座標reset(`sh $zero, 0x80141D60`)
     → `0x800f0988`(script base取得)→ `0x800f0a4c(base, a1=0x4de)`(=script label 0x4de へ seek)→ PC(gp-0x6cc8)更新 → `b 0x800ef318`【観測】。
   - **s2 != -1 枝** [0x800ee890..]:
     `bnez s2, 0x800ee914`。s2==0 は座標/copy block(0x800ee898..、`0x800f0d58` struct setup + `0x800913c0(0x80164068,2/3)`)。
     merge 0x800ee914: `0x800f0c74(1)` 述語 → 0なら 0x800ee948(scene state初期化: 0x80163FD8 struct=[7,0xfd,_,0xa]+ `0x800913c0(0x80164068,2)`)、非0なら `0x800bd820(-1,1)` + `0x800f2b78` + exit【観測】。
7. 出口 = `b 0x800ef318`(共有epilogue)複数 / -1枝は PC seek 後 exit。

### 2-3. handler が触る絶対アドレス(lui base、全列挙)【観測】
`0x8016B100`(retry counter、lui0x8017-0x4f00)/ `0x80141D60`(座標?、lui0x8014+0x1d60、0化)/
`0x80164068`(scene state、×2)/ `0x80163FD8`(scene struct)。★いずれも DF70(0x8013DF70)でない★。
gp相対slot(全て 0x8013E0xx-0x8013E1xx = script VM state域): -0x6cc8(PC ptr=E144)/-0x6ce0(cnt=E12C)/
-0x6d08(selector arg=E104)/-0x6d04(E108)/-0x6d00(E10C)/-0x6cbc(E150)/-0x6cde(E12E)/-0x6ca6(E166)他。

---

## 3. 呼出先1段 RE(直接callee、全長は主要のみ)

- **0x800f0edc**【観測・全長】: operand byte fetch。`lbu[PC]→*a0; PC+=1`。§2-1。
- **0x800f0ac8**【観測・全長】: `lbu[ mem[gp-0x6cec] + a0 + 0x159 ]` を返す = script var/array 表 getter(stream非消費)。a0=0xfa/0xfe/0xfd..で表引き。
- **0x800f0a4c**【観測・全長】: `(base+2)の record を walk、halfword==a1(=0x4de)一致で base+next offset を返す` = script label seek。
- **0x800aeca8(scene selector)**【観測・主要部】: §4。
- **0x800f0cd0 / 0x800f50a8 / 0x800cfec4 / 0x800fa7a8 / 0x800f0988 / 0x800f0d58 / 0x800913c0 / 0x800f0c74 / 0x800bd820 / 0x800f2b78**:
  呼出文脈から役割同定(register set/struct setup/述語/state書込)。★DF70アクセス走査=全14 callee で無し(§6)★。
  個別全長は本p1 scope(handler+1段)で役割確定に足る範囲まで。2段以深は未RE(promote禁止)。

---

## 4. scene selector 0x800aeca8 全長RE(premise核)【観測】

```
800AECBC  move $s2, $a0             ; s2 = arg(=script var 0x8013E104)
800AECC4  sb ..., -0x6b26($gp)      ; busy flag=1
800AECCC  lw $v0, 0x8016B04C ; +0x78/+0x7c/+0x80 を 0x80141FD8/FDC/FE0 へ copy(camera/pos params 3語)
800AED10  jal 0x800e3940 / 800bde30 / 800e9a40   ; scene setup 3連
800AED2C  jal 0x80107258 (a0=s2) → s1            ; ★script/scene init(2段目、StartScript候補)★
800AED40  jal 0x80105be4 (a0=s2,a1=s1)           ; ★同上★
800AED48  jal 0x8005ca7c → s0(sign-ext byte)     ; 結果code
800AED60  sb $zero, -0x6b26($gp)   ; busy flag=0
800AED68  bne $s0, -1, 0x800aedbc  ; -1(失敗)なら以降で座標調整 0x80141D42-=0x1e / 0x80141D40-=0x14 ...
```
- struct ptr 0x8016B04C から camera/pos 3語 copy + scene init(0x80107258/0x80105be4)+ 結果code返却。
- ★2段目 peek(scope注記): 0x80107258 は `mem[gp-0x6dec]+0x66c=1 / +0x670=0` を書く scene/script state init★
  = 07-09『StartScript』の実体候補。**2段目ゆえ full RE は本p1 scope外、PARTIAL と明示**。

---

## 5. premise-check 判定(2源 + H4)

### 5-1. 07-09 worker1『0x66=複合scene/story-progression op(StartScript + scene selector 0x800aeca8 + conditional pan)』
- scene selector 0x800aeca8 = ★CONFIRM★(handler が直接 jal、arg=script var 0x8013E104)。
- StartScript = **PARTIAL-CONFIRM**(selector 内 0x80107258/0x80105be4 が script/scene init。2段目=full RE未)。
- conditional pan = **PARTIAL-CONFIRM**(selector==-1 枝で座標 0x80141D40/D42 を定数減算=camera/coord 調整、結果条件付き)。
- 総合: ★07-09 finding は CONFIRM 方向★(複合 scene/story-progression op として整合)。

### 5-2. census『DF70消費(warp class)、直後op続かず idle_stop 464/464』
- 『DF70消費』= ★REFUTE★(handler + 呼出先1段で DF70=0x8013DF70 アクセス無し。§6。scope=1段)。
- 『warp class』= REFUTE方向(0x66 は map-warp 機構=MAPHEAD/scene-id slot write を持たない。実体=scene/camera selector + script label seek)【観測+推論】。
- 『直後op続かず idle_stop 464/464』= ★CONFIRM(挙動)★(handler 出口=共有epilogue 0x800ef318、-1枝は PC を label 0x4de へ seek=linear継続しない)。
  ⇒ census の**挙動観測は正**だが**機構label(DF70/warp)が誤帰属**。

### 5-3. ★H4(両source label外)★【推論】
実機構 = 『operand 1byte を取り、progress counter を進め、script var 表を反復し、**scene selector で scene/camera を選択**し、
結果で(a)失敗→retry減算+座標reset+script label 0x4de seek /(b)成功→scene state 初期化、する **scene遷移/story前進 driver**』。
= DF70 消費でも純 warp でもない。07-09 の『複合 scene/story-progression op』が最も近いが、
『DF70 を読む』前提は成立しない。両 label を額面採用しない H4 所見として記録。

### 5-4. stale-claim 突合(補足A、boss1指示)【観測】
07-09台帳『0x800EE948=op0x66分岐先』: jump table 27entry に 0x800EE948 は**非登録**(entry でない)。
0x800EE948 は 0x66 handler域 [0x800EE72C,0x800EE994) **内部**の分岐先(0x800EE920 `beqz→0x800ee948`、0x800f0c74(1)==0 時)。
⇒ ★STALE(内部block を handler entry と誤ラベル、table-shift/0x66-0x67混同期の残渣)。別経路は実在せず★。正 entry=0x800EE72C。

---

## 6. DF70 read 判定(scope限定、promote禁止)

- ★真 DF70 slot = 0x8013DF70(gp-0x6e9c)★。census writer 0x800AE4E0 = `sb $v0,-0x6e9c($gp)` 直読で確定
  (task dispatch の 0x8016DF70 は boss1 誤展開=帰属確認済、census 原文は『DF70』のみ)。0x8016DF70 は gp相対 range(±0x8000)外(差0x29164)ゆえ構造的にアクセス不能。
- 判定手順: (i) gp相対 -0x6e9c を handler+14 callee で走査=**0件**(gp相対は直接検出、pointer-base盲点なし)。
  (ii) 絶対 lui 0x8013DF70 走査=**0件**。
- ⇒ ★『0x66 handler + 呼出先1段では DF70(0x8013DF70)を read/write しない』★。
  **scope限定文言を維持**: 2段以深は未測定ゆえ『0x66 は DF70 を読まない』の絶対形に promote しない。
- ★open item(起票のみ、本p1 scope外・追跡しない)★: 『0x8013DF70(field-side writer 0x800AE4E0 が定数2書込、130/130)を誰が読むか』は未解決。
  自道具の盲点注記: 全EXE の 0x8013DF70 reader を絶対lui走査したが、DF70は pointer-base/gp相対で書かれる slot ゆえ、
  絶対走査単独では reader 全列挙にならない(ovldis pointer-base盲点、memory reference_ovldis_xref_absolute_blindspot)= 別途 gp相対-0x6e9c 全域走査が要る(未実施)。

---

## 7. 未確定残(promote禁止・honest gap)

1. StartScript の確定 = 2段目 0x80107258/0x80105be4 の全長RE未(本p1 scope外)。PARTIAL のまま。
2. conditional pan の『pan』意味 = 座標 0x80141D40/D42 の定数減算(-0x14/-0x1e)が camera pan か actor 移動かは未確定(座標系未同定)。
3. list loop(0x800f0ac8 0xfb..0xfd)の具体 semantics = script var 表の内容依存、静的には未確定。
4. ★handler 末尾 block(0x800ee948..0x800ee990)が 0x800EE994(=0x67 handler entry)へ構造上 fall-through する★
   (0x800EE98C `jal 0x800913c0`/0x990 nop の後 branch 無し → 0x800EE994 実行)。0x67 handler は `-0x6ca8` read +
   `jal 0x800f0e6c` + `-0x6cbc=0x67` 書込 = distinct handler ゆえ、fall-through すると 0x66 が書いた -0x6cbc=0x4a を
   0x67 が 0x67 で上書きする【観測】。
   - この path は 0x800EE920 `beqz(0x800f0c74(1)==0)→0x800ee948` 経由のみ。census 動的 trace は 0x66=idle_stop 464/464
     ゆえ、実行される common path は epilogue(0x800ef318)/-1枝 seek で exit していると推測(=この fall-through path は
     稀 or 未踏の可能性)【推論】。
   - ★静的には fall-through 実在。runtime で 0x800f0c74(1)==0 path が踏まれるか(=0x66→0x67 code 流入が実挙動か)は
     未測定。設計(p2)で『0x66 exit の忠実実装』はこの分岐を明示 model 要(over-claim 回避、b/c どちらかを断定しない)★。
5. DF70 reader = §6 open item(未追跡)。

---

## 8. addendum(p1 追記、2026-07-19): 設計直結 2 点の全長RE【観測/推論明示】

boss1 指示で (p2)設計形を左右する 2 点を全長RE。read-only 継続。

### 8-1. ★0x800f0c74 述語 = event-flag bit test。fall-through gate = 「flag#1 clear」★【観測】
```
800F0C84  lhu $a0, 0x20($sp)      ; a0 = id(handler は 1)
800F0C90  jal 0x800f191c          ; (id, &ptr_out=sp[0x18], &mask_out=sp[0x1f])
800F0C98  lw  $v0, 0x18($sp) / lbu ($v0)   ; *ptr(flag byte)
800F0CAC  lbu $v0, 0x1f($sp)      ; mask
800F0CB4  and $v0, $s0, $v0 / sltu $v0,$zero,$v0   ; return (*ptr & mask)!=0
```
- 0x800f191c【観測】: `bit = id & 7 / byteidx = id >> 3`(算術shift、負補正込)= ★bit-flag 配列アドレッシング★
  → 0x800f0c74 は **event-flag[id] の bit test を返す bool 関数**。
- ★handler 内の意味★: `addiu a0,1; jal 0x800f0c74; beqz $v0,0x800ee948`
  = **event-flag #1 が clear(==0)なら 0x800ee948(→0x67 handler へ fall-through)、set なら 0x800bd820(-1,1)+0x800f2b78+epilogue exit**。
- ⇒ ★§7-4 の fall-through は死code でなく **flag#1 clear で踏まれる正規分岐**★。0x66 exit の忠実 model は
  flag#1 で 2 分岐必須(set=action+stop / clear=scene state init→0x67 継続)。
- 未確定: flag#1 の**意味論**(どの story event flag か)= flag-name 表 未同定(p1 scope外)。**構造 gate(flag#1 で分岐)は確定**。

### 8-2. ★StartScript = CONFIRM 昇格(PARTIAL 解消)★: selector 2段目 0x80107258 + 0x80105be4【観測】
- **0x80107258(scene setup / param-list dispatch)**:
  `struct[gp-0x6dec][+0x66c]=1, [+0x670]=0`(scene state init)→ `0x800f0c74(1)`(flag#1 test 保存)→
  `0x800f0ac8(0xfa)`(scene param count?)→ **list loop** `0x800f0ac8(0xfb+i) → 0x801066cc(entry,0)` per entry(0xff終端)。
  = ★scene を param list 反復で開始する『StartScript』本体★。**0x66 handler と同一の flag#1 test + var(0xfa/0xfb..)機構を共有**【観測】。
- **0x80105be4(scene-id dispatch)**:
  `gp-0x6dcc = arg1`(current scene param)→ `struct[+0x66d]` index で descriptor 表(0x8013CDB4)引き →
  first word == 0x73 判定 → scene-id(arg0)を `<2 / <0xa` で分岐【観測】。= scene 種別 dispatch。
- ⇒ ★07-09『StartScript』= **CONFIRM**(scene selector 0x800aeca8 が 0x80107258=param-list start + 0x80105be4=id dispatch を呼ぶ)★。
  §5-1 の PARTIAL を昇格。0x66 の C# model は『scene selector → (a)param-list 反復 start (b)scene-id 種別 dispatch』を emit 対象とすべき【推論=設計含意】。
- 未確定(promote禁止): 0x801066cc(per-entry、3段目)/ 0x80105be4 後半の scene-id 別 dispatch 先(<2/<0xa 各枝)/
  descriptor 表 0x8013CDB4 の内容 = 3段目以深、本 addendum scope 外。

### 8-3. 設計(p2)への含意サマリ【推論】
1. ★0x66 exit = flag#1 gate の 2 分岐★(set=action+stop / clear=scene state init→0x67 fall-through)。C# は 0x66/0x67 を
   flag#1 clear で連鎖する pair として model 要(§7-4 の b/c 断定回避は解消: clear 枝は正規、runtime 頻度は別問題)。
2. scene selector emit = param-list start(0x80107258 相当)+ scene-id dispatch(0x80105be4 相当)の 2 実体。
3. 依然 flag#1 の event 意味論・3段目 dispatch 先は未同定 = 設計は「構造忠実(分岐/呼出形)」を model し、意味未確定部は
   raw/gap 宣言(発明ゼロ原則、既存 disposition 様式踏襲)。
