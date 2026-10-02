# PR 動画の撮りの木と組み立て（worker3, boss1 2026-10-02 02:0x の担い。計画 = PR_VIDEO_PLAN.md（worker2）、ここは担いの記録と予測）

## 1. 撮りの木 track3/pr-capture（遊べる版には入れない、local, push なし）
- 1e1da97 = master a39407d ＋ track2/demo-capture 59bf65f の merge（LiveHost.cs の衝突 = demo の読むだけの 1 行を `lastSnap = s;` の直後へ〔59bf65f と同じ所〕、master の tip の塊をその後 = 和）。
- 69955ba = e2daba5 の ★cherry-pick だけ★（字の帯を y 2..32 へ、DemoCapture.cs 6/3 行）。e2daba5 の branch は fd1ee42（demo の 2 回目）・bb16e93（竿を上げる）・RodBend の弧の試し 21355bb / 35bb9b1 / 9961201 / 83ecc13 の上 = どれも master に無い（merge-base --is-ancestor で 1 つずつ確かめた）= merge すると全部入るので取らない。
- d2c6940 = `-ikadaDemoHud off`: host.Hud を毎 LateUpdate（DefaultExecutionOrder 10000）で非表示、★HudSetting.On と logic の HudOn は触らない★（LiveHost.cs:194 の SessionConfig.HudOn は HudSetting.On だけ、HudSetting.On を書くのは H の手と env IKADA_MOCK_HUD_OFF だけ）= AutoPilot の HUD の読み（ikada-sim AutoPilot.cs:89-90）は不変。HUD の外の 3 部品（ClutchBadge.cs:91・Stage2HudLines.cs:103・RetrievedSashieLayer.cs:125）は既にある `-ikadaHud off` で作られない = 撮りは `-ikadaHud off -ikadaDemoHud off` の両方。
- 3 部品が logic・入力・snapshot に書く道が無いこと（観測, grep）: 3 file に snapshot の書き・HostInput・InputFrame・Session・driver・LiveHost.・HudSetting.On の書き・Send・Link の当たり 0（陽性対照 = 同じ式で LiveHost.cs 51 当たり）。static は 定数・log の重複止め・`RetrievedSashieLayer.VisibleNow`（読むだけの property、読むのは HudSettingTest.cs:107 の記録だけ）。
- 未 compile（Unity・dotnet の番の外）。Roslyn は Unity の番の最初に。

## 2. 陽性・陰性（撮りの番の最初の 1 本で, 予測 = 回す前）
- 同じ種・同じ窓で 旗なし（A）と `-ikadaHud off -ikadaDemoHud off`（B）: ★RESULT の steps・page・screens が A = B★（同じ run = AutoPilot が変わらない）、`[Demo] HUD hidden on N frames` の N > 0（陽性: 消した）、画の差は HUD の所（左の穂先の窓・右の計器・上の帯・下の札と字幕・クラッチの札）だけ・海と筏と竿は 0 px（陰性）。旗なしの A は今の基準と 0 px（陰性）。

## 3. 組み立て drafts/pr_video/assemble_pr.py
- カットの表（JSON）→ 30 fps の連番（frames = DemoCapture の f の連番を sim の秒から、stills = 静止画のクロスフェード、title = 題の字「筏の涯へ」）→ 字幕（白・薄い影・y 868 中心）→ ffmpeg libx264・yuv420p・crf 18・faststart、音は wav があれば AAC 192k・無ければ音なし（報告に書く）→ ffprobe の 1 行・2 か所に同じ sha256。足りない frame は ★止まる（黙って埋めない）★。
- ★selftest（観測, Unity なし）★: 合成の frame 400 枚・静止画 3 枚・題 2 つ・字幕 2 つ・crop 1 つで 900 frame = 30.000 s・h264 yuv420p 1920x1080・r 30/1・音 0 = PASS。

## 4. 音の口（最初の Unity の試し 1 本, boss1 が番を割り当てる）の予測（回す前, 動かさない）
- 形（案）: DemoCapture に `-ikadaDemoAudio <wav>` = 撮りの窓の初めに AudioRenderer.Start()、毎 frame AudioRenderer.Render(NativeArray) で取り、窓の終わり（か終了）に Stop して 16-bit PCM wav を書く（Time.captureFramerate = 60 の固定時計 = 音も sim の時間に合う、PR_VIDEO_PLAN.md §0 の案）。
- 予測: (a) wav の長さ = 撮った sim の秒 ± 1/60 s（frame の数 / 30 と同じ）(b) 標本 48000 Hz・ch 2（AudioSettings.outputSampleRate・speakerMode の既定、未確認）(c) 無音でない（ambient の海の音が入る = live_regress 5 の配線が wired）(d) AudioRenderer は player の build で動く（editor だけの API ではない、Unity の文書の記述 = 未確認）。外れたら = 音なしで出す か PR_VIDEO_PLAN.md §3 の別 run の案。

## 5. 載せ直しと 音の口の code（2026-10-02 11:2x, Unity なし）
- track3/pr-capture = 18330ac（master e41e21c を merge、LiveHost.cs の衝突 = demo の 1 行を lastSnap = s の直後・master の CastLines() をその後 = 和）＋ ★ee307b0 の音の口★（`-ikadaDemoAudio <wav>`: slow window の最初の frame で AudioRenderer.Start、毎 frame Render〔60 / s の sim 時計〕、窓の終わりか終了で Stop → 16-bit PCM、log に frame 数・標本数・秒・peak）。e41e21c との差 = DemoCapture.cs（新, 159 行）・.meta・LiveHost.cs +6。未 compile。

## 6. 撮りの段取りと時刻の見込み（推論, 依頼者の窓が閉じて LOCK の後から数える）
| 段 | 中身 | 見込み |
|---|---|---|
| 0 | Roslyn（errors 0, 負の対照 1）→ BuildPerf（track3, 前回 23 s）| 3 分 |
| 1 | ★音の試し 1 本★: 種 26・4/20・窓 `780-800`（20 s）を `-ikadaLiveFrames -ikadaDemoAudio -ikadaHud off -ikadaDemoHud off` で | 3 分 |
| 2 | 種 26 の掛け・取り込みの時刻を RefCheck（418b374, dotnet 20 s）で取り直す（22e566a では 792.4 / 865.4 s, 記録の直しで動きうる）| 2 分 |
| 3 | 本の撮り 1 本: 種 26 の窓 = 掛けの −7 s 〜 取り込み ＋4 s（約 84 s × 30 = 約 2,500 枚, 前回 2,730 枚で約 12 分の見込み）＋ 旗あり・なしの陽性陰性（短い窓 2 本）| 15 分 |
| 4 | 静止画: 種 26 の 06 を ShotAt で 6〜8 枚（朝〜夕）・StoryFrom 7-20 / 10-15 / 12-10 の 06 の朝 1 枚ずつ（HUD なし）| 5 分 |
| 5 | 穂先: 06 の穂先の窓の crop が粗ければ 06 の竿の弧が見える frame で代える（画を見て決める）| 3 分 |
| 6 | カットの表 → assemble_pr.py → pr_30s_v1.mp4（ffprobe: h264 1920x1080 30/1 900 frame 30 s, 音 aac 1）| 5 分 |
- ★合計 約 35 分（Unity の番 約 25 分 ＋ dotnet 2 分 ＋ 組み立て 8 分）★。

## 7. 予測（回す前, 動かさない）
- 段 0: Roslyn errors 0（NativeArray は UnityEngine.CoreModule = 追加の参照なし, 推論）。
- 段 1（音）: §4 のとおり = wav の秒 = 撮った sim 秒（20 s ± 1/60 s）、48000 Hz・2 ch（未確認）、peak > 0（無音でない）、AudioRenderer.Start true（player で動く = 未確認）。外れ（Start false・無音）= 音なしで出す（PR_VIDEO_PLAN §3 の代わり）を boss1 へ。
- 段 3: 旗あり・なしで RESULT の steps・page・screens 同じ、`[Demo] HUD hidden on N frames` N > 0、画の差は HUD の所だけ。frame の数 = 窓の秒 × 30 ± 2。
- 段 6: 900 frame・30.000 s・h264・1920x1080・30/1・音 aac 1 本・約 25 MB（PR_VIDEO_PLAN §3 の見込み）。
- ★段 2 の結果（観測, 11:2x, RefCheck 418b374 --seed 26 4/20）★: つつき 787.917 s → 本アタリ（Take）791.817 s → 掛け（HookSet, band 1）792.383 s → LandingStart 859.917 s → Landed 865.417 s = 22e566a の 787.9 / 791.8 / 792.4 / 865.4 と同じ（記録の直しで動かない）。その日 catches 3・hooksets 4（2 匹目の掛け 2565.833 s・Landed 2630.350 s）。events 75dbeaea44599520・numbers 5c4981ab58484a76・frames 539333（= live の種 26 の基準の steps 539212 とは別の数 = live の窓は frame/60 の pilot、ここは照合の frames）。→ 本の撮りの窓 = `785-870`（つつきの −3 s 〜 取り込みの ＋4.6 s, 85 s ≈ 2,550 枚）。

## 8. 音の試し 1 回目の結果と 2 回目（計測）の予測
- 1 回目（観測, 11:23, shots/pr_audio_trial_1123, build ee307b0 系 11:22:34, Roslyn 0・負の対照 1 = 当たり）: AudioRenderer.Start ★True★・48000 Hz・Stereo（未確認だった 2 つ = 当たり）、1200 frame・959488 標本 × 2 ch = 19.989 s（20 s ± 1/60 = 当たり）、★peak 0.0000 = 無音 = 外れ★。HUD hidden 7 frame（> 0）、RESULT ok・Exception 0・600 枚・player 0。
- 読んだ事（観測）: PlayerPrefs に音量の鍵なし（= 既定の音量）、ProjectSettings の AudioManager m_DisableAudio 0・m_Volume 1、★runInBackground: 0★（ProjectSettings.asset）、ゲームの試験は focus が無い時のために runInBackground = true を立てる（KeyTest・PlayerShot など）。
- ★2 回目の予測（計測, -ikadaDemoAudioProbe, 回す前）★: 仮説 = 窓に focus が無い（依頼者が PC を使っている）+ runInBackground false で Unity が音を止める → frame 0〜599: isFocused False・runInBackground False・peak 0、frame 600 で runInBackground true・pause false にした後 peak > 0 に変わる。替わらなければ H4（例: sources playing 0 = この窓で鳴る音が無い / AudioRenderer の取り方）→ その時は sources の数と音量で次を決める。

## 9. v1 のカットと出所（assemble の前, PRESIDENT 11:3x (5)）— 表 = drafts/pr_video/pr_30s_v1.json
| 動画の秒 | カット | 出所（全部 ゲームの画, 木 = track3/pr-capture 4969177 の build 11:34 / 最初の撮りは 5d476ad の build 11:25）| 字幕 |
|---|---|---|---|
| 0.0–4.0 | 夜明けの筏 | player の mock 06（-ikadaMock -ikadaScreen 06 -ikadaDayFrac 0 -ikadaSky Sunny, far = bg_fishing_dawn_clear）HUD・穂先の枠 off。★mock = HUD の値は描かない（HUD off）★ | 夜明けの筏。 |
| 4.0–9.0 | 穂先のアップ | live 種 26・4/20（芦北）785-870 の撮り（HUD off・穂先の枠 on）の 787.0–792.0 s（つつき 787.9・本アタリ 791.8）、左の穂先の窓 x16–503 y166–595 を縦横比のまま拡大（fit） | 穂先が、語る。 |
| 9.0–16.0 | 合わせとファイト | live 種 26・4/20 792-867 の撮り（HUD・穂先の枠 off）の 792.0–799.0 s（掛け 792.4）| 待って、合わせる。 |
| 16.0–19.5 | 取り込み | 同じ撮りの 860.5–864.0 s（LandingStart 859.9・Landed 865.4）| — |
| 19.5–24.0 | 場所と季節 | live 種 1 の物語の日 7/20 芦北・10/15 樋島・12/10 蒲江（湾のカセ）の 06 を ShotAt 40 s（HUD・穂先の枠 off）、1.5 s ずつ・クロスフェード 0.4 s | — |
| 24.0–27.5 | 日誌 | live 種 26・4/20 の日の終わりの J（ShotScreens J）= 釣果 チヌ 40/35/30 cm | 海の一日を、記録に。 |
| 27.5–30.0 | 題 | ★組み立ての字（黒地に「筏の涯へ」, Noto Serif CJK）= ゲームの画でない★（PR_VIDEO_PLAN §1 カット 8 の案）| — |
- 音なし（PRESIDENT 11:3x (1)）。種 26 の 4/20 は一日中曇り・雨 = 朝〜夕の移りのカットは入れない（夜明けは mock の dawn_clear）。

## 10. v1 の結果（観測, 11:4x）
- pr_30s_v1.mp4（drafts/user_review と ~/Documents/ikada-play/pr に同じ sha256 14b7bde43c640bbb4015b4b70af9305366e3f311d45e23172ebc891aa37a4151）= h264 yuv420p 1920x1080 30/1・900 frame・30.000 s・13.7 MB・音 0（決めどおり）= §7 の予測（900・30 s・h264・1920x1080・30/1）当たり、大きさは見込み約 25 MB より小さい（13.7）、音は v1 なし。締め = 撮った題の画面 05（f_000058, t 1.967 s, 左上に 筏の涯へ, boss1 11:41）。
- 撮りの数: 本の撮り 2550 枚（85 s × 30 ぴったり）・旗なしの対照と RESULT 同じ（steps 52229・screens）、ファイトの撮り（穂先の枠 off）2250 枚（75 × 30）、Exception 0。
- ★codex（gpt-6-astra high）の要点と source での確かめ★: 字幕の速さ 1.4〜3.3 字/秒 = 5 字/秒 以下で問題なし・規格に欠陥なし。指摘 (a) 待って、合わせる。が曲がった竿の上 → 確かめ: 字幕の頭 9.4 s = sim 792.4 s = 掛け 792.383 s と同じ時刻 = 合っている（竿が曲がるのはその直後）(b) 季節の 3 枚が 海の一日を、記録に。の直前 = 一日の中の季節に読める恐れ = PRESIDENT の決め (3) の並び → 上申 (c) 締めの 05 はメニューが題と競う = PRESIDENT の決め → 上申 (d) 日誌の字幕と頁の字 → 確かめ: 字幕は本の下の机の上 = 重ならない (e) 縦切り・スマホ・TikTok 広告の音の要件 = 場所が決まってから。
- 画で見つけた 1 つ: 16–19.5 s の取り込みに ゲームの「× 飛ばす」の小さな案内が右下に出る（HUD・穂先の枠の外の UI）= v2 で消すか カットを選ぶ。
- 器の注（自分の外れ）: 今日の「players=0」の多くを pgrep -xc Ikada.x86_64（comm）で取った = Unity は comm を変える = その数は 0 の証拠にならない（各 run は前で終わっていたので実害なし）。以後 /proc/<pid>/exe で数える。
