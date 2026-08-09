# vise avatar phase2 scoping設計(boss1、2026-07-23、着手前PRESIDENT確認用)

**前提gate**: phase1 PoC(BOYS単体)完成(user視覚gate PASS、df7838a push済)。
**方針**: phase1教訓踏襲=段階gate方式/worktree隔離/OFF-inert/非侵襲/prior-art継承(再導出ゼロ)/素性tier/scale=native既定/★検証=game-camera基準(framing artifact再発防止)★/完成claim=user実視覚凍結。

---

## 0. 資産verify(boss1実測、measure-first)
- ★AnimatorSetupGenerator.cs(vise)=per-Digimon animator自動生成★(Generate(digimonName, clips, savePath)、base layer+battle layer)=role非依存=Partner/NPC/178体batch全対応の再利用tool。
- ★vise Digimon asset=全種.fbx+.glb+anim dir揃い★(AGUM/KORO/BOTA/GABU…確認、178種、DW1ModelConverter同一pipeline=BOYS実証済)。
- ★★remake EntityPlacer.cs=自comment(L3)『Phase2で実NPCモデルへ差し替え』=可視marker(青sphere placeholder)→実モデル置換が設計済の受け皿★★。PlacedNpc{World, ScriptId, Type}=位置+script_id+type保有。=BOYS→[Player]の直接的アナログ(NPC/entity版)。
- ∴phase2の attach infra=EntityPlacer(remake側で既に『model差替』を意図)+AnimatorSetupGenerator(vise側で per-Digimon animator自動)=両側の設計が既に噛み合う。

## 1. 段階分割(phase1同型のgate方式)
| 段階 | 内容 | gate |
|---|---|---|
| ★2a(最小PoC)=単一推奨★ | ★1体のDigimonをEntityPlacer placeholder→実モデル置換★(BOYS手法再現+remake設計受け皿に載せる)。AnimatorSetupGeneratorでanimator自動生成。候補=覚醒partner種 or 代表種(AGUM) | game-camera render+OFF-inert+native scale+boss1/PRESIDENT/user視覚 |
| 2b | Partner(相棒)特化=userが常時見る第2キャラ。★attach機構=実測確定(worker1 02:20): player-relative companion(EntityPlacer NPCでない)★。vise PartnerController.cs=手本(_followDistance2.5でplayer追従/DigimonModelLoader.LoadModel(digimonId)で動的解決/Warp()でmap遷移teleport)。remake穴=companion spawn未実装(FieldManager gs.Partner=identity-hashのみ)、attach点=player spawn site(FieldSceneBootstrap/PlayerPlacement周辺)にcompanion GameObject生成。素性/rig/scale=2a/phase1再利用(BOTA=starter、fbx+glb+37anim有)。★faithfulness注意=下記★ | 同上+partner追従は視覚のみ(logicは範囲外) |
| 2c | 全178体 import pipeline確立=BOYS/2a手法のbatch自動化(fbx import+AnimatorSetupGenerator+EntityPlacer wiring) | pipeline再現性+抜取り検収 |
| 2d | game-camera見え方(phase1.5 free-roam連動)/battle intro演出 | awakening完走 or battle scene |

## 2. ★単一推奨=2a『1体Digimon×EntityPlacer placeholder置換』を最初のPoC★
理由:
1. ★BOYS手法の再現性実証★(model attach+native scale+OFF-inert env-gate+AnimatorSetupGenerator)=phase2 pipeline の最小検証
2. ★remakeの設計受け皿(EntityPlacer marker→model、L3)に直接載る★=非侵襲で自然
3. ★attach infra(EntityPlacer)確立→2b partner/2c 178体batchへ直接scale★
4. AnimatorSetupGenerator(per-Digimon自動)=178体展開の automation基盤も同時に検証
- PRESIDENT私見(Partner最小PoC)との差分: Partner追従機構(EntityPlacer entity or player-attached)は未確定=先に『EntityPlacer NPC 1体』でattach infra確立し、partner特化を2bに置く方が、機構未確定riskを避けつつ設計受け皿に載る。★候補種は覚醒partner種を優先(userが最初に見る)、それがEntityPlacer管理でなければ代表種で pipeline実証→partnerは2b★。

## 3. worktree(boss1判断)
- ★推奨=新track `viseavatar/phase2-npc` を phase1 commit(df7838a)から分岐★=phase1をclean landed unitに保ち、phase2はその上に積む。ViseAvatarController/Bootstrap/EntityPlacer拡張を再利用。worktree=degimon_world_remake-viseavatar継続(同隔離)。

## 4. 検証gate(phase1教訓の反映)
- ★game-camera基準★(framing camera封印=scale/proportion判断歪み再発防止、boss1 arc教訓)
- OFF-inert(env-gate、default no-op、既存bit不変)
- native scale既定(phase1 DuckStation実測成果を横展開)
- boss1直視→PRESIDENT直視→user実視覚(headless render≠完成)

## 5. honest gap(先出し)
- partner/NPC の追従・AI挙動(logic)=範囲外(視覚PoCのみ、model+anim表示)
- glb→fbx lossless未検証(polish層、phase1継続)
- glTF extras(loop/SE/tex-anim/translucency)=後続polish
- game-camera free-roam実render=phase1.5依存(awakening完走)

## 6. worker分担案
- worker3(主)=2a: 候補Digimon fbx継承→EntityPlacer placeholder差替配線→AnimatorSetupGenerator適用→game-camera render→ScreenCapture
- worker1(副)=候補種provenance台帳(素性tier)+AnimatorSetupGenerator適用性RE(clip→controller、battle layer要否)+EntityPlacer attach点の静的解析(PlacedNpc→model instance wiring)+partner機構(2b先行調査)
- boss1=各gate検収(game-camera基準厳守)+user視覚package+段階裁定

---
★本docはPRESIDENT着手前確認用。承認後に2a着手(worktree/候補種確定→着手)。push HOLD/完成claim凍結不変。★
