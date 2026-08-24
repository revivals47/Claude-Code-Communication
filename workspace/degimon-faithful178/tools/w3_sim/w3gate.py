import numpy as np, sys
rng=np.random.default_rng(8901); M=25
def build(nsess,T_per,ktot,mode,pi=None):
    rates=rng.uniform(0.02,0.12,nsess); tg=[];ou=[];dr=[]
    w=np.ones(nsess) if mode=='unif' else rates.copy()
    w=w/w.sum(); per=rng.multinomial(ktot,w)
    for s in range(nsess):
        slots=T_per*M; idx=rng.permutation(slots)[:per[s]]
        flat=np.zeros(slots,bool); flat[idx]=True
        for t in range(T_per):
            lab=flat[t*M:(t+1)*M]; y=np.zeros(M,bool); st=False
            for i in range(M):
                p=0.45 if st else rates[s]*0.6
                st=rng.random()<p; y[i]=st
            if pi is not None and lab.any(): y[lab]=rng.random(lab.sum())<pi
            tg.append(lab); ou.append(y); dr.append(t%2)
    return tg,ou,dr
def stat(tg,ou,keys):
    num=0.0;den=0
    for k in (0,1):
        a=b=c=e=0
        for L,Y,K in zip(tg,ou,keys):
            if K!=k: continue
            a+=Y[L].sum(); b+=L.sum(); c+=Y[~L].sum(); e+=(~L).sum()
        if b>=3 and e>0: num+=a/b-c/e; den+=1
    return num/den if den else np.nan
def pval(tg,ou,keys,L=5,nperm=200):
    obs=stat(tg,ou,keys)
    if np.isnan(obs): return np.nan
    c=0
    for _ in range(nperm):
        po=[]
        for Y in ou:
            nb=int(np.ceil(len(Y)/L)); bl=[Y[i*L:(i+1)*L] for i in range(nb)]
            po.append(np.concatenate([bl[i] for i in rng.permutation(nb)]))
        s=stat(tg,po,keys)
        if not np.isnan(s) and s>=obs: c+=1
    return (c+1)/(nperm+1)
def run(ns,T,k,mode,pi,reps,tag):
    ps=[]
    for j in range(reps):
        p=pval(*build(ns,T,k,mode,pi))
        if not np.isnan(p): ps.append(p)
        if (j+1)%50==0:
            r=np.mean([x<0.01 for x in ps]); mc=1.96*np.sqrt(max(r,1e-9)*(1-r)/len(ps))
            print(f"   [{tag}] {j+1}/{reps} → {r:.3f} ± {mc:.3f}",flush=True)
    r=np.mean([x<0.01 for x in ps]); mc=1.96*np.sqrt(max(r,1e-9)*(1-r)/len(ps))
    print(f"★{tag} = {r:.3f} ± {mc:.3f} (n={len(ps)})★",flush=True)
print("★gate sim 開始（size 4 + power 2・各 300/150 反復・perm 200）★",flush=True)
for ns,T in ((7,3),(7,5)):
    for mode in ('unif','adv'): run(ns,T,40,mode,None,300,f"size s{ns}T{T} {mode}")
run(7,3,40,'unif',1.0,150,"power s7T3 pi100")
run(7,3,40,'unif',0.8,150,"power s7T3 pi80")
print("★完了★",flush=True)
