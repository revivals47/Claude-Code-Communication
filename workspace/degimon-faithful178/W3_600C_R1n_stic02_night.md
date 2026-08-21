Processor: Intel(R) Core(TM) i7-4790 CPU @ 3.60GHz, 8 core(s) @ 3889 MHz 
Available Memory: 32034 MB 
Linux Kernel and distribution: Linux 6.11 Ubuntu 24.04 64bit
System Language: ja_JP
Keyboard Layout: jp
Selected window backend: x11 
Mono path[0] = '/home/ken/Desktop/Digimon/w3_588c/DegimonLive/DegimonLive_Data/Managed'
Mono config path = '/home/ken/Desktop/Digimon/w3_588c/DegimonLive/DegimonLive_Data/MonoBleedingEdge/etc'
CodeReloadManager initialized
Input System module state changed to: Initialized.
[Physics::Module] Initialized fallback backend.
[Physics::Module] Id: 0xdecafbad
Initialize engine version: 6000.4.11f1 (b0a1d6caadd2)
[Subsystems] Discovering subsystems at path /home/ken/Desktop/Digimon/w3_588c/DegimonLive/DegimonLive_Data/UnitySubsystems
Forcing GfxDevice: Null
GfxDevice: creating device client; kGfxThreadingModeNonThreaded
NullGfxDevice:
    Version:  NULL 1.0 [1.0]
    Renderer: Null Device
    Vendor:   Unity Technologies
Begin MonoManager ReloadAssembly
- Finished resetting the current domain, in  0.003 seconds
[Physics::Module] Selected backend.
[Physics::Module] Name: PhysX
[Physics::Module] Id: 0xf2b8ea05
[Physics::Module] SDK Version: 4.1.2
[Physics::Module] Integration Version: 1.0.0
[Physics::Module] Threading Mode: Multi-Threaded
UnloadTime: 0.352292 ms
[BOOT] AUTOBOOT=1 — headless live-boot verification (Title/NameInput auto-advance)
[RUNBY] who=(unset) build='/home/ken/Desktop/Digimon/w3_588c/DegimonLive' / TILE_5179=ON / MAP_LOADER=ON / WARP_EMIT=★決定は DialogueRuntime の instance gate ゆえ ここからは 読めません★
[MapRegistry] ★name 重複 YAKA25: id=65 と id=232★ — id=232 を name 引きの解決先にする(id 引きなら両方に到達可)。gating/placement は name でなく MapIndex で引くこと
[MapRegistry] loaded 244 entries (242 shipped) from 'registry/maps.json'
[BOOT] services ready: Session, DataRegistry, MapRegistry(entries=244, shipped=242), MapLoader, GameSceneManager
[FLOW] (start) → TitleState
[TITLE] enter
[BOOT] GameFlow started → Title
[BOOT] Bootstrap created GameManager (scene-independent, DontDestroyOnLoad)
[DIALOGUE] DB loaded (DG.SCN)
[TITLE] AUTOBOOT → New Game
[TITLE] New Game → NameInput
[TITLE] exit
[FLOW] TitleState → NameInputState
[NAMEINPUT] enter
[BOOT] FieldPresenter registered: FieldManager
[BOOT] Dialogue facade registered: TextboxView
[H8] ★null 枝 初回★ frame(Time.frameCount)=1 ⇒ ★この枝は ★走っています★（pump したかは 別 = [H8] pump の driver= を 見る）★
[NAMEINPUT] AUTOBOOT → confirm name='TESTBOY'
[DataRegistry] loaded 'data/species_care_params.json' (SpeciesCareFile)
[NEWGAME] InitializeNewGame: flags/vars/inventory reset, clock=Day0 08:00(placeholder), partner init(EXE 0x80110AF4): id=0 stage=1 discipline=8, care(baby form1): max=25 thr=6 decay/h=3 fav=-1
[NAMEINPUT] confirmed name='TESTBOY' partner=pending(intro) → Field
[NAMEINPUT] exit
[FLOW] NameInputState → FieldState
[FIELD] enter (player='TESTBOY')
[MapLoader] loaded 'STIC02' from 'maps/stic02/stic02.json'
[FIELD] map loaded name='stic02' spawns=10 rawCamOrigin=(0.00, -2000.00, -2400.00) viewerDist=1055
[FIELD] HandleMapLoaded name=stic02 arrival=-1 — building field
[FIELD] backdrop full-map billboard size=(33.5,40.2) depth=55.2 factor=(2.00,3.20) worldPerPx=0.0523 shader='Degimon/BackdropBackground' renderQueue=2000
[YINV] OK: canonical 単一反転 + 投影 path world-Y→viewport-Y 単調(vHi.y=0.826>vLo.y=0.218)。consumer flip は grep+review。
[CAMERA] eye=(0.00, 40.00, -48.00) fwd=(0.00, -0.72, 0.69) fov=12.98(=2atan(120/1055)=12.98) aspect=1.333(=1.333) ortho=False near=0.30 far=1000.0 | scrollPx=(0.00, 0.00) scrollNdc=(0.00, 0.00) maxScrollPx=(320.00, 528.00) (3D transform は不動=GS_VIEWPOINT write0 相当)
[PLACE] player initial spawn[0] ps1=(840.00, 0.00, -2873.00) -> world=(8.40, 0.00, -28.73) (canonical 地面 Y=0.00)
[PLACE-GATE] entity gating 表 load: OFF index 32 / name 20
[FIELD-MODEL] code 表 load: 180 種
[PLACE] entities placed=9 (spawn markers + NPC=6、全 ToWorld 経由) — field-model=6/6体(残 marker fallback、DEGIMON_FIELD_MODELS) — time-gate hour=2 除外2体(map=stic02、DEGIMON_TIME_PLACEMENT 既定 ON・=0 で従来へ)
[PLACE-SPECIES] map=stic02 idx=139 rec=2 print_i=0 type=110 script_id=7 ps1=(479,-217)
[PLACE-SPECIES] map=stic02 idx=139 rec=3 print_i=1 type=110 script_id=8 ps1=(-273,-1634)
[PLACE-SPECIES] map=stic02 idx=139 rec=4 print_i=2 type=109 script_id=9 ps1=(217,-2203)
[PLACE-SPECIES] map=stic02 idx=139 rec=5 print_i=3 type=110 script_id=10 ps1=(237,-1248)
[PLACE-SPECIES] map=stic02 idx=139 rec=6 print_i=4 type=110 script_id=11 ps1=(1089,-2909)
[PLACE-SPECIES] map=stic02 idx=139 rec=7 print_i=5 type=110 script_id=12 ps1=(-970,-2155)
[PLACE-SPECIES] map=stic02 ★合計 6 体★(★除外 debug NPC 0 体は含みません★ / ★field-model 6 体★)
[PLACE] coplanar check: player Y=0.000 entities maxΔY=0.000 -> OK(coplanar、生spawn y=0)
[MAPLOADER] ★region → loader = 255 行★(DG.SCN entry 0 の 0xFB section 直読)
[MAPLOADER] ★shipped の 地図 242 本のうち ★loader が 決まる = 242 本★ / 表に 無い = 0 本★(★従来は twna01 の 1 本だけが 確定・残りは fallback★)
[MAPLOADER] map='stic02'(region 139) → loader 127(★表で 解決★ / 従来は placeholder)
[TILE5179] map='stic02' entry=127: ★帯のマス = 0★ / 値の種類 = 0（）/ ★★section が 実在する 種類 = 0 / 0★★（★全 242 地図の 集計は Editor の W3TileBandCoverage★）
[TILE5179] arrival init map='stic02' tile=0 → ★immediate=False / script=False★(兄弟と同規則)
[VISE_CAPSULE] ★placeholder Capsule = 見つけて 切ります★
[VISE_BOOTSTRAP] attach [Player] mode=on useViseModel=True prefab=True ★attach 回数=1★ frame(Time.frameCount)=2 playerId=-168
[VISE_UNLIT] ★unlit へ 切替 = 0 個★ / ★texture 無しで 据え置き = 27 個★ / shader=Unlit/Texture ⇒ ★目的は 彩度の 回復（輝度は 下がってよい）★
[VISE_CTRL] BOYS instantiated: worldPos=(8.40, 0.00, -28.73) renderers=27 boundsCenter=(8.47, 1.31, -28.55) boundsSize=(1.69, 3.55, 1.59) playerPos=(8.40, 0.00, -28.73)
[FIELD] intro trigger → ScenarioVM.Boot()(data 駆動 master-walk)
[SCENARIO-VM] Boot(production faithful awakening, flag OFF)=RunScene(238)(entry0.sec238 ACTIVATE 178→deferred-load→Jijimon 178、worker1/worker2 CONFIRMED ra=0x800EF408)
[SCENE-PROG] RunScene(238) → entry0.section[238](scene-transition driver、ACTIVATE/JMP は Advance)
[DIALOGUE] Begin entry=0 headerValid=False word0=0x468 bodyStart=0x46C len=24576
[DIALOGUE] PlaySection entry=0 section=238 root=NpcSection → pc=0x3518
[FIELD] dialogue started → InputLocked=true (player frozen)
[PROGRESSION][0xFB MAP] map index(op1)=238 → OnMapChangeRequested(spawn=0,mode=0)@pc=0x3518 ★§225: 旧 code は この値を CurrentSection に入れ map 変更を配線していなかった★
[SCRIPTWARP] src=SCRIPT(0x47) request targetMap=238 spawn=0 mode=0 → QueueWarp(deferred)
[SCRIPTWARP] queued -> map=238 spawn=0 mode=0 src=Script
[PROGRESSION] SCENARIO_JUMP(0xFB) @pc=0x3518 scenario(op0)=178 ctx(op1)=238 → Pending body-load(deferred、ACTIVATE=PlayMap)
[VM-GATE] UNSUPPORTED op=0x5D len=2 entry=0 pc=0x3522 prevOp=0x1E stackDepth=0 ctx=B2 00 EE 00 1E 00 F5 00 [5D] 1C 19 00 00 00 37 00 18  ⇒ ★停止(初回)★
[DIALOGUE] scenario finished → OnFinished(player 操作復帰)
[SCENARIO-VM] load scenario=178 section=254(ACTIVATE(section 0xFE)) [SceneCutscene]
[DIALOGUE] Begin entry=178 headerValid=True word0=0x10 bodyStart=0x14 len=6144
[DIALOGUE] PlaySection entry=178 section=254 root=SceneCutscene → pc=0x10 contentEnd=0x1316
[FIELD] dialogue started → InputLocked=true (player frozen)
[PROGRESSION] scenario-VM advanced @OnFinished → 次 scenario 実行(InputLocked 維持)
[SCRIPTWARP] fire frame(Time.frameCount)=4 queued(_pendingFrame)=3 Δ(frame)=1 src=Script -> map=238 spawn=0 mode=0
[MapLoader] loaded 'TOPN01' from 'maps/topn01/topn01.json'
[WARP] -> id=238 name='topn01' spawn=0 mode=0
[FIELD] HandleMapLoaded name=topn01 arrival=0 — building field
[FIELD] backdrop full-map billboard size=(60.6,50.5) depth=143.1 factor=(2.40,2.67) worldPerPx=0.0789 shader='Degimon/BackdropBackground' renderQueue=2000
[YINV] OK: canonical 単一反転(焦点近傍点が viewport 外ゆえ投影 path check skip)。consumer flip は grep+review。
[CAMERA] eye=(0.00, 86.02, -119.46) fwd=(0.00, -0.60, 0.80) fov=7.57(=2atan(120/1813)=7.57) aspect=1.333(=1.333) ortho=False near=0.30 far=1000.0 | scrollPx=(0.00, 0.00) scrollNdc=(0.00, 0.00) maxScrollPx=(448.00, 400.00) (3D transform は不動=GS_VIEWPOINT write0 相当)
[PLACE] player warp-arrival spawn[0] -> world=(4.40, 0.00, -37.15)
[PLACE] entities placed=13 (spawn markers + NPC=8、全 ToWorld 経由) — field-model=8/8体(残 marker fallback、DEGIMON_FIELD_MODELS)
[PLACE-SPECIES] map=topn01 idx=238 rec=0 print_i=0 type=117 script_id=5 ps1=(-261,-2451)
[PLACE-SPECIES] map=topn01 idx=238 rec=1 print_i=1 type=30 script_id=6 ps1=(-406,-2839)
[PLACE-SPECIES] map=topn01 idx=238 rec=2 print_i=2 type=117 script_id=7 ps1=(1054,-2877)
[PLACE-SPECIES] map=topn01 idx=238 rec=3 print_i=3 type=117 script_id=8 ps1=(-103,-1623)
[PLACE-SPECIES] map=topn01 idx=238 rec=4 print_i=4 type=43 script_id=9 ps1=(-1372,-2991)
[PLACE-SPECIES] map=topn01 idx=238 rec=5 print_i=5 type=30 script_id=10 ps1=(480,-1680)
[PLACE-SPECIES] map=topn01 idx=238 rec=6 print_i=6 type=44 script_id=11 ps1=(-839,2210)
[PLACE-SPECIES] map=topn01 idx=238 rec=7 print_i=7 type=29 script_id=12 ps1=(-647,-3108)
[PLACE-SPECIES] map=topn01 ★合計 8 体★(★除外 debug NPC 0 体は含みません★ / ★field-model 8 体★)
[PLACE] coplanar check: player Y=0.000 entities maxΔY=0.000 -> OK(coplanar、生spawn y=0)
[MAPLOADER] map='topn01'(region 238) → loader 178(★表で 解決★ / 従来は placeholder)
[TILE5179] arrival init map='topn01' tile=66 → ★immediate=True / script=False★(兄弟と同規則)
[VM-GATE] UNSUPPORTED op=0x6C len=8 entry=178 pc=0x1A prevOp=0xFE stackDepth=0 ctx=FE 00 64 19 FE 00 FE 00 [6C] FC E5 00 53 F5 02 00 4D  ⇒ ★停止(初回)★
[DIALOGUE] scenario finished → OnFinished(player 操作復帰)
[FIELD] dialogue finished → InputLocked=false (player control restored)
[VISE_CAPSULE] ★placeholder Capsule = 見つけて 切ります★
[VISE_BOOTSTRAP] attach [Player] mode=on useViseModel=True prefab=True ★attach 回数=2★ frame(Time.frameCount)=5 playerId=-4962
[VISE_UNLIT] ★unlit へ 切替 = 0 個★ / ★texture 無しで 据え置き = 27 個★ / shader=Unlit/Texture ⇒ ★目的は 彩度の 回復（輝度は 下がってよい）★
[VISE_CTRL] BOYS instantiated: worldPos=(4.40, 0.00, -37.15) renderers=27 boundsCenter=(4.47, 1.31, -36.97) boundsSize=(1.69, 3.55, 1.59) playerPos=(4.40, 0.00, -37.15)
[MOVE] player pos=(4.40, 0.00, -37.15) ΔXZ=0.000 Y=0.000 groundY=0.000 ΔY=0.0000 scroll.Current=(156.10, 400.00) max=(448.00, 400.00) playerPx=(227.90, -177.14) -> Y不変(落下ゼロ)
[MOVE] player pos=(4.40, 0.00, -37.15) ΔXZ=0.000 Y=0.000 groundY=0.000 ΔY=0.0000 scroll.Current=(156.10, 400.00) max=(448.00, 400.00) playerPx=(227.90, -177.14) -> Y不変(落下ゼロ)
[MOVE] player pos=(4.40, 0.00, -37.15) ΔXZ=0.000 Y=0.000 groundY=0.000 ΔY=0.0000 scroll.Current=(156.10, 400.00) max=(448.00, 400.00) playerPx=(227.90, -177.14) -> Y不変(落下ゼロ)
[MOVE] player pos=(4.40, 0.00, -37.15) ΔXZ=0.000 Y=0.000 groundY=0.000 ΔY=0.0000 scroll.Current=(156.10, 400.00) max=(448.00, 400.00) playerPx=(227.90, -177.14) -> Y不変(落下ゼロ)
[MOVE] player pos=(4.40, 0.00, -37.15) ΔXZ=0.000 Y=0.000 groundY=0.000 ΔY=0.0000 scroll.Current=(156.10, 400.00) max=(448.00, 400.00) playerPx=(227.90, -177.14) -> Y不変(落下ゼロ)
[LIVEBOOT] field reached via real boot path; ran 3.0s — live [CAMERA]/[PLACE]/[MOVE]/[SCROLL] emitted by FieldManager. Quitting.
[Physics::Module] Cleanup current backend.
[Physics::Module] Id: 0xf2b8ea05
Input System module state changed to: ShutdownInProgress.
Input Polling Thread exited.
Input System module state changed to: Shutdown.
CodeReloadManager destroyed
