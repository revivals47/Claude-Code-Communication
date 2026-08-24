import re,struct
P='/home/ken/Desktop/vise/extracted/slps_017_97.bin'
d=open(P,'rb').read(); BASE=0x80090800
pat=re.compile(rb'[ -~]{3,40}')
hits=[]
for m in pat.finditer(d):
    s=m.group().decode()
    if s.upper().endswith('.BIN') or '.BIN' in s.upper():
        hits.append((BASE+m.start(),s))
print("-- strings containing '.BIN' : %d --"%len(hits))
for va,s in hits: print("  0x%08X  %r"%(va,s))
print("\n-- other loadable-looking filename strings (.SCN/.DAT/.TIM/.VHB/.VB/.SEQ/ backslash paths) --")
seen=set()
for m in pat.finditer(d):
    s=m.group().decode()
    u=s.upper()
    if any(u.endswith(e) for e in ('.SCN','.DAT','.TIM','.VHB','.VB','.SEQ','.STR','.XA','.TMD')) or ('\\' in s and len(s)>4):
        if s not in seen:
            seen.add(s); print("  0x%08X  %r"%(BASE+m.start(),s))
