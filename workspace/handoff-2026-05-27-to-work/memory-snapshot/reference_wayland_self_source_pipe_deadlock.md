---
name: reference_wayland_self_source_pipe_deadlock
description: Wayland app が自分の clipboard/DnD の source かつ dest になると同一 event-loop スレッドで pipe の sync read/write が相互待ち→deadlock(compositor SIGKILL=user は「応答なし/クラッシュ」と認識、panic 非ゆえ crash log clean)。fix=self 検出して pipe 迂回し自前データ直結
metadata: 
  node_type: memory
  type: reference
  originSessionId: 98d781a1-a05c-4df7-8911-6ed20b1560fd
---

Wayland の clipboard (wl_data_source の Send=write / wl_data_offer の receive=read) と DnD (同 wl_data_source) はデータ転送に **pipe(fd)** を使う。app が **source(write=on_source_send)** と **dest(read=read_to_string/receive)** の両方になる self-operation(自 copy→自 paste、自 drag→自 drop)で、両者を **同一 event-loop スレッド**で同期的に行うと、read が自分の write を待ち、write は同スレッドの dispatch を待つ → **永久 deadlock**。compositor が応答なし窓を SIGKILL → user は「クラッシュ/応答なし」と認識するが **panic ではないので crash log は clean**(誤誘導される)。

**診断**: 実プロセスの `wchan=pipe_read` + CPU 低(busy-loop でなく blocking wait)。`/proc/<pid>/wchan` か `ps -o wchan`。

**fix pattern = self を検出して pipe を迂回し自前データを直結**:
- DnD #185 (2026-05): `wayland.rs` `is_self_drag` → `dnd_text` 直結で pipe バイパス([[project_dnd_phase_b_status]])
- clipboard #191 (2026-05-27、main d35b718): `paste()` 冒頭で `pending_copy`(自所有 text)が Some なら短絡 return。+ source-identity tracking(`current_source` を copy 時記録、`on_source_cancelled` は `cancelled==current_source` の時のみ clear) で copy A→copy B→旧 source_A Cancelled が pending_copy B を誤 clear する repeated-copy hole を塞ぐ([[reference_clipboard_self_paste_deadlock]])

**cross-source(他 app からの read)は deadlock でなく単発 blocking freeze** = 別 follow-up(calloop fd で非ブロッキング read 化、event loop が clipboard I/O で一切 block しない真の根治)。

**規範**: 新規 clipboard/DnD/pipe-transfer 機構を足す時、self-source case を最初に short-circuit する設計を前提にする。
