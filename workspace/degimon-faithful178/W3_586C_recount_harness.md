// W3Var110Recount.cs — ★#586-C (B) 撃ち直し = ★打ち切りを 開示する★★（worker3・Editor 限定）
// ★事前登録 = PREREG_586C.md（commit b49b097・撃つ前）★
//   ① 各 pass の前に DialogueRuntime.W1AbReset()
//   ② pass ごとに GateCount / GateEntries / GateSeenBandOut / GateSteps を印字
//   ③ pass L のみ WaitingChoice で index 0 を選んで続行（cap 64/entry・打ち切り数を併記）
//   ＋ pass N = W1AbNeverStop=true（★私の追加・framing は推定ゆえ単独では採らない★）
// ★走行後に撤去します★
using System.Collections.Generic;
using System.IO;
using System.Text;
using UnityEditor;
using UnityEngine;
using DigimonWorld.Dialogue;

namespace DigimonWorld.EditorTools
{
    public static class W3Var110Recount
    {
        const int TargetIdx = 110;
        const int ChoiceCap = 64;

        public static void Run()
        {
            var sb = new StringBuilder();
            sb.AppendLine("# W3_586C var[110] 撃ち直し — ★各 pass の前に W1AbReset・打ち切りを全部開示★");
            sb.AppendLine("# ★結論の上限 = 『我々の VM で 225 entry を歩いた範囲では観測しなかった』まで★");

            RunPass(sb, "L(fall-through + 選択 index0 で続行)", behavioral: false, takeChoice: true,  neverStop: false);
            RunPass(sb, "B(BehavioralMode / 選択は break)",     behavioral: true,  takeChoice: false, neverStop: false);
            RunPass(sb, "N(NeverStop・★framing は推定★)",       behavioral: false, takeChoice: true,  neverStop: true);

            string outPath = System.Environment.GetEnvironmentVariable("W3_RECOUNT_OUT");
            if (string.IsNullOrEmpty(outPath))
                outPath = Path.Combine(Application.dataPath, "..", "..", "w3_586c_recount.txt");
            Directory.CreateDirectory(Path.GetDirectoryName(Path.GetFullPath(outPath)));
            File.WriteAllText(outPath, sb.ToString());
            Debug.Log("[W3RECOUNT] out=" + Path.GetFullPath(outPath) + "\n" + sb.ToString());
        }

        static void RunPass(StringBuilder sb, string label, bool behavioral, bool takeChoice, bool neverStop)
        {
            DialogueRuntime.W1AbReset();                 // ★① 同条件に揃える★
            DialogueRuntime.W1AbNeverStop = neverStop;   // ★pass N のみ true★

            var db = DialogueDatabase.LoadFromStreamingAssets();
            var tally = new Dictionary<int, int>();
            var hit = new List<string>();
            int run = 0, skipped = 0, opGuard = 0, contentGuard = 0, tickCap = 0;
            int choiceBroke = 0, choiceTaken = 0, choiceCapHit = 0, choiceRefused = 0;
            long steps = 0, fx = 0;

            for (int i = 0; i < DialogueDatabase.EntryCount; i++)
            {
                var e = db.GetEntry(i);
                if (e.Raw == null || e.Raw.Length < 4) { skipped++; continue; }
                var rt = new DialogueRuntime { TraceEnabled = true, BehavioralMode = behavioral };
                rt.Begin(e);
                int g = 0, chosen = 0; bool broke = false, capped = false;
                while (!rt.IsFinished && g++ < 200000)
                {
                    rt.Tick();
                    if (rt.State == DialogueState.WaitingAdvance) rt.AdvanceInput();
                    else if (rt.State == DialogueState.WaitingFrames) rt.ForceClearWaitFrames();
                    else if (rt.State == DialogueState.WaitingChoice)
                    {
                        if (!takeChoice) { broke = true; break; }
                        if (chosen >= ChoiceCap) { capped = true; break; }
                        chosen++;
                        if (!rt.ConfirmChoiceIndex(0)) { choiceRefused++; broke = true; break; }  // ★menu 型等は false★
                    }
                }
                run++;
                if (g >= 200000) tickCap++;
                if (rt.OpGuardHit) opGuard++;
                if (rt.ContentEndGuardHit) contentGuard++;
                if (broke) choiceBroke++;
                if (capped) choiceCapHit++;
                choiceTaken += chosen;

                int here = 0;
                foreach (var st in rt.Trace)
                {
                    steps++;
                    if (st.Fx == null) continue;
                    foreach (var f in st.Fx)
                    {
                        if (f.T != "var_w") continue;
                        fx++;
                        tally.TryGetValue(f.I, out int c); tally[f.I] = c + 1;
                        if (f.I == TargetIdx) here++;
                    }
                }
                if (here > 0) hit.Add($"entry {i}: {here} 件");
            }

            tally.TryGetValue(TargetIdx, out int target);
            sb.AppendLine();
            sb.AppendLine($"== pass {label} ==");
            sb.AppendLine($"  entry 走った {run} / 空 {skipped} / 全 {DialogueDatabase.EntryCount}");
            sb.AppendLine($"  ★打ち切り(従来の 3 種)★ op guard {opGuard} / content-end guard {contentGuard} / tick 上限 {tickCap}");
            sb.AppendLine($"  ★打ち切り(選択)★ break した entry {choiceBroke} / うち ConfirmChoiceIndex が false {choiceRefused} / cap({ChoiceCap})到達 {choiceCapHit} / 選んだ回数 計 {choiceTaken}");
            sb.AppendLine($"  ★★打ち切り(VM-GATE 停止)★★ GateSteps={DialogueRuntime.GateSteps} / 停止した op 種 {DialogueRuntime.GateCount.Count} / band 外 {DialogueRuntime.GateSeenBandOut.Count}");
            var ops = new List<byte>(DialogueRuntime.GateCount.Keys);
            ops.Sort((a, b) => DialogueRuntime.GateCount[b].CompareTo(DialogueRuntime.GateCount[a]));
            sb.Append("     GateCount(op:回数/entry 数):");
            foreach (var op in ops)
            {
                int ec = DialogueRuntime.GateEntries.TryGetValue(op, out var s) ? s.Count : 0;
                sb.Append($" 0x{op:X2}:{DialogueRuntime.GateCount[op]}/{ec}");
            }
            sb.AppendLine();
            sb.AppendLine($"  trace step {steps} / var_w {fx} / 相異なる idx {tally.Count}");
            sb.AppendLine($"  ★★idx={TargetIdx}(0x6E) の var_w = {target} 件★★");
            foreach (var h in hit) sb.AppendLine("     " + h);
            sb.Append("  ★陽性対照(★機能したのは 0x6F と 0xFE の 2 つ★・#586-C §0(5))★:");
            foreach (int p in new[] { 0x6F, 0xFE, 0x1F, 0x1C, 0x4A, 0x6D, 0x00 })
            { tally.TryGetValue(p, out int c); sb.Append($" 0x{p:X2}={c}"); }
            sb.AppendLine();
            var keys = new List<int>(tally.Keys); keys.Sort((a, b) => tally[b].CompareTo(tally[a]));
            sb.Append("  上位 idx:");
            for (int k = 0; k < keys.Count && k < 12; k++) sb.Append($" 0x{keys[k]:X2}:{tally[keys[k]]}");
            sb.AppendLine();

            DialogueRuntime.W1AbNeverStop = false;   // ★後片付け★
        }
    }
}
