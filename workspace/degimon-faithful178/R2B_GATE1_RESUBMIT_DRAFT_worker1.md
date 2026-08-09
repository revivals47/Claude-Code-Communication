# R2B gate① 再上申 骨子(v1 確保 + v0/v2/v3 状態・選択肢)— worker1 draft

**date**: 2026-07-20 / worker1 / ★doc-only、boss1 起草材料(gate① は boss1→PRESIDENT)。判別 test 結果で確定★
**規律**: 観測/推論/未確定。honest = 確保分と限界を分離明示。

---

## 0. 一行サマリ

★scene33 音楽「途中で重くなる」の真因 = capture 採取時の CPU crash(forced artifact、remake/原盤無罪)。1 word 修正で根治実証。**v1(user 対象 variant)= 全層 clean 確保**。v0/v2/v3 は forced 文脈固有の追加事象を判別中★。

---

## 1. 確保済(実証、上申の core)

### v1(user 対象 variant=partner form 由来の既定 variant)= ★完全確保★
- deliverable: `scene33_fixed_v1.wav`(sha256[:16]=aa9f35a3774e9db2)。battle window [137.8-204.5s]=66.8s(2+loop)、44100/2ch/s16 raw。
- crash-fix: `DG_LATE_DEREF [0x8016B37C]+0x90 ← 0 @frame8900`(cmd0x24 stale-offset 除去=clean-skip)。static 導出 offset と runtime 一致(独立 2 系統接地)。
- 検収: 層0 EXC=0 / 層1 KON 全長(8287-12200)/ 層2 r2b_oracle_v2 33 窓 0 fail(全区間 bright ~2700Hz=原 clean 水準)/ 層3 aplay rc=0。**残 = 層4 user 耳**。
- 機構最終実証: 1 word 除去で crash 消滅 + 音楽不変(crash=ROOT、暗化=結果を実証確定)。write-watchpoint 0 write=注入生存(static 予想的中)。

## 2. 判別確定(2026-07-20 worker3 3 test + worker1 static)★統一像=非native variant の selector 強制 artifact★

★**統一結論**: 失敗 3 variant(v0/v2/v3)は共通に「**native でない variant の selector 入力(form/flag)だけを強制 → 随伴自然文脈(form data / B[0x254] 等)が欠落 → artifact**」。v1 無傷の理由 = **native(注入ゼロ)**★。

### v0(flag=1 経路、variant0)= 注入 artifact(同一 class 確定)
- 現象: bright 8s → near-stop → sparse steady、loop 先頭(167s)で rich 非再現(oracle 21/27 fail、EXC=0、no-crash)。
- ★v0 SEQ note 密度 = **一様(CV=0.08、min50/max66/mean56.3、rich→break→sparse 構造なし)**★(29.12s loop 曲)。→ audio の rich→near-stop→sparse は **SEQ 由来でない = 注入 artifact 確定**。
- H-v0scenario **不成立**(scene_switch は silence 後 165s=説明不可、worker3)。
- ★真因(boss1 統合)★: v0 注入先 0x801639D7=B[0x253]=**F-1 arc の 2-writer flag**(flag==1→[P+0x66d]=B[0x254] copy)。flag=1 強制は **stale B[0x254] との不自然 combo** = v2/v3 と同一 class(部分文脈注入 artifact)。

### v2/v3(form 0x43-0x6F / curForm 0x73)= H-form-data 確定(原理的限界)
- 現象: form 注入(0x8016B374:0x44/0x73)で別 code path、EPC 0x800CABCC frame8501 で Excode12 Arithmetic Overflow。
- 機構(static): `add v0,s1,v0`[ovf]、s1=0x8000127C(garbage 低 ptr)= coord fn 0x800cab44 の table-lookup `[[sp+0x34]+s0*4]`。二の矢: coord caller 0x800ca4d8 = 0x8014 域 entity-data table を entity index で引く構造。
- ★worker3 3 test 確定★: (1)座標妥当(slot8=0x8016B374 一致=座標修正では解決せず) (2)**H-form-data 確定**(form 0x44 の digimon data 未 load → garbage lookup → overflow)=★form-byte 強制の原理的限界★ (3)v0=H-v0scenario 不成立。

## 3. 選択肢(確定、PRESIDENT/user scope 判断材料)

- **v1 = 納品確定**(native、層0-3 PASS、clean)。
- **v0/v2/v3 = 同一 class artifact**(非 native variant の selector 強制で随伴自然文脈欠落)。座標修正・stale-field 個別注入では解決せず=**部分文脈注入の原理的限界**。

| 選択肢 | 内容 | 忠実性/工数 | 評価 |
|---|---|---|---|
| ★(a)[boss1 推奨・第一候補]★ | v0/v2/v3 が **native に鳴る場面の user savestate 追加取得** → 実証済 fix 手法(DG_LATE_DEREF)をそのまま適用し採取 | ◎最忠実(native=随伴データ完備)/ 中(user savestate 依存) | ★fix 手法実証済ゆえ savestate さえあれば即採取。self-consistent★ |
| (b) | data-load 注入実装(form data / B[0x254] 等の随伴文脈を harness 構築) | △(非 native 構築)/ 重(各 variant の全随伴 state 同定=whack-a-mole risk) | 工数大・[[feedback_correction_is_not_automatically_improvement]]risk |
| (c) | v1 のみで R2'b close | 確実 / 小 | 最小線(4/4 断念) |

- ★最小確実線 = v1 完全確保(層0-3 PASS)+ 層4 user 耳★。
- ★honest 上申形★: 「真因=capture 時 CPU crash を 1 word 根治(実証済)。**v1(user 対象 variant)は clean 納品確定**。v0/v2/v3 は forced-capture で native でない variant を強制した artifact(selector だけ強制→随伴データ欠落)=**部分文脈注入の原理的限界**。4/4 には該当場面の user savestate 追加取得(推奨 a、実証済手法が流用可)が最忠実。scope = PRESIDENT/user 判断」。

## 4. 次段
- ★本 §2-3 = 判別確定済★。boss1 が本骨子で gate① 再上申(v1 core 納品 + v0/v2/v3=原理的限界 + 選択肢 a/b/c、推奨 a)。
- (a)採用時: user から v0/v2/v3 が native に鳴る savestate 取得 → 各 fix(DG_LATE_DEREF 相当)実証済手法で採取 → v2 oracle → 4/4 完成。
