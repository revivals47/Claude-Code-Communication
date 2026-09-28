# worker3: both fish sides (L3 61cee7d: the line's sign follows the fish). Same model as worker1's place10.py (positive control = mirror11.py reproduces ROD_ARC_SHAPE §11).
import math
exec(open("place10.py").read().split("for ra in")[0])
PH2=[("Run",0.5),("Side",0.4),("Pause",0.0),("Turn",0.2),("Dive",0.1)]
def ev2(butt,yaw,ra,sign):
    global PH
    PH=[(n,sign*l) for n,l in PH2]
    return ev(butt,yaw,ra)
def row(r): return " | ".join("%s %.2f/%.0f%s"%(k,v[0],v[1],"" if v[2]>=23 else "(in %d)"%v[2]) for k,v in r.items())
ra=0.436
print("== now: right075 (x-0.4 yaw-5)")
for s in (1,-1): print("  fish %s:"%("right" if s>0 else "left "),row(ev2((-0.4,0.75,1.236),-5,ra,s)))
print("== (A) one placement, best min(Run+,Run-) with >=23/25 in every phase both sides")
best=[]
for bx in [x/10 for x in range(-8,9,1)]:
    for yaw in range(-60,61,5):
        rp=ev2((bx,0.75,1.236),yaw,ra,1); rm=ev2((bx,0.75,1.236),yaw,ra,-1)
        if all(v[2]>=23 for v in list(rp.values())+list(rm.values())):
            best.append((min(rp["Run"][0],rm["Run"][0]),bx,yaw,rp,rm))
best.sort(reverse=True)
for m,bx,yaw,rp,rm in best[:4]:
    print("  x %+.1f yaw %+d min %.2f\n    right: %s\n    left : %s"%(bx,yaw,m,row(rp),row(rm)))
print("== (B) butt stays x-0.4; rod yaw for the left-running fish (right side keeps yaw -5)")
for yaw in range(-5,61,5):
    rm=ev2((-0.4,0.75,1.236),yaw,ra,-1)
    print("  yaw %+d left: %s"%(yaw,row(rm)))
