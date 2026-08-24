# W3 #850-C — 構造監査 4 点 ＋ 第 1 session 設計

- 便 #850-C ／ ★remake game code 0 行・compile 0・push HOLD・read only★／★run3 の log は 存在しません★

## §0 ★★gate 確定（記録）★★

```
 gate2  : 0.0080 / 0.0089 / 0.0111 / 0.0106 → ★4/4 合格★（seed 777001）
 fresh  : 0.0104 / 0.0104 / 0.0099 / 0.0118 → ★4/4 合格★（seed 20260825・★独立★）
 power  : ★1.000★（π=100% / 80%）
 判定   : ★非劣性（Clopper-Pearson 片側 上界 ≤ 0.015・Bonferroni 98.75%）★
```

- ★★∴ ★run3 は ★valid かつ vacuous でない 検定★ である ことが 確定★★

## §1 ★★★構造監査 4 点（codex #5）★★★

### 1-1 ★block は strata 内で 単位として 交換可能か（group closure）★

- ★変換群★ = ★★traversal ごとの ★5 block の 対称群 `S_5`★ の ★直積★★★ ⇒ ★★closure / 単位元 / 逆元 いずれも 成立★★（★群です★）
- ★strata（方向）を 跨がない★・★traversal を 跨がない★ ⇒ ★★#847-C (1) の 要件を 満たします★★
- ★★★但し ★交換可能性の 実体は ★outcome 過程が block 単位で 定常★ である こと★★★ ⇒ ★★★これは ★成り立ちません★★★（★burst 過程は ★block 境界を またいで 記憶を 持ちます★★）⇒ ★★∴ ★★近似です★★★
- ★★∴ ★だからこそ ★sim で size を 測った★★★ = ★★§0 が その 補償★★（★★理論的 exchangeability では なく ★経験 size★ で 担保して います★★）

### 1-2 ★境界（部分 block・state 遷移を 跨ぐ block）★

| 項 | 状態 |
|---|---|
| ★部分 block★ | ★★存在しません★★（`M=25 / L=5 → NB=5` ★端数なし★） |
| ★burst が block 境界を 跨ぐ★ | ★★起こります★★／★burst の 平均長 ≒ `1/(1-0.45) ≒ 1.8`★ ⇒ ★`L=5` は ★平均 burst の 2.8 倍★★ ⇒ ★★大半の burst は block 内に 収まります★★ |
| ★遷移（`base`/`map` 変化）を 跨ぐ block★ | ★★遷移窓 ±0.5 秒を 除外して から block 化します★★（★除外後に 番号を 振り直す★） |

- ★★★実 data では `M` は 25 固定では ありません★★★ ⇒ ★★∴ ★★実装規則を 凍結します★★★ = ★★『traversal の episode 数 `m` に 対し ★`NB = floor(m/5)`★ の block を 作り ★余り `m mod 5` は ★最後の block に 併合★★』★★（★★捨てません★★）

### 1-3 ★sparse strata★

- ★strata = 方向 2 つ★・★総 `k ≈ 40` ⇒ 1 stratum ≒ 20★ ⇒ ★★`k<3` 保護に 抵触しません★★
- ★★但し ★実測で 抵触したら★★★ = ★★『その stratum を 落とし ★落とした 数と k を 報告★』★★（#825-C §C の まま）
- ★粗い p / tie★ = ★★`min p` を ★必ず 併記★ します★★（★T=16 単一で 0.0532 = vacuous だった 前例★）

### 1-4 ★★prediction leakage（★最重要★）★★

- ★予測位置の 選択過程★ = ★★①`{0x24, 0x37}`（#827-C で 凍結）②lag = ★区間の 前★（#825-C で 凍結）③E-1（静的長 一致）★★
- ★★★3 つとも ★run3 の data が 存在する ★前★ に commit 済★★★（`ded0b97` / `13d5fb2` / `1f773a9` / `3a157a1`）⇒ ★★∴ ★outcome を 一切 使って いません★★
- ★★∴ ★『各 null 反復で 選択過程を 再実行する』必要は ありません★★★（★選択が outcome に 依存しない ため★）
- ★★★但し 1 つ 残ります★★★ = ★★`L=5` は ★sim で 選びました★★ ⇒ ★★∴ ★fresh 較正（別 seed）で ★選択後の 独立確認★ を 済ませて います★★（#847-C (6)）

## §2 ★★★第 1 session の 設計★★★

### 2-1 route

- ★★`ROOM05B(215)` ↔ `ROOM06(216)` ↔ `ROOM07(217)` の 往復★★（★site 5・#843-C★）
- ★根拠★ = ★`k/分` で 11 map 最小被覆に 勝つ 公算★／★★隣接そのものを probe で 実測できます★★
- ★次手★ = ★落ちたら ★11 map 最小被覆★★

### 2-2 ★probe（★5 分・3 項★）★

| # | 判定 | 中止条件 |
|---|---|---|
| ★P1★ | ★器 gate（G1 接続 / G2 2 点照合）★ | ★不合格 → ★即 中止★★ |
| ★P2★ | ★★1 周の 実時間★★ | ★★3 分 超 → 中止★★（#843-C・★8 session 超を 出さない★） |
| ★P3★ | ★★`k/traversal`★★ | ★★閾値 0.5 未満 → 中止★★（#831-C・★誤中止 5.9%（λ=1.0）★） |

- ★★probe の data は ★本解析に 含めます★★★（★捨てません★）
- ★★3 項とも ★outcome-blind★★★（★seed の 結果を 見ません★）

### 2-3 停止規則

- ★1 session★ = ★★`min(15 分, probe 中止)`★★
- ★全体★ = ★★『総 `k` が ★40★ に 達するまで session を 重ねる』★★／★★各 session 後に ★累積 k と 残り 見込み session 数★ を user に 返す★★
- ★★`k` の 定義★★ = ★★outcome-blind な exposure（★予測位置を 訪問した 独立 episode 数★）★★

### 2-4 器の 変更（run2 → run3）

1. ★slow の key に ★`base`★ を 足す★
2. ★★`base`/`entry` が 変わる たびに ★load buffer 8 KB を dump★★★
3. ★fast の key = `(seed, cursor, base)`★（★変更なし★）
4. ★受入条件は ★`__main__` の assert★★

### 2-5 user 指示（★用語 ゼロ★）

> ★★「★3 つの 部屋の 間を 行ったり 来たり して ください。画面が 切り替わった 後は ★絵が 落ち着いてから★ 次へ 進んで ください。★1 回 15 分★ で こちらから 止めます。★何回 お願いするかは 毎回 お伝えします★」★★

## §3 ★★判断待ち（★1 点だけ・他は 進めます★）★★

- ★★『どの savestate から 始めるか』★★ = ★★ROOM 3 部屋に 行ける 位置★★ ⇒ ★★user しか 知りません★★
- ★★∴ これ 1 点を 保留し ★他は 全部 確定しました★★★


---

## §4 ★★★【#855-C】codex = ★NO-GO★（★統計は 通ったが 的が 違った★）★★★

### 4-1 ★codex の 逐語★

> 『★No-go for the planned 3-8-session run3★. ★A single capped feasibility/calibration session is reasonable★,
>   but ★the present primary test is not decision-relevant to the unresolved Phase-D question★.』
> 『the pooled primary is ★weakly informative★. ★0x24 is already statically established as an
>   unconditional one-draw opcode★. Pooling it with unresolved 0x37 means ★a positive result may be
>   produced entirely by the known positive control★. ★The primary excludes 0x66 altogether★.
>   Therefore it ★does not materially close the main Phase-D uncertainty★.』
> 『If the project decision actually depends on resolving the conditional 0x66 order,
>   ★pause live capture until the experiment can observe s2 or an equivalent complete proxy★.』

### 4-2 ★★NO-GO の 理由（★私の 言葉で★）★★

- ★★『統計は 通った が ★的が 違った★』★★
  - ★統計★ = ★gate2 4/4 ＋ fresh 4/4（独立 seed）＋ power 1.000★ ⇒ ★★valid かつ vacuous でない★★
  - ★★然し ★primary の 中身★★★ = ★`{0x24, 0x37}` の pooled★ ⇒ ★★①`0x24` は ★既に 静的に「無条件 1 draw」★★ ⇒ ★陽性が 出ても ★既知の 陽性対照だけで 説明が 付く★★／★★②`0x66` を ★E-1 で ambiguous に 落とした 結果 ★完全に 除外★ して いた★★
  - ★★∴ ★主問題（★条件つき `0x66` の 順序★）に ★1 mm も 触れません★★★
- ★★∴ ★私は ★『検定として 正しいか』★ ばかり 精密に し ★『何を 決める 検定か』★ を ★E-1 で 削って いた ことに 気づきません でした★★★
  - ★★= ★#827-C で ★`0x66` を ambiguous に 落とした とき★ に ★『主問題が 落ちた』と 書くべき でした★★★

### 4-3 ★★生きて いる 道（★doc に 残します★）★★

- ★★『★A single capped feasibility/calibration session is reasonable★』★★ ⇒ ★★★『1 session だけの ★上限つき feasibility / 較正★』は ★否定されて いません★★★
- ★★但し ★それは 検定では ありません★★★（★実測を 取る だけ★）⇒ ★★∴ ★選択肢として 残します（★今は 撃ちません★）★★

## §5 ★★【#855-C ②】`s2` を 観測する 別の 道（★1 回だけ 考えました★）★★

### 5-1 ★★思いつきは ★在ります★★★

- ★★候補 = ★`[X+0x64E]` = `0x80146746` が ★0 に なる★ こと★★★
- ★根拠（★実測★）★:

| 書き手 | 書く値 |
|---|---|
| `0x80105E14` | ★3★ |
| `0x80107D58` | ★1★ |
| `0x80107F64` | ★0xB★ |
| ★`0x8005CB40`（overlay・s0 = −1 の 経路）★ | ★★0★★ |
| ★`0x8005CB70`（overlay・s0 = 0 の 経路）★ | ★★0★★ |

- ★★∴ ★既知の 書き手の うち ★0 を 書くのは `0x8005CA7C` だけ★★★ ⇒ ★★∴ ★『`0x80146746` が 0 に 遷移した』= ★`0x8005CA7C` が 走り 戻り値が −1 か 0★★★
- ★★∴ ★#806-C の 代理（`[0x80141D42]` 等）より ★はるかに 綺麗★★★（★あちらは 外部書き手 22/17/16/3★・★こちらは ★値が 衝突しません★★）

### 5-2 ★★但し ★完全では ありません★（★3 つ★）★★

1. ★★★−1 と 0 を 分けられません★★★ ⇒ ★★∴ ★run3 の 条件（`s2 == −1`）には ★足りません★★★
   - ★補助★ = ★`[0x80141D3A] += 2` は ★s0 = 0 の 経路だけ★・外部の 定数差分 7 件に ★+2 は 在りません★★ ⇒ ★★∴ ★組み合わせれば 分かれる 公算★★（★但し ★変数差分 3 ＋ 決まらない 4 = 7 件が 射程外★★）
2. ★★`0x80146746` の ★base が 実行時値の store 13,977 件★ は ★射程外★★★（#807-C）
3. ★★overlay 側の 書き手は ★開封禁止ゆえ 数えて いません★★★

### 5-3 ★★∴ 3 値★★

- ★★『★完全な proxy は 無い★・但し ★#806-C より 良い 候補が 1 つ 在る★』★★
- ★★∴ ★探しに 行って いません★★（★#855-C の 指示どおり ★思いつきが 在るかだけ★）
