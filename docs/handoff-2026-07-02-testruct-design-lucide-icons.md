# Handoff 2026-07-02 (work-PC) — testruct 脱チープ (面階層 + Lucide アイコン)

work-PC セッション続き。crash 復帰後のメニューバー修正 (別 handoff) に続き、user「まだダサい・アイコンかな」から testruct のデザイン深化を実施・land。

## ★現 HEAD (home-PC で pull して一致確認)
- **GUI_kit** main = **`4bfd194`** (PR#319 squash-merge)
- **hayate-kit-testruct** main = **`7ce8032`** (PR#82 squash-merge)
- **Claude-Code-Communication** = 本 doc commit 後の HEAD (`git push userfork main`、origin=Akira-Papa read-only)

## 本セッションの成果 (land 済)
初期化イニシアチブ [[project_testruct_design_system_initiative]] の続伸。実機診断で真因 2 つを接地:
1. **面階層がフラット** (token はあるが surface 値が近すぎ + elevation 無し) → matte を (235,238,244) に沈め raised を (252,253,255) に開き差 ~17/ch。widget preset 20 個の旧値ハードコピー drift を是正 (raised 一括 252 + 上部 chrome 白統一)。GROUP アイコン outline 化。
2. **アイコンのチープさ = primitive 天井** (旧 IconCommand カーブ無し + stair-step) → **Lucide 採用**、AA ベクターアイコン基盤新設。`Renderer::draw_vector_icon` (tiny-skia AA ラスタライズ→draw_image で CPU/Vulkan パリティ)、SVG `d` パーサ (arc→cubic)、`widget::lucide` 19 icon、ToolbarWidget 配線。

検証: GUI_kit test **2464緑**/testruct 緑・0 fail (golden 無影響)、codex 査読済 (面階層 LGTM + アイコン ImageKey 衝突根治)、**GPU 実機 user 確認済**。

残 P2 (別 pass、gallery 目視要): recessed control tone (scrollbar/progress/spin/tab-bar が 245 のまま) + ハードコード border 214,218,226 掃除。旧 IconCommand editor 定数 dead 化 (削除は別 cleanup)。

## ★memory mirror (canonical=work-PC、home-PC の memory/ へ反映)

### 新規 1 件: `reference_guikit_vector_icon_pipeline.md` (full body verbatim)

```markdown
---
name: reference_guikit_vector_icon_pipeline
description: GUI_kit の AA Lucide ベクターアイコン基盤 (draw_vector_icon)。アイコン追加・GPU パリティ手法
metadata:
  type: reference
---

**2026-07-02 新設** (GUI_kit PR#319、main `4bfd194`)。旧 `hayate_kit::widget::icon` の `IconCommand` (Line/Rect/Disc/Circle、カーブ無し + 斜線 stair-step = ギザギザのチープ線画) を置換する、アンチエイリアス済みベクターアイコン基盤。

**API**: `Renderer::draw_vector_icon(rect, &VectorIcon, (r,g,b,a))` (hayate-platform、`render::vector_icon.rs`)。`VectorIcon { id: u32, elems: &[SvgEl], stroke_w: f32 }`。`SvgEl` = `Path(&str SVG d文字列)` / `Circle` / `Line` / `Rect(x,y,w,h,rx)` / `Polyline`。

**アイコンの足し方**: Lucide (lucide.dev、ISC ライセンス) の SVG を `raw.githubusercontent.com/lucide-icons/lucide/main/icons/<name>.svg` から取得 → `<path d>` 文字列と circle/rect/line をほぼ verbatim で `SvgEl` に写す (24×24 grid, stroke 2)。`hayate_kit::widget::lucide` に定数追加 (id は unique、`ALL` 配列とギャラリー example `lucide_pilot` で目視検証)。パーサが M/L/H/V/C/S/Q/T/A/Z 絶対相対 + elliptical arc→cubic を処理するので arc 入りもそのまま貼れる。※Lucide main は align-left/center/right が 404 (改名)、align 系は自前 round-cap 線で定義済。

**★GPU パリティ手法 (再利用価値大)**: GUI_kit の Vulkan パスは SDF/glyph-atlas ベースで**汎用ベジェラスタライザを持たない**。任意 AA 描画を GPU で CPU と一致させる正攻法 = **CPU (tiny-skia) でアルファマスクにラスタライズ→`draw_image` (CPU blit + Vulkan push_image テクスチャ、どちらも同一 BGRA を消費)**。glyph アトラスと同原理で、live-Vulkan と headless CPU screenshot が byte 一致 ([[feedback_gpu_text_vcenter_cap_band]] の CPU≠GPU 罠を構造的に回避)。thread_local で (icon,px,color) キャッシュ。**ImageKey 契約**: 同キー=同ピクセル厳守 → id にフィールド非重複配置、色は revision (XOR 折込は衝突するので不可、codex 指摘で修正)。

**面塗り色は CPU screenshot で検証可**: text 縦位置と違い fill/image 色は CPU/GPU 同一なので、surface 階層や色変更は HAYATE_SCREENSHOT で自己検証できる (アイコンの滑らかさ・パリティは初回のみ GPU 実機で user 確認、以降は screenshot 可)。関連 [[project_testruct_design_system_initiative]]。
```

### MEMORY.md 索引追加行 (`project_testruct_design_system_initiative` 行の直前に挿入)
```
- [GUI_kit ベクターアイコン基盤 (draw_vector_icon / Lucide)](reference_guikit_vector_icon_pipeline.md) — 旧 IconCommand ギザギザ線画を置換する AA ベクターアイコン。追加=Lucide SVG を widget::lucide に写す。★GPU パリティ手法=CPU(tiny-skia)ラスタライズ→draw_image で CPU/Vulkan 同一(glyph同原理)。ImageKey は非重複配置(XOR不可)
```

### 既存編集 1 件: `project_testruct_design_system_initiative.md`
「決定保留 (将来の ② PRESIDENT 判断)」段落の直前に「**2026-07-02 work-PC 続伸**」段落を追記済 (面階層 + Lucide アイコン land、PR#319/#82、残 P2)。home-PC は work-PC canonical から該当段落をコピー。

## home-PC 再開手順
1. 3 repo pull: GUI_kit→`4bfd194` / testruct→`7ce8032` / comms→userfork 最新。
2. 上記 memory を home-PC memory/ へ反映 (新規 reference 作成 + MEMORY.md 索引 + initiative 追記段落コピー)。
3. env-drift: golden fail は env-drift の可能性 ([[feedback_golden_env_drift]])、盲目 bless しない。

## backlog / open items
- ★残 P2: recessed control tone + ハードコード border 掃除 (gallery 目視要)。
- 旧 IconCommand editor 定数 (icon.rs の UNDO/CUT 等) dead cleanup。
- window control アイコン (titlebar min/max/close) も Lucide 化候補 (今回 toolbar のみ)。
- 前セッション継続: 複数行 text 編集 / フォント woff2・italic / 解答用紙ビルダー UI / zoom 絶対モデル化。
