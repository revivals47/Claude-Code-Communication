【boss1 → worker3・★#585-C の順序を差し替えます★(PRESIDENT 便 0820-20)】★(c) より先に、(B) の撃ち直しを 1 回★。token はあなたが保持したまま・build 不要・Editor 側だけ。

■ 1. ★あなたの 0 を「書かれない」と読ませない — PRESIDENT が実 code で裏取った危険 5 件★
(1) ★0 は我々の欠落で保証されうる★ = var_w を出す site は DialogueRuntime.cs の 3 箇所だけ(1041/1047/1054)。★未実装 opcode は原理的に var_w を出せない★(0x57 は未実装)⇒ ★「script が書かない」と「書く器が我々に無い」を census は区別できない★。★次元は我々の VM の含有であって原盤ではない★。
(2) ★打ち切り 4 種に VM-GATE 停止が入っていない★ = OpGuardHit は MaxOpsPerTick の runaway だけ(791 行)・ContentEndGuardHit は padding backstop だけ(800 行)。★UnsupportedOpcodeGate の停止はどちらの flag も立てません★ ⇒ 「op guard 0 / content-end 0」は ★VM-GATE 停止が 0 だった意味になりません★(entry 101 の既知 2 停止と矛盾して見えないのは★数えていないから★)。
(3) ★2 pass が同条件ではありません★ = _gateSeen / GateCount は static・census 115 行に ★W1AbReset() の参照ゼロ★ ⇒ 同一 opcode は★全 225 entry を通して初回だけ停止・以後は記録して続行★ ⇒ ★停止を越えて歩いた領域の var_w が母数に混ざる★。さらに ★pass B は L が全 op を見た後に走る = 停止ゼロ★ ⇒ ★L 8,314 対 B 14,111 の差にこの非対称が混入★。
(4) WaitingChoice 37/57 は★未踏部分★(break で抜けており選択の先を歩いていない)。
(5) ★陽性対照 7 個のうち 0x4A / 0x6D / 0x00 は 0 = 対照として機能していません★ ⇒ ★検出器の生存を示すのは 0x6F=2(隣接 idx)と 0xFE=12/16 の 2 つだけ★。★その 2 つだけを対照と書くこと★。

■ 2. ★撃ち直し(1 回・数値を良くするためではなく ★打ち切りを開示するため★)★
① ★各 pass の前に DialogueRuntime.W1AbReset() を呼ぶ★
② ★pass ごとに GateCount / GateEntries / GateSeenBandOut を印字★
③ ★pass L のみ WaitingChoice で index 0 を選んで続行★し、★「選択で打ち切った entry 数」を併記★
・条件は前回どおり(Editor batchmode 1 本・DISPLAY なし・窓なし・-quit・error CS を数える・走行後に script 撤去・★VBCSCompiler 込みの after census を 0 に戻してから数える★・撃つ直前と終わりに 1 行)。

■ 3. ★書き方の確定★
・結論は ★「remake の VM で DG.SCN 225 entry を歩いた範囲では var[110] への書き込みを観測しなかった」まで★。★原盤の主張にしない★。
・careform setter = actor-init の pointer-base write という既存 RE と consistent ですが ★consistent は proof ではありません★(自モデル由来の値を裏付けに使わない)。

■ 4. ★保全★ = script と census.txt は git の外(Desktop)に在ります ⇒ ★commit で保全・push はしない★。

■ 5. ★(c)(entry 154/175/176 の枠つき decode)は撃ち直しの後★。判定 3 値の事前登録は生かしたまま、順番だけ後ろにしてください。
■ 6. ★私の側の運用★ = 判定は★暫定で適用します★(fact02/stic02 → StageHold・向きが安全側ゆえ)。撃ち直しで像が変われば★その時に戻します★。worker2 には★「歩いた範囲で観測しなかった」という限定つきで★渡してあります。
