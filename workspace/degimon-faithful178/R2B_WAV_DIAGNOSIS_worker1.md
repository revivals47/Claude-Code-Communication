# R2B wav 信号診断 — user 症状「途中から重くなる」の signature 同定 — worker1

**date**: 2026-07-19 / worker1 / ★doc-only、並行診断(worker3 capture 機構検証と独立 view)★
**対象**: scene33_v0-3.wav(StreamingAssets/audio、sha 台帳一致品、各 44100Hz/2ch/s16/97.31s)
**user 症状**: (a) 音は鳴る=PASS / ★音質 FAIL「途中で重くなる」= aplay A/B で wav 素材焼き込み確定★
**tool**: python numpy(scipy/matplotlib 環境無=numpy STFT/band-energy で数値診断、図=ASCII+数値表)
**規律**: 各仮説の期待痕跡→実測判定(H4 開放)。症状対応 signature を主成果(proxy 指標で受理基準を切らない)。

> ★★訂正適用 banner(2026-07-20、settle 訂正 list C2-C5 適用)★★
> §2 候補機構(c)「原盤 SEQ arrangement が高音を落とす=musical=忠実」= ★REFUTED★。§4 の「artifact vs 原盤 arrangement」分岐 = ★artifact 側に確定★。真因 = **CPU crash(EPC=0x800C9E3C、forced-capture artifact)→ CPU halt → SEQ tick 停止 → SPU drain = 暗化**(R2B_FIX_DESIGN §10、Run A 実証)。SEQ 静的 parse で全 4 variant が一定 bright 編成 loop の意図(+13s 構造変化皆無、v0 密度 CV=0.08)= 暗化は SEQ 由来でない=artifact 最終確定。
> ★§4 v2「musical?」/ v3「clean」の観測(measurement)は不変。解釈は「forced-capture の crash-class artifact(v0/v2/v3=非 native variant の selector 強制で随伴文脈欠落)」へ更新★。v1(native)= 根治後 clean 確定(sha aa9f35a3774e9db2)。「途中で重くなる」signature 同定(§0)は正しく、原因が crash と判明した。

---

## 0. 結論(主成果=症状対応 signature)

★(A) v1「途中から重くなる」の signature = **t≈12-14s から高/中域エネルギーが collapse し末尾まで持続する「低域偏重化(low-pass 状 spectral collapse)」**★:
- spectral centroid: t<12s ≈2400-3100Hz → t>14s ≈900-1050Hz(**64% 低下**、遷移 t=12→14s の 3s)。
- 高域(>2kHz)比: 5-6% → **1%** / 中域(500-2k)比: 12% → 6% / 低域(<500Hz)比: 83% → **94%**。
- ★pitch/speed でない★: dominant peak=**110Hz が early/late 不変**(速度低下なら peak も下方シフトするはず=否定)。tempo period も early/late ≈同(1.00)。
- ★clip/underrun でない★: clip 0.00%(全区間)、sample 不連続(jump>0.5FS)=0 件、RMS 平坦(≈2000 一定)。
- → ★症状=「高域の voice が途中で消え低域だけ残る=もったり/重い」★。時間軸伸長でも歪みでもなく **帯域欠落(高域 dropout)**。

★(B) re-capture 受理 oracle(下記 §3 の測定手順): 「centroid が全区間で sustained collapse(>50% 低下して持続)しない」かつ「高域(>2kHz)比が t>14s でも early 水準を保つ」★=症状 signature がゼロ。

★(C) 4 variant 横断(§4): collapse は **v0(75%@11s)/v1(64%@13s) に顕著、v2(19%@4s)は軽微、v3=無し**★=uniform-systematic でない(v3 clean)=run-individual or variant-arrangement=worker3 capture 機構と突合で確定。

---

## 1. 仮説別 判定(H4 開放、v1)

| 仮説 | 期待痕跡 | 実測 | 判定 |
|---|---|---|---|
| (i) pitch/tempo 低下(速度低下=時間伸長) | 全 spectrum 下方シフト(dom peak も下がる)+tempo period 伸長 | ★dom peak=110Hz 不変、tempo ratio≈1.00★ | ★否定★(速度低下でない) |
| (ii) sample 落ち/underrun(不連続・click) | sample-to-sample の大 jump、zero-run | ★jump>0.5FS=0 件、RMS 平坦★ | 否定 |
| (iii) 別音混入(SFX/RESET) | 特定帯域の突発 spike/broadband burst | 突発 spike 無し、collapse は緩やか(3s 遷移) | 否定(明確 burst なし) |
| (iv) clipping/歪み | 振幅飽和(≥32760)多発、高調波増加 | ★clip 0.00%、高域は増でなく減★ | 否定 |
| ★(v) 高域 voice dropout(H4)★ | 高/中域エネルギーが特定 t から低下し持続、低域残存、pitch 不変 | ★t≈12-14s から高域 5%→1%、低域 83%→94%、pitch 110Hz 不変★ | ★該当=症状 signature★ |

→ ★症状の正体 = (v) t≈12-14s からの高域 voice 消失(低域偏重化)。速度/歪み/click でない★。

### v1 centroid 時系列(ASCII、1s 刻み、症状 onset 可視)
```
 t= 0-11s : centroid 2300-3200Hz(高域含む正常)
 t=12s 1877Hz ←onset  t=13s 1479Hz ←onset  t=14s 1043Hz ←onset(collapse)
 t=15s 以降: 900-1050Hz で末尾(97s)まで持続(高域欠落)
```
(数値: t11=2527→t12=1877→t13=1479→t14=1043→t15=1023Hz、以降 ~950Hz 持続)

## 2. 機構所見(worker3 capture 突合材料、推論)

- 高域 voice が t≈12-14s から一斉消失し pitch/tempo 不変=**SPU voice(高音 channel)が途中で停止/未再生**の疑い(SEQ の高音パートが鳴らなくなる)。
- 候補機構(H4、worker3 capture 機構で確定): (a) SEQ voice-on/off の取りこぼし(capture 中に高音 voice が re-trigger されず) (b) SPU voice 割当/状態が N 秒後に破綻 (c) 原盤 SEQ arrangement が途中で高音パートを落とす(=musical=忠実) (d) emulator SPU state issue。
- ★speed 説の独立反証★: worker3 doc 名 R2B_CAPTURE_SPEED_RE は「速度」を疑うが、本信号診断は ★dom peak 110Hz 不変+tempo 不変=速度低下でない★=別機構(高域 dropout)を示す。→ 突合で「速度」でなく「voice 消失」に focus 誘導。

## 3. ★re-capture 受理 oracle(測定手順、re-capture 品に適用可能)★

★proxy(SNR 等)でなく症状 signature のゼロを判定★:
1. wav を mono mix(L+R 平均)、0.5s hop で全区間の **spectral centroid** と **高域(>2kHz)エネルギー比** を算出(numpy: rfft+hanning)。
2. **受理条件(症状ゼロ)**:
   - (a) centroid が「早期(t=2-10s)平均の 50% 未満へ低下して 3s 以上持続する onset」が **存在しない**(v1 現状は t≈12s に該当=FAIL)。
   - (b) 高域(>2kHz)比が t>14s でも early(t=2-10s)水準の ≥50% を保つ(v1 現状 1% vs early 5%=20%=FAIL)。
   - (c) dominant peak/tempo は不変が正常(速度系は元から否定=補助確認)。
3. 判定: (a)(b) 両方クリア=症状 signature ゼロ=受理。1 つでも該当=症状残存=再々 capture。
4. ★閾値根拠★: v1 実測(early centroid≈2600Hz/高域 5% → late 930Hz/高域 1%)= collapse 明確。健全品は centroid が全区間で early 水準帯を維持するはず。

## 4. 4 variant 横断(§req C、観測)

| variant | early centroid | late centroid | drop | 高域比 early→late | onset | collapse |
|---|---|---|---|---|---|---|
| v0 | 3082Hz | 769Hz | 75% | 29%→0% | ~11s | ★顕著★ |
| v1(user対象) | 2614Hz | 929Hz | 64% | 6%→1% | ~13s | ★顕著★ |
| v2 | 2456Hz | 1982Hz | 19% | 5%→5% | ~4s | 軽微(高域比不変=別要因/musical?) |
| v3 | 3065Hz | 3249Hz | -6% | 26%→26% | 無し | ★無し(clean)★ |

- ★v3 が clean=collapse は uniform-systematic でない★(全 variant を一律に襲う capture 定数でない)。
- v0/v1 が顕著(高域比が late で 0-1% へ)、v2 は centroid は下がるが高域比不変(=collapse でなく別の中域変動、musical の可能性)、v3 は無し。
- → ★collapse は run-individual(v0/v1 の capture で高域 voice 消失)or variant-arrangement(SEQ 自体)★。判別=worker3 capture 機構(各 run の SPU voice log/emulator 状態)と突合。★もし原盤 SEQ が v0/v1 で高音を落とす arrangement なら忠実(=非 FAIL)、capture で voice を取りこぼしたなら artifact(=re-capture 要)★=この分岐が原因確定の鍵。

## 5. honest gap / 次段

- ★artifact vs 原盤 arrangement の最終判別は本信号診断単独では不能★: clean な原盤 reference 音源(または worker3 の各 run SPU voice-count log)が要る。本診断は「症状=高域 collapse@t≈12-14s(v0/v1)」を定量同定+oracle 化まで。
- worker3 R2B_CAPTURE_SPEED_RE と突合: ①speed でない(本診断)を伝え voice 消失へ focus ②各 run の高域 voice が t≈12s で落ちるか(capture 側 log)で artifact 確定。
- matplotlib 無=png 図は未生成(numpy ASCII+数値表で代替)。png 必要時は matplotlib 導入後に spectrogram 生成可(user 環境変更ゆえ boss1 裁定待ち)。
- ★症状 signature(高域 collapse)は速度系でないため、worker3 の「速度」focus と方向が違う=独立 view の価値(H4: 両説を capture log で決着)★。
