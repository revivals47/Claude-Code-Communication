# OI-3: scene selector 3段目 RE(worker1)— cutoff doc

**date**: 2026-07-19 / worker1 / ★read-only RE(コード変更ゼロ)、scope先行→cutoff確定(boss1裁定)★
**material**: EXE=slps_017_97.bin(base 0x80090800)、tool=exedis.py。
**狙い**: 『0x66 selector が最終的に何を起動するか』の機構確定 + step3 MAPHEAD/RunScene 接続点特定(B4 stub→実配線の設計材料)。
**規律**: 観測(disasm paste)/推論 区分。2-3反復cutoff(boss1裁定=核心確定で深追い不要)。promote禁止。

---

## 0. 結論(単一表)

| 項目 | 判定 | 次元 |
|---|---|---|
| ★0x66 selector が最終起動するもの★ | ★**SCENE 遷移**(scene switcher 0x800cfdf0)★ | 観測(機構確定) |
| call graph | 0x800aeca8(selector)→ 0x80107258(param-list start、per-entry 0x801066cc loop)+ 0x80105be4(scene-id dispatch)→ 0x800cfdf0(scene switcher) | 観測 |
| 0x801066cc(3段目) | per-scene entry setup(table @0x801684a4、(id-2)*12 stride)+ task 登録(0x800a4060、callback 0x80106754) | 観測 |
| 0x80105be4(scene-id dispatch) | descriptor table 0x8013CDB4 で scene 解決 → type tag(first word==0x73)分岐 / sceneId<2・<0xa 分岐 → 0x800cfdf0/0x800cfdf0 | 観測 |
| ★0x800cfdf0(scene switcher)★ | 現 scene(gp-0x6da2/6da0)比較=同一 no-op / 異なれば 旧teardown(0x800cf074/0a8)→新load(0x800cf400)→現更新→finalize(0x800cf29c/314) | 観測 |
| descriptor table 0x8013CDB4 | ★RAM 実行時 populate(static bin=全ゼロ=静的読取不能)★ | 観測(coverage限界) |
| step3 接続点 | ★0x800cf400=**CD disc file load**(§9-6、MAPHEAD/GetSectionOffset と**別層**=接続 REFUTE)★。当初 overlay 候補推定は 4段目 RE で撤回 | 観測(§9 で確定) |

---

## 1. call graph(観測、step5 §4/§8 + 本RE)

```
0x66 handler(0x800EE72C)
 └ 0x800cfec4 → 0x800aeca8(scene selector、arg=E104)
     ├ 0x80107258(param-list start)
     │   └ loop: 0x801066cc(per-scene entry)×N     ← 3段目(§2)
     │       ├ table @0x801684a4((id-2)*12)へ entry設定
     │       └ 0x800a4060(task登録、callback=0x80106754)
     └ 0x80105be4(scene-id dispatch)               ← 3段目(§3)
         ├ descriptor table 0x8013CDB4 lookup(§5)
         └ 0x800cfdf0(SCENE SWITCHER)               ← 核心(§4)
             ├ 0x800cf074 / 0x800cf0a8(旧scene teardown)
             ├ 0x800cf400(新scene load、overlay)     ← step3接続点=OI-3a(§6)
             └ 0x800cf29c / 0x800cf314(finalize)
```

## 2. 0x801066cc = per-scene entry setup(3段目、全長RE、観測)

```
801066E0 (id-2)*12 で index → table @lui0x8017-0x7b5c=0x801684a4
801066FC sh 0, 8(entry)         ; entry+8 clear
80106720 sh a1, 0xa(entry)      ; entry+0xa = param(a1)
80106724 a0=0x196 a1=id a2=0 a3=0x80106754 ; jal 0x800a4060  ; ★task登録(callback=0x80106754、id付)★
```
→ 各 scene entry を table @0x801684a4(stride 12、(id-2)bias)に登録 + task system(0x800a4060)へ callback 0x80106754 で登録。★DF70 reader#1(0x800AE4FC)の (v-2)*104 と同じ -2 bias 族の別 table★。

## 3. 0x80105be4 = scene-id dispatch(3段目、観測)

```
80105C10 sh (a1) → [gp-0x6dcc]                       ; current scene param 保存
80105C1C lbu [gp-0x6dec]+0x66d → idx                  ; struct index
80105C2C-34 v0 = *[0x8013CDB4 + idx*4]                ; ★descriptor table 0x8013CDB4(lui0x8014-0x324c)★
80105C3C-44 if *(desc)==0x73: a0=0x21,a1=3,jal 0x800cfdf0 ; ★type tag 0x73 → dispatch★
80105C6C if sceneId<2: →別枝 / 80105C80 if sceneId>=0xa: →別枝 ; [2,0xa)範囲で分岐
80105C8C-A4 [gp-0x6bf4]==1 なら a0=0x21,a1=0,jal 0x800cfdf0
80105CB4+ sceneId で descriptor table 再lookup(後半分岐)
```
→ struct index or sceneId で descriptor table 0x8013CDB4 から descriptor を引き、first word(type tag、0x73 等)で dispatch。最終的に 0x800cfdf0(scene switcher)を各枝で呼ぶ。type tag 0x73 / sceneId<2 / [2,0xa) / >=0xa で処理分岐(各 scene 種別)。

## 4. ★0x800cfdf0 = SCENE SWITCHER(核心、観測)★

```
800CFE08 if s0<=0 or s0>=0x22(34): return 0          ; scene id range [1,34)
800CFE30 if s0==[gp-0x6da2] && s1==[gp-0x6da0]: return 1  ; ★現 scene と同一=no-op★
800CFE54 jal 0x800cf074 ; 800CFE5C jal 0x800cf0a8     ; ★旧 scene teardown★
800CFE74 if s0!=current: jal 0x800cf400(s0)           ; ★新 scene load(§6)★
800CFE88 [gp-0x6da2]=s0 ; 800CFE94 [gp-0x6da0]=s1      ; ★current scene 更新★
800CFE98 jal 0x800cf29c ; 800CFEA0 jal 0x800cf314     ; finalize
800CFEA8 return 1
```
→ ★scene switcher: (s0,s1)=(scene-id, param)。現 scene と同一なら no-op、異なれば 旧 teardown→新 load→current 更新→finalize★。= 0x66 selector が最終的に起動する『scene 遷移』の実体。scene-id 空間 [1,34)。

## 5. descriptor table 0x8013CDB4(観測、coverage限界)

- ★lui0x8014 + (-0x324c) = 0x8013CDB4 確定★(0x80105be4/0x80106754 両者が同 base 参照)。
- ★static bin 読取=全ゼロ★(0x8013xxxx=RAM data 領域、EXE .data でなく実行時 populate)=★静的に descriptor 内容(first word type tag の全種、pointer 先)を読めない=coverage限界★。type tag 0x73 は code の比較定数から観測、他 tag/pointer 先は RAM dump or 動的 trace が要(未実施)。

## 6. step3 接続点=0x800cf400 scene load(観測+推論、OI-3a)

```
800CF410 lui s0, 0x8001 ; 800CF41C lui a2, 0x8001     ; ★0x8001xxxx=PSX overlay load 領域★
800CF428-38 (a0-1)*? index 計算
800CF43C a0=2 a1=gp-0x77d4 ; jal 0x800cf0e4           ; overlay/section load 系
```
→ 0x800cf400 = scene load(lui0x8001 領域)=当初 step3 MAPHEAD/RunScene interface の候補と推定。★【訂正: §9-6 で REFUTE】OI-3a 4段目 RE により 0x800cf400=**CD disc file load**(CdlFILE、MAPHEAD/GetSectionOffset と別層)と判明。本 §6 の『MAPHEAD/RunScene 最有力候補』は誤=撤回、§9-6 参照★。

---

## 7. 狙い達成 + B4 stub→実配線 材料

- ★『0x66 selector が最終起動するもの』= SCENE 遷移(0x800cfdf0 scene switcher)★=機構確定。selector は descriptor table 0x8013CDB4 で scene-id を解決し、scene switcher が 旧teardown→新load(overlay 0x800cf400)→finalize を行う。
- ★B4 stub→実配線 昇格材料★: remake で 0x66 B4 を実配線するには (i)scene-id 解決(descriptor table 0x8013CDB4 相当、RAM populate ゆえ内容 RE 要)(ii)scene switcher(current 比較 + teardown/load/finalize)(iii)scene load=overlay/MAPHEAD 機構(step3 資産と接続)。★substantial subsystem=step4 A4(actor)と同格の別 arc★。step4 D2 の『descriptor 表 3段目 RE 未ゆえ配線=発明』判断は本 RE で裏付け(descriptor 表が RAM populate で静的不明=なお配線は OI-3a 決着後)。
- ★【訂正: §9-6】step3 接続=REFUTE★: 0x800cf400=CD disc file load(MAPHEAD/GetSectionOffset と別層)と 4段目 RE で判明。★step3 DG.SCN/MAPHEAD/RunScene 資産の単純再利用では B4 配線不可★=scene-asset-load subsystem(CD→buffer→memcpy)が別途要。次 scoping はこの別 subsystem を含めた縦積み設計が核心(§9-6)。

## 9. OI-3a q1② 4段目 全長RE(2026-07-19、PRESIDENT GO)★step3 接続=REFUTE(私の §6 仮説訂正)★

### 9-0. 結論(4段目)
| 項目 | 判定 | 次元 |
|---|---|---|
| ★0x800cf400(scene load)の実体★ | ★**CD file/asset load**(CdlFILE、disc read)★=**MAPHEAD/GetSectionOffset と別層** | 観測 |
| ★§6 仮説『0x800cf400=MAPHEAD/RunScene 接続点』★ | ★**REFUTE**(RE で否定。CD file loader であって DG.SCN offset 解決でない)★ | 観測(自己訂正) |
| scene switcher lifecycle | teardown(旧 resource free)→ load(CD file)→ current 更新 → finalize(loaded data 処理+配置) | 観測 |
| B4 実配線の含意 | scene-asset-load subsystem(CD→buffer)が要=step3 DG.SCN/MAPHEAD 資産の単純再利用では不可 | 推論 |

### 9-1. 0x800cf400 = scene CD-file load(全長、観測)
```
800CF410 s0 = 0x80010000(load buffer base)   ; 800CF418 [0x10sp]=0x27(=39=record stride)
800CF428-38 a3 = (id-1)*0x27(=39)             ; ★record table index(stride 39)★
800CF43C a0=2 a1=gp-0x77d4(filename buf) a2=0x80010000 a3=(id-1)*39 ; jal 0x800cf0e4(§9-2)
800CF450 if v0==-1(load fail): return 0
800CF464-90 s0 buffer header(+8/+0xc)で data start/size 算出 → memcpy(0x80091450) to 0x8015102c(dest)
800CF498 return 1
```
→ scene record #id(stride 39 table、index=(id-1))を CD から buffer 0x80010000 へ load、header で data 部を 0x8015102c へ memcpy。

### 9-2. 0x800cf0e4 = CD file loader(観測)
```
800CF108 a0=filename buf(gp-0x77d4) a1=0x5c ; jal 0x80091430  ; ★strchr(0x5c='\'=CD path sep)=filename 解析★
800CF134 jal 0x800cf4b0(sp+0x24, s2, gp-0x77cc)               ; CdlFILE/path 構築
800CF148 jal 0x800a49a4(sp+0x24, base 0x80010000, off, ...)   ; ★CD read(§9-3)★
800CF160 [0x8013_4230 + mode*4] table + s0 header 処理
```
→ ★filename(gp-0x77d4)を parse(path sep 0x5c)→ CdlFILE 構築 → CD read。= **disc file load**★。DG.SCN の in-memory offset 解決でない。

### 9-3. 0x800a49a4 = CD read(観測、確認)
```
800A49C8 jal 0x800a4444  ; find file(CdSearchFile 系)
800A49E0 jal 0x800b4af8  ; CD read setup
```
→ CD/disc file access 層。0x800cf400→0x800cf0e4→0x800a49a4 = ★CD からの scene asset 読込 chain 確定★。

### 9-4. teardown / finalize(全長、観測)
- ★teardown★: 0x800cf074=旧 scene handle(gp-0x6da4)!=-1 なら 0x800d6bf0(free/despawn)。0x800cf0a8=同 handle で 0x800d6114(追加 cleanup)+ handle=-1。→ 旧 scene resource の解放。
- ★finalize★: 0x800cf29c=loaded data(0x8015102c)の header(*(s0)>>2)を scene param(gp-0x6da0)と照合し active scene state 構築。0x800cf314=handle(gp-0x6da4)を (a1=0x50,a2=0x50)で 0x800d7018=scene 配置/初期位置 setup。→ 新 scene の有効化+配置。

### 9-5. task register(概要、cutoff)
- 0x800a4060 = per-scene task slot register(table lui0x8014 系、callback 0x80106754 を id 付で登録)。★1 行: 各 scene entry に per-frame task を登録する task-system 登録関数(詳細=cutoff)★。

### 9-5b. ★boss1 reconcile 参照(0x80105be4 の a0 意味、2026-07-19)★
boss1 直読 reconcile で私の §3 読み(a0=sceneId 直接)を精密化=★a0=**actor slot index**★: 0x80105be4 構造=(i)現 slot(+0x66d)の actor form==0x73→scene 0x21 強制 /(ii)gp-0x6bf4==1→scene 0x21 /(iii)else a0=slot index で form-id 読取→form range(<0x43/<0x70..)で scene 選択→switcher。★E104=DF70 定数2=slot2=partner record(0x8013CDBC)★ ⇒ ★『0x66=**partner の form に応じた scene 選択**』で全 chain 意味統一★。私の §4 [1,34)=switcher 側 validity(正のまま)、worker3 form-id descriptor と両立(次元差=slot/form-id vs switcher validity)。§3 の『sceneId<2/<0xa』は実は form-id-at-slot range と精密化。

### 9-5c. ★form-class → scene-id 対応表(完全版、0x80105be4 全分岐 disasm、q2 設計材料)★

★重要な精密化(観測)★: 0x800cfdf0 呼出は **全 6 call site で a0=0x21 固定**(=scene record 0x21、0x800cf400(0x21)で常に record#0x21 を load)。★form が決めるのは a1(mode/variant ∈ {0,1,2,3})★。boss1 reconcile『form range で scene 選択』を精密化=★scene record は 0x21 固定、form-class は **変種 a1** を選ぶ★。

| 条件(a0=slot index、form=*(desc[slot])) | a0(scene) | a1(variant) | disasm |
|---|---|---|---|
| desc first-word==0x73(§3 top) | 0x21 | **3** | 80105C4C `a0=0x21;a1=3;jal 0x800cfdf0` |
| slot∈[2,0xa) & gp-0x6bf4==1 | 0x21 | **0** | 80105C9C `a0=0x21;a1=0` |
| slot∈[2,0xa) & form<0x43 | 0x21 | **1** | 80105CDC `slti 0x43;bnez 0x80105d6c`→80105D6C `a0=0x21;a1=1` |
| slot∈[2,0xa) & form>=0x70 | 0x21 | **1** | 80105D10 `slti 0x70;beqz 0x80105d6c`→80105D6C `a1=1` |
| slot∈[2,0xa) & 0x43<=form<0x70 | 0x21 | **byte-table[form-0x43]** | 80105D44 `v1=form-0x43; a1=*(0x801389E8+v1); a0=0x21; jal` |
| slot<2 or slot>=0xa & gp-0x6bf4==1 | 0x21 | **0** | 80105D94 `a0=0x21;a1=0` |
| slot<2 or slot>=0xa & else | 0x21 | **1** | 80105DAC `a0=0x21;a1=1` |

★byte-table @0x801389E8(form 0x43..0x6f、45 entry、**static .data=読取可**)★=form→a1(0x01/0x02):
```
form:  43 44 45 46 47 48 49 4A 4B 4C 4D 4E 4F 50 51 52 53 54 55 56 57 58 59 5A 5B 5C 5D 5E 5F 60 61 62 63 64 65 66 67 68 69 6A 6B 6C 6D 6E 6F
a1:    02 02 02 02 02 01 02 02 02 01 02 02 02 02 02 02 02 02 01 02 02 01 01 01 01 01 02 02 02 02 02 02 02 01 02 02 02 01 01 01 02 01 02 02 02
```
→ ★大半 form=a1=0x02、例外(a1=0x01)= form 0x48,0x4C,0x55,0x58-0x5C,0x64,0x68-0x6A,0x6C★。form<0x43 と >=0x70 は a1=1。

★q2 実装対応値(発明ゼロ)★: 0x66 は scene record **0x21** を、partner(slot2)の form-class で決まる mode a1(0=特殊/初期・1=下位form・2=大半form・3=type-tag0x73)で起動。a1 の実マップ=上表(byte-table 実値込)。remake B4 実配線はこの table(0x801389E8)+ 分岐条件を verbatim 移植すれば発明ゼロ。

**a1(arg1)→gp-0x6dcc(80105C10 store)の消費**: 本関数(0x80105be4)内では read なし。★sibling scene 関数群(0x80105e04/0x80105f20/0x80106040/…lh -0x6dcc、多数)が消費★=scene param として scene 系全体で共有(本関数外、1 行 note)。

### 9-6. ★step3 接続点 突合(最重要、観測)★
- ★step3 MAPHEAD/GetSectionOffset(EXE 0x800F0A4C)= **in-memory DG.SCN blob** の entry+section offset 解決(dialogue/event VM 層)★。
- ★0x66 scene selector の load(0x800cf400)= **CD disc file load**(CdlFILE、stride-39 record table、dest 0x8015102c)= scene **asset** 層★。
- → ★**両者は別層・別機構=接続点 REFUTE**★。scene selector は DG.SCN/MAPHEAD を経由せず、独立に CD から scene asset を load する。私の OI-3 §6『0x800cf400=MAPHEAD/RunScene interface 最有力候補』は ★RE で否定(measure-first、仮説を実測が訂正)★。
- ★B4 実配線の含意(訂正版)★: 0x66 B4 を remake で実配線するには (i)descriptor table 0x8013CDB4(RAM populate、内容 RE 要)(ii)scene switcher lifecycle(teardown/load/finalize)(iii)★scene-asset-load subsystem(CD→buffer→memcpy、disc file)★が要。★step3 の DG.SCN/MAPHEAD/RunScene 資産の**単純再利用では不可**(別層ゆえ)★。scene asset load は remake で別途 model 要(map/graphics overlay 相当)。

---

## 8. cutoff / honest gap(promote禁止)
- ★cutoff(boss1裁定)★: 核心(selector→scene switcher)確定で深追い停止。4段目=OI-3a起票。
- ★OI-3a(起票)★: 0x800cf400(scene load=overlay 実体、RunScene/MAPHEAD bit 対応)/ descriptor table 0x8013CDB4 内容(RAM dump 要)/ 0x800a4060 task register + callback 0x80106754 全長 / 0x800cf074/0a8/29c/314(teardown/finalize)。
- ★coverage限界★: descriptor table 0x8013CDB4=RAM populate ゆえ静的 bin で内容不明(type tag 0x73 は code 比較定数から、他は未確定)。scene-id 空間 [1,34) は 0x800cfdf0 range check から観測。
- type tag 0x73 / sceneId<2 / [2,0xa) / >=0xa の各 scene 種別 semantic=descriptor 内容依存(RAM)=🅰。
