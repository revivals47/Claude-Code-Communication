#!/usr/bin/env python3
"""R2B re-capture 受理 oracle [v1、DEPRECATED — 正本=r2b_oracle_v2.py]。
★settle 訂正 list C8(2026-07-20)適用: 本 v1 は相対 onset/ratio のみで uniform-collapse に false-PASS する限界あり
  (対策B settle-window 版で実証)。絶対 floor を追加した r2b_oracle_v2.py を正本とする。v1 は相対 check の補助/参考用に残置★。
症状『途中から重くなる』(高域collapse) signature をゼロ判定。
worker1 R2B_WAV_DIAGNOSIS §3 の測定手順を実装。numpy のみ(scipy不要)。
usage: python3 r2b_oracle.py <wav_path> [--hop 0.5] [--drop 0.5] [--sustain 3] [--hiband 2000] [--verbose]
判定: (a) centroid が early(t=2-10s)平均の <drop倍 へ低下し sustain秒 持続する onset が【無い】
      (b) 高域(>hiband Hz)比が late(onset後/末尾)で early の >=drop倍 を保持
両方 PASS = 症状 signature ゼロ = 受理。1つでも該当 = FAIL(症状残存=再capture)。
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
def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("wav"); ap.add_argument("--hop",type=float,default=0.5)
    ap.add_argument("--drop",type=float,default=0.5); ap.add_argument("--sustain",type=float,default=3.0)
    ap.add_argument("--hiband",type=float,default=2000.0); ap.add_argument("--verbose",action="store_true")
    A=ap.parse_args()
    sr,a=load(A.wav); dur=len(a)/sr
    cent,hi,dom=series(sr,a,A.hop,A.hiband)
    n=len(cent); e0,e1=int(2/A.hop),int(10/A.hop)   # early window t=2-10s
    early_cent=cent[e0:e1].mean(); early_hi=hi[e0:e1].mean()
    thr=early_cent*A.drop; sust=int(A.sustain/A.hop)
    # (a) onset: first idx where cent<thr and stays <thr for sustain
    onset=None
    for i in range(e1,n-sust):
        if cent[i]<thr and np.all(cent[i:i+sust]<thr): onset=i*A.hop; break
    a_pass = onset is None
    # (b) high-band retention: mean hi in late (after onset or t>14s) vs early
    lstart=int((onset if onset else 14)/A.hop)
    late_hi=hi[lstart:].mean() if lstart<n else hi[-sust:].mean()
    b_ratio=late_hi/(early_hi+1e-9); b_pass = b_ratio>=A.drop
    dom_const = abs(np.median(dom[e0:e1])-np.median(dom[max(lstart,e1):]))<50 if lstart<n else True
    verdict = a_pass and b_pass
    print(f"=== R2B oracle: {A.wav} ===")
    print(f"dur={dur:.2f}s sr={sr} hop={A.hop}s hiband>{A.hiband:.0f}Hz drop_thr={A.drop} sustain={A.sustain}s")
    print(f"early(t2-10s): centroid={early_cent:.0f}Hz 高域比={early_hi*100:.1f}%")
    print(f"(a) centroid collapse onset: {'なし' if a_pass else f'★t≈{onset:.1f}s(< {thr:.0f}Hz持続)★'} → {'PASS' if a_pass else 'FAIL'}")
    print(f"(b) 高域比 late/early = {b_ratio:.2f} (late={late_hi*100:.1f}%) 閾値>={A.drop} → {'PASS' if b_pass else 'FAIL'}")
    print(f"(補) dominant peak early/late 差<50Hz(速度不変) = {dom_const}")
    print(f"★VERDICT = {'PASS(症状signatureゼロ=受理)' if verdict else 'FAIL(症状残存=再capture)'}★")
    if A.verbose:
        print("-- 時系列(1s) t: centroid 高域比 --")
        step=int(1/A.hop)
        for i in range(0,n,step):
            print(f"  t={i*A.hop:5.1f}s cent={cent[i]:5.0f}Hz hi={hi[i]*100:4.1f}%")
    sys.exit(0 if verdict else 1)
main()
