// W3Phase1Check.cs — ★#596-C (c)(d): gate 配線確認 と OFF の bit 同一★（worker3・Editor 限定・走行後に撤去）
// ★新 symbol は reflection で読む★ = ★実装前の DialogueRuntime(34883fad)でも compile できる★ = ★同じ器で A/B できる★
using System.Collections.Generic;
using System.IO;
using System.Text;
using UnityEditor;
using UnityEngine;
using DigimonWorld.Dialogue;

namespace DigimonWorld.EditorTools
{
    public static class W3Phase1Check
    {
        public static void Run()
        {
            var sb = new StringBuilder();
            var t = typeof(DialogueRuntime);
            string Get(string n)
            {
                var f = t.GetField(n, System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.Static);
                return f == null ? "(symbol 無し)" : System.Convert.ToString(f.GetValue(null));
            }
            sb.AppendLine("# W3 Phase1 check — #596-C (c)(d)");
            sb.AppendLine($"# env DEGIMON_OP24={System.Environment.GetEnvironmentVariable("DEGIMON_OP24") ?? "(未設定)"}"
                        + $" / DEGIMON_OP57={System.Environment.GetEnvironmentVariable("DEGIMON_OP57") ?? "(未設定)"}");
            sb.AppendLine($"# ★gate の実値(reflection)★ Op24Enabled={Get("Op24Enabled")} / Op57Enabled={Get("Op57Enabled")}");

            var db = DialogueDatabase.LoadFromStreamingAssets();
            var rows = new List<string>();
            var gateOps = new SortedSet<byte>();
            long steps = 0, varw = 0, covered = 0;
            for (int i = 0; i < DialogueDatabase.EntryCount; i++)
            {
                var e = db.GetEntry(i);
                if (e.Raw == null || e.Raw.Length < 4) { rows.Add($"{i}:skip"); continue; }
                DialogueRuntime.W1AbReset();
                var rt = new DialogueRuntime { TraceEnabled = true };
                rt.Begin(e);
                int g = 0; bool brk = false;
                while (!rt.IsFinished && g++ < 200000)
                {
                    rt.Tick();
                    if (rt.State == DialogueState.WaitingAdvance) rt.AdvanceInput();
                    else if (rt.State == DialogueState.WaitingFrames) rt.ForceClearWaitFrames();
                    else if (rt.State == DialogueState.WaitingChoice) { brk = true; break; }
                }
                var cov = new HashSet<int>(); int st = 0, vw = 0; int lastPc = -1, lastOp = -1;
                foreach (var s in rt.Trace)
                {
                    st++; lastPc = s.Pc; lastOp = s.Op;
                    int len = s.Len > 0 ? s.Len : 1;
                    for (int k = 0; k < len; k++) cov.Add(s.Pc + k);
                    if (s.Fx != null) foreach (var f in s.Fx) if (f.T == "var_w") vw++;
                }
                foreach (var op in DialogueRuntime.GateCount.Keys) gateOps.Add(op);
                steps += st; varw += vw; covered += cov.Count;
                rows.Add($"{i}:{st}/{cov.Count}/{vw}/0x{lastOp:X2}@0x{lastPc:X}/{(brk ? "choice" : rt.TermReason ?? "-")}/{rt.State}");
            }
            string body = string.Join("\n", rows);
            using (var md5 = System.Security.Cryptography.MD5.Create())
            {
                var h = md5.ComputeHash(System.Text.Encoding.UTF8.GetBytes(body));
                sb.AppendLine($"★per-entry digest(md5) = {System.BitConverter.ToString(h).Replace("-", "").ToLower()}★");
            }
            sb.AppendLine($"★合計★ steps={steps} / covered={covered} / var_w={varw} / entry={DialogueDatabase.EntryCount}");
            sb.Append("★gate 停止した op 種★:"); foreach (var op in gateOps) sb.Append($" 0x{op:X2}"); sb.AppendLine();
            sb.AppendLine($"★Op24Count={Get("Op24Count")} / Op57Count={Get("Op57Count")}★");
            var fld = t.GetField("Op57Field1F", System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.Static);
            if (fld != null)
            {
                var d = fld.GetValue(null) as Dictionary<int, byte>;
                sb.AppendLine($"★Op57Field1F の件数 = {(d == null ? -1 : d.Count)}★");
                if (d != null) { int n = 0; sb.Append("   (idx=+0x1F の値):"); foreach (var kv in d) { if (n++ >= 12) { sb.Append(" …"); break; } sb.Append($" {kv.Key}={kv.Value}"); } sb.AppendLine(); }
            }
            else sb.AppendLine("★Op57Field1F = (symbol 無し = 実装前の runtime)★");
            sb.AppendLine(body);

            string outPath = System.Environment.GetEnvironmentVariable("W3_P1_OUT");
            if (string.IsNullOrEmpty(outPath)) outPath = Path.Combine(Application.dataPath, "..", "..", "w3_phase1.txt");
            Directory.CreateDirectory(Path.GetDirectoryName(Path.GetFullPath(outPath)));
            File.WriteAllText(outPath, sb.ToString());
            Debug.Log("[W3P1] out=" + Path.GetFullPath(outPath));
        }
    }
}
