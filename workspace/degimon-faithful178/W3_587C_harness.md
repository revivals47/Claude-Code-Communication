// W3Final587.cs — ★#587-C 確定形(v7)の 42 walk★（worker3・Editor 限定・★走行後に撤去★）
// ★事前登録 = PREREG_587C.md（v7 = commit feaa3b7・撃つ前）★
//   段 0 = #585-C の逐語再現(reset は process 頭 1 回・L→B 順) + VerifyEntry(101)
//   段 1 = entry 154 / 175 × 5 arm(A-E)
//   段 2 = entry 176 × section 6 × 5 arm
// ★knob★ J=_jumpsEnabled(BehavioralMode) / S=_selectorForced(DEGIMON_DIALOGUE_CHOICE) / C=ConfirmChoiceIndex
using System.Collections.Generic;
using System.IO;
using System.Text;
using UnityEditor;
using UnityEngine;
using DigimonWorld.Dialogue;

namespace DigimonWorld.EditorTools
{
    public static class W3Final587
    {
        const int TargetIdx = 110;   // 0x6E
        const int SwallowIdx = 122;  // 0x7A ★飲み込みの直接証拠★
        const int ChoiceCap = 64;
        static StringBuilder sb;

        class Arm { public string Name; public bool J; public bool S; public bool C; }
        static readonly Arm[] Arms = {
            new Arm{Name="A(J-off S-off C-break)",  J=false,S=false,C=false},
            new Arm{Name="B(J-ON  S-off C-break)",  J=true, S=false,C=false},
            new Arm{Name="C(J-off S-off C-cont )",  J=false,S=false,C=true },
            new Arm{Name="D(J-ON  S-off C-cont )",  J=true, S=false,C=true },
            new Arm{Name="E(J-ON  S-ON  C-cont )",  J=true, S=true, C=true },
        };

        class R
        {
            public int Steps, CoveredBytes, VarW, VarW110, VarW122, Distinct110, Regress, ChoiceTaken;
            public bool ChoiceBroke, CapHit, OpGuard, ContentGuard, TickCap;
            public string Term, Cls, State;
            public int LastPc = -1, LastOp = -1;
            public Dictionary<int,int> Hist = new Dictionary<int,int>();
            public List<int> Pc110 = new List<int>();
            public List<string> Exits = new List<string>();
            public int GateOps, GateBandOut;
        }

        public static void Run()
        {
            sb = new StringBuilder();
            sb.AppendLine("# W3_587C 確定形(v7) — 42 walk");
            sb.AppendLine("# ★実測が予測を外した項目はそのまま印字・合わせにいかない★");

            var db = DialogueDatabase.LoadFromStreamingAssets();

            // ================= 段 0 =================
            sb.AppendLine();
            sb.AppendLine("== 段 0 : #585-C の逐語再現(process 頭で 1 回だけ reset・L→B 順) ==");
            DialogueRuntime.W1AbReset();
            DialogueRuntime.W1AbNeverStop = false;
            foreach (int idx in new[]{154,175,176})
            {
                var e = db.GetEntry(idx);
                var l = Walk(e, -1, Arms[0], false);   // ★段 0 = reset しない(process 頭の 1 回だけ)★
                var b = Walk(e, -1, Arms[1], false);
                sb.AppendLine($"   entry {idx}: L step={l.Steps} byte={l.CoveredBytes} term={l.Term ?? "-"}/{l.Cls} | B step={b.Steps} byte={b.CoveredBytes} term={b.Term ?? "-"}/{b.Cls}");
            }
            sb.Append("   ★gate stop の (op → entry 集合)★:");
            foreach (var kv in DialogueRuntime.GateEntries)
            { sb.Append($" 0x{kv.Key:X2}->["); foreach (var en in kv.Value) sb.Append(en + " "); sb.Append("]"); }
            sb.AppendLine();
            sb.AppendLine($"   ★band 外の op 種 = {DialogueRuntime.GateSeenBandOut.Count}★ / 停止した op 種 = {DialogueRuntime.GateCount.Count}");
            // VerifyEntry(101)
            var e101 = db.GetEntry(101);
            System.Environment.SetEnvironmentVariable("DEGIMON_DIALOGUE_JUMPS", null);
            bool ok0 = DialogueRuntime.VerifyEntry(e101, out int m0, out int em0, out int or0);
            System.Environment.SetEnvironmentVariable("DEGIMON_DIALOGUE_JUMPS", "1");
            bool ok1 = DialogueRuntime.VerifyEntry(e101, out int m1, out int em1, out int or1);
            System.Environment.SetEnvironmentVariable("DEGIMON_DIALOGUE_JUMPS", null);
            sb.AppendLine($"   ★VerifyEntry(101)★ JUMPS 未設定: ok={ok0} matched={m0} emitted={em0} oracle={or0}");
            sb.AppendLine($"   ★VerifyEntry(101)★ JUMPS=1     : ok={ok1} matched={m1} emitted={em1} oracle={or1}");

            // ================= 段 1 =================
            sb.AppendLine();
            sb.AppendLine("== 段 1 : entry 154 / 175 × 5 arm(walk ごとに W1AbReset) ==");
            foreach (int idx in new[]{154,175})
            {
                var e = db.GetEntry(idx);
                int cand = CountCand(e.Raw, 0x6E);
                sb.AppendLine($" -- entry {idx} (Raw {e.Raw.Length} / BodyStart 0x{e.BodyStart:X} / 候補 {cand} 件) --");
                foreach (var a in Arms) Emit(Walk(e, -1, a), $"    {a.Name}", cand);
            }

            // ================= 段 2 =================
            sb.AppendLine();
            sb.AppendLine("== 段 2 : entry 176 × section × 5 arm ==");
            var e176 = db.GetEntry(176);
            int cand176 = CountCand(e176.Raw, 0x6E);
            var tbl = DialogueDatabase.GetSectionTable(e176);
            sb.AppendLine($" -- entry 176 (Raw {e176.Raw.Length} / BodyStart 0x{e176.BodyStart:X} / 候補 {cand176} 件 / section {tbl.Count} 本) --");
            var cands = CandPcs(e176.Raw, 0x6E);
            foreach (var kv in tbl)
            {
                int upper = 0; foreach (int p in cands) if (p >= kv.Value) upper++;
                sb.AppendLine($"    ★section id{kv.Key} @0x{kv.Value:X} 起点 byte=0x{e176.Raw[kv.Value]:X2} ★上界 {upper} 件★★");
                foreach (var a in Arms) Emit(Walk(e176, kv.Key, a), $"       {a.Name}", upper);
            }

            string outPath = System.Environment.GetEnvironmentVariable("W3_F587_OUT");
            if (string.IsNullOrEmpty(outPath))
                outPath = Path.Combine(Application.dataPath, "..", "..", "w3_587c_final.txt");
            Directory.CreateDirectory(Path.GetDirectoryName(Path.GetFullPath(outPath)));
            File.WriteAllText(outPath, sb.ToString());
            Debug.Log("[W3F587] out=" + Path.GetFullPath(outPath) + "\n" + sb.ToString());
        }

        static int CountCand(byte[] raw, byte idx)
        { int n=0; for (int i=0;i+3<raw.Length;i++) if (raw[i]==0x1E && raw[i+2]==idx) n++; return n; }
        static List<int> CandPcs(byte[] raw, byte idx)
        { var l=new List<int>(); for (int i=0;i+3<raw.Length;i++) if (raw[i]==0x1E && raw[i+2]==idx) l.Add(i); return l; }

        static void Emit(R r, string label, int upper)
        {
            sb.AppendLine($"{label} step={r.Steps} byte={r.CoveredBytes} ★var_w110={r.VarW110}★(上界 {upper}) distinct110={r.Distinct110} 逆行={r.Regress} var_w122={r.VarW122} varW={r.VarW}"
                + $" | 停止={r.Cls}(term={r.Term ?? "-"} state={r.State} lastOp=0x{r.LastOp:X2}@0x{r.LastPc:X})"
                + $" | choice 取={r.ChoiceTaken} break={r.ChoiceBroke} cap={r.CapHit}"
                + $" | gate op 種={r.GateOps} band外={r.GateBandOut}"
                + $" | hist " + Hist(r));
            if (r.Pc110.Count > 0)
            {
                sb.Append($"{label}   var_w110 の pc:");
                foreach (int p in r.Pc110) sb.Append($" 0x{p:X}");
                sb.AppendLine();
            }
            foreach (var x in r.Exits) sb.AppendLine($"{label}   ★離脱候補★ {x}");
        }
        static string Hist(R r)
        {
            var s = new StringBuilder();
            foreach (int op in new[]{0x13,0x14,0x16,0x17,0x18,0x19})
            { r.Hist.TryGetValue(op, out int c); s.Append($"0x{op:X2}:{c} "); }
            return s.ToString();
        }

        static R Walk(DialogueEntry e, int section, Arm a, bool reset = true)
        {
            if (reset) DialogueRuntime.W1AbReset();
            DialogueRuntime.W1AbNeverStop = false;
            System.Environment.SetEnvironmentVariable("DEGIMON_DIALOGUE_CHOICE", a.S ? "0" : null);
            var r = new R();
            var rt = new DialogueRuntime { TraceEnabled = true, BehavioralMode = a.J };
            if (section >= 0) { if (!rt.PlaySection(e, section)) { r.Cls = "section 不在"; return r; } }
            else rt.Begin(e);
            int g = 0, chosen = 0;
            while (!rt.IsFinished && g++ < 200000)
            {
                rt.Tick();
                if (rt.State == DialogueState.WaitingAdvance) rt.AdvanceInput();
                else if (rt.State == DialogueState.WaitingFrames) rt.ForceClearWaitFrames();
                else if (rt.State == DialogueState.WaitingChoice)
                {
                    if (!a.C) { r.ChoiceBroke = true; break; }
                    if (chosen >= ChoiceCap) { r.CapHit = true; break; }
                    chosen++;
                    if (!rt.ConfirmChoiceIndex(0)) { r.ChoiceBroke = true; break; }
                }
            }
            r.ChoiceTaken = chosen;
            r.TickCap = g >= 200000;
            r.OpGuard = rt.OpGuardHit; r.ContentGuard = rt.ContentEndGuardHit;
            r.Term = rt.TermReason; r.State = rt.State.ToString();
            r.GateOps = DialogueRuntime.GateCount.Count;
            r.GateBandOut = DialogueRuntime.GateSeenBandOut.Count;

            var covered = new HashSet<int>();
            var d110 = new HashSet<int>();
            int prevPc = -1;
            foreach (var st in rt.Trace)
            {
                r.Steps++;
                if (prevPc >= 0 && st.Pc < prevPc) r.Regress++;
                prevPc = st.Pc;
                int len = st.Len > 0 ? st.Len : 1;
                for (int k = 0; k < len; k++) covered.Add(st.Pc + k);
                if (!st.IsText) { r.Hist.TryGetValue(st.Op, out int c); r.Hist[st.Op] = c + 1; }
                r.LastPc = st.Pc; r.LastOp = st.Op;
                if (st.Fx != null)
                    foreach (var f in st.Fx)
                    {
                        if (f.T != "var_w") continue;
                        r.VarW++;
                        if (f.I == TargetIdx) { r.VarW110++; d110.Add(st.Pc); r.Pc110.Add(st.Pc); }
                        if (f.I == SwallowIdx) r.VarW122++;
                    }
            }
            r.CoveredBytes = covered.Count; r.Distinct110 = d110.Count;
            // ★entry 離脱候補★ = 最後の step が 0x14/0x17 で Finished(to は私が operand を読んだ値)
            if ((r.LastOp == 0x14 || r.LastOp == 0x17) && rt.IsFinished && r.LastPc >= 0 && r.LastPc + 4 <= e.Raw.Length)
                r.Exits.Add($"op=0x{r.LastOp:X2} pc=0x{r.LastPc:X} from_entry={e.Index} to(operand 読み)=0x{(e.Raw[r.LastPc+2] | (e.Raw[r.LastPc+3]<<8)):X4}");
            // ★停止理由の分類(5 値 + unclassified)★
            if (r.Term != null) r.Cls = r.Term;
            else if (r.ChoiceBroke) r.Cls = "choice_break";
            else if (r.CapHit) r.Cls = "choice_cap";
            else if (r.GateOps > 0) r.Cls = "vm_gate";
            else if (r.TickCap) r.Cls = "tick_cap";
            else r.Cls = "★unclassified★";
            System.Environment.SetEnvironmentVariable("DEGIMON_DIALOGUE_CHOICE", null);
            return r;
        }
    }
}
