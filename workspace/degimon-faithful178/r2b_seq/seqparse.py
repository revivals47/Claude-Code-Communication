#!/usr/bin/env python3
"""pQES (PS1 SEQp) 構造 parser — 曲構造を秒単位で解析。
目的(boss1 02:35 静的決定打): intro長/+13s付近のsection境界(program/volume/note-range変化)/loop point を判別。
(a)dark=正当なintro→loop構造(=+13s付近に構造境界あり) vs (b)崩壊(=+13s以降もbright編成のまま継続、構造境界なし)。
usage: python3 seqparse.py <seq> [--mark 13.0]
"""
import sys, struct, argparse
def vlq(d,i):
    v=0
    while True:
        b=d[i]; i+=1; v=(v<<7)|(b&0x7f)
        if not (b&0x80): break
    return v,i
def main():
    ap=argparse.ArgumentParser(); ap.add_argument("seq"); ap.add_argument("--mark",type=float,default=13.0)
    A=ap.parse_args()
    d=open(A.seq,"rb").read()
    assert d[:4]==b"pQES", "not pQES: %r"%d[:4]
    ver=struct.unpack(">I",d[4:8])[0]
    ppqn=struct.unpack(">H",d[8:10])[0]
    tempo=(d[10]<<16)|(d[11]<<8)|d[12]   # µs per quarter
    rhythm=d[13]; denom=d[14]
    print("pQES ver=%d ppqn=%d init_tempo=%dus(%.1fBPM) rhythm=%d/2^%d len=%d"%(ver,ppqn,tempo,6e7/tempo,rhythm,denom,len(d)))
    i=15; tick=0; sec=0.0; cur_tempo=tempo; run=None
    events=[]   # (sec, kind, detail, ch)
    active_notes={}  # (ch,note)->on_sec ; for pitch range over time
    note_hist=[]     # (sec, ch, note)
    prog={}          # ch->program
    vol={}           # ch->volume
    end_sec=None
    while i < len(d):
        dt,i = vlq(d,i)
        tick += dt; sec += (dt/ppqn)*(cur_tempo/1e6)
        if i>=len(d): break
        b=d[i]
        if b&0x80: status=b; i+=1; run=status
        else: status=run
        if status is None: break
        hi=status&0xf0; ch=status&0x0f
        if hi==0x90:  # note on
            note=d[i]; vel=d[i+1]; i+=2
            if vel>0: note_hist.append((sec,ch,note))
        elif hi==0x80:  # note off
            i+=2
        elif hi==0xA0: i+=2
        elif hi==0xB0:  # control change
            cc=d[i]; val=d[i+1]; i+=2
            if cc==7: vol[ch]=val; events.append((sec,"vol","ch%d vol=%d"%(ch,val),ch))
            elif cc==11: events.append((sec,"expr","ch%d expr=%d"%(ch,val),ch))
            elif cc in (0x63,0x62,0x14,0x06,0x26,99,100): events.append((sec,"cc%d"%cc,"ch%d val=%d(loop?)"%(ch,val),ch))
        elif hi==0xC0:  # program change
            p=d[i]; i+=1; prog[ch]=p; events.append((sec,"prog","ch%d prog=%d"%(ch,p),ch))
        elif hi==0xD0: i+=1
        elif hi==0xE0: i+=2
        elif status==0xFF:  # meta
            meta=d[i]; i+=1; ln,i=vlq(d,i)
            if meta==0x51:  # tempo
                cur_tempo=(d[i]<<16)|(d[i+1]<<8)|d[i+2]
                events.append((sec,"tempo","%dus(%.1fBPM)"%(cur_tempo,6e7/cur_tempo),-1))
            elif meta==0x2F:  # end
                end_sec=sec; events.append((sec,"END","",-1)); i+=ln; break
            else:
                events.append((sec,"meta","0x%02x len%d"%(meta,ln),-1)); i+=ln
        else:
            break
    dur=end_sec if end_sec else sec
    print("総尺=%.2fs 総tick=%d note数=%d"%(dur,tick,len(note_hist)))
    # note pitch range over 2s windows (bright=high notes present)
    print("-- 2s窓ごと note pitch range(min-max, 平均, 件数)=編成のbright/dark判別 --")
    W=2.0
    nb=int(dur/W)+1
    for w in range(nb):
        t0=w*W; t1=t0+W
        ns=[n for (s,c,n) in note_hist if t0<=s<t1]
        if ns:
            mk="  <<<MARK %gs"%A.mark if t0<=A.mark<t1 else ""
            print("  t=%5.1f-%4.1fs n=%3d pitch min=%3d max=%3d avg=%4.1f%s"%(t0,t1,len(ns),min(ns),max(ns),sum(ns)/len(ns),mk))
    print("-- prog/vol/tempo/cc events(時系列) --")
    for (s,k,detail,ch) in events:
        mk=" <<<~MARK" if abs(s-A.mark)<1.5 else ""
        print("  t=%6.2fs [%s] %s%s"%(s,k,detail,mk))
main()
