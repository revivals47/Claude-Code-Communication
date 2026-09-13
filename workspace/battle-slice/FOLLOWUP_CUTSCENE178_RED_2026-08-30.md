# follow-up 登録 — `CutsceneVerify178` が `ea600ab5` で RED（2026-08-30・boss1）

**battle assembly phase では ★追わない★。** 本 doc は **登録**であって調査ではない。
**PRESIDENT #928-D で「#896 の follow-up が findable な doc に落ちていなかった」と申告があったので、その穴もここで塞ぐ。**

## 1. ★観測（boss1 が headless 実行・逐語）★

**器** = `degimon_world_remake-assy`（base `ea600ab5`）／`Unity -batchmode -quit -nographics -executeMethod DigimonWorld.EditorTools.CutsceneVerify178.Run`

```
[CUTSCENE178] DONE finished=True choiceBreak=False pages=0 termPc=0x1A(padding0x1316 手前=True) emittedChars=0 garble=0
[CUTSCENE178] BASELINE-CHECK pages=0/66(★NG★) chars=0/1601(★NG★) termPc=0x1A/0x1315(★NG★)
[CUTSCENE178] RESULT=FAIL
```

**`error CS` = 0**（compile は通る）⇒ **挙動の regression**。

## 2. ★★(a) この RED を baseline として固定する★★

| 次元 | **baseline（`ea600ab5`）** | 期待値（元の GREEN） |
|---|---|---|
| `pages` | **0** | 66 |
| `chars` | **0** | 1601 |
| `termPc` | **0x1A** | 0x1315 |

> **★battle 実装後に この 3 値が動いたら それは ★battle 起因★ と切り分ける。★**
> **動かない限り battle は「この RED から 非退行」。**（**GREEN に戻すことは battle phase の目標ではない**）

## 3. ★切り分け済み（boss1 の実測）★

- **VM 全体が壊れているのではない** — **同 base で `BattleSeamVerify66` が `RESULT=GREEN`**
  （SWEEP 母数 1556 section・**到達 666**・pages を出して text 同一）。
- ⇒ **`entry 178` の opcode 列に固有の何か。**

## 4. ★仮説（★未検証★・額面で採らない）★

**PRESIDENT #928-D** = 「`#896` の **VM-GATE**（`9d90aabf` = **未対応 opcode で停止する gate**）と **consistent だが同一原因とは未検証**」。

**boss1 が確かめた材料**:

- **`9d90aabf` は実在**（2026-08-12・「**実装: VM-GATE — 未対応 opcode で停止する gate（打ち切り条件 ② の計測器）**」）
- **その commit 本文に `0x1A` / `0x6C` の記述は 0 件**（grep）
- **`0x6C` は `ImplementedOps` に ★入っていない★**（`ea600ab5` で grep = 0）／**`Len[0x6C] = 8`**

> **★∴ 「未対応 opcode で停止する gate」＋「`0x6C` が未実装」は 材料として揃っているが、
> ★`entry 178` の `pc=0x1A` の byte が 実際に `0x6C` かは 読んでいない★。★同一原因とは書かない。★**

### ★これを閉じる 1 手（やれば決まる・本 phase ではやらない）★

**`entry 178` の section 254 の body を読み、`pc=0x1A` の opcode を 1 byte 見る。**
- **`0x6C` なら** — **VM-GATE 由来で確定**（`0x6C` を実装するか gate を通すかの判断へ）
- **`0x6C` でなければ** — **別原因**（**`Len` 表の 19 件訂正由来かも 未検証のまま**）

## 5. 札

**材料**（`entry 178` の body を 1 byte 読めば決まる）。**実機は不要。**

## 6. ★登録の穴について（PRESIDENT の申告を そのまま）★

**`#896` で「`0x6C` 実装を follow-up」と裁定されたが、findable な登録 doc に落ちていなかった**
（**boss1 の grep で 0 件**）。**本 doc がその登録。**
> **★型★ = 「follow-up にする」と言った時点では まだ登録されていない。★doc に落ちて 初めて follow-up★。**

---

## 7. ★★閉じた — `pc=0x1A` の byte = `0x6C` ⇒ ★VM-GATE 由来で確定★（2026-09-13）★★

### 7-1. ★1 byte の読み（data 直読・器に依らない）★

- **tree** = `degimon_world_remake-assy`（HEAD `1e2179e2` / 未 commit 0 行）
- **data** = `unity/Assets/StreamingAssets/dialogue/DG.SCN`（692,224 byte・`sha256 4d776b2c99755328652d015a1aecf9185ff8612a0de6494cbbe6a6546cbc5e5b`）
- **entry 178** = `DG.SCN[0x82000 .. 0x83800)`（len `0x1800`）／`word0=0x10` `firstSectionId=0x00FE` `BodyStart(既定 4+word0)=0x14`
- **subtable**（handler verbatim = offset 2 起点・stride 4・sentinel `0xFFFF`@`0x0E`）= **§254(0xFE)→`0x10` ／ §54(0x36)→`0x1A` ／ §55(0x37)→`0x7CC`**
- **★枠★** = `pc` は **`entry.Raw` 内 absolute**（`DialogueRuntime.cs:403` の宣言 / `Pc` は `:883`）⇒ 読む番地は `raw[0x1A]`

```
+0x0010  1E 00 FE 00 64 19 FE 00 FE 00 6C FC E5 00 53 F5
                                      ↑ raw[0x1A] = 0x6C
```

- **★`raw[0x1A]` = `0x6C`★** ⇒ **§4 の判定規則「`0x6C` なら VM-GATE 由来で確定」に当たった。**
- **副産物** = **`0x1A` は §`0x36` の入口**（subtable 実読）⇒ **止まったのは §0x36 の 1 命令目**。
  text は §0x36 / §0x37 に在るので **`pages=0` / `chars=0` は「1 文字も出る前に止まった」と整合**。

### 7-2. ★★これは静的推論ではなく ★既に観測されていた★ — log を読んでいなかっただけ★★

`logs/assy_gate/step1_011238c6/cut178.log:391` と `step2_a88ac2dd/cut178.log:391`（**両 run**・逐語）:

```
[VM-GATE] UNSUPPORTED op=0x6C len=8 entry=178 pc=0x1A prevOp=0xFE stackDepth=0 ctx=FE 00 64 19 FE 00 FE 00 [6C] FC E5 00 53 F5 02 00 4D  ⇒ ★停止(初回)★
```

- **`ctx` の 17 byte は 私が data から独立に読んだ hexdump と 1 byte 違わず一致**（**器 と data の 2 系統一致**）
- **`VM-GATE` 行は 1 run に ★1 件だけ★**（`grep -c` = 1）⇒ **停止点は この `0x6C` ただ 1 つ**
- **★型（申し送り）★** = **答えは 2026-08-30 の 自分の log の 391 行目に 在った。**
  doc には「`pc=0x1A` の byte は読んでいない」と **正しく** 書いたが、**器の出力そのものを grep していなかった**。
  ⇒ **「読んでいない」と書く前に ★自分の log に 既に在るか 1 grep★。**

### 7-3. 機構（code 直読 — なぜ `pages=0` / `termPc=0x1A` か）

- **`0x6C` は `ImplementedOps`(36 種・`DialogueRuntime.cs:130`) に ★無い★**
- **gate は pc を進めずに return**: `if (UnsupportedOpcodeGate(c, len)) { EmitPage(); State = DialogueState.Finished; return; }`（`:2403`）
  — **`_pc += len` は その後** ⇒ **`termPc` = 違反 opcode 自身の pc** ⇒ **`0x1A` がそのまま出る**（観測と整合）
- **旧 GREEN(66 page) の来歴** = `9d90aabf` 本文 逐語 =
  「**非 jump default fall-through(旧: 黙って len consume)を `UnsupportedOpcodeGate` 呼出に置換**」
  ⇒ **旧実装は `Len[0x6C]=8` を 黙って消費して §0x36 body に入っていた**。
  **`Len[0x6C]=8` は worker1 EXE 直読 TSV（hash `fb8086670e419e78462f449cf880cc2ef7e21e9d`）と GUARD 一致枠。**

### 7-4. 格

- **★観測確定★** = `pc=0x1A` の byte が `0x6C`（data 直読 ＋ 器 log の `ctx` 一致）／**停止点が 1 つだけ**
- **★code 直読で確定★** = `0x6C` 未実装・gate は pc を進めず停止・旧は 8 byte 黙って消費
- **★未検証（書かない）★** = **「`0x6C` を実装すれば 66/1601/0x1315 に戻る」**（測っていない）／
  **`0x6C` が何をする opcode かは 未 RE**（`len=8` だけ既知）／
  **`pages`/`chars` の値そのものに 第 2 原因が 効いていない とは まだ言えない**（**§8 で 測った**）

---

## 8. ★★確認 run (A) = ★P1 的中・RED の原因は gate の停止だけ★／だが (B) の scope が 変わった（2026-09-13）★★

**器** = `tools/cut178_ab.sh`／**出所** = `logs/cut178_ab_20260913/`（`PREREG.md` ＋ `provenance.txt` ＋ `control.log` / `treatment.log` / `driver.out`）。
**変えた変数は env `W1_GATE_NEVERSTOP` の 1 つだけ**（`DialogueRuntime.cs:2432`）= **code / tree / data は不変**。
**tree** = `degimon_world_remake-assy` `1e2179e2`・**run の前後で 未 commit 0 行・HEAD 不動**。

### 8-1. ★実測（2 run・逐語）★

| run | env | pages | chars | termPc | garble | RESULT | exit |
|---|---|---|---|---|---|---|---|
| **control** | （既定＝gate ON） | **0**/66 | **0**/1601 | **0x1A**/0x1315 | 0 | **FAIL** | 3 |
| **treatment** | `W1_GATE_NEVERSTOP=1` | **66/66 OK** | **1601/1601 OK** | **0x1315/0x1315 OK** | 0 | **★GREEN★** | 0 |

両 run とも **`error CS` = 0 ／ Exception = 0 ／ `BAND-OUT` = 0 ／ `[LENGUARD] ★GUARD PASS★ 固定 Len 97/97 一致`**。

- **control が RED を再現した**（`[VM-GATE] UNSUPPORTED op=0x6C ... pc=0x1A ... ⇒ ★停止(初回)★` が **1 件だけ**）
  ⇒ **comparator の陽性対照が立った** = treatment の GREEN は **同じ地面の上の比較**。
- **∴ ★P1 的中 = `CutsceneVerify178` の RED の原因は ★gate の停止★ だけ★**（`Len` 表 19 件訂正 等の第 2 原因は **この 3 次元には効いていない**）。

### 8-2. ★★しかし ★(B) の scope が 変わった★ — baseline GREEN は ★11 種 176 件を 飛ばした上の値★★★

**treatment の `[VM-GATE]` 行 = ★176 行 / 11 種★**（**全行 `entry=178`**・他 entry への漏れ 0）:

| op | 件数 | op | 件数 |
|---|---|---|---|
| `0x56` | **87** | `0x4A` | 3 |
| `0x29` | **58** | `0x4F` | 2 |
| `0x4C` | 10 | `0x6C` / `0x2B` / `0x23` / `0x22` | 各 1 |
| `0x34` | 8 | | |
| `0x4D` | 4 | | |

**初出現 順（= gate ON で 1 つ潰すたびに 次に止まる 場所）**:

`0x6C`@0x1A → `0x4D`@0x22 → `0x4C`@0x26 → `0x56`@0x2E → `0x4F`@0x36 → `0x4A`@0x3C →
`0x22`@0x7DC → `0x34`@0x80E → `0x29`@0x82E → `0x2B`@0x916 → `0x23`@0x91C

> **★∴ `0x6C` だけ実装しても gate ON では ★次の `0x4D`@0x22 で止まる★。★`#896` の「`0x6C` を実装する」= scope が 狭かった★**
> **cut178 を gate ON のまま GREEN にするには ★この path 上の 11 種すべて★ が要る。**

### 8-3. ★★baseline の格が 下がる（これが 本 run の 一番 重い 所見）★★

**`BaselinePages=66` / `BaselineChars=1601` / `BaselineTermPc=0x1315` は「★user 実視覚 PASS 済 known-good★」と註されている。**
**しかし 本 run が示したのは ★その値が 出る条件 = 11 種 176 件の 未対応 op を ★黙って len 消費して 飛ばす★ 挙動★ である。**

- ⇒ **★66/1601 は ★忠実の証明では ない★★**。**飛ばした 11 種の どれかが 本来 state を書くなら、原盤は ここで 別の絵を 出している**（**未検証**）。
- ⇒ **`9d90aabf` の gate は ★regression を作った器★ ではなく、★元から在った 176 件の 穴を 可視化した器★ と読める**（**「RED に戻す/GREEN に戻す」の二択で 扱うと この読みが 消える**）。
- **書かないこと**: 11 種が 何をする opcode かは **未 RE**（`Len` だけ TSV 既知）。飛ばして 3 値が一致したのは **scalar 3 次元の一致**であって **pixel / state 同一ではない**（harness 自身の注記と同じ）。

### 8-4. 残った open（札つき）

1. **11 種の RE と実装**（**材料札** = `Len` は TSV 確定・出現 pc も上表で確定・**実機不要**）。
   **効く順 = `0x56`(87 件) → `0x29`(58 件)**。
2. **cut178 gate の既定** = **★裁定済（§9）= (i) gate ON 据え置き・RED を baseline に据える★**。
3. **§7-4 の未検証は そのまま**（`0x6C` の意味は 未 RE）。

---

## 9. ★★PRESIDENT 裁定（2026-09-13）＋ dispatch 記録★★

### 9-1. ★裁定 ① — gate は ON 据え置き。RED を baseline に据える（= 現状維持）★

**理由** = **`9d90aabf` の VM-GATE は ★regression を作った器ではなく、元から在った 176 件の穴を 可視化した器★ だった**（§8-2 / §8-3）。
**∴ 停止を外す既定化（`W1_GATE_NEVERSTOP` 相当を shipping 既定にする）は ★却下★** — **穴を 再び 隠す形になる。**
**§2 の「battle 実装後に 3 値が動いたら battle 起因」という切り分けは ★そのまま有効★。**

### 9-2. ★裁定 ② — baseline 3 値の『known-good』という格を 下げる★

`CutsceneVerify178.cs` の `BaselinePages=66 / BaselineChars=1601 / BaselineTermPc=0x1315` には
**「★known-good(user 実視覚 PASS 済)★」** と註が在るが、**§8-2 の実測により、その値が出る条件は
★11 種 176 件の未対応 opcode を 黙って len 消費して 飛ばす挙動★ だと判った。**

**⇒ 以後この 3 値を引くときは ★「11 種 176 件を飛ばした上の値」と冠する★。**
**⇒ 「壊れていない = baseline と一致」は ★gate 設計として正しい★ が、★baseline 自体が 忠実の証明ではない★。**
**（器への印字（harness が この 1 行を自分で出す）は boss1 に発注済。`CutsceneVerify178.cs` の sha が動くので
　ledger に新 step 行として記録すること＝黙って差し替えない。）**

### 9-3. dispatch（boss1 へ発注済・2026-09-13）

**scope** = **cut178 path 上の 11 種の handler 直読 sweep（★RE のみ・実装しない★）**。
**判定軸** = **op ごとに ★state を書くか / 演出だけか★**。
- **state を書く op が 1 つでも在れば** ⇒ **baseline 66/1601 は「飛ばしても同じ絵」の保証を失う** ⇒ その op が優先実装候補
- **全て演出のみなら** ⇒ 「skip は視覚的に無害」と書ける（**ただし live 視覚の判定は user のみ**）
- **判定が付かない op は ④ に落とし ★閉じ方の札（材料 / 実機 / 原理）を必ず添える★**（札なしの ④ は受理しない）

**★着手前に先行資産を当てること（重複 RE 禁止）★**:
`docs/RE_opcode_audit_4D_56_67_6C_2026-07-10.md`（**`0x4D` / `0x56` / `0x6C` の handler VA ＋ semantics が既在**。
`0x6C` = `0x800EEB40`・byte + 2×s16 座標 + byte-pair → table `0x80163F60`(stride 12) = **`0x4D` と同じ表**）／
`docs/RE_opcode_audit_4F_6E_2026-07-12.md`（`0x4F` = NameMap `VIEW_FOCUS_XZ`）／`docs/RE_event_opcode_map_2026-06-17.md`／`docs/opcode_lengths_exe.json`
**⇒ 新規 RE が要るのは ★残り 7 種（`0x22` `0x23` `0x29` `0x2B` `0x34` `0x4A` `0x4C`）★。**

**不変（dispatch に明記）** = 実装しない / gate 既定を変えない / push しない / **実機に接続しない** / main を触らない /
**凍結 8 値を動かさない** / comms repo は読取のみ / 既存 `-p2w*` は読取可だが **commit 禁止（tip を動かさない）**。

### 9-4. ★★訂正 — §9-3 の判定軸は 2 値で 粗かった（PRESIDENT 自己訂正・#931-P1）★★

**§9-3 で私は「`state` を書くか / 演出だけか」の 2 値で発注し、さらに
「全て演出のみなら ★skip は視覚的に無害★」と書いた。★後者は誤り★。**
**演出を飛ばせば ★絵は変わる★（camera が pan しない・model が動かない）。**
**正しくは「★cut178 gate の 3 scalar 次元には出ない★」でしかない。**

**⇒ 判定軸を ★3 値★ に改めた（boss1 へ発信済）**:

| | 意味 | 扱い |
|---|---|---|
| **(A)** | **flow / 進行に効く** = 分岐(`0x19` 系) / flag / event var / blocking wait の いずれかに届く | **飛ばすと text・進行が変わりうる ⇒ 優先実装候補** |
| **(B)** | **演出のみ** = 読み手が per-frame の 演出 executor だけ | **飛ばすと絵は変わるが cut178 の 3 値には出ない**（**「無害」とは書かない**） |
| **(C)** | 判定不能 | **④ ＋ 札（材料 / 実機 / 原理）** |

> **★★判定は「書くか」ではなく ★「誰が読むか」★ で決める★★** = **sink の読み手を列挙して分類する。**
> **「RAM に書く」だけでは (A) と (B) を分けられない。**

**併せて boss1 の早期所見（引用 grade）を凍結した**: 「`0x80163F60` へ書く ⇒ pure 演出ではない」は **(A) の根拠にならない**。
**`tag executor 0x8011B40C` が 16 entry の jump table であること自体は ★むしろ (B) = 演出 executor の形★ とも読める**
⇒ **どちらにも倒さず handler 直読を待つ。**

**boss1 の scope 申告（受理）** = **引ける 3 種**（`0x6C` = `0x800EEB40` / `0x4D` = `0x800ED864` / `0x4F` = `0x800ED994`）／
**`0x56` は ★書く先が未 RE ゆえ新規 RE に格上げ★**（87 件 = 最多）⇒ **新規 RE 8 種 / 引用 3 種**。
**換算の宣言**（`extracted/slps_017_97.bin` `sha256 db26754d…c3e27` / base `0x80090800` / `file_off = ram - base`）を **全番地 claim に添えさせる**。
