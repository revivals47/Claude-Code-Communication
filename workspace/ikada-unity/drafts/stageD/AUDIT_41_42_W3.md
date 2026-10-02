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
