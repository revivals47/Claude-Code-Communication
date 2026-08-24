# ★未発行 DRAFT★ — 次 phase の設計問（s2 を完全 observable にする道が静的解析で在るか）

★これは dispatch ではありません★。PRESIDENT の指示（#861-A 追認便）で ★設計だけ★ を先に置いたもの。
★発行 timing は PRESIDENT が指示する★。boss1 は本 doc を worker に渡していない（2026-08-25 04:10 時点）。

## 0. なぜこの問いが唯一意味を持つか
codex の NO-GO 本文（逐語）= 『If the project decision actually depends on resolving the conditional 0x66 order,
**pause live capture until the experiment can observe s2 or an equivalent complete proxy**.』
∴ **park 解除の条件 = s2 または同等の「完全な」proxy の獲得**。∴ 次 phase の問いは 1 本だけ。

現況（worker3・#855-C）= 代理候補 `[X+0x64E]` = `0x80146746` が **0 になる**。既知の書き手のうち
**0 を書くのは `0x8005CA7C` だけ**（他は 3 / 1 / 0xB）。★但し **−1 と 0 を分けられない**★ ⇒ run3 の条件
（`s2 == −1`）には**不足** ⇒ **完全 proxy ではない**。

## 1. 設計問 3 本（★撃たずに考える★・全部 静的解析＋読解のみ）

### (a) −1 と 0 を分ける第 2 の観測点が静的に存在するか
- 手 = `0x8005CA7C` を含む basic block を逐語で読み、**−1 経路と 0 経路の store 集合の対称差**を全列挙する
  （分岐 2 本の side effect を **sink 全列挙**：値は分岐しなくても state へ流れる）。
- 既知の材料 = 補助 `[0x80141D3A] += 2` は **s0 = 0 の経路だけ**・外部の定数差分 7 件に +2 は無い
  ⇒ 組み合わせで分かれる公算（★但し 変数差分 3 ＋ 決まらない 4 = 7 件が射程外★）。
- ★閉じ方の札★ = **材料**（EXE image 全域の store 列挙。既知の限界 = base が実行時値の store 13,977 件は射程外）。
- 3 値 = ①分ける store が在る（**address ＋ 値 ＋ どちらの経路か**）②両経路の store 集合が一致（分けられない＝確定）
  ③決まらない（overlay 呼び出しを跨ぐ）。

### (b) 「`0x8005CA7C` 以外に 0 を書く経路が overlay 側に無い」を **開封禁止下で**どう示すか
- ★正直な前提★ = **一般には示せない**（overlay を開けないため）。∴ 問いは「**どこまでなら示せるか**」。
- 使える材料（開封不要）= ①loader 表 16 本の **VA 範囲と size**（#648-C）②EXE 側から overlay へ渡る entry の全列挙
  ③その場面で load され得る overlay の絞り込み（scene / 常駐前提）。
- ★閉じ方の札★ = **格の限定**。書けるのは『**EXE image 内では 0 を書くのは 1 件**（literal-scan の射程内）』まで。
  ★「overlay にも無い」は書けない★（memory: 打ち切られた list の不在は否定でない）。
- 3 値 = ①当該場面の overlay を **1〜2 本に絞れる** ②絞れない ③**絞るには開封が要る**
  ⇒ ③なら ★開封禁止（#646-X）の例外申請として PRESIDENT へ上申★（**boss1 は単独で開けない**）。

### (c) s2 が memory に落ちる瞬間（spill）が静的に存在するか ★← 本命★
- 原理 = MIPS ABI で `s2` は **callee-saved**。∴ 呼び先の prologue で `sw s2, off(sp)` が在れば
  **register が stack slot に落ちる** ⇒ **poll only でも読める形に化ける可能性**が在る。
- 手 = ①`0x8005CA7C` の**呼び手**を全列挙 ②各 prologue を逐語で読み `sw s2` の **offset** を取る
  ③その場面の **call depth が一定なら sp が固定** ⇒ **絶対 VA に落ちる**かを静的に確かめる。
- ★閉じ方の札★ = **原理**（ABI）＋ **材料**（prologue の逐語）。
- 3 値 = ①固定 VA に落ちる（**address を出す** ⇒ poll 可能）②sp 依存で動く（**寿命と幅を出す**）③到達不能。
- ★注意★ = ①が出ても **「その瞬間を poll で掴めるか」は別問題**（poll 間隔 vs 寿命）。
  ★2 段に分けて評価する★（存在 → 捕捉可能性）。

## 2. 発行時に付ける規範（boss1 の分）
- ★経路★ = 報告は必ず `./agent-send.sh boss1`（pane 出力は boss1 に届かない。#856-C で踏んだ）。
- ★枠★ = 数には枠を添える（address / containment / control-flow / base の 4 枠）。
- ★不変★ = remake code 0 行 / **emulator run 0 本** / compile 0 / push HOLD / overlay 開封禁止 / 視覚凍結 /
  read only / poll only。★静的 python は不変の対象外★（PRESIDENT 確定）。
- ★3 本を独立に★ = (a)(b)(c) は互いに待たない。1 本が詰まっても他を進める（#850-C の体制）。
