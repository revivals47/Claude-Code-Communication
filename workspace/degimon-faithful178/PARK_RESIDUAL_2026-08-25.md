# park 残件 1 枚 — 2026-08-25（boss1 が集約・★worker 稼働ゼロ★）

closeout 本体 = `PARK_CLOSEOUT_2026-08-25.md`（**`c57631d`**）。★本 doc は closeout を書き換えず、閉じきらなかった物だけを 1 枚に集めたもの★。
作成 = boss1（comms repo）。★worker は全員 idle・本 doc のために 1 便も動かしていない★。

## 1. ★過去の数の訂正（retro-sweep）★ — W1_X184 の 118 / 86
| 項 | 内容 |
|---|---|
| 旧 | 「main EXE から overlay 域への `jal` は **118 件 / 相異なる先 86 個**・最小 `0x80000000`」（p2w1 `W1_X184_RESULT_647A.md:37`） |
| 誤りの機構 | ★**data 領域を code として復号した分を含む**★（逆アセンブラは data を命令として読む） |
| 新 | ★code 領域限定（上端 = 最後の `jr ra` `0x80119E5C` / cutoff `0x8011A000`・開示つき）で **98 site / 相異なる 72 個**★ |
| 併せて | ★**どの overlay span にも入らない先は 0 件（72/72）**★ ⇒「image 外 = overlay 域」は **code 領域では成立** |
| 出所 | worker3 `4e61c54`（comms repo `W3_858C_OVERLAY_VA_MATCH_2026-08-25.md`） |
| ★本文への当て★ | ★p2w1 の該当行に **1 行の訂正註を挿入済**（commit **`20601ab7`**）★ = 別 doc に隔離しない（memory: 前置だけで済ませない・該当行に当てる） |
| ★閉じていない所★ | ★**第 17 module の不在は証明していない**★（「overlay は 16 で閉じる」は EXE 内 2 表・同 16 名からの主張であって、常駐 code の非存在証明ではない） |

## 2. ★worker3 が自分で壊した推論 2 件（型として残す）★
1. ★「一致は正しさの証拠ではなかった」★ — worker3 の器は W1 の 118/86 を**そのまま再現**した。
   ⇒ ★両器が同じ穴（data-as-code）を踏んでいた★。memory: `feedback_verify_the_oracle_not_just_the_match`。
2. ★「load 呼びと同一関数の image 外 `jal` は その overlay 宛」は **偽**★ — 反例 `0x800ADC2C`（K=14=MURD）と
   同関数の `0x800ADC94` → MURD span 外／TRN・TRN2 も同一関数で連続 load。
   ⇒ ★router 表は「何を load するか」の表であって **呼び先の帰属には使えない**★（∴ 確定は 1 件だけに留まった）。

## 3. ★lane 間で残った不一致（数は一致・帰属だけ違う）★
- worker2 = **8 sub** / worker3 = **4 sub**（`0x07`(11) / `0x1D` / `0x20` / `0x28`）に image 外 `jal` を帰属。
- ★**件数 14 は両者一致**（別々の器で同数）★ ⇒ ★E-1 の site 数には影響しない★。
- 差の原因（未解決）= fall-through / 共有 body の扱い。★open のまま残置★（PRESIDENT 承認）。

## 4. ★格が「仮定つき」のまま止まった数★
- ★E-1 = 586 / 652★（worker2・X-231）= ★引き算（36 − 32）由来で本 run では**再計測していない**★。
  ⇒ ★closeout（`c57631d`）の 582 / 652 は書き換えない★（未再計測の数を closeout に入れると格が落ちる）。
  ⇒ ★再開時の札 = `w2_scnreach` の census 撃ち直し（静的・材料あり）★。

## 5. ★決まらないまま閉じたもの（札つき）★
| 件 | 状態 | 札（何が来れば閉じるか） |
|---|---|---|
| #861-A 第 3 値（母数の無い内訳の件数） | ★決まらない★（器が陽性対照 `32+7+27+48 = 114 ✓` を落とした） | ★器 = 90 行を手で 3 値に分ける（30〜40 分）★ |
| `0x64` sub arm の 14 件の overlay 帰属 | ★1 件も決まらない★（最良 {TRN, TRN2} は **load VA 同一 `0x80088800` で原理的に分離不能**） | ★arm block の関数境界特定（静的・image 内）★ |
| `0x07` の表引き `jr` | ★呼び先の仮定では原理的に解けない★ | ★表を読む（`0x8011B2BC` と同じ手）★ |
| MWo1 の section 配置 | ★span = [VA, VA+size) は仮定★ | ★overlay 開封（#646-X ゆえ PRESIDENT の例外承認が要る）★ |
| s2 の完全 proxy | ★存在しない★（`0x80146746` は −1 と 0 を分けられない） | ★実行 breakpoint（安定 emulator）／完全 proxy の発見★ ＝ ★park 解除の条件★ |

## 6. 不変（全件維持・本 doc 作成時点）
remake code 0 行 / ★emulator run 0 本★ / compile 0 / ★push HOLD（commit は各 tree 保全のみ）★ / overlay 開封禁止（#646-X）/
視覚凍結 / read only / poll only。★worker 3 名とも idle（新 dispatch ゼロ）★。
