"""#847-C 確定 gate: L=5 固定 / 5,000 反復 / 非劣性(CP 上界 ≤ 0.015) / zero-free p / Bonferroni"""
import numpy as np
rng=np.random.default_rng(20260825); M=25; L=5; NB=M//L
from math import lgamma, exp, log
def binom_cdf(x,n,p):
    """P(X <= x)（log 空間・scipy 非依存）"""
    if p<=0: return 1.0
    if p>=1: return 0.0
    t=0.0
    for i in range(0,x+1):
        lc=lgamma(n+1)-lgamma(i+1)-lgamma(n-i+1)
        t+=exp(lc+i*log(p)+(n-i)*log(1-p))
    return min(t,1.0)
def cp_upper(x,n,conf):
    """★Clopper-Pearson 片側上界（二分法）★ = P(X<=x|n,U) = 1-conf を 解く"""
    if x==0: return 1-(1-conf)**(1/n)
    lo,hi=x/n,1.0
    for _ in range(200):
        mid=(lo+hi)/2
        if binom_cdf(x,n,mid) > 1-conf: lo=mid
        else: hi=mid
    return hi
def build(ns,T,k,mode):
    rates=rng.uniform(0.02,0.12,ns)
    w=np.ones(ns) if mode=='unif' else rates.copy(); w=w/w.sum()
    per=rng.multinomial(k,w)
    TG=np.zeros((ns*T,M),bool); OU=np.zeros((ns*T,M),bool); DR=np.zeros(ns*T,int)
    r=0
    for s in range(ns):
        sl=T*M; idx=rng.permutation(sl)[:per[s]]
        flat=np.zeros(sl,bool); flat[idx]=True
        for t in range(T):
            TG[r]=flat[t*M:(t+1)*M]
            y=np.zeros(M,bool); st=False
            for i in range(M):
                p=0.45 if st else rates[s]*0.6
                st=rng.random()<p; y[i]=st
            OU[r]=y; DR[r]=t%2; r+=1
    return TG,OU,DR
def stat(TG,OU,DR):
    num=0.0; den=0
    for d in (0,1):
        m=DR==d
        if not m.any(): continue
        tg=TG[m]; ou=OU[m]
        b=tg.sum(); e=(~tg).sum()
        if b>=3 and e>0:
            num += ou[tg].sum()/b - ou[~tg].sum()/e; den+=1
    return num/den if den else np.nan
def pval(TG,OU,DR,nperm=200):
    obs=stat(TG,OU,DR)
    if np.isnan(obs): return np.nan
    R=OU.reshape(len(OU),NB,L)
    ge=0
    for _ in range(nperm):
        order=np.argsort(rng.random((len(OU),NB)),axis=1)
        P=np.take_along_axis(R,order[:,:,None],axis=1).reshape(len(OU),M)
        s=stat(TG,P,DR)
        if not np.isnan(s) and s>=obs: ge+=1
    return (ge+1)/(nperm+1)          # ★zero-free（Phipson & Smyth）★
CONFIGS=[(7,3,'unif'),(7,3,'adv'),(7,5,'unif'),(7,5,'adv')]
CONF=1-0.05/len(CONFIGS)             # ★Bonferroni★
print(f"★gate2-FRESH: L=5 固定 / 5,000 反復 / 非劣性 CP 上界 ≤ 0.015 / Bonferroni conf={CONF:.4f}★",flush=True)
res={}
for ns,T,mode in CONFIGS:
    x=0; n=0
    for j in range(5000):
        p=pval(*build(ns,T,40,mode))
        if np.isnan(p): continue
        n+=1; x += (p<0.01)
        if (j+1)%1000==0:
            u=cp_upper(x,n,CONF)
            print(f"   [s{ns}T{T} {mode}] {j+1}/5000 → hat={x/n:.4f} U={u:.4f}",flush=True)
    u=cp_upper(x,n,CONF); ok = u<=0.015
    res[(ns,T,mode)]=(x/n,u,ok)
    print(f"★s{ns}T{T} {mode}: hat={x/n:.4f} / ★CP 上界={u:.4f}★ → {'★★非劣性 合格★★' if ok else '★不合格★'} (n={n})★",flush=True)
print(f"★★総合 = {'合格' if all(v[2] for v in res.values()) else '不合格'}★★",flush=True)
print("★完了★",flush=True)
