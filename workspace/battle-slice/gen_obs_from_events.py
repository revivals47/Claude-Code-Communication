#!/usr/bin/env python3
"""events*.jsonl -> live_compare --obs 形式 を ★機械的に★ 生成する。

boss1 が 手で 書き写さないための器。worker1 も boss1 も 転記しない。
規則は 事前登録 (comms 5da9666 / 7c3e1f6) に従う:
  ・hp event の 空きが 0.5 秒を超えたら 発の境界
  ・適用条件 (束内最大 < 0.5 < 発間最小) を 先に 検査し、成り立たなければ 中止
  ・d= は ★観測されたときだけ★ 書く。推測では 書かない (worker1 #919 §4)
"""
import json, sys
GAP = 0.5                      # ★事前登録★
ENEMY_UNIT = 'enemy2_s104'
ENEMY_ADDR = 0x8016B220        # = 0x8016B104 + 104*2 + 0x4C (worker1/worker2 が独立に一致)
ALLY_ADDR  = 0x8016B0D0

def clusters(evs):
    out=[];cur=None;prev=None
    for d in evs:
        if prev is not None and d['t']-prev>GAP: out.append(cur);cur=None
        if cur is None: cur={'from':d['prev'],'to':d['hp'],'t':d['t']}
        cur['to']=d['hp']; prev=d['t']
    if cur: out.append(cur)
    return out

def gapcheck(evs):
    g=[evs[i+1]['t']-evs[i]['t'] for i in range(len(evs)-1)]
    w=[x for x in g if x<=GAP]; b=[x for x in g if x>GAP]
    return (max(w) if w else None), (min(b) if b else None)

def main(path):
    rows=[json.loads(l) for l in open(path) if l.strip().startswith('{')]
    hp=[d for d in rows if d.get('kind')=='hp']
    disp=[d for d in rows if d.get('kind')=='disp' and d.get('prev') is not None]
    ally=[d for d in hp if d['unit']=='ally']
    enem=[d for d in hp if d['unit']==ENEMY_UNIT]

    # ---- (A) 適用条件: ★表示値を使わずに★ 先に検査する
    for name,evs in (('ally',ally),(ENEMY_UNIT,enem)):
        mw,mb=gapcheck(evs)
        ok = mw is not None and mb is not None and mw < GAP < mb
        print(f"# (A) {name}: 束内最大={mw:.3f}s 発間最小={mb:.3f}s -> {'成立' if ok else '不成立'}")
        if not ok:
            print("# ★規則を適用できない = 束ねない (事前登録どおり 窓は選び直さない)★"); sys.exit(2)

    ac=[c for c in clusters(ally) if 0 < c['from']-c['to'] < 5000]
    ec=[c for c in clusters(enem) if 0 < c['from']-c['to'] < 5000]
    allymax=max(d.get('hpmax') or 0 for d in ally)
    enemymax=max(c['from'] for c in ec)   # 記録上の最大 (hpmax 欄は初期化値を含むため使わない)

    hits=sorted([('ally',c) for c in ac]+[('enemy',c) for c in ec], key=lambda x:x[1]['t'])
    # 表示: slot0 = ally 側, slot1 = enemy 側 (実データで分離している)
    dmap={0:[d for d in disp if d['slot']==0], 1:[d for d in disp if d['slot']==1]}

    print("# 生成元 =", path)
    print("# ★d= は 観測された表示のみ★。推測では書かない (同値の書き直しは 見えないため)")
    print("t")
    print(f"  allyhp={ac[0]['from'] if ac else ally[0]['hp']}")
    print(f"  enemyhp={ec[0]['from'] if ec else enem[0]['hp']}")
    print(f"  enemyhp_addr=0x{ENEMY_ADDR:08X}")
    print("  h2e=0")
    print(f"  allymaxhp={allymax}")
    print(f"  enemymaxhp={enemymax}")

    a_hp = ac[0]['from'] if ac else None
    e_hp = ec[0]['from'] if ec else None
    for side,c in hits:
        if side=='ally': a_hp=c['to']
        else:            e_hp=c['to']
        slot = 0 if side=='ally' else 1
        # ★slot の 値の鎖を (prev, value) から 復元し、鎖の切れ目 = 見逃した表示 とする★
        #   transition N の value が V で、次の transition の prev が P (P != V) なら
        #   その間に ★P という 表示が 在った★ = 見逃し 1 つを 事後回収できる。
        #   ★prev が 直前の value と 同じなら 何も隠れていない★
        #   (= 同値の書き直しは 原理的に 見えない。ここで d= を 書くと 推測になる)
        d=None; src=None
        for x in dmap[slot]:
            if abs(x['t']-c['t'])<0.4: d=x['value']; src='遷移'; break
        if d is None:
            seq=dmap[slot]
            for i in range(len(seq)-1):
                prv=seq[i+1]['prev']
                hidden = prv[1] if isinstance(prv,list) and len(prv)>1 else None
                if hidden is None or hidden==seq[i]['value']:
                    continue                      # ★鎖が繋がっている = 隠れた表示は無い★
                if seq[i]['t'] < c['t'] < seq[i+1]['t'] and hidden==c['from']-c['to']:
                    d=hidden; src='prev欄(鎖の切れ目)'; break
        print("t")
        print(f"  allyhp={a_hp}")
        print(f"  enemyhp={e_hp}")
        print(f"  enemyhp_addr=0x{ENEMY_ADDR:08X}")
        print("  h2e=0")
        if d is not None:
            print(f"  d={d:04d}                # 出所={src}")
        else:
            print(f"  # d= 無し = ★観測されていない★ (ΔHP={c['from']-c['to']} / side={side}) -> 器は評価不能にする")

if __name__=='__main__':
    main(sys.argv[1])
