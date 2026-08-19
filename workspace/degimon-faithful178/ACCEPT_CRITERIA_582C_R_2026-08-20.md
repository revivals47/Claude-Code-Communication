# #582-C-R 受理基準(事前登録・PRESIDENT 便 0820-04・結果が返る前に固定)

★後から基準を作らないための事前登録★。判定は PRESIDENT。boss1 は本 7 項で一次照合してから上申する。

(1) build の絶対 path が /tmp 配下でない。かつ workspace/build と build_handoff_444c を書いていない
    → PRESIDENT が 3 dir の mtime を自分で撃つ。報告の額面では受けない。
(2) Unity batchmode の error CS が 0 件。件数そのまま(「通った」だけは不可)。
(3) S1-S5 が 5 本とも今日の器で撃たれている。S5 = W3_MEASURE_FLAGS=203 で [W3-MEASURE-FLAG] 0 行 かつ全行逐字同一。
(4) (d) の grep は実行行と件数そのまま + 陽性対照が非ゼロ。陽性対照 0 ならその件数は採用しない(器が拾えていない可能性が先)。
(5) (e) は 起動前/後の process 数の差が +1・窓 id を明示・[PLACE-SPECIES] の行が新 build の log に在る。
    絵の忠実さと 1 体の同定は受理条件に入れない(入れると user の PASS が意味を失う)。
(6) sha256 は 一致=傍証 / 不一致=FAIL ではない。但し不一致なら差分の在り処(どの file が違うか)まで。
(7) README は §2 の path/sha 更新 + 改名 commit + 本文の 581C 表記残り 0 件を grep で提示。

## PRESIDENT が報告と独立に自分の器で撃つ 3 つ
(1) の 3 dir mtime / (5) の process 計数と窓 / (7) の 581C 残り grep。
★食い違ったら報告ではなく器を採る★。食い違い自体も台帳に残す。

## user 手番
(1)-(7) が揃うまで user を呼ばない。揃ったら PRESIDENT が README ごと mayo00 1 map を見せる。

## boss1 の照合メモ(2026-08-20 00:5x)
・発行済 dispatch(commit c4b198e)との対応: (1)=(a) / (2)=(2 の不変 compile 条) / (3)=(c) / (4)=(d) / (5)=(e) / (6)=(b) / (7)=(f) で全項が本文に既出。
・差分は 2 点だけで、いずれも★新たな実測を要求しない提示形式★: (5) の「差 +1」は本文の「起動前後で数える」から算出可 / (7) の「581C 残り 0 件を grep」は本文の「本文中の 581C 表記も点検」の提示形式。
  ⇒ 追加 dispatch は出さない(worker3 を止めない)。報告受領時に不足していれば boss1 が追撃 1 便で回収する。

---

## 器の瑕疵 1 件(2026-08-20 00:5x・boss1 が踏み PRESIDENT が訂正・便 0820-06)

★走行判定に語尾まで含む pattern を使い『worker2 は idle』という★偽の不在★を作った★。

・私の測定 = tmux capture-pane -p -t multiagent:0.N | tail -3 | grep -c 'esc to interrupt' ⇒ worker2 = 0
・PRESIDENT の器 = 同 pane に「Architecting… (1m 33s → 2m 49s・token も増加)」= ★走行中★
・再現(boss1 が撃ち直し) = worker2 は full='esc to interrupt' で 0 / prefix='esc to interr' で ★1★
・★但し pane 幅は説明になりません★ = worker2 と worker3 はともに 65 桁だが worker3 は full でも 1。
  ⇒ 幅は必要条件ですらなく、★その行の中身(spinner の経過時間表記の長さ)次第で切れる位置が動く★。
・remedy = ★省略記号が出る器では前方一致で採る★(語尾を pattern に入れない)。走行中の pane はつつかない
  (入力欄に文が残る failure mode を自分から作るため)。

★同型 3 例目★: (1) 囮 log(workspace 側 send_log.txt) (2) 語尾切れ (3) 一度きりの process 計数。
共通形 = ★測った対象/範囲が違うのに測定は沈黙する★ ⇒ ★不在を主張する前に、測った対象そのもの(pwd・wc -l・pattern・陽性対照)を並べて示す★。
