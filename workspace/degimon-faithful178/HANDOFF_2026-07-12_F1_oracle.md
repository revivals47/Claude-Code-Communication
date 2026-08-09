# HANDOFF — 2026-07-12 / F1: correctness oracle 再設計（第2便）

dispatch: `DISPATCH_2026-07-12_F1_oracle.md`
base: **`c6fec7f`**（canonical Len）。main は当初 `7a3d6e9`。
**全 commit local / push ゼロ / cutscene 不触 / 配線ゼロ を最後まで維持。**

---

## 0. 一行要約

**壊れた測定器（prefix 判定の oracle）を、実機 DuckStation を authority にした differential testing に置き換えた。**
その過程で、静的読解では 9 回見つけられなかった opcode length バグを **実行が 2 件（10・11 例目）炙り出した**。
そして **同一構造の失敗（偽 GREEN / 射影を本体と取り違え）が 1 session で 6 着の衣装で生え、boss1・PRESIDENT・worker 全員が踏んだ**。

---

## 1. なぜこの dispatch をやったか

忠実化（MAPHEAD + return-stack + 0xFB + 0x17）は **user 実視覚 PASS 済の cutscene を壊し得る**。
だが **現行 harness（Gamma1aSweep / VerifyEntry）は regression を検出できない**。
`VerifyEntry` は **4 重に壊れている**（prefix 判定 / 静的 byte 順 scan / 到達不能 text も oracle / `WaitingChoice` break で偽 GREEN 増幅）。
= **gate が甘いのではなく oracle が原理的に不健全**。だから oracle を先に作る。配線はその後。

---

## 2. 何を作ったか（authority = 改造 DuckStation）

**user 裁定 = 「自作 emulator でなく DuckStation を借りる」が完全に勝った。**

- **`duckstation-regtest`（headless、Qt 不要）+ `AddBreakpointWithCallback`（Release build で機能）が既存** ⇒ hook 機構の自作不要。「改造」は「callback 登録」に縮小。
- **hook 点 `0x800F0780`**（PC がまだ +1 されていない唯一の点）。`$gp` は **live レジスタから読む**（定数埋め込み = 循環、を回避）。
- **savestate 戦略**: 本物のゲームが作った state を load（authentic かつ non-circular）→ clean 命令境界で **`StartScript(0x800F0188, scn, key, 1)` を guest-BP 注入** → ゲーム自身の loader が走る。**我々は request を注入、decode 済み body は注入していない**。
  - ★`0x800F0150` は scenario 0 hardcode ゆえ使えない。汎用の入口は `0x800F0188`★（PRESIDENT が disasm で先回り）。
- **決定性テスト PASS**: 同一 savestate + 同一 launch を 2 回 → **bit-identical**。flaky（157→0 event）は VM 非決定性でなく host 入力 timing が真因、と実測で確定。

---

## 3. 数値成果（honest、水増しゼロ）

- **launch: 1278 section（scenario 1-224）成功 / 失敗 0**。MAPHEAD 281 section は field-loop に戻らず stall ゆえ **honest 除外**（別記）。
- **完走（自然終端到達）= 471**（return_fe 467 + terminal_ff 4）= **PASS を主張できる唯一の集合**。
- **未完走 = 807**（idle_stop 802 + truncated_cap 5）= **BLOCKED（緑にしない）**。
- 実行 distinct opcode = **65 / 256**（残り 190 = 未検証）。7685 event。
- **clean diff（shipping C# vs 実機、PC 列のみ、実機完走 469 本対象）= 135 / 469 PASS**。
  - FAIL 内訳: **A=293（C# が authority 命令の【内部】を fetch = 実 decode バグ、最大 class）** / B=32 / 長さのみ相違=9。
  - ★boss1 の「BodyStart(+4) で step 0 付近多数 FAIL」予測は **外れた**★ — `PlaySection` は section offset から開始し **BodyStart を使わない**ため（この launch 経路では効かない）。実測が予測を覆した。
  - worker2 は報告前に **自分の harness バグを 1 件潰した**（event 帰属は file 順でなく seq/after_seq。file 順だと前 run の終端 `0xFE` が次 run 先頭に混入し「偽 PASS=3」が出ていた）。

**次元を明記**: 検証できたのは **PC 列（pc, op）のみ**。headline = **PC 列一致 135 / 469**。
`var_w / flag_r / var_r / text / term / warp` = dims.txt 未宣言 = BLOCKED。
**flag_w も BLOCKED に戻した（下記 §3.5）** — authority 側が壊れているため。

### 3.5 ★flag_w 次元は authority 側が壊れている（worker2 が実証）★

PC 列が完全一致なのに flag_w だけ違う 13 本を state 次元が検出。だが **原因は C# ではない**:
`(scn=35,key=53)` step2 `pc=0x02b0 op=0x1C(SET_FLAG)` / step3 `pc=0x02b4 op=0x1D(CLEAR_FLAG)` を
**実機は同じ PC で実行しているのに flag_w event を 1 件も出していない** ⇒ **worker3 の ra-gate が VM 由来 write を落としている（false negative）**。
⇒ **「C# が余計な flag を書いている」とは言えない**。**「2 次元 PASS=122」も主張しない** —
壊れた authority と一致しても「両方 write ゼロ」の自明一致で検証になっていない（= codex で塞いだ「write authority 無しの PASS」が、今度は authority 破損の形で再来）。
⇒ **flag_w = BLOCKED。ra-gate 修正は follow-up（G7）**。

---

## 4. 実行が見つけた新規 length バグ（本 dispatch の主旨の直接成果）

**静的読解では 9 回見つけられなかったものを、実行（sweep）が炙り出した。boss1 が EXE 直読で裏取り済。**

| opcode | runtime | 実行/EXE確定 | handler | 内訳 |
|---|---|---|---|---|
| **`0x75`** | 4 | **12**（8-byte under-consume、71 sample） | `0x800EF0A0` | 0edc(+1)+1660(+4)+1660(+4)+1038(+2)=operand11+op1 |
| **`0x55`** | 2 | **8**（6-byte under-consume、18 sample） | `0x800EDC50` | inline(+1)+1660(+4)+1620(+2)=operand7+op1、fetch は内部 beq より前=固定長 |

candidate（execution-delta のみ、**EXE audit 前 = 断定しない**）: `0x2B / 0x52 / 0x7C / 0x38 / 0x72 / 0x26`。

**★12 件目（可変長）: `0x1A` の text は operand（worker2 が authority 確定、boss1 が byte 裏取り）★**:
実機は `0x1A` を **1 命令（text 込み、可変長）で fetch**（例 entry1 `@0x00aa` = `1a00` + SJIS 24byte + `0d` = 30byte、次 fetch `0xc8`）。
C# は `Len[0x1A]=2` ⇒ 続く SJIS を独立 text run、`0x0D`/pad を独立 opcode として実行 = **実機が fetch しない PC を fetch**。
⇒ **clean diff FAIL 469 中 293 本がこの 1 件で説明できる = PASS を上げる最大の単一要因**。G1 に含める。

---

## 5. merge gate = 「通った」ではなく「基準を変更した」（PRESIDENT 裁定）

`c6fec7f` は `0x4F` と `0x6E` を変更:
- **`0x4F=6` = 実行確認済**（sweep で 12 回 dispatch）✅
- **`0x6E=8` = 実行未確認**。1278 section / 7685 event で **fetch=0 = reachable path に site 無し**。

**PRESIDENT が gate 基準を変更した（そう明言する。「gate が通った」とは言わない）**:
> reachable opcode = 実行検証必須 / **unreachable opcode = EXE 直読 + 不活性実証 + 「実行未検証」mark で merge 可**。
> 理由（PRESIDENT 判断）: **`0x6E` は原理的に実行検証できない。満たせない条件で永久に止めるのは規律でなく麻痺**。

**★正当化の訂正（`docs/RE_c6fec7f_justification_correction_2026-07-12.md`、history 書換えず追加）★**:
- 元の正当化「8 件すべて `0x4F`/`0x6E` 出現、25/25 位置で旧 length が **operand を opcode として実行**」は **部分的に偽**。
- 8 GREEN喪失 のうち **3 件（64/71/108）は `0x4F` を含まず `0x6E` のみに依存**。`0x6E` は実機で実行ゼロ。
- ⇒ この 3 件の desync は **runtime 実行でなく C# の静的寄り decode** だった。「operand を opcode として実行」は **false**。
- **fix が誤りなのではない。fix の【正当化】が誤りだった**（この区別を崩さない）。正当化を「静的 scan 由来」→「実行確認(`0x4F`)+ EXE 直読(`0x6E`、実行不可能ゆえ未検証 mark)」に置換。
- 限界: boss1 の walk は naive linear（text run 非対応）ゆえ `0x6E` サイト自体 phantom の可能性。**確実なのは「実機で `0x6E` 実行ゼロ」だけ**。
- **「`0x6E` は globally dead」とは言わない。「1278 section・序盤 flag では未到達」が正確**。

merge: **local main のみ / push 禁止**。merge 後 **main sha = `03f9dcd`**（`--no-ff`、message に gate 基準変更を明記）。main の Len[] 機械検証: `0x4F=6 / 0x6E=8 / 0x4D=4 / 0x6C=8` = 全て正。working tree clean。

---

## 6. 今日の最大の設計成果 = guardrail を「運用規律」から「コード強制」へ

**偽 GREEN の衣装が 1 session で 6 着生えた。「気をつける」では 6 回とも防げなかった。**

| # | 衣装 | 見た次元 | 落とした次元 |
|---|---|---|---|
| 1 | prefix 判定 = 緑 | text 先頭一致 | 実行順・分岐・到達性 |
| 2 | known-gap tag → PASS | diff の理由 | 「得た正しさの情報 = ゼロ」 |
| 3 | 閾値ヒューリスティック → 赤 | step 数 | 何が起きたか |
| 4 | 「整列so無害」 | PC 整列 | **命令の副作用（SET_FLAG/SET_VAR 落ち）** |
| 5 | 打ち切り authority の prefix 比較 | 捕れた範囲の一致 | 打ち切り以降 |
| 6 | 次元の有無を推論 | read event の存在 | **「write 0 件」=「無い」か「未計装」か** |

**効いたのは構造だけ**:
- override run が marker を吐き、tool が **PASS を機械的に禁止**
- **dims.txt 宣言外の次元 / complete.txt 外の entry は既定で BLOCKED**（人が緑にしたくても構造上できない）
- = [[feedback_control_toggle_must_be_wired]] の裏返し = **「緑に倒せない配線」**

---

## 7. meta 教訓（PRESIDENT 直命で handoff の中核）

1. **射影を見て本体を語るな**。「無害/一致/緑」を言うときは **何の次元で見たか** を明記。次元を落とした主張は落とした次元では無保証。
2. **少数サンプルからの一般化をするな**（[[feedback_small_sample_generalization]]）。母集団を数え、かつ次元を数える。boss1 は 2 件から「影響狭い」、PRESIDENT は 225 だが壊れた Len で 120/9/96 — どちらも実測で覆った。
3. **循環は初期状態から侵入する**（[[feedback_identity_is_not_evidence]]）。savestate 戦略はこれの正しい解（本物のゲームが state を作る）。
4. **N 回外した方法を自動化して網羅するのは改善ではない、誤りの母数が増えるだけ**。自動化前に「なぜ間違えたか」に答えろ。静的解析は「値の算出」でなく「候補生成」に降格。
5. **言葉が仮定を密輸する**。「false-red」は「shipping は正しい」を密輸していた（shipping にバグ確定済ゆえ根拠なし）。
6. **データが無いことと差が無いことは見分けがつかない**（[[feedback_state_which_dimension.md]]）。未計装の次元は常に空 vs 空で一致する。**沈黙は合格ではない**。
7. **結論 = 個人の注意力ではなく構造の問題**。今日 **boss1・PRESIDENT・worker 全員が同じ穴を踏んだ**（PRESIDENT は規範を破って誤った具体例を memory に恒久記録し、後で撤回）。**「知っている ≠ 守れる」。process（第三者査読 / 全数測定 / authority 待ち / コード強制 gate）だけが効く**。

---

## 8. commit 一覧（全 local / push ゼロ）

| branch | sha | 内容 |
|---|---|---|
| `trackF1C/duckstation-golden` | `0ca2a1e` | 225 sweep 成果物（trace / complete.txt / handler_lengths / dims.txt） |
| （duckstation-src） | `5ee5a86` | hook 実装 |
| `trackF1B/event-oracle` | `8fbf2aa` 他 | 2 次元 diff / dims 宣言 / 構造 guardrail / codex 修正 |
| `trackF1A/mips-exe-reference` | `e0747f9` | 設計 doc + stub 台帳（**TrackA 中止、実装ゼロ**） |
| main（local、push なし） | **`03f9dcd`** | `c6fec7f` を `--no-ff` merge（`b77f854`、gate 基準変更を message 明記）+ 訂正 doc（`085fdc5`）+ G1-G7 登録 + oracle doc 未merge 注記。origin より 31 ahead（**全 local・push ゼロ**） |

**push は 1 件もしていない。**

---

## 9. 未検証項目（honest list、埋めていない）

- **clean diff = 135/469（PC 列のみ）**。残り 334 FAIL のうち 293 は `0x1A` 可変長で説明 ⇒ G1 fix 後に再測が必要
- **256 opcode 中 190 は length 未検証**（実行到達サイト無し / 未到達）
- candidate length バグ 6 件（EXE audit 前）
- `0x6E` が **globally** 未到達か（序盤 flag のみ確認、後半 flag 未検証）
- **入力表面の全 load 測定 = 未実施の hard gate**（決定性テスト PASS はこれとは別物）
- var_w / flag_r / text / term / warp 次元 = 実機 trace 未計装 = BLOCKED
- MAPHEAD 281 section stall の原因
- savestate は序盤 flag ゆえ **「実プレイでの挙動」は主張不可**（identity のみ保証）

---

## 10. follow-up（次 session の spec 起草へ）

| 優先 | 項目 | 備考 |
|---|---|---|
| **最優先** | 新 length バグ `0x75`(4→12) / `0x55`(2→8) fix | 実行確認 + EXE 直読済 |
| 高 | **BodyStart(+4) 修正** | 225 entry 全て先頭命令 skip / 9 件 state 書き込み落ち。cutscene 再検証込み |
| 高 | **progression 接続: flag `0x4C`**（entry189 SET_FLAG 未実行）の consumer 走査 | north star=「ゲームが進む」の直接候補。**推論、実測要** |
| 中 | candidate length 6 件の EXE audit + 実行確定 | |
| 中 | 全 load 測定（入力表面）| hard gate |
| 中 | MAPHEAD 281 section stall 調査 / 後半 flag で `0x6E` 再探索 | |

**BodyStart 修正 / length fix / progression 接続 は全て cutscene 経路に触る ⇒ user 実視覚を伴う別 dispatch。**
