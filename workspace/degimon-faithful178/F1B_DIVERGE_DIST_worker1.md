# F1B diverge 分布 RE — [P+0x66d](0x73 check index)の value-chain と静的 dump 可否 — worker1

**date**: 2026-07-19 / worker1 / ★read-only 静的 EXE RE(doc-only、tree 非接触)、F-1(b) 後続★
**material**: EXE slps_017_97.bin(BASE 0x80090800)。tool=scratchpad mdis.py/xref.py/dscan4.py(taint-scan)。DG.SCN walker=scn66.py。
**前提**: F1B_SLOT_UPDATE_RE v2(真 writer=param-list loop 0x80107328、[P+0x66d]=B[0x254]=script[0x254]、B=[gp-0x6cec]=0x80163784)。
**規律**: 観測/推論/honest gap。req(1)=静的抽出可否の分岐点判定を先行(boss1 指示: 静的 dump 不能なら honest 報告+worker3 実測指名で OK、無理な静的化は不要)。

---

## 0. 結論 ★req(1)判定: 静的 per-section dump は INFEASIBLE(VM simulation 相当が必要)。diverge 分布は worker3 runtime 実測が oracle★

| # | 問い | 結論 | 次元 |
|---|---|---|---|
| req1 | [P+0x66d] の値は DG.SCN section data に静的に遡れるか | ★部分的=section bytecode 由来だが **runtime-VM 決定**(PC 軌跡+transform+先行状態)。単一 static section byte には遡れない★ | 観測(chain) |
| req1-chain | value-chain(v2 残 gap 接地) | [P+0x66d] ← B[0x254]=param 0xfb ← 0x66 handler state-machine ← VM PC stream [gp-0x6cc8](section bytecode)+ transform(0x800f50a8 固定 lookup + global 減算) | 観測 |
| req2 | 全 112 section の script[0x254] 静的 dump | ★INFEASIBLE★=各 section の値は VM を当該 0x66 まで実行しないと定まらない(handler state-machine が stream を stateful に消費)。静的 walker では算出不能 | 判定 |
| req3 | diverge 候補(値≠a0=8)の静的特定 | ★不能★→ worker3 runtime 実測に指名(下記 §4 の測定仕様)。section 母集団=V4_REACH_PATH の 112 entry を提供 | honest gap |
| 副 | 単一 slot か diverge か(R1 amendment の核心) | ★未決=「handler が B[0x254] を常に a0(E104)へ同期するか」次第。worker3 単一測定(8=8)は「常に同期」と consistent だが証明でない★ | 未検証 |

---

## 1. value-chain 全接地(観測、v2 残 gap クローズ)

### 1-1. 転写(param-list、v2 で確定)
- param-list loop 0x80107328: `[P + v1 + 0x66c] = 0x800f0ac8(0xfb+s0)`。v1=1 で [P+0x66d] = 0x800f0ac8(0xfb) = **B[0x254]**(B=[gp-0x6cec]=0x80163784)。

### 1-2. B[0x254]=param 0xfb の setter(観測)
- 0x800f0ac8(N)=`B[N+0x159]`(read)。setter=0x800f0cd0(a0=index, a1=value): `B[0x159+index]=a1`(観測: 0x800f0ce4 lw [gp-0x6cec] / 0x800f0cf0 addiu +0x159 / 0x800f0cfc sb)。
- caller=0x66 handler loop(FIRE_GATING §4): `param[state] = 0x800f50a8( 0x800f0ac8(state) )`(get→transform→set)。state=0xfb-0xfd を処理。

### 1-3. transform 0x800f50a8(観測=固定 lookup)
- 0x800f50a8(a0): a0==0xfd→0 / a0==0xfc→1 / …(値→値の固定写像、runtime 非依存の pure function)。★但し入力は param 値(runtime)★。

### 1-4. ★handler init = VM PC stream 読取(req1 の核心、観測)★
- 0x800f0edc(a0=dst): `[dst] = *[gp-0x6cc8]; [gp-0x6cc8]++`(stream cursor から 1 byte 読んで advance)。
- ★[gp-0x6cc8] = scenario VM の PC/命令ポインタ★: writer 60+ 箇所(xref)= jump handler(0x800ef4f0=0x19)/section-load/0x66 handler(0x800ee884)/全 VM 制御フロー = **DG.SCN section bytecode を実行する VM の instruction cursor**。
- → 0x66 handler は section bytecode を stream として stateful に消費し、param 群を評価。

### 1-5. B の初期 populate(観測、補足)
- B+0x0 系 writer(0x800f97b4 等)= `B[idx] = B[idx] - [gp-0x6c3b]` 等の in-place 変換(runtime global 依存)。B+0x159 param 領域 writer=0x800f0cfc(setter、§1-2)。
- → B は event/scenario 実行 state buffer。param 値は「section bytecode を VM が実行した結果」=runtime。

## 2. ∴ 静的 dump INFEASIBLE の論拠(req2)

[P+0x66d] の fire 時値を静的に得るには:
1. 各 0x66 section を VM が **当該 0x66 まで実行**した時の PC([gp-0x6cc8])位置を知る必要(jump/条件分岐/先行 section 依存)。
2. handler state-machine が stream から読んだ byte 列 + transform(0x800f50a8)+ global 減算を **simulate** する必要。
3. B の初期 state(先行 gameplay/event var)に依存。

= ★静的 walker(byte 読取)でなく **scenario VM interpreter の実装 + 初期 state** が必要 = 本 task scope を大きく超える★。boss1 方針「無理な静的化は不要」に従い、静的 dump は行わない(=honest 報告)。

## 3. 静的に言えること(観測、diverge 判定の材料)

- ★section 母集団★: V4_REACH_PATH の **112 entry(idx 1-224)が 0x66 含有**(section key5-10 の form-beat 列)。各 0x66 の直前は 0x67(FRAME_YIELD)固定ペア(entry22/32/97 で bit 確認)。
- ★diverge の定義★: 0x73 check index(=B[0x254])≠ range index(=a0=E104 slot)なら two-slot diverge。worker3 fire では 8=8(一致、非 diverge)。
- ★構造的示唆(推論、要実測)★: handler が param 0xfb を「active slot に同期」する設計なら常に B[0x254]==a0 → diverge なし → R1 の eForm 単一化が忠実。逆に scenario 毎に独立値なら diverge あり → two-slot 分離が必要。★静的に判別不能=worker3 実測待ち★。

## 4. worker3 runtime 実測 指名(req3、測定仕様)

★measure-first(boss1 方針): 静的不能ゆえ worker3 が実測★。
- **測定点**: 各 0x66 fire 時、0x73 check(0x80105c1c lbu)実行の瞬間に **[0x80146765](=[P+0x66d]=B[0x254])と a0(=[gp-0x6d08]=E104 slot)を dump**。
- **母集団**: V4_REACH_PATH 112 entry。全数困難なら代表 sample(census 22/32/97 + 構造の異なる entry 30/49/130/224 等の key5 以外/単一 0x66 entry を含める)。
- **判定**: B[0x254]==a0 が全 sample で成立 → 「常に同期=単一 slot」(R1 eForm 単一化 GO の材料)。1 件でも ≠ → diverge 実在=two-slot 必要+その値/entry/section を列挙(=忠実 model の分岐対象)。
- **既知 data point**: worker3 前回=fire で 8=8(一致)。desc5=0x8016B23C≠desc8=0x8016B374(index が別なら別 actor)。

## 5. R1 amendment への含意(上申、凍結継続)

- writer model は v2 で確定、value-chain は本 doc で接地。残る唯一の未決=**diverge 実在**(B[0x254] が常に a0 か)。
- ★R1 実装変更は §4 実測(diverge 有無)確定まで凍結継続を推奨★(boss1 裁定準拠)。実測後:
  - 常に同期(diverge なし)→ 0x73 check=eForm 単一化(SelectSceneVariant 簡素化)が忠実。
  - diverge あり → 0x73 check index=「当該 section の param 0xfb(=VM 評価値)」を model 要=curSlotForm でも eForm でもない第3実体の忠実 model(要別設計)。

## 6. honest gap / cutoff

- ★static dump 不能は「能力限界」でなく「値が runtime-VM 決定」という性質★(§2)。v1 の轍(scan 限界を不在の証明と誤読)を踏まないため、ここでは「静的に値は定まらない=infeasible」と性質で述べる(scan を増やしても出ない)。
- 0x800f50a8 の 0xfb→値 の完全 lookup / handler state-machine の direct-vs-loop 分岐の param 0xfa 依存 = 部分 RE 済(FIRE_GATING)、完全 simulate は §2 の理由で不要。
- B 初期 state の event-var 源(先行 SET_VAR 等)= runtime、静的追跡外。
- ★self-audit★: 本結論(infeasible)は「やらない言い訳」でなく、value-chain を末端(VM PC stream)まで観測で辿った上での性質判定。chain 各段(§1-1〜1-5)は全て disasm 直読=接地。worker3 実測仕様(§4)を具体化して次段を unblock。
