# V4 0x66 到達条件 静的分岐解析 + unconditional section filter — worker1

**date**: 2026-07-19 / worker1 / ★read-only 静的 DG.SCN 解析(doc-only、tree 非接触)、v4 critical path★
**material**: DG.SCN(degimon_world_remake/extracted)。Len[256]=DialogueRuntime.cs verbatim。0x19 eval=scn_trace.py eval_0x19(shipping runtime DialogueRuntime.Eval0x19 忠実、user 検証済)。worker3 material=V4_CENSUS_FIRE_MAP_worker3.md(115 entry/481 fire、entry22 §254 fires @0x90/0xBC/…)。
**規律**: 観測(decode/eval)/推論/honest gap。全数 filter は範囲明記。

---

## 0. 結論(単一推奨ファースト)

★req(2) 全数 filter 結果 = **unconditional section は 0 件**(112 entry の全 0x66 が section 開始→0x66 間に dialogue(DLG+TEXT)or var-branch を持つ)★。∴ flag 値変更だけの deterministic 到達は不可 → req(3) 最小 state 要求へ。

★★単一推奨(req3)★★: **hook target = 22:254(§254=scene-list loop、dialogue 無し)+ play-mode で var[0x6e]=0 を強制(または event-var を census 同等の fresh state に reset)** してから F9(PlaySection)。
- 根拠: §254 は var[0x6e]<=0x7 / <=0xf の 0x19 gate + var[0x6e]-indexed JMP_D(scene-loop dispatch)。census fresh state(var[0x6e]=0)は scene-0 handler→0x66@0x90 に到達し 8 回発火(実測: worker3)。play-mode 実 state(boot 後累積で var[0x6e]≠0 の公算)は fall-through→0x6a RETURN で 0x66 未到達。
- ∴ ★var[0x6e]=0 強制 = census 再現 = deterministic 8 発火(dialogue interaction 不要)★。worker3 injection/XTEST infra で設定可能。

---

## 1. entry22 §5 / §254 の 0x66 手前 分岐/return 解析(req1、観測)

### §5(key5、offset 0x6c)= dialogue-wait blocker
decode(0x6c→0x90、Len-table + SJIS):
```
0x6c 1b SPK / 0x6e 1a DLG / 0x70 [SJIS text 22B] / 0x86 0d / 0x87-89 00×3 / 0x8a 27 / 0x8c 67 FRAME_YIELD / 0x90 66 SCENE_DRV
```
- ★分岐/return は無い★が ★0x1a DLG + SJIS text(対話表示)が 0x66 手前にある★=play-mode で対話 page-advance 待ち → 自動 run では 0x66 未到達(worker3「§5=0x66未実行」の機構)。
- → §5 は「state 非依存だが dialogue-wait 依存」=hook 自動発火に不適(page-advance input 要)。

### §254(key 0xFE=254、offset 0x28)= var[0x6e] gate + scene-loop(dialogue 無し)
0x19-aware trace(eval_0x19、観測):
```
0x28 op24
0x2c 19 COND_BR: ★var[0x6e]<=0x7★, BR_IF_FALSE→0x3e   (var[0x6e]>7 なら 0x3e へ)
0x38 op74/op2c/op21 → 0x3e
0x3e op24
0x42 19 COND_BR: ★var[0x6e]<=0xf★, BR_IF_FALSE→0x54
0x4e op74
0x50 17 JMP_D(len6、operand 17 00 31 00 24 00)= ★2-operand computed lookup jump(var[0x6e]-indexed scene dispatch の公算)★
0x56 op6e(len8)
0x5e 18 JMP_E → 0x6a
0x62 19 COND_BR skip(mode0x30)
0x68 op4a
0x6a ★fe RETURN★ → section 終了(0x66@0x90 未到達)
```
- ★fall-through(0x19 branch 非成立の linear path)は 0x6a RETURN で終わる=0x66 未到達★(worker3「§254=即finished」の機構)。
- 0x66@0x90 到達には ★JMP_D(0x50)が scene handler(0x90 領域)へ jump する必要★=JMP_D は var[0x6e]-indexed(computed)ゆえ var[0x6e] の値が dispatch 先を決める。
- census(var[0x6e]=0)= JMP_D→scene-0→0x66@0x90、以降 loop で 8 scene(0x90/0xBC/0xEC/0x11A/0x142/0x170/0x192/0x1B6=worker3 実測)。
- ★到達に必要な条件 = var[0x6e] が census 同等(=0、loop 開始値)★。play-mode 実 state で var[0x6e]≠0 なら dispatch がずれ/loop 済 → 0x66 未到達。

## 2. req(2) 全数 unconditional filter(観測、範囲明記)

- ★scan 範囲★: V4_REACH_PATH の 112 entry(idx 1-224)× 各 section。各 section 開始→最初の 0x66 まで decode し、間の opcode を分類(branch=0x13-0x19 / return=0xFE/FF / DLG=0x1a / TEXT=SJIS)。
- ★結果★: **clean(branch/return/TEXT/DLG 全て無し)= 0 件 / DLG-only(TEXT 無し)= 0 件**。= ★全 112 entry の全 0x66 section が、0x66 手前に dialogue(DLG+TEXT)または var-branch を持つ★。
- 内訳(推論): §5-§12 系(dialogue beat)= DLG+TEXT 手前(§5 と同型)。§254 系(scene-loop)= var[0x6e] branch 手前。→ ★flag 値だけで無条件到達できる section は存在しない★。
- ∴ req(3)(最小 state 要求)が唯一の道。

## 3. req(3) 最小 state 要求(単一推奨)

★推奨 = §254(22:254)+ var[0x6e]=0 強制★:
1. hook flag を **DEGIMON_V4_PLAYSECTION=22:254**(§5 でなく §254)。
2. play-mode で PlaySection 前に ★var[0x6e](event-var bank #0x6e)=0★ を強制(worker3 injection)。または event-var 全体を census 同等 fresh state に reset。
3. F9 → PlaySection(22,254) → §254 の var[0x6e]<=7/<=0xf gate 通過 → JMP_D→scene-0→0x66@0x90 発火(census 同型、8 発火)→ SelectSceneVariant→form variant→SceneAudioManager。
- ★なぜ §254 > §5★: §254 は dialogue 無し(var gate のみ)=var 強制だけで deterministic。§5 は dialogue-wait(page-advance input 要)で自動化困難。
- ★var[0x6e] 強制の実現性★: event-var ゆえ worker3 の XTEST/injection で設定可能(SET_VAR 相当 or 直接 RAM 書込)。census が fresh(全 var 0)で発火実績=var[0x6e]=0 で十分の強い傍証。

## 4. worker3 census material との突合(req4、観測)

| worker3 census(V4_CENSUS_FIRE_MAP) | 本静的解析 | 整合 |
|---|---|---|
| entry22 0x66 全て sec=0xFE(254)、pc=0x90/0xBC/0xEC/0x11A/0x142/0x170/0x192/0x1B6(8個) | §254=scene-loop、JMP_D(var[0x6e]-indexed)が各 scene handler(0x90…)へ dispatch=8 iteration | ✓ loop 構造一致 |
| play-mode PlaySection(22,254)=pc0x28→即finished | §254 fall-through(var gate 非通過)→0x6a RETURN | ✓ early-return 機構一致 |
| census B3 var[0xfa]=0x00 gap / B6 flag#1 示唆 | §254 の static gate=★var[0x6e]★(0x2c/0x42)。var[0xfa]は handler-param 層(0x800f0ac8(0xfa)=flag、FIRE_GATING §5)で別層 | ⚠ worker3 var[0xfa] と静的 var[0x6e] は別変数=両方測定推奨 |

★突合 note★: worker3 の var[0xfa](handler param/flag 層)と本解析の var[0x6e](§254 loop gate)は**別の event 変数**。§254 到達の直接 gate は var[0x6e](0x19 直読)。var[0xfa]/flag#1 は 0x66 handler 内 direct/loop 分岐(FIRE_GATING §4-5)に関与。→ worker3 は §254 entry 時に ★var[0x6e] と var[0xfa] 両方を dump★ し、census(fresh)との差分を確認推奨。

## 5. honest gap / cutoff

- ★JMP_D(0x50、0x17)の exact target 未解決★: 2-operand computed lookup(jump 機構)ゆえ静的に dispatch 先を確定せず。但し census 実測(var[0x6e]=0→0x66@0x90)が「var[0x6e]=0 で到達」を経験的に確定=req3 推奨は接地。exact JMP table RE=次段(必要時)。
- ★play-mode の var[0x6e] 実値 未測定★: 「≠0 ゆえ未到達」は推論(fall-through→RETURN の機構 + census 差から)。worker3 が §254 entry で var[0x6e] を dump すれば確定(=req3 の強制値 0 の妥当性 double-check)。
- ★0x19 desync 無害化★: §254 の 0x19 は eval_0x19(shipping 忠実)で正確 decode(Len-table 近似でない)=trace 信頼可。
- ★worker3 var[0xfa] vs 静的 var[0x6e]★: §4 note の通り別層。両測定で最終確定。
- self-audit: req2 の「0 件」は 112 entry 全 section 走査の結果(範囲明記)。unconditional 不在は「探索不足」でなく「全 0x66 が dialogue/var-branch gated」という DG.SCN の構造的性質。
