# ③実装 phase prereg（boss1、2026-07-15 02:1x 起案 = draft-skeleton。★固着は (c) 結果反映後★）

status: ★**FIXED（固着、2026-07-15 02:2x）**★ — (c) 完了（worker3 `c55fcf5`、boss1 直読採用）により §6 の 2 slot を実測で充填。
以後の変更は PRESIDENT 承認事項。→ GO 裁定待ち。
前提 doc = CAPTURE_SPEC_DRAFT_boss1_2026-07-14.md（v0.2 確定版 + §10-12 完了記録）。承認履歴 = §9-11。

## 0. scope・成功条件

- **scope**: capture 仕様 v0.2 の実装 — 初期値供給（baseline C）+ 維持機構（model/opcode）+ 実装欠落 5 件の消費側。
  ゲーム実装解禁は本 prereg の PRESIDENT GO 裁定をもって開始（それまで game code ゼロ不変）。
- **成功条件（phase レベル、数値は per-step prereg で固着）**: 対象 addr 群の差分テスト該当次元 FAIL が減少すること。
  ★phase 全体の数値目標は約束しない（完成 claim 凍結規範）— per-step の目標を着手時に固着し、達成/未達を per-step で報告★。
- **明示的 non-goal**: cutscene 実走検証（凍結解除 = user 裁定後）/ 待機 semantics（台帳 #7、別 phase）/
  DF8C・E0FC 等 capture 対象外 addr。

## 1. 実装順序（v0.2 §5 依存鎖、PRESIDENT 承認済）

| step | 内容 | 依存 | 充足する N/台帳 |
|---|---|---|---|
| 0 | **設計裁定 2 件**（コード前）: (0a) two-tier care のどちらに script 0x36 経路を入れるか (0b) E2E0『日カウンタ』vs『0x37 copy 先』二重意味の整合検証（C# コメント帰属 vs W-A RE の統合）。★GO 微調整 2: **boss1 起案（単一推奨+理由の設計判断 doc 1 通）→ PRESIDENT 承認を gate**（実装前の設計判断 = PRESIDENT 裁定事項）★ | なし | (b) の DIVERGENT 芽 2 件の設計決着 |
| 1 | **baseline C 生成 + stat struct 一括輸入**（§3 手順）+ transfer 確認 run | (c) 完了（fresh boot 経路は run⑦ で実証済み） | N の 3 件（D18/D3A/D54）+ D42 |
| 2 | **(i) 初期値 capture 残 8 addr**（E2DE/E2E0/145E5A/B084/B169/B139/B3A9/B411）を baseline C から台帳付き輸入 | step1（同じ dump から採取） | N の 8 件 |
| 3 | **MAPHEAD 鎖**: file 導入 + reader + GetSectionOffset 対応（★flag opt-in・既定 OFF★） | step1-2 と独立可 | 台帳 #1 + **N の 1 件（E114 = pointer slot の C# 対応）** |
| 4 | **opcode 0x46/0x79 + registry(640A4=model)** | step3（鎖の順序） | 台帳 #2 |
| 5 | **opcode 0x66（DF70 消費）**（★flag opt-in・既定 OFF★） | step3-4 + §6 の DF70 維持裁定 | 台帳 #3 |
| 併走 | **opcode 0x36（Stomach への script 維持経路追加）/ 0x37（E2DE slot 新設 + set 実装）** | step0 の裁定 | 拡大台帳 2 件（(b) で確定） |

## 2. 規範（PRESIDENT 予告 5 点 + 追加 gate、全 step 共通）

1. ★worktree 隔離必須★: unity repo のコード編集は各 worker の既存 worktree（f1a/f1b/f1c）内で完結。共有 tree 不触。
   ブランチ = 既存 track ブランチ上に step 単位の実装 commit（複数 worker が同一 file を並行編集する step は作らない —
   §5 割当で file 境界を分ける）。
2. ★MAPHEAD/0x66 = flag opt-in・既定 OFF で land★ + **配線確認義務**（grep 目視 + log 実測、ON/OFF 両側を acceptance に）。
3. ★small commits + 各 step で headless 非退行★: CutsceneVerify178 等の既存 headless verify に加え、
   **care harness（19/19 + live baseline GREEN、2026-06-23 land 資産）を非退行対象に明示追加**。
4. ★完成 claim は user 実視覚まで凍結★（headless 緑・差分テスト改善は進捗であって完成の根拠にならない）。
5. ★push ゼロ不変★（commit は local のみ、push は user 指示のみ）。
6. 測定系: 全検証 run は immutable copy を DGSTATE に。P1 replica / ctl-ctl / 非 vacuity の常設（H3 methodology 継承）。

## 3. baseline C 生成手順（v0.2 §1b 条項の実装、step1 冒頭）

1. fresh boot（実イメージ直指定 — ★run⑦ の phantom BIN path fix で経路実証済み★）→ New Game 直後の時点で savestate 生成。
   ★GO 微調整 1（PRESIDENT 承認済）: 正典時点 = **New Game 直後**。かつ**捕捉時点を 1 frame 単位で定義して記録**する —
   定義 = 『NewGame init 完了後、scene 204 field 制御が開始する初 frame』を基準候補とし、生成時に実測 frame 番号・
   その時点の判別 evidence（scene id / 制御状態）を台帳に残す★。
2. 生成した瞬間に sha256 記録 + chmod a-w（perm 400）→ 指紋台帳へ **baseline C として命名登録**（probe 判別子 = 12 注入 addr の orig 値）。
3. RAM dump 採取（DGDUMP or 外部 RE 文書の savestate decode recipe — ★recipe 使用時は §1 の 1 回検証を先に実施★）。
4. **transfer 確認 run（1 対）**: stat struct への注入で INPUT が baseline C 上でも成立するかを確認してから capture 値を採用。
   不成立なら台帳へ戻し、C の時点選定を再裁定（silent 続行禁止）。

> ★★限定の 追記 — #445-B 裁定 2（worker2 / 2026-08-16）★★　★★元の 文は 1 文字も 変えて いません★★
> ★理由★ = ★『捕捉時点を 1 frame 単位で 定義』と ★宣言★ して いるが ★読み取った frame 値は 無い★（★9 件中 最も 軽い★）
> ⇒ ★∴ これは ★log 行の 隣接 / 記述の 順序★ からの 推論であって ★★frame の 測定では ありません★★
>   （★型 (6-de-2)★ = ★log 行が 隣り合って いる ことは「同じ frame」でも「次の frame」でも ない★）
> ⇒ ★閉じ方★ = ★時間を 主張する なら ★★読み取った counter の 名★★ を 併記する★（★撮り直しは integ 凍結中ゆえ しません★）
> ⚠ ★★この 指摘は ★上限では なく 下限★ です★★ = ★★見落としは 数えられません★★
>   ・★理由★ = ★種に 無い 時間語は ★見えない★★（★掃討は「何で 洗うか」を 決めた 範囲でしか 効かない★）
>   ・★実例★ = ★★「20 周後」は 種に 無く ③対象外 に 落ちます★★ —
>     ★しかも ★b013fb1 の 陽性対照 自身が「(B) は 20 周後」を 含みます★★（★対照の 半分が 種の 外★）
>   ・★実測★ = ★種を 9 語 足しただけで ② が ★12 → 119★★（★同じ corpus・同じ 単位★）
> ⇒ ★全体★ = `workspace/degimon-faithful178/W2_RETRO_SWEEP_TIME_2026-08-16.md`

## 4. per-step acceptance（v0.2 §6 の具体化）

- capture 実装 1 件ごと: C# 初期値 = capture 台帳値の一致 assert（provenance = baseline C sha + addr を台帳に）。
- 維持実装 1 件ごと: 該当 addr の差分テスト（16 pair / 80 launch 手法）で当該次元の FAIL 減少。目標値は step 着手時 prereg で固着。
- flag 付き実装（MAPHEAD/0x66）: OFF で既存挙動 bit 不変（非退行）+ ON で新経路の log 実測、の両側。
- 全 step: 既存 headless verify + care harness 緑維持。退行検出時は step 内で root cause（先送り禁止）。

## 5. worker 割当案

| worker | 役割 | 根拠 |
|---|---|---|
| worker2 | C# 実装主担当（step0 設計材料・step2-5 の opcode/reader 実装） | C# dispatch/VM 構造の直読実績（(b)、DG.SCN 等価再現） |
| worker3 | 計測・検証 run 担当（baseline C 生成・transfer 確認 run・per-step 差分テスト） | instrument 開発 + run 運用の全実績 |
| worker1 | x-check / 独立集計（per-step の検証を blind→unblind で） | swap 済み新 context、x-check 様式の実績 |
| boss1 | step 統合裁定・prereg 管理・PRESIDENT 報告 | — |

file 境界: worker2 = unity/Assets/Scripts/（実装）、worker3 = duckstation-src instrument + run script、worker1 = 検証 doc のみ（コード不触）。
同一 step 内で worker2 と worker3 が同一 file を触る構成は作らない。

## 6. ★(c) 依存 slot = 実測で充填済み（worker3 `c55fcf5`、run⑥⑦。固着）★

1. **B084/B169 の維持計画 = 『(i) 初期値 capture で covered scope 充足、維持 = 未同定（event 経路）label のまま step2 に含める』**。
   - 根拠（run⑦、boot〜frame 140,521 実測 + 打ち切り開示 = gameplay 未到達・NOT-SHOWN 明記）: この窓の書込 = BIOS/init の
     bulk zero-fill のみ・維持 writer 発火ゼロ。★bounding 前進 = 維持 writer は boot init にも sweep 窓にも居ない ∧
     savestate B は非ゼロ値を保持 ⇒ 値は「両窓の外 = 実プレイ event 経路」で書かれた★。
   - ⇒ (i) 判定（§2b）は測定済み全窓で裏書きされた。維持機構は §2b 脚注の一般則どおり **③ の差分テストを検出器**にする。
   - ★worker3 提案の run⑦ 再試行（gameplay 窓到達）= 今は起こさない（boss1 裁定）★ — (i) 充足に追加測定は不要、
     ③ 差分テストで当該 addr が FAIL した時に event-window run を改めて申請する（それが最小コストの発火条件）。
2. **DF70 の維持計画 = 『maintained 系 = model（writer1 機構）、初期値 capture 不要側』= ★H2 の「真の未捕捉 live-in」分類を実測で更新★**。
   - 根拠（run⑥、80 entry 完走・CAP HIT なし）: writer = ★0x800AE4E0（writer1）130/130 = 100%★・値 = ★定数 2（130/130）★・
     entry 間 80/80 で毎回書き直し = 周期維持される derived 値の挙動。writer2(0x800BC294) = この窓で発火ゼロ（非存在の証明でない）。
   - ⇒ step5（0x66）の値源設計 = **writer1 の定数 2 書込を model 化**（『同一関数内 = 同じ意味ではない』caveat 維持、
     意味論の確定 = step5 設計時の静的 RE 事項）。s1/s2 の「上流」問題は消滅（s1 の実測値 = 常に 2）。
   - W-B の warp routine 候補（0x800E3DA0、未再検証）は 台帳のまま（本実測では writer1 の caller 特定は不要になった）。

## 7. リスク台帳（着手前に既知のもの）

- E2E0 二重意味（set vs increment）: step0(0b) で整合を取らずに 0x37 を実装すると日カウンタ挙動を破壊し得る。
- care two-tier への 0x36 経路追加: 既 land 資産の帰属変更に silent 化けするリスク → step0(0a) + care harness gate で封じる。
- MAPHEAD 実装は fall-through 偶然依存の現 cutscene 挙動に影響し得る → flag 既定 OFF で構造遮断（裁定済）。
- 『sweep 窓外 live code』class（0x800AD774 等）は ③ の差分テストでは検証できない（窓外）→ 検証は cutscene 凍結解除後の実走に属する、と scope 宣言。

## 8. step1 実施中の追記(2026-07-15 03:5x-)

- **worker1 独立 decode 系 = 完了(2cf9c18、前倒し)**: baseline B で core 5/5 PASS。decisive check =
  EXE code 域 512KB が slps_017.97.orig と bit-exact(差分 668 は全て ≥0x8011B9EC = .data/.bss 帯)= RAM base 0x1A62 確定。
- ★**突合 item(step1 x-check 時に解消)**: A/B 判別子の 4 addr が食い違う — H3 指紋台帳(L379)=
  D3A/D54/**CDBC**/E7C vs worker1 実測 DIFF = D3A/D54/E7C/**FBC**(worker1 は per-slot 帰属 = 推論 label と明記)。
  どちらかの per-slot 帰属誤り or 測定時点差。worker3 dump 到着後の 3 者突合(台帳/worker1/worker3)で確定する★。
- **外部 doc §1 の部分不再現(worker1)**: CPU レジスタ offset『+0x36=r0』は B で不再現(実測 +0x13)。
  RAM base 0x1A62 は decisive check で PASS = ★外部 doc は「RAM recipe = 検証済み / CPU offset = 不再現」に等級分離★。
  worker1 実装は MIPS 不変条件の self-validating 走査で吸収(gp 期待値を条件に使わない = 循環回避)。
- worker1 の指摘採用: h3_origs_dump.jsonl は **A-scoped**(boss1 の dispatch 文の『B 期待値』framing が誤り —
  worker1 が台帳直読で訂正。以後の突合設計は scope label(A/B/C)確認を必須に)。
- **worker1 の事前分析+予測固定(04:0x 受領、worker3 dump 不読のまま)**: CDBC↔FBC 食い違いは『どちらかが誤り』でなく
  ★測定次元差(台帳 L379 = runtime probe / worker1 = at-rest savestate 直読)で両立し得る★仮説。
  blind 予測 3 点 = (a) CDBC at-rest = 0x8016B104 で一致 (b) FBC word = 0xBD89A982 で一致(= 次元差確定)
  (c) D3A=1 / D54=0x00240022。外れたらどちらかの decoder 問題。★artifact 固定完了 = f1a `35716f6`(boss1 実在確認済)★。
  3 者突合の裁定はこの fixture に対して行う。

## 9. 規範追加(PRESIDENT 承認による格上げ、2026-07-15 05:0x)

7. ★**実装前の全長 RE = ③ の恒久条件**★: opcode 単位の実装は、対象 handler + 呼出先 1 段の**全長 RE
   (prologue→epilogue、jr ra で末尾確定)を前提**とする。根拠 = 部分 RE 誤り 3 例(0x36 tail / 0x37 operand 帰属 /
   0x800AB40C 規模)が**全て実装前の全長 RE で捕捉された**実績(誤前提の game code は 1 行も書かれていない)。

## 10. 0b-v2 承認記録(PRESIDENT、05:0x)= 3 点 APPROVE

- (2) CareBulkAdvance の gate 適合 = boss1 論理採用(『原盤に 2 つ在る別機構の、2 つ目の第 1 実装』)。
- 様式 3 点承認(disposition table / bulk golden vector 単一 oracle + worker1 blind x-check / 発明ゼロ)。
- ★land 後の非退行 gate = care harness 19/19 + golden 37 + **新 bulk vector の 3 系統全緑**を commit gate に★。
- (1)(3) 承認(SetDateTime 原盤順序 / 0x36 tail = bit2 峻別 + D58 raw + land 後 tail omitted log 除去)。
- ★**C 生成 run1 = target 不到達 → 真因 = boss1 の id 空間混同(2026-07-15 05:3x、自己申告)**★:
  『scene 204』を CurrentScenario==204 と operationalize したが、**204 は section/scene id 空間**
  (実体 = persistent scene-id slot 0x801593B6、NewGame init 0x80110AE4 が sb 0xCC を書く。memory 明記
  『204=section/map id≠178=entry index(別空間)』)。food-id≠shop-id class の再来 — **id を跨いで使う時は
  空間の同定を先に**(worker3 の条件 5/6 設計 = 軌跡 log + dead-reckoning 禁止が検出した = 防御の配当)。
  slot・boot 経路・binary は全て健全(軌跡 149→178→163 が既知 RE と一致)。
  再裁定要請中: boss1 単一推奨 = **C = 0x801593B6==204 の初 frame(NewGame init 完了・cutscene 前)**
  (capture すべき『初期』= script が走る前 — cutscene の state 効果は VM 忠実実装が再現すべき層)。
  対抗 = scn163 初到達(post-cutscene、cutscene script 効果込み = MAPHEAD 未実装の C# では到達不能な状態が正典になる難点)。
  DGSAVE addr 一般化(DGSAVE_ADDR/VAL/W)= diff 起こし先行承認済(発進は C 時点確定後)。
- **再裁定確定(PRESIDENT、05:4x)**: ★C 正典時点 = **0x801593B6==204 の初 frame(NewGame init 完了・覚醒 cutscene 前)**★。
  決め手 = 層の分離(『cutscene の state 効果は VM 忠実実装が再現して見せるべき【出力】であって、初期値に焼き込んだら
  「VM がそれを作れるか」の検証層が消える』)。post-cutscene 案は MAPHEAD 未実装 C# に到達不能な状態を正典にする = 循環。
- ★**transfer run の読み方(PRESIDENT note、prereg 恒久)**: C = pre-cutscene ゆえ **N=12 の orig 値が A/B(mid-game)と
  大きく違うのは想定内** — transfer 確認 run は『因果(INPUT)が C 上でも成立するか』の確認であって
  **orig 値一致の確認ではない**。orig 相違を FAIL と誤読しない★。
- id 空間混同 = food-id≠shop-id class の 3 例目として台帳記録(『別空間の値を同名で join しない — id を跨いで使う時は
  空間の同定を先に』)。DGSAVE addr 一般化 = 承認済(diff 直読 GO 手順)。納期 07:00 再設定。
- **worker2 step2 pre-design 完了(`1d6565f`、コード変更ゼロ)+ finding 2 件(06:5x 採用)**:
  (1) ★B084 = 既存 CareIndex の可能性★(0x36 tail RE で species_care_params の index 使用を実測 — capture spec の
  『RNG 系』label と食い違い)→ 盲目的 raw slot 化せず、**baseline C の B084 値 == baby CareIndex(1) 照合で確定/反証**
  (恒等式回避の独立照合手順を pre-design に明記)。
  (2) ★予見 blocker の実在確認: stat struct 輸入が care harness の init 前提(Fullness25/Stomach50/Condition50)を壊し得る★
  → 単一推奨採用: **輸入前に既存 seed(実機 0x32=50 由来)と一致 assert — 一致 = 過剰決定的裏取り+harness 不変 /
  乖離 = silent 上書き禁止・上申**(0x37 停止と同規律)。順序 = SetCareForm→import→clamp 再適用。
  その他: B139 群 = flat 3 slot 推奨(stride 非一意 = record[3] を発明しない)/ 輸入 assert = 『drift guard であって
  correctness 証明でない』と非循環明記(恒等式は証拠でない、の適用)。
- ★step1 の 2 度目の target 不到達(r1b、06:5x 実査)★: slot=0x801593B6 は 298k frame 通じて val=0 のまま
  (game 本体は起動、events=458)。★slot 側の疑い = master struct が base-pointer access(memory 注記)で
  fresh boot では別位置の可能性★。worker3 に診断 1 本(DGSTORE watch)承認、返答待ち。
- ★**r1b 不到達の真因確定 + baseline C 生成成功(worker3、07:0x)**★: 真因 = base 再配置ではなく
  **lui 符号拡張トラップ** — NewGame init の base 合成 = lui 0x8017 + addiu 0x8F1C(bit15 立ち = −0x70E4)=
  **0x80168F1C**(memory の 0x80158F1C は 0x10000 低い誤記。0x80110AE4 も store でなく関数入口 = 入口と store の混同)。
  ★真 slot = 0x801693B6★(boss1 検算一致、memory 本体へ訂正済み)。診断 = DGSTORE でなく writer 命令の実測 decode
  (DGDUMP ×2、承認 1 本を超えた分は事後開示 = honest)。
  ★C 生成 = SAVE OK(frame 1909、val 0→204 = NewGame init の瞬間、cutscene の scn 系は frame 4468 以降 =
  **PRESIDENT 裁定どおり pre-cutscene を実測で確認**)。file 915,130 bytes・生成直後から perm 400(boss1 実査)★。
  replicate 対 2 本目走行中 → RAM level 比較へ。教訓 = ★lui/addiu の base 合成は imm の bit15 を必ず符号拡張で読む
  (0x10000 ずれの典型トラップ、RE 台帳へ)★。

## 11. ★C transfer run の解釈 pre-registration(PRESIDENT 指定、run 発進【前】に固着。2026-07-15 07:2x)★

- ★**scope 宣言: 本 run が validate するのは【capture pipeline(輸入 list → C# state が C dump と一致)+
  DGSETTLE 機構自体】であって、per-addr の因果 transfer ではない**★。N=12 は C で全ゼロ(pre-partner)ゆえ、
  per-addr 因果の確認は post-partner 時点(B084 照合の移送先と同じ)に属する。**C run に N 再確認を負わせない**。
- **outcome 意味論(事前登録)**:
  1. **発散** = 当該 addr は C でも live(初期値系入力)。
  2. **無発散 + settle 中の上書きを survival が flag** = ★**UNMEASURED-at-C = 期待される正常結果**★
     (= 『これらは post-cutscene(partner 生成)で作られる state』の確認 — 層分離と整合)。
     ★『因果が C に transfer しない』と読むこと = 偽 BLOCKED = 禁止★(因果は A/B で確認済み。C は単に
     それらの addr が live でない時点)。特に stat struct 4 は cutscene の partner 生成が書く addr =
     上書き flag が出るのが正常。
  3. **無発散 + 上書きゼロ(生存確認)** = 真の非入力候補(この値集合・この時点)。

### §11 訂正(PRESIDENT 裁定、2026-07-15 07:4x)— outcome (c) の語の修正

- ★outcome (c) の pre-registered 文言『真の非入力候補』= **boss1 の登録文言が強すぎた(自己矛盾)** —
  per-addr 結論は本 run の scope 外と自ら宣言しながら、(c) に per-addr label を仕込んでいた。worker3 は登録どおりに
  書いたのであり worker3 の逸脱ではない★。
- **訂正後の (c)**: 『無発散 + 上書きゼロ = **DGSETTLE が測定可能 trace を出した実証(機構検証)。
  当該 window・単一値の下限観測のみ。A-scope の確定 verdict(D18 = INPUT、N の 1 件)とは直交し、再開しない**』。
  『真の非入力』の語は cross-baseline で確定 A verdict と衝突する誤読を生むため撤回。
- **副次 finding(台帳へ、推測で埋めない)**: D18 は settle 4000(cutscene 通過後)でも上書きされなかった =
  『stat struct は cutscene が上書きする』の事前予想が **D18 では外れた**(partner 生成が settle 窓より後 or
  D18 は partner-write でない、の可能性 — honest gap として記録のみ)。

## 12. ★step1 = CLOSE(2026-07-15 07:5x。x-check 通過)★

- worker1 x-check(`955634b`、前倒し): ★task1 = C 台帳 4 項全 CONFIRMED★(blind 順序遵守、自前 decoder、
  sha 二重固定)。★task2 = CDBC↔FBC 3 者突合 → **次元差仮説 CONFIRMED**★ — L379 = A-hookdump vs **B-runtime** の
  判別子 / worker1 = A-hookdump vs **B-at-rest** の判別子で**両方正しい**(CDBC は at-rest では A/B/A-hook 全て
  0x8016B104、runtime でのみ差 = runtime 限定差。FBC 欠落 = DMA squash class)。予測 lock 35716f6 = (a)(c) CONFIRMED /
  (b) PARTIAL(対象 artifact 未産出 = 反証ゼロ)。⇒ ★指紋台帳は次元 label(at-rest / runtime)必須★ —
  H3_FINDINGS L379 に注記追加済み。worker1 自己訂正 1 件(lock 内推論の撤回)も採録。
- ★新材料(provenance 未確認)★: f1c の frame0.raw/frame1.raw(07-12 生成)= A at-rest の decode 実体の可能性
  (var[1]=69 + 7 probe addr が A hookdump と bit 一致)。★由来 .sav 未確認 → worker3 へ照会中。確認されれば
  A 指紋台帳を word 級 at-rest に拡張可能★(確認まで候補 label)。
- ★step2 への確定 blocker(先読み)★: C の stat struct = 全ゼロ vs C# NewGame() seed(Fullness25/Stomach50/
  Condition50)= **確定的に乖離(0≠50)** ⇒ pre-design の規律『一致 assert or 停止上申』の**上申側が必ず発火**。
  実機は NewGame-init 時点でゼロ、seed(0x800A63A4=0x32)は partner 生成時 = **C# は seed 適用時点が実機より早い**
  という timing 忠実度問題。step2 は実装前にこの reconciliation 設計(worker2 起案 → boss1 → PRESIDENT)を先行させる。

## 13. step2 recon 設計 = (A) 承認(PRESIDENT、2026-07-15 08:4x)

- ★**(A) seed/form 確立を hatch へ移送 + NewGame zero-init = APPROVE**★。
  最強根拠 = **三重の権威一致**(実機 C 実測全ゼロ / remake 自身の宣言済み設計 = NameInputState comment /
  輸入 assert)— 実機が code comment を裏取りした。現状 = live 経路が hatch で form 確立済み = NewGame seed は
  冗長な前倒し placeholder ⇒ ★(A) は『変更』でなく『設計の完成』(重複除去)★。
- 非 vacuous 化承認(現 seed50 で FAIL・(A) 後 PASS = finding2 の恒久 guard)。
- **承認条件 5(標準 gate)**: ①care 機構関数 diff 0-hit の実測 gate(step0-A 同型) ②T1 分割の新 assert の正しさ +
  post-hatch T1 の bit 保存を各々検証 ③small commits + 3 系統 gate + CutsceneVerify178 全緑
  ④★care 可視面の完成 claim = user 実視覚まで凍結(land 済 care への変更ゆえ再確認)★
  ⑤open items 3 件は推論で埋めない(D40 = step2 測定で裏取り / B084 deferred / D18 非対象)。

## 14. 権限委譲境界(PRESIDENT、2026-07-15 09:3x — 以後の運用基準)

- **boss1 委譲(逐一承認不要)**: dispatch GO / small commits+非退行 gate の検収 land / instrument 変更(§3 規範内・
  観測のみ、diff 直読 GO)/ open items の測定裏取り・honest gap 記録・台帳更新。
- **PRESIDENT gate 維持(5 件)**: ①設計判断(単一推奨 doc = 実装前裁定) ②★MAPHEAD/0x66 の実装 land★
  (feature flag 構造 + go を land 前に。cutscene 挙動に触れる一切は user 凍結解除まで) ③★新 baseline canon★
  (C と同厳密さ: replicate 対 earn + immutable + sha + 次元 label 台帳。生成 ack 必須) ④★全長 RE が設計前提を
  覆した時 = 即上申・実装凍結★ ⑤完成 claim(user 実視覚)。
- 報告頻度: phase 移行ごと(step 完了 / canon 生成 / 設計 doc / blocker)。routine 逐一報告は不要。

## 15. ★gate④ 発動: commit C(0x36 tail)の帰属前提が揺らいだ(2026-07-15 10:4x)★

- **事実**: worker3 の構造実測で ★B084 = 別 actor(CDB8 slot)の record、partner の record は CDBC slot → 0x8016B104★。
  既 land の commit C は固定 addr B084 を『partner の form index』と帰属して partner.FullnessMax で clamp していた
  (worker2 自己申告 `8000a39`)。★disasm は正しく、未検証の【帰属】だけが誤り★。
- **処置(PRESIDENT 承認)**: commit C 系の追加実装 = 凍結 / ★revert しない(挙動 gate 緑)★ / silent 続行もしない /
  ★測定で reconcile★(worker3 の partner 生成点 run が唯一の decider)。
- ★**最重要ガード(PRESIDENT)**: 『care 19/19・golden 37 が緑』を解釈 (1) の証拠にするな★ —
  緑なのは **2 actor の FullnessMax が区別される case を test が exercise していない**から。
  ★緑は (1)(2) の両方と consistent = 帰属について何も言っていない★(「緑が何を assert してるか確認せよ」の適用)。
- ★**class 記録**: land 済 commit が未検証帰属を含んでいた = 『測定済み入力に接地』しても、その入力の
  **意味帰属は別途検証が要る**★(CDB8/CDBC slot 取り違え = 別空間 join の再来)。**実装後も測り続けたから捕まった**。
- ★**20 vs 25 の分離**: recon(A) は **timing 裁定**だった。seed の【値】(C# 25 vs 実機 D54=20)は**別の correctness 問題** —
  step2 の seed 値は本 run まで ★provisional に降格★。timing 裁定を値裁定に流用しない★。
- ★**follow-up 必須条件(どちらの解釈でも)**: 2 actor の FullnessMax が異なる case を exercise する **新 test を追加**★
  (すり抜けた理由 = 区別 case 未 exercise ⇒ 帰属を gate-asserted に変える)。
  (2) = 参照先是正 + end-to-end 実測(swap して仮定しない)/ (1) = comment 訂正 + 同 test。

## 16. ★gate④ 決着(解釈(2))+ follow-up の罠(PRESIDENT、2026-07-15 12:2x)★

- **決着(実測)**: baby(form=1)= 0x8016B1D4(frame 8299)/ tail が読む固定 B084 = 3 不変
  ⇒ ★care-form ≠ partner-form = 別 entity★(worker2 静的 RE と整合)。commit C の partner.FullnessMax clamp = 帰属誤り確定。
  algorithm(clamp/bit2/D58)は不変、参照先のみ是正。
- ★**worker3 の自己訂正の副次効果: (B) user 手動 savestate 依頼は【不要】に**★ — false-absence(coverage gap)を
  潰したことで窓内で決着。user への要請は取り下げ。
- ★★**follow-up の罠(PRESIDENT 指定・最重要)**: 『参照先是正』を【B084 の意味同定前】に land するな★★
  - 解釈(2) は『partner でない』を確定したが、★B084 が【何か】は未同定★。
    ★未同定の先へ参照を差し替える = **H4 を別の H4 に置換**(gate④ を生んだ誤りの再演)★。
  - ★**正しい忠実形 = EXE の構造を複製**: EXE は B084 を【固定 absolute = global】として読む ⇒ C# の忠実実装は
    『partner.FullnessMax』でも『別 actor.FullnessMax』でもなく、**【global な care-form-index の値で clamp】**★ —
    ★actor を当てるのでなく **機構(global read)を model** する。『どの actor か』を先取りしない★。
- next run(承認済)の readout 追加: ★D54=20 が seed 単独か seed==max か + **FullnessMax(baby) の実測値**(clamp に要る)★。

## 17. step4/5 の設計材料(worker3 census `03b4863`+`411e490`、新規 run ゼロ)= ★実装順序を実測が決めた★

- ★**0x66(step5)= 『まれな warp op』ではなく【ほぼ全 entry の定型 prologue 末尾】**★:
  462/463 entry が**ちょうど 1 回**・449 件が**先頭から 4 番目の op**・★直前 op は 0x67 が 464/464 = 100%(固定ペア)★・
  ★直後に op は続かない(0 件)★・idle_stop 464/464。到達列 = 0x1B→0x1A→0x27→0x67→0x66。
  ⇒ ★**差分テストの母数 = 463 entry** = 退行が即可視化される / 実装を誤れば全面的に壊れる = **最も安全に検証できる step**★。
  ★未追跡(開示): 0x66 が DF70 の値を実際に読むかは未測定 → step5 の差分テスト設計で扱う★。
- ★**0x46 / 0x79(step4)= 母数が極小(6 回 / 1 回)**★: 0x46 は `[46][47][NN]` の隣接ペア形(0x47 は C# 実装済)、
  続く 1 byte が entry 170-173 で 01/02/03/04 の連番。0x79 は len=2・operand 0x01・**1 site のみ**(entry 151,60)で
  直後に 0x46 が続く。
  ⇒ ★**full sweep では埋もれる = 差分テストで「踏む entry」を明示指定しないと検証が空振りする**★。
  ★必須 corpus(全件)= (129,6)(151,60)(170,51)(171,51)(172,51)(173,51)★ を step4 の prereg に固定する。
- ★**boss1 採用の実装順序**: step5(0x66)を step4 より先に — 母数 463 で全面検証でき退行が即出る。
  step4 は corpus を prereg で固定してから着手★(step3 完了後の dispatch 設計に反映)。
