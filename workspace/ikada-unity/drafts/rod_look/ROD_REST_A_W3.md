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
