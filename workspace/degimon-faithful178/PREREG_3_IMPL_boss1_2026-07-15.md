# ③実装 phase prereg（boss1、2026-07-15 02:1x 起案 = draft-skeleton。★固着は (c) 結果反映後★）

status: ★**FIXED（固着、2026-07-15 02:2x）**★ — (c) 完了（worker3 `c55fcf5`、boss1 直読採用）により §6 の 2 slot を実測で充填。
以後の変更は PRESIDENT 承認事項。→ GO 裁定待ち。
前提 doc = CAPTURE_SPEC_DRAFT_boss1_2026-07-14.md（v0.2 確定版 + §10-12 完了記録）。承認履歴 = §9-11。

## 0. scope・成功条件

- **scope**: capture 仕様 v0.2 の実装 — 初期値供給（baseline C）+ 維持機構（model/opcode）+ 実装欠落 5 件の消費側。
  ゲーム実装解禁は本 prereg の PRESIDENT GO 裁定をもって開始（それまで game code ゼロ不変）。
- **成功条件（phase レベル、数値は per-step prereg で固着）**: 対象 addr 群の差分テスト該当次元 FAIL が減少すること。
  ★phase 全体の数値目標は約束しない（完成 claim 凍結規範）— per-step の目標を着手時に固着し、達成/未達を per-step で報告★。
- **明示的 non-goal**: cutscene 実走検証（凍結解除 = user 裁定後）/ 待機 semantics（台帳 #7、別 phase）/
  DF8C・E0FC 等 capture 対象外 addr。

## 1. 実装順序（v0.2 §5 依存鎖、PRESIDENT 承認済）

| step | 内容 | 依存 | 充足する N/台帳 |
|---|---|---|---|
| 0 | **設計裁定 2 件**（コード前）: (0a) two-tier care のどちらに script 0x36 経路を入れるか (0b) E2E0『日カウンタ』vs『0x37 copy 先』二重意味の整合検証（C# コメント帰属 vs W-A RE の統合）。★GO 微調整 2: **boss1 起案（単一推奨+理由の設計判断 doc 1 通）→ PRESIDENT 承認を gate**（実装前の設計判断 = PRESIDENT 裁定事項）★ | なし | (b) の DIVERGENT 芽 2 件の設計決着 |
| 1 | **baseline C 生成 + stat struct 一括輸入**（§3 手順）+ transfer 確認 run | (c) 完了（fresh boot 経路は run⑦ で実証済み） | N の 3 件（D18/D3A/D54）+ D42 |
| 2 | **(i) 初期値 capture 残 8 addr**（E2DE/E2E0/145E5A/B084/B169/B139/B3A9/B411）を baseline C から台帳付き輸入 | step1（同じ dump から採取） | N の 8 件 |
| 3 | **MAPHEAD 鎖**: file 導入 + reader + GetSectionOffset 対応（★flag opt-in・既定 OFF★） | step1-2 と独立可 | 台帳 #1 + **N の 1 件（E114 = pointer slot の C# 対応）** |
| 4 | **opcode 0x46/0x79 + registry(640A4=model)** | step3（鎖の順序） | 台帳 #2 |
| 5 | **opcode 0x66（DF70 消費）**（★flag opt-in・既定 OFF★） | step3-4 + §6 の DF70 維持裁定 | 台帳 #3 |
| 併走 | **opcode 0x36（Stomach への script 維持経路追加）/ 0x37（E2DE slot 新設 + set 実装）** | step0 の裁定 | 拡大台帳 2 件（(b) で確定） |

## 2. 規範（PRESIDENT 予告 5 点 + 追加 gate、全 step 共通）

1. ★worktree 隔離必須★: unity repo のコード編集は各 worker の既存 worktree（f1a/f1b/f1c）内で完結。共有 tree 不触。
   ブランチ = 既存 track ブランチ上に step 単位の実装 commit（複数 worker が同一 file を並行編集する step は作らない —
   §5 割当で file 境界を分ける）。
2. ★MAPHEAD/0x66 = flag opt-in・既定 OFF で land★ + **配線確認義務**（grep 目視 + log 実測、ON/OFF 両側を acceptance に）。
3. ★small commits + 各 step で headless 非退行★: CutsceneVerify178 等の既存 headless verify に加え、
   **care harness（19/19 + live baseline GREEN、2026-06-23 land 資産）を非退行対象に明示追加**。
4. ★完成 claim は user 実視覚まで凍結★（headless 緑・差分テスト改善は進捗であって完成の根拠にならない）。
5. ★push ゼロ不変★（commit は local のみ、push は user 指示のみ）。
6. 測定系: 全検証 run は immutable copy を DGSTATE に。P1 replica / ctl-ctl / 非 vacuity の常設（H3 methodology 継承）。

## 3. baseline C 生成手順（v0.2 §1b 条項の実装、step1 冒頭）

1. fresh boot（実イメージ直指定 — ★run⑦ の phantom BIN path fix で経路実証済み★）→ New Game 直後の時点で savestate 生成。
   ★GO 微調整 1（PRESIDENT 承認済）: 正典時点 = **New Game 直後**。かつ**捕捉時点を 1 frame 単位で定義して記録**する —
   定義 = 『NewGame init 完了後、scene 204 field 制御が開始する初 frame』を基準候補とし、生成時に実測 frame 番号・
   その時点の判別 evidence（scene id / 制御状態）を台帳に残す★。
2. 生成した瞬間に sha256 記録 + chmod a-w（perm 400）→ 指紋台帳へ **baseline C として命名登録**（probe 判別子 = 12 注入 addr の orig 値）。
3. RAM dump 採取（DGDUMP or 外部 RE 文書の savestate decode recipe — ★recipe 使用時は §1 の 1 回検証を先に実施★）。
4. **transfer 確認 run（1 対）**: stat struct への注入で INPUT が baseline C 上でも成立するかを確認してから capture 値を採用。
   不成立なら台帳へ戻し、C の時点選定を再裁定（silent 続行禁止）。

## 4. per-step acceptance（v0.2 §6 の具体化）

- capture 実装 1 件ごと: C# 初期値 = capture 台帳値の一致 assert（provenance = baseline C sha + addr を台帳に）。
- 維持実装 1 件ごと: 該当 addr の差分テスト（16 pair / 80 launch 手法）で当該次元の FAIL 減少。目標値は step 着手時 prereg で固着。
- flag 付き実装（MAPHEAD/0x66）: OFF で既存挙動 bit 不変（非退行）+ ON で新経路の log 実測、の両側。
- 全 step: 既存 headless verify + care harness 緑維持。退行検出時は step 内で root cause（先送り禁止）。

## 5. worker 割当案

| worker | 役割 | 根拠 |
|---|---|---|
| worker2 | C# 実装主担当（step0 設計材料・step2-5 の opcode/reader 実装） | C# dispatch/VM 構造の直読実績（(b)、DG.SCN 等価再現） |
| worker3 | 計測・検証 run 担当（baseline C 生成・transfer 確認 run・per-step 差分テスト） | instrument 開発 + run 運用の全実績 |
| worker1 | x-check / 独立集計（per-step の検証を blind→unblind で） | swap 済み新 context、x-check 様式の実績 |
| boss1 | step 統合裁定・prereg 管理・PRESIDENT 報告 | — |

file 境界: worker2 = unity/Assets/Scripts/（実装）、worker3 = duckstation-src instrument + run script、worker1 = 検証 doc のみ（コード不触）。
同一 step 内で worker2 と worker3 が同一 file を触る構成は作らない。

## 6. ★(c) 依存 slot = 実測で充填済み（worker3 `c55fcf5`、run⑥⑦。固着）★

1. **B084/B169 の維持計画 = 『(i) 初期値 capture で covered scope 充足、維持 = 未同定（event 経路）label のまま step2 に含める』**。
   - 根拠（run⑦、boot〜frame 140,521 実測 + 打ち切り開示 = gameplay 未到達・NOT-SHOWN 明記）: この窓の書込 = BIOS/init の
     bulk zero-fill のみ・維持 writer 発火ゼロ。★bounding 前進 = 維持 writer は boot init にも sweep 窓にも居ない ∧
     savestate B は非ゼロ値を保持 ⇒ 値は「両窓の外 = 実プレイ event 経路」で書かれた★。
   - ⇒ (i) 判定（§2b）は測定済み全窓で裏書きされた。維持機構は §2b 脚注の一般則どおり **③ の差分テストを検出器**にする。
   - ★worker3 提案の run⑦ 再試行（gameplay 窓到達）= 今は起こさない（boss1 裁定）★ — (i) 充足に追加測定は不要、
     ③ 差分テストで当該 addr が FAIL した時に event-window run を改めて申請する（それが最小コストの発火条件）。
2. **DF70 の維持計画 = 『maintained 系 = model（writer1 機構）、初期値 capture 不要側』= ★H2 の「真の未捕捉 live-in」分類を実測で更新★**。
   - 根拠（run⑥、80 entry 完走・CAP HIT なし）: writer = ★0x800AE4E0（writer1）130/130 = 100%★・値 = ★定数 2（130/130）★・
     entry 間 80/80 で毎回書き直し = 周期維持される derived 値の挙動。writer2(0x800BC294) = この窓で発火ゼロ（非存在の証明でない）。
   - ⇒ step5（0x66）の値源設計 = **writer1 の定数 2 書込を model 化**（『同一関数内 = 同じ意味ではない』caveat 維持、
     意味論の確定 = step5 設計時の静的 RE 事項）。s1/s2 の「上流」問題は消滅（s1 の実測値 = 常に 2）。
   - W-B の warp routine 候補（0x800E3DA0、未再検証）は 台帳のまま（本実測では writer1 の caller 特定は不要になった）。

## 7. リスク台帳（着手前に既知のもの）

- E2E0 二重意味（set vs increment）: step0(0b) で整合を取らずに 0x37 を実装すると日カウンタ挙動を破壊し得る。
- care two-tier への 0x36 経路追加: 既 land 資産の帰属変更に silent 化けするリスク → step0(0a) + care harness gate で封じる。
- MAPHEAD 実装は fall-through 偶然依存の現 cutscene 挙動に影響し得る → flag 既定 OFF で構造遮断（裁定済）。
- 『sweep 窓外 live code』class（0x800AD774 等）は ③ の差分テストでは検証できない（窓外）→ 検証は cutscene 凍結解除後の実走に属する、と scope 宣言。
