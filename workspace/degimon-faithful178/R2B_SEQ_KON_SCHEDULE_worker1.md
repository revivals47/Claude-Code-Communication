# R2B scene33 SEQ 構造 + 期待 KON schedule — (b) 崩壊の静的物差し — worker1

**date**: 2026-07-20 / worker1 / ★静的 RE(FAALL.VHB 直読 + pQES parse)、worker3 voice-level 動的実測との突合物差し★
**契機**: boss1 02:35 静的決定打指示 → (a)dark=正当intro/loop vs (b)+13s 崩壊 の裁定。worker3 実測(voice 10→6/KON枯渇)と統合。
**規律**: 観測(byte/parse)/推論/H4。抽出の authoritative 性=二重接地(RAMDUMP §5.5 offset 一致)。

---

## 0. 結論(静的決定打 = (b)崩壊確定、(a)/settle=真BGM REFUTE)

★scene33 variant1 SEQ は **一定 bright 5楽器編成を 29.12s loop で継続する意図**。+13s に section 境界/program/volume/expression 変化は**皆無**(唯一の +13s event=ch2 pitch-bend=vibrato 音楽表現)★。
→ 捕獲音の +13s 暗化(centroid 2600→900Hz、R2B_WAV_DIAGNOSIS)は **SEQ に存在しない** = SEQ 意図と実音の乖離 = ★(b) rendering/SPU-state artifact = 真の崩壊★。(a)「dark=正当な intro→loop」・対策B「settle=真BGM」・旧 settle 解釈=**静的 REFUTE**。
★worker3 実測統合(fire+10 vs +20)★: 全 active voice=valid sample(死/garbage ゼロ)、bright→dark=voice 数 10→6 + clean key-off + v07 低 note 再割当 → **sample 崩壊でなく KON 枯渇(H-starve): +13s 以降 高ch KON が発行/割当されない**が (b) 精密機構仮説。本 SEQ parse(高ch KON は +13s も継続発行の意図)と突合=★SEQ は KON を出す意図なのに voice が減る=KON が SEQ-tick↔SPU-voice 間で失われる★。

---

## 1. 抽出(authoritative 静的、run 不要、二重接地)

- FAALL.VHB=`CD/DEGIMON/sound/vhb/faall.vhb`(sha256 067ae902…確認)。record#33(scene 0x21)= byte **0x270000**(39 sector)。
- chunk header word[2]=0xa430(SEQ section offset)/word[3]=0xf99c(end)。SEQ section base=0x27a430。
- SEQ offset table=**[0x10, 0x1828, 0x33b8, 0x3fe0]**(=variant 0-3、RAMDUMP §5.5 と**完全一致**=二重接地)。各 pQES magic 確認。
- 抽出物(workspace/degimon-faithful178/r2b_seq/): scene33_v{0-3}.seq(6168/7056/3112/5516 B)+ seqparse.py + scene33_v1_KON_schedule.csv(834 行)。

## 2. 全 4 variant 構造(pQES parse、全て bright 継続 loop=構造的 REFUTE (a))

| variant | tempo | 総尺(loop) | note数 | ch(prog) | note最大pitch | +13s 構造変化 |
|---|---|---|---|---|---|---|
| v0 | 120BPM | 29.12s | 826 | 0(3)/1(1)/2(2)/4(1)/9(0) | 100 | ★なし★ |
| ★v1(user対象)★ | 120BPM | 29.12s | 834 | 0(3)/1(1)/2(2)/4(1)/9(0) | 100 | ★なし★ |
| v2 | 150BPM | 23.30s | 362 | 0(3)/1(1)/2(2)/3(4)/9(0) | 81 | ★なし★ |
| v3 | 180BPM | 22.75s | 712 | 0(1)/1(0)/2(2)/3(3)/4(4) | 72 | ★なし★ |

- 全 variant: program change は冒頭(t≈0.03s)のみ、以降 楽器/volume 変更ゼロ、末尾 cc99 loop marker。**構造的に「一定編成 loop」**=(a)intro→dark 構造は 4/4 で不在。
- ★collapse 重篤度↔note最大pitch 相関(観測、H4)★: R2B_WAV_DIAGNOSIS §4 collapse=v0/v1 顕著・v2 軽微・v3 なし。SEQ note 最大 pitch=v0/v1:100 / v2:81 / v3:72。→ **高 note を多く持つ variant ほど collapse が可視**(失う高域が多い)。v3(max72)は高域が元々少ない=「崩壊しても目立たない」。(b)=高域 voice loss と整合(崩壊有無でなく可視性の差)。

## 3. variant1 ch 別 KON 特性(高域担当の同定)

| ch | prog | KON数 | 音域(note) | avg | 高域KON(≥72) | 役割(推定) |
|---|---|---|---|---|---|---|
| ch0 | 3 | 44 | 33-72 | 49.6 | 2 | bass 旋律 |
| ch1 | 1 | 224 | 57-76 | 62.2 | 41 | mid 伴奏 |
| ch2 | 2 | 100 | 64-86 | 74.1 | 67 | ★高域旋律(vibrato/pitch-bend 持ち)★ |
| ch4 | 1 | 61 | 89-100 | 95.3 | 61 | ★最高域(全 note 高)=最も bright★ |
| ch9 | 0 | 405 | 36-70 | 41.0 | 0 | drums/percussion |

→ ★高域担当=ch2(64-86)+ch4(89-100)★。centroid collapse(高域喪失)= この 2ch の voice が落ちることに対応。ch0/ch1/ch9(低〜mid)は残存 → 「低域だけ残る=もったり」(R2B_WAV_DIAGNOSIS)と一致。

## 4. ★期待 KON 密度: fire+10〜16s 窓(worker3 KON実測 log 突合の物差し)★

| 時刻 | ch0 | ch1 | ch2 | ch4 | ch9 | 計 |
|---|---|---|---|---|---|---|
| 10-11s | 0 | 8 | 1 | 2 | 14 | 25 |
| 11-12s | 2 | 8 | 1 | 2 | 13 | 26 |
| 12-13s | 0 | 8 | 4 | 2 | 14 | 28 |
| 13-14s | 2 | 8 | 4 | 2 | 13 | 29 |
| 14-15s | 0 | 8 | 6 | 2 | 14 | 30 |
| 15-16s | 2 | 8 | 3 | 2 | 13 | 28 |

★SEQ は +13s 前後で 高ch(ch2/ch4)KON を**継続発行**(ch4=2/s 一定、ch2=1→4→6 増加)。総 KON 密度も減らない★。→ **SEQ 側は高域を止めていない**=(b)の gate は SEQ-tick より下流(KON enqueue→SPU voice assign)にある。

### 判別 logic(worker3 実測 KON/voice log と突合)
- ★case-1: worker3 KON log で ch2/ch4 KON が **+13s 以降も本表通り発行**されている → KON は出ているが SPU voice が割当/steal で落ちる = **voice assign/steal 側の gate**(H-starve の voice 層)。
- ★case-2: worker3 KON log で ch2/ch4 KON が **+13s 以降 発行されない/減る**(本表と乖離) → SEQ-tick→KON enqueue の間に高ch を止める gate = **command enqueue 側**(§5 候補)。
- worker3 voice 10→6 + clean key-off の実測 = KON が来ないので新規 voice が張られず自然減衰(key-off) の様相 → **case-2 寄り**だが、本表(KON 継続発行の意図)との突合で確定。実測 KON log(ch別/時刻)を本 §4 と行単位照合。

## 5. 静的並行: SEQ tick→KON 発行 chain で +13s 高ch を止め得る gate 候補(worker3 実測後に深追い)

- 経路(既知、RAMDUMP/§層): SEQ tick(SsSeqPlay 系)→ note command enqueue(**0x8011C824 queue**=KON 経路実体、[[reference]])→ KON 発行(SsUtKeyOn 系/内部 voice assign)。
- +13s 相当で高ch を止め得る候補(H4、列挙のみ=worker3 per-voice+KON/KOFF log 確認後に裁定):
  1. **voice 上限**: SPU 24 voice。SB skip でも他 bank/SE が voice を占有し +13s で空き枯渇→高ch(後着)が assign 失敗。
  2. **priority/steal**: 低優先 voice が steal されず、高ch KON が空き無しで捨てられる。
  3. **ch mute mask / channel 上限**: SEQ driver の ch 有効 mask が +13s で高ch を落とす(tempo/state 依存)。
  4. **enqueue queue 飽和**: 0x8011C824 queue が +13s の KON 密度増(ch2 1→6)で飽和し高ch 分を drop。
  5. **tempo/tick state**: tempo meta 無し(120BPM 固定)ゆえ tempo 起因は低い(除外寄り)。
- ★worker3 追加観点(boss1 03:21)★: bright 期の高域 driver sample が SS 域 0x040B0/gap 0x1B800(FAALL 純音楽でない)= cross-bank 参照の疑い。→ VAB header(tone table)の VAG addr field を静的確認(§6、別途)。

## 6. honest gap / 次段
- ★最終判別=worker3 KON/voice 実測 log(ch別・時刻)× 本 §4 期待表の行照合★=case-1(voice層)/case-2(enqueue層)確定。
- VAB tone table(faall.vhb header)の VAG addr field 静的確認=高域 driver が SS/SL 域 sample 参照か(cross-bank)=別 step。
- §5 gate 候補の深追い=worker3 実測で case 確定後(推論の密輸禁止=実測待ち)。
- 案X(SB-skip)は真因(H-starve)に非対応と判明=FIX 再設計は (b) 機構 close 後。
