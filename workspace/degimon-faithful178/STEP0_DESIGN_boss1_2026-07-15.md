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

## care 保護 gate の解釈裁定(PRESIDENT、2026-07-15 03:4x)= ★『変更は NG・呼出追加は OK』承認 + 条件 2★

- gate の目的 = **検証済み挙動(golden 37 が assert する method の伝達関数)の保護**であって、忠実な新規利用の禁止ではない。
  原盤が 0x37 で care catch-up を呼ぶなら、呼ぶのが忠実。
- **条件 1 = canonical entry 経由のみ**: harness が検証している public method をそのまま呼ぶ。
  内部 logic の複製・bypass 禁止(呼出追加が『第 2 実装』に化けたら gate の意味が消える)。
- **条件 2 = catch-up 意味論の非退行 + 新規 verify**: 既存全緑に加え、★catch-up 経路自体の検証を新設★ —
  N 時間前進が原盤 loop 意味論(0x800AB40C の引数・単位・loop 回数)どおりの tick 適用回数になるか。
  ★境界の二重適用(set 直後に通常 tick が再発火する等)の意味論も RE から確定させて test に含める★。
- methodology 教訓の採録承認: ★『2 実装収束は【共有された窓境界】の blind spot を検出しない — 収束の独立性は
  方法だけでなく観測窓にも要る』★(per-layer 独立監査の窓版)。
- boss1 即時裁定 2 件(0x36 続行 GO / 0x37 停止+追加 RE)= 追認。0b-v2 提出待ち。

## 0x36 tail finding + (A) core-only 裁定(2026-07-15 03:5x。全長 RE 標準の初回配当)

- **finding(worker2 全長 RE)**: 0x36 の tail 0x800EF7D0(毎回 unconditional)= ★Fullness(D54)clamp +
  ラッチ解除側の D18 write + D58 zero★(care-tick 関数は呼ばない = 別 path)。『bare subtract+clamp』は不完全だった。
- **boss1 裁定 = (A) core-only 実装 + tail は 0b-v2 へ合流**(worker2 推奨に同意): 0x36 の diff 対象次元
  (D3A/D42)は core で充足、tail の書込先(D54/D18/D58)は 0x37 catch-up と同じ『時計/care 相互作用』group。
- **条件 = honest gap の構造化**: ①実行時 loud log に tail omitted 明記 ②IMPL_NOTES に gap entry +
  『diff-test の D54/D18/D58 次元 FAIL は既知の追跡 signal』宣言 ③bit2 ラッチ = RE claim label のまま
  (bit0x40/bit0x10 と混同しない、0b-v2 で確定)。(B) の前提確認(canonical entry の存在)= 0b-v2 材料。
- **0b-v2 の scope(確定)**: 0x37 SET_DATETIME(変換式 + catch-up 規約 + 境界二重適用)+ 0x36 tail
  (Fullness clamp + ラッチ解除)+ canonical entry 対応表 = 『時計/care 相互作用』の一括設計。

## 0x37 追加 RE 結果(worker2 `8dc865d`、2026-07-15 04:3x 受領)= 0b-v2 の主材料

- **(a) 変換式確定**: serial = minute + hour×60 + day×1440 + month×43200(30 日/月)。
  4 var = [month, day, hour, minute]。★**E2DE = month slot と意味論確定**(『raw byte slot・意味論を発明しない』は
  RE で上書き — 発明でなく実測で埋まった)★。store 対応 = E2DE=month / E2E0=day / E298=hour / E29A=minute。
- **(b) catch-up 規約確定**: 0x800AB40C(deltaHours 引数、**単発 1 回・一括適用**、per-hour loop ではない)。
  ★TickCareHour とは別関数 = 『care 累積器の N 時間一括前進』★。
- **(c) 境界二重適用 = 起きない**(handler 順序: serial 計算 → catch-up(旧 slot 基準)→ slot store。
  AdvanceMinutes は real-time 駆動の別経路 = set 後 minute から通常進行)。
- **(d) C# 対応の残 gap**: E2DE=month 新規 slot / Day・Hour・Minute は private set → SetDateTime 追加要 /
  catch-up の C# 対応 method なし = 新規(呼出追加 OK 枠だが、★catch-up が書く 0x80141D6E/D60/D62 の C# field
  対応 = 未同定★)。
- **⇒ 0b-v2 起案前の残 RE 1 束(worker2 へ発注)**: (e) 0x800AB40C の全 store list + D6E/D60/D62 の実体
  (全長 RE 標準の適用。未同定は未同定のまま可 — その場合 catch-up 実装は identified 部分+honest gap の段階案になる)
  + (B 前提) 0x800EF7D0 の書込先に対応する既存 canonical entry の有無(0x36 tail 用)。

## 0b-v2 への PRESIDENT 設計 note(2026-07-15 04:4x、条件 2 の verify 形の確定)

- ★catch-up test は『N 時間前進 = TickCareHour N 回』を assert **しない**★ — 実機は per-hour loop でなく
  deltaHours 単発一括。**assert すべきは『catch-up 関数 1 回・delta=N の一括適用が原盤 0x800AB40C の変換と一致』**。
  loop 意味論を仮定した test は偽 FAIL 製造機(意味論の実測が先、test はそれに従う)。
- 境界二重適用なし(旧値基準 1 回 + real-time 別経路)の機構説明を条件 2 の test 設計にそのまま使う。
- E2DE 事案の教訓の言語化(PRESIDENT): ★『発明しなかったから、正しい意味が入る余地が残っていた』★ —
  未同定 slot は raw 保持が正解(意味論は RE が埋める)。

## ★8dc865d の訂正(worker2 自己申告、`b4a99c0`)+ 残 RE 結果 — 0b-v2 材料完備★

- ★**訂正**: 0x800AB40C は『小型の別関数・hunger/latch なし』ではない — **全長 RE(末尾 0x800AB7B8、jr ra 1 箇所)=
  care-hour 一括前進の【大型 care 本体】**★。store list 13 field = Fullness(D54)/IdleHours(D4A)/latch-precond(D2A)/
  D58/D56/D6A/D6E/D60/D62/D38/D30/D50/D4E。時刻部 = D6E+=delta / D60-=delta / hour+=delta(≥24 で D62 日累積へ)。
  ★内部 loop=0 = bulk(delta-scaled 算術)★ — 単発呼出・一括適用の claim は維持。
  **= 部分 RE 誤りの 3 例目**(0x36 tail / 0x37 / 今回)。worker2 は以後 catch-up 系を最初から全長 RE と自己規範化。
- ★**0b-v2 の核 = 意味論の乖離リスク**: C# TickCareHour = per-hour(1 時間ずつ+clamp)/ 0x800AB40C = bulk 一括式。
  **『N×TickCareHour == bulk(N)』は未検証で、多時間 jump では乖離し得る**(per-hour clamp の反復 vs 一括減算)★。
- **(B 前提)0x800EF7D0 の canonical entry = 不在確定**: ClampCareMeters は Stomach/Condition のみ / CareAction の
  latch は bit0x40 = ★0x36 tail の bit2(0x4)とは別 latch(混同禁止)★ / D58 = C# 不在。⇒ 新規 method 要。

## ★0b-v2: 『時計/care 相互作用』一括設計(boss1 起案、2026-07-15 04:5x → PRESIDENT 承認 gate)★

### (1) 0x37 = SET_DATETIME(単一推奨)
- DialogueRuntime case 0x37: operand = var index。GetVar(idx..idx+3) = [month, day, hour, minute]。
  **handler 順序 = 原盤どおり**: serial 計算(変換式は RE 済)→ 旧値基準で catch-up 1 回(時間前進時のみ)→ slot store。
- C# 形: `GameClock.SetDateTime(month, day, hour, minute)`(bulk setter 1 個を追加、既存 private set は不変)+
  **`Month` = GameClock 新規 slot**(E2DE、意味論 RE 済)。E2DE/E2E0 初期値 = step1 輸入 list 済(承認条件)。

### (2) catch-up = ★bulk 式の新規 method `CareBulkAdvance(deltaHours)` を単一推奨★
- **理由**: (i) 原盤自体が per-hour tick とは別の bulk 機構 — 忠実対象は**その式そのもの** (ii) 『N×TickCareHour ==
  bulk(N)』は未検証 = 等価仮定の per-hour 呼び回しは assumption-based (iii) gate 条件 1(内部 logic 複製禁止)に
  非抵触 — TickCareHour の複製ではなく、**別の原盤関数の第 1 実装**。
- **実装様式 = per-field disposition table 必須**: store list 全 13 field を『implement(C# 対応あり or 算術 RE 済)/
  raw-slot 新設(D6E/D60/D62 等 = 算術は RE 済・意味論未同定 → E2DE 方式で raw 保持)/ declared-gap(宣言付き omit)』
  の 3 分類で実装 note に固定。★silent 欠落禁止 — omit は宣言 + 差分テスト次元の追跡 signal 化★。
- **oracle**: care golden 方式を踏襲 — **bulk 式 golden vector を新設**(EXE 算術から導出、worker1 が blind x-check)
  = 単一 oracle。
- **characterization 測定**: bulk(N) vs N×TickCareHour の乖離を test で記録(実装決定用ではない —
  乖離があれば『per-hour 案は不忠実』の証明、なければ回帰安全性の記録)。

### (3) 0x36 tail = 新規 method(Fullness clamp + bit2 clear + D58 zero)
- Fullness clamp(form 表 +8 の FullnessMax、RE 済)+ **D18 bit2 clear = bit 操作のみ忠実実装**(意味論未確定のまま、
  ★bit0x40(要ケア)とは別 latch と code comment で明記★)+ D58 = 新規 raw slot に zero。
- 呼出 = 0x36 case の core 直後(原盤どおり毎回 unconditional)。land 後、c229d7f の『tail omitted』loud-log を除去。

### (4) verify(PRESIDENT 条件 2 + 設計 note の形)
- catch-up test = ★『catch-up 関数 1 回・delta=N の一括適用が原盤 0x800AB40C の変換(golden vector)と一致』★。
- 二重適用なし test(set 後 AdvanceMinutes が set 値から通常進行)。既存 care harness 37/37 + CutsceneVerify178 全緑維持。
- 差分テスト: E2DE/E2E0/E298/E29A + D54/D18/D58 次元の FAIL 減を per-step 目標に。

### (5) 残 unknown(宣言)
- bit2 の意味 / D56・D6A・D38・D50・D4E の semantics(disposition table で宣言処理)。RE は実装ノート段階で
  worker2 が per-field に判定、未同定は raw-slot or declared-gap(発明ゼロ原則)。

## ★bulk golden vector = 単一 oracle 確定(boss1 裁定、2026-07-15 06:0x)★

- **unblind diff(boss1 実施)**: worker2(9c6b6de)vs worker1 blind 導出(ef67d1a、EXE 独立・不読)=
  ★**12 field × 7 vector 全て bit-exact 一致**★(divergence 点 Fullness once 減・day rollover 境界・gate 系込み)。
- **hour の食い違い裁定**: worker2 table 文言『hour += delta store』は誤記(read-for-rollover を store と誤記)—
  ★EXE 目視確認 = E298 は lh×3 / sh×0 = read のみ★(worker2 自己確認 `347d0f8`、worker1 blind assert が正)。
  vector は元から正(hour 非収載)。
- ★**実装 contract 確定**: CareBulkAdvance は care 累積器 12 field のみ更新(D60/D6A = declared-gap loud-log)。
  **時計 4 slot(month/day/hour/minute)には一切触らない** — 時計 store は 0x37 handler の step③(SetDateTime)の責務★。
  = SetDateTime(時計)と CareBulkAdvance(care)の責務分離が原盤構造から直接導かれた。
- **oracle 化**: care_bulk_golden_vectors.json(9c6b6de)を単一 oracle と宣言。worker1 の bulk_model_worker1.py は
  独立検算器として保存。→ ★実装解禁(worker2、3 commit + 3 系統 gate)★。
