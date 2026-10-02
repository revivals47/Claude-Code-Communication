# PR 動画 v2 の直しの列（worker3, boss1 11:46・PRESIDENT 11:5x。★支度だけ = Unity なし。撮りは依頼者の感想の後にまとめて★）

v1 = drafts/user_review/pr_30s_v1.mp4（sha 14b7bde4…, PR_CAPTURE_W3.md §9-10）。v2 で直す 4 つ ＋ v1 で見つけた 2 つ（締めの題の frame・取り込みの「× 飛ばす」）。

## ③ 季節の 7/20 が「曇りに見える」の訳（観測, Unity なし, v1 の mp4 から frame を抜いて確かめた）
- ★7/20 の画は青空★: mp4 の 19.6・20.3 s = 7/20 芦北の青空・白い雲（出所 shots/pr_main_1127/t720/live_06_t40.0.png）。20.6〜21.0 s が 10/15 へのクロスフェード、21.0〜22.1 s = 10/15 樋島（曇り・生簀）、22.5〜24 s = 12/10 蒲江の夕。
- 食い違いの訳（推論）: 私の確かめの一覧（v1_sheet）が 21.0 s の frame を時刻だけの名で出した = それは 10/15 の頭 = 7/20 と読まれた見込み。予測と画の食い違いではない。
- 本当の弱さ: 7/20 が きれいに見えるのは 約 1.1 s だけ（1.5 s − クロスフェード 0.4 s）= v2 は 季節を 1 枚 2 s・クロスフェード 0.3 s、一覧の名に日付を入れる。見積り = 組み立てだけ 5 分。

## ① 穂先が、語る。= 3D の竿先の寄り
- 今（観測）: v1 の 4〜9 s は 左の穂先の窓 = TipViewCamera（正射影, 竿の横から, 竿先の layer だけ, TipViewCamera.cs:6）の画の拡大 = 平らな図に見える。
- 案（推奨）: DemoCapture に `-ikadaDemoCam tip`（撮りの run だけ）= Camera.main を 竿先（RuntimeRod の先の transform）の斜め前・約 0.5〜1.0 m に寄せ 竿先と道糸の入水を画に入れる（透視, 描きだけ, logic に触らない）。窓 = つつき 787.9 → 本アタリ 791.8 → 掛け 792.4 の 785-793 s。
- 見積り: code 1〜1.5 h（竿先の transform を見つける・寄せの姿勢・near clip・遠景との兼ね合い）＋ Roslyn・build 5 分 ＋ 撮り 5 分 ＋ 画を見て姿勢の直し 1〜2 回。リスク: 竿先が細く 1920x1080 で 1〜2 px（寄りで太くなるが 揺れが小さいと「語る」に見えない）= 撮る前に 1 枚の静止画で確かめる。代わり = 06 の竿の弧が見える frame（v1 の 12 s の形）を長めに。

## ② ファイトと取り込みが曇り・雨の暗い日 → 晴れて釣れる種
- 今（観測）: 種 26・4/20 は一日中 曇り・雨（v1 の撮りの全 frame）。天気は 日ごとの専用の RNG の流れ（ikada-sim Calendar.cs:3）= 種と日付で決まる。
- 案: (a) Calendar だけを種 1〜500 で回して 4/20（と 5/1・6/1 など春の日）の Weather が 晴れ の種を並べる（1 日を回さない = 試験 1 本, dotnet 約 1 分）→ (b) その種だけ RefCheck（1 本 20 s）で catches と最初の hookset・Landed の時刻 → 掛けが朝の早い時刻（< 1500 s）で取り込みまで続く種を 1〜2 個選ぶ。
- 見積り: dotnet 約 10 分（(a) 1 分 ＋ (b) 晴れの種 20〜30 個 × 20 s）、boss1 の合図で。予測: 4/20 の晴れの割合は 種の 3〜4 割（推論, 未確認）= 晴れで朝に釣れる種は数個見つかる見込み。

## ④ 音 = 合成を sim の時計で直に取る口
- 今（観測, PR_CAPTURE_W3.md §8）: AudioRenderer は Start true・48 kHz・2 ch だが 取った音は 毎 frame 0。ゲームの音は AmbientAudio・FishingAudio の OnAudioFilterRead（実時間の音の thread, clip なしの AudioSource）で AmbientSynth / FishingSynth（1024 標本の chunk, RenderChunk）を回す = AudioRenderer の offline の mix に入らない（Unity の中の訳は未確認）。
- 案（推奨）: 撮りの run だけ（`-ikadaDemoAudio`）、2 つの Audio が 音の thread で合成を回すのを止め（OnAudioFilterRead は 0 を返す）、DemoCapture が 毎 frame（1/60 s の sim）に 2 つの合成から 800 標本ずつ 主の thread で取り出して足し、gain（AudioVolume.Sfx01・listener 0.8）を掛けて wav へ。入力（風・波・きしみ・FishingAudio の Feed）は 今と同じ所から入る = 音の中身は同じ式。
- 見積り: code 2〜3 h（2 つの Audio に「取り出し」の口・二重に回さない guard・chunk 1024 と frame 800 の継ぎ目）＋ 確かめ: (i) wav の秒 = sim の秒、(ii) peak > 0 と 実時間の run の [Ambient] の peak 0.572 の桁が同じ、(iii) 波の音の回数 = [Ambient] の wave_hits と同じ（陽性対照）。リスク: 合成の内部の時計が実時間前提なら 足りない所が出る = 読む物 AmbientSynth.cs・FishingSynth.cs。
- 代わり（推奨しない）: 実時間の run を OS で録る（captureFramerate なし = 絵と音がずれる）。

## v1 で見つけた 2 つ
- 締め = 05 の メニューが出る前の題の frame（PRESIDENT 11:5x）: v1 の撮り（title/frames, 0.03〜1.97 s の 05 が 59 枚）の 最初の数 frame にメニューの前の題だけの画があるかを 撮った画で見た（観測, 11:5x）= ★frame 0（t 0.033）から メニュー（ロケーション選択・エントリーモード）が出ている = 題だけの frame は無い★（live は 05 のメニューの画面から始まる）。v2 の案: (a) DemoCapture に 05 のメニューの部品だけを描かない旗（題の字・遠景の絵は残す）、(b) ゲームに メニューの前の題の頁があるかを source で読む（ScreenRegistry / 05 の作り）。見積り 30 分（(b) を先に）。
- 取り込みの「× 飛ばす」の案内（右下, HUD・穂先の枠の外の UI）: DemoCapture の旗で消すか、案内の出ない frame を選ぶ。見積り 15 分（どの部品かを読む）。

## 合計の見積り（撮りの日の前の code）
- ①④ の code 約 4 h ＋ ②の dotnet 10 分 ＋ 締め・飛ばす 25 分。撮りの番（Unity）= Roslyn・build 5 分 ＋ 撮り（晴れの種で 785-870 相当の窓・竿先の寄り・音つき）約 25 分 ＋ 組み立て 5 分。
