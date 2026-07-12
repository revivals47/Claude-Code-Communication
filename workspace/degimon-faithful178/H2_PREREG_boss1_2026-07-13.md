# H2 事前登録 — ★走らせる前に書く。以後変更禁止★

書いた時刻 = **instrument 一括変更に着手する前**。
`dg_vmtrace.cpp` mtime = `2026-07-12 20:58`（**まだ 1 バイトも触っていない**）。duckstation 走行なし。
main `7a87fba` / origin/main `59488d0`（不変） / frozen `09fde5a`（不触）。

**私はこの時点で P1/P2/P3 の結果を一切見ていない。**

---

## P1 — button-phase reset 後、control 同士は bit 一致するか？

**boss1 予測 = ★YES（bit 一致する）★**

理由: 前フェーズで **control 同士が食い違った launch について、捕捉 state（rng_seed / eventBank bank_block / ram_inputs 3 ブロック）は全て bit 一致**していた。
唯一制御されていなかった変数が **host 側ボタン位相**（`DriveInput(n)` の `n` が launch/reload 跨ぎで非リセット、実測確認済）。
savestate は emulated machine を全復元するので、位相を launch 相対にすれば残る非決定要因は無いはず。

★**外れ方を先に定義**★:
- **NO（残差が出る）= それ自体が本物の finding** ⇒ **「捕捉していない state が他にもある」の直接証明**。
  その場合は **残差 launch を全出力**し、捕捉 state を突合して**何が違うか**を特定する（前回と同じ手順）。**残差を「わずかだから無害」と丸めない。**
- **他の host 側非リセット変数**（`s_seq` / phase machine の内部カウンタ等）が真因である可能性も開けておく（H4）。

## P2 — NOT-SHOWN 7 件を gate 値で再注入したら、何件が INPUT に転ぶか？

**boss1 予測 = ★5 件が INPUT に転ぶ（7 件中）。残り 2 件は NOT-SHOWN のまま★**

根拠（worker2 の reader 分類 + 必要注入値。**これは候補であって判定ではない**）:

| addr | 既知の gate / reader | 予測 | 理由 |
|---|---|---|---|
| `0x8016B07C` | CF/WGATE、必要値 **2** | **INPUT に転ぶ** | 等値 gate `==2` を跨げる |
| `0x8016B07D` | WGATE 2 | **INPUT に転ぶ** | 同上 |
| `0x8016B0B8` | CF/WGATE、必要値 **2** | **INPUT に転ぶ** | 同上 |
| `0x8016B0B9` | WGATE 3、必要値 **1** | **INPUT に転ぶ** | `==1` を跨げる |
| `0x8016B3D9` | **CF 4 / WGATE 0** | **INPUT に転ぶ** | CF が 4 本ある |
| `0x8016B441` | **CF 4 / WGATE 0** | **NOT-SHOWN のまま** | CF は在るが、XOR で既に beqz 型は反転済のはず＝等値型のみ残り、当たらない公算 |
| `0x8013E104` | **CF 0 / WGATE 0 / DATA 1** | **NOT-SHOWN のまま** | ★16 target 中唯一、条件分岐に一切使われない。前回も NOT-SHOWN。DATA 1 は「候補」であって実測は CONST 側★ |

★**外れ方を先に定義**★:
- **7 件全部が転ぶ** → 私の「`0x8013E104` は定数」という読みが誤り。**DATA 経路が効いていた**ことになる。
- **転ぶのが 2 件以下** → **gate 値の割り出し（worker2 の静的分類）が誤っている**か、**reader が field code で VM window 外にしか効かない**。
- ★**どちらに転んでも、N の下限は上がるか据え置きであって下がらない**（前回 INPUT 9 件は取り消されない）★

## P3 — fixed-harness の verdict は、旧 first-divergence verdict と収束するか？

**boss1 予測 = ★INPUT/NOT-SHOWN の集合は一致（9 件のまま）。dimension は 4 件確定分が一致、provisional 2 件は変わり得る★**

理由: first-divergence 規則は「初差より前は位相が揃っている」という**構造的に妥当な根拠**に立っており、
button-phase reset は**それを全 launch に拡張する**だけ。よって初差 launch の dimension は変わらないはず。
一方 **provisional 2 件（`0x8016B169` STATE-only / `0x8016B084` RNG-only）は初差 launch が遅い/微小差**なので、
clean data で別の次元が先に出る可能性がある。

★**外れ方を先に定義**★:
- **INPUT 集合が割れた** = **first-divergence 規則に穴があった** ⇒ **それ自体が finding**。
  その場合は「旧 verdict の 9 件」を**撤回可能な下限**として扱い直す。
- **dimension が 4 件確定分でも割れた** = 「初差はカスケード前だから汚染されない」という前提が誤り ⇒ **規則ごと見直す**。

---

## ★判定基準（結果を見てから動かさない）★

- **INPUT の閾値は `aba590e` から不変**: 注入が適用され、PC / STATE / RNG / DONE のどれか 1 つでも 1 launch で変われば INPUT。
- **NOT-SHOWN-INPUT は「非入力の証明」ではない**（複数値注入後も同じ。**試した値の集合を必ず明記する**）。
- **全 16 target が走り切るまで N を更新しない**（部分集計で N を語らない）。
- **`read∩store` を完全性の基準に使わない** — ★基準は「runtime で可変か」であって「window 内で書かれるか」ではない★。
  前フェーズで **INPUT 確定 9 件のうち 3 件が `wcount=0`**（read∩store なら脱落）と実測済み。

## ★staleness の扱い（混同禁止）★

- instrument 変更で **H フェーズの artifact は無効化される = 想定内**（本 batch が再生成する）。
- ★frozen `09fde5a` は**別 authority**。instrument の staleness とは無関係。**追加であって置換ではない**★。
