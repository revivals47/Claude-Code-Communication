# R2B scene 遷移 audio 資源 load 機構 静的 RE — bank 部分読込仮説の chain 特定 — worker1

**date**: 2026-07-19 / worker1 / ★read-only 静的 EXE RE、doc-only、部分先出し版(worker3 対照実測と突合)★
**契機**: live A/B で capture pipeline 無罪確定、真因=forced-fire 文脈が SEQ 再生を途中から壊す。user 証言「知ってる曲の冒頭→途中でエラー曲化」=★bank 部分読込仮説★(冒頭=常駐/共通楽器で正、途中=未転送楽器で崩壊)。
**起点**: OI3B_P1_CDRECORD §p1④(switcher→finalize chain)。tool=scratchpad mdis.py/xref.py。
**規律**: 観測(disasm/xref)/推論/honest gap。address+期待値で worker3 対照実測可能な形。scan 範囲明記。

> ★★訂正適用 banner(2026-07-20、settle 訂正 list C1 適用、真因 = 三段反転後の最終確定)★★
> 本 doc の「bank 部分読込/SB 上書き」仮説は **棄却**。真因は二段反転を経て **CPU crash(Data Bus Error、EPC=0x800C9E3C、fire+10.4s、forced-capture artifact)= parser 0x800c9cbc の未初期化 offset [P+0x90] による wild pointer** に確定(R2B_FIX_DESIGN §10、Run A 全層 PASS で実証、1 word 除去=DG_LATE_DEREF で根治)。
> ★§78「settle=崩壊状態」の訂正方向は不変で有効(settle 部が崩壊部・artifact である事実は Run A で最終実証)。但し崩壊の**原因**は SB 上書きでなく CPU crash★。§7-11 の SB 上書き機構記述は「棄却済仮説の trail」として保持(将来の SPU RE 資産、PRESIDENT 評価)。

---

## 0. 結論(bank 部分読込仮説を chain が支持)

★per-scene の scene 切替 chain は **SEQ(曲)のみ reload**、**VAB(楽器 bank)の SPU 転送を含まない**。SEQ は固定 **vab_id=2** に bind ゆえ、vab_id=2 の VAB が resident(別所で 1 回転送)である前提。forced-fire(DG_RESTORE、scene28 savestate)は VAB を転送する field/sound-init 層を経ないゆえ、resident vab_id=2 が FAALL 完全 bank でない/部分 → SEQ が未転送楽器を参照 → 冒頭(共通楽器)正・途中(FAALL 固有楽器)崩壊★=user 証言と機構的に一致。

---

## 1. scene 切替 audio chain の実行順序+address(req1、観測)

switcher 0x800cfdf0(record,variant)が switched 時に呼ぶ chain(0x800cfe54-0x800cfea0、直読):
```
0x800cfe54 jal 0x800cf074   ; teardown1(前 SEQ 停止系)
0x800cfe5c jal 0x800cf0a8   ; teardown2
0x800cfe78 jal 0x800cf400   ; ★CD load(record 変化時のみ、0x800cfe6c beq でgate)★
0x800cfe98 jal 0x800cf29c   ; finalize(SsSeqOpen)
0x800cfea0 jal 0x800cf314   ; play(SsSeqPlay)
```

### 1-A. CD load 0x800cf400(観測)= FAALL を main RAM へ、SPU 転送なし
```
0x800cf440 a1=gp-0x77d4="FAALL"; jal 0x800cf0e4(CD read/filename、+gp-0x77cc=".VHB")
0x800cf464-484 CD dir entry([s0+8],[s0+0xc])から src/size 算出
0x800cf488 a0=0x8015102c(dest); jal 0x80091450 ; ★memcpy(0x8015102c ← FAALL.VHB、size分)★
```
→ ★FAALL.VHB を **main RAM 0x8015102c** へ copy するのみ。VAB→SPU 転送は含まない★。

### 1-B. finalize 0x800cf29c(観測)= SEQ open、vab_id=2 bind
```
0x800cf2a8 s0=0x8015102c
0x800cf2b8 count = [0x8015102c] word0 >> 2         ; SEQ offset table entry 数(FAALL word0=0x10→count 4)
0x800cf2c4 variant(gp-0x6da0) clamp(範囲外→0)
0x800cf2e4 offset[variant] = [0x8015102c + variant*4]
0x800cf2ec a0 = 0x8015102c + offset[variant]        ; ★variant の SEQ 実体(main RAM)★
0x800cf2f0 a1 = 2 ; jal 0x800d6318(SsSeqOpen)        ; ★vab_id=2 に bind★
0x800cf2fc [gp-0x6da4] = handle                       ; SEQ handle
```
→ ★0x8015102c = SEQ offset table(word0=count)+ SEQ 実体。SsSeqOpen a1=**2**=SEQ は **vab_id 2** の楽器を使う★。

### 1-C. play 0x800cf314(観測)= handle gate + SsSeqPlay
```
0x800cf31c v0 = [gp-0x6da4](SEQ handle)
0x800cf324 beq handle,-1,skip                         ; ★handle==-1(open 失敗)なら play せず★
0x800cf32c a0=handle; a1=0x50; a2=0x50; jal 0x800d7018(SsSeqPlay、vol L/R=0x50=0.625)
```

## 2. load 完了 signal/gate + forced-fire skip(req2、観測+推論)

- ★SEQ 完了 signal★: SsSeqOpen(0x800d6318)の戻り handle(gp-0x6da4)。play は handle≠-1 を gate(0x800cf324)。= SEQ 側の gate は「open 成功」のみ。
- ★VAB は per-scene chain に無い★(§1): SEQ は vab_id=2 に bind するが、その VAB を転送する段が switcher chain に存在しない=**VAB は resident(前もって転送済)前提**。
- ★VAB 転送層 = sound-init 0x800cf548★(観測): SsInit 系(0x800d62d8)+ SsSetMVol(0x800d6730、0x7f/0x7f)+ **bank loader 0x800ceec8 を 3 回**(0x800cf594 a0=0/SOUND\SS、0x800cf5c4 a0=1/SOUND\SL、0x800cfce8 a0=8/SOUND\SB)。0x800ceec8=file load(0x80091430)+filename build(gp-0x77cc=.VHB)+転送 wrapper(0x800a46dc)。
- ★sound-init 0x800cf548 の caller=0x80117078/0b0/104/274(全 0x80117xxx=field/game init 層)★。→ **forced-fire(DG_RESTORE、scene28 savestate 直挿し)は field init(0x80117xxx)を経ない**ゆえ、vab_id=2 の VAB 転送が実行されない/scene28 の別 bank が resident=**bank 部分読込の機序**(推論、worker3 SPU dump で確定)。
- ★DG_RESTORE が skip するもの(推論)★: field/sound-init 層の VAB→SPU 転送(vab_id=2=FAALL 相当 bank)。savestate は scene28 常駐時の SPU 状態ゆえ、FAALL scene-audio 用 VAB が未転送/部分 → SEQ(vab_id=2 bind)が正しい楽器を得られず途中崩壊。

## 3. worker3 対照実測 address 指名(req3、natural vs forced dump)

| 対象 | address | 期待値/確認 |
|---|---|---|
| FAALL SEQ container(main RAM) | **0x8015102c** | word0(=offset count、FAALL 正=0x10→4)。natural/forced で同一か(SEQ 自体は per-scene load ゆえ両者同じはず) |
| SEQ handle | **gp-0x6da4**(=0x80144E0C-0x6da4=0x8013E068) | SsSeqOpen 戻り。≠-1(open 成功) |
| current variant/record | gp-0x6da0 / gp-0x6da2 | fire 時の variant |
| ★vab_id=2 の SPU 転送先 SPU RAM★ | ★worker3 が libsnd の VAB table(vab_id 2 の SPU addr/size)を dump→その SPU RAM 領域★ | ★natural(=正常曲)と forced(=崩壊曲)で **vab_id=2 の SPU RAM 内容/size を bit 比較**★。差分=bank 部分読込の直接証拠。差分ゼロなら仮説 REFUTE(別機序) |
| bank loader descriptor | 0x8013420c(SOUND\SS)/0x80134218(SL)/0x80134224(SB) | 効果音 bank path(音楽 bank でない) |

★核心実測★: **vab_id=2 の SPU RAM 領域を natural(正常)vs forced(崩壊)で dump 比較**。bank 部分読込なら forced 側で vab_id=2 の VAB が欠落/部分/別 bank になっているはず。= 仮説の REFUTE 可能な直接 oracle。

## 4. honest gap / cutoff(promote 禁止)

- ★vab_id=2 に FAALL(音楽)VAB を転送する正確な site 未特定★: sound-init 0x800cf548 は SOUND\SS/SL/SB(効果音)を転送。音楽 bank(VLALL/VBALL/ESALL/FAALL、gp-0x77ec/e4/dc/d4)の VAB 転送は別 site(0x800cfbd8/c8c/db8 load 関数 or field-area entry)=次段追跡。vab_id 番号(転送順で auto-assign)の 2=どの bank かは 0x800a46dc(SsVabTransBody wrapper)の呼出順 trace 要=cutoff。→ ★worker3 SPU dump(vab table)が vab_id=2 の実体を直接確定するのが最短★。
- ★FAALL.VHB の内部 layout(VAB portion vs SEQ portion)未確定★: OI3B_P1_CDRECORD §2 は faall.vhb=VABp magic とするが、0x8015102c(0x800cf400 load 先)は finalize で SEQ offset table(word0=0x10)として読まれる=SEQ container。→ 0x800cf400 が FAALL.VHB の SEQ 部分のみ load か、FAALL.VHB=SEQ+VAB 複合かは worker3 の 0x8015102c dump(先頭が VABp"pBAV" か offset table 0x10 か)で確定。
- ★『settle 部=3-voice 真 BGM』旧解釈の再解釈★: 本 chain RE より、settle 部(途中以降)は **崩壊後の姿(vab_id=2 楽器欠落で voice 数減)の可能性**が高い(user 証言+§0)。過去 doc(3-voice=真 BGM)の訂正は worker3 SPU dump で崩壊確定後にまとめて。
- ★0x800a46dc(VAB 転送 wrapper)の SsVabTransBody 同定+vab_id 戻り値★=次段(部分先出し後 継続)。

## 4-bis. 継続 RE: VAB 転送は 2 層(観測)

part先出し後の継続で、VAB→SPU 転送は **2 つの独立層**と判明:
- ★層(i) 効果音 bank★: sound-init 0x800cf548 → bank loader 0x800ceec8 ×3(SOUND\SS/SL/SB)→ 0x800a46dc(SPU 転送、0x7ff/0x800 align=SsVabTransBody 系)。caller=0x80117xxx(game/field init)。
- ★層(ii) 音楽 bank★: 音楽 load 関数 **0x800cfb78**(VLALL a0=3/gp-0x77ec ほか、0x800cf0e4 CD read + 0x800cfc20 bank-index dispatch 転送)← caller=**0x800a6330**(per-scene switcher でも 0x80117xxx 一般 init でもない別関数=scene/area 遷移系の疑い)。
- → ★per-scene switcher(SEQ reload)/効果音 init(0x80117xxx)/音楽 VAB load(0x800a6330)= 3 層が分離★。SEQ が bind する vab_id=2 の VAB が層(ii)由来なら、**forced-fire(DG_RESTORE)が 0x800a6330 経路(音楽 VAB 転送)を経ないことが崩壊の直接因**(推論、worker3 SPU dump で確定)。
- honest gap 継続: vab_id 番号(SsVabTransBody auto-assign 順)の 2=VLALL/VBALL/ESALL/FAALL のどれか、0x800a6330 が field-area entry か否か(caller 逆探索が関数境界で途切れ=未確定)=worker3 SPU dump(vab table の vab_id=2 実体)+ natural/forced の 0x800a6330 到達有無 log で確定。

## 5. 対策(A/C)設計材料(worker3 bank 仮説確定後、観測+推論)

worker3 三重接地((1)VAB 領域不変(2)pQES 確定(4)loader 0 call)で bank 仮説 runtime 確定=本静的 chain と一致。強制 VAB load 実験の設計材料:

### (1) 音楽 VAB load の入口・引数・前提(観測)
- ★入口関数 = 0x800cfb78(音楽 VAB loader)★: 内部で 0x800cf0e4(CD read)+0x800cfc20(bank-index dispatch 転送)で **VLALL/VBALL/ESALL の VAB を SPU 転送**(固定 file set。a0 は 0x42 閾値で params(s1)を変えるのみ=file 選択でない)。∴ **どの妥当 a0 で呼んでも音楽 VAB set が転送される**。
- ★caller = 0x800a6330★(音楽 load の単一 caller): 呼出直前に **gp-0x6ed2=0 / [0x8016B0D8]=4 を set**(0x800a631c-28)して a0=s0 で 0x800cfb78 を呼ぶ。0x800a6330 の関数境界は caller 逆探索が途切れ=area/scene 遷移系の疑い(worker3 実測で到達 context 確定)。
- ★DG_RESTORE forced から呼ぶ追加前提★: 0x800cf0e4=CD read ゆえ **CD が readable(disc 装填/CD subsystem init 済)**が必須。forced 文脈(scene28 savestate)で CD read が動作するかは worker3 実測要(savestate は SPU/CD state を含むか)。gp 前提=上記 gp-0x6ed2/0x8016B0D8 の set は 0x800a6330 が行うゆえ 0x800a6330 経由で呼べば充足。

### (2) scene33 SEQ(vab_id=2)が要求する VAB の同定(静的+worker3 突合)
- ★FAALL は per-scene で SEQ のみ(0x800cf400、§1-A)。vab_id=2 の VAB は FAALL でなく、0x800cfb78 が転送する音楽 VAB(VLALL/VBALL/ESALL)のいずれか★(SEQ が別 file の VAB を参照=PS1 の SEQ+VAB 分離構造)。
- ★静的転送順★: 0x800cfb78 → VLALL(a0=3、0x800cfbd0)先頭 → 0x800cfc20 dispatch(a0=4→VBALL/gp-0x77e4、以降 ESALL)。SsVabTransBody auto-assign は転送順に vab_id 0,1,2… → ★vab_id=2 = 音楽 VAB の 3 番目★(効果音層 0x80117xxx の SS/SL/SB 転送順と合算した全体順で決まる)。
- ★precise な vab_id=2 の file 同定は worker3 (5) 実測に委譲★(SsVabTransBody 全 call 順の runtime trace が authoritative。静的 auto-assign 全順序 trace は効果音+音楽の 2 層合算で cutoff)。本静的 chain=「vab_id=2 は 0x800cfb78 が転送する音楽 VAB のどれか、FAALL SEQ が bind」まで確定。worker3 (5) と突合で file 名確定。

### (3) 呼出 point 案: C 案(事前 load)vs A 案(fire 後 reload+restart)
- ★原盤 natural 順序(観測)★: area-entry(0x800a6330)で音楽 VAB を SPU 転送 → **その後** scene fire(0x66→switcher→finalize SsSeqOpen が resident vab_id=2 に bind→play)。= ★VAB は SEQ open **前**に resident★(finalize は VAB を転送しない=resident 前提、§1-B)。
- ★∴ C 案(fire 前に 0x800cfb78 で音楽 VAB を事前 load)が原盤挙動★: SsSeqOpen の前提(vab_id=2 resident)を原盤同様に満たす。chain 根拠=finalize が VAB 非転送=VAB は必ず先行 load。
- ★A 案(fire 後に VAB reload→SEQ 再 start)は非原盤★: 原盤は SEQ open 後に VAB を reload しない。かつ forced-fire では SsSeqOpen が既に誤 VAB(vab_id=2 不在/別)で走った後ゆえ SEQ restart が必要=二度手間+原盤に無い順序。
- ★単一推奨=C 案★: worker3 probe が forced 0x66 の**前**に 0x800cfb78(or 0x800a6330)を呼び音楽 VAB を SPU 転送→その後 0x66 fire→SsSeqOpen が正 vab_id=2 に bind→正常再生。前提=CD readable(§(1))。

### 対策実装の worker3 probe 指名
- probe: forced fire sequence の**前**に 0x800a6330(gp 前提 set 込み)or 0x800cfb78 を call し音楽 VAB を SPU 転送。
- 検証: 転送後の SPU RAM(vab_id=2 領域)が natural 正常曲と bit 一致 → その後 fire した SEQ 再生を r2b_oracle.py で判定(症状 signature ゼロ=C 案成功)。
- honest gap: CD read が forced 文脈で動くか(§1)、0x800a6330 の完全前提(gp state 全部)=worker3 実測で確定。

## 6. 部分先出し note
本版は switcher chain(§1、SEQ-only 確定)+ VAB resident/forced-skip 機序(§2、推論)+ worker3 address 指名(§3)を先出し。remaining=vab_id=2 の FAALL VAB 転送 site 精密特定(§4)を継続。worker3 の vab_id=2 SPU dump 比較(§3 核心)が並行で回れば、静的 chain(本 doc)× 実測 SPU 差分 で bank 部分読込を確定できる。

## 6. reverb chain RE(新指示#1、観測)★reverb-overwrite-of-VAB 仮説を静的 REFUTE★

- ★reverb setup site★: sound-init 0x800cf548 内 — 0x800cf640 jal 0x800d1eb8(a0=**3**=reverb type 3 設定)/ 0x800cf648 jal 0x800d1e08(SPU reg write)/ 0x800cf660 jal 0x800d1e88(a0=1,a1=0x7fffff=全 voice reverb ON)。caller=0x80117xxx(field/game init 層、§4-bis と同層)。
- ★work area base 算出式(観測)★: reverb type→base は type table **0x801349d8**(type idx*4)。値=**mBASE reg 値(=base addr>>3)**。base addr = table[type]<<3:
  - type3(本 game)= 0x801349e4=**0xf6f8** → base = 0xf6f8<<3 = ★**0x7B7C0**★(work area 0x7B7C0-0x80000=18496B、SPU RAM 最上部)。
  - 全 type: type0=0x7FFF0 … type7=0x67FC0。★最大(type7)でも base=0x67FC0=VAB(0x1D000-0x2B000)の遥か上★。
- ★custom base 探索★: SpuSetReverbAddr 相当(mBASE 0x1F801DA2 write / 0x1B810>>3=0x3702 値)= **全 EXE 0 件**。→ reverb base は type table 由来(最上部)のみ、0x1B810 に設定する経路なし。
- ★判定: reverb-overwrite-of-VAB(0x1B810 で bank 破壊)仮説は静的に REFUTE★。全 reverb type の work area は SPU 最上部(≥0x67FC0)で、VAB(0x1D000)に到達しない。0x1B810-0x80000 変化域は **reverb 起因でない**(reverb は 0x7B7C0-0x80000 の top 部分のみ書込)。
- ★natural vs forced の reverb base 差★: base は type table(static)由来ゆえ type が同じなら base 同一。type 設定は sound-init(field init 層)ゆえ forced が skip すれば reverb type が savestate 値のまま=但し **どの type でも base は top(≥0x67FC0)=VAB 非到達は不変**。→ reverb type の natural/forced 差があっても VAB 破壊は起きない。
- ★構成的 redirect★: 0x1B810 変化域(VAB 0x1D000 含む)の書込主は reverb でない。候補=(b)SPU malloc/voice 割当が FAALL VAB 領域(0x1D000)を別用途で再利用上書き(forced で FAALL VAB の登録が SPU heap table に無い→後続 alloc が 0x1D000 を奪う)/(c)別 sound(SFX)転送が overlap。→ 次段=#2(FAALL VAB load site+SPU heap 登録)+#3(vab table)で「0x1D000 が誰に上書きされ得るか」を追う方が機構に近い。
- worker3 reverb_base 実測との突合: ★予測=reverb base=0x7B7C0(type3)。worker3 実測が 0x7B7C0 なら reverb-overwrite REFUTE 確定。もし 0x1B810 付近なら custom base 経路の見落とし(要再走査)だが静的には 0 件★。

## 7. #2/#3: SB 上書き機構(worker3 SB実測 23:48 突合、観測)★SPU heap free-list 不整合★

worker3 実測: 0x3B810-0x76340(234KB)=fire時ESALL→settled時SB(効果音)で丸ごと上書き、SB=fire時非常駐→fire後load。FAALL前半0x1D000-0x24800=96%変化。

### #2(α) SB loader の trigger ★boss1 REFUTE(2026-07-19 23:54)=trigger 未接地に downgrade★
★訂正(lexical-scope 誤り、自案件)★: 0x800cfce8 は **独立関数 0x800CFCC8**(0x800CFCC8-0x800CFD14、frame -0x18、gp-0x77c4=-1 set→a0=8/a1=0x80134224 SB descriptor→0x800ceec8)の内部。sound-init 0x800cf548 は lexical に 0x800CF6EC 付近で終端 → **『SB 転送=sound-init 内 0x800cfce8』は誤り**(fn scope=lexical 範囲の規範案件)。
★0x800CFCC8 への参照=主 EXE 内ゼロ★(jal 0/imm 組立 0/LE data word c8fc0c80=0)→呼出=jalr table or 計算 pointer or **overlay 側**(ovldis xref 盲点)。∴ **『fire 後 mode 遷移→sound-init→SB』の trigger 部=未接地推論に downgrade**。overlay 走査で挟撃(§8)。

### #2(α)-旧(未接地、参考)
- ★SB 転送 = bank loader 0x800ceec8(a0=8/SOUND\SB)、caller は 0x800cfce8 のみ = sound-init 0x800cf548 内★(SS 0x800cf594/SL 0x800cf5c4 と同関数)。
- ★sound-init 0x800cf548 の caller = 0x80117078/0b0/104/274(4 site、全 0x80117xxx)★=game-mode init(各 mode 遷移で sound 再init)。各 site 直前に jal 0x80104a70/0x8010496c(mode setup)。
- ★∴ SB は sound-init 経由でのみ load。fire 時 SB 非常駐(worker3)=fire は sound-init 未実行の forced 文脈。fire 後の game-mode 遷移(0x80117xxx のいずれか)が sound-init を呼び SB を load→resident 音楽 bank を上書き★。

### #2(β) 転送 dest 決定機構 = 動的 alloc(観測、固定 table でない)
- ★VAB 転送 = SsVabOpenHead(0x800a4444)→ SPU heap alloc(0x800b49f4)→ dest addr を 2KB align(0x800a46dc: +0x7ff & ~0x800)★。固定 addr 表でない。
- ★worker3 の deterministic layout(SS 0x03000/SL 0x0F000/FAALL 0x1D000/VLALL 0x2D000/VBALL 0x33000/ESALL 0x3D000)= sequential heap alloc の累積結果★(各 bank size 分 pointer 前進)。SB(248KB)が 0x3B810 に載る=「累積ポインタが 0x3B810」= ★alloc 累積の匂い(worker3 推論)を静的に裏付け★。
- FAALL SPU addr 0x1D000(>>3=0x3a00)は hardcode 無し(§6 scan)=動的 alloc 由来=固定 table 説 REFUTE。

### #3 VAB table(vab_id→SPU addr)= 0x80125e18(観測)
- ★SsVabOpenHead(0x800a4444)が VAB header を table **0x80125e18** へ memcpy(0x5c byte)、SPU alloc addr を格納★(s0=0x80125e18 起点、per-vab_id slot)。→ ★vab_id=2 の SPU start addr は 0x80125e18 の vab_id=2 slot にある★=worker3(iii)実測 dump 対象(stride は runtime 確認、memcpy 0x5c/s0+=0xc 併存ゆえ実 stride は worker3 dump で確定)。
- SEQ(finalize a1=2)は vab_id=2 の SPU addr を table 0x80125e18 から引く→その SPU RAM(0x1D000)の楽器を鳴らす。SB 上書きで 0x1D000 前半が壊れれば SEQ の楽器が崩壊。

### 機構(統合、静的×worker3)★SPU heap free-list 不整合★
- ★forced 文脈: 音楽 bank(FAALL/VLALL/VBALL/ESALL)は SPU RAM に resident(savestate bytes)だが、SsVabOpenHead/SPU heap(0x800b49f4)の free-list には未登録(forced が field-init の alloc 列を skip)★。
- ★fire 後、game-mode 遷移が sound-init→SB を SsVabOpenHead で alloc。heap free-list は 0x3B810(ESALL の位置)を空きと誤認→SB(248KB)を 0x3B810 から書込→ESALL 上書き。同様に FAALL 前半も別 alloc/上書きで 96%変化★。
- = 「bytes は resident だが heap allocator が知らない→後続 alloc が奪う」= §6 redirect の候補(b)が worker3 SB 実測で確定方向。

### 対策標的(設計材料)
- ★fix-point = SPU heap free-list を resident 音楽 bank と整合させる★: (i)forced 起動時に音楽 bank を SsVabOpenHead に登録(heap pointer を 0x43000 以降へ進める) (ii)field-init の alloc 列(0x800a6330 音楽 + 0x800cf548 効果音)を fire 前に正順で走らせ heap を正しく積む(=C案の拡張、但し reverb でなく heap 整合が目的) (iii)post-fire の sound-init(SB load)を抑止。
- worker3 write-tracker との突合: SB を 0x3B810 に書く PC=0x800a46dc(SsVabTransBody core 0x800b7170)経由、alloc addr 決定 PC=0x800a4444/0x800b49f4。FAALL前半を書く PC も write-tracker で同定→上書き主(SB alloc か別 bank か)確定。

### honest gap
- 音楽 bank(FAALL VAB 含む)の field-init 転送 site の正確 PC(0x800a6330 経路の全 SsVabOpenHead 呼出順)=vab_id 割当順の完全 trace は未(worker3 (iii) VAB table dump + write-tracker が最短)。
- SPU heap free-list global の実体(0x800b49f4 内)=libspu SpuMalloc 管理域=worker3 runtime dump で確定。
- ★私の §4-bis『FAALL=SEQ のみ、VAB 非転送』は誤り: worker3 実測で FAALL VAB は resident。FAALL は VAB(field-init 転送、vab_id=2)+per-scene SEQ(0x800cf400)の両方=§4-bis 訂正★。

## 8. overlay 走査: SB load trigger を接地(新指示#1、観測)★trigger=vs_rel.bin(battle/VS overlay)★

§7(α) の未接地 trigger を overlay 走査で挟撃・接地:
- ★全 overlay bin + 主 EXE を走査(jal 0x800cfcc8=0x0c033f32 + LE data c8fc0c80)★: hit = **vs_rel.bin offset 0x9954 = jal 0x800cfcc8 の 1 件のみ**(他 overlay/主 EXE=ゼロ)。→ SB loader 0x800cfcc8 の唯一の呼出元=**vs_rel.bin(VS/battle overlay)**。
- ★vs_rel.bin +0x9954 の context(relative disasm)★: 直前=actor struct setup(descriptor 0x8013cdb8 系、sb 0x35)→ **+0x9954 jal 0x800cfcc8(SB load)→ +0x996c jal 0x800cfc20(a0=4=音楽 bank dispatch)**。= vs_rel の **battle/VS sound-init sequence**(SB + 音楽 bank を load)。
- ★∴ SB 上書き trigger = battle/VS overlay(vs_rel.bin)の sound-init★。field 場面音楽 fire(forced 0x66)後、battle/VS 状態が起動し vs_rel の sound-init(+0x9954)が走ると、SB(248KB)+ battle 音楽 bank を SsVabOpenHead 動的 alloc(§7β)→ heap free-list が field 音楽 bank 領域(0x3B810 等)を空き誤認→上書き→field 音楽 SEQ の楽器崩壊=「冒頭正→途中崩壊」と整合。
- ★接地度★: 「何かが SB load を発火」= **vs_rel.bin(battle overlay)と特定**(ovldis xref 盲点だった overlay 呼出を byte-scan で接地)。**なぜ forced 文脈で battle/vs 状態が起動するか**(savestate scene28 が vs overlay 込みか、DG_RESTORE 後の game loop が battle 遷移するか)=worker3 runtime BP(0x800cfcc8 到達時の overlay 状態 + frame)で確定。
- ★兄弟 loader★: 0x800cfcc8(SB standalone loader、gp-0x77c4=-1 set→a0=8→0x800ceec8)は直前 0x800cfcc0=jr(前 fn 終端)/直後 0x800cfd14=jr で独立。SS/SL は sound-init 0x800cf548 内(0x800cf594/5c4)=別配置。→ SB のみ standalone(vs_rel 専用 entry)、SS/SL は sound-init 一括。table 構造でなく **用途別 entry 関数**。

### #2(α) 訂正後の確定 claim
- trigger = ★vs_rel.bin +0x9954(battle/VS sound-init)→ 0x800cfcc8(SB)+ 0x800cfc20(音楽)★(接地)。旧「sound-init 0x800cf548 経由」は REFUTE(lexical-scope 誤り)。
- 上書き機構 = 動的 alloc(§7β)+ heap free-list 不整合(§7 統合)は維持(worker3 SB 実測 + alloc chain jal 実在で支持)。
- worker3 突合: 0x800cfcc8/0x800cfc20 到達時の (a)overlay=vs_rel 確認 (b)SsVabOpenHead が返す SPU addr が field 音楽 bank(0x1D000/0x3B810)と衝突するか。

## 9. vs_rel VS-init 詳細(新指示#1-3、観測)

### #1 vs_rel bank-load 列 完全列挙(vs_rel +0x98d0 関数=VS sound-init)
```
+0x9930-50 actor struct setup(descriptor 0x8013CDB8/BC の +0x35 に flag)
+0x9954 jal 0x800cfcc8         ; SB load(eff果音、gp-0x77c4=-1→a0=8→0x800ceec8)
+0x9964 a0=4, a1=[0x8013CDB8]; jal 0x800cfc20  ; bank dispatch(4)
+0x997c a0=5, a1=[0x8013CDBC]; jal 0x800cfc20  ; bank dispatch(5)
+0x998c a0=0xa; jal 0x5f724…   ; 以降 vs_rel 内部関数列(0x5cd88/5d4fc/5e104/5f724/5f840/612c0/66ed4…=RAM 0x8005xxxx、boss1 追加観測反映)
```
- ★dispatch a1=[0x8013CDB8]/[0x8013CDBC]★=actor descriptor table(0x8013cdb4)の slot1/slot2 content(RAM-populate、静的 0)。0x800cfc20(a0,a1)の a0=bank index(4,5)で load file 決定、a1=param。★どの bank file かは 0x800cfc20 の a0 分岐+実 descriptor=worker3 runtime で確定★。

### #2 vs_rel RAM load base = ★0x80052ae0(二重確認)★
- ★jal 整合逆算★: vs_rel 内部 jal target 180 個中 176 個が base=0x52ae0 で file offset の addiu-sp(関数 entry)に一致=高確度。
- ★overlay loader table DATA★: 主 EXE 0x80138870-84 に **0x80052ae0** 実在(+0x80053800/0x80060000/0x80070000=section addr)=table 値で独立確認。
- → VS sound-init 関数 = +0x98d0 → RAM **0x8005c3b0**。call site +0x9954 → RAM 0x8005c434、★ra 予測=0x8005c43c★(worker3 BP: SB load 到達時 ra≈0x8005c43c で vs_rel 経由確認)。

### #3 VS-init caller trace(natural順=対策忠実性の核心)
- ★chain: 主 EXE 0x8010f710(VS mode dispatch/game-state handler、gp-0x75a0 参照)→ jal vs_rel VS init 0x80057394 → jal VS sound-init 0x8005c3b0(bank load)★。VS sound-init の内部 caller=0x80057394 単一、0x80057394 の内部 caller=0(主 EXE 0x8010f710 から)。
- ★bank load は VS-mode-entry 必須経路★(0x8010f710→VS init→sound-init が init sequence で無条件)。∴ natural VS mode 入場は必ず SB+bank を load。
- ★natural順の含意(対策核心)★: field scene33 音楽=**field state**で再生、VS init(bank load)=**VS state 入場時**(field 音楽は既に停止)。natural では **scene33-SEQ 再生中と VS bank-load は別 state=共存しない**。forced-fire の崩壊=「scene33 SEQ 再生 + VS init が共存」= **forced 文脈の unnatural 共存 artifact**(0x8010f710 VS mode が forced 文脈で走る)。

### 対策忠実性 判断材料(#3 結論)
- ★最有力=(A)natural順再現: capture を純 field state(VS mode 0x8010f710 非起動)で scene33 SEQ を fire★=natural の field 音楽再生を再現、VS bank-load 上書き無し=最も忠実。→ worker3 forced-fire harness が VS state に入る/trigger する原因の除去。
- (B)VS init 抑止(post-fire)=対症、忠実性低(VS mode 自体は原盤機構)。
- (C)SPU heap 整合(§7)=VS init を許しつつ heap を守る=複雑・非原盤。
- ★判断: natural では両者非共存ゆえ、対策は「共存させない」(A)が忠実。worker3 runtime で「forced 文脈がなぜ 0x8010f710(VS mode)に入るか」を確定→(A)の具体化(harness の state 修正 or fire を field state で行う)★。
- honest gap: 0x8010f710(主 EXE VS dispatch)の起動条件(game-state var)=worker3 runtime + 主 EXE state RE(次段)。なぜ forced savestate(scene28 field)から VS mode に入るか=savestate の game-state or DG_RESTORE 後の loop 挙動=worker3 BP。

## 10. 家族2 = 0x66 scene dispatch 自身の SB load(新指示#1、観測)★真 trigger 再接地=vs_rel でなく scene dispatch★

worker3 runtime REFUTE(0x800cfcc8=0 hits=vs_rel 経路でない)を受け、boss1 発見の家族2 を追跡:
- ★家族2 SB loader = 0x80108c00★(a0=8/desc 0x80138AC8→0x80108668、家族1 0x800CFCC8/0x800ceec8/desc 0x80134224 の並行版)。
- ★caller(α)0x80105F54 は dispatch 関数 0x80105be4 内★=**私が RE した 0x66 scene-id dispatch そのもの**(selector 0x800aed40 が呼ぶ、0x73 check+variant 選択+switcher の関数、単一 caller=selector)。
- ★dispatch 内の SB load 位置★: variant 選択(§1-A/OI3A)後、0x80105dbc→ actor/sound setup section(sb [P+0x64e]、slot loop s0=0-9 で [P+0x66c] 配列、flag gp-0x6bf4 gate 0x80105e90/ebc、lb sp+0x87>0 wait-loop 0x80105f44)→ **0x80105F54 jal 0x80108c00(SB load)**。= scene-entry の actor/sound setup の一部。
- ★∴ SB load は 0x66 scene dispatch path 上★: forced 0x66 fire → selector 0x800aeca8 → dispatch 0x80105be4 → (actor setup) → 0x80105F54 SB load 0x80108c00 → 0x80108668 → SsVabTransBody/SsVabOpenHead(0x800a4444)→ SB を SPU 動的 alloc → resident 音楽 bank 上書き。**vs_rel(家族1)不要=forced 0x66 と直接整合**。
- worker3 突合: 0x80108C00 の直上 ra が 0x80105F54+8(≈0x80105F5C、dispatch 内)なら(α)確定。worker3 chain(0x80100E6C←0x80108704←0x80108C00)の 0x80108C00 直上 ra を確認。

### #3 家族1 vs 家族2 対応表(観測)
| | 家族1(vs_rel/VS) | 家族2(scene dispatch) |
|---|---|---|
| SB loader | 0x800CFCC8 | 0x80108C00 |
| bank loader | 0x800ceec8 | 0x80108668 |
| SB descriptor | 0x80134224 | 0x80138AC8 |
| caller | vs_rel +0x9954(VS init) | ★dispatch 0x80105F54(0x66 scene path)★ |
| 文脈 | VS/battle mode 入場 | ★scene 切替(0x66)の actor/sound setup★ |
| 音楽 dispatch(0x800cfc20 類似) | vs_rel +0x9964/9984(a0=4/5) | 家族2 側の有無=次段(0x80105F54 後続に音楽 load があるか)確認 |
- ★どちらも同じ SsVabOpenHead heap(0x800a4444)を使う→どちらの経路でも heap free-list 不整合(§7)なら resident 音楽 bank 上書き★。forced 0x66 は家族2(scene dispatch)経路が本命(worker3 0-hit で家族1 除外)。

### 対策への含意(draft は HOLD、worker3 α/β 確定待ち)
- 真 trigger が家族2(scene dispatch 0x80105F54)なら、SB load は **0x66 fire の不可分な一部**(scene entry の actor setup)=「共存させない(A)」は困難(0x66 fire 自体が SB load を含む)。→ 対策は **SPU heap free-list を fire 前に整合させる(§7 (i)(ii))** が本線になる可能性(natural では heap 整合済ゆえ同 SB load でも上書きしない=forced の heap 不整合が真因)。
- ★natural で同 dispatch が SB load しても崩壊しない理由=heap free-list が音楽 bank を登録済(natural field-init 経由)→ SB は空き領域(0x43000+)へ。forced は未登録→ SB が音楽域(0x3B810)を奪う★=§7 機構と一致。→ 対策 = forced 起動時に heap free-list を natural 相当へ(音楽 bank 登録 or field-init alloc 列実行)。
- honest gap: (α)確定=worker3 ra。dispatch の SB-load section が全 0x66 fire で到達か(flag/slot gate 依存)=次段 trace。std_rel(β)の位置づけ=#2 継続。

## 11. #2 fire-frame hit#1 = FAALL VAB register(観測)★fire 自身が vab table を触る=premise P-a 支持★

- ★hit#1 fn = 0x800a49a4 = SsVabOpenHead 系★(a0=VAB header@sp+0x18 → table search 0x800a4444(vab table 0x80125e18)→ register)。worker3 実測 frame8240(fire 自身)/a2=0x4E0、ra=0x800A49D0(fn 内)。
- ★caller = 0x800cf0e4(CD-load-register 関数)の 0x800cf158★。0x800cf0e4 の caller = FAALL(0x800cf444)/VLALL(0x800cfbd8)/VBALL(0x800cfc8c)/ESALL(0x800cfdb8)。
- ★0x800cf0e4 の全 jal = 0x80091430(CD read/memcpy)+ 0x800cf4b0(filename)+ 0x800a49a4(SsVabOpenHead register)のみ。★SPU body 転送(SsVabTransBody 0x800a46dc/0x800b7170)は**無し**★。
- → ★per-scene FAALL load(0x800cf400→0x800cf0e4)= CD read + **VAB header register(SPU 予約)** のみ、body 転送せず★。body は savestate resident。
- ★§4-bis/§10 再訂正★: 「per-scene=SEQ のみ VAB 非関与」は誤り。正= per-scene FAALL load は **VAB header を SsVabOpenHead で register(vab table 0x80125e18 に登録 + SPU addr 予約)** する(body 転送は別)。∴ **fire 自身が vab table/heap を触る=premise P-a(fire path が heap 状態を変える)を支持**。
- premise 裁定材料: worker3 の 0x80125e18 dump で pre-fire に FAALL vab_id 登録が(a)無く fire で登録される=P-a / (b)既に有る=P-b。hit#1(fire の SsVabOpenHead)が登録 op ゆえ、**fire がまさに登録している=P-a 濃厚**(但し SB load の SsVabOpenHead が FAALL 予約を尊重するか=heap free-list 整合性が上書きの分岐)。

## 12. ★層 relabel consolidation(2026-07-20、stale claim 訂正=朝 session 誤誘導防止)★

本 doc §1-11 の RE 過程で **3 度の layer 誤同定**が worker3 実測 + boss1 直読で訂正された。確定 relabel を一括記録し、以下の旧 claim は **stale=不採用**とする:

| addr/構造 | 旧同定(stale、不採用) | ★確定 relabel(観測)★ |
|---|---|---|
| 0x80125e18(stride 0xc) | 「vab table(vab_id→SPU addr)」(§11) | ★CD file/resource directory(+8=filename/id key、+0=LBA)。worker3 name chase=.MMD モデル表と一致★ |
| 0x800a49a4 | 「SsVabOpenHead(VAB register)」(§11 hit#1) | ★CD-read-by-filename(directory lookup→read)★ |
| 0x800a4444 | 「vab table search」 | ★CD file lookup(directory 0x80125e18 検索)★ |
| 0x800b49f4 | 「SPU addr transform / size helper」(§7/§11) | ★LBA→MSF 変換(CD positioning、a0+150 pregap→÷75/÷60→M/S/F 3byte)★ |
| 0x8013F1A8(+0xC fn ptr) | 「SPU malloc free-list 簿記」(§7) | ★DMA/transfer queue(+0xC=DMA trigger 0x80093a58)。head=0x8013F47C★ |
| 0x8011Cxxx(count 0x8011C8A4) | 「SPU malloc 簿記(7→8=登録)」(§11 誘導) | ★voice/command transient 層(構造 0x14byte queue @[0x8011CB8C]、writer 0x80094984 直 imm 0x8011CBB0)。count 1-8=active voice 数。7→8=切り取り偶然★ |
| 0x800b43bc | 「SpuInitMalloc 簿記 init」 | 未確定(0x8013F47C=working global、簿記 init と断定できず)=honest gap |

★∴ 真の SPU VAB body 転送 dest(0x3B810 を生む式)+ その簿記は【静的に未特定】★: worker3 が 0x800b7170(SsVabTransBody core、caller に family2 chain 0x80100a08 含む)entry hook で **dest 実値(予測 0x7702=0x3B810>>3)+ ra** を捕獲中=これが真 layer の接地点。

### 確定している機構(relabel 後も不変)
- 症状=高域 collapse(R2B_WAV_DIAGNOSIS)。上書き主=SB(効果音)が音楽 bank 域(0x3B810 等)を SPU 転送で奪う(worker3 SB 実測)。
- SB trigger=家族2(0x80108c00)= 0x66 scene dispatch path(§10、worker3 α 確定待ち)。
- fire chain(0x800cf0e4)= CD read(FAALL.VHB→main RAM)。VAB body 転送は別(SsVabTransBody 0x800b7170 経路)。
- premise P'(a'/b')= worker3 の真 dest 簿記 dump で裁定(0x8013F1A8/0x8011Cxxx/0x80125e18 は全て誤 layer=裁定に使わない)。

### 静的 RE の到達限界(honest)
- 真 SPU malloc/dest 簿記 global=間接 base access ゆえ静的 blind 探索で吊れず(boss1 追試 pointer 定数も 0 件)。→ worker3 の 0x800b7170 dest+ra 捕獲(empirical)が唯一の接地路。
- 静的側の残貢献: worker3 の ra 受領後、その fn を decode(dest 算出式)=挟撃の静的側。
