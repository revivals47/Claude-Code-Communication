// GDay (worker3, AJI_HOOKUP_W3.md §8, PRESIDENT 11:4x: how much of the chinu's time does a koaji self-hook take on G's day): per story day
// (IkadaSession lockstep, 60 Hz frames, AutoPilot, as ReferenceRun.RunAt) the casts, the catches by species (the day log), the casts' SelfHooks
// (reflection: the field exists only on the koaji branch = 0 on the base), and the sim seconds the rig spent in a fight with each species
// (FishingSession private _fightSp while State == Fight). Measure only.
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
using Ikada.Native;

static class Program
{
    static int Main(string[] a)
    {
        CultureInfo.DefaultThreadCurrentCulture = CultureInfo.InvariantCulture;
        string label = a[0];
        var fSp = typeof(FishingSession).GetField("_fightSp", BindingFlags.NonPublic | BindingFlags.Instance)!;
        var fSelf = typeof(CastRecord).GetField("SelfHooks");
        foreach (string item in a[1].Split(','))
        {
            var q = item.Split(':'); uint seed = uint.Parse(q[0]); int mo = int.Parse(q[1].Split('-')[0]), dy = int.Parse(q[1].Split('-')[1]); int raft = q.Length > 2 ? int.Parse(q[2]) : 0;
            var cfg = new DayConfig { Seed = seed, TimeSpeedIndex = ReferenceRun.TimeSpeedIndex, StoryFrom = new GameDate(Ikada.Game.Flow.Calendar.Year, mo, dy) };
            using var session = new IkadaSession(new SessionConfig { Day = cfg, SavePath = null, Lockstep = true, HudOn = true });
            session.Start();
            var pilot = new AutoPilot { Mode = "ストーリー", FastSkip = false, PreferMix = "赤土" };
            bool placed = raft <= 0; int frames = 0, casts = 0;
            var fightS = new Dictionary<Species, double>();
            var fightByDay = new Dictionary<string, Dictionary<Species, double>>();   // v2: per DayLog date (Book.Today at the frame)
            DayLog? day = null;
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
                if (session.Flow.Day != null) day = session.Flow.Day.Book.Today ?? day;
                if (fs != null && fs.State == RigState.Fight) { var sp = (Species)fSp.GetValue(fs)!; fightS[sp] = fightS.GetValueOrDefault(sp) + 1.0 / 60.0;
                    string dk = day?.Date.ToString() ?? "?"; if (!fightByDay.TryGetValue(dk, out var fd)) fightByDay[dk] = fd = new Dictionary<Species, double>(); fd[sp] = fd.GetValueOrDefault(sp) + 1.0 / 60.0; }
            }
            // v2 (worker3 12:4x, KTrace): the 12000 s run crosses into the next story day; v1 counted only the LAST DayLog. Sum every
            // DayLog of the book (and print each day) so the catches / self-hooks cover the same span as the fight seconds and casts.
            var days = session.Flow.Day?.Book.Days ?? (day == null ? new List<DayLog>() : new List<DayLog> { day });
            var catches = days.SelectMany(d => d.Catches).Where(c => !c.Npc).GroupBy(c => c.Species).ToDictionary(g => g.Key, g => g.Count());
            int self = fSelf == null ? 0 : days.SelectMany(d => d.Casts).Sum(c => (int)fSelf.GetValue(c)!);
            foreach (DayLog d in days)
                Console.WriteLine($"{label} {item} daylog {d.Date}: casts {d.Casts.Count} selfhooks {(fSelf == null ? 0 : d.Casts.Sum(c => (int)fSelf.GetValue(c)!))} | catches "
                                  + string.Join(" ", d.Catches.Where(c => !c.Npc).GroupBy(c => c.Species).OrderBy(g => g.Key).Select(g => $"{g.Key}={g.Count()}"))
                                  + " | fight s " + string.Join(" ", (fightByDay.TryGetValue(d.Date.ToString(), out var fdd) ? fdd : new Dictionary<Species, double>()).OrderBy(k => k.Key).Select(k => $"{k.Key}={k.Value:0}")));
            Console.WriteLine($"{label} {item}: casts {casts} selfhooks {self} | catches " + string.Join(" ", catches.OrderBy(k => k.Key).Select(k => $"{k.Key}={k.Value}"))
                              + " | fight s " + string.Join(" ", fightS.OrderBy(k => k.Key).Select(k => $"{k.Key}={k.Value:0}")));
        }
        return 0;
    }
}
