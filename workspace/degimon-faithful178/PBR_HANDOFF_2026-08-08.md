# placement re-baseline — handoff / 索引 (2026-08-08)

**性格**: 散在 doc へのポインタ + 各々に何が書いてあるかの 1 行。★全文はここに複写しない。数値・判定は必ずリンク先を読むこと★。
**状態**: ★user 実視覚 gate V2 は回答待ち★。完成 claim は本 doc では出さない。shift 説について ★「unshifted で決まり」とは書かない★。

---

## 0. ★申し送り(最初に読む)★

### 0.0 ★本日最大の教訓★

★**bytes が正しくても、bytes の解釈が完全とは限らない**★。

★視覚 gate は「最後の儀式」ではなく「別次元の測定」★:
- ★bytes = 何が load されるか★
- ★user の目 = 何が画面に居るか★

★今日の gate は実際に defect を捕まえた。bytes だけでは出なかった★。
→ 視覚 gate を「確認のための形式」として最後に付け足すのではなく、★bytes では原理的に届かない次元を測る手段★として設計する。

### 0.1 撤回の質 — A / B の分類

★撤回には 2 種類あり、価値が違う★。本 session の実データで分類する。

**★A = 自分の道具 / 自分の oracle を疑った撤回(効いた。新しい事実を生んだ)★**

| 主体 | 内容 |
|---|---|
| worker3 | 到達性 oracle の**被覆率を測って自分の結論を格下げ**(39%) |
| worker3 | ★remake を見せると V2 は同語反復★ — user に渡る直前に停止(PRESIDENT が「混同は私の側」と認めた) |
| worker3 | ★原盤に存在しないものを原盤の質問に書かない★(黄球の priming)= 観測の独立性を守る基本 |
| worker1 | roslyn standalone は Unity compile ではない(★指摘される前に自己申告★) |
| worker1 | run2 の `error CS` 0 件は「★走らなかった 0★」(Csc 行 0 / SCBP 起動 0) |
| worker1 | ★build errors=0 / 341MB の成果物を検めて StreamingAssets/maps が空と発見★ = ★成功指標でなく中身を見た★「build 成功 ≠ 動く」 |
| worker2 | 自分が回帰 oracle §5.1 に書いた失敗モード(cap 飽和)に自分が踏んでいた |
| worker2 | ★色語が未確定のまま user に質問しようとしていた★ を渡す前に摘出。★本質は「白か紫かを決めたこと」ではなく「期待値を提示しない訊き方に変えたこと」★(色は remake 側の色で、原盤の色と一致する保証がない) |
| worker2 | ★自分の解釈枠 doc が gate 分割裁定で対象ずれ(stale)を起こしていた★ — boss1 の handoff 査読で摘出、V2 / V2R に分けて改訂 |
| boss1 | `strings` 既定 ASCII が .NET UTF-16 literal を取りこぼしていた(`-el` で訂正) |
| boss1 | ★handoff 査読で worker2 の解釈枠の stale を検出★ — ★索引化作業それ自体が stale 検出器として機能した★ |
| worker3 | ★自分の doc の題「entity array に触る全 code site の列挙」を誤りとして自己訂正★ — 実際に列挙したのは ★base を組み立てる site だけ★で、★record ptr を引数で受け取る関数は原理的に見えない★ |
| worker3 | ★worker1 の scan の穴を塞いだ★ — ★`sh@0xBC` / `sw@0xBC` も `+0xBD` を覆う★。発見した 1 site(`0x800DE6F4`)は ★base が `sp` = stack local = 偽陽性★ と本人が確認 |
| boss1 | ★28 点の相関から意味へ 1 段飛ばした★。★その直後に post-hoc の選言を自分で自由度申告した★ |
| boss1 | ★base 組立 site 46 件という起点を作り、worker に渡す前に盲点に気づけなかった★(§0.2c) |

★制度が設計どおり機能した実例★: ★2 系統 scan を control として発注したことが、実際に worker3 側の同型ミスを 1 件炙り出した★。

**★B = 他人に指摘されて直した撤回(必要だが波及が小さい)★**
boss1: flatpak path / 打切り tsv / 境界の形状判断 / 「2 軸で閉じた」/ 「worker1 は誤り」/ gitignore 対象は git diff の母集団外(★4 度目の同型★)

→ ★A は新しい事実を生み、B は誤りを消しただけ★。この差が重要。

### 0.2 ★B の 5 件は 1 つの型に集約される★

boss1 が今日撤回した 5 件は、いずれも ★「自分の測定範囲を全体だと思った」★ という **同一の型**:

| 件 | 全体だと思った範囲 |
|---|---|
| flatpak path | 探索範囲 |
| 打切り tsv | list 範囲(idx 0..238 で停止していた) |
| 形状での境界判断 | table 終端 |
| 「2 軸で閉じた」 | oracle の被覆 |
| gitignore 母集団外 | build 同一性 |

★同一人物が同じ型で 5 回、しかも 5 回とも別の場所で落ちた★。
→ ★これは注意力の問題ではなく、型が見えていなかったということ★。
→ ∴ remedy は「気をつける」ではなく ★手続き★ — 制度 (iii) を置く理由がこれ。

### 0.2b ★doc は書いた瞬間から stale になりうる★

worker2 の V2 解釈枠は ★書かれた時点では正しかったが、その後の gate 分割裁定(V2=原盤 / V2R=remake)で **対象がずれた**★。内容は正しいまま、指し先だけが誤りになった。
→ ★裁定 / 前提が変わったら、既存 doc に遡って「これは今も同じ対象を指しているか」を確かめる★(`feedback_rebaseline_derived_docs_vs_code` と同型。boss1 が本日繰り返し躓いた型でもある)。

★この stale は handoff の査読で捕まった★ = ★doc を索引化する作業それ自体が stale の検出器として機能した★。
索引化は「まとめる事務作業」に見えるが、★各 doc が何を指すかを 1 行で言い直す過程で、指し先のずれが露出する★。
∴ ★closeout を事務作業として省略しない★。

★併せて: doc が参照する一次証跡が追跡下にあるかを、doc とは別に確かめる★。
実例 — PRESIDENT が「★`log` の原本を残せ」と裁定しながら、自分の原本を残していなかった★」と自己申告(`runtime_capture_2026-08-08/` を `f3a8e16` で保全)。★気づいた契機は worker1 の commit(`0f2eeff`)を見て自分の側を確認したこと★ = ★他者の保全作業が、自分の未保全を可視化した★。
★doc だけ残って根拠が消える★形になりかけた点で ★FU-4(`2799c4e` の緑が事後に確認できない)と同型★。
∴ doc の整合を見るだけでは足りず、★その doc が指す証跡が version 管理下にあるかを別途確認する★。★workspace は gitignore 配下なので、force-add しない限り「doc は残るが根拠は消える」が既定の挙動★ — ここが特に危ない。

### 0.2c ★PRESIDENT 自身による「自分の指示の限界」の記録★

★以下は PRESIDENT が自ら記録するよう指示したもの(名前入りで残す)★:

★「PRESIDENT の指示した scan 起点自体が、両方向で同じ盲点を持っていた」★

- PRESIDENT は ★「entity base + stride を READ する site を全数抽出せよ」★ と指示した
- ★この母集団は、record ptr を **引数で受け取る**関数を原理的に含まない★。★今回効いた `0x800BCC20` 群がまさにそれ★
- ∴ ★「向きを変えろ(writer → reader)」とは言ったが、母集団の作り方は writer 時代のままだった★ = ★PRESIDENT の設計ミス★
- ★boss1 も同じ起点(base 組立 site 46 件)を作って worker に渡そうとしており、渡す前に気づけなかった★

★対策★: ★次に reader を探すときは、base 組立 site だけでなく「entity を loop する関数から呼ばれる leaf」まで辿る必要がある★。

→ これは §0.2 の型(「自分の測定範囲を全体だと思った」)が ★指示の設計レベルで起きた★ 例。★向きを変えても母集団の作り方を変えなければ、同じ盲点が両方向に残る★。

### 0.3 ★A を促す制度 3 つ★

- **(i)** ★oracle を使う前に、その oracle の被覆率を測る★
- **(ii)** ★緑の名前を、実際に走らせた gate の名前と一致させる★
- **(iii)** ★不在を主張する前に、母集団が全体であることを別経路で確かめる★

### 0.4 ★結論★

★「撤回を減らせ」ではなく「撤回が出る運用を維持せよ」★。
★撤回が出ないのは規律の証拠ではなく、検証していない証拠かもしれない★。

★boss1 は止める場所を作り、かつ自分でも測る。埋めるのを worker に丸投げしない★。
実データ: 最終盤に user 提示直前で止まった 4 件はすべて worker 側から出た。★しかし session 全体では boss1 自身の実測で出た実バグの方が重い★ —

- ★YAKA25 の name 重複★(gen tool = first-wins / convert_map = last-wins で ★2 tool が逆に動いていた★)= 本 dispatch で最も重い実装バグ
- ★`savestate_ram.py` の story が u8 変数を u16 で読んでいた defect★(0xCCCC 混入まで特定)
- ★容量 assert が gating の外にあった latent bug★(差し戻しは boss1 査読から)
- `strings` 既定 ASCII の自己摘出

★実際にやったのは「段取り」+「自分の手での実測」であり、後者が無ければ YAKA25 は land していた★。
∴「止める場所を作る役」とだけ書くと、次の boss1 が ★「段取りだけ組めばよい」と読む★ — それは今日の実態と違う。

---

## 1. Phase 0(判定)

生 `.map` / EXE / RAM の bytes で shift 仮説を判定した phase。★実装着手なし★。

| doc | 内容(1 行) |
|---|---|
| `PBR_PHASE0_DESIGN_boss1_2026-08-08.md` | 本 dispatch の設計。判定 4 軸(type↔pos pairing / entity 数 / gating / 順序)と担当割り。★§2.3 の「残骸疑い」は後に撤回済★ |
| `PBR_P0_ADJUDICATION_worker2.md` | RAM ↔ json の機械判定。★6 map / 25 record で H-unshifted 全一致、shift 量 k を変えた対抗仮説は 0 件★。7/23 表の bit 単位再生成、視覚 lock の循環摘出、自分の tool の誤りの撤回 |
| `PBR_P0_RAM_INVENTORY_worker1.md` | RAM 素材の全数 inventory と savestate 読取 infra。prefix 実測、素材ごとの map 同定と有効性 |
| `PBR_P0_STREAM_GATING_worker3.md` | 生 `.map` を loader 読み順で手 parse した静的照合 / gating / ★黄 creature の oracle 監査(§6)★ / ★V1-V5 の実行形(§10-§11)★ |
| `PBR_P0_map_index_table.tsv` | map index ↔ 名前の表。★この tsv が idx 0..238 で打ち切られていたことが boss1 の誤裁定の原因(§0.2)★ |
| `pbr_p0_adjudicate.py` / `pbr_p0_crosscheck.py` | worker2 の判定 script。self-check 付き、index 0..7 限定、shift 量 k 全走査 |
| **`runtime_capture_2026-08-08/`** | ★本 dispatch の**入力 spec**(`docs/RE_field_entity_loader_2026-08-08.md`)の一次証跡★。`wp_entity_1.log` / `dis*.log` ほか **28 file**。★PRESIDENT が `f3a8e16` で保全(4,537 行、workspace は gitignore ゆえ force-add)★。`docs/RE_battle_getDamagePoint_2026-08-08.md` L7 と `docs/RE_field_entity_loader_2026-08-08.md` L6 が根拠として参照 |
| `runtime_capture_2026-07-25/` | mayo00 の生 2MB RAM dump 群(`ram_A/B.bin`、`ram_live_1628_*.bin`)。Phase 0 判定の RAM 素材 |

★log は原本を維持する(PRESIDENT 承認)★: 抽出版は我々が作った derived artifact であり、★選択的に切っていないことを後世が確認できない★。★原本が自己 authenticating である★ことに勝る形は無い、という判断。

---

## 2. Phase 1(実装)

worktree `degimon_world_remake-pbr` / branch `track1/placement-rebaseline` → main へ merge。

| commit | 内容 |
|---|---|
| `304d157` | entity re-baseline — ★`i+1` 補正撤去★ / map gating / 容量 8 fail-fast + RAM oracle infra |
| `4ace328` | 容量 assert を ★gating の内側へ移動★(boss1 査読 差し戻し) |
| `c227eaa` | ★key 設計を index へ是正★ + YAKA25 gating 誤り修正 + "story" ラベル誤りの訂正 |
| `7d6ee17` | 空 slot 11 件を権威 table に明示 + ★`index>=255` を fail-fast★ + gating を index source に統一 |
| `1bc84f3` | YAKA25 の採用根拠から到達性を外す(worker3 の被覆率測定を反映) |
| **`473ded8`** | **Merge `track1/placement-rebaseline`** |

| doc / log | 内容 |
|---|---|
| `PBR_P1_REGRESSION_ORACLE_worker2.md` | ★land 合否基準(実装より先に固定)★。pass 条件 P1/P1b/P1c/P2/P2b/P3-P10、★除外条項 X1-X16★、教訓 §6.1-6.4、判定チェックリスト |
| `PBR_P1_ISSUES_worker1.md` | ★latent bug / 未決 issue 4 件★ — ISSUE-1 ViseNpcBootstrap の baked が 7/23 artifact 由来(変更提案) / ISSUE-2 MGEN06-10 = gate ON なのに抽出が落ちている / ISSUE-3 勧誘住人は現行 remake で原理的に再現不能 / ISSUE-4 key 設計(★Phase 1 内で是正済★) |
| `PBR_P1_unity_batch_compile_2026-08-08.log` | Unity batch compile(1 回目) |
| `PBR_P1_unity_batch_compile_run2_2026-08-08.log` | 同 2 回目。★`error CS` 0 件は「走らなかった 0」だった件の一次証拠(§0.1)★ |
| `PBR_P1_unity_build_2026-08-08.log` | player build。★errors=0 / 341MB でも StreamingAssets/maps が空だった件の一次証拠★ |
| `PBR_P1_smoke_run_2026-08-08.log` | build 成果物の起動 smoke |

---

## 3. user 実視覚 gate(★回答待ち★)

| doc | 内容 |
|---|---|
| `PBR_P0_STREAM_GATING_worker3.md` §10-§11 | ★V1-V5 の実行形★。§11 が V2 / V2R の最終形(★自由記述。選択肢も色語も種名も出さない★ / §11.2 blind は既に壊れている旨を取り繕わず明記 / §11.3 user 提示文 / §11.4 採点用) |
| `PBR_V2_PREREG_INTERPRETATION_worker2.md` | ★回答が出る前に「どこまで言えるか」を固定した枠★。§3 = V2R が assert する範囲 / §4 = V2 が assert する範囲 / §5 色語問題の経緯 / §6 doc が stale 化した記録 |

★gate は 2 つに分割されている(PRESIDENT 裁定)★:
- ★V2 = **原盤** を見る★(DuckStation + `SLPS-01797_9`)。検証するのは ★`.map` bytes → type id → species table → 原盤画面上の実個体 の end-to-end★ = ★bytes 決着が原盤の実ピクセルと出会う唯一の場所★
- ★V2R = **remake** を見る★。★shift 判定ではなく動作確認★(完成 claim 凍結解除の要件)。★post-merge の remake は必ず unshifted を描くので、remake を見ても shift については同語反復★

いずれについても ★assert しない範囲★ は解釈枠 §3 / §4 を参照。

---

## 4. follow-up

★follow-up の一覧は worker1 が registry を更新する。本 doc は参照のみで、ここを一次情報にしない★。
未決として明示的に残っているもの(詳細は各 doc):

- 黄 creature 監査の残り(`PBR_P0_STREAM_GATING_worker3.md` §6.8)
- ISSUE-1 / ISSUE-2 / ISSUE-3(`PBR_P1_ISSUES_worker1.md`)
- 除外条項のうち未消化のもの — X5(MGEN17 未測定)/ X14(table 論理長 255 か 256 slot 末尾未使用か)/ X6(RAM 実測は gate ON 223 map の 2.7%)
- worker2 側の未特定: savestate `_4`/`_5`/`_6`/`_7` に対する当時の inline scan が 0 件を出した原因(★撤回済だが原因は未特定★、`PBR_P0_ADJUDICATION_worker2.md` §7.4)

---

## 5. ★`+0xBD` 関連の決着★

★出所 = boss1 経由の受領内容(worker1 / worker3 / boss1 / PRESIDENT の測定)。worker2 は本件を自分では測定していない★ — 引用時は各 doc の一次記述に当たること。

| # | 決着内容 |
|---|---|
| 1 | ★探索の向きを writer → reader に変えた。ただし起点の母集団が両方向で同じ盲点を持っていた★(§0.2c) |
| 2 | ★`+0xBD` = state 3 で毎 tick +1、`0x28`(=40)で 0 に戻る counter。**可視 flag ではない**(機構で確定)★ |
| 3 | ★4 素材 7 record すべて `+0xC0 = 0` = state machine が一度も動いていない★ → ★可視性はこの機構が支配していない★ |
| 4 | ★相関 28/28 は事実のまま、因果の読みは棄却★ — ★この書き分けを崩さないこと★ |
| 5 | ★因果反転仮説(接近した結果 tick が回った)= 次の検証対象★。★mayo00 全 0 を自然に説明する★点も併記。★未検証★ |
| 6 | ★H-alt(user が見落とした / 遮蔽された)は**未棄却**★。★「見なかった」は「居ない」より弱い★ |
| 7 | ★`script10` が原盤で表示されるかは**未決定**★ |
| 8 | ★V2R から体数を外す判断は、上記の当否に依存しない★(worker3 の指摘) |
| 9 | ★user の時間を使う線(V2R / TANE 位置 / mayo00 原盤)は全て**次 session へ持ち越し**★ |

★#4 が本節で最も壊れやすい★: ★相関 28/28 は観測として生きている。棄却されたのは「それを可視性の因果と読む」解釈のみ★。次に読む者は ★この 2 つを混ぜないこと★。
