# #555-C（原盤の 到達可能性 棚卸し）— ★中断時点の 記録★（worker3）

★boss1 の 指示で ★#556-C を 優先★・本便は ★中断（破棄では ありません）★★

## 1. ★到達可能な map（★実測 log からの 集計★）★
- ★A savestate 12 本の 現在 map = ★7 種★★（twna01 / twna13 / frzl17 / gias06b / mgen98 / mist04 / mayo01）
- ★B 各 loader の 1-hop 出口 = ★41 種★★（#551 の 既存 log を 再集計）
- ★C launch で ★実測到達★ = ★3 種★★（mayo00 / mayo02 / mayo04a）
- ★★∴ A∪B∪C = ★50 種★★★

## 2. ★(i) 15 組との 交わり★
★★(i) の per-pair map 一覧は ★doc に 在りません★★★
⇒ ★私が 使ったのは `W1_X103_RESULT_553A.md` §3 の map 列挙（11 種）★ = ★★私の 当てはめです★★
⇒ ★★交わり = 5 種★★ = `mayo02` / `mayo04a` / `mgen99` / `mist07` / `room20`

## 3. ★未了（本便で 書けなかった もの）★
- ★(3) 他の 到達路（原盤側）★ … ★★`DEGIMON_BOOT_MAP` は remake の env で ★原盤に 相当物は ありません★★★
  ⇒ ★launch harness は ★我々の 測定器★ であって ★player が 歩く 路では ありません★★（★この 区別は 保ちます★）
- ★(4) 所要見積★ … ★実測上界 = ★regtest 1 run ≤ 86 秒★★（★7 run が 600 秒 timeout 内で 完了した ことから★）
