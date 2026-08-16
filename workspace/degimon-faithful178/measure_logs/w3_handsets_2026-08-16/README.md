# W3HandwrittenSetsTest 実走 7 本（worker3 / #435-C ②）2026-08-16

★(6-dd) 証跡は sha と枠を添えて恒久な場所へ★ / ★(6-de) 器には sha を焼かない・証跡には焼く★

## 枠（7 本に共通）

| 項 | 値 |
|---|---|
| worktree | `/home/ken/Desktop/Digimon/degimon_world_remake-p2w3` |
| branch | `track3/p2-script-walk` |
| ★HEAD★ | ★`932c9ac1265d6b57b8de55f093a6588fb5d66869`★（7 本とも同一 HEAD） |
| 器（test） | `unity/Assets/Scripts/Editor/W3HandwrittenSetsTest.cs`（sha256 `57a518e62e3e58d7199385ce1d0cd0cfb7b4a486ab160aefff3f47f0d00141cb`） |
| 対象 A | `unity/Assets/Scripts/Editor/Gamma1aSweep.cs`（★原状 sha256 `e38e6c671b17c17d08498e4cb9801fe33c3c6e6ad52a86fa50afa7839b091060`★） |
| 対象 B | `unity/Assets/Scripts/Editor/W3ModeDefaultTest.cs`（★原状 sha256 `dc436c1a10940c4ccb504e99995b69aadf748ed33007392453b62406a2dd96fb`★） |
| 対象 C | `unity/Assets/Scripts/Dialogue/DialogueRuntime.cs`（★原状 sha256 `8f99a98fef9b1177d19d5f5c66a5998817027ea362a280abc34556292559ea15`★） |
| 呼び口 | `workspace/tools/w3_handsets_run.sh`（p2w3・★sha を焼いていない★） |
| Unity | `6000.4.11f1` batchmode / nographics |
| env | ★既定のまま★（gate 3 種は触っていない。器は env を読まない） |
| ★枠★ | ★同一 build・★別 run 7 本★★。02-06 は ★1 要素だけ壊した状態★（測定後に復元・下記） |

## 7 本

| # | log | 壊した箇所（★1 要素だけ★） | PASS/FAIL | Unity exit | 呼び口 exit | 何が落ちたか |
|---|---|---|---|---|---|---|
| 01 | `01_run_head.log` | ★無改変（肯定側）★ | ★8 / 0★ | ★0★ | ★0★ | ― |
| 02 | `02_ctl_A_decl_drop_0x4E.log` | ★A 宣言側★ `InterestOps` から `0x4E` 削除 | 7 / 1 | ★3★ | ★1★ | A-1 差（生成のみ）= `0x4E` |
| 03 | `03_ctl_A_gen_4B_to_4C.log` | ★A 生成側★ `ScanOps` の warp 行 `0x4B`→`0x4C` | 7 / 1 | ★3★ | ★1★ | A-1 差（宣言のみ）= `0x4B` / （生成のみ）= `0x4C` |
| 04 | `04_ctl_B_decl_drop_0x19.log` | ★B 宣言側★ `VariableLenOps` から `0x19` 削除 | 7 / 1 | ★3★ | ★1★ | B-3 差（生成のみ）= `0x19` |
| 05 | `05_ctl_B_gen_drop_0x11.log` | ★B 生成側★ `ExeLen97` から `0x11` 削除 | 5 / 3 | ★3★ | ★1★ | B-1（96 種）/ B-3（生成のみ `0x11`）/ B-4（外れ `0x11`） |
| 06 | `06_ctl_C_jumpops_drop_0x18.log` | ★盲点 C★ `JumpOps` から `0x18` 削除 | 7 / 1 | ★3★ | ★1★ | A-2 差（宣言のみ）= `0x18` |
| 07 | `07_restore_rerun.log` | ★復元後の再走★ | ★8 / 0★ | ★0★ | ★0★ | ― |

★∴ 肯定 1 に対し 否定 5（宣言側 2 / 生成側 2 / 盲点 C 1）★
= ★どちらの側を壊しても落ちる★ ⇒ ★この test は何かを assert しています★。

log の sha256:
```
a86e256606cf37262dcc5e47c8e903e6da59daab8cc483d720a23d68b3135802  01_run_head.log
a77afa1d085fd01d5a86a8e7b762f45f543742554fe59b409089a4ddd511c644  02_ctl_A_decl_drop_0x4E.log
1a9506771c3357a954b48122c62292fb200b96a15c1ec1b958b261cc5ece68f1  03_ctl_A_gen_4B_to_4C.log
f2c19da1706c9efaa94f2145a63aeab53909165a07875dcce45059cdb488d33a  04_ctl_B_decl_drop_0x19.log
bc5a6024c7eb55964affb418d189d5fa84955952e500a491b33bc9ff5dc7320c  05_ctl_B_gen_drop_0x11.log
00f3493ef134e53fc29e0c0a992f0ed0868ffb88bd1c642ca415d00f4a952394  06_ctl_C_jumpops_drop_0x18.log
70ff17953d91f4457920af1a3e57c158b3c4f7905e4262fffdc05131dbe47f3c  07_restore_rerun.log
```

## 対照の復元（★commit していません★）

- 改変は ★毎回 1 file / 1 箇所★、置換対象が ★ちょうど 1 件★ であることを assert してから適用
- 復元 = ★事前に読んだ原本 bytes を書き戻し★
- ★検算 2 本★: `sha256` = ★3 file とも baseline 一致★ / ★07 の再走で PASS へ復帰★
  （= ★sha の一致だけでなく 挙動でも 戻したことを示す★）
- `git status --porcelain` = 測定後に ★該当 3 file の行なし★

## ★この 7 本が見ていない場所（母数の申告 / (6-cy)）★

1. ★「手書き集合 2 本」は 私が扱う数であって 母数では ありません★。
   ★算法★ = `git ls-files '*.cs'`（★母集団 118 本★）に対し
   `grep -P '\{[^{}]*0x[0-9A-Fa-f]+[^{}]*,[^{}]*0x[0-9A-Fa-f]+[^{}]*\}'`
   （= ★1 行の brace 群に hex literal が 2 個以上★）で全数走査 ⇒ ★12 site / 10 file★。
   ★本器が扱うのは 4 site★（A 1 / B 2 / C 1）⇒ ★残り 8 site は未着手★:
   `P1FlagFixture.cs:52,60,68`（byte 列 fixture・集合でない）/
   ★`W3AlignedSweep.cs:831` `int[] want`（address 期待集合・器なし）★ /
   ★`W3CellValue.cs:26`（15 値・器なし）★ / ★`GameState.cs:731` `DailyAllowanceVars`（器なし）★ /
   `workspace/feedmenu_verify.cs:64`・`workspace/registry_verify.cs:61`（standalone harness の test data）
2. ★12 も下界★ — 述語が ★1 行の brace 群 + hex★ なので、
   ★複数行にまたがる初期化子★ / ★10 進の集合★ / ★brace を使わない集合（`Contains` 連鎖・`switch` 羅列）★
   は ★捕まえていません★。⇒ 札 = ★自分の器★（述語を広げた棚卸しを別便で）。
3. ★A の生成は source text を読みます★ ⇒ `jump++` 等の行の書き方を変えると抽出が減る。
   ★安全側★ = 減れば ★不一致で落ちる★（A-0 で「抽出が空」も落とす）。★黙っては通りません★。
4. ★B は `IsInBand` を借りています★ ⇒ ★`IsInBand` 自身の正しさは見ていません★
   （それは EXE router 直読の別件）。見ているのは ★100 / 97 / 3 の整合★ だけ。
5. ★TSV 実物は読んでいません★ — `ExeTsvPath` = `workspace/degimon-faithful178/P2_LEN_EXE_worker1.tsv` は
   ★p2w3 には存在せず★（実在は Claude-Code-Communication 側）、器は ★code に焼かれた `ExeLen97` を読む★。
   100 / 97 という数は TSV footer と一致するが ★それは私が目で照合した★ もので ★器は照合していません★。
   ⇒ 札 = ★材料★（TSV を p2w3 側に置くか、器に絶対 path を渡すか。★勝手に決めていません★）。
