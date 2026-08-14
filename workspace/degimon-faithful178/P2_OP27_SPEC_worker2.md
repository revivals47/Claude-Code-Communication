# ★0x27 の 原盤側 仕様★（worker2 / boss1 #298 §3）

★★測定時点★★ = ★2026-08-14★ ／ ★事前登録★ = `P2_OP27_PREREG_worker2.md`（commit `6c8e478`・★着手前★）
★器★ = `tools/exedis.py`（★私の 器★ / 対象 = `slps_017_97.bin` / base 0x80090800）
★★∴ ★本 file の ★①〜⑥ 欄は 全部 ★私が 自分で 引きました★★★（★中継は §9 に 分離★）

## ★走査型（★『0 件』の 前提★）★
```
★写る★   = ★即値 `jal` / `j` / 条件分岐の target★ / ★gp 相対の load・store★ / ★lui+addiu の 絶対 address★
★★写らない★★ = ★★`jr` の 飛び先★★（表を 別に 読まない 限り）/ ★★register 経由の store 先★★
```

## ① handler address = ★0x800ECA60★  ⇒ ★★① 逐語★★
★★dispatch の 算術を ★実サイトで 読みました★★★（★推定して いません★ / boss1 #299 §2）
```
 ★router 0x800F0744★  0x800F07C8 `sltiu $at, $s0, 0x10` / 0x800F07D4 `sltiu $at, $s0, 0x28`
                       ⇒ ★0x10 <= op < 0x28 なら★ 0x800F07E4 `jal 0x800ec4ac`（★a0 = opcode★）
 ★band 2 の 副 router 0x800EC4AC★
   800EC4C4  `addi $v0, $v0, -0x10`   ← ★index = opcode - 0x10★
   800EC4C8  `sltiu $at, $v0, 0x18`   ← ★★上限 24★★（= 0x10..0x27）
   800EC4D4  `lui $v1, 0x8012` / `addiu $v1, $v1, -0x4f08` ← ★★表 = 0x8011B0F8★★
   800EC4DC  `sll $v0, $v0, 2`        ← ★stride 4★
   800EC4E4  `lw $v0, ($v0)` / 800EC4EC `jr $v0`
 ⇒ ★index(0x27) = 23★ / ★word の VA = 0x8011B154★ / ★★値 = 0x800ECA60★★
 ★裏取り★ = ★index 9 → 0x800EC714★ = ★私の `w2_cov` の comment（0x19 の handler）と 一致★
```

## ② `Len[0x27]` = ★2★  ⇒ ★★① 逐語★★
```
 ★router 0x800F0788★  `addiu $v0, $v1, 1` / `sw -0x6cc8($gp)`   ⇒ ★opcode 自身の +1★
 ★handler 0x800ECA64★ `jal 0x800f0edc`                          ⇒ ★operand の +1★
   ★0x800F0EDC の 中身（★私が 引きました★）★ = `lw PC` → `lbu ($v0)` → `sb ($s0)` → ★`addiu +1` / `sw PC`★ = ★★+1★★
 ★他に PC cell（`-0x6cc8($gp)`）への 書きは ★arm 内に ありません★★
 ⇒ ★★∴ ★Len = 1 + 1 = ★2★★★
```

## ③ operand の 読み方 ⇒ ★★① 逐語★★
```
 800ECA60  `addiu $a0, $sp, 0x26`   ← ★格納先 = sp+0x26（1 byte）★
 800ECA64  `jal 0x800f0edc`         ← ★★PC の byte を 1 つ 読み PC を +1★★
 800ECA6C  `lbu $a0, 0x26($sp)`     ← ★★読んだ byte を そのまま a0 へ★★
 800ECA70  `jal 0x800f31b4`         ← ★helper に 渡す★
 ⇒ ★★∴ ★operand = ★1 byte・符号なし・変換なし★★★
```

## ④ 触る cell ⇒ ★★② 部分★★（★深さ 2 まで 逐語 / 深さ 3 は 未取得★）
```
 ★handler 自身★ = ★PC cell（`-0x6cc8($gp)`）★ = ★★間接（0x800F0EDC 内で 書かれます）★★ / ★他に なし★
 ★helper 0x800F31B4★ = ★store 2 件 = ★どちらも sp（frame 保存）★★ ⇒ ★★VM の cell は 触りません★★
 ★★helper 0x800F32F4（= 0x800F31B4 が 呼ぶ 1 本目）★★:
   800F330C-331C  ★operand × 0x34★（= 52 = ★1 slot の 大きさ★）
   800F3320       `lui/addiu` ⇒ ★★base = 0x801640B8★★
   800F332C       `addiu $s0, $v0, 4`        ⇒ ★s0 = ★0x801640BC + 0x34 × operand★★
   800F3330       `lbu $v0, 0x10($s0)`       ⇒ ★★読み: 0x801640CC + 0x34 × operand（1 byte）★★
   800F333C-3350  ★下位 4 bit が 非 0 なら 下位 4 bit を 0 に する★
   800F3354       `sb $s1, 0x10($s0)`        ⇒ ★★書き: 同じ cell★★
 ★★∴ ★この cell は ★私の 捕獲器の `win[i]` と ★同一★★★（`vmtrace.py` = `0x801640B8 + i*0x34 + 0x14`）
 ★★helper 0x800F3038（2 本目）★★ = ★store 3 件 = ★追えません（register 経由）★★ / ★jal 3 件 = 0x800CBB68 / 0x800CBDF8 / 0x800F23BC★
   ⇒ ★★★未取得★★★（★深さ 3 以降は 引いて いません★）
```

## ⑤ 退出規約 ⇒ ★★① 逐語（★但し 名前は 中継★）★★
```
 800ECA78  `lui $a0, 0x8016` / `addiu $a0, $a0, 0x4068`  ⇒ ★a0 = ★0x80164068★★
 800ECA80  `addiu $a1, $zero, 2`                          ⇒ ★★a1 = 2★★
 800ECA84  `jal 0x800913c0`
   ★0x800913C0 の 中身（★私が 引きました★）★ = `addiu $t2, $zero, 0xa0` / `jr $t2` / `addiu $t1, $zero, 0x14`
   ⇒ ★★= ★A-table（0xA0）の ★関数 0x14★ を 呼ぶ★★★（★★『longjmp』という 名前は ★中継★★ = §9）
 ⇒ ★★∴ ★★`jr ra` では ありません★★★ = ★★arm は ★戻らずに 抜けます★★
```
★★∴ ★★(o) 関数境界を 先に 確かめました★★★（boss1 #299 §2）:
```
 ★0x800ECAA0-0x800ECAAC の epilogue★ = `lw $ra, 0x14($sp)` / `lw $s0, 0x10($sp)` / `addiu $sp, $sp, 0x28` / `jr $ra`
   ⇒ ★★0x800EC4AC の prologue（`-0x28` / ra@0x14 / s0@0x10）と ★一致★★★ = ★★副 router の frame★★
 ★0x800ECA8C★ = ★`beqz $at, 0x800eca8c`（0x800EC4CC）の 飛び先★ = ★★index >= 24 の 側（範囲外 arm）★★
 ⇒ ★★∴ ★★0x27 の arm は ★0x800ECA60 .. 0x800ECA88★★★ ⇒ ★★∴ ★★`jr ra` には ★到達しません★★★
```

## ⑥ 呼ぶ helper = ★即値 `jal` で ★3 件★★ ⇒ ★★① 逐語★★
```
 ★0x800F0EDC★（operand fetch・+1）/ ★0x800F31B4★（本体）/ ★0x800913C0★（A-table 0x14）
 ★★∴ ★『3 件』は ★即値 `jal` の 全数★★★ ⇒ ★★`jr` 経由は ★私の 走査型では 写りません★★（★4 家族の ② = 走査型の 外★）
```

## ⑦ ★事前登録との 突合★
| 予測 | 実測 | 判定 |
|---|---|---|
| `Len[0x27]` = 2 | ★2★ | ★当たり★ |
| 即値 `jal` = 1〜3 件 | ★3 件★ | ★当たり★ |
| 固定 address の cell >= 1 | ★1 件（0x801640B8 系）★ | ★当たり★ |
| ★退出は `jr ra`★ | ★★A-table 0x14 で 抜ける（`jr ra` に 到達しない）★★ | ★★外れ★★ |
★★∴ ★私が 先に 探した『Len が 2 で ない 側』は ★出ませんでした★★（★3 便 連続★）

## ⑧ ★worker3 が 実装する ときの 注意（★私の 座から 言える 分だけ★）★
★① ★operand は ★1 byte・変換なし★★／★② ★触る cell は ★`0x801640BC + 0x34×operand + 0x10` の 1 byte★★（★= 私の `win[operand]`★）
★③ ★処理は ★『下位 4 bit が 非 0 なら 下位 4 bit を 0 に する』★★（0x800F32F4）
★★④ ★2 本目の helper（0x800F3038）の 効果は ★未取得★★★ ⇒ ★★∴ ★★これを 実装しないで ください★★★（★私が 引いて いません★）
★⑤ ★退出は ★VM loop に 戻らない★★ ⇒ ★★『次の opcode を 続けて 実行する』実装は ★原盤と 違います★★

## ⑨ ★中継（★私は 原文 未見 / 裏を 取って いません★）★
★① `0x800913C0` = ★A(0x14) = longjmp★ … boss1 #254 §5（★私が 引いたのは ★A-table 0x14 を 呼ぶ★ ところ まで★）
★② `P2_VM_SPEC_2026-08-11.md` L89 / L349 / L261-263 … boss1 #298（★sha は ★私が 取りました★ = `051045eb5c476c14` / ★885 行★ = ★中継と 一致★）
★③ `P2_FIELD_TO_OPCODE.md` L29 = ★WIN slot0-3 は `0x800F31F4` 経由 = 0x27★ … ★★私が 引いた のは `0x800F31B4`★★（★別関数・隣接★）⇒ ★★食い違い★★（★私は どちらが 正しいか 決めません★）
★④ L40 = ★win[4] / win[5] は 窓では ない★ … ★私は 引いて いません★
