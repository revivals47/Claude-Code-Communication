import numpy as np, sys
from PIL import Image
f=540/np.tan(np.radians(25)); p=np.radians(5.75); C=np.array([0,1.55,0])
fwd=np.array([0,-np.sin(p),np.cos(p)]); up=np.array([0,np.cos(p),np.sin(p)])
def proj(P):
    d=np.array(P)-C; z=d@fwd; return np.array([960+f*d[0]/z, 540-f*(d@up)/z]), z
B=np.array([-0.4,0.75,1.236]); T=np.array([-0.131,0.75,4.315]); L=np.linalg.norm(T-B); S=L/1.5
ge=0.176
def dia(fr, ratio=24.0):
    if fr<ge: return 0.030*S
    u=(fr-ge)/(1-ge); return 0.018*ratio**(-u)*S
img=np.asarray(Image.open(sys.argv[1]).convert('L')).astype(float)
def meas(fr):
    c,_=proj(B+(T-B)*fr); c2,_=proj(B+(T-B)*min(fr+0.01,1)); c0,_=proj(B+(T-B)*max(fr-0.01,0))
    t=(c2-c0); t/=np.linalg.norm(t); n=np.array([-t[1],t[0]])
    ws=[]
    for s in np.linspace(-6,6,9):   # several cross-sections along the rod, median
        q=c+t*s; prof=[]
        for k in np.arange(-25,25.5,0.5):
            x,y=q+n*k; xi,yi=int(round(x)),int(round(y))
            prof.append(img[yi,xi] if 0<=yi<1080 and 0<=xi<1920 else np.nan)
        prof=np.array(prof); bg=np.nanmedian(np.r_[prof[:12],prof[-12:]]); mn=np.nanmin(prof)
        # recentre on the darkest point within +-8 px, then equivalent width = sum of darkness / (bg - rod black 18)
        core=prof[34:67]; dark=np.clip((bg-core)/max(bg-18,1),0,1)
        ws.append(dark.sum()*0.5)
    return c, np.median(ws)
print("fr  screen(x,y)  depth  model_dia_px(no min)  model_px(with 1.5 min)  persp_only_px(dia@0.25)  measured_px")
for fr in [0.1,0.25,0.35,0.5,0.6,0.7,0.8,0.85,0.9,0.95]:
    c,w=meas(fr); _,z=proj(B+(T-B)*fr); m=dia(fr)*f/z
    po=dia(0.25)*f/z
    print(f"{fr:.2f} ({c[0]:.0f},{c[1]:.0f}) {z:.2f}  {m:5.2f}  {max(m,1.5) if fr>=ge else m:5.2f}  {po:5.2f}  {w:5.2f}")
