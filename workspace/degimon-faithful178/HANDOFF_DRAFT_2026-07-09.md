# handoff draft: 2026-07-09 home-PC — faithful-178 残gap 2件 解析+配線 full session (boss1作成、PRESIDENT査読用)

## TL;DR
user実視覚(07-09)で確定した覚醒cutscene 2 gap(家転換欠落/初期framing誤り)を、3-worker解析dispatch
→配線dispatch W1-W4で同日中に根治。AI検証全緑+worker1 spec review APPROVE。
★唯一の残gate=user実視覚(05:12未操作timeout=判定未成立、再起動可能状態維持)★。完成claim凍結継続。

## 確定した機構(原盤RE、全machine-check)
- ★Gap1機構=0x4B MAP/ROOM SWITCH★: 無条件map-load(byte1=registry idx)+spawn(byte2)+scene-return-push(byte3=key)。
  full chain=handler 0x800ED774→(-0x6cac/-0x6caa)→signal a1=3→host loop 0x800F02B8→0x800e3da0(20frame timer)
  →0x800E4178 StartScript=無条件load。mode由来load-skip分岐なし。fade=var[6] gate。
  entry178内対称対: @0x7c8=(218=ROOM08家,1,0x36) / @0x130e=(204=twna01,2,0xff)。
- ★remake根因=0x4B誤bind★: DialogueRuntime OP_WARP_DEST=transporter-menu専用+_warpEmit gate(default false)
  →cutscene中emit全黙殺。load-pathは静的READY(欠落=emitのみ)。家=ROOM08(id218、lname48+operand二重根拠)。
- cutscene内mailbox op群=全てcamera+同期(type6=PAN world座標/type7=PAN-TO-ENTITY/0x4A=WAIT-ASYNC/0x67=WAIT-N-FRAMES)。
- ★Gap2★: principal-shift scroll=Y軸(m12)live有効/X軸(m02)dead。6/16診断『bit-identical』は再現せず(旧harness
  未commit=条件差扱い)。quad-move PoCのattributionはcontrol runで反転→さらにguard未配線発覚→v0.3訂正の教訓
  ([[feedback_control_toggle_must_be_wired]]としてmemory化済)。PRESIDENT裁定=Option A(fy200 center framing)。

## 配線 W1-W4(worker3実装、sp3 track3/faithful-178)
- W1: 0x4B忠実bind(cutscene文脈gate=corpus scanでmaterial確定=『EXE単一経路→remake二経路への写像の整合補償』)
- W2: 0x4E menu-open gate明示化(spurious pauseはcf81bf6で既除去、choiceBreak=False実証)
- W3: guard-C縮退 option a(terminal 0x4B優先+fallback、実質=意図明示+log分岐)
- W4: framing center scroll(既存FieldScroll unfreeze、注入liveness実証済)
- 検証: gate1 headless GREEN(baseline同値+emit実値spec一致)/gate2 live PASS AI目視(草原center→ROOM08→twna01
  復帰、oracle 4+1 montage+62shot)/gate3回帰PASS(構造)/gate4部分(0x4F pan=scope外)/gate5凍結遵守
- worker1 spec照合review=★APPROVE(blocker無し)★(byte読取位置EXE一致/byte3を0固定=mis-wiring回避/id空間end-to-end)
- oracle汚染訂正: run_awakening_centered.sh旧③『水辺map』=bug焼込み→新4+1(③家切替+復帰④草原center)
- build provenance=632c497 W1-W4三重根拠(W4 symbol/tip rebuild zero delta/W3固有log)、provenance行更新済(89d1429)

## session中の品質イベント(訂正の連鎖、全て機械決着)
1. byte=20→map-id直join疑い→Track Aがpan durationと断定(誤join回避)
2. boss1 MIHA逆仮説→worker2がlname実引きで棄却
3. 0x47 warp仮説→PRESIDENT機械scanで棄却(entry178に0x47=0件)
4. fade仮説→worker1がtype7=PAN-TO-ENTITYで反証
5. 0x67 semantic不一致→worker2行番号証拠→worker1訂正commit(cross-opcode混同、0x66との別)
6. Track C attribution反転→control run→さらにguard未配線発覚→v0.3(quad-move帰属は未検証扱いで決着)
7. ★worker1 opcode map全撤回★: flat table仮定でband dispatch未読(実base 0x8011b0f8、+0x0Cズレ)。
   boss1 shift説的中+worker2独立同一結論=二重独立決着。既存label無傷。
8. 実質発見は生存: 0x18=TABLE-JUMP(inline table=desync真因)/0x19可変長term chain/
   ★linear scan原理限界→branch-following tracer必須★(spec=trackA2 §3)

## commit台帳(全local、push=HOLD=user専権)
- worker1(sp3re, scene-prog-re, HEAD=0e059a5): 7204c6f/25ed350/136bb4b/b27c053/db10e1a/0e059a5
  docs=trackA_mailbox_consumer_re.md(§0.5配線spec+refinement)/trackA2_0x19_branch_re.md
- worker2(sp3w2, scene-prog-decode): d50829a/f21409f/2d3ed7b/959b0dc/4e473b9/63f9b70
  docs=trackB_gigimon_house_map_id.md/trackB2(orchestrator+mis-bind)/trackB3(corpus scan、tool=scan_0x4b_corpus_v2.py)
- worker3(sp3, track3/faithful-178, HEAD=89d1429): PoC 359d744/32e04c5/c710262/39ba554
  +W1-W4 8c4a946/ede1a93/8fd4246/397a477+shots 632c497+provenance 89d1429+trackC notes(v0.1→v0.3 revision履歴)
- 全worktree tracked=clean確認済(worker1/3、worker2はTrack B系6 commit報告済)

## 次session冒頭
1. ★user実視覚(唯一の残gate)★: run_awakening_centered.sh、oracle 4+1。build/script不触で再起動可能状態維持済。
   PASS→完成claim凍結解除+push判断(user専権、branch/commit台帳は上記)。指摘→worker3系の指摘対応dispatch。
2. follow-up registry(MASTER_TASKS.md末尾): ①branch-tracer(spec=trackA2§3)→entry152完全列挙→W1 gate撤去再評価
   ②0x4F pan配線(pan(183,221)=ROOM08-local説live確認込) ③W1未忠実分(timer/fade/return-stack)
   ④W4 residual(coverage較正/X軸dead/pin exact=原盤ref要) ⑤0x4E live確認 ⑥entry147=ROOM08第3 warp源(低優先)

## 教訓(本session新規、memory反映済)
- control toggleは配線目視まで信用しない(guard宣言≠配線、[[feedback_control_toggle_must_be_wired]])
- band dispatchをflat table仮定で読むと全labelが系統的にズレる — 照合器(worker間相互view)が2度目の捏造级
  事故を未然阻止。二次表照合の成功は一次表baseの正しさを保証しない
- oracle汚染(bug焼込み)は完成判定を静かに壊す — run scriptのチェック項目もRE成果で更新対象
