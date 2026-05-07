---
name: scope 不確実な作業は計測ファースト → 多択提示で boss/user 相談
description: 当初 scope の規模が見積もれない作業に着手する前に、まず計測 (lint 一時投入 / 数値取得) で現実の規模を確定し、当初計画と乖離する場合は silently 縮小せず multi-option で boss/user に再相談する。2026-04-28 PRESIDENT validated。
type: feedback
originSessionId: a53a8743-d38b-4b28-8849-f368d6b3e4f3
---
当初 scope の規模が見積もれない作業 (lint gate 本番化 / refactor 範囲 / 移行影響範囲など) では、着手前に計測ファースト (lint 一時投入 / cargo doc 数値 / src grep) を実施して現実規模を確定する。当初 scope と乖離する場合は silently 縮小も silently 拡大もせず、3 択ほどの multi-option を整理して boss/user に再相談する。

**Why:** 2026-04-28 Track 6 Phase 3-4 commit 3 で「missing_docs gate 本番化」を当初 commit 計画に含めていたが、lib.rs に #![warn(missing_docs)] を一時投入して計測したところ ~1480 件の warning が露出。20-40min の commit 3 では到底吸収できない規模。silently 縮小すれば spec 違反、silently 拡大すれば数時間〜数日の超過。3 択 (gate 見送り / scope 縮小 deny / per-module gate) を提示して boss1 に判断を仰ぎ、B 案 (broken_intra_doc_links のみ deny) で確定。PRESIDENT は事後評価で「計測ベース scope 再定義として承認、sneak follow-up 該当せず」「計測 → 設計判断のループ規範として優秀」と statement 化。

**How to apply:**
1. scope 不確実な作業 (gate 化 / 全削除 / 全移行) は着手前に「現実の規模を数値で出す」一時計測を 5-15min かけて実施
2. 当初計画と 2x 以上の乖離があれば、silently 進めず 3 択ほどの option を整理して相談
3. 計測のための一時投入 (lib.rs への #![warn] / Cargo.toml 書換等) は必ず revert を計測直後に実行、計測コードを WIP に混入させない
4. boss/user への相談メッセージには (a) 計測数値の根拠 (b) 当初 scope との乖離量 (c) 推奨案 + 理由 を含める
5. 最終 commit message / PR description / CHANGELOG / ROADMAP に「deferral がある場合の理由と将来 track」を 3 箇所以上で一致させ、'sneak follow-up ではなく deliberate scope decision' のフレーミングを徹底
