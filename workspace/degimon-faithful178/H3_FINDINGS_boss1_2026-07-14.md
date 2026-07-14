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

### ★rider 弁別 = 決着（07:24）: rider 不活性を実測確立 → drift が唯一残る説明★

- 同一 immutable file・**watch 領域だけが違う** 2 ctl（STATW vs 0x8013E000-E1FF）: **guest 全次元 bit 一致（pc/varflag/rng/done 0/80）+
  init snapshot 0/80 相違**。差 = struct_w のみ（watch 出力そのもの）。
- ⇒ ★**rider（DGWATCH/DGSTORE）は guest に不活性 — 静的読解を実物で裏取り、watch 領域を変えた対照でも成立**★。
- ⇒ **交絡解消**: A 期 ctl-ctl 発散は rider で説明不能 → **savestate drift が唯一残る説明**（d54 末尾 4 件の immutable 消滅と合わせ 2 系統実測支持）。
  『user が該当時刻に save した』の直接 event evidence は未取得 = **機構は候補のまま**（規範維持）。

### ★E0F0 = INPUT 撤回 → UNMEASURED-by-method(B)★ + 生存基準の厳格化（07:44）

- **E0F0（immutable B、3 値・値妥当性 slip なし〔B-orig=0x01=A と同一〕）: 発散 0/80** —
  A の『最強 profile（3 値全次元 14/76/80）』は **全て drift artifact と確定**（A の e0f0 run は全て汚染域 03:12-03:30）。
  ★『最強に見えた profile ほど疑わしい』が 3 値まるごと具現した実例★。
- ★**生存基準の是正（worker3 自己申告）**: 初版は『注入値と**異なる値**の store』のみ計上 — game が偶然同値を書くと
  『生存』に誤判定（注入の因果的役割ゼロ）。**正 = 『first read 前にいかなる store も無いこと』**。
  e0f0 は緩基準 52/80 → 厳密 0/80 で反転 → **verdict = UNMEASURED-by-method（0B9 型 derived/maintained）**★。
- **遡及適用（承認）**: NOT-SHOWN 判定全件（d42×3 値 / d3a の 0x00・0x07 / 640A4）を厳密基準で再判定 —
  NOT-SHOWN → UNMEASURED への降格があり得る。**INPUT 判定は影響なし**（発散が出た時点で因果は立つ）。
- **N 候補 = D18 / D3A / D54 の 3 件で不変**（D3A の INPUT 根拠 = 0xFF 発散 25/80 は生存基準と独立に成立）。
- 採点への note（D-4 で正式化）: worker3 の blind 予測『E0F0 = UNMEASURED（0B9 型 fwpc 隣接）』が **B 実測でそのまま的中** —
  D-2 で ✗ とされた行が反転する見込み（boss1 の E0F0 IN 予測は UNSCORED 化）。

### ★CDBC = BLOCKED[injection-fragile]（07:56）— prereg 保守条項の発動★

- B（immutable・readback PASS）: v0x84 / v0x00 とも **80/80 no_launch（launch 0・vmop 0・DMA 転送 0 = script を一切 load しない）**。
  ctl は 80/80 正常 launch。⇒ ★**pointer LSB 摂動は alignment を壊し table 走査ごと殺す — 『入力を変えた』と『機械を壊した』を区別できない**
  = prereg §A-4 の『全値 crash なら BLOCKED[injection-fragile]』が発動、INPUT と呼ばない★。
- **A の『CDBC = INPUT（CTX+STATE+RNG 75/80）』は撤回**（汚染域 03:36-03:41 + B で挙動不再現）。
- 分離策（補走組込み済）: B dump から **alignment を保つ実在 slot 値**（§A-1 の本来の意図 = 構造由来 gate 値）を算出して注入 —
  正常完走しつつ挙動が変われば INPUT を clean に立証、変わらなければ NOT-SHOWN。
- **暫定統合 verdict（B/A）**: INPUT 3（D18/D3A/D54）/ UNMEASURED 4（E0F0/E7C/FBC/E0FC）/ NOT-SHOWN 2（D42 = 補走 anchor 再判定へ・640A4）/
  **BLOCKED[injection-fragile] 1（CDBC）** / 未確定 = DF8C（B 再走中）+ 真分岐 claim（0x23 補走待ち）。

### ★B dump（08:19）: cdbc 0x84 は『構造由来』ですらなかった — 注入物理制約下の値表現 slip（worker3 自己申告）★

- B ptr table 実測: CDBC(target)=0x8016B104、隣接 slot = 0x8016B048 / B084 / **B1D4**。
  ★『別 slot の LSB を借りる』は byte 注入(下位 1 byte のみ変更)では **0x8016B184 = どの slot にも無い捏造 pointer** を作る —
  **LSB 借用と pointer alias の混同**。prereg §A-1 の意図（別の valid pointer）は A 期の設計時点から満たされていなかった。
  CDBC の no_launch = 機械を自分で壊しただけ、と確定★。
- ★**正値 = 0xD4**（→0x8016B1D4 = 上位 3 byte が一致する唯一の slot = byte 注入で alias 可能な唯一値）— 補走で実施中★。
  registry の B 実在値 = 0x75/0x1E も同時確定。
- ★教訓（which-values 規律に追加）: **『構造由来値』は instrument の注入物理（byte 粒度）で表現可能かまで検査** —
  値の意味論は『何を入れたいか』でなく『何が実際に guest に見えるか』で書く★。
- **DF8C = NOT-SHOWN（B、3 値・値意味論 OK・★厳密生存 51/80 SURVIVED = 生存証明付き下限主張★）**。
  A の『全次元 80/80 = 両 blind 集合外の H4 実例』は **drift artifact と確定・撤回（H4 実例の座も消える）**。
  副産物: **confound #2（df8c pair bit 非一致）も drift artifact と確定**（B では bit 一致）。
- 補走 5 run 発進（immutable B、〜30 分）: d54=0x23（真分岐可否）/ d42 ctl+2 値（anchor 付き厳密生存）/ cdbc=0xD4。

### ★補走の結果 — boss1 自力集計（12:0x。worker3 通知不達 3h idle → PRESIDENT 指示で artifact 直読）★

worker3 の完了通知が届かず（pane 生成文のみ・送信ゼロ、v3 が phantom 33 回隔離）、補走 5 run は 08:49 完走済みと実査で確定 →
boss1 が cross-validated comparator（h3_compare.py、22/22 検証済）+ 自前 bracket script（stderr LAUNCH anchor、frame tie は保守側）で独立集計:

| pair | readback | 発散 | 厳密生存 | boss1 判定 |
|---|---|---|---|---|
| d54 = **0x23**（B orig 0x22+1） | 80/80（orig=34 実測） | **STATE 1/80 @ (47,82,0)** | 80/80 SURVIVED | ★**真分岐 claim = H3 不成立 確定**（orig+1 正値でも PC-PATH 出ず）。**D54 INPUT = 4 値 × 2 baseline で同一 launch・同一 dim に一貫**★ |
| d42 = 0xFF | 80/80（orig=100） | 0/80 | **80/80 SURVIVED** | **NOT-SHOWN（B、生存証明付き）** — 遡及懸念は anchor 付き補走で解消 |
| d42 = 0x65（orig+1、B でも valid） | 80/80 | 0/80 | **80/80 SURVIVED** | 同上 |
| cdbc = **0xD4**（alias 可能な唯一の実在 pointer） | 80/80（orig=4 = 0x8016B104 の LSB） | ★**STATE 51/80 @ (1,254,0)**★ | 61 SURVIVED / 19 NOREAD / 0 DEAD | ★**CDBC = INPUT（B scope）** — 完走正常（launch 80/80、no_launch ゼロ）のまま挙動が変わった = BLOCKED[injection-fragile] を解消、§A-1 意図の正実装が一発で clean に立てた★ |

- **a4 = 0x75 の silent drop**: START banner に居るが RUN_DONE 無し → **640A4 verdict は補走前のまま据置**（NOT-SHOWN B・任意値 2 点、silent 昇格させない）。欠落理由は worker3 に照会中。
- worker3 pane 生成文（真分岐不成立 / D54 一貫）は boss1 の独立数値が一致したため**この時点で正式採用**（生成文の先読み採用はしていない）。

### 最終 verdict 表の提出と boss1 突合（12:04、worker3 `b159b06`）

- **一致**: INPUT 4（D18/D3A/D54 = A、**CDBC = B**）/ NOT-SHOWN 3（D42・DF8C・640A4）/ UNMEASURED 4。撤回 7 件。
  worker3 は a4=0x75 を**追走で実施**（silent drop を自己開示 + 是正、2/2 entry・生存 1/1）→ 640A4 = NOT-SHOWN(B、B registry 実在値で試験済) に更新。
- ★**差分 1 件（boss1 突合で検出、verdict 不変）**: cdbc の厳密生存 = boss1 61 / worker3 51。
  真因 = ★**LOADT CAP HIT（100k）**★ — 最終 load record は frame 19,921、最終 launch anchor は frame 26,814 =
  **cap 後の entry では load が記録されない**。boss1 の bracket はそれを NOREAD 19 と数え、SURVIVED を 61 に膨らませていた（cap 前は 61 - α）。
  **worker3 の 51 が保守側で正**。★verdict は guest stream ベース（STATE 51/80 発散）ゆえ **INPUT(B) は不変**★。
  教訓（既知 class の再来）: **打ち切られた list の不在は否定でない** — cap は生存の"分母"を静かに削る。cap 開示があったから突合で捕まえられた。
- ★**D42 の BLOCKED 次元 causal witness 2 件（boss1 spot 検証済）**★: (a) 窓外 read +162 (b) ★**0xFF/0x65 注入時のみ target へ 80 件の書込、ctl は 0 件**★
  （boss1 実測: ctl store 0 / vFF store 80）= **機械が注入値に反応して書き戻している** = 因果的反応の直接痕跡。
  ★ただし効果が**宣言済み BLOCKED 次元にしか出ない**ため INPUT に昇格させない — 『効果はある、が測れる窓に出ない』の最も純粋な実例★。

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

## 3. ★H3 close パッケージ（boss1、2026-07-14 12:2x。crash 再起動後、全項 artifact spot-check 済で作成）★

前提の再検証（boss1 crash → PRESIDENT re-brief 12:1x → 鵜呑みにせず artifact 検証、規律遵守）:
- worker 生存実査 = worker1/2/3 + PRESIDENT 全 pane 生存（tmux 実査）。
- re-brief 7 項目中 6 項目 = artifact 一致（worker3 `b159b06` / worker1 `0d1bc23` / h3s_* + h3_supp.log / 32069a3 突合と整合）。
- ★食い違い 1 件（良性、artifact 側が新しい）★: 「a4 欠落説明は未着」→ 実際は worker3 が `b159b06`（12:04）で
  原因開示（df8c 行削除時の編集ミス = script 編集事故）+ **追走実施済**（h3s_a4_v75、12:01、sweep 2/2 実在を boss1 stderr 実査、
  生存 1/1）→ **640A4 = NOT-SHOWN(B、B registry 実在値 0x75 で試験済) に更新**。据置でなく更新側が正。
- ★新規 commit 1 件（re-brief に無し）★: worker3 `31e853f` = per-launch 救済の実施可能性を実測 —
  d54 = 救済実施済（ctl 80/80 clean）/ d42・d3a = 救済不要 / **e0f0・cdbc・df8c = 構造的に不可能**
  （ctl 自体が 0/80 clean = 同一 baseline の比較基準が存在しない）→ この 3 件の verdict は B 再走のみが根拠、
  「実施せず」でなく「不可能」と明記。§(1)(3) を強化する材料として採録。

### (1) 6→4 精錬表（hot 速報 INPUT 6 → 最終 INPUT 4、各件の理由）

| addr | hot 速報(A) | 最終 | 精錬の理由 |
|---|---|---|---|
| 0x80141D18 | INPUT | ★INPUT (A clean)★ | ctl clean 域・3 値発散(50/43/25)。label は multi-dimensional に訂正（PC-PATH 1 + PC-LEN 13 + DONE 14 + STATE + RNG、x-check 収束値）。v0x80 = STATE のみ = 因果 state-only witness |
| 0x80141D3A | INPUT | ★INPUT (A clean)★ | vFF: STATE 25/80 のみ = 因果 state-only witness。0x00/0x07 は生存証明付き NOT-SHOWN 値（閾値 gate 型） |
| 0x80141D54 | INPUT | ★INPUT (A clean launch + B 再現)★ | A は per-launch 救済（(47,82,0) init bit 一致の 1 launch のみ採用）+ B で 3 値（00/FF/0x23=B 正値 orig+1）が同一 launch・同一次元 STATE・1/80 に一貫 = 4 値×2 baseline で最堅 |
| 0x8013CDBC | INPUT | ★INPUT (B scope へ移動)★ | A 期 run は汚染域で撤回。B で §A-1 正実装（0xD4 = 唯一 alignment 保持で alias 可能な実在 pointer 0x8016B1D4）が一発 clean: 80/80 正常完走のまま STATE 51/80 発散 = BLOCKED[injection-fragile] 解消 |
| 0x8013E0F0 | INPUT | **UNMEASURED-by-method (B)** | 「最強 profile」は 3 値まるごと drift artifact。B で 0/80 かつ厳密生存 0/80（全 entry で read 前に store）= 0B9 型 derived/maintained class。A 側救済は構造的に不可能（ctl 0/80 clean） |
| 0x8013DF8C | INPUT | **NOT-SHOWN (B)** | drift artifact。B で 3 値（B 正値 0x01 含む）0/80、厳密生存 51/80 = 生存証明付き下限主張。H4 実例の座も消滅。A 側救済は構造的に不可能 |

### (2) 撤回 7 件と役割巻き取り

1. **E0F0 = INPUT（最強 profile）** → B 実測で UNMEASURED。worker3 の blind 予測（E0F0=UNMEASURED）が的中していた側。
2. **DF8C = INPUT（両 blind の集合外 = H4 実例）** → NOT-SHOWN。★H4 実例としての引用は以後禁止（座が消滅）★。
3. **CDBC = INPUT(A)** → A 撤回、ただし B 0xD4 で INPUT 再確立（撤回と再確立は別 evidence、混同しない）。
4. **D54 0x51 = 真の制御流分岐（H2 以来 2 例目）** → H3 では立証されない（A 汚染 + B 正値 0x23 で PC-PATH 出ず = STATE のみ）。
   「H2 の PC-PATH 例に続く 2 例目」という叙述は close から除去。
5. **confound #1（EARLY hook 順序問題）** → run 中 savestate 差し替えの直接痕跡で説明、機構推論は撤回。
6. **confound #2（同一実効注入で bit 非一致）** → B で bit 一致 = drift artifact。
7. **「baseline A 指紋照合 28/28×80/80」** → vacuous audit（不在 addr の空文字比較 = 自作の完全性偽 GREEN）。
   非 vacuity assert 付き監査に置換済。hot 28 run の A 無傷証明は per-launch init snapshot + mtime 整合という別 evidence で成立（巻き添え無し）。

### (3) methodology 新規 8 項（H3 で確立、以後の標準）

1. **per-launch 粒度が正しい判定単位** — 汚染判定も clean 救済も run 単位/時刻単位では誤る（d54_v00 = 75 clean + 末尾 5 drift）。集計粒度も「次元」。
2. **注入物理での値表現可能性検査** — 構造由来値でも byte 注入で表現可能かまで検査（cdbc 0x84 = LSB 借用と pointer alias の混同 = 捏造 pointer）。
3. **生存基準の厳格化** — 「異なる値の store のみ」→「read 前にいかなる store も無し」（偶然同値 write の偽生存封じ）。NOT-SHOWN 全件へ遡及適用済。
4. **which-values class の全数監査** — 相対指定値（orig+N）・参照値（別 slot）は baseline ごとに再算出（B 再走の orig+1 が A 値 hard-code だった slip から）。
5. **banner/RUN_DONE 突合** — script の宣言と実行 log の突合で silent drop を機械捕捉（a4=0x75 の欠落を検出→追走で是正）。
6. **非 vacuity assert** — 監査は「照合対象が実在する」ことを assert してから照合（空集合照合 = 偽 GREEN 製造機）。
7. **rider-invariance / ctl-ctl 一致テスト** — control 同士の bit 一致テストを常設（rider 不活性の実測確立 + ctl-ctl 発散が汚染の完全性 oracle として機能した）。
8. **no-silent-caps 開示 → 突合** — cap 開示（LOADT 100k HIT）があったから生存分母の膨張（61 vs 51、cap 後 entry の load 非記録）を突合で捕捉できた。打ち切られた list の不在は否定でない。

（補: replicate 対 = immutable copy 上で同 env 2 run BIT-IDENTICAL = 決定性の直接実証、も §(5) の基盤として常設化。）

### (4) A・B 両 scope の verdict 全表 + N=12 の根拠

確定 verdict 全表 = worker3 `b159b06` H3A_FINAL_VERDICTS.md（boss1 突合済、差分 1 件 = cdbc 生存 61 vs 51 は worker3 の 51 が保守側で正 = LOADT CAP、verdict 不変）:

- **INPUT 4**: D18(A) / D3A(A) / D54(A clean launch + B 再現) / CDBC(B)
- **NOT-SHOWN 3**: D42(A/B、6 次元。★BLOCKED 次元に因果 witness 2 件併記 = 窓外 read +162 / 注入時のみ target へ 80 件書込(ctl 0)、boss1 spot 実測済★) / DF8C(B、生存 51/80) / 640A4(B、実在値 0x75 試験済)
- **UNMEASURED-by-method 4**: E0F0(derived/maintained) / E7C・FBC(per-entry DMA squash 12/12・8/8) / E0FC(write-first 17/17 = rbw=0 分類の注入実験による直接観測、負 control 成立)
- **controls**: positive 0x80145E5A = 60/60(pipeline 健全) / P1 replica 3 対 / rider-invariance / replicate 対 BIT-IDENTICAL

★**N（savestate A scope）= 9 → 12**★（PRESIDENT 承認済、12:1x re-brief で再確認）:
- 追加 3 件 = **D18**（multi-dim、A clean）/ **D3A**（state-only witness、A clean）/ **D54**（4 値×2 baseline、per-launch 救済 evidence）。
- いずれも per-launch init snapshot で A 無傷 or clean launch 限定 evidence + worker1 x-check（22/22 bit-exact + 補走 4 pair 独立一致 `0d1bc23`）を通過。
- **CDBC = B-scoped causal witness 1 件**（existence transfer / count non-transfer、PRESIDENT 裁定 06:0x）= N(A) には入れない。
  存在 claim「このアドレスは挙動入力」は成立、population count は baseline B の別台帳。

### (5) 規範遵守 evidence（全て boss1 実測、2026-07-14 12:1x）

- **push ゼロ**: origin/main = `59488d0` 不変（phase 開始前 sha のまま）。f1c = 82 commits / f1a = 69 commits 全て local、両 worktree working tree clean。
- **frozen 不触**: preserved 2 file = perm 400 実測 + baseline B sha256 `4aa92a9f…` 再計算一致（台帳値と bit 一致）。
- **game code ゼロ**: H3 window（prereg 4cd2c9f = 07-13 12:15 以降）の f1c/f1a 全 commit の変更 path = workspace/ + docs/ のみ（unity/ 変更ゼロ、git log --name-only 実査）。
- **prereg 固着**: `4cd2c9f` 以後の H3_PREREG diff = 承認済 caveat 追記 47 行 + placeholder 1 行置換のみ（本文の書き換えゼロ）。

### (6) 次 phase 材料 + 単一推奨

材料（優先順）:
1. ★**D42 write-back witness = 第一級 target**★ — 「注入値に機械が反応して書き戻す」因果反応が宣言済 BLOCKED 次元にのみ出る。
   測定窓の拡張（POST 次元の capture 化）で INPUT 判定可能になる見込みが最も高い。boss1 spot 実測済（ctl 0 / vFF 80、A/B 再現）。
2. UNMEASURED 4 件の測定法: E7C/FBC = DGDMA 同乗で first-read 前 squash を可視化 / E0FC・E0F0 = derived class の上流 writer 特定（0B9 型の既存手法流用可）。
3. capture 仕様の未決部分: MAPHEAD→0x46/0x79→0x66 実装欠落台帳 7 件（H2 §17-18）+ 真 live-in 候補残（10 件中 H3 で 12 addr 処理済、突合要）。
4. 汚染防御の恒久化は完了済（immutable copy + chmod 400 + 全 run DGSTATE 固定）= 次 phase はこの上で走る。

★**単一推奨: capture 仕様確定 → 実装へ進む**★（user 裁定済の推奨順序どおり。因果 sprint は本パッケージで close、
次 dispatch = capture 仕様 draft を boss1 が worker RE 材料から起案 → PRESIDENT 査読）。D42 の POST 次元 capture 化を仕様に含める。
