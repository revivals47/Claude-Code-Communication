# user 視覚 gate — 結果の解釈枠(事前固定)worker2, 2026-08-08

**目的**: user の回答を ★過大解釈しないため★、回答が出る **前** に「どこまで言えるか」を固定する(pre-registration)。
**注意**: user には渡さない。★我々が結果を読む時の枠★。

> ★改訂履歴(重要)★: 本 doc の初版(19:13)は ★V2 = remake を見る gate★ という前提で書かれていた。
> その後 PRESIDENT が gate を分割裁定した(worker3 の指摘: ★post-merge の remake は必ず unshifted を描くので、remake を見ても同語反復★):
> - ★V2 = **原盤** を見る★(DuckStation + `SLPS-01797_9`)
> - ★V2R = **remake** を見る★(★完成 claim 凍結解除の要件であって、shift 判定ではない★)
>
> ∴ 初版 §3 の分析は ★内容は正しいが対象がずれていた★ — あれは **V2R** についてのものだった。本版で §3 = V2R、§4 = V2 に整理し直した。

---

## 1. build 時点の pass 条件ステータス(★V2R にのみ関係する★)

★V2 は DuckStation で原盤を見るので、この表は V2 の解釈に一切関係しない★。V2R の読み方にのみ使う。

| | 条件 | 状態 |
|---|---|---|
| P1 placement 6 値一致(989 entry / 223 map) | | ★未確認★ — 全 map dump 突合は未実施 |
| P1b gating と placement が同一 map index 由来 | | ★未確認★ |
| P1c index 権威経路 `gp-0x6ca6` | | **原盤側は確認済**(savestate 10 件)。★remake 実装が従うかは未確認★ |
| P2 json ↔ raw 同値(966 entry) | | 受領値のみ。本 build での再実行は未 |
| P2b numImg が table entry 由来 | | ★未確認★(worker1 実装依存、私は未検証) |
| P3 entity 数 = 先頭 halfword | | ★未確認★ |
| P4 容量 8 fail-fast / silent clamp 無し | | ★未確認★(count=9 合成入力テスト未実施) |
| P5 gating(OFF entry 21 件で 0 体) | | ★未確認★ |
| P6 debug-gate と gating の独立判定 | | ★部分★ — 間接的傍証にはなるが 2 機構の分離は assert しない |
| P7 OFF-inert(dump sha256 一致) | | ★未確認★ |
| P8 Unity CS0 error 0 | | build が通っていれば確認済。★compile が通っただけで correctness は一切 assert しない★ |
| P9 ViseNpcBootstrap 差分の起票 | | doc 上は起票済。適用可否は user 判断(V5) |
| P10 user 実視覚 | | ★実施中★ |

★私は worker1 の build 内容を検証していない★。実装依存行は worker1 報告で置き換わる。

---

## 2. ★V2 / V2R いずれが PASS でも残る blocking★

| # | 残る理由 |
|---|---|
| **X1** | ★V1 / V3 / V4 / V5 が未消化★なら P10 は close しない |
| **X6** | RAM 実測は 6 map / 25 record = ★gate ON 223 map の 2.7%★。1 座標の目視はこの率を動かさない |
| **X14** | table 論理長「255 か 256 slot 末尾未使用か」未決 |
| **X5** | MGEN17 未測定(★pass ではない★) |
| **X13** | 棄却済 signature を分類に使っていないことの確認は未実施 |
| — | ★P1 / P3 / P4 / P5 / P7 の機械判定が未実施★(§1)。目視はこれらの代替にならない |

---

## 3. ★V2R(remake を見る)が assert する範囲★

★V2R は shift 判定ではない★。post-merge の remake は ★必ず unshifted を描く★ので、remake の描画が unshifted 予測と一致しても ★同語反復であって shift 説の証拠にならない★。

**V2R の位置づけ** = ★完成 claim の凍結解除要件 = 「実際に動くか」の動作確認★。

**PASS で言えること**:
- ★twna01 が起動し、placement が unshifted 予測どおりに描画された★ = ★実装が意図どおり配線され、build が動く★
- それだけ。★以下は assert されない★:
  - shift 説の是非(★同語反復ゆえ原理的に不能★)
  - 原盤との一致(★V2R は remake しか見ていない★)
  - 他 6 座標 / 他 222 gate-ON map
  - type→model 対応表の正しさ

**FAIL で言えること**: ★実装 / build 側の問題★。候補 =
(a) EntityPlacer が RAM 準拠に配線されていない / (b) 描画層が別 source を引いている / (c) roster `type30=TOKO` の誤り / (d) 座標→画面位置の対応の誤り / (e) build 成果物の欠落(StreamingAssets/maps 空の前例あり)

---

## 4. ★V2(原盤を見る)が assert する範囲★

**V2 が実際に検証するもの** = ★`.map` bytes → type id → species table → **原盤画面上の実個体** という chain の end-to-end★。

★ここが、bytes 決着が **原盤の実ピクセルと出会う唯一の場所**★(PRESIDENT の位置づけ)。§3 の V2R と違い ★同語反復ではない★ — 原盤は我々の実装と独立に存在するので、chain のどこかが誤っていれば不一致が出うる。

**PASS(予測と一致)で言えること**:
- ★twna01 の `(798,0,-1656)` 1 座標について、bytes → type id → species → 原盤の実描画 の chain が end-to-end で通った★
- これは ★byte 判定 25/25 に対する独立な確認★であり、V2R には無い価値がある

**★assert しないもの(同じ厳密さで)★**:
- 他 6 座標 / 他 222 gate-ON map(★X6: 2.7%★)
- ★remake 側の正しさ — V2 は remake を見ていない★
- chain の各段の個別正しさ(end-to-end が通っても、2 箇所の誤りが相殺している可能性は排除されない)

**FAIL(予測と不一致)で言えること**: ★重い★。byte 判定 25/25 と衝突するので ★chain のどこかが誤っている★。切り分け候補 =
(a) roster `type30=TOKO` の誤り / (b) 座標→画面位置の対応の誤り / (c) 原盤の描画が entity array 以外の source を引いている / (d) byte 判定側の前提の誤り
→ ★「V2 FAIL = shifted が正しい」と直結させない★。上記を切り分けてから。

---

## 5. ★色語の食い違い — 解消済。ただし経緯を残す★

**経緯**: 19:13 時点で、V2 の期待色の語が食い違っていた:
- 私の回帰 oracle doc(V2)= 「★白★トコモン(TOKO)か ★黄★タネモン(TANE)か」
- boss1 中継 = 「★紫★が居る = unshifted 予測と一致」

私はこれを ★user に渡る前に摘出★し、色語に依存しない訊き方を推奨した。→ ★自由記述化(worker3 §11.1: 選択肢も色語も種名も出さない)で解消済★。

**★残す理由 — 色語で訊こうとしていたこと自体が設計欠陥だった★**:
- ★色は remake 側の色であり、原盤の色と一致する保証がない★(PRESIDENT 指摘)。
  V2 は原盤を見る gate なので、★remake 由来の色語を期待値として user に提示することは、原盤の観測に remake の前提を混入させる★ことになる
- 加えて、色語を提示すること自体が ★priming★ になる(worker3 の「原盤に存在しないものを原盤の質問に書かない」と同型)
- ∴ 解消の本質は「白か紫かを決めたこと」ではなく ★「期待値を提示しない訊き方に変えたこと」★

---

## 6. ★教訓(A 群): doc は書いた瞬間から stale になりうる★

本 doc の初版は ★書かれた時点(19:13)では正しかったが、その後の gate 分割裁定で **対象がずれた**★。内容は正しいまま、指している先だけが誤りになった。

→ ★裁定 / 前提が変わったら、既存 doc に遡って「これは今も同じ対象を指しているか」を確かめる★(`feedback_rebaseline_derived_docs_vs_code` と同型。boss1 が本日何度も躓いた型でもある)。

★そしてこの stale は handoff doc の査読で捕まった★ — ★doc を索引化する作業それ自体が stale の検出器として機能した★。
索引化は「まとめる作業」に見えるが、★各 doc が何を指しているかを 1 行で言い直す過程で、指し先のずれが露出する★。closeout を「事務作業」として省略しない理由がここにある。
