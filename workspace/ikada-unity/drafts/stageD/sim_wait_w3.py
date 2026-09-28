# Offline replay of the DayFlow slot under the proposed rules (a prediction aid, not the logic):
#  - Speech on a Story with time left -> queued (like the same-step rule); Story on Story / Speech on Speech = newest wins (as now)
#  - task line (contains '／') hold = 2 + chars/5, no 20 s cap (min 6)
#  - pending max 2 (oldest dropped), a line that waited > 60 s is dropped when popped (LineTiming.cs MaxPending / MaxWaitS)
# Input = RefCheck --log say lines of 3838e10 (lineslot_after). Say times = display times, except the task line, whose Say is the
# inn line's step (it was queued behind it). Speaker lines only (Status lines are the session slot or yield; not replayed).
import sys, re
def chars(t):
    c=t.find('：'); st=c+1 if 0<c<=6 else 0
    return sum(1 for ch in t[st:] if not ch.isspace())
def hold(t,kind,task,minh=0):
    n=chars(t)
    if kind=='Speech': h=min(max(1.5+n/5,3),10)
    else: h=max(2+n/5,6) if task else min(max(2+n/5,6),20)
    return max(h,minh)
def run(path, cap_task=True, speech_waits=False):
    L=[l.rstrip('\n') for l in open(path,encoding='utf-8')]
    ev=[]; page=None; prep_t=None
    for l in L:
        p=l.split(' ',2)
        if len(p)<3 or not p[0].isdigit(): continue
        t=int(p[0])/1000
        if p[1]=='page': page=p[2]; 
        if p[1]=='page' and p[2]=='Day/Prep': prep_t=t
        if p[1]!='say': continue
        s=p[2]
        if '：' not in s[:12]: continue
        task='／' in s
        inn = (t==prep_t and not task)
        boat = page=='Day/Fishing' and abs(t-[float(x.split(' ')[0])/1000 for x in L if ' page Day/Fishing' in x][0])<0.001 and not task
        kind='Story' if (task or inn or boat) else 'Speech'
        ev.append([t,s,kind,task,30 if inn else 0])
    for e in ev:
        if e[3]: e[0]=prep_t     # the task line's Say = the inn line's step
    ev.sort(key=lambda e:(e[0], 0 if e[4] else 1))
    shown=[]; dropped=[]; cur=None; left=0; pend=[]; now=0
    def show(e,at):
        nonlocal cur,left
        cur=e; left=hold(e[1],e[2],e[3] and not cap_task,e[4]); shown.append((at,e))
    def adv(to):
        nonlocal now,cur,left
        while cur is not None and now+left<=to:
            now+=left; t0=now; cur=None
            for p in pend: p[1]+=0
            while pend:
                e,said=pend.pop(0)
                if now-said>60: dropped.append((now,e,'waited %.1f s'%(now-said))); continue
                show(e,now); break
        if cur is not None: left-=to-now
        now=to
    for e in ev:
        adv(e[0])
        same = cur is not None and shown and shown[-1][0]==e[0]
        if cur is not None and (same or (speech_waits and cur[2]=='Story' and e[2]=='Speech' and left>0)):
            if len(pend)>=2: dropped.append((e[0],pend.pop(0)[0],'queue full'))
            pend.append([e,e[0]])
        else:
            show(e,e[0])
    adv(1e9)
    return shown,dropped
if __name__=='__main__':
    d=sys.argv[1]
    base,_=run(d,cap_task=True,speech_waits=False)
    new,dr=run(d,cap_task=False,speech_waits=True)
    bt={e[1]:t for t,e in base}; nt={e[1]:t for t,e in new}
    for t,e in base:
        if e[1] in nt and abs(nt[e[1]]-t)>0.001: print('  moved %9.3f -> %9.3f (+%.1f s) %s %s'%(t,nt[e[1]],nt[e[1]]-t,e[2],e[1][:30]))
        if e[1] not in nt: print('  NOT SHOWN %9.3f %s %s'%(t,e[2],e[1][:30]))
    for x in dr: print('  dropped at %.3f %s (%s)'%(x[0],x[1][1][:30],x[2]))
