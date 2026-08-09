# SCOREBOARD — G dispatch(測定された改善)2026-07-12

> ★**PRESIDENT 裁定: 2 種類の数字を足すな**★ — headline は「コード改善」と「測定是正」を**分離**して表記する。混ぜると自分の成果を水増しする([[feedback_verify_what_green_asserts]] の 9 着の最後の変奏)。

## 正しい headline

> ★**PRESIDENT 裁定 2026-07-12: 『351/469』を再定義せよ（過大評価の是正）**★ — この数字は ★**PC 列 = 制御流次元のみ**★ の忠実度であって、★**挙動忠実度ではない**★。worker2 実証: 0x1B 等は ★制御流を変えず state 書込だけを gate する★ → C# と実機が state で食い違っても PC 列は完全一致 = ★PC 次元で永久に検出不能★（現 PASS の 85 section が 0x1B 該当）。⇒ ★**state 次元 diff を正式な第2 gate に採用**★。PASS = **PC 列 clean ∧ state 書込列 clean**。片方だけ = **PARTIAL（次元名付き）**。★state を測ると 351 は【下がる】公算 = regression でなく『これまで測れていなかった次元での実態』★（[[feedback_identity_is_not_evidence]] の測定器是正で数字が動く と同型）。**PC diff と state diff は別々に報告（合成スコア禁止 = 次元を潰すな を metric 自体に適用）**。

**clean diff = 351 / 469**（次元 = ★PC 列 = 制御流のみ★、初期状態 identity 確立後。★挙動忠実度は state gate 導入まで未測定★。0x71 land 済で 350→351）

| 区分 | delta | 中身 | 帰属 |
|---|---|---|---|
| **(A) コード改善** | 135 → 230(**+95**) | G1(0x1A +59 / 0x75 +34 / 0x55 ±0)+ G3(0x7C +1 / 0x26 +1) length fix | **C# コードを直した結果**。凍結 09fde5a で before/after、per-item 帰属 |
| **(B) 測定是正** | 230 → 350(**+120**) | 初期状態 identity 注入(worker3 snapshot → worker2 注入)。regression 0 | ★**C# コード変更ゼロ**★。あの 120 は最初から正しく、我々が誤って FAIL と呼んでいた |

★**(A)+(B) を「+215 の改善」と書いてはならない。** (B) は改善でなく、過去の誤測定の訂正。★

### ★帰属の判定基準(PRESIDENT 訂正 2026-07-12)= 分解テスト★
delta が (A) か (B) かは**分解**で決める: **コード変更だけで(測定を正した上で)gain が出るなら (A)。コードは元々正しく測定/setup だけ変えたなら (B)**。
- **(B) の例 = flag/var identity +120**: C# コードは元々正しく、初期状態を正すだけで一致した。**過小評価してよい訂正**。
- **(A) の例 = 0x24 RNG(下記 pending)**: C# は opcode を**未実装** = 実ゲームプレイに影響する本物の欠陥。seed 注入(identity 第3次元)は**測定可能にする前提**にすぎず、+N を生むのは 0x24 の**実装**。⇒ **(A) コード改善。identity を過小評価に使うな(水増しと逆向きの不正確さ)**。

## 残 FAIL 119(identity 確立後の real 残差)

| first-divergence op | 本数 | 性状 | 扱い |
|---|---|---|---|
| **0x19(RNG)** | ~78 | ★**Eval0x19 評価バグは【誤り】(H4 で撤回)**★。真因 = 直前 op **0x24 = BIOS A(0x2F) rand()**。C# 未実装で var=0 固定。★非決定的 = 差分テストの原理的限界★ | ★**一時的 BLOCKED**（RNG desync、seed 注入で測定可能化。恒久盲点ではない）。0x24 実装 = (A)コード改善(下記)★ |
| 0x10 | 13 | 未分類(非 RNG) | worker2 triage 中(決定的なら (A) 候補) |
| **0x17** | 11 | ★cross-scenario 忠実 cutscene 機構(覚醒 4-hop と同一)★ | ★**触るな・保全せよ**（下記）★ |
| 他 | 2(0x71/0x18) | 個別(非 RNG) | 後続 |

### ★pending (A): 0x24(RNG opcode)実装★
- 真因 = C# が op 0x24 を未実装。実機 = `var[dst] = (rand()*(arg+1))>>15`、rand=BIOS A(0x2F) LCG。**実ゲームプレイに影響する本物の欠陥 = (A) コード改善**。
- 前提 = worker3 の **per-launch RNG seed capture**(identity 第3次元)+ 受け入れ gate(捕った seed で rand 再構成 → 実 0x24 write と一致 assert 80 launch、通らねば渡すな)。
- gate 通過後: seed 注入で ~78 を決定的化 → 0x24 実装 → 真の PASS/FAIL。**+N は (A) として正当に主張する**(identity は測定前提、gain は実装由来)。entry178 は 0x24 実行 0 = cutscene 安全。

## ★0x17 の 11 trace = 忠実化の設計図(保全対象)★

- 163_054 → scenario178 §0x37 → pc 0x07CC = **覚醒 cutscene の 4-hop と同一機構**(MAPHEAD + return-record + 0xFB + 0x17)。remake が欠く忠実機構そのもの。
- ★**trace が spec になった**★: 将来の忠実化 dispatch は、この 11 本の原盤 trace を **oracle** として使えば、user 実視覚の前に正しさを測れる。
- 今は**触らない**（直すと user 実視覚 PASS の cutscene を壊し得る）。worker3 が named artifact として保全。

## BLOCKED / coverage 債務(バグではない)

- **0xFE return-stack**: 実機全数で途中 pop = 0（(scn,key) 注入起動 = 空 stack）。現 authority で**非 exercise = BLOCKED**。worker2 前報の「~70 section block」は**撤回**（バグでない）。boot authority で exercise される見込み。
- **stat 依存 0x19 = 15 本**（sub3 13 / sub1 2）: 注入では 0/15 flip（想定どおり）。stat getter 未実装 = 7% lever、優先度低。

## 不変条件（全 phase 通し）

push ゼロ（user 専権）/ cutscene runtime 不触（entry178 = user 実視覚 PASS 資産）/ frozen authority 09fde5a 不変 / staleness guard 有効。
