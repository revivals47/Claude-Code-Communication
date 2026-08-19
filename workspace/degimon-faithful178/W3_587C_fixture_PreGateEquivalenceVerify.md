[PGEQ] PASS 母数: Flag index distinct = 8 本 [114,144,147,203,204,218,231,245]
[PGEQ] PASS (2-a) gias02 段数 Stages=1 / ElsePlaceStages=1
[PGEQ] PASS (2-a) gias03 段数 Stages=1 / ElsePlaceStages=1
[PGEQ] PASS (2-a) gias04 段数 Stages=1 / ElsePlaceStages=1
[PGEQ] PASS (2-a) koda00 段数 Stages=1 / ElsePlaceStages=1
[PGEQ] PASS (2-a) mayo00 段数 Stages=1 / ElsePlaceStages=1
[PGEQ] PASS (2-a) mist02 段数 Stages=1 / ElsePlaceStages=1
[PGEQ] PASS (2-a) mist04 段数 Stages=1 / ElsePlaceStages=1
[PGEQ] PASS (2-a) mist07 段数 Stages=1 / ElsePlaceStages=1
[PGEQ] PASS (2-a) trop04 段数 Stages=1 / ElsePlaceStages=1
[PGEQ] PASS (2-a)件数 = 9 本(期待 ★9 ちょうど★・★0 でも FAIL★)
[PGEQ] PASS ①件数 = 2304 通り(期待 2304 = 9 map × 256)★0 通りでも FAIL★
[PGEQ] PASS ①全数一致(Otsu)
[PGEQ] PASS (1) `Blocked` の arm を 突き合わせた 件数 = ★704 件★(★0 でも FAIL★ = ★`Blocked` が 1 度も 出て いない = 掃引が 効いて いない 印★)
[PGEQ] PASS ②裸の 食い違い = 256 件・map = [gias04,trop04](期待 = 旧口 ∩ StageHold = [gias04,trop04]) ★これは v2 の bug では なく 母数の 引き方★
[PGEQ] PASS ③ gias02 getFlag=null HEAD[else=- only=- skip=] v2[else=- only=- skip=]
[PGEQ] PASS ③ gias03 getFlag=null HEAD[else=- only=- skip=] v2[else=- only=- skip=]
[PGEQ] PASS ③ gias04 getFlag=null HEAD[else=- only=- skip=] v2[else=- only=- skip=]
[PGEQ] PASS ③ koda00 getFlag=null HEAD[else=- only=- skip=] v2[else=- only=- skip=]
[PGEQ] PASS ③ mayo00 getFlag=null HEAD[else=- only=- skip=] v2[else=- only=- skip=]
[PGEQ] PASS ③ mist02 getFlag=null HEAD[else=- only=- skip=] v2[else=- only=- skip=]
[PGEQ] PASS ③ mist04 getFlag=null HEAD[else=- only=- skip=] v2[else=- only=- skip=]
[PGEQ] PASS ③ mist07 getFlag=null HEAD[else=- only=- skip=] v2[else=- only=- skip=]
[PGEQ] PASS ③ trop04 getFlag=null HEAD[else=- only=- skip=] v2[else=- only=- skip=]
[PGEQ] PASS ③ 陰性対照 表に無い fact02
[PGEQ] PASS ③ 陰性対照 表に無い betl01
[PGEQ] ★★④ 退路の 未踏★★ 表の Var 項 = 0 / Clock 項 = 0 ⇒ ★この 掃引では 退路 3 本は ★1 件も 踏まれません★★ = ★『全数 緑』は 退路が 正しい 証拠に ★なりません★★(別建て = PreGateRetreatVerify)
[PGEQ] === MODE=Otsu PASS=26 FAIL=0 / 入力 2304 通り ===
[PGEQ] ★★一致は『差分ゼロ』であって『正しい』では ありません★★
