# V4 reach-path RE — 0x66 発火元 scenario → user 操作列 — worker1

**date**: 2026-07-19 / worker1 / ★read-only 静的 RE(doc-only、tree 非接触)、§2-B 残 TODO 埋め★
**material**: DG.SCN(degimon_world_remake/extracted/DG.SCN、692224B)。Len[256]=DialogueRuntime.cs(EXE-verbatim、user 検証済)。tool=scratchpad scn66.py(section-accurate SJIS+Len walker)。EXE=slps_017_97.bin(mdis)。
**契機**: worker3 (ii) AUTOBOOT 2run で 0x66 到達ゼロ(reachability gate)。診断=0x66 は field NPC/event scenario 由来(census 発火元 entry97/32/22)。
**規律**: 観測(walker/census/decode)/推論/honest gap。全列挙は scan 範囲/方法明記(打切不在≠否定)。

---

## 0. 結論(単一推奨ファースト)

★0x66 は **field NPC/event dialogue scenario** に遍在(実 entry 1-224 のうち **112 entry** が 0x66 含有、census 発火元 22/32/97 を静的に確認)。AUTOBOOT が 0x66 到達ゼロなのは **NPC interaction(PlaySection 呼出)を駆動しない**ため★。

★★単一推奨 user 操作列(v4、Unity remake)★★:
**flags ON(DRIVER+WIRE+AUDIO)で `PlaySection(entry=22, section=key5=0x5)` を発火させる**(census 発火元 + 0x67/0x66 pair 確認済の最確 entry)。
- 自然 play で到達困難な場合(=AUTOBOOT gap の本質)は、既存の PlaySection 経路(NPC 会話 harness)か、最小 test-hook で entry22 §5 を直接 load = **0x66 が deterministic に発火** → SceneAudioManager が partner form 対応 variant を再生。
- ★未検証★: 「どの field NPC/操作が entry22 を自然 load するか」= NPC placement table(map data)未 RE(§6)。自然操作列の precise 化は worker3 (ii) の実 input log か NPC placement RE 後に確定。

---

## 1. 0x66 含有 entry 全列挙(観測、scan 範囲/方法明記)

- ★scan 方法★: section-accurate decoder walk(scn66.py)。各 entry の subtable{key,off}(body+2 から stride4、0xffff 終端)から各 section を起点に、★SJIS-aware(lead 0x81-9F/E0-EF + trail 0x40-7E/80-FC=2byte text 消費)+ Len[256](EXE-verbatim、DialogueRuntime.cs)★で 0xFE/0xFF まで decode、0x66 出現を記録。byte-grep でなく decode walk(operand collision 偽陽性回避)。
- ★scan 範囲★: DG.SCN offset table。**実 entry=225(idx 0-224)**(entry152 HANDOFF 独立裏取り: slot 225=EOF sentinel、226+ =ASCII "\SCN\MAP141.SCN" garbage。本 RE も offset table 単調性で idx 0-224 のみ in-file・body<128KB を確認)。**idx 0(MAPHEAD)は STEP4 同様除外**(map/table data 混在で desync)。
- ★結果: 0x66 含有 entry = 112 件(idx 1-224)★:
```
1,2,3,4,6,9,10,11,12,13,14,15,16,18,19,20,22,23,30,32,33,34,35,36,37,38,39,40,41,42,43,44,
45,46,48,49,51,52,54,55,60,62,63,64,65,66,67,68,69,70,71,73,74,77,78,79,80,81,82,83,84,86,
87,88,89,91,93,94,95,96,97,101,107,108,109,110,112,113,116,117,120,123,126,127,130,135,136,
137,139,140,141,142,143,145,146,155,157,164,165,166,167,168,169,189,190,192,194,216,217,218,219,224
```
- ★除外開示★: idx 225-511(=offset table overflow、stride-8 で key34@0xaee の phantom 0x66 が現れるが body が全 file overflow=false positive)は除外。idx 0(MAPHEAD)除外。
- 大半の entry は section key5-key10(0x5-0xa)に各 1 個の 0x66= **partner-form 対応の dialogue beat 列**(1 会話 = 複数 beat、各 beat で form-appropriate scene 選択)。

## 2. decode 忠実度(triple-grounding、観測)

1. ★census 一致★: worker3 census 発火元 **entry 22 / 32 / 97 が全て本列挙に present**(各 8 個の 0x66)= 静的 walk が runtime census と一致。
2. ★0x67/0x66 固定ペア構造★: entry22/32/97 の key5 section で 0x66 直前 bytes = **`27 00 67 00 01 00 66 00 1c 00`** = `0x67(FRAME_YIELD、Len4: 67 00 01 00)→0x66(SCENE_DRIVER、Len2: 66 00)` = STEP5 既知の「0x66=直前 0x67 固定ペア」と一致(3 entry で bit 同一)。operand 誤読でなく真 opcode 列。
3. ★境界の独立裏取り★: 実 entry=225 は entry152 HANDOFF(worker2)と本 RE の offset table 単調性解析で一致。

## 3. trigger 機構(観測+推論)

- ★0x66 到達 chain(entry152 HANDOFF §2 接地)★: field warp → StartScript(MAPHEAD, §mapId) → MAPHEAD の 0xFB が {scenario,ctx} push → 0xFE pop で BASE=新 scenario → section resolve → 0x17 JMP_SEC → 目的 section(NPC/event dialogue)→ その section 内で 0x67→0x66 実行。
- ★もう 1 経路 = PlaySection(NPC 会話)★: DialogueRuntime.PlaySection(entry, section)(callScriptSection 相当)= NPC interaction で entry の section を直接 load。0x66 含有 section を load すれば発火。
- → ★0x66 発火 = 「field で NPC/event scenario の 0x66 含有 section が実行される」= 主に **NPC に話しかける / event を踏む**(partner 在席時に form-appropriate scene 選択)★。

## 4. AUTOBOOT gap 診断(なぜ (ii) で 0x66 到達ゼロか)

- AUTOBOOT = 自動 boot(player input なし)。§3 の両経路(NPC 会話 PlaySection / field warp→event)は **player の field 操作(移動・話しかけ・event trigger)を要する**。
- AUTOBOOT は intro/boot chain(FullScenario)は流すが、**NPC interaction(PlaySection 呼出)を駆動しない** → 0x66 含有 section に到達しない → 0x66 到達ゼロ。
- → ★reachability gate の本質 = 「field NPC/event interaction の欠如」。fix = interaction を駆動する操作(§0 推奨)★。

## 5. 単一推奨 user 操作列(詳細)

★推奨 = entry22 §5(key5)を PlaySection で発火(deterministic、census+pair 確認済)★:
1. Unity remake を flags ON で起動: `DEGIMON_SCENE_DRIVER=1 DEGIMON_SCENE_WIRE=1 DEGIMON_SCENE_AUDIO=1`(+ partner form を variant 別に設定できるなら §V4 対応表の form へ)。
2. entry22 §5 を load: (a)自然 = 該当 NPC に話しかける(NPC→entry22 対応は §6 gap)/(b)harness = PlaySection(DialogueDatabase.GetEntry(22), 0x5) を直接呼ぶ(worker3 の play-mode harness で最確)。
3. 0x66 発火 → [SCENE-SWITCH]→ SceneAudioManager.OnSwitch(0x21, variant) → partner form 対応 variant の wav 再生([AUDIO-PLAY] log)。
4. partner form を変えて再実行 → 異なる variant の曲(§V4 checklist (b))。同一 form 再実行 → 同一継続=再start せず((c))。
- ★なぜ entry22★: census 発火元(runtime 実績)+ 0x67/0x66 pair 確認 + 8 section = form beat 複数(variant 切替観測しやすい)。代替= entry32/97(同条件)。
- ★未検証 mark★: 自然操作(2a)の「どの NPC/map」= §6。harness 路(2b)は既存 PlaySection API で確実だが env test-hook は未実装(worker3 harness か最小 hook 追加要)。

## 6. honest gap / cutoff(promote 禁止)

- ★entry→NPC/map placement 対応 未 RE★: どの field NPC/event が entry N を load するかは NPC placement table(map data / MAPHEAD 内)の RE が必要=本 task scope 外(cutoff)。→ 自然操作列の precise 化は (a)worker3 (ii) の実 input log(何を操作して 22/32/97 が出たか)、または (b)NPC placement RE で確定。
- ★0x19(COND_BRANCH)desync risk★: walker は Len[0x19]=2(固定)を使うが 0x19 は実際は可変長(評価器駆動)。0x19 を含む section では以降 desync し phantom 0x66 の可能性。→ 主要 entry(22/32/97)は 0x67/0x66 pair で真性確認済だが、全 112 の各 0x66 が真 opcode である保証は 0x19-free section に限る=honest mark。
- ★prior false-GREEN entry の再検証 flag★: entry152 HANDOFF が operand-as-opcode 偽 GREEN 8 件(entry 33/64/71/72/76/98/108/144)を報告。うち **33/64/71/108 は本 0x66 list に重複** → これらの 0x66 は operand 誤読の可能性=個別 decode 再検証要(推奨路 entry22/32/97 は該当せず、census+pair 確認済ゆえ推奨に影響なし)。
- ★entry0(MAPHEAD)除外★: 本手法で 0x66 含有未確定(STEP4 同断)。
- cutoff: 全列挙 + census cross-validation + trigger 機構 + 単一推奨で §2-B 材料は充足。entry→NPC placement は次段(worker3 (ii) log 照合が最短)。

## 付: source
- DG.SCN walker=scratchpad/scn66.py(Len[256]=DialogueRuntime.cs L41-85、SJIS=DialogueData.cs L216-217)
- 実 entry 境界=本 RE offset table 単調性 + entry152 HANDOFF(worker2、slot225=EOF/226+=ASCII)
- census 発火元 22/32/97=boss1 relay(worker3)
- trigger chain=HANDOFF_2026-07-12_entry152_RE.md §2
- 0x67/0x66 pair=STEP5(worker2 d1)+ 本 RE entry22/32/97 実 byte
