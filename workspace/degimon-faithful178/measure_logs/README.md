# 実測 log 3 本（PRESIDENT #449 の 証跡）

- **build sha** = `901efaad` / worktree `degimon_world_remake-integ` / branch `track/measure-fade-tile`
- **地図** = mayo00 / **枠** = 同一 build・同一 env・★別 run★（tile 51 と tile 110 は 20 周では届かない距離）

| file | env | 撮れたもの |
|---|---|---|
| `B_run.log` | TILE_5179=1 + WARP_EMIT=1 | tile 51 → 0x4B → WARP_PENDING → counter 10 → 20 で fire → TWNB01 |
| `A_run.log` | 同上 | tile 110 → queued → ★直後に fire★ / WARP_PENDING **0 件** |
| `ctl_run.log` | なし（対照） | tile 110 → 直後に fire / TILE5179 **0 件** / WARP_PENDING **0 件** |
| `build_integ.log` | — | BUILD-GUARD PASS / result=Succeeded / errors=0 |

★判定★: 同じ build で **(A) は次 tick・(B) は 20 周後** ⇒ 分離は実測された。「20 周の待ちが auto-warp にも付く」は**否定**。

⚠ この branch は**実測専用**であり統合の成果ではない（main に入れない）。gate 3 つの既定値は不変。
