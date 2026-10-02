# held_measure.py - (worker3, boss1 12:43) per frame of a run: the tip's y (the topmost tip-coloured pixel in the window round
# the rest tip (925, 636)) and the reel / grip seen = pixels in x 480-1000, y >= 680 that are grip-dark (max < 60) or reel copper
# in this frame but not in the run's last frame (the rod back in the rest, same 06 HUD). Colour alone fails: the HUD panels are
# the grip's colour (c173_A2: 200k px in every frame). Controls: the rest frames -> tip 636 / reel ~0; c173_A2 8.5 s -> large.
import sys, glob, os
from PIL import Image
def tip(px):
    best = None
    for x in range(880, 990):
        for y in range(540, 800):
            r, g, b = px[x, y]
            if r - b > 70 and r > g + 25 and r > 170 and (best is None or y < best[1]): best = (x, y)
    return best
def mark(px, x, y):
    r, g, b = px[x, y]
    return max(r, g, b) < 60 or (r > 140 and r > g + 30 and b < 120)
def new_reel(px, rest, w, h):
    return sum(4 for x in range(480, 1000, 2) for y in range(680, h, 2) if mark(px, x, y) and not mark(rest, x, y))
for d in sys.argv[1:]:
    fs = sorted(glob.glob(os.path.join(d, "live_06_t*.png")), key=lambda p: float(p.rsplit("_t", 1)[1][:-4]))
    rest = Image.open(fs[-1]).convert("RGB").load()
    for f in fs:
        im = Image.open(f).convert("RGB")
        print(f"{os.path.basename(d)} {os.path.basename(f)[5:-4]:>9}: tip {tip(im.load())} reel/grip new px {new_reel(im.load(), rest, *im.size)}")
