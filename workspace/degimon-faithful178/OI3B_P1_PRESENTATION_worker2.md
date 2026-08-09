# OI-3b p1③ — remake 提示層 survey(R2 scene 0x21 presentation の受け皿 map)

worker2 / 2026-07-19。**read-only、現 main 実code基準(f1b HEAD 04e5d96)grep+直読。過去 doc relay 禁止**。
全項 file:line 接地。semantic 不明=🅰。目的=R1 の [SCENE-SWITCH](record 0x21, variant)を **視覚化する受け皿**の現況と gap。

---

## 0. 結論(R2 の受け皿 map)

remake の視覚提示層は **6 層**存在(§1)。だが ★『scene(0x21, variant)= 全画面 presentation』の専用受け皿は【無い】★:
- 既存の全画面級 layer = **field backdrop**(map 背景 billboard)のみ。scene image 用の asset 層・presentation 層は未実装。
- switcher(0x800cfdf0)の teardown→CD asset load(0x800cf400、stride39 record→0x8015102c)→finalize = ★remake に **CD scene asset の provision 前例が無い**(map _bg.png / portrait のみ)★= R2 の中核 gap。
- ★R1 の [SCENE-SWITCH] log の (record,variant) 列 = R2 視覚化対象リストを実測確定(設計どおり R1 が R2 scoping を兼ねる)★。

---

## 1. remake 提示層 inventory(6 層、file:line)

| # | 層 | file:line | 実体 | asset 源 |
|---|---|---|---|---|
| L1 | **field backdrop** | FieldManager.cs:454-455(BuildBackdrop) | full-map billboard Quad + `Degimon/BackdropBackground` shader(Queue=Background/ZWrite Off) | `StreamingAssets/maps/<name>/<name>_bg.png`(BuildBackdrop:先頭) |
| L2 | **field camera** | FieldManager.cs:446-450(BuildField) | `Camera`(SolidColor clear)+ `FieldCameraRig`(固定3D、scroll follow) | — |
| L3 | **entities/avatar** | FieldManager.cs:471(avatar Capsule)/EntityPlacer | primitive(Capsule=player、Sphere=NPC marker)、Geometry 2000 | — |
| L4 | **textbox(OnGUI)** | TextboxView.cs:354-367(OnGUI) | `GUI.Box`(box)+`GUI.Label`(speaker/page text)、2D overlay | Resources/Fonts/NotoSansJP(TextboxView.cs:380) |
| L5 | **portrait/atlas** | UI/AtlasSpriteLoader.cs(:174 portrait / :189 manifest) | atlas region crop + 独立 portrait PNG。Point filter | `StreamingAssets/textures/etcdat/atlas_regions.json` + `textures/digimon/<name>.png` |
| L6 | **VISMAP coalesce** | FieldManager.cs:105-123/195-207 | cutscene-gated render coalesce(0x4B warp を settle/terminal まで defer→render)。CoalesceActive=AwakeningCutsceneActive | (L1 backdrop を駆動、field warp のみ) |

---

## 2. asset pipeline 現況(CD asset→remake asset の provision 前例)

### 2-1. StreamingAssets layout(実在 dir)
`StreamingAssets/`: `maps/<name>/<name>_bg.png`(map 背景、多数=gcan06/fact02/ogre04/twnb13/… 実在)/ `textures/digimon/<name>.png`(portrait)/
`textures/etcdat/atlas_regions.json`(atlas manifest)/ `dialogue/DG.SCN`(dialogue、bit-exact)/ `models/digimon`(3D)/ `data` / `registry`。

### 2-2. provision tools(workspace/tools/、CD→remake 変換前例)
| tool | 変換 | 対応 remake layer |
|---|---|---|
| `provision_dialogue.py` / provision_dialogue_scn.py | CD DG.SCN → StreamingAssets/dialogue(bit-exact) | dialogue VM |
| `provision_atlas_textures.py` | CD sprite/atlas → textures + atlas_regions.json | L5 portrait/atlas |
| `provision_curated_data.py` | CD data → data/ | care/registry 等 |
| `build_runtime_registry.py` | map registry provision | L1/L2 map |

★前例パターン: CD binary asset → PNG/JSON へ decode+provision → StreamingAssets 配置 → runtime が File.ReadAllBytes+LoadImage で load★
(BuildBackdrop:先頭 / AtlasSpriteLoader.cs:174 が実例)。

### 2-3. ★scene asset の前例は無い(gap)★
- map 背景(_bg.png)・portrait(digimon/<name>.png)は provision 済だが、★『scene(0x21 variant)presentation image』に対応する asset 種別・provision tool は **不在**★。
- switcher の CD load(0x800cf400 stride39 record→0x8015102c)が何を load するか(scene image? 3D? animation?)= 🅰(R2 RE=OI-3b 本体)。

---

## 3. scene 0x21 presentation の実装候補(接続面)+ gap

### 候補A: 全画面 billboard(L1 backdrop 方式の踏襲)
- scene image PNG を全画面 Quad(または overlay)に貼る。BuildBackdrop(FieldManager.cs:454)の全画面 billboard 生成が直接の前例。
- ★gap★: (i)scene image asset(CD stride39 record の decode=R2 RE)/ (ii)scene 用 presentation layer(field と別 or field 上 overlay)/ (iii)L6 VISMAP は field warp 専用ゆえ scene には非流用(草原/ROOM08/twna01 のみ、FieldManager.cs:108)。

### 候補B: OnGUI 全画面 overlay(L4 textbox 方式)
- `GUI.DrawTexture`(全画面 rect)で scene image を描画。textbox(TextboxView.cs:354 OnGUI)と同 layer=最前面 2D。
- ★gap★: scene image asset(同上)。実装は最小(OnGUI 1 texture)。static scene に適。

### 候補C: L5 atlas sprite 層の拡張
- sprite-based scene 要素(portrait 方式)。scene が複数 sprite 合成なら atlas。
- ★gap★: scene が sprite 合成か full-image かは 🅰(CD record 内容 RE 依存)。

### 現況の接続点(R1 との)
- R1 の switcher `SceneSwitch(0x21, variant)`(GameState、r5)が現 scene 状態(RawE06A/E06C)を保持。R2 は switched 時に候補 A/B/C の presentation を発火。
- ★R1 [SCENE-SWITCH] log の (record,variant) 列 = R2 が視覚化すべき scene の実測リスト(sweep で確定)★。teardown/CD load/finalize は R1 で宣言 gap 化済(r3)= R2 の実装対象。

---

## 4. R2 gap 分析(何が揃えば user 可視 scene が出るか)

| gap | 内容 | 依存 |
|---|---|---|
| G-R2-1 | ★CD scene asset の RE★: switcher CD load(0x800cf400 stride39 record→0x8015102c)が load する実体(image/3D/anim)= 🅰 | OI-3b 本体 RE |
| G-R2-2 | ★scene asset の provision★: CD record → PNG/asset へ decode+provision(provision_scene.py 新規)。前例=atlas/map provision(§2-2) | G-R2-1 後 |
| G-R2-3 | ★scene presentation layer★: 候補 A(全画面 billboard)or B(OnGUI overlay)を新設。field/textbox と z 順・teardown 整合 | G-R2-1(scene が何か)後 |
| G-R2-4 | scene→asset 解決 seam: variant(0-3)+ record(0x21)→ 具体 scene asset の mapping(🅰=CD record index との対応) | G-R2-1 |
| G-R2-5 | user live 判定(v4): scene 遷移が実際に画面に出る=凍結解除+push 判断 | G-R2-1〜4 全 |

### 実装順の含意(推奨、推論)
1. まず **R1 ON sweep の [SCENE-SWITCH] (record,variant) 列を実測**(R2 視覚化対象の有限リスト確定)。
2. その列の scene が CD 上で何か(G-R2-1 RE)→ provision(G-R2-2)。
3. presentation layer=候補 B(OnGUI 全画面 overlay)が最小 risk(field 非改変・static image に適)。sprite/3D 合成なら A/C。
4. field(L1-L3)/textbox(L4)との z 順・入力・teardown 整合を OFF-inert 二重確認で。

---

## 5. 未確定(🅰、OI-3b RE 依存)
- switcher CD load(0x800cf400)の load 対象(scene image/3D/animation)= R2 RE 中核。
- scene(0x21 variant 0-3)が field 上 overlay か field 置換(全画面)か= CD record + 原盤挙動 RE。
- stride39 record の構造(0x8015102c buffer)= worker3/worker1 RE 領域。
- 本 doc は **現 remake 提示層の受け皿 map**(read-only survey)。R2 実装設計は q2/OI-3b。
