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

> ### ★★★訂正 — ★上の判定は 2 つの主張に割れ、片方は測定でない★(2026-08-16 / worker3 が生 log 直読・boss1 追認)★★★
> ★**測定である部分**★ = ★(A) の `WARP_PENDING` **0 件**★ / ★ctl_run も **0 件**★ / ★(B) は `B_run:140` で **counter=20 で fire**★
>   ⇒ ★「20 周の待ちが auto-warp にも付く」の**否定は成立**★（★`WARP_PENDING` の有無は log に在る★）。
> ★**測定でない部分**★ = ★**「(A) は次 tick」**★ ⇒ ★★3 本とも **frame 番号を 1 行も持たない**★★（★`frame=` が A / B / ctl とも **0 件**★）
>   ⇒ ∴ ★★「直後に fire」は **log 行の隣接からの推論**であって **frame の測定ではない**★★。
> ⇒ ∴ ★**上の「分離は実測された」は、分離の片側だけを指すなら真**★ — ★★`WARP_PENDING` の有無では分離、**tick 数では未測定**★★。
> ⇒ ∴ ★型★ = ★★**log 行が隣り合っていることは「同じ frame」でも「次の frame」でもない**★★
>   = ★★**時間の主張には時間の目盛りが要る**★★（★行の順序は目盛りではない★）。
>   ⇒ ★∴ 器の側の remedy = ★`[WARP] queued` / `fire` に **frame 番号を印字**★（worker3 が撮り直しで足します・★挙動 code は変えない★）。
> ⚠ ★`(B)` の **counter=20 で fire** と、worker3 の doc の「**21 tick 目**」の ±1 は ★**未決**★★ — ★実装を読んで確定させます★（★今はどちらとも言いません★）。

⚠ この branch は**実測専用**であり統合の成果ではない（main に入れない）。gate 3 つの既定値は不変。
