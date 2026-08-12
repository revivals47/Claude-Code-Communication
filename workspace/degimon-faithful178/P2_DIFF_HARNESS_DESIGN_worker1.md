# P2_DIFF_HARNESS_DESIGN — ★① の 器(原盤 trace 対 remake trace)の 設計★ ★v2★(worker1 / 2026-08-12)

★v3 の 差分★: ★`pc` 変換式の ★判定を 確定★★ + ★『データが 在る』と『主張に 使える』の 分離★ + ★塞げない ものの 明示★
★v2 の 差分★: ★worker2 §(a) の 制約 3 件を 吸収★ + ★CLI 契約を 追加(実装者 = worker2)★ + ★時間箱の 定義を 変更★

★対象★: 打ち切り条件 ★①『★説明不能な★ 状態遷移差 0』★
★本 doc は ★設計のみ★★。★実装は 書きません★ / ★私は 共有 repo を 触りません(収載は boss1)★

★引いた 版(★その場で 実測★)★:
```
★P2_FIELD_TO_OPCODE.md   = sha ★85c1c6447218a749★ / ★144 行★★
★vmtrace.py(worker2)      = sha ★cfb8ee97a788d1f4★ / ★194 行★★
★W3StateTrace.cs(worker3) = ★p2w3/unity/Assets/Scripts/Debug/W3StateTrace.cs★(★sha 未取得 = 私は 実行版を 持たない★)
```

---

## (a) ★★共通 schema — ★何を どの 粒度で 突合するか★★★

### a-1 ★両側の 出力(★直読★)★

★原盤側(vmtrace `FIELDS` + block)★:
`stop`(4) / `pending`(1) / `pc`(4) / `base`(4) / `entry`(2) / `fb_entry`(2) / `depth`(2) / `bank_ptr`(4)
/ `pad_held`(4) / `pad_b`(4) / `pad_edge`(4) / `FLAG`(100 byte) / `VAR`(256 byte) / `STACK` / `WIN`

★remake 側(`W3StateTrace.cs` L94-131 逐語)★:
`f`(frameCount) / `t`(realtime) / `pc` / ★`base` = ★常に 0★★ / `entry`(`CurrentScenario`) / ★`sec`(★比較対象外★と 明記)★
/ `stop` / ★`pending` = ★0/1 のみ・値比較 不可★★ / `depth` / ★`stack` = ★null(深さのみ)★★
/ ★`pad_held` / `pad_edge` = ★null(未実装)★★ / `flags` / `flags_hi` / `vars`

### a-2 ★★★突合する field = ★6 本★★★★

| field | 粒度 | ★変換★ | 根拠 |
|---|---|---|---|
| ★`pc`★ | frame | ★★原盤 `pc − base` = remake `pc`★★ | ★原盤 = 絶対 address / remake = ★body 内 offset★★。★`base` は 原盤側で 取れている★ |
| `entry` | frame | ★そのまま★ | 両側とも entry id |
| `stop` | frame | ★そのまま★ | 両側 |
| `depth` | frame | ★そのまま★ | 両側 |
| `flags` | frame | ★★原盤 100 byte(= id 0-799)のみ★★ | remake `flags_hi` は ★原盤に 対応が 無い★ |
| `vars` | frame | ★★原盤 256 byte / remake `vars`★★ | 両側 |

★★∴ `pc` の 変換が ★本器の 中核★★★: ★これを しないと ★全 frame が 差に なります★★
 ⇒ ★★∴ ★変換式は ★address 枠★ で 書く: ★`remake_pc == 原盤_pc − 原盤_base`(★両方とも byte 単位の offset★)★★

### a-3 ★★★★突合から ★外す★ field = ★8 本(★全数 開示★)★★★★

| field | ★外す 理由★ | 枠 |
|---|---|---|
| ★`base`★ | ★remake は ★常に 0★(W3StateTrace L98 に 明記)★ | address |
| ★`sec`★ | ★remake 側が ★『比較対象外』と 自ら 明記★(L100)★ / ★原盤に 対応 field が 無い★ | address |
| ★`pending`(値)★ | ★remake は ★0/1 のみ★(L102)★ ⇒ ★★値比較 不可 ⇒ ★0 / 非0 だけ 突合★★ | ★control-flow★ |
| ★`stack`(record)★ | ★remake は ★null★(L104)★ ⇒ ★深さのみ★ ⇒ ★★tag 絞り(§261)は ★使えません★★★ | containment |
| ★`pad_held` / `pad_edge` / `pad_b`★ | ★remake ★null(未実装)★★ ⇒ ★★入力を 再現できない★★ | address |
| ★`fb_entry`(`0x8013E136`)★ | ★remake 側に 出力なし★ | address |
| ★`bank_ptr`★ | ★remake は ★pointer を 持たない アーキ★★ | address |
| ★`WIN_*`★ | ★remake 側に 対応 state なし★ + ★worker2 訂正 1: ★slot0-3 のみ★★ | containment |
| ★`flags_hi`★ | ★remake のみ(bool[4096] の 上位)★ / ★原盤 flag 配列は ★100 byte = id 0-799★★ | address |

★★∴ ★この 線引き 自体の 検証★★★(★[[proxyで切って基準を検証しない]])★:
- ★★外した 8 本の うち ★4 本は remake 側の 未実装★★(`stack` record / `pad_*` / `pending` 値 / `flags_hi` の 逆)
  ⇒ ★★∴ ★★『外した』のでは なく ★『まだ 突合できない』★★★ ⇒ ★★(d) の 依頼で ★戻せます★★
- ★2 本は ★アーキが 違う★(`base` / `bank_ptr`)⇒ ★★恒久的に 外す★★
- ★2 本は ★片側にしか 存在しない★(`sec` / `fb_entry` / `WIN_*`)⇒ ★依頼で 戻せる ものと そうで ない ものが 混在★

---

## (b) ★★『説明できる 差』の 定義 — ★帰属の 3 分類★★★

★差が 出た frame の field を ★次の 順で★ 帰属させる★。★どれにも 帰属できない ものだけが ★①の 分子★★

### b-1 ★分類 1: ★未実装 subsystem 依存★★
★手順★: ★差 field → ★`P2_FIELD_TO_OPCODE.md`(sha `85c1c6447218a749`)★ で ★容疑 opcode 集合★ を 引く
 → ★backlog 33 種(★実装可 0 / semantics 未揃い 5 / 保留 11 / 判らない 17★)の どの欄か★
⇒ ★★該当すれば ★説明できる★★★

★★∴ 帰属表が そのまま 効くかの 自己確認★★:
```
★帰属表 13 行 の うち ★突合する 6 field に 対応するのは★:
  ★`pc` ✓ / `entry` ✓ / `stop` ✓ / `depth` ✓ / `FLAG_*` ✓ / `VAR_*` ✓★ = ★★6 行 とも 在る★★
★使えない 行★: ★`base`(外す)/ `fb_entry`(外す)/ `pending`(値 比較 不可 ⇒ ★0/非0 のみ★)/ `bank_ptr`(外す)
             / `STACK_BASE`(★remake null ⇒ ★§261 の tag 絞りは 使えない★★)/ `pad_*`(外す)/ `WIN_*`(外す)★
```
⇒ ★★★∴ ★帰属表は ★6 / 13 行が 生きます★★★★
⇒ ★★∴ ★★§261 で 出した ★`depth` の tag 絞り★ は ★remake が record を 出すまで 使えません★★★ = ★★(d) の 依頼 1★★

### b-2 ★分類 2: ★入力差★★
★`pad_*` が ★remake 未実装★★ ⇒ ★★入力列を 揃えられない★★
⇒ ★★∴ ★入力に 依存する field(★`flags` / `vars` / `pc`★)の 差は ★『入力差の 可能性』で 説明できる★★
⇒ ★★∴ ★★但し ★『説明できる』であって『説明した』では ありません★★★
 ⇒ ★★∴ ★★∴ ★★入力差を ★除外できる 唯一の 方法 = remake が pad を 出す★★★ = ★★(d) の 依頼 2★★

### b-3 ★分類 3: ★時間箱★★
★原盤 = ★1 kHz sample★ / remake = ★frame ごと★★ ⇒ ★★同一 frame に 揃える 必要★★
★★規則★★: ★★『★±1 frame 以内で 一致する 差★ は ★時間箱★ に 帰属』★★
⇒ ★★∴ ★2 frame 以上 ずれた ものだけが ★分子の 候補★★
★★∴ 自由 parameter の 申告★★: ★★『±1 frame』は ★私が 選んだ 値★★★ ⇒ ★★∴ ★±0 / ±2 でも 数えて 3 通り 出す★★

### b-4 ★★∴ ①の 分子 = ★上 3 分類の どれにも 帰属できない 差★★★

---

## (c) ★★欠測の 数え方 — ★『一致』と『撮れていない』を 分ける★★★

### c-1 ★★各 field × 各 frame を ★3 値★ で 記録★★
```
★`match`  ★ = 両側 在り かつ 一致
★`differ` ★ = 両側 在り かつ 不一致
★★`missing`★★ = ★★片側 null / sample 欠落 / 変換不能★★
```
★★∴ ★`missing` は ★分子にも 分母にも 入れない★★★ ⇒ ★★別欄で 数える★★

### c-2 ★★footer(★必須★)★★
```
★[HARNESS] 突合 frame = N / 欠測 frame = M / 対象 field = 6
★[HARNESS] field 別: pc(match/differ/missing) entry(...) stop(...) depth(...) flags(...) vars(...)
★[HARNESS] ★外した field 8 本と 理由★(= (a)-3 の 表を そのまま)
★[HARNESS] ★変換式: remake_pc == 原盤_pc − 原盤_base★
★[HARNESS] ★時間箱 = ±0 / ±1 / ±2 の 3 通り★
```
⇒ ★★∴ ★footer が 無い run は ★『撮れていない』★ として 扱う★★(worker2 §16 と 同趣旨)

### c-3 ★★★閾値つき指標は ★使いません★★★★
★★理由★★: ★① は ★『差 0』★ が 条件 ⇒ ★★閾値が 要りません★★
⇒ ★★∴ ★★『一致率 N%』は ★出しません★★★ — ★★出すと ★1 frame の 増減で 反転する 分解能★ の 議論に なります★★
 ⇒ ★★∴ ★= PRESIDENT #105 の 規範(★1 単位で 反転するか を 撮る前に 書く★)を ★閾値を 置かない ことで 満たす★★
★★∴ 出すのは ★差分 frame の ★絶対数★★★: ★★`differ` が 0 か 非0 か★★

---

## (d) ★★他者への 依頼事項(★boss1 経由。私は 直接 発注しません★)★★

### ★worker3(remake 側)★
1. ★★`stack` の record を 出す★★(★現状 `null`)⇒ ★`ReturnRecord.Kind` を ★tag 相当★ として 出力★
   ⇒ ★★∴ ★★§261 の ★`depth` の tag 絞り★ が 使えるように なります★★(★1 = 0x13/0x14 / 3 = 0xFB / 4 = 0x4B 系★)
2. ★★`pad_held` / `pad_edge` を 出す★★(★現状 `null`)⇒ ★★分類 2(入力差)を ★除外できる★★★
3. ★★`pending` を ★値★ で 出す★★(★現状 0/1)⇒ ★`GameState.RawE150` を 既に 持っています(§256)★
4. ★★`map`(`CurrentMapIndex`)を 出す★★(§226 で 新設済)⇒ ★★原盤 `0x8013E166` と 突合できる★★
5. ★`W3StateTrace.cs` の ★sha を 添えて★ ください★(★私は 実行版を 持ちません★)

### ★worker2(原盤側)★
1. ★★`FIELDS` に ★`0x8013E166`(map index)★ を 追加★★(★read 範囲内・追加コスト ゼロ / §262)
   ⇒ ★★∴ ★worker3 の 依頼 4 と ★対で 成立します★★(★片方だけでは 突合できません★)
2. ★`0x8013E164`(`0x67` frame 待ち counter)/ `0x8013E151`(`0x4B` marker)★ = ★★依頼 1 の 後で 可★★
   ⇒ ★★∴ ★remake 側に 対応が 無い ⇒ ★今 足しても 突合対象に ならない★★
3. ★★frame 同期の 方法を 決める★★: ★1 kHz sample を ★どの 規則で frame に 畳むか★★
   ⇒ ★★∴ ★`compare_runs.py` の `--fold-events` は ★『常用しない』と 明記済★★ ⇒ ★★別規則が 要ります★★

### ★両者★
- ★★同一 run の ★開始点を 揃える 規約★★★(★原盤 = DuckStation 起動後 N 秒 / remake = frame 0 …)
  ⇒ ★★∴ ★★これが 無いと ★時間箱 ±1 frame が 意味を 持ちません★★★

---

## ★事前登録(★本設計 doc 自体★)★

★★『撮る前から 倒れないか』だけ 確かめる★★(★『通るか』は 見ない★):
- ★★倒れる条件 1★★: ★突合する 6 field の うち ★片側が 出していない もの が 在る★ ⇒ ★★設計が 成立しない★★
  ⇒ ★★∴ ★(a)-1 で ★両側の 出力を 直読して 確認済★★ ⇒ ★★6 本とも 両側に 在ります★★
- ★★倒れる条件 2★★: ★`pc` の 変換式が ★成り立たない★★(★remake `pc` が body 内 offset で ない★)
  ⇒ ★★∴ ★★これは ★未検証★★★ — ★★W3StateTrace の `pc` の 定義を 読んでいません★★ ⇒ ★★(d) worker3 依頼 5 で 確認★★
- ★★倒れる条件 3★★: ★★`missing` が 大半を 占める★★ ⇒ ★★『突合した』と 言えない★★
  ⇒ ★★∴ ★footer の `missing` 欄で ★撮る前から 判ります★★

★★∴ 終了文言(★先に★)★★:
- ★`differ` が 0 だった 場合 = ★『★突合した 6 field / 対象 frame N で 差 0★』★ ⇒ ★★『① 達成』とは 書きません★★
  (★外した 8 本 / `missing` / 時間箱 ±1 の 自由度が 残る★)
- ★突合が 走らなかった 場合 = ★『測れなかった』★ ⇒ ★★『差 0』とは 書きません★★

---
---

# ★★★v2 追補 — worker2 §(a) の 制約 3 件 + CLI 契約★★★

## (i) ★★★原盤側に event trace は 無い(state 標本のみ)★★★ ⇒ ★時間箱の 定義を 変える★

★worker2 §(a)(i) 逐語★:『★突合は ★remake を 原盤の 標本粒度に 間引く★ 方向でしか 成立しない(★逆は 不可能★)★』

### v2-i-1 ★★v1 の 誤り(★自己訂正★)★★
★v1 §(b)-3 で 私は『★時間箱 = ±1 frame★』と 書きました★
⇒ ★★∴ ★これは ★両側が frame 粒度である★ ことを ★暗黙に 仮定★ していました★★
⇒ ★★∴ ★原盤は ★1 kHz sample かつ ★変化行のみ記録★★ ⇒ ★★『frame』という 単位が 原盤側に ありません★★
⇒ ★★★∴ ★『±1 frame』は ★定義不能★★★★ ⇒ ★★撤回します★★

### v2-i-2 ★★★新定義 = ★原盤の 標本時刻を 基準に する★★★★
```
★間引き 規則(★zero-order hold★)★:
  ★原盤の 各 標本時刻 `t_i` に 対し、★remake 側は 『★t_i 以下で 最大の t' を 持つ 行★』を 採る★
  ⇒ ★★理由 = 原盤は ★変化行のみ 記録★ ⇒ ★変化していない 間は ★前の 値が 続く★★★
  ⇒ ★★∴ remake も 同じ 読み方に 揃える(= ★直近の 行を 保持★)★★
★時間箱★: ★★`--window-ms N`(既定 ★0★)★★
  ⇒ ★`N = 0` = ★zero-order hold のみ(補正なし)★★
  ⇒ ★`N > 0` = ★`t_i ± N ms` の 範囲に ★一致する 行が 在れば match★ と する 緩和★
  ⇒ ★★∴ ★自由 parameter ⇒ ★`0 / 8 / 16 ms` の 3 通りを 必ず 出す★★★(★16 ms ≒ 1 frame @60fps★)
```
⇒ ★★∴ ★★『±1 frame』を ★`±16 ms`★ に 読み替え、★frame という 語を 使いません★★★

## (ii) ★★変化検出 key の 外で 動く ⇒ ★行が 出ない★★★ = ★missing の 出所 3 種★

★worker2 §(a)(ii) 逐語★:『★変化検出 key に ★`fb_entry` / `bank_ptr` / `pad_b` / stack 中身★ が 無い★
 ⇒ ★`stop==1`(pc 不動)区間で これらだけ 動くと ★行が 出ない★』

### v2-ii-1 ★★`missing` の 出所を ★3 種に 分ける★★★(v1 は 1 種で まとめていた)
```
★`missing_null`★  = ★片側が null★(remake の `stack` / `pad_*` 等)
★`missing_gap`★   = ★標本が 落ちた★(ptrace 失敗 / 欠測)
★★`missing_key`★★ = ★★変化検出 key の 外で 動いた ⇒ ★行 自体が 出ていない★★★
```
⇒ ★★∴ ★`missing_key` は ★原盤側の 器の 性質★★ ⇒ ★★突合器では 検出できません★★
⇒ ★★∴ ★★∴ ★★footer に ★『★`missing_key` は 数えられない★』★ と ★明記する★★★
 ⇒ ★★∴ ★= ★[[打ち切られたlistの不在は否定でない]]★★:『★行が 無い』は『変化が 無い』では ありません★

### v2-ii-2 ★★∴ 判定への 影響★★
★`stop == 1` かつ `pc` 不動の 区間★ は ★★『一致』と 断定しては いけません★★
⇒ ★★∴ ★footer で ★その 区間の 長さを 別掲★★(★= 『この 区間は 見えていない』★)

## (iii) ★★`flags` / `vars` は ★`bank_ptr == 0x80163784` の 時のみ 有効★★★

★worker2 §(a)(iii) 逐語★:『★989 観測すべてで 成立、★但し 恒真では ない★』
```
★adapter 規則★: ★★毎行 `bank_ptr` を 見る★★
  ★`bank_ptr == 0x80163784`★ ⇒ `flags` / `vars` を ★有効★
  ★それ以外★               ⇒ ★★`flags` / `vars` を `null` に する(= `missing_null`)★★
```
⇒ ★★∴ ★v1 §(a)-2 の 突合 6 field の うち ★`flags` / `vars` は ★条件付き★★★
⇒ ★★∴ ★★∴ ★★footer に ★`bank_ptr` が 外れた 行数★ を 出す★★★(★= 有効母数の 開示★)
★★∴ 註記★★: ★`bank_ptr` は ★remake 側に 存在しません(アーキが 違う)★★
 ⇒ ★★∴ ★gate は ★原盤側の 行に のみ 掛かります★★

---

# ★★★CLI 契約(★実装者 = worker2★。★私は 実装しません★)★★★

## c-1 ★1 command の 呼び出し形★
```
★diff_harness.py <原盤_trace.jsonl> <remake_state.jsonl> [--out report.json] [--window-ms 0|8|16] [--selftest]★
```
- ★入力 2 本は ★位置引数★(★順序 = 原盤、remake★)
- ★`--out` 省略時は ★stdout に footer のみ★★
- ★`--window-ms` は ★3 値を それぞれ 走らせる★ のが 既定運用★(★1 回の 呼び出しでは 1 値★)
- ★`--selftest` は ★入力 2 本を 取らない★★

## c-2 ★★終了 code(★3 状態を 区別★)★★
```
★0★ = ★`differ` が ★0★(★但し ★『① 達成』では ない★ — 終了文言 参照)
★1★ = ★`differ` が ★非0★
★★2★★ = ★★判定不能★★ = ★footer が 出せない★ / ★`missing` が ★対象行の 50% 超★★ / ★入力が 読めない★
```
⇒ ★★∴ ★★`0` と `2` を ★同じ 成功として 扱わない★★★(★= worker2 §16 の footer 要件★)
★★∴ 閾値の 申告★★: ★★`50%` は ★私が 選んだ 値★★★ ⇒ ★★∴ ★★1 行の 増減で 反転するか★★:
 ⇒ ★★対象行が 100 行なら ★1 行で 反転します★★ ⇒ ★★∴ ★footer に ★`missing` の 実数と 対象行数を 併記★★★
 ⇒ ★★∴ ★★∴ ★『50% 超』は ★code の 判定にのみ 使い、★報告には 実数を 使う★★★

## c-3 ★★self-test の 同梱要件(★器 自身が 壊れていない ことを 器が 示す★)★★
```
★`--selftest` は ★合成 2 本★ を 内部生成し、★次の 4 件を すべて 通す★:
 ★① 完全一致の 対 ⇒ `differ` = 0 / `missing` = 0 / code 0★
 ★② 1 field だけ 1 行 違う 対 ⇒ `differ` = 1 / ★その field 名が footer に 出る★ / code 1★
 ★③ 片側 null を 含む 対 ⇒ ★`missing_null` に 計上され `differ` に 入らない★★
 ★④ footer を 欠いた 入力 ⇒ ★code 2★
★★∴ ★`--selftest` が 落ちたら ★本走行を 拒否する★★★(★= 器の 事前検定★)
```

## c-4 ★★『間引き』の 規則(★実装者が 迷わない 粒度★)★★
```
★入力★: 原盤 = ★時刻昇順の 標本列(変化行のみ)★ / remake = ★時刻昇順の 行列★
★手順★:
 ★1★ remake 側を ★時刻で index 化★(`t` は `realtimeSinceStartup − t0`、★秒・F4★)
 ★2★ 原盤の 各 標本 `t_i` に 対し ★`bisect_right(remake_t, t_i) − 1`★ で ★直前行★ を 採る
 ★3★ ★index が `-1`(= remake 側に まだ 行が 無い)★ ⇒ ★★`missing_gap`★★
 ★4★ ★`--window-ms N > 0`★ の とき ★`t_i − N/1000 ≤ t' ≤ t_i + N/1000`★ の 範囲で
     ★★『一致する 行が 1 本でも 在れば match』★★ と する(★= 緩和。★differ を 減らす 方向★)
 ★5★ ★開始点の 揃え★ = ★両側の ★最初の 行の 時刻を 0 に 平行移動★★
     ⇒ ★★∴ ★これは ★仮の 規約★★(★依頼『両者 1: 開始点の 規約』が 決まるまで★)
★★∴ 逆方向(remake を 基準に 原盤を 間引く)は ★禁止★★★(★worker2 §(a)(i): ★逆は 不可能★★)
```

---

# ★★v2 の 事前登録(★追加分★)★★

- ★★倒れる条件 4★★: ★`bank_ptr != 0x80163784` の 行が ★大半★ ⇒ ★★`flags` / `vars` が 突合できない★★
  ⇒ ★★∴ ★worker2 の 989 観測では ★すべて 成立★★ ⇒ ★★撮る前から 倒れる 見込みは 低い★★
- ★★倒れる条件 5★★: ★`missing_key`(変化検出 key の 外)が ★実は 大量★ ⇒ ★★突合の 意味が 薄い★★
  ⇒ ★★∴ ★★これは ★器では 検出できません★★★ ⇒ ★★∴ ★『撮る前から 倒れないか』を ★確かめられない 唯一の 条件★★
  ⇒ ★★∴ ★★∴ ★doc に ★『検定できない 条件が 1 本 在る』★ と 明記する★★★

★★∴ 終了文言(★v2 で 追加★)★★:
- ★`differ` 0 の とき = ★『★突合した field / 有効行 N で 差 0。★`missing_key` は 数えられていない★★』
- ★`--selftest` が 落ちた とき = ★『★器が 壊れている ⇒ 本走行の 結果は 採らない★』★

---
---

# ★★★v3 追補★★★

## v3-1 ★★★`pc` 変換式 = ★確定★(倒れる条件 2 を 閉じる)★★★

★★`remake_pc == 原盤_pc − 原盤_base`★★ ⇒ ★★原点は 同一 = `entry.Raw` 先頭★★
★根拠★:
- ★原盤: EXE `0x800F0A4C` が ★`s0 = base + 2`★ で section 表を 読み ★`return base + (u16)[s0+2]`★
- ★DG.SCN: `raw[0..1]=word0` / `raw[2..3]`=最初の section の key / `raw[4..5]`=その offset ⇒ ★表は raw offset 2 から★
- ★remake: `_body = entry.Raw` / `_pc` は ★raw の index★(worker3 実測)

### v3-1-a ★★但し ★開始値が 4 byte ずれる 経路が 在ります★★★
★原盤 linear 開始 = `word0`(★VM_SPEC §3.1 = 母数 225 / 一致 225★)/ remake 既定 `BodyStart = 4 + word0`★
⇒ ★★∴ ★★`Begin` 単独起動の 経路でのみ 4 byte ずれる★★★
⇒ ★★∴ ★`PlaySection` 経由は ★`_pc = off` で 上書き★ ⇒ ★★ずれません★★(worker3 実測)

### v3-1-b ★★器の 運用(★暫定★)★★
★★突合 run は ★`DEGIMON_FAITHFUL_BODYSTART=1`★ で remake を 走らせる★★
★★∴ 但し これは ★consumer 側で 逃がす 形★ です★★(boss1 #167 ②)
 ⇒ ★★∴ ★★抜本解決 = ★既定を `word0` に する★★★(★2026-07-25 `bd82f38` で ★非忠実と 判定済★ / ★残るのは user 実視覚 verify★)
 ⇒ ★★∴ ★★env で 消した 差は ★説明した ことに なりません★★★ ⇒ ★★①の 分子から 除外しては いけません★★

### v3-1-c ★★`Begin` 単独経路の 到達性(★母数つき★)★★
★production 7 本★: ★#1 `AutoStart`=false(既定)/ #2 `ScenarioProgression:41`(`section<0`)/ #3 `ScenarioVM:198`(`sec<0`)
 / ★#4 `FieldState:422`★ / #5 env `DEGIMON_INTRO_ENTRY` / #6 `gs==null` / #7 `PlayEntry`(★caller 0 = dead★)★

★★【★v3-2 訂正★】★#4 を『env-gate なし』と 書いたのは ★誤り★★★ ⇒ ★★§v3-7 が 正★★
 ⇒ ★★∴ ★真の gate = `FieldState.cs:194 if (_scriptWarp)` = ★env `DEGIMON_SCRIPTWARP` == "1" かつ AutoBoot★★★
 ⇒ ★★∴ ★私も worker3 も ★method 本体だけ 読み caller を 読まなかった★★★
★★∴ 但し書き(★boss1 #169 ② の 要求★)★★:
 ★★『#2 / #3 の 呼び元が すべて `section >= 0`』は ★証明では ありません★★★
  ⇒ ★★∴ ★『★私が 追った 呼び元の 範囲では 見つからない★』まで★★
 ★★∴ ★#4 の 到達 = worker3 実測 ★9 本(run 7 + live 2)で 0 件★★★
 ⇒ ★★【★v3-2 訂正★】★この 0 を『不到達』の 根拠に 使っては いけません★★★ = ★★env を 立てていない ことの 帰結★★(§v3-7)

## v3-2 ★★★『データが 在る』と『主張に 使える』を ★分ける★★★★

★出所 = PRESIDENT #109 (c) / boss1 #168 ⑤★
```
★データが 在る★   = ★6 field は ★撮れた 4 本 全 689 行★ に 在る★
★★主張に 使える★★ = ★★footer が 無い runA / runB は ★一致主張に 使えない★★★
⇒ ★★∴ ★★分母は ★run1 / run4 の 2 本★★★
```
★★∴ 器の 要求★★:
- ★★footer の 有無を ★入力ごとに 判定★ し、★無い 入力は ★『データ欄』にのみ 計上★★★
- ★★『一致』『差 0』の 主張には ★footer 在りの 入力だけ★ を 使う★★
- ★★footer に ★両方の 数★ を 出す★★: ★『データ行 = N / ★主張に 使える 行 = M★』★
⇒ ★★∴ ★★`M < N` の とき ★M を 分母に する★★★(★N を 使うと ★水増し★★)

## v3-3 ★★★『現れない』は 禁止 — ★母数を 必ず★★★★(PRESIDENT #110 (b))

★本器の 出力で ★禁止する 書き方★★:
```
★禁止★: 『差は 現れない』『4 byte ずれは 出ない』
★★必須★★: 『★この N 行 / この M run では 現れなかった★』
```
★★∴ 適用例(★本 doc 自身★)★★:
- ★『4 byte ずれは ★worker3 の run 7 本 + live 2 本では 現れなかった★』★(★worker3 実測、母数 = 9★)
- ★『`#2` / `#3` は ★私が 追った 呼び元の 範囲では 到達しない★』★(★母数 = grep 全数 = 3 呼び元★)

## v3-4 ★★★機構で 塞げない ものは ★塞げないと 書く★★★★(PRESIDENT #110 (c))

| 項目 | ★塞げるか★ | ★塞げないなら 誰が いつ 何を するか★ |
|---|---|---|
| ★`missing_key`(変化検出 key の 外)★ | ★★塞げない★★ | ★★worker2 が 原盤側の key を 増やすまで 不可★★。★器は ★『数えられない』と footer に 出す★★ |
| ★入力差(`pad_*`)★ | ★塞げない(現状)★ | ★worker3 が `pad_held`/`pad_edge` を 出すまで★(依頼 w3-2) |
| ★4 byte ずれ★ | ★★env で 回避可・機構では 未解決★★ | ★★PRESIDENT 承認 + user 実視覚 verify の 後に 既定変更★★ |
| ★`bank_ptr` gate★ | ★塞げる(adapter で 毎行 gate)★ | — |
| ★開始点の 揃え★ | ★塞げない(規約 未定)★ | ★boss1 発注済『両者 1』の 回答待ち★ |

## v3-5 ★★私の 計器の 但し書き(★他者が 引く 前に★)★★

- ★★`t4_opcode_len.BANDS` は ★3 本しか 無く stale★★★ ⇒ ★★引かないでください★★(★私は 自前定義で 回避済★)
- ★★`ImplementedOps` は ★`0x10` を 欠く★★★(★2026-08-12 時点。★実体 33 種 / 宣言 32 種★)
  ⇒ ★★∴ ★『★被害が 出なかった★』と『★安全だった★』は ★別★★★:
   ★被害ゼロ = `IsKnown` の 呼び出しが ★0 件★ だった から★ / ★安全では ない = ★呼べば 誤値★★
- ★私の 抽出器は ★`const byte` の 改行継続を 拾えず 3 件 落としていました★★(★修理済。§v3-6★)

## v3-6 ★★抽出器の 修理と ★worker3 との 一致★★★

```
★修理前★: case ★25★ + JumpOps 5 = ★30 種★   ⇒ ★worker3 の 33 と ★3 の 差★★
★★修理後★★: case ★28★ + JumpOps 5 = ★★33 種★★ ⇒ ★★worker3 と ★一致★★★
★原因★: ★`const byte A = 0x.., B = 0x.., C = 0x..;` の ★改行継続★ を 拾えず `0xFB` / `0xFE` / `0xFF` を 落とした★
★★∴ 乖離は ★`0x10` の 1 件のみ★★★(★実体に 在って 宣言に 無い★)= ★★2 者 一致★★
```
⇒ ★★∴ ★★『機械抽出』も ★書いた 人の 手が 入る★★★ ⇒ ★★∴ ★★機械抽出器 同士を 突き合わせる のが ★次の 層★★★

---

# ★★★v3-2 追補★★★(boss1 #170 / #171 / PRESIDENT #111 / #112 反映)

## v3-7 ★★`Begin` 単独経路 = ★実在する。gate は env 1 個★★★(★v3-1-c を 訂正★)

```
FieldState.cs:194 | if (_scriptWarp) { DriveScriptWarpVerify(); return; }   ★← 真の gate★
FieldState.cs:129 | _scriptWarp = _ctx.AutoBoot && Environment.GetEnvironmentVariable("DEGIMON_SCRIPTWARP") == "1";
FieldState.cs:418 |   _ctx.Dialogue.PlayMap(entry.id)
TextboxView.cs:122|     PlayMap(int mapId) => StartScenario(...)
TextboxView.cs:157|       ★_rt.Begin(entry);★   ← ★Begin 単独(PlaySection を 経由しない)★
```
★★∴ 判定 = ★『不到達』でも『常時到達』でも ない★★★ = ★★『★閉じているが 施錠は env 1 個★』★★
★`_startMapName` は #4 を 止めません★: ★write は ★1 箇所(L137)のみ★ / 値 = env `DEGIMON_BOOT_MAP` or 既定 `IntroMap` ⇒ ★常に 実在 map★ ⇒ `TryGetByName` 成功★(★母数 = grep 全出現 11★)

★★∴ 私(と worker3)の 誤りの 型★★ = ★★method 本体だけ 読み ★caller を 読まなかった★★★
 ⇒ ★★∴ ★この doc の 全ての 到達性主張に 適用★: ★★『到達しない』は ★caller を grep 全数した 上で しか 書けない★★★

## v3-8 ★★『無害』の 根拠を ★run 数★ から ★27 entry の 中身★ へ★★(PRESIDENT #111 (b))

```
★禁止★: 『worker3 の 9 run で 出なかった ⇒ 無害』
★★採る★★: 『★経路は 実在する(v3-7)。gate は env 1 個★。
          ★立てば ★27/225 entry★ の 初期 state-writer(flag/var/warp)が drop する★』
```
★★∴ 中身★★: ★entry178 = `0x1E`(SET_VAR) / entry189 = `0x1C`(SET_FLAG) / ★entry204 = `0x47`★
★remake の `0x47` 実装(DialogueRuntime.cs:934)★ = ★`0x47 MM DD 00` — ★MM = target map / DD = ★target spawn★★★
 ⇒ ★★∴ ★drop すると ★spawn 指定を 持つ op が 落ちる★ = ★player が 見る 差★★★
 ⇒ ★★∴ ★★『★止まる★』差では なく『★違う 世界線で 進む★』差★★★ ⇒ ★★プレイ検証で 気づきにくい★★

★★∴ 未突合(★塞いだ ふりを しない★)★★: ★PRESIDENT は `0x47` を『★spawn の guard/activate★』と 書き、remake comment は『MAP_CHANGE』と 書きます★
 ⇒ ★私は ★EXE 側で `0x47` semantics を 確定して いません★ ⇒ ★★同一物かは 突き合わせて いません★★

## v3-9 ★★『gate 待ちの 間 何が 起きているか』欄★★(PRESIDENT #111 (c))

★逐語★:『★gate を 重くすると 未修正が 残る。gate の 重さは ★放置の コスト★ と 釣り合わせる★』

| 項目 | ★gate★ | ★待ち 期間★ | ★★待っている 間 何が 起きているか★★ |
|---|---|---|---|
| ★`BodyStart = 4 + word0`★ | ★user 実視覚 verify + PRESIDENT 承認★ | ★2026-07-25 判定 → 現在 = ★18 日★★ | ★★非忠実と ★判っている★ 既定が 出荷 code で 動き続けている★★。★env 1 個で 27 entry の 初期 state が drop する 状態が 残る★ |
| ★`ImplementedOps` の `0x10` 欠落★ | ★なし(誰も 直していない)★ | ★#114 修理 → ★再 drift★★ | ★呼び出し 0 件ゆえ ★被害は 出ていない★。但し ★呼べば 誤値★ |
| ★remake 側 pad★ | ★★取り下げ(v3-10)★★ | — | ★入力差は ★恒久的に 除去できない★ ⇒ ★明示に 切替★ |

★★∴ 1 行目が 本 doc の ★最も 重い 未修正★★★ ⇒ ★★『★判定済 × 未反映 × 18 日★』は ★gate が 放置コストに 見合っているか★ の 判断材料★★

## v3-10 ★★分類 (2)「入力差」を ★除去できる → 除去できない・明示する★ へ 格下げ★★(boss1 #171)

★根拠(worker3 実測 / boss1 #171)★:
- ★remake に ★中央 入力 router が 存在しない★(`Input.GetKey*` が UI / Field ★20 箇所に 散在★)★
- ★PS1 16bit(SELECT 0x0001 … SQUARE 0x8000)に 対応する ★remake 側 pad word が 無い★★
- ★run は 全部 headless ⇒ ★実測値は 常に 0★ / AUTOBOOT 中の 入力 log = 0 件★

★★∴ remake 側 pad を 出すと ★『入力していない』と『入力機構が 対応していない』が 区別できなく なる★★★
 ⇒ ★★∴ ★『入力差』の 帰属は ★原盤 2 run 間(A / A')でしか 成立しない★★★
 ⇒ ★★∴ ★remake 対 原盤の 突合では ★除去できません★★★

★★∴ 器の 振る舞い(★missing_key と 同じ 扱い★)★★:
```
remake header の ★pad:"null-by-design"★ を 読む
 ⇒ footer に ★『入力差の 可能性を 排除しない』★ を ★機械判定で 出力★
 ⇒ ★★分子にも 分母にも 入れない★★(= ★数えられない ものを 数えられないと 書く★)
```
★★∴ 依頼 w3-2(pad)は ★取り下げ★★★(★boss1 の 中継ミスとして 取り下げ済。★私の 設計側も 追随★)

## v3-11 ★★抽出器の 自己申告 = ★見落としと 拾いすぎを 別々に★★★(PRESIDENT #112)

| 版 | ★偽陰性(見落とし)★ | ★偽陽性(拾いすぎ)★ | 母数 |
|---|---|---|---|
| ★修理前★ | ★3★(`0xFB`/`0xFE`/`0xFF` を case から 落とす) | ★3★(同 3 件を「宣言のみ・実体に無い」と 誤報告) | 33 |
| ★修理後★ | ★0★ | ★0★ | 33 |

★真因★ = ★DialogueRuntime.cs ★L102-L107 = 1 つの `const byte` 宣言が 6 行に またがる★★。旧正規表現が ★行単位★ で 読み 継続行を 落とした★
★★∴ 最も 重い 1 行★★: ★★偽陽性 3 と 偽陰性 3 は ★独立 6 件では なく 同一 bug の 2 症状★★★
 ⇒ ★★∴ ★『★片側の 申告は もう片側を 隠す★』の ★機序★ = ★2 症状を 2 原因と 思い込む こと★★★
★★∴ 但し 修理後の「0 / 0」も ★boss1 の 28 という 外部 oracle との 一致★ でしか 言えて いません★★ ⇒ ★★私の 抽出器 単独では ★特異度 未検証★★★

## v3-12 ★★★CLI 契約(★v3 確定 = worker2 実装用★)★★★

```
diff_harness.py <原盤_trace.jsonl> <remake_state.jsonl> [--out report.json]
                [--window-ms 0|8|16] [--selftest]

★終了 code★: ★0 = differ 0★ / ★1 = differ 非 0★ / ★★2 = 判定不能★★
```
★★突合 6 field★★: ★`pc`(★`remake_pc == 原盤_pc − 原盤_base`★ / v3-1)★ / `entry` / `stop` / `depth` / `flags` / `vars`
★★外す 8 本 = 全数開示★★(v2 §2 に 既載。★件数だけで なく 名前を 出す★)

★★判定語(★5 語★)★★:
```
match / differ / missing_null / missing_gap / missing_key
```
★★∴ v3 で 加わる 要求★★:
1. ★★footer に ★2 つの 数★ を 必ず 出す★★: ★『データ行 = N』★ と ★★『★主張に 使える 行 = M★』★★
   ⇒ ★★`M < N` の とき ★M を 分母に する★★★(★N を 使うと ★水増し★★)
2. ★★footer に ★入力差の 可能性を 排除しない★ を 出す★★(v3-10 / `pad:"null-by-design"` 検出時)
3. ★★`--selftest` は ★見落としと 拾いすぎを 別々に★ 出す★★(v3-11 / ★片側だけの 申告は 健全性の 証拠に ならない★)
4. ★★`DEGIMON_FAITHFUL_BODYSTART=1` で 消した 差は ★①の 分子から 除外しない★★★(v3-1-b)
5. ★★『現れない』は 出力語から ★禁止★★★ ⇒ ★★必ず ★母数つき★★(『この N 行では 現れなかった』)
