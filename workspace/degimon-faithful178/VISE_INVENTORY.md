# VISE 先行資産 inventory(boss1 survey、2026-07-22 着手)

**目的**: 前身project /home/ken/Desktop/vise/ の体系的棚卸し=remakeが再導出した重複の可視化+継承可能な高価値資産(特に3Dキャラ)の同定。read-only survey、remake tree非改変、prior-art原則をvise自体に適用。
**status**: scope 1(全体inventory)=boss1実測済。scope 2(重複map)=worker1 in-flight。scope 3(3Dキャラ精査)=worker3 in-flight。scope 4(素性)=各scope内。

---

## scope 1: 全体inventory(boss1実測、du -sh + ls 一次確認)

| dir | size | 内容(実測) | 継承価値 |
|---|---|---|---|
| **unity_remake/** | 7.1G | ★vise独自のUnity remake★。Assets/Models/{Characters,Digimon,Digimon_gltf_backup,Environment,Effects}, Assets/Animations/Digimon/(356 dir)。IMPLEMENTATION_STATUS/PROGRESS_REPORT/SYSTEM_STATUS doc, dg_scn_parser.py, map_connections.csv | ★★★最高(3Dキャラ本体) |
| **extracted/** | 1.5G | game asset抽出(bgm_wav含む、EXE/DG.SCN/MAPHEAD/overlay/モデル等=要scope2突合) | ★★高 |
| **DW1ModelConverter/** | 921M | ★C++変換器(TMD→glTF、texture+animation付)★。README/LICENSE/THIRD-PARTY(外部OSS tool)。src/build/output。US/JP対応 | ★★★最高(手法) |
| **cd_extracted/** | 317M | CD ISO生抽出 | ★中(raw source) |
| data/ | 3.0M | (要精査) | 要確認 |
| workspace/ | 2.7M | vise作業doc | ★中(手法doc) |
| reports/ | 2.5M | vise解析reports | ★中 |
| docs/ | 1.8M | vise doc群 | ★★高(RE知見) |
| tools/ tmp/ logs/ scripts/ viewer/ assets/ venv/ | <1M各 | tool/一時/log/script/viewer/venv | 中〜低 |

### scope 1 の重要発見(3Dキャラ=user最優先)
- ★DW1ModelConverter=game TMD modelを直接読みglTF(texture+animation付)へ変換する外部OSS tool★。=game-derived=素性良(bgm_wavの『外部source素性不明』とは別格、TMD直読で忠実)。
- ★vise unity_remakeに実成果: Digimon 3D model 503本(gltf/glb)+animation 356 dir(AGUM/AIRD/AKAT…=Digimon個体別)★。
- ∴remakeの現avatar=白Capsule placeholder(描画体ゼロ、sprite-exactは『field-char RE後』先送り)の穴を、★viseの既変換3Dモデル+animationで継承できる可能性=再導出不要★=user評価『viseは動き/animationは再現できていた』の実体はDW1ModelConverter由来と判明(scope3で継承手順を精査)。
- 素性caveat: converter READMEに『TMD一部property→glTF extras、animation未命名、translucency/tex-anim caveat』=完全忠実でない部分の明示あり=継承時に確認要。

---

## scope 2: 重複map(worker1、2026-07-22 初期突合)

vise-has vs remake再導出の突合。★『重複』は深度で3段階(完全重複/構造重複+remake拡張/非重複)に分類★。

| # | 項目 | vise-has(実測) | remake再導出 | 重複判定 | 教訓 |
|---|---|---|---|---|---|
| a | **DG.SCN parser** | ★dg_scn_parser.py(690行)★=offset table(225×u32)/OPCODE_TABLE(opcode→size)/SJIS検出/framing{0x27,0x66,0x67} | DialogueRuntime.cs(band dispatch 0x800F0780/oplen Len[256]/SJIS decode) | ★構造重複+remake拡張★ | vise=parser構造完備。remakeは0x66=SCENE_DRIVER/0x67=FRAME_YIELD/variant/audio semanticsまで深化(vise=『Unknown、skip』)。★parser基盤は再導出不要だった、semantic層のみ新規★ |
| b | **EXE/overlay disasm** | btl_symbols.md/std_symbols.md(★元ソースsymbol名: s_battle.c/s_p_cmd.c等の関数名★)+overlay_analysis.md×11(btl/vs/eab/fish/endi/dget/doo2/dooa/evl/murd/shop) | mdis.py/xref.py 手disasm(crash arc=btl_rel+0x99D4/0x800c9cbc等) | ★部分重複★ | ★vise=symbol名(orient用、但しaddress未mapping)。remake crash-path(0x99/0x800c9)=vise btl_rel_analysis★未カバー=crash RE genuinely新規★。symbol名は参照すれば手RE時のorientに有効だった(function命名の手間削減) |
| c | **warp/scene topology** | map_connections.csv(196接続/170 map/全て双方向↔)+warp docs×4+tmp/*.MAP | ★remake独自: map_connections_complete.json(442edge+全197map raw scan)+warp topology RE(twna01一方通行/3-sink列挙)★ | ★★非重複=remake独自導出が正当(vise warp低信頼)★★ | ★★2026-07-22 user domain知識で訂正: vise warp接続表(196)は★かなり低信頼(バグ領域)★=忠実anchr昇格禁止・★相互検証にも使わない★。∴remakeの独自warp導出(mayo00→twna01一方通行等、map_connections_complete 442edge+全197map raw scan、vise非依存)は『無駄な再導出』でなく★必要かつ正当な独立作業★=旧判定(重複/再導出回避可)を撤回。viseの全↔表記も低信頼の一例(物理隣接ですらない疑い)★★ |
| d | **BGM/sound** | sound_format_analysis.md(FAALL構造=10 program、VHB→VAB sample、bank用途推測) | scene audio arc(FAALL record#33構造/SEQ offset table/pQES parse/driver tick/crash/tempo) | ★浅い重複、remake大幅深化★ | vise=format概観のみ(VHB→VAG sample抽出=psx_vhb_to_wav)。remakeのSEQ render/driver/crash/tempo=ほぼ新規。★format基盤(FAALL=10 program)は既知だった★ |
| e | **モデル** | ★DW1ModelConverter(TMD→glTF)+unity_remake 503 model+anim356 dir★ | 白Capsule placeholder(未着手=先送り) | ★非重複(vise排他)★ | remakeが持たない資産。継承候補(scope3) |
| f | game asset抽出 | extracted/(DG.SCN/MAPHEAD.SCN/slps_017_97.bin/overlay全=★1998 timestamp★) | 同一game file抽出 | ★同一source(重複でない)★ | 両者とも同一CD由来=素性identical。再導出でなく共有source |

### scope2 核心教訓(無駄削減)
★remakeが再導出したが vise に既存だった=(a)DG.SCN parser構造 / (d)FAALL format基盤 / (b)btl_rel symbol名(orient)★。
★★(c)warp接続表は撤回(2026-07-22 user訂正): vise warp=低信頼(バグ領域)ゆえremake独自導出が正当。『vise既存で回避可』の対象外★★。

### ★★領域別 信頼度の一般化(2026-07-22 user domain知識、規範化)★★
viseは領域で強弱がある: ★強い=3Dキャラ資産/ツール(DW1ModelConverter)/基本抽出(EXE/DG.SCN byte直抽出)★ / ★要警戒=ゲーム進行系(warp/topology、flag/分岐等の疑い)=バグ多い★。
→継承候補は★領域ごとに素性/信頼度を判定★。低信頼領域(進行系)はvise非依存のremake独自を権威とし、vise版は相互検証にも使わない。継承価値高=3Dキャラ資産(phase1実証済)。warp以外の進行系(flag/分岐)の低信頼有無=user確認中、判明次第tier一括更新。
但し★remakeの深化部分(0x66 scene driver/variant/audio semantic、SEQ driver/crash/tempo、twna01一方通行機構、crash-path btl_rel)は genuinely新規=vise未到達★。=『parser/topology/formatの基盤層は先に vise を読めば再導出回避できた。semantic/mechanism深掘りは remake独自の価値』。
→ ★今後の規範: 新RE着手前に vise/docs/ + vise tools/ の該当項目を先読み(prior-art check)★。特にsymbol名(btl_symbols/std_symbols)は手RE前のorientに有効。

## scope 4: 素性確認(worker1、2026-07-22)

★素性未確認資産を忠実anchorに昇格させない規範をvise自体に適用★。3 tier分類:

| tier | asset | 素性判定 | 根拠 |
|---|---|---|---|
| ★高(game直抽出)★ | extracted/{DG.SCN, MAPHEAD.SCN, slps_017_97.bin, SLPS_017.97, *_rel.bin} | ★素性良=直接game抽出=byte同一確定★ | ★sha256実測 vise=remake一致: DG.SCN(4d776b2c)/slps_017_97.bin(db26754d)/btl_rel.bin(fafd9bd2)+boss1裏取りSLPS_017.97(1779a08d)★。1998-12 timestamp。忠実anchor可 |
| 高(game直読) | DW1ModelConverter出力(TMD→glTF 503 model) | 素性良=TMD直読(game-derived) | converter=TMD binary直変換。但しREADME caveat(animation未命名/translucency/tex-anim)=完全忠実でない部分明示、継承時確認要 |
| ★中-高(byte-exact検証済)★ | 突き合わせ系doc(突き合わせ_B_battle/原盤突き合わせレポート等) | ★systematic検証済(byte-exact assert)★ | ✅一致assert多数(属性相性8×8 byte-exact/技param 64一致等)。★EXE base t_addr=0x80090800をPS-EXE header直読で確定=remake mdis.py base と一致=検証済shared fact★ |
| ★中(要検証)★ | overlay_analysis×11 / sound_format | ★検証済/推測の混在=要spot-check★ | vise独自解析。overlay base table=推定+精緻化混在(btl_rel=0x80010000推定→0x80056C68精緻化)。引用前にremake実測と突合 |
| ★★低(進行系=バグ領域、anchr禁止)★★ | ★warp接続表/warp docs★ | ★★低信頼=忠実anchr不可・相互検証にも使わない(2026-07-22 user訂正)★★ | vise warp=かなり低信頼(バグ領域、user domain知識)。remake独自warp(map_connections_complete 442edge)が権威。vise版は参照時『低信頼・進行系』明示、判断根拠にしない |
| ★中-低(orient only)★ | btl_symbols.md / std_symbols.md | ★★住所無し=address突合不可★★ | ★vise明言(突き合わせ_B_battle line65): 『btl_relに住所付きsymbol table無し、symbolは住所無しのtext call-tree log のみ』★。=元ソース関数名(s_battle.c等、source file別group)は分るがaddress未対応。cited『getDamagePoint 0x800141C8』=heuristic命名+誤base(0x80010000)。∴資産価値=source構造orient(関数名/moduleの把握)のみ、address lookupには手動相関要=ready as(asset)でない |
| ★低(素性不明)★ | ★extracted/bgm_wav/(74 named song)★ | ★外部source、忠実anchor不可★ | FFmpeg encoder tag(Lavf62.3.100)/git未追跡/provenance doc無し/psx_vhb_to_wav(vise自身のtool)はVAG sample出力で named songを生成しない=外部投入。前arc照合で判明。★曲名label(『Normal Battle』等)も外部命名ゆえ根拠にしない★ |

### scope4 規範(anchor昇格gate)
- ★tier高(1998 timestamp game直抽出)のみ無条件忠実anchor★。tier中(vise RE doc)=remake実測との突合後に採用。tier低(bgm_wav)=anchor不可、参照時は『外部source・素性不明』明示必須。
- 前arc実例: v1 tempo裁定で bgm_wav を『frame-exact vise抽出』と誤認しかけたが、素性確認(FFmpeg/git未追跡)で外部source判明→anchor降格。この規範をvise全asset に予防適用。

## scope 3: 3Dキャラ資産精査(worker3、2026-07-22 実測 read-only)

### 3-1. DW1ModelConverter 変換手法(素性=良、game直読)
- C++/CMake、`DW1ModelConverter <ISO展開path>` で全Digimon modelを output/ へ抽出。US/JP(1.1)/JP(BonBon)検証済。
- pipeline: ★TMD(PSX native model)→glTF、texture(TIM/CLUTMap)+ skeleton(Model.hpp NodeEntry/loadNodes、GLTF.hpp buildSkeletonScene)+ keyframe animation(Animation.hpp: KeyframeInstruction/LoopStart/LoopEnd/PlaySound)★。=完全rig付skeletal animation。
- ★実測(BOYS.gltf)★: "skins"/"joints"/"nodes"/"animations" 全有=rig+skeleton+anim内包。★extras 40箇所=忠実度caveat dataは破棄でなくextrasに保持★。
- 忠実度caveat(README、glTF非native→extras退避): ①animation endless-loop start time ②animation sound-effects ③texture animations(瞬き等) ④TMD translucency blend modes。加えて★raw converterはanimation未命名★。
  - 実影響: glTF importerは①-④を自動適用しない=再生層が extras を読んで実装しないと『loop点/SE/瞬き/半透明』が欠ける。但し骨/mesh/tex/keyframeの本体は忠実。
- ★LICENSE=MIT(SydMontague 2023)★=tool自体は継承・改変自由(model IPは原盤=remakeプロジェクト全体と同じ前提)。

### 3-2. vise unity_remake の実装(converter出力を Unity化済=付加価値有)
- Assets/Models/Digimon: ★.glb 177 + .fbx 178★(NPC variant込)+ per-model _tex png/_textures。BOYS(player)含む。(★数値訂正 2026-07-22: 当初 .fbx 356/.anim 9690/BOYS 78 は macOS AppleDouble `._*` の二重計上=`find`が`._x.anim`も`*.anim`に一致。実数は`._`除外で半減。結論=full set継承は不変★)
- Assets/Animations/Digimon: ★178 dir / .anim 総4845本(実clip、`._`除外)★。★命名は部分的★=共通action(AGUM_Attack1/Angry/Idle/Run…)は命名済だが残りは anim-18/20/21… の未命名(raw converterのunnamedを一部のみ解決)。★BOYS=39 clips(Idle/Run/Walk/Attack1-4/Damage/Eat/Guard/Happy/Sad/Sleep/Special/BattleIntro/Angry + anim-18〜39未命名)=player avatar完備★。
- 配線: Assets/Scripts/AssetPipeline/AnimatorSetupGenerator.cs(Player/Partner/NPC controller、speed param正規化)。IMPLEMENTATION_STATUS=animator速度100%等、稼働system。
- ∴viseは『raw converter出力』でなく『Unity import + 命名 + animator配線まで済んだ完成品』=再利用時この付加価値(命名/animator/fbx化)も継承可。

### 3-3. remake現avatar実装との接続点
- remake unity(degimon_world_remake/unity): Assets={Resources,Scenes,Scripts,StreamingAssets}。★3Dモデル/anim資産=ゼロ(.anim 0本、fbx/glb/gltf無)=白capsule placeholder確定★。
- player=Transform駆動(PlayerController.cs=位置/移動、PlayerPlacement.cs=canonical spawn配置)。visual body=script生成でなくscene/prefab側の最小placeholder。
- ★決定的接続点: remake は `com.unity.cloud.gltfast 6.16.0` 既導入=glTF直import可能★。→player Transform子に BOYS(glTF/glb/fbx)をinstantiate + Animator(BOYS_* clips)配線 で placeholder差替が最短路。

### 3-4. 継承可能性=単一推奨
★推奨(a): vise unity_remake の変換済asset(.glb/.fbx + 命名済.anim + AnimatorSetupGenerator手法)を直接継承★。
- 理由: ①素性=良(DW1ModelConverter=TMD game直読) ②MIT=継承自由 ③Unity-ready+命名+animator配線=vise付加価値込 ④BOYS 78 clips=placeholder即差替 ⑤remake glTFast既導入=接続容易。
- 対 (b)converterをremakeで再実行: raw glTF(未命名/animator無)しか出ず=vise付加価値を捨てる+再導出コスト=劣る。(c)一部のみ=player優先なら合理だが資産は全揃いゆえ全継承が効率。
- ★忠実度honest gap(継承時のremake側TODO)★: extras①-④(loop点/SE/tex-anim/translucency)はimporterが自動適用しない=完全忠実には remake再生層で extras読取実装が要る(anim本体は忠実、これは polish層)。
- 未検証(次段): vise .glb/.fbx が extras を保持したままUnity import されているか(fbxはextras欠落riskあり=glb/gltf経路推奨)、remake側animator互換(rig骨名一致)。asset実import試験は本survey外(read-only厳守)。

## scope 4: 素性確認(各scope内)
主要asset来歴: モデル=DW1ModelConverter(TMD直読=game-derived、素性良) / bgm_wav=外部source(FFmpeg tag、素性不明=先の照合で判明) / RE doc=vise独自解析(要突合)。素性未確認資産を忠実anchorに昇格させない。

---

## 再利用推奨(単一推奨形式、scope2-3完了後に確定)
暫定: ★3Dキャラ継承(DW1ModelConverter出力 or 手法)をremake avatar穴埋めの第一候補★=user最優先+素性良+再導出コスト回避。詳細priorityはworker報告合流後。
