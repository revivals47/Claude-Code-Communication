# 07 の助言の顔を 話し手の名から UiTheme の表 1 か所で引く（worker3、boss1 06:06・PRESIDENT 06:1x。★code を書く前に登録★、2026-09-29 06:1x）

- 木: ikada-unity-track3、branch track3/face-by-speaker（track2/api-0200 976f1c12a211f6e0587a200348dd230a8c96b47c の上）。

## 1. 全数 grep（観測、Assets/Scripts の *.cs 117 file）
| 種 | 母数 | 場所 |
|---|---|---|
| 顔の画の名の直書き（mentor_bust・*_crop・mentor_try・aniki_v1 など） | UiTheme の表の外で ★2★（陽性対照 = Prep07.cs:273 が出た） | Prep07.cs:273（live の Build、`mentor_bust_gray`）・Prep07.cs:379（AdvicePanel、同じ） |
| 顔を表で引く口 | 1 | Harbour04.cs:33-34（`UiTheme.PortraitOf`） |
| GenArt.Texture / Resources.Load の全部 | 35 行（36 か所、LandingLayer.cs:120 に 2 つ。注の行 IkadaFonts.cs:17 を含む） | 顔は上の 2（Prep07）と Harbour04:46（Portrait = 表の値）だけ。他は背景・魚・手・save の写真・船・font・shader |
| 話し手の名の字の直書き（師匠・兄弟子・船長・常連・通りすがり、UiTheme の表の行を除く） | 12 行 | ★既定の話し手 2★: SubtitleText.cs:94（「：」の無い字の head =「師匠の助言」）・Prep07.cs:383（同じ既定）。★mock の字 9★: MockHarbour.cs:18・MockSnapshots.cs:128・MockPrep.cs:20・:141・:152・MockFight.cs:40・MockJournal.cs:39・:40・MockTitle.cs:71。注 1: PerfSwitches.cs:147 |
- 07 のほかに 顔の直書きは 0 件（母数 = 顔の画の参照 3 か所のうち表の外 2、どちらも 07）。既定の話し手「師匠」2 か所は 顔でなく名（「：」の無い字）= 表を引く形にしない（引く名が無い）、そのまま。mock の字は mock の値（spec/mock_values.md）= 触らない。

## 2. 形（案）
- UiTheme の表に ★07 の顔の列★ を足す: 07 の顔 = 胸から上の小さい画（170×138 の枠）。今の 07 は `mentor_bust_gray`、04 の顔は `mentor_try1`（別の画）= 04 の列を 07 に使うと 芦北の 07 が変わる。→ 列 `bust`: 師匠・師匠（電話）= `mentor_bust_gray`（今と同じ）、★胸の画の無い話し手は 04 の顔（*_crop）を 枠に収める（fit、今の Picture の preserveAspect）★、通りすがり（顔なし）・表に無い名 = 顔なし。
- 07 の話し手 = 字幕の 1 人目の名（SubtitleText.Advice の head と同じ = 「：」の前、無ければ「師匠」）。live は 字幕が変わった時に 顔を替える（枠の中で fit し直す）。
- ★決めてほしい所（見た目）★: 兄弟子などの 07 の顔 = 04 の色の顔（*_crop）を灰色の師匠の胸の横の形に収める = 灰と色が混ざる。画で PRESIDENT に。

## 3. 予測（回す前）
- P1 mock の 07（MockPrep「師匠：…」）= 0 px。mock の回帰 26/26 0 px。
- P2 芦北の日（4/20・7/20・E′）と 島の日 F の live の 07 = 顔は今と同じ `mentor_bust_gray`（Prep の間の字幕の 1 人目 = 師匠、観測 = RefCheck の log、4-20 2000 ms・7-20 3500・E′ 2000・F 3500 とも「師匠：」）。★ただし 07 の画は LineSlot の字の変わり（宿の行）で別に動く = 顔の枠の中が 0 px★。
- P3 蒲江の日 G（12/10）の 07 = 顔が 兄弟子（aniki_v1_crop を 170×138 に fit）に替わる（Prep 3500 ms の字幕 = 「兄弟子：よう来たな…」、観測）。その日の 07 の助言の head = 「兄弟子の助言」（今もそう、変わらない）。
- P4 [Subtitle] の行・[Speakers] の行は変わらない。Roslyn errors 0。

## 4. code と Roslyn（観測、06:2x）
- ikada-unity track3/face-by-speaker = e3bf8a4682219c510bf3c725049ed0a329a096b5（976f1c1 の上、3 file +45 −15）: UiTheme の表に bust の列 ＋ `AdviceFaceOf`、SubtitleText に `FirstSpeaker`（Advice の head と同じ名の取り方）、Prep07 の直書き 2 か所を表で引く形に（live は Build で置き場の順だけ控え、Refresh で字幕が変わった時に 画の名が変わった時だけ作り直す）。Prep07.cs 390 → 406 行。
- Roslyn（bundle_compile8.sh、pin 3838e10、sim ApiVersion 0.19.0）: sim 159・game 117・editor 20 とも errors 0、警告の行 0。陰性対照 --inject-error = game errors 1（InjectedErrorGame.cs CS1525）＋ editor の連鎖 1 = error CS 2 行（976f1c1 の worker2 の数と同じ形）。
- ★挙動の変わり（表の外、予測に足す）★: 表に無い名の 07 は 前 = 灰色の師匠の胸 → 後 = 顔なし（[Speakers] missing=[] の間は logic の話し手では起きない。mock の PerfSwitches の名の差し替えの画では起きうる）。
- Unity の番（画・回帰）は worker2 の取り込みの後に boss1 が出す = 未実行。

## 5. master 03fd8f6 の上に載せ直し（boss1 06:37、観測）
- rebase = b06ae2473ce5548930211a67f94ec48736437bea（親 03fd8f6）。触った 3 file は 976f1c1..03fd8f6 で差 0（git diff --stat 空）、range-diff = 同じ patch（=）。Roslyn b06ae24: sim 159・game 117・editor 20 errors 0。
- ★予測の読み直し（回す前、足すだけ・前の行は動かさない）★: master の live_07 の基準は 宿の行（pre-0200 の差し替え済み）= 1 人目 = 師匠 = 灰の胸は前と同じ → ★live_07 は 顔の枠でなく 画の全体で 0 px の見込み = 回帰 15/15★（前の P2 の「07 の画は LineSlot で別に動く」は 基準の差し替えで吸われた）。種 1 の Prep の字幕は私の log に無い = 宿の行は Lodging の出来事で種に依らない（推論）。mock 26/26 0 px は同じ。蒲江 G の 07 は 回帰の外（画は別に撮る）。
