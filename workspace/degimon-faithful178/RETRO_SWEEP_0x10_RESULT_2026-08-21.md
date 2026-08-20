# 0x10 retro-sweep 結果(2026-08-21・#589-591 track・PRESIDENT 裁可で CLOSE)

## 0. verdict(固定)
★誤った Len[0x10]=1 は、追跡カウント(var[110] / entry 175 の候補 / 0x25 A=29)を ★1 件も汚染していません★★
⇒ ★過去 claim の書換は不要★ ⇒ ★retro-sweep 札は discharge★。

★standing residual(札は残る)★ = ★Len[0x10]=1 は実 decode bug★(下の entry 206 が実物)= ★低リスクな correctness fix 候補・0 カウント変化★。
★実修正は PRESIDENT の別 gate★(本 track では ★Len 表 / json / doc の数を 1 字も直していません★)。

## 1. 土台(夜間仮説の否定)
・夜間 doc の仮説 = 「Len 表の 0x10=1 は誤りだが専用処理が上書き = ★inert★」。
・★worker1 が source 行で否定★ = ★scn_trace の top-level walker に standalone 0x10 の特別扱いは無い★ = ★296 行の汎用 branch ln = self.L[op] に落ち Len[0x10]=1 で 1 byte だけ進む = choice 表の中へ入る★。
・★命名衝突の罠(scn_trace.py:126 の 0x10/0x18 = 0x19 term-chain 内の分岐 mode)は両 worker とも踏んでいません★(陰性対照つき)。

## 2. census(手順 a)= 「§238 限定」は両器とも外れ ⇒ (b) 不成立・(c) 該当
| 器 | 件数 / entry | walker | 起点 | 次元 |
|---|---|---|---|---|
| worker1 | ★350 件 / 81 entry★(model C) | w1_x138_choice_census.py walk() 60-95 | BodyStart(OFF+4+word0)+ 対表の全 offset | ★到達★ |
| worker2 | ★360 件 / 93 entry★ | workspace/tools/w2_op10census.py 歩く():44・全数():95 | OFF+4+Word0 のみ | ★線形復号(上限側)★ |
・陽性対照 = ★両器とも entry 175 rel 0x2A(abs 0x07E02A・10 03 …・N=3)を拾った★。
・陰性対照 = ★worker2 clean(term-mode 1,392 件が site に 0 混入)★ / ★worker1 は 1 件 leak → #590-A で ★暴走 parse(D2)★ と確定(owner の 0x19 の span に SJIS text run 11 本・3 項目以降は SJIS を flag idx として読む)⇒ ★主答 350 に確定・349 は取り下げ★。

## 3. (c) 4 対象の entry-level diff(★総和だけにしない★)
| 対象 | worker1(到達) | worker2(線形) | 動いた entry |
|---|---|---|---|
| ① var[110] | 旧 90 → 新 90(★±0★・7 entry) | L 90 → C 90(★±0★) | ★0 本★ |
| ② 0x25 A=29 | 1 → 1(±0) | 2 → 2(±0) | ★0 本★(★次元差 = §5★) |
| ③ entry 175 の候補 | 24 → 24(±0) | 24 → 24(±0) | ★0 本★ |
| ④ 線形被覆 | 60.07% → ★60.35%(+0.28 pt)★ | L 100.0%(★飽和・+237 byte 行き過ぎと自己申告★)→ C 87.8% | ★1 本(entry 206)★ |
・① の C 残存 = 135:1 / 136:1 / 137:1 / 148:1 / ★154:48★ / ★175:24★ / ★176:14★。
・★歴史の「93 件」との差 3 件(entry 135/136/137)は ★起点の定義差(entry base vs body 先頭)★であって model 差ではない★(worker2 の帰属訂正)。

## 4. ★『inert ではない』の実物 = entry 206★
・★75 byte → 2,036 byte(+1,961)★。★その 0x10 は N=241★ ⇒ ★旧 L1(Len=1)は次 byte から復号を続けて鎖が早く尽き、新 C は 2*241+6 = 488 byte 飛ばして同期が続く★。
・★構造の確認★ = ★0x10 を持つ entry 81 本 / 動いた entry 1 本 / はみ出し 0 本★ = ★変化は 0x10 を含む entry の中に完全に収まった★。
・★worker1 の予測 S4 は方向も逆★ = ★『表を飛ばす分だけ被覆が減る』と置いたが、実物は『飛ばした方が同期が回復して先が読める』★。

## 5. ② の次元差(★畳まない★)
・★到達次元 = 1 件(abs 0x03AB6A / entry 88)★ / ★線形次元 = 2 件(+ abs 0x03B4FA / entry 89)★。
・★検出条件は字面同一★(D[p]==0x25 かつ D[p+1]==29)⇒ ★operand の取り方ではない★。
・★決め手★ = ★entry 89 は walk が 0x03B18E の 0xFF(SCRIPT_END)で鎖を終え、site はその 876 byte 先・被覆 371/2,048 = 18.1% ⇒ そもそも歩いて届いていない((i) 到達しない)★。
・★両 site の hex は逐字同一★(前 6 byte 00 00 1C 00 C3 00 / 25 1D 16 00 70 03 4E 05)⇒ ★hex では見分けられない・見分けは abs offset と entry 番号★。
・★どちらでも 0x25 は remake 未実装ゆえ frzl08 の判断(StageHold)は動かない★・★land 候補(sha 3edd9231…)に入っているのは opcode 名だけで件数は 0 件 = この割れは生成物に触れない★。

## 6. park(次 session へ)
・★0x19 の入口 0x07FAC6 が実命令かどうか = 未決★(worker1 が『判らない』のまま保持)。
・★Len[0x10]=1 の実修正★(= §0 の standing residual・PRESIDENT の別 gate)。
・前 track の 7 件(0x57 / 0x24 の GO・呼び元の配線便・5 map (B)・0x10 の Len 表・var[110] 保留・worker1 の札 3 本)は registry のまま。

## 7. 方法論(本 track で確定した 2 点)
1. ★『機構が誤り』と『数が動く』は別★ = ★原因が在ることと効いたことは別★(worker2 が予測 4 本を外して型化)。★裏付け = comparator 自身の陽性対照(|L| 312,399 / |C| 275,403・同種の問いでは 0x1E 全部 -389 / 0x1C 全部 -169 / 0x25 全部 -11 が動く)⇒ ±0 は器の無能ではなく実測★。
2. ★次元差は畳まない★ = ★到達 と 線形復号(上限側)は別の量★。★数が割れたら『どちらが正しいか』の前に『どの器が何を数えたか』★。★正しい count の提示は次元ごとに複数で良い★。
+ ★『終端に届いたから実在の式』とは言えない★(worker1・未知 mode の catch-all 0 件で終端に偶然到達していた実例)。
