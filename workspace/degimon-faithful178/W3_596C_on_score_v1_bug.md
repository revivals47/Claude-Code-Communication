# W3 Phase1 ON 採点 — #596-C (e)
# gate: Op24Enabled=True / Op57Enabled=True

== ① 0x57 ==
  実行 site = 27
  ★cursor +4★ OK=27 / NG=0
  ★書いた値 == operand val★ OK=22 / NG=5
  ★1 site あたり 1 回★ OK entry=3 / NG entry=0
     entry28 pc=0x4E len=4 idx=19 ★operand_val=1 / 書いた値=1★ next=0x52
     entry28 pc=0x52 len=4 idx=18 ★operand_val=1 / 書いた値=1★ next=0x56
     entry149 pc=0x3A len=4 idx=73 ★operand_val=0 / 書いた値=0★ next=0x3E
     entry149 pc=0x3E len=4 idx=74 ★operand_val=0 / 書いた値=0★ next=0x42
     entry149 pc=0x42 len=4 idx=75 ★operand_val=0 / 書いた値=0★ next=0x46
     entry149 pc=0x46 len=4 idx=76 ★operand_val=0 / 書いた値=0★ next=0x4A
     entry149 pc=0x4A len=4 idx=77 ★operand_val=0 / 書いた値=0★ next=0x4E
     entry149 pc=0x4E len=4 idx=78 ★operand_val=0 / 書いた値=0★ next=0x52
     entry149 pc=0x52 len=4 idx=79 ★operand_val=1 / 書いた値=1★ next=0x56
     entry149 pc=0x56 len=4 idx=80 ★operand_val=1 / 書いた値=1★ next=0x5A
     entry149 pc=0x5A len=4 idx=81 ★operand_val=1 / 書いた値=1★ next=0x5E
     entry149 pc=0x5E len=4 idx=82 ★operand_val=1 / 書いた値=1★ next=0x62
     entry149 pc=0x62 len=4 idx=83 ★operand_val=1 / 書いた値=1★ next=0x66
  ★val NG★ entry153 pc=0x48 idx=0 operand_val=0 wrote=1
     entry153 pc=0x48 len=4 idx=0 ★operand_val=0 / 書いた値=1★ next=0x4C
  ★val NG★ entry153 pc=0x4C idx=1 operand_val=0 wrote=1
     entry153 pc=0x4C len=4 idx=1 ★operand_val=0 / 書いた値=1★ next=0x50
  ★val NG★ entry153 pc=0x50 idx=2 operand_val=0 wrote=1
     entry153 pc=0x50 len=4 idx=2 ★operand_val=0 / 書いた値=1★ next=0x54
  ★val NG★ entry153 pc=0x54 idx=3 operand_val=0 wrote=1
     entry153 pc=0x54 len=4 idx=3 ★operand_val=0 / 書いた値=1★ next=0x58
     entry153 pc=0x5C len=4 idx=0 ★operand_val=1 / 書いた値=1★ next=0x60
     entry153 pc=0x60 len=4 idx=1 ★operand_val=1 / 書いた値=1★ next=0x64
     entry153 pc=0x64 len=4 idx=2 ★operand_val=1 / 書いた値=1★ next=0x68
     entry153 pc=0x68 len=4 idx=3 ★operand_val=1 / 書いた値=1★ next=0x6C
     entry153 pc=0x6C len=4 idx=5 ★operand_val=0 / 書いた値=0★ next=0x70
     entry153 pc=0x70 len=4 idx=6 ★operand_val=0 / 書いた値=0★ next=0x74
  ★val NG★ entry153 pc=0x84 idx=4 operand_val=0 wrote=1
     entry153 pc=0x84 len=4 idx=4 ★operand_val=0 / 書いた値=1★ next=0x88
     entry153 pc=0x98 len=4 idx=4 ★operand_val=1 / 書いた値=1★ next=0x9C
     entry153 pc=0xA8 len=4 idx=7 ★operand_val=0 / 書いた値=0★ next=0xAC
     entry153 pc=0xAC len=4 idx=8 ★operand_val=0 / 書いた値=0★ next=0xB0

== ② 0x24 ==
  ★N = 2000(段を評価した回数・1 process 1 stream・walk ごとの reseed 無し)★
  ★stic02(主) arg=2 : 落ち k = 649 / N = 2000  (p0 = 10923/32768 = 0.333344)★
  ★fact02(補) arg=99: 落ち k = 61 / N = 2000  (p0 = 984/32768 = 0.030029)★
  ★var[dst] が 0 でない回数★ arg=2 -> 1351 / arg=99 -> 1939
  ★exact binomial 両側 α=0.01 の受理帯は報告側で計算します(k と N をそのまま出します)★
  (参考)VM 走行での Op24Count 累計は entry ごとに reset しているため上の N とは別軸です
