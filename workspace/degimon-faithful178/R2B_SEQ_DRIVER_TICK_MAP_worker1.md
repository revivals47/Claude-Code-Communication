# R2B SEQ driver tick 静的 map — case-2(KON write 停止@+10.4s)の機構標的 — worker1

**date**: 2026-07-20 / worker1 / ★静的 EXE RE(disasm 直読)、worker3 二分測定の watchpoint 標的提供★
**契機**: boss1 03:56 case-2 確定(KON/KOFF write 完全停止@frame8861=fire+10.4s、tick PC=0x800D2130/ra=0x800D8E34)。SEQ 側は発行継続期待(KON schedule CSV)ゆえ乖離=driver 側停止。
**規律**: 🔬観測(disasm)/🧩推論/H4。fn 役割は disasm 直読、struct field 意味は一部推論(worker3 watchpoint で確定)。

---

## 0. 結論(tick chain + 停止標的)

★KON 物理発行 = fn 0x800d1eb8 @ 0x800d2130 が SPU_KON register 書込。KON mask flush tick = fn 0x800d8a54(fn-ptr 経由、VSync callback 想定)。停止 = この tick が KON mask を設定しなくなる(active track count [0x80157890]→0 or tick 非呼出 or per-track 停止)★。「SEQ data 特定 event 起因」説は静的 REFUTE(+10.4s 付近の SEQ に特殊 event なし=§4)。

---

## 1. tick chain map(fn 役割、🔬disasm)

| fn | 役割 | 根拠(disasm) |
|---|---|---|
| **0x800d1eb8**(@0x800d2130) | ★SPU_KON 物理書込★ | `lw v1,[0x80134404]; sh a1,0x188(v1); sh a2,0x18a(v1)` = SPU_KON lo(0x1F801D88)/hi(0x1F801D8A)。base [0x80134404]=SPU voice-ctrl base ptr。a1=KON lo mask, a2=KON hi mask |
| **0x800d8a54** | ★KON mask flush tick(main)★ | fn-ptr 呼出(jal caller ゼロ=VSync/SsSeqCalc callback)。frame tick counter [0x80157164] mod16、active track loop、KON mask ring [0x80157168+i*4] 構築→0x800d1e88/0x800d2058→0x800d1eb8 |
| 0x800d3008 | per-voice field getter | `[0x80134404]+voice*0x10+0xc` を読み per-track struct へ store(voice status→track) |
| **0x800d8edc** | driver init/reset(count writer) | driver state clear([0x801578b2/7892/76c8]=0 等)+ [0x80157890] 書込(§3)。caller=0x800d6268(fn 0x800d61e8=SsSeqPlay 相当) |
| 0x800d62d8(@0x800d62f0) | KON write 別 caller(stop/keyoff 経路?) | 0x800d1eb8 を呼ぶ 3 caller の一(他=0x800cf548 sound-init/0x800d1458) |

## 2. active track loop 構造(🔬0x800d8a54 内、0x800d8ac8-0x800d8b28)

```
s0=0..[0x80157890](active count)  ; track index
per-track struct base=0x801571ae, stride=0x36(54B)   ; s1/s2 += 0x36
 各track: jal 0x800d3008(a0=track, a1=track_struct)   ; voice status→struct[+0]
   lhu [0x801571ae + track*0x36 + 0]                   ; key-on-enable field
   if ==0 → KON mask ring[tick] |= (1<<track)          ; このtrackを鳴らす
   if !=0 → skip(鳴らさない)
```
- 🔬 **[0x80157890](byte)= active track count**。`blez`(0x800d8aa4)で <=0 なら全処理 skip、loop bound(0x800d8b20 slt)。→ ★これが 0 になれば全 track 停止=KON 完全停止(worker3 の完全停止と一致)★。
- 🔬 **per-track struct = 0x801571ae + track*0x36**(stride 54B)。[+0](lhu)= key-on-enable。position pointer/status/tempo/残time は本 struct 内(field offset は §5 で worker3 dump 突合)。

## 3. active count [0x80157890] writer(停止 trigger 直接)

- 🔬 writer は **fn 0x800d8edc のみ**(0x800d8fc4 sb rt=2 / 0x800d8fd4 sb rt=3)。caller=0x800d6268(fn 0x800d61e8=SEQ play/setup)。
- 🧩 → active count の変更は SEQ play/reset 経路(0x800d61e8→0x800d8edc)に限定。停止が count 経由なら、この経路が +10.4s に走ったことになる(worker3 が [0x80157890] watchpoint で確認可)。

## 4. 「SEQ data 特定 event 起因」説の静的検証(🔬REFUTE 方向)

- KON schedule CSV(t=9.5-11.5s)= +10.4s 付近は通常 music(ch1/ch2/ch9 KON 継続)、★特殊 event(end-marker/prog/tempo)なし★。SEQ data 上は 10.4s 以降も KON 継続(11.0s ch1、11.125s ch0、10.875s ch4…)。
- ∴ 停止は **SEQ data 起因でない**(end-of-track marker も +10.4s の特殊 event もない)= driver-state 停止。「特定 event 起因」説は静的 REFUTE 方向(worker3 の SEQ data 無傷確認と突合で確定)。

## 5. ★停止経路 候補列挙(worker3 二分測定の標的)★

worker3 二分測定(tick 呼出継続? / SEQ data 無傷?)× 以下 watchpoint で機構 close:

| # | 候補 | watchpoint | 判別 |
|---|---|---|---|
| ★A★ | active count [0x80157890]→0 | [0x80157890](byte)write + fn 0x800d8edc 呼出 | +10.4s に 0 化 or 0x800d8edc 実行→A確定(=SsSeqStop/reset 相当が走った) |
| ★B★ | flush tick 0x800d8a54 非呼出 | 0x800d8a54 entry BP | +10.4s 以降 tick 呼ばれない→B(VSync callback 外れ/fn-ptr clear)。worker3「tick 呼出継続?」がこれ |
| C | per-track status/position 停止 | 0x801571ae+track*0x36 struct dump(高track ch2/ch4) | count 不変・tick 継続だが per-track が非 playing/position 停止→C(decode 停止) |
| D | per-track key-on-enable flip | [0x801571ae+track*0x36+0](lhu) | 高 track のみ !=0 化→D(選択的、但し worker3 は「完全停止」報告ゆえ D は低優先) |

- 🧩 worker3 実測(完全停止・voice10→6・high 先落ち)= **A or B**(全停止)が本命。C は decode 停止で同様に全 KON 停止し得る。D(選択的)は「完全停止」と不整合ゆえ低優先。
- ★外部停止 API 候補★: active count writer 経路 0x800d61e8→0x800d8edc(SsSeqPlay/reset)、KON write 別 caller 0x800d62d8(stop/keyoff 疑い)。SsSeqStop/Pause/Close 相当の同定は worker3 が A/B 確定後(どの経路が走ったか)に絞って深追い。

## 6. driver 全 watchpoint 一覧(worker3 提供)

| addr | 型 | 意味(🔬観測/🧩推論) |
|---|---|---|
| [0x80157890] | byte | 🔬 active track count(blez gate + loop bound)★PRIME★ |
| 0x801571ae + track*0x36 | struct(54B) | 🔬 per-track SEQ 状態(position/status/tempo/残time)。[+0]=key-on-enable |
| [0x80134404] | ptr | 🔬 SPU voice-ctrl base(+0x188/8a=SPU_KON lo/hi、+voice*0x10=per-voice struct) |
| [0x80157164] | word | 🔬 frame tick counter(mod16) |
| [0x80157168 + i*4] | word×16 | 🔬 KON mask ring |
| [0x801576b8/76be/76ba/7860/7862] | h/b | 🔬 KON mask flush sources |
| [0x801578b4],[0x801578b2],[0x80157892],[0x801576c8] | b/h | 🧩 driver status flags(init/reset で clear) |

## 7. honest gap / 次段
- position pointer の struct field offset(0x801571ae+track*0x36 内)= 未確定。SsSeqPlay setup(fn 0x800d61e8)の struct init 読切り or worker3 の 0x36-struct dump で確定=次 step。
- 停止機構 A/B/C の裁定 = worker3 二分測定(tick 呼出? / count? / SEQ data?)× §5-6 watchpoint。確定後に真 fix 標的(count 保持/tick 継続/decode 継続のどれを直すか)を FIX 再設計。
- ★案X(SB-skip)/対策B(settle)は真因(driver KON 停止)に非対応=破棄。真 fix は driver 停止機構を止めない/capture 前提を正す方向★。
