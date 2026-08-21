# 次 phase registry(2026-08-20・#584-588 track CLOSE 時点)

## 1. 環境の札(新規登録・PRESIDENT 指示)
・★main worktree の provision 12 本不足(species_care_params.json を含む)★ = StreamingAssets/data が ★main 24 本 / integ 36 本★・★git 管理外(git ls-files = 0)★。
  ★再生成 = provision_curated_data.py で 36 本に★。★踏むと FileNotFoundException → NameInput の BindCareForm で例外 → field に届かない★。
  ★格 = 「worktree の provision 状態の差」まで(baseline build 未撃ゆえ『main の既存不具合』とは断定しない)★。★main から新規 build する人は踏み得る★。

## 2. park した札(座は PRESIDENT・次 session 起点)
・★0x57 の実装 GO★(事前登録 5 点は保持 = ①枠が合うまで実装しない ②読み手 0 件 → 死に field の札 / 非ゼロ → README に consumer 未実装の札 ③受理 oracle は matchedChars ④0x57 だけを通す arm ⑤既定予測 = 動かない)。
・★0x24 の実装 GO★(★G5 draft の再発見★・★DcRandom seam(無 seed System.Random)と混ぜないことが要件★・★同じ入力で同じ絵になるかは判らない★)。
・★呼び元の配線便★ = ★runtime の呼び元は今も 0 件★ ⇒ ★bit 同一は「呼び元 patch 文面の下で」★のまま。配線した瞬間に ★検定の呼び元 3 行(写し)は黙って意味を失う★。
・★5 map の (B)★ = ★段ごとの腕の突合(worker2 の逐語表 × worker3 の harness)★。★27 腕 = 27 一致(slot ↔ record 添字)★は済・★placer が実際に置くことの live 確認は mayo00 のみ★。
・★0x10 の Len 表★ = ★原盤は 2*N+6・shipped の 1 は誤り★・★我々の VM の実行経路は既に正しい(誤っているのは表を引く側)★。★表を直すかは PRESIDENT 保持★。
  ★2026-08-21 更新: retro-sweep で「表を引く側」の実害を測定 = 追跡カウントは ±0 だが、scn_trace の linear walker では実 decode に効く(entry206 75→2036 byte が実物)★。⇒ ★Len[0x10]=1 → 可変長 2*N+6 の修正は『どの追跡カウントも動かさない低リスク correctness fix』= 実施の判断材料が揃った(実修正は PRESIDENT gate、run で回帰確認込み)★。
・★var[110] は未捕獲★ = ★#586-C の 48 件は交絡つきの数として保存(取り下げ・消さない)★ ⇒ ★fact02 / stic02 の StageHold は維持★(理由 = 清潔な VM では gate が先に止める + section 起点では section が先に終わる)。
・★worker1 の札 3 本★ = ①0x80157B38 の同定(候補 2 + 反証材料)②+0x2DD の consumer(器の外に在る可能性)③0x24 の決定性(seed と draw 順)。
・★worker1 の採点待ち固定予測★ = W-3 / W-4 / W-5 / W-6' / W-7' / W-9(静的側)・W-1 / W-2(reset ありの run でのみ採点可)。★後から動かさない★。

・★~~worker2 の retro-sweep 札~~ = 2026-08-21 DISCHARGE(census+2 model diff 完了、結果 doc `RETRO_SWEEP_0x10_RESULT_2026-08-21.md`)★。
  ★verdict = 誤った Len[0x10]=1 は追跡カウントを 1 件も汚染していない = 過去 claim 書換不要★:
  var[110]=90(±0・旧「93」は起点定義差 entry base vs body 先頭で 0x10 model 差でない)/ var[29]=0(影響なし)/ 0x25 A=29=到達1・線形2(±0・次元差、畳まない)/ entry175 候補=24(±0)/ 線形被覆=次元別 2 値(87.8%/60.35%)。
  ★census: standalone opcode 0x10=CHOICE は 350 件/81 entry(§238 限定は否定、2 器+陽性/陰性対照)★。
  ★standing residual → 下の「0x10 の Len 表」札へ統合★: Len[0x10]=1 は inert でなく実 decode bug(entry206 75→2036 byte,+1961,N=241 が実物)。
・★park 解決(2026-08-22)★ = 0x19 入口 0x07FAC6 = ★mid-operand と確定★(実 0x19@abs 0x07FABC len12 の +10 byte 目・到達命令でない)⇒ 暴走 parse は誤 start artifact・census 350 裏取り・retro-sweep park 完全 close。詳細 = RETRO_SWEEP_0x10_RESULT §8。
・★worker2 の自己訂正 1 件★ = #587-B の残り「⑤ 段ごとの腕の突合は未突合」は★古い申告★で、★27 腕 = 27 一致(slot ↔ record 添字)は済★。★live 確認は mayo00 のみ★の限定はそのまま。

## 3. 不変(次 session へ引き継ぐ)
★push は HOLD(local commit まで)★ / ★land は PRESIDENT の承認★ / ★引き渡し build(w3_build582r)は不可触・userbuild branch HEAD 152885f9 不動★ / ★README(c661db4)は追記のみ・command block と §2 の表と log の見かたは不動★ / ★視覚忠実は user 実視覚まで凍結★。
