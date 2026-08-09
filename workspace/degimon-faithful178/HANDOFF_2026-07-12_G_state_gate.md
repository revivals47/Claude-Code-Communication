# HANDOFF — 2026-07-12 G dispatch(measured 忠実度 / state 次元を開いた日）

> ★**全数値は次元付き・水増しゼロ。push ゼロ（全 local）。cutscene runtime 不触。frozen authority 09fde5a 不変。**★

---

## ★0. 今日の総括（PRESIDENT 直命・冒頭に置く）★

**朝、我々の測定器は「text が一致すれば正しい」だった。** それは偽 GREEN を 8 件隠し、cutscene が 66→4 page に崩壊しても「pages>0」で緑を返していた。

**今は、原盤 VM を実機（改造 DuckStation）で走らせ、event 列を 2 次元（PC + state）で diff し、偽 GREEN を 11 着コードで塞いだ authority がある。**

**最大の発見 = 挙動忠実度は 0 / 469 だった。** 我々は「制御流だけ合わせて忠実と呼んでいた」。**measured 忠実度は、今日はじめて honest な出発点（0）に立った。** 数字が下がったのは後退ではない — 見えていなかった次元が、初めて見えた。

## ★★次 session 冒頭規範（PRESIDENT 直命）★★

**★『検証を素通りさせる入口』は 4 つ、穴は 1 つ（＝未検証）★**:
- **『正しい』の嘘**（偽 GREEN） / **『測れない』の嘘**（偽 BLOCKED） / **『網羅した』の嘘**（完全性偽 GREEN） / **『自分が誤り』の嘘**（過剰譲歩 = worker2 の 31→1948 撤回が未検証の譲歩だった）。
- **4 つは別々の入口だが、同じ穴に落ちる = source を直読していない。** 断定も・撤回も・譲歩も・『covered』も、等しく claim。**自分が source（artifact / process / EXE）を見た時だけ額面採用する。**
- **『進捗の報告』も成果物と同じ厳しさで裏取りする**（status ≠ 観測。ps/pgrep/出力ファイルを叩く。boss1 が本 session status を 3 回誤報 → 最後の最重要判定[決定性 PASS]は自分で cmp+sha256 して確定した = remedy は『気をつける』でなく『手続きを実演する』）。

---

## ★▶ 次 session の最初の一手（user 指定 2026-07-12）= store-side hook★

**store 側 hook から再開する。** 改造 DuckStation に load hook（DGLOADS 機構）と同型の **write hook** を足し、VM 実行中の written-address を tally する。
目的 = **真の入力集合 = (VM read) ∩ (runtime WRITE) を測定で決着**。これで①VM-PC reader 定義（31 か 1948 か）②各 address が runtime に書かれるか、の未決 2 点が両方閉じる。
これは §7（読み側）の対を成す測定であり、**入力表面が本当に閉じているかの最終証明**になる。詳細は §7 の "store 側 未測定 / 次 session" 節。
着手順序: store hook 実装（read-only 測定、frozen 09fde5a には触らない）→ read∩store で真入力確定 → 46-capture を過不足なく再構成 → 決定性テスト再確認 → **その後に** var[0]/RNG(0x24)/0x1B state-gate の実装（本物のコード改善、§5）。

---

## 1. headline（次元併記・合成禁止）

| 次元 | スコア | 意味 |
|---|---|---|
| **PC 列（制御流）** | **351 / 469** | opcode/pc の列が実機と byte 一致した section 数 |
| **state（挙動）** | **0 / 469** | var_w/flag_w の書込列が実機と一致した section 数 |

★**この 2 数を合成した単一スコアを作るな**（次元を潰すな を metric 自体に適用）。PASS = PC clean ∧ state clean。片方だけ = **PARTIAL（次元名付き）**。★
★**さらに重い**: PC 完全一致の 351 本に限っても state 一致は **0 / 351** = 制御流盲点は「85 本」でなく **PC-PASS 全数**に及ぶ。★

## 2. 351 の内訳（(A) コード改善 と (B) 測定是正 を分離・足すな）

| 区分 | delta | 中身 |
|---|---|---|
| baseline | 135 | F1 dispatch 終了時点 |
| **(A) コード改善** | **+96** | length fix 6 件（0x1A +59 / 0x75 +34 / 0x55 ±0 / 0x7C +1 / 0x26 +1 / 0x71 +1）= **C# を直した** |
| **(B) 測定是正** | **+120** | 初期状態 identity 注入。**C# コード変更ゼロ**＝最初から正しく、誤って FAIL と呼んでいた |
| = | **351** | (A)+(B) を「+216 の改善」と書くな。(B) は改善でなく過大評価の是正 |

判定基準（分解テスト）: コード変更だけで gain が出れば (A)。コード元々正しく setup だけ変えたら (B)。詳細 SCOREBOARD_2026-07-12_G.md。

## 3. user 実視覚 PASS（凍結）

★2026-07-12（前 session 2026-07-09）、覚醒 cutscene（entry178）= user 本人が実視覚 PASS 済。★ oracle 4+1（台詞可読/家 ROOM08 切替/twna01 復帰/初期 framing/化け無）通過。**この cutscene は資産。壊す変更は user 確認なしに land しない。** 今 session は runtime 不触を厳守。

## 4. 偽 GREEN の衣装 11 着 + 偽 BLOCKED（全て構造で防いだ）

memory feedback_verify_what_green_asserts.md に一覧。**11 回とも「気をつける」では防げず、防いだのは全て構造**（marker強制/event列比較/authority self-check/staleness guard/provenance gate/宣言外BLOCKED/全出力no-silent-caps）:
1 prefix / 2 known-gap tag / 3 閾値 / 4 整列so無害 / 5 打ち切り比較 / 6 次元推論(欠測vs一致) / 7 authority自身の破損(ra-gate) / 8 cutscene gate(pages>0) / 9 stale artifact測定 / 10 完全性偽GREEN(PC whitelist) / 11 pcs 16-cap(飽和で不在≠未読)。
+ **偽 BLOCKED**（「測れない」も証拠の要る claim。worker2 の stale-register quirk 誤診→実は自分の walk バグ）。

## 5. ★未実装の【本物のバグ】= 次 session の実装対象（state 0/469 の原因、3 層+個別）★

★**worker2 の map は【下限】。完全な列挙ではない**（下記 §8-C 参照、未 RE の subroutine が更に state を書き得る）。★

| 層 | opcode/機序 | 実機回数 | C# | section |
|---|---|---|---|---|
| ① | **flag[44]=0 clear**（24-opcode 共通 prologue 0x800F0AE8 の【毎回】部分、両経路通過） | 1503 | 0 | 112/171（171 残差の主因） |
| ② | **var[0] write**（同 prologue の【初回のみ】部分 var[0]=3 の 894 + 0x800F0910 の var[0]=[gp-0x6cbd] の 476） | 1528 | 0 | 最大単一原因。var[0] は script が 0x19 で読む→PC 次元にも波及 |
| ③ | **0x24 RNG**（var[110]=(rand*(arg+1))>>15、seed=0x80009010 LCG、draft ad7520b 済） | 229 | 0 | 非決定。seed 注入で決定化可（GATE-C 83/83 PASS 済） |
| ④個別 | 0xFE var347 / 0x1B flag101 var62 / 0x25 var36 / 0x4D flag22 var20 / 0x4C flag16 var4 / 0x22 var8 / 0xFF var4 | — | 0 | C# 過剰書込ゼロ = 一貫して under-write |

その他の未実装/draft: **0x1B state-gate**（[0x80145E5A]==1 で speaker write skip、PC 不変ゆえ PC 次元で永久不可視、85 section）/ **0x18 selector=GetVar(idx)**（draft d7b2f65、常に jump、fall-through 無し、transporter 影響は本 authority で測定不能）。

## 6. ★次 session の順序★

1. **決定性テスト結果を確認**（worker3、~30分で完走予定。§9 で追記）→ bit-identical なら「全入力掌握済」から始められる。
2. **実装**（measure-first、1 件ずつ）: ① flag[44] clear（24-opcode prologue、最大原因）→ ② var[0] write → ③ 0x24 RNG（seed 注入 + LCG）→ 個別 opcode → 0x18。
3. **各 fix を PC・state 【2 次元】で per-item 測定**（合成スコア禁止）。
4. **各 fix ごと entry178 cutscene trace-diff**（24-opcode prologue は cutscene に波及し得る。壊れそうなら user 前に上申）。
5. **land 判定**: PC clean ∧ state clean。transporter 系（0x18）は coverage 新設 or user 実視覚（§7）。

## 7. ★0x17 の 11 本原盤 trace = 忠実化の設計図（保全済）★

workspace/f1c/faithful_oracle/（commit d078800）。0x17 cross-scenario（例 163_054→scenario178 §0x37 @pc0x07CC = 覚醒 4-hop と同一機構 = remake が欠く MAPHEAD+return-record+0xFB+0x17）。★将来の忠実化 dispatch はこの 11 trace を oracle にすれば user 実視覚の【前】に正しさを測れる。★ 今は触らない。0x18 の transporter land 条件も (a) coverage 新設が第一 /(b) user visual は最後の手段。

## 8. ★未検証 honest list（worker2 提出 = docs/HANDOFF_unverified_worker2_2026-07-12.md, commit b90baa9）★

**「確かめていないこと」を、確定として引き継ぐな。**
- **A 他人の観測（私は測っていない）**: RNG seed 0x80009010/LCG = worker3 実測 / gp=0x80144E0C = worker3 trace（gp 相対は全てこの算出）/ authority flag_w/var_w VALID = worker3 宣言（PC 469/469 一致のみ自分で確認）。
- **B 意味未同定**: 0x80141D18 bitfield の意味（bit 0x04 の setter 未発見=displacement-scan 盲点）/ gp-0x6cbd の源 / 31 未マップ入力の意味 / sub0/2/5 の意味（HP・攻撃力等と名付けない）。
- **★C RE 途中（最も危険）★**: sub0 id==9 別分岐(0x800F5374)未読=operand 長差の可能性 / var[0] 第2 writer 関数先頭 未特定 / **0x800F0AE8 が呼ぶ 0x800bd820・0x800e3940・0x800a565c・0x800e9a40 が未 RE = 更に state を書く可能性 → §5 の 3 層 map は【下限】**。
- **D 少数サンプル**: sub2 観測 id=33 の 1 件 / 0x18 実行 4 launch / 0x10 の index が player 入力か state か未確定（player 入力と【推定】）。
- **E 原理的に測れない**: 0x18 の transporter/navigation 影響（0x4B 実行 0）/ 0x10 fall-through 長 / 0xFE return-record 継続（空 stack 非 exercise）。
- **F 測っていない次元**: state diff は var_w/flag_w のみ。text/warp/term/scn_set/read 列 未測定 → 「state 0/469」も書込列次元の数字。
- **G land 済の未検証**: **0x71（land 済 c1c6cda）は PC 二重検証済だが state 未検証**（実機 write 2 / C# 0 = PC 直ったが state 未実装）/ 0x1A Len は EXE 検証不能（authority 854/854 再現のみ、honest-mark）。

## 9. commit / artifact / worktree（全 local、push ゼロ）

- **main**: G1 merge 7a87fba / 0x71 land c1c6cda（ahead 多数、**未 push**）。
- **worktree（保全）**: ~/Documents/degimon_world_remake-f1a / -f1b / -f1c + 改造 DuckStation（duckstation-src）。
- **frozen authority**: 09fde5a（sweep_225）不変。派生 g6_loads.jsonl / g6_loads_c.jsonl / G6c.jsonl / init_states.jsonl / faithful_oracle/(d078800) / boot_traces/(e64c067) / VALIDITY_MATRIX.md 保全。
- **draft（未 apply）**: 0x18 d7b2f65 / 0x24 ad7520b。
- **worker2 詳細 handoff**: docs/HANDOFF_2026-07-12_worker2_F1B_G.md（**9a21516**、branch trackF1B/event-oracle、main 7a87fba より 30 commit 先行）+ 未検証 list b90baa9。
- **RE doc**: worker2 = 52b7441/a9e0841/b12edda/c095b39/18443cf/cf041b1/b90baa9。worker3 = 061ded0(snapshot)/354e905(classifier)。
- **tools**: measure_pc.py(staleness guard)/state_diff.py/dg_g6_classify.py/dg_g6_overexclude.py/dims_selfcheck.py/make_init_states.py。
- **★決定性テスト = 【PASS: BIT-IDENTICAL】（20:16 完走、boss1 が cmp + sha256 で直接検証）★**: tight -frames 140000 で両 run clean-exit → **det1.jsonl ≡ det2.jsonl（cmp -s exit 0 / 14983 lines / 5,682,982 bytes / sha256 `32f0972dfc0e...` 一致 / 両 run 1278 entry・7686 event）**。3 次元全て 2-run 同一（init: launch1278 + ram_inputs[46] / PC: fetch7686 / write: flag_w1778 + var_w2162）。**boss1 が worker3 報告を額面にせず /tmp/claude-1000/dgtrace/ を自分で cmp+sha256 して確認**（本 session の status 誤報 3 回の remedy 実行）。
  - **★PASS の scope（honest）★**: trace + 46-capture が **sweep 実行 path で reproducible・hidden 非決定性なし** を証明。★但し【入力表面 全閉は未証明】★= 真の入力集合 = (VM read) ∩ (runtime WRITE)、**store 側 未測定**、**31 vs 1948 の VM-PC 定義も UNCONFIRMED**。次 session: store-side hook（DGLOADS 同機構）で write を tally → load∩store = 真入力を測定で決着。
  - 反映 commit = degimon-f1c **5d8dd7e**。
- **★入力表面の数 = 【VM-PC 定義依存】で未確定（boss1 が worker3 の G6_VMPC_RESULT.txt / HANDOFF_G6 を直読して確定）★**:
  - **狭い定義（core-interp [0x800EC000–0x800F1A00] + stat-getter [0x800F5000–0x800F5800]）= 31 RAM** → ★worker3 の独立検算も 31 = worker2 と EXACT 一致（HANDOFF_G6 L19）★。
  - **広い定義 = 1948 RAM / 208 block**（worker3 G6_VMPC_RESULT.txt L15。0x800A4xxx 等の reader を VM に含めた場合）。
  - ⇒ ★**『31 が過少で 1948 が正しい』ではない。定義が違うだけ。同一定義なら両者一致する。**★（worker2 が一度『私の 31 は過少・1948 が正しい』と報告したのは**過剰譲歩＝5件目の誤り、向きが逆**＝60倍差を見て『大きい方が正・自分が誤』と、なぜ違うか=reader 定義 を確かめず撤回した。boss1 も worker2 の譲歩を worker3 artifact 未読で handoff に relay した＝同型。両者 worker3 直読で訂正。）
  - **★真の未決点は 2 つ★**: ①**どの VM-PC reader 定義が正しいか**（31 か 1948 か = 0x800A4xxx 等を VM とみなすか） ②**各 address が runtime に【書かれる】か**（= 真の入力基準。誰も store 側を測っていない。worker2=image proxy / worker3=image 境界、両者 write 未観測）。
  - **依然 有効な worker2 の誤り**: 「EXE image 内=定数=capture不要」は**未検証 proxy**（image に .data/.bss=runtime state）= §8 未検証 list に追加。
  - **次 session**: store 側 hook で written-address tally + VM-PC 定義確定 + 決定性テスト（46注入 bit-identical = read-side closure の経験的検証）。
- **★push は user 専権。今 session もしていない。★**

---

### memory（今日追加/更新）
feedback_audit_your_own_tool（自分の道具を疑え）/ feedback_correct_conclusion_not_excuse_process / feedback_fabricate_in_incidental_fields / feedback_verify_what_green_asserts（11着+偽BLOCKED）/ feedback_identity_is_not_evidence（identity検証・(A)(B)分離）/ feedback_no_relay_expected_as_observed（進捗も claim）。
