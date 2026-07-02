# Handoff 2026-07-03 (b) — home-PC: gamma-correct GPU ブレンドを experimental land (同日 fidelity セッションの続き)

同日午前の GTK4 比較 fidelity 3層 (handoff-2026-07-03) の続き。残っていた text 品質「層#4 = gamma/AA」を潰し、gamma-correct GPU ブレンドを GUI_kit に experimental (既定 OFF) で land + push。

## §A. 本 session でやったこと

### 1. gamma パイプライン全体調査 (Explore agent + code-grounded) — ✅
- GPU 描画は **全 UNORM** で非 gamma-correct ブレンド(sRGB 値を UNORM attachment 上で加重和)。CPU ラスタライザ(golden 基準)は `text.rs:blend_gamma` で正しく linear ブレンド → **GPU だけ非準拠**が「AA エッジ太り・半透明濁り」の正体。詳細 memory `reference_guikit_gamma_pipeline`。

### 2. codex 設計相談 — ✅
- 王道 = render attachment を `_SRGB` 化 + 入力色 CPU linear 化 + image/video texture `_SRGB` view + atlas/SDF は UNORM 維持 + DMA-BUF export は無変換 copy。段階導入「text だけ」不可(hardware blend が全体 gamma 空間)→ env flag で全体切替 + A/B。

### 3. 実装 (worktree feat/gamma-correct-text) — ✅
- `render/gamma.rs` 新規: env `HAYATE_LINEAR_BLEND` flag + `color_u8_to_gpu`/`linearize_channel`(CPU EOTF 共有)+ `render_format`/`color_texture_format`。
- 配線: render image/view/pass を `_SRGB`(vk_dmabuf/vk_renderer)、render→export を **無変換 `cmd_copy_image`**(blit は色変換ゆえ回避)、色 linear 化 choke point(push_rect / push_sdf_rect の color+border / clear_u8 / sdf・bitmap text)、image/video texture `_SRGB` view。shader は色素通しゆえ無改造。
- **既定 OFF = byte 同一**(helper no-op / format UNORM / export blit)。

### 4. live A/B 検証 — ✅
- 専用テストパターン文書 `gamma_test.testruct`(黒αランプ 100/75/50/25% + 色半透明 50% + 半透明重なり + グレーテキスト階調 + 小文字)を作成し、ON/OFF 2 窓で並べて比較。★当初 answer-sheet template で判定しようとして user に「gamma 判定に向かない」と指摘され、α ランプ中心のパターンへ差し替え(部分カバレッジでこそ gamma が出る)。
- user 判定「めっちゃいい」= 半透明が明るく素直・破綻なし。★技術的山 = DMA-BUF `_SRGB render → _UNORM export` の cmd_copy が validation error / crash なしで通過。

### 5. codex impl-review — ✅ (メインパス正しい確認)
- 指摘 4 件は全て**テスト対象外の経路**(実害なし、experimental ゆえ許容): blur attachment UNORM のまま(blur 未使用+既存 SAMPLED 欠落)/ color emoji は coverage atlas 扱い / shadow は shader 黒固定で border_color 未使用 / Color::lerp 非線形。コメント 1 件訂正のみ反映。

## §B. git state (全て origin push 済・clean)
- GUI_kit main = **`1b1fb98`** feat(render): gamma-correct GPU blending behind HAYATE_LINEAR_BLEND (experimental)。worktree GUI_kit-gamma + branch 掃除済。
- hayate-kit-testruct main = `4ea5abf`(午前の #1/#2、変更なし)。testruct-ui/Cargo.toml の一時パスは GUI_kit(main)へ復帰済 = clean。
- 両 repo `## main...origin/main` 同期。testruct は main GUI_kit(gamma 既定OFF)で再ビルド緑 = landed 状態 coherent。
- golden は CPU 経路ゆえこの Vulkan 変更に非影響 (cpu_golden_cannot_verify_vulkan)。

## §C. memory mirror (work-PC `~/.claude/projects/-home-ken-Documents-Claude-Code-Communication/memory/`)
- `reference_guikit_gamma_pipeline.md`(★本 session 中核、現状+設計+LANDED 1b1fb98+codex指摘+follow-up)
- (午前分: `feedback_hayate_vs_gtk_live_compare` / `reference_guikit_sdf_large_text_blur` / `reference_wayland_stuck_grab_vt_switch`)

## §D. 次 session reentry / open items
### D-1. gamma default 化の判断 (要 dogfood)
- 現状 `HAYATE_LINEAR_BLEND=1` opt-in。全 Hayate アプリ(notepad/imageview 等)で ON 起動して破綻ないか広く確認 → 問題なければ default ON 化を検討。`gamma_test.testruct` は scratchpad に退避(再利用可)。
### D-2. gamma follow-up (codex 指摘、default 化前に)
- vk_blur を `render_format()` に揃える(vibrancy 実装時に。現状 blur 未使用+既存 SAMPLED usage バグも同時に)。
- `Color::lerp` を linear 空間補間へ(gradient/hover transition の非線形源)。
- color font/emoji の RGB を色として扱う経路(現状 coverage atlas)。
### D-3. 午前分の持越し (handoff-2026-07-03 §D)
- 各アプリ再ビルドで SDF くっきり化 dogfood / #315 font golden の work-PC canonical 検証 / testruct mac convergence 残タスク。

## §E. プロセス教訓
- verify-first (Explore agent で gamma パイプライン全体を code-ground してから設計) + consult-codex (設計 & impl 二段) + live A/B (golden 検証不能な Vulkan 変更は専用テストパターン + env flag ON/OFF 目視)。
- テスト内容の選定も検証の一部: answer-sheet(不透明ベタ)では gamma 差が出ず、α ランプ(部分カバレッジ)が正しい判定材料 (user 指摘で修正)。
- experimental flag (既定 OFF = byte 同一) で高 blast-radius 変更を安全に land、default 化は dogfood 後 = 段階導入。
