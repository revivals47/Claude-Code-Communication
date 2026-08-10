# Handoff 2026-07-09 — hayate-kit-testruct 社会解答用紙 live-verify + parity land (work-PC → home-PC)

> **status: 確定 (session close 2026-07-09、work-PC `tlcr-X99E`)**。全成果 origin 反映済み。home-PC 再開手順 + memory mirror を本 doc に外部化。

## §0. 30 秒サマリー

- user の「昨夜自宅で社会の解答用紙を実装した」記憶は **正しかった**。実装は `track3/parity-ee5f49a-catchup` (今朝 home-PC 作業、6 commit) に存在し **main 未マージ**だっただけ。
- 本 session で live-verify → polish 3 件追加 → **PR #99 を main に squash-merge**。
- **testruct main = `db1bc67`** / GUI_kit main = `0e5e2b0` (GUI_kit は本 session 無変更) / testruct-v3 master = `364d3b9`。

## §A. land 済み内容 (PR #99 → main `db1bc67`)

### parity 本体 (今朝の home-PC 作業、6 commit)
| commit | 内容 |
|---|---|
| `b25c938` | PageMetadata に shakaiSheetConfig を opaque 往復保持 |
| `7d2a335` | 社会解答用紙レイアウトエンジンを core へ移植 (parity #4-core) |
| `dc31022` | 画像回り込み描画 + 横書き/SVG縦ルビ (parity #2/#3) |
| `010b476` | 挿入メニューにプリセット社会解答用紙 (GUI MVP) |
| `2956577` | フル対話 editor ダイアログ (shakai_dialog.rs 2182 行) |
| `5af39c7` | docs(parity): LINUX_PARITY_TODO 対応記録 + 引き継ぎ節 (SP-1〜5) |

### live-verify polish (本 session、3 commit)
| commit | 内容 |
|---|---|
| `72fefe0` | **fix(canvas)**: 大判ページ (842×595 横長解答用紙) を開いた/挿入直後に fit 表示。従来「100% 実寸・上揃え」だと狭い canvas で右端が切れ縦帯に見えた。`fit>=1` は実寸維持=回帰なし、`fit<1` は `user_scale=1 → zoom=fit` 全体フィット+中央。`crates/testruct-ui/src/canvas/mod.rs` pending_initial_view ブロック |
| `6644515` | **feat(packaging)**: アプリアイコンを新デザイン (Testruct タイル T) に差し替え。`packaging/appimage/hayate-kit-testruct.png` (256×256 RGBA、squircle 角丸透過)。build-appimage.sh は gen_icon.py を呼ばずこの PNG 配置ゆえ差し替えのみで反映 |
| `aeb1a69` | **feat(text-edit)**: 複数行編集 modal 下限拡大。`text_editor_dialog.rs` の PANEL_MIN_W 300→480 / BODY_MIN_H 50→180 / BODY_MAX_H 280→360 |

### 検証
- `cargo test --all-targets --no-fail-fast`: **462 passed / 0 failed** (社会 parity 3 件含む)
- codex 査読: fit-fix の境界連続性 (`fit==1.0` 連続)・中央寄せ・小文書回帰なし・MIN/MAX_USER_SCALE clamp 相互作用、4 点すべて問題なし
- user 実機 live-verify PASS (詳細 §B)

## §B. live-verify の顛末 (診断の教訓 = §D の memory 化根拠)

1. **入力窓が小さい** → modal 下限拡大 (`aeb1a69`) で対応。
2. **社会シートが「縦」に見える** を数 round 追跡。data (page_size)・export PNG・build 関数・replace_document すべて横 (842×595) を指し矛盾。
3. **真因 = autosave recovery の自動復元**。起動時 `~/.local/state/hayate-kit-testruct/recovery.testruct` (旧ビルド由来の「縦 A4 に横レイアウトが乗った壊れた社会シート」) が毎回復元され、それを「生成結果」と誤認していた。
4. paint に `pw/ph/fit/zoom` の eprintln を仕込み、user 実挿入で `page=842x595 zoom=0.518 orient=LANDSCAPE` を確認 → 生成経路は正常・見ていたのは復元 doc と切り分け。debug ログは land 前に除去済み (`fit-fix` commit に debug は含まれない)。
5. 壊れた recovery は **`/tmp/recovery-broken-portrait-shakai.bak` に退避済み** (work-PC ローカル、disposable)。→ **home-PC にも同種の壊れた recovery があれば同様に退避**して再検証すること (home-PC 側 `~/.local/state/hayate-kit-testruct/recovery.testruct` を確認)。

## §C. home-PC 再開手順

```bash
# 1. testruct を最新 main へ
cd ~/Documents/hayate-kit-testruct && git checkout main && git pull origin main   # → db1bc67

# 2. ★testruct-v3 (社会 golden の参照リポジトリ) を必ず更新 — でないと shakai_parity 3 件が
#    「golden テンプレートが読めない」で FAIL する (env-drift、logic regression ではない)
cd ~/Documents/testruct-v3 && git checkout master && git pull origin master        # → 364d3b9
ls templates/shakai_answer_sheet_*.testruct   # 3 件見えれば OK

# 3. 検証
cd ~/Documents/hayate-kit-testruct && cargo test -j1 --all-targets --no-fail-fast   # 462 passed / 0 failed 期待
cargo build -j1 -p testruct-ui

# 4. ★起動前に壊れた recovery を退避 (あれば)。放置すると起動時に縦の壊れた社会シートが復元される
[ -f ~/.local/state/hayate-kit-testruct/recovery.testruct ] && \
  mv ~/.local/state/hayate-kit-testruct/recovery.testruct /tmp/recovery-broken.bak

# 5. 起動して社会シート確認: メニュー「挿入」→「社会解答用紙 (県模試11月/6月2025/6月2024)」
#    → 横長で全体フィット表示されれば land 成功
./target/debug/hayate-kit-testruct
```

- worktree: work-PC では `hayate-kit-testruct-track1/2/3` を使用。track3 は本 session で使い parity-verify branch は削除済 (detached origin/main に復帰)。home-PC の worktree は各自の状態。
- GUI_kit は本 session 無変更 (`0e5e2b0` のまま)。

## §D. memory mirror (local-only ゆえ verbatim 転記 — home-PC で下記どおり反映すること)

memory は各 PC local。**既存 `feedback_state_dependent_runtime_trace` に case 2 を追記 + description 更新 + How to apply 手順 5 追加**。MEMORY.md 索引行は既存のまま (追記不要、MEMORY.md は既にサイズ上限超過)。home-PC では下記 full body で `feedback_state_dependent_runtime_trace.md` を **上書き**すること (case 2 と手順 5 が無ければ追記)。

### `memory/feedback_state_dependent_runtime_trace.md` (full body、verbatim)

```markdown
---
name: feedback_state_dependent_runtime_trace
description: 状態依存 feature の runtime trace は前提状態を固定し状態を trace に含める、でないと汚染で空振りする。auto-restore/recovery が「白紙起動」等の前提を黙って置換する点にも注意
metadata: 
  node_type: memory
  type: feedback
  originSessionId: fd8a3202-cfa1-45ea-a9ba-871cd3d54b1e
---

GUI app の mode/状態で挙動が変わる feature を runtime trace (eprintln) で調査する時は、初手で **(1) 前提状態を固定** (操作手順で「切替ボタンを押さない」等を明示) **(2) 状態自体を trace に含める** (`mode={}` 等)。

**Why (case 1)**: 2026-06-09 hayate-pdfview marquee bug 調査で 2 round 空振り。SinglePage 専用 feature を調べるのに、user が trace 採取前に ≣(mode切替) を押して Continuous に入っていた → press が別経路 (scrollview) に行き「on_drag 非発火」と誤読 → 原因層を downstream と誤判定。trace に mode が無く、前提状態 (SinglePage) も固定指示していなかったため、汚染に気づくのに 2 round 要した。最終的に実バグは SinglePage でなく Continuous の feature gap (未実装) だった = 調査が正常コードに向いていた。

**Why (case 2, 2026-07-09 hayate-kit-testruct 社会解答用紙 live-verify)**: 「解答用紙を生成すると用紙が縦になる」を数 round 追ったが、data (page_size)・export PNG・build 関数・replace_document すべて横 (842×595) を指し矛盾。真因は **アプリ起動時に autosave の recovery.testruct を自動復元する経路**で、その recovery が旧ビルド由来の「縦 A4 に横レイアウトが乗った壊れた社会シート」だった。私が引数なし起動を「白紙」と思い込み、毎回この壊れた縦シートが復元されて「生成結果」と誤認。paint に pw/ph/fit/zoom の eprintln を入れ、user に実挿入させて `page=842x595 zoom=0.518 orient=LANDSCAPE` を確認して初めて「生成経路は正常・見ていたのは復元 doc」と切り分いた。教訓: **live-verify の観測が code/export の ground-truth と矛盾したら、render バグと決める前に auto-restore (recovery/autosave/session 復元) が前提を置換していないか疑う**。起動 log の `[autosave] 復元` 行、実ロード doc の page_size/export での現物確認が切り分け手段。

**How to apply**:
1. trace 注入時、調査対象 feature が依存する状態 (mode/flag/focus) を ★最初の eprintln に必ず含める (`[trace] M0 enter mode={}` 等)。enum が Debug 未実装なら match→&str で出す (enum 非変更)。
2. user/PRESIDENT への操作手順依頼で ★前提状態を明示固定 (「≣ を押さず起動直後の SinglePage のまま」「▣ ON にしてから drag」等、再現に不要な状態遷移を禁止)。
3. log 解析時、★まず状態行を確認してから経路を読む (mode=想定外なら即 retest、誤った原因層判定に進まない)。
4. live verify (実装後の動作確認) でも同様に「mode 固定 + 操作手順明示」を踏襲。
5. ★観測が code/export の ground-truth と矛盾する時は、まず **前提の doc/state が本物か**を疑う: auto-restore (recovery/autosave/前回セッション復元) が「白紙起動」等の前提を黙って置換していないか。起動 log の復元メッセージ確認 + 実ロード doc を export/寸法照合で現物確認してから render バグ調査に入る (壊れた復元 doc は退避してクリーン状態で再検証)。

[[feedback_visual_validation_gap_pattern]] (worker は mouse 操作/目視不可ゆえ interactive trace 採取は user 依頼) と pair。runtime trace は [[feedback_root_cause_over_quick_fix]] の調査手段だが、状態汚染で誤層に誘導されると逆効果。
```

## §E. backlog / 次アクション候補 (未着手)

- **社会解答用紙 live-verify の残**: PDF 出力での社会シート横長確認 (今 session は screen のみ確認、PDF export 経路は未目視)。
- **社会専用プリセット拡充**: 現在 nov2024/june2025/june2024 の 3 preset。他月/他レイアウト追加は user 要望次第。科目欄は自由入力ゆえ「社会」以外の科目 (理科等) も blank builder から組める。
- **新アイコンの AppImage 反映確認**: `./scripts/build-appimage.sh` 再生成 → dock/ファイラでアイコン目視 (B-2 系 live-verify と同枠)。
- DTP roadmap ([[project_dtp_app_roadmap]]) の残: K9 text-alpha / Bold bundle / 約物・禁則 / 明朝 / P4 編集 / P6 解答用紙ビルダー。

## §F. commit/push 状態

- testruct: PR #99 squash-merge 済、main `db1bc67` origin 反映済。feature branch `track3/parity-ee5f49a-catchup` は origin 残置 (未削除、worktree 保全のため)。
- **本 handoff doc = testruct repo `docs/handoff-2026-07-09-testruct-shakai-live-verify.md` に commit + push** (revivals47/SSH で push 可能ゆえ home-PC が `git pull` で取得できる sync channel)。comms repo (Akira-Papa/Claude-Code-Communication) は origin push 権限が実質無く local-only ゆえ sync channel に使えない ([[feedback_handoff_hygiene_local_only_audit]] = プロジェクト repo に archive commit する前例に従う)。comms 側にも同一 doc の local copy を残置 (このPCの handoff ログ慣例と整合、未 push)。
- memory 変更 = local-only、§D に verbatim mirror 済 (home-PC で §D どおり反映)。
