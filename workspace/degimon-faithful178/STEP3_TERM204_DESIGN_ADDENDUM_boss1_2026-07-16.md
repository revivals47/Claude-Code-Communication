# step3 終端204 設計 addendum(案B実測後、boss1、2026-07-16 06:0x → PRESIDENT gate ①)

## 0. 位置づけ
- 前設計 doc(`eba53e5`)の案A→案B切替後の **honest gap I 実測 closer** を受けた設計確定。
- 材料 = worker3 案B実測 `TERM204B_PUSH_RESOLVE.md`(f1c `482e818`、DGRETSTK additive/env-gated、validity gate=prefix byte-identical diff=0)。
  ★boss1 独立裏取り: 私の非対称filter誤検出(200差)→方法論訂正→diff=0 再確認 / push event raw確認(seq433 `…04ff`=K4{0xFF}/seq434 `cc000000b8020380`=K3{0x80}=ACTIVATE)★。

## 1. 実測で確定した faithful 機構(honest gap I 解決)
| 段 | 挙動(depth遷移+byte照合、worker3 482e818) |
|---|---|
| **0x4B** | ★key 値に関わらず常に push K4{kind=4,key}★(seq433 depth0→1 `04ff` / hop1 seq207 `04 36` 同型) + map warp + yield |
| **0xFB** | ★ACTIVATE = push K3{kind=3} + CurrentScenario 張替 + deferred load★(seq434 depth1→2 `03 80`)。**張替-only ではない** |
| **MAPHEAD 0xFE** | pop K3 → §254 resolve(= entry の table 先頭 offset)。終端: entry149@52 / hop2: entry163@64(**2/2 交差検証**) |
| **§254 body 末尾 0xFE** | pop K4 → key 分岐: **key!=0xFF → key resolve(EXE GetSectionOffset、hop2 で rel122)/ key==0xFF → terminal(PC=base+1126 の 0xFF cell → script end)** |
| **空 pop** | kind==0 → VM idle |

- ★hop2 と 終端は【最後の K4 pop 分岐】以外**完全同型**★。
- ★terminal field 表示(twna01)は 0x4B warp 自体が担う(TERM204_MECHANISM.md と整合、前設計の FIELD emit 方針は不変)★。

## 2. ★重要な含意: ②-b の 0xFB「張替-only」は shortcut だった★
- 現 C# ②-b の 0xFB handler = 張替-only(ACTIVATE 抑止、`2dfe2a5` の 169§254 分岐回避由来)。
- ★実機は 0xFB=ACTIVATE(K3 push + §254 resolve で停止)★。hop2 は 0xFE key-resolve が偶然 §218 を止めるので張替-only でも **output は faithful(gate② GREEN)**。だが終端は key-resolve が無く張替-only が cascade 暴走(worker2 step0 実証)。
- ⇒ ★C# に欠けているのは「K3 push + K3-pop=§254 resolve」の対★。これが忠実 0xFB。

## 3. 設計判断点(★PRESIDENT 裁定要: 忠実度 vs gate②-GREEN hop2 への risk★)
- **Option X(推奨・忠実優先)**: 0xFB を **faithful ACTIVATE(K3 push/pop + §254 resolve)に統一**(hop2+終端 both)。実機と同一機構、shortcut 除去。
  - risk: gate②-GREEN の hop2 path を touch。worker3 official harness で hop2(163§0x36→0x17→178§0x37)非退行 + 169§254 非再現を再検証(deferred ACTIVATE は eager-load 由来の 169§254 artifact を再現しないはずだが実測確認)。
- **Option Y(低risk・shortcut 保持)**: hop2 は張替-only(gate②-GREEN)維持、終端(key==0xFF)にのみ ACTIVATE 追加。
  - 難点: 0xFB が key 分岐する = 実機に無い divergence を新設(実機は両方 ACTIVATE)。忠実度で劣る。
- ★boss1 推奨 = Option X★: north star=忠実度、実機は 0xFB を uniform に ACTIVATE。hop2 の張替-only は output-faithful だが機構-unfaithful な shortcut であり、これを機に忠実化。risk は worker3 official harness 再走(K3/K4 depth 遷移を assert 昇格)で封じる。

## 4. ★honest gap / OPEN(実装前提に密輸禁止)★
- ★OPEN(worker3 正直開示): GetSectionOffset の実 algorithm★。worker3 naive table parse(§54=64)より **worker2 EXE RE(rel122)が正**。★C# の resolve offset は table 解釈でなく worker2 EXE GetSectionOffset RE を oracle にする★(§254 の table 先頭 offset 着地も同様)。
- K3 record byte0(cc/da/ee)の意味 / key=0x80 の意味 / 0x800ef34c 内部 Word0 setup = scope 外(実装は observed 挙動に準拠、解釈しない)。

## 5. 実装方針(Option X 前提、worker2)
1. **0xFB = faithful ACTIVATE**: K3{kind=3} push + CurrentScenario 張替 + deferred load(現張替-only を ACTIVATE 化)。
2. **0xFE kind 分岐**: K3→§254 resolve(EXE GetSectionOffset oracle)で停止 / K4 key!=0xFF→key resolve / K4 key==0xFF→terminal(PC=base+1126→script end)/ 空→continue。
3. **0x4B 常時 push K4{key}**(現状 hop1 は push 済、終端 rk==0xFF の push 除外を撤廃)。
4. **FIELD emit(204)** は前設計どおり flag-ON path(二重 emit 回避)。
5. ★全て FaithfulScenarioZero block 内、OFF SceneCutscene MAPWARP(204,2,0) 経路 1bit 不変★。

## 6. acceptance(gate②-style、runtime)
- ★OFF-inert(単独 gate)★: flag OFF byte-identical 前後2run(PRESIDENT construction 直読)。
- ★ON faithful★: worker3 official per-hop harness 再走で —
  - hop2 非退行(163§0x36→0x17→178§0x37 GREEN 維持、169§254 非再現)。
  - 終端 0x4B(204,0xFF)→MAPHEAD rec205→0xFB ACTIVATE→§254(entry149@52)→terminal PC=base+1126、が実機 trace(seq432-457)と一致。
  - ★K3/K4 depth 遷移を assert 昇格(worker3 提案): push/pop の depth 実測値 = trace 値★。
  - FIELD emit MAPWARP(204) 1回、二重 emit 無し。
- cutscene 視覚発火 = user 凍結解除まで凍結。gate② = 上記 + PRESIDENT go を land 前に。

## 7. 実装順序 / 分担
- worker2(DialogueRuntime.cs 0xFB/0xFE/0x4B handler、FaithfulScenarioZero block、既存境界): step0 再読(現 0xFB/0xFE 実装 + GetSectionOffset consumer)→ step1 OFF-inert 単独 commit → step2 faithful ACTIVATE 配線 → step3 FIELD emit。
- worker3(official harness 再走 + K3/K4 depth assert)。
- 各 land = sha+数値、PRESIDENT 直読。

## 8. 規範
push ゼロ / OFF 保護(bit-identical)/ 完成 claim 凍結 / honest gap・OPEN 非promote(GetSectionOffset=EXE RE oracle)/ memory 提案制 / relay 即 ack / hop2 非退行を worker3 official で実測。
