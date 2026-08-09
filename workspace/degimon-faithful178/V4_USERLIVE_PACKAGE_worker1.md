# V4 user live 依頼 package — OI-3b scene audio(form→variant→音) — worker1 確定版

**date**: 2026-07-19 / worker1 / ★doc-only(tree 非接触)、v4 準備(iii)★
**対象**: f1b HEAD=d28852b(R1 land r1-r5 + R2'a a1-a6 + R2'b provision 352e9b0 + r7 honest-mark 8d887e0 + v4 hook 204db16 + P1 harness 保全 d28852b)
**目的**: user 実機(耳)で「partner form に応じた variant の SEQ 音楽が 0x66 切替時に鳴る/同一継続で再start しない」を判定=完成 claim 凍結解除の終端。
**claim 規律**: 各行 観測(commit/doc/code/provenance 直読)/推論/未検証 を明記。裏取り不能行は ★未検証★。

---

## v4 実行 前提(状態、2026-07-19 確定: ★全前提充足=v4 実行可★)

★本 package は確定版。全 chain(0x66→form→variant→audio)を play-mode で検証 PASS(OI3B_V4_HOOK_PREREG (A)-(E)、worker3)。asset・hook・到達手順・実測 variant すべて充足★:
1. ★capture asset = provision 済(f1b commit 352e9b0)★(観測、boss1 独立 sha256 検証済): `unity/Assets/StreamingAssets/audio/scene33_v{0-3}.wav`(+ `.provenance.txt` + `README.md` 台帳)。sha256 4/4 一致(v0 ea50aa8f / v1 9476c23e / v2 bc9c2116 / v3 3e29c465、source⇔f1b blob⇔f1c 3点一致)。
2. ★hook = V4PlaySectionHook.cs(sha256 0e08fed5(commit 204db16、SETVAR診断付)、検収 PASS)★。DEGIMON_V4_PLAYSECTION=22:5 で F9→PlaySection(22,5)→dialogue→Space 送り→0x66@pc0x90 発火(§2)。
3. ★全 chain play-mode 検証 PASS(A-E)★: worker3 run(v2 dll 39d1783d、22:5+Space×15)で [V4-HOOK]→[SCENE-SWITCH] variant=1→[AUDIO-PLAY] scene33_v1(len 97.31s)実再生。実測 eForm=0x00→variant1=§1 表接地一致(§3)。SETVAR 不要。
4. ★slot reconcile 数値 gap / F-1 diverge = v4 と独立★(§4)。v4 の耳判定は対応表 §1(EXE verbatim)+ 検証済 chain で成立。
→ ★完成 claim は user live 実聴まで凍結(v4(iii))=本 package の耳判定で解除★。それ以外の前提は全充足。

---

## 1. form → variant → 期待音 対応表(正本引用、各行 source 明記)

### 1-A. variant 選択 rule(EXE 0x80105be4 verbatim、6 条件)
正本: `OI3A_Q2_DESIGN_boss1_2026-07-19.md §1`(worker1 全分岐読切 + boss1 spot-check 一致)/ code `unity/Assets/Scripts/State/GameState.cs SelectSceneVariant`(land sha=04e5d96=r5、f1b HEAD d28852b)。record は全 site **0x21 固定**、form が決めるのは **variant**(観測)。

| 条件(check-moment、§4 前提) | variant | EXE 分岐(観測) | source |
|---|---|---|---|
| form == 0x73 | 3 | 0x80105C4C | GameState.cs:531 / OI3A_Q2 §1 |
| slot∈[2,0xa) かつ flag(gp-0x6bf4)==1 | 0 | 0x80105C9C | GameState.cs:534 / OI3A_Q2 §1 |
| slot∈[2,0xa) かつ form<0x43 or form≥0x70 | 1 | 0x80105D6C | GameState.cs:535 / OI3A_Q2 §1 |
| slot∈[2,0xa) かつ 0x43≤form<0x70 | ★byte-table[form-0x43]★(§1-B) | 0x80105D44 | GameState.cs:536 / OI3A_Q2 §1 |
| slot<2 or slot≥0xa かつ flag==1 | 0 | 0x80105D94 | OI3A_Q2 §1 |
| slot<2 or slot≥0xa かつ else | 1 | 0x80105DAC | OI3A_Q2 §1 |

★flag(gp-0x6bf4)の決定=scenario work buffer byte [0x801639D7]==1 の時のみ★(観測: OI3B_FIRE_GATING §5、writer 0x801072ac 単一)。→ 通常 partner form 経路では flag≠1=variant は form 由来。

★注記(smoke finding 1、重要)★: 表 1 行目 `form==0x73→3` の form は **curForm(0x73 check 側=現 dialogue actor slot)**。一方 **DEGIMON_V4_FORM が設定するのは eForm(=Partner.DigimonId、range dispatch 側)=別入力**。∴ FORM=0x73 は eForm≥0x70→variant1(≠3)。variant3 到達には curForm=0x73 が必要(hook 手段なし、§3-B/§4)。

### 1-B. scene variant byte-table(EXE 0x801389E8、45 entry、form 0x43..0x6F、verbatim)
正本: `GameState.cs:509-513`(land r2=3dc46d1、r5=04e5d96 で file HEAD)。値=全 0x01/0x02(観測)。★boss1 実 bytes + worker2 EXE 直読一致=発明ゼロ★(GameState.cs:508 コメント)。

```
form:  43 44 45 46 47 48 49 4A 4B 4C 4D 4E 4F 50 51
var :  02 02 02 02 02 01 02 02 02 01 02 02 02 02 02
form:  52 53 54 55 56 57 58 59 5A 5B 5C 5D 5E 5F 60
var :  02 02 02 01 02 02 01 01 01 01 01 02 02 02 02
form:  61 62 63 64 65 66 67 68 69 6A 6B 6C 6D 6E 6F
var :  02 02 02 01 02 02 02 01 01 01 02 01 02 02 02
```
- variant=01 例外 13 件: form 0x48/4C/55/58/59/5A/5B/5C/64/68/69/6A/6C(観測: 上表の 01 位置)。他は 02。
- ★実効 variant 域★: byte-table→{1,2}、flag→0、0x73→3 = variant∈{0,1,2,3}(観測)。scene33 の CD variant count=4(worker3 p1② 静的抽出、OI3B_P2_DESIGN §接地更新)と整合。

### 1-C. variant → 期待音(中立記述、★曲名/内容の断定は凍結★)
★曲名・内容(fanfare/BGM 等)は断定しない=中立記述のみ★(boss1 指示 + provision 台帳 content_claim=保留、PRESIDENT 指定。v3 曲説等は推論 label=書かない)。
- variant n の期待音 = ★provision 済 runtime asset `unity/Assets/StreamingAssets/audio/scene33_v{n}.wav`(観測: 352e9b0)= 実機(DuckStation)forced-injection capture された「SEQ variant n」★。台帳=`unity/Assets/StreamingAssets/audio/README.md`、個別 provenance=`scene33_v{n}.provenance.txt`。
- ★provenance 台帳(観測、README.md + 各 .provenance.txt)★: 各 wav に fired(record=0x21,variant)/injection(0x801639D7 経由=FIRE_GATING §5 determinant)/source savestate sha/DG.SCN section offset/emulator audio 設定を完全記載。audio format(全 variant 共通)= 44100Hz / 2ch / s16 PCM(LE) / normalization=NONE(raw SPU reverb-mix)。SceneAudioLoader が PCM WAV parse。
- ★content_claim=保留(台帳明記)★: 曲の内容/identity 断定は **user 実聴 + form→曲対応実測(=本 v4)** まで。変数 3=boss 曲等は推論 label=本表に書かない。
- 機構的裏付け(観測、OI3B_P1_CDRECORD §p1④): variant → FAALL.VHB offset table[variant] → SEQ(音楽シーケンス)を SsSeqOpen+play(vol 0x50/0x80)。曲の identity は capture asset が oracle(台帳が追跡可能性を永続化)。

### 1-D. partner form → variant 早見(user 視点、slot2=partner)
正本: resolver `GameState.cs:517-522`(slot2→Partner.DigimonId)+ §1-A/B。
- partner の form-id(DigimonId)= §1-A/B の form として variant を引く。例(観測、byte-table 直引き): partner form=0x48 → variant 1 / form=0x43 → variant 2 / form=0x55 → variant 1 / form=0x50 → variant 2。
- ★form が 0x43..0x6F 域外(<0x43 or ≥0x70)→ variant 1★。form==0x73(特殊)→ variant 3。

---

## 2. user 操作手順(0x66 経路到達 → form 切替)

### 2-A. boot(flags ON)
★build/script(観測、worker3 standalone smoke PASS)★:
- build=`workspace/build/DegimonLive/DegimonLive.x86_64`(dll sha=ae30cf53、hook v3=form flag 取込)。
- 起動 script=`workspace/f1c/run_v4_scene_audio.sh`(4+1 flag/中央配置/log tee)。

★flag(観測: DialogueRuntime.cs:453/459/463、WIRE は DRIVER 前提・AUDIO は WIRE 前提)+ v4 hook flag★:
```
DEGIMON_SCENE_DRIVER=1 DEGIMON_SCENE_WIRE=1 DEGIMON_SCENE_AUDIO=1 DEGIMON_V4_PLAYSECTION=22:5 [DEGIMON_V4_FORM=<hex>] <build 起動>
```
- DRIVER≠1 で WIRE=1 → 0x66 case 非到達 loud warning(DialogueRuntime.cs:461)。WIRE≠1 で AUDIO=1 → audio no-op loud warning(:465)。
- DEGIMON_V4_PLAYSECTION=entry:key(★v4 確定=22:5★)= v4 hook 起動(観測: V4PlaySectionHook.cs、flag 無=GameObject 非生成=OFF-inert)。
- ★DEGIMON_V4_FORM=hex(例 0x43 or 43)= partner form(Partner.DigimonId=slot2=eForm)を強制設定★(観測: V4PlaySectionHook.cs:91-110)。variant を変えて聞く時に指定(§1-B、例 variant2=0x43)。無指定=boot 実測 form(=id 0→variant1)。
- ★DEGIMON_V4_SETVAR = 診断用(var dump/強制)、v4 手順では不要★(worker3 検証で var-forcing 不要=§5 は dialogue 送りで 0x66 到達、H4)。

### 2-B. 0x66 発火 操作列(★確定: F9→dialogue 送り★)

★確定手順(worker3 全 chain 検証 PASS、OI3B_V4_HOOK_PREREG §5 再評価、v2 dll 39d1783d)★:
1. §2-A の flags(DRIVER+WIRE+AUDIO)+ **DEGIMON_V4_PLAYSECTION=22:5** で起動 → 起動時 `[V4-HOOK] 起動` log(flag 無=hook GameObject 非生成=OFF-inert)。
2. **field load 到達後に F9 押下**(KeyCode.F9)→ `GameManager.Instance.Dialogue.PlayMapSection(22, 5)` 発火(field 未到達で F9=`[V4-HOOK] field load 前` warning=再押下)→ entry22 §5(pc 0x6C)開始で dialogue 表示。
3. **Space で dialogue を送る**(=natural user 操作、dialogue-wait を進める)→ OPTRACE: pc 0x6C→0x6E→0x8A→0x8C(0x67 FRAME_YIELD)→**pc 0x90 で 0x66 発火**(§5 は JUMP で逸れない=分岐/return 無し、worker1 静的解析的中)。
4. ★実 chain(full path)★: PlaySection→walker→**0x66→SelectSceneVariant→form 由来 variant→SceneSwitch→SceneAudioManager** → `[SCENE-SWITCH] record=0x21 variant=N switched @pc=0x90` → `[AUDIO-PLAY] scene33_v{N}(vol=0.625, len>0)` 実再生。
- ★SETVAR(var-forcing)不要★: §254(22:254)は pc 0x50 JUMP_D→scenario49:section36(★DG.SCN 原本に不在=dead-end no-op、忠実★)で 0x66 未到達=不適。§5(22:5)は dialogue 送りで到達する正路。
- ★form 切替観測(§3 (b) 判定用)★: partner form(slot2=Partner.DigimonId)を variant の異なる form へ変えて F9 再実行 → 異なる variant(§1-D)。同一 form → 同一継続=再start せず((c))。具体的 form 操作=§1-D。
- ★log tag★: `[V4-HOOK]`(起動/F9/warning)。DRIVER/WIRE/AUDIO 未設定で F9=chain 不完全 warning。
- 代替参考: worker3 capture の source savestate(SLPS-01797_3.sav)+ forced-injection = DuckStation 原盤 capture 用(Unity remake の v4 手順でなく asset 生成側、観測: scene33_v{n}.provenance.txt)。

#### 自然経路(NPC talk)= v4 scope 外の将来 work
★census は force-play ゆえ自然経路の実測 log は存在しない。自然経路(field で NPC/event を trigger → entry load → 0x66)の precise 化は **NPC placement table RE**(entry→NPC/map 対応、V4_REACH_PATH §6 gap)が必要=v4 scope 外の将来 work★。v4 の耳判定は確定手順(F9→dialogue 送り)で成立。

---

## 3. 「何を聞けば PASS か」checklist

log 文字列は判定補助(観測: 下記行番号)。★音の実在判定は user の耳=次元分離の終端(PRESIDENT 付記)★。
★検証済 baseline(worker3、22:5+Space、OI3B_V4_HOOK_PREREG (A)-(E) 全 PASS)★: play-mode 実測 eForm=0x00(partner id=0)→ §1 rule(eForm<0x43→1)→ **variant=1** → `[SCENE-SWITCH] record=0x21 variant=1 switched @pc=0x90` → `[AUDIO-PLAY] scene33_v1(vol=0.625, len=97.31s)` 実再生。= §1 表と接地一致。user はこの baseline から form を変えて (b) を判定。

| # | 判定項目 | PASS 基準 | 補助 log(観測) |
|---|---|---|---|
| (a) | 切替時に音が鳴る | 0x66 form 切替(variant 変化)時に SEQ 音楽が再生開始 | `[AUDIO-PLAY] scene33_v{n}(vol=0.625…)`(SceneAudioManager.cs:73)+ `[SCENE-SWITCH] …→ switched`(DialogueRuntime.cs:1179)。★検証済=variant1/scene33_v1/len97.31s★ |
| (b) | form ごとに異なる variant の曲 | §1 表通り、form-class が変わると異なる variant(=別 asset)の音になる | [AUDIO-PLAY] の variant={n} が form により変化 |
| (c) | 同一継続で再start なし | 同一(record=0x21,variant)を再度通しても曲が頭から鳴り直さない | `[SCENE-AUDIO] (record=…,variant=…)同一継続=再start せず`(SceneAudioManager.cs:58)/[SCENE-SWITCH]…no-op(DialogueRuntime.cs:1188) |
| (d) | 音量違和感(参考) | 極端に大/小でない(EXE 実測 vol 0x50/0x80=62.5% 接地=0.625) | vol=0.625(SceneAudioManager.cs:13、RE 接地) ※master 調整は user 裁量域 |
| (e) | FAIL 時に報告してほしい情報 | — | ★どの partner form(DigimonId)/どの操作(進化・ケア・dialogue)/期待 variant(§1 表)/実際に鳴った・鳴らなかった/[AUDIO-PLAY] or [missing-asset] log の variant 値★ |

★missing-asset(asset 未投入)の場合★: `[AUDIO-PLAY missing-asset] scene33_v{n}.wav 不在`(SceneAudioManager.cs:76)= 実音なし=(a)は N/A。この log が出たら「asset 未投入」を報告(★但し scene33_v0-3 は provision 済ゆえ通常出ない★)。

### 3-B. form 切替観測手順((b) 判定用、DEGIMON_V4_FORM=hex、★worker3 3点 smoke 実測★)
★手段=DEGIMON_V4_FORM=hex で partner form(eForm)を設定→F9→Space。3点 smoke(standalone、OI3B_V4_STANDALONE_SMOKE)実測:
| DEGIMON_V4_FORM | 実測 eForm | 実測 variant | AUDIO-PLAY | §1 rule |
|---|---|---|---|---|
| (無) | 0x00 | 1 | scene33_v1 | eForm<0x43→1 ✓ |
| 0x43 | 0x43 | 2 | scene33_v2 | byte-table[0]→2 ✓ |
| 0x73 | 0x73 | 1 | scene33_v1 | eForm≥0x70→1 ✓ |
= 3/3 §1 rule 一致=selector 忠実。
partner form(slot2=Partner.DigimonId)を variant の異なる form へ変えて F9 再実行 → 曲が変わることを耳で確認:
- **variant1 を聞く(baseline)**: DEGIMON_V4_FORM 無 or 0x00-0x42 or ≥0x70 → variant1 → scene33_v1(検証済)。
- **variant2 を聞く**: **DEGIMON_V4_FORM=0x43**(byte-table[0]=2)→ variant2 → scene33_v2(★smoke 検証済★)。他の variant2 form=0x44/0x50/0x60 等(§1-B の 02)。
- ★**variant3 は本 hook で到達不能=v4 scope 外**★: variant3 は §1 表 ①`curForm==0x73` 分岐(0x73 check 側)。**DEGIMON_V4_FORM が設定するのは eForm(別入力)**ゆえ、FORM=0x73 は eForm≥0x70→**variant1**(実測、boss1 予測 REFUTE=§1 rule 通り)。variant3 の full-chain exercise は curForm=0x73 注入が必要(hook 拡張=F-1 解決後 follow-up、§4)。
- ★同一 form 再実行 → 同一継続=再start せず((c))★。form 変更=DEGIMON_V4_FORM 再指定(実 play では進化/ケア変化)。

### 3-C. v4 判定 scope(明記)
- ★(a)切替時発音 + (c)同一継続 non-restart + (b)form 別 variant = **variant1(FORM 無/0x73)と variant2(FORM=0x43)で判定**★(full-chain 検証済、§3-B)。
- ★variant0(flag=1 経路)/ variant3(curForm=0x73 経路)= full-chain では未 exercise(hook 手段なし)★。ただし **audio pipeline 層(P1 harness)は variant0-3 全 4 wav の load+play を PASS 済(OI3B_P1)=asset 側は検証済**。full-chain の form→v0/v3 分岐到達のみ follow-up(§4)。
- ∴ v4 耳判定 = variant1/2 の form-derived 切替 + 発音 + non-restart で成立。v0/v3 の音自体は P1 で検証済(asset authentic)。

---

## 4. 注意書き(対応表の前提 = reconcile CLOSE)

- ★本 fire 文脈の対応表は「check-moment 単一 slot」前提★(推論+実測、OI3B_SLOT_RECONCILE §5 判定 (i)-primary): 0x73 check と range dispatch は実行時に同一 partner actor へ解決(worker3 injection 因果証明: slot8 に form=0x73 注入→variant3)。∴ user 視点では「partner form 一つ」で variant が決まる(§1-D)。
- ★R1 code(GameState.cs r5)は two-slot 分離(curSlotForm と eForm 別引数)で書かれている★(観測: GameState.cs:529)。これは reconcile 前の finding-1 modeling。★実測との差は honest-mark 済(handoff §3/§4)で、通常 partner 経路では curSlotForm と eForm が同一 actor=挙動一致ゆえ v4 判定に影響なし★(推論: 単一 actor なら両引数同値→同一 variant)。
- ★数値 gap([0x80146765]=5 vs 0x73 check=slot8)= follow-up F-1 として起票済=v4 blocker で【ない】★(handoff、OI3B_SLOT_RECONCILE §8): reconcile は CLOSE(H-a=check-moment 単一 slot 確定)。idx 5→8 更新機構 RE(F-1)の結果次第で R1 amendment(SelectSceneVariant を eForm 単一化)裁定だが、★v4 の耳判定(§3)はこの F-1 と独立=対応表 §1 は EXE verbatim ゆえ v4 実行可★。
- ★全 chain 検証 PASS 済=package 確定★: worker3 run(v2 dll 39d1783d/standalone ae30cf53、22:5+Space、OI3B_V4_HOOK_PREREG (A)-(E) + standalone 3点 smoke 全 PASS)で hook→dialogue 送り→0x66@pc0x90→[SCENE-SWITCH]→[AUDIO-PLAY] 実再生を確認。form-derived variant=§1 rule 3/3 一致(v1/v2/v1)。SETVAR 不要。自然経路=v4 scope 外(NPC placement RE 待ち)。§1-C asset=provision 済(352e9b0)。→ ★v4 実行可、全前提充足。残るは user 実聴(耳判定)のみ=完成 claim 凍結解除の終端★。
- ★variant3(curForm=0x73 経路)= full-chain 未到達=v4 scope 外 follow-up★: DEGIMON_V4_FORM は eForm のみ設定(curForm 不変、smoke finding 1)。variant3 full-chain exercise には curForm=0x73 注入(hook 拡張)が必要=F-1(b) 系の slot 機構と関連。asset 側 v3 は P1 で検証済(authentic)。

---

## 付: source 一覧(裏取り済)
- OI3A_Q2_DESIGN_boss1_2026-07-19.md §1(variant 対応表 6 条件)
- GameState.cs SelectSceneVariant/SceneVariantTable/ResolveSlotForm(land r5=04e5d96、file HEAD d28852b)
- DialogueRuntime.cs:453-466(flag 名/前提)/1179-1190([SCENE-SWITCH] log)
- SceneAudioManager.cs:13/58/66/73/76(vol/log 文字列)
- OI3B_FIRE_GATING_worker1.md §4/§5/§7(0x66 到達・variant determinant・注入 6 軸)
- OI3B_P1_CDRECORD_worker1.md §p1④(variant→SEQ 機構)
- OI3B_SLOT_RECONCILE_worker1.md §5/§8(単一 slot 前提・数値 gap=F-1 起票)
- OI3B_P2_DESIGN §接地更新(scene33 variant count=4)
- ★provision 済(観測、352e9b0)★: unity/Assets/StreamingAssets/audio/scene33_v{0-3}.wav + .provenance.txt + README.md 台帳(sha256 4/4 一致=worker1 独立再確認 + boss1 3点検証)
- ★確定★: §2-B 操作列(F9→dialogue 送り Space→0x66@pc0x90)= worker3 全 chain 検証 PASS(OI3B_V4_HOOK_PREREG (A)-(E)、v2 dll 39d1783d)
- V4PlaySectionHook.cs(sha256 0e08fed5、commit 204db16、検収 PASS)= hook 実物
- V4_REACH_COND_worker1.md(§5 unconditional path 静的解析)/ V4_REACH_PATH_worker1.md(112 entry 列挙)
