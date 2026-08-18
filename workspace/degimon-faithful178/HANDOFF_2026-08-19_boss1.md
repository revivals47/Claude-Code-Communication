# 引き継ぎ（2026-08-19・boss1 が context 99% で書いた）

★この file は 状態を 持ちません★ = ★★status は 器に 訊く★★（下の §4）。
書いてあるのは ★① 3 面の 座 ② 残り 2 手 ③ user に 述べる 3 点 ④ 対象と 例外 ⑤ 不変★ だけ。

---

## 1. ★到達点（1 段落）★

★`mayo00` の 74/83 が 時刻で 入れ替わるのは ★script が HOUR で 分岐している★ から★ = ★PRESIDENT 裁定・land 済★。
★その手前に ★もう 1 段（進行度 gate）★ が 在り★、★原盤は ★勧誘済みなら 野生個体を 置かない★★。
⇒ ★2026-08-19 に ★段を land★★（main = `6980befd` 系 / ★★`origin/main` は `ca34f972` = push していません★★）。
⇒ ★受理条件は 全部 通過★（序盤 1 体 / 進行後 昼夜 2 体・`slot` まで 原盤と一致 / 陰性対照 / 退路）。

★★但し 数の 枠★★（★これを 落とすと 誤読されます★）:
```
  96/96   = ★build 対 build★（極性）        13/13 = ★実装 対 ★我々の表★★（自己整合）
  48/48   = ★4 項目のうち 効いたのは 1 つ★  ★原盤と slot で 突き合わせたのは `mayo00` だけ★
  14/47   = ★塞いでいる数★（★42/48 は ★近接★ = 別の量★）
  未説明   = ★20 組（R2'・母数 214・L-b）★ = ★★『我々の 定義の 影』★★（規則を 変えると 18〜67 に 動く）
           ★22 は旧・差 = room06 の 2 組★ ／ ★★『20 組』と書いた 測定 doc は 1 本も無い（22 − room06 2 組 の 導出値）★★（台帳 §6-de-40 の 2026-08-19 追記）
```

## 2. ★残り 2 手（★順序を 飛ばさない★）★

| ★①★ | ★反復 1 本（別 state）★ | ★worker3 #580-C★ ／ ★「進行後 2 体」が `_9` ★1 本★ ゆえ 母数 1★ |
| ★②★ | ★`user` build★ | ★★印字 gate `DEGIMON_PLACE_SPECIES` を ★既定 ON★★★ ＋ ★README に hash と ★3 系統の 根拠★★ |
| ★③★ | ★`user` を 呼ぶ★ | ★★PRESIDENT の 座・boss1 は 呼ばない★★ |

★★見せるのは `mayo00` だけ★★ ∵ ★そこだけ 根拠が ★3 系統★（原盤 byte / 実機 / 我々の実装）★。
★他 map は ★『表どおり』しか 言えません★★ ⇒ ★見せると `user` の PASS が また 意味を 持ちません★。

## 3. ★`user` に 述べる 3 点（PRESIDENT が 述べる）★

1. ★★新規開始の `mayo00` で 入れ替わりが 起きなく なった = ★退行でなく 忠実化★★★
2. ★訂正 = ★`42/48` → `14/47`★★（『近接』と『塞ぐ』を 混ぜていた）
3. ★訂正 = ★`twnb01` の バケモン説は 撤回★★

## 4. ★器の 呼び方（★status は ここから★）★

| 知りたいこと | 呼ぶもの |
|---|---|
| ★★失った dispatch の 本文★★（★本日 3 度目の 救出路★） | ★`logs/send_log.txt` から 逐字 復元できます★ = `awk 'NR>=<行>' logs/send_log.txt | sed '1s/^\[[^]]*\] <agent>: SENT - "//' | awk 'NR>1 && /^\[2026-/{exit} {print}'`（★#577-A = 729599 から 30 行 / #576-B = 729661 から 32 行★） |
| ★worker が 動いているか★ | `tmux capture-pane -p -t multiagent:0.N \| tail -3` に ★`esc to interrupt`★ が 在るか |
| ★★送ってよいか★★ | ★`./agent-send-idle.sh <agent> <file>`★（★busy なら 送らず exit 3★・`--wait 秒` 可） |
| 送信が 届いたか | `logs/send_log.txt` の ★`SENT` 行★ ＋ ★本文★ ＋ ★相手の 応答開始★ ＋ ★同一宛への 間隔★ |
| ★★compile★★ | ★`/home/ken/Unity/Hub/Editor/6000.4.11f1/Editor/Unity -batchmode -nographics -quit -projectPath <repo>/unity -logFile <log>`★ ⇒ ★`grep -c 'error CS'`★ |
| land した 表 | `unity/Assets/Scripts/Field/TimeGatePreGate.cs`（★生成物・手で 直さない★）／ 生成器 = `degimon_world_remake-p2w2/workspace/tools/w2_gen_pregate.py` |
| ★doc の path★ | ★★`/home/ken/Documents/Claude-Code-Communication/workspace/degimon-faithful178/`（★comms repo★・406 本）★★ ⇐ ★degimon repo 側にも ★同名 dir★ が 在り 中身が 違う（122 本）★ |
| 本体 doc | `degimon_world_remake/docs/TIME_PLACEMENT_DEFAULT_ON_2026-08-18.md`（★§3.1-3.20★） |
| 台帳 | `workspace/degimon-faithful178/P2_VM_SPEC_2026-08-11.md` §6-de（★本日 (6-de-29)〜(6-de-54)★） |

## 4-b. ★worker の 座（2026-08-19 02:3x）★

・★worker1 / worker2 は PRESIDENT が /clear して 再発進★（529 で 出力ゼロの turn が 2 度・抱えた context の処理に 3 分半）
  ⇒ ★★彼らの context は 空★★ = ★報告が薄くても 経緯を知らないため★ ／ ★★以後の dispatch は doc を 絶対 path で・前提を 本文に 書く★★
・★worker3 は 継続★（#578-C 系の branch `track3/w3-578c-measure-flagport`）

## 4-c. ★走行中 dispatch の 受理条件（★log から 復元済・boss1 が 判定に 使う★）★

・★#577-A（worker1）★ = ★(1) `opcode 0x75`（NPC スポーン・12 byte 固定）を 5 entry で 数える★ ＋ ★#572-A の「5 entry は NPC を置く entry ではない」を ★維持するか 撤回するか★★
　　★陽性対照★ = ★doc の 3 体（グレイモン `0x2C2` / ベーダモン `0x2B3` / ティラノモン `0x2BA`）を 自分の器が `DG.SCN` から 拾えるか★ ⇒ ★拾えなければ 数を出さない★
　　＋ ★(2) ガード flag 4 組（`0xAE`↔`0xFA` / `0xE5`↔`0xE9` / `0x257`↔`0xE3`・`0xEF` / `0x81`・`0x10A`↔`0xE2`）が 我々の code で 参照されているか★ = ★組ごと★ ＋ ★段の表（9 map）と 重なるか★
・★#576-B（worker2）★ = ★落とした 5 map（`fact02` `fact04` `frzl08` `mist03`段2 `stic02`）を 実装できる形に できるか★
　　★受理 4 本★ = ★(1) 事前登録＋探索集合の定義★ ／ ★(2) remake に `var` を読む口が在るか（`GetVar` 相当・手がかり `EventOracle.cs:118` = eventBank +0x159 の 256 byte）★ ／ ★(3) 各 map の条件を ★演算子つき★ で（`0x0A`=`>=` / `0x8B` `0x08` `0x0B` は ?・判らないなら 判らないと書く）★ ／ ★(4) 陽性対照 = 既に載せた 9 map の どれかを 同じ器に通し 同じ答（bit の OR）に成るか ⇒ 通らなければ 5 map の答を出さない★
　　★『表に足すべき』の判断は boss1 が持つ★（足すなら ★生成器の側★・手で直さない）

## 5. ★対象と 例外（★段★）★

・★段が 有効 = ★7 map★★（`mayo00` `mist07` `gias02` `gias03` `koda00` `mist02` `mist04`）
・★保留 2 map = `gias04`（`ElsePlace` が ★空★）/ `trop04`（1 体だけ・終端 token 未復号）★ ⇒ ★`ElsePlace` が 完成したら 外す★
・★対象外 = `fact04`★（段 2〜5 が bit を 読まない）／ ★`var` 比較で 落とした 5 map = `fact02` `fact04` `frzl08` `mist03`段2 `stic02`★
・★段の 意味★ = ★各段は ★OR★・段の間は AND★ ／ ★通らなければ ★`ElsePlace` の slot ★だけ★ 置き 時刻分岐に 進まない★★

## 6. ★不変★

★`push` は `user` の 個別指示ごと★（★`origin/main` = `ca34f972`★）／ ★「完成」「arc 完了」と 書かない★
★`agent-send` は pipe しない・backtick と ★ドル記号つき register 名★ は file 経由★
★`savestate` / `.bak` は 読取のみ★ ／ ★`workspace/build` と `build_handoff_444c` は 不可触★
★★doc を commit してから ack を 送る（ack は 短く）★★ = ★本日 2 回 ★完成した報告が 送信の段で 消えた★（API 500 / 529）★
★★land する側が compile を 通さないなら それは land でなく 提案★★（★本日 1 度 踏んだ★）
