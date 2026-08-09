# PRESIDENT dispatch (2026-07-12) — entry152 transporter menu 実配線に向けた RE 3 track

## 大前提: ground truth

- repo: `~/Desktop/degimon_world_remake`
- **main HEAD = 7a3d6e9**（origin より 26 ahead、**未 push**）
  - `7a3d6e9` opcode 長 fix（0x4D 2→4 / 0x6C 4→8、EXE handler 直読、Unity build-verify GREEN）
  - `6fe3169` branch-tracer `workspace/tools/scn_trace.py` + census `workspace/tools/scn_warp_census.py`
  - `bb61b82` 覚醒 cutscene 完成版（user 目視 PASS 済、凍結解除済）
- 参照 doc: `docs/RE_scn_branch_tracer_2026-07-10.md` / `docs/W1_gate_reeval_2026-07-10.md` / `docs/RE_opcode_audit_4D_56_67_6C_2026-07-10.md`
- 前 session handoff: `workspace/degimon-faithful178/HANDOFF_2026-07-10.md`（Claude-Code-Communication 側）

## この dispatch のゴール

**entry152 の real transporter menu を「field を壊さずに」有効化する**。

そのために必要な RE が 2 件未解決なので、まず RE を並走で潰し、**配線 spec を PRESIDENT に上申**する。
配線コードそのものは本 dispatch の scope 外（spec 承認後に別 dispatch、単一 worker 直列）。

### なぜ gate 撤去でなく「精密化」か（2026-07-10 で決着済、再議しない）

`OP_WARP_DEST`(0x4B) の W1 gate は現在 **Root 型**（= cutscene 文脈でのみ warp emit）。
全 entry census の結果、**field warp 131 件が flag-gate 無しの LINEAR 0x4B** で、gate を外すと
無条件 emit されて FieldManager と二重発火し navigation が壊れる。よって撤去は NO。

一方 branch-tracer 完成により worker2 corpus-scan の UNKNOWN=174 が解消したため、
gate を **構造型**（= 0x19-gated な 0x4B chain は menu / linear な 0x4B は field warp）に
置き換える道が開いた。これが本 dispatch の本丸。

---

## Track A (worker1) — transporter cascade の flag → 行先 unlock semantics RE

**問い**: entry152 / entry0 の 0x4B flag-cascade で、flag `0xcb / 0xe1 / 0xf6 / 0xdc / 0xd6 / 0xdd` は
**それぞれ何を解放するのか**。

既知（2026-07-10、machine-check 済）:
- transporter menu = entry152 と entry0(master) が同一構造。13 行先に 0x4B の flag-cascade。
- 対象 registry idx = 204 および 168-179 帯。spawn=4 / returnKey=0xff。

成果物:
1. **flag → destination map**（6 flag すべて。map registry idx と、可能なら人間可読な地名）
2. 各行の根拠を明示: EXE address / bytecode offset / `scn_trace.py` 出力のいずれか
3. 「どの flag が立つと解放されるか」の**セット条件**（どの event が flag を立てるか）も判る範囲で
4. 未確定分は **未検証と明示**して残す（埋めない）

手法: `python3 workspace/tools/scn_trace.py 152` および `... 0` の制御流出力を基点に、
flag の read/write 元を EXE 側へ辿る。binary = `extracted/slps_017_97.bin` は **header 無 raw dump、
file_off = ram - 0x80090800**（PS-EXE header 無し、注意）。

---

## Track B (worker2) — W1 gate を Root 型 → 構造型へ精密化する判定式 + corpus 検証

**問い**: 「この 0x4B は menu 選択肢か、field warp か」を **文脈でなく構造**で判定できるか。

仮説（要検証）: `0x19` (CheckFlag/条件分岐) に gate された 0x4B chain = menu、
gate 無しの linear 0x4B = field warp。

成果物:
1. 判定式の**形式的定義**（walker が実装できる粒度で）
2. `scn_warp_census.py` を拡張し、**全 225 entry を新判定式で分類**
3. **現行 Root 型 gate との差分表**: 新たに menu 扱いになる entry / field 扱いになる entry を全列挙
4. **regression ゼロの証明**: field warp 131 LINEAR が 1 件も menu 誤分類されないこと。
   1 件でも誤分類が出たら判定式を修正するか、**判定式が成立しないという結論を honest に出す**（H4 許容）

注意: 前回 worker2 が「entry152 は linear scan では原理的に到達不能」と honest mark している。
tracer 経由なら到達可能なはず。到達できなければそれ自体が finding。

---

## Track C (worker3) — 0x4F / 0x6E opcode audit（EXE handler 直読）

`7a3d6e9` で 0x4D / 0x56 / 0x67 / 0x6C は確定。**0x4F と 0x6E は未 audit で据置**のまま。
0x4F は camera pan の配線候補でもあり、長さが誤っていると walker が desync する。

手法（`docs/RE_opcode_audit_4D_56_67_6C_2026-07-10.md` と同一、derive-blind 禁止）:
1. router `0x800F0744` → sub-interp（`0x46-0x58` = `0x800ED434` / table `0x8011B200`、
   `0x64-0x7E` = `0x800EDE88` / table `0x8011B3A0`）
2. 各 handler の **operand-helper advance を 1 つずつ直読して合計**
3. 既知 helper advance: `0x800f0edc`=+1 / `0x1038`=+2 / `0x1620`=+2(s16) / `0x0e6c`=+3 /
   `0x0ff0`=+3 / `0x1078`=+2 / `0x1660`=+4(2×s16) / `0x0ae8`=+0(setup)

成果物:
1. 0x4F / 0x6E の length 確定 + handler address + advance の内訳
2. 長さに変更が入る場合は **runtime Len[] と `docs/opcode_lengths_exe.json` を同期**
3. **Unity build-verify GREEN 維持**: `CutsceneVerify178.Run`（finished / pages 66 / termPc 0x1315 /
   emittedChars 1601 / garble 0）+ `Gamma1aSweep`（entry204 m/e/o = 773/773/810）
4. 長さ変更時は **clean A/B 必須**（REVERT 版と FIXED 版を同一コードで比較）。
   stale catalog（commit e774357、1 ヶ月前）を baseline に使わないこと ← 前回踏んだ罠

起動: `/home/ken/Unity/Hub/Editor/6000.4.11f1/Editor/Unity -batchmode -nographics -quit -projectPath <repo>/unity -executeMethod DigimonWorld.EditorTools.{CutsceneVerify178.Run|Gamma1aSweep.RunSweep} -logFile <log>`

---

## 必須要件（全 track 共通）

1. **捏造ゼロ / claim 規律**: 観測（EXE bytes・bytecode・実行 log）と推論と仮定を区別する。
   裏取りのない address / 数値 / opcode 挙動は **「未検証」と明示**。確信が強いときほど捏造リスクが高い。
2. **derive-blind 禁止**: doc 値・json 値・過去 doc の記述を鵜呑みにしない。EXE handler を直読する。
3. **codex 査読必須**: Track A の flag map、Track C の length 変更は codex に第二意見を出す。
   前回 codex は tracer の stat operand 長バグを catch し、偽の「未記載 mode 0x28/0x30/0x38」という
   捏造級 finding を阻止している。**「時間がかかるから」で省略しない**。
4. **H4 許容**: N 択仮説の全否定は失敗でなく前進。Track B の判定式が成立しないなら、そう報告する。
5. **worktree 隔離（必須）**: 各 worker は `git worktree add` で別ディレクトリに隔離。
   **共有 `~/Desktop/degimon_world_remake` には触らない**。branch 命名は boss1 が割当時に明示。
6. **commit = local 可 / push = 禁止**。push は user 専権、PRESIDENT も代行不可。
7. **Unity build は worker3 専有**。Track A / B は read-only RE なので競合なし。
8. **完成 claim は user 実視覚まで凍結**（本 dispatch は RE のみなので該当せず。配線 dispatch で発生）。

## 成功基準（数値）

- Track A: flag 6 件中、**根拠付きで確定できた件数 / 6** を報告。未確定は未検証 mark。
- Track B: 全 225 entry 分類 + **field warp 131 LINEAR の誤分類 = 0 件**。
- Track C: 0x4F / 0x6E length 確定 + build-verify **CutsceneVerify178 GREEN / Gamma1aSweep GREEN**。

## 進行

- 各 worker: 着手 ack → **30 分ごと進捗報告** → 完了報告
- boss1: phase 移行ごとに `./agent-send.sh president` で **中間 ack 必須**
  （dispatch 発行完了 / worker ack 受領 / codex 査読受領 / build-verify 結果 / ブロッカー検出）
  tmux pane の text output は PRESIDENT に届かない。pane に書いても伝わらない。
- **Track A + B が揃った時点で、boss1 は「entry152 配線 spec」を PRESIDENT に上申**。
  GO を受けてから配線 dispatch（単一 worker 直列）を切る。boss1 判断での配線着手は禁止。

## モデル

boss1 / worker は **Opus 4.8 継続**（現在の既定のまま。起動し直し不要）。
Fable 5 は使わない: 単価 2 倍 + 常時 thinking で長 turn、かつ cyber 系 classifier が
バイナリ解析に false-positive refusal を返し得るため（本 dispatch は EXE 逆アセンブルが主タスク）。
