# MASTER_TASKS — entry152 transporter 実配線に向けた RE 3 track（2026-07-12）

dispatch: `DISPATCH_2026-07-12_entry152.md`
base: degimon main HEAD = `7a3d6e9`（origin より 26 ahead、**未 push**）
最終ゴール: entry152 の real transporter menu を **field を壊さずに** 有効化する。
本 dispatch は **RE のみ**。配線コードは scope 外（spec 承認 → 別 dispatch）。

## Phase 0 — 環境整備（boss1、完了 03:31）

- [x] worktree 3 本を `7a3d6e9` から作成、4 tree すべて git status クリーン
- [x] gotcha 潰し: `extracted/` が gitignore で worktree に来ない → 共有 tree へ read-only symlink +
      `.git/info/exclude` に `/extracted`（誤 commit 防止）。working tree ファイルは無変更
- [x] worktree 内で `scn_trace.py 152` 動作実証（entry152 decode 成功、Len 0x4B=4 / 0x4E=8）
- [x] dispatch 前提の再検証: HEAD 一致 / EXE `extracted/slps_017_97.bin` 実在 → stale なし

## ★H4 発火（03:38）— dispatch の前提が崩れた★

worker1 と worker2 が別経路から収束、**boss1 が worker 報告に依らず自分で EXE を disasm して裏取り済**。

**CONFIRMED（boss1 実測）**

1. **0x4B は menu item 登録ではない。無条件・文脈非依存の TERMINAL warp。**
   handler `0x800ED774`（table `0x8011B214`）は分岐ゼロの直線コード、末尾が
   `a0 = 0x80164068` / `a1 = 3` / `jal 0x800913C0`。`0x800913C0` は trampoline
   （`addiu t2,0xa0` / `jr t2` / `addiu t1,0x14`）= **BIOS A(0x14) = longjmp**。
   ⇒ 戻らない。直後 `0x800ED7F0` が 0x4C handler = fall-through 不在。
   ⇒ 現行 `DialogueRuntime.cs` の「0x4B が A(0x14) で menu item を add / `0x80164068` = menu-buffer」は
   **A(0x14)=longjmp・`0x80164068`=jmp_buf の誤読**。`_warpDestIndex`/`_selector` の menu dispatch はこの誤読の上に建っている。

2. **「13 行先」は 13 個の行先ではない。同一地点の 13 状態バリアント。**
   map registry（file_off `0xa4c1c`, stride 16）: idx204=`TWNA01` / idx168-179=`TWNA02..TWNA13`、
   **name 以外の 8 byte が 12/12 完全一致**（`000002028c00092b`）。= File City の進行度別バージョン。

⇒ **entry152 は transporter menu ではない。**「どの File City バリアントを load するか」の条件分岐 warp。
⇒ TrackB の「0x19-gated=menu / linear=field」仮説は、**menu 型 0x4B が存在しない以上 成立しない**。

**未検証（額面で受け取らない）**: worker1 の flag 式 / 本物の transporter menu が別機構に存在するか（**未調査**）。

## ★汚染 + push-back（03:40-03:41）★

- worker3 が **0x4F = 2→6 / 0x6E = 4→8**（ともに 4 byte under-consume）を EXE 直読で確定。
  `scn_trace.py` は runtime `Len[]` を直 parse する設計 ⇒ **worker1/2 の tracer 出力は当該 path で desync 汚染**。
  → 両者に corrected walker で再走 + 「当該 path に 0x4F/0x6E が出現しない」実測による汚染否定を指示。
  「再走前後で一致したから正しい」は不可（誤 length 同士で一致し得る）。
- **boss1 が land を止めた**: Gamma1aSweep **GREEN 114 → 112**（2 件減）を worker3 が
  「破損ではなく menu-pause 化 / oracle 順序差」と説明したが、**これは観測でなく解釈**。
  land 条件 = 2 件を entry 番号で名指し / REVERT・FIXED 並置 / 旧 GREEN が desync による**偽 GREEN** だったと
  EXE ground truth で示す / 示せなければ **regression 疑いと honest 報告**（length 自体を再検討）。

## Phase 1 — RE 3 track 並走（進行中）

| track | worker | worktree / branch | 成功基準 | 状態 |
|---|---|---|---|---|
| A: flag → 行先 unlock semantics | worker1 | `-e152a` / `trackA/entry152-flags` | flag 6 件（0xcb/0xe1/0xf6/0xdc/0xd6/0xdd）中の**根拠付き確定数 / 6** | ack 03:29、進行中 |
| B: W1 gate Root型 → 構造型 | worker2 | `-e152b` / `trackB/w1-gate-structural` | 全 225 entry 分類 + **field warp 131 LINEAR の誤分類 = 0** or 判定式不成立の honest 結論 | ack 03:30、進行中 |
| C: 0x4F / 0x6E opcode audit | worker3 | `-e152c` / `trackC/opcode-4f-6e` | length 確定 + CutsceneVerify178 GREEN + Gamma1aSweep GREEN | ack 03:30、進行中 |

各 track 共通の必須要件: 捏造ゼロ（未検証は明示）/ derive-blind 禁止（EXE 直読）/ codex 査読 /
H4 許容 / worktree 隔離 / **push 禁止（local commit のみ）** / 配線コード禁止。

## Phase 2 — 配線 spec 上申（TrackA + B が揃ったら / boss1）

- [ ] TrackA の flag→destination map と TrackB の構造型判定式を統合し **entry152 配線 spec** を起草
- [ ] PRESIDENT へ上申 → **GO を待つ**（boss1 判断での配線着手は禁止）

## Phase 3 — 配線 dispatch（GO 後 / 単一 worker 直列 / 本 dispatch の scope 外）

- [ ] gate を構造型へ差し替え、entry152 menu を有効化
- [ ] regression: field warp 131 件が壊れていないこと
- [ ] **完成 claim は user 実視覚まで凍結**（cargo/headless/codex LGTM は完成の根拠にならない）

## リスク / 監視項目

- **TrackB の判定式が成立しない可能性**（H4）。成立しない場合、entry152 配線は別アプローチが要る
  → Phase 2 の spec 内容が変わるため、判定式不成立の報告が来たら即 PRESIDENT へ上申
- TrackC で length 変更が入った場合、walker の desync 影響が TrackA/B の tracer 出力にも及ぶ
  → 変更確定時は TrackA/B に再走を指示する（boss1 が serialize）
- Unity build は worker3 専有。TrackA/B は read-only RE なので競合なし
