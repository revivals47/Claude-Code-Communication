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

## ② の code と予測（回す前, boss1 11:48: 順 = ② → ③ → ④ → ①, dotnet は boss1 の合図）
- 読んだ事（観測）: 天気 = Calendar.Get（ikada-sim Calendar.cs:70-88）= 日ごとの流れ RngTree.Sub(worldSeed, Noise, 0xCA100 + n) の u で 晴れ u < 0.45・くもり < 0.8・雨、風 w、強風なら 4 月は 0.5 で欠航。描く空 = SnapshotBuilder.SkyOf(Info.Weather)（:175, :184）= その日ずっと同じ。
- code: 試験 ZzWeatherScan（commit しない, 種 1〜500 の 4/20 の天気、陽性対照 = 種 26 が 雨）→ drafts/pr_video/sunny_seed_scan.sh（晴れ・欠航なしの最初の 30 種を RefCheck 418b374 で、最初の hookset・Landed・catches の表）。
- 予測: 晴れ ≈ 45 %（500 中 約 225）、晴れで欠航なし ≈ 41 %（約 208, 強風 15 % × 欠航 0.5 を引く）、種 26 = 雨（陽性対照）。最初の 30 の晴れの種のうち Landed が 1500 s より前の種は 3 個以上（推論: 種 26 は 3 匹・最初の掛け 792 s）。選ぶ = 掛けが早く・ファイト ≥ 30 s・風 微風（波が穏やかな絵）。

## ③ の済み（観測, 11:5x, 組み立てだけ・Unity なし）
- assemble_pr.py: 各カットに label / labels（日付・場所・出所）→ 組み立てのたびに `<名>_sheet.png` = 静止画は各枚の フェード前のきれいな所の真ん中・他はカットの真ん中を 1 枚、名 = 動画の秒 ＋ label（時刻だけの名を出さない）。selftest PASS。
- pr_30s_v2_draft.json: 季節 = 1 枚 2.0 s・クロスフェード 0.3 s（18.0〜24.0 s）、足りない 1.5 s はファイト 7.0 → 5.5 s（v2 の晴れの種の撮りで差し替えるまでの仮）、合計 30.000 s・900 frame。下書きの sheet = drafts/pr_video/pr_30s_v2_draft_sheet.png（18.8 s 7/20 芦北 = 青空、20.8 s 10/15 樋島 = 曇り、22.8 s 12/10 蒲江 = 夕）。下書きの mp4 は scratch だけ（user_review・ikada-play へは出さない）。

## ④ の code（観測, 12:0x, track3/pr-capture, Unity なし, Roslyn 0）と予測（回す前）
- code: AmbientAudio・FishingAudio に `CaptureTap`（static bool, 既定 false）・`CaptureStart()`（窓の前に溜まった波・きしみ・Snap を捨てる）・`PullAdd(mono, n)`（OnAudioFilterRead と同じ手順を主の thread で, 足し込み）、各 OnAudioFilterRead の頭に `if (CaptureTap) return;` の 1 行。DemoCapture = -ikadaDemoAudio の時だけ CaptureTap を立て（:63）、slow window の毎 frame 800 標本（48000/60）を 2 つから足して × AudioListener.volume、16-bit stereo の wav。AudioRenderer は外した。
- ★旗が無い時は今と同じ（boss1 11:48 の条件）の証し（観測, grep / git diff）★: CaptureTap に書く所 = DemoCapture.cs:63 の 1 か所だけ（-ikadaDemoAudio の枝の中）、2 つの音の file の git diff で 消した・替えた行 0、古い OnAudioFilterRead の中に足した行 = 偽の guard 1 行ずつだけ。★撮りの番での陽性（予定）★: 旗なしの regress（REGRESS_LIVE=1）の live 5（音の判定, AUDIO.txt = 基準）が 今と同じ = 音の数え（fed・wave の数・callbacks の形）が変わらない。
- 予測（撮りの番, 回す前）: wav の秒 = 窓の秒 ± 1/60 s（20 s 窓なら 960000 標本 × 2 = 19.98〜20.02 s）、peak > 0 で 桁 0.1〜0.6（実時間の [Ambient] peak 0.572 × listener 0.8 の桁）、[Ambient] RESULT の wave_hits が 0 でない・callbacks 0（音の thread は作らない）、player の窓は無音。外れ（peak 0 など）= 計測へ（PullAdd の中の chunk の数と synth の counter）。

## v2 の撮り直しの支度（worker3, boss1 04:47 / PRESIDENT 04:5x, text だけ）— 竿の直しの後の形で カットごとに見直し
依頼者の根本の指摘（竿の置き方・ファイトの竿の高さ・リールの向き, PRESIDENT 12:0x）の直し = 合わせた木（track2/rod-combined, ROD_COMBINED_PLAN.md §1）の既定: ★竿受け（待ちは受けに水平）・手に持つ（Drop → 手で穂先 −0.10・横 0.10・lift 0.05 → Bottom で受けへ τ 0.5 s、HookSet/StrikeMiss → 手、次の札で受け, RodHand §15-16）・握り +0.30・ファイトの下限 余白 0.6・糸 iii・リール外巻き★。★撮りは この木が master に入った後★（今の v1 の撮りは 全部 直しの前の竿 = 使い回せるのは 竿の映らないカットだけ）。

### カットごと（v2 下書き pr_30s_v2_draft.json の順, 秒は下書き）
| # | 秒 | 中身・出所 | 竿の状態（直しの後, 推論） | 映る直し | 撮り直し | 確かめ（撮りの時, 予測は撮る前に登録） |
|---|---|---|---|---|---|---|
| 1 | 0–4 | 夜明け = player mock 06（dawn_clear, HUD・穂先の枠 off） | 受けに水平（mock は RodHand を回さない = 受け, RodHand.cs の注） | ★竿受け・外巻き★（リールは画の下の端, 台詞の箱の後ろ = mock は台詞なし） | 要 | 受けの U 字に竿・リールの向き（外巻き）が画で読めるか（下の端で切れていないか） |
| 2 | 4–9 | 穂先のアップ = ★3D の竿先の寄り（v2 ①, -ikadaDemoCam tip）★、種 26・4/20 787–792 s（つつき 787.9・本アタリ 791.8） | 待ち = 受けに水平（Bottom の後, 投の後 数 s で受けへ） | ★竿受け★（穂先は受けの先 0.47 m = 寄りの画に受けの U 字が入りうる） | 要（①の code が先） | ①の寄りの姿勢で 受けと穂先の両方を入れるか・穂先だけか（推奨 = 受けを画の端に入れる = 「置いて待つ」が見える）。near clip が受けにかからないか |
| 3 | 9–14.5 | 合わせ〜ファイト, 種 26 792–797.5 s（掛け 792.4） | 掛けで 手 → ファイトの竿（握り +0.30・下限 0.6・糸 iii） | ★ファイトの竿の高さ・リール外巻き・糸★ | 要 | ★晴れて釣れる種（v2 ②）に替えるか★: 種 26・4/20 は一日 曇り・雨（PR_CAPTURE §2-3）。②の走査（Calendar の晴れ × RefCheck の掛け）は dotnet 未実行 = 次の dotnet の番で。替えるなら 2・3・4・6 を同じ種の 1 run に |
| 4 | 14.5–18 | 取り込み, 種 26 860.5–864 s（LandingStart 859.9・Landed 865.4） | 手（HookSet から次の札まで） | 握り・外巻き | 要 | 取り込みの間 竿が受けに戻らない（RodHand = 手のまま, §16 の予測）・リールの向き |
| 5 | 18–24 | 季節 3 枚 = 種 1 の 7/20 芦北・10/15 樋島・12/10 蒲江 の 06 を ShotAt 40 s | 7/20 種 1 = Drop 7.0 s・Bottom 15.9 s（c177 の観測）→ ★40 s は受け★。10/15・12/10 は ★沈みの長さ 未確認★（深い所なら 40 s で まだ手 = 横・穂先 −0.10） | 竿受け（or 手） | 要 | ★3 枚の竿の状態をそろえる★: 撮りの log の [RodHand] rest at bottom の時刻で 40 s を Bottom の後に動かす（推奨 = 3 枚とも受け = 季節の違いだけが目に入る） |
| 6 | 24–27.5 | 日誌 J（種 26 の日の終わり） | 竿なし | – | 種を替えたら要（釣果が替わる） | 釣果の字 |
| 7 | 27.5–30 | 題 05（題だけの frame は無い = v1 の確かめ） | 竿なし | – | 不要（v1 の撮り） | – |

### 足すかの決め（PRESIDENT へ, 推奨 1 つ）
- ★推奨: 「置いて待つ」を 1 カット足す★ = 依頼者の 1 つ目の指摘（竿の置き方）の直しが 今の 7 カットでは「受けに置かれている」静止の画でしか見えない。足す案 = ダンゴを落とす → 手に持って沈める → 停まって受けへ置く（RodHand の移り τ 0.5 s）を 3〜4 s（沈みの間を切り詰めて 2 区間: 落とす 1.5 s ＋ 置く 2 s）。出所 = 本の撮りと同じ種の 1 つ前の投の窓（Drop と Bottom の時刻は 撮りの log の [RodHand] で取る = 今は 未確認）。入れるなら 1 を 4 → 2.5 s、季節 6 → 5 s で 30 s に収める（下書きの計算, 未組み立て）。
- 入れない場合: 2 の寄りに受けを入れる（上の表）で 置き方の直しは見える。

### 撮りの前に要る物（順, 推論の工数）
1. 合わせた木が master に入る（worker2・boss1, 待ち）。
2. ④ 音の口（track3/pr-capture 99c3760 = e41e21c が元）を 新しい master に rebase（衝突の見込み = DemoCapture・2 つの Audio だけ = 竿の file と重ならない, merge-tree で確かめる）— 10 分。
3. ① 竿先の寄り（-ikadaDemoCam tip）の code — 1〜1.5 h（受けを画に入れる姿勢の 1 枚の試し撮りを先に）。
4. ② 晴れて釣れる種: Calendar の走査（ZzWeatherScan.cs.txt, 試験 1 本）＋ RefCheck（その種の掛け・取り込みの時刻）— dotnet 約 10 分（boss1 の合図で）。種を替えるなら 2・3・4・6 の窓を取り直す。
5. 撮り（Unity の LOCK）: 本の 1 run（窓 = 置いて待つ の投〜取り込み）＋ 季節 3 枚（ShotAt を Bottom の後に）＋ mock の夜明け。音の陽性・陰性（旗なしは今と同じ, ④の予測どおり）。
6. 組み立て（assemble_pr.py, Unity なし）→ 出所の表（各カットの run・秒）→ 一覧の sheet を見てから PRESIDENT へ。
- ★動画は ゲームの画だけ（生成の画・作った HUD の値なし）、カットの出所の表を組み立ての前に出す（規則）★。
