# held_lift_calc.py - (worker3, boss1 12:43) the dip while held over the rest: tip y on screen for lift L, rod turned about its
# butt by a (rad, - = tip down), the rod at the cradle kept >= the cradle point + c (no pass through) unless moved aside.
import math, importlib.util, io, contextlib
spec = importlib.util.spec_from_file_location("hc", "holder_calc.py"); hc = importlib.util.module_from_spec(spec)
with contextlib.redirect_stdout(io.StringIO()): spec.loader.exec_module(hc)
butt, tip, S = hc.butt, hc.tip, hc.to_screen
Lr = math.dist(butt, tip); dc = 3.845 - butt[2]; dc /= math.cos(math.radians(5))   # butt -> cradle along the rod (horizontal)
c = 0.045
def pose(L, a, side=0.0):
    u = [(tip[i]-butt[i])/Lr for i in range(3)]; rx = (u[2], 0, -u[0])    # right, horizontal
    b = (butt[0]+rx[0]*side, butt[1]+L, butt[2]+rx[2]*side)
    t = (b[0]+u[0]*Lr*math.cos(a), b[1]+Lr*math.sin(a), b[2]+u[2]*Lr*math.cos(a))
    return b, t
def report(name, L, a, side=0.0):
    b, t = pose(L, a, side); cy = L + dc*math.sin(a)
    bs, ts = S(b), S(t); print(f"{name}: a {a:+.4f} rad  rod at the cradle {cy:+.3f} m vs point  tip ({ts[0]:.0f}, {ts[1]:.0f})  dy_tip {ts[1]-S(tip)[1]:+.0f} px  butt ({bs[0]:.0f}, {bs[1]:.0f})")
print(f"rest tip {tuple(round(v) for v in S(tip))}, butt {tuple(round(v) for v in S(butt))}, butt->cradle {dc:.3f} m, rod {Lr:.3f} m")
report("pre-holder (no rest, L 0, a -0.10)", 0.0, -0.10)
for L in (0.05, 0.10, 0.30):
    a = max(-0.10, -math.asin(max(0.0, L - c)/dc))
    report(f"over the rest L {L:.2f}", L, a)
report("aside L 0.05 side 0.10 (full -0.10)", 0.05, -0.10, 0.10)
