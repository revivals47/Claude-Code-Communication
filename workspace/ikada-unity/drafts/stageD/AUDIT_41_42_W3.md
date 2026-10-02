# AUDIT #41・#42（worker3, boss1 03:26 / PRESIDENT 10/03）

出所: ikada-design 7779d97 research/30_fight_realism_audit_20261002.md（§4 B・C, Mac 側の監査, 合成実験）、ikada-sim issue #41・#42。hardware/ は読んでいない。
版: 監査の固定 = sim 777950e、Unity の pin = 418b374、今の main = 2750f49（ls-remote, boss1 03:30）。順 = 777950e → 418b374 → 2750f49（merge-base で確認, 418b374..2750f49 = 6 commit）。測りは ★2750f49★（~/Documents/ikada-sim-w3 を detach → 局所の枝 w3/audit41-probe = 2750f49 ＋ 試験の器の hook 1 つ e30b781, push しない）。

## #41 — 張力が軽いだけで PULL_SLACK

### source（2750f49, 観測）
- core/ikd_fight_risk.c:67-89 slack_and_pull: `judged(f) < slack_N && (!(flags & IKD_FFL_SLACK_GEOM) || q - x_prev < -0.005)` で slack_s を足し、pull_slack_ms で PULL_SLACK。注 :70「D4 option (a) (flag IKD_FFL_SLACK_GEOM, OFF by default; PRESIDENT 09:26)」= ★旗が既定 OFF なのは 前の決め（D4 (a), PRESIDENT 09:26）★、作りの漏れではない（推論: 決めの記録は未読 = 要 grep）。
- C# の Flags: pc/src/Ikada.Logic/Fight/FightAi.cs:416 = Shallow・RopeZone・LandingReady・Init だけ（SlackGeom = FightParams.cs:23 の 32 は どこからも立たない）。
- PULL_SLACK の時間: FightAi.cs:163 SlackTime(draw)×SlackK、たるみが終わるたびに再抽選（:200-208）。

### 器と対照（観測, C だけ, dotnet なし）
- drafts/stageD/audit41/probe41.c（監査の light_line を土台）を 2750f49 の core（out-of-tree build）で: 結果 probe41_2750f49.txt
  - A 監査の条件（q−x = +0.002, 張力 0.40 N < slack_N 0.45）: ★PULL_SLACK・taut_share 1.000★（= #41 は 2750f49 でも再現 = 陽性）
  - B 同じに SLACK_GEOM を立てる: 3 s で終わらない（旗の効き）
  - C 本当にたるむ（q−x = −0.10）: PULL_SLACK・taut_share 0.000（器の陰性）
- 器 = 終わりの前の PullSlackMs の窓で q − x ≥ −0.005（core の SLACK_GEOM の式そのもの）の割合、0.5 以上 = 「軽いだけ（#41）」。

### 測り（dotnet, boss1 03:30 の合図, main 2750f49）の予測（回す前, 動かさない）
- 器: drafts/stageD/audit41/Probe41（FishingDay・FightHarness・ReferenceRun と同じ回し方を link / 写し、ikada-sim-w3 の 2750f49 を参照）。libikd = 2750f49 から build した .so（IKADA_LIBIKD）。
- (H) 人の手の試験の型（FishingDay, 16 回・本アタリで合わせ・45 s ごとに聞き上げ, 8 時間）× 腕 Good / Slack / Locked × 春 / 7 月 × 20 日:
  - PULL_SLACK の割合（ファイトあたり）: Good 3〜12%・Slack 10〜30%・Locked 3〜12%（前の基準 ikada-design drafts/agent1_21_balance.md = 7 / 18-21 / 7%, 版が古い）。
  - そのうち LIGHT（#41 型）: ★Good・Locked は 半分以上★（巻き続ける腕 = 糸は余らない、魚が止まって張力が軽いだけ）、★Slack は 半分未満★（向きが変わると巻くのを止める = 本当に余る）。
  - 器の自己点検: PULL_SLACK の窓の lowT_share（F < slackN）は 0.8 以上（たるみは張力が閾値より下の時だけ足される; F は平滑前なので 1 より少し下がりうる）。下回れば 窓の合わせの誤り = 結果を使わない。
- (P) AutoPilot の日（IkadaSession lockstep, ReferenceRun と同じ, 4/20・7/20・10/15・12/10 × 種 1〜5 = 20 日）: ファイト 1 日 1〜4、PULL_SLACK は ファイトの 0〜15%、LIGHT の割合は 半分以上（推論: AutoPilot は張って巻く）。0 件なら「起きない」ではなく 母数（ファイト数）を添えて 0/N と書く。
- 追記（回す前, 03:34）: 2 日の試し（人の手の型）= ファイト 1 日 約 1.5・PULL_SLACK 0 → C# の器の陽性対照が要る: 腕 PumpSlack（膝を下げる速さが巻きより速い = 本当にたるむ, FightHarness.cs Player）を対照に足す。予測: PumpSlack は PULL_SLACK が出て（ファイトの 20% 以上）その窓は taut_share < 0.5（really slack）・lowT_share ≥ 0.8。日数は 200（1 run 数秒）。

## #42 — ロープ（RopeQ）が通常のファイトにつながっていない（案だけ, code は後）

### source（2750f49, 観測）
- Ikada.Game/Flow/FishingSession.Fight.cs:107-113 `new FightSetup` に RopeQ なし → FightAi.cs:28 既定 +∞。
- FightAi.cs:332-337 AfterRun: u を 1 つ引き、RopeQ が有限で u < PDive なら DIVE(8 s)、それ以外で u < PDive+0.35 なら PAUSE（★PauseLen() がもう 1 つ引く★）、他は TURN / SIDE。PDive = チヌ 0.5・キビレ 0.4・マダイ 0.3・ボラ 0.1・カサゴ 0.7 ほか（FightSpecies.cs:23-34）。
- DIVE（:290-293, :377-379）: 引き FRun×(0.3+0.7×体力)、速さ ×1.3、XAnchorMax = RopeQ+0.5（[0.01, 50] に clamp）、Rope()（:309-329）= q ≥ RopeQ で区域、張力 ≥ 0.8×FRun が 0.3 s で抜ける（PauseLen を引く）、低い張力が _tWrap（中央値 1.5 s, 構築時に引く :151）続けば 50% で Wrapped、残りは摩耗 +0.5 と PAUSE（PauseLen を引く）。
- FishingSession.Disturb.cs:21-44 FightDives = DIVE か区域の立ち上がりの数 → EcoSim.OnFightEnded（:202-208）で場の荒れ（上限 2）= ★今の通常の遊びでは FightDives は常に 0 = 荒れの「突っ込み」の項は死んでいる★（RopeQ を入れると後のアタリも動く）。
- Wrapped の終わり: 仕掛けを失う・LineBreak を出す・回収へ（FishingSession.Fight.cs:158-167）。Words / PracticeFight に「巻かれた」の語はある。
- FightAi.Side.cs: RunSide = RUN ごとの左右の抽選、★専用の _sideRng★・描きだけ（魚の横の位置・横向きの力は無い）。

### RopeQ を渡した時に変わること（source の推論, codex 済）
1. DIVE が起きる: RUN の後ごとに 確率 PDive（チヌ 0.5）。★RNG の消費も変わる★（DIVE は PauseLen を引かない = 1 回 vs 2 回）= ファイトは最初の u < PDive から分かれる。
2. 巻かれ・切れ: 区域で張力が 0.8×FRun に届かない時間が _tWrap を越えると 50% で Wrapped。前の試し（ikada-design drafts/agent1_21_balance.md:51, 区域 12 m）では「巻くだけで 94%、巻かれた 0%」= 張って巻く腕では起きにくい（版が古い, 再測が要る）。
3. 場の荒れ: FightDives が 0 でなくなる → OnFightEnded の荒れが増え 後のアタリが減る見込み（上限 2）。
4. RefCheck: ファイトのある日は ファイトの時間・終わり方・後の釣果が動きうる = events hash が替わりうる（★「どの日も必ず」は未証明★ = hash は局面を直接は数えない, codex）→ 入れたら 5 本の参照の固定し直し（#14 型）と Unity 側の参照も。
5. 描き（Unity）: DIVE の局面・Wrapped の終わりの絵・音・字幕が 今まで通常の遊びで一度も出ていない = 出る（未確認の道）。

### 決めてほしいこと（issue #42）と 推奨
- 推奨: ★まず 1 次元のまま RopeQ を渡す（位置 = その日の筏の深さ StartLineM ＋ 筏ごとの差、11 §376 の「筏ごとの配置」）を 試験の器（FishingDay・Probe41 と同じ型）で 腕 × 区域の距離で測る → DIVE・巻かれ・取り込み率・荒れの数を見て PRESIDENT が入れるか決める★。左右（2 次元, RunSide を力に）は その後の別の段（大きい）。
- 位置の出所の候補: (a) 筏の性格の表（07 §1, 11 §376）に「ロープまでの距離」を足す、(b) 全部の筏で一定（例 StartLineM + 2 m, RodReport.cs:5 の案 B の試し）。

## #41 の結果（観測, 2750f49 ＋ 試験の器の hook, libikd = 2750f49 から build, 03:34〜03:47）
出力: audit41/human200.txt・pilot5.txt（器 = Probe41, 再現: `dotnet Probe41.dll human 200` / `pilot 5`, IKADA_LIBIKD）。

| 母集団 | 日 | ファイト | PULL_SLACK | うち LIGHT（#41 型, taut ≥ 0.5） | 本当にたるむ | LIGHT の出た日 |
|---|---|---|---|---|---|---|
| 人の手 春 Good | 200 | 446 | 0 (0.0%) | 0 | 0 | 0/200 |
| 人の手 春 Slack | 200 | 450 | 47 (10.4%) | 22 | 25 | 20/200 |
| 人の手 春 Locked | 200 | 464 | 3 (0.6%) | 0 | 3 | 0/200 |
| 人の手 7月 Good | 200 | 473 | 1 (0.2%) | 1 | 0 | 1/200 |
| 人の手 7月 Slack | 200 | 490 | 66 (13.5%) | 34 | 32 | 32/200 |
| 人の手 7月 Locked | 200 | 514 | 1 (0.2%) | 0 | 1 | 0/200 |
| （対照）PumpSlack 春 / 7月 | 200 / 200 | 466 / 496 | 293 / 329 | 215 / 248 | 78 / 81 | 140 / 148 |
| AutoPilot の日（4/20・7/20・10/15・12/10 × 種 1〜5） | 20 | 30 | 3 (10.0%) | 2 | 1 | 2/20 |

- 器の自己点検: 人の手の PULL_SLACK の窓の lowT_share（F < slackN）= 1.000 が 159 件・0.985〜0.995 が 5 件（全部 0.8 以上）= 窓は core のたるみの足しと合う（ただし F は返す力で core の判定の張力そのものではない = 裏付けの 1 つ, codex）。taut_share は ほぼ 0 か 1 に分かれる（列挙 40 件の上限の中で: Slack 春 20 / 17 / 間 3、7月 21 / 15 / 間 4）= ★SLACK_GEOM を立てれば防げる = 窓の全部で幾何が張っている（1.000）のは Slack の約半分★。
- 予測との照合: Good 3〜12% → 0.0 / 0.2% ★外れ★・Locked 3〜12% → 0.6 / 0.2% ★外れ★（前の基準 7% は古い版, いまは張って巻けば PULL_SLACK はほぼ出ない）・Slack 10〜30% → 10.4 / 13.5% ★当たり★・LIGHT の割合: Slack < 50% → 47% / 52%（半々 = 境の上下, 7月は外れ）、Good・Locked の「半分以上 LIGHT」は 母数 1〜4 で判じられない・AutoPilot 0〜15% → 10%（3/30）★当たり★・LIGHT 半分以上 → 2/3 ★当たり（母数 3）★・対照 PumpSlack「taut < 0.5」→ 73〜75% が LIGHT ★外れ★（膝を下げる速さで糸を出すと 魚が離れる速さとほぼ同じで 糸はまっすぐ・張力だけ 0 = 予測の前提「出しすぎ = 余る」が誤り, 推論）。
- 読み（推論）: ★#41 型の外れは「向きが変わると巻くのを止める」腕で ファイトの 5〜7%（1 日に 0.1〜0.17 回, 200 日で 20〜32 日）、張って巻く腕ではほぼ 0、AutoPilot は 30 ファイトで 2★。つまり 遊ぶ人が巻くのを止めた時（＝糸は余らず 魚は止まり 張力だけ軽い）に「たるみで外れた」と出る。
- codex 済（静的, source で確かめた）: (A) 試験の器は 幾何として妥当（x は core の x_prev と同じ tick の値, ikd_fight_risk.c:165 の順）、窓の終わりに 0〜9 ms 余分な sample（魚は止まり糸は動く）= 窓 150〜2355 sample に対し小さい。(B) AutoPilot の日は 近似（_q は最後の報告の q = 最大 20 ms 古い・Rig.X は今）= 5 mm の境で誤りうる = ★AutoPilot の 2/30 は暫定★。「taut ≥ 0.5」は「主に幾何は張っていた」であって SLACK_GEOM で必ず防げたとは限らない（1.000 の数で見るのが厳密）。
- 未確認: 依頼者の手の遊び（人）の率は この 2 つの型の間のどこか。直すかは PRESIDENT の判断（数 = 上の表）。直すなら 監査の注意どおり SlackGeom を立てるだけでなく「張力が軽い時の保持の落ち」を別に持つかを決める（立てると Slack の約半分の外れが消える, 残りは本当にたるむ外れ）。

## #42 の測り（PRESIDENT 03:5x GO, dotnet だけ, 1 次元のまま）— 器と予測（回す前, 動かさない）
- 器: FightHarness.RopeAheadM（局所の枝 cbef6f5, 試験の器の hook = RopeQ = 始めの糸の長さ（= 深さ）＋ d）、Probe41 `rope <日> <腕> <季節> <d|none>` = 1 cell 1 行（区切れる: cell ごとに別の process）。人の手の型（FishingDay, 16 回・本アタリで合わせ・45 s ごとに聞き上げ, 8 時間）。
- cell: 腕 Good / Slack / Locked × 春 / 7 月 × d = none（今）/ 1 / 2 / 4 m × 100 日 = 24 cell。数える: 掛け・ファイト・終わり方の内訳（Landed・Wrapped・PullSlack・PullShake・切れ・口切れ・時間切れ）・DIVE の入り/ファイト（FightResult.Dives）・ファイトの長さの中央値・取り込み/日（場の荒れ = 後のアタリの減りを含む）。
- 対照: ★陰性 = d none は DIVE 0・Wrapped 0（今の通常の遊び）★、★陽性 = d を渡すと DIVE > 0★（どの腕でも）。
- 予測（推論）:
  - DIVE/ファイト: d 1〜4 で 0.5〜3（チヌの PDive 0.5 × RUN の数）、d に依らず ほぼ同じ（AfterRun の u < PDive は距離を見ない）。
  - Wrapped: Good 0〜3%・Locked 0〜3%（区域で張力 0.8×FRun を 0.3 s 保てば抜ける = 張って巻く腕は抜ける; 前の試し 12 m で 0%）、★Slack 2〜10%★（巻くのを止める = 区域で張力が足りない）、d が近い（1 m）ほど多い。
  - 取り込み率: Good・Locked は none 比 0〜5 ポイント下、Slack は 3〜12 ポイント下。ファイトの長さ: 長くなる（DIVE 8 s・区域）。
  - 取り込み/日: 場の荒れ（FightDives）で none 比 0〜10% 減。
  - PULL_SLACK・切れは d で大きくは替わらない（± 2 ポイント）。

## #42 の結果（観測, 2750f49 ＋ hook cbef6f5, 100 日 × 24 cell, 03:52〜04:02, audit41/rope100.txt）
| 腕 | 季節 | d | ファイト | 取り込み | 巻かれた | たるみ外れ | 切れ（すれ） | DIVE/ファイト | 長さ中央値 | 取り込み/日 |
|---|---|---|---|---|---|---|---|---|---|---|
| Good | 春 | none | 228 | 100% | 0% | 0% | 0% | 0.00 | 112 s | 2.28 |
| Good | 春 | 1 / 2 / 4 | 224 / 230 / 221 | 70.5 / 71.7 / 71.9% | 21.9 / 20.4 / 22.2% | 2.2 / 1.7 / 1.8% | 5.4 / 6.1 / 4.1% | 2.88 / 2.96 / 2.98 | 83〜86 s | 1.58〜1.65 |
| Good | 7月 | none | 235 | 100% | 0% | 0% | 0% | 0.00 | 116 s | 2.35 |
| Good | 7月 | 1 / 2 / 4 | 248 / 244 / 237 | 68.1 / 70.5 / 71.3% | 22.6 / 20.9 / 21.9% | 3.6 / 4.1 / 2.1% | 5.6 / 4.5 / 4.6% | 2.85〜3.05 | 86〜91 s | 1.69〜1.72 |
| Slack | 春 | none | 231 | 88.7% | 0% | 11.3% | 0% | 0.00 | 97 s | 2.05 |
| Slack | 春 | 1 / 2 / 4 | 221 / 219 / 216 | 62.4 / 65.8 / 66.2% | 21.3 / 18.7 / 18.1% | 10.4 / 9.6 / 11.1% | 5.9 / 5.9 / 4.6% | 2.29〜2.37 | 68〜70 s | 1.38〜1.44 |
| Slack | 7月 | none | 240 | 87.1% | 0% | 12.9% | 0% | 0.00 | 104 s | 2.09 |
| Slack | 7月 | 1 / 2 / 4 | 238 / 239 / 240 | 54.2 / 58.2 / 58.3% | 26.5 / 24.3 / 22.5% | 13.0 / 11.7 / 12.5% | 6.3 / 5.9 / 6.7% | 2.26〜2.36 | 67〜71 s | 1.29〜1.40 |
| Locked | 春 | none | 239 | 100% | 0% | 0% | 0% | 0.00 | 80 s | 2.39 |
| Locked | 春 | 1 / 2 / 4 | 226（3 つ同じ） | 99.1% | 0% | 0.4% | 0% | 2.45 | 74 s | 2.24 |
| Locked | 7月 | none | 250 | 99.6% | 0% | 0% | 0% | 0.00 | 81 s | 2.49 |
| Locked | 7月 | 1 / 2 / 4 | 227（3 つ同じ） | 99.6% | 0% | 0% | 0% | 2.47 | 77 s | 2.26 |

- 対照: ★陰性 none = DIVE 0・巻かれ 0（6 cell 全部）★・★陽性 = d を渡すと DIVE 2.3〜3.1/ファイト（18 cell 全部）★ = 器は効いている。
- 予測との照合: DIVE 0.5〜3/ファイト・d に依らない → 2.26〜3.05・d でほぼ同じ ★当たり★。巻かれ Good 0〜3% → 20〜23% ★外れ（大きく）★、Slack 2〜10% → 18〜27% ★外れ★、Locked 0〜3% → 0% ★当たり★、「d が近いほど巻かれ多い」→ ほぼ平ら（Slack 7月だけ 26.5→22.5）★外れ★。取り込み率の下がり Good 0〜5 → 28〜32 ポイント ★外れ★、Slack 3〜12 → 21〜33 ★外れ★。取り込み/日 0〜10% 減 → Good・Slack 27〜38% 減 ★外れ★、Locked 6〜9% 減 ★当たり★。PULL_SLACK・切れ ±2 → すれ切れ +4〜7 ポイント（巻かれの摩耗 +0.5 の後）★外れ★。長さ「長くなる」→ 短くなる（巻かれで早く終わる）★外れ★。
- 機構（★未解明★）: 私の仮説「ドラグ 3 N では 0.8×FRun に届かず抜けられない」は ★誤り★（codex, source で確かめた: チヌ 40 cm の F_bias 2.0 N = ikd_fight_draw.c:55 の F_run 列（:41 の型の順）、(L/40)² で 30〜50 cm は 1.1〜3.1 N = 抜ける閾 0.9〜2.5 N は 3 N より下、単位も同じ device N）。Locked が d に依らず全く同じ数 = 区域に一度も入っていない見込み（推論）。2 回外したので 推論をやめ 計測へ: ★区域の入りごとに 張力・0.8×FRun・_ropeHoldT・_ropeLowT・_tWrap を出す trace（試験の器だけ）で 抜け / 巻かれ の分かれ目を測る★ = 次の dotnet の番で。
- 読み（観測の範囲）: ★RopeQ を今の作りのまま渡すと、張って巻く腕でも ファイトの約 2 割が巻かれて終わり、取り込みは 1 日 約 3 割減る★。Locked（締めきる）だけが巻かれ 0。= 入れるなら Rope の閾・確率の釣り合いの見直しが先（推論）。
- codex 済（2 回: 初稿の RNG の主張を訂正・機構の仮説を否定）。

## #42 の trace（PRESIDENT 04:0x GO, 閾はいじらない）— 器と予測（回す前, 動かさない）
- 器: FightHarness.TickProbe（局所 25b4f4f, 10 ms の FightAi.Tick の後）＋ Probe41 `ropetrace <日> <腕> <季節> <d>`: FightAi の _ropeZone・_ropeHoldT・_ropeLowT・_tWrap・_run.FBias・_q・_s.RopeQ を reflection で読み、区域の入り（_ropeZone false→true）ごとに: tick 数・T（LastTensionN = Rope に渡る値）の平均/最小/最大・hold = 0.8×FRun・T ≥ hold の割合・閾をまたいだ回数・holdT / lowT の最大・_tWrap・入った時の q と RopeQ・出方（逃げた = holdT 0.3 s / 巻かれた = lowT ≥ tWrap で 50% に当たる / 巻きの抽選を生き延びた / 他の終わり）。注: Rope() は DIVE の中でだけ呼ばれる（FightAi.cs:292）= 区域の判定も DIVE の間だけ。
- cell: Good / Slack / Locked × 春 × d 2 × 50 日。
- 予測（推論, H を 1 つに決めない）:
  - ★Locked: 区域の入り 0、DIVE の tick は出る（区域の外）= 「区域に入らない」の確かめ★。
  - Good・Slack: 入り 1〜4 / ファイト。出方: 巻かれ ＋ 抽選を生き延び ≥ 70%、逃げ < 30%（巻かれ = 抽選の約半分 = PWrapCut 0.5）。
  - 分かれ目の候補: (H1) 区域の T がずっと hold より下（T ≥ hold の割合 < 10%）、(H2) T が hold をまたいで揺れ（またぎ ≥ 5 / 入り）holdT が 0.3 s に届く前に 0 に戻る、(H3) 他。予測 = Good は H2、Slack は H1（推論）。

## #42 trace の結果（観測, 2750f49 ＋ hook 25b4f4f, 春 d 2 × 50 日, audit41/ropetrace_*.txt）
| 腕 | ファイト | 区域の入り | 逃げた（holdT 0.3 s） | 巻かれた | 巻きの抽選を生き延びた | 他 | DIVE の tick（区域の外） |
|---|---|---|---|---|---|---|---|
| Locked | 115 | ★0★ | – | – | – | – | 217600 |
| Good | 111 | 82 | 42 | 21 | 18 | PullSlack 1 | 193734 |
| Slack | 108 | 73 | 35 | 20 | 17 | PullSlack 1 | 141189 |

入りの中身（列挙 60 件の上限の中の中央値）:
| 出方 | 区域の tick | T 平均 | T ≥ 0.8×FRun の割合 | 閾をまたいだ数 | lowT 最大 / tWrap | q − RopeQ（入った時） |
|---|---|---|---|---|---|---|
| 逃げた（Good / Slack） | 30 / 30 | 3.19 / 3.36 N | 100 / 100% | 0 / 0 | 0 | +0.05 / +0.02 m |
| 巻かれた | 154 / 164 | 0.40 / 0.40 N | 1 / 2% | 1 / 1 | 1.54 / 1.61 s | +2.70 / +1.62 m |
| 抽選を生き延びた | 165 / 159 | 0.79 / 0.51 N | 2 / 2% | 1 / 1 | 1.63 / 1.53 s | +1.33 / +1.20 m |

- 予測との照合: Locked 区域 0・DIVE は区域の外 ★当たり（確かめ済）★。入り 1〜4/ファイト → 0.66〜0.74 ★外れ★。巻き＋抽選 ≥ 70%・逃げ < 30% → 抽選 48〜51%・逃げ 48〜51% ★外れ★（抽選の中の巻かれ 21:18・20:17 = PWrapCut 0.5 どおり）。H1（T がずっと下）★当たり（巻かれの入りで T ≥ hold 1〜2%）★、H2（またいで揺れる）★外れ（またぎ 1 回）★、Good = H2 の予測 ★外れ★。
- ★機構（1 行, 観測＋source, codex 済）★: RUN は RopeQ で止まらず（目標 _q+len, FightAi.cs:332・StartRun）区域の判定は DIVE の中だけ（:290-292, :311）なので、区域の「入り」は 魚がロープを 1〜3 m 越えた所で起き、DIVE のアンカーの上限 RopeQ+0.5（:377-379）へ向けて魚は内へ泳ぎ戻る（core ikd_fight.c:250-251 アンカーの clamp・:265 内向きの速さ）= その分 引きが打ち消され（:294 F = bias + k(q−x) + c(qdot−xdot)）張力が 0.4 N 前後に落ちて 0.8×FRun（約 2.2 N）に届かず、低張力の時計 t_wrap（約 1.5 s）が切れて 50% で巻かれる。ロープの所で DIVE が始まりドラグが滑っている（T ≈ 3.2 N）入りだけが 0.3 s で逃げる = ★腕では決まらず 区域に入る時の魚の位置で決まる★（Good と Slack の中身がほぼ同じ）。
- ★仕様との差★: 11 §5.3:376「魚が DIVE でロープの方へ走り、★アンカーの位置が★区域に入ると ROPE_ZONE」= 仕様はアンカー（向かう先）で判定、code は魚の位置 q ≥ RopeQ を DIVE の間だけで判定。

### 直すなら（案, 閾の数は今回いじっていない）
1. ★第一 = 作りを仕様へ（数でなく形）★: (a) 区域の判定を 仕様どおり「DIVE のアンカーが区域に入った時」に、(b) RopeQ がある時は RUN の目標を RopeQ で止める（ロープの手前で魚が引いている所でぶつかる）。こうすると 張力（＝プレイヤーが止めるか出すか）で分かれ、11 §5.3:380「ロープの手前で止めるか、出して逃がすか が このゲームの判断」に合う。出典 = 仕様 11 §5.3。
2. 数（F_hold_rope = 0.8×F_run・t_wrap 1.5 s・p_wrap_cut 0.5・巻きの摩耗 +0.5）: 仕様の「初期値」で ★実測の出典は無い★（根拠 09 §6.1・10 §2.8 は「当たればほぼ切れる」という定性）= ★依頼者の感覚で決める★: 例「ロープに走られて止められなかった時、何割が切られるか」「止めるのにどのくらい強く・何秒」。1 の形を入れた後に 今の 24 cell の器で測り直してから。
3. 1 の後の予測（推論, 未測）: 巻かれは腕で分かれる（Good・Locked は区域の手前で止めて少なく、Slack は多く）、取り込み/日の 3 割減は縮む。

## #42 形を仕様へ（PRESIDENT 04:1x GO, 局所の枝 w3/rope-shape = main 2750f49 から, push なし）— 予測（code の前, 動かさない）
- 直し（11 §5.3:376）: (a) 区域の判定 = DIVE のアンカーの位置（PC の見積り: DIVE に入った時の q から VAnchor×1.3 で進み XAnchorMax = RopeQ+0.5 で止まる = 0x05 で送る値と同じ式）が RopeQ 以上、(b) RopeQ が有限の時 RUN の目標 _runEndQ を RopeQ で止める。RNG の引き方・閾・確率は替えない。
- ★予測 1（今の遊び, RopeQ +∞）: 何も変わらない★ = RUN の目標は min(_q+len, +∞) で同じ・DIVE は起きない（AfterRun の RopeQ 有限の条件）・区域の判定は呼ばれない → ★RefCheck 11 本 = #15 の値のまま★、dotnet test 全体 = 2750f49 と同じ合否（pre-existing の失敗があれば同じ件数・名前）。
- 予測 2（試験の器 24 cell, RopeQ = 深さ＋d）は 測り直しの前に別に登録する。
- code 済（観測）: w3/rope-shape 262b676 = FightAi.cs（pc/src と unity Runtime の 2 つ, cmp 同一）+6/−2: _diveA（DIVE に入った時の q から VAnchor×1.3×dt で進み min(50, RopeQ+0.5) で止まる = 0x05 の値と同じ）、Rope の inZone = _diveA ≥ RopeQ、StartRun で RopeQ 有限なら _runEndQ = min(_q+len, RopeQ)。測りの枝 w3/rope-shape-probe = 262b676 ＋ 器の hook 3 つ（cherry-pick, push なし）。
- RefCheck の確かめ方: 11 本 = CI の 8 cell（4/20・7/20 × 種 20260925・1・2・3, ci.yml:104-107）＋ README の E′（4/20 三番筏）・F（10/15 種 1）・G（12/10 種 1）。★A/B = 2750f49 と 262b676 で 11 本の events・numbers の hash が全部同じ★（README の固定値も照合）。
- ★予測 2（試験の器 24 cell, 形の直しの後, RopeQ = 深さ＋d）★（推論）:
  - Locked: 区域の入りが ★0 から増える★（アンカーで判定 = 魚が動けなくても DIVE のアンカーは RopeQ+0.5 へ進む）、張力が高いので 入りはほぼ全部「逃げる」、巻かれ 0〜1%。
  - Good: ドラグ 3 N > 抜ける閾 0.9〜2.5 N で 魚が引いている間に区域へ入る = 逃げが大半 → ★巻かれ 20〜23% → 0〜5%★、取り込み率 ≥ 90%、取り込み/日の減り ≤ 10%。
  - Slack: 巻かれ 18〜27% → 3〜15%（Good より多い = 腕で分かれる）。
  - DIVE/ファイト 2.3〜3.1 のまま（AfterRun は替えていない）、d の差は 小さいまま。
- ★予測 1 の外れ（観測, 04:25）★: 262b676 の dotnet test = 失敗 11（base 2750f49 = 10）、増えた 1 = FloatChainGuardTests.NoUnstoredFloatIntermediatesOnTheJudgementPath（FightAi.cs:293 `_run.VAnchor * 1.3f * dt` = float の途中の値, #15）= 私の code の決定性の規則違反（RNG・hash ではなく 規則の器が拾った）。直し dcb796a = double で計算し 1 回だけ丸める（pc/src と unity 同一）、probe の枝にも cherry-pick（641a71f）。base の 10 = 全部 CastScenarioTests.MatchesSimCli（sim_cli の在処 IKADA_SIM_CLI を渡していない = 環境, A/B の両方で同じ）。fix の段は dcb796a でやり直し。

## #42 形の直しの結果（観測, w3/rope-shape dcb796a = 262b676 ＋ double の直し, 04:26〜04:42, audit41/shape/）
- ★予測 1 = 当たり（直しの後）★: dotnet test 全体 = base 2750f49 と同じ（合格 895・失敗 10・スキップ 5、失敗の名前 10 件が同一 = 全部 MatchesSimCli = sim_cli の在処を渡していない環境の失敗）。★RefCheck 11 本 = events・numbers とも 11/11 同一★（base と fix）、README の固定値 5 つ（585fda27・9fc9d0ca・de7c35fa・7328cadb・5ecb4be4）とも一致。注: RopeQ +∞ では新しい code は通らない = この一致は「今の遊びを変えない」の証しで、直しの効きの証しではない（効きは下の cell）。
- 試験の器 18 cell（RopeQ = 深さ＋d, 各 100 日）と 直す前（rope100.txt）の比べ:
| 腕 | 季節 | 巻かれ 前 → 後 | 取り込み 前 → 後 | 取り込み/日 前 → 後（none） | DIVE/ファイト 前 → 後 |
|---|---|---|---|---|---|
| Good | 春 | 20〜22% → 16〜18% | 71〜72% → 76〜78% | 1.58〜1.65 → 1.66〜1.76（2.28） | 2.9〜3.0 → 4.2〜4.9 |
| Good | 7月 | 21〜23% → 16〜18% | 68〜71% → 77〜78% | 1.69〜1.72 → 1.65〜1.67（2.35） | 2.9〜3.1 → 4.3〜5.1 |
| Slack | 春 | 18〜22% → ★0%★ | 62〜66% → 83〜85% | 1.38〜1.44 → 1.95〜2.00（2.05） | 2.3〜2.4 → 4.8〜5.7 |
| Slack | 7月 | 23〜27% → ★0%★ | 54〜58% → 84〜86% | 1.29〜1.40 → 1.83〜1.91（2.09） | 2.3〜2.4 → 4.9〜5.8 |
| Locked | 春/7月 | 0% → 0% | 99〜100% → 99〜100% | 2.24〜2.26 → 2.19〜2.28（2.39/2.49） | 2.5 → 2.8〜3.4 |
- trace（春 d 2 × 50 日）: Locked 区域の入り 0 → 326（全部 逃げ）、Good 82 → 473（逃げ 446・巻かれ 15・抽選を生き延び 12）、Slack 73 → 586（全部 逃げ）。入りは 魚がロープの 2〜4 m 手前（q 10〜12 / RopeQ 14）で起きる。Good の抽選に行く入り = 大きいチヌ（0.8×FRun 2.2〜2.5 N）で 報告の張力の山が 2.0〜2.3 N 前後を上下（閾をまたぐ 10〜30 回）、holdT は 0.3 s に届かず（最大 0.04〜0.21 s）、最後に 閾の下が途切れず tWrap（1.5〜2.2 s）続いた。時間切れ（Abort）0/18 cell。
- 予測 2 との照合: Locked 入り > 0・全部逃げ・巻かれ 0〜1% ★当たり★。Good 巻かれ 0〜5% → 16〜18% ★外れ★、取り込み ≥ 90% → 76〜78% ★外れ★、1 日の減り ≤ 10% → 25〜30% ★外れ★。Slack 3〜15% → 0% ★外れ★、「Good < Slack（腕で分かれる）」→ 逆（Slack 0・Good 17%）★外れ★。DIVE/ファイト そのまま → 3〜6 に増えた ★外れ★（RUN が RopeQ で早く終わり AfterRun が増える, codex）。d の差は小さい ★当たり★。
- codex 済: 今の遊び（+∞）は分岐・RNG とも不変 = 同意。DIVE の増えは code どおり。巻かれは「閾の下が途切れず tWrap」で起きる（またいだ後の最後の 1 区間）。★私の見積りの穴★: core のアンカー a は 糸に引き戻される時 q まで戻る（ikd_fight.c:259 `a = min(a, q)`）が、_diveA は前へ進むだけ = 実のアンカーが届かない区域を「入った」と言いうる（ロープの 2〜4 m 手前の入りと合う）。もう 1 つ: 張力が閾をまたぎ続けると どちらの時計も満ちず DIVE が終わらない道（前からある, 見積りで近くなる）= 今回の 18 cell では Abort 0。
- 読み（推論）: 形を仕様へ寄せると「巻かれ」は腕で分かれるようになった（Locked・Slack 0、Good 17%）が、向きは予測の逆で、残る巻かれは「ドラグを滑らせて張る腕 × 大きい魚 × 閾の近くの張力の揺れ」に集まる。釣れ方の減りは Slack・Locked ではほぼ消え（Slack 1 日 2.05 → 1.95〜2.00）、Good は 約 25% 減が残る。
- 次の候補（決めは PRESIDENT）: (1) _diveA を 引き戻しでも q まで戻す（core と同じ min(a, q)）= 見積りを core に近づける、(2) 閾の判定を 山の 1 tick でなく 平滑した張力で（揺れでの時計の戻りを減らす）、(3) 数（0.8×F_run・0.3 s・t_wrap・p_wrap_cut）を依頼者の感覚で（#41 と一緒の 1 問）。RopeQ を通常の遊びに渡すのは まだ（決めどおり）。

## (1) _diveA の引き戻し — 着手前の source 読み（観測, 04:5x）
- core のアンカー: 初めは q（ikd_fight.c:238）、毎 1 ms `a += v_anchor·dt` → [0, x_anchor_max] に clamp（:250-251）、★糸に引かれている時（dragged = xdot < qdot かつ k(q−x)+c(qdot−xdot) > margin, :252）だけ★ `a = min(a, q)`（:259）。引かれていない時は a は q より先にいてよい（魚がアンカーを追う, :265）。a は phase をまたいで続く（DIVE で q に戻さない）。
- PC が見られるもの: 0x84 の報告 = Q・LineOutM・張力の山・Events（HOOK_PULLED・HARISU_BREAK・SLACK・SHAKE_END・LIMIT_HIT・DRAG_SLIP, ikd_fight.h:63-66）= ★dragged も a も無い★。試験の器の VdevView（mcu/ikd_vdev.c:296-311）にも a は無い。
- ★= PC の式で core の a を「差 0」で写すことはできない★（dragged の判定は 1 ms ごとの x・xdot・ばねの力で決まり、PC には 10 ms の報告しか来ない; 始まりの値も DIVE 前から続く a）。差 0 を試験で縛るには ★判断を 1 経路にする★ 必要。
