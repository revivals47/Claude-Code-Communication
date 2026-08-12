# P2_DIFF_HARNESS_DESIGN — ★① の 器(原盤 trace 対 remake trace)の 設計★(worker1 / 2026-08-12)

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
