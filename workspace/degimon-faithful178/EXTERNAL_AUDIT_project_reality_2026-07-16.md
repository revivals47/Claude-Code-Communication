> **★EXTERNAL-INPUT / 外部独立監査 — 採録 2026-07-26★**
> 出所 = user の別 session 成果（原本 `~/Desktop/実装班向け_プロジェクト実態評価_2026-07-16.md`、以下逐語）。
> プロジェクト外からの独立監査。実装コード・実行痕跡・ドキュメント記述の三点照合で判定したもの。
>
> **★採録時の stale 警告（引用前に必読）★**
> 本文書の評価基準日は **2026-07-16**。その後 7/19〜7/25 に主要な land が発生しており、
> ★「完成度15〜25%」「戦闘・進化判定・セーブ・経済はまだ存在しない」等の数値・状態 claim は
> 現時点の実態を表さない★。少なくとも以下が本文書の基準日より後に land 済み:
> - ③ladder 全段 land 完了（step5 0x66 = scene driver gate② CLOSE / step4 0x46・0x79 = actor registry dual委譲 検収CLOSE / O2(a) clamp populate）
> - 覚醒 arc の user live PASS（歩行不能3層の根治）
> - battle RE 着手（95関数 symbol catalog / overlay load base 0x80052ae0 確定）
>
> ★引用する場合は「2026-07-16 時点の外部監査所見」と必ず日付を添えること★。
> 逆に、**監査の方法論**（三点照合・完了宣言を信用しない姿勢・次元の但し書き）は日付非依存で有効。

---

# 実装班向け — プロジェクト実態評価（外部クロス調査）

- **日付**: 2026-07-16
- **対象**: `/home/ken/Desktop/degimon_world_remake/`（初代デジモンワールド PS1 の Unity リメイク）
- **立場**: プロジェクト外からの独立監査。3系統を並行調査し、相互に裏を取った。
  ドキュメントの完了宣言ではなく、**実装コード・実行痕跡・ドキュメント記述の三点照合**で判定。
- **目的**: 「今どこまで来たか」を、次元の但し書きを外さずに正確に伝える。批判のためではなく、
  次の優先順位を実データで決めるための地図。
- **調査方法**: (A) `Assets/Scripts/` 全56ファイル約10,660行の実装実態、(B) `docs/`+`workspace/`
  の進捗記述の棚卸し、(C) ビルドログ・batchmode 実行ログ・スクショ等の実行痕跡。3者が独立に
  同じ像を指した。

---

## 0. 結論（一行）

**最難関の基礎（会話VM・フィールド探索・育成ケア式）は本物に動いている。だがゲームの背骨
（戦闘・進化判定・セーブ・経済）はまだ存在しない。** 体験は「街を歩いてNPCと喋り、覚醒デモを
見る技術デモ」の段階。完成を100とするなら体感 **15〜25%**（機能数ベース。難所突破度で見れば
もっと高いが、通しでは遊べない）。

---

## 1. 実装が動いているもの（証拠つき）

3系統すべてで確認できた「実際に動く」部分。ここは質が高く、称賛に値する。

| システム | 判定 | 根拠（ファイル:行 / ログ） |
|---|---|---|
| 会話・シナリオVM（opcode解釈） | **実装済** | `Dialogue/DialogueRuntime.cs`(1698行) が DG.SCN(692KB) を実解釈。flag(0x1C/1D)・var(0x1E/1F/20)・give-item(0x28)・evolve(0x49)・map-change(0x47)・warp(0x4B)・scenario-jump(0xFB)・cond-branch(0x19)・choice-table(0x18) を実処理。`ScenarioVM.cs` がコールスタック付きシナリオ間継続 |
| フィールド/マップ/カメラ/ワープ | **実装済** | `Field/FieldManager.cs`(584行)。242マップ読込+背景billboard(:443)・平面移動(:186)・固定カメラ+2Dスクロール・ドアtile110-119の自動ワープ(:257)・転送tile81-86・NPC接触(:303)・ゲーム内時計(:222) |
| GameState/フラグ・変数バンク/時計/インベントリ | **実装済（メモリ内のみ）** | `State/GameState.cs`(497行) |
| 育成ケア計算式（満腹・げんき・しつけ） | **実装済** | `GameState.cs:199 TickCareHour` が満腹D54減衰・二段階確率判定をEXEアドレス(0x800A80E4等)対応で実装。`FieldManager.TickClock` 連動 |

**実機で確認された最も進んだ画面**: twna01（はじまりの街）の覚醒カットシーン **66ページ再生 →
フィールド復帰**。
- 証拠: `workspace/notes/trackC_postcut_fix.log`（2026-07-10、pages=66 / warns=0 / ran 95.0s、
  SCRIPT_END @pc=0x1315）+ ページスクショ62枚 `workspace/notes/trackC_w4_pageshots/`
- 併せて 3D描画・日本語会話表示・番号付き選択メニューは 2026-06 のスクショで実描画確認済
  （`workspace/shots/`, `workspace/a2c_menu_full.png`）

**ビルド**: エディタ内コンパイルは通る。`workspace/a2b_compile.log`（CompileScripts 6094ms、
`error CS` 0件）+ `unity/Library/` の存在。Unity 6000.4.11f1。
※ただし **スタンドアロン実行ファイルは未生成**（`EditorBuildSettings.asset` の `m_Scenes: []` が空、
Player成果物なし）。動作確認はすべて batchmode + `RuntimeInitializeOnLoadMethod` ブートストラップ。

---

## 2. 存在しないもの（＝ゲームの背骨）

| システム | 判定 | 根拠 |
|---|---|---|
| **バトル（戦闘）** | **未着手（コード0行）** | `enemy_data/encounter_table/skills*` へのコード参照 **0件**。turn/damage ロジックなし |
| **進化条件の評価** | **未着手** | `GameState.cs:421 ApplyEvolution` は種族差し替え+ケアリセットのみ。進化条件JSON(各50KB)への参照ゼロ=進化先を決めるエンジンが無い。進化は opcode 0x49 か `DEGIMON_EVOTEST` フックでしか起きない |
| **セーブ/ロード** | **未着手** | `TitleState.cs:54 bool hasSave = false; // 永続 Save は後続フェーズ`。シリアライズ皆無 |
| **ショップ・経済** | **未着手** | shop_items.json はコメント内言及のみ |
| **NPC勧誘・繁栄度** | **未着手** | コードなし（→ §5 参照。実データは解読済） |
| **図鑑** | **未着手** | コードなし |
| 育成の疲労・排泄・病気・寿命 | **未着手** | PartnerStateに変数はあるが tick ロジックなし |
| スターター（初期パートナー） | **未確定** | `NameInputState.cs:85` 「デジタマ…は捏造しない=未設定」、新規はid=0 placeholder |

---

## 3. 即座に効く問題 — 素の状態で起動すると例外落ち

**現リポジトリを provision なしで起動すると、新規ゲーム開始で `FileNotFoundException`。**
- `NameInputState.cs:96 BindCareForm(pt, 1)` が `species_care_params.json` を読むが、
  **StreamingAssets に無い**（`food_effects.json` / `digimon_model_files.json` も同様に欠落）
- これらは repo直下 `data/` には存在し、`workspace/tools/provision_curated_data.py` が全コピーする設計
- **＝データ欠落ではなく provision（供給）漏れ**。ただし現状の unity/ を素で起動すると runtime は
  StreamingAssets しか見ないため、名前確定 → フィールド到達の手前で落ちる

→ **最優先の衛生タスク**: provision を CI/起動前フックに組み込み、「clone して起動＝動く」状態にする。
今は「動かすのに手順を知っている人が要る」状態で、これが新規参加や自動検証の障壁になる。

---

## 4. 「完了宣言」と実態のギャップ（報告がぼかして見える構造的理由）

**解析班は嘘をついていない。むしろ異様に自己批判的**（docs全体で「訂正」167件・「honest-gap」56件・
「誤り」80件・「over-claim」21件を自ら記録）。問題は次元にある。

- 「確定」730回・「GREEN」464回という完了宣言の**大半は狭い次元に貼られている**:
  コンパイル緑(CS0=0) / headless traceのスカラー一致 / byte-exactデコード / offline計算。
  これらを**ゲーム全体の進捗と読み替えると過大評価になる**。
- 決定的事実: **「ユーザーが実機で画面を見て動作OKを出す」最終sign-offが 2026-07-05 以降ずっと
  繰越・凍結**。覚醒デモですら `FAITHFUL178_land` に「完成claim FREEZE=user実視覚未達」と明記。

**具体例（but これらは各文書が自分で認めている）**:
- **イントロ178本文は未だ完全一致していない**: `introfix_run.log` で `MISMATCH matchedChars=528
  emitted=1584 oracle=1995`。best でも 1601/1995（`reg_content_v5.log`）。画面にページは出るが忠実度未達
- **会話225エントリ中110がMISMATCH**（`gamma1a_sweep_catalog.log`、GREEN=115 / real breakers=92）
- **opcode 0x6E の length fix**: 元doc「25/25 desyncを実行していた」→ 訂正で「実行ゼロ=reachable
  pathに無いdead opcode」と判明（`RE_c6fec7f_justification_correction_2026-07-12.md`）。
  実機挙動に影響しないopcodeを、merge基準を変えてまで main に入れた
- **抽出データの死蔵**: enemy/skill/evolution/shop の各JSON（合計数百KB）は揃っているが
  **コードが誰も読んでいない**。「データ集めは済み、動かすロジックが未着手」の状態
- **flag_mapping_complete.json**: "完全マッピング"を名乗るが TOWN_NPC_* 系は pattern_inference
  由来で実在せず、外部検証で全滅（§5の実データ解読で確認済）

→ つまり「GREENの但し書き（どの次元のGREENか）が報告本文に埋もれる」のがぼかしの正体。
個々の主張は正直でも、次元の限定を外して読むと実態より進んで見える。

---

## 5. 補足 — 未着手項目「NPC勧誘・繁栄度」は実データ解読済

本監査と並行して、同セッションで**勧誘フラグ・繁栄度システムを一次データ（セーブRE + dg.scn +
EXE）から解読**した。§2 の「未着手」の1つを、実装可能な仕様レベルまで埋めてある。

- 成果物: `~/Desktop/RE_勧誘フラグ・繁栄度システム解読_2026-07-15.md`
- 内容: 繁栄度=u8 var[1]（RAM 0x801638DE）、加入フラグ格納方式、フラグID↔デジモン43体対応、
  勧誘イベントの3点セット構造（SET_FLAG + VAR_ADD + 定型文）、付随ガードフラグ
- 検証: 独立エージェント再導出 + codex査読 + **事前登録の実機予測検証（繁栄度100到達まで全的中）**
- ＝ 死蔵データの一角を「動かせる仕様」に変換済み。繁栄度システムを実装する際の一次資料になる

---

## 6. 推奨する次の優先順位（実装班向け）

現状の「基礎はあるが背骨が無い」を踏まえた提案。上から順に効く。

1. **provision漏れの根治（衛生・最優先）** — §3。「clone→起動で動く」を保証。全ての自動検証と
   新規参加の前提。コストは小さく効果は全体波及。
2. **ユーザー実視覚 sign-off の解消（凍結中の最上流ブロッカー）** — §4。覚醒cutsceneを中央・前面
   表示でユーザーが実際に読んでPASSを出す。`workspace/tools/run_awakening_*.sh` が起動script。
   これが抜けている限り、覚醒系の下流タスクは全部「着手条件未満」のまま。
3. **背骨のうち1本を縦に通す** — 戦闘 or セーブ のどちらか。データ（enemy/skill JSON）が揃って
   いる**戦闘**が着手しやすい。「1体とエンカウント→ターン→ダメージ→勝敗」を最小で通すだけで、
   死蔵データが初めて動き、"技術デモ"から"ゲーム"への質的転換になる。
4. **進化判定エンジン** — 進化条件JSONを読み、ステータスから進化先を決める部分。現状の
   ApplyEvolution（適用のみ）に判定層を足す。
5. **繁栄度・勧誘** — §5 の実データがあるので、仕様調査コストゼロで着手可能。ただし戦闘/進化より
   優先度は下（街の常設NPC配置に依存するため）。

**イントロ178本文の完全一致（現在MISMATCH）は、上記より優先度を下げてよい**と考える。
プレゼンテーション忠実度の詰めであり、ゲームループの有無より緊急度は低い。

---

## 付録 — 監査に使った主要ファイル（検証可能性のため）

**実装**: `Assets/Scripts/Dialogue/DialogueRuntime.cs`, `ScenarioVM.cs`, `Field/FieldManager.cs`,
`State/GameState.cs`, `Flow/GameFlow.cs`, `Flow/TitleState.cs`, `Flow/NameInputState.cs`,
`UI/FieldCommandMenuController.cs`, `UI/FeedMenuController.cs`, `Boot/Bootstrap.cs`

**ドキュメント**: `workspace/MASTER_TASKS.md`, `workspace/G1_USER_VISUAL_LAUNCH.md`,
`docs/HANDOFF_scene_prog_2026-07-07.md`, `docs/FAITHFUL178_land_2026-07-05.md`,
`docs/RE_c6fec7f_justification_correction_2026-07-12.md`,
`docs/FOUNDATION_CORRECTION_event_system_2026-06-16.md`,
`docs/LAND_care_systemB_honest_boundary_2026-06-22.md`

**実行痕跡**: `workspace/a2b_compile.log`, `workspace/shots/introfix_run.log`,
`workspace/notes/trackC_postcut_fix.log`, `workspace/gamma1a_sweep_catalog.log`,
`workspace/notes/trackC_w4_pageshots/`（62枚）, `unity/ProjectSettings/ProjectVersion.txt`

---

*本評価はプロジェクト外の独立クロス調査による。数値（15〜25%）は機能数ベースの目安であり、
難所突破度で見れば基礎部分の達成は高い。誇張・過小評価のいずれも避け、コードとログが示す
事実に基づいて記述した。*
