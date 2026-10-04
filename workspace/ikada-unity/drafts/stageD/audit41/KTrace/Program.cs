// KTrace (worker3, AJI_HOOKUP_W3.md §12, PRESIDENT 12:2x/12:3x: where does a koaji fight's ~100 s go): GDay's day loop; for every koaji
// fight, per 1/60 s frame: seconds in each FightPhase, seconds with line q <= 2 m (landing distance), seconds in the landing window
// (_landingReady) and in it while taut, bolts near the rod (entries to Run with q <= 2.5 m and stamina >= 0.3, FightAi.cs:279), the stamina
// when q first reaches 2 m, the end. v3: arg 2 "full" reels at 1.0 in a fight. v2: the fight's start time and, per item, every DayLog in the book (GDay reads only the last one). Reads FightAi private fields by reflection. Measure only.
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Reflection;
using Ikada.Game;
using Ikada.Game.Flow;
using Ikada.Game.Input;
using Ikada.Game.Render;
using Ikada.Logic.Fight;
using Ikada.Logic.Journal;
using Ikada.Native;

static class Program
{
    static int Main(string[] a)
    {
        CultureInfo.DefaultThreadCurrentCulture = CultureInfo.InvariantCulture;
        var fSp = typeof(FishingSession).GetField("_fightSp", BindingFlags.NonPublic | BindingFlags.Instance)!;
        BindingFlags pf = BindingFlags.NonPublic | BindingFlags.Instance;
        var fQ = typeof(FightAi).GetField("_q", pf)!; var fReady = typeof(FightAi).GetField("_landingReady", pf)!; var fTaut = typeof(FightAi).GetField("_taut", pf)!;
        var all = new List<double[]>();
        bool full = a.Length > 1 && a[1] == "full";   // v3: "full" = AutoPilot's fight reel 0.7 -> 1.0 (the full trigger)
        foreach (string item in a[0].Split(','))
        {
            var q = item.Split(':'); uint seed = uint.Parse(q[0]); int mo = int.Parse(q[1].Split('-')[0]), dy = int.Parse(q[1].Split('-')[1]);
            var cfg = new DayConfig { Seed = seed, TimeSpeedIndex = ReferenceRun.TimeSpeedIndex, StoryFrom = new GameDate(Ikada.Game.Flow.Calendar.Year, mo, dy) };
            using var session = new IkadaSession(new SessionConfig { Day = cfg, SavePath = null, Lockstep = true, HudOn = true });
            session.Start();
            var pilot = new AutoPilot { Mode = "ストーリー", FastSkip = false, PreferMix = "赤土" };
            int frames = 0; FightAi? cur = null; double[]? acc = null; FightPhase last = FightPhase.None; bool reached = false; float lastQ = 0f;
            while (frames / 60.0 < ReferenceRun.MaxSimS)
            {
                frames++; float t = (float)(frames / 60.0);
                var f = new InputFrame();
                pilot.Apply(f, session.Flow, session.Link, t);
                if (full && f.Reel > 0f && session.Flow.Day?.Session?.State == RigState.Fight) f.Reel = 1f;   // v3: the full-reel arm (PRESIDENT 12:4x)
                RenderSnapshot s = session.Step(ReferenceRun.FrameS, f);
                pilot.See(s, t);
                var fs = session.Flow.Day?.Session;
                FightAi? ai = fs != null && fs.State == RigState.Fight && (Species)fSp.GetValue(fs)! == Species.Koaji ? fs.Fight : null;
                if (cur != null && ai != cur)
                {   // [0..7]=phase s, 8=total, 9=q<=2 s, 10=ready s, 11=ready&taut s, 12=bolts near rod, 13=stamina at first q<=2, 14=end, 15=seed, 16=drag slip s (snapshot DragSlipping), 17=line out gained m (sum of q increases), 18=q at the first fight frame
                    acc![14] = (double)cur.End; acc[15] = seed; all.Add(acc);
                    Console.WriteLine($"{item} fish: start q {acc[18]:0.0} m total {acc[8]:0.0} s | " + string.Join(" ", Enumerable.Range(1, 7).Where(i => acc[i] > 0).Select(i => $"{(FightPhase)i}={acc[i]:0.0}"))
                        + $" | q<=2m {acc[9]:0.0} ready {acc[10]:0.0} ready&taut {acc[11]:0.0} | bolts near rod {acc[12]} | S at 2m {acc[13]:0.00} | drag slip {acc[16]:0.0} s line out gained {acc[17]:0.00} m | end {cur.End}");
                    cur = null;
                }
                if (ai != null)
                {
                    if (cur == null) { cur = ai; acc = new double[19]; acc[13] = -1; lastQ = (float)fQ.GetValue(ai)!; acc[18] = lastQ; last = FightPhase.None; reached = false; }
                    double dt = 1.0 / 60.0; float qv = (float)fQ.GetValue(ai)!;
                    acc![(int)ai.Phase] += dt; acc[8] += dt;
                    if (qv <= 2f) { acc[9] += dt; if (!reached) { reached = true; acc[13] = ai.Stamina; } }
                    bool rd = (bool)fReady.GetValue(ai)!; if (rd) { acc[10] += dt; if ((bool)fTaut.GetValue(ai)!) acc[11] += dt; }
                    if (ai.Phase == FightPhase.Run && last != FightPhase.Run && qv <= 2.5f && ai.Stamina >= 0.3f) acc[12]++;
                    if (s.DragSlipping) acc[16] += dt; if (qv > lastQ) acc[17] += qv - lastQ; lastQ = qv;
                    last = ai.Phase;
                }
            }
            var book = session.Flow.Day?.Book;
            var fSelf = typeof(Ikada.Logic.Journal.CastRecord).GetField("SelfHooks");
            if (book != null) foreach (var d in book.Days)
                Console.WriteLine($"{item} daylog {d.Date}: casts {d.Casts.Count} selfhooks {(fSelf == null ? 0 : d.Casts.Sum(c => (int)fSelf.GetValue(c)!))} koaji catches {d.Catches.Count(c => !c.Npc && c.Species == Species.Koaji)} all catches {d.Catches.Count(c => !c.Npc)}");
            else Console.WriteLine($"{item} daylog: no book (Flow.Day null at the end)");
        }
        if (all.Count > 0)
        {
            double M(int i) => all.Average(x => x[i]);
            Console.WriteLine($"== koaji fights {all.Count}: mean total {M(8):0.0} s | " + string.Join(" ", Enumerable.Range(1, 7).Select(i => $"{(FightPhase)i}={M(i):0.0}"))
                + $" | q<=2m {M(9):0.0} ready {M(10):0.0} ready&taut {M(11):0.0} | bolts near rod {M(12):0.0} | S at 2m {all.Where(x => x[13] >= 0).Select(x => x[13]).DefaultIfEmpty(-1).Average():0.00} | drag slip {M(16):0.00} s line out gained {M(17):0.00} m | fights with slip>0 {all.Count(x => x[16] > 0)}");
        }
        return 0;
    }
}
