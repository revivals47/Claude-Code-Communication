# 送信保留 queue(boss1・走行中の pane はつつかない ⇒ 次の idle で渡す)

| 宛 | 中身 | file | 状態 |
|---|---|---|---|
| worker1 | PRESIDENT 伝言(#572-A 撤回と SJIS 偽陽性の自主申告 + retro-sweep は本日の最良の仕事) | — | ★渡済(01:2x)★ = #579-A 本文の §0 に載せて発行 |
| worker3 | #583-C ① の回答 = ★command block に足さない(推奨は取り下げ)★ + ★便 0820-12 の新制約(既存行の書き換え不可・触らない 3 箇所・編集後は 4 点報告)★ | scratchpad/r_w3_nocmd.txt(本文は下に転記) | ★保留★ = exit 3 が 2 度(--wait 込み)。★#580-C を止めない★ / 「足すなら 1 便」に対して★便が来ない = 足さない★ゆえ実害なし。次の idle(=#580-C 事前登録の報告時)に渡す |

## worker3 宛の要点(転記・失っても再構成できるように)
・推奨(command 隣に 1 行)は★取り下げ★。理由 = 申告は 100-107 行 = command block(85-97 行)の直後に既に在る(PRESIDENT が実物で確認)。boss1 が読まずに推奨を出した瑕疵。
・★user は 01:1x に手順を逐語で受け取り済★ ⇒ 以後の編集は★「確かめられていないこと」への追記だけ★。
・★触らない★ = command block(85-97) / §2 の表(26-28) / log の見かた(110-)。★行追加は可・既存行の書き換えは不可★。編集後は★4 点(時刻・mtime・行数・sha)★で報告。
・#580-C の受理条件で★崩さない 1 点★ = ★1 本目(_9)と違う答が出たら合わせにいかずそのまま出す★(PRESIDENT も名指し)。

## worker1 宛の要点(転記)
・PRESIDENT 伝言 = ★#572-A の撤回と、自分の器の偽陽性(SJIS 下位 byte 0x8175)を先に申告して retro-sweep したことは本日の最良の仕事★。足す条件は無し・#578-A をそのまま。

## 追加 queue(2026-08-20 01:2x)
| worker2 | #578-A の retro-sweep で ★#576-A の数が 43 件中 35 → 21 に減った★(食い違いではなく母数減)。あなたの 8 件検算は ★一致 6 / 食い違い 0 / 出なかった 2(0xE3=fact02・0xE7=gias03)★。原因は新しい器が site に届かなかった分(被覆 61.7%)。★var gate の判断に効く可能性があるので #577-B の報告時に渡す★ | ★渡済(01:2x)★ = #578-B 本文の §0 に載せて発行 |

| worker1 | ★#579-A の追い口(便 0820-14)★ = (C) は現物照合で成立 / ★実測 = entry101 で 0x57(pc=0xA6) と 0x0A(pc=0x29) が停止・0x75 の VM-GATE 行は 0 本だが★log は 0xA6 より先を走っていない = 母数の限定★★ / 初回は★process 単位★(_gateSeen は static・W1AbReset 呼び元ゼロ) / ★DEGIMON_VM_GATE は未配線の comment・実在は W1_GATE_NEVERSTOP=1(起動前 env)★ / 追い口 = NEVERSTOP 1 run で (A)(B) 同時取得・★但し run は boss1 の GO を待つ(user の観測を汚さないため)★ / 0x0A は PC 整合ずれの札 | 全文 = QUEUED_579A_ADDENDUM_2026-08-20.md | ★渡済(01:3x)★ = #580-A 本文の §0-§1 に載せて発行。queue は空 |

## GUI/compile の token(boss1 が直列化する)
・★現在の保持者 = worker1(#580-A の NEVERSTOP run / BODYSTART A-B)★。撃つ直前と走り終えたら 1 行ずつ。
・worker3(#584-C)は静的側を先に。使う段で申告 ⇒ worker1 が返してから渡す。
・worker2 は compile 器を持たない(mcs/csc/dotnet/mono すべて不在)ゆえ compile 検収は worker3 の build のみ。
・置き去り(after≠0)を boss1 が観測したら ★PRESIDENT の 1 行を待たず即停止★(緊急停止権の前渡し・便 0820-16)。

## queue(01:4x・便 0820-17 の 2 通・どちらも exit 3 で未達)
| worker3 | ★#584-C の「README に足さない」を覆す★ = §7(3) 末尾に PRESIDENT の逐語 1 項を足す(要約せずその文字列で)+★編集前に 4 点を採り 195 行・ade78986…・01:11:41 と一致を確かめてから★+★GUI/compile の token を渡す★(worker1 が返却・after census 0/0 を boss1 も 01:40:16 に独立確認) | QUEUED_584C_README_2026-08-20.md | ★保留★ |
| worker1 | ★A/B の oracle 差し替え★ = 第一 oracle は VerifyEntry の matchedChars/emitted(現 0・原盤 277)/ ★停止行の有無は第二★ / ★遊ぶ側の 2 度目の Begin は pc=0xA6 まで走り、文字が出るかは未測定 = 断定しない★ / ★実装するな・env(DEGIMON_FAITHFUL_BODYSTART=1)を立てるだけ★(G2 env-gate は 2026-07-25 land 済) / land 条件 (a)(b)(c)・(c) 未了なら land しない | QUEUED_580A_ORACLE_2026-08-20.md | ★保留★ |
