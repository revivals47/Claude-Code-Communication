# HANDOFF（swap 用・1 枚）— worker2 / worker3 — 2026-08-25 04:00 現在

書き手 = boss1。**worker への打鍵ゼロで書ける範囲だけ**を集めた（両名とも context 98% ゆえ
新 task を投げると auto-compact freeze を誘発する。memory: claude_compact_stall_freeze）。
出所は各行に付す。★出所が「boss1 の推測」の行は 1 行も無い★（無い物は「捕獲不能」と書いた）。

## 0. 局面（両名に共通）
- codex checkpoint 査読 = **run3（3-8 session）は NO-GO**。1 × ≤15 分の較正 session のみ conditional go。
- **不変（全件維持）** = remake code 0 行 / run 0 本 / compile 0 / push HOLD / overlay 開封禁止（#646-X）/
  視覚凍結 / read only / poll only（hbreak・Z1・実行 breakpoint は DuckStation crash ゆえ禁止）。
- park 中の稼働は **記録健全化と静的読解のみ**。

## 1. worker3（multiagent:0.3）
### 1.1 commit 済み＝失われないもの
- `workspace/degimon-faithful178/W3_850C_AUDIT_AND_SESSION1_2026-08-25.md`（commit **bdc3042**、§4/§5 追加）
  = 構造監査 4 点、第 1 session 設計、**codex NO-GO の逐語**、自己評価「統計は通ったが**的が違った**」。
- run3 設計 v2 / v3（W3_823C / W3_825C）、run2 設計（W3_801C / W3_820C）ほか。
- 較正 sim の器 11 file = `tools/w3_sim/`（commit **f83a731**、boss1 が保存。走らせていない）。
### 1.2 ★消えると失う（= ここに写した）★
**(a) s2 の別 proxy 候補**（#855-C ② の回答・原典 = worker3 03:34 の便）
- 候補 = `[X+0x64E]` = **0x80146746 が 0 になる**こと。
- 既知の書き手が書く値（worker3 実測）= 0x80105E14 → 3 ／ 0x80107D58 → 1 ／ 0x80107F64 → 0xB ／
  0x8005CB40（overlay・s0 = −1）→ 0 ／ 0x8005CB70（overlay・s0 = 0）→ 0。
- ∴ **0 を書くのは 0x8005CA7C だけ** ⇒ #806-C の代理（外部書き手 22/17/16/3）より綺麗。
- ★但し完全ではない 3 点★ = ① **−1 と 0 を分けられない**（run3 の条件 s2 == −1 に不足）。
  補助 = `[0x80141D3A] += 2` は s0 = 0 の経路だけ・外部の定数差分 7 件に +2 は無い ⇒ 組み合わせれば
  分かれる公算（**変数差分 3 ＋ 決まらない 4 = 7 件が射程外**）。② 0x80146746 の base が
  **実行時値の store 13,977 件**は射程外。③ overlay 側の書き手は**開封禁止ゆえ未計数**。
- ∴ 3 値 = **「完全な proxy は無い・但し #806-C より良い候補が 1 つ在る」**（探索はしていない）。

**(b) 0x64 の自己撤回**（原典 = worker3 03:23 の便）
- 0x07 / 0x1D / 0x20 の「消費 1 byte」を**撤回**。理由 = image 外の呼び先を `continue` で黙って飛ばし、
  打ち切り（None）ではなく **False（＝完全探索）を返していた**（memory: retreat_must_not_encode_as_pass）。
- 直後の再測 = 3 本とも**打ち切り**（image 外呼び先 11 / 1 / 1 件）。**0x0F のみ「可変」で生存**（image 外 0 件）。
- ∴ **E-1 充足 site = 618 → 582 / 652 に戻る**。checkpoint doc（d8379089）は無傷。
- sub arm から直接呼ぶ image 外 = **14 件**（0x80061AAC 〜 0x8008D9AC・全部 image の下）
  ⇒ overlay 域か別の常駐 code ⇒ **開封禁止下では原理的に閉じられない**（32 site = 4.9%）。

**(c) ★捕獲不能★ = overlay router（自己限定）の途中状態**
- worker3 は #850-C 以降「overlay router（自己限定・main EXE 側からどこまで見えるか）」を継続と宣言。
- **報告は 1 便も出ていない**（send_log 03:34 以降 worker3 発は 0 件）。
- **pane scrollback からも復元できない** — `tmux display-message -t multiagent:0.3 '#{history_size}'` = **0**
  （alternate screen ゆえ画面外に履歴が無い）⇒ ★/clear すると worker3 の頭の中の分は失われる★。
- ∴ 選択肢は 2 つだけ = ① swap 前に worker3 へ**10 行以内の handoff だけ**を求める（compact 誘発の risk を取る）
  ② 失うことを受け入れる。**boss1 推奨 = ①**（park 中で他に走る物が無く、どうせ /clear するため）。

## 2. worker2（multiagent:0.2）— 薄くてよい（完了 idle）
- 03:21 に**降板報告で完了**。以後 idle。
- 成果 = `W2_X229_SUB13.md`（worker2 の tree・commit **e60416e2**、事前登録 **a880b7fb**）。**commit 済ゆえ保全されている**。
- 結論 = 0x64 sub 13 本は**自器で確定 0 本**、**陽性対照（worker3 の 4 本）も 0 本** ⇒「私の器は劣る」を数で。
- 診断（どこまで分かったか）= ① 時間ではない（0.1 秒）② 境界ではない（arm_body は正しく返す）
  ③ **bail は呼び先ではなく `_walk` の中**・場所は未特定 ⇒ 不足 = **`_walk` が `unknown` を立てる条件の特定**。
- 副産物 = **image 外 jal 先 14 個の発見**（これが worker3 の撤回を誘発した = この lane の最大の効き目）。
- 事前登録 5 件中 3 件外し（N2 / N3 / N5）を自己申告。
  ★04:03 の swap 後 worker2 が自分で撤回★ = **N2 は「外れ」ではなく「未判定」**（理由 = `OUTIMG` flag は `_walk` に配線されておらず
  `sub_adv` の唯一の呼び手 L145 が image 外 guard L140-141 の下に在る ⇒ **flag は no-op、A/B が走っていなかった**）
  ⇒ 現況 = **2 件外れ ＋ 1 件未判定**。doc = worker2 tree `workspace/W2_X230_WALK_UNKNOWN.md`（commit fbad0768・branch track2/trace-oracle）。

## 3. 復帰した worker への最初の 3 手（boss1 案）
1. CLAUDE.md ＋ 本 doc ＋ `W3_850C_...md` ＋ `tools/w3_sim/README.md` を読む。
   ★訂正（04:05・worker2 が指摘）★ = `W1_CHECKPOINT_2026-08-25.md` は **comms repo には存在しない**。
   実体は **worker1 の tree** = `/home/ken/Desktop/Digimon/degimon_world_remake-p2w1/workspace/degimon-faithful178/W1_CHECKPOINT_2026-08-25.md`
   （memory: どの worktree で見たか書け — 私がこれを落とした）。
2. **不変を復唱**してから着手（撃つ操作は PRESIDENT の GO なしに 1 件も出さない）。
3. worker3 復帰なら = overlay router（自己限定）を**最初から**やり直す前提で範囲を宣言 → boss1 と合意してから着手。
   worker2 復帰なら = `_walk` の `unknown` 条件の特定（自器の内部・静的読解のみ）。

---

## 4. worker3 本人からの 10 行 handoff（04:03 受領・swap 直前・逐語）
★§1.2(c)「捕獲不能」は解消★ — worker3 に 10 行だけ求めて受け取った。**結論 = 失うものは無かった**。

- ① **着手宣言だけで 1 命令も読んでいない**（overlay router）。直前に見ていたのは `0x8011B2BC`（`0x64` sub 表 57）と
  **image 外呼び先 14 件（`0x80061AAC`〜`0x8008D9AC`）**。
- ② **0 件**（overlay router について確定・前提つき・未検証 いずれも 0）。
- ② 参考（既出・格つき）= **image 外 14 件は全部 image の下 = 確定** ／ **それが overlay か別常駐かは未検証**。
- ③ 次の 1 手 = **#648-C の loader 表（name ptr `0x80138990` / VA `0x80138870`・16 本）を起点に、
  `0x80061AAC`〜`0x8008D9AC` がどの overlay の VA 範囲に落ちるかを突合**（★中身は開けない・表と size だけ★）。
- ④ 落とし穴 1 = **sidecar の `Load Address` を権威にしない**（BTL/STD/VS の 3 本は誤り・真値は EXE 表の `0x80052AE0`）。
- ④ 落とし穴 2 = **image 外の jal を `continue` で飛ばすと「評価できなかった」が「満たした」に畳まれる**（#853-C で踏んで 3 本撤回）。
- ④ 落とし穴 3 = **`pgrep -f` は自分に当たる**・生死は **実 comm ＋ 出力 file の mtime/byte** の 2 系統で。
- ④ 落とし穴 4 = **同じ VA が複数 overlay の span に入る**（`0x8005CA7C` は BTL/STD/VS/KAR/MOV の全部に該当）⇒「どの overlay か」は常駐前提つき。
- ④ 落とし穴 5 = **`0x80159784` は DG.SCN entry 0 ではなく `MAPHEAD.SCN`**（先頭 23,094 byte が一致するため紛れる）。

### 4.1 boss1 の記録（この便で踏んだ型）
- worker3 は最初 **pane に text で出しただけ**で agent-send しておらず、**boss1 には 1 文字も届いていなかった**
  （pane は history_size = 0 ゆえ末尾 5 行しか拾えなかった）。★#856-C に「agent-send で返せ」と書かなかった私の落ち度★。
- ∴ 規範 = **10 行 handoff のような短い求めほど「経路（agent-send）」を明示する**。
