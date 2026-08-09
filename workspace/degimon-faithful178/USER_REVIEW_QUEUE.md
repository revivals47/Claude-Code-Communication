# USER REVIEW QUEUE — user復帰時に順に視覚gateすべきdeliverable (worker3, 2026-07-24)

user復帰時、この順で1passで視覚確認いただくと全arc gateが揃う。各項目=render path + sha256(先頭12) + 確認してほしい1点。
全て `workspace/degimon-faithful178/` 配下。

## 優先1: facing村 (前回queue先頭=user『全員後ろ向き』feedback対応)
- **village_faithful_facing.png** `732a630ec3c6`
  - 確認: 各NPC(TOKO/YURA/TANE)が★原盤同様の向き★を向くか(全員後ろ向き解消)。原盤照合=facing_convention_lock.png併用。
- 参考 village_reframe.png `24e923d4a70d`(色fix後全景、TOKO白+3種+boy)、facing_convention_lock.png `2f3b50a4d53d`(Toko tilt原盤 vs direct/flip)。

## 優先2: gallery 136 distinct-appearance model (全distinct見た目網羅)
- **gallery_INDEX_136models.png** `73be582f7eeb` = ★9 batch一望index(まずこれ)★
  - 確認: 全体として★灰青washout/破損modelの混入が無いか★、canonical色で3D化されてるか。
- 個別sheet(気になれば):
  | sheet | sha | 内容 |
  |-------|-----|------|
  | gallery_baby_tier.png | `02a64b076d71` | baby 4種 |
  | gallery_champion_tier.png | `5c3594d139bf` | champion 12種 |
  | gallery_batch2_champ_ultimate.png | `87c680d7ea70` | champ/ultimate 14種 |
  | gallery_batch3_modelonly.png | `cb9cefa11ae2` | bulk 20種 |
  | gallery_batch4_modelonly.png | `ddb137c001de` | bulk 20種 |
  | gallery_batch5_modelonly.png | `8c37e575e3f5` | bulk 20種 |
  | gallery_batch6_modelonly.png | `1029bce7c878` | bulk 20種 |
  | gallery_batch7_modelonly.png | `9edf08c89f1e` | final 14種 |
  | gallery_variants12_newlook.png | `4681d6badfb2` | variant new-look 12種 |

## 優先3: honest gap確認 (数値の正確性)
- **HONEST_GAP_LEDGER.md** = 6次元到達点。特に確認:
  - scale=native-uniform interim(faithful93%)で許容か、精密化要か(要なら優先4)。
  - 「136 distinct完成、43=stat変種視覚複製で不生成」の判断が妥当か。

## 優先4(user操作要): 深RE 2前線のunblock (任意、精度up)
- placement(全map配置)/faithful scale精密化 = ★user が DuckStation(EnableGDBServer=true)+game走行させれば、非対話gdb scriptでtrap PC取得可★。
  - 手順: **WATCHPOINT_gdb_procedure.md** 参照。H4-i savestate依頼と同枠。
  - これが済めば: 全map faithful placement + 完全faithful scale が自律で進行可能に。

## 現状の到達点(1行)
★全distinct appearance(136 model)を canonical色+form+facing(村)で3D化完成。残=全map placement/完全scale(=watchpoint、user-session gated)。★
