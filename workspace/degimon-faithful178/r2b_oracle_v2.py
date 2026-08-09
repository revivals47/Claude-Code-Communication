#!/usr/bin/env python3
"""R2B re-capture 受理 oracle v2 — 症状『途中から重くなる』(高域collapse) を判定。
v1 (相対 onset/ratio) に ★絶対 floor (c)★ を追加し、uniform-collapse false-PASS を封じる。

v1 の盲点(worker1 2026-07-20 発見): (a)(b) は「clip 内の collapse ONSET / late-early 比」=相対量。
post-collapse steady state のみ切出した capture(対策B settle-window)は onset 無し+比≈1 で false-PASS するが、
絶対水準は一様崩壊(全区間 ~900Hz/0.8%)= userの『重い』音そのもの。→絶対 floor で捕捉。

★floor 較正 = 独立 ground-truth『原 clean early』(被検体でなく)★ [[feedback_verify_the_oracle_not_just_the_match]]:
  原 clean 4本 early(t2-10s) oracle実測: v0=3094Hz/29.2% v1=2544Hz/5.8% v2=2301Hz/8.5% v3=3160Hz/24.0%
  → clean 最小 = centroid 2301Hz / high 5.8%。対策B(false-PASS版)= 920Hz/0.8%。
  → floor = centroid 1800Hz / high 3.0%(clean 最小の下・対策B の上、両側に余裕)。案X capture は【被検体】=較正に使わない。

usage: python3 r2b_oracle_v2.py <wav> [--absfloor-cent 1800] [--absfloor-hi 0.03] [--sustain 3] [他はv1同] [--verbose]
判定: (a) collapse onset 無し / (b) 高域比 late/early>=drop / ★(c) 最良 sustain秒窓の centroid>=floor かつ high>=floor★
      3つ全 PASS = 受理。1つでも FAIL = 再capture。
"""
import numpy as np, wave, sys, argparse
def load(path):
    w=wave.open(path,"rb"); sr=w.getframerate(); ch=w.getnchannels(); nf=w.getnframes()
    a=np.frombuffer(w.readframes(nf),dtype="<i2").astype(np.float64); w.close()
    if ch==2: a=a.reshape(-1,2).mean(axis=1)
    return sr,a
def series(sr,a,hop,hiband):
    h=int(sr*hop); cent=[]; hi=[]; dom=[]
    for i in range(len(a)//h):
        s=a[i*h:i*h+h]
        if len(s)<h: break
        sp=np.abs(np.fft.rfft(s*np.hanning(len(s)))); fr=np.fft.rfftfreq(len(s),1/sr)
        p=sp**2
        cent.append((fr*sp).sum()/(sp.sum()+1e-9))
        hi.append(p[fr>=hiband].sum()/(p.sum()+1e-9))
        dom.append(fr[np.argmax(sp)])
    return np.array(cent),np.array(hi),np.array(dom)
def best_window(x,w):
    """最良(最大平均)の w-点窓の平均値 = clip 中で最も明るい持続部。alignment 非依存。"""
    if len(x)<w: return x.mean()
    csum=np.convolve(x,np.ones(w)/w,mode="valid")
    return csum.max()
def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("wav"); ap.add_argument("--hop",type=float,default=0.5)
    ap.add_argument("--drop",type=float,default=0.5); ap.add_argument("--sustain",type=float,default=3.0)
    ap.add_argument("--hiband",type=float,default=2000.0)
    ap.add_argument("--absfloor-cent",type=float,default=1800.0,help="最良窓 centroid 下限(原clean較正)")
    ap.add_argument("--absfloor-hi",type=float,default=0.03,help="最良窓 高域比 下限(原clean較正)")
    ap.add_argument("--verbose",action="store_true")
    A=ap.parse_args()
    sr,a=load(A.wav); dur=len(a)/sr
    cent,hi,dom=series(sr,a,A.hop,A.hiband)
    n=len(cent); e0,e1=int(2/A.hop),int(10/A.hop)
    early_cent=cent[e0:e1].mean(); early_hi=hi[e0:e1].mean()
    thr=early_cent*A.drop; sust=int(A.sustain/A.hop)
    # (a) onset
    onset=None
    for i in range(e1,n-sust):
        if cent[i]<thr and np.all(cent[i:i+sust]<thr): onset=i*A.hop; break
    a_pass = onset is None
    # (b) high-band retention
    lstart=int((onset if onset else 14)/A.hop)
    late_hi=hi[lstart:].mean() if lstart<n else hi[-sust:].mean()
    b_ratio=late_hi/(early_hi+1e-9); b_pass = b_ratio>=A.drop
    dom_const = abs(np.median(dom[e0:e1])-np.median(dom[max(lstart,e1):]))<50 if lstart<n else True
    # (c) 絶対 floor: clip 中の最良 sustain窓(alignment非依存)が clean 水準に達するか
    best_cent=best_window(cent,sust); best_hi=best_window(hi,sust)
    c_cent_pass = best_cent>=A.absfloor_cent; c_hi_pass = best_hi>=A.absfloor_hi
    c_pass = c_cent_pass and c_hi_pass
    verdict = a_pass and b_pass and c_pass
    print(f"=== R2B oracle v2: {A.wav} ===")
    print(f"dur={dur:.2f}s sr={sr} hop={A.hop}s hiband>{A.hiband:.0f}Hz drop={A.drop} sustain={A.sustain}s")
    print(f"early(t2-10s): centroid={early_cent:.0f}Hz 高域比={early_hi*100:.1f}%")
    print(f"(a) collapse onset: {'なし' if a_pass else f'★t≈{onset:.1f}s(<{thr:.0f}Hz持続)★'} → {'PASS' if a_pass else 'FAIL'}")
    print(f"(b) 高域比 late/early = {b_ratio:.2f} (late={late_hi*100:.1f}%) >={A.drop} → {'PASS' if b_pass else 'FAIL'}")
    print(f"(c) 絶対floor 最良{A.sustain:.0f}s窓: centroid={best_cent:.0f}Hz(>={A.absfloor_cent:.0f}? {'○' if c_cent_pass else '×'}) high={best_hi*100:.1f}%(>={A.absfloor_hi*100:.1f}%? {'○' if c_hi_pass else '×'}) → {'PASS' if c_pass else 'FAIL(一様崩壊)'}")
    print(f"(補) dominant peak 差<50Hz(速度不変) = {dom_const}")
    print(f"★VERDICT = {'PASS(clean=受理)' if verdict else 'FAIL(再capture)'}★")
    if A.verbose:
        print("-- 時系列(1s) t: centroid 高域比 --")
        step=int(1/A.hop)
        for i in range(0,n,step):
            print(f"  t={i*A.hop:5.1f}s cent={cent[i]:5.0f}Hz hi={hi[i]*100:4.1f}%")
    sys.exit(0 if verdict else 1)
main()
