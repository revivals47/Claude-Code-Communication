# track-golden-rebless step 3 — env-diff (single-PC 認知反映)

base: track-golden/rebless @ origin/main 64fb117 起点
date: 2026-05-07
status: **single-PC 運用確定 ((X) 採用、PRESIDENT (P4) で (c) 採用方針確定)、step 4 PRESIDENT 確認 materials draft 兼用**

## (1) 前提整理

### 認知の更新 (memory `reference_dual_pc_setup.md` v2 反映)
- 旧 dual-PC 仕様 (work-PC tlcr + home-PC ken) は撤回、**single-PC tlcr 運用**確定
- 全 worker (boss1 / worker1 / worker2 / worker3) は work-PC tlcr 上の tmux multiagent pane で動作
- ken machine 物理存否は不明、ssh access 不能、現運用には不影響
- 段階 a/b 区別は role/cadence (高頻度 build smoke vs 低頻度厳格 test) に意味分化、物理 machine ではない

### 確定事実 (step 1 / 2)
- 5/5 consumer (label / button / vstack / window_frame_w10 / window_frame_w95) の work-PC tlcr 現観測 = PR #70 commit f4d563e 記載の bless 前 delta と完全一致
- renderer = CPU rasterizer (cosmic-text 0.18.2 + swash + tiny-skia 0.11)
- Vulkan 不在は false lead (CPU path は Vulkan を通過しない)
- libfreetype version は不影響 (cosmic-text + swash は pure Rust、freetype 不使用)

## (2) work-PC tlcr 単一 env factor (確定)

| factor | value | 出典 |
|---|---|---|
| OS | Ubuntu 24.04.4 LTS (noble) | `lsb_release -a` |
| kernel | 6.11.0-17-generic | `uname -r` |
| rustc | 1.94.1 (e408947bf 2026-03-25) | `rustc -V` |
| cargo | 1.94.1 (29ea6fb6a 2026-03-24) | `cargo -V` |
| LANG / LANGUAGE | ja_JP.UTF-8 / ja_JP:ja | `locale` |
| Session / Desktop | wayland / ubuntu:GNOME | `XDG_*` |
| fonts-noto-cjk | 1:20230817+repack1-3 | `dpkg -l fonts-noto-cjk` |
| NotoSansCJK-Regular.ttc size | 19,484,784 bytes | `ls -lL` |
| NotoSansCJK-Regular.ttc mtime | 2023-08-21 | `ls -lL` |
| NotoSansCJK-Regular.ttc fontversion | 131334 | `fc-match -v sans-serif` |
| NotoSansCJK-Regular.ttc ttc index | 0 | `fc-match -v sans-serif` |
| **NotoSansCJK-Regular.ttc sha256** | **b76b0433203017ca80401b2ee0dd69350349871c4b19d504c34dbdd80541690a** | `sha256sum` |
| libfreetype6 | 2.13.2+dfsg-1ubuntu0.1 | (不影響、参考) |
| fontconfig | 2.15.0-1.1ubuntu2 | font discovery 経路 |
| GPU | NVIDIA GeForce GTX 750 (Maxwell GM107) | (不影響、参考) |
| Vulkan SDK / runtime | 不在 | (不影響、参考) |
| user fontconfig override | (`~/.config/fontconfig/` 不在、`~/.fonts.conf` 不在) | step 2 collect-env.sh 確認済 |

実 dump: `workspace/track-golden/env-tlcr-20260507.txt` (79 行、再現性確保済)

## (3) ken 仮説欄 (single-PC 認知下では空欄、撤回済)

| factor | ken 仮説値 | 撤回理由 |
|---|---|---|
| 物理 machine | (旧仮説) /home/ken/Documents/GUI_kit | (X) 採用で物理存否不明、現運用不影響 |
| ssh alias | (旧仮説) optional | 不要 |
| user override | (旧仮説) 不明 | 取得手段なし |
| ttc sha256 | (旧仮説) 不明 | 取得手段なし、bless source 候補から (ii) 除外 |

## (4) bless source 候補 3 件追跡

(P4) で boss1 dispatch された候補:

### (i) 過去異 fontconfig / ttc 設定 — **plausible**

PR #70 merge = 2026-04-29 00:33 JST、現在 2026-05-07 (約 8 日経過)。この期間に work-PC tlcr の env factor が変動した可能性:

| sub-factor | 変動可能性 | 検証手段 |
|---|---|---|
| fonts-noto-cjk apt 更新 | 低 (ttc mtime 2023-08-21 不変、apt package 1:20230817+repack1-3 noble 標準) | `grep "fonts-noto-cjk" /var/log/apt/history.log*` |
| libfreetype6 / fontconfig apt 更新 | 中 (ubuntu noble の routine update 可能性) | 同上 |
| user-level fontconfig override | 低 (現状 `~/.config/fontconfig/` 不在) | 既確認 |
| GNOME / desktop font setting | 低 (default Noto Sans CJK JP のまま) | `gsettings get org.gnome.desktop.interface font-name` 等で確認可能 |
| rustc minor diff | 低 (本 worker session が 1.94.1、PR #70 当時の同 minor 想定) | rustup history 確認可能 |

PR #70 commit message に `cargo test --lib --no-fail-fast -j 1 → 1153 passed` の verification 記録あり。track-ime PR #72 merge 前の lib test count は 1153 仮定、merge 後は 1159 = 私の +6 件と完全一致。**当時の work-PC tlcr で実行された確度高**。

PR #70 当時 work-PC tlcr で `cargo test --test golden_widgets` が 8 passed (no BLESS) を達成したのに、現 work-PC tlcr で同 commit の golden が 5/5 fail = **8 日間の env 変動が原因**である可能性大。

### (ii) 過去 ken machine 物理存在仮説 — **却下** ((P4) (X) 採用で消滅)

memory `reference_dual_pc_setup.md` v2 で「2026-05-07 認識訂正 (旧 dual-PC 撤回)」確定、ken 物理存在を bless source 候補から除外。

### (iii) CI 環境 — **不可能**

memory `reference_github_actions_no_credit.md` 既登録: revivals47 GitHub Actions credit 不在、PR CI は setup レベルで即死、コード問題ではなく環境問題。CI で `GOLDEN_BLESS=1 cargo test` が走った実績はない、bless source ではない。

### 推定結論

bless source = **(i) 過去 work-PC tlcr 自体の env 変動**。具体 factor は apt history / GNOME setting / rustc history を spot check すれば特定可能だが、**(c) work-PC 系再 bless 採用方針確定により詳細特定は不要** (現 work-PC 環境で再 bless すれば mismatch 0 達成、bless source の正確な再現は不要)。

## (5) bless 採用方針 (c) work-PC 系再 bless — 影響評価

### 実行手順 (step 4 PRESIDENT 確認後)

```
cd ~/Documents/GUI_kit-track-golden
GOLDEN_BLESS=1 cargo test --test golden_widgets --no-fail-fast
git add tests/goldens/win10/{button_default,vstack_default,label_default,window_frame_default}.golden
git add tests/goldens/win95/window_frame_default.golden
git status
git diff --stat
git commit -m "test(golden): re-bless 5 widget goldens to current work-PC tlcr env (single-PC 運用)"
git push -u origin track-golden/rebless
gh pr create --base main --head track-golden/rebless --title "test(golden): re-bless 5 widget goldens to current work-PC tlcr env" ...
```

注意点:
- `cargo test --test golden_widgets` (integration test target、`--lib` ではない)
- bless 後 `git diff --stat` で 5 件 binary `.golden` のみ更新確認 (code 不変)
- `cargo test --test golden_widgets --no-fail-fast` で再実行 (no BLESS) して全件緑確認

### 影響範囲

| 項目 | 影響 |
|---|---|
| 更新 file | 5 件 (`tests/goldens/{win10,win95}/*.golden`) のみ、code 不変 |
| test 数 | golden_widgets 8 件中 3 passed → 8 passed (5 件回復) |
| lib / integration tests | 不影響 (1331 passed 維持) |
| TextAreaWidget public API | 不影響 (touch なし) |
| examples | 不影響 |
| 既存 PR #69 / #70 のロジック | 無効化されない (bless 履歴の継続更新、循環ではない = single-PC 認知確定後の最終 bless) |

### リスク評価

| リスク | 発生条件 | 軽減策 |
|---|---|---|
| 将来の work-PC tlcr env 変動で再 mismatch | apt update / dist-upgrade / GNOME font 設定変更 | env-tlcr-20260507.txt を baseline として保持、変動時は再 bless or env 戻し判断 |
| 別 env (将来の ken machine 整備、CI 再開) で mismatch | 物理 ken / CI が後で実在化 | (X) 採用前提では不問、整備時に (b) env-specific subset へ拡張選択肢 |
| commit message 内の env factor 記録不足で再現困難 | 雑な commit message | step 4 で env-tlcr-20260507.txt sha256 + fonts-noto-cjk version + cosmic-text version を commit message に明記 |
| bless 元と現観測の dimension mismatch | widget layout 変更 | PR #70 commit message で「File sizes unchanged (Bin 7694 / 6414 / 19214 / 64014 / 64014) — only pixel content updated, no dimension shift」と記録あり、現状も dimension 不変想定 |

### single-PC 運用認知下での妥当性

memory `reference_dual_pc_setup.md` v2 確定により「multi-environment 反証レイヤ」失効、段階 b retained check は role/cadence で意味分化済 = TextAreaWidget public API caller の厳格 test 経路として継続有効。golden_widgets は段階 a (build smoke) 範囲、single-PC 認知下で work-PC env 固定 bless が論理整合。

## (6) step 4 PRESIDENT 確認 materials

### 提示する判断項目
1. 採用方針 (c) work-PC 系再 bless の確認 — 実行 → PR → merge の流れで OK?
2. commit message format (env factor 記録粒度) — どこまで詳細に書くか?
3. PR description (Out of scope, Test plan) のテンプレ — track-ime PR #72 と同 format で OK?
4. 段階 a 範囲確認 — golden_widgets re-bless は段階 a 範囲、段階 b retained check 通過不要で OK?

### 想定 return 形式
- (c) GO + commit message format 指示 + PR template 指示 = step 4 即実行
- 別案検討要 = step 3 doc を再修正、(b) env-specific golden subset 等再評価

## (7) 隠れ原因 cross-check (codex 監査 v6 反映、2026-05-07)

PRESIDENT v6 codex 監査で「8 日間 work-PC tlcr env 変動」推定の sufficient 性が問われ、隠れ原因 4 件を cross-check した結果。

| # | 候補 | 現状値 (work-PC tlcr) | 8 日間変動可能性 | 影響推定 | 引用 evidence |
|---|------|----------------------|-----------------|----------|--------------|
| 1 | fontconfig / freetype / harfbuzz / fribidi version | fontconfig 2.15.0-1.1ubuntu2 / libfreetype6 2.13.2+dfsg-1ubuntu0.1 / libharfbuzz0b 8.3.0-2build2 / libfribidi0 1.0.13-3build1 | **package 自体は不変** (apt history.log + history.log.1.gz で 2026-04-28 以降 font 関連 update なし) | 不影響 (package) / **高 (cache)** | `/var/log/apt/history.log` grep "Start-Date" 全件確認 |
| 1' | **fontconfig user cache 再生成** | `~/.cache/fontconfig/0bd3dc09...le64.cache-11` mtime **2026-05-07 15:55** | **本日再生成** (PR #70 merge 2026-04-29 以降に再生成された痕跡) | **高 (主因候補)** | `ls -la ~/.cache/fontconfig/` |
| 2 | Vulkan / mesa / driver | libvulkan1 1.3.275.0-1build1 (loader inst、tools 不在) / nvidia-firmware-580 install 2026-05-07 15:26 | nvidia-firmware は install 履歴あり、cosmic-text + swash + tiny-skia の Renderer::Cpu path は GPU/Vulkan 不通過で不影響 | **不影響** | step 2 finding (CPU rasterizer 確定 @ src/testing/mod.rs:161) |
| 3 | locale / timezone / DPI / scale | LANG ja_JP.UTF-8 / TZ Asia/Tokyo NTP active / GNOME text-scaling 1.0 / scaling-factor 0 (auto) / Xft.dpi 96 default | NTP 時計は安定、GNOME default 値で stable、scaling 設定は user override なし | **不影響** | `timedatectl status` / `gsettings get` |
| 4 | test ordering / nondeterministic timing | `cargo test --test golden_widgets` 3 回連続実行で 5 件 mismatch の **pixel diff 数値 + max channel delta が完全 deterministic** | run 1/2/3 で test order だけ変動 (test runner parallel)、結果は不変 | **不影響 (deterministic 確定)** | run 1/2/3 stdout 比較、本 doc § 7 末尾参照 |

### dominant cause 更新

step 3 暫定結論「(i) 8 日間 work-PC tlcr env 変動」は方向性は正しいが、**具体実体として「2026-05-07 15:55 fontconfig user cache 再生成」が主因候補**として浮上。nvidia-firmware-580 install (15:26) のトリガーで GNOME / fontconfig が cache を rebuild した可能性高。

cosmic-text の `FontSystem::new()` は内部で fontdb::Database::load_system_fonts() を呼び、OS の fontconfig cache (`FC_CACHEDIR` = `~/.cache/fontconfig/`) から system font の priority chain を構築。cache rebuild で priority chain や font fallback 解決順序が微変動すると、同一 ttc を選んでも cosmic-text に渡される font の glyph metrics / hinting 計算が変わり pixel level で異なる結果に。

**evidence 強度評価**:
- 強: cache mtime 2026-05-07 15:55 の事実 (一次)、PR #70 merge 2026-04-29 以降に rebuild されたことの timestamp による証明
- 中: nvidia-firmware install (15:26) との causal link (隣接時刻、ただし strict causality は別途実験要)
- 弱: 5 件 golden mismatch の pattern (124/178, 314/255, 58/178, 637/192, 198/250) と font fallback chain 変動の対応関係 (詳細解析は scope 外)

### bless source 候補 (i) の確度更新

`workspace/track-golden/env-diff.md` § 4 の (i) 過去異 fontconfig / ttc 設定 = **plausible** → cross-check で **likely** に強化。fontconfig package 自体は不変だが user cache が rebuild された timing と本日 worker2 観測の golden mismatch が整合。

### test ordering / nondeterminism 否定 (確定)

3 連続 run で同 5 件、同 pixel diff、同 max channel delta = **deterministic 確定**。cosmic-text + swash + tiny-skia の rendering pipeline は env input が同じなら出力同じ。env input の差異 (cache rebuild) が一義的に観測 mismatch を決めている。

## (8) golden input normalization 評価 (codex 推奨対策 1)

codex 推奨対策 1: golden input normalization (font / DPI / scale を test 内で fixed seed 化)。

### 実装 candidates 評価

| 候補 | 実装内容 | scope | 効果 | 即時実装可否 |
|------|---------|-------|------|--------------|
| (i) Renderer init で固定値注入 | WidgetTestHarness に DPI / scale 固定 param 追加、test fixture で 1.0 scale を強制 | 小 (~50 行) | **限定的** (DPI / scale は既に default、本問題の主因 cache rebuild には効かない) | ✅ 即時可、ただし効果薄 |
| (ii) bundled font + cosmic-text FontSystem 強制差替え | tests/fixtures/fonts/ に Noto Sans CJK JP 固定 version の ttc を repo 内配置、test で `FontSystem::new_with_locale_and_db(fontdb::Database::load_fonts_from_dir())` を強制 | **大** (300-500 行 + 19MB binary fixture + license header + 既存 widget paint code 全箇所で test 用 FontSystem 注入 hook) | **真の解** (env 依存完全排除、cache rebuild 影響ゼロ) | ❌ 即時不可、別 track 化 |
| (iii) test config で env-specific golden 切替 | `tests/goldens/win10/button_default.{env_id}.golden` のような env_id-based naming + 起動時 env 検出 | 中 (~150 行) | 部分解 (env 識別が確定的なら緑化、新 env で再 bless 必要) | ⚠️ 中規模、別 track が現実的 |

### 即時実装可否判断

**結論: 後続 sprint 化** (Stage 4 round 直後の sprint で別 track 着手)。

理由:
- (i) のみ即時実装可能だが、本問題 (cache rebuild) には効かない = ROI 低い
- (ii) が真の解だが scope 大 (300-500 行 + 19MB fixture + license + paint code 全変更)、本 PR (5 件 .golden 再 bless) と scope が乖離しすぎる
- (iii) は scope 中だがダブル管理コスト + env_id 確定方法に discipline 要、PRESIDENT 判断 (b) env-specific golden subset 採用時に併用検討

### 別 track 化 sketch (将来 sprint で着手)

**track 名候補**: `track-golden/normalization` または `track-testing/font-fixture`

**deliverable**:
1. `tests/fixtures/fonts/` 新規、Noto Sans CJK JP の特定 version ttc を repo 内配置 (license: SIL Open Font License、~19MB)
2. `src/testing/mod.rs` に `WidgetTestHarness::with_test_fonts()` builder 追加、test 用 FontSystem を inject
3. `tests/golden_widgets.rs` 全 8 件で `with_test_fonts()` を使うよう書き換え
4. `GOLDEN_BLESS=1` で固定 fixture 経由の新 golden 生成 → main merge
5. 既存 system font 経由 path は examples / 実 app では維持、test path のみ fixture 強制

**ETA**: 3-5d (license 確認 / 既存 paint code 全箇所の hook 注入が大半)

**risk**:
- repo size +19MB (binary、acceptable)
- cosmic-text FontSystem の test 用 inject hook を public API or `pub(crate)` で追加要、Section B (TextAreaWidget public API 不変) は維持可能

### 本 PR (track-golden/rebless step 4) では含めない

normalization 即時実装は scope creep、本 PR は (c) 採用方針通り「5 件再 bless + env 記録 commit message + cross-check section 含む env-diff.md」に絞る。normalization は別 track として PRESIDENT 判断後に Stage 4 round 直後の sprint で着手。

## (9) 関連 file index

- workspace/track-golden/step1-finding.md (PR #70 メタデータ + 5/5 完全一致 finding)
- workspace/track-golden/step2-finding.md (renderer path + work-PC env + 仮説 H1-H4)
- workspace/track-golden/collect-env.sh (両 PC で同手順実行できる env collector script)
- workspace/track-golden/env-tlcr-20260507.txt (tlcr 実 dump、79 行)
- workspace/track-golden/bless-policy-options.md (4 候補影響評価、(P4) 確定で (c) lock)
- workspace/track-golden/env-diff.md (本 file、step 4 materials 兼用)
