# vise 3Dキャラ継承 — phase1 PoC設計(boss1、2026-07-22、着手前PRESIDENT確認用)

**scope(PRESIDENT承認済)**: BOYS 1体をremake worktreeへ隔離import→白Capsule差替(fallback温存)→animator基本動作(Idle/Run)確認まで。完成claim=user実視覚まで凍結。

---
## ✅✅✅ PHASE1 PoC = COMPLETE(2026-07-22、user視覚gate PASS)✅✅✅
★user判定『だいたい同じぐらいのサイズに見えます』=scale native OK=user目視gate PASS=phase1完成、完成claim凍結解除★。
- 全次元PASS: モデル同定(主人公・user確認)/anim(Idle/Run bone駆動)/in-field表示/OFF-inert(baseline=inert sha完全一致)/scale=★native(k=1.0)確定=3系統(幾何k≈1.1+精密pixel k=1.03+視覚composite、原盤DuckStation実測ground truth)★
- 実装特性: prior-art継承(vise、再導出ゼロ)/worktree隔離(degimon_world_remake-viseavatar、track viseavatar/boys-poc)/完全非侵襲(RuntimeInitializeOnLoadMethod+env gate、scene/PlayerController非改変)/build緑
- ★scale arc教訓(記録)★: framing camera(2.2u近接、可視保証用)がboyを~8.5倍巨大化→user『5倍過大』+推測k(0.2/0.15/0.12)は全てこのframing artifact由来の誤誘導。measure-first(DuckStation原盤pixel比=camera不変ground truth)がこれを暴き native確定。提示infra側でcamera/次元の妥当性をuser gate前に検証すべき、が教訓。
- ★残honest gap(非blocking、phase1.5/2候補)★: (1)free-roam実game-camera render=awakening完走依存=phase1.5(但しpixel比幾何でscale確定済ゆえ非blocking) (2)glTF extras①-④(loop/SE/tex-anim/translucency)忠実化=後続polish (3)scale微調整(k=1.03 vs 1.0=user OK範囲、native既定確定)
- ★次arc候補(user判断待ち)★: phase2(全178体展開/Partner/NPC配線 via AnimatorSetupGenerator/game-camera見え方/battle intro等)。push=HOLD(user専権、phase1 land push要否=user判断待ち)。

## (旧)DELIVERABLE STATUS(2026-07-22、user目視gate待ち時点)
phase1 PoC技術実証=完了(全gate boss1直視+PRESIDENT直視でPASS)、user目視gate待ち。
- ★(A)OFF-inert最強A/B★: baseline vs inert=同一frame(welcome beat)・game camera・sha256完全一致(0542f64d…1e85)・非ゼロpixel 0/691200=fallback安全bit完全。path=workspace/degimon-faithful178/VISE_AVATAR_field_{baseline,inert}.png
- ★(B)BOYS in-field render★: on shot(awakening beat・framing camera)+診断log(worldPos=(4.40,0,-37.15)=player一致/27 renderers/bounds正立)=BOYSがfield worldにplayer位置で実体化。path=..._field_on.png / ..._on_diag.log
- standalone Idle/Run=anim bone駆動実証。worktree _shots/boys_{idle,run}.png
- 技術path全解決: gltfast失敗→FBX pivot(証拠付き)/rig case-A(三重接地予測的中、bind 18/18)/mesh4217頂点+tex/向き補正/env-gate runtime injection(scene非改変=最強OFF-inert)/build緑。
- ★honest gap(user提示に明記済)★: on shot=別beat/framing camera=『同frame BOYS有無clean A/B』でない。★user実画角(free-roam game-camera追従)=採取blocked=awakening cutscene完走(scenario178→149 transition)依存=phase1.5/2候補task★。worker3が偽shot作らず正直報告(規範遵守)。
- 素性tier(PROVENANCE.md): content=game-derived(TMD→glb)/FBX packaging=vise-processed(glb_to_fbx.py)/import+prefab=vise-impl。glb→fbx lossless未検証=polish層。
- ★次(user判断待ち)★: (i)phase1 PoC受理可否 (ii)phase2進行可否(全178体/NPC/Partner/extras忠実化) (iii)awakening完走task(free-roam実画角の前提)の位置づけ。
---
**規範**: worktree隔離必須(remake本体tree非改変)/継承物provenance台帳(source path+sha)/gltfast実import路をまず実証/push=HOLD(都度user指示)。

---

## 1. worktree隔離設計
- 元repo: `/home/ken/Desktop/Digimon/degimon_world_remake`(main HEAD=7a87fba)
- ★新worktree: `git worktree add ../degimon_world_remake-viseavatar viseavatar/boys-poc`★(main分岐、track=viseavatar/boys-poc)
- 作業は `~/Desktop/Digimon/degimon_world_remake-viseavatar/unity/` で完結。共有main treeには触らない。
- 既存の他worktree(f1a-f1c/e152等)とは独立。

## 2. 継承元asset(provenance台帳=phase1で作成)
| 継承物 | vise source path | 形式/size | 継承先(worktree内) |
|---|---|---|---|
| BOYS model | vise/unity_remake/Assets/Models/Digimon/BOYS.glb | glb 577680B(自己完結=texture埋込) | unity/Assets/ViseAvatar/BOYS.glb |
| BOYS anim | vise/unity_remake/Assets/Animations/Digimon/BOYS/*.anim(39 clips) | Unity .anim | unity/Assets/ViseAvatar/Anim/(Idle/Run先行) |
- ★glb採用(gltf/fbx でなく)★=worker3推奨(自己完結+extras保持経路)。台帳に各copyのsha256記録。
- License=MIT(DW1ModelConverter、確認済)/asset=game-derived(TMD直読、素性良)=継承可。

## 3. import路の実証(第一確認=survey honest gap)
1. ★gltfast 6.16.0でBOYS.glbがUnity import成功するか★(editor import or runtime)。確認項目: mesh/texture/★rig骨名(skeleton node名)★/keyframe anim。
2. ★rig骨名互換★=BOYS .anim clip(vise命名)が import後のskeletonに bind するか=phase1第一の合否点。不整合なら→bone remap要否を判定(phase1で発覚=honest gap消化)。

## 4. 差替機構(fallback温存=必須)
- 既存白Capsule=★削除せず★。player配下に BOYS instance を追加し、★toggle(serialized bool `useViseModel` or env flag)★で capsule/BOYS を切替。default=capsule(既存動作不変)、opt-inでBOYS表示。
- Animator: BOYS instanceに Animator + 最小controller(Idle/Run state)。★worker1 review採用=state遷移はtransform.position deltaの外部観測(静止→Idle/移動→Run)で駆動★=PlayerController露出/編集不要=完全非侵襲(旧案『move状態→trigger配線』はPlayerController編集を誘発するため差替)。
- ★remake本体logic(PlayerController移動/Placement)は非改変★=visual子の追加のみ。worker1確認: PlayerController=Transform専用(position操作のみ、visual body/Animator参照なし)=非改変で子追加可。
- ★rig bind保険路(worker1)★: named .anim(Idle/Run)がcase-B(Armature root prefix不一致)でbind失敗しても、GLB内蔵anim(anim-0..38、同一GLB由来=guaranteed bind)をindex突合で使用可=gateは必ず通せる。

## 5. 検証項目(phase1合否)
1. import成功(§3): mesh/tex/rig表示、anim clip bind
2. 白Capsule→BOYS visual差替(toggle動作、capsule fallback健在)
3. ★Idle/Run animator基本動作★(静止=Idle、移動=Run再生)
4. ★user実視覚★(DISPLAY=:1 + ScreenCapture でheadless確認→最終はuser目視)=★完成gate(headless/import成功では完成でない)★

## 6. honest gap(phase1で扱う範囲/後続polish)
- (a)glTF extras①loop点②SE③tex-anim④translucency=importer自動適用せず→phase1は『表示+基本anim』まで、完全忠実は後続polish(extras再生層実装)
- (b)rig骨名互換=§3第一確認(不整合なら remap課題を起票)
- (c)BOYS clip full set(39)実動作=phase1はIdle/Run先行、残りは動作確認のみ

## 7. worker分担案
- ★worker3(主)★: worktree add→BOYS.glb import実証(§3)→差替機構実装(§4)→animator配線→DISPLAY:1 ScreenCapture検証(§5-1〜3)。screenshot infra保有。
- ★worker1(副)★: provenance台帳作成(§2、sha記録)→rig骨名/extras静的解析(import前予測=§3の答え合わせ材料)→fallback toggle設計review→cargo/unity build健全性確認。
- boss1: 各step検収(import成功のscreenshot直視/台帳sha照合/差替がlogic非改変か)、user実視覚package化、中間ack。

## 8. phase2以降(別承認、phase1 PoC+user実視覚後)
全178体展開/NPC・Partner配線(AnimatorSetupGenerator活用)/extras忠実化/battle intro等。phase1成功が前提gate。

---
★本docはPRESIDENT着手前確認用。承認後にworktree add から着手。push=HOLD不変。★
