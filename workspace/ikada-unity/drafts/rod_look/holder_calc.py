# holder_calc.py - where the waiting rod (right075, master e41e21c) meets the raft's front edge, in the world and on screen
# (worker3, ROD_HOLDER_PLAN.md). The same pinhole as BackdropBuilder.cs (ScreenRay / ScreenPointOnPlane / PitchDown), vfov 50.
import math
DeckTopY, EyeAbove, H0, Asp, VF = 0.45, 1.10, 0.392, 16/9, 50.0   # H0 = ImageHorizonFromTop (image backdrop, BackdropBuilder.cs:82)
Eye = (0.0, DeckTopY + EyeAbove, 0.0)
tanV = math.tan(math.radians(VF/2)); tanH = tanV*Asp
pitch = math.atan((0.5-H0)*2*tanV)            # down
def ray(x, y):
    lx, ly, lz = (x*2-1)*tanH, (0.5-y)*2*tanV, 1.0
    # rotate about x by +pitch (down): y' = y cos - z sin, z' = y sin + z cos  (Unity Euler(pitch,0,0), x right, y up, z fwd)
    c, s = math.cos(pitch), math.sin(pitch)
    r = (lx, ly*c - lz*s, ly*s + lz*c); n = math.sqrt(sum(v*v for v in r)); return tuple(v/n for v in r)
def on_plane(x, y, h):
    r = ray(x, y); t = (h - Eye[1]) / r[1]; return tuple(Eye[i] + r[i]*t for i in range(3))
def to_screen(p):
    d = tuple(p[i]-Eye[i] for i in range(3)); c, s = math.cos(pitch), math.sin(pitch)
    ly = d[1]*c + d[2]*s; lz = -d[1]*s + d[2]*c   # inverse rotation
    return ((d[0]/lz/tanH + 1)/2*1920, (0.5 - ly/lz/tanV/2)*1080)
h = DeckTopY + 0.30
butt = on_plane(0.80, 1.05, h); tip = on_plane(0.53, 0.59, h)
L = math.dist(butt, tip); yaw = math.radians(-5)   # right075: -HandYawDeg (BackdropBuilderProps.cs HandPose; 5 deg RIGHT)
butt = (-0.40, butt[1], butt[2]); tip = (butt[0] - math.sin(yaw)*L, butt[1], butt[2] + math.cos(yaw)*L)   # HandPose(right)
front = on_plane(0.5, 646/941, DeckTopY)[2]
f = (front - butt[2]) / (tip[2] - butt[2]); cross = tuple(butt[i] + (tip[i]-butt[i])*f for i in range(3))
print(f"pitch {math.degrees(pitch):.2f} deg; rod length {L:.3f} m; butt ({butt[0]:.3f}, {butt[1]:.3f}, {butt[2]:.3f}) tip ({tip[0]:.3f}, {tip[1]:.3f}, {tip[2]:.3f})")
print(f"deck front z {front:.3f} m (PlateDeckEdgeScreenY 646/941); rod over the edge at s = {f*L:.3f} m from the butt, world {tuple(round(v,3) for v in cross)}")
for name, p in (("butt", butt), ("edge crossing (rod)", cross), ("edge under it (deck)", (cross[0], DeckTopY, cross[2])), ("tip", tip)):
    sx, sy = to_screen(p); print(f"  {name}: screen ({sx:.0f}, {sy:.0f})")
print("along the rod (s from the butt): rod point / the deck under it, on screen")
for s in (0.2, 0.5, 0.8, 1.0, 1.4, 1.8, 2.2, 2.5, 2.709):
    f = s / L; p = tuple(butt[i] + (tip[i]-butt[i])*f for i in range(3))
    a = to_screen(p); b = to_screen((p[0], DeckTopY, p[2]))
    print(f"  s {s:.2f} m (z {p[2]:.2f}): rod ({a[0]:.0f}, {a[1]:.0f}) deck ({b[0]:.0f}, {b[1]:.0f}) post {b[1]-a[1]:.0f} px")
