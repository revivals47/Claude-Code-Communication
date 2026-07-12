# HANDOFF 2026-07-13 — H dispatch（入力表面を閉じる）締め

**結論を最初に: 入力表面は【閉じていない】。真入力は N ≥ 9 の【下限】であって確定値ではない。**

---

## 0. ★最初に読むべき 3 行（誤読防止）★

1. **`N = 9` は下限**。**`NOT-SHOWN-INPUT` 7 件は「非入力の証明」ではない** —
   注入値が `orig XOR 0xFF` 固定で、等値 gate（`==1`/`==2`/`==3`/`==0xA`）を**一つも跨いでいない**だけ。
   **「7 件は定数だった」と書いたら、それが偽 GREEN。**
2. **closure = 未達。** 未マップ入力が残り、「訂正」が入力 48 byte を落としている（§4）。
3. **今日の core は verdict ではなく【測定基盤の二重汚染を診断して是正したこと】**（§2）。

## 1. ground truth（実測）

| 項目 | 値 |
|---|---|
| main | `7a87fba`（origin/main `59488d0` より **32 commit 先行、push ゼロ**） |
| origin/main | `59488d0`（**不変**） |
| frozen authority | `09fde5a`（**1 バイトも触っていない**） |
| worktree | `-f1a`(worker1) / `-f1b`(worker2) / `-f1c`(worker3) |

worker 成果（すべて local commit、push ゼロ）:
- **worker1** `2cdb326` — state-gate 母集団 census / prologue `0x800F0AE8` 機序 / 4 subroutine RE / store hook 設計たたき台（**read-only、実装ゼロ**）
- **worker2** `012666f` — reader 単位分類（CF / WGATE / **DATA**）+ 自己検出した欠陥 2 件
- **worker3** `e9ab77e` — perturbation harness + **4 次元 first-diff comparator** + verdict 保全
- **boss1**（本 repo）`716fd71` まで — `H_PREREG_boss1_2026-07-13.md`（**閾値の事前登録**）/ `H_FINDINGS_boss1_2026-07-13.md`（測定結果）

## 2. ★★今日の core: 測定基盤の【二重汚染】を診断して是正した★★

verdict を出す前に、**対照（control）が 2 つの独立な理由で汚染されていた**ことを実測で突き止めた。

### 汚染 ①: 計装条件の不一致（DGLOADS）
baseline は **DGLOADS ON**、perturb run は **OFF** で採られていた ＝ **同一条件でない対照に差分を取っていた**。
発覚経路 = `entry_done` の `tmask` が perturb run 12/12・全 launch で `0x0000`（baseline は 1278/1278 が非ゼロ）。
真因 = `tmask` を立てる `OnLoadObserved`（`dg_vmtrace.cpp:364`）は **848 行の `DGLOADS` env で gate** されている。
⇒ **計装 artifact。判定列に入れていたら全 16 件 INPUT ＝ 逆向きの偽 GREEN だった。**

### 汚染 ②: ★host 側ボタン位相（これが本命）★
`Heartbeat` の `static u32 n` → `DriveInput(n)`、auto = `(frame % 12) < 6` で **CIRCLE（台詞送り）を周期的に押す**。
**この `n` は savestate reload でも launch 跨ぎでもリセットされない** ⇒ **ボタン位相が絶対フレームに固定**。

**★観測で確定（source 読みで済ませていない）★** — LAUNCH の stderr 行が `frame` を出す:
- `n` は launch 跨ぎで **単調増加（12 → 124 → 221 → 315 → 424 → 665 …）＝ リセットされない**
- 先行 launch 列を変えた**同一 60 launch** で **frame 一致 0/60、ボタン位相（`frame%12`）違い 60/60**

⇒ **カスケード汚染**: 注入が entry の実行長を変える → 以降の全 launch の位相がずれる → **注入と無関係に trace が変わる**。
⇒ **差分の【件数】は信用できない。**

### 是正: first-divergence 規則
**sweep 順で最初に食い違う launch はカスケード前**（それ以前は位相が完全に揃っている）。
- **INPUT の閾値は不変**（`aba590e`。1 launch でも変われば INPUT）— **カスケードは差の「有無」を偽造できない**
- **dimension だけ初差 launch から読む**。件数は参考値に降格。
⇒ **閾値の変更ではなく、汚染されていないサンプルを選ぶこと。**

### 副産物: 「決定性テスト PASS（bit-identical）」が測っていたもの
同一 sweep を 2 回 ＝ **ボタン位相も同一** ⇒ **位相非依存性を一度も試していない**。
**再現性は検証したが、入力充足性（同一捕捉入力なら同一挙動）は未検証だった。**

## 3. 観測者効果 = ZERO（実測、全 1278 launch）

対照 = **full 1278 sweep・DGLOADS OFF**（baseline の launch 列を **artifact から順序・重複ごと復元**して **sweep 構成を bit 一致**、env は `DGLOADS` だけ差）。

| 次元 | 差分 | 信号の実在（missing-vs-equal 封鎖） |
|---|---|---|
| PC | **0 / 1278** | 非空 1278 launch / 7,682 レコード |
| STATE | **0 / 1278** | 非空 **1259** launch / **3,935** レコード |
| RNG | **0 / 1278** | 非空 **392** launch / **610** レコード |
| DONE | **0 / 1278** | 非空 1278 launch |

**両 run で信号数が完全同数**。⇒ **0 差分は「両方空だから一致」の vacuous truth ではなく【真の一致】。**
⇒ **DGLOADS の read hook は guest 挙動を一切変えていない ＝ 実測。**
⇒ **frozen read 側 authority `09fde5a` の採取条件は、この次元では validity 問題なし。**

## 4. ★closure = 未達（注入テストとは独立に成立）★

- **条件 (b) 不成立**: 同じ基準（VM-read ∧ image 外 RAM ∧ 未捕捉）を満たす address が **16 の外に最低 13 件**
  （`0x80141D18`/`D3A`/`D54`/`D60`、`0x8013E0F0`(dia 3972)、`0x80164098` 系 8 件）。
  ★`0x80141D18` は worker2 が「これは state だ」と名指しした当の address。それが target list に無かった★
- **「訂正」が入力を落としていた**: 46-capture → 3 ブロックの再構成で **120 byte を落とし、うち 48 byte は image 外・VM が window 内で read する state**
  （`0x8013E0F0..FF` = 境界を 16 byte ずらした / `0x80164098..B7`）。**正しく落とした 72 byte は image 内定数**（worker3 の予測 P3 的中）。
- **P7（cap 非依存）は成立**: `vmr`(4548) ⊇ `dpcs_vm`(4237)、64-cap で落ちていた 311 件を救済。

### ★`read∩store` 基準は実測で反証された★
| | |
|---|---|
| INPUT 確定 9 件のうち **`wcount=0`（read∩store なら脱落）** | **3 件**（`0x8013E114` / `0x8016B084` / `0x8016B169`）＝ **33% を落とす** |
| `0x8013E104` = `wcount=1278`（毎 launch 書かれる）だが注入は **NOT-SHOWN** | **偽陽性として残す** |

⇒ **「window 内で書かれるか」は入力性と両方向に無相関。proxy であることが数字で出た。**

### 正しい基準（承認済、次 batch で実装）
**read-before-write（upward-exposed use）= launch 内で【書かれる前に読まれる】address。**
stack local は write-first で自動脱落、boot 書込の state は read-first で残る。**手で範囲の線を引く必要が消える。**
残る proxy 2 件（PRESIDENT 釘刺し）: **① 全 1278 launch の【和集合】で取る ② SCN buffer の境界も `fwpc` 実測で確定（手で書かない）**

## 5. PROVISIONAL VERDICT（下限 N ≥ 9）

対照 = **per-target control**（sweep ファイル・frames・env すべて perturb と一致、`DGPERTURB` だけ外す）。
boss1 と worker3 の **独立 2 実装が per-item まで完全一致**。

| addr | 初差 | 次元（初差＝非汚染） | 判定 | 構造の裏付け |
|---|---|---|---|---|
| `0x80145E5A` | #0 | PC | INPUT | ✔ `0x800F3064` の beqz が 0→255 で反転 |
| `0x8013E2E0` | #0 | **STATE のみ** | INPUT | ✔ DATA（`andi` 経由で SetVar） |
| `0x8016B084` | #0 | **RNG のみ** | INPUT | **provisional**（構造未提示） |
| `0x8013E114` | #1 | PC | INPUT | — |
| `0x8013E2DE` | #1 | **STATE のみ** | INPUT | ✔ `0x25` handler → `jal SetVar` 直渡し |
| `0x8016B139` | #5 | PC | INPUT | — |
| `0x8016B3A9` | #5 | PC | INPUT | — |
| `0x8016B169` | #14 | **STATE のみ** | INPUT | ✔ **FIELD-CF**（reader 4 = VM-PC 1 + field 3） |
| `0x8016B411` | #34 | PC | INPUT | — |
| `0x8013E104` `0x8016B07C` `07D` `0B8` `0B9` `3D9` `441` | — | 差分ゼロ | **NOT-SHOWN-INPUT**（7） | `0x8013E104` は CF/WGATE/DATA いずれも無し ✔ |

**予測の採点**: boss1 N=14 **外し** / worker2 N=15 **外し** / worker2 の CONST 候補 `0x8013E104` **的中**

### ★state-only class は実在する（2 独立方法の収束）★
`0x8013E2DE` = **測定**（初差が STATE のみ、PC 0/60）＋ **構造**（opcode `0x25` の handler が値を**分岐ゼロで** `SetVar` に渡す）。
⇒ **「PC 列だけを見る metric では原理的に検出できない入力」が実機に存在する。**
★ただし `state 0/469` は**別測定**。言えるのは「`0/469` と**整合する class の存在を実証**」であって「`0/469` の根拠が立った」ではない（which-dimension）。★

### state-only の発生経路は 3 つ（worker2、実測と整合）
1. **WGATE** — VM code が分岐して書込を skip、両枝合流（`0x1B`）
2. **DATA** — 値がそのまま store / SetVar に流れる（`0x25` → SetVar）**← 実測済**
3. **FIELD-CF** — **field code が分岐して state を書く（VM router の opcode PC 列は動かない）** **← 新規**
⇒ **我々が「PC」と呼んでいるのは【VM router の opcode PC 列】であって field code の制御流ではない。**

## 6. ★次 batch の pre-register（着手していない）★

**instrument 一括変更**（`dg_vmtrace.cpp`。**verdict 保全のため今日は触っていない** — source を触ると自分の staleness guard が全 artifact を分析拒否する）:
1. **button-phase reset** — 入力フレームを launch 相対にする。**修正後 control 同士は bit 一致するはず ⇒ これが入力表面の完全性 oracle になる**（同一捕捉 state で trace が違う ＝ 捕捉が不完全、の直接証明。**残差が出ればそれは本物の未捕捉 state**）
2. **read-before-write**（first_touch + first-writer-PC、**全 launch の和集合**、SCN 由来は `fwpc` 実測で差引）
3. **`DGPERTURB_VALUE`（値指定注入）** — 現行は `orig XOR 0xFF` 固定で **threshold gate を跨げない**
4. **1 address 複数値注入**（最低 2 値 = XOR + gate 一致値）
5. **NOT-SHOWN 7 件を gate 値で再注入** ← **ここで真の N が 9 の上へ動く**
6. **fixed-harness の clean data で first-divergence verdict を cross-check** ← **2 方法が一致した時が「確定」**

worker2 が用意した必要注入値: `0x80145E5A → 1 / 2 / 3`（ただし WGATE `==1` と CF `==1` が閾値を共有 ＝ **分離不能**）、
**`0x8013E2DE → 0xA`（`0x800AE8D8` の書込 gate 経路の検証）**、`0x8016B07C`/`0B8 → 2`、`0x8016B084 → 0xB` / `0x7F` / `0x27` / `0x98`、`0x8016B0B9 → 1`

## 7. ★今日の教訓（regression norm）★

- **偽 GREEN #11: assumed-base disasm** — 根拠のない base（`0x800D6000`）を仮定して逆アセンブルしたら**それらしい MIPS が出た**。
  **逆アセンブラは正しく動いていた。だから騙した。** どんな well-formed bytes も何かに decode される ⇒ **出力のもっともらしさは base の正しさの証拠にゼロ**。
  正 = `slps_017.97.orig`（t_addr `0x80090800`、size `0xAD800`）。**`extracted/SLPS_017.97` は別物の EXE**（t_addr `0x80080000`）。
  ⇒ **規範: disasm を根拠に使う時は image と base の実測 evidence を必ず添える。**
- **狭い view が自信ある誤答を出す — 今日 4 回**: 逆アセンブル窓 28 命令 / `pcs` 16-cap / cross-entry body / **dataflow の伝播命令セット**（`andi` を落としていた）
- **カテゴリ集合そのものが盲点になる**: worker2 は CF/WGATE の 2 クラスしか立てず、**DATA が座る席が最初から無かった**。
  同型で **worker3 の comparator は RNG 列を持たず**、`0x8016B084` の真の初差（launch #0、RNG 抽選 6→5）を**見えないまま**、カスケード汚染下の #1 を初差と誤認した。
  ⇒ **次元集合が足りない道具は、汚染前のサンプルを取り逃がす。**
- **決定的テストは走らせた case しか裁かない**: boss1 は `0x80145E5A` 1 件の結果から「汚染仮説は棄却」と**母集団に一般化**した。
  実際は **他 target では sweep 構成汚染が verdict を変えていた**（`0x8013E2DE` が state-only に、`0x8016B07C` が NOT-SHOWN に反転）。**真因は 1 つではなかった。**
- **予測は当てるためでなく、外れ方を事前に定義して罠を仕掛けるためにある**: 事前登録に書いた
  「**state-only が 0 件で出たら、それ自体を疑う**」が鳴り、汚染された verdict を自分で止めた。
- **訂正は自動的に改善ではない（今日 3 例）**: capture 再構成が入力 48B を巻き添えで落とした / worker2 の「精密化」が
  自分の正しい初期予測（`0x25` → SetVar 直渡し）を捨てた / walk 修正が正しい出力を落とした。

## 8. 規範（不変）

**閾値 `aba590e` 不動 / 実装ゼロ / push ゼロ（user 専権） / frozen `09fde5a` 不触 / cutscene 不触。**
