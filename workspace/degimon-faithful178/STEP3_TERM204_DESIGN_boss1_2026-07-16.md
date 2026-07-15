# step3 終端204復帰 忠実化 設計doc(boss1 起案、2026-07-16 05:3x → PRESIDENT gate ①)

## 0. 位置づけ
- gate② GO 済(map-warp 4-hop VM byte 忠実+OFF 保護)後の **live sign-off 前 blocking**(PRESIDENT 格上げ)。
- 材料 = worker3 実機実測 `TERM204_MECHANISM.md`(f1c `28f6a2a`、byte 照合付) + worker2 code map `STEP3_TERM204_CODEMAP.md`(f1b `2c5f2a1`)。両者 boss1 独立裏取り済(seq433 base 切替 0x80159784/rel10834/raw `fb009500cc00`、sha 実在)。
- ★boss1 grounding 仮説(b)「hub 復帰→別 load」は **因果逆転で棄却**(worker3 実測)。204 warp が先、149 は 204-record 内 0xFB の帰結。measure-first が私の推論を正した★。

## 1. 確定機構(実測、実装前提に使える)
- 終端 0x4B(204,2,0xFF) = **hop1 の 0x4B(218,0x36) と同一の MAPHEAD map-warp**。key=0xFF でも **warp は起きる**(seq433 が byte 証拠)。
- 連鎖: `終端0x4B(204) → MAPHEAD rec205(map-204 record、rel10834、16/16 照合) → 0xFB(149) → scenario 149 load → 149 body(0x19/0x46/0x47/0xFE) → 0xFE resolve = entry149 offset52(§254/§54)→ 0x57 系列 → VM idle(var[0]=3)`。
- boot seq0 = 同 rec205 = **boot と cutscene 復帰は同一機構**(同型性 witness)。
- OFF facade MAPWARP(204,2,0) = **field 次元忠実(operand `cc 02` 完全一致)/ scenario 次元 shortcut(MAPHEAD rec205→149 連鎖を走らない)**。

## 2. 現状 C# divergence(perhop5_ON 実測 vs 実機)
- 現 C#: 終端 0x4B(rk==0xFF)は flag-ON block の `if(rk!=0xFF)` が FALSE → warp せず素通り → `if(Root==SceneCutscene)` branch へ fall-through。
  - Root==SceneCutscene 時(worker2 chain trace): MAPWARP(204,2,0) emit(field 視覚のみ)。VM warp なし。
  - Root!=SceneCutscene 時(worker3 perhop5_ON=NpcSection root): emit も無く pc4882 0xFE へ fall-through(実機に無い実行)。
- ⇒ ★実機の「終端も faithful warp(MAPHEAD rec205→149 連鎖)」を C# は**どの Root でも**再現していない。field 視覚 emit すら Root 依存★。

## 3. 単一推奨: flag-ON 終端 0x4B(rk==0xFF)を hop1 同型の faithful warp に通す(OFF 非touch)

1. **warp 除外の撤廃(flag-ON のみ)**: flag-ON path で 終端 0x4B(rk==0xFF)も **hop1 と同じ faithful warp**(MAPHEAD §map=204 load → 0xFB(149)→ scenario 149)を通す。②-b の GetEntryBase(0)/PendingScenarioLoad 機構を **再利用**(新機構ゼロ)。差分は resolve 先のみ。
2. **FIELD emit(twna01=204)**: hop1 と同じく flag-ON path 自身が map-warp emit(operand 204)を出す(Root 非依存化)。
   - ★worker2 flag「終端 emit 源=SceneCutscene 共有、追加なら重複注意」★ → flag-ON path が emit する場合、SceneCutscene branch fall-through の二重 emit を回避(flag-ON path で emit したら return、SceneCutscene branch へ落とさない)。
3. **★honest gap 峻別(実装前提に密輸禁止)★**:
   - (I) **0xFF の push 挙動未確定**(push 抑止 vs push+fallback、ReturnStackDepth trace 無)。⇒ ★resolve 先を「§254/§54=entry149 offset52」という**観測**で据える。push 機構を解釈・仮定しない★。
   - (II) **§254 vs §54 区別不能**(同一 offset52)。⇒ offset52 を landing target とし、どちらの section かを claim しない。
   - state 書込 3 件(flag44/var6/var0)の担当 code 未同定 / 0x47(43,4)(44,6)の field 意味 = scope 外。
4. **OFF-inert**: 全変更を FaithfulScenarioZero block 内に閉じる。OFF の SceneCutscene MAPWARP(204,2,0)経路を **1 bit も変えない**(PRESIDENT construction 直読で close)。

## 4. ★設計判断点(PRESIDENT 裁定要): resolve offset52 の実装方法★
honest gap (I) が resolve に効く。2 案:
- **案 A(推奨・保守)**: 終端 warp 後の resolve を「観測された offset52 landing」で実装(mechanism 非解釈)。②-b resolve 機構が offset52 を自然に産まなければ、終端専用に offset52 landing を明示配線(observed oracle 準拠、push 有無を claim しない)。
- **案 B**: 実装前に 0xFF resolve 機構(push 抑止 vs fallback)を **追加実測**(ReturnStackDepth を instrument に追加 → 1 run)してから配線。
- boss1 推奨 = **案 A**(観測 oracle で足りる。機構解釈は忠実度に不要=offset52 に着地すれば trace 一致)。但し ②-b resolve が offset52 を自然に産むか実装時に実測確認、産まなければ案 B へ切替。

## 5. acceptance(gate ②-style、runtime)
- ★OFF-inert(最優先・単独 gate)★: flag OFF で追加 code 前後 byte-identical(前後 2 run、PRESIDENT construction 直読)。OFF cutscene byte 保護。
- ★ON faithful terminal★: 終端 0x4B(204,0xFF)が MAPHEAD §204 → 0xFB(149)→ scenario 149 → resolve offset52 → VM idle、を実機 trace(seq432-456)と per-hop 突合(worker3 official harness 再走)。pc4882 fall-through の消滅を確認。
- ★FIELD emit★: MAPWARP(204,2,0)が flag-ON path で発火(twna01)、二重 emit 無し。
- ★cutscene 視覚発火 = user 凍結解除まで凍結★(chain 一致 ≠ 視覚 PASS)。
- gate ② = 上記 + PRESIDENT go を land 前に。live 視覚実走は user 凍結解除後。

## 6. file 境界 / 実装分担
- worker2(DialogueRuntime.cs 終端 0x4B handler、flag-ON block 内、既存境界)。着手前に L846-880 root 分岐 + ②-b resolve 機構を実 code 直読(premise 化しない)。
- worker3(official per-hop harness で終端 warp 忠実性を再検証、FIELD emit RECEIVED、OFF-inert 実測)。

## 7. 実装順序
1. worker2: L846-880 + ②-b resolve 直読 → 終端 warp 配線設計(案 A、offset52 自然産出を実測確認)。
2. flag 配線(OFF-inert commit 単独)→ OFF byte-identical 実測。
3. ON 終端 warp+emit 配線 → 二重 emit 回避確認。
4. worker3 official harness 再走 → 実機 seq432-456 突合 → gate ② 上申。
5. cutscene 視覚 = user 凍結解除まで凍結。

## 8. 規範
push ゼロ / OFF 保護(bit-identical)/ 完成 claim 凍結(user 実視覚)/ honest gap (I)(II) promote 禁止 / memory 提案制 / relay 即 ack。
