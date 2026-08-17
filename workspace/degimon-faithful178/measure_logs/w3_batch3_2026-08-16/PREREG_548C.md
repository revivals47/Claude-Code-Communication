# PREREG_548C — ③④⑤ ★cherry-pick して 撃つ★（worker3 / #548-C）

★★撃つ前に commit します★★ / ★★「完成」とは 書きません★★（user の 実視覚まで 凍結）/ ★★land は boss1 が 決めます★★

## 0. ★手順★

1. ★`de350eb8`（p2w2）を ★cherry-pick★★（★file を copy しません★）
2. ★compile★（`W3MeasureBuild437C.Build`）
3. ★★④ 退路を 先に★★（受理条件 (2)）= ★env 未設定 ⇒ ★体数 5 / 総数 8★★
4. ★① `DEGIMON_TIME_PLACEMENT=1` ＋ `DEGIMON_START_HOUR=12`★ / ★② 同 ＋ `=22`★
5. ★判定★ = ★`PLACE-SPECIES` の 行（★私の #543-C 印字器★）★ ＋ ★`[PLACE]` の 数★

★boot★ = ★`DEGIMON_BOOT_MAP=mayo00`★（`FieldState.cs:143`）⇒ ★warp も launch も 不要★
★★衝突の 見込み★★ = ★worker2 は `EntityPlacer.cs` を 5 箇所 触っています★ / ★私も 1 箇所 足しています★
　⇒ ★★衝突したら ★両方 残す★★★（★私の 印字は 判定に 要ります★）⇒ ★解決内容を 報告します★

## 1. ★事前登録（予想）★ — ★数を 先に 埋めません★

| # | 内容 | 結果 |
|---|---|---|
| ★V1★ | ①②③④ すべて 的中 | (未) |
| ★V2★ | ①② が ★反転★ ⇒ 生成器の 向きが まだ 逆（self-test を 疑う） | (未) |
| ★V3★ | 体数が 5 のまま ⇒ ★env が 効いていない★ | (未) |
| ★V4★ | slot 2 が ①② で 違う ⇒ ★表が slot 2 を 拾っている★ | (未) |
| ★★V5★★ | ★④ が 崩れる★ ⇒ ★★退路が 壊れた = 最も 重い★★ | (未) |

★私の 予想の 向き★（★#544-C の 実機と 同じ★）= ★★12 時 ⇒ 83（slot 3,4）／ 22 時 ⇒ 74（slot 0,1）★★

## 2. ★母数 / 撃つ 本数★

- ★run = ★4 本★★（★env 未設定 / 12 時 / 22 時 / ★gate ON ＋ START_HOUR 未設定★）
- ★★最後の 1 本の 意味★★ = ★`DEGIMON_TIME_PLACEMENT=1` だけで ★game-clock を 読むか★★
- ★毎回 印字★ = `PLACE-SPECIES` 全行 ＋ `[PLACE]` 行
- ★headless（`-batchmode -nographics`）★ = ★window を 出しません★

## 3. ★切るもの★

- ★★条件の land★★ = ★★私は 決めません★★（boss1 の 座）
- ★他 47 map の 検定★（★依頼は mayo00★）
