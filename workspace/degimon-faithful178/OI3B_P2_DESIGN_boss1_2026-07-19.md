# OI-3b (p2) 設計doc: R2' — form-appropriate SEQ音楽の選択・再生model(boss1 単一推奨、gate①上申用)

status: ★R2'a=CLOSE(boss1委譲検収 land、2026-07-19 09:0x)★ — a1-a6=f1b land(6f57949/98ddd2e/993cec2/1dcbf3d/2894eb4/abeed2b、push HOLD)。検証=★全条項literal充足★(leaf13/13・h1=switched500⇔[AUDIO-PLAY headless]500 1:1+例外0・h2=OFF非生成直接確認+wirenoaudio対照+audioonly loud no-op・h3=care3系統+CutsceneVerify178+ON audio sweep desync0+NEW warning0)。review=finding-A(clamp方向、worker1)/finding-B(headless非互換、worker3)を land前捕捉→a5/a6で解消、残DIFF0。R2'b(capture)実行中。完成claim=v4 user live(耳)まで凍結。
(gate①GO=PRESIDENT 2026-07-19 08:50) — R2'a/D-A=(ii)実機capture採用/mapping RE接地/platform事項/prereg h1-h3=全採用。★補足=R2'b captureの各wavにprovenance台帳(どのsavestate/操作でどの(record,variant)を発火させたか+emulator audio設定(sample rate/正規化有無))必須★。
★接地更新(worker3先出し、08:40)★: SEQ section header word0=header size=entry数×4。★scene 0x21=word0 0x10→4 entry(variant{0,1,2,3}全存在、offsets 0x10/0x1828/0x33b8/0x3fe0、各pQES)★/scene28=2 entry。variant→SEQ mapping=CD静的抽出で全網羅(multi-form save不要、OI3A_V2の残gapも解消)。
(初版status: 上申 08:4x)
入力=p1①(CD record=FAALL.VHB確定、worker1)/p1②(byte-exact確証: at-rest⇔CD 11684B 100%一致+FAALL構造=33 scene×39 sector、worker3)/p1③(提示層survey+audio infra=ゼロ、worker2)/p1④(variant→offset[variant]→SsSeqOpen+play、error文字列pin、worker1)。全てboss1裏取り済(FAALL文字列/SEQ error文字列=実bytes確認)。

## 0. 正premise(byte-exact接地済の全chain)

★0x66 = 『partner form-class に応じた SEQ音楽(BGM/fanfare)の variant 選択再生』★
```
[R1 land済] DF70(2)→E104→selector: form-class→(record=0x21固定, variant∈{0,1,2,3})→switcher(同一no-op/変更)
[R2'対象]  switcher change時: FAALL.VHB record#(record-1)=39 sector chunk
           {16B header + VAB(音色→SPU) + SEQ container([SEQoff,SEQend))→0x8015102c}
           → finalize: offset[variant(clamp)] の SEQ を SsSeqOpen → play(vol 0x50/0x50)
```
- FAALL.VHB=33 scene×39 sector EXACT(file size一致)。scene28実測=RAM⇔CD 100%一致=機構確証。
- ★scene 0x21 の variant offset table+各SEQ実体=CD file byte 0x270000 chunk(SEQ section[0xa430,0xf99c))から★静的抽出可能★(run不要)=mapping RE接地(条件3)。

## 1. ★単一推奨=R2'a(配線+検証)/R2'b(実audio asset)の2段★

### R2'a: 再生配線+log次元検証(本設計の実装scope)
- 新flag DEGIMON_SCENE_AUDIO=1(既定OFF。WIRE=1前提、単独ON=loud no-op)。
- ★AudioManager新設(最小層)★: R1 SceneSwitch の switched event を購読→(record,variant)に対応する provision済 audio asset(StreamingAssets/audio/scene33_v{n})があれば AudioSource で再生、無ければ ★[AUDIO-PLAY missing-asset] loud log(gap可視化、再生なし)★。
- 忠実model点: variant clamp(offset table count基準=§0)/同一(record,variant)継続中は再start しない(EXE no-op対応)/vol既定=EXE実測 0x50/0x80=62.5% を Unity volume へ接地(§3)。
- ★provision loader★: StreamingAssetsパターンの形踏襲(File読取→AudioClip)。asset自体はR2'bで供給(R2'aは0件でも動作=missing-asset log)。
- 検証=★log次元★(h1-h3、§5)。音の実在判定はv4 user liveの耳(次元分離、PRESIDENT付記)。

### R2'b: 実audio asset生成(feasibility spike先行、★設計判断点D-A★)
- 対象=scene 0x21×variant(count=CD静的抽出で確定、最大4)。
- ★D-A 単一推奨=(ii)DuckStation実機audio capture★: 原盤で当該(scene,variant)を再生させ audio出力をcapture→wav/ogg化=★実機出力そのものが忠実性oracle(renderer発明ゼロ)★。対抗(i)=SEQ+VABのoffline render(renderer tool依存=発明/忠実度検証の別問題を生む)。
- spike: DuckStationのaudio dump可否+当該scene再生の到達手順(worker3 infra)→不能なら(i)へfallback再上申。
- v4 user live=R2'b asset投入後(『正しい音が鳴る』)。

## 2. mapping(条件3=推測禁止)
- variant→SEQ対応=★CD静的抽出★(scene33 chunkのoffset table+SEQ実体、worker3のp1②手法で即実施可)。faall_N.wav(VAB sample rip)は使用しない(曲でない)。
- form→variant=R1 land済の§1表(byte-table含む)=検証済。

## 3. audio導入の最小platform事項(PRESIDENT付記 08:40)
- AudioListener: 実装時にcamera既設を確認、無ければFieldCameraRigへ新設(1個原則)。
- 音量既定: EXE play vol 0x50(/0x80)=62.5%→AudioSource.volume=0.625(RE接地値。master調整はuser裁量域として別)。
- ★OFF(AUDIO≠1)=AudioManager/AudioSource を生成しない★(無音再生でなく非生成=強OFF-inert)。
- headless(batchmode): audio API no-opでも h系検証はlog次元で判定=green設計。音の実在=v4 user liveの耳(次元分離)。

## 4. v4 user live checklist(条件2、R2'b後に数値確定)
- ★『何を聞けばPASSか』対応表★: partner form→期待variant(§1表)→期待SEQ(CD抽出後に曲名/性質を記載、capture assetと同一物)。
- 操作手順: flags ON(DRIVER+WIRE+AUDIO)でboot→care/dialogue操作で0x66経路到達→切替時に対応曲が鳴る/同一(record,variant)継続では再startしない、を耳で確認。
- 判定=対応表と聞こえた曲の一致(音の実在はここで初めて判定=次元分離の終端)。

## 5. (p4級) prereg(実装着手時固着)
- h1: ON時 [AUDIO-PLAY](or missing-asset)event が [SCENE-SWITCH] switched event と1:1(log次元)。variant clamp=offset count基準。
- h2: OFF=★AudioManager/AudioSource非生成の直接確認★(FindObjectsOfType=0件)+bit不変+[AUDIO-*] 0件。AUDIO単独ON=loud no-op。
- h3: 非退行=care 3系統+CutsceneVerify178(FSZ-OFF)+BootChainVerdict/PerHopTrace(FSZ ON、OI-10対応表準拠)+full sweep desync0+ON warning⊆OFF。
- 完成claim=v4 user live(耳判定)まで凍結。

## 6. 割当・OI
- 先行小タスク: scene33 SEQ offset table+実体のCD静的抽出(worker3、p1②手法)=variant count確定+R2'b対象list。
- R2'a実装=worker2/review=worker1/検証=worker3。land=委譲検収(D4同条件)。
- R2'b spike=worker3(D-A裁定後)。
- OI-11: 0x66以外のscene-id(1-32)のuser可視意味(scene28=field常駐BGM等)=別arc。OI-9(cur-slot writer/gp-0x6dcc)=継続。
