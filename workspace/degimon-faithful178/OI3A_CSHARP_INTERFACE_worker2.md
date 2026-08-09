# OI-3a q1③ — step3 資産 C# 側 interface 棚卸し(B4 実配線の接続面 map)

worker2 / 2026-07-19。**read-only、現 main 実code基準(f1b HEAD 83c1874)の grep+直読。過去 doc からの relay 禁止=rebaseline**。
全項目 file:line 接地。semantic 不明箇所=🅰。

---

## 0. 結論(B4 接続面の単一 map)

B4(0x66 SCENE_DRIVER の scene selector stub、scene-id を produce)が scene 遷移を起こすには:
- ★scene-id entry point = `ScenarioVM.TryScene(target)`(Flow/ScenarioVM.cs:130)★ = 設計された「caller が target scene-id 供給 → BOUND なら RunScene / UNBOUND なら no-op」の面。
- ★但し 3 つの gap★: (G1)`ScenarioVM` instance は **FieldState 所有**(DialogueRuntime から非到達)/ (G2)SceneTransition.Next の **BOUND=14/238 のみ**(B4 産の scene-id 未 bind)/ (G3)B4 は DialogueRuntime 内=既存の **deferred(PendingScenarioLoad→Advance)or event(OnScenarioJump)** 経由でしか ScenarioVM に届かない。

---

## 1. scene/section API inventory(実 signature・semantics・呼出元)

| API | file:line | signature | semantics | 呼出元 |
|---|---|---|---|---|
| **RunScene** | Flow/ScenarioVM.cs:112 | `public void RunScene(int sceneId)` | ★scene-transition driver core★。callStack clear + pending clear + CurrentSceneId=sceneId + `_dlg.PlayMapSection(BootScenario, sceneId)`(entry0.section[sceneId] を **NpcSection** で invoke) | Boot(:79/:104)/TryScene(:138) |
| **TryScene** | Flow/ScenarioVM.cs:130 | `public bool TryScene(int target)` | ★additive caller-core★=`SceneTransition.Next(CurrentSceneId, target)`→ BOUND なら RunScene(next)+true / UNBOUND なら no-op+false(既存挙動保持) | FieldState.cs:563(dev-gate DEGIMON_SCENE_TARGET のみ) |
| **Advance** | Flow/ScenarioVM.cs:145 | `public bool Advance()` | dialogue finish 契機の loader 継続。`PendingScenarioLoad`(0xFB/0x14/0x17 が立てた)を消化→LoadAndRun。true=継続/false=field 返却 | FieldState.cs:544(OnDialogueFinished) |
| **Boot** | Flow/ScenarioVM.cs(~:70-104) | `public void Boot()` | 起点。FSZ ON=RunScene(204)/dev-gate=RunScene(204)/既定=RunScene(238=SceneAwakening) | FieldState.cs:520 |
| **PlayMapSection** | Dialogue/TextboxView.cs:125 | `public void PlayMapSection(int mapId, int section)` | `StartSection(GetEntryChecked(mapId), section)`(NpcSection root) | RunScene(:119)/facade |
| **PlayMapSectionScene** | Dialogue/TextboxView.cs:127 | `public void PlayMapSectionScene(int mapId, int section)` | 同上 + **SceneCutscene root**(cutscene 系) | ScenarioVM.LoadAndRun(:196、ACTIVATE時) |
| **PlaySection** | Dialogue/DialogueRuntime.cs:488 | `public bool PlaySection(DialogueEntry entry, int section, RootInvoke root=NpcSection)` | 実 section 実行(walker 起動)。root=NpcSection/SceneCutscene/FullScenario | StartSection 経由 |
| **GetSectionOffset** | Dialogue/DialogueData.cs:178 | `public static int GetSectionOffset(DialogueEntry entry, int section)` | section table lookup→offset(不在=-1)。★step3 MAPHEAD 鎖の section 解決★ | walker section-switch/loader |
| **GetEntry / GetEntryForMap / GetEntryBase** | DialogueData.cs:79/109/121 | `GetEntry(int index)` / `GetEntryForMap(int mapId)=GetEntry(mapId)` / `GetEntryBase(int scenario)` | mapId/scenario→DialogueEntry 解決(MAPHEAD 鎖) | PlayMap*/loader |
| **HandleMapLoaded / BuildField** | Field/FieldManager.cs:437 | `public void HandleMapLoaded(MapData map, int arrivalSpawn) => BuildField(map, arrivalSpawn)` | map 実体 load→field 構築(twna01 等) | warp/scene load 消費側 |
| **RootInvoke** | DialogueRuntime.cs:225 | `enum { NpcSection, SceneCutscene, FullScenario }` | section 実行の root 種別(0xFE resolve 挙動を分岐) | PlaySection root 引数 |

---

## 2. gate / feature-flag inventory

### 2-1. 現役 gate(runtime 分岐、B4 段階配線の設計材料)
| gate | file:line | 型 | 意味 | set/clear |
|---|---|---|---|---|
| **FaithfulScenarioZero** | ScenarioVM.cs:46 | `static bool`(env 計算) | ON=RunScene(204)chain / OFF=RunScene(238)。効果は runtime chain(0xFE resolve path)にのみ | env DEGIMON_FAITHFUL_SCENARIO_ZERO=1 |
| **AwakeningCutsceneActive** | ScenarioVM.cs:53 | `static bool` | 覚醒 cutscene(Boot→twna01)進行中 flag(視覚 coalesce gate)。IsCutsceneActive では §204/§238 NpcSection の 0x47 を漏らすため boot chain 全体 cover | set=Boot FSZ block / clear=terminal render(FieldManager)+DialogueRuntime.cs:706 |
| **_warpEmit** | DialogueRuntime.cs:153 | `bool`(instance) | 0x4B emit gate。false=content(fall-through)/ true=1st 0x4B で map-load emit | env DEGIMON_WARP_EMIT=1(:440) |
| **BehavioralMode** | DialogueRuntime.cs(~:170) | `public bool {get;set;}` | 実プレイ path が立てると Begin で jump take ON(_jumpsEnabled) | TextboxView(gameplay) |
| **_jumpsEnabled** | DialogueRuntime.cs(~:165) | `bool` | β=false(全 jump fall-through=linear/narrow)/ γ=true(real dispatch) | BehavioralMode / env DEGIMON_DIALOGUE_JUMPS |
| **CoalesceActive** | FieldManager.cs:114 | `bool =>ACA` | = AwakeningCutsceneActive(視覚 coalesce) | (derived) |
| **_sceneDriver/_actorRegistry/_op67** | DialogueRuntime.cs(step5/4/0x67) | `bool` | 私の実装 op gate(既定 OFF、env) | env DEGIMON_SCENE_DRIVER/ACTOR_REGISTRY/OP67 |

### 2-2. env flag 全 list(55、q2 flag別ON計画の材料)
scene/warp/scenario 系(B4 関連):
`DEGIMON_FAITHFUL_SCENARIO_ZERO`(FSZ chain)/ `DEGIMON_WARP_EMIT`(0x4B emit)/ `DEGIMON_SCENE_TARGET`(TryScene dev-gate)/
`DEGIMON_SCENARIO_VM_BOOT`(RunScene 204 dev)/ `DEGIMON_SCENE_DRIVER`(0x66)/ `DEGIMON_ACTOR_REGISTRY`(0x46/79)/
`DEGIMON_OP67`(0x67)/ `DEGIMON_DIALOGUE_JUMPS`/ `DEGIMON_GAMEPLAY_JUMPS`/ `DEGIMON_AUTOWARP`/ `DEGIMON_SCRIPTWARP`/ `DEGIMON_NPC_SCENARIO`。
その他(test/dump/care/field/shot 系、B4 非関連)= `AUTOBOOT/AUTOADV_FRAMES/CAREVERIFY/CLOCK_SCALE/DEBUG_NPCS/DIALOGUE_AUTOADVANCE/
DIALOGUE_CANCEL/DIALOGUE_CHOICE/DIALOGUE_SHOT/DUMP_*/EDGE_DUMP/EVOTEST/FEEDTEST/FIELD*/FORCE_SCROLL*/INIT_STATE*/INTRO_ENTRY/
MENU*/NARROW_*/NPC_TEST/OPTRACE/PAGE_SHOT_DIR/POSTCUT_*/PROBE_ENTRY/SECTION_LIST/SET_FLAGS/SHOT_PATH/STARVETEST/STATUS*/
TRACE_START/WALK_DIR/BOOT_MAP`(全 55、詳細 grep=DialogueRuntime/FieldManager/FieldState/ScenarioVM)。

---

## 3. DialogueRuntime → ScenarioVM 連絡路(B4 が届く経路)

★DialogueRuntime は ScenarioVM を **static 参照のみ**(FaithfulScenarioZero/AwakeningCutsceneActive)。instance ref 無し=直接 TryScene/RunScene を呼べない(G1)★。連絡は 3 経路:

| 経路 | 機構 | file:line | B4 適合性 |
|---|---|---|---|
| **(a) OnScenarioJump event** | `public event Action<int,int> OnScenarioJump`(:127)、`RaiseScenarioJump(scn,sec)`(:128)が Invoke | DialogueRuntime.cs:127-128 | scenario/section 粒度(scene-id でない)。B4 は scene-id ゆえ直用不可、変換要 |
| **(b) PendingScenarioLoad → Advance** | DialogueRuntime が `_gameState.PendingScenarioLoad=true`(:657/677/958/1030)→ FieldState.OnDialogueFinished→`ScenarioVM.Advance()`(FieldState.cs:544)が消化 | DialogueRuntime + ScenarioVM.cs:145 | ★deferred pattern=既存 0xFB/0x14/0x17 と同型。B4 も pending 立てれば Advance 消化可(但し scenario/section 粒度、scene-id→section 変換要)★ |
| **(c) ScenarioProgression.RequestScenarioJump** | approach-agnostic seam | Flow/ScenarioProgression.cs:26 | `RequestScenarioJump(gs, dlg, scenario, section, trigger)`。呼び元非依存 seam(a/b 統合先) |
| **ScenarioVM 所有** | `FieldState._scenarioVM`(:62)、`new ScenarioVM(gs, _ctx.Dialogue)`(:518)、Boot(:520)/Advance(:544)/TryScene(:563) | FieldState.cs | ★TryScene(scene-id 面)は FieldState だけが呼べる=B4 から使うには FieldState への signal or ScenarioVM ref 注入が要る★ |

---

## 4. B4 接続候補と gap(単一 map)

### 候補X(推奨面): TryScene(scene-id) 経由
- B4 selector が scene-id を出す → `ScenarioVM.TryScene(scene-id)` → BOUND なら RunScene で scene 遷移。
- ★gap★:
  - **G1 到達性**: TryScene は FieldState 所有 ScenarioVM の method。B4(DialogueRuntime)から呼べない。→ 要: (i)DialogueRuntime に scene-transition pending(scene-id 保持)を新設 → FieldState/ScenarioVM が消化、or (ii)ScenarioVM ref を facade 経由注入。
  - **G2 bind**: `SceneTransition.Next`(State/SceneTransition.cs:30)は **target==14 or 238 のみ BOUND**、他は Unbound(-1)=no-op。B4 産 scene-id を bind するには reach-chain decode 後に Next 表へ追加(🅰=どの scene-id が B4 から出るかは OI-3 selector 3段目 RE 依存)。
  - **G3 粒度**: B4 の scene-id と RunScene の sceneId(=entry0.section index)の id 空間一致は未確認(🅰。RunScene は entry0.section[sceneId]=section 粒度)。

### 候補Y: deferred pending(既存 0xFB 型)流用
- B4 が `PendingScenarioLoad` + (scenario,section)を立て、Advance が消化。
- ★gap★: B4 は scene-id を出す。scene-id→(scenario,section)の変換が要(RunScene は BootScenario.section[sceneId] を使う=変換規則は判明、但し B4 scene-id の意味=🅰)。

### 既存 warp/scene emit 経路(参考、B4 と別系)
| op | file:line | 機構 |
|---|---|---|
| 0x4B WARP_DEST | DialogueRuntime.cs:906 | field-tile warp(map/spawn/mode)、_warpEmit gate。**map 変更**(scene でない) |
| 0x47 MAP_CHANGE | DialogueRuntime.cs(case、step4 で非改変確認) | MM DD=map/spawn 変更 |
| 0xFB/0x14/0x17 | DialogueRuntime.cs:958-1035 | scenario JUMP/CALL/ACTIVATE→PendingScenarioLoad→Advance |

---

## 5. 未確定(🅰、OI-3 selector RE 依存)
- B4 selector(0x800aeca8→0x80105be4 scene-id dispatch)が出す scene-id の **id 空間**(RunScene の entry0.section index と同一か / map-id か)= OI-3 3段目 RE 後。
- SceneTransition.Next へ bind すべき (current,target) ペア = reach-chain decode 後(現状 14/238 のみ)。
- descriptor 表 0x8013CDB4(0x80105be4 が引く)の C# 対応=未実装(OI-3)。
- 本 doc は **現 code の接続面 map**(read-only)。実配線(pending 新設/ref 注入/bind 追加)の設計は q2/OI-3b。
