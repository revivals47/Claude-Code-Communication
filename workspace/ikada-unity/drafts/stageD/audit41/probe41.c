/* probe41.c (worker3, AUDIT_41_42_W3.md): the instrument's positive / negative control on the C core (ikada-sim 2750f49).
 * Base = the audit's light_line (ikada-design 7779d97 research/fight-audit-20261002/realism_probe.c), PAUSE, thrust 0.
 * For each 1 ms tick it records gap = q - x; at the end it reports the share of the last pull_slack_ms window where the
 * line was geometrically taut (gap >= -0.005, the core's own SLACK_GEOM test, ikd_fight_risk.c:72) = the instrument. */
#include <stdio.h>
#include <string.h>
#include "ikd_fight.h"
#include "ikd_fight_draw.h"
#include "ikd_fight_risk.h"

static void run(const char *name, float x, int geom)
{
    ikd_fight_t f; ikd_fight_params_t p; ikd_hw_limits_t hw;
    static float gap[5000];
    memset(&f, 0, sizeof f);
    ikd_hw_limits_default(&hw);
    ikd_fight_preset(IKD_SP_CHINU, 12.0f, &p);
    p.fight_id = 1; p.valid_until_ms = 100000;
    p.phase = IKD_FPH_PAUSE; p.F_bias = 0; p.v_anchor = 0;
    p.yield_N = 1.3f; p.tow_Nspm = 0.4f;
    p.pull_slack_ms = 1000; p.shock_gain = 0;
    if (geom) p.flags |= IKD_FFL_SLACK_GEOM;
    ikd_fight_start(&f, &p, 5.0f, 0, 0, p.k, p.c, 0);
    float force = 0.4f; int i;
    for (i = 0; i < 3000 && f.end_cause == IKD_FEND_NONE; ++i) {
        force = ikd_fight_step(&f, &hw, x, 0, force, (unsigned)i, 0.001f);
        gap[i] = f.q - x;
    }
    int w = (int)p.pull_slack_ms, n = 0, taut = 0, k;
    for (k = i - w; k < i; ++k) if (k >= 0) { n++; if (gap[k] >= -0.005f) taut++; }
    printf("%s: x=%.3f geom=%d end=%d (pull_slack=%d) ticks=%d gap_end=%+.6f F_filt=%.4f slack_N=%.3f window=%d taut_share=%.3f\n",
           name, x, geom, f.end_cause, IKD_FEND_PULL_SLACK, i, f.q - x, f.F_filt, p.slack_N, n, n ? (double)taut / n : -1.0);
}

int main(void)
{
    run("A light-but-taut (audit)", 4.998f, 0);   /* positive control: PULL_SLACK, taut_share ~1 */
    run("B same, SLACK_GEOM on", 4.998f, 1);      /* the flag: no PULL_SLACK within 3 s */
    run("C really slack", 5.100f, 0);             /* negative control of the instrument: PULL_SLACK, taut_share ~0 */
    return 0;
}
