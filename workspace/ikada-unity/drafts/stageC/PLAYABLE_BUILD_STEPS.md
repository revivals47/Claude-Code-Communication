# 依頼者に渡す遊べる版の作り方（下書き、worker3、boss1 03:39。★Unity なし・build も起動もしていない★、2026-09-29 03:4x）

- 読んだ所（観測）: worker1 の `PLAYABLE_NEXT.md`（§2 の確かめの列 1〜6）、ikada-unity master `1967187da3429e359da59eef6eeef8b50f21239f`（pin `com.ikada.sim#55ddd942…`）の `Assets/Editor/BuildScript.cs:164-194`（BuildPerf = 唯一の build の口、`BuildOptions.None` = development でない = release、出力 `Builds/Linux/Ikada.x86_64`、1920×1080 窓）、`tools/unity-batch.sh`（`exec <Method>`）、`Assets/Scripts/Live/LiveHost.cs:20-33`（-ikadaLive・-ikadaLiveAutoPilot・-ikadaLiveQuitAfterS・-ikadaSavePath none）、前の渡し方 `user_review/c30_play_guide_one_day.md:6-24`（`~/Documents/ikada-play/<sha>/` に丸ごと copy・diff -rq・file 数・byte・folder の sha256・起動 25 s の確かめ・SessionProbe）。
- ★本番は 港の話し手の直し（ikada-sim 0.20.0 の見込み）が master に入ってから★。今の master 1967187 では dry-run だけ。
- script: `drafts/stageC/playable_build.sh <master の 40 桁 sha> [--apply]`（★既定 = dry-run = 読むだけの確かめを流して止まる★）。dry-run を 1967187 で 1 回（03:42、下の §3）。

## 1. 段（1 行ずつ = 何をする／予測／止める線）
| 段 | すること | 予測（推論、数の出所） | 止める線 |
|---|---|---|---|
| 0 前 | PLAYABLE_NEXT.md §2 の 1〜6 を ★この sha で★ 済ませる（regress 15/15 は REGRESS_LIVE=1 で、StoryRun は pin が変わったら） | 全部 当たり | どれか外れ・未実行 = build しない |
| 0 | master = 渡す sha（40 桁）、pin を読む、`~/Documents/ikada-play/<sha7>` が無い、Unity 0、worktree clean、空き 12 GB 以上、folder の sha の計り方の陽性対照（2cb67ab = 75dc972e…） | 全部 通る（dry-run 03:42 で 1967187 は通った） | どれか 1 つ = STOP（script が止まる） |
| 1 | track worktree を sha に detach（前例 = track1、今は track3） | HEAD = sha・porcelain 0 | HEAD ≠ sha |
| 2 | `tools/unity-batch.sh exec Ikada.EditorTools.BuildScript.BuildPerf`（release = `BuildOptions.None`） | `[BuildScript] … result=Succeeded errors=0`・`check_scene_embeds exit=0`・build 後も porcelain 0。時間 約 1 分（今日の 6b8c31d の build 54 s、観測） | Succeeded でない・errors > 0・embed ≠ 0・tree が汚れる |
| 3 | `cp -a Builds/Linux ~/Documents/ikada-play/<sha7>`、`diff -rq`、file 数・byte・folder の sha256・`Ikada.x86_64` の sha256 | diff 空。file 約 176（±5）・約 520 MB（±10%）= 前の 2cb67ab 176 file・519,568,859 byte から（推論）。`Ikada.x86_64` の sha256 は前と同じ a9a83136…（player の本体は変わらない見込み、前 3 回とも同じ = 観測） | diff が空でない・既に dir がある |
| 4a | 起動 25 s（依頼者と同じ command ＋ `-logFile`、HostInput） | `[Live] start api <pin の版> … input=HostInput`・`[Live] screen Title … -> 05`・例外 0 | start の行が無い・例外 > 0 |
| 4b | `-ikadaSessionProbe` で 1 回 | `[SessionProbe] RESULT ok=True api=<版> abi=3` | ok でない・abi ≠ 3 |
| 4c | ★本物の道の 1 日を 1 回（mock なし）★ = `-ikadaLive -ikadaLockstep -ikadaLiveAutoPilot -ikadaLiveSpeed 300 -ikadaSavePath none -ikadaLiveSeed 1 -ikadaLiveQuitAfterS 9200` | `[Live] RESULT ok=True`・例外 0・画面が 05 → … → J（課題の進みの頁）まで。★9200 s は 推論（ReferenceRun の 1 日 = RefCheck 10/15 で sim 約 9013 s）= 初めの本番で 足りたか log で確かめる★ | RESULT ok でない・例外 > 0 |
| 4d | save の dir が 前後で変わらない（`-ikadaSavePath none` と 25 s の起動の両方） | 変わらない（前の版の確かめと同じ、観測の前例） | 増えた |
| 5 | 渡す物の 1 行を boss1 へ = dir・file 数・byte・folder の sha256・`Ikada.x86_64` の sha256・起動の command・4a〜4d の行 | — | — |

## 2. 未閉・注
- 4c の「AutoPilot の日」は 依頼者の遊び方（HostInput）と違う = ★本物の道（mock なし・logic の日）を 通して回した★ の確かめ。依頼者の操作の確かめではない。
- 4a の 25 s の起動は 窓を出す = 依頼者の操作と取り合う（依頼者の許し 01:38 の範囲、LOCK の中で）。log の頭に LockedHint・IdleHint。
- 前の版の dir（2cb67ab・52e33b5・7261648）は消さない（消すのは boss1・PRESIDENT の決め）。
- 空きの確かめは 12 GB（disk_guard の 10 GB ＋ copy 約 0.5 GB ＋ build の Library の揺れ、推論）。

## 3. dry-run（03:42、master 1967187、`LOG=scratchpad/pb_dry.log`）
- HEAD: IdleHint=no LockedHint=no・Runner.Worker 0・load 16.51・df 38,601,584,640 B・DRY-RUN。0: master = 1967187…、pin #55ddd942…。陽性対照: 2cb67ab の folder の sha = 75dc972e…（記録と同じ）。→ 「would 1)〜4)」で止まった（exit 0）。
- 陰性対照: master でない sha（7e8413a…）→ 「STOP: master is 1967187…, not 7e8413a…」、40 桁でない sha → 「STOP: SHA must be 40 hex」（exit 1）。

## 4. pin 3838e10 の後の見込み（worker3、boss1 06:01。Unity なし・読んだだけ、2026-09-29 06:1x）
- 読んだ所（観測）: ikada-unity-track2 `a5acf53`（pin ikada-sim main 3838e10）の `LiveHost.cs:152`・`:346-349`・`:628`、`UiTheme.cs:71-85`（CheckSpeakers）、`SubtitleText.cs:98-103`、`tools/live_regress.sh:92-95`。ikada-sim の CI run 36476156211 の mono job 109110273997 の log（#12 の 4-20 の frames と sim）。
- ★見つけた穴（観測、直した）★: 4c の止める線「`RESULT ok=True`」は 日が終わった証拠にならない = `LiveHost.cs:347` は `TimeS >= quitAfterS`（時間の上限）でも Info の頁（日の終わり）でも 同じ `Finish(0)` = どちらも ok=True。→ script に「RESULT の `simS` < DAY_S（既定 9200）」を足した（上限で止まった = STOP）。陽性対照 simS=9020.3 → 通る、陰性対照 9200.0・9215.6・ok=False・行なし → 5 つとも STOP（観測、合成の行で）。
- 新しい確かめの行（pin 3838e10 の後、表 §1 に足す）:

| 段 | すること | 予測（推論、数の出所） | 止める線 |
|---|---|---|---|
| 4a+ | 25 s の起動の log の `[Speakers]` の行（worker2 の CheckSpeakers、7d8cb97） | `[Speakers] logic names=7 in table=7 missing=[]`（Speaker の enum 7 つ = MentorLines.cs:9、ShishoPhone = 師匠（電話）を a5acf53 で表に足した） | 行が無い・missing が空でない（script に足した。陽性対照 missing=[] → 通る、陰性対照 missing=[師匠（電話）]・行なし → STOP、観測） |
| 4c+ | 本物の道の 1 日が ★Info の頁で★ 終わる | `RESULT ok=True … simS=` 約 8960〜9015 `page=Info`（前の live の 1 日の終わり = workspace の log で simS 8964.5〜9011.5・page=Info、観測。#12 の 4-20 の種 1 = frames 539333・sim 8988.9 s = CI mono log、観測 = LineSlot の直しで日の長さは変わらない見込み〔numbers 不変〕）= ★9200 に 188 s（2.0%）の余り = 足りる見込み★ | simS ≥ 9200（上限で止まった = 足りない → DAY_S を上げて もう 1 回、boss1 へ） |
| 4c++ | ★章の最初の日の宿の行が字幕に出る★（第1章 = 師匠「明日、一番に渡る。お前が釣れ。わしは見とる」、その後に課題の行） | 出る（RefCheck #12 の 4-20 で 待ち 1 → 宿の行が先・課題の行が後、観測は logic 側だけ） | 出ない |

- ★4c++ の読み口は まだ無い（未閉）★: player の log の `[Subtitle]` の行は 画面・kind・rows の数だけで ★字を出さない★（SubtitleText.cs:101）= log では宿の行と課題の行を見分けられない。案（どちらか、boss1 が決める）: (a) `-ikadaLiveShot <dir> -ikadaLiveShotScreens 06C`（最初の 06C の画 = 日の始め）を 4c に足して 字幕の帯を切り抜いて読む（宿の行は 30 s 残る〔DayFlow.cs:125 の minHold 30〕ので 日の始めの画にある見込み = 推論、ただし session の字〔SnapshotBuilder.cs:125〕が上にあれば覆われる = 未確認）。(b) Unity 側に「新しい字幕の字を 1 行」の log を足す（worker2 の場所、code の変更）。
- 注: 4c の AutoPilot の日は 前例（live の log）が 05 → 07 → 06C/06 の繰り返し → Info。種 1 の日付が 4/20（第1章の最初の日）かは 「save なしの新しい始め = 4/20」の推論（`-ikadaSavePath none`）= 4c の log の `[Live] start` と画で確かめる。
