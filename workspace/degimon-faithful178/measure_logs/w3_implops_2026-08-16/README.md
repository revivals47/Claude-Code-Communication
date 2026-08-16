# W3ImplementedOpsTest 実走 3 本（worker3 / #452-C）2026-08-16 09:2x

★(6-dd) 証跡は sha と枠を添えて恒久な場所へ★ / ★(6-de) 器には sha を焼かない・証跡には焼く★

## 枠（この 3 本に共通）

| 項 | 値 |
|---|---|
| worktree | `/home/ken/Desktop/Digimon/degimon_world_remake-p2w3` |
| branch | `track3/p2-script-walk` |
| ★HEAD★ | ★`76cc61bffd3bb246e38a40427251d16098dcc65c`★（3 本とも同一 HEAD） |
| 器（test） | `unity/Assets/Scripts/Editor/W3ImplementedOpsTest.cs`（sha256 `c68b39d1ecb1d95f3ee77fe6a116bdab978eed85a7f566c92d7783b3defbf685`） |
| 抽出器 | `unity/Assets/Scripts/Editor/W3UnsupportedOpcodeCensus.cs`（sha256 `9538b866da566e615a747249593b9a19d460bcac5fa3c94d9b003695245a7bd9`） |
| 対象（宣言） | `unity/Assets/Scripts/Dialogue/DialogueRuntime.cs`（★原状 sha256 `8f99a98fef9b1177d19d5f5c66a5998817027ea362a280abc34556292559ea15`★） |
| 呼び口 | `workspace/tools/w3_implops_run.sh`（p2w3・★sha を焼いていない = その時点の HEAD を走らせる★） |
| Unity | `6000.4.11f1`（`/home/ken/Unity/Hub/Editor/6000.4.11f1/Editor/Unity`）batchmode / nographics |
| ★枠★ | ★同一 build・同一 env・★別 run 3 本★★。02 のみ ★宣言を 1 種わざと落とした状態★（測定後に復元・下記） |

## 3 本

| # | log | 状態 | Unity exit | 呼び口 exit | 所要 | 宣言 / 抽出 | 差 |
|---|---|---|---|---|---|---|---|
| 01 | `01_run_head.log` | ★現 HEAD 無改変★ | ★0★ | ―（直叩き） | 14s | ★36 / 36★ | ★両方向なし★ |
| 02 | `02_control_drop_0x0D.log` | ★陽性対照 = 宣言から `0x0D` を 1 種削除★ | ★3★ | ★1★ | 17s | ★35 / 36★ | ★抽出のみ = `0x0D`★ |
| 03 | `03_restore_rerun.log` | ★復元後の再走★ | ★0★ | ★0★ | 14s | ★36 / 36★ | ★両方向なし★ |

log の sha256:
```
10b8c0eeb69153e321a895b1784be93d7122d87be28a93de2a6bdbf90dc1c60a  01_run_head.log
805405989f347e0f20c912a9b2ed9efe72b67244530b78190a51bbc8fb9f3192  02_control_drop_0x0D.log
8b3f6416dcf5e89e4f07f4f5bba942d044decb1b64c93acd37306f17653ad535  03_restore_rerun.log
```

## 対照の復元（★commit していません★）

- 改変 = `DialogueRuntime.cs:109` の `ImplementedOps` から `0x0D,` を除去（1 行のみ）
- 復元 = 事前に `cp -p` で取った原本を書き戻し
- ★検算 2 本★: `sha256sum` = `8f99a98f…` ＝ ★baseline と一致★ / `cmp` = ★byte 一致★ / `git status --short` = ★出力なし★
- ★03 の再走で PASS に戻ることも確認★（sha の一致だけでなく ★挙動でも★ 戻したことを示す）

## ★この 3 本が見ていない場所（母数の申告 / (6-cy)）★

1. ★既定 ON / OFF は見ない★ — `case` が在るかだけ。★`0x24` / `0x26` / `0x27` は case 在り・既定 OFF（`goto default`）★で、この test では「実装済」に数えられる。別軸（`GatedOff`）が log に併記されるが ★判定には入らない★。
2. ★Editor 以外の器は見ない★ — play mode / build / 実機は対象外。
3. ★手書き集合は `ImplementedOps` 1 本だけ★を見る。同 tree に残る手書きの byte 集合（棚卸し実測）:
   - `DialogueRuntime.cs:94` `JumpOps = {0x13,0x14,0x16,0x17,0x18}` — ★手書き。ただし抽出器がこれを抽出側にも足すので、この test では★構造上ずれない★（= ★この test では検出できない★）
   - `DialogueRuntime.cs:47` `Len[]` / `:127` `ExeLen97[]` — ★別 guard（`[LENGUARD]` 97/97）が持つ★
   - `Gamma1aSweep.cs:29` `InterestOps` / `W3ModeDefaultTest.cs:61,64` — ★どの器にも守られていない手書き★
   - `W3ToolNameTest.cs` の器 list は ★assembly 走査に置換済＝手書きなし★
4. ★抽出器自身の正しさは見ない★ — `ExtractDispatched` は `DialogueRuntime.cs` を ★source text の regex★ で読む。`switch (c)` の brace 対応で本体を切り出すが、★comment 内に `case OP_xxx:` の形が現れれば拾う★（現 HEAD では 0 件を grep で確認済）。
5. ★Unity は 1 project 1 instance★ — 同 project で並走すると lockfile で走れない（呼び口の exit 2 側に落ちる）。
