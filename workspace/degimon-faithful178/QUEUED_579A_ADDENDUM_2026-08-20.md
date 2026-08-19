【boss1 → worker1・#579-A への追い口(PRESIDENT が器で測った分・作業を止めずに読んでください)】

■ 1. あなたの (C) は★現物照合で成立★(PRESIDENT が 6980befd を読みました)
・2569 行 / sha256 528a2553… 一致。1731 行 = if (UnsupportedOpcodeGate(c, len)) { EmitPage(); State = Finished; return; }
・全 41 case を列挙して 0x75 が無いことも確認。Len[0x75]=12 も実値。

■ 2. ★実測が出ました(あなたの (B) の答の一部)★ = w3_build582r/runs/*.log 全 9 本
・★0x75 の [VM-GATE] 行は 1 本も無い★。
・代わりに ★entry=101(mayo00 intro) で実際に 2 回停止★:
  GUI3.log:111 op=0x0A len=1 entry=101 pc=0x29 = BAND-OUT ⇒ ★停止(初回)★ / :115 同 op = 記録のみ(続行)
  GUI3.log:117 op=0x57 len=4 entry=101 pc=0xA6 prevOp=0x0A = UNSUPPORTED ⇒ ★停止(初回)★
・log を出した binary の DialogueRuntime.cs sha256 = 528a2553 = ★あなたが読んだ現物と同一★。
⇒ ★第一仮説は 0x57(pc=0xA6)・次に 0x0A(pc=0x29)。0x75 は第二以降★。
■ ★但し 0x75 を否定しない★ = gate が 0xA6 で Finished にしている ⇒ ★log は 0xA6 より先を走っていない★。
  0x75 が 0xA6 より後ろに在れば★構造上 log に出ない★。★不在を書く時は「どこまで走ったか」の母数を必ず添える★。

■ 3. ★「初回」の scope を狭く読み直してください★
・_gateSeen は static HashSet・W1AbReset() は★repo の .cs に呼び出し元ゼロ(宣言のみ)★
⇒ 初回 = entry 単位でも run 単位でもなく ★process 単位★。1 起動につき 1 opcode 1 回だけ停止、以後読み飛ばし、★再起動で再武装★。
・症状の形 = hang ではなく ★会話/cutscene が途中で Finished(早期終了)★ + LogError 1 行。

■ 4. ★存在しない逃がし弁(器の瑕疵 8 例目)★
・DialogueRuntime.cs:1750 の comment「env DEGIMON_VM_GATE=0 で gate 自体を無効」⇒ ★repo 全体でこの comment 1 行にしか無い = 未配線★。使わないでください。
・実在するのは ★W1_GATE_NEVERSTOP=1 のみ★(1758 で env 読取 → 1782 で first=false)。★static field 初期化ゆえ process 起動前に env を置く★。

■ 5. 追い口(#579-A が安くなります)
・★W1_GATE_NEVERSTOP=1 で 1 run★ = 停止せず全 gate 行が並ぶ ⇒ ★(A) 停止 opcode の全数 と (B) 経路交差が同じ 1 run で同時に取れる★。compile 不要・GUI 目視不要。
・★★但し run の実行は boss1 の GO を待ってください★★ = ★user が今この build を見ている可能性が在り、DISPLAY=:1 に窓が 2 つ出ると user の観測が汚れます★。
  ⇒ ★1 行だけ申告を送って、私の GO を待ってから走らせる★。それまでは静的側((A) の全数列挙・(C) の被覆)を進めてください。
・(A) の札を 1 つ増やす: ★0x0A の BAND-OUT は ctx が 19 00 0D 00 01 [0A] 18 00 3C 00 = u16 が並ぶ data 面に見える★
  ⇒ ★PC 整合ずれ(len 表 drift)で data を opcode 読みしている可能性★を札に持つこと。★断定しない★(PRESIDENT は当該 EXE handler を読んでいません)。

■ 6. ★GO を出します(条件 4 つ・便 0820-15)★
PRESIDENT が器で採りました(01:25) = ★DISPLAY=:1 の窓 0 個・DegimonLive の process 0 個(exe 実体で走査)★ ⇒ ★今撃っても窓は 1 つ・二重にならない★。
★但し「user の眼」は測れていません★(測ったのは画面に何も出ていないことだけ)。user が戻れば再判定します。
条件:
(1) ★窓を出さない道を先に試す★ = 目的が [VM-GATE] の log 1 行なら、-logFile だけで足りるかを先に見る。駄目な時だけ DISPLAY=:1 に 1 回。
(2) ★実行の直前に boss1 へ 1 行申告し、私の「空いています」を受けてから走らせる★ = ★worker3 が #580-C で GUI を使う可能性が在り、窓が 2 つ出ると worker3 の WID 特定(wmctrl before/after の diff)が別の窓を掴みます★。cargo -j1 と同じ直列化です。
(3) ★置き去り窓を作らない★ = 自動終了つきで走らせ、★before / during / after の census を残し after=0 を証拠に添える★。census は ★/proc の exe 実体 + 前方一致★で(comm 改名と (deleted) の穴は既知)。
(4) ★別 DISPLAY へ逃がす札は今は無い★ = :2 は別 display ではありません(★xdpyinfo の root window id が :1 / :2 とも 0x375 で同一 = 同じ Xwayland★)。Xvfb も未導入。★:2 を使えば安全、と考えないでください★。
