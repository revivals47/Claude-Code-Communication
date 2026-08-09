# V4 0x66 到達 cross-section JUMP topology + eligible section 恒久記録 — worker1

**date**: 2026-07-19 / worker1 / ★read-only 静的 DG.SCN 解析(doc-only、tree 非接触)、v4 上申後 恒久記録★
**material**: DG.SCN(degimon_world_remake/extracted)。Len[256]=DialogueRuntime.cs verbatim。0x19 eval=scn_trace.py eval_0x19(shipping 忠実)。実測接地=worker3 V4_254_TRACE_DIFF/V4_CENSUS_FIRE_MAP/OI3B_V4_HOOK_PREREG。
**位置づけ**: v4 は 22:5(§5 dialogue-advance)で全 chain PASS 済(package 確定・上申)。本 doc は ①§254 dead-end の原盤性確定 ②代替 target(104 eligible)恒久記録 ③census artifact 扱いの明文化。
**規律**: 観測/推論/honest gap。全数 filter は範囲明記。

---

## 0. 結論(3 点)

| # | 問い | 結論 | 次元 |
|---|---|---|---|
| req1 | entry49 に section key 0x24(36)が実在するか | ★不在★=entry49 section keys={254,57,84,85,82,58,81,83}に 0x24 無し。∴ §254 pc0x50 JUMP_D→49:36 は **DG.SCN 原本レベルの dead-end=忠実 no-op(remake resolve gap でない)**。worker2 修正 不要 | 観測(原本 section table) |
| req2 | 112 entry を jump-take semantics で再分類 | ★104/112 entry が v4-ELIGIBLE★(section 開始→0x66 が dialogue/setup のみ、diverting JUMP/COND_BR/RETURN 無し)。dialogue=user page-advance で OK(v4 user-live)。8 entry が INELIGIBLE-only | 観測(全数 filter) |
| req3 | census fire map の扱い | ★『decode census』(force-play、execution 到達可能性の根拠に使わない)★=worker3 artifact 疑い反映。execution 到達の根拠は本 jump-take 解析 + worker3 play-mode trace | 方針 |

---

## 1. req1: §254 JUMP_D の原盤 dead-end 確定(観測、最重要)

- entry22 §254 pc0x50: `17 00 31 00 24 00` = 0x17 JMP_D(2-operand): op1=0x0031(=49)、op2=0x0024(=36)= scenario49:section36 への cross-jump(worker3 play-mode log 実測=『49:36 不在 no-op→dead-end finish』と一致)。
- ★DG.SCN 原本 check(本 doc)★: entry49 の section table = keys **{0xFE(254), 0x39(57), 0x54(84), 0x55(85), 0x52(82), 0x3a(58), 0x51(81), 0x53(83)}**。★key 0x24(36)は不在★。
- → ★§254 の JUMP_D は原本 DG.SCN で存在しない section を指す=原盤仕様の dead-end(忠実 no-op)★。remake の「49:36 不在=no-op」は **原盤忠実**(section-resolve gap でない)。∴ worker2 修正不要。§254 は正常 entry でなく、force-entry(PlaySection 22:254)で dead-end する dispatch section。
- ★含意★: entry22 の 0x66 発火は §254(dispatch dead-end)経由でなく、§5-§12(dialogue section)経由が正路(§2)。census が §254 に 8 fire を計上したのは force-play(decode census)の artifact(req3)。

## 2. req2: jump-take semantics 再分類(全数、観測)

- ★scan 範囲★: V4_REACH_PATH の 112 entry(idx 1-224)× 各 section。各 section 開始→最初の 0x66 まで decode(Len[256] + SJIS-aware)、間の control-flow を分類。
- ★分類基準★: ELIGIBLE = section 開始→0x66 に **JUMP(0x13-0x18)/COND_BR(0x19)/RETURN(0xFE/FF)が無い**(dialogue DLG/SPK/text + setup のみ)。= 0x66 へ linear 到達、dialogue は v4 user が page-advance。INELIGIBLE = 途中に上記 control-flow(divert/dead-end/desync)。
- ★結果★:

| 分類 | 数 | 意味 |
|---|---|---|
| ELIGIBLE entry | ★104 / 112★ | ≥1 個の dialogue-linear 0x66 section を持つ(v4 target 適格) |
| ELIGIBLE (entry,key) section | 462 | 適格 section 総数 |
| INELIGIBLE-only entry | 8 | eligible section 皆無(=下記) |
| INELIGIBLE 内訳(section) | COND_BR 186 / RETURN 125 / JUMP 16 | 0x66 手前で divert/dead-end |

- ★INELIGIBLE-only 8 entry★: 30, 38, 49, 51, 78, 79, 130, 224(全 0x66 section が control-flow gated)。
- ★重要な構造的性質★: ELIGIBLE 462 section の **全てが dialogue(DLG+text)を 0x66 手前に持つ**(no-dialogue path=0 件)。∴ 0x66 は本質的に「対話 beat の後」に発火(SPK/DLG/text→0x67 FRAME_YIELD→0x66)。deterministic な no-dialogue 自動発火 path は DG.SCN に存在しない=v4 は必ず dialogue-advance(user page 送り)を伴う(v4 user-live ゆえ問題なし)。

### 2-B. v4 target 推奨順位(gap=section 開始→0x66 の小さい順、top 12)
| 順 | entry:key | 0x66 offset | gap | 備考 |
|---|---|---|---|---|
| 1 | 110:6 | 0xbe | 22 | 最小 gap |
| 2 | 16:8 / 62:6-10 / 69:9 / 95:6 / 113:5 / 217:6 | — | 24 | 次点群 |
| ★採用★ | **22:5** | 0x90 | 26 | ★v4 確定 target(census 発火元 entry + 全 chain 検証 PASS 済、§254 との対比明快)★ |
- ★22:5 採用維持★: gap は最小でないが、census 発火元(22/32/97)+ worker3 全 chain PASS(OPTRACE pc0x6C→0x90)+ 0x67/0x66 pair 確認済 = 最も接地の厚い target。代替が要る場合は 110:6(最小 gap)等 103 entry から供給可。

## 3. req3: census fire map の扱い(方針、明文化)

- ★worker3 V4_CENSUS_FIRE_MAP(115 entry/481 fire)= 『decode census』★: EventOracle force-play(全 section を強制 PlaySection)による 0x66 decode 一覧。**execution 到達可能性の根拠に使わない**(force-play は自然 control-flow を経由しないため、§254 の dead-end も「fire」計上される artifact)。
- ★execution 到達の根拠★= 本 jump-take 解析(§2、control-flow-aware)+ worker3 play-mode trace(OI3B_V4_HOOK_PREREG、実 chain PASS)。
- ★教訓★: force-play census と execution-reachable は別次元。census の「fire 数」を到達可能性と混同しない(§254 の 8 fire は decode 上の存在であって play-mode 到達でない=worker3 trace で判明)。[[feedback_state_which_dimension]] の適用。

## 4. honest gap / cutoff

- ★JMP_D(0x17)の一般 target 解決★: 2-operand cross-jump(op1=scenario, op2=section key)。§254 の 49:36 は原本 check で dead-end 確定(§1)。他 INELIGIBLE section の JUMP target は個別未解決(cutoff、v4 に不要=eligible 104 で充足)。
- ★0x19 desync 回避★: ELIGIBLE 判定は「0x19 が 0x66 手前に出たら即 INELIGIBLE」ゆえ、0x19 desync 領域を eligible に誤分類しない(0x19 を含む section は COND_BR で弾く=保守的)。
- ★INELIGIBLE-only 8 entry の 0x66 到達性★: 未解析(全 section が control-flow gated=個別 JUMP/COND 追跡要)。v4 target には 104 eligible で十分ゆえ cutoff。
- ★no-dialogue path 不在★は 112 entry 全数の filter 結果(範囲明記)=「探索不足」でなく DG.SCN の構造的性質(0x66=対話後 発火)。

## 5. 恒久記録としての価値

- ①§254 dead-end=原盤忠実(worker2 修正不要)を確定=将来「§254 が通らない」再調査を防ぐ。
- ②104 eligible entry list=v4 の代替 target 供給源(22:5 が使えない状況でも即座に別 target 選択可)。
- ③census=decode census の次元分離を明文化=force-play 数を到達可能性と混同する再発を防ぐ。
- v4 本体は 22:5 で PASS・上申済ゆえ本 doc は topology 永続化 + de-risk が主目的(critical path 外)。

### 付: v4-ELIGIBLE entry list(104、idx 1-224)
1,2,3,4,6,9,10,11,12,13,14,15,16,18,19,20,22,23,32,33,34,35,36,37,39,40,41,42,43,44,45,46,48,52,54,55,60,62,63,64,65,66,67,68,69,70,71,73,74,77,80,81,82,83,84,86,87,88,89,91,93,94,95,96,97,101,107,108,109,110,112,113,116,117,120,123,126,127,135,136,137,139,140,141,142,143,145,146,155,157,164,165,166,167,168,169,189,190,192,194,216,217,218,219
(INELIGIBLE-only: 30,38,49,51,78,79,130,224)
