# P2_WORKER3_STATE — worker3 現在地

★★∴ 引く 順（★これを 守れば 古い 数を 引きません★）★★:
1. ★沈黙 audit の 数★ = `p2w3:workspace/w3_remake/SILENCE_AUDIT.md`（★1 枚に 畳み済★）
2. ★未実装 opcode の 数★ = `p2w3:workspace/w3_remake/ESCALATION_2frames.md`（★2 枠 + 条件 + 軸★）
3. ★全履歴★ = `p2w3:workspace/WORKER3_STATE.md`（92 KB）
★★#286〜#307 の 便に 出た 数は ★射程が 何度も 変わって います★★ ⇒ ★上の file を 引いて ください★。

---

## 現在地（2026-08-14 12:0x / 受領した最後の boss1 番号 = ★#332★）

- ★worktree★ = `/home/ken/Desktop/Digimon/degimon_world_remake-p2w3`（branch `track3/p2-script-walk`）
- ★HEAD★ = `ffead675`（#332 時点）
- ★規範★ = 受領したら最初に `logs/recv_log.txt` に 1 行 / commit は ★path 指定のみ（-a / -am 禁止）★ /
  agent-send は ★単一引用符（backtick も変数記号も使わない）★ / ★数には 測定時点・条件・軸 を隣に★ /
  ★『0 件』には 4 家族のどれかを添える★ / ★台帳に載せる語は 限定を本文に埋める（別行にしない = 規範 (n)）★
- ★不変★ = push しない / 完成 claim 凍結 / ★degimon 共有 tree は読取のみ★ / ★vise も読取のみ（書込は機構で拒否）★ /
  ★p2w2 も読取のみ★ / ★画像は user に出さない★ / ★STATE は送信ごと★

---

## ★★① 閉じたもの（★私の座で これ以上やることは ありません★）★★

| 線 | 結論 | file |
|---|---|---|
| ★沈黙 audit★ | 実行 88 = 前景 78 + 背景 10 / ★実害 有 1・無 77★ / 判定不能 A(背景 10) と B(未検 52) は ★軸が違うので足さない★ | `SILENCE_AUDIT.md` |
| ★2 枠の数★ | 整列静的 ★26.45%★（32,917 / 8,706）/ 到達 ★22.29%★（17,334 / 3,864・★BehavioralMode=true の上★） | `ESCALATION_2frames.md` |
| ★器の A/B★ | 計器 4 site を外しても数は不変 / ★BehavioralMode は数を 37 倍に動かす★（受け手は 1 site） | `AB_JOINCOUNTER.md` / `AB_TRACE_BEHAV.md` |
| ★0x5D の素性★ | site 266 個・★entry 0 が 99.97%★ ⇒ ★件数の軸は entry 0 に支配される★ | `ISSUE_5D.md` |
| ★Editor 7 本★ | ★7/7 が [MenuItem] 持ち★ ⇒ ★「到達できない」ではなく「-executeMethod 経路では現れない」★ | `EDITOR7_INVENTORY.md` |
| ★#20 実修正★ | compile gate を 4 分岐化・red proof 5/5（旧は 5 件中 4 件が素通り） | `ISSUE_20_silent_gate.md` |
| ★台帳の訂正★ | ⓪-385 の訂正文 + ★同型 1 件（RETRO_CS0 §4）も訂正★ | `CORRECTION_385.md` |

## ★★①-b 通信路（#308〜#311・閉じました）★★

- ★失敗形 ③ = ★同時送信で先の便が消える（2 秒窓）★★ / ★私が被害側の候補 6 件 ⇒ boss1 突合で ★届いた 2 / 消えた公算 4★★
- ★★永久に失われたものは 0 件★★（★#310 で 5 件を 1 便に再送・回収済★）
- ★私が出した差し戻し★ = ★remedy ②「SENT を確認」は ★偽 GREEN★（消えた便にも SENT が付く）★ ⇒ boss1 が取り下げ
- ★私が出した強化★ = ★④ 受領番号の欠番検出★（採用・双方向）
- ★★私の側の限定（記録）★★ = ★boss1 の判定器が測るのは「BOSS1_STATE に載ったか」で「context に届いたか」ではない★
  ⇒ ★「消えた公算 4」は ★消失の数ではなく台帳に載らなかった数★★（★#259 §5 = 便は載らず中身は後便で載った★ = 中間形）
- ★手順★ = ★送信前に同宛先 3 秒チェック★ / ★SENT 確認は「到達の証拠でない」と承知して見る★ / ★冒頭に受領番号★
- ★★#313〜#315 = 236,846 の帰属★★: ★私の取り下げは早すぎた（帰属は正しかった）★ /
  ★但し worker1 の答えは ③ 判定不能で理由は別（0x19 が後に決着し当時の読みと別 / 当時の器が現存しない）★
  ⇒ ★確定の語 = ★帰属は戻す / 数の有効性は戻さない★★ /
  ★★私の誤りの正体 = ★正しい場所に疑いを掛けていなかった（弱かったのは数の側）★★★ /
  ★★『③ 追えない』の正体は『追わなかった』= 探す先は前日自分で走査した send_log だった★★
- ★`dwr_RE/` の扱い = ★#312 で確定（#311 の「触らない」は過大だったと boss1 が訂正）★:
  ★① 過去分（#284〜#286 の発注で編集した 5 本）は ★残す（差し戻さない）★★ /
  ★② 以後は ★新しい発注が無い限り触らない★★ / ★③ ★共有 tree 側の `dwr_RE` は読取のみ（不変どおり）★★
  ⇒ ★不変が掛かるのは ★共有 tree★ であって ★p2w3（私の worktree）の中は反していない★★
- ★★通信路の判定の訂正（#312）★★ = boss1 が ★「消えた公算 4」→「★台帳に載らなかった 4★」★ に訂正
  ⇒ ★確定には boss1 側の受信 log が要る（現在は無い）★ ⇒ ★boss1 も本日から recv_log を書く★

## ★★①-c 0x27 実装 arc（#317〜#332）★★

- ★事前登録 3 本★（`a1567707` 実装 / `a34fa261` 出力 oracle / `06b17c9b` 静的+退出）★どれも着手前★
- ★baseline★ = 到達枠（引用値と一致）+ ★貫通枠（新設・2 列で並置）★
- ★器★ = `W3OutputDigest`（Fx 列の digest）/ `W3Op27Index`（index 分布）/ `W3ModeDefaultTest`（★14/14★）
- ★実装★ = 0x27 = ★nibble clear ＋ 退出（a1=2）★・★256 slot・clamp/no-op なし★・★gate 既定 OFF（bit-exact 確認済）★
- ★★結果 = 数①「退出による差」= 487/1,556（到達枠）・488/1,556（貫通枠）★ / ★★数②「私の書込が発火した件数」= 0 ⇒ F 維持★★★
  ⇒ ★remake には消費側だけでなく ★生産側も無い★（nibble に非 0 を書く者がいない）★
- ★index は到達 494 / 静的 563 とも ★全部 0★★ / ★可変 Len は 38 種中 0 種（全数走査の上で）★
- ★★順序依存を実測★★（`_gateSeen` が static）⇒ ★到達枠由来の数 8 件に「この順序での」が付く★
- ★貫通枠で ★未対応 +2 種・相異なる op +3★ = ★到達枠では見えていなかったものが在った★
  （★但し「原盤で走る」ではなく「no-op 仮定の下で到達する」★）

## ★★①-d 実機照合の設計（#336〜#339）★★

- ★`USERCHECK_PLAN_worker3.md`★ = ★時間上限先・3 択判定・不一致でも空振りにしない・環境と代替★（★私は user に直接送らない★）
- ★★#338 ② の陽性対照で ★自分の結論を訂正★★★ = ★『画面に出る差は warp の 5 件だけ』→ ★『5 件は下界』★★
  ★理由★ = ★text Fx 0 は「差が無い」ではなく ★(B-2) 走査型の外 = walk が台詞に 1 度も届いていない★★
  （★IsText step も 0 / 静的には ★225 entry 全部★ に SJIS が在る / 器は正常）⇒ ★★『台詞は変わっていない』とは書けない★★
- ★★#339 = user が明示許可した 1 手（warp 明細）★★ ⇒ ★消えた warp = ★ちょうど 5 行・増加 0★★:
  ★45/60→FRZL06 / 46/52・46/53→FACT03 / 60/60→BETL03 / 219/60→GIAS02★（★行先 4 種はどれも開幕の街でない★）
  ★A/B★ = 6 数一致 ＋ ★digest file が sha256 で bit 一致★ / ★器は既定 OFF の opt-in★
- ★★引き金の場所は未判定★★ = ★DG.SCN 登録簿 36 名に 45/46/60/219 が無い★ ＋
  ★`DialogueData.cs` L13(entry index == map id)と L45(!= / 開幕 178 = 実機 live)が ★同じ file 内で割れている★★
  ⇒ ★★10 分案の成否は未判定 = 材料が揃うまで user に時間を使わせない★★ / ★要る 1 手 = entry → map（EXE 側・私の座でない）★
- ★#338 ④★ = ★不一致時の 2 択判別を先に明記★（★0x800ECA60 末尾の a1=2 が無条件か分岐の下か★ / ★実機照合の前にできる★）
- ★file★ = `workspace/w3_remake/WARP5_AND_TEXTPC.md` / `PREREG_text_and_warp.md`（★着手前 = 91d7c8a9★）/ 結果 = `fc7f0e67`

## ★★①-e term 内訳 と ★私の oracle の欠陥★（#340〜#343）★★

- ★★#339 の私の結論『どの launch も台詞に届く前に終わっている』は ★誤り★★★
  ⇒ ★既定の walk は ★2,640 page / 48,369 文字★ を出している（763 / 1,556 launch）★
  ⇒ ★正しい語 = ★私の oracle が ★画面に出る経路（EmittedPages = 0x1A/0x18 の text operand）を含んでいなかった★★
  （Fx の `text` 型は ★bare な SJIS run だけ★）⇒ ★家族は『走査型の外』でなく ★器の欠陥★★
- ★内訳（到達枠 / 貫通枠 / fix27 ON）★ = ★section_return 89.2%★ / harness 4.4% / 0x17 2.2% / script_end 1.0% /
  ★未対応 gate は 1 種 1 件 × 39 = 2.5% ⇒ ★終わり方の主因ではない★★
- ★★登録していなかった条件 = `Root`（既定 `NpcSection`）★★ ⇒ ★到達枠の数は全て『Root = NpcSection の上』★
  ★1 回目の A/B は no-op（`PlaySection` 第 3 引数が上書き）= ★数が bit 同一ゆえ気づいた★★ / 配線後 fxTotal 7,510 → 103,553
- ★★user に見せられる差 = ★5 件 → 28 launch★★★（page digest 比較・文字 48,369 → 43,920）
- ★予測は ★4 つ外した★（P1 / P3 / Q2 ほか）⇒ ★3 つ外した時点で推論をやめ page を直接数えた★
- ★#341 = ★a1 = 2 は無条件・回避不能（worker2）★ ⇒ ★私の case 0x27 は原盤の形と一致・不一致が出ても (ii) では説明できない★
- ★#343 の訂正（map 表は 0..199）★ = ★私の doc には『表の外』を 1 件も書いていませんでした（grep 0 件）★
- ★file★ = `workspace/w3_remake/TERM_BREAKDOWN.md` / `PREREG_term_breakdown.md`（着手前 = c400e761）/ 結果 = b1b31f7a

## ★★② 開いたまま（★私の座ではないもの★）★★

- ★★実装の再開 = PRESIDENT の裁定待ち★★（★どちらの枠・どの軸で決めるか★ / 私の推奨 = ★到達枠 × 広さの軸 ⇒ 第 1 は 0x27★）
- ★★上申材料の送信 = user が差し止め中 ⇒ boss1 が時期を見る★★（材料は ★完成★）
- ★#293 の捕獲★ = `vmtrace_ms.py` は ★1 run 貰えれば答えが出る状態で凍結★（★emulator は pause / user には頼まない★）
- ★実プレイの到達順位★ / ★どちらの条件が正しいか★ = ★PRESIDENT の座★

## ★★②-b 引き継いだ 開き（#315 §3・★今は追わない★）★★

- ★worker1 #310 §3★ = ★「0x00 も band 外です（906 件）⇒ 機構では 0x00 でも loop を抜けます。
  ★私の pad 扱いと衝突します（未解決）★」★（★08-11 から未解決★）
- ★★∴ 私の #295/#301 の「0x00 = pad であって opcode でない（2,878 件）」と ★同じ面★★★ ⇒ ★開いたまま★

## ★★③ 開いたまま（★私の座だが 未実施★）★★

- ★#18★ 578 画素（build でも guard 本体でもない / 残る候補 = ctor の存在・静的 field の存在）
- ★#19★ `s02_full_extract` の固定 stride 20（★固定 slot 一致は 5/105★・未修正）
- ★未検 52 件★（軸 2 = 私の文章を読む側 / #297 §3 で ★追わないと決定★）
- ★背景 10 件★ = ★原理的に判定不能★（出力が消えている）
- ★他 flag（_selectorForced 等）の A/B★ = ★未走査★（★0 件ではない★）

## ★★④ 本日の自己申告（★型として残すもの★）★★

- ★撤回 6 件★ = 実害 有 0→1 / 自己汚染 4 度目なし / 重複行 5 / 誤定数 9 箇所 5 本 / SKILL_PARAM +4 / vise 書込 0 件
- ★予測の外れ★ = P-2 の向き（jump は終わらせるもの）/ 0x27 圏外 / 0x24・0x10 到達 / 0x5D は 1 site 反復 / MenuItem 1〜3 本
- ★規律 (j) を本日 3 度踏んだ★ = 0x5D の分割 / Editor Q2 の分割 / 陽性対照の読み
  ⇒ ★★(j) は ★枠ごと★ に当てる必要がある（1 つ守れば済むものではない）★★
- ★vise へ 3 file 書いた事故★ = 復元済（HEAD 一致・巻き添えなし）

---

## 索引

| 主題 | file |
|---|---|
| ★全履歴 STATE（92 KB）★ | `p2w3:workspace/WORKER3_STATE.md` |
| 沈黙 audit（1 枚） | `workspace/w3_remake/SILENCE_AUDIT.md` |
| 上申材料（2 枠） | `workspace/w3_remake/ESCALATION_2frames.md` |
| 到達枠の測定 | `workspace/w3_remake/REACH_300.md` / `RANK_BEHAVOFF.md` |
| 器の A/B | `workspace/w3_remake/AB_JOINCOUNTER.md` / `AB_TRACE_BEHAV.md` |
| 棚卸し | `workspace/w3_remake/EDITOR7_INVENTORY.md` |
| 起票 | `ISSUE_19_stride.md`（未修正）/ `ISSUE_20_silent_gate.md`（★修正済★） |
| データ来歴監査 | `workspace/w3_remake/DATA_PROVENANCE_AUDIT.md` |
| 入力/出力 root 分離 | `dwr_RE/tools/vise_root.py` / `out_root.py` / `test_out_root.py` |
| 捕獲器（凍結） | `p2w3:workspace/tools/vmtrace_ms.py` |
