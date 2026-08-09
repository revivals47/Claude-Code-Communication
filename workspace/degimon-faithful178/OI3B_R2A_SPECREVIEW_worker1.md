# OI-3b R2'a spec 照合 review — worker1

**date**: 2026-07-19 / worker1 / ★read-only(f1b 非編集)★
**対象**: f1b — a1=6f57949 / a2=98ddd2e / a3=993cec2 / a4=1dcbf3d
**設計正本**: OI3B_P2_DESIGN(§1 R2'a / §3 platform / §5 prereg h1-h3)
**RE正本**: OI3B_P1_CDRECORD_worker1.md §p1④(finalize 0x800cf29c clamp/SsSeqOpen)
**手法**: 全 path trace(1 path OK 判定禁止)。DIFF=実 code paste。

---

## 判定: ★APPROVE(条件付き)★ — 観点 2-5 PASS、blocker 0、★finding-A 1件(variant clamp 方向逸脱=EXE→0 / C#→count-1、harness も codify)★

R2'a は強 OFF-inert・trigger 配線・platform・a4 scope で spec-compliant。★1件、variant clamp の方向が EXE(→0)と C#(→count-1)で逆=verbatim 逸脱。0x66 の scene33 path(variant 0-3 < count 4)では unreachable ゆえ非 hard-blocker だが、a4 harness が count-1 を正と assert=deviation を緑が mask★。

---

## 観点1: 忠実 model(clamp / same-check)★finding-A★

### ★finding-A: variant clamp 方向が EXE と逆★
- ★EXE finalize 0x800cf29c(p1④、実 disasm)★:
```
800CF2B8 v1 = *(0x8015102c)>>2 = count
800CF2C4 sltu at, variant, count        ; unsigned 比較
800CF2C8 bnez at, 0x800cf2d4            ; variant < count → skip
800CF2D0 sh zero, -0x6da0($gp)          ; ★else variant = 0(clamp to 0)★
```
- ★C# SceneAudioModel.Decide★: `clamped = variant<0?0 : (variant>=count? **count-1** : variant)`。→ ★variant>=count を **count-1** に clamp(EXE は **0**)★=逆方向。
- ★a4 harness も codify★: `m2.Decide(0x28,3).Variant == 1`("0x28 count2 variant3→clamp=1")= count-1 を正と assert → ★deviation を緑が catch できず mask★。
- ★reachability★: 0x66 の record=0x21 固定(count=4)、variant=SelectSceneVariant で {0,1,2,3}(max 3 < 4)ゆえ ★variant>=count は 0x66 scene33 path で unreachable=観測 divergence 無し★。但し verbatim 逸脱 + 発明(count-1 は EXE 非接地)+ harness mask。
- ★severity/推奨★: 非 hard-blocker(unreachable)だが ★(a)clamp を 0 へ修正(EXE 一致)+ a4 harness も 0 を assert、または (b)『count-1 は R2'a 便宜、EXE は 0、0x66 では unreachable』と明記★=発明ゼロ厳密化 + harness mask 解消。負値 clamp(variant<0→0)は EXE の sltu(unsigned で負=huge→0)と一致=OK。

### same-check(EXE no-op 対応)= PASS
- Decide: `play = !(record==CurRecord && clamped==CurVariant)`=同一(record, clamped)継続で shouldPlay=false=再start せず。EXE: switcher(0x800cfdf0)が同一 scene で no-op(OI-3a §9)+ finalize は switched 時のみ。★同一継続=非 restart=EXE no-op 対応 PASS★。clamp 後の same-check(0x28 variant2/3 共 clamp→同一扱い)も一貫。

### VariantCount(CD 静的)= PASS
- scene33(0x21)=4 / scene28(0x28)=2 / 他=1(gap)。★worker3 p1② CD 静的抽出(scene33=word0 0x10→4 entry offsets 0x10/0x1828/0x33b8/0x3fe0)と一致=推測なし★。

---

## 観点2: 強 OFF-inert(AudioManager/AudioSource 非生成)= PASS

- ★lazy-create★: DialogueRuntime:1181-1184 `if(_sceneAudioOn){ if(_sceneAudio==null) _sceneAudio=new SceneAudioManager(); _sceneAudio.OnSwitch(...) }`=★AUDIO ON かつ sw==2 時のみ new★。OFF(_sceneAudioOn=false)→ SceneAudioManager 非生成(null 維持)。SceneAudioManager ctor で初めて GameObject+AudioSource 生成=OFF は AudioSource も非生成。
- ★[AUDIO-*] / [SCENE-AUDIO] log★: 全て SceneAudioManager 内(ctor/OnSwitch)=生成後=AUDIO gate 内。OFF=0 件。
- ★AUDIO 単独 ON(AUDIO=1, WIRE=0)★: 463-465 loud warning + B4 wire 全体が `if(_sceneWire)` gate ゆえ SceneSwitch/OnSwitch 非到達=実 no-op。✓
- ★SceneAudioModel(leaf)も _sceneAudio(=manager)の field ゆえ OFF 非生成★。→ 強 OFF-inert 成立(h2 の FindObjectsOfType=0 は Unity-run 確認)。

## 観点3: platform 事項 = PASS

- ★AudioListener 1個原則★: EnsureListener=`FindObjectOfType<AudioListener>()!=null → return`(既存尊重)/ 無ければ Camera.main に AddComponent(1個)/ Camera.main 無=loud warning(headless)。✓
- ★vol=0.625 接地コメント★: `SceneVolume=0.625f // EXE play vol 0x50(/0x80)=62.5%(RE 接地)`。✓ (0x50/0x80=80/128=0.625)。
- ★headless=log 次元 green★: Camera.main 無時 warning + audio API no-op(AudioSource.Play は headless で無音 no-op、log は出る)=log 次元判定 green 設計。✓

## 観点4: trigger 配線(switched 枝のみ)= PASS

- OnSwitch 呼出=DialogueRuntime:1177 `if(sw==2){ ... _sceneAudio.OnSwitch(0x21,variant) }`=★switched(sw==2)枝のみ★。sw==1(no-op)/sw==0(invalid)では非発火。→ h1(1:1)の code 面: [SCENE-SWITCH] switched(sw==2 の log)と OnSwitch(→[AUDIO-PLAY|missing-asset])が同一枝=1:1。同一継続(sw==1)は audio 非発火。✓
- OnSwitch 内 same-check(Decide)で更に「同一(record,variant)継続=再start せず」= sw==2 でも clamp 後同一なら [SCENE-AUDIO] 同一継続 log(再生なし)=二重の no-op 保護。

## 観点5: a4 harness assert 範囲 + WAV parser R2'b 前提

- ★a4(scene_audio_verify.cs)= SceneAudioModel(leaf)の clamp/same-check/VariantCount を実 assert★。h1(event 1:1)/h2(OFF 非生成 FindObjects=0)/h3(非退行)/WAV parse=§Unity-run へ明示委譲。
- ★WAV parser(SceneAudioLoader)= R2'b 前提明示★: a3 comment『R2'a 時点で asset 0 件=実 WAV run 未(R2'b asset 投入後に実発火)』+ harness §Unity-run『R2'a asset 0 件=実 WAV run 未』。→ ★missing-asset path(asset 不在→loud log)が R2'a の実動作、実 WAV 再生は R2'b=偽green 無し(実在しない asset を『鳴った』と主張しない)★。
- ★但し finding-A: a4 の clamp assert(`0x28 variant3→1`)が EXE(→0)と逆値を正と codify★=観点1 の deviation を harness が mask(clamp 検証が非 verbatim)。

---

## 5bis. a5 差分 review(finding-A 解消確認、2026-07-19、f1b HEAD=2894eb4)★finding-A RESOLVED★

boss1 裁定 (a) 修正の a5(2894eb4)を差分 review。

| 確認点 | 結果 | 根拠 |
|---|---|---|
| (1)clamp→0 が EXE 0x800CF2C4-D0 と 1:1 | ★PASS★ | `int clamped = ((uint)variant >= (uint)count) ? 0 : variant;`=EXE `sltu(unsigned) variant,count → bnez skip → sh zero`(範囲外→0)と 1:1。★unsigned ゆえ負値(=huge)も範囲外→0★=EXE sltu と一致。旧 count-1(発明)撤回 |
| (2)harness 訂正=mask 解消 | ★PASS★ | a4 の `Decide(0x28,3).Variant==1` → ★`==0`★(EXE verbatim)訂正。境界 `Decide(0x21,4).Variant==0`(count4=範囲外→0)追加。負値 `Decide(0x21,-1)==0`(unsigned)注記。clamp-same を clamp0 基準へ(0x28 variant2/3 共 範囲外→0=同一)。unreachable 注記追加。→ ★deviation を正と codify しない=mask 解消★。13/13 GREEN |
| (3)OFF-inert/他機能 不変 | ★PASS★ | a5 変更=SceneAudioModel.Decide(clamp 1 行)+ harness のみ。SceneAudioManager(lazy/OFF 非生成)/DialogueRuntime(trigger sw==2)/SceneAudioLoader(WAV)/platform=不変(a1-a4 の PASS 維持)。same-check は clamp 値変更に追随(scene33 variant 0-3 は範囲内ゆえ挙動不変、範囲外のみ →0) |

★finding-A = RESOLVED★: clamp を EXE verbatim(範囲外→0、unsigned)へ訂正、harness も →0 で mask 解消、unreachable(scene33 variant 0-3 < count 4)注記付き=忠実 safety として明文化。等価/類推でなく disasm 直読へ訂正(commit 帰属明記: a1 の count-1 発明を review が捕捉)。残 DIFF=0。

## 5ter. a6 差分 review(finding-B 解消確認、2026-07-19、f1b HEAD=abeed2b)★finding-B RESOLVED★

worker3 finding-B(ctor の GameObject/DontDestroyOnLoad/AddComponent=play-mode 専用 API→ editor/headless census で即例外→ h1 測定不能=設計§3『headless=log 次元 green』違反)の a6(abeed2b)修正を差分 review。

| 確認点 | 結果 | 根拠 |
|---|---|---|
| (1)isPlaying gate が ctor play-mode API 全部を cover(漏れ無し) | ★PASS★ | ctor の play-mode API 群=`new GameObject`/`Object.DontDestroyOnLoad`/`_go.AddComponent<AudioSource>`/`_src.playOnAwake`/`_src.volume`/`EnsureListener()` 全て `if(Application.isPlaying){...}` 内。★EnsureListener 自身も内部で Camera.main/AddComponent<AudioListener> を触るが gate 内呼出ゆえ headless 非到達=二重安全★。非 play=else 枝で `_go`/`_src`=null 維持 + `[SCENE-AUDIO headless]` log。★unguarded play-mode API=0★ |
| (2)headless時 [AUDIO-PLAY headless]発火=h1 1:1保持 | ★PASS★ | OnSwitch: `Decide`(clamp/same-check=SceneAudioModel、Unity 非依存)は headless でも従来発火(log 次元)。ShouldPlay 時 `if(_src==null){ LogWarning("[AUDIO-PLAY headless] ...") ; return; }`=★switched(sw==2)⇔audio-log の 1:1 を保持★(同一継続は "[SCENE-AUDIO] 同一継続" log)。例外を出さず census 到達可=h1 測定面 復旧 |
| (3)play時挙動+OFF非生成 不変 | ★PASS★ | play(isPlaying=true)=gate 内 block=a5 と bit 同一(GameObject/AudioSource/vol0.625/EnsureListener/log)。OnSwitch も `_src!=null` で headless 枝スキップ→従来 path(clip load/play or missing-asset)。★OFF=caller gate `if(_sceneAudioOn)`(DialogueRuntime)不変=SceneAudioManager 非 new=強 OFF-inert 維持★。SceneAudioModel 不変=leaf harness 13/13 維持 |

★finding-B = RESOLVED★: ctor play-mode API を EnsureListener 同型の `Application.isPlaying` gate で headless 非生成化(例外撲滅)、OnSwitch は `_src==null` で `[AUDIO-PLAY headless]` 発火=h1 の 1:1 を log 次元で保持。play時挙動/OFF-inert/leaf harness=不変。残 DIFF=0。★h1/h2/h3 の authoritative 判定=worker3 Unity-run(a6 で census 到達可能化)★。

## 6. 総括
- ★APPROVE(条件付き)★: 強 OFF-inert(lazy-new/OFF 非生成/AUDIO 単独 loud no-op)・trigger(switched 枝のみ、h1 1:1 code 面)・platform(AudioListener 1個/vol 0.625 接地/headless log 次元)・a4(leaf scope 明示、WAV=R2'b 前提、missing-asset=偽green 無し)= spec-compliant。same-check/VariantCount(CD 静的)= verbatim。
- ★finding-A=variant clamp 方向逸脱(EXE→0 / C#・harness→count-1)★: 0x66 scene33 path で unreachable(variant 0-3 < count 4)ゆえ非 hard-blocker だが ★発明ゼロ違反(count-1 は EXE 非接地)+ a4 harness が deviation を mask★=要決着((a)clamp→0 修正+harness→0 / (b)明記)。
- verification-dependency: h1/h2/h3 + WAV parse = worker3 Unity-run(設計 §5)。完成 claim=v4 user live(耳)。
