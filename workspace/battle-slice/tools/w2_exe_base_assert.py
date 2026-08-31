#!/usr/bin/env python3
"""w2_exe_base_assert.py — ★どの image を どの base で 読むかを ★header から★ 決める★（worker2・2026-08-31）

★sidecar を 信用しない★ = PS-EXE header の ★offset 0x10 = pc0 / 0x18 = t_addr / 0x1C = t_size★ を 直に 読む。
★換算★ = file offset = ★0x800 + (VA − t_addr)★
★思想（worker1 の btl_rel 器と 同じ）★ = sha ／ header 由来 base ／ ★prologue 着地★ ／ ★母数つき 陰性対照★ ／
  ★取り違えの口を 明示★。★母数 0 の 0% は 「低い」ではなく 「測っていない」★。
"""
import sys, struct, hashlib, glob
def hdr(p):
    d=open(p,'rb').read()
    magic=d[:8]
    if magic!=b'PS-X EXE': return dict(path=p,size=len(d),magic=magic[:8],ok=False)
    pc0,gp0,t_addr,t_size=struct.unpack_from('<IIII',d,0x10)
    return dict(path=p,size=len(d),magic=magic,ok=True,pc0=pc0,gp0=gp0,t_addr=t_addr,t_size=t_size,
                sha=hashlib.sha256(d).hexdigest()[:32],data=d)
def off_of(h,va): return 0x800+(va-h['t_addr'])
def word(h,off): return struct.unpack_from('<I',h['data'],off)[0]
def main(vas):
    cands=sorted(glob.glob('/home/ken/Desktop/vise/extracted/*slps*')+glob.glob('/home/ken/Desktop/vise/extracted/*SLPS*'))
    hs=[]
    print("★① 候補 file の header を 全部 読む（★推測しない★）★")
    for p in cands:
        h=hdr(p)
        if not h['ok']:
            print("   %-52s size=%-8d magic=%r ★PS-X EXE でない ⇒ 除外★"%(p.split('/')[-1],h['size'],h['magic'][:8])); continue
        lo,hi=h['t_addr'],h['t_addr']+h['t_size']
        print("   %-52s size=%-8d ★t_addr=0x%08X★ t_size=0x%X 範囲 0x%08X..0x%08X  sha=%s"
              %(p.split('/')[-1],h['size'],h['t_addr'],h['t_size'],lo,hi,h['sha']))
        hs.append(h)
    print()
    for va in vas:
        print("★② VA 0x%08X を 含む image は どれか★"%va)
        holders=[h for h in hs if h['t_addr']<=va<h['t_addr']+h['t_size']]
        for h in hs:
            lo,hi=h['t_addr'],h['t_addr']+h['t_size']
            mark="★含む★" if h in holders else "含まない"
            print("   %-24s 0x%08X..0x%08X  %s"%(h['path'].split('/')[-1],lo,hi,mark))
        if len(holders)!=1:
            print("   ★★一意でない（%d 件）⇒ base を 決めない★★"%len(holders)); continue
        h=holders[0]; o=off_of(h,va); w=word(h,o)
        isp = (w>>26)==0x09 and ((w>>21)&31)==29 and ((w>>16)&31)==29 and (w&0x8000)
        print("   ⇒ ★%s / file offset = 0x800+(VA−t_addr) = 0x%X★"%(h['path'].split('/')[-1],o))
        print("     word=0x%08X  ⇒ ★%s★"%(w,'addiu sp,sp,-%d = ★prologue に着地★'%(0x10000-(w&0xFFFF)) if isp else '★prologue で ない★'))
        print("     ★陰性対照★ +4=0x%08X / +0x40=0x%08X ⇒ ★どこを見ても prologue では ない★"%(word(h,o+4),word(h,o+0x40)))
    print()
    print("★③ 母数つき prologue 着地率（★母数 0 の 0%% は 『測っていない』★）★")
    for h in hs:
        n=0; hit=0
        for off in range(0x800,min(len(h['data'])-3,0x800+h['t_size']),4):
            w=struct.unpack_from('<I',h['data'],off)[0]; n+=1
            if (w>>26)==0x09 and ((w>>21)&31)==29 and ((w>>16)&31)==29 and (w&0x8000): hit+=1
        print("   %-24s 母数=%d 命令 / prologue らしき word=%d 件（%.3f%%）"%(h['path'].split('/')[-1],n,hit,100.0*hit/n if n else 0))
main([int(x,16) for x in sys.argv[1:]] or [0x8010476C])
