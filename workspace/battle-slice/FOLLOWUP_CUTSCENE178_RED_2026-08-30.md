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
