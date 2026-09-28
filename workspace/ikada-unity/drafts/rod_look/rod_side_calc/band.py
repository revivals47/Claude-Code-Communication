exec(open("place10.py").read().split("for ra in")[0])
import math
def pts_px(butt,yaw,ra,line):
    y=math.radians(yaw); a0=(-math.sin(y),0,math.cos(y))
    pts,th=shape2(butt,a0,L,2.6,line,ra); return [px(p)[:2] for p in pts]
def inband(P): return sum(1 for x,y in P if 0.22*1920<=x<=0.93*1920 and 0.80*1080<=y<=0.92*1080)
for nm,yaw,line in [("now fish right Run",-5,0.5),("now fish left Run",-5,-0.5),("proposal fish left Run",-60,-0.5),("proposal fish left Side",-60,-0.4),("proposal fish left Pause",-60,0.0)]:
    P=pts_px((-0.4,0.75,1.236),yaw,0.436,line)
    print("%-26s pts in subtitle band %d/%d  butt px (%.0f,%.0f) tip px (%.0f,%.0f)"%(nm,inband(P),len(P),*P[0],*P[-1]))
