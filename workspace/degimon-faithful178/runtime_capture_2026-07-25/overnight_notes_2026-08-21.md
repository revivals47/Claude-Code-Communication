# 夜間静的RE ノート(2026-08-21→22)

## gap #2 = CLOSE (攻撃側/防御側)
- getDamagePoint(a0,a1,a2): ★a0=攻撃側 / a1=防御側★。
- 両方 actor-pointer-table ★0x8013CDB4★(stride4, actor構造体ptr配列)から引く:
  - a0(攻撃)= 0x8013CDB4[[sp+0x7c]] (sp+0x7c=攻撃unit id) — 0x8005e190 lw
  - a1(防御,s1)= 0x8013CDB4[target_id] (target_id=[gp-0x6dec]+0x66c+iter) — 0x8005e08c lw
- ∴ 式§2.2 の A=[a0+0x38]=攻撃側の攻撃stat / D=[a1+0x3a]=防御側の防御stat。
- 2独立方法一致: 静的disasm(caller 0x8005dfd8) + 今日のwatchpoint(被弾=partner=s1=a1)。
- 副産物: 0x8013CDB8=table[1]=特定unit(系統Aのbonus check対象=player partner有力)。gap#4の一部前進。

## gap #3 = 構造的に CLOSE / 意味ラベルは推論 (技系統境界 58/113)
- skill table 0x801325C0 = resident EXE slps_017_97.bin file off 0xA1DC0, stride16。
- branch判定は skillId範囲のみ(0x8005d728 slti 0x3a / 0x8005d734 slti 0x71)。
- ★ids 58-112(55技)= entry+11==0x64(100) マーカーを54/55で持つ独立カテゴリ★。branch A適用(防御無視: (A+P)*M/30 + player-unit bonus + 変動)。
- ids 0-57 = branch B(攻撃-防御 差分式)。+11 は 55/41 等バラバラ。
- ids 113-121 = 極小power(5-10)= 弱攻撃/struggle系、branch B。
- ★id 122以降 = SJIS名前バイト混入 = 技tableは実質0-121で終わり、以降は別table(item名+値のペア構造: 123=100,125=500,127=1000,129=2500...=価格/威力?)★。
- 結論: 境界58/113は「+11=100マーカー付き技ブロック(58-112)」を画定。★意味ラベル(必殺技/特技 vs 通常技)は推論★(構造は byte確定、game用語対応は未証明)。

## gap #6 = CLOSE (SITE B 0x8005e708/724 の役割)
- 構造は SITE A と同一(min1 clamp → [s0+0x2e]加算 → 9999 clamp)。
- ★条件: skill_table[skill].+8 == 1 のときのみ発火★(0x8005e66c lbu +8 / 0x8005e674 bne 1 → skip)。かつ [s0+0x26]<=0。
- 計算: getDamagePoint を再呼び(同一引数)→ base damage。★rand(0..20)+10 を掛け /100 = base の 10〜30% を追加ダメージ★(0x8005e6a0 rand(0x15)/ 0x8005e6b8 mult / 0x8005e6c8 div 100)。
- ∴ SITE B = ★技クラス+8==1 の「追撃/2段目ヒット」= base の1〜3割を追加★。
- 副産物: skill entry ★+8 = 技クラス(==1で追撃発火)★。gap#3の+8 field意味が確定。

## gap #7 = 枠を確定 / 全長は下限のみ (actor struct)
- ★actorは pointer-table 0x8013CDB4(32bitポインタ配列, stride4, index=battle slot)経由で個別割り当て★。連続stride配列ではない=元gap「unit配列stride」の枠は「stride無し・各actor個別alloc」で解決。
- ★slot 1 = 0x8013CDB8 = player partner★(系統Aのbonus check対象、gap#4)。
- actor struct既知field: +0x00 species-val / +0x04・+0x0c type別sub-ptr(AI/behavior 0x801B60C4等) / +0x1c 状態異常timer / +0x26(SITE B gate) / +0x2e 累積ダメージ / +0x34 flags(0x10/0x40/0x800/0x8000) / +0x36 属性 / +0x38 攻撃stat / +0x3a 防御stat / +0x4e / +0x53(byte)。
- ★struct全長 >= 0x54(84B)★(damage関数でのs1最大offset 0x53)。exact全長=honest gap(top-level battle allocは未trace)。
- ★reconcile(08-08訂正)★: 式のA/D=actor+0x38/+0x3a=★battle実効stat★。08-08の「stat struct 0x8016b0bc(+0=Off/Def...)」は別物=永続/base stat。今日def=60はactor+0x3aから採取。両者は別領域。

## gap #4 = 部分前進
- 系統Aの `[sp+48]==[0x8013CDB8]` = 「攻撃側 == actor table[1] == player partner」= ★player自軍の技のときbonus★。
- bonus: k=[gp-0x6dec]+0x668; k<41→dmg*k/40(小さいと減衰) / k>=41→dmg*(rand(0..100)+100)/100。
- ★[gp-0x6dec]+0x668 の byte k = 未同定(親密度/熟練度/技レベル等の推論)★。gp-0x6dec = battle-context base。

## 0x10 retro-sweep = 精密スコープのみ(solo実行は見送り、次session+worker交差検証へ)

★判断: この領域(dialogue VM count)は registry が『false-GREENが住む・多重worker敵対検証の領域』と明記。solo 4am再カウントは誤りリスク大 ⇒ 実行せず精密スコープを残す(誤った数を出すより価値が高い)。★

### 事実確認(器で直読)
1. ★命名衝突の罠★: `scn_trace.py:126` の「0x10/0x18」は ★0x19(CheckFlag)term-chain内の分岐mode(cond&0x38)★ であって ★standalone opcode 0x10=CHOICE ではない★。retro-sweepが触るべきは後者。混同禁止。
2. runtime `DialogueRuntime.cs:130-136`: opcode 0x10=CHOICE は ★専用可変長ハンドラ(byte形 `10|N|u16×(N+1)|u16`、Len=2*N+6)★ で処理。Len表の `0x10=1` は「誤りだが専用処理が上書き=inert」。
3. `scn_trace.py` は Len[]を runtime DialogueRuntime.cs から parse。★top-level walker が standalone 0x10 を 2*N+6 で扱うか Len=1 で進むかは未確認(要精査)★。

### 次sessionの手順(census-first、推測禁止)
- (a) ★standalone opcode 0x10=CHOICE が corpus(225 entry)のどこに実在するか census★。コメントは「§238」限定を示唆 ⇒ ★§238以外に出るか★を walker で数える(naive byte scanはoperand混入で不可)。
- (b) 出現0件 or §238のみ ⇒ ★retro-sweep はmoot(Len[0x10]=1は誰もwalkしていない)= 札クローズ★。
- (c) §238以外にN>0件 ⇒ 影響先(var[110] 93件/entry175候補24/24/線形被覆99.7%)を ★corrected 0x10(2*N+6)で再walk★し diff。★worker交差検証必須(この数は敵対レビュー領域)★。
- (d) worker2の `opcode_lengths_exe.json` 0x10=1 も同時に監査(scn_traceとは別経路の可能性)。
- ★『機構確定後はretro-sweep』の実例だが、実行はworker apparatus + PRESIDENT gate で。Len表修正の可否はPRESIDENT保持(registry §2)★。
