exec(open("mock.py").read().split("cases=")[0])
exec(open("both.py").read().split('ra=0.436')[0])
cases=[]
for lay in (0,30,40,55):
    yaw=-5-lay; r=ev2((-0.4,0.75,1.236),yaw,0.436,-1)
    cases.append(("魚が左・竿を右へ %d° 寝かす"%lay if lay else "魚が左・今のまま（0°）", "Run の見え方 %.2f・弧 %.0f px"%(r["Run"][0],r["Run"][1]), "画面に入る点 最少 %d/25"%min(v[2] for v in r.values()), yaw))
W,H,S=1920,1080,0.25
f=ImageFont.truetype(FONT,20)
img=Image.new("RGB",(int(W*S)*4+30,int(H*S)+110),"white"); d=ImageDraw.Draw(img)
for i,(t1,t2,t3,yaw) in enumerate(cases):
    ox=i*(int(W*S)+10); oy=100
    d.rectangle([ox,oy,ox+W*S,oy+H*S],fill=(58,92,120)); d.rectangle([ox,oy+0.40*H*S,ox+W*S,oy+H*S],fill=(40,70,95))
    d.rectangle([ox+0.22*W*S,oy+0.80*H*S,ox+0.93*W*S,oy+0.92*H*S],outline="white",width=1); d.text((ox+0.24*W*S,oy+0.81*H*S),"字幕の帯",font=f,fill="white")
    pts=[(ox+x*S,oy+y*S) for x,y in P((-0.4,0.75,1.236),yaw,-0.5)]; d.line(pts,fill=(235,200,120),width=4)
    tip=pts[-1]; d.line([tip,(tip[0]+math.tan(-0.5)*40,oy+H*S*0.95)],fill=(230,230,230),width=1)
    d.text((ox,2),t1,font=f,fill="black"); d.text((ox,30),t2,font=f,fill=(90,90,90)); d.text((ox,58),t3,font=f,fill=(90,90,90))
img.save("rod_side_strip.png"); print(img.size); print([c[1:3] for c in cases])
