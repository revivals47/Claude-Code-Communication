# track-golden-rebless step 1 — PC 切り分け finding (worker2)

base: track-golden/rebless @ origin/main 64fb117 起点
worktree: ~/Documents/GUI_kit-track-golden
date: 2026-05-07

## (1) PR #70 メタデータ (re-bless 経緯)

| field | value |
|---|---|
| PR number | #70 |
| title | Track Q4 (a): re-bless win10/win95 widget goldens after intentional paint changes (5 cases) |
| merged at | 2026-04-28T15:33:58Z |
| merged by | revivals47 |
| merge commit | e0aee3f |
| single commit | f4d563e |
| author/committer | revivals47 (revivals47@yahoo.co.jp) |

PR #70 commit message に当時の bless 前 delta が記録されている (worker2 の現観測と比較する基準値)。

## (2) bless 前 数値 (PR #70 commit f4d563e より) vs work-PC tlcr 現観測

| consumer | PR #70 bless 前 | work-PC tlcr 現観測 | 一致 |
|---|---|---|---|
| label_default_win10        | 314 px / max delta 255 | 314 px / max delta 255 | ✅ |
| button_default_win10       | 124 px / max delta 178 | 124 px / max delta 178 | ✅ |
| vstack_default_win10       |  58 px / max delta 178 |  58 px / max delta 178 | ✅ |
| window_frame_default_win10 | 637 px / max delta 192 | 637 px / max delta 192 | ✅ |
| window_frame_default_win95 | 198 px / max delta 250 | 198 px / max delta 250 | ✅ |

**5/5 完全一致**。work-PC tlcr の rasterizer は安定して PR #70 bless 前と同 pixel を生成 = bless は別 env (高い確度で home-PC ken) で実行され、bless 後の golden は home-PC env でしか mismatch=0 にならない。

## (3) work-PC tlcr env factor (取得済)

| factor | value |
|---|---|
| rustc | 1.94.1 (e408947bf 2026-03-25) |
| cargo | 1.94.1 (29ea6fb6a 2026-03-24) |
| LANG | ja_JP.UTF-8 |
| LANGUAGE | ja_JP:ja |
| XDG_SESSION_TYPE | wayland |
| WAYLAND_DISPLAY | wayland-0 |
| XDG_CURRENT_DESKTOP | ubuntu:GNOME |
| fc-match sans-serif | NotoSansCJK-Regular.ttc / Noto Sans CJK JP / Regular |
| fc-match monospace | NotoSansCJK-Regular.ttc / Noto Sans Mono CJK JP / Regular |
| GPU | NVIDIA GeForce GTX 750 (rev a2、Maxwell GM107) |
| Vulkan SDK / runtime | **不在** (vulkaninfo / vkcube / libvulkan dpkg いずれも不在) |
| OS | Ubuntu (LSB 経由で詳細確認可) |
| Linux kernel | 6.11.0-17-generic |

## (4) ssh / home-PC ken アクセス可否

| 試行 | 結果 |
|---|---|
| ~/.ssh/config | **不在** (memory 上 "ssh alias 整備 optional" 通り) |
| ssh ken | name resolution 失敗 |
| ssh home-pc | name resolution 失敗 |
| known_hosts エントリ数 | 3 (過去接続あり、ken 含むかは不明) |

→ worker2 から home-PC ken 直接 reach 不能。home-PC 再現確認手段:
- (i) worker3 経由 (現在 worker3 が home-PC で Stage 3 進行中)
- (ii) schedule 経由 (cron / 別 PC ログイン)
- (iii) ssh alias 整備依頼 (ユーザー確認要)

## (5) 暫定結論

- worker2 の現 work-PC pixel mismatch は PR #70 bless 前 delta と完全一致 = bless が work-PC では機能していない
- bless 行われた env (= home-PC ken の確度高) と work-PC tlcr で安定的に異なる pixel 生成
- これは memory `reference_dual_pc_setup.md` の multi-env 反証懸念が現実化した状態
- env-specific bless 採用方針 (PRESIDENT step 4) の重要 evidence:
  - 候補 (a) lenient threshold = mismatch 許容、test sensitivity 低下
  - 候補 (b) env-specific golden subset = 両 PC 緑、ただし dual golden 管理コスト
  - 候補 (c) work-PC 系 default 再 bless = work-PC 環境で再 bless、ただし home-PC で再度 mismatch 循環
  - 候補 (d) home-PC 系 default 維持 = PR #70 状態 hold、work-PC 側で env 揃える別アプローチ

## (6) 重要制約 (worker2 self-imposed)

work-PC tlcr で `GOLDEN_BLESS=1` 実行禁制 (step 4 PRESIDENT 判断前)。実行すれば home-PC bless を上書き → 候補 (c) 強制実装になり選択肢が潰れる。

## (7) step 2 transit plan (boss1 GO 待ち)

step 2 = pixel mismatch root cause 特定:
- 取得済 work-PC env factor を比較基準として home-PC env factor 取得 (worker3 経由 or schedule)
- factor delta 列挙 (font / GPU / driver / Vulkan / locale / rustc / compositor)
- 5 件 mismatch のうち pixel 数最大 (window_frame_default_win10 = 637 px) を切り分けピボットに使う

step 2 の cargo 利用は cargo check のみ、cargo test は OOM タイミング分散のため boss1 明示 GO 後。
