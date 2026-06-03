---
name: feedback_verify_reused_mechanism_behavior
description: design が既存 mechanism (cache/generation/feature/macro/API) を reuse/extend すると言う時、その mechanism の実挙動を code/docs で ground せよ。stated intent を approve しない
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 3dbf9b0d-04e8-41e9-b05e-d813a6c036ca
---

設計レビューで、draft が「既存の X (cache / generation 機構 / library feature / macro / API) を reuse/extend してこの目的を達する」と述べる時、★X の実際の挙動を code/docs で ground してから approve する★。draft の stated intent (「X でこうなるはず」) を鵜呑みにしない。reuse される mechanism が intent と違う挙動をすると、設計が静かに壊れる。

**Why:** 2026-06-03 に複数 incident で繰り返し発覚 (boss1 + PRESIDENT 双方が複数回 lapse):
- PDF viewer zoom-key: draft「DecodeService の generation で zoom 後 stale bitmap 破棄」→ 実は `get_or_request` は id で完了結果を先に返し `bump_generation` は **completed を cache 保持 (pending のみ prune)** = zoom 後も stale 返却、rerender 非 dispatch。generation の実挙動を ground せず intent approve した miss。fix=id に zoom encode。
- PDF off-thread rasterize: draft「pdfium thread_safe で worker が doc から render」→ thread_safe は **call を mutex 直列化するのみ**、Send/Sync は別 feature (sync, 'use at your own risk')。feature の実挙動を ground せず impl-detail に defer した miss。fix=owner-thread model。
- S5b focus-routing (2 連続): 「1-window bit-exact」intent に集中し「2-window で必要 state が使用時点に手元にあるか=mechanism の実装可能性」を未 ground ([[feedback_verify_fn_scope_by_lexical_range]] 系)。

**How to apply:** design draft が既存 mechanism reuse を主張する箇所で (1) その mechanism の定義 + 実挙動を grep/read (cache の eviction policy / generation の prune 対象 / library feature の実保証 / macro の borrow 展開) (2) draft の期待と実挙動を突き合わせ (3) 乖離があれば REVISE。codex adversarial gate がこの種を高確率で catch するが、boss1/PRESIDENT review でも reuse-claim を見たら mechanism-ground を先行。[[feedback_verify_before_recommending]] (外部 crate は cargo 実証) の design-review 版。「verify the mechanism, not the intent」。
