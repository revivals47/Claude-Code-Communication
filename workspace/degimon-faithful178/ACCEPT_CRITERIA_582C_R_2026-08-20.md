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

---

## PRESIDENT が★報告の前に★器で採った分(便 0820-07・00:56・commit 363bbac)

★判定ではない★。★報告に形を合わせられない位置で採るため★の先行観測。worker3 は止めていない。

| 受理基準 | PRESIDENT の器で採れた分 | 残り |
|---|---|---|
| (1) path と不可触 | 新 build = /home/ken/Desktop/Digimon/w3_build582r/DegimonLive/ (watch 検知 00:51:44) = /tmp 外 ○ / workspace/build = 8/16 01:11・build_handoff_444c = 8/16 13:16 = 無傷 ○ | — |
| (2) error CS | — | ★件数を報告で★ |
| (3) S1-S5 | log が今日の器で在る(runs/S1 S2 S3h3 S3h22 S4 S5・00:52-00:5x)+GUI.log/GUI2.log/probe.log / [W3-MEASURE-FLAG] は S5 含む全 log で 0 行 ○ | ★逐字同一の側(S5 の command 行と diff)★ |
| (4) grep | — | ★実行行・件数・陽性対照が非ゼロ★ |
| (5) GUI | 窓 = wmctrl_after.txt = 0x00e00008 0 ken-All-Series unity = 窓 id 明示 ○ / [PLACE-SPECIES] = GUI.log 2 行・S1/S3/S4/S5 も 2 行 | process 数の差 +1 / ★S2.log だけ 0 行の意味★ |
| (6) sha | Assembly-CSharp.dll = 256,512 byte・sha256 頭 98ae1499… = #582-C と一致 ⇒ ★傍証(証明ではない・PASS も FAIL も決めない)★ | 一致以外の差分の在り処 |
| (7) README | — | ★改名 commit と 581C 残り 0 件の grep★ |

★S2.log の [PLACE-SPECIES] 0 行★ = ★退路(明示 OFF)の便なのか別の理由かを報告に書かせる★。PRESIDENT も boss1 も断定しない。
⇒ boss1 の一次照合は★この 5 つ + S2 の理由★に絞る。既に器で採れた分を報告の額面で上書きしない。

## 走行判定の規範(確定形・便 0820-07 で支持)
★幅で場合分けしない★ / ★常に前方一致で採る★ / ★陽性対照(同じ pattern が他 pane で 1 を返すか)を同時に撃つ★。

---

## (5)「差 +1」は worker3 の器では原理的に採れない(便 0820-08・PRESIDENT 実測・00:5x)

・実測 = 新 build の player が 1 本走っている(pid 57829)。readlink /proc/57829/exe = /home/ken/Desktop/Digimon/w3_build582r/DegimonLive/DegimonLive.x86_64
  ⇒ ★その窓は新 build のもの(古い窓ではない)★ = (5) の後半は PRESIDENT の器で既に採れた。
・cat /proc/57829/comm = 「Unity Main Thre」= ★Unity は comm を改名する★
  ⇒ worker3 の gui_run.sh は ps -eo pid,comm | awk '$2 ~ /[Dd]egimon/' で数えている = ★走っている今この瞬間に count 0★
  ⇒ ★before 0 → after 0。差 +1 は原理的に出ない★。★報告の 0/0 は「起動していない」を意味しない(器が盲目)★
・ps -eo args | grep -c 'DegimonLive.x86_64' = 3 だが ★うち 2 本は PRESIDENT の watch process★(find の引数に文字列が載る)
  ⇒ ★args 形は観測者自身の道具が汚す★。watch は 0820-08 時点で停止済。

### 正しい oracle(追撃 1 便で使わせる形)
```
for p in /proc/[0-9]*; do [ "$(readlink $p/exe)" = "<新 build の絶対 path>/DegimonLive.x86_64" ] && echo $p; done | wc -l
```
= ★exe の実体で数える★(comm 改名にも観測者の watch にも汚されない)。before/after とも同じ形で。

### boss1 が足す 2 条(追撃 1 便に載せる)
1. ★kill は worker3 自身に撃たせる★ = 走行中の pid 57829 が worker3 の (e) 実行中の便である可能性がある。
   ★boss1/PRESIDENT が先に kill すると 他人の走行を壊す★ ⇒ 追撃 1 便で「自分の実行分を落としてから before を採る」と書く。
2. ★exe の比較は前方一致で★ = build dir を作り直すと readlink は末尾に " (deleted)" を付ける ⇒ 完全一致は★沈黙する★。
   (走行判定の語尾切れと★同じ穴★ = 常に前方一致・陽性対照を同時に撃つ)

★同型 4 例目★(PRESIDENT 申告) = 囮 log / 語尾切れ / 一度きりの process 計数 / comm で数えた player
共通形 = ★測る対象と器を書かずに数だけ求めた★ ⇒ ★数を求める時は数え方まで書く★。
