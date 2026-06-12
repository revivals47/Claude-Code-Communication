# Handoff 2026-06-12 — home-PC: fence-wait land + golden reconciliation + notepad M2 (file I/O + close-veto)

- **作成**: 2026-06-12 home-PC（RTX4070）session 末
- **前提**: 本 session は 2026-06-11 work-PC→home-PC 引き継ぎ（`docs/handoff-2026-06-11-notepad-genesis-flicker-fence-wait.md`）を受けて home-PC で再開したもの。引き継ぎ reentry（comm pull / memory mirror / GUI_kit+notepad clone+build）完了後、open items を 3 件処理した。
- **同期チャネル**: code は全て origin push 済（§C）。memory は local-only ゆえ §B で verbatim mirror（次 PC が反映）。
- **push 先注意**: comm repo の push 先は **userfork（revivals47/Claude-Code-Communication）**。origin = userfork で正。GUI_kit / hayate-kit-notepad は通常の origin（revivals47）。

---

## §A. 本 session でやったこと（open items 3 件処理）

### 1. fence-wait fix（caret flicker 根治）land — ✅ 完了
- 2026-06-11 work-PC で root-cause+user 完治していた branch `fix/dmabuf-export-fence-wait`（`39d43d0`）を home-PC で全 gate 完走 → merge。
- gate: diff review（self.fence が両 path で最終 export submit を signal・wait placement 両 path cover・VUID 違反なし）/ golden net-zero（branch・main とも同一 fail set = env-drift、fix 起因 0）/ hayate-platform lib 865 / examples 39 build / notepad consumer check / codex「重大 finding なし merge 可」。
- **GUI_kit main に FF merge（`39d43d0`）+ origin push + branch cleanup 済**。
- ★home-PC=RTX4070 でも release 起動 + **user live-verify GREEN（flicker 無し・IME「めっちゃ気持ちいい」）** = cross-env 確認完了。handoff §D-6 の「home-PC 非再現懸念」も実機で解消。

### 2. golden baseline reconciliation — ✅ 完了（謎を解明、memory 更新）
- 「home-PC 0 fail vs memory 7 fail」食い違いの真相 = **2026-06-09 PR #235（`61bbeab`）の single-PC（work-PC=canonical）移行決定で golden baseline polarity が反転**していた。
- 旧（〜2026-05-14）: home-PC era bless → home-PC=0 / work-PC=5。新（2026-06-09〜）: work-PC fontconfig（NotoSansCJK）で env-drift golden 10 件 re-bless（+ #231 で button/vstack）→ **home-PC=12 fail / work-PC=0**。
- home-PC 実測（main `39d43d0`）: golden_widgets 7 fail + golden_systemlike_chrome 5 fail = 計 12、全て work-PC re-bless file と一致、diff は全て text 行集中の font-hinting 差 = regression でも home-PC env 変化でもない（fonts intact）。**恒常的・決定的**。
- **home-PC では bisect 不要・re-bless 厳禁**（home-PC で bless すると polarity 再反転して work-PC を壊す）。memory `feedback_golden_env_drift` を polarity 反転で更新（§B-2）。

### 3. notepad M2（file I/O）— ✅ 完了（land、user live「完璧な動作」）
- BLUEPRINT §3 M2: File メニュー（新規/開く/保存/名前を付けて保存）+ Ctrl+N/O/S/Shift+S + UTF-8 read/write + dirty flag + 未保存確認 AlertDialog。
- **★platform 原則で L2 拡張を選択（user 判断）**: app-local private 重複を避け、hayate-kit に public **FileDialog** widget 新設（shipped notepad-l2 の app-local 実装を L2 promote）+ **modal_ime::forward_ime** を app から lift（第三 consumer 出現で YAGNI 解除）+ **Keysym re-export**（L2-only app の key shortcut gap）。
- **★single-window close-veto hook 新設（framework gap 根治）**: × ボタンが未保存確認をバイパスしデータ損失する gap を framework で解決（legacy notepad-l2 も未解決だった）。`App::on_close_request(handler: FnMut()->bool)` + on_event_mut の `WindowEvent::CloseRequested` arm + `cancel_close_requested()` id-free veto helper。**handler は primary window 限定**（codex review で multi-window 漏れ指摘→make_window_build_ctx の明示 param で修正→codex 再確認「可」）。
- notepad: root を Notepad container widget 化（menu_bar + editor + 4 modal、Cmd/DeferredOp 駆動、save-before-discard state machine）。× dirty 時 save_confirm 表示+veto、Don't Save/Save→quit_flag で clean exit。全 close 経路（×/File→Exit/Alt+F4）でデータ保護。
- gate: hayate-kit lib 1048 / hayate-platform lib 866 / notepad-core 9 / file_dialog 6 + modal_ime 3 + cancel_close 群 / examples 39 build / codex（finding→修正→可）/ user live「完璧」。
- **land: GUI_kit main `72164d8` + hayate-kit-notepad main `fd6bc05`、両 push + branch cleanup 済**。

---

## §B. memory mirror（次 PC で `~/.claude/projects/-home-<user>-Documents-Claude-Code-Communication/memory/` に反映）

memory は local-only。本 session で **1 file 更新（feedback_golden_env_drift）+ 1 file 更新（project_hayate_kit_notepad に M2 追記）**。project_hayate_kit_notepad の本体は 2026-06-11 work-PC handoff §B で既出ゆえ、ここでは **本 session での差分のみ** mirror。

### B-1. `feedback_golden_env_drift.md` — polarity 反転で更新（本文先頭に追記 + 旧本文は歴史的記録化）

description 行を更新:
```
description: golden pixel-mismatch fail は cosmic-text fontconfig drift 由来の env-specific。★2026-06-09 (PR #235) に canonical が work-PC 化で polarity 反転 = 今は home-PC が 12 fail / work-PC 0。bisect 前に env 差切り分け必須
```

本文先頭に以下セクションを追記（旧本文は「## 【以下、歴史的記録（2026-05 時点・旧 polarity）】」見出しで残す）:
```markdown
## ★ 2026-06-12 UPDATE: canonical が work-PC 化、polarity 反転

**現 canonical = work-PC fontconfig (NotoSansCJK)**。2026-06-09 PR #235 (61bbeab) の single-PC 移行決定で env-drift golden を work-PC env で re-bless（+ 2026-06-08 PR #231 9285c0b で button/vstack win10）。polarity 反転: 旧「home-PC=0 / work-PC=5」→ 現「home-PC=12 fail / work-PC=0」。

home-PC の expected-fail inventory（2026-06-12 home-PC RTX4070 実測、main 39d43d0）= 計 12、全て work-PC re-bless file と一致:
- golden_widgets 7: button_default/label_default/vstack_default/spin_button_default ×win10 + spin_button_default ×win95 + checkbox_checked/radio_checked ×xp_luna
- golden_systemlike_chrome 5: titlebar default/macos9/macos_big_sur/win95/win95_inactive

regression でも home-PC env 変化でもない（fonts intact: Inter Variable + JetBrains Mono、diff は全て text/glyph 行集中の font-hinting 差、PR #235 で三者 PNG visual gate 済）。恒常的・決定的。

home-PC で今すべきこと: 上記 12 fail は work-PC canonical golden を home-PC で見た期待結果。bisect 不要・re-bless 不要（home-PC で bless すると polarity 再反転して work-PC を壊す）。新規 golden fail を見たら上記 12 inventory に含まれるか照合 → 含まれれば env-drift 無視、含まれない/text 行外の大きな幾何 diff なら真の regression を疑う。
```

### B-2. `project_hayate_kit_notepad.md` — M2 land を追記

roadmap 行を `M2 ✅ land（2026-06-12 home-PC、user live「完璧な動作」）` に更新し、以下を追記:
```markdown
**M2 file I/O（2026-06-12 home-PC land、2 PR 構成）**: File メニュー（新規/開く/保存/名前を付けて保存）+ Ctrl+N/O/S/Shift+S + UTF-8 read/write + dirty flag + 未保存確認。root を Notepad container widget 化（menu_bar + editor + 4 modal、Cmd/DeferredOp 駆動、save-before-discard state machine）。notepad-core に Document::load_path/save_to/save 追加。
- ★platform 原則で L2 拡張選択（app-local 重複回避、user 判断）: hayate-kit に public FileDialog widget 新設（notepad-l2 の app-local 実装を L2 promote、take_outcome→Selected/Cancelled）+ modal_ime::forward_ime を app から lift + Keysym re-export。GUI_kit main 72164d8。
- ★single-window close-veto hook 新設（framework gap 根治）: App::on_close_request(handler FnMut()->bool) + on_event_mut の CloseRequested arm + cancel_close_requested() id-free veto helper。handler は primary 限定（make_window_build_ctx 明示 param、runtime/2nd-window factory は None、codex review で multi-window 漏れ指摘→修正）。notepad は × dirty 時 save_confirm 表示+veto、Don't Save/Save→quit_flag で clean exit。全 close 経路でデータ保護。
- gate: hayate-kit lib 1048 / hayate-platform lib 866 / notepad-core 9 / file_dialog 6 + modal_ime 3 / examples 39 build / codex(finding→修正→可) / user live「完璧」。land = GUI_kit 72164d8 + notepad fd6bc05。
- follow-up（codex 提案、未対応）: save-before-discard chain の E2E test（Notepad は App handle 必要で binary ゆえ test 構築要工夫）。
```

---

## §C. git state（全て origin push 済）

### GUI_kit（github.com/revivals47/GUI_kit）
- **main = `72164d8`**（push 済）。本 session で 3 commit land:
  - `39d43d0` fence-wait fix（caret flicker、#flicker）
  - `4eae6b9` feat(hayate-kit): L2 FileDialog + modal_ime + Keysym re-export
  - `72164d8` feat(app): single-window close-veto hook（App::on_close_request、primary 限定）
- **branch `fix/keyboard-focus-self-bounce`（`ee59a12`）= 保持**（open item #2 = IME-drop split-round の proper fix 用知見資産。NOT merge as-is）。
- 旧 stash 3 件（president/l0-spec / worker2 / main T3b）= 旧 session 残置、本 session と無関係、保持。

### hayate-kit-notepad（github.com/revivals47/hayate-kit-notepad、PRIVATE）
- **main = `fd6bc05`**（push 済）。M2 file I/O + close-veto 配線 land 済。
- home-PC は HTTPS で clone（SSH 鍵が GitHub 未登録のため）。push も HTTPS で通る。

### Claude-Code-Communication（comm repo、push 先 = userfork revivals47）
- 本 handoff doc を追加 + push。

---

## §D. 次 PC reentry checklist

1. **comm repo** `git pull`（userfork から）→ 本 handoff 取得。
2. **§B の memory 差分を反映**（feedback_golden_env_drift の polarity 反転 + project_hayate_kit_notepad の M2 追記）。memory は local-only ゆえ本 doc が唯一の channel。
3. **GUI_kit** `git pull`（main=`72164d8`）。`fix/keyboard-focus-self-bounce` は origin にあり（item #2 用）。
4. **hayate-kit-notepad** `git pull`（main=`fd6bc05`）。PRIVATE = SSH 認証 or HTTPS。
5. rebuild（path-dep: `~/Documents/GUI_kit` + `~/Documents/hayate-kit-notepad` 同階層）。
6. **golden 留意（§A-2）**: work-PC では 0 fail、home-PC では 12 fail（env-drift、期待結果）。どちらでも bisect/re-bless 不要。

---

## §E. open items（次 session で継続）

1. **IME-drop split-round（finding-13）の proper fix** — branch `fix/keyboard-focus-self-bounce`（`ee59a12`）を知見ベースに、split-round time-window debounce + axis-B alt-tab dim 是正。flicker 系列とは分離の別 initiative。band-aid 不可。**本 session 唯一の残 open item**。
2. **（follow-up）notepad M2 の save-before-discard chain E2E test**（codex 提案、low 優先）。
3. **（将来）notepad M3** = DTP 布石（型 placeholder のみ、実装は別 RFC）。M2 land で MVP の file I/O は完成。

---

## §F. 教訓（本 session）
- **live-verify が gate**: M2 の file dialog / 未保存確認 / IME / × ボタンは headless 検証不可。user 実機目視で save_confirm のテキスト未表示（engine 未注入）+ × ボタンの close-veto バイパス（framework gap）の 2 件を捕捉。HAYATE_SCREENSHOT（静的 frame1）は base layout 確認には有効。
- **platform 原則を貫くと framework gap が surface する**: FileDialog を L2 に置く判断から、Keysym 未 re-export / single-window close-veto 不在の 2 gap が連鎖的に判明・根治。新世代 app は framework の latent を駆動する dogfood（newline/flicker/IME と同パターン）。
- **codex は API 設計の漏れを捕捉する**: close-veto handler の multi-window 漏れを指摘 → primary 限定に修正。shared-main land 前の codex gate が機能。
- **derived baseline は git 履歴で再構成できる**: golden の 0⇄7⇄12 の謎は re-bless commit（#231/#235）の message を読むことで「意図的な single-PC 移行」と判明。memory の状態 claim は land で stale 化するので現コード/git log で再 baseline。
