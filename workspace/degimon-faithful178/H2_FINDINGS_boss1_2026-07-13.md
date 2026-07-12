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
