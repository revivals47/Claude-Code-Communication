# F-1(b) [P+0x66d](=[0x80146765])の 5→8 更新機構 RE — worker1 【v2】

**date**: 2026-07-19 / worker1 / ★read-only 静的 EXE 直読、v2=gate④型差戻し後の訂正版★
**material**: EXE slps_017_97.bin(BASE 0x80090800)。tool=scratchpad mdis.py/xref.py/dscan2.py/dscan3.py(taint-propagation)。gp=0x80144E0C。
**oracle**: F1B_DESC_DUMP_worker3.md(worker3 実測、3点 measurement、prereg 固着、savestate sha 記載)= ★本 RE の ground truth★。
**規律**: 観測/推論/honest gap 区分。★v1 の全列挙 claim が実測に反証された経緯を明記(訂正は自動的に改善でない=v2 こそ再検証)★。

---

## ★revision 履歴(v0.1 → v2、REFUTE 経緯)★

| 版 | 主張 | 帰結 |
|---|---|---|
| v0.1(reconcile §4) | H-b: descriptor aliasing(descriptor[5]≡descriptor[8]=0x8016B374)が真機構 | ★REFUTE(worker3: desc5=0x8016B23C≠desc8=0x8016B374、全3点で aliasing でない)★ |
| v1(本doc初版) | H-a: [0x80146765] は store 完全ゼロ→「5→8 書込」は機構的に不可能=REFUTE。真機構=H-b aliasing | ★二重 REFUTE(worker3: [0x80146765]=5→8→8 で **write は在る** + aliasing でない)★ |
| ★v2(本版)★ | 真機構=param-list ループが [P+0x66d] に **scenario work buffer byte(0x801639D8=script[0x254])** を書く(base+computed-offset store=v1 scan の盲点)。5→8 は section 毎の script[0x254] 値 | worker3 実測と静的機構が一致 |

★見落としの型★: v1 §8 honest gap が「memcpy/computed base(base=関数引数)は scan 対象外」と**自ら予告していた盲点**を、v1 §0 で「store 完全ゼロ→REFUTE」と過剰 claim した。**「static store scan 0 件 ≠ writer 不存在」**(ovldis pointer-base write 盲点の既知類型)。gate④型差戻しで worker3 実測 oracle が突いた。→ [[feedback_absence_in_truncated_list]] / [[feedback_correction_is_not_automatically_improvement]] / [[feedback_ovldis_xref_absolute_blindspot]] の再適用。

---

## 0. 結論(単一表、v2)★[P+0x66d] は書かれる、真 writer 特定★

| # | 問い | 結論 | 次元 |
|---|---|---|---|
| 1 | [0x80146765]([P+0x66d])を書く store は在るか | ★YES=0x80107328 `sb a0, 0x66c(v0)`、v0=P+v1(v1=1)=実効 [P+0x66d]★。base+computed-offset ゆえ literal-offset scan(0x66d)/lui-addiu scan が両方見落とし | 観測(taint-scan)+worker3 実測 |
| 2 | writer の所在 | ★param-list 0x80107258(=selector 0x800aeca8 が dispatch 直前に呼ぶ setup)内のループ★(worker3 hint「selector setup 中の base-relative sb」と一致) | 観測 |
| 3 | 書かれる値の源 | ★scenario work buffer byte = [gp-0x6cec=0x80163784 + 0x254] = 0x801639D8 = script[0x254]★(FIRE_GATING の flag byte 0x253=0x801639D7 の隣接次 byte)。0x800f0ac8(0xfb) 読取 | 観測 |
| 4 | 5→8 の意味 | ★section 毎に script[0x254] を [P+0x66d] へ転写。5=前 section の値/stale、8=当該 fire section の script[0x254](=E104 slot 相当)★ | 観測(機構)+実測(worker3 値) |
| 5 | descriptor aliasing か | ★NO(worker3: desc5=0x8016B23C≠desc8=0x8016B374)★。0x73 check が slot8 を読むのは [P+0x66d] が 8 に**更新された**ため(desc index が 5→8)であって alias でない | worker3 実測 |
| 6 | ∴ 0x73 check の実 index | ★scenario-script 制御(script[0x254])の descriptor index★。current-slot でも固定 5 でも a0 でもない=第3の実体 | 判定 |

---

## 1. 真 writer 全長(観測、param-list loop 0x801072c0-0x80107338)

```
801072c0 move s0, zero                    ; s0=0(loop counter)、s2=0(loop前 0x8010728c)
[loop 0x801072cc..0x80107334, s0=0..2]
801072cc addi v0, s0, 0xfb                 ; script index = 0xfb + s0 (251,252,253)
801072d4 jal 0x800f0ac8                    ; v0 = script_base[gp-0x6cec][(0xfb+s0)+0x159]
                                           ;    = [0x80163784 + 0x254 + s0]  (script byte)
801072e0 sb v0, 0x34(sp+s0)               ; [sp+0x34+s0] = script byte
801072f0 beq v0, 0xff, skip-store         ; 0xff terminator → 転写せず(packed)
80107304 jal 0x801066cc (a0=byte, a1=0)    ; per-entry param 登録(side-effect)
80107310 a0 = [sp+0x34+s0]                 ; 転写値 = 生 script byte
80107314 v1 = s2+1 ; s2 = v1               ; 転写 index(非0xff のみ increment)
80107324 v0 = P + v1                        ; ★base = P + v1(computed)★
80107328 sb a0, 0x66c(v0)                  ; ★[P + v1 + 0x66c] = script byte★  v1=1 → [P+0x66d]
8010732c s0++ ; slti s0,3 ; bnez → loop
```
- ★v1=1(first non-0xff)で eff = P+1+0x66c = 0x801460f8+0x66d = **0x80146765**★。value = script[0x254](=0x801639D8)。
- literal store offset は **0x66c**(base=P+v1)ゆえ、v1 の xoff(literal 0x66d)= 0 件、dscan2(addu 非追跡)= 0 件 = 両方 miss。dscan3(taint P-derived + addu 追跡)で捕捉。

## 2. 値の源 = scenario work buffer(観測、FIRE_GATING と接続)

- 0x800f0ac8(N) = `[[gp-0x6cec] + N + 0x159]`(FIRE_GATING §5 で確定)。[gp-0x6cec]=static ptr=**0x80163784**。
- N=0xfb → [P+0x66d] 源 = [0x80163784 + 0x254] = **0x801639D8**。
- ★FIRE_GATING の flag gp-0x6bf4 = script[0x253]=0x801639D7 の**隣接次 byte**★。= scenario section が 0x253(flag)/0x254-0x256(descriptor index 3個)を連続制御。
- → [P+0x66d] は「固定 struct field」でも「party bulk-copy」でもなく、★section 毎に scenario work buffer から転写される descriptor-index★。worker3 の 5→8 = 前 section 値(5)→当該 section の script[0x254](8)。

## 3. worker3 実測 oracle との一致(観測)

| worker3 measurement(F1B_DESC_DUMP) | v2 静的機構 | 一致 |
|---|---|---|
| [0x80146765]=5(fire前)→8(dispatch)→8(check) | param-list loop が section の script[0x254]=8 を転写(fire前=前値5) | ✓ write 在る |
| desc5=0x8016B23C ≠ desc8=0x8016B374 | aliasing 否定=index が 5→8 に変わって別 struct を指す | ✓ non-alias |
| 5→8 は dispatch 中に発生 | writer=param-list(dispatch 直前 selector setup) | ✓ timing |

## 4. two-slot / R1 amendment への含意(v2、上申)

- ★0x73 check の descriptor index = scenario-script 制御(script[0x254])★。range の index = a0(E104 slot、[gp-0x6d08])。両者は **script[0x254]==a0 の section でのみ同一 slot**。script[0x254]≠a0 の section では **異なる slot を読む=two-slot diverge が scenario 毎に起こりうる**(=R1 の two-slot 分離は「起こりうる」が正、但し curSlotForm(slot1/slot2)モデルは実 index(script byte)と非対応=別の誤り)。
- ★R1 amendment 判断★: writer model は v2 で確定(param-list loop、値=script[0x254])。但し忠実 remake は「[P+0x66d]=当該 section の scenario byte(0x254)を descriptor index に」を model する必要=curSlotForm(slot1/2)でも eForm 単一でもない。→ ★R1 は「0x73 check index=E104(a0)」単一化も「curSlotForm」も両方非忠実。正しくは script[0x254] driven★。実装方針は boss1 裁定(worker3 の diverge 実測=script[0x254]≠a0 の section が存在するか、で単一化可否が決まる)。
- ★凍結継続★: writer model は確定したが、diverge の実在(script[0x254]≠a0 section)は未実測=R1 実装変更は diverge 有無確定まで凍結継続を推奨(boss1 裁定「writer model 確定まで凍結」→ writer 確定したが diverge が新論点)。

## 5. honest gap / cutoff(v2)

- ★script[0x254] の値がどの section で何になるか(=a0 と一致する section / diverge する section の分布)★= scenario data 走査(V4_REACH_PATH walker で script[0x254] を各 0x66 section で dump 可能)= 次段(diverge 実在判定)。worker3 の fire section では 8(=a0 一致)。
- 0x801066cc(per-entry param、a0=script byte)の作用 = 転写値には影響しない(a0 再読)が side-effect 未 RE=cutoff。
- ★v2 の self-audit★: 本 v2 は worker3 実測に机上機構を合わせた=「実測に整合する機構を後付けした」risk。→ 機構の独立検証点: (a)0x80107328 の base=P+v1 は disasm 直読(推論なし)(b)値源 0x801639D8 は 0x800f0ac8 の算術直読(c)worker3 の 5→8 timing が param-list(dispatch 直前)と一致。3点とも観測ゆえ後付けでなく接地、と主張。但し「script[0x254]=8 が E104 と一致する理由」は未 RE(scenario design 依存)=honest gap。

## 6. 反省(process、[[feedback_four_lies_one_hole]])

v1 で「store 完全ゼロ」を whole-EXE scan で示したが、scan の base-resolution(lui/addiu/gp-const のみ)が computed base(P+v1 via addu)を解決できず=**scan の能力限界を「不在の証明」と誤読**。§8 で盲点を予告しながら §0 で REFUTE と断じた=予告と結論の不整合。remedy: 「全列挙/不在」claim は scan の base-resolution 能力を明記し、computed/arg base を解決できない場合は「当該 addressing mode では不在」と限定(絶対不在と言わない)。worker3 実測 oracle が最終審=静的 scan の限界を実測で補完する gate④型が正しく機能した。
