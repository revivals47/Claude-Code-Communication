# P2_AXIS_worker2 — ★軸が 決まりました — ★[gp-0x6cd6] は ★opcode 0xFB の 第 1 operand★★★

★受領★ = boss1 #673 ④ ／ ★測定時点★ = 2026-08-15 ／ ★emulator 非接触・EXE と DG.SCN の 直読のみ★
★台帳 grep 済★ = `0x8013541C` / `map 名表` ⇒ ★当たり = §8.2（2207-2234 行）★
★引用 1 行★ = ★『書込 = `0x800EC44C addiu a1,gp,-27814` → `jal 0x800F0D10` / 所属 = ★`0xFB` handler★』★

## ★0. ★★★結論 = ★TWNB01 の loader は ★148★・★81-86 を 持ちます★★★★★

```
 ★★原盤の 引き★★ = ★PlayMapSection(★loader 148★, section 82) ⇒ ★entry 148 に section 82 は ★在ります★★★
 ★★remake の 引き★★ = ★PlayMapSection(★registry id 180★, 82) ⇒ ★entry 180 = [51, 77, 254] ⇒ ★不在★★
 ⇒ ★★∴ ★no-op は ★原盤の 性質では なく ★軸の 取り違え★ の 結果★★★（★boss1 の 見立てどおり★）
```

## ★1. ★★[gp-0x6cd6] の 正体（★逐語★）★★★

```
 ★cell census（母数 = EXE 全 177,664 命令 / load・store 46,092）★:
   ★直接の 書き手 = ★1 件★★（0x800F00B8 sh 定数 0xFFFF = 初期化）
   ★★address が 外へ 出ます★★ = ★0x800EC448 で address を 取り 0x800EC450 で ★0x800F0D10★ に 渡す★
 ★0x800EC448 は ★band 1 router 0x800EC404 の 中★★ ⇒ ★★opcode ★0xFB★ の arm★★
   800EC448  addiu $a0, $gp, -27862      ★= [gp-0x6cd6]★
   800EC44C  addiu $a1, $gp, -27814      ★= [gp-0x6ca6]★
   800EC450  jal 0x800F0D10              ★= script から u16 を 2 本 読む（消費 5）★
   800EC470  sw   1, -0x6cb8($gp)
   800EC47C  lhu  $a0, -0x6ca6($gp)
   800EC480  jal  ★0x800DF7D0★           ★= map writer 3 本の 1 つ★
 ⇒ ★★∴ ★0xFB = ★region header★★★ = ★『第 1 = ★積む script file★ / 第 2 = ★region id★』★
```

## ★2. ★★全数（★母数 = DG.SCN 全 1,559 section★）★★★

```
 ★先頭 opcode が 0xFB の section = ★256 件★ ⇒ ★★全部 entry 0 の 中★★
 ★第 2 operand（region）= ★0..254 の 連番・255 個★★（★1 個だけ 重複 = region 0 が 2 行 = ★行 0/行 1 の offset 重複★★）
 ★第 1 operand（loader）= ★1..219・相異なる 198★★ ⇒ ★★entry 番号の 範囲（0..224）に 256/256 が 収まる★★
 ⇒ ★★∴ ★entry 0 = ★region 表★★★（★section id == region id★）
```

## ★3. ★★★join = ★region → loader → 81-86 の 有無★（★母数 = 255 region 全数★）★★★★

| region | 名 | loader | 81-86 |
|---|---|---|---|
| ★180★ | ★TWNB01★ | ★148★ | ★★有り★★ |
| 181-203 | TWNB02-24 | ★全部 148★ | ★有り★ |
| 168-179 | TWNA02-13 | ★147★ | ★有り★ |
| ★204★ | ★TWNA01★ | ★149★ | ★★無し★★ |

```
 ★★全体 = ★loader が 81-86 を 持つ region = ★99 / 255★★★ / ★0xFB header が 無い region = ★0 件★★
 ★entry 147 = [5,6,7,8,11,51..59,★81,82,83★,254]★ / ★entry 148 = [5..12,51..57,★81,82★,254]★ / ★entry 149 = [5..11,51..54,66,254]★
```

## ★4. ★★★独立 oracle が 1 本 立ちました★★★★

```
 ★remake が 唯一 持つ 束縛★ = ★twna01 → scenario ★149★★
 ★私の 表（EXE 名表 ＋ DG.SCN の 0xFB 全数）★ = ★region 204 = TWNA01 → loader ★149★★
 ⇒ ★★∴ ★逐字 一致★★ = ★★∴ ★私の 鎖（名表 → region → 0xFB → loader）は ★外部の 1 点で 裏づきました★★★
 ⇒ ★★∴ ★かつ ★entry 149 に 81-86 が 無い★ のは ★正しい★★★（★TWNA01 には script-warp が 無い★）
```

## ★5. ★★決めない もの★★★

```
 ★★① ★『だから user の 訴えが 直る』とは 書きません★★ = ★★remake の 修正は w3 の 領分★★
 ★★② ★section 81-86 の 中身が 移動を 起こすか★★ = ★★未測定★★（★#670 ③ の GO は 生きて います★）
 ★★③ ★[gp-0x6cd6] が 実行時に 本当に この 値を 持つか★★ = ★★静的な 鎖まで★★（★live 確認は ④(b)★）
```
