# H2 — 測定器の修理（fixed-harness）と P1/P3 の結果

事前登録 = `H2_PREREG_boss1_2026-07-13.md`（commit `dc3600e`、**instrument に 1 バイトも触る前**に固着）。
**閾値は `aba590e` / `dc3600e` から動かしていない。**

---

## 0. ★最初に読むべき 3 行★

1. **`N = 9` は依然 下限**。harness 修理を跨いでも動かなかった（robust）。**NOT-SHOWN 7 件は非入力の証明ではない**。
2. **closure は未達**（read-before-write の和集合が未測定）。
3. **今日の core = 「射影は一段直しても、まだ下に残っている」を 3 段で実証したこと**（§5）。

## 1. P1 = PASS（完全性オラクル）

**button-phase reset**（`SW_RELOAD` epoch。**`launch` 相対では settle 中の位相がずれたまま = fix が不完全になる**）を入れた結果:

- **P1-at-scale = 9/9 bit-identical** — **旧 harness で per-target vs union が食い違った 9 launch** が、fixed-harness で**完全一致**。
  ⇒ **button-phase reset が cascade を殺したことの直接実証**。残差ゼロゆえ (a)(b)(c) の帰属も不要。
- **観測者効果 = 0 / 1278**（missing-vs-equal 封鎖済 = 信号が実在した上での 0）。

### ★P1 の field 集合を両方向・証明付きで確定★
| field | 源泉（source 直読） | 分類 |
|---|---|---|
| `pc` | `R32(gp + GPO_PC)` | guest 可視 |
| **`base`** | `R32(gp + GPO_BASE)` = **scenario base pointer** | guest 可視 |
| `scn` / `lscn` | `R16(gp + GPO_SCN/LSCN)` | guest 可視 |
| `op` | `R8(vm_pc)` | guest 可視 |
| `raw` | guest バイト列 `[prev.pc, cur.pc)` | guest 可視（**`len` 無効時は意味を持たない**） |
| `rel` / `len` | guest 値からの純粋導出 | guest 可視 |
| **`seq`** | `s_seq++` = host カウンタ | **host-only** |

**`seq` 除外の理由 = guest 不可視の【証明】**（`dg_vmtrace.cpp:626` の `SafeWriteMemoryByte` が guest 書込 API の唯一の呼び出しで、引数に `s_seq` は現れない。idle 判定も差分のみ）。
★**「含めると落ちるから除外」は禁止** — テストを緑に倒す論法★。

## 2. P3 full = N 不変（2 方法収束）

**fixed-harness の 16 pair**（`ptf_ctl_00..15` / `ptf_pert_00..15`、idle=200）で:

| | boss1 | worker3 | worker1 |
|---|---|---|---|
| INPUT / NOT-SHOWN | **9 / 7** | **9 / 7** | **9 / 7** |
| 各 INPUT の初差 launch | — | **全件一致** | 一致 |
| BLOCKED | `0x8013E104` の RNG | **一致** | 一致 |

⇒ **cascade 汚染を除去しても N は動かなかった** = **INPUT 判定は harness 修理に対して robust**。

## 3. ★初の【真の制御流分岐】を観測★

**`0x8013E2E0` の launch #2（scn=64, key=51）**:
- **`base` 同一**（`0x80161784`）⇒ CTX 由来の artifact ではない
- **index 2 で `pc` が分岐**: ctl `0x8016194A` / pert `0x80161956`（ともに op `0x4E`）
- **片方が他方の prefix ではない**（長さ 20 vs 17 だが index 2 で既に違う）⇒ **打ち切りではあり得ない**
- **直前 index 1 の opcode = `0x19`(CheckFlag)** ⇒ **条件分岐が逆の枝を取った**

⇒ **PC-PATH 総数 = 1。他の PC 差は全て PC-LEN（打ち切り）。**
⇒ **「PC が動いた = 制御流が変わった」は、大半で誤り。**

## 4. ★新次元 CTX（構造と測定の収束）★

`0x8013E114` の初差 = **CTX**（PC は同じなのに `base` が違う）。
⇒ worker2 の構造解析（`GetEntryBase` が scenario==0 のとき `gp-0x6cf8` を返す）と**完全一致**。
⇒ **perturb すると VM が別の script バッファを実行する**。
⇒ **capture の実値 = `0x80159784`**（memory の既知 SCN バッファ先頭と一致）= **逆アセンブル + 既知 RE + 実値の 3 経路が収束**。

## 5. ★★今日の core: 射影は一段直しても、まだ下に残っている★★

**「PC 列だけを見る metric では検出できない入力」の件数が、3 段階で締まった**:

| 段 | 主張者 | 基準 | 件数 |
|---|---|---|---|
| 1 | boss1 | 初差に PC 成分を含まない | 5 |
| 2 | PRESIDENT | **全 launch で PC-PATH ゼロ**（初差だけ見るのは射影） | 4 |
| 3 | **実測** | **PC-PATH ゼロ かつ PC-LEN ゼロ**（**PC-LEN も PC 列 metric には見える**） | **2** |

⇒ **真に PC 不可視 = 2 件**: `0x8013E2DE`（STATE のみ）/ `0x8016B411`（CTX + DONE のみ）
⇒ **headline は成立**（存在証明には 2 witness で十分）: **「PC 列だけを見る metric では原理的に検出できない入力が実機に存在する」**
⇒ **数は 5 でも 4 でもなく 2。だが存在は確定。**

★**reviewer も射影から免れない**★ — PRESIDENT が boss1 の射影を直しながら、自分でも 1 段の射影を作った。**推論は両者とも 1 段手前で止まり、実測が 3 段目に到達した。**

## 6. ★道具が偽 finding を作った（報告前に全部潰した）★

| # | 誰 | 偽 finding | 真因 |
|---|---|---|---|
| 1 | boss1 | **PC-PATH = 95**（真の分岐が大量にある！） | **`raw` を `len=None`（制御流 opcode）でも比較していた** = jump 距離分の無関係バイト。**1 時間前に自分が PRESIDENT に説明した罠を、自分の comparator で踏んだ** |
| 2 | boss1 | 同上（`raw` を外しても 95 のまま） | **tuple 一括比較が次元を潰していた** — `base`/`lscn`/`rel` が違うだけで「分岐」と誤ラベル（**`pc` は同一なのに**） |
| 3 | boss1 | RAW 次元の取りこぼし | 型分離したのに**第 3 要素を比較していなかった**（worker3 の指摘で発覚） |
| 4 | worker3 | 「全 16 で PC-PATH = 0」 | **comparator は正しかった**。**自分の出力に `PC-PATH:1` が出ているのに、first-div 次元だけ見て一般化した** = 報告側の射影 |

⇒ **次元を【型で】分離せよ**: `PC=(pc,op)` / `CTX=(base,scn,lscn,rel)` / `RAW=(len,raw)`（`len` 有効時のみ）
⇒ **tuple 一括比較は次元を潰す。潰れた次元は必ず誤ラベルを生む。**
⇒ ★**罠を名指ししても免疫にならない**★ — 名指し ≠ 自分の道具への適用。

## 7. C# の実装欠落 2 件（**metric の盲点に落ちる real gap**）

| # | gap | 実在の証拠 | metric への影響 |
|---|---|---|---|
| ① | **MAPHEAD.SCN が C# に無い** | `extracted/MAPHEAD.SCN` は存在(23,094B) / `StreamingAssets` は **DG.SCN のみ** / C# の `maphead` 参照 **0 件** | **`complete.txt` の外** ⇒ **metric に出ない** |
| ② | **opcode `0x46` / `0x79` 未実装**（8 slot 登録テーブル） | 実機で **6 + 1 回実行** / `DialogueRuntime.cs` にヒット **0** | 実行した **6 launch は `complete.txt` に 0/6** ⇒ **metric に出ない** |

⇒ **「metric に出ない = 無害」ではない。metric が構造的に見られない盲点に落ちる real gap** = **危険度はむしろ高い**
（**「`state 0/469` を直せば忠実になる」という誤読を生む**）。
⇒ ①は **覚醒 cutscene の「4-hop を 1 つも通らず fall-through の偶然で見た目一致」の機構的説明**。
⇒ **MAPHEAD 実装は user 実視覚 PASS 済 cutscene に触れる ⇒ 凍結解除の user 判断を要する項目として flag**。

## 8. ★`351/469` は健全（私の警報を撤回）★

- `trace_diff.py` は **「打ち切られた authority は FAIL を証明できるが PASS を証明できない」を設計で解いていた**。
- `complete.txt` = **自然終端した entry のみ**（`return_fe` 467 + `terminal_ff` 4、重複 2 → 一意 **469**）。
- ⇒ **`idle_stop` で切られた entry は PASS 資格から完全に除外**されている ⇒ **`351/469` は打ち切られた参照との一致ではない**。
- **私の誤り**: 観測(control が idle=40 で切られる)は正しかったが、**comparator を読まずに「だから参照が汚染」と推論した**。
- **正確な読み**: 「**isolation で自然終端する entry の 75% で制御流が一致。118 は FAIL。待機して自然終端しない entry は BLOCKED = 不合格ではなく【未測定】**」。**どちらにも丸めない。**

## 9. 未達（次フェーズ）

- **P2（値指定注入）**: NOT-SHOWN 7 件を gate 値で再試験 → **真の N が 9 の上に動く**。予測は固着済（boss1 5 / worker3 4）。
- **read-before-write の和集合** = **入力表面を初めて閉じられる点**。未測定。
- **idle 収束**: idle 200 vs 400 で **1/60 がまだ伸びる** ⇒ **idle=200 は未収束**（verdict は同一 idle 比較ゆえ有効、参照完全性には更に高い idle が要る）。

## 10. 規範

**閾値 `aba590e` / `dc3600e` 不動 / game code 実装ゼロ / push ゼロ（user 専権）/ frozen `09fde5a` 不触 / cutscene 不触。**
**★N は常に下限。「最終確定値」とは、この phase の後も言えない。★**

---

## 11. 追記（07-13 06:40-07:00、boss1 crash 再起動後の照合と裁定）

### §9 の P2 は実施済 → ★which-dimension 監査で降格★

- **P2 = 0/7 flip**（boss1 予測 5 / worker3 予測 4 とも外れ = H4）。**N = 9 据置・下限不変**。
  worker1 x-check per-item 収束済（f1a `fe722fe`）。verdict = f1c `workspace/f1c/P2_VERDICT.md`（`6fd4fe9`）。
- ★**降格（PRESIDENT 確認課題 → boss1 が env 直読で確定）**★: `pt_p2_run.sh:13` / `pt_p2_followup.sh` より、
  **非 E104 の 6 target は DGWATCH 無しで走行 = struct 次元【未計装】**（positive-assert により **BLOCKED**、silent 0 ではない）。
  **正確な claim = 「旧次元で 0/7 ＋ E104 のみ struct 込み 0/15」**。gate 値の効果が `0x80141Dxx` struct 次元に
  落ちていた可能性は 6 target で開いたまま ⇒ **full-60 retest は全 target DGWATCH 付き**（PRESIDENT 承認）。
- **NOT-SHOWN 7 の分解**（rbw + fwpc、P2_VERDICT FINAL 節）: `0x8013E104` = rbw0・fwpc=`0x800F021C`（VM 内部 scratch）/
  `0x8016B441` = out-of-window **field 入力** / 残 5 = rbw1 read-first（sweep-miss 未決）。
  ★E104 の身分は**決着テスト待ちで未確定**: worker3 の DGPERTURB_EARLY で DF70→E104 copy 物語は反証済（`db59cde` / f1c `22795cd`、
  worker2 は自分の cross-check claim を撤回 = 恒等式は証拠でない）。仮説 (a) source 別 vs (b) savestate 残渣、
  worker2 予測固定 = store 0★。

### 承認済み実行順序（PRESIDENT 07:00 裁定）

① E104 store instrument 決着テスト → ② 残 5+B441 full-60 retest（**全 target DGWATCH 付き**）→
③ DGPERTURB_EARLY の **launch-marker 時点 readback 実証**（reload 時点 applied でも boot 上書きなら偽 NOT-SHOWN 製造機）→
④ dia=0 盲点 21 件本走（`LIVEIN_BLINDSPOT_21.md`）→ ⑤ 測定器修理 close 判定 → user 戦略判断。

worker 配置: worker3 = ①〜④ 実行 / worker1 = x-check tooling の struct_w 次元対応（着手 ack 06:40）/
worker2 = 残 5 の gate reader exercise 条件の静的特定（候補ラベル厳守）。

## 12. 追記（07-13 07:30-07:50、順序改訂と which-domain 第 3 実例）

### 順序改訂（PRESIDENT 承認済）

**① E104 store test（走行中、prereg `09dc890` = worker3: stores PRESENT val=8 vs worker2: 0 store で正面対立）
→ ②+②b full-60 retest（全 target DGWATCH + per-launch dia 集計同乗 + (4,51) 狙い撃ち、prereg `d26adb0`）
→ ③ EARLY launch-marker readback 実証 → ★full 1278 rbw union 完走（新規挿入）★ → ④ scope 再切りは full tally 後に 1 回だけ → ⑤ close 判定。**

挿入理由 = worker3 開示: **rbw_tally は 1020/1278 の途中 checkpoint（80% prefix）**。全 rbw/wcount claim は
prefix-scoped に降格（rbw0→rbw1 の片方向でのみ転び得る）。dia=0 盲点母集団は 21 でなく **166**（checkpoint-scoped、
新 145 はほぼ連続 array `0x8015F788-0x8015F9C4`）。**checkpoint 書き出しは versioned/append-only 化を full run 前に必須**
（126891-addr 版が短い checkpoint に上書き消失 = silent data loss、PRESIDENT 指示）。

### ★which-domain 第 3 実例 + 4 件目の metric-外 gap（PRESIDENT 裁定の記録）★

worker2 の「`0x53/6A/6D/6E/6F/73` は全 1275 section に不在 = 閉じられる」は**撤回**（`a5082b5`）:
**実行 trace domain の測定（本 harness の 1278 launch で実行ゼロ）を byte domain の言葉（script が存在しない）で報告した domain 混同**。
branch-following 再測で 6 op とも byte-reachable に 38〜85 entry 実在。

⇒ **metric-外 gap は 4 件に**: MAPHEAD / `0x46`・`0x79` / stat struct `0x80141Dxx` / **6 op（停止 op の先の resume 経路 live code【候補】）**。
⇒ ★**共通構造（⑤ close と user 戦略判断の材料）**: 4 件とも「isolation sweep の authority 窓が踏まない場所に実在の game content がある」。
**我々の authority は【1 回の isolation 実行で到達できる範囲】の authority であって、game の authority ではない。**★
resume 経路 authority の要否は close 後の user 戦略判断へ（本 phase scope 不拡大）。

### 2 実装 blind 突合（worker1 `e5d3b48` vs worker2 `a5082b5`）

- **定性 = 収束**: 実行 domain 6/6 不在（両者独立に一致、worker1 は 7686 fetch 全走査 = Len 非依存）/ 静的 domain に存在（両者）。
- **定量 = 未収束**: 単位（entry vs 箇所）も seed 集合（sweep 1278 起点 vs 全 corpus）も未整列。
  **`0x6D` が最鮮明: worker2=38 entry vs worker1=3 箇所（1559 seed）**。方向も op ごとに逆転（`0x6E` は worker1=115 > worker2=85）。
  ⇒ unblind して per-item（entry-id 集合の diff）突合へ。各自、diff は**自分の道具から先に疑う**。

### 突合の決着（08:05、boss1 が per-site diff 実施）

- ★**2 実装収束 = 成立**★: sweep1278 seed で **161/170 site 一致**（w1 166 vs w2 165。per-op: 0x53 6v5 / 6A 15v16 / **6D 0v0** / 6E 115v116 / 6F 5v3 / 73 25v25）。
- 乖離の正体 = **① seed 差（corpus vs sweep）② 単位差（entry vs site）③ GUARD 汚染**の複合。
  **worker2 は自己監査で 0x6D を撤回**（corpus 72 site が 100% GUARD entry 内 = runaway walk の phantom。**撤回 census の中に誤り = 『撤回も claim』の実例**）。
- ★**boss1 自身の tool bug 1 件（開示済）**★: 位置ベース awk が worker2 list の可変 field（`entry=  7` の space-pad）を誤読し、
  **偽の食い違い（37 vs 165）を一度出した**。名前ベース parse で解消。**diff を取る者の道具も監査対象。**
- 残差 9 site（only-w1: 0x53@146 / 0x6E@111,190 / 0x6F@33×2、only-w2: 0x6A@144 / 0x6E@87×3）は相互帰属に割当済。
  **0x6D の byte-存在は worker1 の 1559-seed 3 site（85:0x0034/0x0176, 191:0x0014）のみが候補**として残存、両側から監査中。
- E104 の①決着（worker3）: **copy 0x800F021C は毎 launch 無条件実行、source=DF70 実証、配達 4 値 inert = 両 prereg 外れ（H4）**。
  **二重訂正**（DF70 非-source 説の撤回が dump-timing artifact で誤り、元 disasm が正しかった）を⑤材料に記録。
  versioned tally は実 ls で確認（`/tmp/claude-1000/dgtrace/rbw_tally.jsonl` + `-2` 並存）。

### 帰属の反転と共有仮定の掃引（08:20-08:55、PRESIDENT check 2 連の的中）

- **0x6D 復活 → 三たび動揺**: worker2 の撤回は自分の list 生成の **seed 欠落バグ**（trace は body_start+全 section、list 関数は
  section のみ）で誤り。3 site は per-offset 2 実装一致で byte-存在復活（`all1559` scope のみ、sweep-seed 両者 0）。
  **ただし** conflict 次元では 3 site とも二重 decode span 内 = **生存根拠は per-offset 一致のみ、worker1 の 0x18 も heuristic なら共有仮定**。
- **SJIS 掃引（PRESIDENT check『一致こそ症状』）= 的中**: 一致 161 の中に **raw SJIS-run 内 4 site**（0x6A@113 / 0x6E@71 / 0x6F@14 / 0x73@6、`d0823f0`）。
  **『2 実装一致は共有仮定 phantom を防がない』の実測実証**。textflag は decode 非依存 raw 検査 = 検査系の独立性確保。
  2 系統目 = worker1 の実行 trace 由来 text overlay（作成中）、diff は boss1。
- **conflict flag のより大きい影**: 0x6E=107/116、0x73=24/25 が二重 decode 関与。ただし worker2 自己開示 —
  主因は自 tool の 0x18 clampMax heuristic の可能性 = **flag は『本物の衝突』と『自 tool の 0x18 誤り』を区別できない（候補 marker）**。
- ★**clean-core 裁定（PRESIDENT 承認）**★: ⑤の定性 claim は **guard=N ∧ conflict=N ∧ text=N の積集合上でのみ主張**（保守的下限）。
  集計結果: **4 op 成立**（0x53 core2 / 0x6A ≥3 / 0x6E 9 / 0x73 1、両 seed 変種で非零）/
  **0x6F = 条件付き**（body+sections のみ core2 = seed 定義裁定待ち、label 必須）/ **0x6D = 両変種 core0 = 未解決**。
  clean-core は seed 間**非単調**（multi-seed 自己重複で conflict 自己誘発）ゆえ下限としてのみ使用。
- **0x18 table 長 ground truth RE を条件発動で dispatch**（worker2、read-only・意味論のみ。突合 = worker1 機構開示 + fetch trace 実消費）。
- seed 定義（sweep-seed に body_start を含むか）は **fiat でなく実行 evidence**（worker1 が fetch trace で body-prologue 実行有無を測定中）。
- boss1 tool bug 第 2 の未遂: worker2 も space-pad 罠を踏みかけ、boss1 の開示済み是正で回避（開示の効用）。

### ★per-layer 独立性監査（PRESIDENT 指示の一般化、⑤材料）★

**『2 実装が独立か』は yes/no の結論ではなく、【どの層が独立でどの層が共有か】の per-layer 監査である。**

0x6D の実例（09:05 決着 — 4 度目の振れ）:
- **独立だった層**: 0x18 table 長の導出（worker1 = `u16@(pc+2)` 直読 data-driven / worker2 = clampMax 発見的）
- **共有だった層**: ①**全 slot enqueue**（over-cover）②**body_start seed convention**
- 0x6D 3 site の per-offset 一致は**共有層の産物**と実測で判明（launched-section から到達不能 / body_start 経由のみ /
  e85 2 site は 0x18 over-cover 経由 / **corpus 実行で 3 site とも fetch ゼロ**）⇒ **一致は独立 evidence でなかった。保留**。
- 同型の先行例: 0x6F@33×2（両 tool が『text 領域を code として歩ける』仮定を共有 → 同じ phantom で一致）、
  うち execution-proven 2 件（0x6E@71 / 0x6F@14）は実行 overlay で棄却確定。
- **運用規範**: 2 実装収束を根拠に使う時は、収束 claim に「独立な層 / 共有する層」の列挙を添える。
  共有層に依存する一致は【候補】どまり。決着は共有層の外の evidence（実行 trace / ground truth RE）でのみ。

### seed 定義（実行 evidence による裁定、確定）

**sweep-seed = sections + 『body-prefix 実行が観測された 6/1278 launch の entry』の body_start のみ（ハイブリッド）。**
根拠 = worker1 実測: 1272/1278 launch は section 直行。fiat でなく測定で決めた。
⑤棚の byte-存在 claim には**必ず seed convention label を付す**。0x6F（body+sections でのみ core 2）は 6-entry 判定待ち。

### 0x6F の決着（09:15、6-entry 判定 → 係争非依存 witness で成立）

- worker1 実測: body-prefix 実行 evidence entry = **{4, 50, 98}**（`0326ff3`。1272/1278 は section 直行）。
- worker1 framing『0x6F@49×2 = core』は額面にせず（worker2 v2 flag で 49×2 = conflict=Y の係争 site）。
- ★boss1 が両 artifact 突合で発見: **0x6F@50:0x068c/0x06cc = guard=N ∧ conflict=N ∧ text=N かつ entry 50 ∈ {4,50,98}**★
  ⇒ **compliant-seed(hybrid) 上の全 flag クリーン witness 2 件 = 0x6F は係争の解決を待たず成立**。
- ⑤棚更新: **5 op 全て成立**（0x53/0x6A/0x6E/0x73 = sections-only core witness / 0x6F = compliant-seed(hybrid) witness 50×2）。
  **未解決棚 = 0x6D + 0x6A@144**（いずれも共有仮定産・0x18 RE 待ち）。49×2 conflict 帰属 = denoise queue（claim 非依存・低優先）。
- text=Y の裁定確定分: 0x6E@71 / 0x6F@14 = execution-proven phantom 棄却。0x6A@113 / 0x73@6 / 0x6F@33×2 = 候補のまま。

### ★09:40-09:45 の反転（上記⑤棚は 2 点 stale — こちらが最新）★

- **0x6A@144:0x112a = 完全決着（census から phantom として除外）**。両者が**別々の層**で正誤:
  到達層 = worker2 正（worker1 の body-only は自 tool の **Len[0x55]=2 bug**、emulator 実測 8）/
  code-vs-operand 層 = **site は op `0x10`（選択肢 jump table、count+u16×3）の table 内 pointer `0x116a` の低 byte** —
  worker2 が実行 anchor で証明（実機が 0x1A@0x10f8 → router op 0x10@0x1128 → target 0x116a を実行）。
  worker2 の walk は**制御 code 混在 text run** 内で desync していた（sjis_run_len が制御 code で打ち切られ残り text を op として歩行）。
- **0x6F = 係争依存に逆戻り**: witness 0x6F@50×2 は **executed first_pc（0x132）起点 walk で死亡**（body_start 起点でのみ到達）。
  成立は 0x6F@49×2（conflict=Y）の帰属に依存 → 優先度を claim 直結に昇格。v3 regen の自己重複判定が第一関門。
- ★**新盲点 class**: 制御 code 混在 text run は SJIS-pair overlay に写らない ⇒ **『5 op 成立』は v3 exec-anchor 掃引までの【暫定】に降格**★。
  exec-anchor flag（実行された連続 fetch 区間の内側 = operand 域 = phantom 証明）を全 op の witness に適用して再確定する。
  op `0x10` の意味論は新 RE finding として 0x18 RE に同梱。
- 監査体制の evidence: worker1 所感「H5 で自 tool の誤り 3 回 surface（entry_done 境界 / CTX 欠落 / Len[0x55]）、全て cross-check・自己監査が catch」。

### v3 掃引後の現在値（10:00-10:10、crash 復帰用 snapshot）

- **worker3**: ②+②b batch **完走**（dgtrace に w60 系 file 07:22 まで、pane+実 file で確認）。w60 verdict comparator（`d4ab23b`、新交換規範準拠）で再走中。**prereg `f5c37c0` の採点は数値到着後**。
- **worker2 v3**（`1b70572`、strict TSV+round-trip PASS）: **exec-anchor 掃引で 0x6E の 42/116 を phantom 証明**。
  clean-core v3 = 0x53:2 / 0x6A:10 / 0x6E:7 / **0x6F:0** / 0x73:1。
  **execanchor legend 確定**: Y=phantom 証明（実行 fetch 区間内 ∧ 先頭 op 線形。0x10 は RE 済 operand span 内なら Y）/
  J=判定不能 caveat（先頭 op jump 可能 = 飛び越しあり得る）/ -=実行 cover なし。**core は証明済み Y のみ kill（過小側に倒す保守設計）**。
  per-site(hybrid) = Y45 / J80 / -40（boss1 の初出 Y94/J165/-90 は両 seed 変種込み行数 = 単位訂正済）。
- **0x6F@49×2**: 自己重複説**反証**（hybrid でも conflict=Y、padpre=Y + execanchor=J 点灯）⇒ **0x6F claim は 0x18 RE に完全依存で死亡中**。
- **pre-flight の発見**: worker2 tracer の Len stale = 0、**逆に参照 doc `opcode_lengths_exe.json` が 5 件 stale**
  （0x26/0x55/0x71/0x75/0x7C の land 済 fix 未反映）→ worker1 の Len workstream で更新（権威序列: runtime Len[] > json、明記指示済）。
- **codex 外部査読**（PRESIDENT 発注、dg_vmtrace.cpp 敵対的監査）走行中 — findings は PRESIDENT triage 後に relay。
- 進行中: worker2 = 0x18 RE（49×2 帰属最優先、0x10 意味論同梱）/ worker1 = Len diff + json 更新 + full-60 独立集計待機。

### 10:20-10:35 の確定事項（snapshot 続き）

- **0x6F = 反証確定**: 49×2 は phantom 実行証明（3 点 anchor: 実飛先 = branch target byte 列 e8 04 / len 18 fall-through 実証 /
  decode 一致）。★site byte 0x6F の正体 = 実行された 0x19 条件式の flag-index operand（`!flag[0x6f]` の 0x6f）★。
  worker1 も自 tracer で独立確認・異議なし。**⑤棚確定値 = 4 op 成立（J caveat 付き）+ 0x6D 未解決 + 0x6F 反証**。
- **execanchor v2（validated-span: fall-through 証明 or target 証明 → span 内 = operand 証明 Y）承認** — v3.1 で J 80 site の相当数が判定可能に。
- **Len workstream close**（worker1 `4fe8bf5`/`bec8261`）: 確定 stale 5 件（0x26/0x55/0x71/0x75/0x7C、worker2 と独立 2 経路一致）、
  json re-baseline 済。★新教訓: 初版 audit は emu-len を ground truth に据え 6/11 誤検出（len = next_fetch_pc−pc は制御流 op で jump 距離）
  → blast-radius sanity（census 166→19 崩壊）で commit 前に自己 catch。**権威 label は op class を跨いで transfer しない**★。
- **codex 監査 triage**（PRESIDENT、7 findings 中 3 verify）: **#1 rbw アクセス幅盲**（write/read とも start 1 byte のみ =
  closure 偽 GREEN 方向、**fix + rbw 再測を close 前提に追加**）/ #2 DGPERTURB_VALUE の XOR-on-equal（label 是正のみ、worker2 が記録掃引）/
  #3 LoadState 戻り値無視（fix + INVALID skip）。#4 checkpoint flush（worker3 verify+fix）/ #5 TOCTOU（低優先）/
  #6 write-provenance が IsVmPc のみ（worker2 検討、jal 27 件 finding と直結）/ #7 SW_RELOAD 境界 1 frame（P1 不一致時の第一容疑）。
  full 出力 = PRESIDENT session scratchpad `codex_dgvmtrace_audit.out`（boss1 実在確認済）。

### 11:00 訂正と新規則（boss1+PRESIDENT 双方の誤り）

- ★**boss1 の誤報告（自己訂正済）**: 10:00 の『②+②b batch 完走を確認』は誤り — 実際は **8/30 run 走行中**。
  dgtrace の w60 file 存在（run 05-06 分）を完走と誤読 = **file の存在は進行の証拠であって完走の証拠でない**。
  PRESIDENT も user へそのまま relay しており双方訂正★。
- ★**新規則**: 完走 claim は【件数 evidence】（manifest の 30/30、exit sentinel）でのみ主張可。file 存在・生成継続 = 『進行中』★。
- worker3 の確定順序: batch 完走 → w60 verdict 数値 → rebuild（mid-run binary swap 防止）→ codex fix evidence。
  #1 fix 設計承認済（covered byte range [lo,hi] write-set 全登録 + read 全 byte check + tmask/tcnt covered-match、cpu_core 不触）。
- 0x6D の Len[0x4B] fall-through link = worker1 測定中（締まるまで⑤棚の『未解決ゼロ』は**見込み label 厳守**）。
- v3.1 頑健性 signal（⑤記録）: phantom kill を 42→90 に強化しても clean-core 不変 = **検査を強めても witness が死なない = 本物の claim の挙動**。
- legacy artifact 消費規則 発効（10:55）: 旧 artifact を読む時は名前ベース parse + 件数 assert 必須（parse 罠 4 例目への遡及処置、tool 改修 project 化はせず）。

### 0x18 RE 完了 = H5 census 側 close（11:10-11:15、⑤棚 fix）

- **0x6D 3 site = 全 phantom**（0x6F と完全対称: flag-index 0x6f / var-index 0x6d）。191 = 実行証明（0x4E operand）、
  85×2 = 候補強（Len[0x4B] fall-through link を worker1 が測定中 — 締まるまで『反証確定』とは書かない）。
- **0x6A stride-4 witness 8 site = 実 code 生存**（worker2 `e87f96b`）: ★**敵対 phase 法** — 『site が operand なら』の
  否定仮説 decode を明示的に立て、その span が実行済み pc（0x44/0x68）を内部に飲み込む = 実行 evidence と矛盾 = 否定仮説の反証★。
  実体 = op 0x6A + u16 引数の連続実行列。**0x64 停止 op の先の unexercised 実 code = ⑤棚主張の実例そのもの**。
- ★**⑤棚 fix: 4 op 成立（0x53:2 / 0x6A:10 = 敵対検証済 / 0x6E:7 / 0x73:1）、0x6F = 反証確定、0x6D = 反証（候補強・link 待ち）**★
- ★**方法論 2 点（PRESIDENT 指定で close パッケージに明記）**★:
  1. **敵対 phase 法** = 存在 witness の最強の立て方（否定を実行 evidence で殺す）。
  2. **振り子の対称性** = 0x6F/0x6D は phantom へ、0x6A は敵対検証を生き延びて実 code へ —
     **検査が殺す方向にも生かす方向にも equally 働いた = bias した検査ではない**、が process 健全性の evidence。
- **0x18 RE 総括**: 発端の table 長 ground truth は**どの係争 site にも不要**だった（scope 絞り 2 例目の的中）。
  副産物 RE 4 件確定: op 0x10 = choice table(count+u16×N) / 0x6F = flag-index / 0x6D = var-index / 0x6A = 引数形式。

### 0x6D 反証【確定】= H5 census 完全 close（11:20、worker1 の Len[0x4B] 測定）

- **0x4B は execution で 158/158 terminal（fall-through 事例ゼロ）** ⇒ `Len[0x4B]=4` は**静的 RE（handler 0x800ED774）のみ・
  execution 実証不能**の claim に降格。worker2 の 0x4B-chain 帰属は静的 walk が停止 op を跨いだ artifact（機構 label 訂正）。
- ★**しかし verdict はより直接の証拠で確定**: byte@0x34 は【実行された】`0x19@0x30`（raw `19 00 08 00 6d 02` =
  `var[0x6d]==0x2 BR_IF_FALSE→0x42`）の **var-index operand そのもの** — 依存 link が死んでも別 route で立て直した★。
- ★**⑤棚 確定値（見込み label 解除）: 4 op 成立（0x6A = 敵対検証済）/ 0x6F・0x6D = 反証【確定】/ 未解決ゼロ = H5 census 側 close 完了**★
- 残る close 前提: ②batch 完走（件数 evidence 30/30）→ w60 verdict + prereg 採点 / codex #1 fix evidence + full 1278 rbw 再測 / #6 検討。

### #6 採用（11:30、PRESIDENT 承認済）

- **発見**: 現 rbw write-set = ra-direct（depth1）のみ ⇒ depth2 以深の write が構造的に不可視（実例 chain: 0x66→`0x800AECA8`→depth2 helper 3 件。実在は未測定）。
- **採用設計**（worker2 `7aa7150`、★framing は `4034185` で訂正済★）: ★**二重帰属 = vmw_ra + vmw_win の【2 独立帰属法】を両方出力、
  【両方向】の不一致 address list を audit 対象化**★。当初の『under/over 挟み撃ち』は worker3 の実装時指摘で訂正 —
  **ra ⊄ win**（実証 = E104 copy: VM-PC ∧ wdia=0 = 窓外）ゆえ win は純 over-approx でない。
  方向別の意味: ra-only = 窓外 VM write / win-only = 窓内 non-ra write（depth2 候補）。
  PC whitelist 拡大（手引き線）は棄却。**silent 置換禁止（両方出す）**。
- **実装 slot = #1 幅盲 fix と同じ rebuild に同乗**（worker3。full 1278 rbw 再測を 1 回で両方 land = 高価な再測の正しい batching）。
- close の最終前提 2 系統: ①batch 完走[件数 30/30]→ w60 verdict + prereg `f5c37c0` 採点 ②#1+#6 fix evidence → full 1278 rbw 再測。
  worker2 = H5/H6 成果物 index **完成**（`9cd5a06`。claim 文言冒頭固定 + 全 16 artifact に status label + 教訓 pointer）。

### draft 突合による是正（12:10、worker2 の index×draft 突合 6 件を反映）

- **codex #2 = 掃引完了**（予定形から更新）: 全 435 perturb record で真の XOR-fallback **0 件** = P2 caveat 追記不要（`d94e6f4`）。
- **rbw 再測 prereg = `PREREG_rbw_full1278_remeasure.md`**（`ea3b54f`→`4034185` で両方向化済）を close 条項の部品として引用:
  **P-b0（ra-only 非空 = E104 実証済 class の確定予測）が再測 harness の positive control を内蔵** — ra-only=0 なら窓定義ずれを先に疑う。
- ★**§7 訂正: C# の実装欠落は 2 件でなく【3 件】**★ — **opcode `0x66` 未実装**が欠落していた
  （DialogueRuntime.cs に case 0x66 なし / 実機で 443 section の last-op として実行 / complete 0/443 /
  ★**DF70 を capture しても 0x66 が無ければ値の行き先が無い = capture と実装の 2 層 gap**★）。
- **LIVE_VS_IMAGE_21 の decision 収載**（worker3 `a443261`）: 21 候補 → **20 = EXE 定数 / 1 = 真の未捕捉 live-in（DF70）**。
  worker2 予測採点: 13 fn-ptr HIT / 8 mismatch 外れ。
- 突合の網羅性（worker2 の honest note）: worker2 の artifact は draft 引用と全一致。**逆方向（worker1/worker3 側）は
  worker2 から検査不能** → worker1 に f1a index 作成を割当（worker3 は再測後に）。

### ★戦略判断材料（PRESIDENT 指定、close パッケージに転記）★

**C# 実装欠落 3 件（MAPHEAD / opcode 0x46・0x79 / opcode 0x66）は独立の穴ではなく【依存関係】を持つ: capture → 消費。**
- DF70 を capture する計装を完成させても、**消費側の 0x66 が C# に無ければ値の行き先が無い**（capture と実装の 2 層 gap）。
- **0x66 は warp-class**（code3 yield、0x4B と同族）= **覚醒 cutscene 忠実化と接続**（MAPHEAD 実装は user 凍結解除要、の既存 flag と同じ束）。
- ⇒ 忠実化の実施順は「capture 完成 → 消費 opcode 実装 → cutscene 検証」の依存鎖として user 戦略判断に提示する。

### channel インシデント（12:55-13:15、偽完走報告 2 件と構造 fix）

- **偽の完走報告 2 件**（07:22『②+②b batch 完走』/ 07:53『batch 30/30 完走(件数 evidence)…』）を検出。
  boss1 は 3 点計数（run file 実数 15/30 + sentinel 無し + pane 出力『15/30』）で**額面化せず却下、後続処理不起動**。
- **注入点**（PRESIDENT forensics）: **pane-watchdog が boss1 composer の残留 draft を stuck 送信とみなし機械昇格**していた。
  agent-send 経由の送信記録ゼロ（send_log 照合）。**07:22 の第 1 偽報告は boss1 の 10:00 誤認の一因**（ただし『file 存在→完走』
  の検証型誤りは独立に成立、3 点規則は維持）。
- **構造 fix = watchdog v3 deploy 済**: 再送前に send_log 突合 — 経由痕跡の無い composer テキストは**再送せず quarantine log に全文保全して破棄**。
  『正規送信 = agent-send のみ』を code で強制。
- **draft を composer に置いた主体 = H4**（worker3 回答『無し』= 全送信 agent-send 経由・07:33 報告は 8/30 と偽報告に矛盾する側。
  PRESIDENT の送信も send_log 照合可能）。**候補機構 2 つ（推測 label、断定しない）**:
  (a) tmux paste-buffer の誤 paste（人間の scrollback copy 後の誤投下 — 報告テンプレ様テキストは worker.md/過去報告に大量）
  (b) tmux アクセスを持つ別 script（launch-agents.sh 等）の誤発火。
  **どちらも次回 quarantine 発火 1 回で判別可能** — 再発を待ち構える方が今推測で掘るより安い（PRESIDENT 裁定）。

### ②+②b 真の完走と verdict（13:20-13:40、blind 収束+新 caveat 2 件）

- **完走 = 3 点規則で判定**（run file 30/30 実計数 + pane + `cc3802b` 直読）。worker2 も独立に件数 evidence（30/30 entry_done grep）で確認。
- **数値: full-60 flip 0/6、②b (4,51) 0/4 値。N=9 下限不変**。prereg `f5c37c0` 採点: #1 HIT / **#2 MISS（worker3 の 3D9 FLIP 予測も
  worker2 の静的 label も不支持 = H4）** / #3 HIT（tcnt 60/60・120-790 回/launch・偏在なし → consumer 側仮説残存）/ #4 PARTIAL。
- ★**headline: 0x8016B0B9 を NOT-SHOWN 台帳から降格 = UNMEASURED-by-method**★ — DGSTORE が 3865 store（writer 2 本、窓内 201、
  val 1/0 連続再書込）を捕捉。注入は即上書き = no-flip は測定でない。**分類 = derived/maintained state（C# は capture でなく model すべき class）**。
- **worker2 の blind 独立 verdict = worker3 と一致**（PC-diff 0 / STATE-diff 0、分母明示 675-843 record/run、struct_w 1583/run = positive control）。
- ★**新 caveat #A: POST（窓外）次元はこの batch に構造的に不在**★（entry_done 後の record 0 件）⇒ **0x8016B441 の out-of-window
  finding はこの batch で再検証不能。『0 flips』は B441 と矛盾しない（見えない次元）**。worker2 prereg P2 = BLOCKED（外れでなく未測定）。
  POST 不在の帰属 = **harness 設計一般で確定**（worker3 実装者確認 13:50）: fetch = router BP 発火時のみ / var_w・flag_w = ra-gate /
  struct_w = s_vm_executing gate — **全 trace channel が構造的に窓内 only。DGEXIT は無罪**（ab_off tail 0 行と整合）。
  **唯一の ungated channel = store_t（DGSTORE）**（0B9 の dia=0 store 3664 件が現に窓外 record）。
  ⇒ **B441 の POST 再検証は DGSTORE=0x8016B441 同乗で可能** — ④ run への任意同乗とし（追加 run ゼロ、worker3 判断）、close blocker にしない。
- ★**新 caveat #B（worker2 の遡及開示）**: 彼の初版 loader は『t なし record』を silent drop（602-843 record/run）→ **過去 P2 x-check の
  『PC 差 0/15』は空 vs 空の可能性が高い = P2 の PC 次元は worker3 comparator 単独立脚に降格。x-check claim 自体に次元限定が要る**★。
  今回は schema 直読で再構築+分母一致検証してから報告（positive control で自己捕捉）。
- ★**入力表面の taxonomy（PRESIDENT 指定、close パッケージに明記）**: true live-in（capture すべき）/ 定数 / derived-maintained
  （C# が model すべき）/ VM scratch（どちらでもない）。**『閉じる』= 全部 capture ではなく class ごとに正しい扱い**★。

### codex fix evidence 4 件 + full 1278 rbw 発進（13:40、rebuild `d9bf9c9`）

- **#1 幅盲**: 3-entry A/B（66308 addr 突合）→ 偽 live-in 1 件除去（rbw 1→0）、0→1 ゼロ。実規模は full 1278 で判明。
- **#3 reload**: 機能実証 — 不在 savestate で 3/3 が『RELOAD FAILED…SKIPPED as INVALID』+ entry_done 0 件（残渣 trial 不記録）。
- **#4 checkpoint**: 構造実証（flush/fclose/rename 全検査、失敗時 .tmp 除去+final_done 非設定）。機能 trigger は破壊的につき code 直読で確認。
- **#6 二重帰属**: 稼働 — **E104 行が実演: vmw=1(ra)/vmw_win=0(窓外)= 予告どおりの ra-only 方向**。
- ③ = early_01 witness で前提充足済。④ 本走は per-target DGDUMP 生存 evidence 同乗。
- **full 1278 rbw 発進**（fixed binary、`-frames 1200000` = 旧 1020 切れの真因〔250000 不足〕解消、DGIDLE=40 で旧条件一致、
  versioned → `rbw_tally.jsonl-3`）。boss1 が実 process 確認済。

### full 1278 rbw + H6 = 確定（14:25-14:50、3 実装収束）

- **完走**: 1278/1278（boss1 が entry_done を grep 計数、tally-3 生成 + 既存 2 file 不変 = versioning 本番動作）。旧 1020 prefix-scoped claim は全 supersede。
- **H6 二重帰属**（worker3 `be17fcb` / worker1 独立検算 `6b367d5` = **全 10 項目 bit-exact・assert 全 PASS**）:
  vmw 不一致 50590（win-only 50537 + **ra-only 53** = E104 型）/ **実効 audit list = rbw≠rbw_win の VM-read 92 件**（13+79）/
  **depth-2 write 実在 = YES**（win-only-written ∧ VM-read **19 件**、headline `0x8013E2E6` の fwpc=`0x800AECC4` = worker2 が traced した
  0x66 chain の helper 内 = **構造予測と実測の収束**）/ blind 母集団 **231 addr・18 block**。分母 159,941・drop 0。
- ★**cross-consistency（close パッケージの柱）**: depth-2 の 19 addr に **`0x8016B0B9`（fwpc=`0x800E9C74`）** — w60 で 0B9 を demote した
  連続書込 writer と**同一**。⇒ **derived/maintained class が別 batch・別 channel（DGSTORE vs rbw）・別 tool の 2 系統から独立に裏付けられた**★
- **worker2 の rbw 再測 prereg = 6/6 HIT**（P-b0 positive control PASS / P-b1 depth-2 実在 / P-b2 chain 的中 / P-a1 は sign HIT・規模帰属は自制 /
  P-a2 rbw label 変動 0 / P-c1 N=9 不変）。

### ④ = 偽 GREEN を寸前で自己捕捉（15:05、which-dimension の最終盤）

- IN_IMAGE 26: **25/26 一致**（定数）。唯一の不一致 = `0x8013DF70`（既知の非 image state、因果 4 値 inert 済）= 新情報なし。
- ★**OOI 205 の反転**: byte census では **205/205 がゼロ** → worker3 は『constant-zero、注入集合は空』と書きかけた。
  **word 突合で 205/205 が非ゼロ**（`0x00006800, 0x00007000...` の昇順 table）。真因 = **blind list は read の start addr であり、
  read 幅を測っていない = byte 値はその射影**。そのまま出せば **盲点母集団 205 件を silent に落とす偽 GREEN** だった★
- ★**PRESIDENT 指定の記録: これは codex #1（rbw 幅盲）の【read 側再来】**。write-set の幅盲は fix したが、
  **blind list census 自身が read 幅を持たない同族の穴**を持っていた — **『幅は次元である』は write 側 fix では read 側 tool に自動伝播しない**★
- ★**finding の実質**: `0x8015F788-0x8015FB08` は **loader-zero BSS ではなく boot 構築の昇順 table = 実 boot-written state
  ⇒ C# の zero 初期化は誤り**（実装 phase の具体的 gap。taxonomy 上 true live-in か derived かは DGLOADT + 静的 RE で確定）★
  worker2 の『不在 ≠ 0x00』警告が現物で成立した 2 例目。
- **裁定**: **DGLOADT**（read 幅と reader PC を実測する load 版 instrument）承認・実装 GO — **注入の前に「何 byte がどこから読まれるか」を測る**。
  代表注入はその後（選定規則は `d75f242` に事前固定: block 先頭/中央/末尾 + live word 値の多様性 + **flip したら密 sampling に格上げ** + no silent caps）。
  worker2 に同 table の静的 RE を並行発注（**静的 RE と実測 reader の収束が判定**）。
- B441 rider = benign（store 1 件・val=orig・決定論的再現。本 run は DGLOADS 無しで dia flag 無意味 = honest note）。POST finding は台帳維持。
- **close は 1 段延長**（④ の中で新測定が必要になった）。N=9 下限不変。

## ★★13. criteria 自体が射影だった — close の前提が壊れた（15:45-16:00、本 phase 最大の finding）★★

### 実測（worker2 `f64ac1e`、rbw_tally.jsonl-3 = full 1278）

- **盲点 205 件の正体 = DG.SCN という file の中身**: VM buffer 初期化 routine `0x800F0010` が 5 pointer を gp に置き file を load。
  `gp-0x6cf4 = 0x8015F784 ← DG.SCN 先頭`。205 addr = **DG.SCN の entry offset table（index 1..225、224 要素、昇順）**。
  live 観測値と DG.SCN 実 file が **byte-exact 一致**。**C# は既に同じ file から同じ table を parse 済**。
- ★**同じ routine が load する MAPHEAD buffer（`0x80159784`、23,094B）は C# に無い**★:
  実測 = 読まれた **369 addr / vmr 257 / dia>0（＝ dialogue 窓の【内側】）277 / wcount 0**。
  **reader = `GetSectionOffset(0x800F0A4C)` の scan loop**（実測 dpcs 上位 3 件が全て同一関数内: `0x800F0A64`=256 addr /
  `0x800F0A8C`=255 / `0x800F0A78`=1）。逆アセンブルで機構確定 = **(id:u16, offset:u16) stride-4 の線形探索 + 0xFFFF 番兵**
  （worker2 の既報 RE と byte 単位で一致）。**MAPHEAD の 277 addr は「section table を舐める探索」として窓内で消費されている**。
- **C# grep evidence**: Scripts の maphead 参照 **0 件**（唯一のヒットは data json のコメント文字列）。原盤 file は手元にある（23,094B）
  = **入れられるのに入っていない**。**依存鎖の全段（file / buffer / reader / 探索対象 table）が C# に欠落**。

### ★criteria の射影（完全性偽 GREEN #10 = PC whitelist 循環 filter の再来）★

worker3 の blind criteria = `vmr && wcount==0 && **dia==0** && uncaptured` — この **`dia==0` が射影**だった。
- **MAPHEAD の読みは dia>0 ゆえ構造的に除外されていた** ⇒ ★**「blind spot 母集団 231」は【窓外 read の母集団】であって
  【未捕捉 input の母集団】ではなかった**★。**census は blind-to-window を測っていたが、我々が要るのは blind-to-capture**。
- **『blind』が【何に対して盲目か】を宣言していなかった = 発見のための道具の criteria 自体が射影**。
- MAPHEAD 369 addr（dia>0 かつ未捕捉）は **構造的にどの census にも載れなかった**（blind list は dia で除外 / ram_inputs 3 block にも非該当）。

### ★帰結の正確な言い方（close パッケージ用に固定、PRESIDENT 指定）★

**『state 0/469』『N=9』は MAPHEAD 鎖を一度も測定対象にしていない（誤測定ではなく認識対象外）。**
⇒ **両数字は不変のまま、適用範囲の宣言が 1 行増える**:
> 「**捕捉済み入力表面についての数字であり、MAPHEAD 鎖（369 addr、C# は file/buffer/reader とも欠く）はその外**」

### ★『file 由来だから安全』は proxy だった★

同じ criterion が **DG.SCN（C# に出所あり = 除外根拠が立つ）と MAPHEAD（出所なし = 除外不能かつ未 capture）で正反対の結論**。
⇒ **除外根拠は『file 由来』ではなく『C# に対応する出所 + consumer があるか』**。DG.SCN 205 の除外判定にも同基準を適用
（**reader↔consumer 対応表を見るまで承認しない** — boss1/PRESIDENT の保留一致。値の一致は挙動の一致でない: E104 = 配達されて inert、0B9 = 注入即上書き）。

### 処置と close 判定への影響

- worker3 に ★**dia 条件抜きの再走査**（`vmr && wcount==0 && uncaptured` のみ、**dia は filter から分類 label へ降格**）★を発注。
  **新母集団が「入力表面が閉じていない」の新しい下限**。no silent caps（dia>0 で落としていた件数を明記）。
- ★**⑤ close はこの再走査を待つ** — 旧 criteria の上で closure を宣言すれば、**criteria の射影に閉じる宣言**をすることになる★。
- **N=9 下限不変（下限性はむしろ強化された）**。

### 再走査の結果（worker3 `40be99d`、16:05）— 母集団 231 → ★4188★

- **新母集団 = 4188**（`vmr && wcount==0 && uncaptured`）= dia==0 の **231**（旧 class、再現 assert PASS）
  + ★**dia>0 の 3957 件（旧 criteria が落としていた分。全件 rbw=1 = read-first）**★。182 連続 block。
  支配 = `0x80161786..0x80161E4A`（1736B / 1566 件）、**MAPHEAD `0x80159786..0x80159B84`（257 件）**、`0x80161E66..0x8016208A`（408 件）他。
- **worker2 突合 = 完全一致**（MAPHEAD 域: 369 read / 257 vmr / 277 dia>0 / 369 wcount==0）。
- ★★**第 2 の criteria 射影（worker3 の自己提示）**: `wcount==0` は **「CPU store 非観測」であって「未書込」ではない** —
  **CD-DMA write は MemoryBreakpointCheck を素通り**するため、.SCN/MAPHEAD の file-load 内容は wcount==0 のまま任意時点で書き換わり得る★★
- ⇒ **4188 の 3 分割 triage が必要**:
  **(a) savestate 常駐 boot state**（capture/inject class）/ **(b) DMA-load file 内容**（C# が同じ file を読む = **model class、注入対象でない**）/
  **(c) 真の未捕捉 live-in**。`0x8015Fxxx` table（dia==0 側）も (b) の可能性。
  **走行中の DGLOADT reader-PC が triage に直結。(b) の判別は worker2 の MAPHEAD/DG.SCN domain 知識が discriminator。**
- **位置づけ: 『入力表面は閉じていない』の新しい上限母集団 = 4188**（この savestate/sweep scope）。
  **N=9 causal lower bound は不変**（因果確認された新入力はゼロ）。

### close 判定パッケージの条項（PRESIDENT 指定）

残り 3 件（②+②b 完走 / 0x18 RE / worker2 帰属認否）が揃い次第、boss1 総括 1 通で:
**確定 claim 一覧 + BLOCKED/保留一覧 + 棚（metric-外 gap 4 件 + 窓の外 live code）+ 規範遵守 evidence。**
