# OI-3b slot 帰属 reconcile — 0x66 dispatch 0x73 check の effective slot(静的 vs 実測 矛盾決着)

**date**: 2026-07-19 / worker1 / ★read-only 静的 EXE 再RE(命令単位)、自己過去finding(finding-1)+boss1裏取りの両方を検証対象=額面採用せず★
**material**: EXE slps_017_97.bin(BASE 0x80090800、tool=scratchpad mdis.py/xref.py/xoff.py)。gp=0x80144E0C。
**契機**: worker3 R2'b capture injection proof が finding-1(R1 land、worker1+boss1 一致)と矛盾。gate④型 reconcile。
**規律**: 観測(disasm/xref paste)/推論/honest gap 区分。numeric 値は直読のみ額面。

---

## 0. 判定サマリ

| 項目 | 結論 | 次元 |
|---|---|---|
| 静的構造(両 block の form 読取) | ★完全同型 `form = *(descriptor[idx])`、idx だけ相違★。0x73 check idx=[固定struct+0x66d]、range idx=a0(E104 slot) | 観測 |
| finding-1「0x73 check=現slot / range=E104=別slot」の**式レベル**読み | ★正しい★(index 式は確かに別) | 観測 |
| finding-1 の**意味レベル**主張「2つの独立した別 slot」 | ★未検証の推論=実測が反証★。両 idx は実行時に同一 partner actor へ解決 | 推論(実測 authoritative) |
| 判定(boss1 3択) | ★(i)-primary: 静的 semantic 訂正=実効単一 actor(実測支持)+ (iii)-nuance: 機構=descriptor RAM-populate 上の alias/等価で静的決定不能★ | 判定 |
| R1 finding-1(two-slot 分離、r5)の帰結 | ★訂正要=0x73 check は range と同一 form(E104/partner)を test すべき。r5 の curSlotForm 別扱いは実測と乖離★ | 上申(実装は boss1 判断) |
| ★共有盲点★ | worker1+boss1 が「別 index 式 ⇒ 別 slot」の同一 frame で誤読。convergence が偽の確信を強化(静的版『2読み収束は盲点を検出しない』) | 言語化(§6) |

---

## 1. 0x80105be4 命令単位 再全長 RE(観測)★両 block の deref は bit 同型★

### 0x73 check block(0x80105c14-44)
```
80105c14  lw   v0, -0x6dec(gp)     ; v0 = [gp-0x6dec](=P、ポインタ値)
80105c1c  lbu  v0, 0x66d(v0)       ; v0 = [P + 0x66d] = X(descriptor index)
80105c24  sll  v1, v0, 2           ; v1 = X << 2
80105c28  lui  v0, 0x8014
80105c2c  addiu v0, v0, -0x324c    ; v0 = 0x8013cdb4(descriptor table)
80105c30  addu v0, v0, v1          ; v0 = 0x8013cdb4 + X*4
80105c34  lw   v0, (v0)            ; v0 = descriptor[X](ポインタ)
80105c3c  lw   v0, (v0)            ; v0 = *descriptor[X] = form
80105c40  bne  v0, 0x73, 0x80105c64 ; form==0x73 → (0x21,3)
```

### range block form 読取(0x80105cb4-d4、0x80105ce8-d08、0x80105d1c-3c の 3 反復とも同一)
```
80105cb4  lw   v0, 0x88(sp)        ; v0 = a0 = [sp+0x88](dispatch 第1引数=E104 slot)
80105cbc  sll  v1, v0, 2           ; v1 = a0 << 2
80105cc0  lui  v0, 0x8014
80105cc4  addiu v0, v0, -0x324c    ; v0 = 0x8013cdb4
80105cc8  addu v0, v0, v1          ; v0 = 0x8013cdb4 + a0*4
80105ccc  lw   v0, (v0)            ; v0 = descriptor[a0]
80105cd4  lw   v0, (v0)            ; v0 = *descriptor[a0] = form
80105cdc  slti at, v0, 0x43 ...    ; range 判定
```

★観測結論★: 両 block は `form = *( *(0x8013cdb4 + idx*4) )` = **descriptor deref が完全同型**(命令列 bit 一致、descriptor table も同一 0x8013cdb4)。**差は idx の出所だけ**:
- 0x73 check idx = **[P+0x66d]**、P=[gp-0x6dec]
- range idx = **a0** = [sp+0x88](selector が渡す E104 slot)

## 2. [P+0x66d] の正体(観測)★「独立した現slot」ではない★

- ★P=[gp-0x6dec] の値★: 単一 writer 0x80118ef8(`lui 0x8014; addiu 0x60f8`)= **固定静的アドレス 0x801460f8**(a0 非連動、per-slot ポインタでない、global work struct)。xref: sw gp-0x6dec は 0x80118ef8 のみ。
  - ∴ 0x73 check idx = [0x801460f8 + 0x66d] = **[0x80146765]**(固定アドレスの 1 byte)。
- ★offset 0x66d の全 access(xoff 全 EXE 走査)★: **lbu 1 箇所(0x80105c1c=まさに 0x73 check)のみ、store ゼロ**。0x66c への sh/sw(0x66d を含む幅広 write)も無し。struct base 0x801460f8 生成は 0x80118ef4 単一=computed-offset store 経路も無し。
  - → ★[0x80146765] は EXE 内のどの store でも書かれない★。値は bulk-init/data section の初期値、または memcpy/CD-load 等の非 store 機構由来(静的に確定不能)。
- ★a0(=slot、値8)の cache 先★: selector arg [gp-0x6d08](writer 0x800f021c=[gp-0x6e9c]、reader 0x800ee7f8 のみ)→ selector a0 → dispatch a0。**a0 は struct+0x66d に cache されない**(param-list 0x80107258 は struct へ +0x66c=1/+0x670=0 の定数のみ書込、a0 は [sp+0x40] 退避のみ)。
- → ★静的には [0x80146765] と a0 は無関係な値★。finding-1 が「現slot」と呼んだ [P+0x66d] は、実は「writer を持たない固定 global struct の 1 byte」であって、per-frame 更新される「現slot form index」である**保証は静的に無い**(私はこれを未検証で仮定した)。

## 3. descriptor table 0x8013cdb4 = RAM-populate(観測)

- 静的 dump: descriptor[0..9]=**全ゼロ**(0x8013cdb4-0x8013cdd8)。0x8013cddc 以降(0xfea7ff10…)は PS1 RAM ポインタ形(0x80xxxxxx)でない=table 外の別 data。
- → descriptor table(index 0..9)は**実行時 populate**(worker3「descriptor record dynamic」と整合)。∴ **index→actor struct の対応は静的に読めない**。range block(a0=8)も 0x73 check(idx=[0x80146765])も、実行時の descriptor[idx] ポインタに依存。

## 4. 実測(worker3 injection)との照合 ★injection=因果 authoritative★

- worker3 R2'b: fire 時 [gp-0x6dec]+0x66d=5 / a0=E104=8。slot5 に 0x73 注入→variant1(0x73 check **非** trigger)、slot8 に 0x73 注入→variant3(0x73 check **trigger**)。
- ★因果解釈★: 「slot8 の form=0x73 注入 → 0x73 path(variant3)採用」=**0x73 check が実効的に slot8(=a0=range と同一 actor)の form を読む**、の直接証明。
- ★静的との整合★: §1-3 より、[0x80146765] と a0 が**同一 actor へ解決すれば**両 check は同一 form=矛盾なし。これが成立する機構候補(静的決定不能、要 worker3 dump):
  - (H-a) fire 時 [0x80146765] が実は a0(=8)を保持(bulk-populate で active slot が書かれる)。worker3 の「5」は別 time/別 address 由来の可能性。
  - (H-b) [0x80146765]=5 だが descriptor[5]==descriptor[8](RAM-populate table が同一 partner actor を複数 index から指す=alias)。slot8 注入=partner actor form 変更=descriptor[5] 読取にも波及。
  - (H-c) H4: injection 実験の confound(slot8 注入が [0x80146765] or descriptor[5] target も触れた)。
- ★numeric gap(honest)★: 「[0x80146765]=5 かつ 0x73 check が slot8 を読む」の数値矛盾は静的に閉じない(§2 の writer ゼロ + §3 の RAM-populate ゆえ)。但し injection の**因果**結果(注入先→分岐変化)は address 誤り(選択肢 ii)では説明しにくい=(i)を支持。

## 5. 判定(boss1 3択)

- ★(i)-primary(実測支持)★: finding-1 の **semantic 主張「2つの独立した別 slot」は反証**。0x73 check は range と**同一 partner actor** の form を実効的に読む(injection 因果)。式レベルの two-index 読みは正しいが、それを「別 slot」と解釈したのが誤り。
- ★(iii)-nuance(H4)★: 「同一 actor へ解決する機構」は「両方 a0 単一」でも「現slot vs E104 の2 slot」でもなく、**RAM-populate descriptor 上で別 index が同一 actor へ alias/等価化する**という第3の構造。静的に決定不能=worker3 dump 必須(§8)。
- (ii)(static 正・worker3 address 誤り)= ★低優先だが完全排除せず★: 数値「5」の出所は未解明。但し injection 因果を覆すには「注入先 address が実際は 0x73 check の読む actor だった」必要があり、それは結局 (i)(同一 actor)に帰着。

★上申★: R1 finding-1 の two-slot 分離は取り下げ、0x73 check=range=同一(E104/partner)form でモデル化するのが実測整合。

## 6. ★共有盲点の機構言語化(boss1 PRESIDENT裁定 10:40 対応)★

**なぜ worker1 と boss1 が同じ誤読をしたか**:

1. ★同一 interpretive frame★: 両者とも `*(*(gp-0x6dec)+0x66d)` と `*(descriptor[a0])` を見て、「**index 式が構文的に違う ⇒ 別 slot**」と semantic 変換した。この frame 自体が共有された前提。
2. ★未追跡だった検証点(両者とも省略)★:
   - (a) offset 0x66d は **store ゼロ**(§2)→「per-frame 更新される現slot form index」ではあり得ない、を確認しなかった。writer 追跡を省略。
   - (b) P=[gp-0x6dec] が **固定 global struct**(a0 非連動)である値まで展開しなかった(「slot base ポインタ」と語感で解釈)。
   - (c) descriptor が **RAM-populate**(§3)ゆえ index→actor 対応は静的に読めない=「別 index ⇒ 別 actor」は静的に**証明も反証もできない未決事項**だった、を認識しなかった。
3. ★convergence の罠★: worker1 の読みに boss1 裏取りが「一致」した(R1 land 時)。この**2名収束が偽の確信を強化**した。だが 2名は**同一 frame(1,2)を共有**していたため、収束は独立検証を増やさず、共有盲点を温存した。=★『2実装/2読みの収束は共有盲点を検出しない』の静的版★。
4. ★破れた理由★: 欠落情報(+0x66d の実行時値・descriptor の実行時対応)は**静的テキストに原理的に存在しない**。ゆえに何名が静的に読んでも同じ盲点に留まる。**異なる method(worker3 の runtime injection)**のみが破れた=hidden-input completeness の実証。

★再発防止則★: index/pointer 式の semantic 差(別 slot/別 actor)を主張する前に、(a)当該 offset の writer 有無、(b)base ポインタの実値、(c)table が静的か RAM-populate か、を必ず確認。静的に決定不能なら「別 slot」と**断定せず**「実行時依存(要 injection/dump)」と honest mark。2名一致は独立検証にカウントしない(同一 frame 共有の疑いを先に排除)。→ memory [[feedback_harness_hidden_input_completeness_oracle]] / [[feedback_verify_the_oracle_not_just_the_match]] の静的適用。

## 7. R1 finding-1 訂正の実装含意(上申、実装は boss1 判断)

- 現 remake(GameState.SelectSceneVariant): `if(curSlotForm==0x73) return 3;` が **curSlotForm(現slot=slot1→CareForm/slot2→DigimonId)** を test。range は eForm(E104-slot)。
- ★実測整合の訂正★: 0x73 check も **eForm(E104/partner form)** を test すべき(range と同一 actor)。→ curSlotForm 引数と RawCurSlot 配線(r5 で追加)は**実測上不要=単一 slot モデルへ回帰**。
- ★但し注意★: eForm==0x73 の時 range も同 actor ゆえ、SelectSceneVariant を `if(eForm==0x73) return 3; else if(flag==1) return 0; else range(eForm)` へ単純化=r5 の two-slot 構造分離を revert。→ ★revert 前に worker3 の descriptor dump(§8)で (H-a/H-b) 確定を推奨★(数値 gap を残したまま実装変更しない)。

## 8. honest gap / worker3 close-out oracle(promote 禁止)

静的に閉じない残(要 worker3 runtime dump、0x73 check 実行の瞬間):
1. **[0x80146765]** の実値(=5 か 8 か)。§2 で writer ゼロゆえ静的不明。
2. **descriptor[[0x80146765]]** と **descriptor[a0]** のポインタ値(同一=alias(H-b) か別か)。§3 で RAM-populate ゆえ静的不明。
3. *descriptor[X] の +0(form)field が、worker3 の「slot5/slot8 注入」でそれぞれどう変わるか(注入先 address と descriptor target の対応)。
4. [0x80146765] を bulk-populate する機構(memcpy/CD-load 元)=非 store ゆえ静的追跡困難。
→ 1+2 を dump すれば (H-a)/(H-b)/(ii) が一意に判別=reconcile 完全 close。それまで finding-1 訂正は「semantic 反証は確定・機構は (i)/(iii) 未分離」で honest mark。
