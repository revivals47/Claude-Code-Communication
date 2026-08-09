# step4 (p2) 設計doc: opcode 0x46/0x79 忠実実装(boss1 単一推奨、gate①上申用)

status: ★CLOSE(boss1委譲検収 land、2026-07-19 06:2x)★ — k1-k4=f1b land(a69a76e/a104260/0b7ab36/548fa99、push HOLD)。検証=★全条項literal充足★(leaf18/18・e1 desync0+0x47隣接正当(ON/OFF emit27=27)・e2 corpus 6/6 byte1:1・e3 OFF-inert・e4 care3系統+sweep+warning等集合NEW=0)。字義未充足ゼロ=帰属判断上申は不要(gate①D4条件非発動)。ON側user可視挙動=user live凍結維持。残OI=OI-5/6/7。
(gate①GO=PRESIDENT 2026-07-19 06:20) — 全採用。D4=boss1委譲検収でland承認、条件=『prereg条項の字義未充足→条項改訂/実装是正/mis-spec訂正の帰属判断はPRESIDENT裁定へ(委譲=検収であって条項変更権を含まない。boss1権限内mis-spec訂正は(vi)方式=Pattern 4記録+次報追認)』。§3 prereg e1-e4=本裁定をもって固着(以後改訂禁止)。land後=簡潔close報告(commit列+条項単位判定)。入力=STEP4_P1_RE_worker1.md(handler全長RE+corpus 6 site実byte、0x47 gloss是正済)+STEP4_P1_XCHECK_worker2.md(blind x-check Q1-Q4全CONVERGE=二重独立)。boss1裏取り=両table実word+両handler prologue一致。

## 0. 正premise(p1確定)

- ★0x46 = REGISTRY_ADD★(handler 0x800ED480、Len=2): operand(registry id)を 8-slot registry(@0x80164098、stride4、sentinel -1)の空きslotへ格納+activate(0x800bb518→0x800a1348=actor実体、2段目gap)。
- ★0x79 = REGISTRY_REMOVE★(handler 0x800EF190、Len=2): operand一致slotを-1 clear+deactivate(0x800bb968=gap)。0x46の完全dual。
- PREREG §1 旧label『registry(640A4=model)』の精密化: 0x801640A4=★registry slot3★。『model』semantic=🅰(slot値の意味論はactor実体RE後)。
- corpus実測(6 site全、実byte確定): [46 XX][47 XX NN 00]隣接=『ADD id XX→MAP_CHANGE(map=XX,spawn=NN)』。★XX 6/6一致=id空間観測(registry id空間==map id空間の機構的同一は主張しない=🅰)★。(151,60)のみ[79 01][46 75]=registry入替。0x79=全corpus 1 site。
- 実行実測: 0x46=6回/0x79=1回(census動的)=母数極小 → ★検証はcorpus 6 entry明示指定★(full sweepでは埋もれる、census §4c既定)。

## 1. 忠実仕様(実装対象面)

| block | EXE実測 | 忠実度クラス |
|---|---|---|
| A1 operand fetch | 1byte(0x800f0edc)、両opcode | ★実装(decode忠実)★ |
| A2 registry ADD | 8-slot array、★空slot探索順=0x800f1590の実orderを実装時に1:1複製★(発明禁止、p1 doc記載orderで) | 実装(raw model) |
| A3 registry REMOVE | operand一致slot→-1 | 実装(raw model) |
| A4 activate/deactivate | 0x800bb518→0x800a1348 / 0x800bb968(actor実体) | ★宣言gap(loud log、id実値付き)★ |
| A5 exit | 両handlerとも b epilogue=clean(fall-through無、p1確定) | 通常break(0x66型のlaunch停止は不要=EXEもepilogue復帰) |

## 2. 設計判断点と★単一推奨★

- D1 scope=★0x46+0x79同時★(完全dual・同一registry・合計diff極小。片方だけでは(151,60)の入替patternを検証できない)。
- D2 registry=GameState raw model(int[8]、sentinel -1、既存raw slot方式=step2台帳と同形式)。activate実体=宣言gap(step5 D2と同方針、発明禁止)。
- D3 flag opt-in既定OFF(新flag DEGIMON_ACTOR_REGISTRY=1、_warpEmit/_sceneDriver同型)。★0x47は既存実装のまま非改変★(corpus内0x47=MAP_CHANGEとして従来どおりemit、0x46/0x79が0x47のbyteを消費しない=隣接decode正当性がe1の検証面)。
- D4 land gate: 0x46/0x79はPREREG §14 gate②列挙(MAPHEAD/0x66)の対象外 → ★単一推奨=boss1委譲検収でland(small commits+非退行gate)、設計のみgate①裁定★。PRESIDENTがgate②扱いを望む場合は指定を。

## 3. (p4) 差分テスト prereg(p3着手時固着・事後改訂禁止)

- e1 decode: corpus 6 entry(=(129,6)(151,60)(170,51)(171,51)(172,51)(173,51))で walker desync 0+0x47隣接decode正当(0x46がLen2で止まり0x47が従来どおりMAP_CHANGE emit)。
- e2 registry state: ON時、corpus 6 entryの registry op列が実byteと1:1 — (129,6)=ADD 0x9a/(151,60)=REMOVE 0x01→ADD 0x75/(170-173,51)=ADD 0x50/0x44/0x63/0x5d。slot挙動(空slot探索order/sentinel)=EXE order準拠。
- e3 OFF: [ACTOR-REG] log 0件+bit不変。
- e4 非退行: care 3系統+CutsceneVerify178+full sweep desync 0+ON warning⊆OFF(NEW=0、step5訂正(vi)条項の再利用)。
- 完成claim=user live凍結(ON側可視挙動)。

## 4. 割当

worker2=p3実装(f1b、small commits)/worker1=spec照合review/worker3=検証run(slot、corpus指定+full sweep)。

## 5. open items(2026-07-19 06:4x 更新)

- OI-5: ★RESOLVED★(worker1 OI5_ACTIVATE_RE、boss1 spot-check済)— activate/deactivate実体=refcounted actor-instance allocator(0x800a2c30/0x800a3164、table@0x80140410 stride0x1c、id gate[0,180)、refcount初回=spawn)。registry slot値=actor-instance id。残=spawn block 0x800a2d98(id→model/sprite解決)=後段起票(OI-5b)。
- OI-6: ★RESOLVED★ — 6/6値一致=別テーブル・別resolverのauthoring属性(機構的同一でない)。p1 🅰保留の実証。
- OI-7: ★RESOLVED(上界確定)★(worker1 §6ter、section-accurate decoder walk・corpus6完全一致でself-validate)— 0x46静的≈19 site/16 entry(entry0=MAPHEAD特殊entry除外・開示)/0x79静的=4 site/2 entry(★entry176 ×3=79 00、動的未到達=新規static site★)。動的(6/1)=confirmed floor、静的=upper bound(exhaustive証明でない、section-internal desync未定量=開示)。差分テストcorpus6=reached挙動の代表として妥当(静的追加siteは同機構)。
