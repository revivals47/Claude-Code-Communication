# key script (tools/key_day.sh format "<screen|*> <wait s> <Key> <hold s>"): RODHOLD_SWITCH_W2.md ②-1 positive control (i) = the holder key once, not in a fight
05  2.0 Enter      0.1   # title: ストーリー
07  1.0 Enter      0.1   # inn prep -> 出船する
07  0.5 Enter      0.1   # -> the tackle shop
07  0.8 Enter      0.1   # shop: 出発 -> 06C
06C 3.0 Enter      0.1   # close the dango card = drop (KEY_DAY.md:25) -> 06, sinking
06  15.0 C         0.1   # after the bottom (~8.5 s): HolderToggle once (HostInput.cs:272 = C) -> logic Rest -> Hand, Unity stays Rest = a KH run
06  5.0 Escape     1.7   # long press -> pause P1
P1  0.5 DownArrow  0.1
P1  0.5 DownArrow  0.1
P1  0.5 Enter      0.1   # 今日は上がる
04  2.0 Enter      0.1
04  1.0 Enter      0.1
J   2.0 Enter      0.1   # the run ends at the info page
