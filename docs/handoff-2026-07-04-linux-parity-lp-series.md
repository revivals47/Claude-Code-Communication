# Handoff 2026-07-04 — home-PC: testruct 公開イニシアチブ始動 + LINUX_PARITY LP シリーズ全 CRITICAL land

testruct 公開イニシアチブ (全国の教員向け、3 OS 同時、ジョブズ思想) の初日。ファイル互換監査 → stale 前提事故と全面訂正 → Linux 版の Mac 追いつき (LP-1〜R2) を一気通貫で land。

## §A. 確定した前提 (恒久、memory `project_testruct_public_release`)
- **開発フロー**: Mac (MacBook Air M1 = user メイン機) が常に最先端 → Win が継承 → Linux が dogfooding で追う。**正典は常に Mac (testruct-v3 master)**。
- **公開形態**: 3 OS 同時。各 OS の機能差は許容、**「どの OS で作ったファイルも開ける」が絶対要件**。
- GTK 版 2 本は完全廃止 (仕様参照のみ)。
- **方針の合言葉** (user の WINDOWS_PARITY_TODO より): 「未知値で全体を壊さない・未知は既定へ・既知は保持」。

## §B. ⚠️ 教訓: stale 前提事故 (午前)
local testruct-v3 を fetch せず 16 コミット遅れのまま監査 → 「Mac が遅れている」と誤診し、誤った Swift パッチ (branch `feat/format-compat-catchup`、**local のみ・push 禁止・退避中**) を作った。user の一言「Mac が常に最先端」で発覚。→ **監査/dispatch 前に対象全 repo を fetch、特にマルチマシン repo (testruct-v3)**。[[feedback_dispatch_premise_stale_after_bulk_merge]] 第2実例。
- サルベージ価値が残る部品 (stale branch 内): TestructCore の Linux ビルド化 (canImport os.log/CoreGraphics ガード、CZlib system-library、Package.swift resources) / クロス fixture 手法。**Swift 6.0 toolchain は導入済で恒久資産** (`source ~/.local/share/swiftly/env.sh`)。

## §C. 本 session の land (hayate-kit-testruct main、全 push 済)
再監査 (実 heads: Mac f89a9f9 ↔ Rust 4ea5abf、双方向) → `docs/LINUX_PARITY_TODO.md` 新設 (Win 版の姉妹編) → CRITICAL 全件対応:

| commit | 内容 |
|---|---|
| `ae43a17` LP-1/2/3 | 下線ファミリー3フィールド + Plot v2 (series/annotations/label/ticks/equal_aspect) の**保持**。idgen 新設 (UUIDv4=/dev/urandom + ISO8601 civil-from-days、依存ゼロ) で全 id 発行を UUID 化 + `normalize_for_save()` 安全網。契約テスト mac_parity.rs 8本 (ワイヤ名は実 master Swift へ直 grep 裏取り) |
| `53c82bf` LP-5 | **画像 asset が Linux の Open/Save で全消失**していた重大バグ修正 (Open が asset を捨て Save が空書き)。ImageStore に assets()/replace_assets()、往復テスト |
| `b7c9061` LP-R1a | 下線 Double/Wavy + run 上書きの**描画** (screen+PDF、Mac WavyUnderlineRenderer 定数準拠)。span 連結が underline_style 非比較で上書きが消えるバグも発見修正。PNG/pdftoppm 目視済 |
| `89bca13` LP-R2 | Plot v2 の**描画** (render_plot = core painter 非依存 → screen/PDF/SVG 一括)。ガター 26/16/6、equal_aspect=共有スケール中心拡張、nice step、マーカー r=max(w+1,2)、注記、凡例 (clip 外遅延)。目盛数値は U+2212 (ASCII '-' は UAX#14 改行機会で "-1" が割れる)。PNG 目視済 |

341 tests green。testruct-v3 local は f89a9f9 に更新済み。

## §D. 分担と次アクション
**「足並み」= コードの pull ではなくワイヤ互換。** Linux は本日で Mac の最新ワイヤに追いついた。
- **user @ Mac**: LP-4 = `ShapeElement.rotation` を Mac に採用 (裁定(a)。唯一 Linux が先行していた項目。decode 寛容 + レンダラ)。**Mac での pull は不要** (こちらから testruct-v3 へは何も push していない)。
- **user @ Win PC**: `testruct-v3` を **pull してから** 既存 WINDOWS_PARITY_TODO の CP-1 (下線3フィールド) 対応。
- **次 session @ この機**: ①LP-R1b 縦書き傍線 (縦書きペインタは下線自体未実装、機能追加として) ②Swift core Linux ビルド化を実 master に再適用 → クロス実装 round-trip テストの CI 土台 ③P0-2 = バージョンフィールド + 未知要素の raw 保持を 3 実装で統一 (恒常的に遅れる側の最強保険) ④Phase 1 = 公開品質ギャップ棚卸し (GTK v2 README を要件リストに採掘)。

## §E. 前日分の残 (handoff-2026-07-03b より)
gamma default 化 dogfood / vk_blur・Color::lerp follow-up / SDF 後の各アプリ再ビルド dogfood / #315 font golden work-PC 検証。

## §F. memory mirror
`project_testruct_public_release` (中核、全状況) / `reference_guikit_gamma_pipeline` / `reference_guikit_sdf_large_text_blur` / `feedback_hayate_vs_gtk_live_compare`。
