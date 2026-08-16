# 保全の突合（全 dir）— ★`git status` では判らないことを 器で出す★（worker3 / #445-C ①）

## 0. ★なぜ `git status` を使ってはいけないか（今日の実例）★

★CCC の `.gitignore:3` が `*.log`（＋ `*.txt`）★
⇒ ★★ignore された file は `git status` に `??` としても 現れません★★
⇒ ★★「status が clean」は「保全されている」を 意味しません★★
★実例★ = before/after の run log 14 本が ★status では 見えないまま 未追跡★ だった。
保全には ★`git add -f`★ が要り、★保全済かどうかは status からは 誰も 知り得なかった★。

⇒ ★★remedy（以後の既定）★★ = ★`git ls-files <dir>` と ★実在数★ の 突合★
⇒ ★器にしました★ = `degimon_world_remake-p2w3/workspace/tools/★w3_preserve_audit.sh★`
　（`<repo_root> --under <parent>` で 親直下の 全 dir を 一括）

★★器は 良し悪しを 決めません★★ = ★数を 出すだけ★。
∵ ★慣行 =「log は 追跡しない・README が 証跡」★ ⇒ ★★差が 在るのが 既定★★
⇒ ★判定は 「★意図した差か★」★ = 人の仕事（下記 §2）。

## 1. ★実測（CCC / `measure_logs` 配下 全 dir）★

| dir | 実在 | tracked | log 実在 | log tracked | 判定 |
|---|---|---|---|---|---|
| `measure_logs`（直下） | 5 | 1 | 4 | 0 | ★意図した差★ |
| `w3_flip_2026-08-16` | 2 | 0→★1★ | 2 | 0 | ★★意図しない差 → 本便で閉じた★★ |
| `w3_gateflip_2026-08-16` | 8 | 1 | 7 | 0 | ★意図した差★ |
| `w3_h1_h8_after_2026-08-16` | 8 | ★8★ | 7 | ★7★ | ★一致（例外・保全済）★ |
| `w3_h1_h8_before_2026-08-16` | 9 | ★9★ | 7 | ★7★ | ★一致（例外・保全済）★ |
| `w3_handoff_444c_2026-08-16` | 2 | 1 | 1 | 0 | ★意図した差★ |
| `w3_handsets_2026-08-16` | 8 | 1 | 7 | 0 | ★意図した差★ |
| `w3_implops_2026-08-16` | 4 | 1 | 3 | 0 | ★意図した差★ |

## 2. ★判定の理由（★1 行ずつ★）★

・★`measure_logs` 直下 / `w3_gateflip` / `w3_handoff_444c` / `w3_handsets` / `w3_implops`★
　= ★慣行どおり log 非追跡・README が tracked★ ⇒ ★★意図した差★★。
・★`w3_h1_h8_before` / `after`★ = ★③ を正当化する唯一の実物ゆえ ★慣行の例外★ として保全済★
　（PRESIDENT `d4670ed`・★`git add -f` が要った★）⇒ ★意図した一致★。
・★★`w3_flip_2026-08-16` = ★意図しない差★★★ = ★破棄した試行の残骸に README が無かった★
　⇒ ★★log が在るのに README が無い dir は 後世が「証跡」と誤読します★★
　⇒ ★`rm` せず（boss1 裁定）★ ★README を 1 枚置いて閉じました★（本便）。

## 3. ★p2w3 側（`workspace/w3_remake`）★

| 項 | 値 |
|---|---|
| 実在（直下） | 578 / tracked 518 ⇒ ★差 60★ |
| 実在 `.log` | 200 / tracked `.log` 140 |
| ★`.gitignore` が無視している `.log`★ | ★★60★★ |

⇒ ★★差 60 = 無視 60 と 完全一致★★ ⇒ ★★意図した差★★。
⇒ ★台帳 `README_LOGS_UNTRACKED.md` は tracked（1）★ = ★33 本の sha256 と 引いた線が残っている★。
　（60 = ★既存 rule 27（`build*` / `hf` / `live*`）★ ＋ ★#435-C で私が足した 33★）

## 4. ★この突合が見ていない場所（母数の申告）★

1. ★再帰しません★（sub dir は `--under` で展開）。
2. ★中身は見ません★ = ★同名で内容が違っても「一致」と出ます★（同一性は sha256 で別に）。
3. ★`measure_logs` 以外の dir は本便の対象外★（`workspace/degimon-faithful178/` 直下など）。
