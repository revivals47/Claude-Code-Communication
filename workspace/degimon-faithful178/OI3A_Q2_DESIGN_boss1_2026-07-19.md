# OI-3a (q2) 設計doc: 0x66 B4実配線 — partner-form scene選択の段階配線(boss1 単一推奨、gate①上申用)

status: ★R1=CLOSE(boss1委譲検収 land、2026-07-19 08:0x)★ — r1-r5=f1b land(9e15368/3dc46d1/6c2f1a9/7d3bc55/04e5d96、push HOLD)。検証=★全条項literal充足・honest gapゼロ★(leaf25/25・g1 rule mismatch0+two-slot条項+oracle rule整合+ra-filter・g2三態・g3 desync0+warning attribution+care 4系統(golden37/caretick36/bulk89/CutsceneVerify178)全緑)。worker1 review=finding-1(two-slot collapse)捕捉→r5構造分離でRESOLVED。
- ★provenance開示(worker3自己訂正)★: 過去検証docの『bulk89 PASS』=oracle値relayの可能性(f1c独立実測の証跡なし)→★今回r5 runがf1c実測初回=現cumulative code(O2+step5+step4+0x67+R1全部入り)でALL PASS=遡及的にも非退行確認★。
- 残: v3(統合flag段階ON検証)→R2(OI-3b visual arc)→v4 user live。完成claim=v4まで凍結。
(gate①GO=07:35。初版status: 上申 07:3x)
入力=OI3_SELECTOR_RE_worker1.md(§1-9、4段構造+CD層REFUTE自己訂正+boss1 reconcile採録)/OI3A_DESCRIPTOR_RAM_RE.md(worker3、actor slot table実測)/OI3A_CSHARP_INTERFACE_worker2.md(TryScene+3 gap+flag 55)/boss1 0x80105be4直読。

## 0. 正premise(q1で確定した全chain意味論)

★0x66 = 「slot N(通常N=2=partner)のactor form classに応じた presentation scene への切替」★
```
DF70(定数2、field-side維持)→[section-init 0x800F0188]→E104(slot index)
→0x66 B4: selector 0x800aeca8
   → param-list start 0x80107258(per-scene task 登録)
   → dispatch 0x80105be4:
       special-case1: 現slot(+0x66d)actor form==0x73 → switcher(0x21,3)
       special-case2: flag[gp-0x6bf4]==1        → switcher(0x21,0)
       else: a0=E104 を slot index に actor form-id 読取
             → ★form range class → scene-id(対応表=§1、worker1充填)★ → switcher
→ scene switcher 0x800cfdf0: 現scene(gp-0x6da2/6da0)同一=no-op / 異なれば
   teardown → ★CD asset load(0x800cf400、stride39 record→buffer→0x8015102c)★ → finalize
```
- descriptor table 0x8013CDB4=actor slot table(slot1=B084=care-form/slot2=B104=partner、table static・record dynamic=worker3実測)。
- ★step3 MAPHEAD/DG.SCN資産とscene asset層は別層(worker1 REFUTE自己訂正)=単純再利用不可★。

## 1. ★対応表=充填完了(worker1全分岐読切+boss1 spot-check一致、2026-07-19 07:29)★

★精密化: scene record は全6 call site で 0x21 固定。form が決めるのは a1(mode/variant∈{0,1,2,3})★ — 『form→scene選択』を『record 0x21固定+form-class→variant選択』へ訂正。

| 条件 | a0(record) | a1(variant) | disasm根拠 |
|---|---|---|---|
| 現slot form==0x73 | 0x21 | 3 | 0x80105C4C |
| slot∈[2,0xa) & flag gp-0x6bf4==1 | 0x21 | 0 | 0x80105C9C |
| slot∈[2,0xa) & form<0x43 or form≥0x70 | 0x21 | 1 | 0x80105D6C |
| slot∈[2,0xa) & 0x43≤form<0x70 | 0x21 | ★byte-table[form-0x43]@0x801389E8★(45 entry static .data、大半02・例外01=form 0x48/4C/55/58-5C/64/68-6A/6C。boss1実bytes一致) | 0x80105D44 |
| slot<2 or ≥0xa & flag==1 | 0x21 | 0 | 0x80105D94 |
| slot<2 or ≥0xa & else | 0x21 | 1 | 0x80105DAC |
- a1(第2引数)→gp-0x6dcc store=本関数内read無、sibling scene関数群が消費(scene param共有、OI-9へ)。

## 2. ★単一推奨=2段階配線(R1 state-machine先行/R2 visual後続)★

### R1(本arcの実装scope): scene state-machine の忠実配線
- 新flag DEGIMON_SCENE_WIRE=1(既定OFF。DEGIMON_SCENE_DRIVER=1 が前提=両ON時のみB4実配線、WIRE単独ONはloud no-op)。
- 配線内容(全てEXE実測接地、発明ゼロ):
  1. ★供給鎖model★: RawDF70(const 2、新raw slot)→ section開始点(remakeのPlaySection開始)で RawE104=RawDF70(=0x800F0188 転写のmodel)。E104を発明的に直接2セットしない=機構をmodel(gate④教訓)。
  2. ★slot→form resolver★: slot1→CareFormIndexGlobal / slot2→Partner.DigimonId / 他slot→gap loud log(remakeにactor slot実体が無い分は宣言gap)。
  3. ★scene選択★: §1対応表をverbatim実装(special-case 2種含む。gp-0x6bf4 flag=raw slot model、意味論🅰)。
  4. ★scene switcher model★: 現scene raw slot(E?? = gp-0x6da2 model)保持、同一=no-op/変更=[SCENE-SWITCH id mode] loud log+現scene更新。★teardown/CD load/finalize=R2宣言gap(視覚実体なし)★。
- B6(flag#1 gate)/idle_stop exit等の既存c1-c5挙動=不変(B4のstub→実配線の置換のみ)。

### R2(次arc、本設計のscope外として起票=OI-3b): visual scene presentation
- scene asset(CD stride39 record)の内容RE(何が映るsceneか)→remake視覚実装。R1の[SCENE-SWITCH]眼で観測されるscene-id列が、R2の視覚化対象リストを実測で確定する=R1がR2のscopingを兼ねる。

## 3. 検証階段(PRESIDENT条件3=『何が揃ったらuserに見せられるか』)

| 段 | 内容 | userに見せられるもの |
|---|---|---|
| v1 | leaf harness(resolver/対応表/同一no-op) | — |
| v2 | ★EXE probe oracle★: dg_vmtrace に scene switcher 0x800cfdf0 probe追加(worker3 infra、観測のみ)→原盤sweepの(scene-id,mode)event列 vs remake ON sweepの[SCENE-SWITCH]列を★直接diff(behavioral oracle)★ | — |
| v3 | 統合ON(DRIVER+WIRE+既存flag段階ON)headless=非退行+scene state遷移整合 | — |
| ★v4★ | R2完了後: 視覚scene付きON実走 | ★user live=scene遷移が見える=凍結解除判定+push判断タイミング★ |
- ★R1完了時点ではuser可視の新画面は無い(state+log忠実まで)=v4はR2後、と正直に明示★。

## 4. (p4級) prereg(★gate①GO=2026-07-19 07:35 をもって着手時固着★)
- g1: v2 oracle diff=scene-switch決定(record,variant)整合(母数=sweep内0x66実行全件)。★PRESIDENT補足(07:35): EXE probe=観測のみ・probe台帳記録・★probe込みbuildと素buildの区別管理(sha/名称でsweep結果を紐付け、混同禁止)★を含む★。
  ★g1比較設計の固着(boss1、oracle採取後 07:3x — 判定基準の precise 化、緩和でない)★:
  (i) oracle event は ★ra=selector site 由来に filter★(selector外caller(実測: 0x800F1708→(1,0))=R1 scope外、開示のみ)。
  (ii) EXE oracle(実プレイ savestate)と remake sweep(fresh state)は入力(form/flag)次元が異なる → ★raw stream 1:1 でなく『per-event 決定rule整合』(各eventの入力(slot form, flag)→出力(record,variant)が §1 表と1:1)で判定★(d1教訓の先取り)。
  (iii) variant{2,3} の runtime観測=宣言gap(rule-level は静的接地+leaf harness全class網羅で担保。multi-form save 入手時に機会採取)。
  oracle artifact=OI3A_V2_ORACLE.md(probe sha=de34f1dc、10 event、(33,1)×9=form12→variant1 の静的表一致を実測確認済)。
- g2: OFF(WIRE=0)=bit不変(c1-c5挙動含む)+[SCENE-SWITCH] 0件。
- g3: 非退行=care 3系統+CutsceneVerify178+ON warning⊆OFF。
- 完成claim=v4(user live)まで凍結。R1の「配線完了」claimはv2 oracle green+v3で『state忠実まで』と限定表現。

## 5. 割当
worker2=R1実装/worker1=spec照合review/worker3=EXE probe(v2 oracle)+検証run。land=委譲検収(D4同条件)。

## 6. open items
- OI-3b: R2 visual arc(scene asset RE)。
- OI-9: gp-0x6bf4 flag意味論/a1(gp-0x6dcc)消費先。
- OI-4/OI-5b/OI-8=継続。
