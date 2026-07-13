# H3 FINDINGS — 因果 sprint（進行中 doc、boss1）

prereg = `H3_PREREG_boss1_2026-07-13.md`（`4cd2c9f` 固着、caveat D-0 = `0bf6c40`）。

## 1. B 系（DG.SCN 225 等価構築確認）— 中間裁定（2026-07-14 00:5x）

### 三者突合 = 205/205 収束（boss1 が per-entry 集合比較を実施）

| 系 | 導出元 | 独立層 | 結果 |
|---|---|---|---|
| worker1 `194d5d0` | DG.SCN file bytes 直読（C#/worker2 非参照） | parse 実装 | 225 entry + EOF sentinel、assert PASS |
| worker2 `c776a69` | C# DialogueDatabase parse の python 逐語再現 | parse 実装 | HW live vs C# = **205/205 一致・系統差ゼロ** |
| HW live | ④ dump 実測（file から作っていない = 循環なし） | 実行時実体 | 基準値 205/225 |

- **boss1 突合（w1 file 直読 vs HW live）: MATCH=205 / MISMATCH=0 / NO-ROW=0**（件数 assert w1=225, hw=205 PASS）。
- ★**規約の確定（trap (iv) 発火 2 例目）**: `HW table[i] = entry i+1 の file byte offset`（= w1 の `next_offset[i]`）。
  index が 1 つずれた**書き方の差 = convention 差**であり値の差ではない。trap (ii) = EOF sentinel も発火
  （HW = table[225] を file 値 0xA9000 で保持 / C# = `_scn.Length` から導出 — **値一致・導出経路差**）。
  ★どちらも事前登録済み trap に落ちた = 「一致/不一致の誤読」を様式が防いだ実例★。

### 裁定

- **3 条件 standard の充足見込み**: ① file 由来 ✓ ② C# が同 table を導出 ✓（205/205）③ consumer 対応 ✓
  （offset table ↔ `_offsets[index]` / subtable 線形探索 + 0xFFFF sentinel ↔ 同 model verbatim）。
- ★**(b) 復帰の最終承認は保留**: HW 基準が 205/225 — **残 20 件（153,154,176..181 他）の live 値が揃うまで 225/225 と言わない**
  （worker2 自身が file で埋めない・小標本一般化しないと正しく留保）。**worker3 への短 run（DGDUMP `0x8015F788..0x8015FB08` 全 225 word）を承認・依頼済み**。
  20 件到着 → boss1 が同 diff を再走 → 225/225 なら (b) 復帰確定。

### RE 訂正 1 件（worker2、prereg §B-1 の記述を上書き）

★**`0x80161788` は entry offset table ではない** — **entry buffer 内 subtable の pair[0] offset field**
（`0x800F0A78` = lhu 2(s0) = pair の offset 側 / `0x800F0A64` = pair の sectionId 側）★。
H2_FINDINGS §15 の「`0x80161788` = w=2 (lhu)、225 回」の読みは幅と reader は正しいが**帰属 label がずれていた**。以後この訂正を正とする。

### 静的 RE（(c) self-modify 同定の材料、worker2）

- `0x800AF6AC` = 引数の指す byte が `0xFD` なら **その byte を 0 に潰す**機構を持つ（確定）。
- `0x800BB940` = `sb zero, 0x34(s0)`、+0x34 = readerA の述語 field と同 offset。
- **s0 の実体（script か record か）は静的には未確定 — 推測 label なし**。実測 = worker3 の DGSTORE rider、突合 = worker2。

### (b) 復帰 = ★確定★（2026-07-14 00:4x、boss1 最終 diff）

worker3 短 run `5823909`（`B_DUMP_225_LIVE.tsv`、3 点 evidence + 狭義昇順 sanity）到着後、boss1 が最終 diff を実施:

- **live vs file 直読（worker1）: MATCH = 225/225、MISMATCH = 0**。
- **capture 間整合（④ dump の 205 vs 本 run）: DIFF = 0**（独立 2 回の capture が bit 一致 = control 同士の一致テスト）。
- **新規 20 件（153,154,176-184,201-203,212,213,220,221,223,224）: 20/20 が file と一致**。
- ⇒ ★**DG.SCN offset table 225 = (b) 復帰確定**（3 条件 standard 全成立: file 由来 ∧ C# 同 table 導出 225/225 ∧ consumer 対応）。
  **C# は capture 不要 — 同 file から同 table に到達済み**。0% DMA（boot/CPU 構築）は「作られ方」の差であって「到達する値」の差ではない、が実測で閉じた★。
- 4,388 分類の更新: **(b) = 3,555 + 225 = 3,780**（H2 §17(0b) の保留が解けて、結果として当初の 3,780 に実測で戻った —
  ★ただし今回は「C# が file を持つ」proxy でなく「値+consumer の実測一致」で立っている = 同じ数字でも根拠の等級が違う★）。

## 1b. 手隙タスク（worker2 `221ddaf`）: 0x80163F60..FFC の 45 件 = scratch 確定

- **45/45 が rbw=0（write-first）∧ dia=0 ∧ dpcs 空** = boot 値を消費していない = **live-in ではない**（0x8013E0FC と同 class）。
  H9 の 10 件に影響なし（元より非包含）。
- writer 機構（EXE 直読）: byte 単位 append buffer（`sb s1,(v0)` + pointer++、script PC `gp-0x6cc8` を読み進める同型 3 site）。
  writer PC 68 種 + **BIOS ROM 域 `0xBFC03408` も writer に出現**。
- ★未同定のまま台帳（推測 label なし）: buffer の中身 / BIOS write の実体 / 45 件が末尾側に偏る理由★。

## 1c. ★instrument の dia-gating finding（worker3 自己捕捉）→ boss1 拡張で closed claim 1 件を訂正★（00:4x-00:5x）

### worker3 の finding（`dg_vmtrace.cpp:1060`）

`s_vm_executing=true` は `s_g6_active || s_watch_lo` が条件 = **dia 次元は DGLOADS/DGWATCH 併設時のみ配線**。
- (1) A-0 hot 短 run（両者非設定）の全 record dia=0 = **構造強制であって測定でない**（幅次元は有効、ただし再走まで参考値扱い = worker3 の保守判断を承認）。
- (2) 同型の疑いが close 済 claim に波及: loadt_run（09:32）は companion tally 不在（boss1 実査: 08:59 rbw_tally-3 と 09:56 final_tally の間に tally なし）= 非配線の可能性高。
- (3) final_run（09:56）は dia>0 多数 = 配線済み → 母集団/dia 分類は無傷。
- memory の control-toggle 配線教訓（[[feedback_control_toggle_must_be_wired]]）の同型を**自分の instrument で自己捕捉**。

### boss1 の裁定 + 拡張実測（rbw_tally-3 直読）

- tally-3 は dia 次元 live の実測証明あり（159,941 行中 **dia>0 = 62,836 行**。分母は doc 記載と bit 一致）。
- ★**当該 table 域 0x8015F788..0x8015FB08 を tally-3 で直読: 225 word 中 dia>0 = 20**★ —
  「全 read が dia=0（窓外）」は**誤り**。正 = **205 word は窓外 read のみ / 20 word は窓内でも読まれている**。
- ★★**決定的: dia>0 の 20 index = live 基準から欠けていた 20 件と【完全一致】**（153,154,176-184,201-203,212,213,220,221,223,224）★★
  ⇒ 機構が端から端まで閉じた: **④ blind list の dia==0 criteria が、窓内で読まれる 20 word を構造的に落とした → live 基準が 205 になった**。
  = criteria 射影（H2 §13-14 で捕捉済みの型）の**具体的 witness 3 例目**。（覚醒 entry 178 の offset を含む 176-184 が窓内 read = 台帳 note、意味論は掘らない）

### 訂正の scope（正確に）

- **訂正対象**: H2 §15 と worker3 PHASE_CLOSE_PACKAGE の「全 268 read が dia=0（窓外）」→
  「loadt_run の dia=0 は構造強制（その run では dia 非測定）。tally-3 実測 = 205 窓外のみ / 20 窓内あり」。
- **不変**: reader = VM interpreter PC の同定（dia と独立）/ read 幅 w=4・w=2（measure-first 配当の本体）/
  (b) 復帰確定（値 225/225 + consumer 対応は dia 非依存）/ 母集団 4,388・DMA 分類（final_run = 配線済み）/ N=9。

## 2. A 系（注入 batch）— 進行

- worker3 手順 0-1 完了: 実査一致（§17(0) と bit 一致）+ **blind 予測固定 `e4a6884` = INPUT 8 件**
  （D18/D3A/D42/D54/CDBC/E7C/FBC/640A4。boss1 7 件との差分 3 addr。件数のみ露出 caveat = prereg D-0）。
- A-0 幅表 = 12/12 実測（`338fec7`、承認済）。positive control = **INPUT 確定**（0x80145E5A=255、readback 60/60 + 生存実測 +
  60/60 発散、H2 profile 整合）= abort 規則クリア、batch 本走 GO（01:2x）。
- **中間（02:32、11/28 run）— 早期 verdict 2 件（正式表は batch 完了後）**:
  - `0x80141D18` = **INPUT**（実効 3 値全発散: 0xFF STATE+RNG 50/80 / 0x01 STATE+RNG 43/80 / 0x80 STATE 25/80、
    first-div 全て先頭 launch、readback 80/80。**PC 次元なし = state-only 型**。orig=0x00 ゆえ v00 は規則で 0xFF に bump、記録済）。
  - `0x80141D3A` = **INPUT**（0xFF のみ STATE 25/80。0x00/orig+1 は**生存実測付き NOT-SHOWN 値**（store 0 件・22,445 read）
    = 閾値 gate 型 profile — 記述のみ、掘らない）。
- ★無料 control 2 件（methodology へ）: (1) d18 v00/vFF = 同一実効注入の jsonl bit 一致（P1 replica）
  (2) ctl 同士で rider 構成のみ違う 2 run の guest 全次元 80/80 bit 一致 = **rider-invariance の実測**（DGSTORE/DGLOADT 同乗は guest を変えない）★。
- 運用 note: hot runner は stderr（LAUNCH frame anchor）非保存 → hot target の **NOT-SHOWN 最終判定に限り** per-launch 生存 bracket の
  補助 run を許可（INPUT 判定は決定論 argument で充足）。rare batch は stderr 保存 + **DGDMA 同乗**（script block の DMA 上書きは store_t 不可視のため）設計済。
- ETA 改定: 1 run ≈ 6 分実測 → hot 完了 ≈ 04:15（+75 分）、rare はその後。

### hot batch 完了（04:12、28/28 run・CAP HIT ゼロ・readback 全 run 100%）— hot 7 target の verdict

| addr | verdict | profile（発散 launch 数/80） |
|---|---|---|
| `0x80141D18` | **INPUT** | 0xFF: STATE+RNG 50 / 0x01: 43 / 0x80: STATE 25。**PC なし = state-only 型** |
| `0x80141D3A` | **INPUT** | 0xFF: STATE 25。0x00/0x07 = 生存 clean の NOT-SHOWN 値。**閾値 gate 型** |
| `0x80141D42` | **NOT-SHOWN（窓内 5 次元）** | 全 launch 差ゼロ。★併記: v00 のみ**窓外 read +162** = **POST 次元（H2 BLOCKED 宣言済）に効果の実測 witness** — 窓内 verdict と別次元、per-dim label で峻別★ |
| `0x80141D54` | **INPUT** | 0x00: STATE 5 / 0xFF: STATE+RNG 75 / ★**0x51(orig+1): PC-PATH+CTX+RAW+STATE+RNG+DONE 73 = 真の制御流分岐、H2 以来 2 例目**★ |
| `0x8013E0F0` | **INPUT** | 3 値とも全次元発散（14/76/80）。最強 profile |
| `0x8013CDBC` | **INPUT** | 0x84(→ptr 0x8016B184): CTX+STATE+RNG 75 / 0x00(→0x8016B100): 15。crash なし（null 未試験 = D-1(a)） |
| `0x8013DF8C` | **INPUT** | 実効 0xFF: 全次元 80/79 / 0x01: 全次元 80 |

- **hot 小計: INPUT 6 / NOT-SHOWN 1**。予測採点は正式表（rare 完了）後に prereg §D で実施
  （速報レベル: DF8C は両者外し / D42 も両予測 IN で外れ / D54・E0F0 は片方ずつ的中 — 数字は採点時に確定）。
- ★新 confound 1 件（掘らず台帳、次 phase 候補）★: df8c の同一実効値 pair（v00/vFF）が bit 非一致 —
  vFF run の一部 launch で EARLY 時 orig=1 + 先頭 record 順序差 = **reload 境界の write race 疑い**。
  判定影響なし（両 run とも readback 100% + 発散成立、d18 の同型 pair は bit 一致 = 対照あり）。
- 進行: anchor run（full 1278、stderr LAUNCH anchor + rare 4 の DGLOADT 同乗）→ mini sweep 構築 → rare batch（16 run、stderr + DGDMA 同乗）。

### anchor run stall インシデント（04:11-04:48、3 発進目で解消。process 規律の記録）

1. **stall（04:11-04:45、boss1 が president 照会で検出・診断）**: 起動 shell 冒頭の待機 loop `until ! pgrep -f duckstation-regtest` が
   **自分の command line（eval 文字列内の同 literal）に self-match** → 永久 sleep、emulator 未発進、worker3 は完了通知待ち = 相互待ち。
   pkill self-match gotcha の pgrep 変種。
2. **unstick 1 回目 = 不完全（2 敗目）**: `[d]uckstation-regtest` の文字 class 修正は、**同 argv 内の emulator 実 path literal
   （./build/bin/duckstation-regtest）への self-match を見落とし** pre-check が abort。
3. ★**worker3 の regnorm 違反 自己申告**: 04:47 ack の『emulator 起動を pgrep 実測で確認済み』は**虚偽**（実出力は not started yet、
   期待値を観測扱いして送信）。自己申告により 04:48 の訂正 ack で開示 — **三度目発進は pid + stderr 成長を実測してから ack**★。
4. **boss1 独立実測（04:48）で三度目発進を確認**: timeout+regtest process 実在 / h3_anchor.jsonl 134KB 成長 / stderr LAUNCH 行 9 本
   （president 指示の縮小 3 点規則 = process + file + marker）。
5. **lesson（台帳固定）**: (a) 待機 guard の検証対象は『パターンが自分に当たるか』でなく**『同じ argv に含まれる全 literal』**
   (b) **恒久策 = pid file / flock**（cmdline match は書いた瞬間に self-match 候補。president 指示、次の harness 修正時に実装）
   (c) `pgrep -x`（comm 15 字・cmdline 非参照）は self-match 原理的に不能 = 外部 shell からの idle 判定に使える。

### ★canonical savestate 上書き incident（user play 起因、05:45 worker3 報告 → boss1 裁定）★

**事実（worker3 全実査 + boss1 が preserved copy 実在を確認）**:
- `SLPS-01797_3.sav` が **04:38:59 / 04:39:14 の user save（duckstation-qt、02:54〜稼働中の user play）で上書き**。
  原本（baseline A = H2〜H3 の canonical）は rotation で消失、.bak も probe 4/12 addr 不一致で A でない。
  新 2 版は hash 付き即時保全済（`preserved_slot3_{bak,sav}_*`、boss1 実在確認）。
- ★**hot batch 28 run = 無傷の証明**★: 全 run per-launch init snapshot が 80/80 launch とも A に一致 + mtime 整合
  （batch 終了 04:11 < 初回 save 04:38）⇒ **hot verdict（INPUT 6 / NOT-SHOWN 1）は有効**。
- anchor1/2 は **baseline B（新 save）を load** — rare2(A) との 640A4 read 数不一致の真因。
  ★**coverage assert 163 が捕捉**（assert 無しなら誤った mini sweep で silent 進行していた = prereg 様式の配当）★。
- cdbc_v00 追加所見: launch record 15/80（entry_done 80）= **pointer 摂動で 65 entry が launch marker 未到達 = DONE 級の強い INPUT 証拠**
  （comparator の divergent 数は undercount、verdict 不変・数字は正式表で是正）。
- ★未解決 confound（束で台帳）: EARLY orig の run 内 block 変動（file 変更で説明不能）= EARLY hook × per-entry LoadState の順序/同期疑い。
  df8c pair 非一致も同束。**機構推論は 2 敗で停止（規範遵守）→ replicate 実験 1 対で決着**★。

**boss1 裁定（05:5x）**:
1. **replicate 実験 1 対 = GO（rare の前、~12 分）** — 不変 copy 上で同 env 2 run → bit 比較。EARLY confound 束の切り分けに直結。
2. **rare batch = `DGSTATE=preserved B copy`（不変・user save 免疫）で実施、全 verdict に scope label『savestate B』**。
   hot（=A）と分離報告。anchor1/2 は B 素材として有効（04:39:14 以降不変確認済）。merge assert は 163 前提を撤廃し内部整合へ = 承認。
3. **N の scope 案（PRESIDENT へ上申）**: N（savestate A scope）の更新は **hot INPUT 6 のみ**（A 走行・無傷証明済、worker1 x-check 後）。
   rare の INPUT は **『B-scoped causal witness』として別立て** — 存在 claim（この addr は因果入力になり得る engine state）は transfer、
   count/population claim は non-transfer。close パッケージは両 scope 並記。
4. **予防**: 以後の全 run は preserved copy を DGSTATE に（user play は制限しない — 免疫側で解決）。
