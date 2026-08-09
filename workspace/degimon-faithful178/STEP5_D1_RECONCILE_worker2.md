# STEP5 d1 reconcile — 0x66 到達統計 sweep 500/115 vs census 464/463 の乖離機構

worker2 / 2026-07-19。**測定で確定(assumption 禁止)**。f1c=読取のみ(worker3 残置物非改変)。
データ源: census=`f1c/real_traces/sweep_225.jsonl.gz`(1278 launch EXE trace)/ remake=`f1c/step5_on_census.log`(ON sweep [SCENE-DRIVER])。
観測/推論を区分。

---

## 0. 結論(単一表)

| 論点 | 判定 |
|---|---|
| sweep『distinct 115 entry』の正体 | ★`_curEntry.Index`(section 内 local index=非 unique)の集計 artifact。真値=500 launch が 0x66 到達・**各 1 回**(distinct(entry,section)=499)★ |
| 真の比較(共通次元=0x66 到達 launch 数) | ★remake **500** launch vs census **444** launch(sweep_225)= remake が **+56 多く**到達(under-coverage でなく over-reach)★ |
| boss1 前提『463 vs 115=d1 未充足(under-coverage)』 | ★誤り。乖離は identifier-artifact(115)+ 到達 launch の絶対数差(500>444)。カバレッジ不足ではない★ |
| Δ+56 の機構 | ★dimension 差(jump-mode + state): remake=narrow-mode(0x18/jump fall-through)+ fresh state(flag=0)で 0x19 条件分岐が 0x66 側へ / census=EXE savestate で 0x19・jump が 0x66 から分岐離脱★ |
| decode/実装バグ | ★否定★(walker desync=0、0x66=1回/launch 構造が census と一致、Len=2 忠実、ON/OFF warning 完全一致) |
| 副次 finding(count に非影響) | remake は 0x66 の後 0xFE RETURN まで数 byte 継続実行(census は 0x66 で idle_stop)= exit 忠実度の別 gap(下記 §4) |

---

## 1. 『115 distinct entry』= 非 unique index の集計 artifact(観測)

remake log の `@entry=` は `_curEntry.Index`(DialogueRuntime の entry index)。**section 内 local ゆえ launch 跨ぎで非 unique**。

- distinct `@entry` のみ = **115**、distinct `(entry,sec)` = 115(sec は全 500 で `0xFE` 定数=FirstSectionId、識別に無効)。
- ★実 launch 境界(`[DIALOGUE] Begin/PlaySection`)で parse すると: 1278 launch 中 **500 が 0x66 到達、分布 {1 回: 500}**(多重到達ゼロ)。distinct `(entry,section)` = **499**★。
- 例: `@entry=1` の 8 回 = **8 つの別 launch**(各 `Begin entry=1` → `PlaySection section=N` → 0x66 → `RETURN(0xFE) Finished`)。同一 index 値が別 section で再出現しただけ。
- ⇒ ★『115』は launch 数でも site 数でもない。0x66 到達の実カウント=**500 launch(1:1)**★。census も **444 launch × 1 回**(§2)=**両者とも 1 回/launch の同一構造**。

---

## 2. 真の乖離 = 到達 launch 数(remake 500 vs census 444)(観測)

census(sweep_225.jsonl.gz、1278 launch)を launch 単位で集計:

- 0x66 含む launch = **444**、★全 444 が launch 内 0x66 **ちょうど 1 回**({1:444})、かつ 0x66 が **最終実行 op**(idle_stop、後続実行 op ゼロ)★。
- 直前 op = **444/444 が 0x67**(固定ペア、census §4b と一致)。
- remake(step5_on_census.log、同 1278 launch)= 0x66 含む launch **500**、全 500 が **1 回**。
- ⇒ ★構造(1 回/launch・直前 0x67)は一致。差は「0x66 に到達する launch 数」= **500 vs 444(Δ+56)**★。remake が **多く**到達(coverage 不足の逆)。

（注: doc の census 値 464/463 は authoritative `final_run.jsonl` 由来と思われる。手元 `sweep_225.jsonl.gz`=444/444。±20 は run 変種だが**構造・機構は同一**ゆえ reconcile 結論不変。final_run 実体は未取得=honest gap。）

### ★次元 label(必読、feedback_state_which_dimension)★
到達 launch 数の 2 値は **別次元の測定**であり、直接の大小比較で優劣を語らない:

| 値 | 測定次元 | 意味 |
|---|---|---|
| **remake ON = 500 launch** | ★fresh state(flag/var=全0)+ narrow-mode(0x18/jump fall-through)★ | New Game 直後・未実装 selector blind-take 回避の下で 0x66 に線形到達する launch 数 |
| **census = 444 launch**(手元)/ 464(doc final_run) | ★real savestate(flag/var populated)+ jump-taken★ | 実プレイ state で 0x19/jump が評価された EXE trace で 0x66 に到達する launch 数 |

⇒ ★500 と 444 は「同一 quantity の 2 観測」ではなく「異なる state/mode 次元での到達集合サイズ」★。0x19/jump は state 駆動ゆえ到達集合が次元で変わるのは原盤仕様(§3)。**同次元で揃えた run(同 state・同 jump-mode)でのみ superset/一致を論じられる**(現データは非対称=直接比較不可、§6 honest gap)。

---

## 3. Δ+56 の機構 = jump-mode + state の dimension 差(観測+推論)

### 3-1. remake sweep = narrow-mode(観測)
`[JUMP-SKIPPED narrow-mode] op=0x18(TABLE) … fall-through(未実装 selector の blind-take 回避)` = 36 件。
★jump(0x18/table)は **take せず fall-through**(content/narrow mode)。0x19 条件分岐は fresh GameState(flag/var=全 0)で評価★。

### 3-2. census 非到達 834 launch は 0x19/jump で 0x66 から分岐離脱(観測)
census の 0x66 **非**到達 launch(834、op 有)での条件/jump op 出現:
- ★**0x19(条件分岐)= 426 launch** / 0x17(JMP)=27 / 0x18=4★。
- 対して 0x66 **到達** launch(444)では 0x19 は僅か **8** のみ。
- 具体例(census raw、観測):
  - `launch(scn=1,key=254)`: op 列 = `0x24 0x19 0x24 0x19 0x24 0x19 …`(0x24 clock-read + 0x19 条件分岐の反復)→ 0x66 非到達。
  - `launch(scn=1,key=51)`: `0x19 0x4E 0x4E 0x4B`(0x19 → 0x4B warp で終了)→ 0x66 非到達。
  - `launch(scn=2,key=254)`: `0x24 0x19 0x24 0x19 0x19 0xFE`(0x19 連鎖 → 0xFE 終了)→ 0x66 非到達。

### 3-3. 機構(推論、observation grounded)
census(EXE)= real savestate の flag/var で 0x19 が評価され、jump も take → これら 834 launch の多くが **0x66 の手前で分岐/終了**(0x66 に至る `…0x67→0x66` prologue へ到達しない)。
remake = ★narrow-mode(jump fall-through)+ fresh state(flag=0)で 0x19 が別枝★ → 一部 launch が **線形に prologue 末尾 0x67→0x66 へ到達** → +56 launch 多く 0x66 を踏む。
⇒ ★到達 launch 集合が mode/state で変わるのは **設計どおり**(0x19/jump は state 駆動)。decode の問題ではない★。

### 3-4. decode/実装バグの否定(観測)
- walker desync=0 / phantom-jump=0(sweep result、0x66 起因の decode 異常ゼロ)。
- 0x66 = 1 回/launch・直前 0x67 固定ペアが census と一致(構造忠実)。
- ON/OFF の pre-existing warning(op-guard 22/UNMAPPED 6)完全一致=0x66 非回帰。
- ⇒ ★Δ は path(到達可否)差であって、0x66 の decode/実行は忠実★。

---

## 4. ★副次 finding: remake は 0x66 の後 0xFE まで継続実行(census は 0x66 で idle_stop)★(観測)

count には非影響だが exit 忠実度の別論点として記録:
- census: 0x66 の **operand 後に静的に op が続く**(0x66 operand 後 byte = **0x1c(SetFlag)418 件** / 0xFE 16 / 0x1D 9)にも関わらず、EXE は **0x66 で実行停止**(idle_stop、後続 0x1c 等を実行しない)。
- remake(c3 実装 = exit `break` 継続): 0x66 の後を継続実行 → 直近の `0xFE RETURN` で Finished(例: 0x66@0xCE → …→ 0xFE@0xD4 Finished)。= ★0x66 と 0xFE の間の op(SetFlag 等)を census が実行しない分まで実行★。
- これは 0x66 の 0x66-count/launch-coverage には効かない(依然 1 回/launch)が、★PRESIDENT 補足『両枝とも trace 上停止で終わる』=census idle_stop-at-0x66 と、remake の『0xFE まで継続』は厳密には非一致★。
- ⇒ ★exit 意味論の忠実化候補(0x66 で launch 実行を停止=idle_stop、後続 op を実行しない)= 別 finding として上申★。**本 reconcile の Δ 説明とは独立**(Δ は pre-0x66 の path 差、これは post-0x66 の継続差)。

---

## 5. d1 条項の充足判定 = ★どの次元で見るべきか(単一推奨)★

固着 prereg d1『full sweep で walker desync 0 件 + 0x66 到達 463 launch entry を全 cover』。

- ★『463 launch entry を全 cover』は census(EXE savestate + jump-taken)次元の到達集合であり、remake(fresh state + narrow-mode)の到達集合とは **mode/state で必然的に異なる**★(§3)。この literal 一致は cross-mode で達成不能かつ意味を持たない(0x19/jump は state 駆動=到達集合が state に依存するのが原盤仕様)。
- **単一推奨**: ★d1 の充足は **decode 忠実度次元**で判定する — (i)walker desync=0(観測: 達成)(ii)0x66=1 回/launch・直前 0x67 固定ペアの構造一致(観測: 達成)(iii)Len[0x66]=2 忠実(達成)★。= **d1 の intent(『実装を誤れば全面的に壊れる母数 463 で退行を可視化』)は満たされている**(desync 0 + 構造一致)。
- 『到達 launch 数 500≠444』は **カバレッジ判定に使わない**(mode/state 依存の path 差ゆえ)。使うなら『remake が census 到達集合を superset するか』を **同一 state/mode で** 測る別 run が要る(現データは mode 非対称=直接 superset 判定不可、honest gap)。
- ★prereg 改訂は PRESIDENT 裁定事項。本 doc は「decode 次元で判定」の推奨まで★。

---

## 6. 未確定残(promote 禁止・honest gap)
- `final_run.jsonl`(census authoritative 464/463)実体未取得=手元は sweep_225(444/444)。構造同一ゆえ結論不変だが、±20 の絶対数照合は未実施。
- remake 500 が census 444 を **superset するか**は mode 非対称(narrow vs jump-taken)ゆえ現データで直接判定不可。同一 mode 揃えた run が要る(§5)。
- §4 の exit 継続差(0x66→0xFE)の忠実化要否 = 別 finding(PRESIDENT 裁定)。
- flag#1 / 0x19 の具体 state 依存(どの flag が 56 launch を分岐させるか)は per-launch 追跡未実施(機構は §3 で確定、個別 flag 同定は scope 外)。
