# ★★run3 PARK closeout（worker1 / 2026-08-25）★★

- ★tree★ = `/home/ken/Documents/Claude-Code-Communication`（comms repo）／★file★ = `workspace/degimon-faithful178/PARK_CLOSEOUT_2026-08-25.md`
- ★語★ = 「draw」は ★抽選（RNG draw）★（★描画では ありません★・描画 sink 同定 ＝ 0 件）
- ★私の 原典 doc は 別 tree★ = `/home/ken/Desktop/Digimon/degimon_world_remake-p2w1/workspace/degimon-faithful178/`
- ★他 lane の 数は ★boss1 経由（原典は 各 worker）★・私が 直に 確かめて いない ものには そう 書きます★

---

## (a) ★★静的到達と 格★★

| # | 事実 | ★格★ | 出所 |
|---|---|---|---|
| ① | ★`0x66` の RNG 消費 ＝ 0 or 1 回・★`s2 == −1 ∧ s1 ≥ 4`★ の ときだけ★ | ★★確定（EXE 逐語 `0x800EE820` / `0x800FA86C`）★★ | p2w1 `W1_X245_RESULT_782A.md`（`b6665399`） |
| ② | ★LCG ＝ `seed ← seed×0x41C64E6D + 0x3039`・戻り `(seed>>16)&0x7FFF`／`seed = 0x80009010`★ | ★確定★（★worker2・boss1 経由・私は 直に 確かめて いません★） | worker2 原典 |
| ③ | ★★Phase D partition ＝ ★確定 0 ＋ 条件つき 24（`0x66`→`0x24` 12 ＋ 両端 `0x66` 12）＋ 決まらない 35 ＝ ★59★★★ | ★確定★／★★partition invariant ＝ ★`0 + 12 + 12 + 35 = 59` ＝ 母数と 一致★★★ | p2w1 `W1_PHASE_D_STATIC_CLOSEOUT.md`（`af729145`） |
| ④ | run1 ＝ ★器の 検証（entry 148）★ | ★確定★（worker3・boss1 経由） | worker3 原典 |
| ⑤ | run2 ＝ ★抽選順 7 draw★／`#2` ＝ `MAPHEAD[0x2FE2] = 0x24` の fetch 直後 | ★★`n=1` の 相関 ＝ ★encouraging であって validation では ありません★★★ | p2w1 `W1_RUN2_FINDINGS.md`（`f6f8a97c`） |

- ★補助（確定）★ = ★fetch は read-then-increment（`0x800F0EDC`）⇒ 最後に 読んだ byte ＝ `b[cursor−1]`★／★`MAPHEAD.SCN` ≡ DG.SCN entry 0 の 先頭 23,094 byte（sha256 `375620dd…`）★

## (b) ★★壁（★なぜ 止まるか★）★★

- ★★`s2` は ★CPU register★ ゆえ ★poll できません★★★（worker3・boss1 経由）
- ★★完全な proxy が 在りません★★ = `0x80146746` も ★`−1` と `0` を 分けられません★（同上）
- ★★∴ run3 の primary は ★主問題（どの draw が `0x66` の 条件対か）を 閉じません★★★ ⇒ ★★= codex NO-GO の 核心★★
- ★私の 側の 壁（静的）★ = ★`0x37`/`0x64`/`0x66` prologue の 回数は ★gate が RAM 値ゆえ 静的に 閉じません★★（`0x800F0AC8` ＝ 分岐 0 の 純粋 load・★確定★）

## (c) ★★再開条件★★

- ★★`s2` が 観測可能に なれば★★ ＝ ★安定 emulator の 実行 breakpoint★ ／ ★完全 proxy の 発見★
- ⇒ ★exposure-controlled な run3 設計（★事前登録★）★ ＋ ★sim 器（`f83a731` で 保存済）★ で ★再開可★
- ★route 材料（静的・再開時 そのまま 使えます）★ = ★MAPHEAD の 到達 target ＝ `0x24` 14 件 / `0x37` 0 件★／★14 site を 全部 踏む 最小被覆 ＝ 11 map★／★最密は `ROOM05B`/`ROOM06`/`ROOM07` の 3 map で 5 site★（★隣接は 未確認★）

## (d) ★★記録健全化（land 済）★★

| # | 件 | 中身 |
|---|---|---|
| ① | ★partition invariant★ | ★旧 3 値 `0+12+35 = 47 ≠ 59` は ★非網羅★（codex 指摘・正）⇒ ★`0x66`→`0x66` の 12 対を 条件つき② として 追加★ |
| ② | ★『valid test』格下げ★ | ★点推定 size は ★8 config とも ≤ 0.01 合格★／★然し 本丸は ★exchangeability の 破綻★★（audit 自身が 認めて います）⇒ ★`valid` とは 書きません★ |
| ③ | ★size label 訂正★ | ★★`0.0104/0.0106/0.0111/0.0118` は ★CP 片側上界（`U`・conf 0.9875）★ で あって size では ありません★★ ⇒ ★★boss1 が 枠を 落として 中継し・★私が 額面で 受けて「4 config とも 超過」と 書きました★★★（★2 本で 1 組★） |
| ④ | ★post-hoc の 3 値★ | ★★post-hoc です（確定）／但し「結果に 合わせて 緩めた」形では ありません★★（①提案者が bias を 先に 開示 ②codex が 提案者の 案 `2α` を ★却下★ し より 厳しい `0.015` を 採用 ③remedy（fresh 較正）が 事前指定 かつ 実行済）／★残る 反実仮想は ★開いた まま★★ |
| ⑤ | ★invariant の 全数適用（#861-A）★ | ★明示算術 ★19 式 ＝ 合う 19 / 合わない 0★★／★1 回目の「不一致 6」は ★私の regex の 偽陽性★（`2*` 落ち・hex 誤読）★／★★第 3 値（母数の 無い 内訳）＝ ★決まらない★★★（★器が 陽性対照 `W1_TIMEBAND_SITES_546A.md:43` の `32+7+27+48 = 114 ✓` を 落とした ため ★数を 出しません★★）／★札 ＝ 器・再開時に 手作業（90 行）を 回せば 閉じます★ |

- ★見本（invariant を 満たす 形）★ = ★`0 + 12 + 12 + 35 = 59`★ ／ ★`32 + 7 + 27 + 48 = 114 ✓`（★2026-08 の 私の doc に 既に 在った★ ＝ ★invariant は 新しい 規範では なく 既に 踏んで いた★）★

## (e) ★★不変（全件維持）★★

remake code ★0 行★ ／ ★emulator run 0 本★ ／ compile ★0★ ／ push ★HOLD★ ／ overlay 開封 ★禁止★ ／ 視覚 ★凍結★ ／ ★read only★ ／ ★poll only★

- ★本 doc の 作成で 触った もの ＝ ★doc と grep と 静的 python のみ★★（★枠の 統一どおり 静的 python は 対象外★）
