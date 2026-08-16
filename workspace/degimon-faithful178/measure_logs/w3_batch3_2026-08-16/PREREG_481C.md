# ★#481-C 事前登録★（worker3）— ★3 つ ON の 画・撮る前に 書きます★

## env（★`[RUNBY]` に 全部 印字されます★）
```
DEGIMON_BOOT_MAP=twna01（★intro 後 session は topn01 に なります★ = 実測済）
DEGIMON_FIELD_MODELS=1 / DEGIMON_VISE_VILLAGE=1 / VISE_NPC_MODE=on
VISE_AVATAR_MODE=（未設定 = 既定 ON）
★DEGIMON_VISE_VILLAGE_MAP=topn01★ ← ★明示します★
  理由 = ★帰属は 突合で twna01 と 決まりました★ が ★session map は topn01★ ゆえ、
        ★既定（twna01）のままだと 村人は 1 度も 置かれません★。
        ⇒ ★★画を 撮るために 明示的に 上書きします（★隠しません★）★★
DEGIMON_VISE_SHOT_AT=20,34（★直した 撮影器で 2 枚★）
```

## ★予想（★撮る前に★）★

| # | 予想 |
|---|---|
| ★P1★ | ★村人 = 3 体 置かれる★（`village place` = 3 行） |
| ★P2★ | ★`FIELD_MODELS` 由来 = twna01 の `digimon` 7 件 のうち ★code 表で 引けた分★★（★数は 撮る前に 数えていません = 撮って 数えます★） |
| ★P3★ | ★boy が 3D で 立つ★ |
| ★P4★ | ★despawn = 0 行★（★同じ map に 居続けるため★） |
| ★P5★ | ★2 枚とも 撮れる★（`two.png` / `two_1.png` 相当） |

★★P2 の 数を 先に 埋めません★★ = ★prefab が 引けるかは code 表次第で、私は まだ 数えていません★。

## ★外れたら 前進★
・★P1 が 0★ ⇒ ★`DEGIMON_VISE_VILLAGE_MAP` の 上書きが 効いていない★
・★P4 が 1 以上★ ⇒ ★session map が 撮影中に 変わっている★（= ★私が 掴んでいない 遷移★）
