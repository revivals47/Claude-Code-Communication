exec(open("place10.py").read().split("for ra in")[0])
import math
from PIL import Image, ImageDraw, ImageFont
FONT="/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc"
def P(butt,yaw,line,ra=0.436):
    y=math.radians(yaw); a0=(-math.sin(y),0,math.cos(y))
    pts,th=shape2(butt,a0,L,2.6,line,ra); return [px(p)[:2] for p in pts]
cases=[("今（右巻き）・魚が右へ Run","x -0.4・右 5°",(-0.4,0.75,1.236),-5,0.5),
       ("今（右巻き）・魚が左へ Run","同じ置き方",(-0.4,0.75,1.236),-5,-0.5),
       ("推奨: 魚が左の時だけ 竿を右へ 55° 寝かす","手（元）は動かさない",(-0.4,0.75,1.236),-60,-0.5),
       ("退けた案: 竿をいつも横たえる（魚が右）","x -0.8・右 60°",(-0.8,0.75,1.236),-60,0.5),
       ("退けた案: 竿をいつも横たえる（魚が左）","x -0.8・右 60°",(-0.8,0.75,1.236),-60,-0.5)]
W,H,S=1920,1080,0.25
f=ImageFont.truetype(FONT,26); fs=ImageFont.truetype(FONT,20)
img=Image.new("RGB",(int(W*S)*len(cases)+10*(len(cases)-1),int(H*S)+120),"white")
d=ImageDraw.Draw(img)
for i,(t1,t2,butt,yaw,line) in enumerate(cases):
    ox=i*(int(W*S)+10); oy=110
    d.rectangle([ox,oy,ox+W*S,oy+H*S],fill=(58,92,120))
    hy=oy+0.40*H*S; d.rectangle([ox,hy,ox+W*S,oy+H*S],fill=(40,70,95))
    d.rectangle([ox+0.22*W*S,oy+0.80*H*S,ox+0.93*W*S,oy+0.92*H*S],outline=(255,255,255),width=1)
    d.text((ox+0.24*W*S,oy+0.81*H*S),"字幕の帯",font=fs,fill="white")
    pts=[(ox+x*S,oy+y*S) for x,y in P(butt,yaw,line)]
    d.line(pts,fill=(235,200,120),width=4)
    tip=pts[-1]; d.line([tip,(tip[0]+math.tan(line)*40,oy+H*S*0.95)],fill=(230,230,230),width=1)
    d.text((ox,4),t1,font=fs,fill="black"); d.text((ox,34),t2,font=fs,fill=(90,90,90))
    d.text((ox,64),"糸 %+.1f rad"%line,font=fs,fill=(90,90,90))
d.text((4,img.height-2-0),"",font=fs)
img.save("rod_side_mock.png"); print(img.size)
