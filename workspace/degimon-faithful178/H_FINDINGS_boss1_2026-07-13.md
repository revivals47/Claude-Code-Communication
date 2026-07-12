# H 測定結果 — closure 判定 = ★閉じていない★（boss1、2026-07-13）

事前登録 = `H_PREREG_boss1_2026-07-13.md`（commit `aba590e`、集計前に固着）。**閾値は 1 バイトも動かしていない。**

## 0. 結論（先に）

**入力表面は閉じていない。closure 3 条件のうち (b) が明確に欠けている。**
そして **数を当てる問題ではなかった** — 31 でも 1948 でも 16 でもなく、**基準を dataflow で定義する問題**だった。

## 1. 測定（artifact 直読、pt_baseline_tally.jsonl = 156,794 address）

### P7 = ★成立★（cap 非依存性は達成）
| 指標 | 実測 |
|---|---|
| `vmr==1`（cap 非依存 VM-read） | 4548 |
| dpcs に VM-PC を含む（64-cap の影響下） | 4237 |
| dpcs 飽和（len≥64） | 20 |
| `vmr ⊇ dpcs_vm` | **True**（cap で落ちていた **311 件**を救済） |

※ boss1 は当初この比較で `dia>0`（VM 実行中の全 read）を「dpcs ベース」と取り違え、「P7 不成立」と誤集計した。自分で次元を取り違えた。是正済み。

### P6 = ★不成立★（closure 残余 = 4197、期待 0）
捕捉機構は **artifact 直読**で 4 ブロック（`ram_inputs` 3 + `bank_block` 0x80163784+601B）。全部除いた残余の内訳:

| 件数 | 正体 | 入力か |
|---|---|---|
| 4002 | DG.SCN script バッファ | program 本体（C# も同じ .SCN を読む）⇒ 入力でない（**判断**） |
| 128 | スタック 0x801Fxxxx | launch 内 scratch ⇒ 入力でない（**判断。実測ではない**） |
| **67** | **真の未マップ候補** | ← 本体 |

### ★67 のうち 13 件は window 内で VM に read されている（dia>0）= 明白な未マップ入力★
- `0x80141D54`(dia 7560) / `0x80141D3A`(7454) / **`0x80141D18`(6914)** / `0x80141D60`(400) — partner/care 構造体
  → **`0x80141D18` は worker2 が CORRECTION 節で「これは state だ」と名指しした当の address。それが 16 の target list に無かった**
- `0x8013E0F0`(dia 3972、VM reader 0x80104624)
- `0x80164098`..`0x801640B4`（8 件、VM reader 0x800F15C0/0x800F1880）— window/textbox table
- 残り 54 件 = dia=0 かつ vmw=1（actor table 0x80163F60-）= VM が書くが window 内で読まない ⇒ 出力の見込み

## 2. ★★finding 本体: 「訂正」が入力を落としていた★★

sub2 の偽 GREEN を潰した capture 再構成（46-capture → 3 ブロック）が、**旧 capture から 120 byte を落としていた**:

- ★正しく落とした 72 byte★ = EXE image 内 [0x80090800, 0x8013E000) の定数群（10 領域）
  → **worker3 の予測 P3「46 に定数が混じっている」は的中**
- ★誤って落とした 48 byte★ = image 外 RAM で VM が window 内で read している state
  - `0x8013E0F0..0x8013E0FF`（16B、dia=3972）— 旧 capture は (0x8013E0F0, 0x30) で保持。**新ブロックは 0x8013E100 開始 = 境界を 16 byte ずらして落とした**
  - `0x80164098..0x801640B7`（32B）— 旧 capture は (0x80164098, 0x20) で保持。新 3 ブロックのどれにも入らない

⇒ [[feedback_correction_is_not_automatically_improvement]] が **我々自身の訂正で起きた**。勝った瞬間が最も検証が緩む。

## 3. closure 3 条件の判定

| 条件 | 判定 |
|---|---|
| (a) 16 の各 address が注入で真入力と直接証明 | **未確定**（matched control 待ち） |
| (b) 16 が下限でない（EXACT） | **★不成立★** — 同基準の address が 16 の外に**最低 13 件** |
| (c) capture に 16 が全て含まれる | 16/16 は capture 内（形式的に成立）だが、真の入力集合が 16 より大きい以上 **moot** |

**⇒ 「閉じた」とは言わない。16 に完璧な verdict を出しても表面は閉じない。**

## 4. ★承認済の新基準: read-before-write（upward-exposed use）★

「VM が read する ∧ image 外 RAM」は **proxy** であり、program バイト（SCN 4002）と stack scratch（128）を過剰に拾う。**線を引いた本人が線を検証していなかった。**

**正しい定義 = launch 内で【書かれる前に読まれる】address。**

| ケース | 旧 proxy | read-before-write |
|---|---|---|
| stack local | image 外 RAM ⇒ 誤って入力 | write-first ⇒ **自動脱落** |
| sub2（boot 書込・window 内 read-only） | read∩store が落とす（偽 GREEN） | read-first ⇒ **入力として残る** |
| actor table | — | read されず ⇒ 出力 |
| `0x80141D18` | list から漏れた | read-first ⇒ **入力** |
| SCN buffer | 誤って入力 | 形式的に入力だが**由来**で除外 |

**手で範囲除外する必要が消える = 線そのものを消して解いた。**

### ★新定義にまだ残る proxy 2 件（PRESIDENT 釘刺し、設計に必ず入れる）★
- **リスク A（window 罠）**: 「window 内で read されない = 出力」は**その window での話**。別 launch/別 section で read-first になる address を単一 sweep で見落とす（G の store 側未測定と同型）。
  ⇒ **read-before-write は全 1278 launch の【和集合】で取る。1 launch で write-first でも、別 launch で read-first なら入力。**
- **リスク B（SCN 境界も proxy）**: `0x80159784-0x80163784` は **boss1 が手で置いた線**。今回 16 byte ずれで入力を落としたのと同じ罠。
  ⇒ **.SCN load が実際に書いた address を write hook で実測して由来を確定する。範囲を手で書かない。**

## 5. 計装 audit（道具を対象に使う前に control で検証した）

- **tmask を判定列に入れかけた** → perturb run **12/12・全 launch で 0x0000**、baseline は 1278/1278 が非ゼロ。
  source 直読で決着: tmask setter（`dg_vmtrace.cpp:364`、`OnLoadObserved` 内）は **848 行の `DGLOADS` env で gate**。`pt_run_perturbs.sh` は DGLOADS 未設定 ⇒ observer が動かず **構造的に 0**。
  **採用していれば全 16 件 INPUT = 逆向きの偽 GREEN（過敏な次元による全件陽性）**だった。
- **rng_draw の値 field を `val` と推測で書いていた**（実際は `rand`/`seed_after`）→ source 直読で是正。
- **`(scn,key)` を dict キーにして重複 launch を上書きしていた**（baseline 1278 → distinct 1275）→ launch 連番キーに是正。worker3 側も同修正。
- **`pgrep -f duckstation-regtest` が自分の cmdline に自己マッチ**して永久待機 + 「走行中」の偽陽性。さらに `pgrep -x duckstation-regtest` は**プロセス名 15 文字制限でエラー**を返し、それを「不在」と読みかけた。
  **tool のエラーを不在の証拠にするな。** 正: `pgrep -x duckstation-reg`。

## 6. 対照の汚染（matched control が必要な理由）

- baseline = **DGLOADS ON**、perturb run = **DGLOADS OFF** ⇒ **同一条件でない対照に差分を取っていた**。
- worker3 の preliminary（perturb[OFF] vs baseline[ON]）= 16/16 が INPUT・全て PC 変化。
  **だが worker2 が構造的に PC 不変と予測した 4 件（0x80145E5A の merge-point gate 等）まで PC 変化** ⇒ 注入の効果ではなく **DGLOADS ON/OFF 差が PC 列をずらしている**の実測裏付け。
  **worker3 はこれを finding にせず差し止めた（正しい）。**
- ⇒ matched control（env を perturb と完全一致、DGPERTURB のみ外す、union sweep 397 launch）で
  (a) perturb を control 基準で再判定 (b) **control vs baseline で観測者効果を定量（期待 0 差分）**。
  **非ゼロなら DGLOADS の read hook が guest 挙動を変えている = frozen read 側 authority `09fde5a` の validity 再検討。**

## 7. ★注入テストの verdict と、決定的テストで判明した測定設計の欠陥★

### 7.1 verdict（perturb vs matched control）
- **N = 15 / 16 INPUT、NOT-SHOWN-INPUT = 1（`0x8013E104`）、INVALID = 0**
- boss1 独立 comparator と worker3 の comparator が **独立に同じ N=15/1** に到達（二重集計一致）。
- 事前登録（`aba590e`）: boss1 N=14（**1 件外し**）/ worker2 N=15（**的中**）/ worker2 の CONST≤1 候補 `0x8013E104` = **完全一致**。

### 7.2 ★事前登録の地雷が鳴った: state-only = 0★
事前登録に「**state-only が 0 件で出たら、それ自体を疑う**」と測る前に書いていた。0 件で出た。
さらに `0x80145E5A` は worker2 が EXE 直読で **merge-point gate = PC は構造的に不変**と証明した address なのに **60/60 で PC 変化**。
**構造の証明と測定が矛盾 ⇒ 疑うのは測定。**

### 7.3 boss1 の汚染仮説 = ★棄却★（H4）
「control の sweep 構成が perturb と違う（union 397 vs per-target 60）から汚染」と考え、**per-target control**（sweep ファイル・frames・env すべて一致、DGPERTURB のみ外す）を 1 本走らせた。
**結果: PC 差分 59/60**（union control では 60/60）。**⇒ sweep 構成差は主因ではない。私の仮説は外れ。**

### 7.4 ★★真因（実測 2 本）★★

**(1) 注入値が worker2 の gate を一度も跨いでいない**
- gate = `beq v0, 1`（値が **1** なら書込 skip）
- **実注入 = orig 0 → new 255**（DGPERTURB は `new = orig XOR 0xFF` 固定）
- **0 も 255 も「1」ではない ⇒ gate は一度も反転していない**
- ⇒ **worker2 の state-only 予測は「外れた」のではなく「一度もテストされていない」。**
  **予測を、その予測を exercise しない test で採点していた。**

**(2) `0x80145E5A` の reader は 1 個ではなく 6 個**（tally `dpcs` 直読、64-cap 未飽和 = 全列挙）
`0x800CB0C8` / `0x800CBD10` / `0x800CBD20`（field/engine）/ **`0x800EC7A4`（worker2 が解析した 0x1B handler）** / `0x800F3064` / `0x800F308C`（window/textbox 系）
- ⇒ worker2 の構造証明は **6 reader のうち 1 個についての証明として正しい**。PC が動いたのは別 consumer 経由。
- ⇒ **「PC 変化 か state-only か」は【address ごと】ではなく【reader ごと】の属性だった。**
  単一 reader の構造から address 全体の次元を予測したのが誤り。**構造解析も測定も、どちらも健全。**

### 7.5 verdict の射程（どの次元で見たかを明記）
- **INPUT / NOT-SHOWN-INPUT の判定 = 頑健**（byte-flip で挙動が変わる = 入力）
- **「PC か state-only か」の次元 = 摂動値依存 ⇒ 現設計では判定不能・保留**
- **NOT-SHOWN-INPUT（`0x8013E104`）も「非入力の証明」ではない** — 別の値なら効くかもしれない

### 7.6 次の instrument 変更（verdict 確定後に一括投入、staleness guard の order 制約に従う）
1. **read-before-write**（first_touch + first-writer-PC、全 launch 和集合、SCN 由来は fwpc 実測で差引）
2. **値指定注入（DGPERTURB_VALUE）** — 現行は XOR 0xFF 固定で **threshold gate を跨げない**
3. **1 address につき複数値の注入**（最低 2 値 = XOR 0xFF + gate 一致値）

## 8. 規範

閾値 `aba590e` 不動 / 実装ゼロ（計装は可）/ push ゼロ / frozen `09fde5a` 不触 / cutscene 不触。
