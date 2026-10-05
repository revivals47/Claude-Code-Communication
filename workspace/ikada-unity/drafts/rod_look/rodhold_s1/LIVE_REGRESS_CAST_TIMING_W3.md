# live_regress.sh の『並び』の比べに cast の時刻を足す案（worker3, 2026-10-06 05:4x, boss1 05:43。★書くだけ = tools は worker2 の物、触っていない★）

## 穴（観測）
- 今の 2（tools/live_regress.sh:6-8・:129-134）= RESULT の page= と screens= を文字で比べ、steps と simS は 基準が -ikadaLiveQuitAfterShots の時だけ比べる。
- S1（regress 43beea1_051728）の 種 26 = ★画面の順も steps の合計も同じ（"logic sequence = baseline (screens 104; steps compared: y)"）なのに、logic の時刻は cast 42 から違う★（cast 42 の始まり 8121.8 → 8121.4, その後の cast も時刻がずれる）= 順と合計だけでは 一日の中の時刻のずれを見ない。音の 5b（wind_frames 157→156）だけが それを拾った。

## 案（2t, 2 の後に 1 つ）
- live.log の [Cast] 行（1 cast 1 行, logic の値: cast 番号・placement・tRest・tLand・tBreak・t = 投げの時刻）を 基準の live.log と 文字で比べる。lockstep の live は決まった値ゆえ 許しの幅 0。
- 違えば FAIL "2t: logic timing differs at cast N"（最初に違う cast の 旧 / 新 の行を出す）、同じなら "2t: casts N = baseline"。数（cast の数）の違いも FAIL。
- 形（sketch）: casts() { grep -oE "\[Cast\] day=[^ ]+ cast=[0-9]+ placement=[A-Za-z]+ tRest=[0-9.]+ tLand=[0-9.]+ tBreak=[0-9.]+ t=[0-9.]+" "$1"; } を 基準 $B/live.log と 今の $D/live.log で取り、diff の最初の行を出す。
- 限り: cast の始まりの時刻だけ = 最後の cast の中だけの違いは拾わない（RESULT の simS・steps と 音の 5b が補う）。

## 対照（観測, 今ある log で回した = Unity なし）
| run | 基準 | 結果 |
|---|---|---|
| ★陽性★ S1 43beea1_051728 種 26 | 5e50ac7_s26_014332 | ★DIFF: 最初 = cast 42（t 8121.8 → 8121.4）★ = 今の 2 は通していた所を拾う |
| S1 種 20260925 | ae3b5c4_s20260925_231126 | DIFF: 最初 = cast 12（tBreak 40.09 → 40.85）（今の 2 も screens で FAIL） |
| S1 種 1 | ae3b5c4_s1_231126 | SAME（46 / 46 cast） |
| ★陰性★ 273fecb_032003（基準と同じ pin）種 26 / 1 / 20260925 | 同上 | ★3 種とも SAME★（46 / 46 / 44 cast） |
- = 同じ pin では 0 の違い（偽の FAIL を出さない）、pin が替わった所では 今の 2 が見逃した 種 26 を拾う。
