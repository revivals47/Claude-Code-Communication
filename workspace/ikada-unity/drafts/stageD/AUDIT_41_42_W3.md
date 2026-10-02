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
