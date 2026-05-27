---
name: reference_clipboard_self_paste_deadlock
description: GUI_kit notepad の Paste 応答なし + intermittent Ctrl+V「crash」= 同一 self-paste deadlock(hang、panic ではない)。clipboard paste() の同期 blocking pipe read が
metadata: 
  node_type: memory
  type: reference
  originSessionId: bba0eb80-c5e4-4310-a4ee-8daaac9203de
---

GUI_kit L1 `platform/clipboard.rs` `paste()` (clipboard.rs:104 `file.read_to_string`) は **同期 blocking pipe read** を calloop event-loop スレッド上で実行 (呼出 wayland.rs:1102)。自分の Copy で selection 所有 (pending_copy=Some) のまま同 app で Paste すると、データ供給元 `on_source_send` (clipboard.rs:187 write) は wl_data_source Send の Dispatch handler ＝ event_loop.dispatch() が pump して初めて走るが、その loop が read_to_string で block 中 → **同一スレッドで read↔write 相互待ち = 永久 deadlock** (force-quit まで)。wchan=pipe_read が clipboard.rs:104 に一致。

★これは **#185 (Finding 9) で根治済の DnD self-drag deadlock の clipboard 版未修正**。precedent = wayland.rs:1255-1278、コメント(1256-1267)が同一機構を記述、修正は `is_self_drag=dnd_source.is_some()` なら自前 dnd_text/uris を直結 (pipe 迂回、案A)。clipboard paste() には同手当てが無い取りこぼし。

★**intermittent「Ctrl+V crash」(no backtrace / crash.log clean / OOB 計装 非 fire) はこの deadlock-hang の公算大** = panic でなく hang。anomaly guard が鳴らないのは OOB が無く clean blocking-wait だから。「応答なし→force-quit」が user には crash に見えるだけ。selected+Ctrl+V も clipboard に自 copy があれば self-paste。→ crash diag を memory-safety bug として追う前にこの deadlock を疑う。

fix (2026-05-27 ★MERGED PR #191): paste() 冒頭で `if pending_copy.is_some() { return clone }` short-circuit (=#185 案A 適用、L1 全 app 受益)。codex impl-review PASS + user live verify PASS。★codex design-gate の high must-fix: pending_copy invariant が repeated self-copy (copy A→B) で崩れる — on_source_cancelled が無条件 clear ＋ source identity 未 track ゆえ旧 source_A の Cancelled が pending_copy(B) を誤 clear → deadlock 再露出。修正= Clipboard に current_source: Option<WlDataSource> 追加、copy() で格納、on_source_cancelled は cancelled==current_source の時のみ clear (stale source 無視、destroy は従来通り)。proxy 比較= WlDataSource PartialEq (既存 dnd is_dnd と同手法)。secondary follow-up = cross-app blocking read を calloop fd poll で非ブロック化 (別 dispatch)。詳細 = workspace/worker2-notes/notepad_clipboard_self_paste_deadlock_fix.md。関連 [[project_dnd_phase_b_status]] [[project_notepad_l2_phase2_resume]]
