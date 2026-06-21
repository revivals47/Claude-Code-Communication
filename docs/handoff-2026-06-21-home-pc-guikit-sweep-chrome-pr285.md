# Handoff 2026-06-21 — home-PC: GUI_kit ブランチ棚卸し + chrome-controls PR #285（work-PC golden bless 待ち）

home-PC session。GUI_kit の生きたブランチ棚卸しと、各案件の調査/land/掃除。
**work-PC で唯一やるべき actionable = PR #285 の golden 再 bless + merge**（下記 §D-1）。

---

## §A. 本 session でやったこと

### 1. GUI_kit ブランチ棚卸し + 死にブランチ掃除 — ✅ 完了
- `feedback_dispatch_premise_stale_after_bulk_merge` のフル発現を 3 件確認: **patch-id "LIVE" ≠ 残作業あり**（bulk/squash merge が同じ論理変更を別テキストで再実装するため patch-id 不一致でも内容は land 済）。
- 内容検証で DEAD 確定した死にブランチを削除: local 3 + origin 8（`track1/facade-gaps-kit-calc`/`examples-prelude-migration`/`slider-offwindow-drag-latch`/`label-alignment`/`feat/button-icons`/`test-coverage-wave-b,c`/`track-fix/example-drawbuf-arity`）。
- `git fetch --prune` で**サーバ側既削除の stale 追跡 ref 20本**一掃。
- 教訓: ブランチ生死は patch-id でなく**現 main を grep 内容検証**。詳細 memory `project_guikit_track1_branches_landed`。

### 2. text_area select+paste 間欠クラッシュ調査 — ✅ 解消済を確認、diag 撤去
- 結論: **現 main (eeaf068→) で構造的に解消済、再修正不要**。全変異が selection reset + line_index 再構築 + `content_rev` bump、visual_lines memoize は content_rev keyed、set_cursor/selection は char 境界 snap、preedit は text と別フィールド。
- 回帰ガード 4 件 green（`text_area/mod.rs:1576-1623`）。
- 目的を終えた `diag/select-paste-crash`（local-only、計装のみ）削除（recovery tip `0da0725`）。詳細 memory `project_text_area_select_paste_crash`。

### 3. R2-4 modal focus trap — ✅ doc 救出 land + branch 削除
- `track-r2/r2-4-modal-focus-trap` は **design draft doc のみ（未実装）**。3 bug のうち bug1（AlertDialog Tab cycle）が唯一の生きた user 可視 gap、bug2（FilePicker Escape）は host `file_dialog.rs` で解消済、bug3 は R5。
- doc を救出 → **PR #284 squash → main `f32bc51`**（`docs/R2-4-design-draft-v0.1.md`）。stale branch 削除。詳細 memory `project_r2_4_modal_focus_trap`。

### 4. chrome-controls rebase + live review — ✅ PASS、PR #285 化（**work-PC bless 待ち**）
- 旧 `feat/chrome-controls`（`0084ea9`、181 commits 遅れ）を単一 commit として現 main に cherry-pick rebase。conflict は `hayate_original` idle bg のみ（B1 設計通り解決）。
- 検証（home-PC、全 -j1）: lib + `--examples` build 緑、`title_bar` unit **18/18 緑**、**period skin 4 golden が clean main と bit 一致 = period 不変の機械実証**。
- **user live-visual review PASS**（実 Vulkan、`verify_dnd` の SystemLike chrome 明示 opt-in。idle pill 可視 + 押しやすい）。★元ブロッカー解消。
- 注: `App::new` は default=Borderless（[[reference_decorations_default_borderless]] 裏取り済、app.rs docstring が stale）ゆえ titlebar 出ず → `verify_dnd` 等の SystemLike 明示 example が live review に必要。`decorated_app_minimal` は「App::new=SystemLike」の stale 前提で borderless になる別バグ（要別途修正）。
- 旧 `feat/chrome-controls`（local+origin）は削除済（内容は PR #285 に保全）。詳細 memory `project_chrome_controls_visibility`。

---

## §B. memory mirror（work-PC で `~/.claude/projects/-home-<user>-Documents-Claude-Code-Communication/memory/` に反映）

memory は PC ローカル。以下を work-PC の memory dir に作成/更新（本文は home-PC の各ファイル参照、要点のみ転記）:

- **新規** `project_guikit_track1_branches_landed.md` — track1/* + slider + facade + veto は内容 land 済（patch-id 偽 LIVE）。
- **新規** `project_text_area_select_paste_crash.md` — select+paste byte境界 crash は構造的解消済 + 回帰ガード4件 green。
- **新規** `project_r2_4_modal_focus_trap.md` — branch=doc のみ、doc は PR #284→main land。bug1 のみ残（AlertDialog Tab、~70 LOC）。
- **更新** `project_chrome_controls_visibility.md` — 末尾に「2026-06-21 live review PASS + PR #285、旧 branch 削除済、work-PC golden bless 待ち」追記。
- **更新** `MEMORY.md` — 上記 3 新規 index 行追加。

（home-PC 側の本文をコピーするのが確実。各ファイルは `[[...]]` cross-link 込みで完結している。）

---

## §C. git state（全て origin push 済）

### GUI_kit（github.com/revivals47/GUI_kit）
- `main` = `f32bc51`（PR #284 R2-4 doc rescue land）、origin 同期。
- **PR #285 OPEN**（`feat/chrome-controls-rebase` = `b925c6b`、pushed）= chrome Tier A+B1 rebase。→ §D-1。
- 削除済ブランチ多数（§A-1）。残ブランチは archive/* / backup/user-wip-local / docs/* / 各 track 系の生き残り。

### Claude-Code-Communication（comm repo、push 先 = revivals47/Claude-Code-Communication）
- 本 handoff doc を commit + push。
- `.claude/settings.local.json` の M と `section/`（untracked）は本 session 無関係、commit しない。

---

## §D. 次 PC（work-PC）reentry checklist / open items

### D-1. ★最優先: PR #285 の golden 再 bless + merge（work-PC でのみ可能）
PR #285 は home-PC で完成済だが、`titlebar_default.golden` が **home-PC bless** で残っている。canonical は **work-PC**（#235、`feedback_golden_env_drift`）。手順:
```
git fetch origin && git checkout feat/chrome-controls-rebase
# feature が default テーマの titlebar rendering を変える（idle pill）ので titlebar_default は意図 diff。
GOLDEN_BLESS=1 cargo test -j1 -p hayate-kit --test golden_systemlike_chrome -- --test-threads=1 systemlike_titlebar_default
git add crates/hayate-kit/tests/goldens/systemlike/titlebar_default.golden
git commit -m "test(chrome): re-bless titlebar_default golden on work-PC (canonical) for idle-pill rendering"
git push
# work-PC で 5/5 systemlike_titlebar_* green を確認（period 4 は変更なし、default のみ re-bless）。
gh pr merge 285 --squash --delete-branch
```
※ period skin 4 golden（win95/win95_inactive/macos9/big_sur）は**触らない**（home-PC では bit 一致で不変実証済、work-PC canonical のまま green のはず）。

### D-2. open items（継続）
- **chrome B2（defer）**: crisp ~16px vector glyph chrome、public API 変更ゆえ codex API-gate 必要（`project_chrome_controls_visibility` §残）。
- **R2-4 bug1（任意）**: AlertDialog の Tab cycle + focus ring、~70 LOC、option A。設計は main の `docs/R2-4-design-draft-v0.1.md`。
- **`decorated_app_minimal` stale バグ（任意）**: 「App::new=SystemLike」前提で実際 borderless。SystemLike 明示 opt-in に直すか docstring 訂正。
- **IME-drop split-round proper fix**: 前 handoff からの継続（branch `fix/keyboard-focus-self-bounce`、WIP）。

---

## §F. 教訓（本 session）
1. **patch-id "LIVE" ≠ 残作業あり** — squash/bulk merge は patch-id 不一致でも内容 land 済。ブランチ生死は現 main の grep 内容検証で判定。
2. **stale 前提を着手前に検証** — 調査 3 案件中 2 件（crash / facade）が既に解消/land 済だった。`feedback_dispatch_premise_stale_after_bulk_merge`。
3. **live-visual review は SystemLike 明示 example で** — `App::new` は Borderless ゆえ titlebar 出ない。chrome review には `verify_dnd` 等を使う。
4. **golden env-drift の分離は bit-identical 比較で** — 自変更が period skin 不変なことを「clean main と branch の pixel-mismatch delta 一致」で機械実証できた（pre-existing fail triage）。
