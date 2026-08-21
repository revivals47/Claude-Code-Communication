# W3 #600-C — ★③ 段の var control★ の設計（★実装 0・撃つのはまだ★）

- 便: #600-C ／ 背景 job: 0 ／ ★run 0 本・game code 非触・push HOLD★
- 受領 = ★Phase 2 の受理は 3 本立て★ = ★①OFF bit 同一★ / ★②時刻 control（済 = 私の 4 本）★ / ★③段の var control（未・本 doc）★
- ★境界（PRESIDENT 明記・畳みません）★ = ★②で効いたのは ★時刻 gate★ であって ★段★ ではありません★ ⇒ ★『管が生きている』を『段が効く』に畳まない★

---

## §0 答（3 行）

- ★① 注入口は ★`EntityPlacer` の中ではなく `GameState` に★ 置いてください★ = ★中に置くと ★配線ではなく詰め物を測る★ ことになります★
- ★② ★評価時の値（3 値の verdict / var / flag）を印字しないと、非入替を帰属できません★★ ⇒ ★印字を受理条件に含めてください★
- ★③ 2 値の署名は ★極端に大きい★ ので見分けは容易です★ = ★stic02 は ★1 体 ↔ 5 体★・fact02 は ★1 体 ↔ 2 体★★

---

## §1 ★なぜ ②（時刻 control）の信頼を継承できないか★

- ★時刻 control が通ったのは ★`TimeGatedPlacement` → `ShouldPlace`★ の路★
- ★段が通るのは ★`CurrentFlagGetter` → `TimeGatePreGate.Passes` → `elseSlots` / `elseOnlySlots`★ の ★別の路★★
- ★しかも段の路は ★今 production で dead★★ = ★`TryEvaluate`（3 値）の production 呼び元 = 0 件★・★`ElsePlaceStages` の production 呼び元 = 0 件★・★`EntityPlacer` 内の `getVar` = 0 件★（#600-C の census）
- ⇒ ★★∴ ★③ は ★自前の動く陽性対照★ を持たなければ、★配線したつもりで no-op でも緑になります★★★

## §2 ★注入口の置き所（★推奨 1 つ★）★

| | 案 | 判定 | 理由 |
|---|---|---|---|
| ★推奨★ | ★`GameState` に入れる★ = env `DEGIMON_FORCE_VAR=110:N` を ★session 生成時に `SetVar` で適用★ | ★採る★ | ★`getVar` → `GameState.GetVar(110)` の ★鎖を丸ごと通ります★★ = ★配線そのものを測れます★ |
| 却下 | `EntityPlacer` の中で偽の `getVar` を作る | ★却下★ | ★測る対象（`GameManager.Instance?.Session?.GameState` を引く配線）を ★迂回します★★ = ★詰め物を測ることになる★ |
| 却下 | `DEGIMON_OP24=1` で RNG に書かせる | ★却下★ | ★確率ゆえ ★1 run が 2 値になりません★★（#596-C で確認済の性質） |

- ★注入口は ★既定 OFF★・★env 未設定なら 1 bit も動かない★ こと★（①OFF bit 同一 と両立させるため）
- ★注入は ★placement より前★★でなければ効きません（`FieldState` が map を load する前 = session 生成時が安全）

## §3 ★★印字（これが無いと非入替を帰属できません）★★

- ★段の OR 項★ = ★stic02 = `var[110] > 0` ★OR★ `Flag 309 IsSet`★ / ★fact02 = `var[110] > 2` ★OR★ `Flag 227 IsSet`★
- ⇒ ★★flag が立っていると var を 0 にしても段は通ります = var control が ★死にます★★★
- ★census★ = ★`SetFlag(309)` / `SetFlag(227)` を書いた code = 0 件★（`unity/Assets/Scripts/**`）★但し VM が `0x1C` で動的に立て得ます★ ⇒ ★「既定 0 のはず」を前提にしない★
- ⇒ ★★受理条件に ★1 行の印字★ を入れてください★★:

```
[PLACE-PREGATE] map=stic02 verdict=Blocked var[110]=0 flag309=False  elseSlots={4} 適用=elseSlots(段を通らない)
[PLACE-PREGATE] map=stic02 verdict=Passed  var[110]=1 flag309=False  elseOnlySlots={4} 適用=elseOnly(段を通った)
```

- ★3 値をそのまま出すこと★ = ★`NotApplicable` を印字しないと「素通り」と「通った」が見分けられません★（★#596-C で私が踏んだ「退路を true に畳む」と同じ穴★）

## §4 ★2 値の署名（★撃つ前の予測として先に固定します★）★

★`TryEvaluateStages` の逐語（`TimeGatePreGate.cs:367-388`）＋ `EntityPlacer.cs:378-397` から導いた形です。★

| 条件 | verdict | 置かれる rec | 合計（昼 hour=12） | 備考 |
|---|---|---|---|---|
| ★stic02 var[110]=0★（flag309=false） | ★Blocked★ | ★{4} だけ★ | ★1 体★ | ★`elseSlots != null` ゆえ ★時刻 gate は適用されません★★ |
| ★stic02 var[110]=1★（flag309=false） | ★Passed★ | ★{0,1,5,6,7}★ | ★5 体★ | rec4 を除外 ＋ 時刻 gate 適用 |
| ★fact02 var[110]=0..2★（flag227=false） | ★Blocked★ | ★{4} だけ★ | ★1 体★ | 同上 |
| ★fact02 var[110]=3★（flag227=false） | ★Passed★ | ★{0,1}★ | ★2 体★ | rec4 を除外 ＋ 時刻 gate 適用 |

- ★∴ ★入替の署名は「集合が入れ替わる」より強く、★体数そのものが 1 ↔ 5 / 1 ↔ 2 に動きます★★★
- ★2 値の読み方（②と同じ形）★:
  - ★動いた = 段が実際に評価されている証拠★ ／ ★動かなかった = 段が評価されていない（配線が死んでいる）証拠★
  - ★どちらも同じ重さで出します★

## §5 ★★設計上の警告（★land の前に見ておく価値があります★）★★

- ★`Blocked`（段を通らない）のとき ★時刻 gate が丸ごと適用されません★★（`EntityPlacer.cs:381` の `elseSlots == null` 条件）
  ⇒ ★∴ ★stic02 を段に載せると「通らない夜」は ★1 体だけの map★ になります★★（今は昼 6 / 夜 6）
- ★これは worker2 の逐語（通らない = `(109, 4)`）と向きは合っています★ が、★見た目の変化がとても大きい★ので ★user 実視覚の前に boss1 / PRESIDENT が知っておくべき量★です
- ★私は「忠実かどうか」を判定しません★（★原盤側の次元・worker1 / worker2 の座★）

## §6 ★③ を撃つときの手順（申告・★まだ撃ちません★）★

1. ★①OFF bit 同一★ を先に取り直す（注入口を足すと code が動くため）
2. ★`DEGIMON_FORCE_VAR=110:0` と `=110:1`（fact02 は `:0` と `:3`）で ★同じ器・同じ hour・env 1 つだけ違い★ の 2 本ずつ★
3. ★`[PLACE-PREGATE]` の verdict / var / flag を毎 run 印字★し、★§4 の表と突き合わせる★
4. ★非入替なら「段が評価されていない証拠」として そのまま出す★（★noise にしません★）

## §7 書かなかったこと

- ★実装 / compile / run★（★本 doc は 0★）／ ★land・push・README★
- ★『忠実かどうか』の判定★／ ★視覚の判定（user 実視覚まで凍結）★
- ★注入口を足すかどうかの採否★（★boss1 / PRESIDENT の座★）／ ★A5 の EXE 読み（PRESIDENT gate で停止中）★
