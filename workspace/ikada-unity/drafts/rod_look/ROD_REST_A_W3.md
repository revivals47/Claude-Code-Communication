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
- ★撮り直しの結果（boss1 08:56 LOCK, 木 cf22288）★: git diff 7327e8c cf22288 = ★Assets/Editor/ShotRunner.cs の 1 file だけ（+4/−1, 横の env の camera の高さ）= 遊びの code は同じ★ → ゲームの画角の 2 枚は 7327e8c の撮りを使う。Roslyn 0、横の 2 枚 rc 0・exception 0、porcelain 0、FREE 前 Unity・player・VBCS 0（撮り中に出た自分の VBCS 1429226 を kill）。★log の pitch = 手 0.0°・沈み −5.7°（7327e8c と同じ, 当たり）★。★画: 竿が横向きに全長写る（手 = 水平、沈み = 穂先が下がる）★ = 直しの予測どおり。甲板は 板の筋と その間に水（§7.29 と同じ形, 予測の恐れどおり）、竿は画の上の方に小さめ（見下ろし）→ c202 では 竿の帯を切り出して拡大。
- ★c202 = drafts/user_review/c202_rod_tip_hand_sinking.png★（手に持つ時・沈むのを待つ時 × 左 = 遊ぶ時の画面・中 = 穂先の周り 3 倍・右 = 横から見た図（ゲームの画角ではない）、札 = 今の値）。

## §7.44 依頼者の c202 の答え（PRESIDENT 09:0x）— 穂先のカクン / 左への平行移動 = 不具合として 測る（★code の既定は替えない, log から★）: code と予測（撮りの前, 動かさない）
- 依頼者: 穂先がカクンと曲がって見える（特に 中 = 3 倍）、穂先が竿に対して 少し左に平行移動している、とも言える。
- code = track3/side-shot ★dfa2b29★（cf22288 ＋ ShotRunner.cs だけ +29）: 撮りだけ・log だけの env ★IKADA_SHOT_TIP_JOINT=1★ = 撮りの時に [TipJoint] の 1 行 = 竿の本体の 最後の active な piece の両端と軸・穂先の層（TipBendLayer）の 最初の piece の両端と軸・その base の最初の点（中心線の cut）・★ずれ（穂先の始め − 本体の終わり）を 竿の向き / 右 / 上 に分けて m で★・軸の角の差（上下・左右）・太さ 2 つ・画の点。何も動かさない。
- ★source の読み（推論ではなく行）★: 本体 = RuntimeRod.DrawUpTo(Resample(centre), CutArcM(centre))（RuntimeRod.cs:210, :362-）、穂先の層 = tipLayer.SetBaseFromCentre(centre, entry)（:238 → TipBendLayer.cs の basePoints = 同じ centre の cut から先）＋ Apply で ばねの下げ（pts = basePoints ＋ deflection）。= ★両方とも 同じ centre（手の 戻し・横・上げ・沈みの下げ を入れた後の _butt / _tip から RodBend で作る）を読む★。本体の piece は 区の中で 太さの半分だけ 重ねて延ばす（:381-384 ext）。BlankToCut（BackdropBuilderTip.cs:62）は runtime の竿では作らない（lastPieces == null）。
- ★この画の撮りの時の状態（log の規律）★: editor の 06 ＋ IKADA_ROD_SHOT_HOLD=hand / sinking（mock の 06, 張力 約 0.2 N）、対照 = 06（受け, env なし）・06C（受け）。
- ★候補（予測として書くだけ, 決めるのは log）★:
  - C1 手の横 0.158・上げ 0.05 が 本体にだけ掛かり 穂先の層に掛からない → ずれ side ≈ −0.158 m（左）・up ≈ −0.05、受けでは 0。★source の読みでは 両方 同じ centre = この候補は起きない見込み★。
  - C2 沈みの下げ（−0.10 rad）が 本体にだけ → 沈みで 穂先の軸が 本体より 約 +5.7° 上、手・受けでは 0。★同じく 起きない見込み★。
  - C3（★主の予測★）= 両方とも同じ centre → ★ずれ ≈ 本体の延ばし ext の分だけ（along ≈ −dia/2 = 約 −0.003 m, side ≈ 0, up ≈ 0）、軸の角の差 = ばねの下げの分（mock 0.2 N, TipSoft ×2 → 1° 未満 下）★、手・沈み・受けで ほぼ同じ。
  - C4 ★太さの段★: 本体の最後の piece の太さ（床 1.5 px を 竿に直角で 前に出した位置で焼いた, §7.36 の 1.4 倍）と 穂先の層の最初の piece の太さ（s_tipMinCut = 同じ床だが 別の式で焼く）が 違う → 継ぎ目で 太さが段に替わり 輪・ガイドと重なって カクン / 横ずれに見える。手（竿が手元へ近い）で 段が大きく見え 受け（遠い）で小さい（推論）。log の dia 2 つで分かる。
  - C5 それ以外（H4）。
- 撮り（4 枚, 06）: TJ_hand・TJ_sinking（SHOT_HOLD）・TJ_rest06（env なし）・TJ_rest06C（06C）、全部 IKADA_SHOT_TIP_JOINT=1。exception 0・porcelain 0。
- ★番 4（boss1 09:1x）の段取り★: 番 1 で ずれが見つかり 直しが小さければ 直しを env の後ろ（既定 OFF）に置き、c203（沈み待ちの構え 候補 3 つ × c202 と同じ 3 段, 値は boss1 から）は 直しを ON で撮る。ずれが無ければ そのまま c203。番 4 の env（沈み待ちの構えだけ 試しの値: 竿尻の高さ・角）は 値を受けてから。
- ★結果（boss1 09:10 LOCK, 木 dfa2b29, 出力 = tipjoint_turn/）★: Roslyn 0、4 枚 rc 0・exception 0、porcelain 0、FREE 前 Unity・player・VBCS 0（撮り中に出た自分の VBCS 1438541 を kill）。
  | 画 | ずれ along / side(+右) / up（m） | 軸の角の差 | 太さ 本体 / 穂先 | 継ぎ目の画の点 本体の終わり → 穂先の始め |
  |---|---|---|---|---|
  | 手（06） | 0.0000 / ★−0.0333★ / 0.0000 | 0.00° | 0.0073 / 0.0074 | (957.0, 643.9) → (944.1, 643.7) = ★左へ 12.9 px★ |
  | 沈み（06） | 0.0000 / ★−0.0333★ / 0.0000 | 0.00° | 0.0073 / 0.0074 | (956.6, 721.9) → (943.7, 721.6) = ★左へ 12.9 px★ |
  | 受け（06, 対照） | 0 / 0 / 0 | 0.00° | 0.0073 / 0.0074 | (955.8, 619.7) = 同じ |
  | 受け（06C, 対照） | 0 / 0 / 0 | 0.00° | 0.0073 / 0.0074 | (955.8, 619.7) = 同じ |
  - ★どの候補か = C5（予測した C1〜C4 のどれでもない）★: 手・沈みで 穂先の層が 本体の終わりから ★横（左）へ 0.0333 m だけ平行にずれる★（向き・上下・角・太さは同じ）、受けでは 0 = ★依頼者の「穂先が竿に対して少し左に平行移動」= この 3.3 cm（遊ぶ画面で 12.9 px、c202 の中の 3 倍で 約 39 px）★。「カクン」= その横の段（継ぎ目で穂先が左へずれて続く）。C3（主の予測, ずれ ≈ 0）は 外れ、C4（太さの段）も 外れ（太さ同じ）。
  - ★数の訳（source の行 ＋ 計算, 4 桁で一致）★: 手の横 SideTarget = max(HandSideM, Rest2SideClear() ＋ 0.02)、Rest2SideClear の倍率 sc = dressing != null ? dressing.guideScale : 1（RuntimeRod.Hold.cs:137）。builder は ★rod.ApplyNow() → tipLayer.Apply(0f) → dressing を作る → rod.ApplyNow()（BackdropBuilderProps.cs:292-295）★ = 1 回目の ApplyNow は dressing が無い = 倍率 1 → 横 = max(0.10, 0.1051 ＋ 0.02) = ★0.1251 m★、穂先の層は ここで置かれる（:293）。2 回目は dressing あり = 倍率 2.06 → 横 = 0.1384 ＋ 0.02 = ★0.1584 m★、本体はここで置き直すが ★穂先の層の Apply は呼ばれない★ = 穂先は 0.1251 の所に残る → 差 ★0.1584 − 0.1251 = 0.0333 m★（log の 0.0333 と一致）。受けでは 横 0 = ずれ 0（log と一致）。
  - ★遊び・live では（推論, 測っていない）★: TipBendLayer.Update が 毎フレーム Apply（TipBendLayer.cs:84）= 2 フレーム目から 穂先は 本体の今の centre に付く = ずれは editor の静止の撮り（と遊びの最初の 1 フレーム）だけの見込み。c202 の画は editor の撮り = 依頼者が見たのは この editor の撮りの ずれ。
  - ★直しの案（小さい）★: builder の 2 回目の rod.ApplyNow() の後（:295）に tipLayer.Apply(0f) をもう一度（dressing.ApplyNow の前）= editor の撮りでも 穂先が 本体の今の centre に付く。boss1 09:1x の段取りどおり ★env の後ろ（既定 OFF）★に置き、c203 は ON で撮る。

## §7.45 live の継ぎ目の測り（PRESIDENT 09:5x (2), 先に）・直し（直接）・c203 の code — 予測（撮りの前, 動かさない; Unity なし = 未 compile）
- code（track3/side-shot）: ★6c90269★ = TipJointProbe（1 か所で 継ぎ目を計算 = editor の撮り ShotRunner と 遊び RodDressing.LateUpdate の 2 つの呼び手が 同じ式を読む）、遊びの log = env ★IKADA_ROD_TIP_JOINT_LOG=1★ の時だけ（手・ファイトのフレームごと 1 行, 300 まで, log だけ）、撮りだけの env ★IKADA_SHOT_SINK_POSE=bx,by,bz,tx,ty,tz★（沈みの時の 竿尻と まっすぐの穂先, c203 用）。★bad4d3c★ = builder の置き順の直し（2 回目の ApplyNow の後に tipLayer.Apply(0f), ★env なし・直接★ = PRESIDENT 09:5x）。★live の測りは 6c90269（直しの前）で★、master へ入れるのは その結果の後。
- ★live の予測（source の行）★: 遊びでは 毎フレーム RuntimeRod.Update（order 50）→ TipBendLayer.Update（order 100, :84 Apply）→ RodDressing.LateUpdate（order 150, ここで log）の順 = 本体と穂先の層は 同じフレームの centre を読む、dressing は 作ってある = 横は いつも 0.158。★= 手・ファイトの全部のフレームで ずれ 0（along・side・up とも |·| < 0.0001 m, 角 < 0.01°）、手の続きの最初のフレームも 0★。0.0333 が出うるのは scene を読んだ直後の 1 フレーム（builder が置いた形）だけ = live は 題の画面から始まる = 手のフレームには出ない見込み。★1 フレーム目以外に ずれが出たら 止めて報告★（PRESIDENT 09:5x）。
- 撮り = live_tj_turn/run.sh: track3 を 6c90269 に detach → Roslyn → 作り → 種 26 を live_regress.sh の引数（-ikadaLiveShotWait 139 込み）＋ IKADA_ROD_TIP_JOINT_LOG=1 で 1 本 → [TipJoint] play frame の行を集計（ずれの大きい行の数・手 / ファイトの続きの最初の行）→ track3/side-shot に戻す。
- ★直しの後に動く基準（予測, master へ入れる時）★: mock の撮りは 受け（06・06C・06M・P1・P2）と ファイト（08）= 横 0 = ずれ 0 だった → ★mock の 26 枚は 0 px のまま★（手・沈みの mock の撮りは regress に無い）。live は 遊び = 0 px のまま。= regress は 16/16 のままの見込み、差し替えなし。替わるのは editor の 手・沈みの撮り（c202 の様な 撮りだけの画）だけ = 穂先が 本体に付く（左へ 12.9 px 戻る）。
- c203（①②, 直しの後の builder = bad4d3c で撮る）: ① 竿尻 (−0.400, 1.450, 1.236)（今の手の竿尻の x・z、甲板 ＋ 1.0 m）・穂先 = 竿の向きに 3.09 m・下 25.9° = (−0.157, 0.100, 4.005)、② 竿尻 (−0.40, 1.45, 2.62)・穂先 (−0.16, 0.10, 5.39)（boss1 の値, 長さ 3.09・下 25.9° を検算）。予測は 次の節で（live の結果の後）。
- ★live の測りの結果（boss1 09:17 LOCK, 木 6c90269 = 直しの前, 出力 = live_tj_turn/）★: Roslyn 0・作り ok（fonts の変わり 0）、種 26 1 本 rc 0・exception 0・画 8、[TipJoint] play frame 300 行（上限）。FREE 前 Unity・player・VBCS 0（撮り中に出た自分の VBCS 1445713 を kill）、side-shot bad4d3c に戻した・porcelain 0。
  - ★手（沈み）= 150 フレーム（frame 1〜150, 沈みの続き 5 回, TimeS 5.517・210.521・415.525・620.529・715.531 で始まる）= 全部 ずれ 0（along・side・up 0.0000, 角 0.00°）、各続きの最初のフレームも 0★ → 予測どおり（当たり）= ★c202 の 3.3 cm は editor の撮りだけ、遊びには無い★（log で実測）。
  - ★ファイト = 150 フレーム（frame 151〜300, HookSet TimeS 792.399 から）= ずれ along −0.0004・side −0.0008・★up +0.0014 m・軸の角の差 2.62°★（全部のフレームで同じ）★ → ★予測（全フレーム 0）に外れ = 止めて報告★。
  - ★外れの訳の候補（source の行 ＋ 計算, 推論）★: ファイトでは 竿が曲がる（rodT > 0）。本体の piece = 中心線を PieceFractions で取り直した 点の間の まっすぐの円柱（先の半分は 1 本 約 0.124 m, RuntimeRod.DrawUpTo の b = 弦の上の Lerp, :378）、穂先の層の base = 中心線の上の点（AtArc, TipBendLayer.SetBaseFromCentre）で 1 本 約 0.025 m。= ★曲がった中心線を 長さの違う弦で近似した 継ぎ目の段★: 角の差 2.62° = 0.0457 rad ÷（0.124/2 ＋ 0.025/2 m）→ 曲がり κ ≈ 0.61 rad/m、長さ 0.124 m の弦の垂れ = κ L² / 8 = ★0.0012 m（log の up 0.0014 と近い）★。受け・手では 竿はまっすぐ（rodT 0）= 弦 = 弧 = 0（log と一致）。= 3.3 cm の置き順の不具合とは 別の物（遊びの描きの近似, 画では 約 0.4 px・角 2.6°, 推論）。editor の 08 でも 同じ形が出る見込み（測っていない）。
- ★控え（PRESIDENT 09:7x (2)）★: ファイトの 継ぎ目の弦の段（up 1.4 mm・角 2.62°, 曲がった中心線を 長さの違う弦で近似）は ★置いておく★。依頼者が ファイトで「カクン」を言えば 調べる（本体の先の piece を 穂先の層と同じ細かさにする 等, 推論）。

## §7.46 builder の置き順の直しを既定へ（PRESIDENT 09:7x GO）— mock 0 px の訳・予測・番（撮りの前, 動かさない; Unity なし）
- code = track3/side-shot ★d95bd5a★（master 13ac877 ＋ 6 file +109/−1）: bad4d3c の直し（BackdropBuilderProps.cs の 2 回目の ApplyNow の後に tipLayer.Apply(0f)）＋ 撮りだけ / log だけ（TipJointProbe・横の camera・LastButt・RodDressing の log の呼び）。c203 用の IKADA_SHOT_SINK_POSE は ★d95bd5a で外した★（c203 取り消し, master に入れない）。
- ★mock の基準が 0 px のままの訳（source の行 ＋ 前の log）★: (a) mock の撮り（editor の ShootCycle・player の -ikadaShot）では ★RodHand.State = Rest★（RodHand.cs: 初めの値 s_shotHold = env IKADA_ROD_SHOT_HOLD が無ければ Rest、regress は付けない）→ RuntimeRod.Hold.Rest の ★hand = !fight && (hold != Rest || _lowHeld) = false★（06・06C・06M・P1・P2 = 受け、08 = ファイト = !fight で false）。(b) 置き順の不具合の元 = ★手の横 SideTarget（倍率が 1 回目 1・2 回目 2.06 で違う）は hand の時だけ使う★（_side の目標 = hand ? SideTarget : 0）= 受け・ファイトでは 横 0 で 1 回目も 2 回目も同じ。ほかの centre の元（戻し restForwardM・受けの傾き −5°・editor の握り・下限 = 値そのもの）は 1 回目と 2 回目で同じ = 1 回目で置いた穂先の層 = 2 回目の本体 → 直しても 同じ所に置き直すだけ。(c) ★実測★: §7.44 の editor の [TipJoint]（直しの前の builder）で 受け 06・06C = ★ずれ 0.0000★。（08 の editor の継ぎ目は 測っていない = 弦の段だけの見込み, 直しで替わらない。）→ ★予測 = mock 26 枚 0 px・live 0 px・regress 16/16・差し替えなし★。
- ★直しの確かめ（同じ番, editor の [TipJoint]）★: 手・沈み = ★side −0.0333 → 0.0000★、継ぎ目の画の点 本体の終わり = 穂先の始め（今 957.0 → 944.1 の 12.9 px の段が 0 に）。08（ファイト）= 弦の段（up 約 1 mm・角 約 2〜3°）だけ。
- 番 = tipfix_turn/run.sh（Roslyn d95bd5a → regress 1 回 → editor の 手・沈み・08 の [TipJoint]）。mock の画が動いたら 止めて sheet を 1 枚ずつ（PRESIDENT 09:7x）。
- ★予測の直し（boss1 09:24, 走らせる前）★: master 13ac877 には refcheck-auto が入っている = pin b80715f が基準の PIN と同じ = ★refcheck は SKIPPED★ → regress の数の予測は ★PASS 15/16・SKIPPED 1★（16/16 とは出ない, worker2 01:13 の訂正と同じ形）。ほか（mock 26・live 0 px、差し替えなし、手・沈みの継ぎ目 0）は そのまま。
- ★結果（boss1 09:24 LOCK, 木 d95bd5a, 出力 = tipfix_turn/）★: Roslyn 0。★regress d95bd5a_092436 = PASS 15/16・SKIPPED 1（refcheck = auto: pin b80715f = 基準の PIN）★ → 直した予測どおり。★baseline 26/26 組 0 px・live 3 種 画 0 px・logic sequence = baseline・compare max 0.24 %・git_clean 0/0/0 = 差し替えなし★ → 当たり。FREE 前 Unity・player・VBCS 0、porcelain 0。
  - ★直しの確かめ（editor の [TipJoint]）★: 手 = side 0.0000・up 0.0000・角 0.00°・継ぎ目の画の点 (957.0, 643.9) = 本体の終わり = 穂先の始め、沈み = 同じく 0・(956.6, 721.9) → ★当たり（−0.0333 → 0, 12.9 px の段が 0）★。
  - 08（ファイト, editor）: side −0.0013・★up +0.0024 m・角 4.29°★・画で 約 1.1 px → 弦の段の形は予測どおりだが ★大きさは外れ（予測 up 約 1 mm・角 2〜3°）★。訳（推論）: mock の 08 の張力 3.8 N（live のファイトの最初の 約 1 N より大きい）= 竿がより曲がる = 弦の段も大きい。置いておく（§7.45 の控え）。
  - master への merge（track3/side-shot d95bd5a）は boss1。遊べる版は 遊びの code が替わらない（builder の editor の置き順・撮りと log の道具だけ）= 作らない見込み（PRESIDENT の判断）。
- ★記録（boss1 / PRESIDENT 09:8x, merge 済 b34cd9c の後）★: mock の撮りは builder の 2 回の ApplyNow を ★通る★ = editor の mock（ShotRunner.cs:25・:77 SceneBuilder.Build(id, …) → 3D の画面は SceneBuilder.cs:55 Backdrop(cam) → :88 BackdropBuilder.Build → BackdropBuilder.cs:107/114/121 BuildRod → ★BackdropBuilderProps.cs:292 rod.ApplyNow → :293 tipLayer.Apply → :295 rod.ApplyNow★（:299 = 直しの tipLayer.Apply））、player の mock も 作りの時に 同じ道で scene を作る（BuildScript.cs:178 SceneBuilder.Build(id, false, true)）＋ 遊びの Update で 毎フレーム 穂先を置き直す（TipBendLayer.cs:84）。通るが ★mock は手ではない = 横 0 = ずれの元が 0★（§7.46 の (a) RodHand.State = Rest → hand = false、(b) 横 SideTarget は hand の時だけ・ほかの centre の元は 1 回目と 2 回目で同じ、(c) 実測 = 直しの前の editor の [TipJoint] で 受け 06・06C ずれ 0.0000、と regress d95bd5a_092436 の mock 26 組 0 px）。

## §7.47 沈みの構え A の下ごしらえ（PRESIDENT 10:0x）: code と予測（撮りの前, 動かさない; Unity なし = 未 compile）
- code = ikada-unity-track3 ★track3/sink-prep 68507ec★（master b34cd9c ＋ 7 file +60 前後）。道具の側（regress_all.sh の 26 の字 → ids の数・compare の ids・baseline_pin.sh・新しい基準の dir）は 所有者 worker2 の枝 = ★2 つの枝を合わせた木で 1 回の番★（boss1 12:0x）。
  - ★撮りの id 06H / 06S★（新 ShotScreenIds.cs）: 06H = 画面 06 ＋ 竿は手、06S = 画面 06 ＋ 竿は手（沈み）。ScreenRegistry には足さない（遊びは見せない）。player = ScreenHost.StartScreenArg が 06 に読み替え、Start で RodHand.SetForShot（新、Changes に数えない）。editor = ShootCycle の list の末に 06H 06S（06 を Show してから hold を置き、rod.ApplyNow → tipLayer.Apply(0) → dressing.ApplyNow = builder の順, §7.44）、shoot.sh の Shoot も同じ読み替え。
  - ★IKADA_ROD_LENGTH_M★（1〜5 m, builder = player は作る時に効く）: 竿尻から同じ向きに 穂先を置き直す。RodScale（太さ・ガイドの大きさ）は 今の式のまま長さに付いてくる（= 長さを 2.7 にすれば 太さも 2.7/1.5 = 1.8 倍 = ★これで良いかは 長さの答えの時に確かめる（未決）★）。
  - ★IKADA_ROD_SINK_DEG★（0〜89, 水平から下へ度）: 沈みの構えの角 = Hold.cs:61 の HandDipRad の代わり。角だけ（竿尻・上げ・横は不変）。
  - 未設定 = 2 つの env の道に入らない（builder は if の中、Hold は SinkDipRad = HandDipRad そのもの）= ★既定の画は 0 px の見込み★。
- ★先に書く気づき（推論, 未検証）★: A（70〜80° 下）を角だけで入れると 竿 3.09 m・竿尻 0.80 m では 穂先が 水面の下（0.80 − 3.09 × sin75° ≈ −2.2 m）= ★依頼者の言う「竿尻を高く」= 竿尻の位置も 構えの引数に要る見込み★。穂先の窓は 竿の角を −0.15〜0.35 rad に clamp（§7.43 の札）= 70° は窓の外 = 「穂先は窓で読む」も 窓の側の手が要る見込み。今回は形だけ（値は入れない）。
- ★撮りの状態（1 行）★: 06H / 06S = mock の 06（待ちの snapshot）の上で RodHand の状態だけ置く = §7.43 の IKADA_ROD_SHOT_HOLD の画と同じ状態（撮りの道が違うだけ）。
- ★予測（動かさない）★:
  - R1 合わせた木の regress_all（道具は worker2 の版）: ★今の 26 組 vs 基準 = 0 px★（既定の道は不変・06H/06S は list の末 = 前の撮りの順は不変）。06H / 06S の 4 組は 基準に無い = 道具の扱い（worker2 の版の表示）に従う。editor_shots / player_shots = 30 枚、exception 0、missing_chars 0。compare（player vs editor）06H / 06S = 06 と同じ程度（max の % は 06 の行 ± 0.1 %, 推論）。live 3 種 0 px（遊びの code は 読み替えの 1 行と env の読みだけ）。
  - P1 陽性対照（editor, 同じ ShootCycle の道）: IKADA_ROD_SHOT_HOLD=hand で回した cycle の 06 vs 既定の cycle の 06H = ★0 px★、sinking と 06S も ★0 px★（= ApplyHold の置き直しが 組み立て時の状態と同じ）。
  - N1 陰性対照: 06H vs 06 ≠ 0（竿が戻り・上げ・横 = 竿の所が動く）、06S vs 06H = 穂先が下へ ★(967, 624) → (967, 705) の 81 px★（§7.43 の当たりの値）。
  - E1 env が効く対照（editor shoot.sh 06S, 各 1 枚）: IKADA_ROD_SINK_DEG=20 → 穂先が 06S より下（画面の外へ出る見込み・log の pitch −20.0 ± 0.2）、IKADA_ROD_LENGTH_M=2.5 → log「[Builder] IKADA_ROD_LENGTH_M 2.500 m (was 3.09x)」・穂先が 竿尻の方へ寄る。★足し（PRESIDENT 12:5x）★: IKADA_ROD_SINK_BUTT_UP_M=0.3 → 06S の竿全体が 0.3 m 上（穂先 (967, 705) より上へ、画の px は撮って読む = 向きだけ予測）。
  - ★足し（PRESIDENT 12:5x）竿尻の env★（b4d5375）: IKADA_ROD_SINK_BUTT_UP_M / IKADA_ROD_SINK_BUTT_FWD_M（−2〜2 m, 今の手の場所からの上げ / 穂先の方へ）= 沈みの時だけ 竿全体を動かす（PlaceTauS で ease）。未設定 = 0 = 道に入らない。窓の clamp は 依頼者の答えまで触らない、太さは 長さの答えの時。
  - 基準の足し: 予測 → dry（worker2 の道具）→ PRESIDENT の画（06H / 06S × A/B）→ apply。known pixel（字幕帯 (1404,1014)）に 06H|06S を足すかは dry の画で。

## §7.48 worker1 の同値の確かめ用の step の log（boss1 12:4x, 欄 = worker1 §6c）: code と予測（撮りの前, 動かさない）
- code = track3/sink-prep ★b4d5375★: env ★IKADA_ROD_HOLD_STEP_LOG=1★ = LiveHost.cs:348 の RodHand.Step の直後に 毎 step 1 行「[RodHoldStep] frame= step= TimeS= events= panel= leadIn= hold= [snapHold=] inHolder= angle= lowHeld= fight=」（新 RodHoldStepLog.cs、LiveHost は +1 行、RuntimeRod.LowHeld は読みだけ）。s.RodHold は dev-pin の枝でだけ在る = SnapRodHold(s) が今は null（欄を出さない）→ dev-pin で s.RodHold.ToString() の 1 行に替える。200,000 行で切り「cap reached」の 1 行。c9a9358 の毎フレームの log は外した。
- ★lowHeld の注（source の行）★: _lowHeld は RuntimeRod の 描きのフレームで更新（Hold.cs の Rest）= 1 フレームに step が何本もある速さでは ★前のフレームの値★。同値の比べで lowHeld の欄を使う時は frame の欄でまとめる。
- ★予測（live 3 種 = 物語 4/20 s0・練習 free・練習の組 winter, 合わせた木の番で）★: 行数 = その run の step の数（cap に届かない見込み, 届けば行で分かる）、hold の欄が替わる step = [RodHand] の替わりの行と 同じ数・同じ TimeS（同じ所の後に読むゆえ）、env なしの run の [RodHoldStep] = 0 行、遊びの画と logic sequence は env の有無で不変（log だけ）。

- ★竿受けは閉じ（依頼者, boss1 2026-10-06 00:2x）★: 「c205を見る限り、竿おきはよく再現されています」= 縁の (a)・2 点の V は OK。手元の形は 構え A（§7.47 の引数: 長さ・角・竿尻）と 竿の長さの答えで続く。master 6775ad7。

## §7.49 c206 竿の長さの比べ・c207 窓の比べ（PRESIDENT 00:5x, 撮りだけ・既定不変）: code と予測（撮りの前, 動かさない; Unity なし = 未 compile）
- ★先に私の外れ（source を読んで見つけた, 撮りの前）★: §7.47 の E1「IKADA_ROD_SINK_DEG=20 → 穂先が下・pitch −20.0」は ★当たらない形だった★ = 描きの角は RodBend.Points が −0.2〜0.75 rad に clamp（RodBend.cs:42・:78, −0.2 rad = 11.5°）し、さらに DisplayRaise（RuntimeRod.cs:255〜）が 甲板を避け・穂先が目から見える角まで上げる。§7.47 の「角の引数」は 11.5° より深くは描けなかった。★E1 は未撮り★（boss1 01:51: drafts と regress の log を grep, SINK_DEG を使うのは この doc と stance_turn/run.sh だけ）= 外れは 撮りの前に source で見つけた形。
- code = ikada-unity-track3 ★track3/stance-shots b7fe54a★（master 6775ad7 ＋ 3 file +33）:
  - ★IKADA_ROD_SINK_DEG が在る時の沈み = 構えをそのまま描く★: 竿を竿尻のまわりに その角だけ回し（RodHolder.TurnAbout, 竿尻が軸）、RodBend には 0 を渡し、DisplayRaise を通さない（構え A = 3D の穂先は見えなくてよい）。未設定 = 道に入らない。
  - ★IKADA_SHOT_TIP_STANCE=1★（撮りだけ, 構えの時だけ効く）: 窓の竿 = 構えの角を clamp なしで、★静止の穂先のまわりに回す★（今の窓は 傾きを tan で「ずらす」形 = 75° では 3.7 倍に伸びる → 回しに替えた）、曲がり（DeflectionM）は 竿を横切る向きに cos(角) 倍（糸は真下に引く・竿に直角の分だけ曲げる = ★私の置いた描きの仮の形, 物理の証拠でない★）。0° では 今の窓と同じ式。
  - IKADA_ROD_SINK_BUTT_FWD_M の幅を 4 m まで（縁に立つ 2.37 m のため）。
- ★値（worker2 SINK_STANCE_W2.md §4.3・§7.2 から, 枠 = 水面から y・目から前 z）★: 3.09 m = 角 25.9°・竿尻 甲板から 1.0（y 1.45）・穂先 水面から 0.10 = env SINK_DEG 25.9・BUTT_UP 0.65（0.80 から）・FWD 1.39。1.5 m = 角 75°・★縁に立つ形★（竿尻 z 3.59, worker2 §7.4 の推奨; 今の手の場所では穂先が甲板の中 = 比べにならない）・竿尻 y 1.55 = SINK_DEG 75・BUTT_UP 0.75・FWD 2.373・LENGTH_M 1.5。★1.5 m は全長と仮定（札に書く）★。太さ = RodScale が長さに付いてくる（1.5 m = 実の太さ, 3.09 m = 2.06 倍）= 札に書く。
- ★撮りの状態（1 行）★: editor の shoot.sh、mock の 06（待ち, 張力 0.2 N）の上で 06S（沈み）/ 06H（手）/ 08（ファイト）、HUD あり（横からは なし）。手の横 0.158 m・上げ 0.05 m は今のまま。
- ★予測（計算 = worker2 の §0 の写像を python で, 陽性対照: 甲板の縁 → y 741.4・手の穂先 3.09 m → (967, 624) = §7.43 の当たりの値と一致）★:
  - c206-1 3.09 m 沈み: 竿尻 画 ★(906, 468)★（目の高さの近く・画の真ん中やや左 = 握りとリールが大きく写る）、穂先 ★(985, 731)★（甲板の縁 741 の 10 px 上）= ★竿は 全部 画に入る★、糸は穂先から 水へ 約 10 px。log（横から）butt (−0.121, 1.450, 2.607)・tip (0.121, 0.100, 5.377) ± 0.05（曲がりの分）・pitch −25.9 ± 1。
  - c206-2 1.5 m 沈み（縁に立つ）: 竿尻 ★(948, 423)★、竿は ほぼ真下へ、★(957, 746) で甲板の箱に入って切れる（竿の 76 %）★、穂先 (959, 835) は箱の陰 = 画に出ない、糸も出ない。log butt (−0.036, 1.550, 3.586)・tip (−0.002, 0.101, 3.973)・pitch −75.0 ± 1。
  - 横から 2 枚: 竿の角が 一目で 26° と 75°、1.5 m の竿は 甲板の縁の上に立って下へ。
  - c206-3 手 3.09 m = 今の 06H と同じ（穂先 (967, 624)）、1.5 m = 穂先 ★(913, 738)★ = 甲板の縁 741 の 3 px 上・★z 2.72 = 甲板の上★ = 糸は 甲板の板の上で切れる（水に届かない絵, 推論）。
  - c206-4 ファイト（08）: 1.5 m は穂先が手前・下（数は撮って読む = 向きだけ予測）。FightEntry が糸を縁の外へ（推論）。
  - c207（1.5 m・75°・窓は x 17〜500・y 168〜595）: 今の窓 = 今と同じ水平の竿（窓は logic の角 0 を見る, 3D の構えは入らない）、穂先 窓の中 (423, 296) 付近。構えの窓 = 穂先は同じ所、竿は そこから 左上へ 75° = ★窓の上端 y 168 を x 約 389 で抜ける 約 130 px の ほぼ縦の棒★。アタリ（IKADA_TIP_T=1.0, 仮の値; 0 → 1.0 N で 今の窓の穂先は 約 28 px 下がる, 先の測り）: 今の窓 = 穂先が下へ、構えの窓 = ★動きは 今の窓の 約 0.26 倍・向きは ほぼ横（左）★ = 上の仮の形からの帰結（式の言い直し = 証拠でない）。
  - 全 11 枚 rc 0・exception 0、log に [Builder] IKADA_ROD_LENGTH_M 1.500 と [RuntimeRod] shot overrides sinkDeg=… が出る、porcelain 0（.meta 新 0）。
- 画 = c206（8 枚: 長さ 2 × 沈み・横から・手・ファイト）・c207（4 枚: 今の窓 / 構えの窓 × 静止 / アタリ, 窓は切り出して拡大）、見出しは依頼者の言葉、札に「1.5 m は全長と仮定」「太さは長さに比例して描いた」「構えの窓の曲がりは仮の描き」、商品名なし。run = stance_turn/run.sh（1 本ずつ shoot.sh 11 回）。
- ★結果（boss1 01:51 LOCK, 木 b7fe54a, 出力 = stance_turn/）★: 11 本 rc 0・error CS 0・Exception 0、porcelain 0、FREE 前 Unity・player・VBCS 0（撮り中に出た自分の VBCS 1615412 起動 01:52:15 を kill）。測り = log の世界の点 ＋ 4 倍の切り出しで読んだ画の点。
  - c206-1 3.09 m 沈み: ★当たり★ = log butt (−0.121, 1.450, 2.607)・tip (0.121, 0.100, 5.376)・pitch −25.9、画の穂先 ★(985, 731)★（予測と同じ）、竿は全部 画に入る、糸は穂先から水へ 約 11 px。見え = 竿が奥へ下る向きゆえ 画では「握りとリールが画の真ん中に立つ短い棒」に見える。
  - c206-2 1.5 m 沈み: y・z・角は ★当たり★（log butt y 1.550・z 3.592、tip y 0.101、pitch −75.0、甲板に入る所 画 y 746）、★x は外れ★ = log butt x −0.094（予測 −0.036）・画の入る所 (939, 746)（予測 957）。訳（source の行 ＋ log）: 手の横 SideTarget = max(0.10, 受けの大きさ ＋ 0.02)（Hold.cs:142）、受けの大きさは guideScale = 長さ / 1.5 に比例（:156）= 1.5 m では 0.10 が勝つ → 横 0.10（予測は 3.09 m の 0.158 のまま）。0.10 で計算し直すと (940, 746) = 画と合う（後からの計算 = 当たりに数えない）。
  - c206-3 手: 3.09 m = 今の 06H。1.5 m = 画の穂先 (890, 735)（予測 (913, 738): y 当たり・x 23 px 外れ, 訳は上と同じ横 0.10, 計算し直し (889, 737)）、★糸は甲板の板の上で切れる（y 約 875）= 当たり★。
  - c206-4 ファイト: 1.5 m の穂先は 手前・下 = 向きは当たり。竿は細く（実の太さ）弧は小さい。
  - c207: 構えの窓（静止）= 穂先 (420, 283)（予測 (423, 296) 付近）・竿は 窓の上端を ★x 389 で抜ける（当たり）★・見える竿 約 115 px（予測 約 130）。log tilt −1.31 rad（= 75°）。アタリ 1.0 N: 今の窓 = 穂先 ★約 113 px 下★（予測に添えた「約 28 px」は古い測りの値 = 外れ。穂先を柔らかく描く c190 の後の値ではなかった）、構えの窓 = 左へ 27 px・下へ 6 px = 今の窓の 約 0.25 倍・ほぼ横 = 予測どおり（仮の描きの式の言い直し = 証拠でない）。
  - ★状態の直し★: 静止の画の窓の張力は ★0 N★（log T 0.00、窓の穂先は撮りでは IKADA_TIP_T が無いと 0）= §7.49 の 1 行「張力 0.2 N」は 3D の竿と HUD だけ。c207 の「静止」= 0 N。
  - 画 = ★c206_rod_length_compare.png（8 枚）・c207_tip_window_compare.png（4 枚, 窓を 1.6 倍）★（drafts/user_review/, ls で c206・c207 は空きと確かめた）。見出し = 依頼者の言葉、札 = 1.5 m は全長と仮定・太さは長さに比例・3.09 m は 26° が手の届く最大・横から見た図は説明の図・構えの窓の曲がりは仮の描き。

## §7.50 沈み待ちの構えを既定に（依頼者 02:0x「3.09mのほうが迫力があっていい…穂先は今の窓のままのほうがわかりやすい」, PRESIDENT 02:0x）: code と予測（撮りの前, 動かさない; 未 compile）
- 依頼者の答え（要点）: 竿は 3.09 m のまま、窓は今のまま（c207 の構えの窓は採らない）、沈みの竿が受けの上に短く立って見えるのは気にならない（閉じ, boss1 02:1x）。
- code = ikada-unity-track3 ★track3/sink-stance-default f2b113b★（master 6775ad7 ＋ 2 file +34 −22, env の枝でなく既定の直し）:
  - 沈みの時: 竿を 竿尻のまわりに ★SinkStanceDeg 25.9°★ 回し、竿尻を ★0.65 m 上・1.39 m 前★（SinkButtUpM / SinkButtFwdM, c206 左の値 = 竿尻 甲板から 1.0 m）。回しは _stanceA を PlaceTauS で ease = 入りも出も滑らか（沈みの終わりで跳ばない）。沈みの間は DisplayRaise の持ち上げと 受けの間隔の角（HeldAngle）を通さない（c206 と同じ描き）。logic の角が 構えより深い分（W / S）だけ 今の道で足す（合計 = min(logic の角, −構え), 前の min(角, −0.10) と同じ形）。
  - 前の沈みの下げ HandDipRad 0.10 は消した（grep 0, 履歴の 1 行のみ）。env IKADA_ROD_SINK_DEG / _BUTT_UP_M / _BUTT_FWD_M は 撮りで上書き（−2〜2・−4〜4）。
  - ★窓の構えの撮りの引数（c207 の IKADA_SHOT_TIP_STANCE）は master に持ってこない★ = 枝 track3/stance-shots b7fe54a にだけ残る記録（master の grep stanceView 0 = 遊びに入らない, source で確かめた）。窓は logic の角のまま = 不変。
  - BackdropBuilderProps.cs（526 行）は この番で触らない = 分けは次に その file を触る番へ（控えのまま）。
- ★状態（1 行, 撮りの前に）★: mock の 06S = editor / player とも 撮りは即（k2 = 1）= 構えの全量。live の regress の live_06（種 20260925・1・26 の 3 本とも）= ★落とした後・底の前の 沈みの状態★（基準の live.log: [RodHand] hand (sinking) at drop TimeS 5.517 → live_06 の shot → rest at bottom 14.417）、lockstep の待ち 139 frame で 構えは ease の 約 99 % 以上（推論: τ 0.5 s）。種 26 の live_08・live_03 は 沈みの終わり（720.5）から 70 s 以上後 = ease 済み = 不変。
- ★予測（動かさない）★:
  - P1 陽性対照（editor shoot.sh 06S, env なし）vs c206 の L309_sink.png（b7fe54a, env で同じ値）= ★0 px★（同じ式・同じ道; 違いは 角の持ち方 _drawnA → _stanceA だけ）。
  - E1 env が上書きする（IKADA_ROD_SINK_DEG=40）: 06S の竿が P1 より深い（log の shot overrides sinkDeg=40）。
  - regress（worker2 の regress_all.sh, 合わせない木 = この枝だけ）: ★mock の基準 30 組のうち 06S_A / 06S_B の 2 組だけ差★（竿・糸・甲板の竿の影の所, 箱は y ≥ 440 の中の見込み; 窓・HUD は 0 px の見込み = 窓は logic の角から描き 穂先からの相対で置く・推論）、★残り 28 組 0 px★（06・06C・06M・06H・08・2D: 沈みでない = _stanceA 0 = 前と同じ式）。player の 06S は editor の 06S と同じ形（compare の 06S の行 = 前と同じ程度）。★live = 3 種とも live_06 だけ差★（竿が構えへ）、ほかの live の画 0 px、logic sequence（page・screens）= 基準と同じ。exception 0・error CS 0・missing_chars 0。
  - 基準の差し替え（予測 → dry → PRESIDENT の画 → apply）: mock 06S_A_sans・06S_B_serif（札 = 3.09 m・26°・竿尻 甲板から 1.0 m、依頼者 02:0x）、live 3 種の live_06.png ＋ live.log・ARGS.txt（live_rebase5.py の表どおり）。apply の後に PIN（baseline_pin.sh）。
- run = sinkdef_turn/run.sh（P1・E1 の 2 枚 → regress、1 本ずつ）。
- ★結果（boss1 02:16 LOCK, 木 f2b113b, 出力 = sinkdef_turn/, regress f2b113b_021733）★: editor 2 枚 rc 0・error CS 0。regress = ★PASS 13/16・SKIPPED 1（refcheck auto）・FAIL 2 = baseline と live だけ★（build・tests・atlas・player_shots 30/30・editor_shots 30/30・editor_repeat・compare 30/30 max 0.24 %・git_clean は PASS）。FREE 02:29（Unity・player・VBCS 0, porcelain 0）。
  - ★mock baseline = 28/30 0 px・差は 06S_A / 06S_B だけ = 当たり★。06S: 差 > 30 = 26,741 px・箱 (726, 455)〜(1636, 1080)（竿・糸・甲板の竿の影, y ≥ 455 = 予測の y ≥ 440 の内）、★窓 0 px★（A・B とも）、既知の点 全 0。
  - ★live: logic sequence = 3 種とも基準と同じ・live_06 は 3 種とも差 = 当たり★（差 > 30 = 10,622 / 9,342 / 9,366 px、箱 x 725〜986・y 458〜1080 = 竿の所、窓 0 px）。★外れ = 種 26 の live_08 も差★（予測は不変）: 差 > 0 = 4,881 px・> 30 = 101 px・箱 (577, 560)〜(1048, 877)、×8 の差の画で ★竿とリールの輪郭だけ = 竿全体が 1 px 未満ずれた形★（live08_s26_zoom_old_new_diffx8.png）、窓 1 px。live.log の差（06 の shot から 08 の shot まで, frame の数を除く）= [RodHolder] dip の要約の行 5 本だけ（描きの側, logic 0）。
  - ★P1 の外れ（対照の作りの誤り）★: 既定の 06S vs c206 の L309_sink = 442,004 px 差、★全部 水の帯 y 446〜744 の中★（帯の外 0 px）= shoot.sh は水の時刻を止めない（regress は IKADA_WATER_T 10 で止める）= 2 回の撮りの水が違う。竿の所は 水と重なり 画では切り分け不能 → 竿の log の行（[TipAngle]・[RodHolder]・[TipView] 9 行）は 2 つで ★同じ★（弱い裏付け: 竿尻・穂先の座標は この行に無い）。0 px の予測は外れのまま。次から 水の時刻を揃えた対照にする。
  - E1（SINK_DEG=40）= 竿が より立ち 穂先が甲板の縁 (約 955, 745) へ = 当たり（向き）。
  - dry（live_rebase5.py, 動かさない）= changed 7（live_06 ×3・live.log ×3・種 26 live_08）・same 26（RESULT・ARGS・AUDIO は 3 種とも same）= live_dry_table.md・live_dry_sheet.png。mock = mock_06S_sheet.png。apply しない（boss1）。

## §7.51 種 26 live_08 の外れを測る計画（boss1 02:3x, 推論のまま → 次の Unity の番で測る）: 予測を先に（動かさない）
- ★code を読んだ所（観測, 読むだけ・csc なし）★: ease がファイトに入っても残る道は ★在る★ = ファイトでは hand = false（RuntimeRod.Hold.cs:57）→ sinking = false（:64）→ _stanceA・_sinkUp・_sinkFwd は 0 へ向かうが ★描きのフレームごとに k2 だけ縮む（:60, k2 = 1 − exp(−Time.deltaTime / 0.5) = 実のフレームの時間, logic の時間でない）★ → 1e-5 を超える間は 竿を動かす（:82・:83・:85）→ その後に if (fight) return raise（:95）= ★ファイトの竿は 残りで回った _butt / _tip から作られる★（RuntimeRod.cs:181 Rest → :182 GripRaise）。DisplayRaise を飛ばした事の残り（LastDisplayRaise・LastClamped）は 書くだけで読む所 0（grep）= 道でない。_drawnA の残りは ファイトの道（:95 return raise）で使われない。
- ★数の枠★: live は speed 300・lockstep の 1 step = 1/60 s（ikada-sim-w3 の ReferenceRun.cs:45 FrameS, Unity の pin の版は未確かめ）= ★1 フレーム ≈ 5 s★。種 26: 沈み 711.981〜720.514（約 8.5 s = 約 2 フレーム）、底 720.514 → アワセ 792.399（71.9 s = ★約 14〜15 フレーム★）、その後 live_08 の shot まで 139 フレームの待ち（歩みは止まるが フレームは進む = ease は進む）。
- ★仮説 H★: 沈みの約 2 フレームで構えは少しだけ入り（k2 × 2 程度）、底の後 約 15 フレーム ＋ 待ち 139 フレームで縮むが ★shot の時に 1e-5 を超えて残る★ → 竿全体が 1 px 未満ずれる。
- ★測り（次の番, 木 = track3/sink-stance-default 2ae11c7 = f2b113b ＋ log だけ）★: build → LIVE_SEEDS=26 で live 2 本:
  - M1 = IKADA_ROD_FRAME_LOG=1（log: 手・ファイト・戻りの毎フレームに stanceA・sinkUp・sinkFwd・butt, 上限 20000 行）。
  - M2（反実仮想の対照）= M1 ＋ IKADA_ROD_SINK_DEG=0・IKADA_ROD_SINK_BUTT_UP_M=0・IKADA_ROD_SINK_BUTT_FWD_M=0（構えを 0 にする）。
- ★予測（H が正しければ）★: (1) M1 の live_08 の sha = regress f2b113b_021733 の live_08（log は描きを替えない = 陽性対照）。(2) M1 の log: 720.514〜792.399 の戻りの行 = ★14〜15 フレーム★、沈みの終わりの |stanceA| は 0.452 rad よりずっと小さい（構えは入りきらない）、その後 毎フレーム 同じ比で縮み、★live_08 の shot のフレームで 1e-5 < |stanceA| （かつ sinkUp・sinkFwd > 1e-5）★。(3) ★M2 の live_08 = 基準（5e50ac7_s26_014332）と 0 px・sha 同じ★。(4) M1 と M2 の butt= の行が違う最初のフレーム = 711.98 の沈みの入り、ファイトのフレームでも違いが続き、|stanceA| が 1e-5 を割るフレームで消える。
- ★H が違えば見える物★: (2) で shot のフレームの 3 つが全部 ≤ 1e-5（回しも動かしも飛ばされる）、または (3) で M2 の live_08 が まだ基準と違う → 原因は構えの残りでない → 次 = M2 と基準の差の所と log の行を 1 行ずつ。
- ★遊びに時間の早送りは在るか（boss1 02:3x, 読むだけ, ikada-sim は pin の b80715f で読んだ）★: ★沈みの終わり→アワセの間を飛ばす道は無い★。(a) LiveHost.cs:91 speed 1、:159 の 1 より大は 試験（lockstep ＋ AutoPilot ＋ -ikadaLiveSpeed）だけ、遊びは :311 の 1 step / フレーム・logic は 1 フレーム 最大 0.1 s（IkadaSession.cs:53・:121）、Time.timeScale を替える所 0。(b) 遊びの飛ばし DayFlow.cs:327・:328 → Skip :333〜338 → FishingSession.FastForward :458 は State が Card でないと戻る（:460）= 投げの間だけ（Settle・DayFlow.Stock.cs:44〜48 も Card）。(c) DayFlow.cs:325 Clock.CycleSpeed = 時計だけ（GameClock.cs:2・:27, 竿・魚・ダンゴは実時間）。= 遊びで 構えの残りが 1e-5 rad を超えるのは 沈みの終わりから 約 5.4 s 以内のアワセだけ（0.452 × exp(−t/0.5), 計算）= ファイトの頭の 0.5 s の戻りの ease として見える（推論）。
- ★P1 の対照の誤り（記録）★: shoot.sh は水の時刻を止めない → 2 回の撮りの水の帯が違い 0 px の対照にならなかった（§7.50 の結果）。直しは 次に P1 を使う時（IKADA_WATER_T を両方に）。
- ★枝★: 測りの木 2ae11c7 は track3/sink-measure（master に入れない, M2 の env 0 も含め）、track3/sink-stance-default は f2b113b のまま。M1・M2 は同じ build で。
- 直しの案（測ってから決める, 今は何もしない）: H が正しければ ★これは speed 300 の写りでだけ起きる（遊びの速さ 1 では 底からアワセまで 数千フレーム = 残り 0）= 基準の差し替えに live_08 を含める★ を推す（ease の式を替えると 前からの _lift・_side・_back と違う扱いになる）。
- ★結果（boss1 02:50 LOCK, 木 2ae11c7, 出力 = measure_turn/）★: build rc 0・error CS 0、M1・M2 は ★同じ build★（player の sha を前後で照合 OK）。FREE 02:53（自分の VBCS 1672967 を kill, 作業木 f2b113b・porcelain 0）。
  - (1) ★当たり★: M1 の live_08 の sha = regress f2b113b_021733 の live_08（6c00cea0…）= log は描きを替えない。log 2,415 行・上限に届かず。
  - (2) ★当たり★: 底 720.514 → アワセ 792.399 の 戻りのフレーム = ★15★（予測 14〜15, 1 フレーム ≈ 5 s, dt 0.0167）。沈みの終わり（frame 710, TimeS 715.5）で stanceA = −0.0400 rad（= 構え 0.452 の 約 9 % しか入っていない）、毎フレーム 0.967 倍（= exp(−0.0167/0.5)）。★shot のフレーム = 867（shot の行の直前）: stanceA −2.135e-4 rad・sinkUp 3.070e-4 m・sinkFwd 6.565e-4 m = 3 つとも 1e-5 を超える★。
  - (3) ★M2（構えを env で 0）の live_08 = 基準と 1 px 差・sha 違い = 予測「0 px・sha 同じ」の字面は外れ★。その 1 px = (917, 563) G 86 → 87 = ★種 26 live_08 の 登録済みの既知の点★（live_regress.sh:53〜58 KNOWN_LIVE_08_S26 "917,563,1", 描くたびに 1 段揺れる縁）= live_regress は live_08 を ★差に数えない★（M2 = differ: live_06 だけ）。予測を書く時に 既知の点の表を見なかった = 私の外れ。中身（構えが 0 なら live_08 は基準どおり）は 道具の基準で成り立つ。
  - (4) M1 と M2 の butt の行の比べは しなかった（(2)(3) で足りる・時間の都合ではなく 要らない, boss1 の求めの 4 つの数に入っていない）。
  - ★読み★: 仮説 H は ★測りで成り立つ★ = 種 26 live_08 の差は 構えの ease の残り（沈みの約 2 フレームで 9 % 入り、15 ＋ 139 フレームで 2e-4 まで縮んだ所）を speed 300 の写りが止めた物。遊び（speed 1, 早送り無し）では 沈みの終わりから 約 5.4 s 以内のアワセでだけ ファイトの頭の 0.5 s の戻りとして見える（推論, 上の読み）。
  - 推す 1 つ: ★live_08（種 26）も 基準の差し替えに含める★（ease の式は替えない = 前からの _back・_lift・_side と同じ扱い）。PRESIDENT の判断へ。

## §7.52 基準の差し替え（PRESIDENT 03:0x GO, ease の式は替えない）: script と予測（apply の前, 動かさない）
- ★差し替える物★: mock = shots/player/a9106ea_234105 の 06S_A_sans・06S_B_serif（その場で, 旧 = pre-stance_<名>, 源 = regress f2b113b_021733 の player 撮り f2b113b_022239）、live = 3 種の live_06.png・live.log と 種 26 の live_08.png（live_rebase5.py, dry の表 live_dry_table.md = changed 7 を前の照合に）。札（NOTE と merge の commit 本文）= ★種 26 live_08 は 沈みからアワセへの戻りの ease の残りを含む★（§7.51 の測り）。
- script = sinkdef_turn/apply_run.sh（門の内で 1 回）: 木が clean な f2b113b か → ① mock_apply.py --apply（sha を mock_apply_want.md と照合, 違えば何も動かさない）→ ② live_rebase5.py --apply（表と照合）→ ③ regress_all.sh → 新しい regress の baseline が PASS の時だけ ④ baseline_pin.sh <mock dir> <その regress> → PIN を表示。どこかで外れたら止まる。
- ★予測（動かさない）★: ① 2 changed・新 = 源・pre-stance_ = 旧・NOTE に 1 節。② changed 7・新 = 源・pre-stance_ = 旧・3 つの dir の NOTE に行。③ ★RESULT PASS 15/16・SKIPPED 1（refcheck auto: PIN の pin b80715f = 今の pin）★、★baseline 30/30 0 px★（既知の点は今の扱い）、★live 3 種 PASS★（logic sequence = 基準・画 全部 0 px, 種 26 live_08 は 既知の点 (917,563) の 1 段以内）、ほかの段は前と同じ PASS（player_shots 30/30・editor_shots 30/30・compare 30/30・git_clean）。④ PIN = pin b80715f… ＋ regress <③の id>。
- ★木の替え（boss1 03:05）★: master = a98fb81（backdrop の分け）を track3/sink-stance-default へ --no-ff merge = ★273fecb★（衝突なし, 作業木 clean, master の 3 file の違いは file の名の注だけ = BackdropBuilderProps → BackdropBuilderRod.cs）。apply_run.sh の確かめ・regress の id は 273fecb に替えた = regress は master ＋ 構えの組み合わせそのものを見る。予測は同じ（backdrop の分けは 動きの変わり 0 = boss1 の regress 済みの見込み、未確かめ）。
- その後: track3/sink-stance-default の log と diff --stat を boss1 へ → boss1 が master へ --no-ff（前に PRESIDENT へ 1 行）。track3/sink-measure（2ae11c7）は master に入れない（残すだけ）。
- ★結果（boss1 03:19 LOCK, 木 273fecb）★: ① mock 2 changed（新 = 源・pre-stance_ = 旧・NOTE 1 節）② live changed 7・same 26（新 = 源・pre-stance_ = 旧・NOTE の行）③ ★regress 273fecb_032003 = RESULT PASS 15/16・SKIPPED 1（refcheck auto）★、★baseline 30/30 0 px★、★live 3 種 PASS（logic sequence = 基準、画 0 px: 6・7・8 枚）★、player_shots 30/30・editor_shots 30/30・compare 30/30（max 0.24 %）・git_clean 0/0/0 ④ ★PIN = pin b80715f… ＋ regress 273fecb_032003（30/30）★ = ★予測 全部 当たり★。FREE 03:2x（自分の VBCS 1701516 を kill, porcelain 0）。
  - track3/sink-stance-default = f2b113b（構え）＋ 273fecb（master a98fb81 の merge）、master.. の diff = RuntimeRod.Hold.cs +30 −22・RuntimeRod.cs +2 −2（2 file）。merge は boss1（commit 本文に 札 = 種 26 live_08 は 沈みからアワセへの戻りの ease の残りを含む）。

## §7.53 段 (3) S1 = logic 0.26.0 の pin ＋ step の log の器（boss1 04:36, RODHOLD_SWITCH_W2.md ②-0; RodHand はまだ切り替えない）: code（未 compile）
- code = ikada-unity-track3 ★track3/rodhold-s1 138bb9e★（master c50933d ＋ 5 file +21 −10）:
  - pin = Packages/manifest.json の com.ikada.sim を ★db43865a481439d06d4061245bcc5ba402a80797★（40 桁, logic main, API 0.26.0）。packages-lock.json = 前の pin の commit（3f7ac9a・27bf061）と同じ 2 行（version・hash）を手で = Unity の書き直しと同じかは regress の git_clean で確かめる。
  - step の log（IKADA_ROD_HOLD_STEP_LOG=1 の時だけ, log だけ）の欄 = 前からの frame・step・TimeS・events・panel・leadIn・hold（Unity の RodHand.State）・★snapHold（= s.RodHold, logic）★・inHolder・angle・lowHeld・fight ＋ 新 ★stick・strikeAcc・holderKey（その step の InputFrame = SessionDriver.LastInput, session は読まない）・hk（FishingSession.HooksetCount, session 無し = −1）★。上限 200,000 → ★600,000★（live 1 本 約 540,000 step, cap の行は残す）。LiveHost は log が on の時だけ 引数を集める（RodHoldStepLog.On）。
- ★compile の見込み（読みだけ, csc なし）★: (a) RodHold の名が 2 つ（Unity の Ikada.Render.RodHold と logic の Ikada.Game.Render.RodHold）= 名だけで書く file は RodHand.cs・RuntimeRod.Hold.cs・TipJointProbe.cs（namespace Ikada.Render の中 = 自分の名が先に引かれる）と ShotScreenIds.cs（using Ikada.Render だけ）= 曖昧 0 の見込み。(b) 0.25 → 0.26 で消えた public = DayFlow の field RodInHolder（property になった）と Apply の中身だけ = Unity が書く RodInHolder は RenderSnapshot の field（MockSnapshots.cs:114・MockFight.cs:16, RenderContract.cs:348 に在る）= 壊れない見込み。
- 予測（logic の並び・(b1)(b2)・送りの門・refcheck）は worker2 が書く（boss1 04:36）。

## §7.54 段 (3) S1 の番（boss1 04:42 GO, 木 43beea1 = 138bb9e ＋ refcheck #18）: 走らせ方と 私の足した所の予測（回す前, 動かさない）
- 予測の本体 = worker2 RODHOLD_SWITCH_W2.md §⑥（refcheck 11/11・mock 30/30 0 px・live は画で FAIL: 06C・06 = 手の揺れの項、08 = FishSide、種 20260925 は並びも、種 26 未確認・数え 訳なし 0・ファイト中の違い 0・受けかつ _lowHeld 0）。
- run = rodhold_s1/s1_run.sh: ① regress_all.sh ② live 3 種 env なし（wall time）③ live 3 種 IKADA_ROD_HOLD_STEP_LOG=1（wall time）④ rodhold_count.py --expect pass ×3 ⑤ 陽性対照 (i) 鍵 1 回 = key_day.sh で rodhold_s1/kh_once.md（06C で Enter = 投下 → 06 で 15 s 後 = 底の後に C = HolderToggle 1 回 → 上がって終わる）→ --expect kh ⑥ 陽性対照 (ii) 練習の組（set, lead-in が回る）を IKADA_RODHAND_NO_LEADIN=1 で（QuitAfterS 3600）→ --expect unexplained。log は Logs/regress/<id>/s1/ と Logs/player/（drafts に写さない）。
- ★私の足した所の予測★: ⑤ = KH の run が 1 つ・--expect kh が exit 0（鍵は 06 の待ち = Card でない・ファイトでない時）。外れうる所 = 鍵を押す時に まだ沈み（底が 15 s より後）か 札の頁 = 違いが出ない（R7・R3 が勝つ）→ 外れとして報告。⑥ = lead-in の step > 0・訳なしの run > 0・--expect unexplained が exit 0。外れうる所 = QuitAfterS 3600 の内に 組の投（lead-in）が来ない。③ の wall time > ② の wall time（log の行 約 54 万 × 3 種, 何倍かは予測しない）。
- ★1 回目（04:44〜05:17）= 止まった★: regress の build（Unity 1754685）が ★31 分 出力なし★（log exec-044449.log の最後 04:45、CPU 48 s / 31 分、wchan futex_wait_queue）。所 = PrebakeFonts（BuildScript.cs:36）の『Unloading 10 Unused Serialized files』の直後（良い build exec-032003.log では すぐ次の行が出る）。その前は正常（pin = db43865 に解決 log :230・:867、compile ExitCode 0・error CS 0）。boss1 も見た: Xid・OOM 無し、GPU 873 MiB、mem 空き 22 GB。thread ごとの待ち = rodhold_s1/hang1_threads.md（Unity 88 thread: sigsuspend 32（thread pool・Burst・job worker・main の 2 つ）ほかは futex = ★Mono が GC の止めで thread を寝かせる形に見える（推論, 測っていない）★）。boss1 05:16 GO で 止めて（task 停止 = Unity と子 3 つも終了）、2 回目を 1 回。2 回目も同じ所で止まれば 推論をやめて報告。
- ★過去の同じ形 1 件（boss1 05:18 の grep）★: MASTER_TASKS.md:739-740 = worker2 の regress 5aa7d8d の build が ★同じ『Unloading Unused Serialized files』の後で futex 待ち★（pid 1069005, 状態 = drafts/stageC/stall_0939_pid1069005.txt）、1 回だけやり直し → 2 回目は 36 秒で通過・原因未確認（H4）。
  - ★thread の待ちの並べ（観測, 名ごと）★: 前 / 今 = Background Job 16 futex / 16 futex・BakingJobs 8 futex / 8 futex・Burst-CompilerT 7 sigsuspend / 7 sigsuspend・AssetGarbageCol 7 futex / 7 futex・Finalizer sigsuspend / sigsuspend・main thread futex / futex・Loading.Preload sigsuspend / sigsuspend・Thread Pool Wor 10 / 13（今は sigsuspend）・Job.Worker 0〜6 = 前は 7 つとも sigsuspend / 今は 1〜5 sigsuspend・0 と 6 futex = ★ほぼ同じ形★（同じ所・同じ thread 名の待ち）。違いは Thread Pool の数と Job.Worker 2 つだけ。
  - ★順の誤り（私）★: boss1 05:18 の『並べてから再走』の便より前（05:17）に 2 回目を始めていた（05:16 の GO で）= 並べは 2 回目と同時に行った（読むだけ）。
- ★2 回目の結果（05:17〜05:4x, 木 43beea1）★: build ★通過 約 40 s★（exec-051728.log, PrebakeFonts の unload の次の行がすぐ出た = 1 回目の止まりは再現せず = stall_0939 と同じ「やり直すと通る」, 原因は未確認 H4）。
  - ★regress 43beea1_051728 = RESULT FAIL・PASS 15/16・SKIPPED 0★: build CS 0・★git_clean 0/0/0（packages-lock の手書き = Unity の書き直しと同じ）★・★refcheck PASS 11/11（pin が替わり 回った）★・★baseline 30/30 0 px★・player 30/30・editor 30/30・compare 30/30・key / pad / hud / edge / tip_size / input / atlas PASS・★live FAIL★ = worker2 §⑥ の予測の形:
    - 種 20260925: ★logic の並びが基準と違う★（予測どおり, 画は比べず）、音 5b も違う（drag 0→1・reel 84→85・wind 147→141 = 並びの違いの続き）。
    - 種 1: 並び = 基準（予測どおり）、★画 = live_06・live_06C が違う★（予測 06C・06 どおり）、音 5b = 基準。
    - 種 26: ★並び = 基準★（予測は未確認 → 同じ）、★画 = live_06・live_06C・live_08 が違う★（予測 06C・06・08 どおり）、★音 5b FAIL = wind_frames 157→156★ = ★予測に無かった（外れ: §⑥ は音を書いていない）★。
  - ★wall time★: live 3 種 env なし 166 s・IKADA_ROD_HOLD_STEP_LOG=1 199 s（+33 s, +20 %）。
  - ★数え（rodhold_count.py, 予測 = 訳なし 0・ファイト中 0・受けかつ _lowHeld 0）★ = 3 種とも ★PASS★: 種 20260925 = 540,561 step・違う step 11,366・run 2（K2: 2447.916〜2637.270 の 11,362 step = 長い・3821.876 の 4 step）、種 1 = 539,333 step・run 1（K2 4 step）、種 26 = 539,212 step・run 4（K2 4 step ×3（792.333 = アワセの直前）・6213.091〜6364.311 の 9,074 step = 長い）。訳なし 0・ファイト中の違い 0・受けかつ _lowHeld 0（手かつ _lowHeld = 2 / 0 / 33 frame = 陽性の向き）。上限に届かず。
  - ★log の場所★: 3 種の step log = ~/Documents/ikada-unity-track3/Logs/regress/43beea1_051728/s1/steplog/seed_*/live.log、env なし = s1/plain、練習の組 NO_LEADIN = s1/noleadin/live.log、★鍵 1 回 = key_day.sh の dir = Logs/player/keyday_43beea1_kh_once.md_053805/live.log（regress の dir の外）★（boss1 05:43 に path を送った）。
  - ★陽性対照★: (i) 鍵 1 回 = ★KH の run 1 つ（TimeS 24.834〜40.834, 961 step）・--expect kh PASS★（予測どおり）。(ii) 練習の組 NO_LEADIN = lead-in の step 172・★訳なしの run 19・--expect unexplained PASS★（予測どおり）。
  - 長い K2 run（20260925 の 2448〜2637 s・26 の 6213〜6364 s）は S2 で 画が替わりうる所 = live の撮りの秒（5.5・792.4・865.4 ほか）は入らない（読み）。
  - FREE 05:4x（Unity・player・VBCS 0, porcelain 0）。apply（基準の差し替え）はしない = PRESIDENT が画を見てから。
- ★S1 の画と 2 つの問い（boss1 05:40, Unity なし・今ある出力だけ）★
  - ① sheet = rodhold_s1/s1_live_old_new_diff.png（旧｜新｜差 ×8）・s1_live_s20260925_new.png（種 20260925 の新 8 枚, 並びが替わったので旧と比べない）。差（観測）: 種 1 live_06 = > 30 で 376 px・live_06C 185 px、種 26 live_06 141 px・live_06C 35 px、★どれも箱 x 279〜422・y 284〜316 = 左上の穂先の窓の 竿の先だけ★（Q3 (a) 受けの間の手の揺れの項 と合う）。★種 26 live_08 = > 30 で 32,649 px・箱 (577, 561)〜(1467, 893) = ファイトの竿が ★右へ寝る（旧は左）★★（Q3 (b) FishSide → 糸の角 と合う, 画で大きく見える）。
  - 種 20260925 の並びの最初の違い（観測, live.log の logic の行を並べた）: [Cast] cast=12（t 2442.9, 始まりの時刻は同じ）の ★tBreak 40.09 → 40.85★ が最初、cast 14 から時刻がずれる。= 1,980 s より後 = worker2 の #17（フグの到着か つつき = 1,980 s 以後）と 時刻は合う。★フグの窓が訳か は 未確認★（live.log に 魚の到着・つつきの行が無い）。数えの長い K2 run（2447.9〜）は この cast 12 の中。
  - ② ★種 26 の音 wind_frames 157 → 156 = 予測の外れ★: wind_frames = FishingAudio.cs:47 = 描きの フレームごとに その snapshot が 歯車の音の条件（condGear）を満たせば +1（1 フレーム = speed 300 で 約 5 s の最後の 1 step）。live.log の [Audio] は RESULT の合計 1 行だけ = ★どの時刻の frame が増減したかは 今の log では 未確認★。log で分かった事（観測）: ★種 26 の logic は cast 1〜41 まで 時刻まで同じ、cast 42 の始まりが 8121.8 → 8121.4（0.4 s 早い）★（間の 35 行は 同じ = cast 41 の中で log の無い所が替わった）、その後の cast は時刻がずれ、fed（1795）は同じ・clicks 382 → 385・reel 86 = 86・drag 1 = 1。live_regress の『並び = 基準』は 画面の順だけを比べる = 時刻のずれは見ない。
  - ★Unity で測るなら（計画と予測, 回していない）★: env だけの log（例 IKADA_AUDIO_FRAME_LOG=1: FishingAudio.Feed で frame・TimeS・condGear・ReelSpeed）を足し、種 26 の live を ★master c50933d（旧 pin）と S1（新 pin）の 2 つの build★ で回し 行を並べる。予測: 違う frame は ★t ≥ 7917.7（cast 41 の始まり）の後だけ★、合計は 157 / 156。外れたら（7917.7 より前に違いが在る）= log の無い所で もっと前から logic が違う。

## §7.55 段 (3) S1 の基準の差し替え（PRESIDENT 05:5x 画として可・★条件付き GO★ = worker1 の logic の測りが 種 26 の cast 42 の 0.4 s を予測どおりに説明したら）: script と予測（apply の前, 動かさない）
- ★差し替える物★: live 3 種（regress 43beea1_051728 から, live_rebase5.py, 表 = rodhold_s1/s1_live_dry_table.md の dry: ★changed 14・added 2・gone 0・same 19★）= 種 20260925 = live_06・06C・J・RESULT・live.log・AUDIO が changed、★live_03・live_08 が added★（並びが替わりファイトが入った）、種 1 = live_06・06C・live.log、種 26 = live_06・06C・08・live.log・AUDIO。★mock の基準は替えない★（S1 で 30/30 0 px）。apply の後の regress の baseline が PASS なら PIN を新しい pin に。
- ★器の確かめ（観測, 今ある出力）★: S1 の同じ build の live 3 回（regress・s1/plain・s1/steplog）= ★3 種の全部の画が 3 回とも sha 同じ★、RESULT・cast の時刻も同じ = 同じ build は 同じ画を描く = 差し替えの後の regress が 0 px になる前提が立つ。既知の点の数え（live_regress.sh:61-63 known_count）は 引数の数を数える物 = 画が替わっても 引数は同じ = 外れない（読み）。
- script = rodhold_s1/s1_apply.sh（門の内で 1 回）: 木が clean な 43beea1 → ① live_rebase5.py --apply（表と照合）→ ② regress_all.sh → baseline PASS の時だけ ③ baseline_pin.sh。どこで外れても止まる。
- ★予測（動かさない）★: ① changed 14・added 2・新 = 源・pre-s1_ = 旧・3 つの NOTE。② ★RESULT PASS 16/16・SKIPPED 0★（refcheck は PIN の pin がまだ b80715f ≠ db43865 = 回る → 11/11 PASS）、★baseline 30/30 0 px★、★live 3 種 PASS（並び = 新しい基準・画 0 px・音 5b = 新しい基準）★、ほか（build CS 0・git_clean 0/0/0・player / editor / compare 30/30・試験）PASS。③ ★PIN = pin db43865a481439d06d4061245bcc5ba402a80797 ＋ regress <② の id>★（その後の regress は refcheck が SKIPPED に戻る見込み）。
- ★条件の答え（boss1 05:48, worker1 S1_DIFF_W1.md）★: 種 20260925 = 8:21 に旧のフグの到着が新に無い・cast 12 の break 40.1 → 40.9（= Unity の tBreak と同じ）、種 26 = 14:27 に新のフグの到着・cast 42 の break 38.7 → 38.3（= Unity の cast 42 と合う）= #17 のフグの窓の直しの分 = PRESIDENT の条件を満たした。★種 26 の音 wind_frames 157 → 156 と cast 42 のずれの結び付きは frame では測っていない = 推論★（PRESIDENT 06:0x, 種 26 の NOTE にも 1 行）。
- 次: S2 = RodHand.Step を logic の RodHold に切り替え ＋ _lowHeld を消す（PRESIDENT 05:5x: S3 を分けない）。器の穴 2t は 次の小さな番（今回の判定に使わない）。
- ★結果（boss1 05:48 LOCK, 木 43beea1）= 予測の外れで止めた★: ① live changed 14・added 2（新 = 源・pre-s1_ = 旧・NOTE）= 当たり。② regress ★43beea1_054818 = RESULT FAIL・PASS 15/16・SKIPPED 0★: build CS 0・refcheck PASS 11/11（回った）・baseline 30/30 0 px・player / editor / compare 30/30・git_clean 0/0/0 = 当たり、★live FAIL = 種 20260925 の live_08（S1 で足された画）だけ 1 px 違う★（種 1 = 0 px (7)・種 26 = 0 px (8)・3 種とも並び = 新しい基準・音 5b = 新しい基準）。③ PIN = pin db43865 ＋ regress 43beea1_054818（30/30）= script が baseline PASS で書いた。
  - ★その 1 px（観測）★: (697, 726)（筏の側）= 基準 (37, 43, 54) → 今 (43, 50, 64) = ★6〜10 段★。基準の live_08 = 322521d1…（S1 の 1 つの build の 3 回 = 同じ）、今 = 6f52285c…（★同じ木 43beea1 を build し直した 2 つ目の build★）。種 26 の live_08 は 2 つの build で sha 同じ。
  - ★私の外れ★: §7.55 の「器の確かめ」= ★同じ build の 3 回★ だけ = build し直しの揺れ（live_regress.sh:41-59 の既知の点の注が書く『build ごとに 1 段 違い、同じ build では 0』の型）を 見ていなかった。但し 今の 1 点は 6〜10 段 = 既知の点の 1〜2 段より大きい = 同じ型かは 未確認。
  - 止めた: master への merge はしない（PRESIDENT 06:0x の条件 = 16/16 でない）。PIN は 書かれたまま（中身 = mock の基準 30/30 を新 pin で見た regress = それ自体は正しい, 戻すかは boss1 の判断）。
- ★3 つ目の build の測り（boss1 06:03 GO）の予測（回す前, 動かさない）★: 同じ木 43beea1 を build し直し → live を 種 20260925（と 種 26 = 陰性の対照）だけ。(1) ★種 20260925 live_08 の (697, 726) = (37, 43, 54) か (43, 50, 64) の どちらか★ = build ごとの 2 値の揺れ（既知の点の型）。新しい値なら 別の訳（止めて報告）。(2) その点のほかは 2 つの build のどちらかと 0 px（違いが (697,726) だけ）。(3) 種 26 live_08 の sha = 47697630…（2 build で同じだった）。(4) 9×9 の拡大を 3 build で並べ 何の画素かを書く（竿の縁・筏・糸の どれか, 見て決める）。PIN は戻さない。

## 次の番の段取り（控え, 竿の長さの答えの後）
- ★沈みの構え A を入れる番（依頼者 = A: 沈み待ち 70〜80° 下・穂先は窓で読む、竿の長さの答えの後）の中身に 必ず含める（PRESIDENT 09:9x 控え）★: ★mock の基準に 手・沈みの 2 枚を足す（IKADA_ROD_SHOT_HOLD=hand / sinking の撮り, editor と player の両方）★ = 今の mock の基準 26 枚は 受けとファイトだけ = 手・沈みの見た目が壊れても regress は気づかない（§7.44 の 3.3 cm も regress では見えなかった）。足す時は regress_all.sh の BASE_IDS / player_shots の画面の列（worker2 / boss1 の道具 = 所有者の確認）と 基準の差し替え（予測 → dry → PRESIDENT の画 → apply）を一緒に。MASTER_TASKS の 09:36 の控え（boss1）と同じ件。
