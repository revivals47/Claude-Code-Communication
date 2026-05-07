# track-golden-rebless step 2 — pixel mismatch root cause 特定 (worker2 work-PC tlcr)

base: track-golden/rebless @ origin/main 64fb117 起点
date: 2026-05-07

## (1) renderer path 確定

| layer | crate / module |
|---|---|
| harness | `src/testing/mod.rs` `WidgetTestHarness::paint()` (line 157) |
| canvas | CPU only (`Renderer::Cpu`、line 161) |
| widget paint | `widget.paint(&mut renderer, rect)` |
| text shaping | `cosmic-text 0.18.2` (`FontSystem::new()` @ src/render/text.rs:263) |
| glyph rasterizer | `swash` (cosmic-text の SwashCache、src/render/text.rs:574) |
| canvas blit | `tiny-skia 0.11` |

→ **CPU rasterizer 確定**、Vulkan path は不通過。Vulkan 不在は本 issue の root cause ではない。

`FontSystem::new()` は cosmic-text default ctor、内部で `fontdb::Database::load_system_fonts()` を呼んで OS fontconfig 経由でシステム font を全 load する = **env-specific font discovery**。

bundled fonts (`assets/fonts/`) は BDF (Misaki / Shinonome / Spleen) のみで retro テーマ用、cosmic-text TTF/OTF rendering path とは無関係。

## (2) work-PC tlcr 詳細 env factor

| factor | value | 備考 |
|---|---|---|
| OS | Ubuntu 24.04.4 LTS (noble) | |
| kernel | 6.11.0-17-generic | |
| rustc | 1.94.1 (e408947bf 2026-03-25) | |
| cargo | 1.94.1 (29ea6fb6a 2026-03-24) | |
| LANG / LANGUAGE | ja_JP.UTF-8 / ja_JP:ja | |
| Session / Desktop | wayland / ubuntu:GNOME | |
| **fonts-noto-cjk** | **1:20230817+repack1-3** | apt package version |
| NotoSansCJK-Regular.ttc | 19,484,784 bytes (mtime 2023-08-21) | file size + mtime |
| fontconfig sans-serif resolve | Noto Sans CJK JP / fontversion 131334 / ttc index 0 | `fc-match -v sans-serif` |
| **libfreetype6** | **2.13.2+dfsg-1ubuntu0.1** | cosmic-text は freetype 不使用 (pure Rust) |
| **fontconfig** | **2.15.0-1.1ubuntu2** | font discovery / priority に影響 |
| GPU | NVIDIA GeForce GTX 750 (Maxwell GM107) | rendering path 不通過 |
| Vulkan SDK / runtime | 不在 | rendering path 不通過 |
| mesa-utils | 9.0.0-2 | mesa 経由不通過 |

## (3) factor 影響度評価 (CPU rasterizer 前提)

| factor | 影響 | 根拠 |
|---|---|---|
| GPU / Vulkan | **不影響** | Renderer::Cpu 確定、GPU path 不通過 |
| libfreetype version | **不影響** (推定) | cosmic-text + swash は pure Rust rasterizer、freetype 経由 dependency なし |
| **font binary content** | **高** | NotoSansCJK-Regular.ttc の minor patch / repack 差で glyph metrics / hinting 微差発生可能 |
| **fontconfig 構成** | **中-高** | sans-serif resolve 順序、cosmic-text が選ぶ family chain が変動 |
| **fonts-noto-cjk apt version** | **中** | apt package version 一致なら ttc file content 一致 (ubuntu repo の deterministic build 仮定) |
| cosmic-text version | 不影響 | Cargo.lock fix で両 PC 同一 |
| swash version | 不影響 | 同上 |
| tiny-skia version | 不影響 | 同上 |
| rustc version | **低-中** | 同 1.94.1 で一致なら不影響、minor diff があれば codegen 差で影響可能性 |
| LANG / locale | **低** | text 内容は test fixture で固定、locale-dep 機能 (number format 等) 経路にあれば影響 |

## (4) 主要仮説 (work-PC では mismatch が出る理由)

複数仮説を優先順位順に列挙:

(H1) **fontconfig priority 差**: work-PC と home-PC で `fc-match sans-serif` の resolve 結果 (family chain) が異なる。両 PC で同 Noto Sans CJK JP に解決されても、fallback chain の順序差で composite glyph (e.g. accented characters) で異なる pixel。

(H2) **fonts-noto-cjk version 差**: home-PC が異なる version (例: noble 以外 / dist-upgrade 差) を持つ場合、ttc binary 自体が異なり glyph 微差。fc-match の fontversion 値で判別可能。

(H3) **GNOME / fontconfig user override**: ~/.config/fontconfig / ~/.fonts.conf 等で user-specific font hinting / antialiasing 設定がある場合、cosmic-text fontdb 経由で間接影響可能 (要調査)。

(H4) **rustc minor diff**: home-PC の rustc 1.94 系で patch 番号が違うと、cosmic-text / swash 内の sub-pixel positioning 計算 codegen が変わる可能性 (低、確認は必要)。

## (5) home-PC ken から取得すべき env factor (boss1 → worker3 経由)

worker3 経由で取得する因子 (step 1 で boss1 dispatch 確定):
- `rustc -V` / `cargo -V`
- `locale | head -5` (LANG / LANGUAGE / LC_CTYPE)
- `echo $XDG_SESSION_TYPE / $WAYLAND_DISPLAY / $XDG_CURRENT_DESKTOP`
- `fc-match -v sans-serif` (family / fullname / file / index / fontversion)
- `dpkg -l fonts-noto-cjk fonts-noto-cjk-extra | grep ^ii`
- `dpkg -l libfreetype6 fontconfig | grep ^ii`
- `lsb_release -a`
- `uname -r`
- `lspci -nnk | grep -A2 -iE "vga|3d"`
- `vulkaninfo --summary 2>&1 | grep -E "deviceName|driverName" || echo "vulkaninfo not installed"`
- `find /usr/share/fonts -name "NotoSansCJK-Regular.ttc" -exec ls -lL {} \;` (file size + mtime 比較用)
- (任意、決定的) `sha256sum /usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc` (ttc binary 完全一致確認)
- `ls -la ~/.config/fontconfig/ ~/.fonts.conf 2>/dev/null` (user override 確認)
- `cd ~/Documents/<homepc-worktree> && cargo test --test golden_widgets --no-fail-fast 2>&1 | grep "differing"` (home-PC 現観測値、bless せず)

cargo test は worker3 P3 verify cadence と分散調整、boss1 dispatch 通り。

## (6) step 3 (env-diff doc) ドラフト方針

step 3 では home-PC ken 結果が来た後に dual-PC factor table を完成させ、(H1)-(H4) のうち各 factor で説明可能 / 不能を記録。

bless 採用方針 (a)-(d) に対する materials:
- (a) lenient threshold = test sensitivity 低下、glyph 微差を許容するなら 178/192/250 max delta level 許容必要 = font glyph anti-alias 全境界が許容範囲、fail 検知能力大幅低下
- (b) env-specific golden subset = 両 PC 緑、ただし dual golden 管理 + bless 時の env 明示 + CI host との整合 (revivals47 GitHub Actions credit 不在 memory 既登録 = CI gate なし、両 PC ローカル運用前提)
- (c) work-PC default 再 bless = work-PC で再 bless、home-PC ken で再 mismatch 循環 (loop 化)
- (d) home-PC default 維持 = PR #70 状態 hold、work-PC で env を home-PC 側に揃える

(d) の環境揃えは ttc binary 一致 + fontconfig priority 一致 + cosmic-text shaping 同条件、技術的に再現可能だが work-PC daily 運用との整合がコスト。

## (7) step 2 結論 (worker2 暫定)

- pixel mismatch の root cause は **font discovery + font binary content の env-specific 差**である確度が極めて高い
- Vulkan 不在 / freetype version は false lead
- 決定的な指標は **NotoSansCJK-Regular.ttc の sha256 一致 / 不一致** (両 PC で取得)
- 副次的に fontconfig user override / fc-match resolve chain の差を確認

home-PC ken 結果待ち、step 3 着手は boss1 GO 後。
