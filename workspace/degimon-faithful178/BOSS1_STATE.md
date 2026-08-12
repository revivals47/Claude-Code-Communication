# BOSS1_STATE（★毎便 末尾に 更新★ / 1 画面以内）
更新: 2026-08-12 / PRESIDENT #114 まで 反映（boss1 は 本日 2 度 落下 → #106 で 再 brief）

★★通番欄の 定義（#107 (529)）★★: ★★受領した 最後の 番号★（処理済では ない）★ / ★★ground truth は log と 受け手の 通番 echo。本 file は 補助★★
★★送信規範（#108 (c)）★★: ★本文を file に 書き agent-send.sh "$(cat file)" で 送る★（★code fence を 直書きすると block ごと 消える = #165 で 実害★）
★★便の 冒頭に「照合した 過去裁定の 番号」欄（#113 (b)。PRESIDENT も 自便に 設置）★★

## ① 4 者の 通番
| 相手 | 私が 発行した 最後 | 相手から 受領した 最後 | 次 |
|---|---|---|---|
| worker1 | ★#173★ | worker1 #159 | #174 |
| worker2 | ★#146★ | worker2（#144 返信 + 短信） | #147 |
| worker3 | ★#153★ | worker3 #230 | #154 |
| PRESIDENT | ★#114★ | PRESIDENT #114 | #115 |

## ② 3 者の 現在 task
- ★worker1★ = ★doc v3-3 収載（第 1 号 = ③ 相当 + #159 §1-§3）★ + ★§3 は ★GetEntry(-1) の 2 行 直読だけ 許可★（それ以上は 開始しない）★
- ★worker2★ = ★★器の 実装（律速 解除済）★★ = 1 command / self-test 同梱 / 終了 code 3 値 / ★meta.scene_id・savestate_id★
- ★worker3★ = ★retro-sweep（cap + census 三版 → 撤回台帳の 系列撤回欄）★ → w3-1 / w3-3 → 05ed4d5 → choice

## ③ 未決 3 件
1. ★★第 1 号（BodyStart 4 byte）= ★③ 相当 = backlog で 確定★★★ — ★#2 dead / #3 の sec<0 は setter 5 site 全数 0 件 / boot 初回は PlaySection 起動★
   ★★backlog に 併記する 2 行（worker1 案・採用）★★: ★『施錠は env 1 個（DEGIMON_SCRIPTWARP）。★開けば 27/225 entry の 初期 state-writer が drop する★』★ /
   ★『「到達しない」は ★施錠の 現状★ であって ★非忠実性が 消えた ことでは ない★』★
2. ★RETURN path に scn 範囲 filter が 無い（worker1 #159 §3）★ — ★(462) 判定 = ★2 行 直読のみ 許可★。throw なら user 可視 ⇒ 別件上申 / null なら 記録のみ★
3. ★census v7 = 39 種 / 4,175 件（飽和 NO）★ ⇒ ★完了条件 ④ の 分母は これ★（★v5 破棄 → v6 → v7 の 経緯を 撤回台帳の ★系列撤回欄★ へ★）

## ④ user 依存の 保留 ＋ ★「待っている間 何が 起きているか」欄（#111 (c)）★
- ★user 提供実績 = 本日 ★4 回 / 計 4.5 分★★ ⇒ ★★5 回目は 出していません（束ねる）★★
- ★★束ねる 候補 3 件（#114 (567) 登録・★単独では 発注しない★）★★
  ① ★0x8013E166（map index）の 捕獲★ — 待っている間 = ★remake の map 出力（w3-4）も 対で 保留★
  ② ★BodyStart の user 実視覚★ — 待っている間 = ★★非忠実な 既定が 動き続ける（既に 18 日）。但し production 経路は 施錠中★★
  ③ ★savestate id の 記入★ — 待っている間 = ★『run1 と run4 が 同じ 場面の 対か』は ★人の 申告に 依存★ / 器は footer に「対の 保証なし」と 出す★
- ★★器は 新規 capture なしで 走る★★（6 field は 撮れた 4 本 全 689 行に 在り）/ ★★但し 一致主張に 使えるのは footer の 在る run1 / run4 の 2 本★★
- ★push なし / 完成 claim は user 実視覚まで 凍結★

## ⑤ ★人の 動作に 依存する 約束（台帳化 = 個人に 依存させない）★
1. ★DialogueRuntime.cs の ★Len[]★ が 直ったら ★boss1 が worker2 に 通知★★ — ★worker2 の 被覆率 / 命令数 / TEXT byte は この 写しの 上に 立つ★（★通知が 無ければ 静かに stale★）
2. ★配布物の sha が 動いたら 配った 相手に その都度★（worker2 の 恒久規則）

## ⑥ 直近の PRESIDENT 裁定（要点のみ）
- ★#105★ 打ち切り条件 4 本（② は 計器へ 格下げ）/ worker1 = ★差分が 要求した 実装★ / 事前登録は「倒れないか」だけ
- ★#107★ 通番 = 受領番号 / ★突合は script 化・1 command（boss1 の 手作業に 置かない）★ / データと log を 別 commit
- ★#108★ ★計器は 機械抽出。手写しは 1 段でも 禁止★ / tsv 由来の 0 件主張を 全数 洗う / user 拘束は 束ねる / 送信は file + cat
- ★#109★ 正否（word0）は 決着済 = 調べるのは 出所だけ / ★env で 消した 差は「説明した」ことに ならない★ / ★データが 在る と 主張に 使える を 分ける★
- ★#110★ カテゴリ 3 分類（観測 / 機構・経路実在 / 機構・経路未発見）/ ★『現れない』禁止 = 母数を 添える★ / ★機構で 塞げない ものは 塞げないと 書く★
- ★#112★ ★全数走査は 見落としと 拾いすぎを 別々に 書く★（★片側の 申告は もう片側を 隠す★）
- ★#113★ ★見落とし = 壊れた 入力を 通す / 拾いすぎ = 正常な 入力を 拒否する★（★対の 概念は 同じ行に★）/ ★実測を 持って 照会する★
- ★#114★ ★5 点様式 (3) に「★同じ gate を 通る 対照か★」を 追加★ / ★台帳の 型を ★原因で 束ね直す★★ / 束ねる 候補 3 件

## ⑦ 成果物（共有 repo 収載済）
- ★P2_DIFF_HARNESS_DESIGN_worker1.md = ★v3-2 / c62374b029c2c47a / 479 行★（CLI 契約 v3 確定）★
- ★P2_TYPE_ROOTCAUSE_BUNDLE.md = ★症状 19 → 原因 6★ + ★『運が 良かった』7 件★（#114 (b) の 回答）★
- ★worker 側（未収載・各 worktree）★: PBR_ORACLE_FEED_SPEC（1ef7d72101ce79e2）/ SYNC_RULES（dcfcf83f3ca0fc7c）/ oracle_adapt.py + selftest ★17/17★ / PBR_INSTRUMENT_SELFDECL（32b760f8c30f3c88）/ PBR_CLAIM_TWOSIDED（29587885386a8b26）/ CENSUS_VERSIONS.md（8e1d20f）
