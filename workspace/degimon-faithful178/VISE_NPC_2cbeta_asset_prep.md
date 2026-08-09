# 2c-β asset prep 台帳 (worker3, 2026-07-23)

## 目的
2c-α(baby 4種: TOKO/YURA/TANE/KORO)で実証したvise NPC pipelineを、adult/child/perfect tierへ拡張する前提の asset 有無・pipeline適用可否を実確認。

## vise source
- Models: `/home/ken/Desktop/vise/unity_remake/Assets/Models/Digimon/` = ★178種 全fbx+glb完備★
- Anim: `/home/ken/Desktop/vise/unity_remake/Assets/Animations/Digimon/{CODE}/` = 各種.anim群
- tex: `{CODE}_tex1.png`(各種1枚)

## 近接NPC候補種 asset availability (実測)
| code | fbx | glb | tex | anims | 命名規約 |
|------|-----|-----|-----|-------|---------|
| GREY(グレイモン) | ✓ | ✓ | 1 | 48 | CODE_Idle/Run/Walk/Attack1-4/BattleIntro… |
| AIRD(エアドラモン) | ✓ | ✓ | 1 | 49 | 同 |
| ANDR(アンドロモン) | ✓ | ✓ | 1 | 51 | 同 |
| PALM(パルモン) | ✓ | ✓ | 1 | 43 | 同 |
| OGRE(オーガモン) | ✓ | ✓ | 1 | 47 | 同 |
| BAKE(バケモン) | ✓ | ✓ | 1 | 48 | 同 |
| AGUM/GABU/PATA/ELEC/KUNE/TYRA… | ✓ | ✓ | 1 | 43-49 | 同 |
- ★全178種で成立(fbx+glb+tex1+full anim set)。命名規約=TOKO(baby)と同一★。
- ※どの種が近接map(twna01周辺)の実NPCかは worker1 RAM列挙scope。ここでは asset 有無のみ確認(捏造join禁止)。

## pipeline tier非依存性 (結論)
2c-α pipeline構成要素の全てが tier非依存で適用可:
1. ★AnimatorSetupGenerator.Generate★: named clip(Idle/Run/Walk/Attack1-4/BattleIntro)を全tier種が保持=batch loop可(ViseNpcSetup.Build(species)がそのまま動く)。
2. ★orientation補正(y反転+180Y)★: uniform確定=種別差なし(2a確立)。
3. ★emission color-fix(今回)★: Build()が{species}_tex1.png自己発光をbake=全種tex1枚ゆえ自動適用。追加コード不要。

## 唯一のper-tier未知 = scale
- ★baby 0.67x(TOKO body/boy)は流用不可★=tier別に原盤実測要(H1『全tier一定normalize』仮定は禁止=baby内でも2倍差の前例)。
- adult/child/perfect各tierの faithful scale = worker1 frame探索(原盤に該当tier NPCが可視な場面)待ち。
- 実測が付くまで interim scale で render→user gate、は baby と同運用可(honest mark付き)。

## batch拡張 readiness (task 2)
- 現 `BuildVillage()` = hardcoded {TOKO,YURA,TANE,KORO} loop。
- 拡張案: species list を引数化 or `Assets/ViseAvatar/*/` 存在dir自動列挙 → `Build(sp)` loop。小改修で対応可(worker1のmap roster確定後に実装)。
- 各種の asset copy(fbx+tex1+必要anim → `Assets/ViseAvatar/{CODE}/`)は 2c-α と同手順。

## 次アクション(待機)
1. worker1: 近接map NPC roster(RAM) + per-tier原盤scale frame → 確定後に該当種を asset copy + BuildVillage拡張。
2. 色fix(2c-α)= boss1直視→user gate 完了後に本格着手。

## 全178種 asset完全性 audit (2026-07-23、batch task向けhonest gap台帳)
実測scan(fbx/glb/tex1/anim-count):
- ★総数=178種、全種 fbx+tex1 完備、anim完全欠落=ゼロ★。
- ★151種=完全(fbx+glb+tex1+anim≥8)=即import batch可★。
- 27種=LOW_ANIM(anim 2-7、named clip一部欠落possible=honest-mark要):
  ANLG(4)/BRAK(5)/BRIK(3)/EGOB(4)/EHOE(6)/EMON(5)/ESEA(6)/EVEG(7)/EYUK(7)/HAGU(4)/JIJI(6)/JURE(3)/PUTI(3)/SCUD(2)/TENS(6)/TIRS(3)/cegr(3)/cemg(6)/ecen(3)/emoj(6)/enan(4)/epiy(5)/escu(6)/eshe(7)/euni(6)/evan(7)/eved(4)
  - ※E-prefix/小文字code(cegr等)=特殊/enemy/effect系の可能性(full character でない)ゆえ低anim=想定内。
- 1種=JIJI: glb欠落(fbxは有=import可、glbは代替形式ゆえ影響小)。

### batch適用judgment
- 151完全種=AnimatorSetupGenerator batchそのまま。
- 27 low-anim種=存在するanimのみでcontroller生成(欠落clipはhonest gap台帳mark)。Idle欠落種はdefault state要注意=個別確認。
- ★tier別scale=別軸(worker1 tier代表frame実測待ち、H1流用禁止)。asset完全性とscaleは独立★。

## ★124 unique実character 全model 3D化 完了 (2026-07-24)★
- gallery 7 batch(baby4/champion12/batch2×14/batch3-7×94)=124 unique model prefab生成、各batch boss1 gate PASS(色canonical/facing/form/import、灰青ゼロ)。
- 178内訳確定: ★124 unique実character + BOYS(1、boy本体) + enemy変種54(E-prefix25 + 小文字30=EDEV等 palette-swap、本体modelのcolor/stat版、新規geometry非)★。
- 手法: model-only bulk(fbx+tex、controller skip=先行30種full実証済ゆえ)。emission floor全種適用(暗域canonical色)。facing=北固定でなくrot適用は placement段階(村3種で実証)。scale=viewing-normalized(faithful=native-uniform interim 93%、完全faithfulはwatchpoint/frame源待ち)。

### 残scope(boss1指示待ち)
- (a) enemy変種54=palette-swap生成(同pipeline、texture差のみ確認)。
- (b) placement層=loader RE(user-session watchpoint、procedure doc準備済)→faithful per-map配置。
- (c) faithful scale精密化=user-session watchpoint(scale適用site) or per-species原盤frame。

## 変種analysis + 136 distinct-appearance 完成 (2026-07-24)
実sha比較(55変種 vs 124本体 texture):
- ★43=本体とtexture同一(sha一致)=視覚重複★: enemy stat変種(EDEV/EAIR/ekuw/eogr等)。fbxは別exportだが同geometry+同tex→appearance=本体と同一。→gap台帳: 『既存model stat変種、視覚価値ゼロ、必要時同pipeline生成可』。
- ★12=独自texture(新見た目)=生成済★: cemg/ebak/ecen/edig/edor/eleo/emoj/epen/epic/epiy/escu/eved。distinct appearance確認(白ghost変種/灰knight/黄wizard/青penguin等)。
- texture欠損=ゼロ。

### 結論
- ★gallery= 124 base + 12 new-look = 136 distinct-appearance model 網羅 = 178の全distinct visual到達★。
- 178 literal count差=43(視覚重複stat変種)。count重視なら生成可だが視覚価値ゼロ(padding)ゆえ台帳化推奨。
- 生成prefab総数=136(Resources/ViseNpc/*_Avatar.prefab)。
