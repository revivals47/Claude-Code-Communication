# ③ladder 次opcode scoping(boss1、2026-07-19 swap後再init 初回上申)

status: ★**GO承認(PRESIDENT、2026-07-19 04:35)**★ — 単一推奨(step5=0x66)採用、phase構成・割当承認。補足2点:
1. (p1) premise-check の2源(07-09『複合scene op』/ census『warp class』)は★両方とも未検証claim★として扱う。二者択一禁止、EXE handler直読=唯一のoracle、両説外れのH4も許容。『DF70を実際に読むか』も同じくEXE直読で確定。
2. (p4) 差分テスト目標値のprereg固着=★着手時固定・事後改訂禁止★を(p2)設計docに明記すること。

(p1)=worker2へ04:37 dispatch済。worker1 blind x-check投入タイミング=boss1判断委譲。材料 = MASTER_TASKS.md(07-09 follow-up registry)/ PREREG_3_IMPL(§1 ladder・§17 実装順序)/ STEP45_OPCODE_CENSUS.md(worker3 実測)。

## 0. ladder 現在地(ground truth、f1b git log --all 直読)

| step | 内容 | 状態 |
|---|---|---|
| 0 | 設計裁定2件(0a/0b) | CLOSE |
| 1 | baseline C 生成+stat struct 輸入 | CLOSE(PREREG §12、x-check通過) |
| 2 | 初期値 capture 残8 addr + recon(A) | land(seed care gate audit C-3 CLOSE、handoff §2-1) |
| 3 | MAPHEAD 鎖 | land(c8e2e32 chain+終端204+VISMAP、gate①でuser live PASS) |
| **4** | **opcode 0x46/0x79 + registry(640A4)** | ★未着手★ |
| **5** | **opcode 0x66(DF70 消費)** | ★未着手★ |
| 併走 | 0x36/0x37(時計/care) | 0b-v2 として部分完成CLOSE(open=O2/O3/O4) |

残 = step4 と step5 のみ。

## 1. ★単一推奨 = step5(0x66)を次opcodeとする★

**理由(census 実測、PREREG §17 で既採用の順序の再確認+具体化)**:
1. **検証母数の非対称**: 0x66 = 464実行/226 site/463 launch entry(ほぼ全entryの定型prologue末尾に1回、直前0x67が100%固定ペア)。差分テスト母数=463 entry — 実装を誤れば即・全面的に可視化される=★最も安全に検証できるstep★。対して 0x46/0x79 = 6/1実行 — full sweepでは埋もれ、踏むentryを明示指定しないと検証が空振る。
2. **依存充足済**: step5 の前提 = step3(land済)+ §6 DF70 維持裁定(済 = writer1 0x800AE4E0 定数2 のmodel化、130/130実測)。step4→step5 の「鎖の順序」は §17 で boss1 が逆転採用済(本上申はその履行)。
3. step4 は後続で低リスク着手可: 必須corpus全件 = (129,6)(151,60)(170,51)(171,51)(172,51)(173,51) を prereg 固定済(census §4c)。

## 2. step5 の phase 構成(規範準拠)

- **(p1) 全長RE(実装前の恒久条件、PREREG §9 規範7)**: 0x66 handler(≥0x64 二次表 0x8011b3a0 経由)+呼出先1段を prologue→epilogue 全長RE。
  - ★premise-check 必須(2源の突合)★: 07-09 worker1 finding「0x66=複合scene/story-progression opcode(StartScript+scene selector 0x800aeca8+conditional pan)」vs census label「DF70消費(warp class)」+実測「直後にop続かず idle_stop 464/464」。両立するか、どちらかがstaleかを実disasmで決着(額面relay禁止)。
  - census 未追跡の開示事項「0x66 が DF70 を実際に読むか」をここで確定。
- **(p2) 設計doc(boss1 単一推奨)→ PRESIDENT gate①裁定**(実装前の設計判断)。
- **(p3) 実装 = ★flag opt-in・既定OFF★ + 配線確認義務(grep目視+log実測、ON/OFF両側)** → ★land は PRESIDENT gate②★(MAPHEAD/0x66 は明示gate対象)。
- **(p4) 検証**: OFF側bit不変+ON側差分テスト(母数463、目標値は着手時preregで固着)+headless(CutsceneVerify178等)+care harness 19/19 非退行。完成claim=user live凍結。
- 全長REが設計前提を覆した場合 = 即上申・実装凍結(gate④)。

## 3. worker 割当案

- **worker2**: (p1) 全長RE + (p3) C#実装(VM dispatch直読実績、待機中)。
- **worker1**: (p2)以降の blind x-check / spec照合review(待機中)。
- **worker3**: 投入しない(O2 CareFormIndexGlobal (a) 継続中、非干渉)。検証runで計測が要る場合のみ (a) との優先度を都度裁定。
- boss1: prereg管理・RE裏取り・統合裁定・中間ack。

## 4. 非対象(本scopingで開かない)

- step4(0x46/0x79) = step5 完了後、corpus固定済で着手。
- 07-09 follow-up registry(0x4F pan配線/branch-following tracer/W4 residual/0x4E live確認/entry147) = ③本線と別線のまま維持。
- O2-O7(handoff §4) = 既存ticket運用のまま。
