# 引き継ぎ（2026-08-19 02:5x・★PRESIDENT が OS 再起動の前に 採取★）

★この file は status を持ちません★ = ★status は 器に訊く★。書いてあるのは
★① 再起動の手順 ② 開いている user 手番 ③ 私が user に 負っている訂正 ④ 本日 効いた型★ の 4 つ。

---

## 1. ★再起動の手順★

```bash
cd /home/ken/Documents/Claude-Code-Communication
./setup.sh                      # ★multiagent 4 pane（boss1 + worker1-3）＋ president を作り直す★
# 各 pane で claude を起動したあと:
#   boss1  → workspace/degimon-faithful178/HANDOFF_2026-08-19_boss1.md（comms 1f35986・81 行）を読ませる
#   worker → 本文は logs/send_log.txt から復元できる（下の awk）
```

★★boss1 への briefing は ★私の要約を渡さない★★★ = ★彼自身の doc を 読ませる★
（★要約を渡すと 私の理解の劣化が そのまま 出発点に 焼き付きます★）

## 2. ★★開いている user 手番 = 1 件（★これだけ★）★★

★引き渡し build を user に見せる★。★呼ぶ条件（全部 揃ってから）★:

| # | 条件 |
|---|---|
| 1 | ★S1-S5 全通過★（S5 = 203 を付けても 何も起きない） |
| 2 | ★実 GUI で 窓と `[PLACE-SPECIES]` が 出る★（★絵の判定では ない★） |
| 3 | ★README に ★branch 名と sha★・3 系統の根拠・限定・`_3` の落ち方★ |

★見せるのは `mayo00` ★1 map だけ★★ ∵ ★そこだけ 根拠が 3 系統★（原盤 byte / 実機 / 我々の実装）。
★他 map は 「表どおり」しか 言えない★ ⇒ ★見せると user の PASS が また 意味を 持ちません★。
★進行後の絵も 見せません★（★見せる = 注入口を 渡す★）。

## 3. ★★★私が user に 負っている 訂正 4 件（★次に user に 触れる時 必ず★）★★★

1. ★★入れ替わりが 消えたのは 忠実化★★ = ★新規開始の `mayo00` は ★アグモン 1 体のみ★・★進めれば 入れ替わります★★
   ・★user 逐語「入れ替わっています。昼はモドキベタモンで、夜はドクネモンです。」は ★原盤の その進行度では 起きない絵★ でした★
2. ★段が 塞ぐ map = ★42/48 は 誤り・正 = 14/47★★（★42 は 近接・14 が 鎖★）
3. ★`twnb01` の バケモン説 = ★撤回★★（★bit 237 が 出るのは gcan01/02/03★）
4. ★★未説明の対の 数は ★述べません★★★（★22 も 20 も 測定では ない・差の 2 組（room06）は ★2 器で 割れて 未判定★★）

★user 自身が 取り下げたもの★ = ★「アグモン（パートナー）」の ★同定★★（★観測「アグモンが居た」は 残る★）
⇒ ★★引用は 「アグモン」まで・「（パートナー）」を 付けない★★

## 4. ★器の呼び方（status はここから）★

| 知りたいこと | 呼ぶもの |
|---|---|
| ★止まった agent の 原因★ | ★★`logs/send_log.txt` の `ATTEMPT` / `SENT`★★（★ATTEMPT だけ = 途中で死んだ★）★本日 3 度 これで 救出★ |
| ★dispatch 本文の 復元★ | `awk 'NR>=<行>' logs/send_log.txt \| sed '1s/^\[[^]]*\] <agent>: SENT - "//' \| awk 'NR>1 && /^\[2026-/{exit} {print}'` |
| agent が 動いているか | `tmux capture-pane -p -t multiagent:0.N \| tail -3` に `esc to interrupt` ／ ★＋ 1.6 秒あけて md5 が 変わるか★ |
| ⚠ pane の 見え方 | ★★空の箱には ★古い frame★ が 残ります★★ ⇒ ★1 文字 打ってから 読む★ |
| player process | ★`ps -eo args --no-headers \| grep -c '[D]egimonLive.x86_64'`★（★`comm` は Unity が改名するので 常に 0★） |
| repo 実体 | ★`/home/ken/Desktop/Digimon/degimon_world_remake`★（`~/Desktop/degimon_world_remake` は 別 path） |
| ⚠ doc の path | ★comms 側 `workspace/degimon-faithful178/`（406 本）★ ⇐ ★degimon repo に 同名 dir・中身 別（122 本）★ |

## 5. ★不変（全便に明記してきたもの）★

・★push は user の 個別指示のみ★（★origin/main = `ca34f972` から 動かしていません★）
・★land は PRESIDENT の承認★ / ★「完成」「arc 完了」は user 実視覚まで 書かない★
・★`workspace/build/` と `build_handoff_444c/` は 不可触★ / ★`track/measure-fade-tile` は delete/reset/rebase/worktree remove しない★
・★savestate と `.bak` は 読取のみ★（取り直せない） / ★`git add -A` 不使用★
・★agent-send は pipe しない★（SIGPIPE） / ★backtick は file 経由★ / ★ack 冒頭に【配布済】★
・★★worker の pane を PRESIDENT が 直接 触らない★★（★8/19 に 侵して boss1 に 戻しました★）

## 6. ★★本日 効いた型（★台帳 §6-de に 全部 在ります・ここは 索引★）★★

・★★間違った対象の測定は ★沈黙しない★★★ — `var[203]`(byte) の 0 が `flag[203]`(bit) の 0 として 半日 流通（4 人）
・★★数を 渡す時 ★名詞を 2 語★（何を / どの集合で）★★ — 「近接 42」を「塞ぐ 42」として user に 渡した
・★★user 実視覚 PASS は ★そう動く★ 証拠であって ★そう動くべき★ 証拠では ない★★
・★★user がくれるのは ★観測★ — ★同定を 頼ってはいけない★★★
・★★『同一』と『同等』を 書き分ける★★ — 生成 C# = byte 同一（厳格）／ Unity build 成果物 = 挙動の同等
・★★引き渡す artifact に ★state を 変えられる口★ を 同居させない — ★観測の口は 残す★★
・★★未実装の gotcha 欄は ★未来の bug 台帳★★★ — 本日の bug は 2026-07-15 の doc に 予言されていた
・★★台帳を 内向きだけに 使っていた★★ — 「未説明 N を 進捗指標に しない」は ★user への 報告にも 掛かる★

## 7. ★API 529 の 手当て（本日 多発）★

★観測★ = ★1 往復 ≒ 40 秒・★5 往復（≒3 分半）で 落ちます★★ / ★context の 大小では ありません（clear 後も 落ちた）★
★手当て★ = ★★① 1 turn = tool 3 回以内 ② doc を commit してから ack ③ ack は 3 行★★
∵ ★★2 回とも ★完成した報告が 送信の段で★ 消えました★★ ⇒ ★commit を 先に すれば 消えるのは ack だけ★

---

## 8. ★再起動後に器で採った事実（2026-08-19 02:5x・PRESIDENT）★

・★OS 再起動 = 02:46:45★（`uptime -s`）／ tmux は 02:47:33 に作り直し済 = ★4 pane とも履歴ゼロの新規 session★
・★★#582-C の引き渡し build は 消えました★★ = README §2 の出力先が ★scratchpad(/tmp 配下)★ だったため
　　実測 = `find /tmp -maxdepth 8 -name 'build582*'` → ★0 件★ ／ `/tmp/claude-1000/` 配下は本 session の dir のみ
・★source は無事★ = `track3/w3-582c-userbuild` HEAD `152885f9` は git に在る ／ `origin/main` = `ca34f972` のまま
・★README の実体★ = ★comms 側 `workspace/degimon-faithful178/USER_RUN_README_581C_DRAFT.md`★（degimon repo 側ではない）
　　§2 branch+sha / §4 根拠 3 系統 / §5 限定と `_3` の落ち方 まで揃っている。★但し file 名が 581C のまま（中身は #582-C）★

⇒ ★★§2 の user 手番は 「build の作り直し」が済むまで 呼べません★★（3 条件のうち ②が 器ごと 消えたため）。
　 02:5x に boss1 へ割り直しを 1 便（rebuild 先を ★/tmp 配下にしない★・S1-S5 は ★消えた器の PASS を使い回さず 全部撃ち直す★）。

### ★新しく効いた型★
・★★引き渡す artifact を ★揮発する器★ に置かない★★ — ★PASS の証跡ではなく ★PASS した器そのもの★ が 消える★
・★★`byte 不一致 = FAIL` に しない★★ — Unity 生成物の byte 再現性を 我々は測っていない ⇒ ★挙動同一 + 差分の在り処★ で退く

### ★02:5x 追記 — boss1 は 529 で 落ちました（★私の便は 未処理★）★
・pane 0.0 逐語 = "API Error: 529 Overloaded" ／ "Churned for 3m 10s" ⇒ ★doc 読了も ack も していません★
・★PRESIDENT session は健在★（同時刻に tool を連続実行できている）⇒ ★529 は 我々の側の問題ではない★
・★再開時に投げ直す本文 2 通は send_log の この行から★: 731139 731183 
　　復元 = §4 の awk（agent 名 = boss1）
・★次に boss1 が立ったら 順序は 変えない★ = ①自分の doc を読む ②3 行 ack ③worker3 に rebuild（§8）

---

## 9. ★2026-08-20 00:5x — 2 度目の再起動後に器で採った事実(PRESIDENT)★

・★OS 再起動 = 2026-08-20 00:40:57★(`uptime -s`)／ tmux は 00:45:24 に作り直し = ★4 pane とも履歴ゼロ★。
・★昨日 boss1 が 529 で落ちて以降、rebuild は 1 歩も進んでいません★
　　実測 = `find /tmp /home/ken/Desktop -maxdepth 6 -name 'build58*'` → ★0 件★。
　　`-integ` 配下の build は `workspace/build` / `build_handoff_444c` / `build_m437c` の 3 つのみ・★mtime は全て 8/16★(= 今回の器ではない)。
・★source は無事★ = worktree `degimon_world_remake-integ` が `track3/w3-582c-userbuild` HEAD ★152885f9★。`origin/main` = `ca34f972` 不動。
・★不安定な観測★ = 00:5x に `DegimonLive` process が ★2 本★→ 1 分後 ★0 本★。
　　⇒ ★GUI 検証の前に必ず数え直す★(古い窓を新 build と取り違えない)。★1 回の計測で在/不在を決めない★。
・再投函 = boss1 へ ★0820-01(自分の doc を読む→3 行 ack)★ と ★0820-02(§8 の割り直し・今日の数字で採り直したもの)★。
　　0820-01 の ack 受領済(【配布済】・doc 読了・要約は渡していない)。

### ★手順の瑕疵(自分の分・記録して再発を止める)★
・★`agent-send.sh` を `| tail -2` に通しました★ = ★pipe 禁止の規範違反★。
　　今回は log 行が残り pane も busy だったので ★届いています★が、★配達 oracle は SENT 行と受け手の通番 echo★。
　　⇒ ★出力を削りたい時は pipe でなく 送信後に `tail logs/send_log.txt` を別 command で読む★。

### ★00:5x 追記 — 割り当ての順序(0820-03)と ★囮 log★★
・boss1 は #582-C-R を worker3 へ発行(00:49・着手 ack あり・本文は commit c4b198e で保全)。本文を送信 log から復元して検収 = ★条件 (a)-(f) 保持・(e) に process 計数と窓 id を追加★ ⇒ ★差し戻し無し★。
・★順序の裁定★ = ★worker3 は #582-C-R 専任★(★#580-C 反復は rebuild 判定の後★ ∵ user 手番を最短で開ける + ★Unity batchmode compile と DISPLAY=:1 を 1 本ずつ★)。
　★worker1/worker2 は #577-A / #576-B を再投函★・★受理条件は逐字復元★(worker1 = `729599` 行 / worker2 = `729661` 行。02:31 の便は /clear 通知ゆえ本体ではない)。
　★compile が要る段は boss1 に申告させて serialize★。
・★★同名の囮 log★★ = ★復元用は repo root の `logs/send_log.txt`(★731,398 行★)★。
　★`workspace/degimon-faithful178/logs/send_log.txt` は ★8/15 までの 131 行★の別物★。
　私は cwd が `degimon-faithful178` に残ったまま grep し ★worker1/2 の SENT 0 件・`577-A` の言及 0 件★ という ★偽の不在★ を採りました。
　⇒ ★不在を主張する前に `pwd` と `wc -l` で ★測った対象そのもの★ を示す★(★間違った対象の測定は沈黙する★の 2 例目・本日)。

### ★00:53 追記 — ★#582-C-R の受理基準を 結果が返る前に 事前登録★(0820-04)★
★後から基準を作らない★ため、★7 項★を先に固定しました(便 0820-04)。
　(1) build の絶対 path が ★/tmp 配下でない★ + ★`workspace/build` と `build_handoff_444c` を書いていない★
　(2) Unity batchmode の ★error CS が 0 件★(件数そのまま)
　(3) ★S1-S5 が 5 本とも 今日の器で★ + ★S5 = `W3_MEASURE_FLAGS=203` で `[W3-MEASURE-FLAG]` 0 行 かつ 全行逐字同一★
　(4) (d) の grep は ★実行行と件数そのまま + 陽性対照が非ゼロ★(★陽性対照 0 なら件数を採用しない★)
　(5) (e) は ★process 数の差が +1★・★窓 id 明示★・★`[PLACE-SPECIES]` が 新 build の log に在る★
　　　★絵の忠実さと 1 体の同定は 受理条件に入れない★(入れると ★user の PASS が意味を失う★)
　(6) sha256 は ★一致 = 傍証 / 不一致 = FAIL ではない★・★不一致なら 差分の在り処まで★
　(7) README は ★§2 更新 + 改名 commit + 本文の `581C` 残り 0 件を grep で提示★
★私が報告と独立に自分の器で撃ち直す 3 つ★ = ★(1) の 3 dir の mtime★ / ★(5) の process 計数と窓★ / ★(7) の `581C` 残り grep★。
　⇒ ★食い違ったら 報告ではなく 器を採る・食い違い自体も台帳に残す★。

### ★走行の座(00:52)★
・worker3 = ★#582-C-R★(着手 ack 済) / worker1 = ★#577-A★(00:52:17) / worker2 = ★#576-B★(00:52:22)
・再投函は ★逐字復元★(worker1 30 行 / worker2 32 行)・boss1 が足したのは ★context ゼロの明示★ と ★compile は申告して serialize★ の 2 点のみ。
・boss1 の実測 `wc -l logs/send_log.txt` = ★731,440 行★(私の 731,398 との差は本日の送信増分)。

### ★00:56 — ★報告が来る前に★ 私が器で採った #582-C-R の実測(PRESIDENT・独立)★
★これは判定ではありません★ = worker3 の完了報告は未着。★報告に形を合わせられない位置で採るため★に先に撃ちました。
・★新 build = `/home/ken/Desktop/Digimon/w3_build582r/DegimonLive/`★(watch が 00:51:44 に検知) ⇒ ★/tmp 配下でない★(受理基準 (1) 前半 ○)
・★不可触 3 dir は無傷★ = `workspace/build` = ★8/16 01:11★ / `build_handoff_444c` = ★8/16 13:16★(受理基準 (1) 後半 ○)
・★器の同形★ = `DegimonLive.x86_64` ★4,472 byte★ ・ `UnityPlayer.so` ★42,108,768 byte★ = ★参照 build と同一サイズ★
・★`Assembly-CSharp.dll` = 256,512 byte・sha256 頭 `98ae1499…`★ = ★#582-C の値と一致★
　　⇒ ★これは傍証であって証明ではない★(★byte 再現性を我々は測っていない★・★一致しても FAIL/PASS を決めない★)
・★S1-S5 の log が今日の器で在る★ = `runs/S1 S2 S3h3 S3h22 S4 S5`(00:52-00:5x)+`GUI.log`/`GUI2.log`/`probe.log`
・★`[W3-MEASURE-FLAG]` = ★S5 を含む全 log で 0 行★★(受理基準 (3) の片側 ○ / ★逐字同一の側は報告の command 行を見るまで未判定★)
・★`[PLACE-SPECIES]` = `GUI.log` 2 行・S1/S3/S4/S5 も 2 行★ / ★`S2.log` は 0 行★ ⇒ ★S2 が退路(明示 OFF)の便かは 報告を見るまで断定しない★
・★窓★ = `wmctrl_after.txt` = `0x00e00008 0 ken-All-Series unity`(★窓 id 明示 ○★)
⇒ ★残るのは (2) error CS 件数・(3) 逐字同一・(4) grep の陽性対照・(6) 差分の在り処・(7) README 改名と `581C` 残り★。

### ★00:59 — ★(5) の「差 +1」は worker3 の器では原理的に採れない★(PRESIDENT 実測・0820-08)★
・★新 build の player が走っている最中★に採りました(pid 57829)。
　★`readlink /proc/57829/exe` = `/home/ken/Desktop/Digimon/w3_build582r/DegimonLive/DegimonLive.x86_64`★
　⇒ ★その窓は 新 build のもの(古い窓ではない)★ = ★窓の帰属は exe で決まる★。
・★`cat /proc/57829/comm` = 「Unity Main Thre」★ ⇒ ★worker3 の gui_run.sh は `ps -eo pid,comm` で数えている★
　⇒ ★走っている今この瞬間に count = 0★。★before 0 → after 0 で 差 +1 は出ない★ = ★器が盲目★。
　★∴ 報告の計数が 0/0 でも「起動していない」を意味しない★。
・★`ps -eo args | grep -c 'DegimonLive.x86_64'` = 3 のうち ★2 本は私の watch★★(find の引数に文字列が入る)
　⇒ ★args 形は 私の道具が汚す★。★watch は停止済★。
・★正しい oracle★ = ★`readlink /proc/*/exe` が 新 build の exe と一致する数★(★comm 改名にも watch にも汚されない★)。
　★before を採る前に 残っている player を kill させる★(★残 1 本が before を 1 にする★)。

#### ★私の瑕疵(4 例目)★
★(5) を受理基準に入れた時 ★どの形で数えるか★ を書かなかった★。
⇒ ★★数を求める時は 数え方まで書く★★。★本日の同型 4 例★ = ★囮 log / 語尾切れ / 一度きりの process 計数 / comm で数えた player★
　= すべて ★測る対象と器を書かずに 数だけ求めた★。★この型は 台帳(HANDOFF §4 の器の表)に既出だった★ = ★索引を引かずに基準を書いた★。

### ★01:00 — ★受理基準 (7) を 私が誤って書いた★(0820-09 で訂正)★
・★誤★ = 「★`581C` 残り 0 件を grep で提示★」。★実測 = 改名後の README に 2 件残る★
　　= ★5 行目「元 ticket = #581-C」★ / ★50 行目「#581-C で 既定 ON に しました」★ ⇒ ★どちらも来歴の言及★。
　⇒ ★0 件を求めると ★来歴を消させる★★。★正 = 残った `581C` を ★来歴の言及★ か ★今の器の指示★ か 1 件ずつ区別して示す★。
・★器で採れた分(報告の前・独立)★
　　★改名済★ = commit ★f30e8de★(`..._581C_DRAFT.md` → ★`..._582C_DRAFT.md`★)
　　★dll 行は新しい★ = 256,512 byte / `98ae1499…3032` = ★私の実測と一致★
　　★但し §2「出力」行が まだ `<scratchpad>/build582/...`★ = ★消えた器の path のまま★ ⇒ ★(7) の本体はここ★
　　　★報告後もこの行が古ければ FAIL★(★user に 存在しない path を渡すことになる★)
・boss1 の 2 条を採用 = ★kill は worker3 自身に撃たせる★ / ★exe 比較は前方一致 + 陽性対照★(★`readlink` は build dir 作り直しで `(deleted)` が付き ★完全一致が沈黙する★★ = ★私が見落としていた穴★)

#### ★型(本日 5 例目・基準の側の欠陥)★
★★受理基準そのものを 検証していなかった★★ — ★(5) は 数え方を書かず★・★(7) は 0 件という 誤った形★。
⇒ ★★基準を書いたら ★基準を 器に当てて 空撃ちする★★★(★結果が来る前に 一度 自分で撃つ★)。
　★今回は 空撃ちしたから 2 件の来歴が 消される前に 止められた★。

### ★01:01 — ★私の README 観測は 書き足し途中の 1 時点だった★(boss1 の指摘・受け入れ)★
・boss1 の実測(01:00 頃) = ★`581` 残り 3 件(6/7/110 行)・3 件とも来歴★ / ★§2 出力行(26 行)は ★既に新 path★★。
・私の実測(01:01:53・★3 点目★) = ★mtime `01:01:00`・194 行・sha `da5693ec…`★ / ★`581` = 3 件★ /
　　★26 行 = `/home/ken/Desktop/Digimon/w3_build582r/DegimonLive/DegimonLive.x86_64`★・27 行 = build log 同 dir。
　⇒ ★私の 01:00 の「§2 は消えた器の path のまま」は ★書き足し途中を読んだ時点差★★。★誤りとして訂正します★。
・★規範(boss1 の形を採用)★ = ★★走行中の worker が書いている file は at-rest ではない★★
　　⇒ ★(7) の判定は 報告受領後に撃つ★(★走行中の pane をつつかないのと同じ理由★)。★今この差で PASS も FAIL も付けない★。
　　★file を読む時も ★時刻・mtime・行数・sha★ を添える★(★行番号だけでは 時点差と 食い違いを 区別できない★ = 5→6 / 50→110)。
・★これは台帳既出の型★ = ★「live RE は at-rest で読む — 遷移途中 read は stale mirror」★ ⇒ ★file にも掛かる★と拡張。

### ★01:0x — ★§3 の「user に負っている訂正 4 件」は 本 session で 渡しました★(PRESIDENT)★
・渡した先 = ★user 本人★(2026-08-20 の 1 通目の返信)。★4 件とも逐語で★ + ★「アグモン（パートナー）」の同定は引用しない★も併記。
・★user からの応答は まだ ありません★ ⇒ ★「受け取られた」とは書きません★(★送達 ≠ 受領★)。
・★次 session は 再送しないこと★(★同じ訂正を 2 度渡すのは 台帳の腐り★)。★但し user が同じ誤りを再び前提にしたら その場で 1 件だけ★。

## 10. ★01:10 — ★#582-C-R を 受理(7/7)・user 手番を 開きました★(PRESIDENT 判定・便 0820-11)★
★報告と独立に私が撃った 4 つ★(全部一致):
・(1) ★不可触 3 dir = 8/16 のまま★ / (7) ★README は at-rest★(mtime 01:01:00・194 行・sha `da5693ec…`・01:01:53 と 01:08:48 で不変)・★581 = 3 件 全て来歴★・★§2 は新 path★
・(3) ★S1 と S5 の全文 diff を 私自身が撃った = 4 行 = 2 対だけ(Processor MHz 3948/3839 と UnloadTime)★・★`^\[PLACE` 行 diff は空 = 逐字同一★
・(5) ★pid 57829 の exe = 新 build★ = ★私は worker3 の census を見る前に採った★ ⇒ ★独立に一致★
★boss1 の判定材料 1(AUTOBOOT_SEC=60)は 器の上で既に満たされていた★ = 申告は ★100-107 行 = command block(85-97)の直後★。★§6 まで読まれなくても届く★ ⇒ 追加要求なし。
★足させた 1 行★ = ★GUI3 の run で player 座標が (2.64,0,35.85)→(5.19,0,21.16) に動いた★を「確かめられていないこと」へ(★原因は書かない★)。
★errors=3★ = ★README に既出(開示済)★ゆえ ★札のまま受理★。
★解除★ = #580-C を worker3 に積んでよい(★§3 の 1 行が先★) / worker1 #578-A・worker2 #577-B を承認 / 時刻 gate を bit と混ぜない draft 先行を承認(★land は私の承認★)。
### ★user 手番の中身(私が渡すもの)★
・★build = /home/ken/Desktop/Digimon/w3_build582r/DegimonLive/DegimonLive.x86_64★ / README = ★workspace/degimon-faithful178/USER_RUN_README_582C_DRAFT.md★
・★見せるのは mayo00 1 map だけ★ / ★新規開始は 昼も夜も 1 体 = 変わらないことも仕様★ / ★絵の忠実さの検証ではない・同定はしない★

### ★01:13 — README の +1 行を PRESIDENT が器で確かめました(worker3 の値は正しい)★
・現物 = ★195 行・sha `ade78986…`・mtime 01:11:41★ / commit ★79c7b32★ = ★1 file・1 insertion★。
・追加は ★末尾(195 行目)の「確かめられていないこと」への 1 行★ = 座標 (2.64,0,35.85)→(5.19,0,21.16)・★入力は送っていない/他からの入力は未確認/理由は判らない★まで。
　⇒ ★command block・§2 の表・log の見かたは 不動★ = ★user が持っている値は動いていません★(0820-12 の制約は守られた)。
### ★★私の道具が また 偽の不在を作りました(本日 7 例目)★★
・私は `git diff 79c7b32^ 79c7b32 -- <file> | grep -E '^[+-]' | grep -v '^[+-][+-]'` で ★差分 0 行★ と読みました。
・真因 = ★追加行の中身が markdown の箇条書き `- ` で始まる★ ⇒ diff 行は ★`+- ★私の…`★ ⇒ ★`^[+-][+-]` に当たって 私の filter が消した★。
・★`+++`/`---` を落とすつもりの filter が ★本物の追加行★ を落とした★ ⇒ ★★diff は `git show`(生)で読む・filter で削らない★★。
・型 = ★★除外規則そのものを検証していない★★(台帳 `feedback_fabricate_in_incidental_fields` = ★引いた線自体を検証★)。
