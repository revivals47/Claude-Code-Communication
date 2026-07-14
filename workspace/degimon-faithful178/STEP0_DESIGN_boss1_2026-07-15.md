# step0 設計判断 doc(boss1 起案、2026-07-15 02:4x → PRESIDENT 承認 gate)

prereg = PREREG_3_IMPL_boss1_2026-07-15.md(FIXED + GO 微調整 2 点反映済)。
起案前の ground truth 直読(boss1): GameState.cs(State/、care 節 + GameClock)/ care two-tier memory 本体 /
worker2 preflight `c63b14f` / W-A `6a78786` / worker1 x-check `27f3fa7` / docs/RE_time_day_system_2026-06-17.md の実在確認。

## 裁定 (0a): script opcode 0x36 経路の帰属

★**単一推奨: two-tier のどちらにも入れない — 「care-tick に触らない第 3 の writer」として実装する**★

- **形**: DialogueRuntime の case 0x36 → `PartnerState` の**新規 public method**(例 `ScriptStatSub(statId, amount)`)を呼ぶ。
  clamp は既存 `StomachMin=-100` 定数を共有(値の重複定義禁止)。**TickCareHour / 2 確率系統 / golden vectors には一切触らない**。
- **理由**:
  1. **実機が既にそうなっている** — care-tick(0x800A76A0 系)と 0x36 handler(0x800ECF48)は別 PC の別機構。
     忠実 = 「帰属の変更」ではなく「並存する writer の追加」。tier 構造(Fullness/Stomach/Condition + ラッチ/飢餓)は不変。
  2. **既 land 資産の構造的保護** — care golden 37 vector + harness 19/19 は TickCareHour 系の挙動を凍結している。
     新 method 分離なら care harness は 0x36 経路を通らず、**非退行が構造で保証される**(PRESIDENT の care 保護 gate を
     「気をつける」でなく構造で充足)。
  3. **stat 選択の honest 実装** — 0x36 の対象 stat は operand→`0x800F53C8`(未同定)で決まる。
     ★mapping は「sweep で実測された operand 値 → 実測された書込先(D3A/D42)」のみ実装し、
     **未対応 operand は loud log + no-op(silent fallback 禁止)**★。mapping の実測抽出 = worker3 の既存 sweep jsonl から
     (新規 run 不要)。未対応 operand が ③ の差分テストで FAIL を出せば、それが次の RE トリガー(検出器設計)。
- **acceptance への反映**: care harness 全緑(既存)+ 新規 unit test(0x36 経路の減算+clamp)+ 差分テストで D3A/D42 次元の FAIL 減。

## 裁定 (0b): E2E0 の二重意味(『日カウンタ ++』vs『0x37 set』)

★**単一推奨: 矛盾ではなく「同一 slot への 2 writer class の共存」として両実装 — 既存 ++ は不変、0x37 set を追加**★

- **前提の解消(boss1 実査)**: C# の『日 ++』は assumption ではなかった —
  **docs/RE_time_day_system_2026-06-17.md の RE 裏付き**(分 0x8013E29A wrap60 → 時 0x8013E298 wrap24 → 日 0x8013E2E0 ++、
  1 game-day = 実 24 分 LIVE 裏取り。doc 実在を boss1 確認済)。
  つまり原盤の E2E0 には**時刻繰り上げ(++)と script 0x37(set)の 2 writer class が実在**する。
  『時刻を script が設定できる時計』は矛盾でなく原盤の形 — set 後の繰り上げは同一 slot を読むので自然に整合する。
- **形**:
  1. 0x37 handler(DialogueRuntime 新 case)= operand byte1 を `GameClock.Day` へ **set**(実機 = lbu→sh、値域 0-255 の
     値保存 copy を x-check 済)。既存 `AdvanceMinutes` 繰り上げ経路は**不変**。
  2. **E2DE = 新規 raw byte slot を GameState に新設**(C# 不在は preflight 確定)。0x37 の operand byte0 を set。
     ★意味論を発明しない★ — 時刻 block 隣接(E298/E29A/E2DE/E2E0)だが実機 read 側の同定まで「保持するだけの state」
     (表示・分岐に使わない)。H2 で state-only INPUT 実証済ゆえ、**保持自体が忠実度に寄与**(将来の read 対応の受け皿)。
- **acceptance への反映**: unit test『0x37 set 後、AdvanceMinutes の繰り上げが set 値から継続する』+
  差分テストで E2DE/E2E0 次元の FAIL 減。

## 共通の含意

- どちらの裁定も「**既存経路の帰属変更ゼロ・追加のみ**」= リスク台帳の『silent 帰属変更』を構造で封鎖。
- 実装 file = DialogueRuntime.cs(case 追加)+ GameState.cs(method/slot 追加)のみ = worker2 の file 境界内。
- 初期値供給(baseline C からの capture)との関係: E2DE/E2E0/D3A/D42 の初期値は step1-2 の capture が供給し、
  本裁定の維持経路はその上で動く(prereg §1 の順序どおり)。

承認いただければ step1(baseline C 生成 + stat struct 輸入)と併走で worker2 へ 0x36/0x37 実装を dispatch します。

## 承認記録(PRESIDENT、2026-07-15 02:5x)= ★両裁定 APPROVE + 追加条件 2 点★

1. (0a) 追加: ★loud log には operand 値 + 実行文脈(entry/section/pc)を含める★ — FAIL 時の RE trigger が
   そのまま着手材料になる形で。
2. (0b) 確認条件: ★E2DE/E2E0 とも baseline C からの初期値輸入対象に含まれることを step1 の輸入 list で明示★
   (受け皿を作って空のままにしない)。
3. 併走 dispatch = GO(step1=worker3 / 0x36・0x37 実装=worker2 / x-check 準備=worker1)。
   ★本 arc 最初の game code commit★ — small commits + 非退行 gate(CutsceneVerify178 + care harness)を各 commit で。

## ★裁定 (0b) の実装形 = 撤回・再設計へ(2026-07-15 03:3x、worker2 の実装前全長 RE による blocker)★

- **何が誤りだったか**: 『0x37 = operand byte を E2DE/E2E0 へ無加工 copy』は **handler 後半だけを見た不完全 RE**
  (worker2 W-A `6a78786` 自己申告)。全長 RE の実際 = operand は **var index 1 個**。handler は
  GetVar(idx..idx+3) の 4 値を date 化(0x800F13CC 変換)し、現在の時計 4 成分と比較、
  ★時間前進なら 0x800AB40C(care-tick 前進 = D54 writer 関数)を呼び★、4 slot へ store する。
- **boss1 検算(統合推論、worker2 の RE 待ちで確定)**: 比較 slot の gp-0x6b74 / gp-0x6b72 =
  **0x8013E298(時)/ 0x8013E29A(分)** = RE_time_day_system の時計 slot と一致
  ⇒ **0x37 = SET_DATETIME(var 由来の時計 4 成分 set + 時間前進時の care catch-up)**の読みが整合。
- **生き残るもの / 死ぬもの**: 『E2E0 = 2 writer class の共存』の骨格と taxonomy (i) 判定 = **不変**。
  死んだのは実装形(値の由来 = operand → var bank / side effect なし → care-tick 呼出あり)。
- **x-check への波及(methodology 台帳、新規)**: worker1 x-check の claim3 CONFIRMED は store site の値保存性としては
  正しいが、**source の帰属(operand か var か)は両実装が同じ切り取り窓を共有して見えていなかった** —
  ★**2 実装収束は『窓境界の blind spot』を検出しない。実装前の handler RE は全長(prologue→epilogue + 呼出先 1 段)を標準とする**★。
- **処置**: 0x37 実装凍結(worker2 は実装ゼロで停止 = 正しい)。0x36 = tail 0x800EF7D0 の全長 RE 完了後に続行 GO。
  追加 RE 2 件(0x800F13CC 変換式 / 0x800AB40C 呼出規約)→ 設計判断 doc v2(0b-v2)→ PRESIDENT 承認 → 実装。
  care 保護 gate の解釈(『変更は NG・呼出追加は OK』か)= PRESIDENT 裁定要請済み。
