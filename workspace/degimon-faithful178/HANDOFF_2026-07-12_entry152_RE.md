# HANDOFF — 2026-07-12 / entry152 RE 3 track（dispatch: DISPATCH_2026-07-12_entry152.md）

base: degimon main HEAD = `7a3d6e9`（origin より 26 ahead、**未 push**）
結論: **dispatch の前提が 2 つとも誤りだった**。RE は完遂。**配線は未着手**（PRESIDENT 裁定 (C)）。
**全 commit は local。push は 1 件もしていない。**

---

## 1. dispatch の前提は 2 つとも誤りだった

| dispatch の前提 | 実際 |
|---|---|
| entry152 = transporter menu、13 行先 | **menu ではない**。13 個は **同一地点 TWNA01-13 = File City の進行度別バリアント**。player 選択なし、flag/var で完全決定 |
| `0x4B` を無条件 emit すると field warp と二重発火して連鎖する | **連鎖は構造上ゼロ**。`0x4B` は**常に script を停止**する |

---

## 2. 確定した VM 機構（多重独立で裏取り済）

### `0x4B` は「terminal」だが、意味は「VM tick を抜ける」

- `0x4B` handler `0x800ED774`（分岐ゼロの直線）は末尾で `RestoreState(jmp_buf=0x80164068, param=3)`。
  BIOS **`A(0x13)=SaveState` / `A(0x14)=RestoreState`**（`setjmp`/`longjmp` は**相当物であって BIOS の定義名ではない** — codex 指摘で訂正）。
- VM 受け口 `0x800F0764` が同じ jmp_buf に SaveState を張る。`0x800F08C8` の分岐:
  - **code 1** → `0x800F0764` へ戻る = interpreter loop 継続（10 site）
  - **code 2** → VM 関数から return = tick 離脱（23 site）
  - **code 3** → pending = `75`(=`0x4B`) を `gp-0x6CBB` に記録 → tick 離脱（**3 site のみ = `0x4B` / `0x58` / `0x66`**）
- host: pending==`0x4B` の間 `warpTo`(`0x800E3DA0`) を毎 frame。完了で pending clear。**ここに PC write も key 分岐も無い**。
- **`warpTo` → `0x800E3FA0` → `StartScript`(`0x800F0150`→`0x800F0188`) が script BASE(`gp-0x6CCC`) と PC(`gp-0x6CC8`) を clobber**。
  ⇒ **caller script は継続しない。`0x4B` は常に停止**。

### 継続は「元 script への復帰」ではない — 多段 hop

> ★2026-07-12 訂正（codex 査読が発見、boss1 が byte-exact 裏取り）★
> 当初「4 hop」と書いたが**誤り**。`0xFB` は **kind=3 record を push する**ので、
> MAPHEAD の直後の `0xFE` が pop するのは **kind=3** であって warp の kind=4 ではない。
> **kind=3 の commit hop が 1 つ挟まる。実装 spec は必ず下記の訂正版を使うこと。**
> 根拠: `0xFB` handler `0x800EC448` = `jal 0x800F0D10`(operand→`gp-0x6CD6`/`gp-0x6CA6`) →
> **`addiu v0,zero,3` / `sb v0,30(sp)`(=kind=3)** → `addiu a0,sp,24` → **`jal 0x800F0D58`(PUSH)** → `RestoreState(code 1)`。
> `0xFE` handler `0x800EF3B0` は **POP を loop で回す**（kind==3 → §`0xFE` へ / kind==4 → key 分岐）。

**訂正後のモデル（実装はこれを使う）**

1. `0x4B` が **kind=4{key}** を push → **停止**
2. warp 完了 → `StartScript`(scenario 0 = MAPHEAD, §\<新 mapId\>)
3. MAPHEAD §\<mapId\> の **`0xFB` が kind=3{scenario, ctx} を push** → loop 継続
4. **`0xFE` が kind=3 を pop** → BASE = 新 scenario、`PC = resolve(新 scenario, §0xFE)` → loop 継続
5. **その scenario の §`0xFE` 内の `0xFE` が kind=4 を pop** → key≠`0xFF` → `PC = resolve(現 scenario, key)`
6. → `0x17 JMP_SEC` → 目的 section

（**結論自体は不変**: `0x4B` は常に停止 / caller は継続しない / returnKey = 遷移先 scenario の継続 section id。
codex も「warp 後に caller が保存 PC から継続する反例は見つからない」= 反証不能と判定）

覚醒 cutscene の実経路（**全 hop byte-exact 検証済**）:

1. entry178 §`0x36` @`0x001a`（草原）末尾 = `0x4B` @`0x07c8`（dest=218/ROOM08, **key=`0x36`**）→ **停止**
2. warp → StartScript(MAPHEAD, §218) → **MAPHEAD @`0x3252` = `fb 00 a3 00 da 00`** = `0xFB` scenario→**163**
3. `0xFE` が record pop → key≠`0xFF` → `resolve(`**163**`, 0x36)` = **entry163 §`0x36` @`0x007a`**
4. **entry163 §`0x36` = `17 00 b2 00 37 00`** = `0x17 JMP_SEC` → scenario **178**, section **`0x37`**
5. → **entry178 §`0x37` @`0x07cc` = 家の場面** 。末尾 `0x4B` @`0x130e`（dest=204, key=`0xFF`）→ 停止 → MAPHEAD §204 → `0xFE` pop → key=`0xFF` = **終端**（field 復帰）

### `returnKey`（byte3）の意味 = 確定

**「遷移先 scenario における継続 section id」**。**「元 script への戻り先」ではない**。`0xFF` = 真の終端。

---

## 3. ★remake は「見た目 PASS」だが「忠実」ではない★

remake が §`0x37` に着地しているのは **fall-through の偶然**（§`0x37` が `0x4B` の物理直後にあるため）。
**原盤の 4 hop を 1 つも通っていない。**
⇒ 忠実化には **MAPHEAD + return-record stack + `0xFB` + `0x17` JMP_SEC** が前提 = **別 dispatch 規模**。
⇒ **着手すると user 実視覚 PASS 済の覚醒 cutscene を壊し得る**（= F4、要 PRESIDENT 承認）。

---

## 4. entry152 = File City の進行度バリアント selector（bytecode 裏取り済）

```
if (!flag[0xcb]) → reg204 (TWNA01)
else reg = 168 + A + B + C
  A = (flag[0xdc] || flag[0xd6] || var[0x01] >= 50) ? 6 : 0
  B = flag[0xdd] ? 3 : 0
  C = flag[0xe1] ? 2 : (flag[0xf6] ? 1 : 0)     # 0xe1 が 0xf6 を優越
```
12 通りが 168..179 を重複なく欠番なく覆う（flag 32 通り機械実行で確認）。

**flag 6/6 の set 元 = すべて「◯◯が街に参加した！！！」= 街への仲間加入**:
`0xcb`=アグモン(+1) / `0xf6`=パルモン(+1) / `0xdc`=エンジェモン(+2) / `0xdd`=バードラモン(+2) / `0xe1`=ベジーモン(+2) / `0xd6`=もんざえモンのぬいぐるみ(+2)
各 site = `SET_FLAG` + `var[0x01] += N`。**`var[0x01]` = 街の繁栄度カウンタ**（cascade の `var[1]>=50` と直結。`0x1F` handler `0x800ec844` 直読）。
**決定打**: entry118 は `SET_FLAG(0xdd)` の**直後に同一 cascade を再実行**（@`0x03f8`）= 加入 → flag → **更新後の街へ warp**。

map registry（file_off `0xa4c1c`, stride16）: idx204=`TWNA01` / idx168-179=`TWNA02..TWNA13`、**name 以外 12/12 byte 一致**。
entry152 の `0x4B` は **13/13 すべて key=`0xFF`** ⇒ 復帰しない ⇒ **連鎖 warp ゼロ**。

---

## 5. opcode / tooling の修正

- **`0x4F` = 6**（旧 2）/ **`0x6E` = 8**（旧 4）— EXE handler 直読で確定。**canonical = `c6fec7f`**
- `docs/opcode_lengths_exe.json` の pre-existing drift 2 件（`0x4E` 4→8 / `0xFB` 2→6）も同期
- **`scn_trace.load_scn` の 512-slot bug**: `first`(=`0x800`) を count と誤読していた。
  **実 entry = 225（idx 0..224）**、slot 225 = EOF sentinel、226 以降は ASCII `\SCN\MAP141.SCN`

### ★Gamma1aSweep の GREEN は correctness oracle ではない（最重要の副産物）★

`ok = emit.Length > 0 && common == emit.Length` = **linear text の prefix 一致のみ**。
**偽 GREEN が 8 件実在した**（entry 33/64/71/72/76/98/108/144 — 25/25 箇所で operand を opcode として実行しながら GREEN）。
⇒ **今後あらゆる変更で GREEN 数を regression gate に使えない**。
⇒ **差引の数字を額面で読むな**（「2 件減」の実体は **8 喪失 / 6 獲得**）。

---

## 6. 我々が落ちた罠（次の世代へ）

1. **循環論法**: 「entry178 の再開 PC `0x07cc` が §`0x37` の offset と byte-exact 一致 = モデルの裏付け」は**循環**だった。
   `0x4B` が section 末尾命令なら「fall-through の次 byte == 次 section の先頭」は**恒等式**。
   fall-through を仮定して得た値を fall-through の裏付けに使っていた。**chain 全体（worker2 → boss1 → PRESIDENT）が一度騙された。**
2. **暗黙の誤仮定**: 「`0xFE` の resolve は**元の** scenario に対して行われる」を **worker2 以外の全員（boss1 / PRESIDENT / codex）が共有**していた。
   実際は `0xFB` が張り替えた**後**の scenario に対して resolve される。ここが最後の 1 ピースだった。
3. **推論を観測扱いしない**: codex の「`0x1312` の `0xFE` は dead code」は EXE 未読の構造推論で、**誤り**（実行を担うのは遷移先 scenario 側の `0xFE`）。**観測 > 推論**が正しく機能した実例。
4. **boss1 の MAPHEAD parse は誤りだった**（DG.SCN entry layout と誤仮定 → section 1245 個の garbage）。**worker2 の offset が正**。

---

## 7. commit（**全て local。push は 1 件もしていない**）

| branch | sha | 内容 |
|---|---|---|
| `trackC/opcode-4f-6e` | `c6fec7f` | **canonical**: `0x4F`=6 / `0x6E`=8 + json 同期 |
| `trackC/opcode-4f-6e` | `488abee` | 偽 GREEN / oracle 欠陥の単独 doc |
| `trackC/opcode-4f-6e` | `9f67f02` | follow-up F4-F6 登録 |
| `trackA/entry152-flags` | `a60d4cf` | entry152 flag RE doc + tools（Len[] 重複は除去、`c6fec7f` に一本化） |
| `trackB/w1-gate-structural` | （worker2 最終 commit） | VM 機構 / 4 hop / returnKey / census / `scn_trace` fix |

worktree: `-e152a` / `-e152b` / `-e152c`（`extracted/` は共有 tree への read-only symlink、`.git/info/exclude` で除外）

---

## 8. follow-up（MASTER_TASKS 登録済）

- **F1** 真の correctness oracle 設計（(a) 実機 golden / (b) 別実装 walker で anti-circular / (c) char multiset は**順序を示さないので代替にならない**）。着手前に PRESIDENT 判断
- **F2** `0x4F` の consumer trace（`0x800E3550` / `0x80159730`）— **(x,y) が camera pan target か別 entity かは【未確定】。確定するまで「camera pan」と呼ばない**
- **F3** `scn_trace.load_scn` 512-slot bug（worker2 が fix、owner 単独化済）
- **F4** **MAPHEAD + return-record stack + `0xFB` + `0x17` の 4 hop 忠実化** — **user PASS 済 cutscene を壊し得る。要 PRESIDENT 承認・別 dispatch**
- **F5** **W1 gate 撤去の再評価** — 連鎖 warp が構造上ゼロと判明し、撤去の主障害が消滅
- **F6** 本物の transporter menu 機構の所在調査（entry152 は menu ではなかった）

## 8.5 次 session 着手前に必ず読むこと（worker2 最終 finding + codex 査読）

1. **DG.SCN の entry index は map id ではない**。map の script は「entry S の §\<mapId\>」にあり、S は MAPHEAD の `0xFB` が指定する。
   ⇒ **remake の `PlayMapSection(mapId)` = `GetEntryChecked(mapId)` は原盤と異なる = 要 audit**
2. **`DialogueData.cs` の `BodyStart = 4 + word0` は +4 ずれ**（正 = `word0`）= 要 fix
3. **`0x58` = GetVar による var 間接 dest = 本物の transporter menu 機構の最有力候補**（F6 の入口）
4. **`0x58` / `0x66` も warp に流れる**: VM の code3 path（`0x800F08F8`）は `addiu v0,zero,75` で
   **どの opcode でも pending に 75(=`0x4B`) を hardcode** する。よって `0x58`/`0x66` が code3 で yield すれば
   同じく `warpTo` に流れる（codex の「`0x4B` のみ warp」は**誤り**、boss1 が反証）。
   ただし**両 handler が `gp-0x6CAC`/`-0x6CAA` を書くかは未確認 = 【未検証】**。
5. **codex 査読は 4 hop モデルの実欠陥（kind=3 hop 欠落）を発見した**。
   **spec 起草前に必ず codex 反証を回すこと**。「終わったから」で省略すると誤ったモデルで実装する。

## 9. 未検証（honest mark、埋めていない）

- `0x4F` の (x,y) の意味（camera か別 entity か）= **未確定**
- flag `0xcb` の非アグモン系 7 site（entry46/91/94/95、VAR_ADD 無し）の意味 = **未検証**
- flag `0xe1` の entry14 site の到達経路 = **未検証**（raw は clean decode）
- 本物の transporter menu の所在 = **未調査**
- `gp-0x6cac` / `-0x6caa` の意味づけ（dataflow は観測、「map id / spawn」の解釈は**推論**）
