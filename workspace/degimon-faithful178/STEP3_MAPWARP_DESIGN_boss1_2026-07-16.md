# step3 追加実装 設計 doc — ROOM08 field map-warp emit(boss1 起案、2026-07-16 04:1x → PRESIDENT gate ①)

## 0. 位置づけ
- OPEN-CLOSE 確定後(PRESIDENT byte 直読、memory §13 line82 CLOSE)の**唯一残 gap の追加実装**設計。
- ★redesign ではない★: script-side traverse(②-b GetEntryBase(0)=MAPHEAD → 0xFB(163) → resolve → 163 → 0x17 → 178§0x37)は byte 確証済で **valid・不変**。足すのは FIELD map-warp(視覚 ROOM08 切替)の emit のみ。
- 実装 land は gate ②(PRESIDENT go)を land 前に。本 doc は方針の裁定要求。

## 1. 前提の峻別(★honest gap を実装前提に密輸しない★)

### CONFIRMED(byte、実装前提に使える)
- 覚醒経路: `178§0x36 … 0x4B(entry178[1992]=4bda0136…) → 実行 base が entry178→MAPHEAD へ切替 → MAPHEAD[12882]=0xFB(163) → 0xFE resolve → 163§0x36 → 0x17 → 178§0x37`。
  根拠 = MAPHEAD.SCN[12882] が trace raw と 16/16 一致・entry178[12882] 不一致・較正 seq206 rel1992=entry178[1992] 一致(PRESIDENT 独立 byte 直読、worker3 9f72e71 datum)。
- C# ②-b は **script-side dialogue load(GetEntryBase(0)=MAPHEAD 経路)を既に valid に実装済**。0xFB(163)→resolve→163 の per-hop は headless で通っている。

### HONEST GAP(★promote 禁止・実装前提にしない★)
- (i) **rec id = operand+1**(operand 0xda=218 → MAPHEAD table id 219)の +1 lookup 機構は未検証。
  ⇒ ★設計は「219」を導出規則として hardcode しない★。表示 map は operand を既存 registry 機構にそのまま通して解決する(下記 §3-2)。
- (ii) **map-warp load が LoadScenario 非経由**は推論。⇒ ★load 経路が LoadScenario を bypass すると仮定した最適化・分岐を書かない★。
- (iii) entry178 body 長 6144 は未独立確認(結論は byte 不一致で不変)。実装は body 長に依存しない。

## 2. remake の残 gap(単一)
- memory L137: remake 根因 = **0x4B mis-bind — `_warpEmit` gate default false で cutscene 中の FIELD map 切替 emit を黙殺**。
- 現状 = 0x4B handler は return-stack push + script-side は動くが、**視覚的な ROOM08 field への map 切替を emit しない** → live で覚醒の場面転換が出ない。
- ⇒ gap は **0x4B during-cutscene map-warp の視覚 emit** の 1 点のみ。

## 3. 単一推奨: flag 背後で 0x4B map-warp emit を有効化(既存 registry 解決を再利用、新規発明ゼロ)

1. **flag**: 既存 `FaithfulScenarioZero`(既定 OFF)を再利用。新 flag を増やさない。
2. **map 解決**: 0x4B operand を ★既存の map registry lookup にそのまま渡す★(operand→表示 map)。
   - ★honest gap (i) 回避★: 「operand+1=219」という +1 規則を実装に埋め込まない。既存 lookup が実機と同じ結果(ROOM08 を表示)を返すことを ON 側 trace/live で**測って**確認する。lookup の +1 由来は未検証 scope 外のまま。
3. **emit 配線**: flag ON 時のみ、0x4B handler が cutscene 中でも FIELD map-warp を emit できるよう `_warpEmit` gate を通す。
   - ★OFF 側は現行のまま(gate default false / flag で gate)= 1 bit も変えない★。
4. **script-side は不変**: ②-b の GetEntryBase(0) 経路には触らない(既に valid)。

## 4. acceptance(gate ② の材料、runtime 次元)
- ★OFF-inert(最優先・単独 gate)★: flag OFF で **追加 code 導入前後の run が byte-identical**(前後 2 run 実測)。user PASS 済 cutscene 保護の load-bearing 証明。宣言でなく実測。
- ★ON 配線 end-to-end★: flag ON で 0x4B が実際に `_warpEmit` を通り FIELD map-warp を emit することを log で確認(forward-infra 教訓=定義だけで未配線を禁止)。
- ★ON per-hop trace★: `0x4B(map-warp emit) → MAPHEAD 0xFB(163) → resolve → 163§0x36 → 0x17 → 178§0x37` の各 hop を byte 確定経路と突合。
- ★cutscene 視覚発火 = user 実視覚まで凍結★(chain 一致 ≠ 視覚 PASS、完成 claim 凍結継続)。
- gate ② = 上記 + PRESIDENT go を land 前に。live 視覚実走は user 凍結解除後の別 phase。

## 5. file 境界 / 実装分担
- worker2(DialogueRuntime.cs / 0x4B handler / `_warpEmit` gate 周辺、worker2 の既存境界)。
- ★worker2 は着手前に実 code で `_warpEmit` gate site と map registry lookup の実在を直読確認(本 doc の memory L137 依拠を実物 grep で裏取り、premise にしない)★。
- worker3(instrument/trace 検証)・worker1(検証 doc)との交差なし。

## 6. 実装順序
1. worker2: `_warpEmit` gate site + map registry lookup を実 code 直読(gap 峻別)→ 差分設計を worker note に embed。
2. flag 配線(OFF-inert commit 単独)→ OFF byte-identical 実測。
3. ON emit 配線 → end-to-end log。
4. ON per-hop trace 突合 → gate ② 上申。
5. cutscene 視覚は user 凍結解除まで凍結。

## 7. 規範
push ゼロ / OFF 保護(bit-identical) / 完成 claim 凍結(user 実視覚) / honest gap (i)(ii)(iii) promote 禁止 / relay 即 ack。
