# 配線dispatch設計案 (boss1、2026-07-09 03:55 最終化)

status: ★上申済 — worker3一括test完了(03:42): cutscene liveness=PASS(condition3充足)、
mechanism分離=principal-shift単独で草原center framing可(最小実装確定)。PRESIDENT GO待ち。

## 確定済み入力(全てcommit保全済)
- 原盤spec: sp3re/workspace/notes/trackA_mailbox_consumer_re.md §0.5(b27c053)
  0x4B=文脈非依存で常時 map-load(byte1=registry idx)+spawn(byte2)+scene-return-push(byte3)、
  20frame timer warp、fade=var[6] gate。0x4F/0x67/0x4A/type6-7 各spec。live確認5項目。
- remake根因: DialogueRuntime.cs OP_WARP_DEST=_warpEmit gate誤bind(trackB2、f21409f)
- load-path: 静的READY、欠落=emitのみ(2d3ed7b)。家=ROOM08(id218)二重根拠
- Gap2: Option A裁定(fy200系center framing)+条件4点(03:40)

## 実装Track案(単一worker直列を推奨 — 変更が全てDialogueRuntime/FieldManager近傍に集中、
## 並走利益より統合リスクが勝る。worktree=sp3継続)

### W1: 0x4B忠実bind(Gap1本体)
- OP_WARP_DEST caseをStep1原則『opcode semanticは文脈非依存で忠実bind、menuは別機構』で書換え:
  常時 MapChangeRequested emit(byte1=registry idx直引き)+spawn選択(byte2)+return-push(byte3)
- menu機構(_warpEmit/_selector/_warpDestIndex)は0x4Bから分離(transporter=entry152系の
  別経路として保持。degradeさせない=既存transporter回帰testを検証項目に含める)
- 20frame timer warp/fadeの忠実度: 初回は即時loadでも可(honest-mark)、fade bracketは
  0x67 wait×2が既に忠実実行されるため視覚上の猶予は既存で一部確保される(未検証、live確認)

### W2: 0x4E mc対策(PRESIDENT必須①)
- 0x4E caseの『!_warpEmit && mc>=2でmenu pause』条件がentry178(0x4B×2、mc=2)で
  spurious pause/hangする潜在riskを排除。menu起動は明示的menu文脈(transporter)のみに限定
- 検証: entry178 headless完走(terminal 0x1315到達維持)+entry152 transporter動作不変

### W3: guard C整合(PRESIDENT必須②)
- terminal 0x4B(204=twna01, mode2, key0xff)忠実実装とStep1 interim guard C
  (空stack 0xFF=script-end→field復帰)の二重遷移/競合を明示解決
- 方針候補(worker実装時にコード実態を見て1本選定、選定理由をdocに):
  a) guard Cを『0x4B未処理時のfallback』に縮退(0x4B emit成功が観測されたらguard C skip)
  b) guard C撤去(※原盤挙動確認とセット、honest-mark済interimの撤去条件を満たすこと)
- どちらでも『field復帰がtwna01+正しいspawnで1回だけ起きる』が完了基準

### W4: awakening framing(Gap2、Option A)
- ★最小fix確定(worker3 mechanism分離済)★: 既存FieldScroll(principal-shift)をcutscene中
  unfreeze+center寄りscroll(principal-Y≈0、fy200系)適用。新規quad-move実装は不要
- 注入点=FieldManager InputLock gate前(cutscene liveness実証済: [FORCESCROLL] log毎frame
  +inputLocked=True中の適用+目視で草原framing、RMSE0.073)
- residual登録(honest-mark、worker3 doc): (i)backdrop coverage/scale較正(exact targetで黒帯)
  (ii)principal-shift X軸(m02)live dead(combined観測、単独X isolation未測定)
  (iii)awakening pin(412,448)exact再確認=原盤DuckStation ref未発見のため次回送り
  (pin正否orscroll較正offの二択未分離。Option A=center framing採用ゆえ進行に支障なし)

## 検証gate(全W共通)
1. headless: CutsceneVerify178完走+terminal到達+§0x37以降のop列不変
2. live screenshot: §0x36→§0x37でROOM08室内bgに切替わること/terminalでtwna01復帰/
   awakening初期framingがfy200系草原
3. 回帰: entry152 transporter menu(現行動作維持)/entry204等の0x4B非含有cutscene不変
4. live確認5項目(trackA §0.5 F): warp完了vs pan frame順序/座標origin/fade視覚/spawn位置/scene-return
5. 完成claimはuser実視覚まで凍結(全員)

## live確認項目(登録済)
- 0x4E spurious menu pause(W2で対策後に確認)
- ROOM08 runtime load(W1検証gate 2で吸収)
- warp/pan frame順序=(183,221)のROOM08-local最終確認
