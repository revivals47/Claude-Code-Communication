# 竿受け (a)・太さ F2 の続き（worker3）— ROD_HOLDER_FIX_W3.md §7.33 の続き（あの file が 462 行 = ここから分ける）

## §7.34 手の姿の横の逃げ（§7.33 の 4）と 手の場面の撮り（§7.33 の 6）— code と予測（撮りの前, 動かさない; Unity・Roslyn・dotnet なし = 未 compile）
- 決め: boss1 21:5x GO（4 = 横の逃げを RodRest2 の大きさから、2 点の時だけ、既定の 1 点は不変を対照で / 6 = IKADA_ROD_SHOT_HOLD=hand|sinking, 撮りだけ）。(a) の前の受けの見え = 依頼者がこの見えで選んだ = 今は直さない（PRESIDENT へ boss1 から）。
- code = ikada-unity-track3 track3/rod-edge ★01df0df★（be3ec28 ＋ この差）:
  - RodRest2.SideClearM(r, scale) = 受けの腕の上の外の面（床の半分の隙 r ＋ 腕の厚さ/2 ＋ 2 mm ＋ tan25° × 腕の高さ ＋ 当ての幅/2）＋ 竿の半径 r ＋ 1 cm、実寸 × 竿の倍率。
  - RuntimeRod.Hold: 2 点（HOLDER2 / EDGE=a）の時 ★手の横 = max(HandSideM 0.10 か IKADA_ROD_HELD_SIDE, 2 つの受けの SideClearM の大きい方 ＋ 0.02)★、HeldAngle の「受けの外へ出た」の境も その SideClearM（RodHolder.HeldAngle に引数を足した, 既定 = 今の RodHolder.SideClearM）。1 点（既定）は ★HandSideM・RodHolder.SideClearM のまま = 式は前と同じ★。dip の log の through の境も同じ値へ。
  - RodHand: env IKADA_ROD_SHOT_HOLD=hand / sinking = State の初めの値（editor の撮りは今まで いつも Rest）、未設定 = Rest、LiveHost の Reset は Rest のまま。
- ★数（計算）★: 後ろの受け（柄, 半径 0.0309 m）の SideClearM = 0.0309 ＋ 0.0082 ＋ 0.002 ＋ 0.0432 ＋ 0.0132 ＋ 0.0309 ＋ 0.01 = ★0.138 m★、前の受け（芯, 半径 約 0.013, F2）= 約 0.10 m → ★手の横 = 0.158 m（今 0.10）★。§7.33 4 の重なり（右の腕 x 0.069〜0.087 と 柄 0.069〜0.131）→ 柄の左の端 0.158 − 0.031 = 0.127 m ＞ 腕の上の外 0.097 m（0.03 m の隙）。

## §7.35 次の番（C0・W・F・L1・H）の予測（撮りの前, 動かさない）
- 木 = track3/rod-edge 01df0df。撮り（drafts/rod_look/rod_a_shots/run.sh）。F2 = IKADA_ROD_MIN_ACROSS=1 IKADA_ROD_GUIDES_REAL=1、(a) = IKADA_ROD_EDGE=a IKADA_ROD_FORWARD_M=1.73。
  1. C0（06, env なし）vs R0 = ★0 px★（01df0df でも既定は不変）。
  2. W（06, (a)＋F2, 待ち）: 竿の画 約 145 px・V 2 つ・挟む台が縁の線（Ea と同じ形）、竿は Ea より細い（F2）。★穂先の窓（画の x 17〜500・y 168〜595）は T2（F2 だけ）と 0 px★（§7.33 1）。Ea との差 = 竿と輪の所だけ。
  3. F（08, (a)＋F2, ファイト）: log の ★「fight floor」の行が無い★・★tipOverRaft False・entryPastEdge True★、穂先 z 約 5.6（log の tip）、糸は穂先から ほぼ真下。柄は 後ろの受けの上 約 0.3 m（grip 0.30）= 受けと重ならない。
  4. L1（06, F2＋糸 3 mm）: §7.32 のまま（下りる糸の先 2.25 → 約 1.1 px、T2 との差は下りる糸の所だけ）。
  5. Ha（06, (a)＋F2＋SHOT_HOLD=hand）: 竿全体が 右へ 0.158 m・上へ 0.05 m = 前の受けの所で ★画で 右へ 約 48 px・上へ 約 15 px（深さ 3.79 m）★、柄は 後ろの受けの右の腕の外（腕と柄の間に 水か甲板が見える）。
  6. Hs（06, (a)＋F2＋SHOT_HOLD=sinking）: Ha ＋ 穂先が 竿尻のまわりに −0.10 rad = ★穂先 約 0.31 m 下（画で 約 80 px 下, 深さ 約 4.5）★、受けとは重ならない。
  7. H1p（06, 既定 1 点＋SHOT_HOLD=hand, 対照）: 手の横 ★0.10 m のまま★（今の式）= 縁の受けの所（深さ 3.9）で 画で 右へ 約 30 px・上へ 約 15 px。
  - 7 枚 exception 0・porcelain 0。画: c199 = (a)＋F2 の 待ち・手・沈み・ファイト（依頼者の言葉の見出し, PRESIDENT が見てから）。
- ★結果（boss1 22:25 LOCK, 木 01df0df, 画 = rod_a_shots/, 依頼者向け = c199）★: Roslyn sim/game/editor 0 error。7 枚 rc 0・exception 0、track3 porcelain 0、FREE 前に Unity・player・VBCS 0（撮り中に出た自分の VBCS 1108322 を kill）。
  1. C0 vs R0 = ★0 px★ → 当たり。
  2. W: ★穂先の窓（x 17〜500・y 168〜595）W vs T2 = 0 px★ → 当たり。Ea との差 1,044 px・枠 x 910〜969・y 608〜701（竿の先と輪の所だけ = F2）→ 当たり。
  3. F（08）: log に ★「fight floor」の行なし★・★tipOverRaft False・entryPastEdge True★ → 当たり。穂先 (0.489, 1.784, 5.422) = ★z 5.42（予測 約 5.6 = 0.18 m 手前, 小さく外れ）★。入水 (1.464, 5.422) = z は穂先と同じ（真下の z）、x は LINE_SIDE（rodLine 0.500）で 右へ 0.98 m = 「ほぼ真下」は ★z は当たり・x は 外れ（§7.33 3 に書いた LINE_SIDE の横の傾きが 0.5 rad で大きい）★。目: 竿は 2 つの V の上 宙に立つ（手は描かない = 前から）、糸は穂先から右下の海へ。
  4. L1 vs T2 の差 = ★x 924〜927・y 636〜742 だけ = 下りる糸の所だけ★ → 当たり。★糸の見える幅（背景より明るい分の 1 行の和, y 690〜735 の中央; 1 px より細い線は 和 ∝ 幅）: L1 / T2 = 0.72 → 2.25 px × 0.72 = 約 1.6 px（予測 約 1.1 = 外れ）= F2 の竿の先 1.5 px と ほぼ同じ（細くはなったが 竿より細くはない）★。
  5. Ha: log の穂先 x 0.178（W 0.019 から ★+0.159 m, 予測 0.158★）・y 0.800（+0.05）→ 当たり。目: 柄は 後ろの受けの右の腕の外（拡大で 腕と柄が 画で重なるのは 柄の方が目に近い = 竿尻 z 2.96 が 後ろの受け z 3.08 より手前, 奥行きの重なり）。Ha vs W 9,272 px・枠 x 831〜991・y 565〜783。
  6. Hs: 穂先 y 0.491 = Ha から ★0.309 m 下（予測 0.31）★ → 当たり。Hs vs Ha 4,419 px・枠 x 913〜991・y 565〜743（穂先の側だけ）。
  7. H1p（1 点・手）: 穂先 x −0.031（R0 −0.131 から ★+0.10 m = 今の HandSideM のまま★）→ 当たり = ★既定の 1 点は 横の逃げの code で動かない（対照）★。
- 依頼者向け: c199_rod_a_scenes.png（待つ時・手に持つ時・沈むのを待つ時・やり取り, 拡大と全体, 見出しは依頼者の言葉）。気づき（観測）: 手・沈み・ファイトで 竿は 手なしで宙にある（前からの形, 手は描いていない）。

## §7.36 手・沈み・やり取りでは 竿を手の位置へ戻す（PRESIDENT 22:4x）— code と予測（撮りの前, 動かさない; Unity なし = 未 compile）
- PRESIDENT の読み: c199 の 手・沈み・やり取りで 竿が 縁の受けの真上（目から 4 m 余り先）の宙に立つ = 手で持つ竿が 4 m 先にある形。84 cm 前は 受けに置く時の為 → ★手の状態（落とす・沈み・合わせ〜取り込み）と ファイトでは 竿を前の手の位置（(a) の前, 握り +0.30 を決めた位置）へ戻す、移りは今の τ（PlaceTauS 0.5 s）のまま★。
- code = ikada-unity-track3 ★track3/rod-default 0ef08cf★（01df0df ＋ この差, 既定は不変）: 
  - builder（BackdropBuilderProps.BuildRod）は 今どおり 竿を FORWARD_M だけ前に作り（待つ時の画 = c199 のまま）、その量を RuntimeRod.restForwardM に残す（scene に焼かれる）。
  - RuntimeRod.Hold.Rest: 受け（RodHolder の点・RodRest2）を 前の竿の位置で置いた後、★_back を (手 または ファイト) かつ EDGE=a なら restForwardM、ほかは 0 へ k2（PlaceTauS）で寄せ、竿尻と穂先を 竿の水平の向きに沿って _back だけ戻す★（lift・横・沈みの下げは その後に今どおり）。受けは動かない。戻した竿は受けの上にいないので 手の横は HandSideM 0.10（§7.34 の 0.158 は 戻さない 2 点（HOLDER2 の台）の時だけ）。_settling に _back を足した（受けへ戻る間は 手の角の式）。
  - 撮りだけの env IKADA_ROD_SHOT_EASE（0〜1）= editor の 1 枚で 寄せを 1 段だけ その割合で（受け → 手の 途中の 1 枚）。未設定 = 今どおり 一度に。
- ★予測（log の穂先 ＝ 世界の座標, 画の穂先, 竿の画の長さ）★: 対照は 同じ番の F2 だけ（(a) なし）の 手 H0・沈み Hs0・ファイト F0。
  1. W'（待ち, (a)＋F2）vs c199 の W = ★0 px★（待つ時は _back 0 = code の前と同じ）。
  2. Ha'（手）: log の穂先 = ★H0 と 0.001 m 以内（(−0.031, 0.800, 4.306) = 前の H1p と同じ）★、画の穂先の位置 H0 と ±1 px、竿の画の長さ H0 と ±2 px。違い = 縁に 空の V 字 2 つと台が残る ＋ ★竿の太さ: 床（1.5 px）を 前に出した位置で測って焼いたので 戻すと 先で 約 1.4 倍（1.5 → 約 2.1 px）太い★（推論, 4.37 / 6.04 の深さの比）。
  3. Hs'（沈み）: 穂先 = Hs0 と 0.001 m 以内（y 約 0.49）、画 ±1 px。
  4. F'（ファイト 08）: 穂先 = F0 と 0.001 m 以内（今の F の穂先 (0.489, 1.784, 5.422) から 竿の向きに 1.73 m 戻る = 約 (0.338, 1.784, 3.699) ＋ 下限 0.6 が効けば F0 と同じだけ上がる）、log の tipOverRaft・fight floor の行は F0 と同じ。画の竿の長さ F0 と ±2 px。
  5. M（移りの途中, 手 ＋ SHOT_EASE=0.5）: _back 0.865・lift 0.025・横 0.05 = 穂先 約 (−0.006, 0.775, 5.18)、画で W と Ha' の間（竿の長さも間）。
  6. C0（env なし）vs R0 = 0 px。全 9 枚 exception 0・porcelain 0。
- 既定にする commit（PRESIDENT の答えの後に同じ形で）: EDGE の既定 a・FORWARD の既定 1.73（EDGE=off で 前の 1 点・FORWARD 0）、F2（MIN_ACROSS・GUIDES_REAL の既定 on, =0 で前）、糸 3 mm（LINE_MM の既定 3, =6 で前; §7.35 で 1.6 px = 竿の先とほぼ同じ → 入れるかは PRESIDENT）。差し替えの表（替わる画面）は 既定の commit の時に書く。
- ★結果（boss1 22:32 LOCK, 木 0ef08cf, 画 = rod_back_shots/, 並べ = c200）★: Roslyn 0 error。9 枚 rc 0・exception 0、track3 porcelain 0、FREE 前に Unity・player・VBCS 0（撮り中に出た自分の VBCS 1116804 を kill）。
  1. W2 vs c199 の W = ★0 px★ → 当たり。C0 vs R0 = 0 px → 当たり。
  2. Ha2（手）の穂先 (−0.031, 0.800, 4.306) = ★H0 と同じ（log の 3 桁で一致）★、Hs2（沈み）(−0.032, 0.491, 4.291) = ★Hs0 と同じ★、F2b（ファイト）(0.338, 1.784, 3.699)・[FightLine] の px (1103, 349)・入水 (1.362, 4.235)・tipOverRaft True = ★F0 と全部同じ★ → 当たり（「fight floor」の行は F0 にも F2b にも無い）。画の差: Ha2 vs H0 5,579 px・Hs2 vs Hs0 6,487 px・F2b vs F0 8,108 px = 縁の 空の V 2 つと台 ＋ 竿の太さ。
  3. M（途中, SHOT_EASE=0.5）の穂先 (−0.018, 0.788, 4.739) ★予測 約 (−0.006, 0.775, 5.18) = 外れ★。訳（source）: builder は rod.ApplyNow() を 2 回呼ぶ（BackdropBuilderProps.cs:286・289）= 寄せが 2 段 = 1 − 0.5² = 0.75 → 戻り 1.30 m・lift 0.0375 → 穂先 z 4.306 ＋ 0.25 × 1.73 × 0.996 = 4.737（測り 4.739 と一致）。途中の 1 枚としては 移りの 0.75 の所。
  4. ★竿の太さ（boss1 の足し）★: 計算 = 床（1.5 px）を 前に出した位置で測って焼いたので 手元へ戻すと ★f 0.7〜0.95 で 1.42〜1.51 倍（1.5 → 2.1〜2.3 px）、f 0.5 は 1.0 倍（床が効かない）★。測り = 前の形（H0・Hs0）との差の画素の幅（竿に直角, 25 断面の中央）: 手 f 0.85 で 3.5・0.95 で 2.5 px、沈み 3.75・3.5 px、f 0.3 は 0（太い所は同じ）、f 0.5・0.7 は 縁の空の受けと重なり 数えられない（11〜15 px は受けの分）。目（拡大）: 先は少し太いが 先へ細くなる形は残る。★「先まで同じ太さ」へ戻るかは 依頼者の目の判断に要る★。直すなら: 床を 手元の位置でも測った大きい方でなく 小さい方（＝ 手元の位置）で焼く → 待つ時（遠い）の先が 1.5 → 約 1.07 px に細る（ちらつきの危険が上がる）、または 床を 毎フレーム 今の位置で測り直す（code 大きめ）。
  5. ★新しい気づき（観測 ＋ 計算）★: 手・沈みで ★竿が 縁に残った空の V 字（前の受け）を 通り抜けて見える★（c200 の上の拡大 3 枚目）。訳: 受けは 前に出した竿の線の上 = 竿を 竿の向きに戻すと 手元の竿の線も 受けの所を通る、横 0.10・上 0.05 だけでは 受けの腕（横 約 0.10・高さ 約 0.09）から出切らない。計算: 前の受けの所（z 3.79）で 手の竿 x −0.075・y 0.80、前の受けの右の腕の上 x 約 −0.08 → 重なる。直しの案: 戻した時も 横を §7.34 の 0.158（受けの大きさから）にする / または 受けを 竿の線から横へずらして置く。PRESIDENT の判断に要る。

## §7.37 案 A = 手元へ戻した時も 手の横を受けの大きさから（PRESIDENT 22:4x GO）— code と予測（撮りの前, 動かさない; Unity なし）
- 決め: (1) 案 A GO（手の時だけ横 0.158、待つ時は不変）→ 撮り直し 手・沈み ＋ 対照 待つ時 0 px。(2) 太さは今は直さない（依頼者の目）。
- code = track3/rod-default ★1b1a1da★（0ef08cf ＋ SideTarget・SideClear の「戻した時は HandSideM」を外した = 2 点の受けがあれば いつも 受けの大きさ ＋ 0.02 = 0.158）。待つ時は _side 0 = 不変。
- ★計算（世界, 手の竿の 受けの z での点 と 受けの右の腕の上の外）★: 横 0.10（0ef08cf, c200）= 前の受け（z 3.79）で 隙 +0.007 m・★後ろの受け（z 3.09）で −0.011 m = 腕の中★（c200 の通り抜け）。★横 0.158（1b1a1da）= 前 +0.065 m・後ろ +0.047 m = 両方 外★。
- ★予測（3 枚, 06, (a)＋F2）★: W3（待ち）vs W2 = ★0 px★。Ha3（手）の穂先 log = ★(0.027, 0.800, 4.301)★（Ha2 から 竿の横へ +0.058 m）、Hs3（沈み）= ★(0.026, 0.491, 4.286)★。画: 前の受けの所で 竿が Ha2 より ★右へ 約 17 px★（937 → 954, 計算）、★前の V の右の腕の上（画 約 931, 750）と竿の間に 背景の画素が 横の行で 10 px 以上★（Ha2 は 6 px 程度で 腕と竿が接する）。exception 0・porcelain 0。
- 途中の 1 枚の 2 回進め（boss1 の問い, source）: ★撮りだけ★。editor の撮りは Update が回らず builder が ApplyNow を 2 回呼ぶ（BackdropBuilderProps.cs:286・289）。live は RuntimeRod.Update（RuntimeRod.cs:162）の 1 フレーム 1 回で、RodSnapshotFeed.OnShown（RodSnapshotFeed.cs:54）は ScreenHost.LiveDriven なら先に返る = 足しの 1 回は無い（mock の遊び = live でない時だけ 画面の替わり目の 1 フレームに 1 回足される）。
- ★結果（boss1 22:40 LOCK, 木 1b1a1da, 画 = rod_a2_shots/, 依頼者向け = c201）★: Roslyn 0 error。3 枚 rc 0・exception 0、track3 porcelain 0、FREE 前に Unity・player・VBCS 0（撮り中に出た自分の VBCS 1124383 を kill）。
  - W3 vs W2 = ★0 px★ → 当たり。Ha3 の穂先 ★(0.027, 0.800, 4.301)★・Hs3 ★(0.026, 0.491, 4.286)★ = 予測と 3 桁で一致 → 当たり。
  - 画（4 倍の拡大, 目）: ★前の受け（遠い小さい V）= 竿は その右を 大きく離れて通る（通り抜けなし）★ → 当たり。★後ろの受け（近い大きい V）= 竿が 右の腕の外の縁に沿って ほぼ接して見える★（世界では 0.047 m 離れる計算, 画で隙はほとんど無い = 目の位置の重なり）。「隙 10 px 以上」は 前の受けの所では当たり、後ろの受けの所は 測りの行を決めていなかった（前の受けの所だけを予測した）= 当たりとは数えない。沈み（Hs3）は 竿が下がり 両方の受けから離れる。
  - c201 = 待つ時（W3）・手（Ha3）・沈み（Hs3）・やり取り（F2b, 0ef08cf の撮り = 手の横はファイトに掛からないので 1b1a1da でも同じ, 推論）、見出しは依頼者の言葉。途中の 1 枚は 0.10 の時の画なので入れていない。

## §7.38 既定にする commit（PRESIDENT 22:5x GO）— code・差し替えの表（予測）・1 点の道の全列挙（撮り・regress の前, 動かさない; Unity なし = 未 compile）
- code = ikada-unity-track3 ★track3/rod-default 525d9b1★（1b1a1da ＋ 既定の差, 4 file +38/−29）。既定（env 未設定）と 旧に戻す env:
  | 何 | 既定（新） | 旧に戻す env | 出所 |
  |---|---|---|---|
  | 竿受け | 縁を挟む台＋腕＋V 2 つ（EDGE=a） | IKADA_ROD_EDGE=off（縁の 1 点, c196 まで）／=b（V 1 つ） | 依頼者 c198 の答え (a)・PRESIDENT 21:5x |
  | 竿の位置 | 1.73 m 前（実 0.84 m）, 手・ファイトでは戻す | IKADA_ROD_FORWARD_M=0（EDGE=off なら既定 0） | 同上 ＋ PRESIDENT 22:4x |
  | 手の横 | 0.158（受けの大きさ ＋ 0.02） | （EDGE=off で 0.10） | PRESIDENT 22:4x 案 A |
  | 太さの床 | 竿に直角で 1.5 px（F2） | IKADA_ROD_MIN_ACROSS=0 | 依頼者 c197 の答え 案 2・PRESIDENT 21:5x |
  | ガイドの輪・針金 | 実寸 ×1（F2） | IKADA_ROD_GUIDES_REAL=0 | 同上 |
  | 下りる糸 | 3 mm | IKADA_ROD_LINE_MM=6 | PRESIDENT 22:5x |
  - 注の直し: LineDiaM と GuidesReal の注が be3ec28 で割れていた（GuidesReal の注の後に LineDiaM の注と宣言）を 戻した。「shots only」の古い注 5 か所（RodRest2 2・RodDressing 1・RuntimeRod.Hold 2・Props 1 の行末）を今の値へ。
- ★差し替えの表（予測）★: regress の画面（tools/regress_all.sh:72 BASE_IDS = S0 05 07 06 08 03 04 J Z P1 P2 06C 06M）× A/B。3D の画面（ScreenRegistry の Uses3D = true: 06・06C・06M・08・P1・P2、ほかに 06G は regress 外）だけ替わる:
  | 画面 | 替わるか | 予測の形 |
  |---|---|---|
  | 06・06C・06M・P1・P2（待ち, 受けに置く） | ★替わる★ | 竿は縁の V 2 つに 遠く小さく（c199/c201 の待つ時 = W3 と同じ）、太さ F2、下りる糸 3 mm。★06 の新しい既定 vs W3（1b1a1da の env 撮り）= 下りる糸の所だけの差（糸 6 → 3 mm, 穂先 (964, 614) から下の縦の帯）★。HUD の所は 0 px。 |
  | 08（ファイト） | ★替わる★ | 竿は手元へ戻り（F2b と同じ形）, 縁に V 2 つと台、F2、糸 3 mm。★08 の新しい既定 vs F2b = 下りる糸の所だけの差（穂先 (1103, 349) から入水 (1441, 836) の線）★。 |
  | S0・05・07・03・04・J・Z（2D） | 替わらない | ★0 px★ |
  - regress の baseline（今 ae3b5c4 系）に対しては 3D の 6 画面 × A/B = 12 組が FAIL（替わる = 予測どおり）、2D の 7 画面 × A/B = 14 組は PASS（0 px）の見込み。差し替え = 新しい baseline を PRESIDENT の GO で。
  - ★対照★: 525d9b1 で 旧に戻す env を全部（IKADA_ROD_EDGE=off IKADA_ROD_MIN_ACROSS=0 IKADA_ROD_GUIDES_REAL=0 IKADA_ROD_LINE_MM=6）付けた 06 vs R0（e7f7269 の既定）= ★0 px★、08 vs master の 08 = 0 px（既定の差が 旧の道を壊していない確かめ）。
  - live（遊べる版）: 待ち = 竿は縁の受けに、手（落とす・沈み・合わせ〜取り込み）とファイト = 手元へ τ 0.5 s で戻る。log: ★[Cast]・screens・RESULT など logic の行は不変★（描きだけの差）。[RodHolder] rest の cradle = (−0.177, 0.750, 3.791)（今 (−0.172, 0.750, 3.845)）、★[RodHolder] dip の dy は 前の受けの点からの高さ = 竿が手元へ戻るので 意味が替わる（値は大きく替わる, 推論）★、[FightLine] の穂先・入水は ★今（F2 前）と同じ★（戻した竿は (a) の前の位置, F2 は中心線を動かさない; §7.36 で F2b = F0 一致）。
- ★1 点（RodHolder）の道の全列挙（grep, 1b1a1da/525d9b1, Assets 全部の .cs）★:
  1. RuntimeRod.Hold.cs:38 `_holder.Place(_butt, _tip, deckTopY, deckFrontZ, radius)` = 1 点の受けを縁に置く道 → ★既定では通らない★（EDGE=off / b の時だけ）。
  2. RodHolder の部品（Clamp・ClampLip・Post・Cradle の箱）= 既定では Show(false) で描かない。RodHolder の Point（前の受けの点）・TurnAbout（−5° の軸）・HeldAngle（手の角の式）は ★既定でも使う★（2 点の前の受けの点として）。
  3. RodHolder.SideClearM・RuntimeRod.HeldClearM（0.045）= 1 点の時だけ（SideClear / HeldAngle の引数）→ 既定では通らない。
  4. RuntimeRod.Hold.cs:26 の f（縁から 1 点の受けの竿の割合）と radius = 1 点の道でだけ使う（2 点では RadiusAt）→ 既定では計算するが使わない。
  5. BackdropBuilderRodGrip.BuildRodHolder（BackdropBuilderProps.cs:296）= P3/P4 の試しの置き方（TrialPlacement）だけ = 前から既定外。
  6. pose "holder075"（BackdropBuilderProps.cs:215）= RodPose の env だけ = 前から既定外。
  7. log: RuntimeRod.Hold.cs の [RodHolder] rest・dip・placed の 5 行 = 既定でも出る（_holder.Point = 2 点の前の受けの点に対して測る）、dip の「clear >= HeldClearM − 0.002」の字は 1 点の値のまま（既定では HeldClear2M 0.10 が効く）= ★字が今の式と合わない 1 か所★（直すなら log の字だけ, code 1 行）。
- ★結果（boss1 22:48 LOCK, 木 2932798, 道具 = default_turn/run.sh, 出力 = default_turn/）★: Roslyn sim/game/editor 0 error。FREE 前 Unity・player・VBCS 0（数えて 0）、track3 porcelain 0（regress の start / after_build / end も 0）。
  - regress（Logs/regress/2932798_224907）= ★13/16 PASS★: build・key・pad・hud・edge・tip_size・input（91）・atlas・refcheck 11/11・player_shots 26/26・editor_shots 26/26・editor_repeat・git_clean = PASS。FAIL 3: ★live★（seed 3 種とも ★logic sequence = baseline★、差 = live_06・live_06C（3 種）・live_08（種 26）の画 = 竿の差 = 予測どおり）、★baseline★（14/26 組 0 px = 2D の 7 画面 × 2、3D の 12 組が差 = ★予測 12 FAIL・14 PASS と同じ★）、★compare★（player と editor の差: 08 だけ diff>24% 2.10 / 2.11 %（上限 1.0）、ほかは 0.24 以下）= ★予測していなかった FAIL★。
  - ★compare の 08 の訳（観測 ＋ source）★: player の 08（mock の撮り -ikadaShot）は 竿が 手元へ戻り切らず 前に残る（画で 竿が小さく遠い）、editor の 08 は 戻り切る。訳 = RuntimeRod.Hold の k2 は Time.deltaTime > 0 なら τ で寄せる → player の mock の撮り（数十フレーム目）は 移りの途中。ファイトの握り +0.30（GripRaise）は s_stillShot（-ikadaShot）なら一度に、を前から持つが、私の _back（§7.36）は それを見ていない。★直し = Rest の k2 にも s_stillShot を足す（1 行: Time.deltaTime > 0f && !s_stillShot）★ = player の mock の撮りだけ editor と同じに、live（-ikadaLiveShot・遊び）は τ のまま。GO の後。
  - 対照: ★K06（旧に戻す env 全部）vs R0 = 0 px、K08 vs master の 08（506dfab_194806）= 0 px★ → 当たり（既定の差は 旧の道を壊していない）。
  - editor 26 枚 vs master（506dfab_194806）: ★2D 14 枚 = 0 px★、06・06C・06M = 43,979 px（箱 611,612〜1543,1080）、08 = 12,561 px（688,204〜1273,783）、P1 = 95,715、P2 = 79,632 / 79,684（590,599〜1566,1080）→ 予測（3D の 6 画面が替わる）どおり。
  - ★新しい既定 06 vs W3 = 202 px・箱 x 963〜965・y 615〜717 = 下りる糸の所だけ★ → 当たり。★08 vs F2b = 差（> 30 の 810 px）が 穂先 (1070, 355) から 甲板の縁 (1272, 741) まで 垂れた糸の道に沿う ＋ ほかに 7 px（差 5 以下, x 719〜1046）★ → ほぼ当たり（7 px の細かい差は 予測に無い, 記録）。
  - live dry（live_rebase5, ★apply なし★）: changed 10（live_06・live_06C × 3 種・live_08 種 26・live.log × 3）、added 0・gone 0・same 23。表 = default_turn/LIVE_SWAP_TABLE.md、画 = default_turn/live_sheet.png。mock の新旧 = default_turn/mock_sheet.png（06・06C・06M・08・P1・P2, 旧 master ｜ 新）。
- ★直し ed4fe86（boss1 23:0x GO）と予測（regress もう 1 回の前, 動かさない）★: RuntimeRod.Hold.Rest の寄せ k2 に s_stillShot（-ikadaShot = player の mock の撮り）を足した（GripRaise と同じ）= player の mock の撮りでも 受け・手・戻しが一度に。live（-ikadaLiveShot, -ikadaShot なし）と遊びは τ 0.5 s のまま。予測:
  - ★compare の 08 = diff>24 % が 上限 1.0 % の中（前の木の値 0.00〜0.13 程度）★、ほかの画面は 今回（2932798）と同じ値。
  - ★player の 06・06C・06M・P1・P2・2D 7 画面 = 2932798 の player と 0 px★（受けに置く時は 寄せる物が無い = k2 の替わりが効かない）。★player の 08 だけ替わる★（竿が手元へ戻り切る）、player 08 vs editor 08 は 竿の位置が同じになる。
  - ★live の画（3 種）= 2932798 の live と 0 px★（live は -ikadaShot を付けない）、logic sequence = baseline。
  - regress は 14/16 の見込み（FAIL = live・baseline = 差し替え待ちの 2 つ）。対照 2 枚 0 px のまま。

## §7.39 live 08（種 26）の竿の位置 — 測りの番の決め（PRESIDENT 23:1x〜23:5x）
- 控え（PRESIDENT 23:5x, 別の番）: ★live の撮りで 穂先のばねを止めている（-ikadaTipSettle → TipBendLayer.SettleForShots, TipBendLayer.cs:90-100 = Step の代わりに Settle）= 撮りと遊びの差★。揃える（時刻をずらす方へ）と live 08 の基準が動く。
- ed4fe86 の s_stillShot = mock の撮りだけ（RuntimeRod.Fight.cs:31 の式 = 引数 -ikadaShot がある時だけ）= 線の中（PRESIDENT 23:5x）。
- 08 の撮りの時刻 = HookSet ＋ 2.31 s（描きの時間, 戻し τ 0.5 と 握り τ 0.25 の残り 1 % 未満 = 0.5 × ln 100 = 2.303 s）, 遅くした窓（1 倍）の中, regress の引数のまま（PRESIDENT 23:5x GO）。
- 帯 6 枚（HookSet ＋ 0・0.1・0.25・0.5・1.0・1.5 s）= 見るための 1 回物 = ★-ikadaTipSettle を外す★（穂先の揺れも込み）、別の run。
- ★ed4fe86 の regress の結果（23:06 LOCK, Logs/regress/ed4fe86_230630, 出力 = default_turn2/）★: Roslyn 0。★14/16 PASS★（FAIL = live・baseline = 差し替え待ち）→ 予測どおり。★compare 08 = 0.01 / 0.02 %★（上限 1.0）→ 当たり。★player の 08 以外 12 画面 = 2932798 の player と 0 px、08 だけ 45,981 px（竿が戻り切る）★ → 当たり。★live の画 3 種の全部 = 2932798 の live と 0 px★（live_08 種 26 も同じ = 寄せ途中のまま）→ 当たり。対照 2 枚 0 px。live dry changed 10。FREE 前 Unity・player・VBCS 0。
- ★測りの番の code と予測（撮りの前, 動かさない）★: code = track3/rod-default ★4232827★（ed4fe86 ＋ ファイトの frame log に TimeS・戻しの量/作りの量・竿の根元・受けの点・手の状態、上限 120 → 200 行, env IKADA_ROD_FRAME_LOG=1 の時だけ, log だけ）。道具 = live08_turn/run.sh（Roslyn → player の作り → run A 帯 → run B regress の引数 ＋ 2.31 s）。
  - ★予測（計算: k = 1 − exp(−dt/τ), dt = 1/60 s, 戻し τ 0.5 → k 0.0328, 握り τ 0.25 → k 0.0645）★:
    - fight frame 1（HookSet の最初の 1 フレーム = regress の live_08 の frame）: ★back = 0.057 / 1.73★、butt ≈ ★(−0.254, 0.769, 2.903)★（受けの位置の竿 (−0.249, 0.750, 2.960) から 竿の向きに 0.057 戻り、握り 0.019 上）、rest = ★(−0.176, 0.750, 3.791)★、hold = ★Hand★、backInHand = True。
    - n フレーム目: back = 1.73 × (1 − 0.9672ⁿ)。frame 7（＋0.1 s）0.36 m・16（＋0.25 s）0.73・31（＋0.5 s）1.10・61（＋1.0 s）1.50・91（＋1.5 s）1.65。
    - ★frame 139（＋2.31 s = run B の撮り）: back = 1.713 m（残り 0.017 m = 1.0 %）、grip = 0.300、butt ≈ (−0.398, 1.050, 1.253) = 手元★（手元 (−0.400, 0.750, 1.236) ＋ 握り 0.30 ＋ 残り 0.017）。画は 竿が 左下に大きく（mock の 08 = editor の 08 と同じ形）。
    - 帯 6 枚: 竿が 受けの所（画の中ほど 小さく）から 左下へ 大きく 滑ってくる、＋1.5 s で ほぼ手元（残り 5 %）。穂先は TipSettle なしで揺れる。
  - 外れたら止めて報告（PRESIDENT 23:3x）。
- ★結果（boss1 23:22 LOCK, 木 4232827, 出力 = live08_turn/）★: Roslyn 0・作り ok（fonts の変わり 0）。run A（帯, TipSettle なし）・run B（regress の引数 ＋ 遅くした窓 ＋ 794.71 の 1 枚）とも rc 0・exception 0、HookSet = TimeS 792.399（両方, 前の regress と同じ）。FREE 前 Unity・player・VBCS 0（撮り中に出た自分の VBCS 1163431 を kill）、porcelain 0。
  - ★frame の行（観測）★: fight frame 1 = back ★0.0567★/1.73・butt ★(−0.254, 0.769, 2.903)★・rest (−0.177, 0.750, 3.791)・hold ★Hand★・backInHand True・grip 0.0193 → ★予測と一致（rest の x は −0.176 予測 = 0.001 の丸め）★。frame 139 = back ★1.7132★・grip 0.300・butt ★(−0.399, 1.050, 1.253)★ → ★一致★。frame 2・3 = 0.1116・0.1646（1.73 × (1 − 0.9672ⁿ) と一致）。= ★置きの code は 手（ファイト）で 竿を手元へ τ 0.5 s で戻している（log で実測）★。
  - ★外れ（記録, 止めて報告）★: (i) 予測は「遅くした窓の中では sim の時刻 = 描きの時刻（1 フレーム 1/60 s）」と置いたが、★実際は HookSet の後 sim が 約 33 フレーム 792.399〜792.416 に止まり、その後も 1 フレーム < 1/60 s★（run A: frame 139 で sim は ＋0.52 s、run B: ＋1.77 s）→ 帯の 6 枚は 予測の frame 1・7・16・31・61・91 でなく ★frame 34・72・113・160・200 以上・200 以上★（back 1.17・1.57・1.69・1.72・1.73・1.73）= ★「＋0」の 1 枚目で 既に 68 % 戻っている★。(ii) run B の 2.31 s の 1 枚も frame 200 以上（back 1.7278 = 残り 0.13 %）。(iii) ★run B の screen の撮り live_08（regress と同じ引数 ＋ 遅くした窓）は frame 33（back 1.154）★ = 遅くした窓が 撮りの frame を替えた → ★本物の regress（窓なし）の live_08 が frame 1 かは まだ log で測っていない★（前の regress の live_08 と run B の live_08 = 7,687 px 違う = 別の frame）。
  - 画（目, live08_compare.png）: ★旧 baseline の live_08（master 系）と ＋2.31 s の 1 枚は 竿が同じ所（左下から 手元）★、regress の live_08 は 竿が受けの所（画の中ほど 小さく）= 寄せ途中。帯（strip.png）= ＋0 で既に半分以上手元、＋0.5 以降 ほぼ手元。
  - ★次（案, PRESIDENT の判断）★: (a) 本物の regress の引数（窓なし）＋ frame log で 種 26 を 1 本 = live_08 が何 frame 目かを log で（約 2 分）。(b) 08 の撮りを ずらすのは 「sim の ＋2.31 s」でなく ★「08 の画面が出てから 描きの 139 フレーム以上」★（窓の中では sim が描きと揃わない = 時刻で決めると frame が読めない）= live の撮りの道具に 画面ごとの遅らせ（frame 数）を足す code（live の撮りの道具だけ, 遊びは替えない）。(c) 帯を 竿が受けにある時（frame 1）から見たいなら 撮りを frame で（＋0・6・15・30・60・90 frame）。

## §7.40 live 08 の frame を本物の regress の引数で 2 本・帯を frame で（PRESIDENT 23:6x）— code と予測（撮りの前, 動かさない; Unity なし = 未 compile）
- ★私の前の言の訂正（source, LiveHost.cs:457-460）★: live の画面の撮り Shot(id) は holding = true にして ★30 フレーム待ってから★ 撮る（その間 logic の歩みは止まり 描きは進む = 竿の寄せは進む）。= ★regress の live_08 は「アワセの最初の 1 フレーム」ではなく 約 31 フレーム目★（§7.39 で「frame 1」と書いたのは log の時刻から推した誤り、PRESIDENT の「frame 1 なら 0.057」の前提も同じ）。§7.39 の「窓の中で sim が 約 33 フレーム止まる」も この 30 フレームの待ち（run A は 最初の ShotAt、run B は 08 の画面の撮り）。
- もう 1 つ（source, LiveHost.cs:358 と :383）: 画面が替わった step では Shot を始めて return するので ★その step の RuntimeRod.SetLive(s) は呼ばれない★ = 待ちの 30 フレームの間 竿は 前の step の snapshot（ファイト前 = fight False の見込み）で描く、RodHand は HookSet で Hand（:337）→ ★手の形（lift 0.05・横 0.158・戻し）で 握り +0.30 は無い★ 見込み（run B は 窓で step が分かれ fight True の frame log が出た = regress と別の道, 7,687 px の差の訳の候補）。
- code = track3/rod-default ★b763128★（4232827 ＋ ① 手・ファイト・戻りの途中の毎フレーム log「hold frame」（fight・hold・hand・back・lift・side・butt・rest, IKADA_ROD_FRAME_LOG=1 の時だけ, 400 行まで）② 撮りの道具 -ikadaLiveShotFrames <画面>:n1,n2,… = その画面が出てから n フレーム目に撮る（歩みを止めない）, 遊びは不変）。LiveHost.cs は 前から 708 行（500 超え）、＋24 行。
- ★予測（動かさない）★:
  - (a) R1・R2（regress の引数そのまま = ARGS.txt, 窓なし）: ★HookSet から 08 の撮りまでの hold frame = 31 ± 2★、撮りの frame の ★back = 1.12〜1.16 m★（1.73 × (1 − 0.9672ⁿ)）、★fight = False・hold = Hand・lift 0.05・side 0.158（手の形, 握りなし）★（外れて fight = True なら 握り 0.26 前後）。★R1 vs R2 の live_08 = 0 px、frame の行も同じ★（lockstep・captureFramerate = 決まっている）。★R1 vs ed4fe86 の regress の live_08 = 0 px★（b763128 は log と撮りの道具だけ, 08 の撮りは同じ道）。
  - (c) 帯（窓 785-800 = 1 倍、TipSettle なし、ShotFrames 08:0,6,15,30,60,90）: back ≈ ★+0: 0〜0.06（受けの所）・+6: 0.31〜0.36・+15: 0.68〜0.71・+30: 1.09〜1.12・+60: 1.50・+90: 1.65 m★、画は 受けの所の小さい竿 → 左下の手元へ。
  - 全 3 本 exception 0、作りの後 porcelain 0。
- ★結果（boss1 23:30 LOCK, 木 b763128, 出力 = live08b_turn/）★: Roslyn 0・作り ok（fonts の変わり 0）。R1・R2（regress の引数そのまま）・C（帯）rc 0・exception 0、HookSet TimeS 792.399（3 本とも）。FREE 前 Unity・player・VBCS 0（撮り中に出た自分の VBCS 1170635 を kill）、porcelain 0。
  - ★(a) 3 つを並べて（log の実測, R1 = R2 で同じ行）★: 撮りの frame = HookSet から ★33 フレーム目★（予測 31 ± 2 = 当たり）。★log の fight の欄 = True（33 フレーム全部）★ → ★SetLive 説（fight False のまま描く）は外れ★。戻し = ★1.1841 / 1.73（68 %）★（予測 1.12〜1.16 = 小さく外れ: 最初のフレームで既に 0.144 = 前の沈みの手から 受けへ戻り切っていなかった残り, hold frame 191 の lift 0.0025・side 0.0080 も同じ残り）。★描きに渡った竿の根元（fight frame 33）= (−0.350, 1.018, 1.780)★（握り 0.267 を含む = 予測の「fight True なら握り 0.26 前後」当たり）。手元（−0.400, 0.750 ＋ 0.30, 1.236）まで z で あと 0.54 m、受けの位置の根元 z 2.960。
  - ★R1 vs R2 の live_08 = 0 px、R1 vs ed4fe86 の regress の live_08 = 0 px★ → 当たり（決まっている）。
  - ★(c) 帯（frame, 窓 1 倍, TipSettle なし）★: +6 back 0.360（予測 0.31〜0.36 当たり）・+15 0.7151（予測 0.68〜0.71 = 0.005 外れ）・+30 1.1144（予測 1.09〜1.12 当たり）、+0・+60・+90 は log の 400 行の上限に達して行が無い（上限は 沈みの手の frame も数えた = 私の上限の選びの誤り）。画（strip_frames.png）: ★+30（戻し 64 %）でも 竿は 受けの近くに小さく見え、+60・+90 で 左下の手元へ★。
  - ★「64 % 戻ればほぼ手元のはず」と画のずれの訳（計算, 推論）★: 画の大きさと位置は 目からの深さ z に反比例 = 根元の z が 2.96 → 1.78（68 % 戻り）でも 画で見える竿は 深さ 1.78 m の所 = 手元（z 1.24）より 1.4 倍遠い → 画の動きは 最後の 0.5 m で大きい（+30 → +60 で 竿が下へ大きく動くのと同じ）。= ★live_08 は アワセの 33 フレーム（0.55 s）後 = 竿は手元へ 68 % の距離で 画ではまだ受けの側に見える 形★。
  - ★次（PRESIDENT の判断）★: SetLive 説は外れ = 撮りの道具は直さない（PRESIDENT 23:7x の条件どおり 止めて報告）。PRESIDENT 23:6x の決め「frame 1 かつ 2 本同じなら 札を書いて 今の撮りのまま基準」は 前提（frame 1）が 33 に替わった = その札の言を「アワセの 33 フレーム（0.55 s）後 = 竿は手元へ 68 %、画では受けの側」に替えて 今の撮りのまま基準にするか、PRESIDENT が決める。
- ★記録（PRESIDENT 23:8x）: SetLive 説の外れ★ = 「画面が替わった step の SetLive が呼ばれず 待ちの 30 フレーム fight False のまま描く」は 私の候補で、PRESIDENT 23:7x も「SetLive 説が当たれば 撮りの道具を直す」と推した = ★log の fight の欄が 33 フレーム全部 True で 外れ★（両方の推しとも外れ, 撮りの道具は直していない）。当たったのは「撮りの frame が 寄せの途中」の方（33 フレーム目・68 %）。
- ★apply の番（PRESIDENT 23:8x GO, boss1 23:35 LOCK）★: 札 = 「live_08（種 26）= アワセの 33 フレーム（0.55 s）後: 竿は手元へ 68 %、画ではまだ受けの側」を LIVE_SWAP_TABLE と sheet に。b763128 の frame log と -ikadaLiveShotFrames は ★env / 引数の時だけ★（RuntimeRod.Hold の s_frameLog = IKADA_ROD_FRAME_LOG == "1"、LiveHost の shotFrames は shotDir があり かつ -ikadaLiveShotFrames がある時だけ埋まり 既定は空 = TryGetValue は false）= 遊びは不変。予測: regress 16/16（live・baseline も PASS、ほかは ed4fe86 と同じ値）。道具 = apply_turn/run.sh。
- ★apply の番の結果（23:35 LOCK, 木 b763128, 出力 = apply_turn/）★: live dry = changed 10・added 0・gone 0・same 23 → ★live apply rc 0★（新 = 源、pre-roddefault_ = 旧の sha の確かめ ok、NOTE の行 3 種）。札は LIVE_SWAP_TABLE.md の末と live_sheet.png の下の帯と NOTE の理由の行に。★mock 12 枚（06・06C・06M・08・P1・P2 × A/B）を shots/player/68f766b_113126 で入れ替え★（旧 = pre-roddefault_<名>、源 = shots/player/ed4fe86_231608、sha 前後の確かめ ok、NOTE の 12 行）、★PIN は不変★（pin b80715f… regress 506dfab_194806）。
  - ★regress b763128_233732 = 16/16 PASS★（予測どおり）: build・key・pad・hud・edge・tip_size・input 91・atlas・refcheck 11/11・live（3 種 logic sequence = baseline・画 0 px）・player_shots 26/26・editor_shots 26/26・editor_repeat・compare（max 0.24 %）・git_clean（0/0/0）・baseline（26/26 組 0 px）。FREE 前 Unity・player・VBCS 0。master への merge は boss1。

## §7.41 控え: 撮りで穂先のばねを止めている（-ikadaTipSettle）— 揃え方の案・予測・替わる基準・費用（PRESIDENT 00:0x, ★既定は替えない, Unity なし★）
- ★今の形（source, master 0b53e4a）★: TipBendLayer.SettleForShots = 引数 -ikadaTipSettle か env IKADA_TIP_SETTLE=1（TipBendLayer.cs:90-92）→ Apply で Step（ばねを dt 進める）の代わりに Settle（その時の張力の釣り合いへ跳ぶ, :100, TipModel.cs:58-62）。★渡している所 = 3 つ（grep）★: (1) tools/live_regress.sh:78 = live の撮り（regress の live 3 種）(2) tools/regress_all.sh:203 = player の mock の撮り（-ikadaShot と一緒）(3) tools/trace04.sh:21（調べの道具）。editor は dt 0 で いつも Settle（:100 の dt <= 0）。遊び = どれも無い = ばねは動く。入れた訳（TipBendLayer.cs:86-89 の注）: 「08 の player の 2 枚が 同じ build で 955 px 違った（13:2x）」= その頃は 撮りの時計が固定でなかった（ShotClock = captureFramerate 60 は 後 19:5x で入った, regress_all.sh の注）。
- ★ばねの数（TipModel.cs:22-27, 柔らかい穂先 = 既定）★: K 80 N/m・Fn 3 Hz・ζ 0.15 → 揺れの包絡の τ = 1 / (ζ · 2π · Fn) = ★0.354 s★、残り 1 % = τ ln 100 = ★1.63 s（98 フレーム）★（硬い穂先 Fn 5・ζ 0.10 → τ 0.318 s・1.47 s）。
- ★大事な source の事実（§7.40）★: live の画面の撮り Shot(id) は 撮る前に 30 フレーム待ち、その間 logic は止まる（LiveHost.cs:457-460）= ★張力は一定のまま 描きだけ進む★ = ばねは その一定の張力の釣り合いへ 自分で落ち着いてゆく（30 フレーム = 0.5 s で 揺れの残り e^(−0.5/0.354) = ★24 %★）、竿の戻し（τ 0.5）は 0.5 s で 残り 37 %。
- ★案（推奨 1 つ = C）★:
  - A 今のまま（撮りは Settle、遊びは ばね）: 費用 0。差 = 撮りの穂先は いつも釣り合い・遊びは 張力が替わるたび 3 Hz で 揺れて 1.6 s で落ち着く。記録だけ。
  - B live の撮りから -ikadaTipSettle を外すだけ: 撮りは 30 フレームの所の ばね（残り 24 % の揺れ）= 遊びと同じ道。撮りの時計は固定 = 2 本で同じ画（決まっている）見込み。替わる基準 = 張力が替わった直後の画（live_06・06C・08 の穂先と 窓の穂先）。mock（-ikadaShot）は 外さない（mock = 静止の約束 = PRESIDENT 23:5x の線）→ 外すと player の mock と editor（dt 0 = Settle）の compare が 08 で開く見込み（§7.38 の握りと同じ形）。
  - ★C 撮りの時刻をずらす（推奨）★: live の撮りの待ちを 30 → ★139 フレーム★（竿の戻し τ 0.5 の 残り 1 % = 2.30 s と ばね τ 0.354 の 残り 0.14 % の 大きい方）にし、live の撮りから -ikadaTipSettle を外す（mock は今のまま Settle）。待つ間 logic は止まる = 張力一定 = ばねも 竿の戻しも ★遊びと同じ式のまま 落ち着いてから撮る★（撮りだけの道は 待ちの長さ 1 つ = 道具の側, 遊びの code は不変 = PRESIDENT 23:3x「時刻をずらす」と同じ形）。
- ★C の予測（動かさない, 回すのは boss1 の合図の後）★:
  - 穂先: 139 フレームの後の ばね = 釣り合い × (1 ± 0.0014) = Settle とほぼ同じ → ★穂先の画の差 = 1 px 以下（窓の中の穂先・主の画の穂先）★、live_06・06C は 竿も受けのまま = ★0〜数十 px の差（穂先の縁の 1 px の揺れ程度）★。
  - ★live_08（種 26）= 竿が手元へ戻り切る（戻し 残り < 1 %）★ = 今の札「33 フレーム・68 %・画では受けの側」から「落ち着いた手元」へ = ★大きく替わる（数万 px）★、札を書き替え。mock の 08（editor・player）とは 張力・角度が別なので 同じ画ではない。
  - 2D の画面（live_03・04・05・07・J）= 0 px（待ちの長さは 2D の画を替えない、logic 止まり = 並びも同じ）。logic sequence（RESULT の page / screens）= 不変。
  - ★2 本で 0 px（決まっている）★を 対照に（撮りの時計は固定）。
- ★替わる基準の list（C）★: player_live の 3 種の live_06・live_06C（数 px）・種 26 の live_08（大）＝ live の差し替え 最大 7 file（3 種 × 06・06C ＋ 08）、mock 26 枚は替わらない（mock は Settle のまま）。PIN は替えない（mock の基準は替わらない）。
- ★費用（見積り）★: code = LiveHost.Shot の待ちの数を 引数（例 -ikadaLiveShotHold 139, 既定 30 = 今と同じ）にする 数行 ＋ tools/live_regress.sh の引数（-ikadaTipSettle を外し -ikadaLiveShotHold 139 を足す）= tools の変更（regress の道具 = boss1 / worker2 の物に触る → 所有者の確認が要る）。時間 = 1 枚あたり +109 フレーム（1.8 s）× 約 9 枚 × 3 種 ≈ ★+50 s / regress★。番 = Unity 1 回（作り ＋ live 3 種 × 2 本 ＋ dry）＋ 差し替え（最大 7）＋ regress 1 回。
- 推しの訳: B は 撮りが 遊びの「揺れの途中の 1 枚」になる = 基準が 30 フレームの所の 揺れの位相に縛られ 小さな替わり（張力の 1 step）で 画が大きく動く = 変化を見つける器として弱い。C は 落ち着いた形 = 遊びの式のまま 決まった 1 枚（live_08 の札の「寄せの途中」も消える）。

## §7.42 案 C の code（PRESIDENT 00:2x GO）— 撮りの待ちを引数に（Unity なし = 未 compile）
- code = ikada-unity-track3 ★track3/shot-hold fe3f1d7★（master 0b53e4a ＋ LiveHost の 1 file +8/−1）: test だけの引数 ★-ikadaLiveShotHold n（1〜600, 既定 30 = 今と同じ）★ = Shot が 撮る前に待つフレーム数（待つ間 logic は止まり 描きは進む）。日誌の 2 枚目以降（2D）の待ちは 30 のまま。遊び・mock の撮り・editor は 不変（引数がなければ 30）。
- ★触らない物（PRESIDENT 00:2x）★: tools/live_regress.sh（worker2 の物, boss1 が所有者の確認中 = 返事まで触らない）、tools/regress_all.sh:203 と tools/trace04.sh の -ikadaTipSettle。
- ★表に 1 行: mock の撮り（regress_all.sh:203, -ikadaShot と一緒）の -ikadaTipSettle は残す = mock は 手で置いた値の静止画と最初から決めてある（PRESIDENT 23:5x）= ばねを止めるのは mock の定義どおり、live の「撮りと遊びの差」とは別の理由★。trace04.sh は 調べの道具（基準を作らない）なので残す。
- live_08（種 26）の札 = C の後は ★「落ち着いた手元」★（アワセの 139 フレーム（2.3 s）後, 竿の戻し 残り < 1 %, 穂先のばね 残り 0.14 %）に書き替える（差し替えの番で）。
- 予測は §7.41 に登録済（動かさない）: 穂先 1 px 以下・live_06・06C ほぼ不変・種 26 の live_08 は竿が手元へ・2D と logic の並び 不変・2 本で 0 px・替わる基準 live 最大 7・mock 26 と PIN 不変・regress +50 s。live sheet は 1 枚ずつ。
- 番（Unity は boss1 の合図まで起こさない）: Roslyn fe3f1d7 → 作り → live 3 種を「regress の引数 − -ikadaTipSettle ＋ -ikadaLiveShotHold 139」で 2 本ずつ（私の draft の run.sh で、live_regress.sh は触らない）→ 今の基準と比べ・2 本の一致・live sheet 1 枚ずつ → live_regress.sh の引数の替え（所有者の GO の後）→ 差し替え → regress。
- ★worker2（所有者）の GO と注文 5 つで 直した（00:2x）★: code = track3/shot-hold ★aa95036★（引数の名を ★-ikadaLiveShotWait <n>（整数 ≥ 1, 既定 30）★ に、Shot の 2 か所 = 画面の撮りの前（:496）と 日誌 J の頁ごと（:516）を ★同じ値 ShotWaitFrames() で揃える★（入れ子の coroutine にせず ふつうの loop = 既定 30 の時 frame が前と同じ）、★[Live] start の行に shotWait=<n>★）＋ ★f7af1d2★（tools/live_regress.sh:78 の ARGS から -ikadaTipSettle を外し -ikadaLiveShotWait 139 を足す だけ, 種・画面の列は不変, 注 2 行）。ほかの呼び手（regress_all.sh:196 → live_regress.sh / trace04.sh / live_press_shot.sh / drafts の script）は 既定 30 で不変。fe3f1d7 の -ikadaLiveShotHold は aa95036 で置き換え（名は残っていない, grep 0）。
- ★予測の足し（§7.41 は動かさない）★: 日誌 J の頁も 139 フレーム待つ = 2D の画 = 0 px（待ちは 2D の画を替えない）・時間が 1 頁 +1.8 s。[Live] start の行に shotWait=139（新）・30（旧の引数）。
- ★番（Unity は PRESIDENT の返事まで起こさない）= shotwait_turn/run.sh★: Roslyn f7af1d2 → 作り → ★(5) 陽性対照（入れる前）: 3 種 × 2 回（新の引数）→ 全部の画 0 px で一致、一致しなければ STOP（入れない）★ → 既定 30 の対照（種 26 を 旧の引数で 1 回 vs 今の基準 = 0 px の予測）→ 新の画 vs 今の基準の表 ＋ 替わった画ごとに 1 枚の sheet（sheets/）。その後（GO の後）= regress 1 回（live_regress.sh の新の引数）→ live_rebase5 の dry ＋ PRESIDENT が画 → apply → regress。
- ★陽性対照の番の結果（boss1 00:31 LOCK, 木 f7af1d2, 出力 = shotwait_turn/）★: Roslyn 0・作り ok（fonts の変わり 0）。FREE 前 Unity・player・VBCS 0（撮り中に出た自分の VBCS 1222254 を kill）、porcelain 0。
  - ★(5) 陽性対照 = PASS★: 3 種（20260925・1・26）× 2 回（新の引数, [Live] start に shotWait=139）の 全部の画 21 枚 = ★0 px で一致★、RESULT も同じ（steps 540682・539333・539212）、exception 0。
  - ★既定 30 の対照 = 当たり★: 種 26 を旧の引数（-ikadaTipSettle, shotWait=30）で 1 回 vs 今の基準 = ★8 枚全部 0 px★ = 既定は前と同じ。
  - ★新 vs 今の基準（表）★: 2D（live_03・04・05・07・J・J_p2）= ★0 px★（当たり）。live_06C = 9・1・14 px（窓の穂先の線, x 288〜417・y 282〜296）= ★当たり（穂先 1 px 以下の揺れ）★。★種 26 の live_08 = 32,114 px★（竿が手元へ戻り切る, 当たり）。★live_06 = 24,031・24,027・24,015 px（3 種とも）= ★外れ（予測「ほぼ不変」）★。訳（log の実測）: live_06 は ★落とした直後（[RodHand] hand (sinking) at drop TimeS=5.517 → 06 → 撮り t=5.52）= 竿は手（沈み）★で、待ち 30 では 手元へ戻りの途中（受けの所に小さく）、待ち 139 では 手元に戻り切る（sheet: 右で 竿が左下の手元・穂先下げ）。私は 06 を「受けに置いた待ち」と思い込んだ（live の 06 の撮りの時の 手の状態を log で見ていなかった）。
  - ★替わる基準 = live 7 file★: live_06 × 3 種・live_06C × 3 種・live_08（種 26）。★数（上限 7）は予測と合ったが 中身の予測（06 は ほぼ不変）は外れ = 当たりとは数えない★（PRESIDENT 00:8x: 数が合ったを当たりと書かない）。mock 26・PIN は不変（mock の撮りは触っていない）。
  - sheet（左 = 今の基準 TipSettle・待ち 30 ｜ 右 = 案 C）= shotwait_turn/sheets/ の 7 枚: 20260925_live_06・20260925_live_06C・1_live_06・1_live_06C・26_live_06・26_live_06C・26_live_08。
  - 次（GO の後）: master へ shot-hold を入れる（--no-ff は boss1）→ regress 1 回（live は FAIL = 差し替え待ち 7）→ live_rebase5 の dry → PRESIDENT が画 → apply（live 7、札: live_08 = 落ち着いた手元、live_06 = 落とした後 手元で沈みを待つ）→ regress 16/16。
- ★記録（PRESIDENT 00:8x）★: (1) live_06 の外れ = ★撮りの時の手の状態を log で見ずに置いた予測の外れ★（06 を「受けに置いた待ち」と思い込んだ, 実は 落とした直後の手 = 沈み）。★次から: 画の予測の前に その画の撮りの時の状態（手 / 受け / ファイト・張力）を log で 1 行 引いて書く★。(2) ★数の上限が合っても 中身が外れたら 当たりと書かない★（§7.42 の 7 の行を直した）。
- ★apply の番（PRESIDENT 00:8x GO, boss1 00:40 LOCK, 枝 track3/shot-hold f7af1d2）★: regress（源, live は差し替え待ち 7 で FAIL の予測）→ live_rebase5 の dry（changed 7 の予測 = live_06 × 3・06C × 3・08 種 26）→ apply（札 live_06 = ダンゴを落とした後 手元で沈みを待つ・live_08 = アワセの後 落ち着いた手元, 旧は pre-shotwait_<名>, sha 前後, NOTE）→ regress 1 回（★16/16 の予測★）。★この画の撮りの時の状態（log, shotwait_turn/new_26_a/live.log）★: live_06 = [RodHand] hand (sinking) at drop TimeS=5.517 → 06 の撮り t=5.52（手・沈み）、live_06C = 札の画面（受け = 06C の撮り（log 477 行）は 最初の [RodHand] の行（479 行）より前 = 始めの Rest のまま）、live_08 = [RodHand] hand at HookSet TimeS=792.399（ファイト）。遊べる版は作らない（遊びの code 不変）。mock と PIN は替えない。
- ★apply の番の結果 = 歯止めで STOP（apply していない）★（00:41〜00:55, 木 f7af1d2）: regress 1（f7af1d2_004153）= ★15/16★（live だけ FAIL = 差し替え待ち, 予測どおり）。live_rebase5 の dry = ★changed 13・added 0・gone 0・same 20★ → 私の歯止め「changed 7 でなければ apply しない」で STOP（基準の dir に pre-shotwait_ は 0 件 = 何も動いていない）。★13 = 画 7（live_06 × 3・06C × 3・08 種 26 = 予測の 7 と同じ顔ぶれ）＋ live.log × 3（前の apply でも changed）＋ ARGS.txt × 3（引数が替わった = -ikadaTipSettle → -ikadaLiveShotWait 139）★。★外れ = 予測の「changed 7」は png だけを数え、live_rebase5 が 替える file（png・live.log・ARGS.txt・RESULT.txt・AUDIO.txt）を数えなかった★（RESULT・AUDIO は same = logic と音は不変, 観測）。FREE 前 Unity・player・VBCS 0。次 = changed 13（画 7 ＋ live.log 3 ＋ ARGS.txt 3）での apply の GO を boss1 へ。
- ★予測の外れの記録（boss1 00:56）★: dry の予測「changed 7」は ★png だけを数え、live_rebase5 が替える file（png・live.log・ARGS.txt・RESULT.txt・AUDIO.txt）を数えなかった★（13 = 画 7 ＋ live.log 3 ＋ ARGS.txt 3）。次から: 差し替えの数の予測は その道具の替える file の種類ごとに書く。
- ★apply の前の live.log の diff（boss1 00:56 の条件, 3 種, 基準 vs f7af1d2_004153）★: ★logic の行（[Live] screen・RESULT・shot・handover・press、[RodHand]、[Cast]、[Landing]）= 3 種とも 0 行の差★（240・248・260 行 同じ）。[Live] start の行 = 末に shotWait=139。ほかの差（種類と行数, apply2_turn/livelog_diff_kinds.md）: [Stage2Hud] tide / strip（frame= の欄）・[TmpFlags]・[Prep07]（frame=）・[Catenary]・[ClutchWire]・[Audio]・[Ambient] の RESULT（frame の数）・[FrameGap]・Vulkan PSO の行（1 行増え = 行数 +1 の訳）・Processor の行（CPU の MHz）＝ 待ちの frame の数と環境。★ただし frame の数でない 描きの値も替わる★: [RodHolder] dip（例 種 26: frames 34 → 143 と 同時に dy・lift・side の値, その後の dip も 竿の描きの続きで 値が少し違う）・[RodHolder] placed・[FishSurface] shown の画の位置（x 1002.5 → 991.2 = 糸が穂先の位置に付いてくる）= ★どれも描きの側（logic でない）だが 条件の字「待ちと frame の数だけ」には外れる★ → apply せず止めて報告（PRESIDENT / boss1 の判断待ち）。
- ★案 C の差し替えの結果（boss1 01:0x GO）★: live apply 00:58:40 = changed 13（画 7 ＋ live.log 3 ＋ ARGS.txt 3）、新 = 源・旧 = pre-shotwait_ の sha 確かめ ok、NOTE の行（札 live_06・live_08 ＋ livelog_diff_kinds.md を指す）、PIN 不変（中身 = worker2 23:52 の書き直し b763128_233732）。★regress f7af1d2_005840 = 16/16 PASS★（予測どおり; live 3 種 logic sequence = baseline・画 0 px、baseline 26/26 0 px、compare max 0.24 %、git_clean 0/0/0）。live.log の差の判定（PRESIDENT 01:1x）: tide・strip・advice = frame だけ、Catenary max_view_sag は通す、[Audio]/[Ambient]/[TmpFlags] = 陽性対照の 2 本の間でも違う = 揺れ → 通す（apply2_turn/livelog_diff_kinds.md）。FREE 前 Unity・player・VBCS 0。merge（track3/shot-hold f7af1d2 → master）は boss1。

## §7.43 依頼者の c201 の答え（PRESIDENT 01:5x）— 手・沈みの 穂先が大きく見える画（★画だけ, 既定は替えない★）: code と予測（撮りの前, 動かさない; Unity なし = 未 compile）
- 依頼者（要点）: 手に持つ時・沈むのを待つ時の穂先が変？ この画では分かりづらい／沈み待ちは 竿尻を高く 穂先を水面へ垂直近くに持つことが多い／アワセの前に送る動作がある。★構え（竿尻を高く・穂先を垂直）と 送り は PRESIDENT が依頼者に確かめてから = まだ着手しない★。
- code = ikada-unity-track3 ★track3/side-shot 7327e8c★（master 13ac877 ＋ 2 file +29）: 撮りだけの env ★IKADA_SHOT_ROD_SIDE=1★ = main camera を 竿の左（竿の水平の向きに直角）・竿の真ん中から 4.2 m・fov 45°、竿の根元と穂先（★RuntimeRod.LastButt（新, このフレームの描いた根元）と LastTip★ = 手の動きの後）と 水面（y 0）が 1 枚に入る。塗った板と穂先の窓は消し 3D の甲板（寄りと同じ）。log に butt・tip・pitch。★ゲームの画角ではない★。既定は不変。
- ★この画の撮りの時の状態（log で 1 行, §7.42 の記録の規律）★: editor の 06 ＋ IKADA_ROD_SHOT_HOLD=hand / sinking（§7.34 の env）= mock の 06（待ちの snapshot, 張力 約 0.2 N・RodAngleRad 0 の見込み）の上で 手の状態だけ置く = ★live の「落とした直後」と同じ手の式（戻し・横・上げ・沈みの下げ）、張力は mock の値★。
- ★札にする今の値（source の行）★: 竿の根元の高さ = 甲板 0.45 ＋ 0.30 = 0.75 m（BackdropBuilderProps.cs:222 h = DeckTopY + 0.30）＋ 手の上げ 0.05 m（RuntimeRod.Hold.cs:96 HandLiftM）= ★0.80 m★。横 = 受けの大きさ ＋ 0.02 = ★0.158 m★（Hold.cs:134 Rest2SideMarginM・SideTarget）。手では 受けの所から ★1.73 m 手元へ戻す★（restForwardM, §7.36）。沈みの下げ = ★HandDipRad 0.10 rad（5.7°）★ = 竿尻のまわりに穂先を下げる（Hold.cs:61・:96）。竿の長さ 3.09 m（実 1.5 m × 2.06, BackdropBuilderPlacement.cs:31）。穂先の窓（TipBendLayer）は 竿の角を −0.15〜0.35 rad に clamp（13 l.185）。
- ★予測（計算 = §7.30 の写像; 動かさない）★:
  - 段 1 ゲームの画角: 手 = 穂先 画 ★(967, 624)★・竿尻 画の下の外（742, 1100）、沈み = 穂先 ★(967, 705)（81 px 下）★。穂先の窓: 手 = 竿の角 0 の形、沈み = 窓の竿の角 −0.10 rad。
  - 段 2 穂先の周り 3 倍（段 1 から 640 × 360 を切り出し）: 穂先・トップガイド・下りる糸（3 mm）が見える、沈みは 穂先が下がった分 下に。
  - 段 3 横から（IKADA_SHOT_ROD_SIDE=1, HUD なし）: ★手 = 竿は水平（pitch 0.0°）、竿尻・穂先とも 水面の上 0.80 m★、穂先から糸が ほぼ真下へ。★沈み = pitch −5.7°、穂先 水面の上 0.49 m、竿尻 0.80 m★。= 依頼者の言う「竿尻を高く・穂先を水面へほぼ垂直」（例 −60〜80°）とは ★大きく違う（今は ほぼ水平）★ = その差が画で分かる。log の pitch = ★0.0 / −5.7 ± 0.2★。3D の甲板は §7.29 の寄りと同じく 板の面が出ない恐れ（記録の外れ）= 横の画の甲板は見えにくい見込み（竿と水面の判断には効かない）。
  - 4 枚 exception 0、porcelain 0。画 = c202（ls で確かめた: c202〜c209 は空き）= 状態ごとに 段 1〜3、見出しは依頼者の言葉、段 3 に「ゲームの画角ではない（横から見た図）」、札に上の値。
- ★結果（boss1 08:52 LOCK, 木 7327e8c, 出力 = side_turn/）★: Roslyn 0、4 枚 rc 0・exception 0、porcelain 0、FREE 前 Unity・player・VBCS 0（撮り中に出た自分の VBCS 1424201 を kill）。
  - ★log の pitch = 手 0.0°・沈み −5.7°★（[Shot] rod side: butt (−0.242, 0.800, 1.222) tip (0.027, 0.800, 4.301) / (0.026, 0.491, 4.286)）→ ★予測と一致（当たり）★。ゲームの画角の穂先の世界の点も 予測と同じ。
  - ★外れ（私の camera の置き方の誤り）★: 横の 2 枚に 竿が写らない = camera の高さを「水面と竿の真ん中」= 0.40 m にした → 甲板の上面 0.45 m より下・x −4.29 は筏の上 = ★甲板の中から見た画（茶の板と梁の面だけ）★。直し = ★cf22288★: camera の高さ = max(竿の高い端 ＋ 0.30, 甲板 ＋ 0.50)（= 1.10 m）、見る点は 竿と水面の真ん中のまま（少し見下ろす）。撮りだけ、未 compile。
  - ★直しの予測（動かさない）★: camera (−4.29, 1.10, 3.13)・見下ろし 約 9°。★竿が 横向きに全長（竿尻 z 1.22 〜 穂先 z 4.30）、手 = 水平、沈み = 穂先が 5.7° 下がる★、穂先の先は 甲板の縁（z 3.94）の外 = その下に水面と下りる糸。甲板（BuildDeckForShot）は §7.29 と同じく 板の面が出ず 細い筋の恐れ（竿と水面の判断には効かない）。log の pitch は 0.0 / −5.7（7327e8c と同じ）。
  - 次の番: side_turn/run2.sh = Roslyn cf22288 → 横の 2 枚だけ（ゲームの画角の 2 枚は 7327e8c の撮りを使う = 直しは横の camera だけ）→ c202。
