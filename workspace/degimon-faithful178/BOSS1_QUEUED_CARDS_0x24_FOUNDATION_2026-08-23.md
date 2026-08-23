# boss1 待ち行列 — 0x24 foundation の潜在 crack(2026-08-23・PRESIDENT 指示で doc 化)

★status = ★保持のみ・今は開きません★★。★1 枚ずつの原則を守り、★0x0A handler 逐語(+ entry 進入点)が先★★。
本 doc は ★材料の保全★ が目的で、★結論を出していません★。

## 0. 位置づけ(★畳まないための枠★)

- ★これは「新しい矛盾」ではありません★ = ★NEXT_PHASE_REGISTRY §4.5 が 既に自分で
  「★2 map の実 site が本当にこの arg でこの述語に入るか(実行 path 同定)= 測っていない★」と明記済★。
  ⇒ ★既に開いている札に ★材料が付いた★ という位置づけ★。
- ★Phase 1 (e) は retroactive に壊れません(PRESIDENT 明確化)★ = ★(e) は 0x24 handler の出力分布を
  arg 2 / 99 で検定した ★handler test★ であって ★正しく立ちます★。★実 scene がその arg を使うかは §4.5 park★。
- ★∴ 本 doc を「Phase 1 の受理が揺らいだ」と読ませないこと★。

## 1. 観測(boss1 の生 byte 実測・DG.SCN 直読)

器 = `/home/ken/Desktop/Digimon/degimon_world_remake/extracted/DG.SCN`(692,224 B・md5 `8910720ca7f74ca898b2f06b504a5ccc`)
母集団 = ★各 entry の span 全体(OFF[i]..OFF[i+1])★ / tool = python3 の生 byte 走査 / ★打ち切り無し・cap 無し = 飽和なし★

| entry | 由来 | `24 00 6E` 件数 | arg byte(+3) | body 開始 rel |
|---|---|---|---|---|
| ★101★ | worker1 A3 の INTRO_ENTRY | ★5★(rel 0x44 / 0x5A / 0x70 / 0x7E2 / 0x7F8) | ★5 件とも 0x63 = 99★ | 0x24 |
| ★139★ | worker3 R1 log の `map=stic02 idx=139` | ★0★ | — | 0x20 |
| ★153★ | worker3 R2 log の `map=fact02 idx=153` | ★1★(rel 0x43E) | ★0x09★ | 0x38 |

- ★registry §4.3 の前提 = 「arg=2 site が stic02 / arg=99 site が fact02」★ ⇒ ★上の実測と向きが合いません★。
- ★★但し これは registry が誤りだという主張ではありません★★(下の §2 の未検証仮定を参照)。

## 2. ★この観測が依っている 未検証の仮定(1 つ)★

- ★`[PLACE-SPECIES] map=stic02 idx=139` の `idx=` が ★DG.SCN の entry index と同一の番号体系★ であること★。
- ★これは boss1 の仮定であって 観測ではありません★。★対応が別体系なら §1 の表は 別の entry を見ています★。

## 3. 待ち行列(★PRESIDENT が格上げ・0x0A の次に 順に開く★)

### (a) ★idx ↔ entry 対応の検定★
- 内容 = ★log の `idx=` が DG.SCN の entry index と同一かを 1 度確かめる★。
- 器 = ★worker3(placer / log 側を握っている)= 安価★。★run 要否は worker3 の申告制★。
- ★これが閉じるまで §1 の表は「仮定の上の観測」★。

### (b) ★Phase 0 の「fact02 arg=99 / stic02 arg=2」の出どころ再検★
- 疑い(★推論★)= ★Phase 0 の arg は ★DG.SCN の entry body ではなく 段 table か別構造★ から読んだ可能性★。
- 根拠 = §1 の実測と向きが合わないこと ★のみ★(★仮定 §2 の上★)。
- ★閉じ方 = source 直読で再 baseline★(★引用されている値でなく 実 code / 実 byte を読む★)。
- 規範 = ★結論は code に反映されたとは限らない★ / ★oracle を検証せよ(一致でなく)★。

## 4. 不変(本 doc の時点)

★実装 0 / run 0 / compile 0 / push HOLD / 不可触 4 点(引き渡し 98ae1499…3032・w3_588c・integ 152885f9・README c661db4)+ w3_601a /
park 全維持 / A5(EXE 0x800bb544)未読・停止 / a0d5ff58 は測定 read only / 視覚凍結★。

## 5. 今 開いている札(参考・本 doc の外)

- ★0x18 の表の長さ★(handler は表を skip しないので この handler には材料が無い)
- ★base = buffer 先頭 が entry 先頭と一致するか★(= `0x800EC21C` の逐語 = buffer が 1 entry か複数か)
- ★entry 101 の rel 0x2A が 原盤で実行されるか★(= ★今 worker2 が読んでいる 0x0A handler★)

---

## 6. ★★追記(2026-08-23・#602-C 後)= ★§1 の私の実測も 疑いの対象になりました★★★

- ★原盤 EXE の逐語で ★byte には 2 つの人格が在る★ことが確定★(boss1 + worker2 が独立に確認):
  - ★standalone opcode★ = router 表 `0x8011B0F8` の [byte − 0x10] → handler
  - ★`0x19` 式の中の ★項★★ = ★mode 場 = `byte & 0x38`★ で評価器 `0x800EF4F0` が分岐
- ⇒ ★★`0x24` も `(0x24 & 0x38) == 0x20` の項 と混ざり得ます★★
  ⇒ ★∴ ★§1 の「entry 101 = 5 件 / entry 139 = 0 件 / entry 153 = 1 件」は ★生 byte 走査★ ゆえ
    ★standalone opcode 0x24 と 式の項 を分離していません★★。
- ★∴ §1 の表は ★PENDING-SEPARATION★★ = ★分離後に数え直すまで、待ち行列 (b) の材料としての重みも 保留★。
  ★数は消しません(死票ではなく 未分離)★。
- ★閉じ方の札 = ★文脈込み復号器★★(= worker2 が今 作っています・★census class 全体を unblock する前提 tool★)。
- ★同型の波及(記録のみ・今は掃きません)★ = ★raw byte 走査で opcode を数えた doc / code は 全部 疑い★
  (worker1 の `0x24` census 1,265 / 740 / 687・本 doc §1・過去の `0x18` 依存 claim 等)。
  ★順序 = 復号器の後★(PRESIDENT 確定)。

---

## 7. ★★決着(2026-08-23・R0 = worker3 #604-A)= ★§1 は 別 entry を見ていました★★★

- ★待ち行列 (a)(idx ↔ entry の検定)は ★閉じました★★ = ★答 = ★別体系★★。
  - ★log の `idx` = ★map(region)index★★(EXE `0x8013541C` の map 表・★255 件★)
  - ★DG.SCN の entry index は 別の番号(★225 件★)★
  - ★構造的な反証 1 行★ = ★log に `map=topn01 idx=238` が在り ★238 > 224★ ⇒ ★entry index では在り得ない★★
- ★★∴ §1 の「entry 139 / 153」は ★stic02 / fact02 ではありません★★★ = ★別の scenario entry を見ていました★。
  ★これは 私(boss1)の仮定が誤っていた ということです★(★PENDING-SEPARATION の宣言は 免責ではありません★)。
- ★正しい対応(★boss1 が DG.SCN entry 0 の 0xFB record から 独立に再現・worker3 と一致★)★:

  | region(log の idx) | map | ★DG.SCN entry(loader)★ |
  |---|---|---|
  | 139 | ★stic02★ | ★127★ |
  | 153 | ★fact02★ | ★140★ |
  | 238 | topn01 | 178 |
  | 204 | twna01 | ★149★(★live binding と一致★) |
  | 109 | mayo00 | ★101★(★boss1 が補完 = worker3 は本便で未取得と申告★) |

- ★副産物 = ★entry 101 は 結果として 正しかった★★ = ★但し理由が違います★ = ★「INTRO の entry」ではなく ★mayo00(region 109)の loader が 101★★。
  ⇒ ★★結果が合っていることは 過程の正しさを保証しない の 3 例目★★(今夜 boss1 側で 3 回目)。
- ★§1 の数の格★ = ★★破棄ではなく 付け替え★★ = ★entry 101 の 5 件は 生きる(mayo00 の loader ゆえ)★ / ★139・153 の数は ★別 entry の数★ として 残す(消さない)★ /
  ★stic02 / fact02 の数は ★entry 127 / 140 で 測り直し★★ ⇒ ★但し ★測り直しは 生 byte 走査ではなく 到達可能性復号器で★★(★項と opcode の分離が要る = PENDING-SEPARATION の理由は 依然 有効★)。
- ★boss1 の器の限界(自己申告)★ = ★私の FB record 走査は ★構造を見ない byte 走査★ ゆえ 264 件を拾い、★loader 値に 225 以上が 2 件混入★しました(★max 33788 = 明らかに record ではない★)。
  ⇒ ★上の 5 件は 個別に確かめた値ゆえ立ちます★が、★★255 行 全数の census は ★構造を辿る walk が要る★★★ = ★worker3 の「飽和未確認」の申告は 正当★。

---

## 8. ★★待ち行列 (b) 決着(2026-08-23・#607-A + #608-B)= ★Phase 0 は 最初から 正しかった★★★

### 8.1 ★答★
- ★★段(進行度 gate)と その直前の 0x24 は ★DG.SCN entry 0★ に在ります★★ = ★entry 127 / 140 では ありません★。
- ★一次 byte(worker3 が一次まで降り・boss1 が検算)★:
  - ★stic02 = abs 0x0025F2(entry 0 rel 0x1DF2)★ = `F5 00 5D 13 | 24 00 6E 02 | 19 00 | 0B 00 6E 00 | 81 00 35 01 | 18 00`
    ⇒ ★arg ★2★ / 閾値 ★0★ / flag ★309★★
  - ★fact02 = abs 0x00289A(entry 0 rel 0x209A)★ = `F5 00 5D 16 | 24 00 6E 63 | 19 00 | 0B 00 6E 02 | 81 00 E3 00 | 18 00`
    ⇒ ★arg ★99★ / 閾値 ★2★ / flag ★227★★
- ★到達(#608-B・boss1 検算)★ = ★★両方とも 到達 = 弱い肯定★★ / ★root = section id 0x008B / 0x0099★ / ★経路 = root(0xFB) → 0x1E → 0x5D → 0x24 の 4 手・同じ骨★。
- ⇒ ★★arg 2/99・閾値 0/2・flag 309/227・到達 = ★7 点すべて 一次で立ちました★★★。

### 8.2 ★★§1 / §6 の私の記述を 訂正します★★
- ★§1 の「entry 139 / 153」★ = ★map(region)index を entry と誤読していた★(★§7 で既に訂正済★)。
- ★§1 を「entry 127 / 140」に読み替えた後の観測★ = ★entry 127 = 生 0x24 6 件すべて arg 99 / entry 140 = var[110] 書き 0 件★ = ★★事実として真★★。
- ★★但し 私が そこから引いた推論「∴ Phase 0 の arg ↔ scene の向きは 逆か 別 source」は ★誤りでした★★★
  ⇒ ★正しくは「★段が entry 0 に在るので entry 127 / 140 では 裏づけようがない★」★。
  ⇒ ★★観測は真・推論が誤り★★ = ★今夜 boss1 側の H4 の 1 例★。
- ★§6 の PENDING-SEPARATION★ = ★★解除しません★★ = ★生 byte 走査が 項と opcode を分離しない、という理由は ★今も有効★★
  (★但し 待ち行列 (b) の材料としての重みは ★不要になりました★ = ★一次と到達で 直接立ったため★)。

### 8.3 ★待ち行列の状態★
| 札 | 状態 |
|---|---|
| ★(a) idx ↔ entry 対応の検定★ | ★★閉じた(#604-A・R0)★★ = ★別体系(idx = map/region index)★ |
| ★(b) Phase 0 の arg の出どころ再 baseline★ | ★★閉じた(#607-A + #608-B)★★ = ★Phase 0 は正しい・段は entry 0★ |

### 8.4 ★残っている札(本 doc の外)★
- ★0x1E / 0x5D / 0x81 の意味★(★場の位置だけ判っている★)
- ★0xFB の第 1 引数(0x7F / 0x8C)が何か★
- ★entry 0 の跨ぎ 359 本の先★(= ★draw 順に要る★・★③④ は未 open★)
- ★未到達の 0x24(entry 0 で 45 件)の分類★
