seed 20260925:     194 [StageNHud] tide
seed 20260925:     184 [StageNHud] strip
seed 20260925:      10 [RodHolder] dip
seed 20260925:       2 [TmpFlags] rebuilt
seed 20260925:       2 [TmpFlags] font
seed 20260925:       2 [PrepN] advice
seed 20260925:       2 [Live] start
seed 20260925:       2 [FrameGap] minute
seed 20260925:       2 [ClutchWire] frames
seed 20260925:       2 [Catenary] RESULT
seed 20260925:       2 [Audio] RESULT
seed 20260925:       2 [Ambient] RESULT
seed 20260925:       2 Vulkan PSO
seed 20260925:       2 Processor: Intel(R) Core(TM) iN-N CPU @ N.NGHz, N core(s) @ N MHz 
seed 20260925:       1 [RodHolder] placed
seed 1:     200 [StageNHud] tide
seed 1:     188 [StageNHud] strip
seed 1:      10 [RodHolder] dip
seed 1:       2 [TmpFlags] rebuilt
seed 1:       2 [TmpFlags] font
seed 1:       2 [PrepN] advice
seed 1:       2 [Live] start
seed 1:       2 [FrameGap] minute
seed 1:       2 [ClutchWire] frames
seed 1:       2 [Catenary] RESULT
seed 1:       2 [Audio] RESULT
seed 1:       2 [Ambient] RESULT
seed 1:       2 Vulkan PSO
seed 1:       2 Processor: Intel(R) Core(TM) iN-N CPU @ N.NGHz, N core(s) @ N MHz 
seed 1:       1 [RodHolder] placed
seed 26:     200 [StageNHud] tide
seed 26:     188 [StageNHud] strip
seed 26:      22 [RodHolder] dip
seed 26:       2 [TmpFlags] rebuilt
seed 26:       2 [TmpFlags] font
seed 26:       2 [PrepN] advice
seed 26:       2 [Live] start
seed 26:       2 [FrameGap] minute
seed 26:       2 [FishSurface] shown
seed 26:       2 [ClutchWire] frames
seed 26:       2 [Catenary] RESULT
seed 26:       2 [Audio] RESULT
seed 26:       2 [Ambient] RESULT
seed 26:       2 Vulkan PSO
seed 26:       2 Processor: Intel(R) Core(TM) iN-N CPU @ N.NGHz, N core(s) @ N MHz 
seed 26:       1 [RodHolder] placed

# 種類ごとの 旧行 / 新行（PRESIDENT 00:9x）— 旧 = 基準の dir の pre-shotwait_live.log、新 = Logs/regress/f7af1d2_004153/live/seed_<n>/live.log（worker3）
| 種類 | 行数 旧/新（3 種） | 替わった欄 | 値の欄 |
|---|---|---|---|
| [Stage2Hud] tide | 98/98・101/101・101/101 | frame= だけ（97・100・100 組） | ★潮の字（例「上げ潮・満潮 8:42　潮は緩い」）は全部同じ★ |
| [Stage2Hud] strip | 93/93・95/95・95/95 | frame= だけ | ★gandama・wear 同じ★ |
| [Prep07] advice | 2/2 ×3 | frame= だけ（例 35 → 144） | ★lines=1 など同じ★ |
| [Catenary] RESULT | 1/1 ×3 | frames・main_sag_frames・view_sag_frames（数） | ★値: max_main_sag_m 同じ（0.1905）、max_view_sag_m が 種 1・26 で違う（例 0.0383 → 0.0392）★ = 窓の糸の垂れの最大（描き） |
| [Audio] RESULT | 1/1 ×3 | callbacks（音の callback の回数 = 時間） | ★fed・drag/reel/thumb/wind/creak_frames・snaps 同じ（logic から渡す数）、clicks（377 → 382）・gears（319 → 315）が違う★（音の thread の数） |
| [Ambient] RESULT | 1/1 ×3 | callbacks | ★fed・wind_frames・gust・wave_up/down・tops・creaks_asked・rain/duck/harbour 同じ、peak・wave_hits・wave_smalls・smalls/waves_dropped・wind_chunks・rain_chunks が違う★（音の thread の数） |
| [ClutchWire] | 1/1 ×3 | frames・inverted_mismatch（= frames と同じ数, 前も同じ形） | wire/text_mismatch 0 同じ |
| [FrameGap] minute | 1/1 ×3 | frames・max_ms（2683.4 → 2709.3） | at_s・over1s 同じ |
| [TmpFlags] | 7/7 ×3 | frame=・★bit256（49 → 48）・set_none（110 → 101）★ | added・lookup 同じ |
- ★結論（観測）★: tide・strip・advice = 値の欄は同じ（frame だけ）。★RESULT の値の欄は 一部違う★: [Catenary] max_view_sag_m（描きの最大）、[Audio] clicks・gears、[Ambient] peak・wave_hits ほか（音の thread の数, callbacks の回数と一緒に動く）。logic から渡す数（fed・*_frames・creaks_asked など）は同じ。AUDIO.txt（regress の比べる音の表）は same（dry の表）。
- 全部の組 = livelog_kinds_table_raw.md。
