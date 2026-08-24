import numpy as np
rng=np.random.default_rng(24601); M=25
def build(ns,T,k,mode):
    rates=rng.uniform(0.02,0.12,ns); tg=[];ou=[];dr=[]
    w=np.ones(ns) if mode=='unif' else rates.copy(); w=w/w.sum()
    per=rng.multinomial(k,w)
    for s in range(ns):
        sl=T*M; idx=rng.permutation(sl)[:per[s]]
        flat=np.zeros(sl,bool); flat[idx]=True
        for t in range(T):
            lab=flat[t*M:(t+1)*M]; y=np.zeros(M,bool); st=False
            for i in range(M):
                p=0.45 if st else rates[s]*0.6
                st=rng.random()<p; y[i]=st
            tg.append(lab); ou.append(y); dr.append(t%2)
    return tg,ou,dr
def stat(tg,ou,keys):
    num=0.0;den=0
    for kk in (0,1):
        a=b=c=e=0
        for L,Y,K in zip(tg,ou,keys):
            if K!=kk: continue
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
print("★size 精密 sim（n=1200・perm 200）★",flush=True)
for ns,T in ((7,3),(7,5)):
    for mode in ('unif','adv'):
        ps=[]
        for j in range(1200):
            p=pval(*build(ns,T,40,mode))
            if not np.isnan(p): ps.append(p)
            if (j+1)%200==0:
                r=np.mean([x<0.01 for x in ps]); mc=1.96*np.sqrt(max(r,1e-9)*(1-r)/len(ps))
                print(f"   [s{ns}T{T} {mode}] {j+1}/1200 → {r:.4f} ± {mc:.4f}",flush=True)
        r=np.mean([x<0.01 for x in ps]); mc=1.96*np.sqrt(max(r,1e-9)*(1-r)/len(ps))
        print(f"★s{ns}T{T} {mode} = {r:.4f} ± {mc:.4f} (n={len(ps)})★",flush=True)
print("★完了★",flush=True)
