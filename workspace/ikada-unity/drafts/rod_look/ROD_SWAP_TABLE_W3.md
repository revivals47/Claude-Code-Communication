# 差し替えの表（竿の作り V4・曲がり・糸の横, 合わせた木 = master ＋ 3f7ac9a（dev-pin025）＋ track3/rod-build 13ce74f）— 形と予測（regress の前, 動かさない）
worker3, boss1 19:1x。★Unity・Roslyn なし = 形だけ★。regress の後に 観測の欄を埋め、PRESIDENT が新旧の画を見てから当てる（apply は PRESIDENT の後）。

## 欄の形（regress の後に 1 行ずつ埋める）
| 器 | 画面 | 旧（基準）の path | 新の path | 差の px（全体） | 差の箱 bbox | ★替わる訳（commit）★ | 予測 | 照らし |
|---|---|---|---|---|---|---|---|---|
- 器 = editor_shots（基準 shots/editor/177002a_152845, 26 枚 = 13 画面 × A_sans/B_serif）・player_shots（基準 shots/player/68f766b_113126, 同じ 26 枚, regress の baseline の比べ）・live（3 種 20260925 / 1 / 26 の live_*.png, live_rebase5.py の表）。
- 差の px = cmp_px（unity_direct.sh）、bbox = 差の箱。訳 = 下の commit の記号。

## 替わる訳の記号（既定が替わる commit）
- V = 6ac9bcf ＋ fce80d7（竿 V4: 柄 0.176・座 0.197・金 0.206〜0.25・ガイド 14・太さ 24 倍 ＋ 1.5 px・地を黒）
- R = 8828b78（ガイドの輪 16 → 4 mm 等比）
- B = 6ac9bcf の曲がりの式 1 つ（u^p, p 4）＋ 572e038（満ち 2 N・指数 0.5・窓のばね ×2）＋ 13ce74f（注だけ, 画は不変）
- L = 386e333（糸の横 既定 ON, mock 08 の LineAngleRad 0.5 → 描きの糸が右へ）
- P = 3f7ac9a（dev-pin025: ikada-sim b80715f = API 0.25.0 の logic、画への効きは worker2 の予測による）

## 予測（画面ごと, 回す前）
| 画面 | 竿の 3D | ★予測★ | 訳 |
|---|---|---|---|
| 06（待ち） | 見える | ★替わる★ 約 4 万 px（V4 の 06 vs 177002a = 42,892 px・箱 654,633-1512,1079 と同じ形） | V・R |
| 06C（札） | 見える | ★替わる★ 06 と同じ形 | V・R |
| 06M（中ほど） | 見える | ★替わる★ 06 と同じ形 | V・R |
| 08（ファイト） | 見える | ★大きく替わる★: 竿 V4 ＋ 曲がり（mock 3.8 N は満ち 2 N でも 4 N でも満ち切り = 弧の形はほぼ同じ）＋ 窓のばね ×2（窓の垂れが深い）＋ ★描きの糸が右へ 約 +338 px（c191 の +0.5 と同じ形）★、6 万 px 以上 | V・R・B・L |
| 03（取り込み） | 見えない（写真の頁, 177002a の画で確認） | 0 px（P で替わる物があれば P） | （P） |
| P1・P2（一時停止・設定） | 背景に竿は見えない（177002a の画で確認, ぼかし） | 0 px の見込み（★未確認: 背景が 3D の画の写しなら 竿の所だけ ぼけて動く★） | （V） |
| 05・07・04・J・S0・Z | なし | 0 px（P で替わる物があれば P） | （P） |
| live 3 種（06 系） | 見える | ★替わる★（待ちの竿）、logic の並び（RESULT の page / screens）は P 次第 | V・R（・P） |
| input・key・pad・hud・edge・atlas・git_clean | — | 替わらない見込み | — |
- ★regress は 15/15 にならない★（editor_shots / baseline / compare / live が FAIL の見込み = 差し替えの番）。差し替えの dry = live_rebase5.py の表 ＋ editor / player の 06・06C・06M・08 の新旧の sheet。

## P の行（worker2 が足した、boss1 19:3x「同じ表に P の行を」）— integ/next-build 506dfab の regress（Logs/regress/506dfab_193209/、19:32-19:45）の観測
| 器 | 画面 | 旧（基準）の path | 新の path | 替わる訳 | 観測 |
|---|---|---|---|---|---|
| live 3 種 | 07（支度） | shots/player_live/<種の基準>/live_07.png | 506dfab_193209/live/seed_<種>/live_07.png | ★P = 潮見表（右上「潮　干潮 2:30・14:55　満潮 8:42・21:08」、4/20）★ | changed × 3 種（dry）= P だけ（07 に竿は無い） |
| live 3 種 | 06・06C | 同 live_06・live_06C | 同 | P（潮の行の頭「上げ潮・満潮 8:42」）＋ V・R（竿） | changed × 3 種 × 2（dry）= 2 つの訳が重なる = 潮の行の箱（左上 x 168〜648・y 140〜164）の外は 竿の訳 |
| live 種 26 | 08 | 同 live_08 | 同 | V・R・B・L（竿・曲がり・糸の横）、P は 08 に潮の行が無い（Stage2HudLines は 06 系だけ）= P なし | changed（dry） |
| live 3 種 | live.log | 同 | 同 | P（DevView・潮の行の log、b80715f の欄）＋ 竿の log | changed × 3 |
| player（mock） | 06・06C・06M・08・P1・P2 × A/B | shots/player/68f766b_113126 | shots/player/506dfab_194135 | V・R（・B・L は 08）、★P は mock に潮も段 2 の欄も無い = P で動く mock は 0 枚★ | baseline の差 = 12 枚（この 6 画面 × A/B）= ★P1・P2 は竿の訳（ぼかした後ろ）で動いた = worker3 の予測の「未確認」は 動く 側★、ほか 14 枚 0 px |
| refcheck | 11 本 | refcheck_probe.sh の #16 | 506dfab の player | P（b80715f の logic） | PASS 11/11・control_flipped_fails=True（314 s） |
- dry の表 = drafts/stageD/integ_turn/LIVE_SWAP_TABLE.md（changed 13 = 06・06C・07 × 3 種 ＋ 08 × 種 26 ＋ live.log × 3、added / gone 0）・sheet = integ_turn/live_sheet.png（全部の旧｜新）・P の寄せ = drafts/user_review/c195_integ_tide.png。apply は PRESIDENT の画の後。
