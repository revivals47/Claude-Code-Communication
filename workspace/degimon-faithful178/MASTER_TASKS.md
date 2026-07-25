# faithful-178 残gap解析 dispatch (2026-07-09)

## 目的
user実視覚(2026-07-09)で確定した覚醒cutscene 2 gapの解析。read-only RE中心、remake配線は本dispatchのscope外。

- Gap1: 場面転換欠落 — 原盤は§0x36→§0x37境界でジジモンの家(室内)へ転換、remakeは全編twna01
- Gap2: 初期framing誤り — 原盤=twna01中央草原、remake=水辺/洞窟(camera scroll freeze未解決が根)

## Phase / 完了基準

### Track A (worker1, sp3re, track/scene-prog-re) — mailbox consumer RE ★Gap1決着 03:35★
- [x] consumer chain完全pin(drainer 0x800EC394→jump-table 0x8011b40c)
- [x] type6=CAMERA PAN(world/signed16 triple-confirm)、type7=PAN-TO-ENTITY、0x4A=WAIT-FOR-ASYNC、0x67=WAIT-N-FRAMES(訂正25ed350)
- [x] ★0x4B=MAP/ROOM SWITCH全chain確定(136bb4b)★: a1=3→host loop 0x800F02B8→0x800e3da0(20frame warp)→0x800E4178 StartScript(byte1)=無条件load。mode由来load-skipなし、byte2=spawn選択、byte3=return-push、fade=var[6] gate
- [ ] 最終task: 配線dispatch入力spec集約節をdocにcommit(03:46依頼)
- 成果物: sp3re/workspace/notes/trackA_mailbox_consumer_re.md(commits 7204c6f/25ed350/136bb4b)

### Track B (worker2, sp3w2, track/scene-prog-decode) — 家map同定+setup分類 ★完了 03:19★
- [x] 家=ROOM08(id218)第一候補(lname48実引き+TWNA01 slot2 warp)、副候補ROOM10/11。最終選択=Track A map-set機構待ち
- [x] byte=0x14=pan duration と判明(Track A)、map id 空間でないことを両面から確定
- [x] cluster全opcode分類(handler RE+disasm addr付)、map-load opcode不在
- [x] 座標183/221=warp spawn(±千)とスケール不一致=別座標系、load後ROOM08座標の公算(定量妥当性open)
- [x] 2 id空間規約(registry idx 218 vs 内部map_id、TWNA01=4)をdoc冒頭に
- 成果物: sp3w2/workspace/notes/trackB_gigimon_house_map_id.md
- 次タスク(03:24割当): scenario-0 orchestrator解読(entry0 ACTIVATE178前後walk+ROOM08内部map_id実引き+room08_bg寸法傍証)

### Track C (worker3, sp3, track3/faithful-178) — scroll機構置換PoC
- [x] diagnosis doc 読了、Option A(backdrop quad移動)選定 → boss1承認
- [x] PoC 実装(FieldManager: FORCE_SCROLL parse+ApplyBackdropScroll、FieldState: intro抑止)
- [x] ★PASS★ FORCE_SCROLL 0,0 vs 448,400 → AE=102543(33.4%)/RMSE=0.2417、coherent pan目視済。commit 359d744(local)
- [ ] control run厳密化(quad無効化1枚でattribution機械的close) — 03:14割当、slot再付与
- [ ] 原盤準拠実装形の設計draft(コード未着手、座標空間はworker1確定待ちで両案併記)
- 成果物: sp3/workspace/notes/trackC_scroll_replacement_poc.md + shotA/B/diff png + logs
- 制約: commit可/push禁止。entities側の扱い=配線dispatch設計時のPRESIDENT論点

## serialization / 制約
- Unity build/live: worker3 専有(A/B は read-only RE で競合なし)
- 0x4F の remake 実装配線: scope外(A/B確定後の別dispatch、PRESIDENT判断)
- 捏造ゼロ: 観測/推論/仮定の区別、未検証明示

## timeline
- 02:50 worker1 着手ack
- 02:51 worker2 着手ack
- 02:53 worker3 dispatch 発行、PRESIDENT へ dispatch完了ack → PRESIDENT承認受領
- 02:54 worker2 30分報告: 街=id168-204/twna01=id204確定、cluster再現(0x29×58訂正)。byte=20→id20=MIHA02。boss1: H4逆仮説(MIHA=家family)のlname実引き検証を指示、0x4F深掘りはTrack A重複で差止め
- 02:55 worker3 着手報告: Option A(backdrop quad transform移動)採用→boss1承認。FORCE_SCROLL 0,0 vs 448,400の2枚diff計画
- 02:58 worker1へcross-track共有(byte→MIHA02、consumerのindex先tableが核心)、PRESIDENTへ集約ack
- 02:57 worker3 slot使用開始(code編集完了: FORCE_SCROLL parse+ApplyBackdropScroll+intro抑止)→rebuild/screenshot中
- 02:58 worker1 中間報告: ★consumer chain完全pin、type6=CAMERA PAN断定(machine-check)★。byte=20はpan duration(frame)、u16対183/221=world座標。0x4F=家転換hypothesis非支持(H4)
- 03:00 仮説転換の再調整: worker1→0x4A(operand c8=200、街id範囲内)RE優先度上げ+pan座標系open question。worker2→MIHA02検証打切り、id200実引き+cluster分類続行。PRESIDENTへ重要ack(配線dispatch設計は0x4A確定後に上申と報告)
- 03:02 PRESIDENT追加指示を展開: worker1に(183,221)座標空間断定(world vs bg-pixel、0x800e2b28変換式で確定)を0x4Aと並ぶ優先度で追加。worker3に原盤camera pan spec(target投影-半画面offset+map境界clamp)を供給、PoC成功後は原盤準拠形に寄せる方針
- 03:03 worker2 ★家map同定決着★: ジジモンの家=ROOM08(id218、lname48実引き、TWNA01 slot2 warp、flags204室内)。副候補ROOM10/11。MIHA逆仮説は観測棄却。id200=TWNB21(街区)→0x4A=家load説の状況証拠弱化
- 03:05 boss1調整: warp-slot発火仮説をcluster分類観点に追加(worker2)。worker1へ0x4A『load以外の可能性』を開いておくようcross-share。PRESIDENTへ決着ack
- 03:08 boss1直接grep(PRESIDENT手掛かり): jal 0x800bb544(warp executor)直呼びは全EXEで0x47 handler(0x800ED4D4)の1件のみ。0x47はoperand 3byte(a0/a1/a2)+共通return 0x800edd5c合流。→worker2に『entry178境界付近の0x47存在+operand実値』最優先確認、worker1にexecutor引数semantic確定を依頼
- 03:10 PRESIDENT機械scan: entry178本文にraw 0x47=0件→★warp仮説棄却確定★。境界cluster実op列を機械walkで提供(4f/4a c8/67×2/1d/22/19×2/18/16/34×16/29×58/2b/23/4c/1b 05→DIALOG)
- 03:12 優先度組替: worker1=①type7 consumer chain(fade bracket説、map switch実行主体候補)②座標空間③0x4A④0x4C(executor引数REは取消)。worker2=0x47確認打切り、機械walk列基準でcluster分類(0x67×2 fade bracket照合+0x34/0x29 operandパターン)
- 03:09-14 worker3 ★Track C PASS★(AE=102543/33.4%、coherent pan、commit 359d744 local)→control run(QUADMOVE=0 guard)割当、slot再付与、実行中
- 03:12 worker2 cluster分類完了(handler RE根拠): 0x4A=portrait set/0x34=property store/0x29=roster/0x67=u16 set+YIELD等。★map-load opcodeはcluster内不在★→map設定は親flow(§238 ACTIVATE178+0x800E3FA0)
- 03:13 worker1 ★Track A完了★(commit 7204c6f): type6=CAM PAN(world/signed16 triple-confirm)、0x4A=WAIT-FOR-ASYNC、bonus type7=PAN-TO-ENTITY(fade仮説反証)、0x67 blocking=pan-to-player
- 03:16 boss1再編: H4前線=0x800E3FA0(ACTIVATE handler)RE→worker1投入(0x4C取消=B重複)。★0x67 semantic A/B不一致検出★→worker1照合最優先、worker2データはboss1中継。PRESIDENTへ集約ack
- 03:15 worker3 ★attribution反転(自己検出・撤回)★: quad移動=no-op(on/off bit-identical×2組)、PoC diffは全てprincipal-shiftが生成=principal-shiftはliveで実pan。diagnosis『bit-identical』と矛盾(条件差: diagnosis=x224固定y振り vs 今回x,y両振り)→axis分解測定中
- 03:16 worker2 0x67不一致の証拠(行番号付き): 0x67 handler=0x800ee994(u16+YIELD)、0x800EE948=★op0x66分岐先★=Track A cross-opcode混同疑い→worker1へboss1中継、機械再現+doc訂正依頼
- 03:20 PRESIDENT観測: twna01_bg=屋外のみ(室内不在)→★map切替必須確定★。ROOM08 asset=remake配備済(runtime load確認は配線時)。pan先=ROOM08-local座標可能性、切替/pan実行順序を0x800E3FA0 REで確定する観点を投入
- 03:22 worker3 axis分解完了(commit 32e04c5): ★X軸m02=live dead(AE103)/Y軸m12=live有効(AE102186)★、diagnosis一致ケースも再現せず(AE102448)→『条件差』として記録(当時harness未commit復元不能、batchmode縮退仮説)。→Gap2は機構置換不要の可能性大、worker3推奨採用で『既存Y-scrollでframingが直るか』検証ショットGO
- 03:22 worker1 0x67照合決着: Track B説を独立機械再現で承認、自doc訂正commit 25ed350。0x67=WAIT-N-FRAMES(u16 countdown)。dispatch 2段表構造確定(≤0x63一次表0x8011b0e8/≥0x64二次表0x8011b3a0)。★新リード: op0x66=複合scene/story-progression opcode(StartScript+scene selector 0x800aeca8+conditional pan)★
- 03:26 boss1: worker2にentry178/entry0のop0x66 walkスキャン追加。PRESIDENTへ2件決着+Gap2方針転換を上申
- 03:30 PRESIDENT ★0x4B=room-load有力解を発見★(machine-check): handler 0x800ED774がoperand(map,mode,key)を-0x6cac/-0x6caaへsh+type4 return-record push+signal a1=3。entry178内0x4B×2完全対称: @0x7c8=(218=ROOM08,1,0x36)家転換点一致 / @0x130e=(204=twna01,2,0xff)field復帰一致。consumer未confirm
- 03:32 redirect: worker1=①a1=3 arm ②-0x6cac/-0x6caa consumer(本命0x80118590)③var[6]分岐 — ②確定でGap1決着。worker2=0x66スキャン打切り(SJIS 0x8366偽hit教訓)、entry0の0x47 WARP群listing+remake現行0x4B実装確認(oplen=4正否含む)
- 03:30 worker2 ★Gap1根因をremakeコードで特定★: DialogueRuntime.cs OP_WARP_DEST(0x4B)がtransporter-menu専用semanticに誤bind、_warpEmit gate(default false)でcutscene中は消費のみ=map変更emitゼロ。oplen=4は正。map operand=registry idx空間(5例bytecode裏取り)。★副次risk: 0x4E spurious menu pause(mc=2)→live確認項目★
- 次: worker1 0x4B consumer pin(mode1/2使い分け=配線fix仕様の核)、worker2 doc commit→収束、worker3 Y-scroll framing検証ショット
- 配線dispatch設計案の骨子(材料揃い次第上申): 0x4B mode1=無条件room-load route(OnMapChangeRequested)+menu gate分離+0x4E対策+ROOM08 runtime load確認
- 設計制約(PRESIDENT 03:36先出し): ①原則=『opcode semanticは文脈非依存で忠実bind、menuは別機構』(0x4E-as-menuと同型誤conflate第2例としてStep1原則適用) ②★terminal 0x4B(204,mode2,ff)とStep1 interim guard C(空stack 0xFF=script-end→field復帰)の役割重複★ — 忠実化後の二重遷移/競合を設計時に明示解決。guard C縮退/撤去も選択肢だが撤去は原盤挙動確認とセット(honest-mark済interim)
- live確認項目(配線dispatch時): 0x4E spurious menu pause / ROOM08 asset runtime load
- 03:32-40 Gap2裁定: worker3検証=Y機構+center較正健全、fy200=clean村中心framing(RMSE0.208最良)、逆算exact(328)は黒帯で再現不可。→★PRESIDENT裁定=Option A採用★(center framing、条件: ①coverage較正residual登録 ②pin(412,448)再確認推奨 ③(b)cutscene注入liveness FAILなら再上申 ④完成claimはuser実視覚凍結)。worker3=(b)test実行中
- 03:33 worker2本日分収束(commit d50829a/f21409f)+最終残タスク=ROOM08 load-path静的readiness確認(15分級)
- 03:35-38 ★worker1 Gap1決着(136bb4b)+spec集約§0.5(b27c053)→Track A正式収束★。worker2も readiness=静的READY(2d3ed7b、欠落=emitのみ)で正式収束
- 03:36 worker3自己訂正: QUADMOVE guard未配線=control run無効→『principal-shift帰属』未検証格下げ(axis分解+framing事実+Option A前提は不変)。(b)rebuildに正しいon/off control同梱で一括決着へ
- 03:50 boss1: 配線dispatch設計案DRAFT作成(WIRING_DISPATCH_DESIGN_DRAFT.md — W1忠実bind/W2 0x4E対策/W3 guard C整合/W4 framing、PRESIDENT必須2点込み)。worker3結果待ちで上申
- 03:42 ★worker3一括決着→Track C正式収束(39ba554)★: cutscene liveness=PASS(condition3充足)、mechanism分離=principal-shift単独で草原framing可(quad inert説は撤回、最小実装=既存FieldScroll unfreeze+center scroll)、pin再確認=原盤ref未発見で次回送り、residual 3件登録、slot返却
- 03:56 ★boss1: 配線dispatch設計案をPRESIDENTへ上申★(W1忠実bind/W2 0x4E対策/W3 guard C整合/W4 framing最小fix、単一worker直列推奨)。GO待ち
- 全track正式収束。worker commit=全local保全(w1×4/w2×3/w3×4)、push=★HOLD(user専権、PRESIDENT代行不可)★
- 04:00 ★PRESIDENT GO(配線dispatch承認)★+補足4点: ①W3=a)縮退第一候補(b)撤去は全corpus証明必須) ②honest-mark 3点をland doc明記 ③run_awakening_centered.sh oracle訂正(現③水辺map=bug焼込み汚染→新4+1点: 台詞/26+page/★家切替+twna01復帰★/草原framing/化けcrash無) ④push=user専権HOLD
- 04:02-04 配線dispatchをworker3へ発行(単一直列、sp3)、着手ack受領。worker1/2待機
- 段取り: W単位commit+検証gate報告→全緑→user実視覚(完成claim凍結解除はuserのみ)
- 04:06 worker2へidleタスク発行(PRESIDENT提案): ★corpus全225 entry 0x4B出現scan★=W1 blast radius確定(回帰gate3の対象リスト)+『0x4B無しterminal entry』実在確認(W3 guard C縮退の傍証)。worker1=W1完了時spec照合review要員として温存待機
- 04:16 ★W1 land(8c4a946)★: emit実値spec完全一致(218/1/0x36+204/2/0xFF)、headless baseline同値。W2へ
- 04:26 ★W2 land(ede1a93)+W3 land(8fd4246)★: choiceBreak=False実証/guard-C縮退=意図明示+log分岐(元来warp非emit)。PRESIDENT承認
- 04:30-34 premise照合発生: worker1の新opcode map(0x18/0x19=表示op、0x0C=TABLE-JUMP)が既存live証拠(0x19=CheckFlag+flag実験)と衝突→3仮説(二層構造/4entry shift(0x8011b0e8 vs 0x8011b0f8)/worker1正)で機械決着中、relabel凍結
- 04:38 ★W4 land(397a477)→配線dispatch W1-W4完走★: 忠実遷移AI検証達成(草原center→ROOM08→twna01復帰、gate1-5充足、gate4部分=0x4F pan未配線scope外honest)。oracle 4+1訂正済+montage+62shot。slot返却。worker1 spec照合review発動(PRESIDENT指定interrupt)
- follow-up登録: 0x4F pan配線 / W1 gate撤去(0x19層決着+field検証後) / W4 residual 3件 / 0x4E live確認 / entry152 menu型0x4B完全列挙
- 04:44-48 dispatch表照合が機械決着: worker1自map全撤回(band dispatch 0x800F0780、実base 0x8011b0f8、flat仮定で+0x0Cズレ=boss1 shift説CONFIRMED)+worker2独立同一結論(二重独立=triple-grounding水準)。★0x18=TABLE-JUMP branch確定(PC書換0x800EC708直読)=walker desync真因★。worker2既存label+live証拠は全て無傷、relabel不要。trackB3 honest訂正commit 4e473b9
- 04:52 ★worker1 spec照合review=APPROVE(blocker無し)★: byte読取位置EXE完全一致/byte3を0固定=mis-wiring回避/guard-C排他成立/honest-mark正確/id空間end-to-end実証。spec側refinement(『remake二経路では文脈gate=整合補償』)をworker1が追記へ
- ★PRESIDENTへuser実視覚起動を依頼済★(run_awakening_centered.sh、新oracle 4+1)。完成claim凍結継続
- 04:54-05:00 build provenance確認(PRESIDENT捕捉): worker3が三重根拠(W4 symbol export/tip再build zero delta=idempotent/W3固有log文字列)でW1-W4入り確定+provenance更新(89d1429)。timestamp矛盾=build(04:06)→test→report(04:16)の正常因果順序。★user実視覚起動OK、PRESIDENTへ転送済★
- 04:58 worker1 0x19正map完成(remake OPLEN交差検証済): 0x14-0x19 control-flow確定、desync二大要因機械確定(0x18 inline table欠落/0x19可変長term chain)。worker2にwalker fix+corpus再scan発行(follow-up線、user gate非block)
- 05:04-08 follow-up線着地: worker1 Track A2収束(db10e1a+§0.5 refinement 0e059a5)=entry152 hand-decode(menu=0x19-gated 0x4B chain、12行先live一致)+★linear scan原理限界→branch-following tracer必須★。worker2 walker fix(63f9b70)=coverage79.6%(+8.1pt)/0x4B 156確認/gate結論robust/entry147=ROOM08第3 warp源/entry152原理的到達不能honest mark。tracer実装は次session送り(PRESIDENT承認)
- ★現況: 全worker正式収束+standby、user実視覚判定待ち(cutscene起動済)★
- commit総覧(全push HOLD=user専権): worker1×6(7204c6f/25ed350/136bb4b/b27c053/db10e1a/0e059a5)、worker2×6(d50829a/f21409f/2d3ed7b/959b0dc/4e473b9/63f9b70)、worker3×9(PoC 359d744/32e04c5/c710262/39ba554+W1-W4 8c4a946/ede1a93/8fd4246/397a477+shots 632c497+provenance 89d1429)

## 2026-07-09昼 user実視覚judgment
- 12:20 ★判定=ほぼPASS(user原文『ほぼ正解』)★: ①台詞可読②66page完走③家(room08)切替+街復帰=PASS④草原center開始=PASS⑤crash無。W1-W4本丸2点通過
- 残指摘1件(bounded): terminal warp後にcamera右上snap(scroll=0既定枠=水辺)。原因仮説=W4 scrollのscope=IsCutsceneActive中のみ(高確度、要コード裏取り)
- 12:22 worker3へ指摘対応dispatch発行: 仮説裏取り→post-cutscene framing継続(最小=着地center維持/可能なら原盤followモデル=player投影-半画面+境界clamp)、単一座標権威、headless非退行+live screenshot→user再目視(該当部分のみ)→凍結解除判断
- 完成claim凍結=この1件解消+user再確認まで継続
- 12:22-40 指摘対応完了(worker3、commit bb61b82): 裏取りで★真因=Follow Y-clamp(spawn2 playerPx.y=58→scroll.y=0=水辺)、PRESIDENT仮説(scope切れ)は反証、原盤follow式では未解決(式一致で同水辺)★→boss1判断=(a)bounded center-bias GO(Yのみcenter hold/X追従、単一座標権威維持)。検証=headless GREEN+live草原center(y=200)+★再snap 90frame歩行PASS★。tradeoff honest-mark=縦深部移動でplayer下方drift(根治=projection較正residual)。user再目視依頼済(観点3点+tradeoff正直提示)

## ★最終裁定(2026-07-09 12:50)= SESSION CLOSE★
- ★user再目視=PASS(『まぁ良いでしょう』、Y-hold tradeoff許容)→完成claim凍結解除 — faithful-178覚醒cutscene(家転換+framing+復帰)はuser目視で完成★
- 全worker解散(12:52)。handoff最終化=PRESIDENT側(boss1 draft base+bb61b82+最終裁定反映)。push判断+main反映=次session(user専権/裁定済chain)
- 総commit: worker1×6/worker2×6/worker3×13(PoC4+W1-W4 4+shots/provenance 2+postcut fix bb61b82他)、全local/push HOLD

## 次session follow-up registry
1. branch-following tracer実装(spec=trackA2 §3)→entry152 menu型0x4B完全列挙→W1 gate撤去可否の再評価
2. 0x4F camera pan配線(spec=trackA §0.5 B、pan(183,221)=ROOM08-local説のlive確認込み)
3. W1未忠実分: 20frame timer warp/fade var[6]/return-stack push(byte3)
4. W4 residual: backdrop coverage較正/X軸m02 dead(単独isolation未測定)/awakening pin(412,448)exact再確認(原盤ref要)
5. 0x4E live確認(transporter実操作=user session)
6. entry147→ROOM08 第3 warp源の文脈調査(低優先)
7. ★(2026-07-19 OI-3b, v4 blockerでない)★ ~~false-GREEN 重複 4 entry(33/64/71/108)の 0x66 個別 decode 再検証~~ → ★CLOSED(2026-07-19、worker1 自主進行)★: 4 entry 全ての 0x66 を section-accurate walk + 0x67/0x66 pair 検証 = ★全て REAL(`27 00 67 00 01 00 66 00` pair、census 22/32/97 と bit 同一)★。entry152 HANDOFF の false-GREEN 懸念(0x46/0x79 operand 誤読)は 0x66 occurrence には及ばない。備考: entry33/64/71 の key254(0xFE) section は同一 0x66 を二重計上(0x19 先行 path だが clean な key5/6 path が同 offset を独立確認=desync 無関係)=per-entry count に軽微 dup、entry-level 列挙(112)は不変。→ V4_REACH_PATH の enumeration de-risk 完了。
- 04:20 ★worker2 scan完了(959b0dc)★: 123箇所/69entry(coverage71.5%下限)、0x4B無しterminal=212/225(guard C縮退傍証確定)。★activation-class: CUTSCENE=178のみ/FIELD-MAP=67→W1 gateはmootでなくmaterial(無条件化=field navigation破壊risk)★。caveat=entry152 menu型0x4Bはsystematic未捕捉(0x19 pin後)。boss1推奨=gate維持を当面の設計正解として確定+faithful無条件化はfollow-up登録、worker1解除候補=0x19 handler REをPRESIDENTへ上申

## PRESIDENT からの判断点(承認済方針)
- Track A consumer semantic が map転換と断定できれば → 実装配線dispatch設計へ
- Track C diff=0 FAIL でも honest 報告を評価、代替機構再設計は報告後に PRESIDENT と協議

---

# 2026-07-25 自律RE session(boss1)— 次phase registry

前提: 本日session成果=VAB loader確定(0x80147358反証)/entity配列再同定(base 0x80145608, stride 0xC4, type@+0x00)/off-by-one=測定artifact確定/battle caller全景+HP addr静的確定(0x8016b0d0)。詳細=RUNTIME_SESSION_2026-07-25.md(訂正banner済)+VERIFY doc+track1/track2 worktree docs。

## 次phase dispatch候補(PRESIDENT裁定済の登録)
1. ★field-model配線 re-baseline★(PRESIDENT裁定 7/25: 本phase着手禁止、独立dispatch化):
   land済のEntityPlacer系を正base 0x80145608+type@+0x00直読へ再接地。旧2誤り(base誤り×off-by-one読み)相殺で現画はuser PASS済のため、★回帰検証設計込み★が着手条件(oracle=map自己同定20/20の新読み+user実視覚)。
2. savestate_ram.py修正(frame prefix 0x1A62補正)。棚卸し完了済(worker1 SAVESTATE_TOOL_IMPACT_AUDIT.md、ce5908b): 実害=0x80147358系のみで訂正済、主要anchor 12件はEXE-grounded確認。修正案=load_ram()がEXE署名でprefix実測(回帰確認=gp-0x6cd6/gp-0x6d90不変、印字gpが0x8014686E→0x80144E0Cに変わる点は明示)
2b. ★0x10000ずれ2例の原因特定+doc訂正(小、未断定)★: HANDOFF_scene_prog_2026-07-07のwatch 0x801593B6 vs grounded 0x801693B6 / evl_rel_analysisの0x8017B084・0x8017B0BC vs 0x8016B084・0x8016B0BC。lui符号拡張トラップ同型の転記/算出ミス疑い(事実のみ、原因未特定)
3. scale field書込み元RE(honest gap継続、runtime state帯+0x14/16/18/1C/1Eの静的writer未特定)
4. getDamagePoint確定(user 1-2分: 0x8016b0d0 Z2 write watch→書込みPC→file offset換算、PRESIDENTがuser帰還queueへ登録済)
5. (798,-1656)黄creature件 — ★optional/低優先へ降格(PRESIDENT裁定 7/25)★: shift仮説はcode二重閉包(load段writer 0x800bae54単一stream+表示段reader 0x800bb580単一経路)で決着済。残るのは「色不一致そのものの原因究明」(座標→個体の帰属/種→色の想定/別variant等、RE_field_entity_array_rebase §6参照)
6. SLPS_017.97素性調査(別build確定、来歴未特定。extracted/README_EXE_PROVENANCE.md参照。rename要否=user判断FYI済)
