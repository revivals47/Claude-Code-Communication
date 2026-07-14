# step3 設計判断 doc ★v2(改訂)★ — boss1、2026-07-15 15:2x → PRESIDENT gate ① 再上申

v1(`f5dc5b5`+`ff0e6c7`)からの改訂理由 = ★設計前提が実測で覆った★(worker2 の byte 直読、worker3 の self-check 連鎖)。
実装は HOLD 中。本 v2 の承認をもって実装解禁 → land は gate ②(測定条件 3、v1 のまま不変)。

## 0. 何が変わったか(実測による前提の訂正)

- ★**MAPHEAD.SCN(23,094 B)== DG.SCN entry[0] の先頭 23,094 bytes = byte 完全一致**(sha 375620dd)★。
  ⇒ v1 の前提『MAPHEAD は C# に無い = provision/load が要る』は **不成立**。
  ★H2 以来の『原盤 scenario 0 = MAPHEAD / C# の scenario 0 = 全く別 script』は **未検証推論**だった★
  (file/code の不在は実測したが、**content が別だとは測っていなかった**)。
- ⇒ ★**欠落は content ではなく【配線のみ】**★: GetEntryBase dispatch / 0xFE resolve / scenario-0 routing。
- **実装 scope の縮小**: MAPHEAD provision = **ゼロ**。残 = **GetEntryBase dispatch + 0xFE resolve 配線 + Boot shortcut 置換**。

## 1. 単一推奨(v2): entry[0] 流用(23,094 bound)+ 配線のみ実装

PRESIDENT 裁定(承認済): ★忠実性は**挙動(解決結果)**であって memory-layout の模写ではない★。
別 buffer を C# に作るのは layout 模写 + 未同定余剰の抱え込みで、挙動差ゼロ。

### 条件 1(bound)= 実測で理由が sharpen された
- ★実測(worker2): MAPHEAD buffer は **alloc 24,576 / file load 23,094**(base 0x80159784、次 buffer との間隔 0x6000)★。
  差 1,482 = entry[0] の余剰と**完全一致**。⇒ v1 裁定文の『23,094 ちょうど・余剰なし』は不正確で、
  正しくは **『24,576 alloc・23,094 load』**。
- ⇒ ★**23,094 bound は正しい。理由 = 「loaded 領域のみを見せる」= entry[0] tail(DG.SCN 由来の別内容)の混入を防ぐ**★
  (EXE の unloaded tail と entry[0] tail は別内容 = bound しなければ原盤に無い読み出しを許す)。
- **実装要件**: `GetEntryBase(0)` は **Raw = entry[0][:23094] の bounded entry** を返す。

### 条件 2(all-sinks)= 列挙完了、23,094 超えの consumer は無し
- **C# 側**: entry[0] を読む全経路(VM Tick / GetSectionTable / ExtractTextRuns / Editor tools)は ★全て `entry.Raw.Length` で
  bound★ ⇒ scenario-0 Raw を 23,094 bound すれば **全 consumer が構造保証で 23,094 を超えない(by construction)**。
- **EXE 側**: MAPHEAD buffer access 6 site を全確認 — ★固定 high-offset read は無い★
  (GetEntryBase = ptr のみ / GetSectionOffset = subtable<1128 / setup 0x800ef34c = offset0+base+1126 /
  VM section 実行 = 最大 section offset 23,086 / loader)。
- **覚醒 chain の scenario-0 read**: {0(Word0), 2..1128(subtable), 1126(PC), 12882..12888(§218 0xFB)} = ★全て < 23,094★
  ⇒ entry[0] と MAPHEAD の**解決結果は同一**。
- ★honest 開示(worker2)★: 末尾 section(23,032..23,086、他 map 常駐)の body が 23,094 を跨ぐ可能性がある
  (EXE では unloaded / C# では bound fault)。★ただし覚醒 chain では実行されない★ = 宣言 gap。

### 条件 3(layout gap の台帳明記)
★EXE = 別 buffer(alloc 24,576 / load 23,094)/ C# = entry[0] 由来(Raw 23,094 bound)= **content 同一(実測)・
memory-layout 相違・覚醒挙動差ゼロ**。tail 相違は never read★。
E114 → 『scenario-0 base 参照(entry[0] 由来・23,094 bound)』へ写像(挙動忠実、layout 非模写 = 裁定済)。

## 2. gate ②(land 前の測定条件 3)= v1 のまま不変

1. ★OFF-inert を実測 bit-identical で証明★(宣言でなく)— parent vs child、flag OFF。
2. ★GetEntryBase の配線を end-to-end 実測★(定義だけで caller が旧経路なら未達)。
3. ★ON 側 trace 検証は per-hop★(endpoint でなく 1 hop ずつ data 直読地図と突合)。
- ★live・視覚実走は user 凍結解除まで禁止(headless trace は可)★。

★**測定基盤は準備完了**(worker3)★: harness v2(3 次元 = base identity / 静的 resolve 面 / **runtime chain**)+
coverage assert + reflection binding + ★比較器 2 段(CHECK1 = binding assert / CHECK2 = 実体行のみ sha)★ +
★verdict 4 分岐の事前固定(INVALID / **VACUOUS = flag が no-op or 経路未観測 → inert とは呼ばない** / OFF-INERT / NOT INERT)★ +
smoke test で検出器自身の検出能力を実証済み。
- ★重要(worker3 の self-check)★: entry[0]==MAPHEAD かつ GetEntryBase(0)=GetEntry(0) ゆえ **base identity は ON/OFF で不変** —
  静的 trace だけでは positive control が空振りする。★flag が効くのは **0xFE resolve 配線** = runtime chain 次元★。

## 3. 副次: step4/5 の優先度が実測で反転(worker3 census `03b4863`、参考)

| opcode | 実行回数 | launch entry | 位置づけ |
|---|---|---|---|
| 0x46 | 6 | 6 | step4。実行実績は**極小** |
| 0x79 | 1 | 1 | step4。**1 site のみ**(scn=151,key=60) |
| ★0x66★ | ★464★ | ★463★ | step5。★**ほぼ全 entry が通る = 全面的経路**★ |

⇒ ★0x66 は『特殊 op』ではない。差分テストの母数が大きく、退行が即可視化される★ = 実装優先度・検証コストの見積りは
step4/5 dispatch 時に再考する(本 doc の scope 外、記録のみ)。
★census は『実行された』のみ claim(静的 byte scan は operand collision で偽陽性 = 0x6F/0x6D の前科ゆえ採らない)★。

## 4. 承認要請

上記 v2(entry[0] 流用 + 23,094 bound + 配線のみ + 条件 1-3 反映)で **実装解禁**を要請。
land は gate ②(測定条件 3 + PRESIDENT go)を経る。cutscene 実走・視覚検証は user 凍結解除まで実施しない。
