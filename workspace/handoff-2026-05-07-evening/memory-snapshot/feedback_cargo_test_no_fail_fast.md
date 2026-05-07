---
name: cargo test 数値は --no-fail-fast 付きで報告する
description: 2026-04-28 教訓。`cargo test` は最初の bin 失敗で停止するため部分カウントになる。`cargo test --all-targets --no-fail-fast` で全 bin を走らせた数値が真の品質根拠
type: feedback
originSessionId: 894b93ff-e8db-4f9b-a616-814f85ab325c
---
cargo test の数値を品質根拠として報告するときは、必ず `cargo test --all-targets --no-fail-fast` で全 bin を実行する。

**Why:** 2026-04-28 GUI_kit プロジェクトで worker2 と worker3 が main の同一 commit に対し別々の数値 (1187 / 1179 / 1281) を報告し、退行を疑う騒動になった。原因は worker2/worker3 が `cargo test` (--no-fail-fast なし) を使っており、最初に失敗した bin で停止して残りの bin が走らないまま部分カウントを集計していたこと。worker3 が --no-fail-fast 付きで再計測したら 1286 passed / 0 failed / 5 ignored で healthy、退行ではなく計測手順差だった。

**How to apply:**
- worker への計測指示テンプレートに必ず `cargo test --all-targets --no-fail-fast` を含める。`cargo test` 単体は禁止
- worker からの報告で『passed / failed / ignored』の 3 連数値が揃っていない場合は --no-fail-fast 付きで再計測を求める
- bin 数や test 構成が違う複数 worktree 間で数値比較するときも --no-fail-fast を統一基準にする
- CI 不在 (revivals47 GitHub Actions クレジット切れ) のためローカル cargo test のみが品質根拠 → 計測精度の差は致命的、規範化必須
