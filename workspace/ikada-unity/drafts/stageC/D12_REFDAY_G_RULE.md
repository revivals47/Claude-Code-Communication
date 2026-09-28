# 照合の足す日 G（第4章 12/10 蒲江）— 回す前の決まり（worker3、2026-09-28 22:1x、PRESIDENT 22:1x。登録後に回す・動かさない）

- 基: ikada-sim main b70c0c430bc798214b1f25a3235f2e239c1e73db（worker1 の第4章の中身 8bcf00f・#10 を含む）。
- 日: 12/10（第4章・蒲江の湾のカセ）。RefCheck `--date 12-10`（`ReferenceRun.RunAt(seed, 12, 10, 0)`）。
- ★種の決まり（第3章 F と同じ）: 種 20260925 で掛かり（hooksets）が 1 回以上ならそれ。0 回なら 種 1..10 を小さい順に回し、掛かりのある一番小さい種。★10 までに無ければ 広げずに 上申★。
- 置き方は F と同じ: ci.yml は触らない。試験で縛る（F と同じ file の InlineData か Fact）＋ `pc/tools/Ikada.RefCheck/README.md` の行（--expect・Mono の例・表の行 = 理由・種の選び方・中身）。
- 予測（F と同じ形、回す前に書く）:
  - R1 12/10 の選んだ種の日は迎えまで回り、2 回回して log が 1 byte も違わない。
  - R2 .NET の events = Mono float = Mono double（`scripts/refcheck_mono.sh` DATES=12-10）。
  - R3 基準の縛り（#10 の 4/20・7/20・E′・F）は変わらない（src を変えない）。
  - R4 ci.yml は変えない。
  - R6（確度 低）: 投 30〜50・掛かり 1 回以上の種が 1..10 の中にある。
- 手元の全体の試験: CI の Runner.Worker 0 の時に。log の頭に ps で数えた Runner.Worker の数と load average の 1 行。出力は 1 回目から file に。時間の assert の赤は 1 回だけ回し直し、2 回続けば上申。値の assert の赤は即上申。
