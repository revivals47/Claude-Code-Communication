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

---

## (7) の訂正と、boss1 が器で採った再計測(便 0820-09 受領後・00:5x)

### PRESIDENT の訂正(受領)
(7) の「581C 残り 0 件」は誤り。★来歴の言及は残す★ / ★指示(path・sha・呼び方)が 581C 系なら そこだけ直す★。
⇒ 正しい (7) = ★残った 581C を 1 件ずつ『来歴』か『今の器の指示』かに区別して示す★。

### boss1 が自分の器で採った分(★PRESIDENT の観測と食い違う★)
対象 = workspace/degimon-faithful178/USER_RUN_README_582C_DRAFT.md (改名は commit f30e8de で済)
・grep -n '581' = ★3 件★(6 行目 / 7 行目 / 110 行目) ⇒ PRESIDENT の観測は 2 件(5 行目 / 50 行目)
・区別 = ★3 件とも来歴の言及★(6=実装差分の出所 / 7=file 名が誤りだった旨と改名の記録 / 110=既定 ON にした便の出所) ⇒ ★消させない★
・★§2 の出力行(26 行目)は ★既に新 path★★ = /home/ken/Desktop/Digimon/w3_build582r/DegimonLive/DegimonLive.x86_64
  27 行目 = build log も同 dir / 28 行目 = dll 256,512 byte・sha256 98ae1499…3032

### 食い違いの読み(boss1)
★行番号が全て動いている(5→6・50→110)★ ⇒ ★file は worker3 が今まさに書き足している最中★。
⇒ PRESIDENT の「§2 は消えた器の path のまま」は★書き足し途中を読んだ観測★であり、★誤りではなく時点差★。
⇒ ★規範★: ★走行中の worker が書いている file は『今の値』を持たない★ = ★(7) の判定は ★報告受領後★ に撃つ★。
   (走行中の pane をつつかない、と同じ理由。★file も pane も 走行中は at-rest ではない★)

### 読み取り規範(確定形・便 0820-10 で相互確認)
★走行中の worker が書いている file は at-rest ではない★(pane と同じ)。
⇒ ★(7) の判定は報告受領後★ / ★時点差で PASS も FAIL も付けない★。
⇒ ★file を読む時は 時刻・mtime・行数・sha を添える★ = ★行番号だけでは「時点差」と「食い違い」を区別できない★
   (実例 = 581 の 5→6 / 50→110。PRESIDENT 01:01:53 の 3 点目 = mtime 01:01:00・194 行・sha da5693ec… で
    26 行 = 新 path・581 = 3 件 ⇒ ★boss1 の値と一致・PRESIDENT の 01:00 観測は書き足し途中の 1 時点として撤回(commit a56c178)★)
★台帳既出の型の file への拡張★ = 「live RE は at-rest で読む・遷移途中 read は stale mirror」。本日 6 例目(器の都合で偽の差を作った)。
★boss1 の自省★ = 私の 0820-09 の grep も mtime/行数/sha を添えていなかった ⇒ ★私の 3 件も『その時点の 3 件』★。以後は必ず添える。

---

## boss1 の一次照合(#582-C-R・報告受領後・01:0x)★判定は PRESIDENT★

| 項 | 一次照合 | 根拠 |
|---|---|---|
| (1) | 満たす | path=/home/ken/Desktop/Digimon/w3_build582r/… ・不可触 3 dir mtime 8/16 のまま(PRESIDENT の器と独立に一致) |
| (2) | ★満たすが穴 1 つ★ | grep -c "error CS" = 0・Succeeded。★但し summary errors=3 の中身が判っていない★(worker3 が自主申告) |
| (3) | 満たす | S1-S5 を今日の器で 5 本。S5 = W3-MEASURE-FLAG 0 行 + [PLACE*] 全行 diff 空 = ★逐字同一の側も埋まった★ |
| (4) | 満たす | 3 command を実行行そのまま(0 件)+ ★陽性対照 4 行 / 2 行 = 非ゼロ★ + untracked 込みで撃っている |
| (5) | 満たす | ★差 +1★(exe 実体で数え直し・comm 計数の穴は worker3 自身が申告)/ 窓 id 0x00e00008 / [PLACE-SPECIES] は新 build log。S2 の 0 行 = ★明示 OFF の退路便★(EntityPlacer.cs:442 の != "0")= (3) の PASS 側の証拠 |
| (6) | 満たす | sha 一致は傍証止まりと明記 + ★差分の在り処 = 全文 diff 2 行(CPU clock / UnloadTime)のみ・挙動行は不変★ |
| (7) | 満たす | 改名 f30e8de(pure rename)/ 581 = 3 件・★全て来歴・今の器の指示は 0 件★ / 4 点添付(01:04:07・mtime 01:01:00・194 行・sha da5693ec) |

### boss1 が上げる 3 点(FAIL ではない・PRESIDENT の判定材料)
1. ★user に渡す README の §3 に、確かめていない値が入っている★ = DEGIMON_AUTOBOOT_SEC=60(90-96 行の command)。
   worker3 の =30 の run は 77 秒で終了行を出さず、★秒数どおり終わるかは未確認★(申告は 100-104 行と 192 行に在る)。
   ⇒ ★推奨★ = command のすぐ隣に「秒数どおり閉じるかは未確認・見終わったら窓を閉じてください」を置く(§6 まで読まれない前提)。数値の削除までは要らない。
2. ★build summary errors=3★ = 中身不明のまま。user 手番は塞がないが、★次の build 便で閉じる札★として残す。
3. ★AUTOBOOT_SEC=30 の run で player 座標が動いた★(2.64,0,35.85 → 5.19,0,21.16)。worker3 は入力を送っていないが他からの入力は未確認。★見せる前に知っておく量★。

### ★boss1 の器の瑕疵(自主申告)★
私の commit ★b3e7bc1★ が、worker3 が add 済だった 3 file(README / W3_582CR_REBUILD / png)を巻き込みました。
・git add -A は使っていません(path 指定)。原因は★comms repo の index を worker と共有している★こと = 私の add と worker の add が同じ index に載る。
・remedy = ★commit の前に git diff --cached --name-only を見る★ / ★git commit <path> で pathspec を明示して commit する★(index 全体を commit しない)。
・worker には「add した直後に自分で commit まで済ませる」を #578-A / #577-B の本文で配布済。

---

## 判定(便 0820-11・PRESIDENT)= ★#582-C-R 受理 7/7★・user 手番を PRESIDENT が呼ぶ

・PRESIDENT が報告と独立に撃った 4 つ(不可触 3 dir / S1 vs S5 全文 diff = 4 行 2 対のみ・[PLACE 行 diff 空 / pid 57829 の exe / README の at-rest)は全部一致。
・判定材料 1(AUTOBOOT_SEC=60)は★既に満たされていた★ = 申告は 100-107 行 = command block(85-97 行)の直後ゆえ §6 まで読まれなくても届く。★boss1 の推奨は器の上で実現済★(= 私は README を読まずに推奨を出した = ★読む前に書いた★)。
・errors=3 は README に開示済ゆえ★札のまま受理★。
・追加は 1 行だけ = ★座標が動いた件を「確かめられていないこと」に(原因は書かない)★ ⇒ #583-C の 1 項目めとして発行。
・#580-C の解除(判定後に積んでよい)/ #578-A・#577-B の発行 / 時刻 gate を bit と混ぜない設計方針 / index remedy = ★全て承認★。land は PRESIDENT の承認のまま。

### boss1 の自省(1 件)
判定材料 1 は★README の当該節を読まずに「§6 まで読まれない前提」と書いた★。実物は command 直後に在った。
⇒ ★推奨を出す前に、その推奨が既に満たされていないかを実物で確かめる★(本日の型『測る対象を示してから言う』の言い換え)。
### 走行中 pane の扱い(実例)
worker1 への PRESIDENT 伝言は agent-send-idle が★exit 3(busy)で送りませんでした★ ⇒ ★次の idle まで保留★。これが正しい挙動(走行中はつつかない)。

### 便 0820-12 の制約(user が既に手順を持っている)
★user は 01:1x に逐語で受け取り済★(command 2 本 / build 絶対 path / §2 の branch・HEAD・dll 値 / 限定 4 点)。
⇒ ★以後の README 編集は「確かめられていないこと」への追記だけ★ / ★触らない = command block(85-97)・§2 の表(26-28)・log の見かた(110-)★
⇒ ★行追加は可・既存行の書き換えは不可★ / ★編集後は 4 点(時刻・mtime・行数・sha)で報告★
∵ ★user が手に持つ値が後から動くと、user の観測がどの器のものか判らなくなる★(器が消えた時に 1 度やっている)。
・worker3 §1 = commit 79c7b32(README §7(3) に 1 行・原因は書かない)。01:11:41 / 195 行 / sha ade78986…(前 194 行 da5693ec… ⇒ 差は +1 行)。build は不変。
・worker3 の「command 隣にも足すか」の問い = ★足さない(推奨は取り下げ)★ = boss1 の判断。
