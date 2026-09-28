# worker3: for the left-running fish, the smallest move from right075 (x-0.4, yaw-5) that gives Run>=0.3 and >=23/25 on screen in every phase
exec(open("both.py").read().split('ra=0.436')[0])
ra=0.436; hits=[]
for bx10 in range(-8,9):
    bx=bx10/10
    for yaw in range(-60,61,5):
        rm=ev2((bx,0.75,1.236),yaw,ra,-1)
        if rm["Run"][0]>=0.3 and all(v[2]>=23 for v in rm.values()):
            hits.append((abs(bx+0.4)+abs(yaw+5)/100.0,bx,yaw,rm))
hits.sort()
for c,bx,yaw,rm in hits[:5]:
    print("x %+.1f yaw %+d (butt px %.0f): %s"%(bx,yaw,px((bx,0.75,1.236))[0],row(rm)))
print("mirror of right075 = left075 (x+0.4 yaw+5), fish left:", row(ev2((0.4,0.75,1.236),5,ra,-1)))
print("left075, fish right:", row(ev2((0.4,0.75,1.236),5,ra,1)))
