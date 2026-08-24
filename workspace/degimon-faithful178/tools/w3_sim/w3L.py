"""#845-C ② = ★L を 上げた ときの size と min p を ★同時に★ 出す★（★準備のみ・撃たれるまで 待機★）"""
import numpy as np, sys
rng=np.random.default_rng(1357); M=25
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
        for L_,Y,K in zip(tg,ou,keys):
            if K!=kk: continue
            a+=Y[L_].sum(); b+=L_.sum(); c+=Y[~L_].sum(); e+=(~L_).sum()
        if b>=3 and e>0: num+=a/b-c/e; den+=1
    return num/den if den else np.nan
def permdist(tg,ou,keys,L,nperm):
    D=[]
    for _ in range(nperm):
        po=[]
        for Y in ou:
            nb=int(np.ceil(len(Y)/L)); bl=[Y[i*L:(i+1)*L] for i in range(nb)]
            po.append(np.concatenate([bl[i] for i in rng.permutation(nb)]))
        s=stat(tg,po,keys)
        if not np.isnan(s): D.append(s)
    return np.array(D)
print("★② L 走査 = size と min p を 同時★",flush=True)
for ns,T in ((7,3),(7,5)):
    for L in (5,10,20):
        for mode in ('unif','adv'):
            sig=[]; mps=[]
            N=400
            for j in range(N):
                tg,ou,dr=build(ns,T,40,mode)
                obs=stat(tg,ou,dr)
                if np.isnan(obs): continue
                D=permdist(tg,ou,dr,L,200)
                if len(D)==0: continue
                p=((D>=obs).sum()+1)/(len(D)+1); sig.append(p<0.01)
                ties=int((D>=D.max()-1e-12).sum()); mps.append((ties+1)/(len(D)+1))
                if (j+1)%100==0:
                    r=np.mean(sig); mc=1.96*np.sqrt(max(r,1e-9)*(1-r)/len(sig))
                    print(f"   [s{ns}T{T} L={L} {mode}] {j+1}/{N} size={r:.4f}±{mc:.4f} minp中央={np.median(mps):.4f}",flush=True)
            r=np.mean(sig); mc=1.96*np.sqrt(max(r,1e-9)*(1-r)/len(sig))
            ok = (r+mc<=0.01) and (np.median(mps)<0.01)
            print(f"★s{ns}T{T} L={L} {mode}: size={r:.4f}±{mc:.4f} / minp中央={np.median(mps):.4f} → {'★両立★' if ok else '不成立'}★",flush=True)
print("★完了★",flush=True)
