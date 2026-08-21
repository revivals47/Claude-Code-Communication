# 次 phase registry(2026-08-20・#584-588 track CLOSE 時点)

## 1. 環境の札(新規登録・PRESIDENT 指示)
・★main worktree の provision 12 本不足(species_care_params.json を含む)★ = StreamingAssets/data が ★main 24 本 / integ 36 本★・★git 管理外(git ls-files = 0)★。
  ★再生成 = provision_curated_data.py で 36 本に★。★踏むと FileNotFoundException → NameInput の BindCareForm で例外 → field に届かない★。
  ★格 = 「worktree の provision 状態の差」まで(baseline build 未撃ゆえ『main の既存不具合』とは断定しない)★。★main から新規 build する人は踏み得る★。

## 2. park した札(座は PRESIDENT・次 session 起点)
・★0x57 の実装 GO★(事前登録 5 点は保持 = ①枠が合うまで実装しない ②読み手 0 件 → 死に field の札 / 非ゼロ → README に consumer 未実装の札 ③受理 oracle は matchedChars ④0x57 だけを通す arm ⑤既定予測 = 動かない)。
・★0x24 の実装 GO★(★G5 draft の再発見★・★DcRandom seam(無 seed System.Random)と混ぜないことが要件★・★同じ入力で同じ絵になるかは判らない★)。
・★呼び元の配線便★ = ★runtime の呼び元は今も 0 件★ ⇒ ★bit 同一は「呼び元 patch 文面の下で」★のまま。配線した瞬間に ★検定の呼び元 3 行(写し)は黙って意味を失う★。
・★5 map の (B)★ = ★段ごとの腕の突合(worker2 の逐語表 × worker3 の harness)★。★27 腕 = 27 一致(slot ↔ record 添字)★は済・★placer が実際に置くことの live 確認は mayo00 のみ★。
・★0x10 の Len 表★ = ★原盤は 2*N+6・shipped の 1 は誤り★・★我々の VM の実行経路は既に正しい(誤っているのは表を引く側)★。★表を直すかは PRESIDENT 保持★。
  ★2026-08-21 更新: retro-sweep で「表を引く側」の実害を測定 = 追跡カウントは ±0 だが、scn_trace の linear walker では実 decode に効く(entry206 75→2036 byte が実物)★。⇒ ★Len[0x10]=1 → 可変長 2*N+6 の修正は『どの追跡カウントも動かさない低リスク correctness fix』= 実施の判断材料が揃った(実修正は PRESIDENT gate、run で回帰確認込み)★。
・★var[110] は未捕獲★ = ★#586-C の 48 件は交絡つきの数として保存(取り下げ・消さない)★ ⇒ ★fact02 / stic02 の StageHold は維持★(理由 = 清潔な VM では gate が先に止める + section 起点では section が先に終わる)。
・★worker1 の札 3 本★ = ①0x80157B38 の同定(候補 2 + 反証材料)②+0x2DD の consumer(器の外に在る可能性)③0x24 の決定性(seed と draw 順)。
・★worker1 の採点待ち固定予測★ = W-3 / W-4 / W-5 / W-6' / W-7' / W-9(静的側)・W-1 / W-2(reset ありの run でのみ採点可)。★後から動かさない★。

・★~~worker2 の retro-sweep 札~~ = 2026-08-21 DISCHARGE(census+2 model diff 完了、結果 doc `RETRO_SWEEP_0x10_RESULT_2026-08-21.md`)★。
  ★verdict = 誤った Len[0x10]=1 は追跡カウントを 1 件も汚染していない = 過去 claim 書換不要★:
  var[110]=90(±0・旧「93」は起点定義差 entry base vs body 先頭で 0x10 model 差でない)/ var[29]=0(影響なし)/ 0x25 A=29=到達1・線形2(±0・次元差、畳まない)/ entry175 候補=24(±0)/ 線形被覆=次元別 2 値(87.8%/60.35%)。
  ★census: standalone opcode 0x10=CHOICE は 350 件/81 entry(§238 限定は否定、2 器+陽性/陰性対照)★。
  ★standing residual → 下の「0x10 の Len 表」札へ統合★: Len[0x10]=1 は inert でなく実 decode bug(entry206 75→2036 byte,+1961,N=241 が実物)。
・★park 解決(2026-08-22)★ = 0x19 入口 0x07FAC6 = ★mid-operand と確定★(実 0x19@abs 0x07FABC len12 の +10 byte 目・到達命令でない)⇒ 暴走 parse は誤 start artifact・census 350 裏取り・retro-sweep park 完全 close。詳細 = RETRO_SWEEP_0x10_RESULT §8。
・★worker2 の自己訂正 1 件★ = #587-B の残り「⑤ 段ごとの腕の突合は未突合」は★古い申告★で、★27 腕 = 27 一致(slot ↔ record 添字)は済★。★live 確認は mayo00 のみ★の限定はそのまま。

## 3. 不変(次 session へ引き継ぐ)
★push は HOLD(local commit まで)★ / ★land は PRESIDENT の承認★ / ★引き渡し build(w3_build582r)は不可触・userbuild branch HEAD 152885f9 不動★ / ★README(c661db4)は追記のみ・command block と §2 の表と log の見かたは不動★ / ★視覚忠実は user 実視覚まで凍結★。

## 4. Phase 1 受理条件の事前登録(2026-08-22・PRESIDENT・両 Phase 0 返着後に確定)
起点 = 0x57(worker1 #595-A・587bac3c)/ 0x24(worker2 #594-B・3021b607)。★実装着手はこの版を worker に配ってから★。採点値は後から動かさない(measurement discipline)。

### 4.1 共通の型(両 opcode)
- ★実装 = OFF-inert env-gate★ = 既定 OFF で完全 no-op(既存経路に触れない)。★gate 名を実装前に宣言★(未配線 toggle は no-op ゆえ grep+log で ON/OFF が本当に分岐することを確認してから A/B を信用)。
- ★採点順 = OFF 先★ = ON を測る前に、OFF で既存 golden/harness が bit 同一であることを確認。
- ★push HOLD / land = PRESIDENT / game code は commit まで(local)・push は user のみ★。
- ★札の格付け(死に field 等)は印字するが「格」の最終確定は PRESIDENT 保持★。

### 4.2 0x57
- ★再現対象 = (b) の 2 つのみ★ = ①operand 2 byte 消費(PC を opcode 込みで +4 前進 = 予約 1 byte skip + 1 byte×2)②record +0x1F へ 1 byte 書き(★2026-08-22 訂正: 値 = operand の val(4th byte)・sb。旧「値 = a1=1 固定」は誤読 = a1 は書く回数(loop 1・slt 上限)であって書く値ではない。worker3 が worker1 の逐語 handler body 0x800BA978 を直読 = lb ,0x10()=val / lh ,8()=idx / sb ,0x2dd()。裏取り = DG.SCN 生 byte 走査で 0x57 の 4th byte は 0×1792/1×1405/131×619 = 1 固定でない★)。
- ★共有 epilogue A(0x14) は実装対象外★ = 0x57 固有でない(0x80164068 を materialize する site は EXE 全体 37 件)・BIOS 内部未読 ⇒ ★park・実装しない★(この判断は PRESIDENT 確定)。
- ★value consumer は配線しない★ = census = 8 形態 0 件 ⇒ +0x1F の値は正しく書くが読み手ゼロ ⇒ ★「死に field の札」を doc/README に印字★(値は消さない・格は保留)。
- ★受理 oracle(2026-08-22 訂正)★ = ①cursor +4 前進が entry 実 decode で byte 一致 ②+0x1F に 1 byte(1 回)書かれ・★書いた値 = その site の operand val★(printer は「書かれた値」と「operand val」を両方印字 = 一致で PASS)③OFF で bit 同一。★「+0x1F=1 固定」は撤回★(踏んだ site の val がたまたま 1 なら旧文面も偶然通るが、oracle は val 一致で採る)。★「同入力→同絵」は要求しない★(0x57 は絵を出さない・state 遷移なし)。

### 4.3 0x24
- ★再現対象 = (b) の 3 つ★ = ①cursor +4 ②var[dst] へ RNG 由来値(handler 0x800EC964 = rand→mult→mflo→sra15→var[dst])③RNG の流を 1 つ消費。
- ★RNG = DcRandom seam と別 stream★(無 seed System.Random と混ぜない = care 決定性保護)・★seed は強制しない★。
- ★受理は「同入力→同絵」を要求できない★(非決定的 random var setter)。代わりに =
  ①var[dst] が 0 でなくなる(書かれる)②gate 式が『常に偽(ElsePlace 毎回)』から『確率的に真/偽』へ変わる(StageHold が確率解放される)③統計 = exact binomial 両側 α=0.01・2 値・N = 段評価回数。
- ★測る場所の訂正(2026-08-22・worker3 の撃つ前指摘 → PRESIDENT 承認)★ = ★landed の Stages は 9 map のみで stic02/fact02 は不在((B) 未承認・park)⇒ 『landed 表経由の ElsePlace 落ち率』は観測不能★。⇒ ★測る場所を 0x24 出力の gate 式直接評価に差替★ = arg=2 site で var[110]>0 が偽になる率(stic02)= P[(rand*3)>>15==0] = rand≤10922 ⇒ 10923/32768 / arg=99 site で var[110]>2 が偽になる率(fact02)= P[(rand*100)>>15≤2] = rand≤983 ⇒ 984/32768。★条件★ = (A) 結果の隣に枠を毎回明記(『landed 表の ElsePlace 落ち率ではなく 0x24 出力に対する段の式の直接評価』= 受理文言と測定場所が違う)/ (B) 段の式の出どころ(worker2 X-127 逐語 or 自器再読)を 1 行。
- ★恒等式は証拠でない(worker3 自身が添付)★ = p0 が worker2 の全数列挙と逐字一致するのは『差分ゼロ』であって『正しい』ではない(同じ列挙)⇒ 実の確証は ★実装の実測 draw 分布が N 回で二項帯に入ること★。
- ★受理の格(scope の次元明記)★ = この統計 PASS が証すのは ★0x24 が gate 式層で正しい確率分布を出す★ことまで・★実プレイで scene が原盤率で ElsePlace に落ちる★ことではない(後者は (B) 承認 + draw 順 + live が要る = park)。
- ★注記(scope 明示)★ = 0x24 だけ実装しても絵は揃わない(worker2 (b): 本体は draw 順)⇒ 受理は var[110] gate 挙動に scope・★full-scene 視覚一致は別 phase(draw 順込み)★。
- ★fact02/stic02 の確率(~3% / ~1/3)は算術であって実機未測★ = 統計 oracle の「原盤率」は実機 trace で裏取りするまで参考値。主 oracle = stic02(~1/3)/ fact02(~3%)は検出力ほぼ無で補助。
- ★生成器カバレッジの穴(2026-08-22・worker2 自己申告 f257548e)★ = 帯の一様性は worker2 の経験測定(PSX LCG・4 seed×100 万)では裏取りされていない = 実装は .NET System.Random(Next(0,32768))を使うゆえ、依っているのは『Next(int,int) は [0,32768) を一様に返す』の仕様。⇒ ★C# 側で同じ生成器から 100 万 draw して経験率を 1 行 = 切り分け材料(受理条件ではない)★ = 帯が外れたとき『実装の誤り』と『生成器の偏り』を分ける。worker3 の (e) run に同乗(別 run 不可・同乗不可なら 1 行でそう書く)。帯・p0・要 N の表は不変。
- ★static _op24Rng の reset 決定(2026-08-22・me+PRESIDENT)★ = ★reset は足さない★。理由 = (1) 原盤も 1 本の共有 stream(static single stream は原盤忠実)(2) 単一 PRNG からの連続 draw はまさに独立 Bernoulli 試行 = 二項帯の前提を満たす(壊すのは walk ごと同 seed 再初期化・していない)(3) process 分離は System.Random 既定 seed が時刻由来で近接起動衝突ゆえ より危険 ⇒ ★1 process・1 stream のまま撃つ★。worker2 の指摘(harness hidden input 完全性)は正当な提起で、事実確定の上で解消。
- ★生成物 comment の理由修正(0x1E-only は不完全)は別 PRESIDENT gate★ = Phase 1 に含めない。

### 4.4 Phase 1 に含めない(park・座は PRESIDENT)
BIOS A(0x14) の中身 / 配列 0x80157B38 の同定 / var[110] 書き手台帳の comment 反映 / 呼び元配線(runtime 呼び元 0 件のまま) / full-scene draw 順。
