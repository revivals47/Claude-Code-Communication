# MASTER_TASKS — F1: correctness oracle 再設計（2026-07-12 / 第2便）

> ★**2026-07-12 追記(PRESIDENT 裁定): 本 doc の全 FAIL 数に但し書き**★ — 原盤 sweep は launch を連続実行して flag/var が**累積**、C# は launch ごと全 0 新規 ⇒ **初期状態 identity が未確立**。worker2 実測: 分岐が割れた 0x19 の **93%(203/218 section)が flag/var のみ参照**。⇒ **`FAIL = (実装バグ) ∪ (identity 違反)` の和集合であり、bug 数ではない**。「135 FAIL」「240 FAIL」を「そのままバグ数」と読むな。**PASS(135→229)は有効だが「state 非依存 section に偏った標本」**。identity は worker3 の初期状態 snapshot sweep(加算 artifact、09fde5a 不変)を C# 注入して 203 件再測で確定/反証する。詳細 [[feedback_identity_is_not_evidence.md]]。**PRESIDENT 自己申告: identity を要求しながら満たされているか検証しなかった = 宣言しただけで配線せず([[feedback_control_toggle_must_be_wired]])**。

> ★**2026-07-12 CLOSED**★ — 完了報告 = `HANDOFF_2026-07-12_F1_oracle.md`。
> clean diff = 135/469（PC 列）/ 新規 length バグ 3 件（0x75/0x55/0x1A、実行が炙り出した）/
> main = `03f9dcd`（c6fec7f を gate 基準変更明記で local merge、**push ゼロ**）/ follow-up G1-G7 登録。
> 偽 GREEN の衣装 6 着 + 教訓 7 件は handoff §6-7 と memory へ。



dispatch: `DISPATCH_2026-07-12_F1_oracle.md`
base: **`c6fec7f`**（canonical = `0x4F`=6 / `0x6E`=8。boss1 が `load_lengths` で実測確認済）
※ **main は `7a3d6e9` のまま。merge していない**（理由は下記「merge 順序」）

## なぜ今これをやるか

忠実化（MAPHEAD + return-record stack + `0xFB` + `0x17`）は **user 実視覚 PASS 済の cutscene を壊し得る**。
だが **現行 harness は regression を検出できない**。だから oracle を先に作る。**配線はその後**。

## 現行 oracle の壊れ方（boss1 がコード直読、4 件すべて実在を確認）

`DialogueRuntime.VerifyEntry`（`DialogueRuntime.cs:1097-1131`）:

1. **prefix 判定** — `bool ok = emit.Length > 0 && common == emit.Length;`
   1 文字出して止まっても GREEN。desync で早期停止しても、そこまで合っていれば GREEN。**偽 GREEN 8 件の正体**
2. **oracle が byte 順の静的 scan** — `DialogueData.ExtractTextRuns` は SJIS lead/trail の線形 scan。
   **jump / 条件分岐 / section table を一切考慮しない** = 実行順と無関係
3. **到達不能 text も oracle に含む** — 分岐で通らない台詞まで拾う。だから完全一致にできず **prefix で逃げた**
4. **★boss1 追加発見★** — verify loop に `else if (rt.State == DialogueState.WaitingChoice) break;`。
   **menu で emit が止まる** → prefix 判定と組むと「menu 手前まで合っていれば GREEN」= **偽 GREEN 増幅器**

**★皮肉（PRESIDENT 直命で doc 化）★**: `ExtractTextRuns` の comment は「opcode 非依存ゆえ anti-circular 維持」と称している。
つまり **anti-circular を狙った設計が、実行順を捨てたことで別種の不健全さを生んだ**。
= 「抽象度を下げて circular を避けたつもりが、意味を失う」。**新 oracle 設計で我々自身が踏み得る罠**。
⇒ 新 oracle が同じ罠に落ちていないかを **codex に反証依頼**すること。

## ★merge 順序（PRESIDENT 裁定 2）★

`0x4F`/`0x6E` の Len fix は **EXE handler 直読（25/25 の byte 証拠）が根拠**であり技術的には正しい。
しかし **その build-verify に使った Gamma1aSweep 自体が不健全と判明した**以上、
「不健全な gate で緑を確認した変更」を main に入れるのは順序として不味い。

**正しい順序 = 新 oracle を立てる → 新 oracle で Len fix を再検証 → 通ったら main merge を上申**
⇒ **TrackB の受入試験が、まさにその再検証そのもの**。通過確認まで merge しない。

## ★方針転換（user 発案 / PRESIDENT 裁定 04:46, 04:52）★

**最終形 = 原盤 VM と C# VM に同じ入力を与え、event trace を diff する differential testing。225 entry 全部。diff がゼロになるまで直す。**
今の**「読んで理解して実装して祈る」ループ**を**「走らせて差分を潰す」ループ**に置き換える。
PRESIDENT 曰く「**今日 仮説を 4 回外したが、その全てが『EXE を読んで理解した』ことから来ている。動かしていれば 1 回も外していない**」。

### ★優先順位が逆転した（PRESIDENT 自己訂正）★

当初は TrackA（自作 MIPS interp）= 主力 / TrackC（DuckStation）= 検証役。**これは誤りだった**。
**改造 DuckStation が任意 entry を直接起動できるなら、225 entry の trace はそれだけで採れる ⇒ TrackA は存在理由を失う**。
DuckStation は **本物のハードが動く = stub がゼロ = 歪みが原理的にない**、しかも**書くコードも少ない**。
**TrackC が TrackA を不要にできるかを先に確かめずに MIPS interpreter を書き始めるのは assumption-based**。

⇒ **TrackC = 主力 / TrackA = fallback（本実装は保留、recon と支援のみ）**
⇒ 教訓: **authority を自作するより、既にある authority を借りるほうが強い**。**H4 は他人の仮説だけでなく自分の設計にも適用する**。

### ★decisive question（これに答えが出るまで他は従属）★

**「改造 DuckStation から、任意の entry（scenario, section）を、ゲームプレイ無しで起動して event trace を採れるか」**
- **yes** → TrackA 中止、worker1 を TrackC 支援へ完全再配置
- **no** → 何ができて何ができないかを列挙 → そこで初めて TrackA を GO

## Phase 1 — 3 track（進行中）

| track | worker | worktree / branch | 成功基準 | 状態 |
|---|---|---|---|---|
| **C: DuckStation 改造 → event trace（★主力★）** | worker3 | `-f1c` / `trackF1C/duckstation-golden` | **decisive question に実機で答える**。build 不可・hook 不可も正当な成果 | build compile 中 |
| B: event-trace 化 + prefix 判定廃止 | worker2 | `-f1b` / `trackF1B/event-oracle` | 偽 GREEN 8 件が旧長で **8/8 赤** かつ 正コードで **false-red 0 件**（= Len fix の正式再検証。**authority 不在でも単独成立**） | 進行中 |
| A: MIPS interp（**fallback / 本実装保留**） | worker1 | `-f1a` / `trackF1A/mips-exe-reference` | TrackC が no の場合に GO。設計 doc + stub 台帳は完成（`e0747f9` local、**実装ゼロ**） | 支援へ再配置 |

### ★canonical trace schema（boss1 確定 — 3 track が diff 可能であることが最優先）★

JSONL、1 event 1 行。**骨格 = `(seq, scn, sec, pc, op)`** + `raw` + `fx[]`。
`fx`: `text` / `flag_r` / `flag_w` / `var_r` / `var_w` / `push` / `pop` / `warp` / `scn_set` / `jmp` / `yield` / `term`

**`text` だけを見ないのが要点** — text 一致だけ見ると**分岐の誤りを見逃す = 現行 oracle が踏んだ罠そのもの**。
**出せない field は空で埋めず、出力しない + doc に「出力不能」と明記**（捏造ゼロ）。

### ★diff は regression gate であると同時に「忠実化の作業リスト生成器」になる（worker2 の申告より）★

C# は **`push`/`pop` / `yield code` / `sec` を出せない** — **remake にその機構が無いから**（return-record stack も
非ローカル脱出も section 追跡も未実装）。⇒ **diff に「未実装の穴」がそのまま現れる**。
**diff ゼロを目指す作業 = MAPHEAD + return-stack + yield の忠実化そのもの**。
⇒ **schema から push/pop/yield を外さない（意図的に残す）**。外すとこの可視化が失われる。
**「未実装ゆえの差分」と「実装したのに間違っている差分」を区別できる形にすること** — 前者は作業リスト、**後者は bug**。

## ★worker3 の実機発見（TrackC の工数が激減）★

- **`duckstation-regtest` = headless frontend が既に存在**（core+common のみ、Qt 不要、`-frames N` / `-dumpdir`）
- **`AddBreakpointWithCallback(type, addr, callback)` が既に存在**（`cpu_core.h:244`、**Release build で機能**）
  ⇒ **hook 機構を自作する必要がない。`0x800F0744` / `0x800f0188` に callback を刺すだけ**
- build 障害は **全て sudo 無しで回避**（prebuilt deps pack / curl header のみ / Wayland・X11 OFF）
- **`ptrace_scope=1`** は user にしか変えられない → **savestate(zstd) route を先に試す**。user 依頼は PRESIDENT 経由

## ★worker1 の recon（TrackC の hook に直結。地雷 4 件を事前に潰した）★

**`LoadScenario 0x800f0988`: `if (id==0) return MAPHEAD ptr`** ⇒ **「scenario 0 = MAPHEAD」は我々の解釈ではなく EXE の実コード**。
昨日は data の突き合わせから導いたが、**今回は実装コードが明言 = 循環ではない独立確認**。
**`gp = 0x80144e0c`**（crt0 が `[0x80119e68]` から load。EXE data のみから導き、過去 live 観測 3 点を**予測した** = 恒等式でない）。

**地雷（worker3 に転送済）**:
1. ★**`eventBank`(flag/var) を `StartScript` は reset しない**★（reset は VM init の memset のみ）
   ⇒ **flag を立てずに entry178 を起動すると `0x19` が別 arm に落ち、6 step が「再現しない」= 【偽陰性】**。
   **モデルが正しくても誤結論する危険**。最大の地雷
2. `SectionLookup` は key 不在で **0 を返す** ⇒ PC=0 で暴走。hook 側で 0 判定必須
3. `warp 0x800e3da0` は **20 frame の state machine** ⇒ frame を進めないと完了しない
4. `LoadScenario` は 1-scenario キャッシュ（`[gp-0x6cd4]`）

## ★★authenticity と identity の区別（PRESIDENT 裁定 — 最重要。取り違えると循環 or 誤った不可能判定）★★

**boss1 が循環を踏みかけ、PRESIDENT が止めた。**
boss1 は worker3 に「entry178 を忠実に踏ませるには**事前に必要な flag を立てろ**」と指示した。
**これは循環の再侵入**である — 「178 に必要な flag はこれのはず」という**我々のモデルを初期状態に注入**しておいて、
「6 step が出たからモデルは正しい」と言えば**恒等式**になる。
**worker1 が最初に警告した「循環は初期状態から侵入する」そのものを boss1 が踏みかけた。**

**目的によって「初期状態が本物である必要があるか」が変わる**:

| 目的 | 初期状態 | 方法 |
|---|---|---|
| **(a) 我々のモデルの検証**（6 step は本当に起きるか） | **本物でなければならない**。我々が置いたら循環 | ★**自然到達路**★ = `entry178` は**ゲーム冒頭の覚醒 cutscene** ⇒ **fresh boot → New Game でゲーム自身が到達する**。**flag は本物のゲームが作る。我々は何も注入しない**（New Game を選ぶ入力だけ = frame 送り + ボタン注入で script 化可能） |
| **(b) differential testing**（原盤 VM vs C# VM） | **本物である必要はない。両者に「同一」でありさえすればよい** | **任意の flag 状態 `F` を注入してよい**。原盤と C# に**同じ `F`** を与えて trace を diff。★**authenticity は不要、identity だけが要る**★ |

⇒ **この区別が 225 entry sweep の成否を分ける。**
**「本物の flag 状態が作れないから 225 entry は不可能」と誤って諦めてはならない** — **(b) なら注入で全 entry 回せる**。
**「到達可能性の忠実さ」は別問題として切り離す**（oracle の仕事ではない）。

**(a) に注入を使うと循環 / (b) に自然到達を要求すると不可能になる。この 2 つを混ぜないこと。**

### ★★「同一 F」の F は flag/var だけでは足りない — 入力表面の再定義（worker1 実測）★★

**`0x19`（条件分岐）の stat term（mode `0x20`）は eventBank の【外】を読んでいる**:
`0x800f53c8` = **partner の stat table** / `0x800f5658` = **`[0x80141d18]` の bitmask**（しつけ/機嫌と同じ partner・care 構造体）/
`0x800f19d8` = **`0x801040bc` = inventory item count**

**225 entry 全走査**: `0x19` 保有 = **185 entry** / ★**stat term を含む entry = 72 件 = 32.0%**★ / stat term 総数 **310**

⇒ **`F` を flag/var だけにすると、72 entry（1/3）で原盤と C# が乖離する。**
⇒ **その乖離は VM の正しさとは【無関係な理由】で起きる ⇒ 我々はそれを「C# VM のバグ」と誤診断する。**
⇒ **oracle の信頼性を根本から崩す穴だった。実装前に見つかったのが決定的に大きい。**
（**「緑が何を assert しているか確認せよ」の同型** — **差分が何を意味するかを確認せよ**）

**★入力表面 = identity の定義（これを両者に同一に与えられること）★**

| # | 対象 | 位置 |
|---|---|---|
| ① | eventBank **flag** | `eventBank + 0xf5 + (f>>3)`, bit `1<<(f&7)` [eventBank = **`0x80163784`**] |
| ② | eventBank **var** | `eventBank + 0x159 + idx` (byte) |
| ③ | ★**partner / care 構造体**★（`0x80141xxx` 帯、`0x80141d18` の bitmask 含む） | **worker1 が recon 中 = critical path** |
| ④ | ★**inventory item count**★（`0x801040bc` が読む実体） | **worker1 が recon 中** |

**③④ は ①② と同格の優先度**（落とすと 72 entry が原理的に diff 不能）。
**③④ を後付けにすると API が壊れる。先に器を用意すること。**
**完全解明は不要** — `0x19` の getter 6 本が実際に読む範囲が分かれば十分。**不明は【未検証】のまま残す。**

⇒ **worker2**: 注入 API は **①②③④** を受け取れる設計に。**これが無いと 225 entry の diff が原理的に取れない。**
⇒ **worker3**: DuckStation 側も同じ **①②③④** を RAM に注入できる hook を。**(a) 自然到達路では注入ゼロ。注入は (b) のみ。**

### ★(a) 自然到達路の副次価値★

fresh boot → New Game で entry178 に自然到達させると、**長年未 pin の `204→238` trigger**
（過去 live-RE で「static edge 皆無、field/state 駆動」と三重に falsify 済）が
**「自然到達の観測」として一撃で pin できる**可能性。
⇒ **(a) は「モデル検証」だけでなく「RE の観測装置」としても機能する。**

### ★循環は「知っている」だけでは防げない（2 例目）★

**循環注入（必要な flag を立てろ）を具体的に提案したのは worker1 本人**（本人が自己訂正）。
本人曰く「**抽象的に警告しておきながら具体で自分が踏んだのは、警告しなかったより悪い**（権威を誤りに貸すため）」。
**boss1 も同罪** — その提案を検証せずに worker3 へ転送した。**2 人とも踏み、止めたのは PRESIDENT。**
⇒ **process（第三者の査読）でしか防げない。** [[feedback_identity_is_not_evidence]]

## ★honest な限界（PRESIDENT 裁定 8 — 誇張しない）★

**emulation が与えるのは「挙動」であって「意図」ではない。**
「原盤がこう動く」は分かっても「リメイクでどう表現すべきか」は決めてくれない。
**oracle が手に入るだけで、リメイクが自動で出来上がるわけではない。**

### ★Track A の分水嶺 — 循環の侵入口は「初期状態」（worker1 が自ら特定）★

「EXE を走らせれば再解釈ゼロ」は原理的に正しいが、**循環は interpreter 本体ではなく初期状態の作り方から侵入する**。
gp / script buffer / return-stack / CurrentScenario を**手で置くと、我々のモデルをそのまま埋め込む = 循環が復活**。

⇒ worker1 の方針: **初期状態も EXE の実コードに作らせる**。手で globals を置かず **原盤の `StartScript` を実際に call** し、
供給するのは **CD から読まれるはずの生 byte（DG.SCN / MAPHEAD.SCN）だけ**。= **入力は data のみ、解釈はゼロ**。

+ **stub 台帳**（PRESIDENT 裁定 4）: 各 stub 点で「原盤は何をしたか / stub は何をしたか / 差が VM の観測可能状態に影響しないか」。
**ここが曖昧だと、我々は「実行した」と言いながら実は「解釈した」ことになる**。

## Phase 2 — oracle 確定後（本 dispatch の後）

- [ ] 新 oracle で Len fix 再検証 → 通過なら **main merge を PRESIDENT に上申**
- [ ] TrackA が authority を名乗れるなら、reference event trace vs C# の完全一致比較を TrackB に追加
- [ ] **その後にはじめて忠実化（配線）dispatch**。★本 dispatch では cutscene に一切触らない★

## 必須要件（全 track 共通）

捏造ゼロ / **恒等式を証拠にするな** / **codex 反証査読（締めフェーズで打ち切るな — 前 dispatch で欠陥 1 件を見逃しかけた）** /
H4 許容（「不可」も正当な成果）/ worktree 隔離 / **push 禁止** / **配線・cutscene 不触**

## 監視項目

- TrackA が「不可」と判定した場合 → codex 案（EXE handler の逐語移植 Python reference）に落とす。
  ただし codex 曰く「Python と C# が一致しても EXE と一致したことにはならない」= **authority の格は落ちる**
- TrackC が「不可」でも正当。その場合 **authority を TrackA に委ねる判断**になるため、
  **TrackA の stub 保証が一層 load-bearing になる**（worker3 に反証者視点で条件を書かせている）
