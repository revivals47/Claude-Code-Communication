// W3Cand86Decode.cs — ★#585-C (c) entry 154/175/176 の 候補 86 件を ★枠つきで 3 値に 落とす★★（worker3）
// ★事前登録 = PREREG_585C.md（commit 3348981・撃つ前）★
// ★Editor 限定★ = player build に 入りません。★走行後に 撤去します★。
using System.Collections.Generic;
using System.IO;
using System.Text;
using UnityEditor;
using UnityEngine;
using DigimonWorld.Dialogue;

namespace DigimonWorld.EditorTools
{
    public static class W3Cand86Decode
    {
        static readonly int[] Targets = { 154, 175, 176 };

        class Cover
        {
            public HashSet<int> Starts = new HashSet<int>();          // ★step の Pc★
            public HashSet<int> StartsOp1E = new HashSet<int>();      // ★Pc かつ Op==0x1E★
            public HashSet<int> Inside = new HashSet<int>();          // ★[Pc, Pc+Len) の 全 byte★
            public int Steps, OpGuard, ContentGuard, TickCap, WaitChoice;
        }

        public static void Run()
        {
            var sb = new StringBuilder();
            sb.AppendLine("# W3_585C (c) — entry 154/175/176 の 0x1E ?? 0x6E 候補を枠つきで 3 値に落とす");
            sb.AppendLine("# ★Len は VM が宣言した消費長をそのまま使う(自前で枠を引き直さない)★");

            var db = DialogueDatabase.LoadFromStreamingAssets();
            int gTot = 0, g1 = 0, g2 = 0, g3 = 0;

            foreach (int idx in Targets)
            {
                var e = db.GetEntry(idx);
                var raw = e.Raw;
                var cands = new List<int>();
                for (int i = 0; i + 3 < raw.Length; i++)
                    if (raw[i] == 0x1E && raw[i + 2] == 0x6E) cands.Add(i);

                var L = Walk(e, false);
                var B = Walk(e, true);

                int c1 = 0, c2 = 0, c3 = 0;
                var detail = new StringBuilder();
                foreach (int p in cands)
                {
                    bool isStart1E = L.StartsOp1E.Contains(p) || B.StartsOp1E.Contains(p);
                    bool isStart   = L.Starts.Contains(p)     || B.Starts.Contains(p);
                    bool inside    = L.Inside.Contains(p)     || B.Inside.Contains(p);
                    bool header    = p < e.BodyStart;
                    string v;
                    if (isStart1E) { v = "①opcode0x1E"; c1++; }
                    else if (header || (inside && !isStart) || (isStart && !isStart1E)) { v = "②枠外/別op"; c2++; }
                    else { v = "③未到達"; c3++; }
                    detail.AppendLine($"     pc=0x{p:X4} {v}"
                        + (header ? " (header+subtable 域)" : "")
                        + (isStart && !isStart1E ? " (step の Pc だが Op!=0x1E)" : ""));
                }
                gTot += cands.Count; g1 += c1; g2 += c2; g3 += c3;

                sb.AppendLine();
                sb.AppendLine($"== entry {idx} : Raw {raw.Length} byte / BodyStart 0x{e.BodyStart:X}");
                sb.AppendLine($"   ★候補(C# で数え直し) = {cands.Count} 件★");
                sb.AppendLine($"   pass L: step {L.Steps} / opGuard {L.OpGuard} / contentGuard {L.ContentGuard} / tickCap {L.TickCap} / WaitingChoice {L.WaitChoice} / 覆った byte {L.Inside.Count}");
                sb.AppendLine($"   pass B: step {B.Steps} / opGuard {B.OpGuard} / contentGuard {B.ContentGuard} / tickCap {B.TickCap} / WaitingChoice {B.WaitChoice} / 覆った byte {B.Inside.Count}");
                sb.AppendLine($"   ★3 値★ ①opcode0x1E={c1} / ②枠外={c2} / ③未到達={c3}  (合計 {c1 + c2 + c3} / 候補 {cands.Count})");
                sb.Append(detail.ToString());
            }

            sb.AppendLine();
            sb.AppendLine($"== ★総計★ 候補 {gTot} 件 : ①={g1} / ②={g2} / ③={g3} (合計 {g1 + g2 + g3})");
            sb.AppendLine($"   ★足し合い★ = {(g1 + g2 + g3 == gTot ? "OK" : "*** 不一致 = 器の誤り ***")}");

            string outPath = System.Environment.GetEnvironmentVariable("W3_C86_OUT");
            if (string.IsNullOrEmpty(outPath))
                outPath = Path.Combine(Application.dataPath, "..", "..", "w3_585c_cand86.txt");
            Directory.CreateDirectory(Path.GetDirectoryName(Path.GetFullPath(outPath)));
            File.WriteAllText(outPath, sb.ToString());
            Debug.Log("[W3C86] out=" + Path.GetFullPath(outPath) + "\n" + sb.ToString());
        }

        static Cover Walk(DialogueEntry e, bool behavioral)
        {
            var cov = new Cover();
            var rt = new DialogueRuntime { TraceEnabled = true, BehavioralMode = behavioral };
            rt.Begin(e);
            int g = 0; bool choice = false;
            while (!rt.IsFinished && g++ < 200000)
            {
                rt.Tick();
                if (rt.State == DialogueState.WaitingAdvance) rt.AdvanceInput();
                else if (rt.State == DialogueState.WaitingFrames) rt.ForceClearWaitFrames();
                else if (rt.State == DialogueState.WaitingChoice) { choice = true; break; }
            }
            cov.OpGuard = rt.OpGuardHit ? 1 : 0;
            cov.ContentGuard = rt.ContentEndGuardHit ? 1 : 0;
            cov.TickCap = (g >= 200000) ? 1 : 0;
            cov.WaitChoice = choice ? 1 : 0;
            foreach (var st in rt.Trace)
            {
                cov.Steps++;
                cov.Starts.Add(st.Pc);
                if (!st.IsText && st.Op == 0x1E) cov.StartsOp1E.Add(st.Pc);
                int len = st.Len > 0 ? st.Len : 1;
                for (int k = 0; k < len; k++) cov.Inside.Add(st.Pc + k);
            }
            return cov;
        }
    }
}
