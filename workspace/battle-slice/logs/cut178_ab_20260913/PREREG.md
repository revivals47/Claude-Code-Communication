# 事前登録 — cut178 A/B（2026-09-13・撃つ前に固定）

**変える変数は 1 つだけ** = env `W1_GATE_NEVERSTOP`（`DialogueRuntime.cs:2432`）。code / tree / data は触らない。

## 予測（★走らせる前に書いた★）

- **control（gate ON = 既定）** — `pages=0 / chars=0 / termPc=0x1A / RESULT=FAIL` ＋ `[VM-GATE] ... op=0x6C ... pc=0x1A` が **1 件**。
  **これが再現しなければ 比較の地面が step2 と違う ⇒ treatment の結果は読まない**（comparator の陽性対照）。
- **treatment（`W1_GATE_NEVERSTOP=1`）** — 3 つに分ける:
  - **P1 = gate 停止が唯一の原因** ⇒ `pages=66 / chars=1601 / termPc=0x1315 / garble=0 / RESULT=GREEN`
  - **P2 = 第 2 原因が在る** ⇒ 完走するが 3 値のどれかが baseline と不一致（Len 表 19 件訂正 等の寄与）
  - **P3 = 仮説集合の外** ⇒ 完走しない（別の停止 / `choiceBreak=True` / guard 発火 / exception）
- **P1 でも言えないこと** = 「`0x6C` を実装すれば GREEN」。NEVERSTOP は `0x6C` を **8 byte 読み飛ばす**だけで、
  **0x6C が本来する仕事を していない** ⇒ 示せるのは **「RED の原因は gate の停止だけ」**まで。

## 機構の確認（code 直読・予測の根拠）

`UnsupportedOpcodeGate` が false を返すと `break` → `_pc += len` ⇒ **`9d90aabf` 以前の「黙って len consume」と同形**。
`Len[0x6C]=8`（worker1 EXE 直読 TSV hash `fb8086670e419e78462f449cf880cc2ef7e21e9d` と GUARD 一致枠）。
