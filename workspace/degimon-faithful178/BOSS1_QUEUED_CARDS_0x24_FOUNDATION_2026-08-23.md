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
