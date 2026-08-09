# STEP4 (p1) 全長RE — opcode 0x46 / 0x79 + registry 0x801640A4(worker1)

**date**: 2026-07-19 / worker1 / ★read-only RE(コード変更ゼロ)、規範7=実装前全長RE の p1 先行★
**material**: EXE=slps_017_97.bin(RAM image、base 0x80090800)、tool=exedis.py(capstone MIPS)。gp=0x80144E0C。
**手法**: dispatch 表から handler 自力導出(step5 p1 同手法、band/表基底 anchor 再確認)→ handler + 呼出先1段 全長RE → census §4c premise-check(額面採用せず、H4 開放)。
**規律**: 観測(disasm paste)/推論を区分。2段以深は promote 禁止(honest gap)。

---

## 0. 結論(単一表)

| 項目 | 判定 | 次元 |
|---|---|---|
| 0x46 handler entry | ★0x800ED480★(band 0x800ed434[0x46,0x59)→table 0x8011B200 idx0) | 観測(直読+anchor) |
| 0x46 operand 長 | ★1 byte(総長 Len=2)★(0x800f0edc 1回) | 観測 |
| 0x46 機構 | ★8-slot registry @0x80164098 の空きslotへ operand 格納 + activate(0x800bb518→0x800a1348)= actor 登録★ | 観測(構造)+推論(actor 意味) |
| 0x79 handler entry | ★0x800EF190★(band 0x800ede88[0x64,0x7f)=0x66 と同 band→table 0x8011B3A0 idx21) | 観測 |
| 0x79 operand 長 | ★1 byte(総長 Len=2)★(0x800f0edc 1回) | 観測 |
| 0x79 機構 | ★同 registry @0x80164098 の operand 一致slotを -1 clear + deactivate(0x800bb968)= actor 解除(0x46 の dual)★ | 観測(構造)+推論 |
| registry 0x801640A4 | ★8-slot actor registry @0x80164098 の **slot 3**(=+0xC)。0x46(add)/0x79(remove)が read/write★ | 観測 |
| census §4c(adjacency/連番/operand) | premise=stream 使用 pattern、handler 機構と非矛盾(add/remove)。ただし corpus 未走査=stream-content は未検証で採録 | 観測(handler)+ census 未検証 flag |
| exit 構造 | 両 handler とも clean `b epilogue`(0x46→0x800edd5c / 0x79→0x800ef318)、fall-through 無し | 観測 |

---

## 1. dispatch → handler 導出(観測、anchor 検算込)

### 1-1. band 帰属(band dispatch 0x800F0780、step5 で確定した band 表)
- 0x46(=70)∈ **[0x46,0x59)** → band handler **0x800ed434**(0x800F0820-083C: sltiu<0x46 skip / sltiu<0x59 skip / jal 0x800ed434)。
- 0x79(=121)∈ **[0x64,0x7f)** → band handler **0x800ede88**(0x66 と同 band、0x800F0894 jal)。

### 1-2. 0x46 band handler 0x800ed434 = jump table(観測)
```
800ED450  addi $v0, $v0, -0x46        ; idx = op-0x46
800ED454  sltiu $at, $v0, 0x13        ; idx<0x13(19) 有効、else 0x800edd5c(epilogue)
800ED460  lui $v1, 0x8012
800ED464  addiu $v1, $v1, -0x4e00     ; table base = 0x80120000-0x4e00 = 0x8011B200
800ED468  sll $v0,$v0,2 ; addu ; lw ; jr $v0
```
- ★anchor 検算★: table[0](idx0=op0x46)=**0x800ED480** = `jr` 直後(0x800ED480)の inline code と一致 → base 0x8011B200 正(+shift 無し)。
- table 実読: idx0 op0x46=**0x800ED480** / idx1 op0x47=0x800ED4A0 / idx2 op0x48=0x800ED4E4 …。

### 1-3. 0x79 band handler 0x800ede88(=step5 と同、table 0x8011B3A0)
- idx = 0x79-0x64 = 0x15(21)、range<0x1b OK。entry = 0x8011B3A0 + 21*4 = 0x8011B3F4。
- table 実読: idx21 op0x79=**0x800EF190**(neighbor idx20 op0x78=0x800EF16C / idx22 op0x7A=0x800EF1B0)。
- ★step5 で anchor(idx0=0x800EDEDC)検算済の同 table★=base 信頼。

---

## 2. 0x46 handler 0x800ED480 全長RE(観測)

```
800ED480  addiu $a0, $sp, 0x2d
800ED484  jal 0x800f0edc          ; ★operand fetch 1byte→sp+0x2d、PC+1(step5 で確定した PC-advance reader)★
800ED48C  lbu $a0, 0x2d($sp)      ; a0 = operand(registry id、actor 意味は🅰)
800ED490  jal 0x800f1590          ; ★registry ADD(§2-1)★
800ED498  b 0x800edd5c            ; → band epilogue(clean exit)
```
→ ★operand=1 byte、総長 Len=2★。PC-advance reader は 0x800f0edc 1回のみ。

### 2-1. 呼出先1段 0x800f1590 = registry ADD(観測、全長)
```
s1 = a0(operand); s0 = 0
loop (s0 < 8):
  v0 = *[0x80164098 + s0*4]        ; registry slot 読取(lui0x8016+0x4098)
  if (v0 != -1) → s0++, continue   ; 空きslot(==-1)を探索
  *[0x80164098 + s0*4] = s1        ; ★最初の空きslotへ operand 格納★
  jal 0x800bb518 (a0=s1)           ; activate(§2-2、2段目)
  break
```
→ ★registry base=**0x80164098**、8 slot × 4byte(0x80164098..0x801640B8)★。0x46=「operand(id)を空きslotに登録し activate」。全slot埋(8)なら格納せず loop 終了(honest: overflow 時 no-op)。

### 2-2. 2段目(参考、promote 禁止): 0x800bb518
`a0=operand; a1=0; jal 0x800a1348`(actor activation 本体、3段目)。「actor」意味は activate/deactivate pattern からの推論=3段目 RE 未ゆえ label 未確定。

---

## 3. 0x79 handler 0x800EF190 全長RE(観測)

```
800EF190  addiu $a0, $sp, 0x43
800EF194  jal 0x800f0edc          ; operand fetch 1byte→sp+0x43、PC+1
800EF19C  lbu $a0, 0x43($sp)      ; a0 = operand(registry id、actor 意味は🅰)
800EF1A0  jal 0x800f1850          ; ★registry REMOVE(§3-1)★
800EF1A8  b 0x800ef318            ; → epilogue(0x66 と同 epilogue、clean exit、fall-through 無し)
```
→ ★operand=1 byte、総長 Len=2★。次 code 0x800EF1B0 は 0x7A handler=0x79 は fall-through しない(explicit b)。

### 3-1. 呼出先1段 0x800f1850 = registry REMOVE(観測、全長)= 0x46 の dual
```
s1 = a0(operand); s0 = 0
loop (s0 < 8):
  v0 = *[0x80164098 + s0*4]        ; ★同 registry @0x80164098★
  if (s1 != v0) → s0++, continue   ; operand 一致slot を探索
  *[0x80164098 + s0*4] = -1        ; ★一致slot を -1 clear★
  jal 0x800bb968 (a0=s1)           ; deactivate(2段目)
  break
```
→ 0x79=「operand(id)一致slotを registry から解除(-1)し deactivate」= ★0x46(add)の完全 dual★。同 registry @0x80164098 を操作。

---

## 4. registry 0x801640A4 の実根拠(観測)

- ★registry = 8-slot 配列 @**0x80164098**(stride 4、0x80164098..0x801640B8)★。0x46(0x800f1590)が add、0x79(0x800f1850)が remove、両者 lui0x8016+0x4098 で同一 base。
- ★0x801640A4 = 0x80164098 + 0xC = **slot 3**(index 3)★。census『registry 0x801640A4系』= この actor registry の 1 slot を指す(registry 全体は 0x80164098 起点)。
- ∴ census の「0x46/0x79 ↔ 0x801640A4 紐付け」= ★confirm(0x46/0x79 が 0x80164098 registry を add/remove、0x801640A4 はその slot 3)★。値の意味(slot に入る id が actor か object か)は 2段目 0x800a1348/0x800bb968 の RE 後(promote 禁止)。

---

## 5. premise-check(census §4c、額面採用せず・H4 開放)

> ★注記(§6bis で解決済)★: 本節は corpus 走査 **前** の handler 次元 premise-check(「stream-content 未検証」stance)。corpus 6 site の実 byte 突合は §6bis で完了(全 CONFIRM)+ 0x47=MAP_CHANGE 訂正済。下表の「corpus 未走査/actor 差替え」表現は §6bis(訂正版)で置換。

| census §4c claim | 次元 | 裁定 |
|---|---|---|
| 0x46=[46 XX 47 XX NN 00] 隣接ペア形 | stream 使用 pattern | handler は 0x46=Len2(operand1)=「46 XX」。続く「47 XX」=別 opcode 0x47(Len4=operand3)。★『隣接ペア』は stream 上の 0x46→0x47 並びであって 0x46 の operand 長でない★=非矛盾(handler と整合)。stream 出現自体は corpus 未走査=未検証で採録 |
| 0x46 連番 01-04 | stream content(operand 値) | handler=operand を registry id として登録ゆえ、id 01-04 の 4 actor 登録は機構と整合。★但し「01-04」値は corpus 依存=handler では未確定(census stream 観測、私は未走査)★ |
| 0x79=len2 / operand 0x01 / 1 site | Len=観測 / 値・site=stream | ★Len=2 は handler で CONFIRM★。operand 値 0x01・1 site は corpus 観測(未走査)=未検証で採録 |
| 0x79 直後 0x46 | stream 隣接 | handler 機構=0x79(remove)→0x46(add)= ★actor 差替え pattern と整合★(remove して再 add)。stream 隣接自体は corpus 未走査 |

★H4 所見(handler が明かす真機構)★: 0x46/0x79 = 両 census label(隣接ペア/連番)を超え、**共有 8-slot actor registry(0x80164098)への add/remove pair**。census の stream 観測(隣接・連番・値)は機構と非矛盾だが、私の RE は handler 次元ゆえ ★stream-content(連番/値/site 数)は corpus 走査で別途裏取り要(未実施=honest gap)★。額面採用せず「handler=add/remove 確定 / stream-content=census 未検証」を分離。

---

## 6. corpus(設計時 差分テスト指定、RE 段階では文脈材料)
(129,6)(151,60)(170,51)(171,51)(172,51)(173,51) = 0x46/0x79 出現の (scenario,section)。p1 RE では handler 機構確定が目的ゆえ corpus 走査は未実施(設計 p2/差分テスト段で使用)。上記 §5 の stream-content 裏取りは本 corpus で行うのが自然。

---

## 6bis. corpus 裏取り(census §4c stream-content、DG.SCN 実 byte decode)★全 CONFIRM★

固定 corpus 全 6 site を DG.SCN(unity/…/dialogue/DG.SCN、offset table→entry→subtable{id,off}→section)で実 byte decode(Len 表 EXE-verbatim)。

### 各 site 実 byte(paste、entry-rel offset)
| (scn,sec) | entry@ | 0x46 site | 実 byte 列(0x79/0x46/0x47) |
|---|---|---|---|
| (129,6) | 0x54800 | 0x196 | `46 9a` / `47 9a 01 00` = **[46 XX 47 XX NN 00]** XX=9a NN=01 |
| (151,60) | 0x66800 | 0x42 | `79 01`(@0x40)→ `46 75` → `47 75 03 00` = **[79 01][46 XX 47 XX NN 00]** XX=75 NN=03 |
| (170,51) | 0x75800 | 0x12 | `46 50` / `47 50 01 00` = [46 XX 47 XX NN 00] XX=50 **NN=01** |
| (171,51) | 0x77800 | 0x12 | `46 44` / `47 44 02 00` = XX=44 **NN=02** |
| (172,51) | 0x79800 | 0x12 | `46 63` / `47 63 03 00` = XX=63 **NN=03** |
| (173,51) | 0x7B800 | 0x12 | `46 5d` / `47 5d 04 00` = XX=5d **NN=04** |

### ★0x47 = MAP_CHANGE(既確立 RE、文脈非依存=PRESIDENT Step1 原則、boss1 査読訂正)★
corpus の 0x47 も **同一 handler = MAP_CHANGE**(0x4E 誤 conflate の教訓=opcode semantic は文脈非依存)。実 disasm 確認:
```
800ED4A0 (=0x47 handler、table[1]) : 0x800f0edc[+1→sp0x2d] + 0x800f1078[+2→sp0x2e,0x2f]=operand3
800ED4C8 lbu a0,0x2d(sp) / lbu a1,0x2e(sp) / lbu a2,0x2f(sp)   ; a0=map a1=spawn a2=mode
800ED4D4 jal 0x800bb544                                        ; ★warp executor(MAP_CHANGE、C# 実装済)★
```
→ 0x47 operand = **[47 MM DD XX]**(MM=map / DD=spawn / XX=mode)。corpus の `47 50 01 00` = map 0x50 / spawn 01 / mode 00。★私の旧 gloss『per-actor 設定』は誤り=撤回★。

### census §4c claim 突合(実 byte 根拠、gloss 訂正版)
| census claim | 裁定 | 根拠 |
|---|---|---|
| 0x46=[46 XX 47 XX NN 00] 隣接ペア形 | ★**CONFIRM(6/6)**★ | 全 6 site で 0x46(2byte=registry ADD)直後に 0x47(4byte=MAP_CHANGE `47 MM DD XX`)。★0x46 operand == 0x47 の MM(map id):6/6 一致★(下記 id 空間観測) |
| 連番 01-04 | ★**CONFIRM**★ | ★連番は 0x47 の **DD(spawn)field**(=[47 MM **DD** XX] の 2nd operand)が scn 170/171/172/173(sec51)で **01/02/03/04**★。(129,6)DD=01 /(151,60)DD=03。※census『0x46 連番』を「0x47 spawn field の連番」と精密化 |
| 0x79=len2 / operand 0x01 / 1 site / 直後0x46 | ★**CONFIRM**★ | (151,60)`79 01`(len2 operand0x01)直後 `46 75`。0x79 は corpus 6 中 (151,60) のみ + sweep_225 動的 exec=1(0x46 exec=6=6 site / 0x47 exec=3) |

### ★id 空間観測(強い claim、意味論は🅰=保留、food-id≠shop-id 要注意)★
- 6/6 site で ★0x46 operand(registry ADD id)== 0x47 の MM(遷移先 map id)★:
  (129,6)9a=9a /(151,60)75=75 /(170,51)50=50 /(171,51)44=44 /(172,51)63=63 /(173,51)5d=5d。
- ★これは値一致の **観測**であって「registry id 空間 == map id 空間」の機構的同一性を主張しない★。0x46 の registry(@0x80164098)に入る id の意味空間 と 0x47 の map id 空間 が構造的に同一か(recruit→当該 map 遷移の設計)は ★RE 後(0x46 activate 0x800a1348 + registry semantics)★。id 空間跨ぎの値一致は food-id≠shop-id 教訓の要注意領域=額面で「同一空間」と結論しない。

### 機構統合(p1 + corpus、gloss 訂正版)
- ★[46 XX][47 XX NN 00] = registry ADD id XX → MAP_CHANGE(map=XX, spawn=NN, mode=00)★。0x46 が id XX を registry 登録、0x47 が map XX へ spawn NN で遷移(0x46 operand==0x47 map id=id 空間観測)。
- ★(151,60) [79 01][46 75 47 75 03 00]★ = 0x79(registry REMOVE id 0x01)→ 0x46(registry ADD id 0x75)→ 0x47(MAP_CHANGE map 0x75 spawn 03 mode 00)。= registry 入替 + 当該 map 遷移。
- ★census stream-content は全て実 byte で CONFIRM★。handler 次元(p1)+ corpus 実 byte + census 動的 exec の一致(0x47=MAP_CHANGE は既確立 RE と整合)。

### honest 注記
- 「1 site」= corpus 6 内 + sweep_225 動的 exec=1 で確認。全 225 静的走査は scope 外(動的=1 と整合)。
- ★0x46 operand==0x47 map id の 6/6 一致=id 空間観測。機構的説明(なぜ registry id == 遷移先 map id か)= 🅰 保留、0x46 activate/registry semantics RE 後(promote 禁止、id 空間跨ぎ要注意)★。
- 0x47 は MAP_CHANGE(既確立、C# 実装済)ゆえ step4 実装対象は 0x46/0x79(registry add/remove)。0x47 は本 corpus では文脈材料。

---

## 6ter. OI-7: 0x46/0x79 全225 entry 静的走査(decoder walk、best-effort)★2026-07-19★

**手法**: ★byte grep 禁止(census §0: operand collision 偽陽性、0x6F/0x6D phantom 前科)★ → **section-accurate decoder walk**: 各 entry の subtable{sectionId,offset}から各 section を起点に oplen 表(EXE-verbatim)+SJIS-aware で 0xFE/0xFF まで decode。0x46/0x79 出現を count。
**walker 検証(corpus 6)**: entry129 0x46@0x196 / entry151 0x46@0x42+0x79@0x40 / entry170-173 0x46@0x12 = ★corpus 実 byte と完全一致(section 境界停止で naive linear の desync 偽陽性を排除)★。

### 静的走査結果(section-accurate、全 1559 section)
| opcode | 静的 site 総数 | 出現 entry 数 | 出現 entry |
|---|---|---|---|
| 0x46 | ★19★(entry0 除く) | 16 | 7,45,49(×2),60,104,127,129,133(×2),151,162(×2),170,171,172,173,196,219 |
| 0x79 | ★4★ | 2 | 151(×1、`79 01`)、**176(×3、`79 00 18 00` sec A/B/C)** |

- ★entry0(MAPHEAD、0x800..0x6800=24KB)は 324 件 0x46=**desync 除外**★: scenario-0/MAPHEAD は map/table data 混在ゆえ section decode が非 script data を opcode 誤読(GetEntryBase(0)が MapheadLoadedLen bound する特殊 entry)。本 walker では信頼不能=★除外し disclose★(entry0 の真 0x46/0x79 含有は本手法で未確定)。

### 整合検証(corpus / 動的 / 静的、上界関係)
- ★corpus 6(0x46)⊆ 静的 19 ⊇ 動的 6★: corpus entry(129,151,170-173)全て静的に present。動的 census(0x46 exec=6)⊆ 静的 19 = ★静的が上界(reached ⊆ static)★。整合。
- ★0x79: 動的 1(entry151 のみ reached)⊆ 静的 4(entry151 + entry176×3)★。★H4 finding: 『0x79=1 site』は **dynamic 到達数**であって static 総数でない。静的には entry176 に 3 site 追加存在(sec A/B/C、operand 0x00、census run 未到達=state/path 依存)★。「打ち切られた list の不在は否定でない」規範どおり、動的 1 を静的総数と誤らない。

### coverage 限界(数値開示、best-effort)
- ★走査 section 数=1559 / subtable 無し entry=0(全 entry が section 列挙可)★。
- ★entry0(MAPHEAD)= desync 除外 1 件★=本手法の非適用領域(真含有未確定)。
- ★section-internal desync は未定量★: section 内に embedded data/誤 Len op があれば local desync で false±の余地。corpus 6 は clean 実証だが全 1559 section の clean 保証ではない=★静的数は upper-bound 推定であって exhaustive 証明でない★。動的(0x46=6/0x79=1)が confirmed-reached の floor。
- content-end 以降 / subtable 非参照領域は非走査(section 起点 walk ゆえ)。

### OI-7 結論
- ★0x79 の静的上界 = 4 site(2 entry: 151+176)、動的到達=1★。『1 site』は dynamic-reached の意味で正、static 上界は 4(H4 開放が正しかった)。
- 0x46 静的上界 ≈ 19 site(16 entry、entry0 desync 除外)、動的 6・corpus 6 ⊆ 静的。
- ★step4 差分テスト corpus(6 site)は動的到達の代表集合として妥当(design §3 の corpus 指定は reached 挙動検証に正しい選択)★。静的追加 site(entry176 0x79 等)は本 step の実装対象挙動(A2/A3 registry add/remove)に同機構ゆえ、忠実度は corpus 6 で担保、静的追加は同型(別 entry での同 opcode)。

---

## 7. 未確定残(promote 禁止・honest gap)
- 2段目 0x800a1348(0x46 activate)/ 0x800bb968(0x79 deactivate)= actor の実体(sprite/NPC/object)と activate 内容 = 2段以深、未RE。
- registry @0x80164098 の slot 値の semantics(actor id 空間)= 3段目 + corpus 依存。
- census §5 stream-content(0x46 連番 01-04 / 0x79 operand 0x01 / 隣接 pattern / site 数)= corpus 走査で裏取り要(handler では非確定)。
- 0x46 直後の 0x47 = ★MAP_CHANGE(既確立 RE、handler 0x800ED4A0→warp executor 0x800bb544、operand=map/spawn/mode)★。step4 実装対象は 0x46/0x79(0x47 は C# 実装済)。0x46 registry id == 0x47 map id の値一致機構(§6bis id 空間観測)= 0x46 activate/registry semantics RE 後。
