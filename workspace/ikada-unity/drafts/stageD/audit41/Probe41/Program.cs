// Probe41 (worker3, AUDIT_41_42_W3.md, measure only): how often a fight ends PULL_SLACK in ordinary play, and for each such end
// whether the line was geometrically taut through the slack episode that ended it (#41: light tension only) or really slack.
// Classifier (checked on the C core by probe41.c: audit case taut_share 1.000, really slack 0.000): over the last PullSlackMs
// before the end, the share of samples with q - x >= -0.005 m (the core's SLACK_GEOM test, ikd_fight_risk.c:72). >= 0.5 = "light".
//   human: the tests' fishing days (FishingDay + FightHarness, ms samples), skills Good / Slack / Locked, spring and July
//   pilot: whole story days through IkadaSession (lockstep) + AutoPilot, as ReferenceRun.RunAt (10 ms samples)
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using Ikada.Game;
using Ikada.Game.Flow;
using Ikada.Game.Input;
using Ikada.Game.Render;
using Ikada.Logic.Fight;
using Ikada.Logic.Journal;
using Ikada.Logic.Story;
using Ikada.Tests.Ecology;
using Ikada.Tests.Fight;

static class Program
{
    sealed class Ring
    {
        readonly float[] gap; readonly float[] low; readonly int[] tms; int n;
        public Ring(int cap) { gap = new float[cap]; low = new float[cap]; tms = new int[cap]; }
        public void Clear() => n = 0;
        public void Add(int ms, float g, bool lowT) { int i = n % gap.Length; gap[i] = g; low[i] = lowT ? 1f : 0f; tms[i] = ms; n++; }
        public (double taut, double low, int samples) Window(int windowMs)
        {
            if (n == 0) return (-1, -1, 0);
            int last = tms[(n - 1) % gap.Length], k = 0; double t = 0, l = 0;
            for (int j = n - 1; j >= Math.Max(0, n - gap.Length); j--)
            {
                int i = j % gap.Length;
                if (last - tms[i] >= windowMs) break;
                k++; if (gap[i] >= -0.005f) t++; l += low[i];
            }
            return (k == 0 ? -1 : t / k, k == 0 ? -1 : l / k, k);
        }
    }

    sealed class Tally
    {
        public int Days, Fights, PullSlack, Light, Real, PullShake; public readonly Dictionary<FightEnd, int> Ends = new Dictionary<FightEnd, int>();
        public readonly List<string> Lines = new List<string>(); public readonly List<int> PerDay = new List<int>(), LightPerDay = new List<int>();
        public void End(FightEnd e, (double taut, double low, int n) w, string where)
        {
            Fights++; Ends[e] = Ends.GetValueOrDefault(e) + 1;
            if (e == FightEnd.PullShake) PullShake++;
            if (e != FightEnd.PullSlack) return;
            PullSlack++; bool light = w.taut >= 0.5; if (light) Light++; else Real++;
            Lines.Add($"  PULL_SLACK {where} taut_share={w.taut:0.000} lowT_share={w.low:0.000} samples={w.n} -> {(light ? "LIGHT(#41)" : "really slack")}");
        }
    }

    static int Main(string[] a)
    {
        CultureInfo.DefaultThreadCurrentCulture = CultureInfo.InvariantCulture;
        string mode = a.Length > 0 ? a[0] : "human";
        int days = a.Length > 1 ? int.Parse(a[1]) : 20;
        if (mode == "human") Human(days); else Pilot(days, a.Length > 2 ? a[2] : "4-20,7-20,10-15,12-10");
        return 0;
    }

    static void Human(int days)
    {
        var skills = new (string, PlayerSkill)[] { ("Good", PlayerSkill.Good), ("Slack", PlayerSkill.Slack), ("Locked", PlayerSkill.Locked), ("PumpSlack(control: real slack)", PlayerSkill.PumpSlack) };
        foreach (var (season, m) in new (string, SeasonMonth?)[] { ("spring", null), ("July", Chapter2Season.For(7)) })
            foreach (var (sk, skill) in skills)
            {
                var T = new Tally(); var ring = new Ring(70000); ushort pullMs = 0; int fightNo = 0; uint dayNow = 0;
                FightHarness.Record = new List<(Ikada.Native.Species, float, FightEnd)>();
                int recSeen = 0;
                void Close() { while (recSeen < FightHarness.Record!.Count) { var r = FightHarness.Record[recSeen++]; T.End(r.end, ring.Window(pullMs), $"day {dayNow} fight {fightNo} {r.sp} {r.lengthCm:0}cm"); } }
                FightHarness.Probe = (ms, F, x, q, slackN, pull) =>
                {
                    if (ms == 0) { Close(); ring.Clear(); fightNo++; }
                    ring.Add(ms, q - x, F < slackN); pullMs = pull;
                };
                var p = new Profile(16, StrikeTiming.OnTake, 150f, 45f, fight: skill);
                for (uint s = 1; s <= (uint)days; s++)
                {
                    dayNow = s; int before = T.PullSlack, beforeL = T.Light;
                    var c = m == null ? new DayConditions() : new DayConditions { TempC = m.TempC, Activity = m.Activity };
                    if (m != null) { c.Density[Ikada.Native.Species.Chinu] = m.ChinuSeason; foreach (var kv in m.Stealers) c.Density[kv.Key] = kv.Value; }
                    c.Purchase = Ikada.Logic.Tackle.Inventory.Default();
                    FishingDay.Run(s, p, 8f, 0f, c);
                    Close(); T.Days++; T.PerDay.Add(T.PullSlack - before); T.LightPerDay.Add(T.Light - beforeL);
                }
                FightHarness.Probe = null;
                Report($"human {season} {sk}", T);
            }
    }

    static void Pilot(int seeds, string dates)
    {
        var fq = typeof(FightAi).GetField("_q", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance)!;
        var T = new Tally();
        foreach (string d in dates.Split(','))
        {
            int mo = int.Parse(d.Split('-')[0]), dy = int.Parse(d.Split('-')[1]);
            for (uint seed = 1; seed <= (uint)seeds; seed++)
            {
                var cfg = new DayConfig { Seed = seed, TimeSpeedIndex = ReferenceRun.TimeSpeedIndex, StoryFrom = new GameDate(Ikada.Game.Flow.Calendar.Year, mo, dy) };
                using var session = new IkadaSession(new SessionConfig { Day = cfg, SavePath = null, Lockstep = true, HudOn = true });
                session.Start();
                var pilot = new AutoPilot { Mode = "ストーリー", FastSkip = false, PreferMix = "赤土" };
                var ring = new Ring(8000); FightAi? cur = null; ushort pullMs = 0; int frames = 0, before = T.PullSlack, beforeL = T.Light, casts = 0;
                bool counted = false;
                while (frames / 60.0 < ReferenceRun.MaxSimS)
                {
                    frames++; float t = (float)(frames / 60.0);
                    var f = new InputFrame();
                    pilot.Apply(f, session.Flow, session.Link, t);
                    RenderSnapshot s = session.Step(ReferenceRun.FrameS, f);
                    pilot.See(s, t);
                    foreach (RenderEvent e in s.Events) if (e.Kind == RenderEventKind.Drop) casts++;
                    FightAi? fa = session.Flow.Day?.Session?.Fight;
                    if (fa != cur) { cur = fa; ring.Clear(); counted = false; }
                    if (fa != null && !counted)
                    {
                        if (!fa.Ended) { ring.Add(frames * 1000 / 60, (float)fq.GetValue(fa)! - session.Rig.X, false); pullMs = fa.PullSlackMs; }   // lowT n/a here (slack_N's units)
                        else { counted = true; T.End(fa.End, ring.Window(pullMs), $"{d} seed {seed} t={t:0.0}"); }
                    }
                }
                T.Days++; T.PerDay.Add(T.PullSlack - before); T.LightPerDay.Add(T.Light - beforeL);
                Console.WriteLine($"pilot {d} seed {seed}: casts {casts} fights so far {T.Fights} pull_slack this day {T.PullSlack - before} (light {T.Light - beforeL}) frames {frames}");
            }
        }
        Report("pilot", T);
    }

    static void Report(string name, Tally T)
    {
        Console.WriteLine($"== {name}: days {T.Days} fights {T.Fights} | ends " + string.Join(" ", T.Ends.OrderBy(k => k.Key).Select(k => $"{k.Key}={k.Value}")));
        Console.WriteLine($"   PULL_SLACK {T.PullSlack} ({(T.Fights == 0 ? 0 : 100.0 * T.PullSlack / T.Fights):0.0}% of fights) = LIGHT(#41) {T.Light} + really slack {T.Real}; per day max {(T.PerDay.Count == 0 ? 0 : T.PerDay.Max())}, days with a LIGHT end {T.LightPerDay.Count(v => v > 0)}/{T.Days}");
        foreach (string l in T.Lines.Take(40)) Console.WriteLine(l);
        if (T.Lines.Count > 40) Console.WriteLine($"  ... {T.Lines.Count - 40} more (cap 40, the counts above are complete)");
    }
}
