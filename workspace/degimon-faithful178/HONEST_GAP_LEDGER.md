# HONEST GAP LEDGER — Digimon World remake 3D-化 現到達点 (worker3, 2026-07-24)

honest透明化の単一source。進捗の過大表示を防ぐため、6次元の到達点と gap源を明記。

## 全体サマリ
- ★136 distinct-appearance model を 3D化完成★（124 unique base character + 12 variant new-look）。
- 178 literal差=43 = 既存modelの stat変種（sha一致=texture同一=視覚複製）。新geometry/新appearanceでない → padding回避で不生成、必要時に同pipeline即生成可。
- 正確表現: 「178中の全distinct appearance（=136 prefab）を網羅」。「136/178」でなく「全distinct見た目を網羅、残43は視覚複製」。

## 6次元 到達点テーブル
| 次元 | 到達点 | 根拠 | gap / 未達 |
|------|--------|------|-----------|
| ① 形状(geometry) | ★完成★ 136 distinct model import→rig | 7 batch全gate PASS、fail 0 | なし(43 stat変種は同geometry複製) |
| ② 色(canonical) | ★完成★ emission floor全種、灰青ゼロ | TOKO srgb(90,91,95)≈原盤(85,84,83)、7 batch灰青混入ゼロ | なし(暗域含め canonical維持実証) |
| ③ form(立体感) | ★完成★ lit shading残しpure-flat回避 | TOKO gradient top71/center91/bottom53≈原盤(72/85/44) | なし |
| ④ facing(向き) | ★村3種=faithful★ / gallery=viewing(camera向き) | rot@+0xe実読→convention=直接を視覚lock(Toko tilt+gestalt)、村default適用 | ★全map placement facing=loader RE gated(下記⑥依存)★ |
| ⑤ scale | ★native-uniform interim(faithful93%)★ | (A)/(B)判別: visible body0.574/total0.622 vs faithful0.67、bbox0.52より近 | ★完全faithful=残~1.1x per-species factor。源=user-session watchpoint(scale適用site) or per-species原盤frame★ |
| ⑥ placement(位置) | ★村3種=RAM authoritative★ / 全map=未 | 村=RAM位置baked-in(json bug非依存) | ★全map per-NPC配置=loader RE gated(entity array書込みPC未取得、user-session watchpoint待ち)★ |

## gap源(user-session gated、自律不可)
- ★(b) placement層 / (c) faithful scale★ = 両方 DuckStation write-watchpoint(entity array/scale適用site)で解消。
  - feasibility実測: GDB server実在するが headless :1で DuckStation emulation走行不能→port未listen→自律不可。★user が real display で DuckStation(EnableGDBServer=true)+game走行させれば、準備済gdb scriptで非対話trap可★。
  - 手順: WATCHPOINT_gdb_procedure.md 参照。

## 非侵襲性(remake本体)
- 全て ViseAvatar/ViseNpc additive層(RuntimeInitializeOnLoadMethod + env gate、OFF-inert)。remake scene/logic非改変。push HOLD。
- controller: 代表30種(baby/champion/batch2)full実証、bulk106種=model-only(anim controller skip、honest gap、placement時該当種full-build可)。

## 2026-08-15 追加 — ★item 使用 UI が無い★(実装対象 第 2 号の引き金)
| 名 | 欄 | 影響 | 出所 |
|---|---|---|---|
| ★**item 使用 UI が無い**★ | ★機構ごと欠落★(remake に item 選択/使用の呼び元 = ★0 件★) | ★オートパイロットの**引き金が dev-gate しか無い**★(env `DEGIMON_ITEM_AUTOPILOT` ＋ F10、既定 OFF) | worker3 #522 / #552、PRESIDENT (1754) 条件 ③ |

- **効果**は実装済で数が出ている(`284b356d`：変種 id が変わった launch = ★10 / 20 状態★、対照 item 21・38 → −1)。
  ★**「効果」と「引き金」を分けて申告する**★ — 効果は立ち、引き金は未実装。
- ∴ ★**「オートパイロットが動く」とは書かない**★。書けるのは ★「**効果**を live で確認した」★ のみ(それも live 視覚の取得後)。
- 原盤側の引き金は特定済(実装の指針): item 表 `0x8013400C` の id 22..37 → handler `0x800CD2D4` →
  `0x800CD39C jal 0x800F0188(0, 1245, 0)`。使用の順序 = ★効果 → 在庫 −1(cursor の欄) → 使用中 id を 255★。
  在庫 = `0x80145F2C+i`(id) / `+0x1E`(個数・上限 99) / `+0x3C` / `0x80145F86`(有効 slot 数)。
- ★**live 視覚は未取得**★ = 完成 claim 凍結。取得には ★item22 worktree からの Unity build 1 回(user 資源)★ が要る。

## 2026-08-15 追加(2) — live 実 build で確認した/しなかったこと
### ★確認した = 「効果」★(user 実プレイ・log 直読、PRESIDENT (1778))
```
[ITEM-AUTOPILOT] item=22 → entry 0 / section 1245 → map=204   (3 回とも)
[MapLoader] loaded 'TWNA01' from 'maps/twna01/twna01.json'
```
⇒ ∴ ★**鎖は live の実 build で端から端まで動いた**★(harness ではなく**画面が出ている binary**)。
⇒ ∴ ★書ける = 「**効果**(1245 が選んだ map への帰還)を live で確認した」★

### ★確認していない = 「街の姿が変わる」★
user は ★新規 game(加入 0・繁栄度 0)★ ⇒ 我々の表では ★**204 が唯一の答え**★。
⇒ ∴ ★**「変わらない」は失敗ではなく正しい出力**★ = 分類 ★① 同値(下端)★。
⇒ ∴ 見える差を出すには ★**加入が要る**★(実 play 依存 / live build に flag 注入の env は見当たらない)。
⇒ ∴ ★**「街の姿が変わる」とは書かない**★ / ★「オートパイロットが動く」とも書かない(引き金は dev-gate)★

### ★視覚 gap(user 一次情報・(1781))★
| 名 | 内容 | 備考 |
|---|---|---|
| ★覚醒場面のカメラ★ | ★ズームが強すぎる★ / ★カメラが高い(もう少し下)★ | ★**headless では一生出ない型**★。数値化は user 判断 |

### ★build 手順の欠落(我々の実装とは無関係)★
★`data/` 36 件・`maps/` 486 件が build に入っていなかった★(PRESIDENT が配置して復旧、実装は無変更)。
⇒ ∴ ★**build 手順そのものが不完全**★ — 次回 build 時に同じ欠落が出る。手順側の修正が要る。

## 2026-08-15 追加(3) — ★item 22 の前提条件 `[gp-0x6cb0]` を remake が持っていない★
**原盤**: item 22 arm は ★`[gp-0x6cb0] != 1` なら何もしない★(`0x800CD378` lw → `bne v0,1`)。
**意味**(worker2 `fb83397`、逐語 4 本立て・反例なし): ★**1 = script(VM) が走っていない / 0 = 走っている**★
⇒ ∴ item 22 の gate = ★**「script 実行中は街へ戻さない」**★。

| 根拠 | 逐語 |
|---|---|
| (A) | `0x80118590` = lw → ★`bnez` で `jal 0x800F027C`(VM step)を飛ばす★ ⇒ VM step は cell が 0 のときだけ回る |
| (B) | `0x800F0208` = 汎用入口 `0x800F0188` の直線 init(分岐 0 本)⇒ ★起動した瞬間 必ず 0★ |
| (C) | 進めなくなったら 1(終端 / band 外 opcode 151 本 / loop 条件、いずれも直後 yield) |
| (D) | ★`0x800F0188` の呼び元 12 site のうち **10 site** がこの cell の門の中★ ⇒ ★**二重起動の禁止**★ ★**12/12 ではない**★(内訳は下記) |

★**(D) の内訳(2026-08-15 15:15、worker2 が自分の開示を閉じた結果)**★:

| # | site | 状態 |
|---|---|---|
| 10 | — | ★`[gp-0x6cb0] == 1` の門の中★ |
| 1 | `0x800F0168`(fn `0x800F0150`) | ★0 を書いた直後に `0x800F027C` を呼ぶ**起動 routine** ⇒ 門が要らない(自明)★ |
| 1 | `0x800FF0E8`(fn `0x800FF0D4`) | ★門は**別**(`0x8007D8D4` の返り値)・★**判定不能**★ |

`fn 0x800FF0D4` = 12 語の薄い殻 = ★`LaunchSection(entry 0, section 1252, 0)` だけ・条件分岐 0 本★。
その呼び元 `fn 0x80102BAC` は ★`jal 0x8007D8D4` の返り値で門を作る★ が、
★**`0x8007D8D4` は EXE image の外**★(image = `0x80090800..0x8013E000`、`0x8007` 帯は disasm に 0 行)
⇒ ∴ ★**別 overlay / kernel 側 = 我々の母数の外**★ = 分類 ★④★。

⇒ ∴ ★**「全数見た上での反例なし」と書けるのは (A)(B)(C) だけ**★。
   (D) は ★**10/12 が cell の門 / 1 は自明 / 1 は判定不能**★ と書く(worker2 の明示的な要請)。
⇒ ∴ 併せて記録すべき境界: ★**「EXE 全 177,664 命令・全走査」の母数には端がある**★ —
   `0x8007` 帯のような image 外の呼び先は ★**走査したことにならない**★。

読み手 18 件の全数分類(過不足なし) = ★`== 1` の門 10★ / ★真偽 4★ / ★返り値として読む 4★
(後者は `fn 0x800F027C` = 「VM を 1 歩進めて**止まったか**を返す」)。

- ★**実装すべき**★(＝今の remake が持たないのは**忠実性 gap**)。remake 側の等価条件 = ★VM が idle のときだけ効く★(1 行)。
- ★**ただし現状は観測不能**★ — 差が出るのは ★script 実行中に item を使える UI が在る場合だけ★ で、UI が無い(上の gap)。
- 開示: ★worker2 は実行していない(根拠は code の構造のみ)★ / 覆われない 2 site の一方 `0x800FF0E8` は未読 /
  jalr 98 件は塞げない / ★**「VM idle」は worker2 が付けた名で、原盤の呼び名ではない**★((6-av) 遵守)。

## 2026-08-15 追加(4) — ★overlay 帯(image の下)★ ※旧称「未踏帯」
| 名 | 範囲 | 何が依存するか | 分類 |
|---|---|---|---|
| ★**未踏帯**★ | ★EXE image(`0x80090800..0x8013E000`)より**下**★ / 確度のある呼び先 ★**16 個**★(`0x8005E934` / `0x80060E70` / `0x80065C7C` / `0x8007257C` / `0x8007A758` / `0x80081ECC` / `0x80086678` / `0x800869DC` / `0x80086AF4` / `0x80086C7C` / `0x80086DB4` / `0x800871B4` / `0x800873E8` / `0x80087580` / `0x80087844` / `0x80087C00`)＋ `0x8007D8D4` | ★**VM step 本体 `fn 0x800F027C` が 12 本**★ / `0x800CD6BC`(item 11・12 = 再生系)2 本 / `0x8011935C`(item 15〜21 = プラグイン)10 本 | ★**未踏**★(kernel / BIOS / overlay の**どれかは決めない**) |

- ★**「穴」ではなく「未踏の領域」**★ — 我々の器が誤っているのではなく、★**そこを一度も見ていない**★。
- ★**VM の動作そのものがこの帯に依存している**★(`0x800F027C` から 12 本)⇒ ★VM の完全な記述は image 内では閉じない★。
- ★**実務上の要点: item 22(オートパイロット)は外向き 0**★
  ⇒ ∴ ★**本日の結論(オートパイロット → 1245 → 街の変種)は未踏帯に依存しない**★ = 実装対象は安全。
- ★影響を受けるのは item 11・12(再生 / 超再生フロッピー)と item 15〜21(プラグイン)の**効果の中身**★
  ⇒ これらを実装するときは ★**image 内だけでは決まらない**★ ことを先に申告する。
- 併記: ★「閉じている」は**即値 jal の範囲で**閉じている★ — ★jalr 98 件と表引き(`jr`)は端の判定にも入っていない★。

### ★訂正(15:3x) — 「未踏」ではなく ★overlay(常には存在しない)★ (PRESIDENT (1809)、実測)★
判別子 = ★`jr ra`(`0x03E00008`) の件数★ / 器 = PRESIDENT の python / 原物 = savestate 12 本 ＋ live

| 範囲 | 状態 | 件数 |
|---|---|---|
| ★未踏帯 `0x80050000..0x80090800`(258 KB)★ | slot 4(FRZL17) | ★120★ |
| 〃 | slot 5(GIAS06B) / slot 6(MAYO01) | ★65 / 65★ |
| 〃 | ★他 9 状態(TWNA01 / TWNA13 / MGEN98 / MIST04 …)＋ live★ | ★**全部 0**★ |
| 対照 = EXE 本体 256 KB | 全 12 状態 | ★**699(不変)**★ |

⇒ ∴ ★**状態によって code が在ったり無かったりする = overlay(実行時に積む)**★。
⇒ ∴ ★**EXE image に無いのは「見落とし」ではなく「そもそも入っていない」**★
   ⇒ ★**静的走査では原理的に届かない**★。∴ 表記を ★「未踏」→「EXE の外に実体が在る」★ に改める。
⇒ ∴ ★**但し手は在る**★ — ★code が載っている状態が 3 本(slot 4 / 5 / 6)★ 手元にあり、
   ★slot 4(`jr ra` 120 = 最多)から overlay を切り出して逆アセンブルできる★
   = ★**「届かない」が「届く」に変わった**★。
⇒ ∴ 整合: ★index 13 が flag で image 内 / 外に切り替わる「兄弟」★ = ★**同じ処理の 2 版で、片方が overlay**★。
⇒ ∴ 不変: ★**item 22 はこの表を通らない ⇒ 実装対象は端に触れない**★。

## 2026-08-15 追加(5) — ★原盤には script の外に「native code の event 処理」がある★
**出所**: worker2 `8e34a4b`(overlay slot4 / slot5 の逆アセンブル) / 器 = worker2 の decoder
★陽性対照: 同 decoder を EXE image に当て、core 命令 43 種・**111,598 語で capstone と食い違い 0**★

- ★**base `0x80050000` は正しい**★ — 17 呼び先のうち ★**10 個が `addiu sp,sp,-N` にちょうど命中**★(偶然では起きない)
  ・1 個(`0x80081ECC`)は ★関数の頭ではなく、`beq` の遅延 slot の nop★
  ・6 個(`0x8005E934` / `0x80060E70` / `0x80065C7C` / `0x8007257C` / `0x8007A758` / ★`0x8007D8D4`★)は ★この 2 版では **data**★
    ⇒ ★別の場面の overlay に在る公算だが**決めない**(④)★
- ★**10 個の関数は何か**★ = ★「場面ごとの event 処理を native code で書いたもの」★(worker2 の命名、原盤の呼び名ではない)
  ・10 個とも同じ形 = ★入口で `lhu [gp-0x6caa]` を読み `sh` で書き戻す(段階 counter)★・終盤で `[gp-0x6c9c]` / `[gp-0x6c90]` を書く
  ・★**呼ぶ相手が script の helper と同じ顔ぶれ**★ = `SetFlag 0x800F0F1C` / `GetFlag 0x800F0C74` / var 配列 `0x800F0CD0` /
    loader `0x800F0988` / section lookup `0x800F0A4C` / ★在庫 加算 `0x800CE348`★ / ★在庫 減算 `0x800CE5B4`★
  ・例: `0x80081ECC` 近傍は ★flag 5..13 を順に GetFlag し、全部立っていれば SetFlag(14)★
- ★**2 版は別物だが、この 10 個は共通部にある**★ — byte 差 74.9% / ★byte 完全一致 `0x80081000..0x80087FFF` の 28KB ほか 3 帯★

### ★remake への含意(gap)★
★**remake は `DG.SCN` の script しか実装していない**★。原盤にはそれと**並んで** ★native code の event 処理★ があり、
同じ flag / var / 在庫を触る。⇒ ∴ ★**script を完全に実装しても、この層の挙動は出ない**★。
★分類 = 機構ごと欠落(未着手)★ / ★影響範囲は未測定(2 版しか見ていない)★。

### ★下界宣言が実測で埋まった例(記録)★
worker2 が #553 で ★「在庫減算 `0x800CE5B4` の呼び元 = image 内 8 site(★下界★)」★ と書いていたところ、
overlay から ★**4 site(`0x80082B6C` / `0x80082E28` / `0x800830C8` / `0x80087A74`)**★ が出た
⇒ ★**8 → 12 以上**★(他の場面の overlay にさらに在り得る)。同様に 加算 +5 / SetFlag +3 / GetFlag +3 / var 配列 +16(slot4)・+13(slot5)。
⇒ ∴ ★**(B) 下界の判定は正しく、かつ実際に埋まった**★ — 下界と書いておくと、後から**足せる**。
