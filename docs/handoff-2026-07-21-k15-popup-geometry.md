# Handoff 2026-07-21 (work-PC): K15 popup geometry feedback track 完遂

## セッション概要
前日 PC 復帰失敗 → 再起動からの復帰セッション。中断点 = GUI_kit `track1/ctxmenu-stage-a` の live-debug (未 commit は [k15] trace 11 行のみ、損失ゼロ)。そこから PR #332 merge → K15 Stage B を実機 live-verify 7 round + codex 査読で根治完遂。

## 着地 (全 merge 済)
| repo | PR | main HEAD | 内容 |
|---|---|---|---|
| GUI_kit | #332 | (squash) | ctxmenu Stage A (セパレータ/サブメニュー/accel) live-verify PASS |
| GUI_kit | #333 | `e9e6ca0` | K15 本体: on_popup_configured + commit-sync + ContextMenu derived layout + Slide 専用制約 |
| GUI_kit | #334 | `ebb470a` | Dropdown/MenuBar の K15 消費 retrofit |
| testruct | #108 | `7038b44` | canvas host forward + ROADMAP K15 closure / K16 起票 |

workspace tests: GUI_kit 2622 passed / 0 fail、testruct core 261 + ui 234 passed / 0 fail。

## 技術要点 (再発見コスト削減用)
1. **commit-sync invariant**: popup geometry は xdg configure 受信時でなく「ack 後の buffer commit 時」に画面適用される。pointer 変換 (`applied_x/y`) と widget 通知はこの境界に同期させる。configure 即時反映は commit までの谷間でイベントが移動量ぶんズレる。
2. **stale pointer offset**: Enter 時 offset キャプチャは reposition (re-Enter 無し) で恒久 stale 化。entered popup id を保持し毎イベント live 解決が正 (dispatch_impls.rs)。
3. **Flip-X vs 親固定**: Mutter は制約を Flip-X (anchor 軸鏡映) で解決し得る。same-surface 拡張で親パネルを固定するには Slide 専用制約 + anchor 不変 + `clamp(base−confirmed, 0, 子幅)` の layout 導出。anchor 補正の再要求は二重鏡映で悪化 (実測)。
4. **手動 popup forward host は 4 callback**: popup_request / paint_popup / on_popup_dismissed / **on_popup_configured**。demo HostPanel と testruct canvas の両方で 4 つ目欠落を実地で踏んだ (Phase 12 forward-gap の新 callback 再発)。
5. **freeze 直列化**: reposition 在飛行中は commit / widget 通知 / 新 reposition を全停止 (codex High 2 件)。

## 残課題 / 次アクション
- **K16 (fractional scale 視覚整合)**: 実機 1.5x で ~5px 体感ズレ。入力チェーンはバイアス 0 実証済 → 表示層。根治 = wp_fractional_scale_v1 + wp_viewport。testruct ROADMAP に起票済、走行は user 判断待ち。
- ctxmenu Stage B 続き (Mac parity 残: dwell timer 等) は必要に応じて。
- 多段 submenu が要件化したら nested xdg_popup 検討 (codex: 現 1 段なら same-surface が最小)。

## memory mirror (home-PC PRESIDENT 向け verbatim)
`project_dtp_app_roadmap.md` 末尾に以下を追記済 (home-PC でも同追記を):

> ## 2026-07-21 追記: K15 完遂 + K16 起票 (popup geometry feedback track)
>
> - **K15 ✅ 根治完遂**: GUI_kit PR #333 (`e9e6ca0`) + #334 (`ebb470a`)、testruct PR #108 (`7038b44`)。`Widget::on_popup_configured` + `PopupActualGeometry` feedback 経路、**commit 境界での atomic 適用** (PopupState.applied_x/y は commit 直後に promote、pointer 変換は「Enter 時キャプチャ」を廃し entered popup id から毎イベント live 解決 — reposition は re-Enter なしで surface を動かすため capture は恒久 stale)、reposition 在飛行中の freeze (commit/通知/新 reposition 全停止)。ContextMenu は anchor 不変 + `clamp(base−confirmed, 0, 子幅)` の derived layout + **Slide 専用制約** (Flip-X は surface 全体を anchor 軸に鏡映し親 rect をカバー外へ飛ばすため親固定が原理的に不能 = Mutter 実測)。Dropdown/MenuBar も消費 retrofit 済 (#334、MenuBar は menu idx タグで兄弟切替 self-invalidate)。
> - **教訓 (live-verify 7 round + codex 査読)**: ① popup geometry は configure 受信時でなく **buffer commit 時に画面適用** される — 受信時に座標系を即更新すると commit までの谷間でイベントが移動量ぶんズレる ② 手動 popup forward する host は **4 callback 目 on_popup_configured 必須** (demo host / testruct canvas 両方が踏んだ forward-gap、project_phase_12_popup_framework_critical_gap の新 callback 再発) ③ compositor 制約への「anchor 補正」は Flip-X で二重鏡映になる — **anchor 不変 + feedback からの layout 導出**が正
> - **K16 🟡 起票** (testruct ROADMAP): fractional scale (実機 1.5x + scale-monitor-framebuffer) の視覚整合 ~5px ズレ。K15 最終較正 trace で論理座標系の入力チェーンはバイアス 0 を実証済 → 表示層 gap。根治 = wp_fractional_scale_v1 + wp_viewport の真 1.5x レンダリング (reference_gui_kit_external_audit_2026-06-16 の「fractional scale 休眠」実機事例)。走行時期 user 判断待ち。
