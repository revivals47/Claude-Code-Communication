# F1B src254=2 vs idx73=8 reconcile — [P+0x66d] は flag-gated 2-writer — worker1

**date**: 2026-07-19 / worker1 / ★read-only 静的 EXE 読み(仮説でなく disasm 直読)、background reconcile★
**契機**: worker3 強化実測(fire context bit-一致確認済): 源 0x801639D8(=B[0x254])=**2** / 転写先 0x80146765(=[P+0x66d])=**8** = 別値。v2 model『B[0x254]→copy→[P+0x66d]』と不整合。
**規律**: 観測(disasm)/推論/honest gap。REFUTE 可能な形。追実測は worker3 指名。primary 非 diverge 結論には影響しない(close 済扱い)。

---

## 0. 結論 ★不整合は解消: [P+0x66d] は flag(B[0x253]) で分岐する 2-writer。worker3 fire は flag≠1 枝ゆえ [P+0x66d]=E104 slot(8)、B[0x254]=2 は flag==1 枝の未使用 source★

| # | 問い | 結論 | 次元 |
|---|---|---|---|
| a(順序/writer) | copy(0x80107328)と別 writer の関係 | ★[P+0x66d] は param-list 内で **flag-gated 2-writer**: flag(B[0x253])==1→0x80107328([P+0x66d]=B[0x254]) / flag≠1→0x8010743c([P+0x66d]=E104 slot=a0)★。v2 は flag==1 枝のみ記述=不完全 | 観測 |
| b(同定) | 0x801639D8=B[0x254] 再検証 | ★正しい★(base [gp-0x6cec] 実 trace=0x800f0044 `lui0x8016+addiu0x3784`=0x80163784、算術でなく writer 直読) | 観測 |
| c(transform) | 0x800f50a8(0xfb)出力=2 の由来か | flag==1 枝の B[0x254] は handler が transform 済(2 の候補)。但し worker3 fire は flag≠1 ゆえ [P+0x66d] に B[0x254] は使われない=2 は「使われなかった flag==1 source」 | 観測+推論 |
| 総合 | src254=2 ≠ idx73=8 の矛盾 | ★矛盾でない★: 別 flag 値の別 source。fire(flag≠1)は E104 slot(8)を [P+0x66d] に書く。B[0x254]=2 は同 fire で不使用 | 判定 |

---

## 1. [P+0x66d] の flag-gated 2-writer(観測、param-list 0x80107258)

param-list 冒頭で slot index を退避:
```
0x8010726c sw a0, 0x40(sp)        ; a0=selector arg=slot index(E104)を [sp+0x40] 保存
0x801072a4 jal 0x800f0ac8(a0=0xfa) ; v0 = B[0x253]
0x801072ac sb v0, gp-0x6bf4        ; flag = B[0x253]
0x801072b8 bne v0, 1, 0x8010741c   ; ★flag≠1 → 0x8010741c(下記 writer2 へ)、flag==1 → copy-loop(writer1)★
```

### writer1(flag==1、0x80107328、v2 で既出)
```
[copy-loop 0x801072cc-0x80107334]
0x801072d4 jal 0x800f0ac8(a0=0xfb) → B[0x254]
0x80107328 sb a0, 0x66c(P+v1)      ; v1=1 → [P+0x66d] = B[0x254](scenario param 0xfb)
```

### writer2(flag≠1、0x8010741c、★v2 で見落とし=本 reconcile で発見★)
```
0x8010741c lh v0, 0x40(sp)          ; v0 = 保存 slot index(=a0=E104)
0x80107424 andi a0, v0, 0xff         ; a0 = slot & 0xff
0x80107428 addi v1, s2, 1(s2=0)→v1=1 ; s2=0(0x8010728c で初期化、flag==1 枝を通らないので不変)
0x80107430 lw v0, -0x6dec(gp)        ; v0 = P
0x8010743c sb a0, 0x66c(P+v1)        ; v1=1 → [P+0x66d] = ★slot index(E104=a0)★
```

★∴ [P+0x66d](0x73-check の descriptor index)は flag で切替★:
- **flag(B[0x253])==1**: [P+0x66d] = B[0x254](scenario param、writer1)
- **flag≠1**: [P+0x66d] = E104 slot(a0=selector arg、writer2)

## 2. worker3 実測の reconcile(観測+実測)

- worker3 fire: variant=**1**(既報)。§1 rule で variant=1 は ★flag≠1★ 経路(flag==1 なら variant=0)。∴ この fire は **flag≠1 → writer2 発動**。
- ∴ [P+0x66d] = E104 slot = **8**(worker3 実測と一致)。B[0x254] = **2** は writer1(flag==1)の source ＝ **この fire では [P+0x66d] に使われない**(flag≠1 ゆえ writer2 が上書き)。
- → ★src254=2(未使用 flag==1 source)≠ idx73=8(E104 slot、flag≠1 で使用)= 矛盾でない★。両アドレスの同定(0x801639D8=B[0x254]、0x80146765=[P+0x66d])は正しく、v2 の欠落は「flag≠1 枝の writer2」の見落とし。

## 3. finding-1 / 非 diverge との整合(強化)

- ★原 reconcile finding-1(0x73-check が slot8=E104=range slot を読む)の機構解明★: flag≠1 時 [P+0x66d]=E104 slot ⟹ 0x73-check が descriptor[E104 slot] を読む=range(a0)と**同一 index=構造的に単一 slot**。coincidence でなく **flag≠1 枝が [P+0x66d]=a0 を明示 set** するため。
- ★非 diverge の強化★: flag≠1(通常 partner 経路)では [P+0x66d]≡a0 ⟹ 0x73-check≡range ⟹ **非 diverge は構造的**(1 点の偶然でなく writer2 の設計)。diverge が起こりうるのは flag==1 fire のみ([P+0x66d]=B[0x254]≠a0 可能)だが、flag==1 は variant=0 強制側(0x73≠時)=稀。
- ★R1 amendment への含意(上申)★: 忠実 model は [P+0x66d] = (flag==1 ? B[0x254] : a0)。0x73-check = descriptor[[P+0x66d]]。通常(flag≠1)は eForm/E104 slot 単一で正しい(現 curSlotForm 別引数は flag≠1 では a0 と同 actor ゆえ挙動一致)。★close 済の非 diverge status は維持・強化★。

## 4. self-correction(v2 の不完全、[[feedback_correction_is_not_automatically_improvement]])

- v2 §1-2 は [P+0x66d] の writer を「param-list copy-loop(0x80107328)」単一と記述=★flag==1 枝のみ、flag≠1 枝(0x8010743c)を見落とし★。
- 見落とし理由: v2 では copy-loop(flag==1)を辿り、その手前の `bne flag,1` が flag≠1 を別枝(0x8010741c)へ分岐する事実を writer 探索に反映しなかった(dscan3 は 0x8010743c も列挙していたが、v2 執筆時に copy-loop に注目して flag 分岐を追わなかった)。
- ★worker3 実測(src≠idx)が v2 の不完全を露呈=gate④型の再機能★。訂正版(本 doc)=[P+0x66d] は flag-gated 2-writer。

## 5. honest gap / 追実測(worker3 指名、REFUTE 可能)

- ★確認測定(REFUTE 可能)★: worker3 が当該 fire で **flag=B[0x253]=[0x801639D7] を dump**。本 reconcile の予測=**flag≠1**(variant=1 と整合、writer2 発動)。flag==1 だったら本 reconcile REFUTE(その場合 [P+0x66d]=B[0x254] のはずで 8≠2 が別要因)。
- ★flag==1 fire での [P+0x66d]=B[0x254] 検証★: flag==1 になる scenario/section で [P+0x66d] と B[0x254] が一致するか(writer1 の検証)=別 fire 必要(worker3 infra 制約、opportunistic)。
- writer2 の v1 loop 構造(複数 slot 書込)の完全 trace=cutoff(v1=1 の [P+0x66d]=slot は確定、それで本 reconcile 十分)。
- ★primary 非 diverge は close 済=本 reconcile は機構精緻化(非 diverge を構造的に強化)であって結論変更なし★。
