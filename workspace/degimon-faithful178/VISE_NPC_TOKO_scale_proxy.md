# TOKO scale — 原盤proxy測定 (worker3, 2026-07-23)

## 目的
boss1 step4: k_TOKO=1.03×(原盤トコモンfrac/boy frac)/1.604。原盤トコモン単独可視frame未捕獲(savestate _1/_2=boy at tunnel/トコモン off-screen、_3/_7=別NPC/area、regtest=input injection不可)。
→ proxy=resume savestate(twna01 area)に黄baby Digimon+boy同frame隣接=same-camera scale比較。

## 測定 (probe_sresume.png、319x224、software renderer)
| 対象 | head_y | feet_y | height | frac(/224) |
|---|---|---|---|---|
| 黄baby Digimon(白腹/赤眼、種未同定) | 50 | 94 | 45px | 0.201 |
| boy(player) | 55 | 118 | 64px | 0.286 |

- ★boy frac=0.286 ≈ 原盤calibration 0.290★=boyは標準depth(cross-check OK)。
- ★depth交絡★: boy足元(y=118)がbaby足元(y=94)より24px低い=boyがカメラに近い(top-down view)=boy拡大。
- depth補正(size∝feet_y-horizon): horizon 0-40で depth-scale 1.26-1.44 → baby_corrected 56-65px → ★baby/boy=0.88-1.02(中心~0.92)★。
- raw(無補正)=0.70。

## 推論 (観測でなく推論=honest mark)
- IF トコモンが此baby同様にrender(両者baby-form、game normalize仮説) THEN k_TOKO=1.03×0.92/1.604≈**0.59**。
- =native(k=1.03、1.604x boy)でなく**downscale**を示唆→EntityPlacer uniform-native assumption破れ→2c per-species scale要。

## 未解決(assumption、authoritative RE要)
1. 黄baby種のnative TMD size不明→「downscaleされた」か「元々boy-sized native」か判別不能(前者ならトコモンも0.58、後者ならトコモン native 1.6x)。
2. トコモン固有挙動未確認(此bayとは別種)。
→ ★worker1 EXE per-species/display scale RE=authoritative★(pixel proxyのdepth/種交絡を超える上位source)。proxyは「downscale plausible、k_TOKO~0.58寄り」まで。

## 結論 — k_TOKO=HOLD (worker1 EXE per-species scale RE 合流待ち)
proxyは native(1.03)でなくdownscale(~0.58)を**弱く**支持。ただしcritical交絡(黄baby種のnative TMD size不明)により(A)(B)いずれも生存(H4開放)。EXE RE=authoritative裁定器。

### EXE RE合流での二択 (boss1 2026-07-23裁定)
| 結末 | EXE所見 | k_TOKO | 2c戦略 | proxyとの関係 |
|---|---|---|---|---|
| **(A) per-species** | EXEに種別display scale table発見 | table値(authoritative) | per-species路 | proxy downscale signalが弱く支持 |
| **(B) uniform native** | table無し=TMD nativeそのまま | 1.03据置(TOKO=native size、※下記訂正: 実測0.52x boy、当初1.6xは誤り) | uniform路 | proxy downscaleは黄baby種のnative小ささ由来でトコモン非適用の可能性=(B)も生存 |

- proxyのdownscale signal=**(A)を弱く支持するが(B)も否定できない**(黄baby種のnative size未測=判別不能)。
- ★worker1 EXE RE結果で(A)/(B)択一→k_TOKO確定→game-camera render(framing封印)→boss1直視→user視覚gate★。
- (B)確定時はk=1.03のTOKO(実測≈0.52x boy、※当初1.6xは誤り)をuser視覚で忠実性確認(=native据置の最終検証)。

**STATUS: EXE RE合流待ち。k確定後にrender準備。**

---

## ★裁定確定 (2026-07-23、worker1 EXE RE authoritative → boss1裁定)★
- ★結末=(B) uniform native★。worker1 EXE RE=per-species scale data不在(status struct / TMD scale全0 / converter raw=3系統一致)=uniform native scaleが忠実。
- ★k_TOKO=1.03★(BOYS同一global定数)。k=0.58(A)路は破棄。

### ★★重大訂正 (2026-07-23 02:03): 「TOKO=1.6x boy」は誤り→実測 TOKO≈0.52x boy★★
- 当初『TOKO native=1.604x boy』と報告(mesh-unit比178/111由来)=**誤り**。mesh-unit比をworld-size比として使用した無効な cross-model比較(『恒等式は証拠でない』)。且つ baby(トコモン)>boy は物理的に不合理、実renderのsmall creature視覚とも矛盾を見逃した(規律failure)。
- ★実測(BOYS+TOKO両k=1.03、同一game-camera)★:
  - Unity Renderer.bounds: **BOYS=3.55 / TOKO=1.84 → 0.518**。両FBX import設定同一(globalScale1/useFileScale1)ゆえ差=fbx内geometry=converter出力。
  - 視覚A/B(boy_toko_AB.png、同camera geometry・同crop)=**TOKO明確に約半分**。
  - 物理的sensible(トコモン=tiny baby<boy)。
  - uniform-native= relative size=model bounds比=0.52と整合(1.6xはbounds実測と不整合だった)。
- ★render toko_k103_native.png自体はfaithful scale(k=1.03)のまま=正しい★。誤りは私の数値characterization(1.6x)のみ。boss1 visual PASS(small white creature)は実はCORRECTな0.52xと整合。
### root-cause: 「BOYS=1.11 vs 3.55」計測器検証 (boss1 task1, 2026-07-23)
- ★「BOYS=1.11」は計測log群に存在しない=私の仮定値(111 mesh-unit×仮定0.01 import scale)。実測でない★。
- 全render logのBOYS boundsSizeはmodelScale比例で一貫実測(scale0.12→0.41 / 0.15→0.52 / 0.2→0.69 / 0.8→2.76 / 1.0→3.45 / 1.03→3.55 / 1.2→4.14)=★計測器(Renderer.bounds)にbug無し★。
- 誤りの機構=★実測TOKO(1.79)を仮定BOYS(1.11)と比較★(mixing measured with assumed)。両方実測=BOYS3.45/TOKO1.79=0.52。
- OUTLIER check: BOYS最大single-renderer=1.17 << 全体3.45=27部品がhead-toe組上げ(実体、inflation無し)。

### 単一frame視覚比 (boss1 task2)
- ★boy_toko_oneframe.png=BOYS+TOKO同一地平面・同depth・fov7.57(game projection、montageでない単一frame)★=TOKO耳先が boy腰〜胸=約半分、両足同一地平線。ratio(render bounds)=0.519。曖昧さゼロ。

### ★render pipeline混入audit=混入ゼロ確定 (boss1 task, 2026-07-23)★
- node hierarchy scale audit(HierAudit): BOYS 46 transforms / TOKO 152 transforms=★両model全node localScale=1、renderer lossyScale=[1.0,1.0]★。ScaleModelToTargetHeight/正規化/loader不使用(grep全確認)。
- ∴組上げ(BOYS3.45/TOKO1.79)は純translation(部品配置)由来=scale混入ゼロ。私のrenderはfaithfulに「FBX組上げ図体」を描画。
- per-part max: TOKO1.31 > BOYS1.17(TOKO部品大=worker1 mesh比と一致)だが★組上げ図体はBOYS高★=worker1 mesh比(頂点data)と私のassembled(図体)は別次元を測定、両立。mesh大≠render大(assembly次第)。

### ★原盤baby測定 — orig_ss9(村meat vendor: boy+TANEMON+Agumon同frame) (2026-07-23)★
| 対象 | 測定 | 注 |
|---|---|---|
| TANEMON(緑baby) | head~72-88/feet~110、boyの約0.5-0.85x | green-on-green seg困難+leaf含否で幅大 |
| boy | helmet~90/feet~120(Agumonにocclude) | ★occlude=不確実★ |
| Agumon(黄rookie) | ~0.63x boy | 参考 |
- ★H2(mesh×0.748: TANE=1.49x=boyより大)=決定的に否定★: 原盤TANEMONは視覚的に明確にboyより小(頭がboy mid-body)。mesh-proportional renderは誤り。
- H1(baby一定0.92x)=上側error内で両立。resume Koromon(0.92x clean)と併せ、★原盤babyは~0.7-0.9x boy(H1寄り、H2否定)★。
- ★未解決tension★: 私のremake fbx TOKO=0.52x(混入ゼロ確定)。原盤babyが~0.9xなら fbx TOKOは faithfulより小の疑い→clean原盤TOKO測定要(ss9はboy occlude+green segで幅大、決着せず)。

### ★裁定進展 (boss1 2026-07-23 04:50): H2死亡、H1(normalize)寄り★
- H2(mesh-proportional)=ss9で決定的否定。H1(全baby~一定normalize)寄り。
- ★含意(重要): 原盤がnormalize(全baby~0.9x boy)なら、fbx組上げ0.52xは faithfulより小→remakeはTOKOを~0.9xへscale up(=normalize)が忠実★=「vise生fbxが忠実」から「normalizeが忠実」へ反転。但し★原盤TOKO clean値(target height)確定が前提★。
- route A(承認): worker1が boyをTOKO[798,-1656]/YURA[-1372,-2991]隣接へ歩かせたsavestate作成→worker3 regtest dump+clean測定(非occlude/同depth)。
- 得たTOKO/YURA screen比→H1最終確定+fbx tension(0.52 vs~0.9=scale up要否)決着→2c=normalize path確定見込み。
- ★注意: TOKO方向は依然素で測る(先入観排除)。normalize確定なら k_TOKO再算出(1.03でなく~0.9x target heightから逆算)★。

### ★原盤_9(SLPS-01797_9=meat vendor村)測定 (2026-07-23、worker1同定frame)★
- _9 rendered frame=boy中央+緑TANEMON左+黄creature右。★白TOKO не可視★。
- worker1 RAM: player(-103,-1623)/slot2「TOKO」(798,-1656)=同Z(diff33)=同depth・X+901。
- ★測定(同depth、feet共有=depth補正最小)★:
  - ★slot2(黄creature)/boy = 0.80x★(boy46px[head74-feet120]/黄37px[head84-feet120]、clean)。
  - TANEMON(dialogue確定baby)≈0.9x(leaf-topmost)〜0.53(body、green-on-greenで幅)。視覚上明確にboy<。
- →★H2(TOKO1.20/TANE1.49=boyより大)決定的否定、H1(~0.8-0.9x)寄り確定★。
- ★★critical species disconnect★★: slot2(remake script10=白Tokomon想定、798,-1656)は原盤で★黄色Agumon様=白Tokomonでない★(位置一致=slot2実体は黄creature)。
  →worker1確認要: (a)_9 slot2=Tokomonか黄/partnerか (b)remake script10=Tokomon種assign正否 (c)白Tokomon可視frame有無。
- 含意: village baby~0.8-0.9x boy(H1)。remake fbx TOKO0.52x<此→scale up要。
- ★boss1 framing(2026-07-23 06:20): H1(normalize)は種横断で支持(村baby全0.8-0.9x)。Tokomon=In-Training段階ゆえ同段階anchor(Koromon0.92/TANEMON~0.9)でTokomon target~0.9x接地可=Tokomon特定frame無くてもH1確定でk算出可★。
- ★target~0.9x → k_TOKO=1.03×0.9/0.52≈1.78★(machinery test k=1.78で実測0.90x boy確認済=render既存 toko_k178_machinerytest.png)。
- ★但しk確定=worker1 species ID直読verdict後(premature k禁止)★: (a)slot2=partner確定なら0.80xは別data(H1支持不変) (b)同段階anchorでTokomon target確定→k algo。

### ★★測定pair訂正 (worker1 player direct-read, 2026-07-23 06:52)★★
- ★player boy=(-647,-3108)★(worker1 slot仮定破棄・direct-read)。旧player=(-103,-1623)は誤り(=ユラモン)。
- ★0.80x(boy vs 黄creature=タネモン798,-1656)は破棄★: 実boy Z=-3108 vs タネモン Z=-1656=ΔZ~1450=depth交絡=perspective非公平。旧「同depth」は誤player同定由来。
- 正pair=boy(-3108)+トコモン(-2991)=ΔZ117=同depth=perspective公平。だが★_9 frameにトコモン不在(白pixel2個=画面外)=_9で直接測定不可★。
- visual↔RAM照合問題: _9で boy隣接の黄creature(feet同y120=boy同depth・追従的)=partner(Agumon様)公算、RAM far-depthタネモン(Z-1656)と不整合。隣接可視creature↔RAM stationary NPC mapping未確立。
- ★必要=白トコモンがboy近傍同depth可視のframe(worker1同定/位置調整待ち)。無ければIn-Training anchor grounding(target~0.9x、k=1.78 render既存)継続★。

### ★species照合確定 (worker1 RAM +0x22 type直読, 2026-07-23)★
- 原盤twna01 authoritative: (-103,-1623)=ユラモン(baby_I) / (798,-1656)=タネモン(baby_II) / (-1372,-2991)=トコモン(白,baby_II) / (-839,2210)=空。
- ★私の0.80x測定対象(黄creature右)=タネモン(798,-1656)=baby_II=トコモン同tier★=X順照合一致(緑左=ユラモン/黄右=タネモン)。∴0.80xはトコモン同tier anchorとして直接有効。
- flag1(色): タネモン(798)実render=純黄(207,177,0)、canonical緑と乖離=worker1 type read二重確認推奨(oracle相互検証)。
- flag2(depth=validity核心): ★boy実Z未確定(worker1旧player-103,-1623は誤り=ユラモン)。0.80xはboy feet=タネモンfeet(y120)共有=同depth前提。boy実Zがタネモン(Z-1656)同域か要検証★。
- ★白トコモン=_9 frame画面外(白pixel2個)★=トコモン直接測定不可、In-Training anchor grounding継続。

### ★user提示package用 honest gap (boss1 2026-07-23 06:28、先出し記録)★
- ★Tokomon自体は原盤で直接測定していない★。target~0.9xは In-Training同段階anchor(Koromon0.92 / TANEMON~0.9)からのnormalize推論。
- 妥当性根拠=H1(種横断normalize)がKoromon/TANEMON/slot2の複数種一致で確証、Tokomon=同In-Training段階ゆえ同target帯に接地。
- 但し『Tokomon特定frame実測でなく同段階grounding』は★honest markとしてuser提示に必ず含める★=過去のsize誤同定(1.6x→0.52x)の轍を踏まぬ透明性。
- 完全確証には白Tokomon特定frameの原盤実測が要(worker1探索中、無ければ同段階groundingで確定)。

### ★★3-way honest record — faithfulness=未決着(0.52を確定と書かない)★★
| 値 | source | 信頼性 |
|---|---|---|
| **fbx 0.52** | vise BOYS/TOKO.fbx 組上げworld bounds(3.45/1.79)+単一frame視覚 | ★measured、robust。但し「remakeが何をrenderするか」であって「原盤忠実」ではない★ |
| ~~TMD 1.6~~ | 私のmesh-unit bbox(178/111) | ★discredited: 組上げbounds(0.52)と不整合、provenance=私の計測(独立TMD authorityでない)。likely誤り★ |
| 原盤 Koromon proxy 0.92 | resume savestate黄baby(別種)vs boy、depth補正 | 原盤anchorだが★別種+depth交絡★=Tokomon直接でない |
- ★原盤Tokomon特定のboy-vs-Tokomon比=依然未測定★(savestateに単独可視frame無し、regtest input不可)。faithful比を決めるのは此のみ。
- ∴remakeは現状TOKO≈0.52x boyをrender(models robust)。**原盤忠実性=未検証**。
- ★authoritative cross-check提案: worker1がraw TMD model寸法(BOYS vs TOKO native)を直読→TOKO>BOYS(1.6方向)かTOKO<BOYS(0.52方向)か=converter歪みの有無を独立判定★。EXE scale RE(uniform native)は既済ゆえ、raw TMD寸法の追加読取で fbx-vs-TMD を割れる。
- ★proxy(downscale~0.58)との関係★: 黄baby(別種)=自種native~0.92x boy / トコモン=自種native~0.52x boy=別種は別native。proxyの弱限定(「弱く支持」、over-claimせず)が正しかった=cross-species native等価の誤仮定を断定しなかったのが効いた。注: 訂正後、トコモン0.52x < 黄baby0.92xゆえproxyのbaseline自体トコモンには非適用(別種)。
- global scale懸念解消: k=1.03は原盤boy on-screen sizeにfit=global field scale吸収済。同一render path/native幾何のNPCも同k=1.03で正しいon-screen size(player=user確認済ゆえNPC従属)。

### ground-offset de-risk実測 (feetY/groundOffset log、boss1 pivot懸念)
| k | boundsSize(h) | feetY(world) | groundOffset | 判定 |
|---|---|---|---|---|
| 0.58 | 1.04 | -0.016 | -0.016 | 接地(破棄路) |
| 1.0 | 1.79 | -0.027 | -0.027 | 接地 |
| 1.03 | 1.84 | -0.028 | -0.028 | ★接地(model高の1.5%=無視可)★ |
- ★TOKO pivot非対称(y-150~28)だが実render feet offset=極小(-0.028、model 1.84uの1.5%)+k比例=pivotは実質feet-align→scaleでfeet浮き/沈み無し。ground補正不要★。視覚もgrass接地確認(toko_k103_native.png)。

**STATUS (2026-07-23更新): H2死亡/H1(normalize)寄り。fbx組上げ=TOKO0.52x boy(混入ゼロ確定=faithfulに図体描画)。normalize確定なら原盤target(~0.9x?)へscale up要。**
- ★測定待ち: worker1が既存savestate静的解析でclean village frame(boy+TOKO/YURA非occlude同depth)同定中→worker3 dump+測定→target確定★。
- ★render machinery=prep完了: helper render_toko_k.sh、公式 k_TOKO=1.03×(target_TOKO/boy)/0.52、高k検証OK(k=1.78→0.90x boy、feet接地、k範囲0.58-1.78動作)。target確定→k算出→即render★。
- ★k値=測定後確定(0.52もfbx比であり原盤忠実確定でない、素で測定)★。
- 残polish=NPC facing(背面向き、scope外)。

### 2b用log: partner視覚観測 (2026-07-23)
- _9 frameで boy隣接の黄creature(pure yellow 207,177,0)=feet同y120=boy同depth+追従的配置=★partner(Agumon様rookie)の挙動★。
- RAM far-depthタネモン(Z-1656、ΔZ~1450)とは不整合ゆえ、隣接黄=stationary NPCでなくplayer-attached partner公算。
- →2b(Partner特化)で: partnerはEntityPlacer NPCでなく player-attached companion機構の可能性=2b調査の起点data。

### ★★原盤直接Tokomon anchor (user撮影, 2026-07-23) — honest gap閉じる★★
- user自身がDuckStation覚醒scene撮影(path C proactive)=remake完全同一scene(『む…気がついたか』ジジモン)。/home/ken/Pictures/Screenshots/Screenshot from 2026-07-23 04-03-23.png(958x1050表示、native320x240)。
- ★直接測定(display px、ratio=scale不変)★:
  - 白Tokomon: 耳含112px / body-only 84px(feet462)。★耳=bodyに+33%(耳ambiguity原盤解決)★。
  - ジジモン立位133px(feet458≈Tokomon462=同depth fair比)→ ★Tokomon耳/ジジ=0.84 / body/ジジ=0.63★。
  - boy(大の字伏せ)140px=foreshorten+feet685(closer depth)交絡=信頼低、立位frame待ち。pink/orange baby=横臥/curled=height ref不適。
- ★予備裁定★: IF ジジモン≈boy THEN Tokomon耳/boy≈0.84・body≈0.63。remake k=1.55(0.92 body)は原盤よりやや大の可能性。耳含k≈1.42/body基準~1.0。ジジモン(猫背)<boy立位なら更小。
- ★確定要: user立位boy frame(予定)でTokomon/boy直接 + 耳含vs body どちらがuser知覚か。背景cross-check(task5)も。★
- STATUS: honest gap(トコモン直接未測定)=CLOSED(直接anchor入手)。k=1.55の最終微調整=立位frame待ち。

### ★boy scale bug + tunnel artifact診断 (2026-07-23、worker1 git考古学連動)★
- ★worker1確定: phase1結論=native k=1.03、but出荷code=ViseAvatarController.modelScale 0.2(debunk値未反映)=boy 5x under-scale BUG★。k=1.03が正値(誤引用でなくcode未反映)。gap真因=boy小さすぎ確定。
- ★私の全boy render=DEGIMON_VISE_SCALE=1.03 override(bounds3.55)=faithful基準★。∴TOKO/boy比0.67は正しいboy(1.03)基準でrobust。出荷code 0.2は私のrender外。
- 原盤boy px(worker1逆算用): orig_ss1(care HUD twna01)=boy≈63px native(frac0.281≈0.290、feet113)。
  - ★★#457-C 訂正(worker3): この行は ★帰属が 逆★★★ — 原典 `VISE_AVATAR_scale_measurement.md:32` = ★**原盤_1 frac = 0.290** / **remake game-cam(k=1) frac = 0.281**★。
    ★算術で 決着★: `k = 0.290/0.281 = 1.032` ≈ 1.03。逆に取ると `0.281/0.290 = 0.969` で ★1.03 に ならない★。
    ⇒ ★結論(k=1.03)は 無傷 / ★どちらが 原盤かの ラベルだけ 逆★★（★逆のまま 3 段を 通っていました★）。
- ★『tunnel過大』=framing artifact確定★: [FIELD] backdrop値完全faithful(size60.6,50.5/depth143.1/factor2.40,2.67/worldPerPx0.0789=worker1一致)+camera faithful(fov7.57/eye0,86,-119/pitch37°)。remake tunnel大=scroll/moment差(覚醒spawn近接view vs 原盤wide view)、backdrop scale bugでない。私の早合点訂正。
- ★fix path: code boy 0.2→1.03(5x)、TOKO=0.67x boy維持(=1.13)→再render→boss1直視→user視覚gate(全体proportion)★。
- STATUS: TOKO scale=0.67x boy比CLOSE(robust)。boy絶対fix(0.2→1.03)+TOKO絶対再算出=worker1 grounding+code fix待ち。

### ★boy scale bug FIX適用 (2026-07-23、boss1 GO)★
- ★ViseAvatarController.modelScale 0.2f→1.03f(default)★=phase1結論値の反映、debunk値0.2除去。comment更新(『5倍過大/0.2』debunk理由除去、faithful根拠[calibration0.281≈0.290+worker1逆算]明記)。
- 0.2他consumer=無し(ViseAvatarSetup:69の0.2f=RenderPose t引数=anim time、無関係)。rebuild OK、env無しでboy bounds3.55=default 1.03 faithful確認。
- TOKO=1.13維持(0.67x boy1.03、robust比)。
- matched-scroll verification blocker: remake覚醒harnessがfree-roam(orig_ss1状態)未到達=boy spawn下端でboy+tunnel同frame撮れず。代替=component-faithful analytical(backdrop+camera+boy全faithful→proportion自動faithful)。方針=boss1裁定待ち。
- STATUS: boy fix LAND(default 1.03)。TOKO=0.67x boy(=1.13)。matched-scroll視覚検証 or analytical=boss1裁定待ち。

### ★boy/tunnel empirical検証 (2026-07-23、PRESIDENT裁定=observationをinferenceで潰すな)★
- 反省: 私はcomponent-faithful論理でuser observed『tunnel過大』を潰そうとした=phase1教訓の逆。実測で検証。
- FORCE_SCROLL=backdrop quadのみ移動→boy(3D)とdesync=boy/tunnel比に無効判明。→DEGIMON_VISE_BOY_OFFSET追加(BOYS可視位置配置、faithful camera・FORCE_SCROLL無し)でboy+tunnel同frame撮影(boytunnel_offset.png=boy1.03 substantial figure)。
- boy/tunnel pixel比=★inconclusive★: dialogue box=boy feet遮蔽(boy外挿) / 原盤=boyがtunnel緑ring遮蔽(ring under-measure)。remake~1.05/原盤~0.79だが0.75-1.05に振れ決着せず(matched-scroll clean=crate occlusion+dialogue+desyncでinfra block)。
- ★最強empirical(実測): [FIELD] backdrop値=worker1原盤RE完全一致(60.6,50.5/143.1/2.40,2.67/0.0789)=tunnel世界size faithful実測★+boy bug実測(0.2=5x under)。∴『tunnel過大』機構=boy 5x過小ゆえtunnel相対過大に見えた、tunnel自体faithful。userのobservationは正しく真因=boy過小(→1.03 fix)。
- STATUS: boy fix(0.2→1.03)+backdrop実測faithfulがuser観測を機構説明・解決。fully-decisive boy/tunnelはworker1 scroll data or user post-fix screenshot要。

### ★★decisive empirical: boy fix忠実 実測確認 (2026-07-23、PRESIDENT裁定=observed潰すな)★★
- ★field-RT capture infra追加(DEGIMON_VISE_FIELD_RT_SHOT=Camera.main→RenderTexture=OnGUI textbox除外、camera改変なし)★=boy occlusion根治(外挿→実測)。
- ★clean boy px測定(boytunnel_RT_notextbox.png、boy isolated on grass、feet実測)★: remake boy(1.03)=depth133で49px native-equiv → depth補正(133→122)=53.6px。
- ★照合: worker1原盤予測native51px(depth122)→faithful(×1.03)=52.5px。remake 53.6 ≈ 52.5 = ~2%一致★=fix(0.2→1.03)がboy on-screen sizeを原盤忠実再現、empirical確認。
- ∴機構確定(実測): tunnel=backdrop faithful(1:1) + boy=fix後原盤px一致。★user『tunnel過大』observationは正しく真因=boy 5x過小、boy fix(1.03)で解決を実測裏付け★。observedをinferenceで潰さず実測決着。
- honest残: ~2%+depth補正(1/depth近似)+worker1予測照合(_9 boy occlusionでraw原盤px直測困難)。
- ★arc総括: TOKO scale=0.67x boy比CLOSE + boy modelScale 0.2→1.03 fix(5x under bug)LAND + tunnel過大=boy過小が真因(実測decisive)★。

### ★user提示render完成 (2026-07-23、wide before/after)★
- ★user_package_wide_before_after.png★: BEFORE(boy modelScale0.2=5x過小=tiny/ほぼ不可視=userが見た通り) / AFTER(1.03 faithful=proper-sized、tunnel不変=faithful、proportion正)。
- ★wide framing(DEGIMON_VISE_FIELD_RT_BACK=100=camera同fov後退・比保持・game camera不改変temp複製)★=close-camera tunnel拡大回避=orig_ss1相当wide view=userの『まだtunnel大』誤解防止。
- 趣旨(observation尊重): BEFORE=userのtunnel過大観測は正しい(boy 5x過小)→AFTER=boy fix解決、tunnel自体faithful不変。実測decisive(remake boy px≈原盤~2%)添付。
- infra: field-RT(OnGUI textbox除外)+temp wide camera=clean非遮蔽+wide、camera不改変。
- ★arc最終総括: (1)TOKO scale=0.67x boy比CLOSE (2)boy modelScale 0.2→1.03 fix(5x under bug、これが全体小さすぎ主因)LAND (3)tunnel過大=boy過小が真因(実測decisive、observedをinferenceで潰さず) (4)user提示=wide before/after。全measure-first接地★。
