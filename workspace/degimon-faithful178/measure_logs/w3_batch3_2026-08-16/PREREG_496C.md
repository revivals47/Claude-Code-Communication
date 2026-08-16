# PREREG_496C — trace の被覆を上げる（worker3 / #496-C）

★★本 file は 1 度でも 数を 撮る前に commit します★★（受理条件 (1)）。
★数は 先に 埋めません★（O③ の作法 = 受理条件 (3)）。

---

## 0. 何を しようとしているか

#490-C で 撮れたのは ★3 経路・80 行・相異 pc 78 点★ でした。
boss1 の依頼 = ★mayo00 の他 section を踏む筋書きを作る★。

## 1. ★選んだ 梃子（★新しい走査器を 書きません★）★

★`DEGIMON_DUMP_ENTRY` ＋ `DEGIMON_DUMP_SECTIONS`★
= `DialogueRuntime.DumpSections()`（`:2427`）＝ ★既に在る 器★。

なぜ これを 選ぶか:
- ★headless で 走る★（`Tick` / `AdvanceInput` を 内部で 回す）⇒ ★user を 呼びません★（受理条件 (5)）
- ★key を 列で 与えられる★ ⇒ ★1 run で 多数の section を 叩けます★
- ★`PlaySection` を 通る★ ⇒ ★私が #490-C で 足した `[OPTRACE]` 印字は そのまま 発火します★
- ★不在の key を 「不在(no section)」と 印字する★ ⇒ ★★母数の 数え上げに そのまま 使えます★★

★他に 見た 梃子と 落とした理由★:
- `DEGIMON_V4_PLAYSECTION`（`V4PlaySectionHook.cs:23`）= ★F9 の 押下が 要る★ ⇒ ★headless 不可・user を 呼ぶ★ ⇒ ★落とす★
- `DEGIMON_NPC_TEST`（`FieldManager.cs:136`）= ★NPC 接近が 要る★ ⇒ ★player build と 歩行が 要る★ ⇒ ★今便では 落とす★（札=材料）
- tile 52 を 踏む = ★実機歩行★ ⇒ ★窓を 出す run★ ⇒ ★★boss1 の 停止命令（窓を 出す run を 止めよ）が 生きています★★ ⇒ ★落とす★

## 2. ★★本器の 限定（先に 書きます）★★

★★「叩いた」は 「実機で 踏んだ」では ありません★★:
- `DumpSections` は ★section の 頭から 直接 起動★ します（`Root = FullScenario` 既定・`SceneCutscene` を 与えない）
- ★live で player が 歩いて 到達したか は 一切 見ていません★
- ⇒ ★∴ tsv の `run` 列で ★`live-walk` と `headless-dump` を 分けます★★（★混ぜません★）

★(A) の oracle としては どうか★:
- ★実行された byte 範囲★ という点では ★同じ意味で 有効★（★VM が 実際に 命令として 消費した pc★）
- ★但し 到達可能性の 証拠には なりません★（★誰も そこへ 歩けないかも しれません★）

## 3. ★事前登録（予想）★ — ★★数を 先に 埋めません★★

| # | 予想 | 根拠 | 結果 |
|---|---|---|---|
| O① | `-executeMethod` で ★runtime class の `DumpSections` を 叩ける★ | ★doc-comment が「Unity -executeMethod から呼ぶ」と 書いている★ / ★但し Unity の 通例は Editor assembly★ ⇒ ★自信は 低い★ | (未) |
| O② | ★gate OFF で `[OPTRACE]` 0 行★ ＋ ★`[DUMP]` 行が 完全一致★ | #490-C の O② と 同形（受理条件 (2)） | (未) |
| O③ | entry 101 の section は ★key 0-255 のうち 一部のみ 実在★ | ★section 表は 疎★ | (未) |
| O④ | ★相異 pc は 78 点より 増える★ | ★新しい section を 踏むため★ | (未) |
| O⑤ | ★`SJIS-text` 行が 出る★ | ★#490-C で 外した 予想の 再撃★ / ★worker2 の 51.9% は text★ | (未) |
| O⑥ | ★叩いた section の 一部は `WaitingChoice` で 止まる★（= 全部は 走り切らない） | `DumpSections` は choice で break する | (未) |

★O⑤ が 当たれば★ = #490-C の 2 択のうち ★「経路を 走らせていなかった」側★ が 生きます。
★O⑤ が また 外れれば★ = ★「VM が trace 前に 消費する」側★ の 疑いが 上がります（★決めつけません★）。

## 4. ★母数の 申告（今から 数えるもの）★

- ★枠★ = ★entry 101（mayo00 の loader）の key 0-255★
  - ★entry=101 の 出所★ = ★#490-C の live run で `[OPTRACE] entry=101` が mayo00 上で 出た★（★測定★・★推定では ありません★）
- ★★「mayo00 に section が いくつ 在るか」は 誰も 数えていない★★（boss1 §4）
  ⇒ ★本便で 数えるのは ★entry 101 の 表に 在る key の 数★★ であって
    ★「mayo00 の 全 section」では ありません★（★別の entry が 関与する 可能性を 排していません★）

## 5. ★受理条件の 対応表★

| boss1 の条件 | 本便での 形 |
|---|---|
| (1) 事前登録を 撃つ前に commit | ★本 file★ |
| (2) gate OFF で 1 bit も 変わらない対照 | ★O②★ |
| (3) 数は 先に 埋めない | ★§3 の 表は 空欄★ |
| (4) `is_text` 列を 維持 | ★tsv の 列を 変えません★（★`run` 列の 値が 増えるだけ★） |
| (5) user を 呼ばない | ★headless のみ★（★窓を 出す run を 使いません★） |
| 「切った」と「出なかった」を 分ける | ★§1 の「落とした 梃子」＋ §2 の `run` 列★ |
