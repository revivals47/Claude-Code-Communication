# Handoff 2026-07-22 (work-PC): K16 Stage D 完遂 — fractional scale default-on

## セッション概要
user trigger「K16 走らせて」で Stage D 実機 live-verify を完遂。Stage A/B/C は前日 07-21 夜に land 済 (07-21 handoff / memory には未反映だった点に注意)。本 session で M4 NG → diagnostic → root-fix #339 → default-on flip #340 まで着地し、K16 track 完全終結。

## 着地 (全 merge 済)
| repo | PR/commit | main HEAD | 内容 |
|---|---|---|---|
| GUI_kit | #339 | `8788782` | M4 root-fix: popup surface に wp_fractional_scale bind (SC3 parity、PopupKey no-op consume) |
| GUI_kit | #340 | `ddee0db` | default-on flip (escape hatch = `HAYATE_FRACTIONAL_SCALE=0`/`off`) |
| testruct | 直コミット | `57357aa` | ROADMAP K16 closure (doc-only、user へ pre-flag 済) |

verify battery 全 GO: M1-M4 / D1-D5 / V1-V3 / R1-R2 + 最終 smoke (env 無し起動で鮮明表示)。GUI_kit test 2657/0/65、golden 14/14 byte 不変。

## 技術要点 (再発見コスト削減用)
1. **protocol bind は宣言だけで load-bearing**: popup が wp_fractional_scale 非 bind だと mutter が legacy 扱い (preferred_buffer_scale(2) 送信) → 分数 framebuffer 合成で二重 downscale。bind するだけで fractional-aware 合成に反転する。値の consume は不要。set_buffer_scale/ack 追加は有害 (legacy 経路混在で integer 2x 化)。
2. **popup PreferredScale は専用 no-op sink へ**: owner window へ route すると multi-monitor で owner scale を誤上書きする latent bug。PopupKey userdata + 空実装 named fn + 機械証明 test (`popup_preferred_scale_does_not_touch_owner`) で構造排除。owner ScaleManager が buffer scale の SSOT。
3. **隔離 instrumentation は link 実証を前提条件化**: path 依存 app は隔離 copy の dep 書換 + 起動 banner ([k16-diag] 方式) 確認後に計測。banner 無しの計測は無効扱い — 無症状を仮説反証と誤読する trap を封じる。
4. **merge ack の『remote 削除済』は ls-remote 出力を読んでから**: gh pr merge --delete-branch は local 削除失敗 (worktree 占有) 時に remote も未削除で終わることがある。本 session で 2 件実例 (PRESIDENT 誤報 → boss1 検出 → PRESIDENT 削除 + 検証で訂正)。
5. **doc sweep の弁別**: 「gate off = pre-K16」(escape hatch 記述、default 非依存で保持可) と「default off / opt-in」(default 主張、flip 必須) を区別して sweep する。

## 残課題 / backlog (詳細 = workspace/k16_stage_d_boss1_closeout_notes.md)
- gallery context_menu demo が stub (実 popup 非表示) → popup 系 visual validation 標準シナリオとして実 popup demo 化推奨
- popup per-monitor scale (foreign monitor 上の軽微 mis-scale = owner SSOT の意図的 tradeoff、将来 enhancement)
- escape hatch alias (`=false`/`no` は現状 ON、混乱あれば alias 追加)
- k16 系 remote branch 4 件 hygiene: **track1/k16-scale-transform (ff3cbf2) + track2/k16-popup-cpu-path-2 (a0aabda) は WIP worktree 占有中で削除禁止**、protocol-wiring + popup-cpu-path は main 包含検証後に削除候補
- F-3 (fractional 時 CPU plain text ~0.75px subpixel phase) / Q2 (SDF >256px) / FB-1 (dogfood pre-existing fail 2 件: agents-linux-v2 E0063 + gpu-furnace E0308、bisect 要) / pdfview physical render target opt-in

## memory mirror (home-PC PRESIDENT 向け mandatory instruction)
home-PC の memory に以下 2 点を反映すること (memory は local-only、handoff doc が単一 channel):

### (1) 新規 memory file `project_k16_fractional_scale.md` を full body verbatim で作成:

> ---
> name: project_k16_fractional_scale
> description: K16 fractional scale (HiDPI default-on) 完遂記録 — mutter fractional-aware / popup SC3 parity / 静的監査 airtight → runtime 帰属の切り分け法
> metadata:
>   node_type: memory
>   type: project
> ---
>
> **2026-07-22 完遂**: GUI_kit の fractional scale (HiDPI 非整数 scale、mutter scale-monitor-framebuffer + 1.5) が **default-on** で着地 (main=`ddee0db`)。opt-in gate `HAYATE_FRACTIONAL_SCALE` は escape hatch (`=0`/`off` で pre-K16 bit-exact) 化。Stage A(protocol配線) → B(renderer scale transform C1-C9) → C(popup physical buffer + viewport) → M4 root-fix → D(default-on flip) の順。全段で品質 gate が実仕事、band-aid ゼロ。
>
> **M4 bug の核心 (再利用価値の高い教訓)**: popup が「window 正寸だが中身が左上に小さく」= **popup surface に `wp_fractional_scale` object を bind していない** → mutter が legacy integer-scale surface 扱い (`preferred_buffer_scale(2)` を送る) → physical buffer を高密度ソースと認識せず二重 downscale。主 surface は bind 済で fractional-aware 合成される非対称。**fix = SC3 parity** (popup surface に主 surface と同一の `get_fractional_scale` bind を複製、PR #339)。`wp_fractional_scale_v1` は ack handshake 無し、`set_buffer_scale` は legacy 経路で混在有害。
>
> **切り分け方法論 (worker3 が体現、[[feedback_visual_validation_gap_pattern]] 系)**:
> 1. **静的監査 airtight → runtime 帰属**: SC5 chain 7 脚 (owner_scale→physical buffer→wl_buffer→new_scaled→set_cpu_scale→cpu_scale-aware arms→viewport) を全裏取りし静的欠陥ゼロを確定 → 「buffer=physical かつ paint=logical は静的に発生不能」と論証し、原因を runtime (mutter 合成) に絞り込んだ。
> 2. **症状ベース脚特定**: 「window 正寸・中身だけ小さい」で viewport 動作 vs cpu_scale 未適用 vs owner_scale 誤値を弁別する 4値 diagnostic table (owner_scale / (pw,ph)vs(w,h) / paint入口cpu_scale() / viewport.is_some())。
> 3. **WAYLAND_DEBUG protocol trace** で主 surface (@14 get_fractional_scale bind) vs popup surface (未 bind) の非対称を実証。
>
> **default-on flip の doc sweep 教訓**: gate default を謳う comment は「gate off = pre-K16」(escape-hatch state 記述、default 非依存で保持可) と「default off / opt-in」(default 主張、要 flip) を弁別。repo 全体 sweep で `scale_transform.rs` の「the default (gate-off) path」= 両者を等号で結ぶ stale を検出 (PR scope 外)。cross-PR は `gh pr diff` 一次ソース + 未 merge PR は pre-image 補正。
>
> **backlog (K16 closeout)**: gallery `context_menu` demo が stub (println のみ、実 popup 出ない) = demo 網羅性 gap、起票候補。F-3 (scale 1.5 で CPU plain text 最大~0.75px subpixel phase ずれ) / Q2 (>256px SDF glyph ぼけ) は既知 follow-up。multi-monitor で popup が owner と別 DPI 出力の場合 owner_scale SSOT による軽微 mis-scale (将来 popup 自身 PreferredScale consume で解消可)。

MEMORY.md index 追加行:
`- [K16 fractional scale (HiDPI default-on)](project_k16_fractional_scale.md) — **2026-07-22 完遂** (main=ddee0db)。HiDPI 非整数 scale が default-on 着地、HAYATE_FRACTIONAL_SCALE=0/off は escape hatch。M4 bug 核心=popup surface に wp_fractional_scale 未 bind → mutter legacy 扱いで二重 downscale、fix=SC3 parity (PR #339)。backlog=gallery context_menu demo stub / F-3 subpixel / Q2 SDF ぼけ / multi-monitor popup mis-scale`

### (2) `project_dtp_app_roadmap.md` 末尾 (07-21 K15 追記の後) に以下を verbatim 追記:

> ## 2026-07-22 追記: K16 完遂 — fractional scale default-on (Stage A-D 全決着、詳細 = [[project_k16_fractional_scale]])
>
> - **K16 ✅ 完遂**: Stage A #335 (HAYATE_FRACTIONAL_SCALE gate 配線) / B #337 (renderer scale transform C1-C9) / C #336+#338 (screenshot scale-1 強制 + popup physical buffer + SC5 owner scale 供給) は 07-21 中に land 済 (当時の memory 追記に未反映)。07-22 は Stage D 実機 live-verify → M4 root-fix **#339** → default-on flip **#340**。GUI_kit main = `ddee0db`、testruct ROADMAP K16 closure = `57357aa`。**escape hatch = `HAYATE_FRACTIONAL_SCALE=0`/`off`** (unset/`=1`/その他 = ON。`=false`/`no` は ON になる点は backlog の alias 候補)。verify battery = M1-M4 / D1-D5 / V1-V3 / R1-R2 全 GO、当初症状 (~5px カーソル/内容ズレ) の解消を D1/D2 実機確認、K15 popup 挙動非回帰 (D3-D5)、testruct V1 zoom 二重 scale 無し・V2 gate ON/OFF screenshot byte-identical。
> - **M4 root cause (Stage D 唯一の NG)**: popup surface が wp_fractional_scale **非 bind** → mutter が legacy 扱い (legacy preferred_buffer_scale(2) 送信) → 分数 framebuffer 合成で二重 downscale = 中身が logical/1.5 の小描画 (frame は正寸)。app 側 render 配線は完全に正 (worker3 静的監査 + WAYLAND_DEBUG 18955 行 trace で確証、user 協調 1 run で症状と protocol 証拠を同 run 紐づけ)。**fix = SC3 parity bind (#339)**: bind 自体が load-bearing (mutter の per-surface 扱いを fractional-aware へ反転)、値は non-consume。**PopupKey userdata + 専用 no-op consume handler** で owner ScaleManager SSOT 維持 = multi-monitor で popup の PreferredScale が owner scale を誤上書きする経路を構造排除 (worker3 の owner-route 案を worker1 検出 trap で差替えた boss1 裁定、機械証明 test 付き)。set_buffer_scale/ack 追加は**有害** (legacy 整数経路と混在で integer 2x 化、主 surface も 0 件で正)。
> - **教訓**: ① protocol object は bind するだけで compositor の per-surface 合成経路を切替え得る — 「値を使わないから bind 不要」は誤り ② 隔離 instrumentation は「trace が link された実証 (起動 banner)」を計測の前提条件化 (無症状→仮説反証の誤読 trap、path 依存 app は隔離 copy の dep 書換必須) ③ merge ack の『remote branch 削除済』は ls-remote 出力を読んでから書く — gh pr merge --delete-branch は local 削除失敗 (worktree 占有) 時に remote も未削除のまま終わることがある (本 track で 2 件実例、PRESIDENT 誤報 → boss1 検出で訂正) ④ worker 見解対立時は「単一モニタで同値なら multi-monitor 安全側 (構造的排除 > idempotent 依存)」に倒す。
> - **backlog (boss1 closeout notes = Claude-Code-Communication/workspace/k16_stage_d_boss1_closeout_notes.md に詳細)**: gallery context_menu demo が stub (実 popup を出さない、popup 系 visual validation の標準シナリオ化推奨) / popup per-monitor scale (foreign monitor 上の軽微 mis-scale = owner SSOT の意図的 tradeoff、将来 enhancement) / escape hatch alias (=false/no) / k16 系 remote branch 4 件 hygiene (scale-transform ff3cbf2 + popup-cpu-path-2 a0aabda は **WIP worktree 占有中で削除禁止**、protocol-wiring + popup-cpu-path は main 包含検証後に削除候補) / F-3 CPU plain text subpixel phase (~0.75px、fractional 時のみ) / Q2 SDF >256px / FB-1 dogfood pre-existing fail 2 件 (agents-linux-v2 E0063 + gpu-furnace E0308、bisect 要) / pdfview physical render target opt-in。

また、07-21 K15 追記の K16 起票行の末尾に `→ **2026-07-22 完遂 (下記)**` を追記すること。

---

## §F セッション末尾追補 — dual-PC 同期・再開手順 (session close 監査で追記)

### ★重要: ops repo (本 repo) の dual-PC line 分岐を解消済
handoff push 時に判明: userfork (revivals47) の main は home-PC が 07-08 に push した line (CLAUDE.md 行動姿勢 7 箇条 / instructions 棚卸し / degimon handoffs ×3) で止まっており、work-PC は 07-07 分岐点から handoff 4 本 (07-09 / 07-13 / 07-21 / 07-22) を **pull せずに local へ積んでいた** = 07-09〜07-21 の work-PC handoff は本日まで remote に存在しなかった。**解消 = work-PC 側で `git rebase userfork/main` (conflict ゼロ、ファイル互いに素) → push 済、userfork/main = `77c5260` 以降**。work-PC には棚卸し後の新 instructions (CLAUDE.md 行動姿勢 7 箇条含む) が rebase で取り込まれた。

**home-PC 再開手順**:
1. 本 repo: `git fetch userfork && git status -sb` — home-PC local が 506a152 のままなら `git merge --ff-only userfork/main` で一括取得 (07-09〜07-22 handoff 4 本 + 本追補が入る)
2. GUI_kit: `git pull` → main が `8ca0cb8` (= ddee0db の K16 default-on + K16 workspace notes archive 12 件) 以降であること
3. testruct: `git pull` → main `57357aa` 以降
4. memory mirror: 本 doc の mirror 節 2 点を home-PC memory へ verbatim 適用
5. **home-PC は display 環境が異なる可能性**: fractional scale が default-on になったため、home-PC の scale 設定 (整数 scale なら実質不変 / 非対応 compositor なら protocol 非 bind で不変) を最初の app 起動時に一度目視。異常があれば `HAYATE_FRACTIONAL_SCALE=0` で切り分け

### session close 監査結果 (work-PC、2026-07-22)
| repo | HEAD | 状態 |
|---|---|---|
| Claude-Code-Communication | `77c5260`+ (userfork 同期済) | clean。origin (upstream Akira-Papa) ahead 48 は正常 (push 先は userfork のみ) |
| GUI_kit | `8ca0cb8` | clean。K16 workspace notes 12 件 archive commit 済。stash 2 件は旧 stray-ラベル (既知、温存) |
| hayate-kit-testruct | `57357aa` | clean |
| hayate-kit-settings / linux-gallery / pdfview | main / master 同期 | Cargo.lock 自動更新のみ (harmless、commit 不要規範) |

### 残 open (次 session 冒頭 checklist)
- なし (K16 track 完全終結、全 worker standby)。次 dispatch = user trigger 待ち (backlog は本 doc §残課題 + testruct REMAINING-TASKS.md)
