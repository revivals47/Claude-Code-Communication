# BATTLE_CENSUS 2026-09-14 / worker2 実測値 1 枚（#933-P1）

記載は 数・逐語・出所 のみ。格は 各行 末尾に 付す。
格 = [観測] 本 file 執筆時に 再走して 貼った / [先行] 過去 census の 値（本 file では 再走せず） / [未取得] 手元に 無い
★語 未閉 の 印は w3b 以降の 節にだけ 付けてある。それより 前の 節の 開いている 箇所は §12 / §13 / 14-x を 直接 読むこと（未閉 の grep で 出る 件数は 下界）★

## 0. 換算の宣言（これが 無いと 以下の 番地は 検算 できない）

| 項目 | 値 | 出所 |
|---|---|---|
| EXE | /home/ken/Desktop/Digimon/degimon/extracted/slps_017_97.bin | [観測] |
| EXE sha256 先頭 20 | db26754d97f4673f881b | [観測] sha256sum |
| EXE size | 710656 | [観測] stat |
| BASE | 0x80090800 | [観測] |
| 換算 | file_off = VA - 0x80090800 | [観測] |
| 像の端 | 0x8013E000（以上は BSS/実行時） | [先行] |
| DG.SCN sha256 先頭 20 | 4d776b2c99755328652d | [観測] degimon_world_remake/extracted/DG.SCN |
| degimon.bin size | 381160416 | [観測] stat |
| 逆汁器 | capstone CS_ARCH_MIPS / CS_MODE_MIPS32 + LITTLE_ENDIAN / skipdata=True | [観測] |

## 1. tree / branch / HEAD（2026-09-14 実行）

| tree | branch | HEAD | dirty(tracked) | untracked |
|---|---|---|---|---|
| degimon_world_remake-p2w2 | track2/battle-re-damage | 4f02c681 | 0 | 15 |
| degimon_world_remake-vmslot | track1/vm-slot-impl | ddd4a4e0 | 0 | 4 |
| degimon_world_remake-anim43 | track1/battle-anim43 | 49ca250e | 0 | 0 |
| degimon_world_remake-assy | track1/battle-assembly | 1e2179e2 | 0 | 0 |
| degimon_world_remake-p2w1 | track1/battle-slice-impl | a86e1b2b | 0 | 1 |
| degimon_world_remake-p2w3 | track3/battle-re-ai | f7d60c27 | 0 | 1 |
| degimon_world_remake（共有） | track3/w3-phase1-op5724 | a0d5ff58 | 0 | 1 |

worker2 が 進めた commit = 0 件（p2w2 の tip 4f02c681 は 2026-08-29 の 保全 commit・私は 動かしていない）[観測] git log -1

## 2. anim setter 0x800C9CBC 逐語（VA + mnemonic + operand）

窓 = 0x800C9CBC..0x800CA064 / 234 命令 [先行]
a0 相対 store = 13 件 / remake が 写したのは +0x2E の 1 件 = ★1/13★ [先行]

```
800c9cd0  sw       $a0, 0x40($sp)
800c9ce0  lw       $v0, 8($v0)
800c9cec  lbu      $v0, 0x44($sp)
800c9cf4  sll      $v1, $v0, 2
800c9d04  lw       $v0, ($v0)
800c9d0c  beqz     $v0, 0x800ca048
800c9d38  addu     $s2, $v1, $v0
800c9d44  addiu    $s1, $v0, 0xc
800c9e10  sb       $v0, 0x22($s1)
800c9e1c  addiu    $v0, $zero, 1
800c9e20  sb       $v0, 0x24($s1)
800c9e24  sb       $zero, 0x23($s1)
800ca044  sw       $s2, 0x14($s1)
```
[観測] 2026-09-14 再走

$s1 = actor+0x0C ゆえ 実効番地 [先行]:
- 0x22($s1) = actor+0x2E
- 0x24($s1) = actor+0x30（★sb 1 = byte 代入・bit 演算ではない★）
- 0x23($s1) = actor+0x2F（0 代入）
- 0x14($s1) = actor+0x20

800c9d0c beqz $v0, 0x800ca048 = table[id]==0 で 抜ける（抜け先は 書き込み 0 の epilogue・合流点 0）[先行]

## 3. actor +0x2E 読み手 census（全数・打ち切りなし）

母数 = 関数 1546 本 / cap 4000 / ★飽和 1 本（開示）★ [観測]
器 = workspace/w2_readers.py（3 形 同時: 直 disp / base+N / 引数供給 base）[観測]
★器の 打ち切り（既定 14 件表示）を 外して 全 27 件 を 貼る★

■ 実効 +0x2e の 読み手 = ★27 件★ [観測] 2026-09-14 再走
```
800971fc fn 80097080 root=a0          base+0x18/disp0x16  lhu $v0, 0x16($t0)
8009d6b8 fn 8009d620 root=a0          base+0x1c/disp0x12  lhu $t2, 0x12($a0)
800bb230 fn 800bae54 root=a0          base+0x2e/disp0x0   lh  $v0, ($v0)
800bc318 fn 800bbea8 root=lw@800bbf04 base+0x0/disp0x2e   lbu $v0, 0x2e($s1)
800bc32c fn 800bbea8 root=lw@800bbf04 base+0x0/disp0x2e   lbu $v0, 0x2e($s1)
800c666c fn 800c6518 root=a0          base+0x0/disp0x2e   lbu $v0, 0x2e($s2)
800cac6c fn 800cabe8 root=a1          base+0xc/disp0x22   lbu $v0, 0x22($s0)
800cac7c fn 800cabe8 root=a1          base+0xc/disp0x22   lbu $v0, 0x22($s0)
800d1c68 fn 800d192c root=a0          base+0x0/disp0x2e   lhu $v0, 0x2e($a0)
800ddd8c fn 800ddb50 root=a1          base+0x0/disp0x2e   lbu $v0, 0x2e($s1)
800ddd9c fn 800ddb50 root=a1          base+0x0/disp0x2e   lbu $v0, 0x2e($s1)
800dee54 fn 800dee24 root=a0          base+0x0/disp0x2e   lbu $v0, 0x2e($s0)
80102f30 fn 80102f1c root=a0          base+0x0/disp0x2e   lh  $v0, 0x2e($s0)
80102f54 fn 80102f1c root=a0          base+0x0/disp0x2e   lh  $v0, 0x2e($s0)
80102f64 fn 80102f1c root=a0          base+0x0/disp0x2e   lh  $v0, 0x2e($s0)
80102f88 fn 80102f1c root=a0          base+0x0/disp0x2e   lh  $v0, 0x2e($s0)
80102f98 fn 80102f1c root=a0          base+0x0/disp0x2e   lh  $v0, 0x2e($s0)
80102fbc fn 80102f1c root=a0          base+0x0/disp0x2e   lh  $v0, 0x2e($s0)
80102fcc fn 80102f1c root=a0          base+0x0/disp0x2e   lh  $v0, 0x2e($s0)
80102fec fn 80102f1c root=a0          base+0x0/disp0x2e   lh  $v0, 0x2e($s0)
801079cc fn 80107970 root=lw@801079c4 base+0x0/disp0x2e   lh  $v1, 0x2e($v0)
80107c38 fn 80107970 root=lw@80107c30 base+0x0/disp0x2e   lbu $v0, 0x2e($v0)
801082ec fn 801081d4 root=lw@80108200 base+0x0/disp0x2e   lbu $v0, 0x2e($s0)
801082fc fn 801081d4 root=lw@80108200 base+0x0/disp0x2e   lbu $v0, 0x2e($s0)
80108338 fn 801081d4 root=lw@80108200 base+0x0/disp0x2e   lbu $v0, 0x2e($s0)
80108360 fn 801081d4 root=lw@80108200 base+0x0/disp0x2e   lbu $v0, 0x2e($s0)
801083d0 fn 801081d4 root=lw@801083c8 base+0x0/disp0x2e   lbu $v0, 0x2e($v0)
```

■ 27 件の 内訳 [観測]
- base+0x0/disp0x2e（= 真に actor+0x2E の 形）= 24 件
- 別 struct の 偶然一致 = 3 件（800971fc base+0x18/disp0x16 / 8009d6b8 base+0x1c/disp0x12 / 800bb230 base+0x2e/disp0x0）
- 0x2E を 0xc+0x22 の 形で 読む = 2 件（800cac6c / 800cac7c・fn 800cabe8）※上の 24 に 含む

■ 関数別 [観測]: 80102f1c=8 / 801081d4=5 / 800bbea8=2 / 800ddb50=2 / 800cabe8=2 / 80107970=2 / 他 6 関数 各 1

## 4. 0x2B(=43) との 比較 site census

窓 = 各 読み手 site の ★直後 12 命令★（宣言）/ 母数 = 27 site [観測]
探した形 = 即値 0x2b / 0x2B / ",43" の 文字列一致 [観測]

- 器の 生の hit = 1 件（800971fc: lw $a0, 0x2b4($a0)）
- ★これは 偽陽性★ = "0x2b4" の 部分文字列一致。比較命令ですらない [観測]
- ⇒ ★真の 一致 = 0 件 / 27★ [観測]

★器の 欠陥を 開示★: 本 census は 部分文字列一致ゆえ 0x2b0..0x2bf を 誤 hit する。逆に 下記は ★原理的に 見えない★（未検証であって 不在ではない）:
- 表引きで 43 を 作る形
- register 経由で 43 が 来る形
- 窓 12 命令の ★外★ で 比較する形
- lui+addiu で 43 を 合成する形

## 5. 資源路 CHDAT\MMD<N>\<CODE>.MMD

```
800a3030  lui      $v0, 0x801a
800a3034  addiu    $v0, $v0, -0x2e48      ; = 0x8019D1B8（buffer）
800a30d0  jal      0x800a46dc             ; (a0=sp+0x2c filename, a1=buffer)
800a3104  sw       $v0, 8($s0)            ; record+0x08 = buffer + buffer[0x04]
800a3108  lw       $v0, 4($s0)
```
[観測] 2026-09-14 再走

| 項目 | 値 | 出所 |
|---|---|---|
| template | 0x8012348C = "CHDAT\MMD0\" | [観測] 文字列直読 |
| 拡張子 | 0x8013D3C4 = ".MMD"（gp-0x7a48） | [観測] 文字列直読 |
| 名前表 | 0x801231A4 / [0..3] = BOYS, BOTA, KORO, AGUM | [観測] |
| digit | speciesIdx / 30 | [先行] |
| 合成形 | CHDAT\MMD<N>\<CODE>.MMD | [先行] |

## 6. 種族表

| 項目 | 値 | 出所 |
|---|---|---|
| 先頭 VA | 0x8013A924 | [先行] |
| stride | 52 | [先行] |
| entry 数 | ★180★ | [観測] 2026-09-14 再走（終端 = name 先頭 2 byte が 00 00） |
| 名前 | +0x00 / Shift-JIS | [先行] |
| 種族別 list | +0x23 / 0xFF 終端 | [先行] |
| 引き手 | 0x80104250(rec, x) = rec[0x23 + (x - 0x2E)] | [先行] |

## 7. disc 上の 実 file 数

| 文字列 | 件数 | 出所 |
|---|---|---|
| .MMD;1 | ★178★ | [観測] 2026-09-14 再走 degimon.bin 全走査 |
| CHDAT | 8 | [観測] 同上 |
| MMD0 | 6 | [観測] 同上 |

## 8. 事件 VM router の band 導出

```
800f07c8  sltiu    $at, $s0, 0x10
800f07cc  bnez     $at, 0x800f07f4
800f07d0  nop
800f07d4  sltiu    $at, $s0, 0x28
800f07d8  beqz     $at, 0x800f07f4
800f07dc  nop
800f07e0  move     $a0, $s0
800f07e4  jal      0x800ec4ac
800f07e8  nop
800f07ec  b        0x800f0910
800f07f0  nop
800f07f4  sltiu    $at, $s0, 0x28
800f07f8  bnez     $at, 0x800f0820
800f07fc  nop
800f0800  sltiu    $at, $s0, 0x40
800f0804  beqz     $at, 0x800f0820
```
[観測] 2026-09-14 再走 → band 0x10-0x27 が 0x800ec4ac / band 0x28-0x3F が 0x800ecab4

```
800ec4c4  addi     $v0, $v0, -0x10
800ec4c8  sltiu    $at, $v0, 0x18
800ec4cc  beqz     $at, 0x800eca8c
800ec4d0  nop
800ec4d4  lui      $v1, 0x8012
800ec4d8  addiu    $v1, $v1, -0x4f08     ; = 0x8011B0F8（★lui 符号拡張★ 0x8012 - 0x4f08）
  --
800ecad4  addi     $v0, $v0, -0x28
800ecad8  sltiu    $at, $v0, 0x18
800ecadc  beqz     $at, 0x800ed404
800ecae0  nop
800ecae4  lui      $v1, 0x8012
800ecae8  addiu    $v1, $v1, -0x4e60     ; = 0x8011B1A0
```
[観測] 2026-09-14 再走。各 band 24 entry（sltiu 0x18）

## 9. tag dispatch / selector

| 項目 | 値 | 出所 |
|---|---|---|
| tag 表 0x8011B40C | 16 entry / 相異なる arm = 16 | [観測] 2026-09-14 再走 |
| selector guard 0x800F53DC | 語 = 0x2c410017 = sltiu $at,$v0,0x17 ⇒ ★23 entry★ | [観測] 2026-09-14 再走 |
| selector 0x800F53C8 の 23 entry 内訳 | 形 A 絶対 15 / 形 B gp 相対 6 / 形 C 読取専用 mirror 2 | [先行] |

## 10. anim interpreter 0x800CA064（[先行]・本 file では 再走せず）

窓 = ..0x800CA4D8 / 285 命令 / 基本 block 29 / caller 11 [先行]
$s1 = actor+0x0C / $s2 = actor+0x1C / $s0 = actor+0x20 [先行]
loop 頭 0x800CA43C: andi 0xfff → actor+0x28 と actor+0x1C を 比較・一致で dispatch [先行]
dispatch 0x800CA13C: andi 0xf000 の 4 値 [先行]

| arm | 入口 | 命令数 | 消費 byte | 出所 |
|---|---|---|---|---|
| 0x0000 | 0x800CA188 | 10 | cursor +2 / jal 0x800CA884(a0=sp+0x20, a1=$s0)・消費は ★未解決★ | [先行] |
| 0x1000 | 0x800CA1B0 | 16 | ★2★（旧値 4 は 誤り・#933-P8 で 訂正）| [実測] 2026-09-14 再走 / 陽性対照 2 件 = 0x3000 の 8 と 0x4000 の 4 は 旧値と 一致（器の 一様故障 ではない）/ boss1 独立照合 = 窓 0x800CA064..0x800CA4D8 の cursor 書込 全 12 件と 突合 一致 |
| 0x2000 | 0x800CA1F0 | 32 | 抜けは +4 / 継続は +2 | [先行] |
| 0x3000 | 0x800CA270 | 70 | 8 / jal 0x8009492C | [先行] |
| 0x4000 | 0x800CA388 | 45 | 4 / 条件 *(sp+0x30)+0x35 == 1 / jal 0x800CF96C | [先行] |
| 0x5000..0xF000 | - | - | 800CA180 bnez → loop 頭・cursor を 進めない | [先行] |

★本表の 4 arm 行は #933-P8（本 file 末尾の worker2 追記）が 上書きする★（格 [先行] → [観測]）。0x2000 の 「継続は +2」も 同節で 精密化した。

## 11. overlay loader 0x801044AC（[先行]）

| 項目 | 値 |
|---|---|
| caller | 17 件 |
| 名前 pointer 表 | 0x80138990 |
| load VA 表 | 0x80138870 |
| entry | 16 |
| sidecar と 食い違う | BTL_REL.BIN / STD_REL.BIN / VS_REL.BIN = 0x80052AE0（sidecar は 別値） |
| 直 caller 0 件 | DOO2_REL.BIN |

## 12. ★未取得★（boss1 が 対象例に 挙げたが 私の 手元に 無い）

- ★MMD idx43 census 167/178★ = [未取得]・★未閉★。私の doc / comms repo / p2w2 workspace を grep して ★0 件★。この数は 私の 実測では ない
- ★0 の 11 種 全列挙★ = [未取得]・★未閉★。同上・私は 取っていない
- ⇒ この 2 つの 出所は worker1 か worker3。私からは 書けない（捏造しない）
- なお 私が 持つ 隣接値は §7 の .MMD;1 = 178 のみ。178 という 分母は 一致するが、★167 の 側は 私の 観測では ない★

## 13. 未解決（意図的に 空欄・推測を 置かない）

- 0x800CA884 = ★閉じた★（§15 で 全文 102 命令 読了）
- 0x8009492C の 間接 jalr 先（*(0x8011CB8C)+0x08）= ★未閉★（0x8009492C 本体は 14-6 で 読了・jalr 先は 未読）
- 0x800CF7AC = ★閉じた★（14-7 で 全文 77 命令 読了）
- 0x80092C84 = ★未閉★（先頭 30 命令のみ 読んだ・全文 未読）
- DG.SCN の 0x10 opcode 長さ規則 = ★未閉★（83 entry で 打ち切り・開示済）
- btl overlay 全域 = ★未閉★（私の 器は slps 像内のみ 走査ゆえ 原理的に 見えない。※ 0x800CA884 と 0x800CAA1C の caller census だけは §15 で overlay 16 file も 走査した）

---

# BATTLE_CENSUS 2026-09-14 / worker3 実測値（#933-P3 直列 2 番目）

## w3-0. 換算の宣言
- slps = /home/ken/Desktop/Digimon/degimon/extracted/slps_017_97.bin / base 0x80090800 / sha256 db26754d…565c3e27 / 710656 byte / 像 = [0x80090800, 0x8013E000)
- btl  = /home/ken/Desktop/Digimon/degimon/extracted/btl_rel.bin / base 0x80052AE0（worker2 実測）/ 179412 byte
- disc = /home/ken/Desktop/Digimon/degimon/degimon.bin / MODE2 2352 / user data offset 24
- tree = /home/ken/Desktop/Digimon/degimon_world_remake-p2w3 / branch track3/battle-re-ai / HEAD dede9499d16e0b9d0c863f67d754656a50f18c43
- 器 = w3_phase.py / w3_disc.py / w3_anim.py / w3_field.py / w3_disp.py / census.py（すべて上記 tree の workspace/p2_opcode_sweep_20260913/ に commit 済）

## w3-1. phase 表 11 行

f_8005CA7C = 8005CA7C..8005CB8C / 70 命令 / btl

| # | 番地 | 命令 | 像 | 位置 | 役割の格 | 読了の範囲 |
|---|---|---|---|---|---|---|
| 1 | 80056CA8 | 529 | btl | 本 loop の外・前 | 観測 | 全文 |
| 2 | 800574EC | 453 | btl | 本 loop の外・前（自前 frame loop） | 未判定 | ★339 行中 269 行（残り 70 行 未読）★ |
| 3 | 80057C00 | 222 | btl | 本 loop 頭・唯一の出口 | 観測 | 全文 |
| 4 | 80057F78 | 646 | btl | 本 loop 内 | 未判定 | ★本 session 未再読★ |
| 5 | 80058990 | 443 | btl | 本 loop 内 | 未判定 | ★本 session 未再読★ |
| 6 | 8005907C | 194 | btl | 本 loop 内 | 観測 | 全文 |
| 7 | 80059384 | 131 | btl | 本 loop 内 | 観測 | 全文 |
| 8 | 8005FCE8 | 79 | btl | 本 loop 内 | ★推論★ | 全文 |
| 9 | 801045E8 | 97 | slps | 本 loop 内 | 観測 | 全文 |
| 10 | 8010476C | 18 | slps | 本 loop の外・後 | 観測 | 全文 |
| 11 | 80059590 | 286 | btl | 本 loop の外・後（自前 frame loop） | 観測 | 全文 |

- 観測 7 / 推論 1 / 未判定 3 / 合計 11
- phase 8 が推論である根拠（2 点のみ）= 条件分岐 0 本 / 0x8013CDB4 を 1 度も引かない
- loop の実体（逐語）: 8005CABC jal 0x80057c00 ／ 8005CAC4 bnez v0, 0x8005cb14 ／ 8005CB0C b 0x8005cabc ／ 8005CB14 jal 0x8010476c
- 全文 = 上記 tree の W3_PHASE_01.txt(416) / 02.txt(340) / 03.txt(166) / 06.txt(138) / 10_8_9_7.txt(246) / 11f.txt(214)

## w3-2. MMD idx 43 census

- 器 = w3_disc.py（自己 test = /CHDAT/MMD0/BOTA.MMD 22092 byte が extracted/bota.tmd と sha256 一致）＋ w3_anim.py
- 母数 = 名前表 0x8013CE24（8 byte stride）の実名項のうち disc に .MMD が在るもの = ★178★
- 除外 ★0★ ／ 打ち切り ★0★ ／ 合計 128 + 11 + 25 + 14 = ★178★

| 区分 | 数 | 定義（何を数えたか） |
|---|---|---|
| 綺麗 | ★128★ | w3_anim.py が「総 frame 数に到達して完走」かつ「実行命令 2 個以上」かつ「総 frame 数が 1..600」 |
| entry 0 | ★11★ | word @ (buffer + 4*43) == 0（setter 800C9D0C beqz が何もせず返る枝） |
| 表の外 | ★25★ | 上記以外で、表の枠数が 43 以下。枠数 = entry が 0 か 4*(k+1) 以上である限り数えた k（陽性対照 = BOTA が 47） |
| 未説明 | ★14★ | 上記いずれにも該当しない |

- buffer = actor+0x08 = mmd + mmd の word[1]（loader 800A2F64 で観測）
- N = master 表 0x8013A924（stride 52）の +0x14 の下位 byte
- header = 2 + (N-1) * (18 または 12)（setter 800C9F14 bnez の 2 枝）

★entry 0 の 11 種 全列挙★
BOYS / BRIK / EBAK / EELE / ELEO / EPEN / EUNI / JIJI / JURE / PUTI / TONO

★表の外 25 種 全列挙★
ANLG / BRAK / CEGR / EAND / EANG / ECEN / EGOB / EHOE / EKUW / EMNO / EMOJ / EMON / ENAN / EPIY / ESCU / ESEA / ESHE / ESIR / EVED / EVEG / EYUK / HAGU / SCUD / TENS / TIRS

★未説明 14 種 全列挙★
EETE / EKAB / ETEM / EVAN / HKAB / KABU / KUWA / MRIS / MTET / SHEL / SIMA / SNDY / UNIM / YANM

- 名前表の全項 = 183（実名 180 ＋ 接尾辞 3 = .MMD / .TMD / .MTN）
- 名前表にあって disc に無い = 2（wEAG / tAKA）／ disc にあって名前表に無い = 0
- master 表の連続件数 = 180
- 否定済の仮説: 重複 file（178 件すべて sha256 相異・重複 group 0 件）／ N の違い（39 件中 26 件はどの N（1..40）でも解けず）

## w3-3. +0x53

★[A] 表 slot に値を入れる命令（slps）★
```
800ac330: 3c028017  lui   $v0, 0x8017
800ac334: 2442b048  addiu $v0, $v0, -0x4fb8
800ac338: 3c018014  lui   $at, 0x8014
800ac33c: ac22cdb4  sw    $v0, -0x324c($at)

800a62a4: 3c028017  lui   $v0, 0x8017
800a62a8: 2442b084  addiu $v0, $v0, -0x4f7c
800a62ac: 3c018014  lui   $at, 0x8014
800a62b0: ac22cdb8  sw    $v0, -0x3248($at)
```

★[B] +0x53 に書く site（btl・80056E1C から 80056E58 まで連続）★
```
80056e1c: 8f829214  lw    $v0, -0x6dec($gp)
80056e24: 00521021  addu  $v0, $v0, $s2
80056e28: 9042066c  lbu   $v0, 0x66c($v0)
80056e30: 00021880  sll   $v1, $v0, 2
80056e34: 3c028014  lui   $v0, 0x8014
80056e38: 2442cdb4  addiu $v0, $v0, -0x324c
80056e3c: 00431021  addu  $v0, $v0, $v1
80056e40: 8c420000  lw    $v0, ($v0)
80056e48: afa20028  sw    $v0, 0x28($sp)
80056e4c: 8fa20028  lw    $v0, 0x28($sp)
80056e54: 24510038  addiu $s1, $v0, 0x38
80056e58: a220001b  sb    $zero, 0x1b($s1)
```
同 loop の添字条件
```
80056fb0: 22520001  addi  $s2, $s2, 1
80056fb4: 87829234  lh    $v0, -0x6dcc($gp)
80056fbc: 0052082a  slt   $at, $v0, $s2
80056fc0: 1020ff96  beqz  $at, 0x80056e1c
```

★[C] land 済の 1 の書込（btl）★
```
8005c298: 00808821  move  $s1, $a0
8005c2a4: 24020001  addiu $v0, $zero, 1
8005c2a8: a0220053  sb    $v0, 0x53($s1)
```
f_8005C288 の caller = 2 件
```
8005817c 直前: 80058170 move $a0, $s2
80058c54 直前: 80058c4c lw   $a0, 0x38($sp)
```

★[D] 表[1]+0x53 を絶対番地で書く site（btl）★
```
80057ca0: 3c018017  lui $at, 0x8017
80057ca4: a020b0d7  sb  $zero, -0x4f29($at)
```

★番地算術★
```
表[0]                  = 0x8016B048
表[1]                  = 0x8016B084
表[1] - 表[0]          = 0x3C（60）
表[0] + 0x53           = 0x8016B09B
0x8016B09B - 表[1]     = 0x17
表[1] + 0x53           = 0x8016B0D7   ← [D] が書く番地
0x80170000 - 0x4f29    = 0x8016B0D7
```

★数の格★
- 3 形の器（w3_field.py）= 2 件と出たが ★陽性対照 3 件中 8005C2A8 が落ちた★ ⇒ この数は捨てた
- disp だけの走査 = ★33 件は上限★（disp 0x1B は 表[]+0x38 の専用ではない・他構造体にも当たる）
- 表[] に帰属できると言える site = ★[B] / [C] / [D] の 3 件のみ★
- B[0x66C+s2] の書き手 5 件のうち: 8010727C = 定数 1（添字 0）／ 80107844・80107884 = s0 が 2 起点 slti 0xa ／ 80107328 = event var 0xFB/0xFC/0xFD（801072CC addi v0,s0,0xfb ／ 801072D4 jal 0x800f0ac8）／ 8010743C = f_80107258 の引数（caller 1 件 = 800AED2C）
- ★矛盾が実在するとも実在しないとも書かない★（event var 0xFB..0xFD が 0 を取りうるかは未検証）

---

# BATTLE_CENSUS 2026-09-14 / worker2 追記 #933-P8（直列 3 番目）

対象 = anim interpreter 0x800CA064 の 上位 nibble arm。母数 4（0x1000 / 0x2000 / 0x3000 / 0x4000）・4/4 埋めた。
本節は §10 の 4 arm 行を 上書きする（§10 の 格 = [先行] / 本節の 格 = [観測] 2026-09-14 再走）。
★4 arm に 名前は 付けない★（動作は 番地と 命令で 書く）。

## 14-0. 器と換算

| 項目 | 値 | 出所 |
|---|---|---|
| EXE | /home/ken/Desktop/Digimon/degimon/extracted/slps_017_97.bin | [観測] |
| EXE sha256 先頭 8 | db26754d | [観測] sha256sum |
| EXE size | 710656 | [観測] stat |
| BASE / 換算 | 0x80090800 / file_off = VA - 0x80090800 | [観測] |
| 逆汁器 | capstone 5.0.7 / CS_ARCH_MIPS / CS_MODE_MIPS32 + LITTLE_ENDIAN / skipdata=True | [観測] |
| 器の path | degimon_world_remake-p2w2 の workspace/w2_dis.py | [観測] |
| tree / branch / HEAD | degimon_world_remake-p2w2 / track2/battle-re-damage / 4f02c681 | [観測] git |
| 本 task での p2w2 編集 | 0 件 | [観測] |

## 14-1. decode 不能・打ち切り

| 窓 | 命令数 | skipdata の .byte | 出所 |
|---|---|---|---|
| 0x800CA064..0x800CA4D8 | 285 | ★0 件★ | [観測] |
| 0x8009492C..0x800949E0 | 46 | 0 件 | [観測] |
| 0x800CF96C..0x800CFA3C | 53 | 0 件 | [観測] |
| 0x800CF7AC..0x800CF8DC | 77 | 0 件 | [観測] |
| 0x800CF6F4..0x800CF7A8 | 46 | 0 件 | [観測] |

- 印字すべき decode 不能 address = ★無し★（0 件ゆえ）
- 打ち切り = ★0 件★（窓は 命令数で 全長指定・cap を 置いていない）

## 14-2. 母数と 上位 nibble の 落ち先 全 16 値

dispatch 0x800CA13C の andi 0xf000 ⇒ 取りうる値 16。落ち先の 全列挙 [観測]:

| 値 | 落ち先 | 根拠の 命令 |
|---|---|---|
| 0x0000 | 0x800CA188 へ fall-through（cursor +2 / jal 0x800CA884） | 0x800CA180 bnez が 不成立 |
| 0x1000 | 0x800CA1B0 | 0x800CA178 beq $v0,$at |
| 0x2000 | 0x800CA1F0 | 0x800CA16C beq $v0,$at |
| 0x3000 | 0x800CA270 | 0x800CA160 beq $v0,$at |
| 0x4000 | 0x800CA388 | 0x800CA154 beq $v0,$at |
| 0x5000..0xF000（11 値） | 0x800CA43C（cursor を 進めない） | 0x800CA180 bnez $v0 |

- 16 = 4（母数）＋ 0x0000 ＋ 11。★0x5000..0xF000 の 11 値の 到達可能性は 未確認★（列に この 上位 nibble が 現れるかを 測っていない）
- 各 arm への 外部入口 = 全数 1 本ずつ（branch target census。arm 範囲内を 指す 他の branch は arm 自身のもの だけ）[観測]

## 14-3. register と state の 地図（prologue 逐語から 再確認）

```
800ca084: 2451000c  addiu     $s1, $v0, 0xc
800ca088: 26300014  addiu     $s0, $s1, 0x14
800ca08c: 26320010  addiu     $s2, $s1, 0x10
```
[観測] 2026-09-14 再走

| register / disp | 実効番地 | 本節での 呼び方 |
|---|---|---|
| $s1 | actor+0x0C | - |
| $s0 | actor+0x20 | cursor（u16 列への pointer）を 入れた word の 番地 |
| $s2 | actor+0x1C | 現在 frame の 番地 |
| 0x12($s1) | actor+0x1E | 総 frame 数 |
| 0x18($s1) | actor+0x24 | cursor の 控え |
| 0x1c($s1) | actor+0x28 | 次 event frame（語の 下位 12bit） |
| 0x1e($s1) / 0x20($s1) | actor+0x2A / actor+0x2C | arm 0x3000 が 足す 基点 |
| 0x23($s1) | actor+0x2F | byte |
| 0x24($s1) | actor+0x30 | bit0 |

- 窓全体の cursor 書込（sw の 先が $s0）= ★12 件★ = 800CA104 / 800CA194 / 800CA1D8 / 800CA22C / 800CA244 / 800CA264 / 800CA27C / 800CA2C0 / 800CA310 / 800CA360 / 800CA394 / 800CA438 [観測。boss1 独立照合と 一致]
- 内訳 = 先頭語 判定部 1（800CA104）＋ 0x0000 の 1 ＋ 0x1000 の 1 ＋ 0x2000 の 3 ＋ 0x3000 の 4 ＋ 0x4000 の 2 = 12・残余 0
- 0x800CA43C..0x800CA4B8 の cursor 書込 = 0 件 [観測。boss1 独立照合と 一致]

## 14-4. arm 0x1000 = 0x800CA1B0..0x800CA1EC / 16 命令

■ 何もしない条件
- arm 内の 条件分岐 = ★0 本★ ⇒ arm に 入れば 必ず 3 つ 書く（actor+0x2F / cursor / actor+0x24）。arm 内に 何もしない条件は 存在しない
- arm に 入らない gate（arm の 外・3 件）= 0x800CA0A8 beqz $v0, 0x800ca4bc（actor+0x30 の bit0 が 0）／ 0x800CA468 beq $v1,$v0 が 不成立（actor+0x1C と actor+0x28 が 不一致）／ 語の 上位 nibble が 0x1000 でない

■ 逐語 16 行
```
800ca1b0: 8e020000  lw        $v0, ($s0)
800ca1b4: 00000000  nop       
800ca1b8: 84420000  lh        $v0, ($v0)
800ca1bc: 00000000  nop       
800ca1c0: 304200ff  andi      $v0, $v0, 0xff
800ca1c4: 304200ff  andi      $v0, $v0, 0xff
800ca1c8: a2220023  sb        $v0, 0x23($s1)
800ca1cc: 8e020000  lw        $v0, ($s0)
800ca1d0: 00000000  nop       
800ca1d4: 24420002  addiu     $v0, $v0, 2
800ca1d8: ae020000  sw        $v0, ($s0)
800ca1dc: 8e020000  lw        $v0, ($s0)
800ca1e0: 00000000  nop       
800ca1e4: ae220018  sw        $v0, 0x18($s1)
800ca1e8: 10000094  b         0x800ca43c
800ca1ec: 00000000  nop       
```
[観測] 2026-09-14 再走

■ 説明
- 語 = 0x1nnn。下位 byte を actor+0x2F に 代入（andi 0xff が 2 回 連続・冗長だが 逐語のまま 貼った）
- cursor を +2 した 後の 値を actor+0x24 に 控える
- cursor 書込 = 1 件（0x800CA1D8）・直前が 0x800CA1D4 addiu $v0,$v0,2 ⇒ ★消費 = 2★
- 同じ 3 動作が 0x800CA0DC..0x800CA110 にも 在る（0x800CA0D0 andi $v0,$v0,0x1000 の 成立枝 = 列の 先頭語に この bit が 立つ 場合）

## 14-5. arm 0x2000 = 0x800CA1F0..0x800CA26C / 32 命令

■ 何もしない条件
- ★arm 全体が 何もしない条件 = 無し★（2 つの 出口の どちらも cursor を 書く）
- 部分的に 何もしない条件 = 1 件。actor+0x2F が 0xFF のとき 0x800CA1F8 beq $v0,$at,0x800ca210 で 減算だけ を 飛ばす（actor+0x2F 不変）
- arm に 入らない gate は 14-4 と 同じ 3 件

■ 逐語 32 行
```
800ca1f0: 92220023  lbu       $v0, 0x23($s1)
800ca1f4: 240100ff  addiu     $at, $zero, 0xff
800ca1f8: 10410005  beq       $v0, $at, 0x800ca210
800ca1fc: 00000000  nop       
800ca200: 92220023  lbu       $v0, 0x23($s1)
800ca204: 00000000  nop       
800ca208: 2442ffff  addiu     $v0, $v0, -1
800ca20c: a2220023  sb        $v0, 0x23($s1)
800ca210: 92220023  lbu       $v0, 0x23($s1)
800ca214: 00000000  nop       
800ca218: 14400007  bnez      $v0, 0x800ca238
800ca21c: 00000000  nop       
800ca220: 8e020000  lw        $v0, ($s0)
800ca224: 00000000  nop       
800ca228: 20420004  addi      $v0, $v0, 4
800ca22c: ae020000  sw        $v0, ($s0)
800ca230: 10000082  b         0x800ca43c
800ca234: 00000000  nop       
800ca238: 8e020000  lw        $v0, ($s0)
800ca23c: 00000000  nop       
800ca240: 24420002  addiu     $v0, $v0, 2
800ca244: ae020000  sw        $v0, ($s0)
800ca248: 8e020000  lw        $v0, ($s0)
800ca24c: 00000000  nop       
800ca250: 84420000  lh        $v0, ($v0)
800ca254: 00000000  nop       
800ca258: a6420000  sh        $v0, ($s2)
800ca25c: 8e220018  lw        $v0, 0x18($s1)
800ca260: 00000000  nop       
800ca264: ae020000  sw        $v0, ($s0)
800ca268: 10000074  b         0x800ca43c
800ca26c: 00000000  nop       
```
[観測] 2026-09-14 再走

■ 説明
- actor+0x2F を lbu（符号なし byte）で 読む。0xFF は 減らさない
- 減算後 actor+0x2F が 0 ⇒ 0x800CA228 addi $v0,$v0,4 で cursor +4（語 2 つ = 0x2nnn と 直後の operand を 飛ばす）
- 0 でない ⇒ cursor を +2 して operand 語を lh で 読み、0x800CA258 sh $v0,($s2) で actor+0x1C に 代入。続いて 0x800CA25C lw $v0,0x18($s1) / 0x800CA264 sw $v0,($s0) で cursor を actor+0x24 の 値に する
- ★§10 の 「継続は +2」の 精密化★: この +2 は 直後 0x800CA264 の sw で 上書きされる ⇒ 継続枝の 正味 cursor 変化は +2 ではなく ★actor+0x24 の 値への 置換★
- arm 内の cursor 書込 = 3 件（0x800CA22C / 0x800CA244 / 0x800CA264）・全列挙

## 14-6. arm 0x3000 = 0x800CA270..0x800CA384 / 70 命令

■ 何もしない条件
- arm 内の 条件分岐 = ★0 本★ ⇒ arm に 入れば 必ず cursor +8 と jal 0x8009492C
- 呼び先 0x8009492C が 何も 積まずに -1 を 返す 条件 = 2 件（逐語）:
```
8009495c: 86020004  lh        $v0, 4($s0)
80094964: 10400019  beqz      $v0, 0x800949cc
8009496c: 86020006  lh        $v0, 6($s0)
80094974: 14400003  bnez      $v0, 0x80094984
```
  ⇒ a0 の +0x04 が 0（下記 W2 の 上位 byte）／ a0 の +0x06 が 0（W2 の 下位 byte）
- なお 0x80092C84 は この 判定より 前（0x80094954 jal）に 呼ばれる

■ 逐語 70 行
```
800ca270: 8e020000  lw        $v0, ($s0)
800ca274: 00000000  nop       
800ca278: 24420002  addiu     $v0, $v0, 2
800ca27c: ae020000  sw        $v0, ($s0)
800ca280: 8e020000  lw        $v0, ($s0)
800ca284: 00000000  nop       
800ca288: 84420000  lh        $v0, ($v0)
800ca28c: 00000000  nop       
800ca290: 3042ff00  andi      $v0, $v0, 0xff00
800ca294: 00021a03  sra       $v1, $v0, 8
800ca298: 8622001e  lh        $v0, 0x1e($s1)
800ca29c: 00000000  nop       
800ca2a0: 00431020  add       $v0, $v0, $v1
800ca2a4: 00021400  sll       $v0, $v0, 0x10
800ca2a8: 00021403  sra       $v0, $v0, 0x10
800ca2ac: a7a20024  sh        $v0, 0x24($sp)
800ca2b0: 86240020  lh        $a0, 0x20($s1)
800ca2b4: 8e030000  lw        $v1, ($s0)
800ca2b8: 00000000  nop       
800ca2bc: 24620002  addiu     $v0, $v1, 2
800ca2c0: ae020000  sw        $v0, ($s0)
800ca2c4: 84620000  lh        $v0, ($v1)
800ca2c8: 00000000  nop       
800ca2cc: 304200ff  andi      $v0, $v0, 0xff
800ca2d0: 00821020  add       $v0, $a0, $v0
800ca2d4: 00021400  sll       $v0, $v0, 0x10
800ca2d8: 00021403  sra       $v0, $v0, 0x10
800ca2dc: a7a20026  sh        $v0, 0x26($sp)
800ca2e0: 8e020000  lw        $v0, ($s0)
800ca2e4: 00000000  nop       
800ca2e8: 84420000  lh        $v0, ($v0)
800ca2ec: 00000000  nop       
800ca2f0: 3042ff00  andi      $v0, $v0, 0xff00
800ca2f4: 00021203  sra       $v0, $v0, 8
800ca2f8: 00021400  sll       $v0, $v0, 0x10
800ca2fc: 00021403  sra       $v0, $v0, 0x10
800ca300: a7a20028  sh        $v0, 0x28($sp)
800ca304: 8e030000  lw        $v1, ($s0)
800ca308: 00000000  nop       
800ca30c: 24620002  addiu     $v0, $v1, 2
800ca310: ae020000  sw        $v0, ($s0)
800ca314: 84620000  lh        $v0, ($v1)
800ca318: 00000000  nop       
800ca31c: 304200ff  andi      $v0, $v0, 0xff
800ca320: 00021400  sll       $v0, $v0, 0x10
800ca324: 00021403  sra       $v0, $v0, 0x10
800ca328: a7a2002a  sh        $v0, 0x2a($sp)
800ca32c: 8e020000  lw        $v0, ($s0)
800ca330: 00000000  nop       
800ca334: 84420000  lh        $v0, ($v0)
800ca338: 00000000  nop       
800ca33c: 3042ff00  andi      $v0, $v0, 0xff00
800ca340: 00021a03  sra       $v1, $v0, 8
800ca344: 8622001e  lh        $v0, 0x1e($s1)
800ca348: 00000000  nop       
800ca34c: 00432820  add       $a1, $v0, $v1
800ca350: 86240020  lh        $a0, 0x20($s1)
800ca354: 8e030000  lw        $v1, ($s0)
800ca358: 00000000  nop       
800ca35c: 24620002  addiu     $v0, $v1, 2
800ca360: ae020000  sw        $v0, ($s0)
800ca364: 84620000  lh        $v0, ($v1)
800ca368: 00000000  nop       
800ca36c: 304200ff  andi      $v0, $v0, 0xff
800ca370: 00823020  add       $a2, $a0, $v0
800ca374: 27a40024  addiu     $a0, $sp, 0x24
800ca378: 0c02524b  jal       0x8009492c
800ca37c: 00000000  nop       
800ca380: 1000002e  b         0x800ca43c
800ca384: 00000000  nop       
```
[観測] 2026-09-14 再走

■ 説明
- 語 0x3nnn の 後ろに operand 3 語（W1 / W2 / W3）。cursor 書込 4 件（0x800CA27C / 0x800CA2C0 / 0x800CA310 / 0x800CA360）× 各 +2 ⇒ ★消費 = 8★
- byte 取り出しは andi 0xff00 の 後 sra 8、および andi 0xff。andi が 符号 bit を 落とすので ★どちらも 符号なし 0..255★（sll 16 / sra 16 が 符号拡張するのは 基点を 足した 後の 和）
- sp+0x24 に half 4 つ: sp+0x24 = actor+0x2A ＋ W1 上位 ／ sp+0x26 = actor+0x2C ＋ W1 下位 ／ sp+0x28 = W2 上位（基点 足さず）／ sp+0x2A = W2 下位（同）
- 呼出 = 0x800CA378 jal 0x8009492c。a0 = sp+0x24 / a1 = actor+0x2A ＋ W3 上位 / a2 = actor+0x2C ＋ W3 下位
- 0x8009492C の 中身（逐語で 確かめた 事実のみ）: a0 の +0x00 word を 0x8011CBB0 へ、(a2 を 16bit 左 shift) or (a1 の 下位 16bit) を 0x8011CBB4 へ、a0 の +0x04 word を 0x8011CBB8 へ 積む。送出 = a3 = *(0x8011CB8C) = 0x8011CB4C、jalr *(a3+0x08)、a0 = *(a3+0x18)、a2 = 0x14（20 byte = 5 word）
- packet 先頭 0x8011CBA8 の 静的 byte 直読 = ★04ffffff 80000000★（tag = len 4 / 終端 addr 0xffffff、続く word = 0x80000000）[観測]
- 0x80092C84 に 渡す 文字列 = 0x8011A1E8 直読 = ★"MoveImage"★ [観測]
- ★格の 注記★: 「0x80 = VRAM 内 矩形 copy」「a0 は RECT（+0 x / +2 y / +4 w / +6 h）」は ★観測（上記 2 件の 直読）＋ 外部仕様（PSX GPU の 0x80 command の 意味）に 拠る★。像の 中だけでは 決まらない
- 基点の 出所（setter 0x800C9CBC 窓・逐語）:
```
800c9dc4: 94420010  lhu       $v0, 0x10($v0)
800c9dcc: 2042fff0  addi      $v0, $v0, -0x10
800c9dd0: 00021180  sll       $v0, $v0, 6
800c9ddc: a622001e  sh        $v0, 0x1e($s1)
800c9de8: 90420015  lbu       $v0, 0x15($v0)
800c9df0: 20420100  addi      $v0, $v0, 0x100
800c9dfc: a6220020  sh        $v0, 0x20($s1)
```
  ⇒ actor+0x2A = (rec の +0x10 - 0x10) * 64 ／ actor+0x2C = rec の +0x15 ＋ 256 [観測]
- *(0x8011CB8C) の 後続 word 直読 = 00000400 00000400 00000400 00000200（= 1024 と 512）[観測]

## 14-7. arm 0x4000 = 0x800CA388..0x800CA438 / 45 命令

■ 何もしない条件
- (1) ★actor+0x35 が 1 以外★ ⇒ jal 0x800CF96C を 呼ばない。効果は cursor +4 のみ（sp+0x2C への sh は stack 局所ゆえ 捨てられる）。本 arm 唯一の 完全な 何もしない条件
```
800ca3c4: 80420035  lb        $v0, 0x35($v0)
800ca3c8: 24010001  addiu     $at, $zero, 1
800ca3cc: 14410017  bne       $v0, $at, 0x800ca42c
```
- (2) 呼んだ 場合でも 0x800CF96C が 何もせず return する 条件 = 2 件:
```
800cf9f8: 2a010003  slti      $at, $s0, 3
800cf9fc: 1420000a  bnez      $at, 0x800cfa28
800cfa04: 2a010008  slti      $at, $s0, 8
800cfa08: 10200007  beqz      $at, 0x800cfa28
```
  ⇒ a0 が 3 未満（0 と 1 は 先に 別経路へ 分岐済ゆえ 実質 2 と 負）／ a0 が 8 以上（8 は 先に 別経路へ 分岐済ゆえ 実質 9 以上）。a0 が 0 / 1 / 8 は 第 1 経路、3..7 は 第 2 経路

■ 逐語 45 行
```
800ca388: 8e020000  lw        $v0, ($s0)
800ca38c: 00000000  nop       
800ca390: 24420002  addiu     $v0, $v0, 2
800ca394: ae020000  sw        $v0, ($s0)
800ca398: 8e020000  lw        $v0, ($s0)
800ca39c: 00000000  nop       
800ca3a0: 84420000  lh        $v0, ($v0)
800ca3a4: 00000000  nop       
800ca3a8: 3042ff00  andi      $v0, $v0, 0xff00
800ca3ac: 00021203  sra       $v0, $v0, 8
800ca3b0: 00021400  sll       $v0, $v0, 0x10
800ca3b4: 00021403  sra       $v0, $v0, 0x10
800ca3b8: a7a2002c  sh        $v0, 0x2c($sp)
800ca3bc: 8fa20030  lw        $v0, 0x30($sp)
800ca3c0: 00000000  nop       
800ca3c4: 80420035  lb        $v0, 0x35($v0)
800ca3c8: 24010001  addiu     $at, $zero, 1
800ca3cc: 14410017  bne       $v0, $at, 0x800ca42c
800ca3d0: 00000000  nop       
800ca3d4: 87a2002c  lh        $v0, 0x2c($sp)
800ca3d8: 24010004  addiu     $at, $zero, 4
800ca3dc: 10410006  beq       $v0, $at, 0x800ca3f8
800ca3e0: 00000000  nop       
800ca3e4: 87a2002c  lh        $v0, 0x2c($sp)
800ca3e8: 00000000  nop       
800ca3ec: a7a2002e  sh        $v0, 0x2e($sp)
800ca3f0: 10000006  b         0x800ca40c
800ca3f4: 00000000  nop       
800ca3f8: 8fa20030  lw        $v0, 0x30($sp)
800ca3fc: 00000000  nop       
800ca400: 84420054  lh        $v0, 0x54($v0)
800ca404: 00000000  nop       
800ca408: a7a2002e  sh        $v0, 0x2e($sp)
800ca40c: 87a4002e  lh        $a0, 0x2e($sp)
800ca410: 8e020000  lw        $v0, ($s0)
800ca414: 00000000  nop       
800ca418: 84420000  lh        $v0, ($v0)
800ca41c: 00000000  nop       
800ca420: 304500ff  andi      $a1, $v0, 0xff
800ca424: 0c033e5b  jal       0x800cf96c
800ca428: 00000000  nop       
800ca42c: 8e020000  lw        $v0, ($s0)
800ca430: 00000000  nop       
800ca434: 24420002  addiu     $v0, $v0, 2
800ca438: ae020000  sw        $v0, ($s0)
```
[観測] 2026-09-14 再走

■ 説明
- 語 0x4nnn ＋ operand 1 語。cursor 書込 2 件（0x800CA394 / 0x800CA438）× 各 +2 ⇒ ★消費 = 4★
- t = operand の 上位 byte（符号なし 0..255）を sp+0x2C へ
- gate = actor+0x35 が 1
- t が 4 ⇒ u = actor+0x54 の half（0x800CA400 lh $v0,0x54($v0)）。それ以外 ⇒ u = t
- 呼出 = 0x800CA424 jal 0x800cf96c。a0 = u / a1 = operand の 下位 byte（0x800CA420 andi $a1,$v0,0xff ゆえ 符号なし）
- 0x800CF96C の 中身（逐語 由来の 事実のみ）:
  - a0 が 0 / 1 / 8 ⇒ a1 を 16 で 割った 商（負の 時は +0xf 補正・0x800CF9B0）を a1 に、余り（負の 時は -0x10 補正）＋ 0x3c を a2 にして jal 0x800CF7AC
  - a0 が 3..7 ⇒ a1 を そのまま a2 に、a1 = 0 で jal 0x800CF7AC
  - 0x800CF7AC は 表 0x80134230 を a0 で 引き（lui 0x8013 ＋ addiu 0x4230・符号拡張なし）、得た pointer ＋ 0x820 ＋ a1 * 512 から 32 byte stride で 16 entry 走査し、各 entry の +0x07 と a2 を 比較
  - 一致 entry で jal 0x800CF6F4（a0 = 0x18 = 24）。0x800CF6F4 は i を 0..13 で 回し、番号 = (gp-0x6da8 の counter ＋ i) mod 14 ＋ 10 の 1bit mask を 0x800D2218 に 渡し、返り値が 1 の 間 次へ 進む ⇒ 使う 番号は 10..23、0x800D2218 の 走査上限 = 0x18 = 24、全滅時 -1
  - 割当 後 0x7f と 0x7f を stack 引数に 積んで jal 0x800D7880
- ★格 = 推論（名前は 付けない・根拠だけ 書く）★: 24 本の 排他 資源 ／ 0x7f の 対 ／ 0x3c(= 60) を 基準に した 16 進の 商と余りの 分解 ／ 呼び先 0x800D7880 が 文字列 0x8011AEB3 付近の "This is an old SEQ Data Format." と "Can't Open Sequence data any more" を 抱える code 帯（0x800D1xxx..0x800DBxxx）の 中に 在る（文字列は 直読 [観測]）。0x800D7880 の 本文は ★未読★ゆえ 確定と しない

## 14-8. §10 の 訂正 1 件

| 項目 | §10 の 値（格 [先行]） | 本節の 値（格 [実測]） |
|---|---|---|
| arm 0x1000 の 消費 byte | 4 | ★2★ |

- 根拠 = arm 範囲 0x800CA1B0..0x800CA1EC の cursor 書込は 0x800CA1D8 の 1 件のみ・直前が 0x800CA1D4 addiu $v0,$v0,2
- 器 = arm 範囲内の sw ..($s0) と その 直前の addiu/addi を 機械列挙。★全 arm に 同じ 器を 当てた★
- ★陽性対照 2 件★ = 0x3000 の 8 と 0x4000 の 4 が §10 の 旧値と 一致 ⇒ 器の 一様故障 ではない
- ★boss1 独立照合★ = 窓全体の cursor 書込 12 件（14-3 に 全列挙）／ dispatch 帯 0x800CA13C..0x800CA17C にも cursor 書込 0 件 ／ 0x800CA43C..0x800CA4B8 にも 0 件 ⇒ arm 0x1000 の 消費は 2
- §10 の 0x2000 行「継続は +2」も 14-5 で 精密化した（正味は actor+0x24 の 値への 置換）

## 14-9. 未解決（推測を 置かない）

- actor+0x35 の 書き手 = ★未閉★（未調査 ⇒ arm 0x4000 の gate の 意味は 未確定）
- actor+0x54 の 書き手 = ★未閉★（未調査 ⇒ t が 4 の 時の 差替先の 意味は 未確定）
- 0x800D7880 の 本文 = ★未閉★（未読）
- 0x800CA884（0x0000 の 呼び先）= ★閉じた★（§15。全文 102 命令 読了・消費は 可変長と 判明）
- 0x800CA4D8（prologue 0x800CA0B8 jal）= ★未閉★（未読・本 task の 範囲外）
- 0x800C9A80（0x800CA4B4 jal）= ★未閉★（未読・本 task の 範囲外）
- 0x5000..0xF000 の 11 値 = ★未閉★（到達可能性 未確認・14-2）

---

# BATTLE_CENSUS 2026-09-14 / worker3 追記 #933-P13（直列 4 番目）

## w3b-0. 出所
- tree = /home/ken/Desktop/Digimon/degimon_world_remake-p2w3 / branch track3/battle-re-ai / HEAD 096079f996c21f52a162ff7d6bcc45ca2f3e8049
- 器 = w3_bfield.py / w3_span.py / w3_slot.py（すべて上記 tree の workspace/p2_opcode_sweep_20260913/ に commit 済）
- 換算は w3-0 と同じ

## w3b-1. B[0x66C + i] への store 全数
- B = 0x801460F8（gp-0x6dec への store は両像で 1 件のみ = 80118EF8。値は 80118EF0 lui 0x8014 ＋ 80118EF4 addiu 0x60f8）
- 器 = w3_bfield.py（形1 = gp-0x6dec から直に lw / 形2 = 形1 に addu / 形3 = 絶対番地）
- 陽性対照 = 8010727C（出力に在り）／ 母数 = 両像 全語 ／ ★除外 0★ ／ ★打ち切り 0★
- ★store = 5 件（すべて slps・すべて disp 0x66C）★ ／ load = 61 件（disp 0x66D の 2 件を含む）

| site | 形 | 逐語 | 0 を取りうるか |
|---|---|---|---|
| 8010727C | 形1 | 80107270 addiu $v1, $zero, 1 ／ 80107274 lw $v0, -0x6dec($gp) ／ 8010727c sb $v1, 0x66c($v0) | ★取らない★ |
| 80107844 | 形2 | 8010782C andi $a0, $s0, 0xff（s0 は 8010744C addiu $s0, $zero, 2 起点・801078A4 slti $at, $s0, 0xa） | ★取らない★ |
| 80107884 | 形2 | 8010786C andi $a0, $s0, 0xff（同じ s0） | ★取らない★ |
| 80107328 | 形2 | 801072CC addi $v0, $s0, 0xfb ／ 801072D4 jal 0x800f0ac8 ／ 801072E0 sb $v0, 0x34($v1)。801072EC で 0xFF なら飛ばす（0 は飛ばさない） | ★決まらない・未閉★ |
| 8010743C | 形2 | 8010741C lh $v0, 0x40($sp) ／ 80107424 andi $a0, $v0, 0xff。sp+0x40 = 8010726C sw $a0, 0x40($sp)（f_80107258 の引数） | ★決まらない・未閉★ |

- ★未閉★ 8010743C の引数 chain: caller 1 件 = 800AED2C ／ その a0 = 800EE7F8 lh $a0, -0x6d08($gp) ／ gp-0x6d08 の書き手 1 件 = 800F021C（値は 800F0214 lb $v0, -0x6e9c($gp)）／ gp-0x6e9c の書き手 2 件 = 800AE4E0 と 800BC294（どちらも実行時 register・★未閉★）

## w3b-2. event var 0xFB / 0xFC / 0xFD の書き手（未閉）
- 配列の素性（逐語）: 800F0CE4 lw $v0, -0x6cec($gp) ／ 800F0CEC addu $v0, $v0, $v1 ／ 800F0CF0 addiu $s0, $v0, 0x159 ／ 800F0CFC sb $v0, ($s0)
- 番地 = [gp-0x6cec] ＋ 0x159 ＋ 添字。0xFB から 0xFD は ★+0x254 から +0x256★
- setter 0x800F0CD0 の caller = ★48 件★ ／ a0 が即値 = 22 件（値 = 0x2 が 2 / 0x3 / 0x4 / 0x5 / 0x6 / 0xC8 / 0xF3 が 4 / 0xF4 が 3 / 0xFE が 4 / 0xFF が 4）
- ★a0 が即値で 0xFB / 0xFC / 0xFD = 0 件★
- ★未閉 (1) a0 が即値でない 26 件★
  800E9170 800EB32C 800EC834 800EC884 800EC8D0 800EC8FC 800EC934 800EC994
  800EC9C0 800EC9E4 800ECA08 800ECA2C 800ED310 800ED32C 800ED348 800ED364
  800ED3FC 800EE7C4 800EF1D8 800EF21C 800F08F0 800F0930 800F0B44 800FAC78
  80111218 80111590
- setter 以外の書込路 = gp-0x6cec の中身を base にする store 10 件（陽性対照 800F0CFC を含む）。setter 以外は 9 件
  - 範囲の外と言える 5 件: 800F0D8C / 800F0D90（800F0D80 addiu $s0, $v0, 0x25c）／ 800F138C / 800F13B0（800F1368 addiu $s0, $v1, 0xd4）／ 800FAB88（800FAB90 slti $at, $s0, 6・0xFF を書く）
  - ★未閉 (2) offset が実行時で不明な 4 件★ = 800F97B4 / 800F9F20 / 800FA978 / 800FA9C4

## w3b-3. 札 = 実機
- ★未閉★ B[0x66C + i] が 0 を取りうるかは、静的には決まらない（gp-0x6e9c / 26 件 / 4 件 と、辿るたびに実行時 register に落ちた。3 回）
- ★閉じる手順★: 戦闘中に B[0x66C + i]（i = 0 から 9）の値を採取し、0 が現れるかを見れば閉じる
- ★[B] 80056E58 ／ caller2 80058AC8 ／ 表の添字引き の 3 つは、この 1 回の観測で同時に閉じる（3 回測らない）★

## w3b-4. UNK の未閉（w3-3 の続き）
- ★未閉★ B = 2 件（addu 形・base 0x8016ADCC・帯に届くには添字 141 以上・上限は押さえていない・読んだ値は直後に jalr へ）
  801137B0 sw $a0, -0x5234($at)（addu = 801137AC）／ 80113800 lw $v0, -0x5234($at)（addu = 801137FC）
- ★未閉★ C = 90 件（$at の書き手を辿れない・code か data か未判定）。全 address は p2w3 の W3_UNK_CLASSIFY.txt
  命令の形 = lb $ra が 57 / sb $ra が 10 / sw $ra が 8 / lw $ra が 4 / lh $ra が 3 / lbu $ra が 3 / 他 5
  居場所 = slps 0x8012 台が 85 / slps 0x8013 台が 4 / btl 0x8007 台が 1
  生 byte の例 = 0x80128EA0 は ff fb 3f 80 ff fb ff fb ／ 0x80129DE4 は ff ff 3f 80 bf ff bf ff
  ★印字可能 byte の比率は 0x8012 台 23 パーセント / 既知 code の 0x800A 台 20 パーセント で判別に使えない（★未閉★）

## w3b-5. worker1 節
- ★worker1 節 = 未追記（worker1 保留中）★

---

# BATTLE_CENSUS 2026-09-14 / worker1 追記 #933-P3（直列 3 番目）

- この節は、worker3 が置いた w3b-5 の枠（worker1 節 = 未追記）を置き換えるものです。w3b-5 の行そのものは他人の節なので編集していません。

## w1-0. 出所と器
- 観測 / tree = /home/ken/Desktop/Digimon/degimon_world_remake-anim43 / branch track1/battle-anim43 / HEAD 49ca250eac5b32cd5d6626af22205a759947bd56 / dirty 0
- 観測 / 器 = grep（comment 行を除外）と、mono の reflection（BindingFlags.Public | Instance | DeclaredOnly）と、strings（build 成果物の dll）
- 観測 / 除外 = unity/Assets/Scripts/Editor 配下と workspace 配下（harness）は「production の呼び手」から除外。comment 行（行頭 // と ///）も除外
- 観測 / 母数の宣言 = unity/Assets/Scripts/Battle/*.cs = 16 file 4254 行。打ち切りなし、cap なし

## w1-1. API 30 本（呼び手が 0 のもの）と、その内訳
- 観測 / 13 本 = BattleAi の public static API。出所 file = unity/Assets/Scripts/Battle/BattleAi.cs
  - 器 = grep -cE の public static 行数。production からの呼び出しは 0 件（器 = grep -rn の BattleAi. を comment 除外して計数）
  - 呼んでいるのは harness のみ（workspace/battle-slice-verify/ai_verify.cs と runtime_verify.cs）
- 観測 / 11 本 = BattleFormulas の public static API 12 本のうち、production から呼ばれていない 11 本。出所 file = unity/Assets/Scripts/Battle/BattleFormulas.cs
  - 器 = 同上。呼ばれている 1 本は GetDamagePoint（呼び手 1 件 = BattleSession の ForcedHit 内）
  - 呼ばれていない側に GetHitRate と RollHit を含む（= 命中判定は「0 本」ではなく「在るが呼ばれていない」）
- 観測 / 6 本 = BattleStateSequence の public static API。出所 file = unity/Assets/Scripts/Battle/BattleStateSequence.cs
  - 器 = 同上。production からの呼び出しは 0 件。harness からは 5 本が呼ばれ、BuildsAppend は自 file 内から 1 件のみ（外から 0・内から 1）
- 観測 / 合計 = 13 + 11 + 6 = 30 本
- 推論 / 「式は固定されているが、配線は 1 本も固定されていない」= 上の 3 つの 0 件からの読み

## w1-2. BattleActor 32 欄（30 本とは別の量）
- 観測 / 32 = BattleActor の public instance member（field と、引数なしで読める property）の数。器 = reflection（DeclaredOnly）
- 観測 / これは API の数ではなく actor の欄の数。30 本（public static API の数）とは別の量なので、足し合わせない
- 観測 / 2026-09-13 時点では 31。ActorB30 を足したため 32（= 同じ名前の数でも時点で変わる）
- 観測 / 実走 1 戦（104 frame・Decided・結果 -1）で 1 度でも値が変わった欄 = 味方 7 / 敵 6。残りは初期値のまま
- 観測 / 32 欄の中に、座標（x / y / z）と属性（attr）は 1 件もない（= 0 のままではなく、置き場がない）

## w1-3. build 成果物と source の版のずれ
- 観測 / workspace/build/DegimonLive/DegimonLive_Data/Managed/Assembly-CSharp.dll（mtime 2026-09-13 20:56:43）
- 観測 / 器 = strings で symbol 名の完全一致を計数
- 観測 / ActorB30 = 0 件
- 観測 / IsAnyEnemyCollapsed = 1 件 / AllyAttacksThisHit = 1 件 / StandaloneScaffold = 1 件
- 推論 / ActorB30 を入れた commit は e8ab5727。その 1 つ手前までの symbol は在り、ActorB30 だけが無い。よって焼かれているのは e8ab5727 より前の版
- 推論 / この dll を走らせても +0x30 の書込は入っていない（再 build するかは boss1 の判断。2026-09-14 時点では再 build していない）

## w1-4. 未閉（行内に印を置く）
- 未閉 / btl f_8005C288 側の write の全数が未 census。我々が写した 2 本（+0x53 と 相手 H34）は「写した数」であって「在る数」ではない。よって TryCollapse の見出しは 4/(13 ＋ btl 未 census) と書いており、1 つの数に畳んでいない
- 未閉 / remake の Tick 8 段のうち原盤 VA を引用する 4 本（0x80057F78 / f_8005907C / 0x80058990 / 0x8005C1DC）が、原盤 11 phase のどれに当たるかの対応づけ。worker3 の phase 表が埋まってから照合する
- 未閉 / 43 が倒れる anim であること（anim 表は誰も読んでいない）。remake の目視では閉じない。閉じる道は anim 表の RE か原盤の観察
- 未閉 / 表[1] = Ally であること / 入口 B が Enemy 固定であること（原盤は可変選択）/ 原盤の frame 内で drain と段 1 のどちらが先かの順序

## w1-5. 事前登録した予測（実装より前に書いたもの・code 側にも置いてある）
- 推論 / 予測 5 = 読む側（phase 3 相当 = 43 かつ +0x30 bit0 == 0）を実装した commit で戦闘が終わらなくなる。原因はその commit ではなく、bit0 を落とす機構（0x800CA064）が無いこと。読む側は落とす側と対でしか入れない
- 推論 / 予測 6 = 表参照（表[id]==0 なら何も書かない bail）を入れた commit で 11 種族の挙動が変わる。これは露出であって欠陥ではない。11 種族が戦闘 actor になり得るかは 未閉
- 推論 / H18 に実値が入る commit で TryFire が止まる。現在 TryFire が通っているのは H1A == H18 が 0 == 0 で成立しているため。同型は他に 3 箇所（H1A > H18 の clamp / H64A > 0 / State == Wait）

---

# BATTLE_CENSUS 2026-09-14 / worker2 追記 #933-P8 続き（0x800CA884）

母数 = ★1 関数★（0x800CA884）。§10 の arm 0x0000 行「消費は ★未解決★」を 閉じる のが 目的。

## 15-0. 器・窓・decode 不能

| 項目 | 値 | 出所 |
|---|---|---|
| 器 | p2w2 の workspace/w2_dis.py（capstone 5.0.7 / MIPS32 + LITTLE_ENDIAN / skipdata=True） | [観測] |
| EXE sha256 先頭 8 / BASE | db26754d / 0x80090800 | [観測] |
| 窓 | 0x800CA884..0x800CAA18 = ★102 命令★ | [観測] |
| 窓の 終端 根拠 | 0x800CAA14 jr $ra ＋ 遅延 slot。次 関数の 頭 = 0x800CAA1C addiu $sp,$sp,-0x28 | [観測] |
| skipdata の .byte | ★0 件★（印字すべき address 無し） | [観測] |
| 打ち切り | ★0 件★ | [観測] |
| 参考に 全文 読んだ 母数外 1 本 | 0x800CAA1C = 0x800CAA1C..0x800CAB40 / 74 命令 / .byte 0 件 | [観測] |

## 15-1. caller census

| 探した形 | slps 像 | overlay 16 file | 合計 |
|---|---|---|---|
| jal 語 0c032a21（= jal 0x800CA884） | 1 件 = ★0x800CA1A0（arm 0x0000）★ | 0 件 | 1 |
| jal 語 0c032a87（= jal 0x800CAA1C） | 1 件 = 0x800CA9B8 | 0 件 | 1 |
| 0x800CA884 / 0x800CAA1C を word として 持つ 箇所 | 0 件 | 0 件 | 0 |
| 下位 a884 / aa1c を 積む addiu と ori | a884 = 0 件 / aa1c = 1 件（0x800B6B90。但し 上位は lui 0x8012 ゆえ 実効 0x8011AA1C ＝ ★偽陽性★） | 0 件 | 真の 一致 0 |

- overlay = /home/ken/Desktop/Digimon/degimon/extracted/ の *_rel.bin ★16 file★ 全走査 [観測]
- ★未閉★: 実行時に base を 作る jalr の 形は 見ていない（上の 4 形は 静的に 番地が 現れる 形だけ）

## 15-2. 引数

| register | 値 | 逐語 |
|---|---|---|
| a0 | interpreter の sp+0x20 = *(actor+0x0C) | 0x800CA898 sw $a0, 0x50($sp) |
| a1 | ★cursor を 入れた word の 番地（actor+0x20）★ | 0x800CA89C move $s1, $a1 |

## 15-3. cursor 書込の 全数

| 関数 | cursor 書込 | 番地 | 直前 |
|---|---|---|---|
| 0x800CA884 | ★2 件★ | 0x800CA8B4 sw $v0,($s1) / 0x800CA8FC sw $v0,($s1) | 各 addiu +2 |
| 0x800CAA1C（母数外） | ★1 件★ | 0x800CAA5C sw $v0,($a0)（$a0 = 0x800CAA48 lw $a0,0x3c($sp) = 第 6 引数） | addiu +2 |

- 器 = 関数内 store を 機械 全列挙し base が cursor pointer の ものを 取った。0x800CA884 の store 全 19 件 / 0x800CAA1C の store 全 16 件 [観測]
- 0x800CA96C sw $s1,0x14($sp) は ★$s1 の 値を stack 引数に 置く★もの で cursor 書込 ではない。但し これが 番地を 0x800CAA1C に 渡すので ★消費は 0x800CA884 だけでは 閉じない★
- 0x800CA884 と 0x800CAA1C 以外に cursor を 書く 経路は 本 task の 母数外（0x800CAA1C から 更に 下は jal 0x800913A0 の 1 本のみ・その 中身は BIOS 呼出 3 命令で store 0 件）

## 15-4. 消費 byte

- 外側 1 周 = ★4 byte 固定（W1 と W2）＋ 2 byte × (W1 の bit14 から bit6 のうち 立っている 数)★
- 外側の 継続条件 = 0x800CA9F8 bnez ＝ 今の cursor の 語の bit 0x8000 が 立っている 間
- ⇒ arm 0x0000 の 総消費 = 2（interpreter 0x800CA190）＋ Σ 各周（4 ＋ 2 × popcount(W1 and 0x7FC0)）
- 1 周あたり 最小 4 / 最大 4 ＋ 18 = 22。外側 0 周なら 総消費 2
- ★§10 の 「0x0000 の 消費は 未解決」は 閉じた★。但し ★定数ではなく 列の 中身に 依存する 可変長★

## 15-5. 何もしない条件

- (1) ★完全★ = 入口の 語の bit 0x8000 が 0 ⇒ 本体に 1 度も 入らず epilogue。cursor 書込 0 件 / jal 0 件 / a0 も 読まない
```
800ca8a0: 10000050  b         0x800ca9e4
800ca9e4: 8e220000  lw        $v0, ($s1)
800ca9ec: 84420000  lh        $v0, ($v0)
800ca9f4: 30428000  andi      $v0, $v0, 0x8000
800ca9f8: 1440ffab  bnez      $v0, 0x800ca8a8
```
- (2) ★部分★ = W1 の bit14 から bit6 が 全部 0 ⇒ 内側 9 回とも 0x800CA954 beqz 成立 ⇒ jal 0x800CAA1C は 0 回。但し cursor は +4 進み、sp 上の 5 pointer は 組まれる
- (3) ★部分・母数外★ = 0x800CAA1C 自体に 何もしない枝は 無い（必ず cursor +2 と 商・剰余の 2 書込）。書込の 一部を 飛ばす 条件 = 剰余が 0（0x800CAABC beqz $v0,0x800cab28）⇒ 4 書込（第 5 引数の byte / abs の 返り値 / a1 / a3）が 起きない
- 条件分岐の 全数 = 0x800CA884 が 3 本（0x800CA954 beqz / 0x800CA9DC bnez / 0x800CA9F8 bnez）／ 0x800CAA1C が 2 本（0x800CAABC beqz / 0x800CAACC blez）[観測]

## 15-6. 逐語 102 行（VA : raw : mnemonic operand）

```
800ca884: 27bdffb0  addiu     $sp, $sp, -0x50
800ca888: afbf002c  sw        $ra, 0x2c($sp)
800ca88c: afb20028  sw        $s2, 0x28($sp)
800ca890: afb10024  sw        $s1, 0x24($sp)
800ca894: afb00020  sw        $s0, 0x20($sp)
800ca898: afa40050  sw        $a0, 0x50($sp)
800ca89c: 00a08821  move      $s1, $a1
800ca8a0: 10000050  b         0x800ca9e4
800ca8a4: 00000000  nop       
800ca8a8: 8e230000  lw        $v1, ($s1)
800ca8ac: 00000000  nop       
800ca8b0: 24620002  addiu     $v0, $v1, 2
800ca8b4: ae220000  sw        $v0, ($s1)
800ca8b8: 84620000  lh        $v0, ($v1)
800ca8bc: 00000000  nop       
800ca8c0: a7a2004a  sh        $v0, 0x4a($sp)
800ca8c4: 87a2004a  lh        $v0, 0x4a($sp)
800ca8c8: 00000000  nop       
800ca8cc: 3043003f  andi      $v1, $v0, 0x3f
800ca8d0: 00031080  sll       $v0, $v1, 2
800ca8d4: 00431020  add       $v0, $v0, $v1
800ca8d8: 000210c0  sll       $v0, $v0, 3
800ca8dc: 00431020  add       $v0, $v0, $v1
800ca8e0: 00021840  sll       $v1, $v0, 1
800ca8e4: 8fa20050  lw        $v0, 0x50($sp)
800ca8e8: 00000000  nop       
800ca8ec: 00439021  addu      $s2, $v0, $v1
800ca8f0: 8e230000  lw        $v1, ($s1)
800ca8f4: 00000000  nop       
800ca8f8: 24620002  addiu     $v0, $v1, 2
800ca8fc: ae220000  sw        $v0, ($s1)
800ca900: 84620000  lh        $v0, ($v1)
800ca904: 00000000  nop       
800ca908: a7a2004c  sh        $v0, 0x4c($sp)
800ca90c: afb20034  sw        $s2, 0x34($sp)
800ca910: 26420012  addiu     $v0, $s2, 0x12
800ca914: afa20038  sw        $v0, 0x38($sp)
800ca918: 26420024  addiu     $v0, $s2, 0x24
800ca91c: afa2003c  sw        $v0, 0x3c($sp)
800ca920: 26420036  addiu     $v0, $s2, 0x36
800ca924: afa20040  sw        $v0, 0x40($sp)
800ca928: 26420048  addiu     $v0, $s2, 0x48
800ca92c: afa20044  sw        $v0, 0x44($sp)
800ca930: 24024000  addiu     $v0, $zero, 0x4000
800ca934: a7a2004e  sh        $v0, 0x4e($sp)
800ca938: 00008021  move      $s0, $zero
800ca93c: 10000026  b         0x800ca9d8
800ca940: 00000000  nop       
800ca944: 87a3004a  lh        $v1, 0x4a($sp)
800ca948: 97a2004e  lhu       $v0, 0x4e($sp)
800ca94c: 00000000  nop       
800ca950: 00621024  and       $v0, $v1, $v0
800ca954: 1040001a  beqz      $v0, 0x800ca9c0
800ca958: 00000000  nop       
800ca95c: 8fa20044  lw        $v0, 0x44($sp)
800ca960: 00000000  nop       
800ca964: 00501021  addu      $v0, $v0, $s0
800ca968: afa20010  sw        $v0, 0x10($sp)
800ca96c: afb10014  sw        $s1, 0x14($sp)
800ca970: 27a2004c  addiu     $v0, $sp, 0x4c
800ca974: afa20018  sw        $v0, 0x18($sp)
800ca978: 00101840  sll       $v1, $s0, 1
800ca97c: 8fa2003c  lw        $v0, 0x3c($sp)
800ca980: 00000000  nop       
800ca984: 00432021  addu      $a0, $v0, $v1
800ca988: 00101840  sll       $v1, $s0, 1
800ca98c: 8fa20034  lw        $v0, 0x34($sp)
800ca990: 00000000  nop       
800ca994: 00432821  addu      $a1, $v0, $v1
800ca998: 00101840  sll       $v1, $s0, 1
800ca99c: 8fa20038  lw        $v0, 0x38($sp)
800ca9a0: 00000000  nop       
800ca9a4: 00433021  addu      $a2, $v0, $v1
800ca9a8: 00101840  sll       $v1, $s0, 1
800ca9ac: 8fa20040  lw        $v0, 0x40($sp)
800ca9b0: 00000000  nop       
800ca9b4: 00433821  addu      $a3, $v0, $v1
800ca9b8: 0c032a87  jal       0x800caa1c
800ca9bc: 00000000  nop       
800ca9c0: 97a2004e  lhu       $v0, 0x4e($sp)
800ca9c4: 00000000  nop       
800ca9c8: 00021043  sra       $v0, $v0, 1
800ca9cc: 3042ffff  andi      $v0, $v0, 0xffff
800ca9d0: a7a2004e  sh        $v0, 0x4e($sp)
800ca9d4: 22100001  addi      $s0, $s0, 1
800ca9d8: 2a010009  slti      $at, $s0, 9
800ca9dc: 1420ffd9  bnez      $at, 0x800ca944
800ca9e0: 00000000  nop       
800ca9e4: 8e220000  lw        $v0, ($s1)
800ca9e8: 00000000  nop       
800ca9ec: 84420000  lh        $v0, ($v0)
800ca9f0: 00000000  nop       
800ca9f4: 30428000  andi      $v0, $v0, 0x8000
800ca9f8: 1440ffab  bnez      $v0, 0x800ca8a8
800ca9fc: 00000000  nop       
800caa00: 8fbf002c  lw        $ra, 0x2c($sp)
800caa04: 8fb20028  lw        $s2, 0x28($sp)
800caa08: 8fb10024  lw        $s1, 0x24($sp)
800caa0c: 8fb00020  lw        $s0, 0x20($sp)
800caa10: 27bd0050  addiu     $sp, $sp, 0x50
800caa14: 03e00008  jr        $ra
800caa18: 00000000  nop       
```
[観測] 2026-09-14 再走

## 15-7. 説明（名前は 付けない）

- $s1 = a1 = cursor の 番地。入口 0x800CA8A0 b で 0x800CA9E4 の 判定へ 飛ぶ
- 本体 1 周:
  - W1 = 語（cursor +2）。sp+0x4a = W1
  - k = W1 and 0x3F。k * 82 を 0x800CA8D0..0x800CA8E0 の sll と add で 作る（(((k 左 2) ＋ k) 左 3 ＋ k) 左 1 = 82k）
  - $s2 = a0 ＋ k * 82
  - W2 = 語（cursor +2）。sp+0x4c = W2
  - sp+0x34 / 0x38 / 0x3c / 0x40 / 0x44 = $s2+0x00 / +0x12 / +0x24 / +0x36 / +0x48
  - sp+0x4e = 0x4000、$s0 = 0
  - 内側 i = 0..8（0x800CA9D8 slti $at,$s0,9）: W1 and sp+0x4e が 0 なら 飛ばす。そうでなければ jal 0x800CAA1C。引数 = a0 が ($s2+0x24) ＋ i*2 / a1 が ($s2+0x00) ＋ i*2 / a2 が ($s2+0x12) ＋ i*2 / a3 が ($s2+0x36) ＋ i*2 / 第 5（sp+0x10）が ($s2+0x48) ＋ i（★byte stride★）/ 第 6（sp+0x14）が cursor の 番地 / 第 7（sp+0x18）が sp+0x4c の 番地。最後に sp+0x4e を sra 1
  - sp+0x4e は 0x4000 から 0x40 まで 9 段（和 = 0x7FC0）
- ⇒ W1 の 形 = bit15 が 外側 継続 / bit14 から bit6 の 9 本 / bit5 から bit0 が k
- 数の 検算（82 = 0x52 の 割付）: +0x00 と +0x12 と +0x24 と +0x36 が 各 9 half = 18 byte ずつ で 0x48 まで、+0x48 から 9 byte で 0x51、82 との 差 1 byte は 余り
- 0x800CAA1C の 中身（母数外・全文 74 命令 読了）:
  - W3 = 語（cursor +2）。sp+0x26 = W3 ／ D = *(第 7 引数) = 呼び元の W2
  - *(a0) = W3 割る D の 商（div の lo を s16 に 符号拡張）／ *(a2) = W3 割る D の 剰余（div の hi）
  - 剰余が 0 ⇒ 即 return
  - 剰余が 正 ⇒ *(第 5 引数・byte) = 1 ／ 負 ⇒ -1
  - *(a2) = 0x800913A0 の 返り値（引数 = 剰余）／ *(a1) = D ／ *(a3) = D
- 0x800913A0 の 逐語:
```
800913a0: 240a00a0  addiu     $t2, $zero, 0xa0
800913a4: 01400008  jr        $t2
800913a8: 2409000e  addiu     $t1, $zero, 0xe
```
  ⇒ BIOS の A 表 0x0E 呼び出し。★「A(0x0E) = abs」は 外部仕様に 拠る★（像の 中だけでは 決まらない。14-6 の GPU 0x80 と 同じ 格）

## 15-8. 未閉

- a0（= *(actor+0x0C)）の 実体と 全長 = ★未閉★（k は 0..63 を 取りうるので 最大 64 * 82 = 5248 byte を 指す 形だが 確保側 未確認）
- $s2+0x00 / +0x12 / +0x24 / +0x36 / +0x48 の 5 配列の 読み手 census = ★未閉★（未実施）
- D（= W2）が 0 を 取りうるか = ★未閉★（0 なら div の 結果は 未定義。R3000 は 例外を 出さない）
- 表からの jalr で 0x800CA884 と 0x800CAA1C に 入る 形 = ★未閉★（15-1 の 4 形は いずれも 真の 一致 0 件だが 実行時 base 生成は 見ていない）
- W1 の bit14 から bit6 の 9 本が どの 実 file で どう 立つか = ★未閉★（列の 実データを 見ていない）
