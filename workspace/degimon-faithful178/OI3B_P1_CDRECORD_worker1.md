# OI-3b p1① scene 0x21 実体 CD record RE(worker1)

**date**: 2026-07-19 / worker1 / ★read-only RE(コード変更ゼロ)、R2(OI-3b)p1、cutoff 規範★
**material**: EXE=slps_017_97.bin(base 0x80090800)/ DG disc=degimon/degimon.bin / extracted=degimon/CD/DEGIMON/ + degimon/extracted/。tool=exedis.py。gp=0x80144E0C。
**規律**: 観測(disasm/hex paste)/推論 区分。2-3反復 cutoff。promote 禁止。

---

## 0. 結論(単一表)★重要=R2 前提の再検討要★

| 項目 | 判定 | 次元 |
|---|---|---|
| scene 0x21 の CD filename | ★**FAALL.VHB**★(gp-0x77d4="FAALL" + gp-0x77cc=".VHB"、0x800cf4b0 で連結) | 観測 |
| filename base の所在 | ★static bin(.data、0x8013D638="FAALL\0..VHB")=読取可★ | 観測 |
| FAALL.VHB の実体 | ★**VAB 音源バンク**(CD/DEGIMON/sound/vhb/faall.vhb、2.6MB container+VAB、faall.vab magic="pBAV"=VABp、10 sample faall_1..10.wav)★ | 観測 |
| ★0x66 『scene』の正体★ | ★**音源(sound/VAB)バンク load**=視覚 scene でない疑い濃厚★ | 観測+推論 |
| variant(a1 0-3)の asset 分岐 | post-load(faall.vhb 内のどの sample/mode か)= sibling scene 関数(gp-0x6da0 消費)側=cutoff | 推論 |
| record 構造((id-1)*39) | offset/record 意味は 4-5段目=cutoff(候補: faall.vhb 内 offset or directory record) | honest gap |

---

## 1. filename 構築(観測、EXE 直読)

- 0x800cf400 → 0x800cf0e4(a1=gp-0x77d4)→ 0x800cf4b0(dest, s2, gp-0x77cc):
  - ★0x800cf0e4: `strchr(gp-0x77d4="FAALL", 0x5c='\')` → 無し(NULL)→ s2=gp-0x77d4="FAALL"(path sep 無ゆえ全体)★。
  - ★0x800cf4b0 = 文字列連結: dest = s2("FAALL") + gp-0x77cc(".VHB") + '\0' = **"FAALL.VHB"**★(観測: loop で s2 コピー→s1 コピー→null 終端)。
- ★gp-0x77d4(0x8013D638)static bin 実読★: `46 41 41 4C 4C 00 00 00 2E 56 48 42 00` = "FAALL\0\0\0.VHB\0"。gp-0x77cc(0x8013D640)=".VHB"。★両 static .data=読取可(RAM populate でない)★。
- → ★scene 0x21 が load する CD file = **FAALL.VHB**★(filename は static、直読確定)。

## 2. FAALL.VHB の実体=VAB 音源バンク(観測、disc)

- ★degimon.bin(disc image)内に "FAALL.VHB" 実在★(ISO9660 dir、offset 335425987/348939968、grep 確定)。
- ★CD/DEGIMON/sound/vhb/faall.vhb(2.6MB)★=sound/vhb dir 配下=音源バンク format。vhb dir 一覧: esall/faall/sb/sl/ss/vball/vlall.vhb(★7 音源バンク★、全 "XXall/XX" 命名)。
- ★faall.vab(extracted)magic="pBAV"=**VABp**(PSX VAB=sound bank)★。faall.vhb header=`10 00 00 00 30 14 00 00 80 d4 00 00 40 d6 00 00`(container header+offsets、内部に VAB)。
- ★faall_1..10.wav(extracted)=RIFF/WAVE(10 sample)★=faall バンクの 10 音源。
- → ★FAALL.VHB = 音源(VAB)バンク=確定★。scene 0x21 が load するのは **audio asset**。

## 3. ★R2 前提の再検討(観測ベースの reframing)★

- ★OI-3b/R2 の当初前提『visual scene presentation』は、scene 0x21 の実 asset が **音源バンク(faall.vhb)** ゆえ **再検討要**★。
- ★0x66 chain の semantic 更新(推論)★: 「0x66 = partner form に応じた scene 選択」の "scene" = **audio バンク/mode の選択**(record 0x21=faall バンク固定、variant a1=form-class で bank 内の sample/mode 選択)。= ★partner の form に応じた **音(fanfare/music)** の再生/切替★。
- 根拠: (i)scene switcher 0x800cfdf0 が load する唯一 asset=faall.vhb(0x800cf400、OI-3a §9-1 で単一 file load 確認)。(ii)faall.vhb=VAB 確定(§2)。(iii)variant→gp-0x6da0→sibling scene 関数消費(OI-3a §9-5c、post-load 分岐)。
- ★honest 限定★: 本 RE は scene selector(0x800cf400)が load する asset=音源 を確定したのみ。0x66 が **別経路で視覚要素も trigger するか**(他 block/handler)は未確認=『0x66=音のみ』とは断定しない(scene selector の asset は音、と限定 claim)。

## 4. variant(a1)の asset 分岐(所見、cutoff)

- variant a1(§1 OI-3a=form-class で 0/1/2/3)は record(0x21=faall.vhb 固定)を変えず、★load 後の処理で分岐★(gp-0x6da0=current variant を sibling scene 関数群が消費=OI-3a §9-5c)。
- → ★record 単位でなく post-load(faall バンク内のどの sample/group/mode を鳴らすか)で variant 分岐、が有力★。faall_1..10 の 10 sample から form-class で選ぶ形と整合(推論、要 4段目確認=cutoff)。

## 5. record 構造((id-1)*39)= honest gap(cutoff)

- 0x800cf400: a3=(id-1)*39(id=0x21→32*39=0x4E0)+ stack-arg 0x27(=39=record stride)→ 0x800cf0e4 → 0x800a49a4(CD read、offset/param)。
- ★(id-1)*39 の意味=4-5段目(cutoff)★: 候補=(a)faall.vhb 内の 39-byte record offset /(b)directory record index。faall.vhb は VAB header 始まりゆえ 39-byte-record container と単純両立しない=exact 解釈は要深追い(cutoff、OI-3b p1② 候補)。
- 0x66 では record=0x21 固定ゆえ offset=0x4E0 固定(scene selector としては単一 record)。

---

## 6. 未確定残(promote 禁止・honest gap)
- ★(id-1)*39 record 構造の exact 意味(faall.vhb offset vs directory record vs VAB sub-index)★=4-5段目 cutoff(OI-3b p1②)。
- ★0x66 が scene selector(音源)以外に視覚要素を trigger するか★=他 block/handler 未走査=『scene selector asset=音源』限定 claim。
- variant a1→faall.vhb 内の具体 sample/mode mapping=post-load 処理(sibling scene 関数群、gp-0x6da0 消費)未 RE。
- 2.6MB faall.vhb vs SPU 512KB=全 load か部分/stream かの load 機構=未 RE。
- FAALL 命名の意味(fanfare/field-area/music の別)=命名規則(esall/vball/vlall 等)からの推論止まり。

## p1④. variant → audio 挙動 機構 RE(2026-07-19、R2' PRESIDENT 承認)★SEQ 音楽確定★

### 消費 chain 特定(観測)
- variant(a1)→ RawE06C 相当=★gp-0x6da0(cur_variant)★。主消費=★finalize 0x800cf29c★(gp-0x6da0 読取)。scene param gp-0x6dcc は sibling(0x80105e04 等=scene-id 別 dispatch、variant 消費でない)。

### ★variant → sub-asset index 機構(finalize 0x800cf29c、全長、観測)★
```
800CF2A8 s0 = 0x8015102c                    ; loaded faall.vhb data(memcpy 先)
800CF2B0 v0 = *(s0)                          ; word0
800CF2B8 v1 = v0 >> 2                         ; ★count = word0/4(offset table entry 数)★
800CF2BC v0 = [gp-0x6da0] = variant
800CF2C4 if variant >= count: [gp-0x6da0]=0  ; ★variant clamp to [0,count)★
800CF2DC v0 = variant * 4
800CF2E4 v0 = *(0x8015102c + variant*4)       ; ★offset[variant](offset table を variant で index)★
800CF2EC a0 = 0x8015102c + offset[variant]     ; ★variant の sub-asset(SEQ data)★
800CF2F0 a1 = 2 ; jal 0x800d6318              ; ★SsSeqOpen(§下)★→ handle
800CF2FC [gp-0x6da4] = handle
```
→ ★variant(form-class)が loaded faall.vhb 内の **offset table を直接 index**(variant*4→offset[variant])→ その sub-asset を open★。★どの index がどう決まるか=variant 値そのもの(clamp 済)が offset table index★=推測なし・RE 接地。

### ★sub-asset = SEQ 音楽シーケンス確定(観測、決定的)★
- 0x800d6318 = handle allocator(bitmap free-mask 0x8015_7044、slot scan)。★error path 文字列(0x8011AEA8)= **"Can't Open Sequence data any more"**★=SsSeqOpen 相当(PSX SEQ=音楽シーケンス open、table 満杯 error)。
- → ★sub-asset = **SEQ(音楽シーケンス)data**。0x800d6318 = SEQ open(handle=gp-0x6da4)★。
- 0x800cf314: 0x800d7018(handle=gp-0x6da4, 0x50, 0x50)= SEQ 再生/音量 op(0x50/0x50=vol L/R=80/80 の公算、object table 0x8015_70e0[handle]+0x98 state)。=★SEQ play★。
- ★p1① の『音源(VAB)』を **SEQ 音楽(sequence)+ VAB instrument** へ精密化・確定★: faall.vhb=SEQ(曲)+VAB(音色)container、variant=どの SEQ(曲/BGM/fanfare)を鳴らすか。★sprite/視覚でなく音=ambiguity 解消(error 文字列が SEQ を pin)★。

### mapping(condition3=推測禁止、RE 接地)
- ★variant → offset[variant] → SEQ = 機構確定(推測なし)★。variant は offset table の直接 index(clamp [0,count))。
- ★faall_1..10.wav(VAB instrument sample)↔ variant の対応は **主張しない**★: variant が選ぶのは **SEQ(曲)**であって VAB sample でない(SEQ が VAB 音色を使って演奏)。variant→具体 SEQ の対応は loaded faall.vhb の offset table 内容(RAM、要 dump)=cutoff。★index 機構(variant→offset[variant])で足りる(boss1 指定)★。

### callback 0x80106754(per-scene task、概要)
- 0x66 param-list(0x801066cc)が登録した per-scene task。descriptor 0x8013CDB4 read + per-scene table @0x801684a4(stride12、(id-2))の +8 field(slti 5 check)を処理=per-scene update task(scene 進行の frame 処理)。★variant→audio の直接消費でない(scene entry 管理側)=概要止め cutoff★。

### 2.6MB VHB vs SPU 512KB(1 行 optional)
- faall.vhb(2.6MB)は SEQ(曲 data、main RAM)+ VAB(音色、SPU upload)の container。SEQ data は main RAM 保持(SPU 非常駐)、VAB 音色のみ SPU=2.6MB>512KB と矛盾しない(SEQ は SPU 外)。★推論(cutoff、要確認)★。

---

## 7. R2 設計への含意(観測接地、次 scoping 材料)
- ★R2 は『視覚 scene』でなく『form-appropriate 音源(faall バンク)の load/再生』を実装対象とすべき(前提訂正)★。
- remake 実装=faall.vhb 相当の音源 asset + form-class→sample 選択(§4)+ audio 再生機構。step3 DG.SCN/MAPHEAD(REFUTE 済、OI-3a §9-6)とも別、音源層。
- ★R1 の [SCENE-SWITCH] log(record 0x21, variant)は『どの音を鳴らすべきか』の観測 oracle として R2(音源)に直結★=R1 が R2 の音源 scoping を兼ねる(OI3A_Q2 §2 R2 の想定と整合、但し asset=音源へ訂正)。
