# P2_6CAA_JOIN_worker2 — ★boss1 の join を 検める（script 0x4B ↔ overlay event）★

★受領★ = boss1 #571 ②／ ★測定時点★ = 2026-08-15 ／ ★emulator 非接触★
★器★ = ★w2_cell_census（image）★ ＋ ★w2_overlay（overlay・自前 decoder）★
★★帯を 分けて 書きます★★ = ★image = 0x80090800..0x8013E000（177,664 語）★ / ★overlay = 0x80050000..0x80090800（66,048 語）★

## ★1. ★★① join は ★成立します★★★★

```
 ★★同じ cell か★★ = ★はい★ = ★[gp-0x6caa] = ★0x8013E162★★（gp = 0x80144E0C・中継値）
 ★★同じ 幅か★★   = ★はい★ = ★image 側も overlay 側も ★sh / lhu（half・2 byte）だけ★★
   ⇒ ★byte（sb/lbu）/ word（sw/lw）の access = ★両帯とも 0 件★★
 ★★引用 address の 検算★★:
   ★boss1 の 引用『0x800ED774』= ★opcode 0x4B の handler（arm）の ★先頭★★（★band[0x46,0x59) の index 5・表 0x8011B200★）
   ★その arm の 中の 実際の store = ★0x800ED7B0  sh $v0, -0x6caa($gp)★★（★arm 範囲 0x800ED774..0x800ED7EC の 中★）
   ⇒ ★★∴ ★arm として 正しく、store site は 0x800ED7B0★★★（★どちらも 誤りでは ありません★）
 ★★逐語（0x4B arm の 該当部）★★:
   ★800ED7A4  sh $v0, -0x6cac($gp)★  ← ★★副 index★★
   ★800ED7A8  lbu $v0, 0x2e($sp)★    ← ★script から 読んだ byte★
   ★★800ED7B0  sh $v0, -0x6caa($gp)★★ ← ★★本 cell★★
   ★800ED7B4  jal 0x800EF8E0★
   ⇒ ★★∴ ★0x4B は ★[gp-0x6cac] と [gp-0x6caa] を ★対で★ 書きます★★★
```

## ★2. ★★② 書き手 / 読み手（★両帯・全数★）★★★

| 帯 | 母数 | 書き手 | 読み手 | 幅 |
|---|---|---|---|---|
| ★EXE image★ | 177,664 語 | ★32★ | ★7★ | sh / lhu |
| ★overlay slot4★ | 66,048 語 | ★70★ | ★11★ | sh / lhu |
| ★overlay slot5★ | 66,048 語 | ★70★ | ★11★ | sh / lhu |
| ★★合計（image ＋ 1 版）★★ | ★243,712 語★ | ★★102★★ | ★★18★★ | — |

```
 ★slot4 と slot5 の site は ★1 つ 残らず 同じ★★（= ★byte 一致の 共通部 0x80081000..0x80087FFF ほか に 在る★）
 ★★overlay 側の 読み手 11 の うち ★10 は 例の event 関数の 入口★★★:
   ★0x80086698 / 0x800869E4 / 0x80086B14 / 0x80086C98 / 0x80086DD4 /
    0x800871D4 / 0x80087404 / 0x800875A8 / 0x8008786C / 0x80087C0C★（★残り 1 = 0x8008257C★）
 ★image 側の 読み手 7★ = ★0x800F02D8 / 0x800F8D00 / 0x800FADA0 / 0x800FB528 / 0x800FD5F0 / 0x801054BC / 0x801057E4★
 ★image 側の 書き手 32★ = ★0x800ED7B0（0x4B）/ 0x800EDD20 / 0x800EDF4C / 0x800EE8D0 ほか 28★
```

## ★3. ★★③ 成立すると 何が 言えるか（★事実の 範囲で★）★★★

```
 ★★(a) この cell は ★帯を 跨ぐ 受け渡し★ です★★
   = ★script（image）が 書き★ ★native の event 処理（overlay）が 入口で 読む★
 ★★(b) 書きは ★overlay 側の ほうが 多い★★（70 対 32）⇒ ★★この 層の 主役は overlay 側★★
 ★★(c) 0x4B は ★[gp-0x6cac]（どれ）と [gp-0x6caa]（何を）を 対で 置く★★
   ⇒ ★[gp-0x6cac] は ★resume 表 0x8011B014 の index★（#568）★ / ★[gp-0x6caa] は ★event 関数が 入口で 読む 値★★
   ⇒ ★★∴ ★『どの event を』『どの 段階 / 引数で』の ★2 語 組★ に 見えます★★★（★私は 決めません★）
 ★★(d) ★機構ごとの 欠落★ の 裏取り★★ = ★remake が script を 完全に 実装しても、
   ★この cell を 読む 側（overlay の 10 関数）が 無い★ ので ★受け取り手が 居ません★
   ⇒ ★★∴ ★boss1 #571 ④ の 台帳 1 行と ★同じ 向き★★★（★私は 台帳を 書きません★）
```

## ★4. ★★もう 1 件（★下界が また 埋まりました★）★★★

```
 ★★image だけで 数えると 32 / 7★★ ⇒ ★★overlay 2 版を 足すと 102 / 18★★（★1 版分だけで★）
 ★★∴ ★cell census を image だけで 出すと ★書き手を 3 分の 1 しか 見て いない★ 場合が 在る★★★
 ★★∴ ★#563 の (B) 下界 判定は ★2 例目の 実証★★★（1 例目 = 在庫減算 8 → 12 以上）
 ★★開示★★ = ★★他の 場面の overlay は まだ 見て いません★★ ⇒ ★★102 / 18 も ★下界★★★
```

## ★5. ★母数・窓・形★

```
 ★母数★ = ★image 177,664 語 ＋ overlay 66,048 語 × 2 版★
 ★形★   = ★gp 相対の load・store のみ★（★gp = 0x80144E0C は 中継値★）
 ★窓★   = ★使って いません★
 ★見えない 分★ = ★address を register に 載せて 渡す 経路★ / ★jalr★ / ★他版の overlay★
```
