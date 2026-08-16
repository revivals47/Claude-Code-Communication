# ★この dir は 破棄された 試行の 残骸です（★中身に 値打ちは ありません★）★

worker3 / #442-C の 途中で 作り、★受理条件の run には 使っていません★。

## なぜ残っているか

★`rm` を 出したところ 器（permission prompt）が 止めました★。
boss1 の 裁定 = ★消す理由が「前回の残骸と混ざる」なら ★混ざらない場所★ で 解決する★
⇒ ★★新 dir（`w3_gateflip_2026-08-16`）に 書き直し、この dir は ★消さずに 残しました★★。

## 中身（★2 本とも 破棄★）

| file | 何か | なぜ破棄か |
|---|---|---|
| `F1_default_on_tile51.log` | 初回の F1 試行 | ★`DEGIMON_FIELDSCRIPT=1` を 誤って 付けた★ ⇒ `this map has no script trigger tile(81-86)` で 即 Quit |
| `F1_default_on.log` | 2 回目の F1 試行 | ★`DEGIMON_AUTOBOOT_SEC` 未設定★ ⇒ ★既定 3.3s で 終了★ し tile 51 に 届かず |

★★どちらも 受理条件の 判定には 使っていません★★。
★正の証跡★ = ★`../w3_gateflip_2026-08-16/`★（README ＋ log 7 本）。

## ★この dir が 教えていること★

★log が 在るのに README が 無い dir は、後世が 「証跡」と 誤読します★
⇒ ★★破棄した 試行にも 1 枚 置く★★（★消すより 安い★）。
