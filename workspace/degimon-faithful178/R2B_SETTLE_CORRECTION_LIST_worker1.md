# R2B settle 解釈 訂正棚卸し list — A/B 確定後に一括適用 — worker1

**date**: 2026-07-20 / worker1 / ★doc-only、訂正候補 list(適用は A/B 確定 + boss1 承認後)★
**契機**: 旧『settle 部=真 BGM』系解釈が『再生中の崩壊状態』へ反転。handoff open item の一括訂正 list 化(boss1 01:27 task2)。★2026-07-20 適用準備完了(worker3 4 wav 検収 + boss1 承認で一括適用)★。
**規律**: 観測(measurement)は不変・解釈(interpretation)のみ訂正。適用条件を各項に明記。捏造禁止=所在不明の旧 claim は「未特定」明示。

**★真因の最終確定(2026-07-20)★**: 崩壊原因は二段反転を経て確定 = SB 上書き(棄却)→ driver KON 停止(中間)→ ★**CPU crash(Data Bus Error、EPC=0x800C9E3C、fire+10.4s、forced-capture artifact)**★。fix=`DG_LATE_INJ 0x801EE184:0:8900`(1 word clean-skip)、Run A 全層 PASS(R2B_FIX_DESIGN §10)。**本 list の「settle=崩壊状態(真 BGM でない)」「collapse=artifact(原盤 arrangement でない)」の訂正方向は真因が何であれ不変=そのまま有効**(崩壊原因が精緻化されただけ、settle が崩壊部・artifact である事実は Run A で最終実証)。C1-C8 全項適用可(下記 §3)。

---

## 0. 全 grep 結果(workspace 全体、2026-07-20)

- ★R2B 固有の settle=真 BGM 系旧 claim は **R2B_BANK_LOAD_RE_worker1.md line 78/131 のみ**★。他の "settle" hit(VISMAP/phase3b/PREREG/handoff)は **別 domain**=対象外。
- ★『3-voice=真 BGM』は共有 doc 内に **独立の active claim として存在しない**★: line 78 の再解釈 marker 自身が唯一の言及。line 78 が参照する「過去 doc(3-voice=真 BGM)」= **共有 workspace に該当ファイルなし**(worker3 notes / transcript / 口頭 claim 起源の可能性)。→ 訂正対象の実体が shared doc に無い=line 78 marker の firm 化のみで足りる(下記 #1)。

---

## 1. 訂正候補 list(適用=A/B 確定後、boss1 承認)

| # | file:line | 旧 claim / 現状記述 | 訂正後(A/B 確定前提) | 種別 | 適用条件 |
|---|---|---|---|---|---|
| C1 | R2B_BANK_LOAD_RE:78 | 「settle 部=崩壊後の姿の**可能性が高い**、訂正は崩壊確定後にまとめて」(再解釈 marker、soft) | 「settle 部=**SB 上書き後の崩壊状態(確定)**。vab_id=2 楽器 VAB が SB(効果音 bank)に上書きされ高域 voice 欠落」= soft→firm | 解釈 firm 化 | 層1(bank bit 差分>0=上書き実証)+層2 PASS |
| C2 | R2B_WAV_DIAGNOSIS:49 | 候補機構(c)「原盤 SEQ arrangement が途中で高音パートを落とす(=musical=忠実)」= H4 併記 | (c)を **v0/v1 で REFUTED**(機構=SB 上書き artifact、musical でない)。(a)voice 取りこぼし系に確定 | H4 枝の否定 | 層1 で SB 上書き確定 |
| C3 | R2B_WAV_DIAGNOSIS:74,78 | 「artifact vs 原盤 arrangement の最終判別は本診断単独では不能」「この分岐が原因確定の鍵」 | 「分岐=**artifact(SB 上書き)側に確定**(R2B_BANK_LOAD_RE 機構 + A/B 実証)」 | 分岐の resolve | 層1+層2+A/B(SB 抑止で collapse 消失) |
| C4 | R2B_WAV_DIAGNOSIS:69,73 | v2「軽微(高域比不変=別要因/**musical?**)」 | v2 の再解釈=**要 A/B 突合**(v2 は centroid 低下だが高域比不変=部分上書き or 別 bank layout の可能性。A/B で v2 の SB 上書き有無を確認してから firm 化。musical 断定は保留) | 解釈保留→A/B 依存 | v2 の層1 bank bit 測定 |
| C5 | R2B_WAV_DIAGNOSIS:70,72 | v3「clean」+「uniform-systematic でない」 | 観測(clean)=**不変**。解釈に機構注記追加: 「v3=当該 run で SB が音楽域を上書きしなかった(run-context 依存の裏付け)」。SB 上書きは run/context 依存ゆえ v3 clean は矛盾でなく機構整合 | 解釈への機構注記(観測は保持) | A/B(SB 抑止=全 variant clean 化の実証) |

---

## 2. v0 caveat(低域/短尺帰属)の再解釈可否 = ★所在未特定(boss1 確認要)★

- boss1 01:27 task2 で「v0 caveat(低域/短尺帰属)の再解釈可否も含めて」指示 → **該当する『v0 の低域/短尺帰属 caveat』テキストを共有 doc 全 grep で特定できず**。
- 発見した v0 記述(参考): R2B_WAV_DIAGNOSIS §4=v0 は 4 variant 中最重(75% drop@11s、高域 29%→0%) / V4_USERLIVE_PACKAGE=v0 wav provision(sha ea50aa8f)・variant0 は full-chain 未 exercise(P1 で asset 検証済)。いずれも「低域/短尺帰属」の caveat ではない。
- ★honest gap: 当該 caveat の所在(file:line or worker3 doc/transcript)を boss1 に確認。所在判明後に本 §へ再解釈可否を記入★。
- 暫定見立て(所在不明ゆえ推論・未適用): もし v0 caveat が「v0 の重い collapse を低域偏重/短尺 capture に帰属」した旧解釈なら、SB 上書き機構確定により **artifact(SB 上書き)へ再帰属**が妥当(C2/C3 と同型)。但し所在確認前は適用しない。

---

## 2-bis. ★対策B provenance = settle=真 BGM 反転 claim の現物(remake repo)★(2026-07-20 発見、boss1 要請3 承認)

★§0 で「shared workspace に該当ファイルなし」とした『settle=真 BGM』claim の**現物を remake repo 側で発見**★(worker1 V5 package 作成中の現 provision 計測)。

### 現物 = f1b/f1c の scene33 audio provenance + 関連 commit
- **`unity/Assets/StreamingAssets/audio/scene33_v{0-3}.provenance.txt`**(commit 1519bf0 "R2'b re-capture — settle window版")= ★対策B★:
  - `method_change`: 「旧 R2'b(trim3s=遷移含み)は fire 直後の 24-voice burst(scene28 残留)混入で高域 collapse(user『途中で重くなる』FAIL)。本版=fire+~20s 以降(residual 減衰後)の settled loop を採用」
  - `oracle`: 「VERDICT=PASS(onset 無/高域比 late/early=0.72)」
  - = ★診断が反転★: fire 直後の高域(=clean 音楽)を「ノイズ burst」と誤認し、settle 部(=SB 上書き後の崩壊 timbre)を「真 BGM」として採用。
- **R2B_DISCRIMINATOR**(provenance 引用: 「三重接地: settle_clean PASS/withtrans FAIL/voice-count 24→3、H-art 確定」)= 対策B の根拠 doc。これも反転診断。
- **commit 1519bf0**(settle window 版 4 wav 差替)= 反転診断の実装。

### 実測反証(worker1、2026-07-20、r2b_oracle v2)
- 対策B v0/v1 = **全 95s centroid ~880-1150Hz 一様**(onset ゼロ、high>2k 0.8-2.5%)= R2B_WAV_DIAGNOSIS の「崩壊後 ~900Hz」水準に全区間張り付き=**崩壊 timbre そのもの**を採用。
- ★対策B の r2b_oracle(v1)PASS は **false-PASS**★: v1 は「clip 内 collapse onset / late-early 比」=相対量のみ判定。post-collapse steady state だけ切出した settle window は onset 無し+比≈1 で PASS するが、絶対水準は一様崩壊。→ **r2b_oracle v2 に絶対 floor(c)追加で対策B v0/v1 を FAIL 化**(negative control 確認済、floor 較正=独立 ground-truth 原 clean early 2301Hz/5.8%、被検体でなく=循環回避)。
- ∴ 対策B は「clean な早期高域部を捨て、SB 上書き崩壊部を採用」= 反転が実測確定([[feedback_verify_the_oracle_not_just_the_match]] の模範=oracle 自体の盲点を計測で暴いた)。

### 訂正候補(A/B 確定=案X 済ゆえ適用可、boss1 承認 + provision 差替 gate①承認と連動)
| # | 対象 | 訂正 | 適用条件 |
|---|---|---|---|
| C6 | scene33_v{0-3}.provenance.txt(対策B) | 案X provenance へ差替: 真因=SB(効果音 bank)上書き / fix=capture 時 SB load skip(案X) / 全長 clean capture(settle 切出し不要) / oracle=v2(絶対 floor 付) | 案X 4本 provision(gate① 承認済、差替 HOLD 中)着信 |
| C7 | R2B_DISCRIMINATOR(反転診断 doc) | 「24-voice burst=artifact / settle=clean」の結論を **REFUTED**(真機構=SB 上書き)へ。voice-count 24→3 は SB 上書きで楽器 voice が落ちた結果であって settle=clean の証拠でない、と再解釈 | 案X provision + boss1 承認 |
| C8 | r2b_oracle.py(v1) | v1 は uniform 崩壊に false-PASS の限界を doc 明記 + v2(絶対 floor)を正本化。v1 は relative-only の補助として残置 or deprecate | v2 検収 PASS(済)+ boss1 承認 |

---

## 3. ★適用済(2026-07-20、PRESIDENT 承認 11:56、一括適用完了)★

真因は最終確定(CPU crash)まで精緻化されたが、各訂正の「解釈方向」は不変で全項適用:

| # | 対象 | 適用状況 |
|---|---|---|
| C1 | R2B_BANK_LOAD_RE:78 + doc 冒頭 | ★適用済★: 訂正 banner 挿入(SB 上書き仮説棄却→真因 CPU crash、settle=崩壊部の事実は不変・Run A 実証)。SB 機構記述は棄却済 trail として保持 |
| C2/C3 | R2B_WAV_DIAGNOSIS §2(c)/§4 分岐 | ★適用済★: 訂正 banner 挿入((c)musical=REFUTED、artifact 側確定=CPU crash) |
| C4/C5 | R2B_WAV_DIAGNOSIS §4 v2/v3 | ★適用済★: 同 banner(観測不変、解釈=crash-class artifact へ更新。v2/v3=非 native selector 強制 artifact) |
| C8 | r2b_oracle.py | ★適用済★: DEPRECATED 注記(v2=正本、v1 は uniform-collapse false-PASS 限界) |
| C6 | scene33_v{0-3}.provenance.txt(remake repo) | ★worker2/worker3 provision で反映★(v1=scene33_fixed_v1.provenance.txt 済、v0/v2/v3=(a)採取後)。crash-fix diagnosis へ差替=provision owner 担当 |
| C7 | R2B_DISCRIMINATOR(worker3 doc、共有 workspace 外) | ★worker3 へ flag★: 「24-voice burst=artifact/settle=clean」結論は REFUTED(真因=crash)。worker3 doc ゆえ worker3 が訂正 |

- 観測値は全て不変、解釈のみ訂正=[[feedback_correction_is_not_automatically_improvement]] 遵守(訂正版も Run A 実測で裏取り済)。
- ★v0 caveat(§2、旧 handoff『低域/短尺帰属』)★: 所在は共有 doc に未特定のまま(honest)。但し v0 の実態は判別で確定(SEQ 密度一様 CV=0.08=短尺でない、劣化=注入 artifact)ゆえ「短尺帰属」説も REFUTE 済。
