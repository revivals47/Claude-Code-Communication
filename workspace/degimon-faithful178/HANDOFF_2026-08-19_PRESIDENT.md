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
