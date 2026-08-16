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

~~⚠ この branch は**実測専用**であり統合の成果ではない（main に入れない）。~~ gate 3 つの既定値は不変。

> ### ★★★訂正 — ★この札は実体と合っていませんでした★（2026-08-16 19:4x / PRESIDENT 裁定 (甲)・boss1 実行）★★★
> ★書かれた時点★ = `901efaad` は base +1 commit で、★本当に 1 回の実測のためのものでした★。
> ★現況の実測★ = `main..track/measure-fade-tile` = ★614 commit★。★TILE_5179 既定 ON / AVATAR_MODE 既定 ON / latch 撤去 / yaw / unlit★ を抱え、
> ★★user が実視覚で PASS した 2 件（TWNB01 到達 / BOYS 3D）の唯一の実体★★ がここに在ります。
> ⇒ ★★現況の札 = 「事実上の統合 branch」★★。★実測専用ではありません★。
> ⇒ ★★かつ ★複製が 1 つしか無い★★★ = remote branch 14 本のどれにも含まれない（`git branch -r --contains f5924776` = 0）。
> ⇒ ★★∴ delete / reset / rebase / worktree remove をしない★★。★merge は別便★。★push は user の判断★。
> ⇒ ★型★ = ★★札は書かれた時点の実体を指す ⇒ ★実体が育っても札は育たない★★★
>   = ★★「remedy の status を doc に持たせない」の ★branch 版★★★（★status でなく ★数を器で引く★: `git rev-list --count main..<branch>`）。
