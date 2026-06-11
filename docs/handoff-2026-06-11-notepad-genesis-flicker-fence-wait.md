# Handoff 2026-06-11 — hayate-kit-notepad genesis + framework bug 2件 root-cause（work-PC → home-PC）

- **作成**: 2026-06-11 work-PC（GTX750/tlcr-X99E）session 末
- **制約**: user は **明日から3日間 work-PC に触れない**。本 doc + origin push 済の git で home-PC が完全に引き継げること（local-only stranded ゼロ）が要件。
- **同期チャネル**: memory は local-only ゆえ §B で verbatim mirror、code は全て origin push 済（§C）。

---

## §A. 本 session でやったこと（時系列サマリ）

新世代 notepad リメイク `hayate-kit-notepad` を起案・scaffold し、M1 land 後の live-verify で framework bug 2件を root-cause した。

1. **hayate-kit ime/a11y passthrough**（GUI_kit **PR #238**、main `895c440`）: R1 調査で「新世代 app は hayate-kit only で IME/a11y 到達可（hayate-platform default 継承）」を確認、暗黙依存を明示 opt-in feature edge で堅牢化。notepad が初 consumer。
2. **hayate-kit-notepad M1 scaffold**（repo genesis、**PRIVATE**、commit `466ef35`）: 2-crate（notepad-core 非GUI / notepad-ui hayate-kit only + features=[ime,a11y]）、SystemLike titlebar + TextAreaWidget + Document 配線。全 gate pass（cargo緑/test4/HAYATE_SCREENSHOT 視覚/規範self-check/codex LGTM）。**legacy notepad の 2 gap（titlebar ボタン/drag-select）を clean-slate で解消**（両方 GUI_kit 側で既に解決済だった）。
3. **改行ずれ bug 根治**（GUI_kit **PR #239**、main `542c090`）: vector-fallback path の row_height 固定18 が実 font metric と SSOT 分裂。fix=`sync_vector_row_height`（cosmic line metric 由来 SSOT 化）。win95 AppTheme 注入を probe に切り分け。
4. **caret ちらつき bug 根治**（branch `fix/dmabuf-export-fence-wait` `39d43d0`、**user-live 完治確定・merge pending**）: 真因=GPU-completion sync gap（vk export DMA-BUF copy 後の fence-wait 欠落、NVIDIA implicit-sync torn）。fix=export submit 後 `wait_for_fences`（+20行）。**誤った 2 仮説（focus-bounce / triple-buffer）を経て trace#2 確証で命中**。

**GUI_kit main HEAD = `542c090`**（#238 + #239 land 済）。fence-wait（#flicker）は branch 保全、home-PC で形式 gate 完走 → merge。

---

## §B. memory mirror（home-PC で `/home/tlcr/.claude/projects/-home-tlcr-Documents-Claude-Code-Communication/memory/` に反映）

### B-1. `project_hayate_kit_notepad.md`（新規作成、verbatim）

```markdown
---
name: project_hayate_kit_notepad
description: hayate-kit-notepad = 新世代 notepad リメイク (legacy notepad の clean-slate 版、DTP 布石込み)。M1 scaffold land 済
metadata:
  type: project
---

**2026-06-11 work-PC 起案 + M1 land**: 新世代 app として legacy `hayate-notepad`（dogfood 資産）を clean-slate でリメイク。起源 = 2026-05-19 に notepad で発見した 2 gap（titlebar 閉じる/最大化ボタン不在 + drag-select 不在）を「notepad-side fix せず新アプリ起案を待つ」と defer した件（[[feedback_dogfood_legacy_new_apps_clean_slate]]）。調査の結果 2 gap は両方 GUI_kit 側で既に解決済（titlebar = hayate-kit が Decorations/build_systemlike re-export、drag-select = TextAreaWidget 内蔵）→ リメイクは「framework を正しく使うだけ」で吸収 = clean-slate path 正当性の実証。

**repo**: github.com/revivals47/hayate-kit-notepad（**PRIVATE** = 初の private 新世代 repo、user 明示指示。既存 hayate-kit-* は public）。SSH origin、default branch main、genesis commit `466ef35`（10 files/+2707）。BLUEPRINT = Claude-Code-Communication/docs/blueprint-hayate-kit-notepad-v0.1.md（v0.2）。

**構成 = 2-crate**: `notepad-core`（非 GUI、serde only、Document plain-text model + DTP 布石の RichSpan 空 struct placeholder のみ=YAGNI）/ `notepad-ui`（hayate-kit のみ依存 + features=[ime,a11y] 明示 opt-in、hayate-platform 直 dep 禁止 [[feedback_new_apps_depend_on_gui_kit_only]]）。core 分離理由 = 将来 DTP（縦書き/ルビ rich-text span）を GUI 非依存層に additive 拡張する受け皿 [[project_dtp_app_roadmap]]。UI 側 DTP surface 候補 = hayate-kit の RichTextWidget（既存）。

**前提 land**: hayate-kit ime/a11y passthrough feature（PR #238、GUI_kit main `895c440`）。R1 調査結論 A（hayate-platform default=[vulkan,ibus,a11y] を hayate-kit が継承で IME 到達可）の暗黙依存を、明示 opt-in feature edge で堅牢化。notepad が初 consumer。

**roadmap**: M1 ✅ land / M2 = file I/O 本体（新規/開く/保存 + AlertDialog 未保存確認、**未着手**）/ M3 = DTP 布石は型のみ実装は別 RFC。

**M1 live-verify で framework bug 2 件 surface（いずれも新世代 notepad が GUI_kit latent を露呈、newline と同パターン）**:
1. **改行ずれ（newline）= ✅ 根治 land**。vector-fallback path の row_height が固定18で実 font metric と SSOT 分裂 → caret/line-y 乖離。fix=`sync_vector_row_height`（cosmic line metric 由来 SSOT 化、bitmap path 対称）。GUI_kit **PR #239、main `542c090`**。AppTheme 注入（win95）が probe で切り分け（bitmap path が row_height を実 metric に整合）→ band-aid 回避で framework 根治。
2. **caret ちらつき（type/backspace で右→一瞬左 + ghost-after-delete）= ✅ root-cause 確定 + user 完治（land pending）**。**真因 = GPU-completion sync gap**: `vk_renderer.rs` の最終 export DMA-BUF copy submit（936/947）後に **fence-wait が欠落**したまま wl_buffer commit → GPU 書込み完了前の buffer を compositor が sampling、NVIDIA GTX750（旧 proprietary）の implicit-sync 不全で torn/stale glyph。staging→CPU copy は wait（872）済の**非対称**が tell。fix=export submit 後 `wait_for_fences` 追加（+20行）、**worktree/branch `fix/dmabuf-export-fence-wait`**。trace#2 で SKIP=0 確認＝documented recycling-race も triple-buffer 仮説も否定、caret_x 単調正常＝layout/shape-cache も無実。**誤った 2 仮説を経た**: (a) focus-bounce 仮説（axis-A pending_leave + axis-B activation 分離）→ live-verify で flicker 未解決 + axis-B が alt-tab dim regression → **未 merge・worktree `fix/keyboard-focus-self-bounce` 保全** (b) triple-buffer 仮説 → SKIP=0 で否定し fence-wait へ ② 再分岐。教訓=render-core 大改修前に trace 確証 + 最小 fix（[[feedback_measure_first_rescope]]）。full 検証（golden/consumer/codex）+ merge は **home-PC で完了予定**。
3. **IME-drop split-round（finding-13、~33件/session）= real latent だが secondary**（IME 機能は user OK）。focus-bounce 仮説の axis-A（同一 dispatch round 前提）が当 compositor で split-round 常態のため無効。proper fix は別途後追い（band-aid 不可）、知見は worktree `fix/keyboard-focus-self-bounce` に保全。

GUI_kit headless screenshot は静的描画のみ＝live interaction bug（newline/flicker/IME）は user 実機 live-verify が gate（[[feedback_visual_validation_gap_pattern]] / [[feedback_state_dependent_runtime_trace]]）。
```

### B-2. MEMORY.md index 行（新規追加、verbatim）

```
- [hayate-kit-notepad (新世代 notepad リメイク)](project_hayate_kit_notepad.md) — **2026-06-11 起案 + M1 land**: legacy notepad の clean-slate リメイク (DTP 布石込み)。起源=2026-05-19 defer の 2 gap (titlebar ボタン/drag-select) は両方 GUI_kit 側で既解決→clean-slate path 正当性実証。**初の PRIVATE 新世代 repo** (revivals47/hayate-kit-notepad、genesis 466ef35)。2-crate (notepad-core 非GUI serde+RichSpan placeholder YAGNI / notepad-ui hayate-kit features=[ime,a11y] opt-in)。前提=hayate-kit ime/a11y passthrough PR #238 (GUI_kit 895c440)、notepad が初 consumer。M1 ✅ land。**live-verify で framework bug 2件 surface: (1)改行ずれ=✅根治 PR #239 (542c090、vector row_height SSOT) (2)caret ちらつき=✅root-cause確定+user完治(land pending)、真因=GPU-completion sync gap (vk export copy の fence-wait 欠落、NVIDIA implicit-sync torn)、fix=branch fix/dmabuf-export-fence-wait (+20行)、focus-bounce/triple-buffer 2仮説を経て trace 確証で命中**。IME-drop split-round は secondary (branch fix/keyboard-focus-self-bounce 保全)。M2 file I/O 未着手。全 WIP は home-PC 引き継ぎで origin push 済
```

---

## §C. git state（全て origin push 済 = home-PC が git で取得可能）

### GUI_kit（github.com:revivals47/GUI_kit）
- **main = `542c090`**（#238 ime/a11y passthrough → `895c440`、#239 newline row_height SSOT → `542c090`）。clean。
- **branch `fix/dmabuf-export-fence-wait` = `39d43d0`**（push 済）= **flicker 真因 fix（+20行、user-live 完全完治確定）**。残作業 = golden 全 suite net-zero / 全 Vulkan consumer（新世代4+dogfood8）起動+描画 smoke / present cadence 計測 / codex 査読 → PRESIDENT 判断で merge → main 同期 → worktree cleanup。**user-live 完治済ゆえ land 価値確定、残りは形式 gate のみ**。
- **branch `fix/keyboard-focus-self-bounce` = `ee59a12`**（push 済）= axis-A+B WIP（+297/-51）。**NOT merge as-is**（axis-A は split-round で IME-drop 残存・無効、axis-B は alt-tab dim regression）。IME-drop split-round の proper fix（split-round time-window debounce + axis-B alt-tab 是正）後追い用の知見資産。
- ※ worktree（GUI_kit-track-fence / GUI_kit-track-flicker）は local-only。home-PC は `git fetch origin` + `git checkout <branch>` で取得。

### hayate-kit-notepad（github.com:revivals47/hayate-kit-notepad、**PRIVATE**）
- **main = `466ef35`**（genesis、clean）。SSH origin。**PRIVATE ゆえ home-PC clone は SSH 認証要**。

### Claude-Code-Communication（comm repo）
- 本 handoff doc + `docs/blueprint-hayate-kit-notepad-v0.1.md`（v0.2）+ 既存 ahead 分を push 済。

---

## §D. home-PC reentry checklist

1. **comm repo** `git pull` → 本 handoff + BLUEPRINT v0.2 取得。
2. **§B の memory を home-PC の memory dir に反映**（`project_hayate_kit_notepad.md` 新規作成 + MEMORY.md に index 行追加）。memory は local-only ゆえ本 doc が唯一の channel。
3. **GUI_kit** `git pull`（main=542c090）+ `git fetch origin` で 2 branch 取得（`fix/dmabuf-export-fence-wait` / `fix/keyboard-focus-self-bounce`）。
4. **hayate-kit-notepad** clone（PRIVATE、SSH 認証）or pull（main=466ef35）。
5. rebuild（path-dep ゆえ GUI_kit と同階層に配置: `~/Documents/GUI_kit` + `~/Documents/hayate-kit-notepad`）。
6. **env 留意**: home-PC = RTX4070（NVIDIA、新しいドライバ）。flicker は NVIDIA implicit-sync 由来ゆえ home-PC では再現しない可能性あり（ドライバが implicit-sync 改善済の場合）。**ただし fence-wait fix は work-PC で user-live 完治済・correctness 上正しい**ので、home-PC で flicker 非再現でも fix は維持・land する（home-PC の live-verify は flicker fix の gate ではない）。golden baseline は §E 参照。

---

## §E. open items（home-PC で継続）

1. **fence-wait fix（`39d43d0`）の land**: golden net-zero / 全 Vulkan consumer smoke / present cadence / codex を完走 → PRESIDENT 判断で merge → 共有 GUI_kit main 同期 → worktree cleanup。user-live 完治済。
2. **IME-drop split-round（finding-13）の proper fix**: `ee59a12` を知見ベースに、split-round time-window debounce + axis-B alt-tab dim 是正。本 flicker 系列とは分離の別 initiative。band-aid 不可。
3. **golden baseline reconciliation**: 本 session、work-PC（tlcr-X99E、fontconfig=NotoSansCJK）で golden_widgets **0 fail** を観測。memory `feedback_golden_env_drift` の「work-PC canonical = 7 fail」と食い違う（baseline が 0 へシフトした可能性 = fontconfig が golden bless と整合した等）。**単一観察ゆえ memory 即更新はしない**（[[feedback_memory_prescriptive_value_requirement]]）が、home-PC でも 0/7 を確認し恒常性を判断 → 恒常 0 なら memory 更新検討。
4. **M2（file I/O 本体）**: fence-wait land 後に着手。新規/開く/保存 + AlertDialog 未保存確認（BLUEPRINT §3 M2）。M2 前に M1 全体の再 live-verify は不要（newline/flicker は root-cause 済）。

---

## §F. 教訓（本 session）
- **live-verify は static screenshot で捉えられない bug を捕捉する gate**: M1 全 gate pass 後の user 実機 live-verify で newline + flicker の 2 framework bug を捕捉。HAYATE_SCREENSHOT（静的描画）は titlebar 等の視覚確認に有効だが、live interaction（caret/IME/GPU sync）は user 目視必須。
- **render-core 大改修前に trace 確証 + 最小 fix**: flicker で focus-bounce 仮説（1 full cycle 空費）→ triple-buffer 仮説（SKIP=0 で否定）→ trace#2 で GPU sync gap 確証 → +20行 fence-wait で命中。measure-first が大改修の空振りを防いだ。
- **新世代 notepad が GUI_kit latent を連続 surface**: newline / flicker / IME-drop すべて「新世代 app が framework の既存 latent を露呈」パターン。dogfood として framework 改善を駆動（[[project_hayate_kit_notepad]]）。
