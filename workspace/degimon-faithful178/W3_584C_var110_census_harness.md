// W3Var110Census.cs — ★#584-C (B) var[110] の 捕獲★（worker3・★測定専用・Editor 限定★）
//
// ★何を 見るか（★撃つ前に 登録した とおり★）★:
//   ★remake 自身の VM（DialogueRuntime）が DG.SCN を ★枠つきで★ 歩いた ときに
//    `TraceFx{T="var_w", I=110}` が 出るか★ = ★var[110] へ 値が 入る 瞬間★（★読みでは ありません★）
//
// ★2 pass 撃ちます（★どちらの 次元か を 分けるため★）★:
//   ★pass L（linear）★ = ★jump は fall-through（既定）★ ⇒ ★entry の opcode を 順に 全部 踏む★
//                        = ★『site が 在るか』に 近い★（★到達可能性では ありません★）
//   ★pass B（behavioral）★ = ★BehavioralMode=true ＋ DEGIMON_DIALOGUE_JUMPS=1★ ⇒ ★1 本の 経路★
//                        = ★『この 初期 state で 実際に 走ったか』★
//
// ★打ち切りを 必ず 数えます★ = ★op guard / content-end guard / tick 上限 / WaitingChoice★
//   ∵ ★打ち切られた list の 不在は 否定では ありません★（#583-C で 私が 踏んだ 型）
//
// ★file を 1 つだけ 書きます★（出力先 = env `W3_CENSUS_OUT`・★/tmp 配下には 置きません★）
// ★game state は DialogueRuntime の 既定（new GameState()）★ = ★注入なし★
using System.Collections.Generic;
using System.IO;
using System.Text;
using UnityEditor;
using UnityEngine;
using DigimonWorld.Dialogue;

namespace DigimonWorld.EditorTools
{
    public static class W3Var110Census
    {
        const int TargetIdx = 110;   // ★0x6E★

        public static void Run()
        {
            var sb = new StringBuilder();
            sb.AppendLine("# W3_584C var[110] census — remake の VM で DG.SCN を枠つきに歩いた結果");
            sb.AppendLine("# ★読みではなく『書かれた瞬間』(TraceFx var_w)を数えます★");

            RunPass(sb, "L(linear/fall-through)", behavioral: false);
            RunPass(sb, "B(behavioral/jumps)",    behavioral: true);

            string outPath = System.Environment.GetEnvironmentVariable("W3_CENSUS_OUT");
            if (string.IsNullOrEmpty(outPath))
                outPath = Path.Combine(Application.dataPath, "..", "..", "w3_584c_census.txt");
            Directory.CreateDirectory(Path.GetDirectoryName(Path.GetFullPath(outPath)));
            File.WriteAllText(outPath, sb.ToString());
            Debug.Log("[W3CENSUS] out=" + Path.GetFullPath(outPath) + "\n" + sb.ToString());
        }

        static void RunPass(StringBuilder sb, string label, bool behavioral)
        {
            var db = DialogueDatabase.LoadFromStreamingAssets();
            var tally = new Dictionary<int, int>();
            var hitEntries = new List<string>();
            int entriesRun = 0, entriesSkipped = 0;
            int opGuard = 0, contentGuard = 0, tickCap = 0, waitChoice = 0;
            long stepsTotal = 0, fxTotal = 0;

            for (int i = 0; i < DialogueDatabase.EntryCount; i++)
            {
                var e = db.GetEntry(i);
                if (e.Raw == null || e.Raw.Length < 4) { entriesSkipped++; continue; }
                var rt = new DialogueRuntime { TraceEnabled = true, BehavioralMode = behavioral };
                rt.Begin(e);
                int g = 0; bool capped = false, choice = false;
                while (!rt.IsFinished && g++ < 200000)
                {
                    rt.Tick();
                    if (rt.State == DialogueState.WaitingAdvance) rt.AdvanceInput();
                    else if (rt.State == DialogueState.WaitingFrames) rt.ForceClearWaitFrames();
                    else if (rt.State == DialogueState.WaitingChoice) { choice = true; break; }
                }
                if (g >= 200000) capped = true;
                entriesRun++;
                if (rt.OpGuardHit) opGuard++;
                if (rt.ContentEndGuardHit) contentGuard++;
                if (capped) tickCap++;
                if (choice) waitChoice++;

                int hereTarget = 0;
                foreach (var st in rt.Trace)
                {
                    stepsTotal++;
                    if (st.Fx == null) continue;
                    foreach (var fx in st.Fx)
                    {
                        if (fx.T != "var_w") continue;
                        fxTotal++;
                        tally.TryGetValue(fx.I, out int c); tally[fx.I] = c + 1;
                        if (fx.I == TargetIdx) hereTarget++;
                    }
                }
                if (hereTarget > 0) hitEntries.Add($"entry {i}: {hereTarget} 件");
            }

            tally.TryGetValue(TargetIdx, out int target);
            sb.AppendLine();
            sb.AppendLine($"== pass {label} ==");
            sb.AppendLine($"  entry: 走った {entriesRun} / 空で飛ばした {entriesSkipped} / 全 {DialogueDatabase.EntryCount}");
            sb.AppendLine($"  ★打ち切りの数★: op guard {opGuard} / content-end guard {contentGuard} / tick 上限 {tickCap} / WaitingChoice {waitChoice}");
            sb.AppendLine($"  trace step 総数 = {stepsTotal} / var_w 総数 = {fxTotal} / 相異なる idx = {tally.Count}");
            sb.AppendLine($"  ★★idx={TargetIdx}(0x6E) の var_w = {target} 件★★");
            foreach (var h in hitEntries) sb.AppendLine("     " + h);
            sb.Append("  ★陽性対照★:");
            foreach (int probe in new[] { 0x1F, 0x1C, 0x4A, 0x6F, 0x6D, 0xFE, 0x00 })
            {
                tally.TryGetValue(probe, out int c);
                sb.Append($" 0x{probe:X2}={c}");
            }
            sb.AppendLine();
            var keys = new List<int>(tally.Keys); keys.Sort((a, b) => tally[b].CompareTo(tally[a]));
            sb.Append("  上位 idx:");
            for (int k = 0; k < keys.Count && k < 12; k++) sb.Append($" 0x{keys[k]:X2}:{tally[keys[k]]}");
            sb.AppendLine();
        }
    }
}
