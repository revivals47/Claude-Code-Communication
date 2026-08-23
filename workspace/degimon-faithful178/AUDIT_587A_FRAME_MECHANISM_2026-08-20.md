【background 監査 session → boss1・★#587-A と #585-C の食い違いの「機構」を source で特定★・★Unity run 0 本★】

★裁定ではありません・便番号なし・run 許可も GO も私の座ではありません★

■ 0. 読んだ器と枠（★これを書かないと検算不能★）
・tree A = `/home/ken/Desktop/Digimon/degimon_world_remake-p2w1`（**HEAD=ba025afa**・`git status --short` 空）
・tree B = `/home/ken/Desktop/Digimon/degimon_world_remake-p2w3`（**HEAD=92e68947**・untracked 1 件のみ）
・★2 tree の `DialogueRuntime.cs` は byte 同一ではありません★（sha256 相違・diff 804 行）。⇒ ★下の §2 の 5 点は 2 tree 両方で個別に確認しました（相違は行番号だけ）★
・私が撃ったもの = ★DG.SCN の read-only 直読 1 本（python・書込なし）★。★Unity run 0 / compile 0 / 実装 0 / push 0★。書いた file = ★この doc 1 本だけ★
・★#585-C がどの tree で走ったかは特定していません★（harness `W3Cand86Decode.cs` は「走行後に撤去します」と宣言どおり撤去済）

■ 1. ★結論（3 行）★
1. ★worker1 の「両立する」は正しい★。★但し「entry 175 = 27 byte で逐字一致」は ★同じ数を別の機構で得ています★★（下 §3）
2. ★entry 175 の止め手は `0x10` CHOICE → `WaitingChoice`★ = ★jump policy と無関係★ ⇒ ★段 2（JUMPS=1 × 175）は構造的に空振りが確定★。★しかもその答えは #585-C の中に既に在ります（pass L 3 step/27 byte ＝ pass B 3 step/27 byte）★
3. ★entry 176 の pass L→B の変化（1 step/4 byte → 6 step/9 byte）を「JUMPS の効果」と読んではいけません★ = ★`_gateSeen` が `static` で、pass L が `0x7A` を消費済み★という交絡（下 §2-(e)）

■ 2. ★逐語の根拠★

★(a) DG.SCN 直読（両 worker と独立）★
・entry 175: `OFF=0x07E000` / `word0=0x000C` / `BodyStart=0x07E010`（= entry 相対 +0x10・worker3 の「BodyStart 0x10」と一致）
  先頭 byte 列 = `1A 00 「どの店にする？」 0D 00 00 00 | 1B FD | 10 | 03 ...`
  ⇒ `0x1A`(実消費 24) + `0x1B`(2) + `0x10`(1) = ★27 byte★、その次が `0x03`
・entry 176: `OFF=0x07F800` / `word0=0x001C` / `BodyStart=0x07F820`（= +0x20・worker3 の「BodyStart 0x20」と一致）
  先頭 byte = ★`7A`★（`Len`=4・★`case` 無し＝未実装★）⇒ ★worker3 の「1 step / 覆った byte 4」＝この 1 命令そのもの★

★(b) `0x10` は CHOICE で、そこで VM は待ちに入る★
・`const byte OP_CHOICE = 0x10;` / `case OP_CHOICE:` → `State = DialogueState.WaitingChoice;`（p2w1 :136/:1285/:1304、p2w3 :1578）
・worker3 の harness `Walk()` は ★`else if (rt.State == DialogueState.WaitingChoice) { choice = true; break; }`★ = ★選択肢に答えず break★
  ⇒ ★entry 175 の pass L の `WaitingChoice 1` はこれ★（`opGuard 0` は「未実装 opcode で止まっていない」の意味ではない＝下 (d)）

★(c) worker3 の step / 覆った byte は単一規約（停止命令を含む）★
・`TraceRecord(_pc, c, len, false);` は ★`switch` の前★（p2w1 :783 / p2w3 :989）⇒ ★停止した命令も Trace に載る★
・harness は `foreach (var st in rt.Trace) { cov.Steps++; ... cov.Inside.Add(st.Pc + k); }`
  ⇒ ★176 の「1 step / 4 byte」＝停止命令 `0x7A` を含めた値★・★175 の「3 step / 27 byte」＝`0x03` を一度も decode していない値★（規約は同一・下 §3）

★(d) `opGuard` は未実装 opcode 停止の counter ではありません★
・`public bool OpGuardHit;          // MaxOpsPerTick 超過(runaway)`（p2w1 :321）★逐語★
・`TermReason` の代入は ★4 箇所だけ★ = `op_guard` / `content_end_guard` / `section_return` / `script_end`（:735/:744/:909/:1508）
・★VM-GATE 停止（`if (UnsupportedOpcodeGate(c, len)) { EmitPage(); State = DialogueState.Finished; return; }`・:1664）は `TermReason` にも 4 counter にも記録されません★
  ⇒ ★worker3 の entry 176「4 counter すべて 0」は「理由なし」ではなく ★理由が器に出ていない★★（= 記録済の規範「0 件は emitter 全列挙とセット」に該当）
  ⇒ ★安い直し★ = 出力に `rt.TermReason` と Trace 末尾 op を 1 行足す。★run 本数は増えません★

★(e) 停止は「opcode ごとに process 内で 1 回だけ」＝★順序依存★★
・`static readonly HashSet<byte> _gateSeen`（p2w1 :1684 / p2w3 :1958）★static★
・`bool first = _gateSeen.Add(op);` … `if (first) { ... return true;  // 停止 }` … `return false;  // 記録のみ(2 回目以降、続行)`
・harness は entry ごとに `var L = Walk(e, false); var B = Walk(e, true);` を ★reset 無しで連続★（reset は ★`public static void W1AbReset()`★ = p2w1 :1696-1697 / p2w3 :1973-1974 に在るが ★呼んでいない★）
  ⇒ ★#585-C の数の中に痕跡が出ています★:
    ・entry 154: L 2 step/5 byte → ★B 7 step/116 byte★（L で消費済ゆえ B は止まらない）
    ・entry 176: L 1 step/4 byte → ★B 6 step/9 byte★（同上）
    ・entry 175: L 3 step/27 byte ＝ ★B 3 step/27 byte（完全一致）★（止め手が gate でなく `WaitingChoice` ゆえ順序に依存しない）

★(f) pass B は「JUMPS=1 の腕」そのものです★
・`if (BehavioralMode) _jumpsEnabled = true;`（p2w1 :572 / p2w3 :765）
・★`BehavioralMode` を ★読む★ 箇所は :572（p2w3 :765）の ★この 1 行だけ★★ = ★jump を ON にする以外の副作用を持ちません★（他の出現は宣言 :165 と comment 2 行、および `VerifyNarrow` 内の setter :2273 = 立てる側）
  ⇒ ★worker3 の pass B ＝ JUMPS=1★。★∴ 段 2 の測定対象は #585-C で既に 1 度撃たれています★

■ 3. ★worker1 の説明の 1 点だけ訂正（★数は 1 つも動きません★）★
・worker1 は step の差を ★「停止した命令自身を step に数えるか」の 1 命令分★ で ★両 entry まとめて★ 説明しています。
・★176 では正しい★（同じ `0x7A` 停止・worker1 は停止命令の byte を数えず 0、worker3 は数えて 4）。
・★175 では違います★ = worker3 の VM は ★`0x03` を一度も decode していません★（`0x10` CHOICE の直後に `WaitingChoice` へ入り harness が break）。
  ⇒ ★同じ pc（`0x07E02B`）・同じ 27 byte・★止め手が別★★。worker1 の「停止集合 `0x03`」は ★worker1 の器の停止理由★ であって worker3 の器の停止理由ではありません。
  ⇒ ★「逐字一致」と書くと、機構が一致したように読めます★。正しくは ★「境界（pc と 27 byte）は一致・止め手は不一致」★。
・worker1 の枠宣言 ③ に ★書き落としが 2 つ★ = `sweep()` は `0xFF` の他に ★entry 範囲を出た時★ と ★`x in seen`（再訪）★ でも止まります。
  ⇒ ★どちらも数を増やす方向ではありません★（chain は決定的ゆえ再訪打切りは着地集合を変えない）。★数の訂正は要りません・枠の欄に 2 行足すだけ★。

■ 4. ★段 2 への含意（★撃つ可否は私の座ではありません★）★
・★entry 175★: 撃っても ★1 byte も動きません★（#585-C の L=B 一致が既にその証拠）。動かすには ★選択肢に答えて再開する 1 行★（harness 側）が要ります。
  ・事前登録 v4 の外れ方 ★巳（段 2 で候補に届く）★ は、175 については ★構造的に起こり得ません★ = 候補の最小 pc が ★0x1042★ に対し停止は ★0x2B★。
・★entry 176★: 撃つなら ★先に交絡を外す★ = pass ごとに ★`DialogueRuntime.W1AbReset()` を 1 行呼ぶ★か、★pass の順を入れ替えた対照★を取る。★どちらも 1 行・run 本数は増えません★。
・⇒ ★段 2 の値打ちは「176 の 1 本（交絡を外した形）」に縮みます★。★175 の分は撃つ前に答えが出ています★。

■ 5. 書かなかったこと
・★どちらの器が正しいかの判定★ / ★数の書き直し★ / ★段 2 の可否★ / ★land・push・実装・compile・Unity run★
・★worker3 の器の意図の推測★（読んだのは harness doc の code と VM の source だけ）
・★#585-C が走った tree の特定★（harness 撤去済ゆえ不能。★2 tree で機構が同一であることは確認済★）
