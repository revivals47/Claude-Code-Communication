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

## 1d. (c) self-modify 疑い annex 最終化（worker2 `7654661`、s0 未確定のまま据置）

3 事実の並置: ① 静的 RE（0x800AF6AC の 0xFD→0 機構 = 構造事実 / 0x800BB940 = sb zero,0x34(s0)）
② A scope（tally-3）で fwpc=BB940 を E7C/FBC に観測 ③ rare B で BB940 store 非再現 + **per-entry script DMA reload 実証**。
台帳文言: 『CPU write は A で観測・B で非再現。buffer は per-entry reload される（実測）。**s0 実体は未確定 = self-modify とも無いとも言えない**』。
★未回答 3 点を明示: s0 実体 / **同一 entry 内書換の可否（per-entry reload は entry 跨ぎ持続のみ否定）** / 0xFD→0 の実適用（機構の存在≠適用）★。
E7C/FBC の身分 = UNMEASURED-by-method + (b) per-entry reload 実証、live-in 候補としては保留。**worker2 の H3 タスク全完了**。

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

## 1e. ★★hot 4 target の baseline drift 汚染疑い — INPUT 4 件凍結（06:52 worker3 自己撤回 → boss1 裁定）★★

### worker3 の自己撤回（worker1 の query 2 が引き金）

1. ★**元の指紋照合『28/28×80/80 全一致』は vacuous = 完全性偽 GREEN の自作**★: audit script が `ri.get(addr,'')` で
   **不在 addr を空文字に化かし、空文字同士を比較**していた（判別 block 3 本は launch.init に実在しない — worker1 指摘どおり）。
2. 実在 block（0x8013E100 / 0x80145E58 / 0x8016B07C）で再監査 → **ctl 同士（注入ゼロ）の guest stream が食い違う**:
   d18_ctl vs e0f0/cdbc/df8c_ctl = 全次元 80/80 発散（d3a/d42/d54_ctl とは 0/80 一致）。
   時系列境界 = duckstation-qt 起動 02:54:29（d18/d3a/d42/d54_ctl = それ以前 = clean）。
3. **verdict 影響**: 維持 = D18 INPUT / D3A INPUT / D42 NOT-SHOWN(+POST)。★凍結 = D54 / E0F0 / CDBC / DF8C の INPUT 4 件★
   （drift でも『全次元発散』は同じ絵 — **最も強く見えた profile ほど疑わしい**）。**確定 INPUT は現時点 2 件**。
4. 是正 = 4 target × 15 run を preserved immutable B copy で再走中（〜08:05 見込み、B scope label で再提出予定）。

### boss1 裁定（07:0x）

- **凍結 + immutable copy 再走 = 承認**（凍結は保守方向、再走は機構仮説に依らず verdict を確定させる）。
- ★**『真因確定』は過剰 label → 【機構候補】に降格**★: 提示機構（user save が per-entry reload 中の baseline を差し替え）には
  **時系列の穴**がある — 既知の file 書込 event は 04:38:59/04:39:14 のみで、**汚染とされる run 群（02:55〜04:11）より後**。
  02:55〜04:11 に slot3 が書き換わった event の実証（qt の save 履歴 / rotation 痕跡 / 別 channel の書込 = memcard 等の除外）が
  無い限り『確定』とは書かない。**観測事実（実在 block での ctl-ctl 発散）が operative fact であり、凍結の根拠はそれで足りる**。
- ★**ctl-ctl 発散の観測自体も x-check 対象**★: worker3 の audit tool は直前に vacuous 偽 GREEN を出した —
  再監査 script + 発散 evidence を commit させ、**worker1 に独立検証を dispatch**（rider 構成差での ctl-ctl 比較の妥当性
  — rider-invariance は d18/d3a の 1 pair でしか実証されていない — を含めて）。
- 採点 D-2 の該当 4 行 = PROVISIONAL 降格（prereg D-3）。**N 更新候補は現時点 D18 + D3A の 2 件に縮小**、正式上申は再測定+x-check 後。
- confound #1 の機構再帰属（EARLY hook 順序 → run 中 file 差し替え）も**候補どまり**（同じ時系列の穴に依存）。

### worker3 の裁定反映 + 追加開示（06:56、`e3d2aef` = 監査 script + evidence + 再走 script）

- 機構候補への降格 = 受諾。補足: **mtime rotation は直近 2 版のみ保持 → 02:55〜04:11 の save の不在は証明不能**
  （『痕跡が無い』はどちらの証拠にもならない — 打ち切られた list の不在は否定でない、の実例）。
- ★**追加交絡の自己開示**: 一致 4 ctl = **全て同一 DGWATCH 領域（STATW）** / 発散 3 ctl = **各々別 watch 領域** =
  **時刻と rider 構成が完全交絡**。rider-invariance 実証は同一 watch の 1 pair のみ = 『rider 不活性』は未証明
  （静的には観測のみの実装 = 期待は不活性、だが期待は観測でない）★。
- ★**弁別の事前設計（再走に内蔵）**: 同一 immutable file 上で h3b_d54_ctl（STATW）vs h3b_e0f0_ctl(別 watch) —
  **bit 一致 → rider 不活性 = drift 候補支持 / 発散 → rider observer effect（savestate drift 不要）**。どちらでも凍結判断は不変★。
- 監査 evidence: 非 vacuity assert（block 実在強制）導入済。発散 3 ctl は **init snapshot が 80/80 launch で相違** =
  launch 時点 RAM が違う直接痕跡（drift 寄りだが rider 経路排除まで断定しない）。
- 再走 06:51 START（〜08:20）。h3b ctl 群で ①rider 弁別 ②4 target 再判定 ③d18 label 訂正 + state-only witness 確定を 1 commit 予定。

### query 2 件の決着（06:59、worker3 `bc32434`）

- **Q1（d18）**: h3_compare.py に正規化・除外は**無し**（実物確認）。過小記述の出所 = ★**first-divergence の dims 文字列 1 件だけ見て
  label を書いた（per-launch 出力の全件集計をしなかった）**★。全件集計の正: d18 v00/vFF = STATE 50 + RNG 43 + PC-LEN 13 + DONE 14 + PC-PATH 1。
  訂正済: **d18 = multi-dimensional（0x8013E2E0 と同型）**。
  ★**因果 state-only witness の確定（自 tool 全件集計で PC 系ゼロ）: `0x80141D18 v0x80`（STATE のみ 25/80）+ `0x80141D3A v0xFF`（STATE のみ 25/80）**
  — 両方 clean baseline A・汚染 target 非依存 = close headline に使用可★。（d18 の PC-LEN 13 は「pert 側延長」型、内容分岐は 1 launch のみ）
- **Q2（A 指紋）**: worker1 が正。実在判別 block = 0x8013E100(488B) / 0x80145E58(8B) / 0x8016B07C(984B)。
  現行 audit = h3_baseline_audit.py（非 vacuity assert 付き）。
- ★新教訓（methodology 節へ）: **label は first-divergence の標本でなく per-launch 全件集計から書く** — 『表 vs 自 tool 出力』整合 check の根本原因が同定された形★。

### 汚染 audit の独立検証（07:0x、worker1 `2f4322a`）—(1)(3) 完了

- **(1) clustering = bit-exact 再現**（cluster A {d18,d3a,d42,d54} 相互 0/80・非 vacuity / cluster B {e0f0,cdbc,df8c} 80/80）。
  dim 精密化: 発散は **STATE 80 + RNG 68 主導、PC 系 6**（『全次元』は count 正・dim 主導は STATE）。
- **(3) ★時系列境界の独立訂正: 02:54（qt 起動時刻の proxy）でなく実測 (02:55:49, 03:01:30)★** — init snapshot による per-run 直接判定。
  ★**d54_v00（02:55:49）= CLEAN** / 初 DRIFT = d54_vFF（03:01:30）★。時刻 proxy より測定が 3〜6 分細かい。
- ★**d54 nuance**: 100% 汚染ではない — **v00（STATE 5/80、first-div (47,82)）は clean baseline 上で有効**。
  vFF（75/80）+ v51（73/80 = 真分岐 evidence）のみ drift 交絡 = 強 evidence 側が交絡、弱 evidence 側が clean★。
- rider-invariance = 1 pair → **4 構成（cluster A 相互）に拡張**。ただし全て 0x80141Dxx family（境界前）— 0x8013xxxx family は未証明。
- init 差分 byte は**全て mutable 領域**（E104/E204 marker・item bitset・E5A）、stable savestate byte 差ゼロ =
  『別 savestate』か『mutable drift』かは init だけでは未確定 → h3b 弁別（(2)、defer）に同意。

### ★D54 = INPUT（A scope）復帰確定（07:0x、per-launch 粒度で両 worker 収束 → boss1 裁定）★

- worker3 の per-launch 実測（非 vacuity audit）: d54_v00 は**一律 CLEAN ではない** — init 相違 = **末尾 5 launch のみ**
  （(200,6)(207,5)(213,81)(217,51)(220,81)、run 02:49:52〜02:55:50 の末尾で file 差し替わり = worker1 境界 02:55:49 と整合）。
  ★**first-divergence launch (47,82,0)（sweep index 20）は init が ctl と bit 一致 = baseline 同一を実測**★。
- ★**粒度の教訓**: worker1 の run 単位判定（v00=CLEAN）は末尾 5 launch を丸め、worker3 の時刻 proxy（02:54 以降全汚染）は粗すぎた —
  **正しい粒度は per-launch**。食い違いは粒度を上げたら消えた★。
- **boss1 裁定: D54 = INPUT（A scope）復帰**。採用 evidence = ★**launch (47,82,0) の 1 件のみ**★（init bit 一致 + readback PASS +
  STATE 発散 + 生存 clean）。末尾 4 launch の発散は drift 交絡で除外。**閾値 aba590e の正規適用（1 launch でも clean 発散 = INPUT）であって緩和ではない**。
  vFF/v51（真分岐 = headline 級）は凍結維持 → h3b 再検。**N 更新候補 = 3（D18/D3A/D54）**。
- ★時系列の穴の部分充填: d54_v00 run 末尾の init 相違 = **02:55:49 頃に load される file 内容が実際に変わった直接痕跡**
  （per-entry reload 前提。rotation で mtime 痕跡が残らない save の実在を示唆）— 機構はなお候補（rider 弁別待ち）だが、
  『02:55〜04:11 に書込 event の evidence が無い』という反論は弱まった★。
- per-launch 救済手法は e0f0/cdbc/df8c にも適用可（汚染 run 内の clean launch）→ worker3 の 1 commit（h3b 突合込み）で実施予定。

### h3b で D54 が immutable B 上に完全再現（07:05）— drift 機構候補が一段強化

- h3b_d54_ctl/v00（preserved immutable copy・同 rider 構成）: ★**first-div = (47,82,0)・dims=STATE — A の clean launch と同一 launch・同一次元で再現**★。
  発散 = **1/80**（A の 5/80 との差分 4 件 = 末尾 init 相違 launch と完全一致、**immutable file 上では消滅**）。
  readback 80/80 / store 2 件 / dma_w cover 0/17,964（squash なし）。
- 含意: (1) ★**D54 = INPUT は A（clean launch）と B（immutable）の 2 baseline で独立再現** — existence transfer 自明★
  (2) ★**drift 機構候補の強い支持**: 『file が変わらなければ末尾 4 件の発散は起きない』が実測。rider は両 run 同一 = rider 説では説明不能な差★。
  rider 不活性の直接証明は h3b_e0f0_ctl 待ち（維持）。
- ★粒度の教訓の一般化（PRESIDENT 採録指示）: **集計粒度も次元の一つ** — run 単位・時刻 proxy は粗い粒度での射影だった。5→4→2 の射影連鎖と同族★。
- worker1 が per-launch を独立再測で確認（`c39c990`、CLEAN 75 + 末尾 DRIFT 5 = 一致）→ **凍結集合 = {E0F0, CDBC, DF8C} に縮小確定**。
  A 有効 = INPUT 3（D18/D3A/D54）+ NOT-SHOWN 1（D42）。worker1 も『どの粒度で見たか』教訓を自台帳化。

### ★which-values slip（07:18 worker3 自己検出）: B での『orig+1』が A の値の hard-code だった★

- h3b_d54_v51 は **B の最小摂動でなかった**: B の D54 orig = 0x22（A は 0x50）→ B の orig+1 = **0x23**。0x51 は『B では別の試験』。
  ⇒ ★**真の制御流分岐 claim は『反証』でなく【B 未試験】のまま凍結継続**★（h3b v51 の 1/80 STATE は分岐 claim に触れない）。
  A 側の当該 evidence（v51 run 03:06）は drift 交絡域ゆえ採れない。**真分岐 headline は『H3 未確立』として close から外す**（0x23 run で復活可否）。
- h3b の他の実測値: vFF は B 上で 1/80 STATE のみ = **A の 75/80 の誇張分は drift 由来と確定**。
- ★**confound #1 = 決着**: B では EARLY orig 80/80 一様（0x22）/ A 汚染 run は {56,72,80} の 3 block =
  **orig 残滓 = file 差し替えの直接痕跡**。worker3 の『hook 順序』仮説は誤りと確定★。
- **boss1 裁定**: 是正 3 点承認 + ★**slip class の全数監査を追加指示**★ — B 再走で使った**全値**（e0f0 の orig+1 / cdbc の『別 slot 実測値』0x84 /
  registry の 0x93 等）について『その値の意味論的根拠（orig+1・実在値）が **B の実測**から算出されているか』を 1 件ずつ監査
  （見つけた 1 instance を直すだけでは同 class の残りが素通りする）。★『orig+1』等の相対指定値は **baseline ごとに再計算** = which-values 規律に追加★。

### 全数監査の結果（07:20、worker3 `93168d0`）— class の中身が確定

- **SLIP 確定 1**（d54 0x51）/ ★**B 値確定待ち 4**: e0f0・df8c の orig+1 / cdbc 0x84 / **a4 0x93 = A 期 registry の slot[0] 値と特定**
  （= B の実測でない ⇒ **640A4 NOT-SHOWN(B) の which-values 注記も『任意値 2 点』へ訂正対象** — verdict は下限主張ゆえ不変）★ /
  ✅ **baseline 非依存 3**: 0xFD = engine 定数（0x800AF6AC の比較値、再走不要）/ 絶対境界値（実効値は perturb record の new から読む規律を明記）/
  e0fc 0x02（B orig=0x01 を perturb record で実測済 = B でも orig+1 として正当）。
- 補走計画承認: **B dump 1 本（〜30 秒）で ptr table + registry + 3 addr の orig を実測 → 全相対値・参照値を B から再算出** → 補走各 1 run
  （d54=0x23 が真分岐 claim の可否を決める run）。close 前に含める（boss1 判断済み）。

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

### x-check 決着（06:5x、worker1 `6353050` + unblind 突合 `ec02042`）— 2 実装が count・dim 両層で完全収束

- **発散数 22/22 bit-exact（独立実装同士、初回から）+ unblind 後 dim-level も全 22 pair 不一致 0**。readback 22/22 / survival = before-first-read bracket で厳密確認。
- ★**d18 dim 相違の決着**: worker1 tool の過剰ラベル（PC-PATH を full-list 比較 = 長さ差を混同）。**正しい内訳（両 tool 収束値）= PC-PATH:1（真分岐）+ PC-LEN:13（return_fe→idle_stop の実行長差）+ DONE:14**★。
- **boss1 裁定 (A)**: worker3 verdict 表の d18 一言『PC 次元に一切出ない』は**自 tool 出力と不整合の過小記述** → doc 訂正指示。
  ★**d18 の label = multi-dimensional に変更**（state 主体 + PC-LEN 13 + 真分岐 1 + DONE 14。0x8013E2E0 と同型）。
  『因果 state-only』の witness は **dim-level 収束データで PC 系ゼロが立つ value-run**（d3a_vFF / d18_v80 が候補、worker3 が自 tool 出力で確定）に移す★。
- worker1 の tool 自己捕捉 3 件（segment 境界 = 一致**前**に捕捉 / PC-PATH full-list / RAW skip）= 台帳化。count は全て不変、dim 正確性の是正のみ。
- 残 reconcile = A 指紋 block 所在（worker3 回答待ち、documentation のみ。hot=A は mtime 時系列で独立成立）。

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

**PRESIDENT 裁定（06:0x）= boss1 案承認 + 追加 2 点（両方実施済）**:
- ★N scope 承認★: N（savestate A scope）更新 = hot INPUT 6 のみ（worker1 x-check 後）/ rare = B-scoped causal witness 別立て
  （existence は transfer / count・population は non-transfer）。
- **追加 (1) 実施済 — preserved copy の filesystem 強制免疫**（boss1、06:0x）:
  - `preserved_slot3_bak_20260714_0438.sav` sha256 = `44a9b1e24081e34e9d663ccf707102e5b8cf45b52a0d4d6ced3a875225c66e74`
  - `preserved_slot3_sav_20260714_0439.sav`（= baseline B、現 slot3 と同一）sha256 = `4aa92a9f9cf6c63078cf010e0dbb6c8b7c01dabb58f347f89409f2090d15b6d7`
  - 両 file とも `chmod a-w` 済（perm 400 実測）。
- **追加 (2) 実施 — baseline A の指紋台帳（復元不能・同定可能）**:
  A の原本 savestate は失われたが、以下が A の部分指紋として disk に残る（将来「これは A か？」の照合に使える）:
  1. `h3_origs_dump.jsonl`（01:24、A 上で取得。sha256 = `42cbbfac26d7f310534e591c5a18e1ef24524e1006537d961bab2d0a5860bbb9`）
     — 12 注入 addr の orig 値 + launch(1,254) の init snapshot（bank_block 601B / flags / vars の全 hex）。
  2. hot 28 run の per-launch init snapshot（80/80 launch × 28、ram_inputs 判別 block）— A 一致の証明に使った当のデータ。
  3. 04:38 以前の A 走行 artifact 群: `final_run` / `sp_run` / `loadt_run` / `rbw_tally.jsonl-3` / `B_DUMP_225_LIVE.tsv`（00:35）。
  4. **A vs B の判別子（probe 実測）: 12 注入 addr 中 4 addr が不一致 = D3A / D54 / CDBC / E7C**（B で値が変わった = user play の進行分）。
