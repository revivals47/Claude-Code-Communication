# 3 gate 1 batch の 個別検証（worker3 / #461-C）2026-08-16

★★見せるのは 1 回・検証は 1 つずつ★★（boss1 裁定）。★本 doc は ★検証の 側★★。
★user は 呼んでいません★ / ★「arc 完了」と 書きません★。

## 0. ★★既定は ★実測で★ 決めました（演算子から 読んでいません）★★

★何も 設定せずに 走らせた 実測★:

| tag | 行数 |
|---|---|
| `[VISE_BOOTSTRAP]` | ★3★（= ★avatar は 既定 ON★ = #460-C の 反映） |
| `[FIELD-MODEL]` | ★0★ |
| `[VISE_NPC]` / `[VISE_EMIT]` | ★0★ |
| `[SCENE-AUDIO]` / `[AUDIO-PLAY]` | ★0★ |

⇒ ★★∴ 3 gate は 実測でも 既定 OFF★★（boss1 の code 読解と 一致）。

## 1. ★★測定器の 検算を 先に（★これが 無いと 数が 読めません★）★★

★★反復対照（同一 env・別 run）★★:
・★歩行あり × game camera★ = ★★80.678%★★ ⇒ ★★雑音が 信号を 上回る = 判定に 使えません★★
・★★歩行なし × game camera（`POSTCUT_WALK` 無し・`CAPSEC=20`）★★ = ★★0.001%（4 px）★★ ⇒ ★これを 使いました★
⇒ ★★∴ 最初の 測定（歩行あり）で 出た 23.948% は ★雑音の 中★ でした★★
　= ★反復対照が 無ければ 「FIELD_MODELS は 効く」と 誤報していました★

★★私の 測定の 誤り 2 件（自己申告）★★:
1. ★tag を `[A-Z0-9_]` で 抽出し ★`[FIELD-MODEL]`（ハイフン）を 取り零した★★ ⇒ 直して 再測
2. ★`npc-model` を log で 探した★ が ★それは GameObject 名で log ではない★ ⇒ 無意味な 検索だった

## 2. ★① 反転（未設定 vs ON）★

| gate | 次元 | 反転 | 数 |
|---|---|---|---|
| ★`DEGIMON_FIELD_MODELS`★ | 画面 | ★★OK★★ | ★1.935%（5943 px）★ 対 雑音 0.001% ／ 新規 tag `[FIELD-MODEL]` |
| ★`DEGIMON_VISE_VILLAGE`★ | 画面 | ★★OK★★ | ★0.115%（352 px）= 雑音の 100 倍★ ／ 新規 tag `[VISE_NPC]` `[VISE_EMIT]` |
| ★`SCENE_DRIVER`+`WIRE`+`AUDIO`★ | ★音★ | ★★NG★★ | ★★RMS 0.000000 = 1 sample も 鳴らない★★（§3） |

★`FIELD_MODELS` の 画★ = `f_fm.png` = ★★3D の digimon が 2 体 立っています★★（黄 = AGUM 系 / 緑 = 別種）
★対照★ = `f_none.png`（marker のみ）

## 3. ★★③ 音は ★音で★ 判定しました（log で 済ませていません）★★

★算法★ = ★PipeWire の sink monitor を `parec` で 録音し RMS / peak を 出す★

| run | RMS | peak |
|---|---|---|
| 音 gate なし | ★0.000000★ | 0.000000 |
| ★`DRIVER`+`WIRE`+`AUDIO`=1★ | ★★0.000000★★ | ★★0.000000★★ |
| ★★録音器の 陽性対照★★（既知 wav を 同 sink へ 流す） | ★★0.072942★★ | ★0.999969★ |
| ★`+ DEGIMON_SCENE_AUDIO_EXERCISE=1`★ | ★★0.022865★★ | ★0.180908★ |

⇒ ★★録音器は 生きています★★（陽性対照 RMS>0）⇒ ★★∴ 上の 0 は ★本当に 無音★★★
⇒ ★★∴ `DRIVER+WIRE+AUDIO` の 3 つを ON に しても ★この筋書きでは 音は 鳴りません★★★
　（log も ★`SCENE-AUDIO` 0 行★ = ★audio path に 到達していない★）
⇒ ★★但し `EXERCISE=1` なら 鳴ります★★ = `[AUDIO-PLAY] scene33_v0(vol=0.625、len=77.76s)` ＋ ★RMS 0.0229★
　★★但し exerciser 自身が 申告しています★★:
　「★scope=asset 検証のみ / ★0x66 到達は 非検証★★」
　⇒ ★★∴ ★asset と pipeline は 生きている★ が ★実 game path では 鳴っていない★★★

## 4. ★★音源の 母数（★user への 説明に そのまま 使えます★）★★

★wav = 4 本★ = ★`scene33_v0` / `v1` / `v2` / `v3`★
⇒ ★★∴ 「4 場面」では ありません = ★scene 33 という ★1 場面★ の 4 variant★★★
⇒ ★★∴ 音を ON に しても ★鳴り得るのは scene 33 だけ★★★
⇒ ★★「音が 出た」と「音が 揃った」は 別★★（boss1 の 語）= ★材料の 問題であって bug では ない★

## 5. ★② 退路★
・`FIELD_MODELS` / `VISE_VILLAGE` = ★未設定が そのまま OFF★（= 上表の 対照 run）
・音 = ★未設定で RMS 0★

## 6. ★見ていないこと（母数の 申告）★
1. ★地図は mayo00 のみ★（残り 241）⇒ 札 = 材料
2. ★★scene 33 に 到達する 筋書きは 未特定★★ ⇒ ★これが 音の 律速★ ⇒ 札 = 材料
3. ★`VISE_VILLAGE` の 0.115% は 小さい★ = ★この地点では 村人が 遠い 公算★（★別地点 未測定★）⇒ 札 = 材料
4. ★user 実視覚 / 実聴取 は 未★
