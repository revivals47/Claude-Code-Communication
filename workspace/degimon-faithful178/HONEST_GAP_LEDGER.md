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
