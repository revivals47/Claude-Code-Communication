# STEP4 p1 blind x-check(0x46/0x79)— worker2 独立検証

worker2 / 2026-07-19。**BLIND 方式**: STEP A=worker1 doc 未開封で EXE 直読から自力導出→固定。STEP B=突合。
EXE=SLPS_017.97(slps_017_97.bin、base 0x80090800)、tool=exedis.py。lui 符号拡張・anchor 検算・自道具盲点を明示。

---

## STEP A — 独立導出(worker1 doc 未読、固定値)

### Q1. handler entry(band dispatch 起点 + anchor 検算)【観測】
band dispatch = 0x800F0780(opcode fetch → range band、0x66 RE で確認済の同機構)。

- **0x46**(=70): band `sltiu 0x46 / sltiu 0x59` = **[0x46,0x59)** → `jal 0x800ed434`。
  - 0x800ed434: `index = op-0x46`, `sltiu 0x13`(0x46..0x58 有効), table base = `lui 0x8012 + addiu -0x4e00` = **0x8011B200**(符号拡張OK)。
  - table[0](0x46) = **0x800ED480**。★anchor 検算: table[0] = `jr $v0`(0x800ED478)直後の実命令 0x800ED480 と bit 一致=shift 無し★。
  - ⇒ **0x46 handler = 0x800ED480**。
- **0x79**(=121): band **[0x64,0x7f)** → `jal 0x800ede88`(0x66 と同 band)。
  - 0x800ede88: `index = op-0x64`, table base = **0x8011B3A0**(0x66 RE で anchor 検証済=table[0]=0x800EDEDC=post-jr)。
  - table[0x79-0x64=21] = **0x800EF190**。
  - ⇒ **0x79 handler = 0x800EF190**。

### Q2. operand 長【観測】
- 0x46(0x800ED480): `addiu a0,sp,0x2d; jal 0x800f0edc`(=1 byte fetch+PC前進)→ `lbu a0,0x2d(sp); jal 0x800f1590; b exit`。
  = ★operand 1 byte、Len[0x46]=2★。
- 0x79(0x800EF190): `addiu a0,sp,0x43; jal 0x800f0edc`(1 byte)→ `lbu a0,0x43(sp); jal 0x800f1850; b 0x800ef318`。
  = ★operand 1 byte、Len[0x79]=2★。
- 両 handler とも「operand 1 byte fetch → 単一 callee(operand 渡し)→ exit」の同型構造。

### Q3. 共通 registry の base + slot 構造【観測】
両 callee(0x800f1590 / 0x800f1850)が触る registry:
- base = `lui 0x8016 + addiu 0x4098` = **0x80164098**(符号拡張なし=0x4098<0x8000)。
- slot = `s0<<2`(stride **4 = word**)、loop `slti s0, 8` = ★**8 slot**(index 0..7、範囲 0x80164098..0x801640B4)★。
- sentinel = **-1(0xFFFFFFFF)= 空 slot**。
- （設計 scoping の "640A4" = 0x801640A4 = slot 3 = registry 中間参照点。base は 0x80164098。）

### Q4. 0x46 と 0x79 の機構関係(何の dual か)【観測】
★同一 8-slot registry(0x80164098)への **ADD / REMOVE dual**★:
- **0x46 → 0x800f1590 = ADD**: slot を 0..7 走査し **最初の空(==-1)slot** に operand を store → `jal 0x800bb518(operand)`(登録/spawn 相当)。
- **0x79 → 0x800f1850 = REMOVE**: slot を 0..7 走査し **operand と一致する slot** を **-1 に clear** → `jal 0x800bb968(operand)`(登録解除/despawn 相当)。
- operand = registry に載る **model/entity id**。registry = 同時に最大 8 個の active id table。
- 0x46=add-first-free / 0x79=remove-by-value = ★集合(add/remove)の対★。callee 0x800bb518(add 副作用)/ 0x800bb968(remove 副作用)が実 spawn/despawn。

### STEP A 固定値サマリ(worker1 doc 未読時点)
| Q | 値 |
|---|---|
| Q1 | 0x46=0x800ED480(table 0x8011B200[0]) / 0x79=0x800EF190(table 0x8011B3A0[21]) |
| Q2 | 両 operand 1 byte、Len=2 |
| Q3 | registry base 0x80164098、stride 4(word)、8 slot、sentinel -1 |
| Q4 | 同 registry の ADD(0x46)/REMOVE(0x79)dual、operand=model id、副作用 0x800bb518/0x800bb968 |

---

## STEP B — worker1 doc 突合(STEP A 固定後に開封)

worker1 = `STEP4_P1_RE_worker1.md`。STEP A 固定値と逐条突合。

### 収束表(Q1-Q4)
| Q | worker2(STEP A、blind) | worker1 | 突合 |
|---|---|---|---|
| Q1 0x46 entry | 0x800ED480(table 0x8011B200[0]、anchor 一致) | 0x800ED480(同、anchor 一致) | ★一致(bit-exact + anchor 検算も同)★ |
| Q1 0x79 entry | 0x800EF190(table 0x8011B3A0[21]) | 0x800EF190(同) | ★一致★ |
| Q2 operand 長 | 両 1 byte、Len=2 | 両 1 byte、Len=2 | ★一致★ |
| Q3 registry base | 0x80164098、stride 4、8 slot、sentinel -1 | 0x80164098、stride 4、8 slot、sentinel -1 | ★一致★ |
| Q3 "640A4" | slot 3(=+0xC) | slot 3(=+0xC) | ★一致★ |
| Q4 dual | 同 registry の ADD(0x46)/REMOVE(0x79)、operand=id、副作用 0x800bb518/0x800bb968 | 同(ADD/REMOVE dual、0x800bb518/0x800bb968) | ★一致★ |

⇒ ★Q1-Q4 全 CONVERGE(DIFF ゼロ)。band 帰属・table 基底・anchor 検算・operand 長・registry base/stride/slot 数/sentinel・add/remove dual・callee アドレスが全て独立に bit-exact 一致=二重独立成立★。

### 差分(非矛盾、scope/深さの違い)
1. ★worker1 は 2段目を 1 段深く追跡: 0x800bb518(add 副作用)→ `jal 0x800a1348`(a1=0、actor activation 本体)★。
   → ★worker2 独立 spot-check で裏取り: 0x800bb518=`lbu a0,operand; a1=0; jal 0x800a1348; jr ra` を直読確認=worker1 claim 一致★。
   私の STEP A は callee(0x800bb518/0x800bb968)を spawn/despawn 推論で止めた(1段)。worker1 の 0x800a1348 は 3段目=両者とも label 未確定(promote 禁止)で一致。
2. worker1 は census §4c premise-check(0x46 隣接ペア/連番 01-04 / 0x79 operand 0x01・1 site / 隣接 0x79→0x46)を実施(§5)。
   worker2 の Q1-Q4 scope 外ゆえ未実施。worker1 の裁定=「handler 機構(add/remove)= CONFIRM / stream-content(連番・値・site)= corpus 未走査ゆえ未検証で採録」= 額面採用せず H4 開放、規範遵守。矛盾なし。
3. registry 範囲表記: worker2 "..0x801640B4"(slot 7 の addr)/ worker1 "..0x801640B8"(end-exclusive 境界)= 同一(8 slot × 4byte)、表記差のみ。

### 結論
★worker1 STEP4 p1 RE の Q1-Q4 = worker2 blind 独立導出と DIFF ゼロで収束。0x800bb518→0x800a1348 の 2段目も独立裏取り一致★。
差分は worker1 の追加深度(0x800a1348)+ census premise-check(§5)であって矛盾でない。
→ ★STEP4 p1 = 二重独立確定(gate① 設計入力として信頼可)★。
honest gap(両者共有): 2段以深 0x800a1348/0x800bb968 の actor 実体 + registry slot の id 意味 + census stream-content = corpus/深層 RE 後(promote 禁止)。
