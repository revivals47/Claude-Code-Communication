# PRESIDENT dispatch (2026-07-12 / 第3便) — G: 測定された改善を出す

## 前提（F1 dispatch の到達点）

- **authority = 改造 DuckStation**（任意 entry を launch して原盤 VM の event trace を採取できる）
- **baseline = clean diff `135 / 469`（PC 列という次元のみ）**。これが動くかどうかで改善を判定する
- main = `03f9dcd`（local、origin より 31 ahead、**push ゼロ**）
- **cutscene(entry178) は user 実視覚 PASS 済の資産。壊す変更は user 確認なしに land しない**

## このフェーズの目的

**「改善した」を、測定で言えるようにする。**
今日までの 9 回の length fix は「読んで直して、目に見える失敗が出て初めて誤りに気づく」ループだった。
**今回は、直す → 測る → 数字が上がったことを示す、をやる。**

---

## ★順序が決定的。この順で行う。並行させるな★

### **Step 0（最優先・前提条件）— G7: authority の `flag_w` 破損を直す**

**なぜ最初か**: G2(BodyStart) 修正の眼目は「**落ちていた SET_FLAG / CLEAR_FLAG / SET_VAR が復活すること**」。
だがその次元を計測する **authority 側の `flag_w` 捕捉（ra-gate）が壊れている**（F1 で実証: PC 列一致なのに flag_w が空）。
⇒ **壊れた測定器で修正を検証してはならない。** これは今日ずっと潰してきた構造そのもの。

- ra-gate が SET_FLAG/CLEAR_FLAG の write を落としている原因を特定し、**実機 trace が flag_w を正しく出すようにする**
- **検証**: PC 列に `0x1C`/`0x1D`/`0x1E` が現れる section で、**対応する flag_w / var_w イベントが必ず出ること**を機械 assert
- **これが通るまで Step 2 の検証はできない**（Step 1 は PC 次元だけなので先行可）

### **Step 1 — G1: length fix（`0x1A` / `0x75` / `0x55`）**

- `0x1A` = text が operand の可変長（**FAIL 293/469 の単一最大要因**）
- `0x75` = 4 → 12 / `0x55` = 2 → 8（実行 + EXE 直読で確定済）
- **1 件ずつ入れて、1 件ずつ測れ**。まとめて入れて net を見るな（「2件減 = 実は 8喪失/6獲得」の教訓）
- **各 fix ごとに clean diff を測り、`135` からいくつ動いたかを報告せよ**
- **下がったら止めて報告せよ**。下がることは失敗ではなく情報だ

### **Step 2 — G2: BodyStart = Word0（`4 + Word0` は誤り）**

- **225 entry すべてが先頭命令を skip している**。うち 9 entry は skip 対象が **state 書き込み**（entry189 の SET_FLAG(flag 0x4C) 等）
- **Step 0 完了後に実施**。flag_w が正しく出る authority で、**state 次元でも diff を取れ**
- **PC 列 + state 書き込み列の 2 次元で測る**。片方だけで「改善した」と言うな

### **Step 3 — 残り opcode の length 監査（候補 6 件）**

`0x2B` / `0x52` / `0x7C` / `0x38` / `0x72` / `0x26` = execution-delta で候補に挙がったが未確定。
**handler BP（PC 増分）+ EXE handler 直読の両方で確定させよ。** 片方だけで断定するな。
到達しない opcode は **「原理的に未検証」と honest に残せ**（190/256 未検証の現状を隠すな）。

---

## ★cutscene(entry178) の扱い — ここが最大の risk★

**現在の cutscene は「偶然の連鎖」で動いている**（fall-through が §0x37 の物理位置とたまたま一致）。
⇒ **G1/G2 で decode を正すと、その偶然が崩れて cutscene が壊れる可能性がある。**
⇒ しかも remake には忠実化に必要な機構（**MAPHEAD / return-record stack / 0xFB / 0x17 JMP_SEC**）がまだ無い。

**★だが今回は、user に見せる前に予測できる★**:
- **entry178 の C# trace と原盤 trace を、各 fix の前後で diff せよ**
- **原盤に近づいたのか / 離れたのか / 別の壊れ方をしたのか** を trace で判定する
- **「壊れそうだ」と分かった時点で、user に見せる前に PRESIDENT に上申せよ**

**判断の分岐**:
- **(a) trace が原盤に近づき、cutscene も動く見込み** → user 実視覚を依頼して land
- **(b) trace は近づくが、cutscene が壊れる見込み** → **忠実化機構（MAPHEAD + return-stack + 0xFB + 0x17）を同時に入れる必要がある = 別 dispatch として上申**。半端に直して壊すな
- **(c) trace が離れる** → 我々の理解が誤り。**H4。止めて報告せよ**

---

## 必須要件

1. **1 件ずつ入れて 1 件ずつ測る。** net を見るな、per-item に分解せよ
2. **数値には必ず「何の次元で測ったか」を添えよ**（PC 列 / state 書き込み / 終端理由）
3. **PASS / FAIL / BLOCKED / INVALID の 4 分類を維持**。BLOCKED を PASS 側に混ぜるな
4. **guardrail はコード強制のまま**（override marker / dims.txt 宣言外は既定 BLOCKED）
5. **壊れた authority で検証するな**（Step 0 が Step 2 の前提である理由）
6. **codex 反証査読**: G1 の length 値、G2 の影響範囲判定。**締めフェーズで打ち切るな**
7. **push 禁止**（user 専権）。commit は local 可
8. **cutscene を壊す変更は、trace で予測して PRESIDENT に上申してから**。独断で land するな
9. **少数サンプルから一般化するな。** 「これで直った」は母集団（469 section）で測ってから

## 成功基準（数値）

- **Step 0**: PC 列に 0x1C/0x1D/0x1E が出る section で、flag_w/var_w が **100% 出る**こと（機械 assert）
- **Step 1**: clean diff が **135 から N へ**。**各 fix の寄与を個別に報告**
- **Step 2**: clean diff（PC 列）と **state 書き込み次元の一致数**を両方報告
- **Step 3**: 候補 6 件を「確定 / 未到達」に全件分類

## 進行

- boss1: phase 移行ごとに `./agent-send.sh president` で中間 ack
- **clean diff が baseline 135 を初めて超えた瞬間、即座に報告せよ。それが「測定された改善」の第一号だ**
