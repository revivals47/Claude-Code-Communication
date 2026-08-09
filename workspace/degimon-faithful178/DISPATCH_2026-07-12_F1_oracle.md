# PRESIDENT dispatch (2026-07-12 / 第2便) — F1: correctness oracle の再設計

## なぜ今これをやるか

忠実化（MAPHEAD + return-record stack + 0xFB + 0x17 JMP_SEC）は **user 実視覚 PASS 済の cutscene を壊し得る**。
だが **現行の harness は regression を検出できない**。だから oracle を先に作る。配線はその後。

## 現行 oracle が不健全である根拠（PRESIDENT がコードを直読）

`DialogueRuntime.VerifyEntry`（unity/Assets/Scripts/Dialogue/DialogueRuntime.cs:1097）:

```csharp
string oracle = concat(DialogueDatabase.ExtractTextRuns(entry.Raw, entry.BodyStart));
bool ok = emit.Length > 0 && commonPrefixLen == emit.Length;   // ★prefix 判定★
```

**壊れ方が 3 重**:
1. **prefix 判定** — 1 文字出して止まっても GREEN。desync で早期停止しても、そこまで合っていれば GREEN。
   → **偽 GREEN 8 件（entry 33 / 64 / 71 / 72 / 76 / 98 / 108 / 144）の正体はこれ**。
2. **oracle が byte 順の静的スキャン** — VM には jump / 条件分岐 / section table があり **実行順は byte 順ではない**。
   線形 script 以外では比較対象として原理的に成立していない。
3. **到達不能 text も oracle に含む** — 分岐で通らない台詞まで拾う。だから完全一致にできず prefix で逃げた。
   **逃げが構造に焼き付いている**。

⇒ これは「gate が甘い」のではなく **oracle が原理的に不健全**。作り直す。

## 設計方針（codex 査読を経た層構造）

| 層 | 役割 | 位置づけ |
|---|---|---|
| **authority** | 原盤 EXE の実挙動 | 唯一の真実 |
| **executable spec** | EXE を実行 or 逐語移植した reference | authority に最も近い |
| **production** | C# Unity interpreter | 検査対象 |
| **guard rails** | text に依存しない不変条件 | 常時 |

★**pass 条件は「文字列」ではなく「VM が発生させる event 列」の完全一致にする**★。
静的 text scan は **gate から外し、diagnostic（到達可能性の可視化）へ用途変更**する。

---

## Track A (worker1) — ★循環論法を完全に消す: 原盤 EXE の VM を実行する★

**着想**: reference を手で書き起こすと、我々の誤解がそのまま移る（codex 曰く「Python と C# が一致しても EXE と一致したことにはならない」）。
であれば **EXE の機械語そのものを走らせればよい**。再解釈がゼロになり、**authority = 実機械語**になる。

やること:
1. 小さな **MIPS-I インタプリタ**（Python）を書く。VM が使う subset のみ（GTE / COP 不要）。
2. 原盤 EXE を RAM イメージとしてロード（file_off = ram - 0x80090800）、gp-relative globals のメモリモデルを用意。
3. DG.SCN / MAPHEAD.SCN をロードし、VM の dispatch loop（`0x800F0740` 系）を **そのまま実行**。
4. host 側関数（描画 / warp / 音 / BIOS SaveState/RestoreState）は **stub 化して event を記録**する。
   BIOS A(0x13)/A(0x14) は setjmp/longjmp 相当として素直に実装できる。
5. 出力 = **event trace**（PC / opcode / section / text emit / warp / flag・var の read-write / 終端理由）。

★**決定的な受入試験**★:
**entry178 を走らせ、我々が導いた 6 step が「我々が何も教えないのに」再現されるか**。
（0x4B kind=4 push → warp → MAPHEAD 0xFB が kind=3 push → 0xFE が kind=3 pop → §0xFE 内の 0xFE が kind=4 pop → 0x17 JMP_SEC）
- **再現すれば**: 我々の理解が「読んだ結果」ではなく「実行した結果」で裏付けられる。**循環が消える**。
- **再現しなければ**: 理解のどこかが誤り。**それ自体が最重要 finding**。

**非現実的と判明したら honest に不可と報告せよ**。その場合 codex 案（EXE handler の逐語移植 Python reference）に落とす。
**着手前に設計を codex に査読させること**（工数の見積りと落とし穴の洗い出し）。

---

## Track B (worker2) — ★C# runtime の event-trace 化 + oracle 差し替え★

1. `DialogueRuntime` に **event trace hook** を入れる（PC / opcode / section / emit / warp / flag・var access / 終端理由）。
   read-only な観測に留め、**挙動を変えないこと**。
2. `VerifyEntry` の **prefix 判定を廃止**。新 pass 条件:
   - **reference の event trace と完全一致**（Track A の成果が出るまでは、下記 3 の不変条件のみで暫定運用）
   - **終端理由が期待どおり**（End / Return / WaitInput / Choice / ScriptJump / Error / StepLimit を区別）
   - **不変条件違反ゼロ**
   - **step count / coverage が sane**
3. **text 非依存の不変条件（これだけでも今すぐ効く）**:
   - **PC が常に opcode 境界に着地する**（walker と runtime が PC 列で一致）
   - **未知 opcode を実行しない**
   - **step 上限に達しない**（runaway 検出）
   - **emit した文字は必ず script 内の text run に由来する**
4. **静的 text scan を gate から外す** → 「静的に存在するが到達しない text」の一覧化 = **coverage の可視化**へ用途変更。

★**受入試験（これが Track B の成功基準）**★:
**偽 GREEN 8 件（entry 33 / 64 / 71 / 72 / 76 / 98 / 108 / 144）が、opcode 長を旧値（0x4F=2 / 0x6E=4）に戻した状態で
新 oracle では ★赤になる★ こと**。同時に、正しい現行コードで **不当に赤くなる entry を出さない**こと。
→ 新 oracle が「本当に壊れているものを壊れていると言える」ことの実証。旧 oracle はこれができなかった。

---

## Track C (worker3) — ★DuckStation golden の実現可能性を honest に判定★

**authority は原盤の実挙動**だが、225 entry すべてに人間のプレイで到達するのは非現実的。
**user のプレイ時間を使わずにどこまで golden を採れるか**を判定せよ。

調べること:
1. DuckStation の debugger / savestate / メモリ read（既知: ptrace_scope=0 で live RAM 読取可）で、
   **VM の text emit 関数に breakpoint を張り、emit 列を機械的に採取できるか**。
2. **script を外から起動できるか**（StartScript を叩く / savestate を細工する等）。できれば人間のプレイ無しで多数 entry を採れる。
3. できないなら、**「どの entry なら通常プレイで到達でき、user に何分の作業を頼むことになるか」**を具体的に見積れ。

★**「不可能」という結論も正当な成果**★。無理に golden を作らず、Track A（EXE 実行）に authority を委ねる判断もあり得る。
その場合、**Track A が authority を名乗れる条件は何か**（BIOS/host stub が挙動を歪めない保証）を書け。

---

## 必須要件（全 track 共通）

1. **捏造ゼロ / claim 規律** — 観測・推論・仮定を区別。裏取りのない claim は「未検証」と明示。
2. **codex 査読** — Track A の設計、Track B の新 pass 条件、Track C の可否判定は codex に **反証依頼**（「無害だと思う」ではなく「無害である証拠はこれだ、崩せるか」）。
   **締めフェーズで査読を打ち切るな**（今日それで欠陥を1件見逃しかけた）。
3. **恒等式を証拠にするな** — 自モデルを仮定して導いた値を、そのモデルの裏付けに使わない（今日の循環論法の教訓）。
4. **H4 許容** — 設計が成立しないなら「成立しない」と報告してよい。
5. **worktree 隔離** — 各 worker は別 worktree。共有 tree に触るな。branch は `trackF1{A,B,C}/...`。
6. **commit = local 可 / push = 禁止**（user 専権）。
7. ★**忠実化（配線）は依然 scope 外**★ — oracle が立つまで cutscene には触らない。
8. **既存の user 実視覚 PASS 済 cutscene を壊す変更を入れないこと**（本 dispatch は観測系のみ）。

## 成功基準（数値）

- **Track B**: 偽 GREEN 8 件が旧 opcode 長で **8/8 赤**、正コードで **false-red 0 件**。
- **Track A**: entry178 の 6 step を EXE 実行で再現（yes / no）。no なら差分を opcode 単位で提示。
- **Track C**: golden 採取の可否に結論。可なら採取した entry 数、不可なら理由と user 作業見積り。

## 進行

- 各 worker: 着手 ack → 30 分ごと進捗 → 完了報告
- boss1: phase 移行ごとに `./agent-send.sh president` で中間 ack（pane 出力は PRESIDENT に届かない）
- **Track A が「EXE 実行で 6 step 再現」に成功したら即座に PRESIDENT へ報告せよ**。これは project 全体の土台が変わる。
