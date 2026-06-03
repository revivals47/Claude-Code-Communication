---
name: feedback_shared_to_perinstance_handle_audit
description: shared Rc を per-instance に分ける refactor は、その Rc を返す public handle / run 前に取得する consumer を grep audit せよ。silent dead-handle = bit-exact 違反
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 3dbf9b0d-04e8-41e9-b05e-d813a6c036ca
---

ある shared state (`Rc<...>`) を per-instance / per-window に「new で分ける」refactor をする時、その Rc を **public API handle 経由で外部に露出していないか / consumer が初期化前 (例 run() 前) にその Rc を取得して保持していないか** を grep audit してから着手する。露出 handle があると、per-instance new で内部 cell と handle の Rc が **silent に切断** され、handle 保持側が dead handle (書いても届かない) になる = 挙動変化・bit-exact 違反。

**Why:** 2026-06-03 GUI_kit multi-window S5b-1 impl-plan で発覚。設計は per-window channel を「closure 内で new」と規定 (codex 6 gate + boss1 + PRESIDENT verify を通過)。だが worker1 の impl-plan grep audit で、これらの channel は全て `App::window_action()`/`move_request()`/`ime_enable_request()` 等の **public handle** (= `Rc::clone(&self.field)`) を持ち、consumer が `run()` 前に取得して使う public API だった。`build_window` は同じ App Rc を window に焼く (`window.window_action = Some(Rc::clone(&self.window_action))`)。→ primary を per-window new にすると handle が dead = bit-exact 違反。設計レビュー (boss1/PRESIDENT 含む) は **「所有粒度 (どの Rc を持つか)」に注目し「public API 露出 (consumer がどこで wire するか)」を見落とした** = abstract design の構造的盲点。

**How to apply:** shared→per-instance refactor の着手前に (1) 対象 field の Rc を返す pub fn を grep (`pub fn .* -> .*Rc`) (2) その handle の consumer が初期化前に取得・保持していないか確認 (3) 露出ありなら「既存 instance (primary) は共有 Rc capture 維持 / 新規 instance のみ fresh」と分け、bit-exact を保つ。public handle の per-instance 化は別 phase / L2 concern に defer。[[feedback_platform_principle]] / [[feedback_pre_move_grep_audit]] の consumer-handle 版。abstract design gate は通っても impl 直前の consumer grep audit で必ず再確認。
