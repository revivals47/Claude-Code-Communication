# PRESIDENT dispatch (2026-07-13) — H: store-side hook で入力表面を閉じる

## 前提（G session の到達点、実測で再確認済）

- main = `7a87fba`（G1 land）/ **origin/main = `59488d0`（push ゼロ、不変）**
- frozen authority = `09fde5a`（read 側 trace、**1 バイトも触らない**）
- worktree = `~/Desktop/Digimon/degimon_world_remake-f1{a,b,c}`（保全済）
- 改造 DuckStation = `duckstation-src`（load hook = DGLOADS 機構、build 済）
- **決定性テスト = PASS**（read 側 46-capture は sweep path で再現可能、隠れた非決定性なし）

## G session の未決点（このフェーズで閉じる）

**入力表面は「閉じた」と証明できていない。**
真の入力集合 = **(VM が read する) ∩ (runtime に write される)**。
G session は **read 側だけ**測って「入力」と呼んでいた。**write 側は誰も測っていない。**

未決 2 点:
1. **VM-PC reader の定義**（入力表面は 31 か 1948 か = `0x800A4xxx` 等を VM とみなすか）
2. **各 address が runtime に write されるか**（= 真の入力の基準）

## このフェーズの目的

**store-side hook を足して、入力表面が本当に閉じているかを測定で決着する。**
そして**その先の実装（var[0] / RNG / 0x1B）には、まだ進まない。** 測定が先。

---

## ★★最重要 guardrail（G session の全教訓の凝縮）★★

1. **これは測定であって実装ではない。** frozen `09fde5a` に触るな。read 側 authority を差し替えるな（追加であって置換でない）。
2. **『検証を素通りさせる入口』は 4 つ、穴は 1 つ（未検証）**: 『正しい』の嘘（偽 GREEN）/『測れない』の嘘（偽 BLOCKED）/『網羅した』の嘘（完全性偽 GREEN）/『自分が誤り』の嘘（過剰譲歩）。**断定・撤回・譲歩・covered は等しく claim。自分が source を見た時だけ額面採用する。**
3. **進捗も status ≠ 観測。** ps/pgrep/出力ファイルを叩いてから報告する。
4. **no silent caps**: discovery tool は捨てた中身を全出力する。whitelist/backstop/cap で黙って落とすな。
5. **measure-first**: 実装する前に予測を書き、判定基準を測定前に固定する。
6. **少数サンプルから一般化するな。** 全数走査が可能なら必ずやる。母集団を数えてから「無害」「これで全部」を言う。
7. **push 禁止**（user 専権）。commit は local 可。cutscene 不触。

---

## Track A (worker3) — ★store hook 実装 + written-address tally★（critical path）

1. 改造 DuckStation の **load hook（DGLOADS）と同型の write hook** を足す。
   - **単一 choke point**（`MemoryBreakpointCheck<Write>` 等、load hook と対称な1箇所）。core 改造は最小限。
   - **read 側と同じ provenance gate**（VM fetch 中の write のみ、field-loop 除外）を適用する。
   - **incremental flush**（途中で殺されても部分結果が残る）。**staleness guard**（artifact < source で拒否）も read 側と揃える。
2. sweep（1278 launch）を走らせ、**written-address を tally**。dims 宣言 + self-check assert（宣言した次元を実際に出しているか）。
3. **決定性テスト**: 同一入力で write trace が 2 回 bit-identical か。read 側で PASS したものが write 側でも PASS するか。

**受入 gate**:
- write hook が **非 inert であることを実証**（何も書かない launch と書く launch で tally が変わる = 配線が生きている）。read 側の「注入 harness 非 inert 実証（302/1275）」と同じ手続き。
- **self-check assert が赤にできることを実証**（宣言と違う出力をわざと作って INVALID を返すか）。

---

## Track B (worker2) — ★read ∩ store で真入力を確定 + VM-PC 定義決着★

1. Track A の write tally が出たら、**read 集合 ∩ write 集合** を取る。
   - **これが真の入力表面**。read だけの address（runtime で書かれない = 定数/EXE image）は入力でない。
   - **31 vs 1948 の定義論争が、これで決着する**（write されるものだけが残るので、VM-PC 定義に依らず絞れる）。
2. **予測を先に書け**（measure-first）: read∩store の件数を、write tally を見る前に予測し、外れたら「どちらの集合の見積りが誤りか」を分類する。
3. 確定した真入力で、**46-capture を過不足なく再構成**。多すぎ（定数を注入していた）/ 少なすぎ（write される入力を漏らしていた）を両方チェック。

**受入 gate**:
- **read∩store が、G session の決定性テスト(46注入)を壊さない**こと（真入力 ⊆ 46 なら決定性は保たれるはず。もし真入力が 46 を超えたら、G session の closure は不完全だった = それ自体が finding、honest に報告）。

---

## Track C (worker1) — ★state-gate class の完全性 + var[0]/flag[44] の RE 準備★（次フェーズの地図）

**実装はしない。** 次フェーズ（state 次元を上げる）のための read-only な地図作りのみ。

1. **`0x1B` 以外の state-gate opcode を全列挙**（制御流を変えず state 書き込みだけを gate するもの）。G session で `0xFE`/`0x1B`/`0x25`/`0x4D`/`0x4C`/`0x22`/`0xFF` が候補に挙がっている — **これが完全か、G6 の入力 + handler 逆引きで確認**。
2. **var[0] の正体**（prologue `0x800F0AE8` の初回部分）と **flag[44]=0 clear**（毎回部分）を EXE 直読で確定。prologue が呼ぶ 4 subroutine（`0x800bd820`/`e3940`/`a565c`/`e9a40`）が未 RE = **state gap の下限**。ここを RE すれば「あと何本直せば挙動が合うか」の見積りが締まる。
3. **未検証のまま残す部分は honest に mark**（推測で埋めない）。

---

## 成功基準（数値・次元付き）

- **Track A**: write hook 非 inert 実証 + self-check 赤実証 + write trace 決定性 PASS/FAIL を数値で。
- **Track B**: **真入力表面 = |read ∩ store| を確定**（31/1948 論争の決着）。46-capture の過不足を件数で。
- **Track C**: state-gate class の完全リスト + var[0]/flag[44] 機序確定 + 4 subroutine RE の進捗（未 RE は honest mark）。

## 進行

- boss1: phase 移行ごとに `./agent-send.sh president` で中間 ack。**進捗は artifact/process を見てから報告**（G session で 3 回誤報した教訓）。
- **真入力表面が確定した瞬間（|read∩store| が出た瞬間）、即報告**。これが「入力表面を閉じた」と初めて言える点。
- **実装（var[0]/RNG/0x1B）は、入力表面 closure が確定してから、別途 PRESIDENT 承認を得て着手**。今フェーズでは着手しない。
