# W3_587C 確定形(v7) — 42 walk
# ★実測が予測を外した項目はそのまま印字・合わせにいかない★

== 段 0 : #585-C の逐語再現(process 頭で 1 回だけ reset・L→B 順) ==
   entry 154: L step=2 byte=5 term=-/vm_gate | B step=7 byte=116 term=-/vm_gate
   entry 175: L step=3 byte=27 term=-/choice_break | B step=3 byte=27 term=-/choice_break
   entry 176: L step=1 byte=4 term=-/vm_gate | B step=6 byte=9 term=-/vm_gate
   ★gate stop の (op → entry 集合)★: 0xB2->[154 ] 0x06->[154 ] 0x7A->[176 ] 0x81->[176 ]
   ★band 外の op 種 = 3★ / 停止した op 種 = 4
   ★VerifyEntry(101)★ JUMPS 未設定: ok=False matched=0 emitted=0 oracle=277
   ★VerifyEntry(101)★ JUMPS=1     : ok=False matched=0 emitted=0 oracle=277

== 段 1 : entry 154 / 175 × 5 arm(walk ごとに W1AbReset) ==
 -- entry 154 (Raw 4096 / BodyStart 0x18 / 候補 48 件) --
    A(J-off S-off C-break) step=2 byte=5 ★var_w110=0★(上界 48) distinct110=0 逆行=0 var_w122=0 varW=1 | 停止=vm_gate(term=- state=Finished lastOp=0xB2@0x1C) | choice 取=0 break=False cap=False | gate op 種=1 band外=4 | hist 0x13:0 0x14:0 0x16:0 0x17:0 0x18:0 0x19:0 
    B(J-ON  S-off C-break) step=2 byte=5 ★var_w110=0★(上界 48) distinct110=0 逆行=0 var_w122=0 varW=1 | 停止=vm_gate(term=- state=Finished lastOp=0xB2@0x1C) | choice 取=0 break=False cap=False | gate op 種=1 band外=4 | hist 0x13:0 0x14:0 0x16:0 0x17:0 0x18:0 0x19:0 
    C(J-off S-off C-cont ) step=2 byte=5 ★var_w110=0★(上界 48) distinct110=0 逆行=0 var_w122=0 varW=1 | 停止=vm_gate(term=- state=Finished lastOp=0xB2@0x1C) | choice 取=0 break=False cap=False | gate op 種=1 band外=4 | hist 0x13:0 0x14:0 0x16:0 0x17:0 0x18:0 0x19:0 
    D(J-ON  S-off C-cont ) step=2 byte=5 ★var_w110=0★(上界 48) distinct110=0 逆行=0 var_w122=0 varW=1 | 停止=vm_gate(term=- state=Finished lastOp=0xB2@0x1C) | choice 取=0 break=False cap=False | gate op 種=1 band外=4 | hist 0x13:0 0x14:0 0x16:0 0x17:0 0x18:0 0x19:0 
    E(J-ON  S-ON  C-cont ) step=2 byte=5 ★var_w110=0★(上界 48) distinct110=0 逆行=0 var_w122=0 varW=1 | 停止=vm_gate(term=- state=Finished lastOp=0xB2@0x1C) | choice 取=0 break=False cap=False | gate op 種=1 band外=4 | hist 0x13:0 0x14:0 0x16:0 0x17:0 0x18:0 0x19:0 
 -- entry 175 (Raw 6144 / BodyStart 0x10 / 候補 24 件) --
    A(J-off S-off C-break) step=3 byte=27 ★var_w110=0★(上界 24) distinct110=0 逆行=0 var_w122=0 varW=0 | 停止=choice_break(term=- state=WaitingChoice lastOp=0x10@0x2A) | choice 取=0 break=True cap=False | gate op 種=0 band外=4 | hist 0x13:0 0x14:0 0x16:0 0x17:0 0x18:0 0x19:0 
    B(J-ON  S-off C-break) step=3 byte=27 ★var_w110=0★(上界 24) distinct110=0 逆行=0 var_w122=0 varW=0 | 停止=choice_break(term=- state=WaitingChoice lastOp=0x10@0x2A) | choice 取=0 break=True cap=False | gate op 種=0 band外=4 | hist 0x13:0 0x14:0 0x16:0 0x17:0 0x18:0 0x19:0 
    C(J-off S-off C-cont ) step=12 byte=253 ★var_w110=0★(上界 24) distinct110=0 逆行=0 var_w122=0 varW=0 | 停止=vm_gate(term=- state=Finished lastOp=0x2B@0x140) | choice 取=1 break=False cap=False | gate op 種=1 band外=4 | hist 0x13:0 0x14:0 0x16:1 0x17:0 0x18:0 0x19:2 
    D(J-ON  S-off C-cont ) step=13 byte=377 ★var_w110=0★(上界 24) distinct110=0 逆行=0 var_w122=0 varW=0 | 停止=vm_gate(term=- state=Finished lastOp=0x2B@0x1CA) | choice 取=1 break=False cap=False | gate op 種=1 band外=4 | hist 0x13:0 0x14:0 0x16:0 0x17:0 0x18:0 0x19:2 
    E(J-ON  S-ON  C-cont ) step=13 byte=377 ★var_w110=0★(上界 24) distinct110=0 逆行=0 var_w122=0 varW=0 | 停止=vm_gate(term=- state=Finished lastOp=0x2B@0x1CA) | choice 取=1 break=False cap=False | gate op 種=1 band外=4 | hist 0x13:0 0x14:0 0x16:0 0x17:0 0x18:0 0x19:2 

== 段 2 : entry 176 × section × 5 arm ==
 -- entry 176 (Raw 4096 / BodyStart 0x20 / 候補 14 件 / section 6 本) --
    ★section id254 @0x1C 起点 byte=0xFE ★上界 14 件★★
       A(J-off S-off C-break) step=33 byte=625 ★var_w110=0★(上界 14) distinct110=0 逆行=0 var_w122=1 varW=1 | 停止=choice_break(term=- state=WaitingChoice lastOp=0x10@0x28C) | choice 取=0 break=True cap=False | gate op 種=0 band外=4 | hist 0x13:0 0x14:0 0x16:0 0x17:0 0x18:0 0x19:2 
       B(J-ON  S-off C-break) step=1 byte=1 ★var_w110=0★(上界 14) distinct110=0 逆行=0 var_w122=0 varW=0 | 停止=section_return(term=section_return state=Finished lastOp=0xFE@0x1C) | choice 取=0 break=False cap=False | gate op 種=0 band外=4 | hist 0x13:0 0x14:0 0x16:0 0x17:0 0x18:0 0x19:0 
       C(J-off S-off C-cont ) step=76 byte=1185 ★var_w110=0★(上界 14) distinct110=0 逆行=0 var_w122=1 varW=2 | 停止=vm_gate(term=- state=Finished lastOp=0x5A@0x654) | choice 取=1 break=False cap=False | gate op 種=1 band外=4 | hist 0x13:0 0x14:0 0x16:6 0x17:0 0x18:0 0x19:9 
       D(J-ON  S-off C-cont ) step=1 byte=1 ★var_w110=0★(上界 14) distinct110=0 逆行=0 var_w122=0 varW=0 | 停止=section_return(term=section_return state=Finished lastOp=0xFE@0x1C) | choice 取=0 break=False cap=False | gate op 種=0 band外=4 | hist 0x13:0 0x14:0 0x16:0 0x17:0 0x18:0 0x19:0 
       E(J-ON  S-ON  C-cont ) step=1 byte=1 ★var_w110=0★(上界 14) distinct110=0 逆行=0 var_w122=0 varW=0 | 停止=section_return(term=section_return state=Finished lastOp=0xFE@0x1C) | choice 取=0 break=False cap=False | gate op 種=0 band外=4 | hist 0x13:0 0x14:0 0x16:0 0x17:0 0x18:0 0x19:0 
    ★section id6 @0x1E 起点 byte=0x1E ★上界 14 件★★
       A(J-off S-off C-break) step=31 byte=623 ★var_w110=0★(上界 14) distinct110=0 逆行=0 var_w122=1 varW=1 | 停止=choice_break(term=- state=WaitingChoice lastOp=0x10@0x28C) | choice 取=0 break=True cap=False | gate op 種=0 band外=4 | hist 0x13:0 0x14:0 0x16:0 0x17:0 0x18:0 0x19:2 
       B(J-ON  S-off C-break) step=25 byte=523 ★var_w110=0★(上界 14) distinct110=0 逆行=0 var_w122=1 varW=1 | 停止=section_return(term=section_return state=Finished lastOp=0xFE@0x228) | choice 取=0 break=False cap=False | gate op 種=0 band外=4 | hist 0x13:0 0x14:0 0x16:0 0x17:0 0x18:0 0x19:1 
       C(J-off S-off C-cont ) step=74 byte=1183 ★var_w110=0★(上界 14) distinct110=0 逆行=0 var_w122=1 varW=2 | 停止=vm_gate(term=- state=Finished lastOp=0x5A@0x654) | choice 取=1 break=False cap=False | gate op 種=1 band外=4 | hist 0x13:0 0x14:0 0x16:6 0x17:0 0x18:0 0x19:9 
       D(J-ON  S-off C-cont ) step=25 byte=523 ★var_w110=0★(上界 14) distinct110=0 逆行=0 var_w122=1 varW=1 | 停止=section_return(term=section_return state=Finished lastOp=0xFE@0x228) | choice 取=0 break=False cap=False | gate op 種=0 band外=4 | hist 0x13:0 0x14:0 0x16:0 0x17:0 0x18:0 0x19:1 
       E(J-ON  S-ON  C-cont ) step=25 byte=523 ★var_w110=0★(上界 14) distinct110=0 逆行=0 var_w122=1 varW=1 | 停止=section_return(term=section_return state=Finished lastOp=0xFE@0x228) | choice 取=0 break=False cap=False | gate op 種=0 band外=4 | hist 0x13:0 0x14:0 0x16:0 0x17:0 0x18:0 0x19:1 
    ★section id10 @0x590 起点 byte=0x19 ★上界 14 件★★
       A(J-off S-off C-break) step=11 byte=200 ★var_w110=0★(上界 14) distinct110=0 逆行=0 var_w122=0 varW=0 | 停止=vm_gate(term=- state=Finished lastOp=0x5A@0x654) | choice 取=0 break=False cap=False | gate op 種=1 band外=4 | hist 0x13:0 0x14:0 0x16:0 0x17:0 0x18:0 0x19:3 
       B(J-ON  S-off C-break) step=4 byte=97 ★var_w110=0★(上界 14) distinct110=0 逆行=0 var_w122=0 varW=0 | 停止=section_return(term=section_return state=Finished lastOp=0xFE@0x5F0) | choice 取=0 break=False cap=False | gate op 種=0 band外=4 | hist 0x13:0 0x14:0 0x16:0 0x17:0 0x18:0 0x19:1 
       C(J-off S-off C-cont ) step=11 byte=200 ★var_w110=0★(上界 14) distinct110=0 逆行=0 var_w122=0 varW=0 | 停止=vm_gate(term=- state=Finished lastOp=0x5A@0x654) | choice 取=0 break=False cap=False | gate op 種=1 band外=4 | hist 0x13:0 0x14:0 0x16:0 0x17:0 0x18:0 0x19:3 
       D(J-ON  S-off C-cont ) step=4 byte=97 ★var_w110=0★(上界 14) distinct110=0 逆行=0 var_w122=0 varW=0 | 停止=section_return(term=section_return state=Finished lastOp=0xFE@0x5F0) | choice 取=0 break=False cap=False | gate op 種=0 band外=4 | hist 0x13:0 0x14:0 0x16:0 0x17:0 0x18:0 0x19:1 
       E(J-ON  S-ON  C-cont ) step=4 byte=97 ★var_w110=0★(上界 14) distinct110=0 逆行=0 var_w122=0 varW=0 | 停止=section_return(term=section_return state=Finished lastOp=0xFE@0x5F0) | choice 取=0 break=False cap=False | gate op 種=0 band外=4 | hist 0x13:0 0x14:0 0x16:0 0x17:0 0x18:0 0x19:1 
    ★section id11 @0x7EA 起点 byte=0x19 ★上界 14 件★★
       A(J-off S-off C-break) step=11 byte=200 ★var_w110=0★(上界 14) distinct110=0 逆行=0 var_w122=0 varW=0 | 停止=vm_gate(term=- state=Finished lastOp=0x5A@0x8AE) | choice 取=0 break=False cap=False | gate op 種=1 band外=4 | hist 0x13:0 0x14:0 0x16:0 0x17:0 0x18:0 0x19:3 
       B(J-ON  S-off C-break) step=4 byte=97 ★var_w110=0★(上界 14) distinct110=0 逆行=0 var_w122=0 varW=0 | 停止=section_return(term=section_return state=Finished lastOp=0xFE@0x84A) | choice 取=0 break=False cap=False | gate op 種=0 band外=4 | hist 0x13:0 0x14:0 0x16:0 0x17:0 0x18:0 0x19:1 
       C(J-off S-off C-cont ) step=11 byte=200 ★var_w110=0★(上界 14) distinct110=0 逆行=0 var_w122=0 varW=0 | 停止=vm_gate(term=- state=Finished lastOp=0x5A@0x8AE) | choice 取=0 break=False cap=False | gate op 種=1 band外=4 | hist 0x13:0 0x14:0 0x16:0 0x17:0 0x18:0 0x19:3 
       D(J-ON  S-off C-cont ) step=4 byte=97 ★var_w110=0★(上界 14) distinct110=0 逆行=0 var_w122=0 varW=0 | 停止=section_return(term=section_return state=Finished lastOp=0xFE@0x84A) | choice 取=0 break=False cap=False | gate op 種=0 band外=4 | hist 0x13:0 0x14:0 0x16:0 0x17:0 0x18:0 0x19:1 
       E(J-ON  S-ON  C-cont ) step=4 byte=97 ★var_w110=0★(上界 14) distinct110=0 逆行=0 var_w122=0 varW=0 | 停止=section_return(term=section_return state=Finished lastOp=0xFE@0x84A) | choice 取=0 break=False cap=False | gate op 種=0 band外=4 | hist 0x13:0 0x14:0 0x16:0 0x17:0 0x18:0 0x19:1 
    ★section id7 @0xA68 起点 byte=0x1E ★上界 8 件★★
       A(J-off S-off C-break) step=6 byte=181 ★var_w110=0★(上界 8) distinct110=0 逆行=0 var_w122=1 varW=1 | 停止=choice_break(term=- state=WaitingChoice lastOp=0x10@0xB1C) | choice 取=0 break=True cap=False | gate op 種=0 band外=4 | hist 0x13:0 0x14:0 0x16:0 0x17:0 0x18:0 0x19:0 
       B(J-ON  S-off C-break) step=6 byte=181 ★var_w110=0★(上界 8) distinct110=0 逆行=0 var_w122=1 varW=1 | 停止=choice_break(term=- state=WaitingChoice lastOp=0x10@0xB1C) | choice 取=0 break=True cap=False | gate op 種=0 band外=4 | hist 0x13:0 0x14:0 0x16:0 0x17:0 0x18:0 0x19:0 
       C(J-off S-off C-cont ) step=51 byte=811 ★var_w110=0★(上界 8) distinct110=0 逆行=0 var_w122=1 varW=2 | 停止=vm_gate(term=- state=Finished lastOp=0x5A@0xDC4) | choice 取=1 break=False cap=False | gate op 種=1 band外=4 | hist 0x13:0 0x14:0 0x16:6 0x17:0 0x18:0 0x19:7 
       D(J-ON  S-off C-cont ) step=18 byte=392 ★var_w110=0★(上界 8) distinct110=0 逆行=0 var_w122=1 varW=2 | 停止=section_return(term=section_return state=Finished lastOp=0xFE@0xCDC) | choice 取=1 break=False cap=False | gate op 種=0 band外=4 | hist 0x13:0 0x14:0 0x16:1 0x17:0 0x18:0 0x19:1 
       E(J-ON  S-ON  C-cont ) step=18 byte=392 ★var_w110=0★(上界 8) distinct110=0 逆行=0 var_w122=1 varW=2 | 停止=section_return(term=section_return state=Finished lastOp=0xFE@0xCDC) | choice 取=1 break=False cap=False | gate op 種=0 band外=4 | hist 0x13:0 0x14:0 0x16:1 0x17:0 0x18:0 0x19:1 
    ★section id12 @0xD02 起点 byte=0x19 ★上界 8 件★★
       A(J-off S-off C-break) step=11 byte=198 ★var_w110=0★(上界 8) distinct110=0 逆行=0 var_w122=0 varW=0 | 停止=vm_gate(term=- state=Finished lastOp=0x5A@0xDC4) | choice 取=0 break=False cap=False | gate op 種=1 band外=4 | hist 0x13:0 0x14:0 0x16:0 0x17:0 0x18:0 0x19:3 
       B(J-ON  S-off C-break) step=4 byte=99 ★var_w110=0★(上界 8) distinct110=0 逆行=0 var_w122=0 varW=0 | 停止=section_return(term=section_return state=Finished lastOp=0xFE@0xD64) | choice 取=0 break=False cap=False | gate op 種=0 band外=4 | hist 0x13:0 0x14:0 0x16:0 0x17:0 0x18:0 0x19:1 
       C(J-off S-off C-cont ) step=11 byte=198 ★var_w110=0★(上界 8) distinct110=0 逆行=0 var_w122=0 varW=0 | 停止=vm_gate(term=- state=Finished lastOp=0x5A@0xDC4) | choice 取=0 break=False cap=False | gate op 種=1 band外=4 | hist 0x13:0 0x14:0 0x16:0 0x17:0 0x18:0 0x19:3 
       D(J-ON  S-off C-cont ) step=4 byte=99 ★var_w110=0★(上界 8) distinct110=0 逆行=0 var_w122=0 varW=0 | 停止=section_return(term=section_return state=Finished lastOp=0xFE@0xD64) | choice 取=0 break=False cap=False | gate op 種=0 band外=4 | hist 0x13:0 0x14:0 0x16:0 0x17:0 0x18:0 0x19:1 
       E(J-ON  S-ON  C-cont ) step=4 byte=99 ★var_w110=0★(上界 8) distinct110=0 逆行=0 var_w122=0 varW=0 | 停止=section_return(term=section_return state=Finished lastOp=0xFE@0xD64) | choice 取=0 break=False cap=False | gate op 種=0 band外=4 | hist 0x13:0 0x14:0 0x16:0 0x17:0 0x18:0 0x19:1 
