# R2B FIX 設計 draft — SB 上書きによる scene33 音楽崩壊の対策 — worker1

**date**: 2026-07-20 / worker1 / ★doc-only、対策 draft(premise 分岐併記、worker3 3点 dump が裁定するまで両論)★
**根拠**: R2B_BANK_LOAD_RE §7-11(SB 上書き機構)+ R2B_WAV_DIAGNOSIS(症状 signature)+ worker3 runtime(SB overwrite/vab-table dump)。
**規律**: 観測/推論/未確定。忠実性(原盤機構準拠)/OFF-inert/実装点/検収を各案に明記。draft=裁定材料、実装は worker3 probe。

---

## 0. 確定した機構(R2B_BANK_LOAD_RE 統合)

- 症状「途中で重くなる」= 高域 voice collapse(centroid 2600→930Hz@t≈12-14s、R2B_WAV_DIAGNOSIS)= field 音楽 SEQ(vab_id=2)の楽器 VAB が SPU 上で上書き破壊。
- 上書き主 = ★SB(効果音 bank、248KB)を SsVabOpenHead 動的 alloc(0x800a4444→heap)で SPU に載せる際、resident 音楽 VAB 領域(0x1D000/0x3B810)を空き扱いして上書き★(worker3 SB 実測 + §7 heap 不整合)。
- SB load trigger = ★家族2 = scene dispatch 0x80105be4 内 0x80105F54(0x66 fire path)★(worker3 α/β 確定待ち、家族1 vs_rel は 0-hit で除外)。
- fire 自身 = FAALL VAB header を SsVabOpenHead register(0x800cf0e4→0x800a49a4、§11)= fire が vab table/heap を触る。

---

## 1. premise 分岐 P'(malloc-level 再構成、2026-07-20 boss1: 不整合 site=SPU malloc 簿記 0x8013F1A8)

★worker3 3点 dump(vab table 0x80125e18)= 完全不変+vab_id=2 登録済+16/16 有効 → vab table は idempotent(0x800a4444 search が既存 entry 再利用、§11)。∴ 不整合 site は vab table でなく **SPU malloc 簿記 0x8013F1A8**(SpuMalloc iteration 0x800b45b4 が index=vab_id&0xff で走査する word 配列 + pointer 0x8013F47C + flag 0x8013F488 &0x10)★。SB alloc が 0x3B810(ESALL 占有域)を取得=malloc 簿記が resident bank の占有を反映していない。

### premise 裁定 = worker3 の malloc 簿記 3点 dump(0x8013F1A8-0x8013F4A0 + 0x80144ac0-e0、pre-fire/post-fire/SB-load)

★分岐点 = pre-fire 時、SPU heap free-list / vab table に **音楽 bank(vab_id=2)の登録・SPU 予約が整合しているか**★:

### P-a': fire path 自身が malloc 簿記を摂動(pre-fire に音楽 VAB body resident + malloc 簿記に占有記録有 だが、fire の register/alloc chain が簿記を変える)
- 想定: fire(0x800cf0e4→0x800a49a4 header register + 音楽 body 転送 chain)が SpuMalloc/Free で簿記 0x8013F1A8 を操作し、音楽域の占有記録を解放/上書き → 直後の SB alloc がそこを取得。
- ★fix 標的 = fire 内 alloc chain(音楽域を解放させない/SB alloc を音楽域外へ)★。

### P-b': DG_RESTORE 起点で malloc 簿記が resident bank と不整合(起点 artifact)
- 想定: DG_RESTORE(savestate 直挿し)が SPU RAM の bytes(音楽 body resident)は復元するが、main RAM の malloc 簿記 0x8013F1A8(占有記録)を音楽 bank と整合させない → 簿記が音楽域を「空き」と認識 → SB alloc が奪う。
- ★fix 標的 = capture harness 起点(savestate 復元時に malloc 簿記へ音楽 bank 占有を注入/整合)★。

★裁定 = worker3 の malloc 簿記 0x8013F1A8 dump 3点★: pre-fire に音楽 bank 域(0x1D000/0x3B810)が簿記上 used 記録(有→P-a'方向: fire が壊す / 無→P-b'方向: 起点で欠落)。SB-load 前後で簿記がどう変わるか(SB が音楽 slot を上書き取得する瞬間)。

---

## 2. 対策案比較(各 premise 分岐で)

### 案(i) 登録注入(heap free-list / vab table に音楽 bank を明示登録)
- 内容: fire 前に音楽 bank(FAALL/VLALL/VBALL/ESALL、SPU 0x1D000-0x43000)を SsVabOpenHead 相当で heap free-list に「予約済」登録 → SB alloc が空き 0x43000+ へ回る。
- 忠実性: △(原盤は field-init で自然登録=登録状態自体は原盤同等だが、注入手段は非原盤 API 呼出)。
- OFF-inert: ○(flag-gate で通常 build 不変可)。
- 実装点: P-a'=fire 前/中 probe(alloc chain 補正)/ P-b'=capture harness(簿記注入)。
- 検収: SB-load 後の音楽 bank 域(0x1D000/0x3B810)bit 不変 + r2b_oracle PASS + user 耳。

### 案(ii) natural init 列先行実行(field-init の alloc 列を fire 前に正順で走らせる)
- 内容: fire 前に field/sound-init(音楽 VAB 転送を含む natural な alloc 順)を実行 → heap free-list を natural 相当に積む → 以降 SB load も natural と同挙動。
- 忠実性: ◎(原盤の init 順そのものを再現=最も原盤機構準拠)。
- OFF-inert: ○(capture 専用 path)。
- 実装点: capture harness(fire 前に natural init sequence)。natural の音楽 VAB 転送 site(§9/§10 の field-init 経路)を正順実行。
- 検収: 同上 + natural dump との heap 一致。
- ★課題★: natural init 列の完全同定(音楽 VAB body 転送 site + 順序)= §10 honest gap(継続 RE)。worker3 runtime で natural の alloc 順を採取するのが最短。

### 案(iii) SB load 抑止(post-fire / capture 中に SB load を skip)
- 内容: capture 中、家族2 SB load(0x80108c00)or dispatch の SB-load section(0x80105F54)を no-op 化。
- 忠実性: ✕(SB=効果音は原盤機構、抑止は原盤挙動改変)。但し **音楽 capture 目的では SB 不要**ゆえ capture 専用なら許容余地。
- OFF-inert: ○(capture flag-gate)。
- 実装点: capture harness(SB load をhook で skip)。
- 検収: 音楽 bank 域 bit 不変(SB が来ない)+ r2b_oracle PASS。★但し「原盤で鳴るはずの SB が capture に無い」= capture の忠実性は音楽のみに限定と明示要★。

---

### 案(iii') capture-only SB-load 抑止(DG_flag gate、OFF-inert)★2026-07-20 boss1 steer で主候補に昇格★
- 内容: DG capture flag ON 時のみ、家族2 SB load(dispatch 0x80105F54 の jal 0x80108c00)を skip。通常 build は flag OFF で完全不変。
- ★忠実性の適用面 再評価(旧(iii)『忠実性低』評価の訂正)★: 旧評価は「SB=原盤機構の抑止=非忠実」としたが、**適用面を取り違えていた**。本 fix の**納品物 = scene33 音楽 audio 素材**(+ 4層検収 + user 耳 gate)であり、capture harness は元々 DG_RESTORE 直挿しの**非 natural 文脈**。∴ 忠実性の判定基準は「原盤ゲーム進行の逐一再現」ではなく **「捕獲した音楽素材が原盤 SEQ を忠実に鳴らすか(=capture 正しさ)」**。SB は効果音であり音楽素材には不要 → capture 時に SB を抑止しても**音楽素材の忠実性は損なわれない**(むしろ SB 上書きを除去して音楽 SEQ を原盤通り鳴らす=素材忠実性は向上)。
- OFF-inert: ◎(DG_flag gate、通常 build bit 不変)。
- 実装点(patch 安全性 静的確認済、2026-07-20): 案X=0x80105F54 の jal を flag-gate skip(最局所) / 案Y=0x80108c00 内 0x80108c20(jal 0x80108668)のみ skip し gp-0x77c4=-1 cache-invalidate は保持(外科的)。**(a) v0 戻り値不使用=安全確定**(0x80105F5C=move s0,zero 無条件、後続 loop は v0 非依存)。**(b) 残1点=案X は cache-invalidate 欠落で stale bank-id memo(gp-0x77c4)誤抑止の理論 risk**(reader 0x800cfd2c/0x80108cf0=最終 load bank id cache)→ 案Y で回避 or worker3 runtime 確認。
- 検収: 音楽 bank 域(0x1D000/0x3B810)bit 不変(SB が来ない)+ r2b_oracle PASS + user 耳。★「原盤で鳴るはずの SB が capture に無い」= capture 忠実性は**音楽素材に限定**と明示(納品物定義と整合)★。

---

## 3. 現時点の暫定推奨(2026-07-20 boss1 steer 反映)

★主線 = 案(iii')capture-only SB-load 抑止(fix 十分性 A/B)★:
- 理由: (1) 機構 close(真 SPU dest 簿記の静的同定)を待たず**即 A/B 実証可能**(SB を抑止すれば音楽 bank 上書きが物理的に発生しない=症状消失を層1 oracle で直接検証)。(2) 忠実性の適用面(上記 (iii') 再評価)= 納品物は音楽素材ゆえ SB 抑止は素材忠実性を損なわない。(3) patch 安全性 静的確認済((a)安全確定/(b)残1点は案Y or runtime で解消)。
- 手順: 案(iii')で A/B(SB 抑止 ON/OFF)を capture → 層1(音楽 bank bit 不変)+ 層2(r2b_oracle PASS)+ 層4(user 耳)。PASS なら gate① 上申。

★本命(機構 close 後)= 案(ii)natural init 列先行実行★(A/B で機構確証後の最終形として併記維持):
- 理由: 原盤は field-entry で音楽 VAB を natural に heap 登録 → その後 scene fire。capture がこの natural 順を再現すれば、heap free-list が原盤同等 → SB load も原盤同挙動(音楽域を奪わない)= 機構を改変せず順序を原盤に合わせる=進行忠実性も保つ最終形。
- 課題(honest): natural init 列(音楽 VAB body 転送 site + 順序)の完全同定が前提 = §10 honest gap。worker3 natural run 採取が最短。案(ii)は SB も鳴る=進行忠実だが、納品物が音楽素材である限り (iii') で十分。
- 位置づけ: (iii')=**十分性の主線**(即実証・素材忠実)、(ii)=**機構完全 close 後の理想形**(進行忠実まで含む)。案(i)登録注入=natural 列同定が難な場合の次善。

---

## 4. 検収方法(4層 oracle、proxy でなく症状 signature + 崩壊機械検出)

★fix 検収=以下 4層(機械 2 + 直接再生 1 + 人 1)。r2b_oracle 単独は遷移症状のみ(handoff 既知限界)ゆえ bank 崩壊の機械 oracle を新設★:

### 層1(新設): ★SPU bank 崩壊ゼロ oracle(機械、崩壊の直接検出)★
- 手順: capture run 中に **(a)fire 直後(音楽 SEQ 再生開始時)の SPU 音楽 bank 域 snapshot** と **(b)capture 終端(or SB-load 後)の同域**を dump し **bit 比較**。
- 対象域: FAALL 0x1D000-0x2B000 / VLALL 0x2D000-0x33000 / VBALL 0x33000-0x3D000 / ESALL 0x3D000-0x43000(worker3 実測 layout)。
- PASS 基準: **(a)==(b) bit 一致(上書きゼロ)**。差分>0=崩壊(現状 forced=0x3B810 で SB 差分=FAIL)。
- 実装: worker3 の SPU dump 2点(fire 直後/終端)+ bit diff。=★『音楽 bank が再生中に破壊されない』の直接 oracle(症状の根本を SPU-side で検出、wav 化前に判定可)★。

### 層2: r2b_oracle.py(機械、wav signature)
- 対策後 capture wav が症状 signature ゼロ(centroid collapse 無/高域比 late/early≥0.5、R2B_WAV_DIAGNOSIS §3)。層1(SPU)が上流、層2(wav)が下流=二重確認。

### 層3: ゲーム外直接再生(機械/人、asset 単体)
- capture wav を aplay 等で直接再生し全長聴取(遷移文脈なしの素材確認)。

### 層4: ★user 実聴(完成 claim、凍結解除の終端)★
- 「途中で重くなる」解消を user 耳で確認。= 完成判定の唯一の終端(次元分離)。

### 補: OFF-inert(全層の前提)
- 対策 flag 無で通常 build bit 不変(P-a' fire 内 fix / P-b' harness fix いずれも flag-gate)。

---

## 5. honest gap / 次段

- premise P'(a'/b')裁定 = worker3 malloc 簿記 3点 dump(★0x8013F1A8 index table + 0x8013F47C pointer + 0x8013F488 flag、+ 0x80144ac0-e0★)。
- ★SPU malloc 簿記 = 0x8013F1A8 特定済(SpuMalloc iteration 0x800b45b4、index=vab_id&0xff の word 配列)。真 count/stride/SpuInitMalloc 初期化 site + word slot 先 struct 意味 = 継続(worker3 pointer-chase dump 突合)★。0x800b49f4 は size helper(誤同定訂正済)。
- natural init 列(音楽 VAB body 転送 site + vab_id 割当順)= §10 honest gap、worker3 natural run 採取が最短。
- 家族2 α 確定(0x80108C00 直上 ra=0x80105F5C)= worker3。
- ★SPU malloc 簿記 init = 関数 0x800b43bc(0x8013F47C 系 store 群含む)← caller 0x80104584 / 0x80116f98(boot/sound init 層)★。P-b' 検証点=DG_RESTORE 起点がこの init(0x80116f98 系)を通るか(通らない→簿記が savestate 値のまま=音楽占有欠落なら P-b' 確定)=worker3 runtime。
- ★案(ii)実装点 受け皿(worker3 natural run VAB loader 呼出順 log 待ち)★: capture harness が fire 前に走らせる列 = [natural init の SsVabOpenHead/SsVabTransBody 呼出を {関数 addr, 引数(vab_id/descriptor/SPU addr), 順序} で列挙]。log 到着後、本 §に確定表を挿入 → worker3 probe が同順再現。
- ★副線 dest RE 打切り所見(2026-07-20、姿勢則#4=2回外し→計測委譲)★: 真 SPU transfer_addr write(SPU_ADDR reg 0x1F801DA6、0x3B810>>3=0x7702 相当を積む式)の静的所在を 2 手法で scan=**両方0件**: (1) lui 0x1f80 + sh 0x1da0-0x1dbe(immediate-base)=0件、(2) libspu 域 0x800b4000-8000 の srl,3(8byte 単位変換 signature)=0件。∴ **SPU transfer 実 write は indirect/computed base + 非標準単位変換**(boss1 の pointer-constant scan 0件と整合)=静的同定不能を再確認。→ ★worker3 の 0x1F801DA6 hardware watchpoint が唯一の接地路★(runtime 捕獲 PC + 積値 を突合して機構 close)。static 側の寄与はここまで=honest gap 明示。
- ★本 draft は両分岐併記=worker3 malloc 簿記 dump 後に単一案へ収束させ、boss1 裁定 → 実装(worker3 probe)→ 4層 oracle(§4)→ user 耳。gate① 上申は premise 裁定 + 単一案収束後★。

---

## 6. 案X/Y 比較 + boss1 裁定 log(2026-07-20、fix 十分性 A/B)

### patch 安全性 静的確認(worker1、boss1 検収 PASS = gp-0x77c4 access 全6件 sw×4/lw×2 と worker1 の reader 2箇所が完全一致=見逃しなし)

| 項目 | 案X(最局所) | 案Y(外科的) |
|---|---|---|
| patch 点 | 0x80105F54 の jal 0x80108c00 を flag-gate skip | 0x80108c00 内 0x80108c20(jal 0x80108668)のみ flag-gate skip |
| SB SPU load 除去 | ○ | ○ |
| gp-0x77c4=-1 cache-invalidate | ✕(skip される) | ○(保持) |
| v0 戻り値 | 不使用=安全(0x80105F5C=move s0,zero 無条件、後続 loop v0 非依存) | 同左(0x80108c00 は依然 v0=8 返す) |
| 残 risk | stale bank-id memo 誤抑止の理論 risk(reader 0x800cfd2c/0x80108cf0=最終 load bank id cache) | なし(cache 意味保持) |
| 影響範囲 | dispatch 1点 | 0x80108c00 の全 caller(flag gate 必須) |

### ★boss1 裁定(2026-07-20 01:15)= 案X で即実行 GO★
- 根拠: build 済を活かす + stale-cache risk は**監視 BP で実測判定**(2 reader entry 0x800cfd2c/0x80108cf0 に BP、要求 id / 現値 gp-0x77c4 / 分岐成否 を log)。
- 分岐 logic: ★誤抑止(false『既 load 済』で本来必要な reload を skip)発生ゼロ → 案X のまま最終版 / 発生あり → fix 最終版を案Y(cache-invalidate 保持)へ差し替え★。
- worker3 へ GO 発行済(boss1)。A/B(SB 抑止 flag ON/OFF)capture 実行中。

### A/B 結果欄(worker3 実測、2026-07-20 01:33 着信=★全 PASS★)
| 測定 | ON(SB 抑止=案X) | OFF(現状) | 判定 |
|---|---|---|---|
| 層1: 音楽 bank 域 bit(fire 直後 vs 終端) | ★SPUWRITE-3B=0、0x3B810 帯=ESALL 残存、FAALL intact★ | 差分>0=SB 上書き(FAIL) | ★PASS(上書きゼロ)★ |
| 層2: r2b_oracle.py(centroid collapse/高域比) | ★VERDICT PASS、高域比 0.96★ | v1=FAIL(高域比≈0.2) | ★PASS★ |
| 監視 BP: gp-0x77c4 誤抑止 回数 | ★0 hit★ | — | ★誤抑止ゼロ=案X 確定(案Y 不要)★ |
| 層4: user 耳 | (re-capture 4本 + V5 package で最終) | 「途中で重くなる」 | user 起床後 |

→ ★層1(SPU bank 上書きゼロ)+ 層2(oracle PASS 高域比 0.96)+ 監視 BP 誤抑止 0 hit = **案X で単一推奨確定・案Y 不要**★。cache-invalidate 欠落の理論 risk は実測で不発(誤抑止 0)=案X の局所 patch で十分。gate① 上申文=boss1 送信済(BOSS1_GATE1_DRAFT_sbskip.md + A/B 実測値)。残=re-capture 4本 provision(gate① 承認待ち)+ user 耳(層4)。

---

## 7. 単一推奨(確定、2026-07-20)

★確定 fix = 案X: capture 時 DG flag ON で 0x80105F54 の jal 0x80108c00(家族2 SB load)を skip★
- 機構: SB(効果音 bank)load を capture 中のみ抑止 → 音楽 bank 域(FAALL/ESALL、0x1D000-0x43000)が SB に上書きされない → vab_id=2 音楽 SEQ の楽器 VAB が保全 → 高域 voice collapse 消失。
- 実証: A/B 全 PASS(§6)。層1 で SPU 上書き物理ゼロ、層2 で wav signature 正常(高域比 0.96 vs FAIL 時 0.2)、監視 BP で cache 誤抑止ゼロ(案Y 不要)。
- OFF-inert: DG capture flag OFF で通常 build bit 不変(patch は 1 点 flag-gate)。
- 忠実性: 納品物=音楽素材ゆえ SB 抑止は素材忠実性を損なわない(§2 案(iii') 再評価)。SB は効果音=音楽 capture に不要。
- 残: (1) re-capture 4本(worker3 実行中)の provision=gate① 承認待ち / (2) user 耳(層4)=完成 claim 凍結解除の終端。
- ★本命(進行忠実まで含む理想形)= 案(ii)natural init 列先行は機構完全 close(SPU dest 簿記の runtime 同定=worker3 watchpoint)後の将来 work として併記維持。現納品(音楽素材)には案X で十分★。

### gate① 裁定記録(2026-07-20)
- ★PRESIDENT 裁定(01:45、boss1 経由 01:47)= **gate① 全5項承認**★。gate① 上申文=boss1 送信済(BOSS1_GATE1_DRAFT_sbskip.md + A/B 実測値)。
- PRESIDENT 注記: (1) **dest 算出式=honest gap 維持で可**(A/B 担保の整理に同意、SPU dest 簿記の runtime 同定は将来 work)。(2) §12 layer relabel 記録=**将来の SPU RE 資産**と評価。(3) doc path=workspace/degimon-faithful178/(f1c 表記は誤り、修正済)。
- ★provision 差替=gate① 承認済だが worker3 に **差替 HOLD 発令中**★(2026-07-20 02:09): 現 provision(対策B settle 版)が崩壊部採用+r2b_oracle v1 false-PASS と判明(§8)。案X 4本 re-capture + v2 oracle 検収 後に差替。
- 残(user 起床後 PRESIDENT 代行起動): 案X 4本 provision(v2 oracle PASS + 絶対水準=原 clean 相当を確認)→ V5 package(PRESIDENT 即起動できる完成形)→ user 耳(層4)=完成 claim 凍結解除の終端。

---

## 8. oracle v2(絶対 floor)+ 対策B false-PASS 発見(2026-07-20)

★V5 基礎確定前に現 provision を計測し、r2b_oracle v1 の false-PASS を発見(oracle 自体の検証、[[feedback_verify_the_oracle_not_just_the_match]])★:
- **現 provision(対策B settle-window 版、commit 1519bf0)= 崩壊部採用**: v0/v1 は全 95s centroid ~880-1150Hz 一様(onset ゼロ)= SB 上書き後の崩壊 timbre そのもの。fire 直後の clean 早期高域を「24-voice burst ノイズ」と誤認して捨て、settle 部を「真 BGM」と誤採用=診断反転(settle 訂正 list §2-bis C6-C8)。
- **r2b_oracle v1 の盲点**: (a)(b) は「clip 内の collapse onset / late-early 比」=相対量。post-collapse steady state だけの clip は onset 無し+比≈1 で false-PASS。対策B v1 が実例。
- **r2b_oracle v2 = 絶対 floor(c)追加**(workspace/r2b_oracle_v2.py): clip 中の最良 3s 窓(alignment 非依存)の centroid≥1800Hz かつ high>2k≥3.0%。floor 較正=**独立 ground-truth 原 clean early**(被検体=案X でなく、循環回避=boss1 訂正遵守。原 clean=git 352e9b0 復元、content sha 4/4 一致)。原 clean 最小 2301Hz/5.8% と対策B 920Hz/0.8% の間に floor。
- **negative control PASS**: 対策B v0/v1 → v2 で VERDICT FAIL(false-PASS 封鎖)。対策B v2/v3・原 clean v2/v3 → PASS(bright 保持)。原 v0/v1 → (c)PASS だが (a)(b)FAIL(実崩壊)=正しい帰属。∴ (c) は uniform 崩壊のみ捕捉、(a)(b) を壊さない。
- ★案X 4本(被検体)の受入基準 = **v2 oracle 全 PASS(絶対 floor 含む)+ 絶対水準が原 clean early(2300-3160Hz/5.8-29%)相当**★。worker3 の案X 絶対水準計測と突合 → V5 基礎確定。

---

## 9. ★真因確定: CPU crash(Data Bus Error)= DG_RESTORE forced-fire artifact(2026-07-20 worker3 verdict)★

### 9-0. 機構の二段反転(SB-overwrite → driver KON停止 → CPU crash が真ROOT)
- 反転1: worker3 skip版でも+13s暗化残存 → **案X(SB-skip)supersede**(SB上書きは無相関)。
- 反転2: 静的SEQ parse+voice-level → 「driver KON停止@+10.4s」を(b)として特定。
- ★真ROOT(worker3 verdict run)= **CPU crash: Excode=7 Data Bus Error / EPC=0x800C9E3C / fire+10.4-11.5s** → BIOS例外spin → SPU自律drain が「暗化」の正体★。**A/B/C(driver KON停止機構の3仮説)は全REFUTED**: KON停止はcrashでCPU halt→SEQ tick非実行の【結果】であって、driver内部のcount/callback/decode停止ではない。
- ★skip有無両方で同一crash=DG_RESTORE forced-fireのstate不整合が誘発するcapture artifact確定。remake/原盤とも無罪★(§9-2 A分岐のharness-artifact筋は本質的に的中、機構はinitでなくcrash)。

### 9-1. crash機構(静的解剖、R2B_SEQ_DRIVER_TICK_MAP 系と別=汎用parser)
- faulting fn = **0x800c9cbc**(汎用 halfword-blob parser、97 caller、sound-driver caller ゼロ=SEQ tick本体でない)。EPC=+96 insn。
- faulting命令: `move v0,s2; addiu s2,v0,2; lh v0,(v0)`(0x800c9e34-3c)= halfword cursor読取で **s2=wild addr → Data Bus Error**。
- cursor: s2 = **P + [P+0]**(P=[sp+0x28]、0x800c9d38)、末尾 [s1+0x14] へ write-back(persist)。s1=出力state struct。
- ∴ crash = P/s1/[P+0] のいずれかが壊れ s2 が wild。**forced DG_RESTORE(scene28常駐+scene33強制fire、scene33 full-loadなし)が parser の参照する blob(scene33 script/actor等)を未load/stale放置** → parserが該当event到達(~+10.4s周期)でwild読取、が最有力(scene33 blob未load説、boss1固着)。
- ★caller確定=worker3 fault-time値(ra+s2/P/[P+0]/s1+stack窓)★。着信後、当該1 callerのP/s1 setupを静的traceで「DG_RESTOREの欠落state」を特定。

### 9-2. ★fix方向(2分岐、worker3 caller確定後に単一収束)★

**方向A: natural navigation(推奨筋、最忠実)**
- 内容: capture起点を DG_RESTORE forced-fire でなく、**natural にscene33へ到達**(scene28→scene33の正規遷移で full scene-load を経る)→ parser が参照する blob が正しく load済 → wild なし → crash なし。
- 忠実性: ◎(原盤の正規経路そのもの=state不整合が原理的に発生しない)。
- 課題: natural navigation の到達手段(V4系のnavigation infra、NPC/event trigger)。worker3のcapture harnessがforced-fire依存の度合い次第。
- 検収: capture全長でcrashゼロ(EPC 0x800C9E3C不到達)+KON write継続+v2 oracle絶対floor PASS+user耳。

**方向B: state是正(次善、forced維持)**
- 内容: forced DG_RESTORE を維持しつつ、crash前に **欠落state(scene33 blob/P構造)を正しく設定**(worker3特定の欠落fieldをharnessで注入)。
- 忠実性: △(forced文脈のpatch、but 結果の音は正しいSEQ全長render)。
- 課題: 欠落stateの完全同定(1個のwild pointerの背後に他の未初期化stateがある risk=[[feedback_correction_is_not_automatically_improvement]])。
- 検収: 同上。

- ★単一推奨=worker3 caller確定+欠落state範囲判明後★。原則: 欠落stateが1点local→B可、広範/連鎖→A(natural navigation)が抜本。scene33 blob全体が未loadなら A一択。
- ★SB-skip(旧案X)の最終処遇★: **方向A採用なら不要**(natural navigationでSBも正規に鳴る=音楽素材にSB混入するが原盤同様、除去は音楽単体納品時のみ任意)。**方向B採用なら任意hygiene**(forced文脈でSB上書きは崩壊と無相関だが、音楽素材の純度目的でDG flag gate skipを付けても可=必須でない)。いずれも最終版に採否を明記。

### 9-3. 共通(検収・原則)
- 検収4層更新: **層0(新・最上流)=capture全長でcrashゼロ(EPC 0x800C9E3C不到達 / Excode例外ゼロ)** → 層1=KON write全長継続 → 層2=v2 oracle(絶対floor) → 層4=user耳。crashゼロが根本oracle。
- ★案X(SB-skip)/対策B(settle)は真因(crash)に非対応=破棄★。gate①(SB-skip)再上申は撤回、crash-fix版で再設計。
- OFF-inert必須(DG flag gate)。genuine gameplay不変(crashはforced固有ゆえ通常build無関係)。
- fix確定 = worker3 caller/欠落state → 方向A/B単一収束 → boss1裁定 → 実装 → 層0-4検収 → user耳 → gate①再上申。

---

## 10. ★B案確定 + injection {offset,値} 機構完全解明(2026-07-20)★

### 10-0. 裁定: B案採用(boss1 07:56)
- worker3 A案(natural nav)probe = blocker(sweep 非決定性で (33,x) 発火ゼロ + field-nav 未実装 = hidden-input 問題)。
- ★B案採用★: 機構最終証明 + clean 採取を 1 手同時達成。音声は SEQ+VAB 由来ゆえ注入で歪む経路なし(forced でも rendered music は同一 data)。worker3 = DG_RESTORE_INJ(byte/halfword 注入、build 不要)。

### 10-1. crash 機構(静的完全解明、worker3 bit-pattern と完全一致)
- crash caller = **btl_rel.bin+0x99D4**(battle overlay、boss1 byte-proof)。`jal 0x800c9cbc`(a0=blob 0x8016B374, a1=cmd 0x23/0x24)。btl_rel fn +0x9958: cmd = (a2&1)==0 & [s0+0x10]/5<[s0+0x14] ? 0x24 : 0x23。
- parser 0x800c9cbc: **P = [blob+8] = [0x8016B37C] = 0x801EE0F4**。**s2(cursor) = P + [P + cmd*4]**(cmd=0x24 → offset field [P+0x90])。s2 = init(この式)+ 2進 のみ(in-fn recompose なし)。
- ★fault: [P+0x90]=0xFED20000 → s2 = 0x801EE0F4+0xFED20000 = 0x7EF0E0F4(32bit trunc) → `lh (s2)` = Data Bus Error★。lower 0xE0F4=P保存(offset下位0x0000)、0x801E+0xFED2=0x7EF0 = worker3 bit-pattern 完全一致。

### 10-2. ★injection {offset, 値}(確定)★
- **injection 座標** = P+0x90 = **0x801EE184**(= [[0x8016B37C]]+0x90、P が run 間で変動する場合は runtime dereference)。現 garbage=0xFED20000。
- **値 option (1) clean-skip = [0x801EE184] ← 0x00000000 [推奨]**: parser 0x800c9d0c `beqz([P+cmd*4]==0 → 0x800ca048 exit)` で s2 読取前に return = crash 完全回避。cmd0x24 = battle actor event(音楽 SEQ 無関与)ゆえ skip で音楽 render 不変。beqz exit は原設計の正規 path(異常分岐でない)。値導出不要=即実行可。
- **値 option (2) faithful = [0x801EE184] ← healthy offset**: worker3 (1,0) natural healthy dump の [P+0x90] 値。actor event 忠実性まで要る場合のみ。
- 推奨 = (1) clean-skip(納品=音楽素材、actor event 非関与)。

### 10-3. 検収(B案)
- 層0(最上流)= crash ゼロ(EPC 0x800C9E3C 不到達 / Excode 例外ゼロ)= worker3 injection run 直後判定。
- 層1 = KON write 全長継続 / 層2 = v2 oracle(絶対 floor)/ 層4 = user 耳。
- 4 variant = forced fire で form/flag を振り各 variant 発火 + [0x801EE184]←0 で各 crash 回避 → 4本 clean 採取。
- ★注入検証 = worker3 DG_RESTORE_INJ run(層0-2)+ 独立 cross-check(worker3 healthy dump vs 本静的導出)。run PASS → provision → v2 oracle → user 耳 → gate① 再上申★。

### 10-4. ★Run A 実測=全層 PASS=機構最終実証(2026-07-20 worker3)★
- **fix 確定 = `DG_LATE_INJ 0x801EE184:0:8900`**(clean-skip、[P+0x90]←0、frame 8900 注入)。1 word 除去で crash 消滅 + 音楽不変。
- **層0(crash ゼロ)= PASS**: Excode=0 完走(EPC 0x800C9E3C 不到達、Data Bus Error 消滅)。
- **層1(KON write 全長継続)= PASS**: KON 66s 一様(停止ゼロ)。
- **層2(v2 oracle)= PASS**: centroid 全区間 2700 平均 = 原 clean 水準、暗化消滅。
- ★**write-watchpoint 0x801EE184 = 0 write = 本静的予想(能動 write ゼロ=stale leftover)的中**★。→ 注入は生存(P struct 生成後の stale garbage を上書き、以降 clobber なし)。1 word 除去で crash 消滅 + 音楽不変 = 機構最終実証(crash が ROOT、暗化が結果、を実証的に確定)。
- ★honest mark★: 本注入(値=0 clean-skip)は cmd0x24 = battle actor event を skip。natural の [P+0x90] 値(healthy)が非0 なら actor 挙動に差(その event が本来走る)が生じるが、**音楽 render は同一**(cmd0x24 は actor event、音楽 SEQ 非関与=層1/2 で実証)。healthy 値は worker3 (1,0) natural dump で確認可(faithful 版が要る場合)。納品=音楽素材ゆえ clean-skip で十分。
- 残: worker3 v0-v3 展開(P 安定性 per-run 確認 + v2 oracle 正式適用)→ 4本 clean 採取 → provision → V5 package → user 耳 → gate① 再上申。
