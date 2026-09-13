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
  **`Len[0x6C]=8` は worker1 EXE 直読 TSV と GUARD 一致枠。**
  **★2026-09-13 訂正（boss1 #931-B1 便 002・私が受理）★** = **本文が引いた `fb808667…` は ★旧版 blob★**。
  **HEAD 版は `5f18d9094ab6b66ca25c47b4f8fa38ff60a9d540`**（両 blob で **本 sweep の 11 op は全 11 行 bit 同一**・差分は `0xFB` 行追記と見出し 3 行）⇒ **以後の引用は `5f18d909`**。
  **★さらに足す所見★** = **器（`OpcodeTable.ExeTsvHash`）は `fb808667` を ★印字するだけで照合していない★**（`ExeLen97` は hardcode・TSV を読まない）
  ⇒ **「GUARD PASS」は ★Len 値の一致★ であって ★出所の一致ではない★**（**出所 hash を印字するが検証しない器** = 別枠で登録）。

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

---

## 10. ★★PRESIDENT 実測（2026-09-13 夕）— ★0x4A は VM を yield する★／訂正 3 件★★

**器** = `tools/p_opcode_census.py`（**anchor 5/5 で検定してから数を出す**）／出力 = `logs/cut178_ab_20260913/p_opcode_census_out.txt`
**換算** = `extracted/slps_017_97.bin` `sha256 db26754d…c3e27` / base `0x80090800` / `file_off = ram - base`（capstone 5.0.7）

### 10-1. ★訂正 3 件（boss1 の読み 2 件 ＋ ★私の第一読み 1 件★）★

| # | 誤り | 実測 |
|---|---|---|
| ① | boss1 = 「`0x4A` handler の **同じ枝の直後**に blocking signature」 | **`0x800ED754` は ★全 arm の合流点★**。翻訳表の全 arm が `b 0x800ed754` で落ちる ⇒ **blocking は枝ではなく ★共通 path★** |
| ② | **私** = 「cut178 の operand は `0xFF` でないから blocking を踏まない」 | **★誤り★。合流ゆえ ★3 件すべて踏む★**（実 operand = `pc=0x3C:0xC8` / `0x676:0xFC` / `0x7D2:0xC8`） |
| ③ | boss1 が `0x4A` として引いた `0x800ED774`〜 | **★`0x4B` の handler 先頭★**（table 直読で bound = `0x4A` は `0x800ED53C..0x800ED770`）。**型 = 近接命令は scope の証拠にならない** |

### 10-2. ★`0x800913C0` の素性（in-image の裏取り 2 件つき）★

- **stub の形** = `addiu t2,0xA0 / jr t2 / addiu t1,0x14` = **BIOS A0 表 index `0x14` の呼び出し stub**。
  **★「A0[0x14] = longjmp」は 外部知識であって image 読みではない★**（格を落として扱う）。
- **裏取り (i)** = **router 先頭 `0x800F076C` が ★同じ jmp_buf `0x80164068`★ で `0x800913B0`(= A0 index `0x13`) を呼ぶ**。
- **裏取り (ii)** = **band-out 停止 path `0x800F08A4`-`B8` が ★`0x4A` と bit 同一の呼び（`a0=0x80164068` / `a1=2` / `jal 0x800913C0`）★**（既登録 fact と一致）。
- **⇒ ★`0x4A` は router の停止と ★同じ機構★ で VM を抜ける。差は `0x4A` が stop flag `gp-0x6cb0` を立てないこと★。**
- **★yield の口 census = `jal 0x800913C0` が EXE 全走査で 36 件★** ⇒ **「blocking」は例外事象ではなく ★VM の常用機構★**
  ⇒ 以後は **「blocking」で止めず ★「yield（router 先頭の setjmp へ戻る）」★ と書く**。

### 10-3. ★11 種の depth-1 census（band 表 base は ★router 直読★・推定なし）★

**band → sub-interpreter → table base**: `0x10-0x27`→`0x800EC4AC`/`0x8011B0F8` ／ `0x28-0x3F`→`0x800ECAB4`/`0x8011B1A0` ／
`0x46-0x58`→`0x800ED434`/`0x8011B200` ／ `0x64-0x7E`→`0x800EDE88`/`0x8011B3A0`
**器の検定** = anchor 5/5 一致（`0x6C`=`0x800EEB40` / `0x4D`=`0x800ED864` / `0x56`=`0x800EDC84` / `0x4F`=`0x800ED994` / `0x4A`=`0x800ED53C`）。

| op | 件数 | handler | 命令数 | yield | gp flow cell への store |
|---|---|---|---|---|---|
| **`0x4A`** | 3 | `0x800ED53C..0x800ED770` | 142 | **★1★** | **`gp-0x6cbc` = mode（★router 先頭 `0x800F0748` が読む★）＋ `gp-0x6d00`** |
| `0x6C` | 1 | `0x800EEB40` | 46 | 0 | - |
| `0x4D` | 4 | `0x800ED864` | 32 | 0 | - |
| `0x4C` | 10 | `0x800ED7F0` | 29 | 0 | - |
| `0x56` | 87 | `0x800EDC84` | 10 | 0 | - |
| `0x4F` | 2 | `0x800ED994` | 26 | 0 | - |
| `0x34` | 8 | `0x800ECDD4` | 44 | 0 | - |
| `0x29` | 58 | `0x800ECB60` | 10 | 0 | - |
| `0x2B` | 1 | `0x800ECBD4` | 15 | 0 | - |
| `0x22` | 1 | `0x800EC90C` | 14 | 0 | - |
| `0x23` | 1 | `0x800EC944` | 8 | 0 | - |

> **★限界の明示★ = これは ★depth 1（handler body のみ・閉包なし）★ ⇒ 「0 件」は (A) の ★下界★ であって ★演出の証明ではない★。**

### 10-4. ★件数上位は薄い委譲だった ⇒ 残りの仕事は handler ではなく callee★

| op | 件数 | handler が やること（全命令を読んだ） |
|---|---|---|
| `0x56` | **87** | operand 2 byte → **`jal 0x800EFA24(b1,b2)` だけ**（10 命令） |
| `0x29` | **58** | operand 2 byte → **`jal 0x800CE5B4(b1,b2)` だけ**（10 命令） |
| `0x23` | 1 | operand 1 byte → `jal 0x800CDA6C(b)` |
| `0x22` | 1 | operand 1 byte ＋ **`lui at,0x8017 / lw v0,-0x4f7c(at)` = ★`0x8016B084` の語の下位 byte を読む★** → `jal 0x800F0CD0(b, that)` |

**⇒ `0x22` は件数 1 だが ★既登録 fact（`0x8016B084` = actor slot1 の pointer-base 配線）に触る★** ⇒ **「1 件だから後回し」にしない。`0x8016B084` の読み手として扱う。**
**⇒ 残作業 = callee 4 本（`0x800EFA24` / `0x800CE5B4` / `0x800CDA6C` / `0x800F0CD0`）＋ `0x4C`/`0x4D`/`0x4F`/`0x6C`/`0x34`/`0x2B` の callee。**

### 10-5. ★worker1 の閉包 tool に 陽性対照を課した★

**「`0x56` = 22 関数・深さ 6・flow cell 到達 0 件」は ★tool の power が未検定★** ⇒
**同じ tool を ★`0x4A` に当てて flow cell 到達（`gp-0x6cbc` / yield）を出せること★ を示させる。**
**出ないなら `0x56` の 0 件は ★器の盲点★ と区別できない。**

### 10-6. ★現時点の裁定② への効き★

**`0x4A`（3 件）が ★VM を yield し、router の先頭が読む mode cell を書く★** ⇒
**★飛ばした 176 件の中に「VM の時間構造を変えるもの」が混ざっていた★** = **§8-3 の格下げは 実測で裏打ちされた。**
**★ただし「`0x4A` を実装すれば 3 値が動く」とは書かない（測っていない）。★**

---

## 11. ★★`0x4A` の正体 = 「演出の完了を待つ」op（2026-09-13 夜・PRESIDENT 直読）★★

**器** = capstone 5.0.7 / `extracted/slps_017_97.bin` `sha256 db26754d…c3e27` / base `0x80090800` / `file_off = ram - base`
＋ **`DG.SCN` 直読**（`entry178 = DG.SCN[0x82000..0x83800)` / `sha256 4d776b2c…5e5b`）

### 11-1. ★機構（mode 分配 → resume 判定を全部読んだ）★

`0x4A` は **mode slot `gp-0x6cbc` に `0x4A` を立て、翻訳値を `gp-0x6d00` に置き、yield する**。
**次回 entry で `0x800F0310` が mode を見て `mode==0x4A` なら `0x800F062C`** へ入り、`gp-0x6d00` の値 `v` で:

| `v` | 待つ条件 |
|---|---|
| `0x19` | **`f_800EC210`**（= `lw gp-0x6d10 / jr ra` の **2 命令 accessor**）が **0 の間 待ち続ける** |
| `0x1A` | `gp-0x6d57` が **非 0 の間 待ち続ける** |
| `0xFF` | **22 slot 全部の `[0]` が `0xFF` になるまで**（`loop i<0x16`） |
| その他 | **slot `v` の `[0]` が `0xFF` になるまで** |

**条件が満たされた時だけ `sb zero, gp-0x6cbc`（mode clear）**。そして `0x800F072C` → `0x800F0748` で
**★mode != 0 なら 次の opcode を実行せず return★**。

> **★∴ `0x4A` は「record table `0x80163F60` の command が完了するまで VM を進めない」= (A) 確定★**
> **（yield はその ★実装手段★ であって、op の意味は ★wait★）**

### 11-2. ★cut178 の 3 件は ★静的に解けた★★

- **`0x4F@0x36`** は **`0x80163FD8` に `tag 6` ＋ `s16 x,y` を書く**（直読）。**`(0x80163FD8-0x80163F60)/12 = ★slot 10★`**
- **`0x4A@0x3C`** の operand `0xC8` は **`0x4A` 自身の翻訳表で `0x0A` = ★slot 10★** ⇒ **★直前の `0x4F` の完了を待っている★**
- **`0x4A@0x7D2`** も **`prevOp=0x4F` / operand `0xC8`** = **同形**
- **`0x4A@0x676`** の operand `0xFC` は **`f_800F50A8(0xFC)` = slot 1**。**直後 `0x56@0x678` は `b1=0xFC`（FC arm = `0x8016B084`）**
  ⇒ **同じ actor の「完了待ち → anim 設定」という並び**

### 11-3. ★`f_800F50A8` の正体 = ★id → slot 解決★（`0x4A` の else 枝と `0x4C` が共用）★

`0xFD`→**slot 0** ／ `0xFC`→**slot 1** ／ それ以外は
**`0x8013CDBC + i*4` の pointer が非 0 の `i`(0..7) について `0x8016B104 + i*0x68` の `+0x65` が id と一致したら slot = `i+2`**、
不一致なら **`0xFF`**（**`0x4C` はこの `0xFF` で bail** = `0x800ED820`）。

> **★∴ `0x4C` の slot は ★実行時の entity table の内容に依る = 静的には決まらない★★**（札 = **実機 or runtime**）。
> **一方 `0x4F` の slot 10 と `0x4A` の直接翻訳値は ★静的★** ゆえ **cut178 の `0xC8` 2 件は確定**。

### 11-4. ★判定軸の運用を改訂（§9-4 の 3 値に 追補）★

**`0x4C` / `0x4D` / `0x6C` / `0x4F` は ★行為は (B)（演出 command の登録）だが ★`0x4A` の待機対象★ = flow と結合している★。**
⇒ **★(B) と書くときは必ず「ただし `0x4A` の待機対象」を併記する★。「単独で飛ばしても進行に無関係」とは ★書かない★。**

### 11-5. ★★remake 実装への 設計警告（登録）★★

**`0x4A` は `[0]==0xFF` を待つ。★完了 writer（slot に `0xFF` を書き戻す者）が居なければ 0x4A は永久に待つ★。**
**⇒ ★`0x4A` ＋ 登録 op（`0x4C`/`0x4D`/`0x6C`/`0x4F`）を実装して ★完了 writer を実装しないと cutscene が hang する★★。**
**⇒ 実装は ★3 点セット（登録 / 待機 / 完了 writer）★ で行う。片方だけの land を承認しない。**
**⇒ worker3 の census の最重要項目を ★`0xFF` writer の全列挙★ に昇格させた（順序も変更発行済）。**

### 11-6. ★boss1 の母数指摘を 別系統で検算（bit 一致）★

**boss1 = log の `ctx` 読み / 私 = `DG.SCN` 直読** ⇒ **`skip` byte 87/87 が `0x00`**、
**`b1` 分布**（`0x05`×30 / `0x08`×23 / **`0xFD`×16** / `0x0A`×6 / `0x06`×4 / `0x07`×4 / `0x0C`×2 / **`0xFC`×2**）、
**`FD` 16 件・`FC` 2 件の ★pc 集合まで完全一致★**。
⇒ **「`0x56` 87 件 = (B)」は ★母数 69/87 の上の判定だった★** という boss1 の指摘は **正しい**（worker1 へ rescope 発行を受理）。
**型** = **分岐 handler の判定は ★arm 全数を母数に★ 取る。arm 1 本の読みから op 全体を語らない。**

### 11-7. 格

- **★観測確定★** = 11-1 / 11-2 / 11-3 / 11-6（**EXE 直読 ＋ `DG.SCN` 直読・2 系統**）
- **★未検証（書かない）★** = **完了 writer の在処**（worker3 進行中）／**`0x4C` の slot**（実行時依存）／
  **「`0x4A` を実装すれば cut178 の 3 値が動く」**（測っていない）／**`0x56` の (A)/(B) 確定**（anim block の読み手待ち）
