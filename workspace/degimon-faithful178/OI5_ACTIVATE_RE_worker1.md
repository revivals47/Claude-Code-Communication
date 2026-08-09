# OI-5: registry activate/deactivate 実体 全長RE(worker1)

**date**: 2026-07-19 / worker1 / ★read-only RE(コード変更ゼロ)★
**material**: EXE=slps_017_97.bin(base 0x80090800)、tool=exedis.py。gp=0x80144E0C。
**狙い**: (1)registry slot 値の semantic(『model』label 検証)/(2)id 空間 6/6 一致の機構的説明(OI-6)/(3)actor 実体 生成/破棄=step4 A4 宣言gap の実配線材料。
**規律**: 観測(disasm paste)/推論 区分。promote 禁止。深追いは狙い達成まで。

---

## 0. 結論(単一表)

| 項目 | 判定 | 次元 |
|---|---|---|
| activate chain | 0x800bb518(id)→0x800a1348(id,0)→★0x800a2c30★(実処理) | 観測 |
| deactivate chain | 0x800bb968(id)→0x800a1378(id,0)→★0x800a3164★(実処理、activate の dual) | 観測 |
| actor-instance table | ★@0x80140410、stride 0x1c(28B)、id=halfword @+0x18、refcount @+0★ | 観測 |
| activate 機構 | ★id で instance 探索/確保 → refcount++ → refcount==1 で実 spawn(0x800a2d98)★=refcounted actor-instance allocator | 観測 |
| id 範囲 gate | id ∈ [0, 0xb4=180)(範囲外=no-op、v0=0 return) | 観測 |
| (1)slot 値 semantic | ★actor/entity id(refcounted instance を spawn)★。『model』label=方向的に正(視覚 entity を spawn)、精密には actor-instance id。どの model/sprite かは spawn 内(🅰) | 観測(構造)+推論(label) |
| (2)OI-6 id 空間一致 | ★activate id 空間(actor-instance @0x80140410)と 0x47 map 空間(DG.SCN/MAPHEAD)は **別テーブル**。6/6 値一致=authoring(script byte)、機構的同一でない★=food-id≠shop-id 実証 | 観測+推論 |
| (3)step4 A4 gap 配線材料 | activate=refcounted alloc+spawn / deactivate=dual dealloc。substantial subsystem ゆえ A4 宣言gap は妥当 | 観測 |

---

## 1. activate chain 全長RE(観測)

### 1-1. 0x800bb518(0x46 A4 activate 入口)
```
800BB524 lbu a0, id ; 800BB528 a1=0 ; 800BB52C jal 0x800a1348   ; activate(id, 0)
```
### 1-2. 0x800a1348 = 薄 wrapper
```
800A1360 jal 0x800a2c30(a0=id, a1=0)   ; 実処理へ委譲
```
### 1-3. 0x800a2c30 = 実 activation(refcounted actor-instance allocator)
```
800A2C44 s2 = a0(id) ; a1(=0=activate mode)
800A2C50 if a1==1: return 0                       ; a1==1 は別 mode(activate は 0)
800A2C6C if s2<0 or 800A2C74 s2>=0xb4(180): return 0   ; ★id ∈ [0,180) gate★
800A2C8C if a1!=0: → 0x800a2fb0                    ; a1!=0 別 path(activate は 0 で継続)
800A2CA4 s0 = 0x80140410                           ; ★actor-instance table base★
  loop(stride 0x1c):
    800A2CB8 lw v0,(s0)                            ; entry[+0]=refcount/active
    if v0==0: 最初の空 slot を 0x54(sp) に記録
    else: 800A2CDC lh v0,0x18(s0); if ==s2: → 0x800a2d14(既存 found)  ; ★id は +0x18 の halfword★
    800A2CEC s0 += 0x1c                            ; 次 entry
```
### 1-4. found/alloc path 0x800a2d14(観測)
```
800A2D40-D68 slot addr = 0x80140410 + slot*0x1c ; ★sh s2,0x18(s0) = id を +0x18 へ格納★
800A2D6C-D78 *[s0]++                              ; ★refcount(+0)++★
800A2D7C-D84 if refcount==1: → 0x800a2d98(実 spawn/init) ; else return s0(既 active=refcount 増のみ)
800A2D98+    (refcount 1=初回)別 table @0x8014049c 系を loop=instance 実生成
```
→ ★activate = 「id で instance を探索、無ければ空 slot 確保して id を +0x18 に置き、refcount++。refcount 1(初回)で実 spawn」= **refcounted actor-instance allocator**★。

## 2. deactivate chain(観測、activate の dual)

```
800BB968 lbu a0,id ; a1=0 ; 800BB97C jal 0x800a1378
0x800a1378: 800A1390 jal 0x800a3164(id,0)   ; ★activate(0x800a2c30)の dual=dealloc★
```
→ 0x79 deactivate = 0x800a3164(refcount-- / 0 で実 despawn、activate と対称)。構造 dual 確認(0x800a1348↔0x800a1378 が 0x800a2c30↔0x800a3164 を呼ぶ mirror)。

---

## 3. 狙い達成

### (1) registry slot 値の semantic(『model』label 検証)
- registry(@0x80164098、8-slot)の値 = activate に渡る id。id ∈ [0,180) で actor-instance table(@0x80140410、stride 0x1c)を refcount 管理し、初回 spawn。
- ★『model』label=方向的に正★(視覚 entity を spawn する id)。★精密には「actor/entity instance id」★(refcount+spawn 機構=単なる model 番号でなく instance 実体化)。どの model/sprite/TMD に解決されるかは spawn block(0x800a2d98 + table @0x8014049c)=🅰(未 RE)。180 の意味(character/model 総数?)も 🅰。

### (2) id 空間 6/6 一致(OI-6)の機構的説明 ★食い違い空間の確定★
- ★activate の id 空間★ = actor-instance table @0x80140410(id を +0x18 halfword、range<180)。
- ★0x47 MAP_CHANGE の map id 空間★ = DG.SCN entry / MAPHEAD(warp executor 0x800bb544 経由、step4 p1)。
- ★両者は **別テーブル・別 resolver**★。0x46 operand==0x47 map id の 6/6 値一致は、両 opcode が **同じ script byte を読むが別 id 空間で解釈**した結果であって、★『registry id 空間 == map id 空間』という機構的同一ではない★。
- ★OI-6 結論: 6/6 一致=**authoring(scenario data 上で recruit id と遷移先 map id を等値に書いた)属性**、機構でない★。food-id≠shop-id 教訓が実証された領域=額面で「同一空間」と結論してはならなかった(p1 §6bis の 🅰 保留が正しかった)。『recruit→当該 map 遷移』は data 設計上の対応であって activate/MAP_CHANGE を繋ぐ機構は無い。

### (3) actor 実体=step4 A4 宣言gap の実配線材料
- A4 gap(0x800bb518→0x800a1348 / 0x800bb968)の実体 = ★refcounted actor-instance allocator/deallocator★(table @0x80140410、id@+0x18、refcount@+0、初回 spawn)。
- ★remake で A4 を実配線するには actor-instance subsystem(8→instance table、refcount、id→model/sprite 解決、spawn/despawn)が要る=substantial★。step4 が A4 を宣言gap(log のみ)にした設計判断は妥当(trivial でない)。
- 配線材料の要点: (i)id keyed instance table(refcount)/(ii)refcount 1→ で spawn・0→ で despawn/(iii)id→視覚 model 解決(spawn block、未 RE)。

---

## 4. 未確定残(promote 禁止・honest gap)
- ★spawn block 0x800a2d98 + table @0x8014049c の実体(id→どの model/sprite/TMD を load するか)= 未 RE★=『model』の具体 resolution。(1)の精密化はここ。
- id 範囲 180(0xb4)の意味(character/model 総数 or 別上界)= 未確定。
- refcount>1(同 id 多重 activate)/ a1==1・a1!=0 の別 mode(0x800a2fb0)= 本 activate(a1=0)path 外、未 RE。
- 0x800a3164(deactivate 実処理)の despawn 詳細 = 構造 dual 確認のみ、全 body 未展開。
- OI-6 の『authoring 対応』= 6 corpus site での値一致は data 観測(p1 §6bis)。全 scenario での対応則(recruit id==map id が常か)は全 corpus 走査で別途(本 RE は機構=別空間の確定まで)。
