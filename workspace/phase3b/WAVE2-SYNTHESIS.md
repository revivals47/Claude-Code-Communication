# Phase 3b 第2波 完了サマリ（boss1 synthesis — PRESIDENT/codex 査読向け）

作成: 2026-05-20 / boss1。第2波 = 実装準備フェーズ（worker は cargo-free、grep/ドラフトのみ）完了。
PRESIDENT は本サマリと 3 本の draft doc を codex 査読 + user 判断に回せる。**worker 実装(cargo)は未着手** — PRESIDENT の titlebar cargo 完了通知後に boss1 が 1 人ずつ順次解禁。

---

## 0. 3 draft 完了 + boss1 検証結果（全て実コード/grep 照合済、fabrication ゼロ）

| draft | worker | 状態 | boss1 検証 |
|-------|--------|------|-----------|
| color-tweaks-draft.md | worker1 | DONE | 全 file:line + test assert 2件を grep 照合→正確 |
| win95-font-draft.md | worker3 | DONE | bitmap_font 定数/embed asset/win95 dims を grep 照合→正確 |
| macos9-button-fix-draft.md | worker2 | DONE | renderer 構造制約を button.rs paint で照合→正確 |

---

## 1. 各 draft の要点 + boss1 所見

### 1-A. worker1 = 色微修正バッチ（color-tweaks-draft.md）
- 対象 5 値: tooltip win95 #FFFFC0 / Win10 bg_primary #F0F0F0 / Big Sur warning #FF9500 / XP selection #316AC5（theme.rs:386 + input.rs:20 の 2 箇所）。
- **test 追従 2 件を worker1 が自力検出**（私の dispatch では未指定）: tooltip.rs:120（win95_is_yellow_with_hard_border）と button.rs:239（macos_big_sur_radius）。未更新だと cargo test が落ちる。← この rigor は high value。
- file 競合: worker1 = theme.rs/tooltip.rs/input.rs に限定、button.rs 不可。clean partition 確立。
- 1 commit でまとめ、cargo -j1 verify。

### 1-B. worker3 = Win95 font 案B 実現性（win95-font-draft.md）
- **答え**: 純既存資産では 11-12px は出せない（既存定数は 8px か 16px のみ）。
- **発見**: Shinonome 12×12 は既に embed 済（shinonome12_gothic.bdf 497KB、現状 16行 padding で JP 側専用）。→ **B2 = Spleen 6×12 BDF 1 本(BSD-2, 数十KB)追加で真の native 12px が成立**。案C(重ベクター)は不要。
- font 使用 9 サイト列挙。override 削除でグローバル継承一本化案を推奨(cohesion)。
- **TITLE_HEIGHT は PRESIDENT スコープ**（titlebar 連動）として worker 単独変更しない明示 ← boundary 認識が正確。

### 1-C. worker2 = Mac OS 9 Platinum button（macos9-button-fix-draft.md）
- **renderer 構造制約をコード読解で発見**（cargo なしで button.rs paint を精読）:
  - bevel は押下で light↔dark **自動反転**（raised 4 色指定のみで pressed 自動、追加 field 不要）。
  - bevel は **fill_rect 直線で radius 無視**（body は fill_rounded_rect、bevel は矩形）→ **radius>0 + bevel = 角破綻**。Win95 が radius 0 なのはこのため。
  - bevel が border を上書き → 別 border のダーク輪郭は出ない。
- **私の dispatch の「radius 3.0」を訂正する正当な push-back**: 即時実装は **radius 0.0**。
- 即時案: win95 bevel 機構 + Platinum グレー(platinum.css)+ 淡グラデ face + **白黒反転廃止**(fg 黒維持) + press_text_offset。
- radius 3.0 / 全周ダーク輪郭 / default ring は **framework 拡張待ち**(§4 A/B/C) として正しく分離（consumer 側で fake せず framework で抜本解決＝platform 原則整合）。

---

## 2. user 判断待ち（PRESIDENT が user 確認に回す項目）
1. **Win95 font: B1(8px・ゼロアセット) vs B2(12px native・小BDF1本)** ← font 実装の前提ゲート。
2. Win10 button rest 背景: 白(UWP) か 淡灰 #E1E1E1(native dialog) か。
3. Big Sur vibrancy/blur 投資是非（GPU 大工事、framework §3-A 系）。
4. 各タイトルバー グラデ可否（Win95 はソリッド紺が忠実、現 #1084d0 グラデは Win98 機能）。
5. Mac OS 9 button: face グラデ濃淡 / 外BR シャドウ濃度 / radius 0 許容 / default 強調 / 点線フォーカス（draft §6 の 6 点）。

---

## 3. 実装ゲート + boss1 推奨シーケンス
**全実装は (G1) PRESIDENT titlebar cargo 完了通知が前提**（cargo -j1 直列、PRESIDENT と worker の同時 cargo 回避）。解禁後 boss1 が 1 人ずつ順次解禁し各自 edit→commit→cargo -j1 verify。

推奨順（file 競合 + 依存 + リスクで判断）:
1. **worker1 色バッチ**（最小・依存なし・pipeline 検証）。theme.rs/tooltip.rs/input.rs + test 2行、1 commit。
2. **worker2 Platinum button radius-0**（最大視覚利得・button.rs 単独）。worker1 の Big Sur radius 8→6（button.rs:175 + test:239）も worker2 が同梱（button.rs オーナーゆえ collision 回避）。
3. **worker3 font B2**（user の B1/B2 決定後）。bitmap_font.rs + build.rs + win95 dims + builder 9サイトと広範囲に触るため、他 worker の edit と重ねず単独 window で。

※ font 実装は **G1 + user B1/B2 決定の二重ゲート**。

---

## 4. framework 拡張バックログ（両波で析出、PRESIDENT/framework 領域）
consumer 側で fake せず framework で抜本対応すべき項目（platform 原則）:
- radius 対応 bevel（Mac OS 9 角丸 Platinum / 一般）
- bevel 後 border or 専用 outer-frame（Mac OS 9 全周ダーク輪郭 / Win95 default button 黒枠）
- default button 外周リング（Mac OS 9 / Win95）
- 多stop グラデ（XP button 3stop / XP titlebar 8stop グロッシー）
- inset glow（XP amber hover / XP focus blue）
- title text-shadow（XP caption #0F1089）
- pressed border（Win10 #005499）
- soft drop shadow 大ぼかし（Big Sur）
- **vibrancy/半透明**（Big Sur 最大ギャップ、platform compositor 大工事）
- traffic-light 縁取り + hover ×/−/+ + inactive グレー（Big Sur titlebar）
- **active/inactive titlebar 状態**（横断: Mac OS 9 縞 on/off / Big Sur 信号機グレー / Win95 inactive caption）
- title button 左右分割配置（Mac OS 9: close 左 / collapse+zoom 右、現 ButtonSide 単側のみ）

補足: worker2 が bevel テーマは既に**点線フォーカス**を持つと発見(button.rs L519-529)。Win95 の「破線フォーカス」gap(wave1 worker3)は theme.focus_ring(solid 2px) と button-paint dotted の二系統があり、Win95 実装時に reconcile 要（既存 dotted が活きる可能性）。

---

## 5. 制約遵守状況
- cargo: 第2波で worker は一切起動せず（grep/読解/doc のみ）。PRESIDENT titlebar cargo と非競合。
- 記憶ベース禁止: 全 draft が第1波 research doc + 実コード grep 根拠、出典明記。
- agent-send: backtick/$ 不使用継続。
- file 競合: worker1=theme/tooltip/input、worker2=button、worker3=font系で partition。実装解禁時に shared-wt commit hygiene（pathspec + workerN/ prefix）厳守、3 worker 同時 commit 化なら専用 worktree 検討。
- 視覚判定: 全 draft が user 確認事項を明示（worker は GUI 不可視前提）。
