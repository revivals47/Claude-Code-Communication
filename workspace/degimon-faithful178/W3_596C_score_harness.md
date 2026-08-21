// W3Phase1Score.cs — ★#596-C (e) ON 採点★（worker3・Editor 限定・走行後に撤去）
//   ★1 process・1 stream★（walk ごとの reseed をしない）
using System.Collections.Generic;
using System.IO;
using System.Text;
using UnityEditor;
using UnityEngine;
using DigimonWorld.Dialogue;

namespace DigimonWorld.EditorTools
{
    public static class W3Phase1Score
    {
        public static void Run()
        {
            var sb = new StringBuilder();
            sb.AppendLine("# W3 Phase1 ON 採点 — #596-C (e)");
            sb.AppendLine($"# gate: Op24Enabled={DialogueRuntime.Op24Enabled} / Op57Enabled={DialogueRuntime.Op57Enabled}");
            if (!DialogueRuntime.Op24Enabled || !DialogueRuntime.Op57Enabled)
                sb.AppendLine("# ★★警告: gate が ON でありません = 採点は成立しません★★");

            // ================= ① 0x57 =================
            var db = DialogueDatabase.LoadFromStreamingAssets();
            int sites = 0, cursorOk = 0, cursorNg = 0, valOk = 0, valNg = 0, onceOk = 0, onceNg = 0;
            var detail = new List<string>();
            for (int i = 0; i < DialogueDatabase.EntryCount; i++)
            {
                var e = db.GetEntry(i);
                if (e.Raw == null || e.Raw.Length < 4) continue;
                DialogueRuntime.W1AbReset();
                DialogueRuntime.Phase1Reset();
                var rt = new DialogueRuntime { TraceEnabled = true };
                rt.Begin(e);
                int g = 0;
                while (!rt.IsFinished && g++ < 200000)
                {
                    rt.Tick();
                    if (rt.State == DialogueState.WaitingAdvance) rt.AdvanceInput();
                    else if (rt.State == DialogueState.WaitingFrames) rt.ForceClearWaitFrames();
                    else if (rt.State == DialogueState.WaitingChoice) break;
                }
                var tr = rt.Trace;
                // ★書いた瞬間の値★ = Op57Writes(時系列)。★store(Op57Field1F)は同 idx の後続書きで上書きされます★
                var wr = DialogueRuntime.Op57Writes;
                // ★1 実行 = 1 書き★（handler の 件数=1 固定）
                if (DialogueRuntime.Op57Count > 0) { if (wr.Count == DialogueRuntime.Op57Count) onceOk++; else { onceNg++; detail.Add($"★件数 NG★ entry{i} exec={DialogueRuntime.Op57Count} writes={wr.Count}"); } }
                int wi = 0;
                for (int k = 0; k < tr.Count; k++)
                {
                    if (tr[k].IsText || tr[k].Op != 0x57) continue;
                    sites++;
                    int pc = tr[k].Pc;
                    if (k + 1 < tr.Count)
                    {
                        if (tr[k + 1].Pc == pc + 4) cursorOk++; else { cursorNg++; detail.Add($"★cursor NG★ entry{i} pc=0x{pc:X} next=0x{tr[k + 1].Pc:X}"); }
                    }
                    // ★operand val は raw から独立に読みます★ / ★書いた値は VM が store に入れた値★
                    int val = pc + 3 < e.Raw.Length ? e.Raw[pc + 3] : -1;
                    int idx = pc + 2 < e.Raw.Length ? e.Raw[pc + 2] : -1;
                    if (wi < wr.Count && wr[wi].Pc == pc && wr[wi].Idx == idx && wr[wi].Val == val) valOk++;
                    else { valNg++; detail.Add($"★val NG★ entry{i} pc=0x{pc:X} idx={idx} ★operand_val={val}★ / ★書いた値={(wi < wr.Count ? wr[wi].Val.ToString() : "書き無し")}★ (writePc=0x{(wi < wr.Count ? wr[wi].Pc : -1):X})"); }
                    if (detail.Count < 40 && wi < wr.Count)
                        detail.Add($"   entry{i} pc=0x{pc:X} len=4 idx={idx} ★operand_val={val} / 書いた値={wr[wi].Val}★ next=0x{(k + 1 < tr.Count ? tr[k + 1].Pc : -1):X}");
                    wi++;
                }
            }
            sb.AppendLine();
            sb.AppendLine("== ① 0x57 ==");
            sb.AppendLine($"  実行 site = {sites}");
            sb.AppendLine($"  ★cursor +4★ OK={cursorOk} / NG={cursorNg}");
            sb.AppendLine($"  ★書いた値 == operand val★ OK={valOk} / NG={valNg}");
            sb.AppendLine($"  ★1 site あたり 1 回★ OK entry={onceOk} / NG entry={onceNg}");
            foreach (var d in detail) sb.AppendLine("  " + d);

            // ================= ② 0x24 =================
            sb.AppendLine();
            sb.AppendLine("== ② 0x24 ==");
            int N = 2000;
            int k2 = 0, k99 = 0, nz2 = 0, nz99 = 0;
            for (int i = 0; i < N; i++)
            {
                int v2 = DialogueRuntime.Op24NextValue(2);     // stic02 の site(arg=2)
                int v99 = DialogueRuntime.Op24NextValue(99);   // fact02 の site(arg=99)
                if (v2 == 0) k2++; else nz2++;                 // stic02: var[110] > 0 が ★偽★ = 落ち
                if (v99 <= 2) k99++; else nz99++;              // fact02: var[110] > 2 が ★偽★ = 落ち
            }
            sb.AppendLine($"  ★N = {N}(段を評価した回数・1 process 1 stream・walk ごとの reseed 無し)★");
            sb.AppendLine($"  ★stic02(主) arg=2 : 落ち k = {k2} / N = {N}  (p0 = 10923/32768 = {10923.0 / 32768:F6})★");
            sb.AppendLine($"  ★fact02(補) arg=99: 落ち k = {k99} / N = {N}  (p0 = 984/32768 = {984.0 / 32768:F6})★");
            sb.AppendLine($"  ★var[dst] が 0 でない回数★ arg=2 -> {nz2} / arg=99 -> {nz99}");
            sb.AppendLine("  ★exact binomial 両側 α=0.01 の受理帯は報告側で計算します(k と N をそのまま出します)★");
            // VM 経由の 0x24 も 1 度出す(実行 path の確認)
            sb.AppendLine($"  (参考)VM 走行での Op24Count 累計は entry ごとに reset しているため上の N とは別軸です");

            string outPath = System.Environment.GetEnvironmentVariable("W3_P1S_OUT");
            if (string.IsNullOrEmpty(outPath)) outPath = Path.Combine(Application.dataPath, "..", "..", "w3_phase1_score.txt");
            Directory.CreateDirectory(Path.GetDirectoryName(Path.GetFullPath(outPath)));
            File.WriteAllText(outPath, sb.ToString());
            Debug.Log("[W3P1S] out=" + Path.GetFullPath(outPath));
        }
    }
}
