# W3_584C var[110] census — remake の VM で DG.SCN を枠つきに歩いた結果
# ★読みではなく『書かれた瞬間』(TraceFx var_w)を数えます★

== pass L(linear/fall-through) ==
  entry: 走った 225 / 空で飛ばした 0 / 全 225
  ★打ち切りの数★: op guard 0 / content-end guard 0 / tick 上限 0 / WaitingChoice 37
  trace step 総数 = 8314 / var_w 総数 = 183 / 相異なる idx = 22
  ★★idx=110(0x6E) の var_w = 0 件★★
  ★陽性対照★: 0x1F=0 0x1C=0 0x4A=0 0x6F=2 0x6D=0 0xFE=12 0x00=0
  上位 idx: 0xF8:25 0xF7:25 0x65:22 0xFA:19 0xFE:12 0x01:10 0xFB:9 0xFC:9 0xFD:9 0x70:9 0xC8:7 0x78:4

== pass B(behavioral/jumps) ==
  entry: 走った 225 / 空で飛ばした 0 / 全 225
  ★打ち切りの数★: op guard 0 / content-end guard 0 / tick 上限 0 / WaitingChoice 57
  trace step 総数 = 14111 / var_w 総数 = 600 / 相異なる idx = 32
  ★★idx=110(0x6E) の var_w = 0 件★★
  ★陽性対照★: 0x1F=1 0x1C=4 0x4A=0 0x6F=2 0x6D=0 0xFE=16 0x00=0
  上位 idx: 0xF5:171 0x65:85 0xF8:63 0xF7:62 0xFA:49 0xFB:24 0xFC:24 0xFD:24 0xFE:16 0x01:15 0xC8:11 0x27:9
