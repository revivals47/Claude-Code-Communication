---
name: project-multiwindow-l1
description: GUI_kit multi-window L1 phased migration (S0-S5) — S0-S4 land 完了、次=S5 (2 窓目 e2e + per-window render/routing/popup/a11y)
metadata: 
  node_type: memory
  type: project
  originSessionId: f9e15643-7405-4f08-ab6d-f8ccec762a16
---

GUI_kit hayate-platform を **single-window 前提から multi-window 対応に段階的 migrate** する initiative。RFC=`docs/rfc-multi-window-l1.md` v0.5 (codex LGTM/0、388 行)、§6 stage table が source of truth。**2026-06-01 PR #193 で main へ merge 済** (main 0889983、旧 branch track-multiwindow/l1-rfc は削除)。

**Why**: future-proof platform API (現状 1 process 1 window 縛り、L2/L3 consumer も追従できない)。
**How to apply**: stage 単位 small dispatch、各 stage で bit-exact または explicit AC、Pattern 1 sequential rename + Pattern 5 pre-existing fail triage。実装は in-house ([[feedback_inhouse_implementation_default]])、codex は review 2+ round (全体 + 差分 + 必要なら rework 後再差分)。

## stage 進行状況

- **S0 ✅ MERGED 2026-05-29 02:08** (PR #204 → main 786630d、12 commits / +97/-84 / 806 passed bit-exact)
  - `type UiState = WaylandWindow` alias 導入 + 35 Dispatch impl + LoopHandle/QueueHandle/callback 全 UiState 経由
- **S1 ✅ MERGED 2026-05-29 04:37** (PR #205 → main 6402446、22 commits / +2270/-1025 / 806 passed bit-exact)
  - WaylandConnection struct 新設 + 19 global/seat field 移管 + UiState flip + 35 Dispatch impl body `.window` delegation + WaylandWindow→Window rename + BC alias
  - codex 3 rounds (round-1 2 BLOCKER + 1 MINOR → C1-C3 → round-2 1 BLOCKER cousin → C4 → round-3 LGTM + 2 Nit → C5)
- **S2 ✅ MERGED 2026-05-31 07:43** (PR #206 → main ce875d1、17 commits squashed / +7024/-261 / 806 passed bit-exact / ~1h39min)
  - WaylandConnection.window: Window → windows: HashMap<WindowId, Window> + primary_id: WindowId に flip + macro 経由 (`window!`/`window_mut!`) 経由化 + 206 callsite + 12 test code = 218 件 rename
  - **macro 設計** = place-expression (commit 1-9: `$conn.window` bare 展開 = Rust auto-borrow に委ねる) → commit 10a で value-expression swap (`{ let __id = $conn.primary_id; $conn.windows.get_mut(&__id).expect("primary window missing") }`)
  - **focal callsite 戦略 a-e**: (a) intermediate let / (b) clone snapshot / (c) closure helper (last resort) / (d) HashMap::remove (Drop only) / (e) `&mut` prefix 削除 (free fn arg)。確定 8 + 同 statement 2 + Phase 3 a 追加 3 = 13 件適用 (v0.4 §A2.4.1.d 「最大 29、実際 10-15」予測内)
  - **nit-2 累計 48 件**: window!→window_mut! flip (commits 4-9 proactive 16 + commit 10a value-expression swap catch 32)、auto-borrow promote 想定内
  - codex 2 rounds (round-1 0 BLOCKER + 0 MINOR + 3 NIT → commit 11 reflect → round-2 LGTM 0/0/0)、S0 precedent と同 pattern + S1 より大幅 clean
  - **Pattern 5 triple verification**: worker1 並行 S1 land HEAD で golden 2 fail 同実行 + boss1 直 read 4 verify 点 + codex 独立 run で golden 09327ba/6402446 両方 same mismatch counts confirmed = 起因切り分け evidence 最高品質
- **S3 ✅ MERGED 2026-05-31 21:00** (PR #214 → main 5332a98、5 commits / +200 行規模 / 818 passed bit-exact / ~21 min impl + verify 集約)
  - **Dispatch UserData WindowId 化 6 種** (wl_surface / xdg_surface / xdg_toplevel / zxdg_toplevel_decoration / zwlr_layer_surface / wl_callback frame) + `Connection::window_id_from_surface()` 逆引き fn (O(N) iter、S2/S3 N=1 trivial、S4+ cached reverse index 余地)
  - **R2.1 seat focus state 4 field** (pointer/keyboard/dnd/ime focus_window: Option<WindowId>) + 8 update path wiring (Enter/Leave 対称)、touch_focus_windows は **S4+ deferred** (TouchState::handle_event signature 改造併せて、mid-impl flag option C)
  - **wl_pointer Leave handler 新設** (R2.1 完全性、~10 行 minimal、mid-impl flag option A)
  - 1 entry HashMap bit-exact 維持 (surface 逆引き常に primary_id、focus_window 常に Some(primary_id) or None)、S4+ multi-entry 化時 state machine ready
  - **★ codex 1-round closure LGTM 0/0/0 ★** (progressive improvement: S0=2r+1minor → S1=3r+2BLOCKER → S2=2r+3NIT → **S3=1r LGTM**)
  - ★ **quadruple verification 達成** ★ = worker 並行 verify + boss1 self-check + codex independent review + **codex 自発 cargo re-run** (818/0 + 1011/0 + golden 12/2 + popup_validation 31/0 全 4 件) = Pattern 5 triple verification 上位形態
  - ★ **nit-4 規範初発動** ★ (preemptive admission)：design v0.1 review で PRESIDENT が「focal scope expansion admission を v0.2 §0.2 で preemptive embed」を nit-4 として追加 → impl 着手前に worker1 が 2 件 mid-impl flag catch (wl_pointer Leave 未実装 = scope 拡大 / wl_touch surface 取れず = scope 縮減) → **wasted impl 0** + 設計 stage で catch
- **S4 ✅ MERGED 2026-06-02 01:49** (PR #219 → main 14f2b62、9 code commits + doc trail / 16 commits off main / squash / platform 838/0・kit 1022/0・ac9 3/0・golden 12-2 env-drift bit-exact・examples 緑、AC6 bit-exact 維持)
  - **API surface + lifetime plumbing のみ** (実窓は HashMap 1 entry 維持、per-window 本体は S5)。build_window(config, root, layer:Option) DRY factor で ~830 行 inline window build を 1 本化 → open_window(toplevel, layer=None) + run legacy layer path(Some) が共有 (codex C1 no-misroute 構造保証 + SD3=a layer bit-exact、780 行重複回避)
  - WindowConfig = surface descriptor 純化 (title/width/height/resizable/decorations:bool SSD-hint + min/max_size 追加) + From<&AppConfig> lossless。**D1 errata**: decorations bool→Decorations enum 格上げは構造不可 (Decorations: !Clone が WindowConfig: Clone を壊す、Debug は手実装ゆえ非 blocker) → chrome は mem::take 別 path、per-window chrome は S5
  - close_window = primary deferred (running=false、window!/WindowRestoreGuard 不変)、surplus 即時 teardown。**AC5 nuance**: close_window は WaylandConnection (callback receiver) 上、App ではない (App は run trampoline で consume)、L2 reach は on_event_mut(|conn,ev| conn.close_window(id))
  - event loop `while has_open_windows()` (R5) + teardown_all_windows (leak-free、1-entry no-op=bit-exact) + open_window single-entry guard = **assert! (release panic、actionable msg)** (debug_assert は release compile-out で ID 不整合、codex R1 高)
  - **OQ1 = a LOCK-IN (PRESIDENT 2026-06-02、SD 同格)**: WindowManager/ManagedWindow/WindowState dead stub (App::run 未結線、production ref ゼロ、test-only) を完全削除、connection.windows が single source of truth。WindowState lifecycle (4 状態 + 7 assertion) は S5 で Window.lifecycle field 再導入 (PR #219 §S5 carry-over + design draft §3.2 に test-parity 粒度 capture、git archaeology=PR #119/#100)
  - codex 3-round (design-gate REVISE/5 全 ADOPT → impl-review R1 REVISE/2 → commit 8 → R2 LGTM + 低1 → commit 9 false-confidence test 強化 seam-proven)。PRESIDENT 独立 verify: D1 errata grep / open_window debug_assert / WindowManager 0-ref / merge-gate 5 点 full cargo 自走
- **S5 (最終 stage、機能本体) — sub-phasing LOCK-IN 済** (PRESIDENT 2026-06-02、SD 同格): S5a→S5b→{S5c,S5d sequential}、plumbing-first 哲学 (bit-exact refactor 先行 + 機能 flip=2窓目 open を S5b に集中 + AI-verifiable headless 最大化、user-live を S5b+ に寄せる)。infra (Window per-window field / 33 Dispatch impl / surface_to_window / windows HashMap / open_window) は S1-S4 で構築済・single-entry 維持、S5 = 実 multi-entry 化
  - **S5a ✅ MERGED 2026-06-02 03:36** (PR #220 → main d50bbba、8 commit + doc / squash / platform 842/0・kit 1022/0・golden 12-2 env-drift bit-exact・examples 緑・★非 test build warning-clean★、全 1-entry bit-exact AC6 維持、headless 完結=user-live 不要)
    - per-window render plumbing: run() draw を draw_all_windows(windows_to_draw=!frame_pending iterate) 化 (site A/C 置換) + frame-callback per-window routing (site D=dispatch_impls.rs Dispatch<wl_callback,WindowId> を _data 経由、4th draw site) + create_window_surface full per-window 化 (window!/window_mut! 全廃→windows.get/get_mut(&id)) + Window.id=id invariant (R2-F1)
    - AC4 device-lost: Window::force_device_lost() fault-injection hook (cfg(all(test,vulkan))) + 局所化 unit。AC10 scale: per-window 独立保持 unit (scale routing は S5b defer=hidpi Dispatch surface 経由ゆえ headless 不能)
    - codex design-gate 3-round (REVISE→REVISE→LGTM) + impl-review (REVISE/高1 create_window_surface leaky plumbing → commit7-8 → 再 review LGTM/0)。F1(stuck-reset dead 維持)/F2(4th draw site)/F3(windows_to_draw shared helper の dual seam-proof = take(1)&!frame_pending 両 neuter で実 FAIL、S4 commit9 false-confidence cure)/R2-F1(Window.id)/create_window_surface body 全て PRESIDENT 独立 grep verify
    - ★crash 2 回 (codex gate 中 / commit7 前) を context+disk 保全で復元、code 喪失ゼロ★
  - **S5b** pending — ★runtime 2窓目を live connection 上に open★ (App 非存在の running connection 上で Window build+wire する経路 = S5b 核心、design-gate 最重点) + per-window routing e2e (AC1/AC3) + WindowState lifecycle (Window.lifecycle 再導入、4状態/7assertion、S4 carry) + AC10 scale routing。★初の user-live verify★ (2窓同時可視)。design 時 further sub-split 検討可
  - **S5c** pending — per-window popup chain (R6/AC7、OQ2 PopupId→WindowId)
  - **S5d** pending — per-window a11y (R7/AC11 focus+bounds) + per-window title 消費 (AC2、S5a で WindowConfig.title carry 済未消費、hardcode 廃止)

## S0-S3 = 外形挙動不変 (refactor、全 ✅ MERGED)、S4-S5 = 機能追加

## S3 forward-readiness (S2 完遂時点)

- `WaylandConnection.windows: HashMap<WindowId, Window>` + `primary_id: WindowId` 並存、S3 で `surface → WindowId` 逆引き lookup 追加で multi-entry 化 natural
- `window!`/`window_mut!` macro 両方 `primary_id` 経由、S3 で `window!(conn, window_id)` / `window_mut!(conn, window_id)` signature 拡張可能 ($conn.primary_id → $window_id への簡単 swap)
- Connection::alloc_popup_id() delegation method は S3 で alloc_popup_id(window_id) signature 拡張 natural (S1 land precedent)
- callback Connection 受維持 = S3 で `on_event_mut(|conn, window_id, event|)` 拡張 natural

## S2 で確立した規範 (S0+S1+S2 集約)

- **pre-cargo PoC 必須**: 新 scaffolding 案件は boss1 APPROVE 前に PoC で split-borrow safety 確認 ([[reference_deref_scaffolding_split_borrow]] = S1 B2 Deref 失敗 + S2 PoC が Approach C accessor method 破綻 catch、Deref 学習の継承 first 実例)
- **PoC scope limitation admission**: PoC が証明する範囲を明示 (S2 = inter-field disjoint borrow のみ証明、intra-Window operation 未 validate)、commit 中盤で gap 検出 → mid-impl flag pattern。worker1 が commit 2 段階で v0.2 → v0.3 macro design revision 提起 → wasted impl 回避
- **focal callsite full-sweep grep audit**: PoC 範囲外領域は initial 推定 (4-5 件) を超え得る、v0.4 で 29 件 (確定 8 + 条件付き 19 + 同 statement 2) 規模に拡大判明。`if let Some(ref X) = window!(Y).field { body 内 window_mut! }` pattern + intra-Window field pair assignment + Drop move-out + free fn `&mut` prefix を網羅 grep
- **戦略 d/e は boss1 裁量範囲**: mechanical/scope-limited 戦略 (HashMap::remove for Drop / `&mut` prefix 削除 for free fn arg) は boss1 直 read で 4 verify 点 (Option::take 済 / 最終 statement / 後続 access ゼロ / S2 invariant runtime 維持) を踏めば PRESIDENT 上申不要、運用 efficient 化
- **nit-2 proactive interpretation**: 「commit 10a value-expression swap で auto-borrow promote 効かなくなる write context catch」は commit 10a で catch する代わりに commit 4-9 段階で proactive flip 化 (累計 48 件)、commit 10a 訂正 noise 最小化 + 各 commit risk class 統一純化
- **codex output full capture**: tail -N pipe truncation 禁止 ([[reference_codex_exec_background_stdin]])、4608/1338 行 output 全 capture で codex finding 漏れゼロ
- **Pattern 4 dual embed**: 設計 revision 履歴を git log + workspace doc 両方に embed、後世が「なぜこの設計になったか」を re-discover 可能。connection_macros.rs docstring (032ed2c) + s2_design_draft.md §A2.1.3 / §A7 で dual trail
- **Pattern 5 triple verification**: pre-existing fail 起因切り分けは worker1 並行 verify + boss1 直 read + codex 独立 run の triple 体制で confirm、env drift も同 HEAD 並行実行で証拠化
- **AC self-audit 5 項目 mapping**: dispatch 時に impl 後 verify 手段 + 想定結果を明示 (AC4 cargo test 数値 + golden bit-exact / AC5 hayate-kit check + examples build = [[feedback_merge_gate_build_examples]] 遵守)
- **stage 完遂時 PR description で scope-out 明示** (forward-readiness trail = S3/S4/S5 で何をやるか明記、本 PR 単独 scope を防御)

## 次 dispatch trigger

S5a ✅ MERGED 2026-06-02 03:36 (PR #220 main d50bbba)、次は **S5b dispatch** (S5 の本丸 = 初の runtime 2窓目 open + 初の user-live verify、別 session 推奨)。S5b 核心 = App 非存在の running connection 上で Window を build+wire する経路 (S4 build_window は App 内、runtime live insertion 経路が未踏)。design-gate でここを最重点 scrutinize。AC1(2窓同時可視)/AC3(routing) は user-live carve。S5a で render plumbing 全 path per-window 化済ゆえ S5b は「実際に 2 個目を生やす」に集中可。

[旧] S4 ✅ MERGED 2026-06-02 01:49 (PR #219 main 14f2b62)、次は **S5 dispatch** (別 session 推奨、最終 stage = 機能追加の本体ゆえ S0-S4 refactor より重い)。S5 scope = 2 窓目を実際に開く e2e + per-window render(R4 device-lost/scale per-window 化、PR #186 伝播)/routing(S3 逆引き map を multi-entry 化)/popup(R6 per-window)/a11y(R7 SD2=a focus+bounds)/mixed-DPI(AC10) + per-window title(AC2、S4 で WindowConfig.title carry 済・未消費) + decoration handle per-window 保存 + WindowState lifecycle を Window.lifecycle field 再導入 (S4 §S5 carry-over + design draft §3.2 の 4 状態/7 assertion を test-parity で再実装)。S4 dispatch 運用が好実績 (codex 3-round / PRESIDENT 独立 verify 多発 / D1 errata + OQ1=a の design pivot を impl 前に catch)、S5 も同 flow。

post-S2 関連 land (2026-05-31 同 session 内):
- **app_id PR (#208) MERGED** = RFC R3 carve-out from S4 scope (`AppConfig.app_id: Option<String>` + `App::with_app_id()` builder + connection.rs:301 read from config + None fallback 'hayate-ui' で 100% BC)。S4 scope 縮減実現、Option δ pre-cargo grep audit pass で S3 と conflict ゼロ並走 (PRESIDENT 提案 carve-out が technical validate された first 実例)
- ★ multi-window L1 外で本 session 内 land された関連 PR ★ (PRESIDENT 視点参考、scope は別系統):
  - PR #207 Task C TerminalWidget Scroll arm (wheel/touchpad scroll fix、partial = wave 2/3/4 で完遂)
  - PR #209/#4 Task B + EAW terminal_widget cell metrics + East Asian Width double-cell (CJK 2-cell wide)
  - PR #212 Task A wave 2 WindowAction priority-based replacement (action.set race fix、Maximize/Restore terminal action が DragMove transient で上書きされない)
  - PR #213 EAW double-cell follow-up + recalibrated tests
  - PR #2 Task D app icon + .desktop deploy (per-app icon、app_id chain 'hayate-kit-agents')
  - PR #210/#3 popup_validation + send_bar pre-existing fail triage (option β/β-bis、Pattern 5 起因切り分け worker2 catch)
  - PR #211 Task A Phase 3 diagnostic eprintln (revert-after-diagnosis 設計、close 済)
  - **PR #215 Task C wave 2** event_with_csd Scroll x/y CSD-adjustment (PR #207 partial fix の上流 silent path 露見)
  - **PR #216 Task E** terminal_widget scrollbar UI (case B overlay、xterm 規約準拠 public accessors)
  - **PR #217 Task C wave 3** wl_pointer axis_value120 + Frame accumulator (Wayland v8+ high-resolution scroll、protocol evolution catch、PointerState Vec<PointerEvent> signature)
  - **PR #218 Task C wave 4** paint loop scrollback migration (`cell_at()` migration + cell_at alt-screen guard、Phase 9-2b BC clause migrate 忘れ catch、6 test 二重 net)
  - **Task C 4 階 catch chain** (PR #207 → #215 → #217 → #218) で wheel scroll 完全機能達成 = headless verification gap 4 階 root cause を user 介入 trigger × 3 sequential で根治
  - **wave 5 polish initiative (Mac 参照取込)**:
    - **PR #5 wave 5 Phase 1** ActivityState (time-based 2s threshold = Mac v0.5 triangulate、LLM semantics 整合) + PaneHeader 5 要素 (status_dot + name + cli_badge + activity_label + pin_badge) + paint_working_glow (subtle accent #5A8BA8 wind blue 4-edge hairline、Hayate 独自解釈) + dirty() lifecycle propagation full fix (artifact #26 evidence)
    - **PR #6 wave 5 Phase 2** mode toolbar visual clarity = active mode underline 2px + 5 layout icon (▣ ≡ ⊞ ◉ ▥、mode_icon.rs) + shortcut hint label-concat (paint_after API 制約 pivot)、codex 3 findings reflect (a11y + bevel doc-only + icon ▥ const swap)
    - wave 5 Phase 3 follow-up candidate: binding 実装 + grayed-out shortcut + with_accessible_name GUI_kit API + bevel theme follow-up

session 学習 artifact 累計 16 件 mark (#6-#22、handoff doc embed candidate、boss1 next-session task):
- #6-#11 (S2 + wave 1 session 既 mark)
- **#14 v2 拡張**: LGTM round-2 skip 規範 (test-only reflect + boss1 直 verify + workspace docs PR diff embed pattern、5 回該当)
- **#16 ULTIMATE finalize**: headless verification gap class of bug、4 階 catch chain で完全根治 (Task C wave 1/2/3/4 全 land)
- **#17 真価 7 回連続**: codex structural coverage gap catch (Win95 frame-border + alt-screen contract + AxisValue120 + Frame coupling + cell_at latent bug + test-coverage gap)
- **#19**: Wayland protocol version evolution 追従必修 (pointer.rs:223 'ignore for now' anti-pattern、wave 3 root cause 実証)
- **#20**: protocol bind version + handler 完備性 pair audit (v9 bind + v8+ events 未実装 gap)
- **#21**: quintuple verification 達成 (wave 3、worker + boss1 + codex independent + codex 自発 verify + PRESIDENT independent investigation 5 layer)
- **#22**: BC clause deferred migration + raw field accessor invariant (Phase 9-2b BC migrate 忘れ + cell_at raw alt-screen contract 破る、wave 4 root cause + scope expansion 2 段実証)

session 学習 artifact 6 件 (#6-#11) mark 済、handoff doc 化候補 (boss1 next-session で embed 想定):
- #6 Option δ pre-cargo grep audit pass technical validate
- #7 worker2 が複数 PR 並行進行中に 2 件 pre-existing fail 独立 catch + option β-bis triage 提案
- #8 triage queue 2 件 (popup_validation + send_bar) を 2 worker 分担で並走完遂
- #9 revert-after-diagnosis PR pattern (diagnostic-only commit を独立 PR で raise → root cause 確定後 wave 2 impl + revert PR で trail clean)
- #10 4 worker (boss1 + worker1/2/3) で 11 PR を ~3h18min で連続 land (parallel dispatch 規範運用最高峰)
- #11 codex 自発 verify run pattern (PR #212 round-1 で codex が自発的に独立 cargo test verify を embed = triple verification の上位形態)

S3 再開 trigger:
- option A: user が S3 design v0.1 review approach 介入解除 → 本 session 内続行
- option B: 別 session で S3 start (cooldown valid)、現 hold をそのまま carry over
- option C: RFC v0.6 errata (S0 #6 軽 PR、Dispatch impl 集計 33→35 訂正) を別 session 合間で実施
