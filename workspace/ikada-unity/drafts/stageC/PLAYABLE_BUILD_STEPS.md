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
