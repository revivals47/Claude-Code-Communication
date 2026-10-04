import numpy as np, sys
from PIL import Image
exec(open('drafts/rod_look/thin_measure/rodw.py').read().split("img=")[0])
a=np.asarray(Image.open('drafts/rod_look/rest2_shots/R0_point1_06.png').convert('RGB')).astype(int)
b=np.asarray(Image.open('drafts/rod_look/rest2_shots/R1_point2_06.png').convert('RGB')).astype(int)
m=np.abs(a-b).sum(2)>30; L_=a.sum(2)/3
out=[]
for fr in np.arange(0.74,1.0,0.02):
    P=B+(T-B)*fr; c,z=proj(P); c2,_=proj(P+(T-B)*0.01); t=(c2-c); t/=np.linalg.norm(t); n=np.array([-t[1],t[0]])
    ws=[]
    for s in np.arange(-4,4.5,0.5):
        q=c+t*s; ks=np.arange(-10,10.25,0.25)
        pts=[q+n*k for k in ks]; mm=np.array([m[int(round(p[1])),int(round(p[0]))] for p in pts]); ll=np.array([L_[int(round(p[1])),int(round(p[0]))] for p in pts])
        win=np.where(np.abs(ks)<=3)[0]; i=win[np.argmin(ll[win])]   # darkest point near the model centre = the blank
        if not mm[i]: continue
        j=i
        while j>0 and mm[j-1]: j-=1
        k=i
        while k<len(mm)-1 and mm[k+1]: k+=1
        ws.append((k-j+1)*0.25)
    md=max(dia(fr)*f/z,1.5)
    print(f"f {fr:.2f}  model blank {md:.2f} px  model wrap {md+0.003*f/z+0.0005*f/z:.2f} px  measured contiguous: min {min(ws):.1f} median {np.median(ws):.1f}")
