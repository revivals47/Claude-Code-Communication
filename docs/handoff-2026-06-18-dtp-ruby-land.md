# Handoff 2026-06-18 — home-PC session: DTP 縦書き+グループルビ land + framework debt 2件

在 PC: **home-PC**。発端 = PC クラッシュ復帰後の認識合わせ → GUI_kit 作業の継続。

## このセッションでやったこと

### 0. PC クラッシュ原因の切り分け (session 冒頭)
- 6/18 14:02 のクラッシュは **ログに決定的カーネル原因が残らないハングまたは電源断型** (`last` に shutdown 記録なし=非正常終了、journal が 14:02:49 で途切れ、pstore 空)。直前ログは discord snap の apparmor ptrace 連打のみ。**熱暴走でない (温度低)・クラッシュ時 OOM でない・panic dump なし**。
- 別件で 6/15 13:50 に OOM-kill 実績あり (claude プロセス total-vm 73GB を kill)。16GB 機の OOM 傾向 ([[reference_user_machine_16gb_oom]]) と一致。再発防止候補 = earlyoom / swap 増 / 並行 cargo 抑制。

### 1. GUI_kit framework debt 2件 (boss1 dispatch、land 済)
- **②** `clippy::never_loop` root-fix (`line_height_for` の for+無条件break → `.next().map().unwrap_or(fallback)`、挙動同一) → **PR #277、main `b3eb5a4`**。
- **③** hayate-platform examples の `draw_buffer` 8-arg 取りこぼし E0061 (good catch でスコープ 4→**6 file / 16 site** に訂正、#276 が hayate-kit examples のみ修正し platform examples を取りこぼしていた) → 全 site 9番目 `clip_rect=None` 付与 → **PR #278、main `dbf1f9e`**。arity gap 完全 closure (他クレートに 8-arg 残存ゼロ確認)。
- どちらも `cargo j1` 直列規範で PRESIDENT(track-dtp ルビ)と worker1(debt)の cargo lane を譲り合い運用。

### 2. DTP 縦書き + グループルビ (PRESIDENT 直接 path、land 済) ★本命
- **PR #275 squash merge → GUI_kit main HEAD=`f7e5549`**。詳細は下の memory mirror 参照。
- codex 査読で実バグ 2件を**同 PR で root-fix** (commit c75ce6f)。codex は bwrap 不全でローカル查読不可 → GitHub connector 経由 ([[reference_codex_sandbox_repo_mutation]]、今回ローカル repo 改変なし=HEAD 検証済)。
- user 目視 GO + `。」`/括弧 probe で約物 gap を実機確認 (= 次ステージ)。
- track-dtp は land 後 local/remote とも `f7e5549` に reset 済 (次 DTP ステージのクリーン base)。

## 🔁 home-PC PRESIDENT への memory mirror (必須適用)

memory は local-only のため、home-PC では以下を手で適用すること ([[reference_dual_pc_setup]] 規範)。

### (A) `memory/project_dtp_app_roadmap.md` に追加した新セクション (verbatim)

> 既存 `## ⚡ 2026-06-17 縦書き/ルビ feasibility 確定` セクションの `② 待ち` 行末に「→ **2026-06-18 に Stage 1+2 land で全 5 判断点 resolved (下記)**。」を追記し、直後に以下を挿入:

```markdown
## ⚡ 2026-06-18 Stage 1+2 land (縦書き engine + グループルビ) — home-PC session

2026-06-17 POC → feasibility 確定を受け Stage 1 (engine vertical core + L2 `VerticalTextWidget`) + Stage 2 (グループルビ) を実装・**main land**。PC クラッシュ復帰後の home-PC session で完遂。

- **landed**: PR #275 squash → GUI_kit main HEAD=`f7e5549`。`crates/hayate-platform/src/render/text.rs` の `TextEngine::layout_vertical` (2 パス: base を RTL 列配置しつつ ruby job 記録 → ink 位置 + ルビ strip 解決)、`VerticalSegment::{Plain,Ruby}`、`VerticalTextBlock::measure_segments`、L2 `VerticalTextWidget` (builder `.text()/.ruby(base, reading)`)。`。、，．` は cell 右上。ルビ = `RUBY_FONT_RATIO`(0.5) を base 列の右 strip に **base span 全体へ均等配分 = グループルビ** (mono/熟語ルビではない、API は base 塊+reading 塊)。
- **5 判断点 resolved**: (1)engine-level layout 採用 (2)Stage1=CJK-only (3)専用 `VerticalTextWidget` (RichParagraph 拡張でなく) (4)PRESIDENT 直接 path で完遂 (boss1 並走は別件 #277/#278) (5)cosmic upstream 待ち無し。
- **検証**: cargo test -p hayate-platform --lib = 918 passed/0 fail (ルビ 4 test)、build -p hayate-kit --examples 緑、実機 visual GO (NVIDIA/Vulkan)。**codex 査読で実バグ 2 件 (ルビ列分割の stale anchor / ルビ内 `\n` 無視) を同 PR で root-fix** (commit c75ce6f、review-trail 別コミット、[[feedback_root_cause_over_quick_fix]] defer ゼロ)。codex は bwrap 不全でローカル不可→GitHub connector 経由査読 ([[reference_codex_sandbox_repo_mutation]])。
- **`。」`/括弧 probe で約物 gap を実機確認**: `。` は右上寄せ済だが `「」『』` は横字形のまま (縦字形=OpenType `vert` 未適用)、`。」` のアキ詰めも無し → **約物/禁則は次ステージと確定** (regression でなく設計上の段階分け、docstring で明示 scope 外)。
- **次 DTP ステージ backlog (本 land で明文化、PR #275 説明に記録)**: ① 縦書き経路の `scratch_buffer`/`shape_cache` 載せ替え (現 `shape_vertical_glyphs` がセグメント毎 `Buffer::new`、横書きの glibc-RSS 注意書きを縦書きだけ踏む、user 指摘) ② **`.family()`/明朝(serif) 対応** (現状 SansSerif 決め打ち、縦組み本文は明朝が慣習=組版品質に直結、user 重視) ③ 約物/禁則 (括弧縦字形・`。」`アキ・行頭行末禁則) ④ Latin 縦中横・caret/selection・mono/熟語ルビ。**Stage 3 (約物 or 明朝) 着手は user trigger 待ち**。
- track-dtp は land 後 local/remote とも main へ reset (次ステージのクリーン base)。ルビ pitch 契約 = `RUBY_MIN_PITCH_RATIO`(1.6)、ルビ時 `column_pitch` を詰めすぎると右隣列に被るため debug_assert + doc で契約化 (user 指摘 ③)。
```

### (B) `MEMORY.md` 索引行 (project_dtp_app_roadmap) を以下に差し替え (verbatim)

```markdown
- [GUI_kit 長期 north star = DTP app (日本語 / ルビ / 縦書き)](project_dtp_app_roadmap.md) — GUI_kit 長期 north star=DTP ソフト(日本語+ルビ+縦書き必須)。2026-05-26 境界確定: 実在 2 アプリ(Testruct=testruct-v3 国語解答用紙 / ファイラ Hayate=Mac_explorer_v2 v2.4.6)の Linux 移植で「L2 十分」を有限化。**2026-06-18: 縦書き engine + L2 VerticalTextWidget + グループルビ ✅ land (PR#275 squash、main `f7e5549`、test --lib 918 passed、codex 実バグ2件同PR root-fix、実機 visual GO)。次 DTP ステージ backlog = ① scratch_buffer/shape_cache 載せ替え(RSS) ② .family()/明朝対応 ③ 約物/禁則(括弧縦字形・。」アキ)、着手 user trigger 待ち**。ファイラ合成系一部 (multi-pane / pane DnD 等) は [[project_hayate_kit_agents_v3]] 先行 dogfood
```

## 現在の状態 / 次の一手
- GUI_kit main HEAD=`f7e5549`。boss1 + worker idle standby。本セッションの GUI_kit work 全完遂。
- 次 DTP ステージ (Stage 3) 候補 = **約物/禁則** または **明朝(.family) 対応**。着手は user trigger 待ち。
- クラッシュ再発防止 (earlyoom / swap 増) は未着手、user 判断待ち。
