# Handoff 2026-07-13 — PDF/SVG fidelity 補完 3 波完遂 + dock アイコン root-fix (work-PC → home-PC)

> **status: 確定 (session close 2026-07-13、work-PC `tlcr-X99E`)**。全成果 origin 反映済み。memory mirror を §D に外部化 (sync channel = 本 testruct repo、comms repo は push 不可)。

## §0. 30 秒サマリー

- **PDF/SVG export fidelity 補完を 3 波 dispatch で完遂**: 画面 ↔ PDF ↔ SVG が gradient / 真の opacity 合成 / blur 影 / 複数行揃え / 楕円形状のすべてで一致。
- 計 7 PR: testruct #100-#106 (6 本) + GUI_kit #331。**testruct main = `6d734e8` / GUI_kit main = `e9668ef`** / testruct-v3 master = `364d3b9` (無変更)。
- テスト 462 → **494 passed / 0 failed**、全工程 pre-existing fail ゼロ。負債ゼロ着地 (#104 の楕円影暫定特例は #106 で自己回収)。
- 前段で 2026-07-09 handoff §E backlog 1/2 も closure (社会シート PDF 横長 = PASS / AppImage 新アイコン = ビルド+目視 PASS)。

## §A. land 済み内容

| PR | repo | 内容 | 担当 |
|---|---|---|---|
| #100 `51c57cc` | testruct | dock アイコン root-fix: `with_app_id("hayate-kit-testruct")` + `scripts/install-desktop.sh` 新設 (GNOME は app_id ⇔ 同名 .desktop 照合、AppImage はホスト非統合が仕様) | PRESIDENT 直接 |
| #101 `909d87e` | testruct | SVG fidelity: native linear/radialGradient + `<g opacity>` + feGaussianBlur 影 + 複数行 per-line 揃え | worker1 |
| #102 `cc97992` | testruct | PDF 複数行 Center/End 根治: Start-shape → cosmic `rich_line_extents_aligned` 差分 shift 焼込、単一行 bit-exact、異常時 Start-safe degrade | worker3 |
| #103 `41fdb34` | testruct | PDF gradient (Type2/3 shading + stitching) + 真の opacity (Form XObject isolated transparency group + ca/CA)、半透明 stop = Luminosity SMask | worker2 |
| #104 `296ebb2` | testruct | PDF blur 影: RecordingPainter capture → CPU raster (黒地+白 coverage) → separable Gaussian → 1×1 base RGB + gray SMask (PDF に blur primitive 無ゆえ raster が正攻法) | worker2 |
| #105 `a9e761a` | testruct | 空行含む複数行 per-line 揃えの pin test (codex Low finding を非バグ確定で closure) | worker3 |
| #331 `e9668ef` | **GUI_kit** | `Renderer::fill_ellipse` 真楕円 primitive (K6 真 close)。既存 K4 GradientMask::Ellipse の単一 stop wrapper = 新 raster/GPU shader ゼロ (Option B、measure-first 補正)。golden 14/0 不変 | worker2 |
| #106 `6d734e8` | testruct | 楕円 parity Stage B: screen fill_ellipse の K6 内接円 fallback → 真楕円化 + #104 解析楕円特例の撤去 (負債消滅)。挙動ゲート = 正方形不変・扁平のみ変化 | worker2 |

### 検証
- `cargo test -j1 --all-targets --no-fail-fast`: **494 passed / 0 failed / 4 ignored** (baseline 462 から全増分が新規 test)
- merge gate = boss1 精読 + PRESIDENT session codex 第二意見の 2 段 (全 PR LGTM / blocking 0)。boss1 の codex CLI は権限却下 → user 裁定で自己査読 + PRESIDENT 側 codex 補強の体制
- visual evidence (repo commit 済、全て PRESIDENT も独立 view 済): `docs/svg-fidelity-verify/` `docs/pdf-align-verify/` `docs/pdf-gradient-verify/` `docs/pdf-blur-verify/` `docs/ellipse-parity-verify/`

## §B. 発見・教訓

1. **#104 の live-correct visual gate が pre-existing 可視 bug を捕捉**: screen の実線 (solid) 楕円は K6 内接円近似で**扁平時に円へ潰れていた** (`screen_painter.rs` 旧 fill_circle 経路)。PDF は bezier 真楕円ゆえ cross-backend 不一致。→ 第 3 波 (GUI_kit #331 + testruct #106) で root-fix。「unit-green ≠ live-correct」の再実証。
2. **premise 補正 2 回 (measure-first)**: Stage A で「新 CPU scanline + GPU SDF が要る」想定 → worker2 調査で「真楕円 raster は K4 で既存」と判明し薄 wrapper 化 (Option B)。#102 空行 Start-degrade 懸念も #105 で「両側対称スキップで実害なし」と確定。
3. **boss1 NG パターン再発**: codex 却下時の確認質問を pane 内 AskUserQuestion に留め user 直接介入を招いた (2026-05-13 sweep stall 再発形)。規範リマインド送付済み — blocker/確認質問は必ず `agent-send.sh president`。
4. **.gitignore 同一行競合**: #102 (`/artifacts/`) と #103 (`/verify`) が同一行追記で #103 が CONFLICTING → PRESIDENT 直接 union rebase + rebased 全数再検証 (487/0) 後 merge。並走 dispatch で「全 track が .gitignore に 1 行足す」形は競合源、以後 dispatch 文面で ignore 先を一元指定するか事前に用意すると良い。
5. **poppler "Mismatch between font type" 警告は pre-existing** (国語経路でも出る、描画影響なし、Stage 2b subset 埋込の FontFile3 subtype 宣言由来)。backlog 化。

## §C. home-PC 再開手順

```bash
# 1. testruct + GUI_kit を最新 main へ
cd ~/Documents/hayate-kit-testruct && git checkout main && git pull origin main   # → 6d734e8
cd ~/Documents/GUI_kit && git checkout main && git pull origin main               # → e9668ef

# 2. testruct-v3 は本 session 無変更 (364d3b9 のままで OK、2026-07-09 handoff §C 参照)

# 3. 検証 (494 passed / 0 failed / 4 ignored 期待)
cd ~/Documents/hayate-kit-testruct && cargo test -j1 --all-targets --no-fail-fast

# 4. (任意) dock アイコン統合を home-PC にも適用する場合
./scripts/build-appimage.sh          # release ビルド + AppImage 生成
./scripts/install-desktop.sh         # ~/.local へ .desktop + icon 導入
# → Activities「Testruct」から起動、dock が青タイル T になれば OK

# 5. 起動前の壊れ recovery 退避 (2026-07-09 handoff §B/§C の注意は継続有効)
[ -f ~/.local/state/hayate-kit-testruct/recovery.testruct ] && \
  mv ~/.local/state/hayate-kit-testruct/recovery.testruct /tmp/recovery-broken.bak
```

- worktree (work-PC): testruct-track1/2/3 + GUI_kit-track2 は全て merge 済 branch で clean・hands-off。home-PC の worktree は各自の状態。
- work-PC の testruct 直下 `target-baseline/` は boss1 の baseline 検証用使い捨て target dir (untracked、無視可・削除可)。
- GUI_kit の stash 6 件は既知の旧 named stray (本 session 無変更)。comms repo local-only commit (ahead) も従来どおり (push 権限なし、sync は本 doc)。

## §D. memory mirror (local-only ゆえ verbatim 転記 — home-PC で下記どおり反映すること)

**`memory/project_dtp_app_roadmap.md` に 2026-07-13 節を追記** (それ以外の本文は 2026-06-24 時点から無変更)。home-PC では下記 block を **`## 🎯 2026-05-26 境界確定` heading の直前に挿入**すること (既に 2026-07-13 節があれば上書き)。MEMORY.md 索引行は既存のまま (追記不要、サイズ上限超過中)。

### 挿入 block (verbatim)

```markdown
## ⚡ 2026-07-13 PDF/SVG fidelity 補完 + 楕円 parity 完遂 (work-PC、boss1 dispatch 3 波)

**台帳「PDF/SVG 描画 fidelity fallback」系統 gap を全 closure** (testruct #101-#106 + GUI_kit #331 の 7 PR、testruct main=`6d734e8` / GUI_kit main=`e9668ef`)。前段で backlog 1/2 (社会シート PDF 横長 live-verify PASS / AppImage 新アイコン) + dock アイコン root-fix (#100 = `with_app_id` + `scripts/install-desktop.sh`、GNOME は app_id⇔同名 .desktop 照合) も closure。

- **第1波 (3 worker 並走、file disjoint 設計)**: #101 SVG (native gradient/g opacity/feGaussianBlur/per-line 揃え) / #102 PDF per-line 揃え (Start-shape→cosmic `rich_line_extents_aligned` 差分 shift 焼込、単一行 bit-exact、異常時 Start-safe degrade) / #103 PDF gradient+opacity (Type2/3 shading + stitching、Form XObject isolated transparency group + ca/CA、半透明 stop = Luminosity SMask)。
- **第2波**: #104 PDF blur 影 = RecordingPainter capture → CPU raster (黒地+白 silhouette 2値 coverage、transparent-dst 非依存) → separable Gaussian → 1×1 base RGB + gray SMask。PDF に blur primitive 無ゆえ raster が正攻法。
- **第3波 (楕円 parity、#104 visual gate が surface した pre-existing 可視 gap)**: screen 実線楕円が K6 内接円近似で扁平時に円へ潰れる → Stage A GUI_kit #331 `Renderer::fill_ellipse` (既存 K4 GradientMask::Ellipse の単一 stop wrapper = 新 raster/shader ゼロ、Option B へ measure-first 補正) + Stage B testruct #106 (内接円 fallback 差替え + #104 解析楕円特例の撤去=負債消滅)。solid 楕円が screen/PDF/SVG 全 backend 同形状に。
- **merge gate**: boss1 精読 + PRESIDENT session codex 第二意見 (user 裁定: boss1 の codex CLI 却下→自己査読、PRESIDENT 側 codex で補強)。全 PR LGTM/blocking 0。テスト 462→494 passed / 0 fail。#105 = 空行 per-line pin test (codex Low を非バグ確定で closure)。
- **運用 note**: boss1 が確認質問を pane 内 AskUserQuestion に留め user 直接介入を招く NG パターン再発 → 規範リマインド済。.gitignore 同一行追記で #103 が CONFLICTING → PRESIDENT 直接 union rebase + 全数再検証 487/0 後 merge。
- **残 backlog (次 sweep、低優先)**: #103 form resources 実参照絞り / blur_guard stroke 系 assert / dead-code 3 件 (fill_color 等) / poppler "Mismatch between font type" 警告 (pre-existing、FontFile3 subtype 宣言)。REMAINING-TASKS.md の大物残 = 右クリック context menu / K-track 実機較正 3 点 (影 σ / linear blend / VK 目視) / 編集 modal スタイル反映 / rich run・ruby 編集面 / 約物・禁則精緻化。
```

## §E. backlog / 次アクション候補 (未着手)

- **次 sweep (低優先、boss1 保持)**: #103 form resources 実参照絞り / #104 blur_guard の stroke 系 op assert 追加 / dead-code warning 3 件 (fill_color / build_vertical_segments / draw_vertical_layout) / poppler font subtype 警告の整合。
- **K-track 実機較正 3 点** (REMAINING-TASKS.md §3b、user 実機): 影 blur σ 較正 (SHADOW_BLUR_TO_SIGMA=0.5) / linear blend 時の blur skip / VK 実機 visual (gradient/半透明/blur)。
- **REMAINING-TASKS.md の大物残**: 右クリック context menu (台帳唯一の ❌) / 編集 modal のスタイル反映 (kit K-f 待ち) / rich run・ruby の編集面対応 / 縦書き約物・禁則精緻化 / DTP roadmap 残 (Bold bundle / 明朝 / P6 拡充)。
- 2026-07-09 handoff §E の「社会プリセット拡充」は user 要望次第で継続。

## §F. commit/push 状態

- testruct: #100-#106 全 squash-merge 済、main `6d734e8` origin 反映済。**本 handoff doc も testruct repo に commit + push** (user 指示による session close、docs-only 直 push は本会話で pre-flag 済)。
- GUI_kit: #331 squash-merge 済、main `e9668ef` origin 反映済。tree clean (stash 6 件は既知 stray、無変更)。
- comms repo (Claude-Code-Communication): 同一 doc の local copy を残置 (push 不可ゆえ未 push、従来慣例どおり)。
- memory 変更 = local-only、§D に verbatim mirror 済 (home-PC で §D どおり反映)。
