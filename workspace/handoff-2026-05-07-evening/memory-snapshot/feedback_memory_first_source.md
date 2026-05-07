---
name: 一次ソースとしての project memory を初手で確認する
description: 2026-04-28 教訓。クラッシュ復帰 / 認識合わせ / 候補列挙が必要な場面で、自前 grep より先に project memory (MEMORY.md + 関連 .md) を Read して既存の一次データを取り込む
type: feedback
originSessionId: 894b93ff-e8db-4f9b-a616-814f85ab325c
---
クラッシュ復帰や状態認識合わせ、候補列挙（dogfood crate / Track 進捗 / canonical baseline 等）が必要な場面では、**自前 grep / find より先に project memory を Read** して既存記録を一次ソースとして取り込む。

**Why:** 2026-04-28 GUI_kit Track 7-C 復帰中、boss1 が dogfood 候補を grep で 6 crate と認識し PRESIDENT に確認質問した。実際は project memory project_gui_kit_reliability.md line 39 に dogfood 全 8 件が明記されており、PRESIDENT 側で memory + filesystem 直接確認した結果 8 件正しいと判明。boss1 自身が後で「memory line 39 を初手で読まなかった規律違反」と自己反省。一次ソースを後回しにすると（a）誤った数値で確認往復が発生（b）user / PRESIDENT に修正コストを押し付ける（c）feedback_rfc_data_sources.md の RFC 版と同型の規律違反になる。

**How to apply:**
- 復帰直後 / 認識合わせ直前 / 候補列挙の前に、`Read` で MEMORY.md → 関連 project memory `.md` を必ず通読
- memory に該当記述があれば一次ソースとして取り込み、`grep` / `find` は cross-check 用に降格
- memory 記述と現実 (filesystem / git) が乖離している場合は memory 側が古い可能性 → memory 更新候補としてマーク
- 関連: feedback_rfc_data_sources.md（上位提供 grep を一次ソース）、feedback_rfc_deliverable_check.md（RFC deliverable 機械的検証）と同じ「一次ソースを最初に見る」族の規律
- 復帰時は特に重要: 短期記憶を失った状態で memory を読まずに grep から始めると、project state を誤認識したまま判断を進めるリスクが高い
