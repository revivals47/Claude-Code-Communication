# ★#490-C 事前登録★（worker3）— ★撃つ前に 書きます★

## ★★先に 確かめたこと（§2 の 検算）★★
★boss1 の 主張★ =「VM の pc 進行は `Len` に 依るので `Len` の oracle に ならない」
★私の 検算（code 直読）★ = `DialogueRuntime.cs:837` = ★`int len = OpcodeTable.Length(c);`★
　／ `:94` = ★`public static int Length(byte op) => Len[op];`★
⇒ ★★∴ boss1 の 主張は ★正しい★★★（★`Len` の oracle には なりません★）

## ★★既存の 器が 在りました（新しく 作りません）★★
★`DEGIMON_OPTRACE=1`★ = ★既に 実装済★（`:679` で env 読取・`:809` で 印字・★既定 OFF★）
★印字★ = `pc / b0 / opcode 名 / len / bytes[6] / pages`
★window★ = `DEGIMON_OPTRACE_LO` / `_HI`（hex）
⇒ ★★∴ 私が 足すのは ★entry / section の 併記★ だけ★★（★boss1 の (2) の 要求分★）

## ★予想（★撃つ前★）★

| # | 予想 |
|---|---|
| ★O①★ | ★gate OFF（未設定）で `[OPTRACE]` = ★0 行★★ |
| ★O②★ | ★gate OFF の 画が ON 前と ★1 bit も 変わらない★★（★F④ と 同じ形の 対照★） |
| ★O③★ | ★`=1` で ★行が 出る★★（母数は 撮って 数えます = ★先に 埋めません★） |
| ★O④★ | ★出た pc の 範囲が ★entry の body 長 以内★★ |
| ★O⑤★ | ★★出た pc の うち SJIS-text と 印字された 行が 在る★★（worker2 の「51.9% は text」と 突合可） |

## ★★限定（doc に 明記します）★★
・★★実行した 範囲しか 出ません★★（= ★全数では ない★）
・★★`Len` の oracle では ありません★★（pc 進行が `Len` に 依るため）
・★得られるのは ★どの byte 範囲が 実際に code として 実行されたか★ の ground truth★
