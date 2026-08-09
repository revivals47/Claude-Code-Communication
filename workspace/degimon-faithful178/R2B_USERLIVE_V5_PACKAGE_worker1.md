# R2B V5 user 実聴 package — scene33 音楽「途中で重くなる」根治版 — worker1

**date**: 2026-07-20 / worker1 / ★doc-only、V5 準備(user 起床後 PRESIDENT 代行起動できる完成形基準)★
**対象**: scene33 音楽 audio の音質 FAIL(user 症状「途中で重くなる」)を根治した re-capture 4本。
**claim 規律**: 各行 観測(commit/実測/直読)/推論/未確定。sha 欄=worker3 展開後に記入(★worker3 sha 待ち★)。

---

## 0. ★user 向け 1 行説明★

★「前回 scene33 の曲が途中で重くなったのは、capture(音を録る)時に **tool 側で CPU crash** が起きて音が止まり減衰していたのが原因でした。crash を 1 word の修正で根治し、全長 clean に録り直しました。ゲーム本体(remake)も原盤も無罪で、録音手順だけの問題でした。」★

---

## 1. 何が起きていたか(真因、観測ベース)

- 症状: scene33 の曲が fire+~13s から高音が消え「低域偏重=重い/もったり」化(R2B_WAV_DIAGNOSIS、centroid 2600→900Hz)。
- ★真因 = capture 採取時の **CPU crash**(Data Bus Error、EPC=0x800C9E3C、fire+10.4s)★。crash → BIOS 例外 spin → CPU 停止 → 音楽 SEQ 再生 tick も停止 → SPU が自律 drain(減衰)= 「途中で重くなる」の正体。
- crash の機構: 強制 capture 文脈(DG_RESTORE)で battle overlay の汎用 parser が **未初期化の work-buffer offset(1 word、stale garbage 0xFED20000)** を読み wild pointer 化 → 無効 addr 読取で crash。
- ★remake 本体・原盤 とも無罪★: 通常ゲーム進行では該当 work-buffer が正しく初期化され crash しない。crash は forced-capture harness 固有の artifact(state 不整合)。
- 根治: 該当 1 word を 0 に注入(`DG_LATE_INJ 0x801EE184:0:8900`)= parser が正規の early-exit path(beqz)で該当 event を skip → crash 消滅。cmd 対象 = battle actor event(音楽 SEQ と無関係)ゆえ **音楽 render は完全不変**(層1/2 で実証)。

## 2. 根治の実証(Run A、worker3 実測、全層 PASS)

| 検収層 | 内容 | Run A 結果 |
|---|---|---|
| 層0(最上流) | crash ゼロ(EPC 0x800C9E3C 不到達 / Excode 例外) | ★PASS(Excode=0 完走)★ |
| 層1 | KON write 全長継続(音の停止ゼロ) | ★PASS(KON 66s 一様)★ |
| 層2 | v2 oracle(centroid 絶対 floor、暗化検出) | ★PASS(centroid 全区間 2700 平均=原 clean 水準、暗化消滅)★ |
| 層4 | user 耳(完成 claim 凍結解除の終端) | ★本 package で判定★ |

- write-watchpoint(注入座標 0x801EE184)= 0 write = 注入生存確認(static 予想的中)。1 word 除去で crash 消滅 + 音楽不変 = 機構最終実証。

## 3. 納品物(4 wav、★worker3 展開後 sha 記入★)

`unity/Assets/StreamingAssets/audio/scene33_v{0-3}.wav`(crash-fix re-capture、DG_LATE_INJ 適用):

| variant | 期待音(中立記述) | content sha256 | v2 oracle |
|---|---|---|---|
| v0 | scene33 variant0 | ★保留(第3失敗モード解析中、下記)★ | 21/27 fail(no-crash別failure) |
| ★v1(user 対象)★ | scene33 variant1 | ★aa9f35a3774e9db2★(clean 確定) | ★33窓 0 fail(全区間 bright ~2700Hz)★ |
| v2 | scene33 variant2 | ★保留(v2/v3 座標再検証中)★ | (Excode12 overflow で未達) |
| v3 | scene33 variant3 | ★保留(同上)★ | (同上) |

**v1 確定 deliverable(worker3 2026-07-20 03:08)**: `workspace/f1c/oi3b_capture/scene33_fixed_v1.wav`(sha256[:16]=aa9f35a3774e9db2)。(33,1) native。切出し=battle window [137.8-204.5s]=KON first_frame8287 基準、66.8s(2+loop)、44100/2ch/s16 Clamp16 raw、正規化 NONE。crash-fix=`DG_LATE_DEREF [0x8016B37C]+0x90 ← 0 @frame8900`(=本静的導出 offset と一致)。判定 EXC=0 / KON 全長(8287-12200)/ r2b_oracle_v2=33 music 窓 0 fail(全区間 bright ~2700Hz)/ 層3 aplay rc=0。provenance=scene33_fixed_v1.provenance.txt(同 dir)。
→ ★v1 = user 対象 variant の clean deliverable 確定=本命確保★。v0/v2/v3 は下記解析後。

- format(全 variant): 44100Hz / 2ch / s16 PCM(LE)/ normalization=NONE(raw SPU reverb-mix)。
- ★content_claim=保留★: 曲の内容/identity 断定は user 実聴まで(中立記述のみ、boss1/PRESIDENT 原則)。
- provenance: 各 `scene33_v{n}.provenance.txt` を crash-fix 版へ更新(真因=CPU crash / fix=DG_LATE_INJ 0x801EE184:0:8900 / 全長 clean / v2 oracle PASS)。旧「対策B settle 版」の反転診断は撤回(settle 訂正 list C6-C8)。

## 4. ★層3: ゲーム外直接再生(aplay、最速の音質確認)★

音の全長 clean を最速で確認する手順(遷移文脈なし、素材単体):
```bash
AUDIO=/home/ken/Desktop/Digimon/degimon_world_remake-f1b/unity/Assets/StreamingAssets/audio
# user 対象 variant1 を全長再生
aplay "$AUDIO/scene33_v1.wav"
# 4 variant 順次
for n in 0 1 2 3; do echo "=== variant$n ==="; aplay "$AUDIO/scene33_v${n}.wav"; done
```
- ★判定★: 全長で「途中から重くなる」がゼロ(高音が最後まで維持)= 根治確認。前回品との A/B が要る場合は旧 wav(git 1519bf0=対策B settle 版)と聴き比べ。
- 機械確認(補): `python3 workspace/degimon-faithful178/r2b_oracle_v2.py "$AUDIO/scene33_v1.wav" --verbose`(VERDICT=PASS=症状ゼロ、絶対 floor 含む)。

## 5. ゲーム内実聴(層4、V4 chain 流用=文脈込み確認)

前回 V4 の chain(form→variant→音)で **ゲーム進行文脈の中で**聴く場合:
- 起動 script: `workspace/f1c/run_v4_scene_audio.sh`(DRIVER+WIRE+AUDIO+V4_PLAYSECTION=22:5)。
- 操作: field 到達 → F9 → Space 連打(dialogue 送り)→ 0x66@pc0x90 → [AUDIO-PLAY] scene33_v{n} 実再生。
- variant 切替: `DEGIMON_V4_FORM=0x43`(→variant2)等(V4_USERLIVE_PACKAGE §3-B)。variant1(無指定)/variant2(0x43)が full-chain 到達可。
- ★run script の wav path/sha 参照★: script は StreamingAssets/audio を build にコピーして参照(wav path は固定、sha 直参照なし)。新 wav 差替後は build へ再コピーのみ(script 変更不要)。★但し worker3 の provision(4 wav 差替)完了が前提★。
- ※ 音質(重くなる)判定は層3(aplay 直接)が最速・確実。層4 はゲーム文脈での最終確認。

## 6. 起動チェックリスト(PRESIDENT 即起動用)

1. □ worker3 の 4 wav 展開 + provision 完了(sha 記入 + v2 oracle PASS 確認)。
2. □ 層3 aplay(§4)で全長 clean を耳確認(最速)。
3. □(任意)層4 ゲーム内(§5、run_v4_scene_audio.sh)で文脈確認。
4. □ user 判定: 「途中で重くなる」解消 = 完成 claim 凍結解除。

## 7. honest gap / 未確定
- ★worker3 展開待ち★: 4 wav の content sha + v2 oracle 正式判定 + P 安定性 per-run 確認(§3 記入で確定)。
- honest mark: 注入(値=0 clean-skip)は cmd0x24=battle actor event を skip。natural [P+0x90] が非0 なら actor 挙動に差が出るが **音楽 render は同一**(層1/2 実証)。faithful 版(healthy 値注入)は worker3 (1,0) dump 後に選択可=納品(音楽素材)には clean-skip で十分。
- ★完成 claim は user 実聴まで凍結★(次元分離)= 本 package の耳判定で解除。

---

## 8. ★v0/v2/v3 の natural 到達 guide(H4-i savestate 依頼同梱用、PRESIDENT 指定)★

**背景**: v0/v2/v3 は forced-capture で variant selector だけ強制すると artifact 化(§3 保留欄 + R2B_GATE1_RESUBMIT §2)。★根治は「その variant が **native に鳴る場面** の user savestate を取得 → 実証済 fix 手法(DG_LATE_DEREF)で採取」(選択肢 a、PRESIDENT 採用)★。以下は各 variant が native に鳴る条件(観測=variant selector 機構 0x80105be4、判読範囲)。

### variant 選択条件(EXE ground truth、確実)
scene33(場所は下記 honest gap)に到達した時、**その瞬間の partner/actor の状態**で variant が決まる:
| variant | native に鳴る条件 | 具体(user 視点) |
|---|---|---|
| ★v1(取得済)★ | partner form < 0x43 or ≥ 0x70 | 序盤〜幼年/成長期など低 id 形態、または特殊高 id。**id 0(無 partner 相当)含む=最も出やすい** |
| v2 | partner form 0x43-0x6F かつ byte-table[form-0x43]==2(大半が 2) | **中盤の成熟形態(成熟期/完全体クラス)**の partner で scene33 到達 |
| v0 | scenario flag B[0x253]==1(slot∈[2,0xa)) | ★特定 scenario 進行状態★で scene33 到達(story flag 依存、下記 honest gap) |
| v3 | curForm==0x73(特殊 form entity) | ★form 0x73 の特殊 entity が絡む場面★(通常 partner でなく event 固有 entity、下記 honest gap) |

### ★honest gap(判読不能=user 実プレイ記憶で補完)★
- **scene33 が発生する具体的 map/event = 不明**。scene-id は多段 VM 変数([gp-0x6d08]←[gp-0x6e9c]←上流 writer 0x800ae3dc/0x800bbea8)経由で、DG.SCN の完全 scan は本 arc scope 外(large)。★user は「この曲が実際にゲームのどの場面で流れるか」を実プレイ記憶で特定できるはず(scene33 の曲=v1 取得済 wav を聴けば場面が想起可能)★。
- v0 の B[0x253]==1 になる具体 scenario 状態 / v3 の form 0x73 entity が出る具体 event = 静的判読不能(honest)。user のプレイ記憶 + v1 曲の場面想起で補完。

### savestate 取得 1 行手順(user 向け)
★「scene33 の曲が流れる場面に到達したら(v2=中盤成熟 partner / v0=該当 story 状態 / v3=form 0x73 event)、**曲が鳴っている最中に emulator の savestate を作成**し、そのファイルを共有してください。各 variant 1 つずつあれば、実証済の採取手法でそのまま clean 録音します」★。
- 補足: v1 は取得済(id 0 相当で採取)。v2/v0/v3 の 3 場面の savestate があれば 4/4 完成。1 つでも v1 に加えて増える分だけ納品 variant が増える(部分納品可)。
- fallback: savestate 取得不能な variant は (c) として v1(+取得分)のみで close 合意済(PRESIDENT 裁定)。
