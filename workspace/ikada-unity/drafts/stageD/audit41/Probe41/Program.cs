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
        if (mode == "koaji") { Koaji(a[1]); return 0; }      // its 2nd argument is a list, not a number
        int days = a.Length > 1 ? int.Parse(a[1]) : 20;
        if (mode == "rope") { Rope(days, a[2], a[3], a[4]); return 0; }
        if (mode == "ropetrace") { RopeTrace(days, a[2], a[3], a[4]); return 0; }
        if (mode == "weather") return Weather(days, a[2]);   // PR v2 (2): weather <seeds N> <M-D>
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

    // #42: one cell = skill x season x rope distance (m beyond the start line, or "none" = +inf), one line (chunkable runs)
    static void Rope(int days, string skillName, string season, string ropeArg)
    {
        PlayerSkill skill = (PlayerSkill)Enum.Parse(typeof(PlayerSkill), skillName);
        SeasonMonth? m = season == "July" ? Chapter2Season.For(7) : null;
        FightHarness.RopeAheadM = ropeArg == "none" ? (float?)null : float.Parse(ropeArg, CultureInfo.InvariantCulture);
        var p = new Profile(16, StrikeTiming.OnTake, 150f, 45f, fight: skill);
        int hooked = 0, landed = 0, dives = 0, fightsWithDive = 0; var ends = new Dictionary<FightEnd, int>(); var secs = new List<float>();
        FightHarness.Record = new List<(Ikada.Native.Species, float, FightEnd)>();
        for (uint s = 1; s <= (uint)days; s++)
        {
            var c = m == null ? new DayConditions() : new DayConditions { TempC = m.TempC, Activity = m.Activity };
            if (m != null) { c.Density[Ikada.Native.Species.Chinu] = m.ChinuSeason; foreach (var kv in m.Stealers) c.Density[kv.Key] = kv.Value; }
            c.Purchase = Ikada.Logic.Tackle.Inventory.Default();
            DayTally t = FishingDay.Run(s, p, 8f, 0f, c);
            hooked += t.Hooked; landed += t.Landed; dives += t.FightDives; secs.AddRange(t.FightSeconds);
            foreach (var kv in t.Ends) ends[kv.Key] = ends.GetValueOrDefault(kv.Key) + kv.Value;
        }
        FightHarness.RopeAheadM = null;
        int fights = ends.Values.Sum(); secs.Sort();
        string E(FightEnd e) => $"{ends.GetValueOrDefault(e)}({(fights == 0 ? 0 : 100.0 * ends.GetValueOrDefault(e) / fights):0.0}%)";
        Console.WriteLine($"rope {skillName} {season} d={ropeArg} days={days} hooked={hooked} fights={fights} landed/day={landed / (double)days:0.00} " +
                          $"Landed={E(FightEnd.Landed)} Wrapped={E(FightEnd.Wrapped)} PullSlack={E(FightEnd.PullSlack)} PullShake={E(FightEnd.PullShake)} " +
                          $"BreakT={E(FightEnd.BreakTension)} BreakW={E(FightEnd.BreakWear)} Mouth={E(FightEnd.MouthTear)} Abort={E(FightEnd.Abort)} " +
                          $"dives/fight={(fights == 0 ? 0 : dives / (double)fights):0.00} median_s={(secs.Count == 0 ? 0 : secs[secs.Count / 2]):0}");
    }

    // #42 trace: each rope-zone entry (FightAi._ropeZone false -> true, only updated in DIVE) followed tick by tick (10 ms)
    static void RopeTrace(int days, string skillName, string season, string ropeArg)
    {
        var BF = System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance;
        var ty = typeof(FightAi);
        var fZone = ty.GetField("_ropeZone", BF)!; var fHold = ty.GetField("_ropeHoldT", BF)!; var fLow = ty.GetField("_ropeLowT", BF)!;
        var fWrap = ty.GetField("_tWrap", BF)!; var fRun = ty.GetField("_run", BF)!; var fQ = ty.GetField("_q", BF)!; var fS = ty.GetField("_s", BF)!;
        PlayerSkill skill = (PlayerSkill)Enum.Parse(typeof(PlayerSkill), skillName);
        SeasonMonth? m = season == "July" ? Chapter2Season.For(7) : null;
        FightHarness.RopeAheadM = float.Parse(ropeArg, CultureInfo.InvariantCulture);
        FightAi? cur = null; bool inEp = false; int fights = 0, entries = 0, diveTicksNoZone = 0, lines = 0;
        var outc = new Dictionary<string, int>();
        int epTicks = 0, epHoldTicks = 0, epCross = 0; float epHoldMax = 0, epLowMax = 0, epTmin = 0, epTmax = 0, epTsum = 0, epWrap = 0, epHoldN = 0, epQ = 0, epRope = 0; bool lastHi = false;
        float prevHold = 0, prevLow = 0;
        void Close(FightAi ai, string why)
        {
            string k = why; outc[k] = outc.GetValueOrDefault(k) + 1;
            if (lines++ < 60)
                Console.WriteLine($"  entry {entries}: {k} ticks={epTicks} T mean={epTsum / Math.Max(1, epTicks):0.00} min={epTmin:0.00} max={epTmax:0.00} hold(0.8FRun)={epHoldN:0.00} " +
                                  $"T>=hold {100.0 * epHoldTicks / Math.Max(1, epTicks):0}% crossings={epCross} holdT max={epHoldMax:0.00}s lowT max={epLowMax:0.00}s tWrap={epWrap:0.00}s q={epQ:0.00} ropeQ={epRope:0.00}");
            inEp = false;
        }
        FightHarness.TickProbe = (ai, now) =>
        {
            if (ai != cur) { if (inEp && cur != null) Close(cur, "fight-switch"); cur = ai; fights++; }
            bool zone = (bool)fZone.GetValue(ai)!; float hold = (float)fHold.GetValue(ai)!, low = (float)fLow.GetValue(ai)!;
            float T = ai.LastTensionN; float frun = ((FightParams)fRun.GetValue(ai)!).FBias; float h = 0.8f * frun;
            if (ai.Phase == FightPhase.Dive && !zone) diveTicksNoZone++;
            if (zone && !inEp)
            {
                inEp = true; entries++; epTicks = epHoldTicks = epCross = 0; epHoldMax = epLowMax = epTsum = 0; epTmin = epTmax = T; lastHi = T >= h;
                epWrap = (float)fWrap.GetValue(ai)!; epHoldN = h; epQ = (float)fQ.GetValue(ai)!; epRope = ((FightSetup)fS.GetValue(ai)!).RopeQ;
            }
            if (inEp)
            {
                if (zone) { epTicks++; epTsum += T; epTmin = Math.Min(epTmin, T); epTmax = Math.Max(epTmax, T); bool hi = T >= h; if (hi) epHoldTicks++; if (hi != lastHi) epCross++; lastHi = hi;
                            epHoldMax = Math.Max(epHoldMax, hold); epLowMax = Math.Max(epLowMax, low); prevHold = hold; prevLow = low; }
                if (ai.Ended) Close(ai, ai.End == FightEnd.Wrapped ? "WRAPPED (lowT >= tWrap, 50% cut)" : "fight ended " + ai.End);
                else if (!zone) Close(ai, prevHold >= 0.29f ? "ESCAPED (holdT 0.3 s)" : prevLow >= epWrap - 0.011f ? "survived wrap draw (+wear, pause)" : "left zone otherwise");
            }
        };
        var p = new Profile(16, StrikeTiming.OnTake, 150f, 45f, fight: skill);
        for (uint s = 1; s <= (uint)days; s++)
        {
            var c = m == null ? new DayConditions() : new DayConditions { TempC = m.TempC, Activity = m.Activity };
            if (m != null) { c.Density[Ikada.Native.Species.Chinu] = m.ChinuSeason; foreach (var kv in m.Stealers) c.Density[kv.Key] = kv.Value; }
            c.Purchase = Ikada.Logic.Tackle.Inventory.Default();
            FishingDay.Run(s, p, 8f, 0f, c);
        }
        FightHarness.TickProbe = null; FightHarness.RopeAheadM = null;
        Console.WriteLine($"ropetrace {skillName} {season} d={ropeArg} days={days} fights={fights} zone entries={entries} dive ticks outside the zone={diveTicksNoZone} | " +
                          string.Join(" ", outc.OrderByDescending(k => k.Value).Select(k => $"[{k.Key}]={k.Value}")));
    }

    // PR v2 (2) (worker3, PR_VIDEO_V2_PLAN.md): the day's weather of world seeds 1..N on one date (Calendar.Get with RngTree.World(seed),
    // the drawn sky = SnapshotBuilder.SkyOf(Weather) for the whole day). Positive control: seed 26 on 4/20 = 雨 (its live 4/20 was rain all day,
    // PR_CAPTURE_W3.md §9). Prints the counts and one line per sunny, not cancelled seed (seed, wind) = the input of sunny_seed_scan.sh.
    static int Weather(int n, string md)
    {
        var d = new GameDate(Ikada.Game.Flow.Calendar.First.Year, int.Parse(md.Split('-')[0]), int.Parse(md.Split('-')[1]));
        var count = new Dictionary<string, int>(); var sunny = new List<string>();
        for (uint seed = 1; seed <= (uint)n; seed++)
        {
            DayInfo i = Ikada.Game.Flow.Calendar.Get(d, Ikada.Logic.Rng.RngTree.World(seed));
            string k = i.Weather + (i.Cancelled ? "/欠航" : "");
            count[k] = count.GetValueOrDefault(k) + 1;
            if (i.Weather == "晴れ" && !i.Cancelled) sunny.Add($"{seed}\t{i.Wind}");
            if (seed == 26) Console.Error.WriteLine($"[weather] control seed 26 {md}: {i.Weather} {i.Wind} cancelled={i.Cancelled}");
        }
        Console.Error.WriteLine($"[weather] {md} seeds 1-{n}: " + string.Join(", ", count.OrderByDescending(x => x.Value).Select(x => $"{x.Key} {x.Value}")) + $"; sunny not cancelled {sunny.Count}");
        foreach (string l in sunny) Console.WriteLine(l);
        return 0;
    }

    // AJI_HOOKUP_W3.md §3 (PRESIDENT 11:2x, measure only): the pecks of every species on the hook bait (EcoSim.Pecks, OnBait) per day, on
    // story days run as ReferenceRun.RunAt does (lockstep, 60 Hz frames, AutoPilot, --place on the prep screen). The eco steps every 10 logic
    // ticks (FishingSession.cs:315, private _ecoTicks) and clears Pecks each step (EcoSim.cs:294); a frame runs <= 2 ticks, so a wrap of
    // _ecoTicks within a frame = exactly one eco step, whose Pecks are read once. Positive control: E' (4/20 raft 3, the rig drifts).
    static void Koaji(string list)
    {
        var fTicks = typeof(FishingSession).GetField("_ecoTicks", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance)!;
        foreach (string item in list.Split(','))
        {
            var q = item.Split(':'); uint seed = uint.Parse(q[0]); int mo = int.Parse(q[1].Split('-')[0]), dy = int.Parse(q[1].Split('-')[1]); int raft = q.Length > 2 ? int.Parse(q[2]) : 0;
            var cfg = new DayConfig { Seed = seed, TimeSpeedIndex = ReferenceRun.TimeSpeedIndex, StoryFrom = new GameDate(Ikada.Game.Flow.Calendar.Year, mo, dy) };
            using var session = new IkadaSession(new SessionConfig { Day = cfg, SavePath = null, Lockstep = true, HudOn = true });
            session.Start();
            var pilot = new AutoPilot { Mode = "ストーリー", FastSkip = false, PreferMix = "赤土" };
            bool placed = raft <= 0; int frames = 0, casts = 0, ecoSteps = 0; FishingSession? last = null; int prev = 0;
            var bait = new Dictionary<Ikada.Native.Species, int>(); var dango = new Dictionary<Ikada.Native.Species, int>(); var koajiCasts = new HashSet<int>();
            while (frames / 60.0 < ReferenceRun.MaxSimS)
            {
                frames++; float t = (float)(frames / 60.0);
                var f = new InputFrame();
                pilot.Apply(f, session.Flow, session.Link, t);
                if (!placed && session.Flow.Day != null && session.Flow.Day.SelectRaft(raft)) placed = true;
                RenderSnapshot s = session.Step(ReferenceRun.FrameS, f);
                pilot.See(s, t);
                foreach (RenderEvent e in s.Events) if (e.Kind == RenderEventKind.Drop) casts++;
                var fs = session.Flow.Day?.Session;
                if (fs == null) continue;
                int now = (int)fTicks.GetValue(fs)!;
                if (fs != last) { last = fs; prev = now; continue; }
                if (now < prev)                                                       // wrapped = one eco step in this frame
                {
                    ecoSteps++;
                    foreach (var pk in fs.Eco.Pecks)
                    {
                        var d = pk.OnBait ? bait : dango; d[pk.Species] = d.GetValueOrDefault(pk.Species) + 1;
                        if (pk.OnBait && pk.Species == Ikada.Native.Species.Koaji) koajiCasts.Add(casts);
                    }
                }
                prev = now;
            }
            string B(Dictionary<Ikada.Native.Species, int> d) => string.Join(" ", d.OrderBy(k => k.Key).Select(k => $"{k.Key}={k.Value}"));
            Console.WriteLine($"koaji {item}: casts {casts} ecoSteps {ecoSteps} | bait pecks: Koaji={bait.GetValueOrDefault(Ikada.Native.Species.Koaji)} casts-with-koaji-bait-peck={koajiCasts.Count} | all bait [{B(bait)}] | dango [{B(dango)}]");
        }
    }

    static void Report(string name, Tally T)
    {
        Console.WriteLine($"== {name}: days {T.Days} fights {T.Fights} | ends " + string.Join(" ", T.Ends.OrderBy(k => k.Key).Select(k => $"{k.Key}={k.Value}")));
        Console.WriteLine($"   PULL_SLACK {T.PullSlack} ({(T.Fights == 0 ? 0 : 100.0 * T.PullSlack / T.Fights):0.0}% of fights) = LIGHT(#41) {T.Light} + really slack {T.Real}; per day max {(T.PerDay.Count == 0 ? 0 : T.PerDay.Max())}, days with a LIGHT end {T.LightPerDay.Count(v => v > 0)}/{T.Days}");
        foreach (string l in T.Lines.Take(40)) Console.WriteLine(l);
        if (T.Lines.Count > 40) Console.WriteLine($"  ... {T.Lines.Count - 40} more (cap 40, the counts above are complete)");
    }
}
