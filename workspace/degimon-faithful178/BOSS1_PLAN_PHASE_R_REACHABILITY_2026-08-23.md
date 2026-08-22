# Phase R 起案 — 原盤 reachability で critical path へ再接続(2026-08-23・boss1・★実装 GO 前★)

★status = 起案・PRESIDENT 裁定待ち★。★run 0 で設計し、run が要る段は 本数と目的を固定して 個別に上申★。

## 0. なぜ今これか(前提の確認)

- ★消費規則 phase は完了★ = script VM 5 band 100 opcode が ★逐語 89 / 推定 0 / ABS 7 / 固定長でない 2 / 長さの概念が無い 1 / sub 別に分解 1★・★器の限界で止まった本 0★。
- ★今夜確定した機構★ = ★項と opcode の 2 人格(mode 場 = byte & 0x38)★ / ★0x18 standalone = 表 index 無条件 jump(+2 = clamp 上限)★ / ★式の項 mode 0x10・0x18 = base + u16 の跳び★ / ★脱出は必ず LongJmp(a1 で VM loop に用件を伝える)★ / ★entry 先頭 = u16 長 + (id, offset) 対 + 0xFFFF 終端の section directory★ / ★band は重複するので ★router を指定しないと opcode は意味を持たない★★。
- ⇒ ★★『原盤で 0x24 が撃たれるか』を 静的に答える道具が 初めて揃いました★★。

## 1. 目標(1 行)

★stic02 / fact02 の scene で ★原盤が 0x24 を撃つのか★ を答え、答えられたら ★draw 順★ に進む★。

## 2. 段(★1 枚ずつ・順序厳守★)

### R0. ★idx ↔ entry の検定★(器 = worker3・★park 中の待ち行列 (a)★)
- 問い = ★`[PLACE-SPECIES] map=stic02 idx=139` の `idx` は ★DG.SCN の entry index と同一の番号体系か★★。
- 方法 = ★remake の placer が `idx` を ★何から印字しているか★ を code で辿り、その出どころが entry index か 別の index かを決める★。★run 0 が既定・要るなら本数と目的を固定して申告★。
- ★陽性対照★ = ★独立に分かっている map(例 = INTRO の entry)で 同じ辿り方をして 一致するか★。
- 出力 = ★3 値(同一 / 別体系 / 決まらない)★ + 根拠 file:line。
- ★これが閉じるまで、R1 以降の entry 指定は「仮定の上」★。

### R1. ★原盤 reachability walk★(器 = worker2 = 本命)
- 入力 = ★R0 で確定した stic02 / fact02 の entry★。
- 器 = ★到達可能性の復号器★(★線形ではない★)= ★section directory の各 entry point から始め、後継を辿る★。
- 後継の作り方(★今夜の機構をそのまま使う★):
  - ★消費規則表(89 逐語)で 次の位置★
  - ★0x18 standalone★ = ★表の ★全 entry★ を後継に入れる★(★添字は runtime ゆえ ★過大近似★★)
  - ★0x19 式の項 mode 0x10 / 0x18★ = ★base + u16 を後継に★(★条件の真偽は runtime ゆえ ★両方★★)
  - ★0x13 / 0x14 / 0x15 / 0x16 / 0x17 / 0x66 の ABS★ = ★行き先を後継に(base 差替を伴うものは ★別 entry へ跨る★ と明記)★
  - ★LongJmp★ = ★その経路の終端★(★a1 の値を記録★)
- ★★止まる規則(force しない)★★:
  - ★固定長でない(0x10 / 0x1A)★・★長さの概念が無い(0x19 の standalone)★・★0x64 の可変長 sub★ に当たったら ★そこで打ち切り、★到達集合を「未確定」に格上げ★★。★推測で先へ進まない★。
  - ★overlay 帯に出たら ★open として止める★★(★overlay は 開かないと決めています★)。
- 出力:
  - ★到達集合(byte 位置)★ + ★その中に ★standalone 0x24★ が在るか★
  - ★★判定の非対称性を必ず明記★★ = ★過大近似ゆえ ★「集合に 0x24 が無い」= 撃たれない は 強い否定★・★「在る」= 撃たれ得る に留まる(弱い肯定)★★
  - ★3 値★(到達する / 到達しない / 未確定)+ ★未確定なら ★どこで止めたか★ を全部列挙★
- ★受理条件★ = ★母集団 + tool 名 + 打ち切り + 飽和★ / ★陽性対照(既知の到達点を到達と判定できるか)★ + ★陰性対照(到達しないはずの位置)★ / ★対照が通らなければ 数を出さない★。

### R2. ★交差検証★(器 = worker1)
- ★同じ entry を 自分の器で独立に歩き、★到達集合と 0x24 の verdict★ を突合★。★中間値は共有しない★。
- ★食い違いは 発見として そのまま出す★。

### R3. ★draw 順★(★R1 / R2 で 0x24 が到達すると出た場合のみ★)
- ★到達 path 上の draw の順序★を出す。
- ★★次元を畳まない★★ = ★『draw 順』の referent は 未確定のまま★(worker1 §7 A1 = ★193 site の一致は推定★)⇒ ★「C1(RNG draw 順)の内部の話」と 明記して出す★。

### R4. ★remake 比較 → gap★(★R1-R3 の後★)
- ★原盤 reachability と remake の挙動を 突合し gap を出す★。★gap は flag であって 修正ではない★(★修正は PRESIDENT gate・push HOLD★)。

## 3. 割り当てと役割

| 段 | 本命 | 交差 | run |
|---|---|---|---|
| R0 | ★worker3★(placer / log 側を握る) | ★boss1 が突合★ | ★0 が既定・要れば申告★ |
| R1 | ★worker2★(消費表 + EXE RE) | — | ★0★ |
| R2 | ★worker1★ | ★boss1 が突合★ | ★0★ |
| R3 | ★worker2★ | ★worker1★ | ★0★ |
| R4 | ★worker1★ | ★boss1★ | ★0★ |

## 4. 不変(全段)

★実装 0 / game code 0 行 / compile 0 / rebuild 0 / push HOLD★ / ★不可触 4 点(引き渡し 98ae1499…3032・w3_588c・integ 152885f9・README c661db4)+ w3_601a★ /
★共有 main は a0d5ff58 read only★ / ★A5(0x800bb544)の中身は 未読・停止★ / ★overlay 未開封★ / ★park 全維持★ / ★視覚忠実は user 実視覚まで凍結★ /
★router を指定しない opcode 表記を使わない(script VM 5 band に限定)★ / ★判別力の無い対照は 通っても根拠にしない★ / ★退路を true に畳まない★。

## 5. 私が見ている risk(先に出します)

1. ★R0 が「別体系」と出ると、今夜の私の待ち行列 doc §1 の数(entry101 / 139 / 153)は ★別 entry を見ていたことになります★★ ⇒ ★§1 は PENDING-SEPARATION のまま・置き換えない★。
2. ★R1 の到達集合が「未確定」で埋まる可能性★ = ★可変長 opcode が stic02 / fact02 に多いと 早期に止まります★ ⇒ ★その場合は ★どこで止まったか の列挙自体が 成果★(★次に開く札になる★)。
3. ★過大近似は ★肯定側を弱くします★★ ⇒ ★「0x24 が在る」で終わらせず、★その 0x24 が どの条件下で撃たれるか★ まで要求するかは ★R3 の設計事項★。
4. ★overlay に出たら そこで止まります★ ⇒ ★overlay を開ける判断が 必要になる可能性★(★今は開けない★)。

---

## 6. ★R0 決着後の追記(2026-08-23・PRESIDENT 裁定)★

### 6.1 ★的が確定しました★
- ★stic02 = ★DG.SCN entry 127★ / fact02 = ★entry 140★★(R0 = worker3 #604-A・★boss1 が DG.SCN entry 0 の 0xFB record から独立再現して一致★)。
- ★log の `idx` は ★map(region)index★ であって entry ではない★ = ★★以後 idx と entry を 同じ語で呼ばない★★。

### 6.2 ★R1 の受理条件に ★待ち行列 (b) の閉鎖★ を追加(PRESIDENT 指示)★
- ★1 つの walk で 2 つを同時に閉じます★:
  1. ★entry 127 / 140 で ★standalone 0x24 が到達するか★★(= R1 の本題)
  2. ★★その 0x24 が var[110] へ書くか・arg は 2 / 99 か★★(= ★待ち行列 (b) = Phase 0 の「arg=2 が stic02 / arg=99 が fact02」の出どころ再 baseline★)
- ★分岐の読み方(★先に固定します★)★:
  - ★持っていれば★ = ★Phase 0 の arg 帰属は ★entry 側で裏づけられた★★。
  - ★★持っていなければ★★ = ★Phase 0 の arg 値は ★別 source(landed Stages 表など)由来★★ ⇒ ★★その source を さらに追う★★(★「無かった」で止めない★)。
  - ★決まらなければ★ = ★3 値でそのまま★(★止まった場所を列挙★)。
- ★★注意 = 生 byte 走査で数えないこと★★ = ★項と opcode の分離が要る★(★PENDING-SEPARATION の理由は R0 が閉じても 依然 有効★)。

### 6.3 ★渡す順序(変更なし)★
- ★entry 127 / 140 は ★R1 / R2 の骨と対照が通ってから★ 渡します★。★今は渡していません★。

### 6.4 ★次の候補(まだ出していません)★
- ★map 表 255 行 全数の census(★構造を辿る walk★)★ = ★器 = worker3 が候補★。★★構造盲の byte 走査では 同じ限界に当たります★★(★boss1 の FB 走査で 225 超が 2 件混入した実例★)⇒ ★復号器の後★。
