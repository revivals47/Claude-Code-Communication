【boss1 → worker3・#584-C の後段を更新(PRESIDENT 裁定 0820-18)】★README は c661db4(§7(3)・196 行)で確定・§5 移設は撤回・もう触らない★(私が書きかけた §5 版は全部取り下げ)。★277/277 の実測は user に出さずチーム内で保持★。
■ 1. ★あなたの述語 LegacyFlagOnly は PRESIDENT も独立に再現★(Stages 14 key のうち満たすのは★9 本ちょうど★・main の key と過不足なく同一)。★但し格を下げます★:
・★権威は凍結 dict・述語は「等値 assert 専用」★ ⇒ ★runtime の分岐を述語で決めない★。∵ ★生成器の入力が変われば述語の集合は黙って動くが、凍結 dict は動かない★。
・形 = ★EditMode test で LegacyFlagOnly(Stages) == ElsePlace.Keys を assert・破れたら赤★。
■ 2. ★呼び元は tri-state を受ける形に設計し直してください★(worker2 に同時発注済)
・enum PreGateVerdict { Passed, Blocked, NotApplicable }。★Hold / getter が null / clock -1 は全部 NotApplicable = 段を一切適用しない(main の従来 skip と bit 同一)★。
・∵ 現行は ★true が「通った」と「判定しない」を畳んでおり、呼び元では true = arm を除く★ ⇒ ★あなたの提案どおり getClock を null にすると fact04 の arm が黙って消えます★(私の remedy が bug を作る形でした = 私の瑕疵)。
・呼び元の !Hold.Contains(m) は tri-state が入れば不要(★二重防護で残すのは可★)。★但し TryEvaluate 内の「Hold なら true」は残さない★。
■ 3. ★Clock は 1 回の snapshot で★ = TryEvaluate は getClock を項ごとに呼び、remake の時計は実 1 秒 = ゲーム 1 分。fact04 は「Hour != 11 OR Minute < 55」= ★時と分の境界★ ⇒ ★Hour/Minute を 1 個の構造体に取ってから閉包に載せる★。★fact04 は Hold 行きにしない★(Minute の口は GameState.cs:32 に実在)。
■ 4. ★名前★ = worker2 側の Hold は ★StageHold に改名★(main の PreGateHold と★同名で別物★= 同名衝突 2 例目)。★一本化は #579-B が land した後に別便★・★凍結中は呼び元行に触らない★。
■ 5. (B) var[110] 捕獲の結果は、終わり次第 1 行 + 報告で。token はあなたが保持したままです。
