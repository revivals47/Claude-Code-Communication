// FTension (worker3, drafts/rod_look/ROD_HOLDER_FIX_W3.md §7.14, PRESIDENT 17:4x): the line tension during forced fights (as the tests'
// ScenarioFight / FishSideTests: the AutoPilot's 4/20 day up to the first rig on the bottom, then FishingSession.StartScenarioFight, played by
// the AutoPilot). Per fight: RenderSnapshot.TensionN (DEVICE N, the link's peak since the last frame, SnapshotBuilder.cs:85) on every frame
// while State == Fight and before the landing sequence; median / p10 / p90 / max and the fight's seconds. Measure only.
// usage: FTension <species> <lengths cm, comma> <seeds, comma>
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Reflection;
using Ikada.Game;
using Ikada.Game.Flow;
using Ikada.Game.Input;
using Ikada.Game.Render;
using Ikada.Logic.Journal;
using Ikada.Logic.HookArm;
using Ikada.Native;

static class Program
{
    static int Main(string[] a)
    {
        CultureInfo.DefaultThreadCurrentCulture = CultureInfo.InvariantCulture;
        var sp = (Species)Enum.Parse(typeof(Species), a[0]);
        var start = typeof(FishingSession).GetMethod("StartScenarioFight", BindingFlags.NonPublic | BindingFlags.Instance)!;
        var all = new List<float>();
        foreach (var ls in a[1].Split(','))
        foreach (var ss in a[2].Split(','))
        {
            float len = float.Parse(ls); uint seed = uint.Parse(ss);
            var dayCfg = new DayConfig { Seed = ReferenceRun.DefaultSeed, TimeSpeedIndex = ReferenceRun.TimeSpeedIndex, StoryFrom = new GameDate(Ikada.Game.Flow.Calendar.Year, 4, 20) };
            using var s = new IkadaSession(new SessionConfig { Day = dayCfg, Lockstep = true, HudOn = true });
            s.Start();
            var pilot = new AutoPilot { Mode = "ストーリー", FastSkip = false, PreferMix = "赤土" };
            bool started = false; var tv = new List<float>(); int frames = 0; string end = "?";
            for (int i = 1; i < 60 * 12000; i++)
            {
                float t = (float)(i / 60.0);
                var f = new InputFrame();
                pilot.Apply(f, s.Flow, s.Link, t);
                FishingSession? fs = s.Flow.Day?.Session;
                if (fs != null && !started && fs.State == RigState.InWater && fs.OnBottom)
                {
                    start.Invoke(fs, new object[] { sp, len, HookLoc.Kannuki, false, seed });
                    started = true;
                }
                RenderSnapshot snap = s.Step(ReferenceRun.FrameS, f);
                pilot.See(snap, t);
                if (!started) continue;
                fs = s.Flow.Day?.Session;
                if (fs == null || fs.State != RigState.Fight) { end = fs?.Fight?.End.ToString() ?? "none"; break; }
                if (fs.LandingStage != LandingStage.None) { end = fs.Fight?.End.ToString() ?? "?"; break; }
                tv.Add(snap.TensionN); frames++;
            }
            if (tv.Count == 0) { Console.WriteLine($"{sp} {len} cm seed {seed}: no samples"); continue; }
            var o = tv.OrderBy(x => x).ToList();
            float P(double q) => o[Math.Min(o.Count - 1, (int)(q * o.Count))];
            all.AddRange(tv);
            Console.WriteLine($"{sp} {len} cm seed {seed}: fight {frames / 60.0:0.0} s | T device N median {P(0.5):0.00} p10 {P(0.1):0.00} p90 {P(0.9):0.00} max {o[^1]:0.00} | end {end}");
        }
        if (all.Count > 0)
        {
            var o = all.OrderBy(x => x).ToList(); float P(double q) => o[Math.Min(o.Count - 1, (int)(q * o.Count))];
            Console.WriteLine($"== {sp} all frames {all.Count}: median {P(0.5):0.00} p10 {P(0.1):0.00} p25 {P(0.25):0.00} p75 {P(0.75):0.00} p90 {P(0.9):0.00} max {o[^1]:0.00} (device N)");
        }
        return 0;
    }
}
