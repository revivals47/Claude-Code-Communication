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
