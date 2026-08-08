# entity record `+0xBD` / `+0xBF` / `+0xC1` の writer 全数特定 (worker1, 2026-08-08)

**発端**: user 観測(TANE 居た / YURA 居た / ★TOKO 居なかった★)と、原盤 record の
`+0xBD` 非0/0 が twna01 4 素材 × 7 record = 28 点で相関した(boss1 実測)。
`+0xBD` は loader `0x800BAE54` の書込み対象外 ⇒ ★runtime 側の writer を特定する★のが本 doc の task。

claim 規律: 【観測】= disasm 直読 / bytes 直読。【推論】= 未裏取り。

---

## 0. 結論(先出し)

1. ★writer は全数特定した(resident EXE 内)★ — store ★13 site / 8 関数★(§1)
2. ★`+0xBD` / `+0xBF` は waypoint 機構の state★【観測 = 命令列】(§3)
   - `+0xBF` = ★waypoint で待機中か★ / `+0xBD` = ★その待機の tick counter★ / `+0x94` = ★waypoint index★
   - ∴ ★可視 flag ではない★。worker3 が `0x800BCC20` 側から出した結論と ★別関数から独立に一致★
3. ★`+0xC1` != 0 は per-entity update 全体を skip させる latch★。writer は `0x800BD820` のみで、
   その caller は ★event/script VM 帯★(§2)
4. ★twna01 の 7 record は全て `ai(+0xBC)=1`。ai jump table `0x8011AC24` で ai=1 の飛び先は
   `0x800BC1B4` = epilogue★ ⇒ ★ai arm では何もしない。動くのは waypoint 経路だけ★(§2)
5. ★反例を自分で出した★: `+0xC1` は「見えた/見えない」と一致しない(§4)
6. ★母集団の限界を明示★: resident EXE のみ。overlay 未走査、`addu` 畳み込み未網羅(§5)

---

## 1. writer 全数(displacement scan)

`sb/sh/sw` の displacement が `0xBD` / `0xBF` / `0xC1` の store を EXE 全走査で抽出:

| 関数 | 書く offset | caller |
|---|---|---|
| `0x800BB994`(clear) | `+0xBD`←0 / `+0xBF`←0 | `0x800DFA04`(map load) |
| `0x800BBD6C` | `+0xBF`←0 ×2 | `0x800BBD48` / `0x800BD904` / `0x800BD99C` |
| `0x800BC57C` | `+0xBF`←0 | `0x800BBFD4` |
| `0x800BCC20` | `+0xBD` ×4 / `+0xBF` ×1 | `0x800BC704` |
| `0x800BCF28` | `+0xBD` ×3 / `+0xBF` ×1 | `0x800BC8B8` |
| ★`0x800BD1B0`★ | `+0xBD` ×3 / `+0xBF` ×2 | `0x800BC424` |
| `0x800BD278` | `+0xBF` ×2 | `0x800BC440` / `0x800BC45C` |
| ★`0x800BD820`★ | ★`+0xC1` ×2★ | ★`0x800EE930` / `0x800F0950` / `0x800F0B1C` / `0x800F0B2C` / `0x800F0C54`★ |

★base が entity 配列であることの直接確認★【観測】: `0x800BD8E8` / `0x800BD988` の 2 site は直前で
`lui 0x8014` + `addiu 0x5608` + `idx*0xC4`(`sll 3 / sub / sll 3 / sub / sll 2` の定型)を組んでいる
= ★`0x80145608` / stride `0xC4`★。残り 11 site は関数引数で record ptr を受け取る形。

---

## 2. 呼ばれる条件 / ★書かれない条件★

per-entity update = `0x800BBEA8(a0 = record ptr, a1 = …)`【観測 = 命令列】:

```
0x800BBF24  lb   v0, 0xC1(s0)
0x800BF2C   bnez v0, 0x800BC360        ← ★+0xC1 != 0 なら update 全体を skip★
0x800BBF34  lb   v0, 0xC0(s0)
0x800BBF3C  bnez v0, 0x800BBF54
0x800BBF4C  jal  0x800BC3D0            ← ★+0xC0 == 0 のときだけ waypoint 系を呼ぶ★
0x800BBF54  lb   v0, 0xBC(s0)          ← ai_type
0x800BBF5C  sltiu at, v0, 0x13
0x800BBF60  beqz at, 0x800BC1B4        ← ai >= 19 は skip
0x800BBF68  lui/addiu → 0x8011AC24     ← ★ai jump table(19 entry)★
0x800BBF80  jr   v0
```

★注意★: `lui $v1,0x8012` + `addiu $v1,$v1,-0x53dc` = ★`0x8011AC24`★。
私は初回 `0x8012AC24` と読み違えた(memory `reference_mips_lui_sign_extension_trap` の型)。★訂正済★。

### ai jump table `0x8011AC24`(19 entry)【観測 = bytes 直読】

| ai | 飛び先 | ai | 飛び先 |
|---|---|---|---|
| 0 / 1 / 10 | ★`0x800BC1B4` = epilogue(何もしない)★ | 2 / 11 | `0x800BBF88` |
| 3,4,5,12,13,14 | `0x800BBFE4` | 6 / 15 | `0x800BC044` |
| 7 / 16 | `0x800BC0CC` | 8,9,17,18 | `0x800BC154` |

★twna01 の 7 record は全て ai=1★【観測 = RAM】 ⇒ ★ai arm は epilogue 直行★。
∴ ★twna01 で `+0xBD`/`+0xBF` が動く経路は「`+0xC1`==0 かつ `+0xC0`==0 のときの
`0x800BC3D0` → `0x800BD1B0` / `0x800BD278`」だけ★。

### 近接判定 `0x800BC4B4`(ai=2/3/4/5/11/12/13/14 の arm が使う)

```
return 1 iff  pos.x(+0xA8) - r < px  &&  px < pos.x + r
          &&  pos.z(+0xAC) - r < pz  &&  pz < pos.z + r      (r = +0xB4)
```
`px/pz` = `[0x8016B04C] + 0x78`(player struct 経由)。
★`+0xB4` は抽出 JSON の `tracking_range` と一致★【観測: twna01 idx0/1 = 1000、idx2-6 = 0】。
★不等号が厳密なので `r = 0` では絶対に成立しない★。

---

## 3. ★`+0xBD` / `+0xBF` の機構 = waypoint の待機 state★【観測 = `0x800BD1B0` の命令列】

```
0x800BD200  sb  zero, 0xBD(s0)      ; 待機開始: counter = 0
0x800BD208  sb  1,    0xBF(s0)      ; ★+0xBF = 1(待機中)★
...
0x800BD214  lb  v0, 0xBD(s0)
0x800BD21C  addi v0, v0, 1
0x800BD220  sb  v0, 0xBD(s0)        ; ★+0xBD += 1(tick)★
0x800BD228  lh  v0, 0x94(s0)        ; waypoint index
0x800BD230  sll v0, v0, 4           ; *16
0x800BD238  lw  v0, 4(s0 + idx*16)  ; ★この waypoint の待機長★
0x800BD240  slt at, v1, v0          ; +0xBD < 待機長 なら継続
0x800BD24C  sb  zero, 0xBF(s0)      ; 満了: 待機解除
0x800BD250  sb  zero, 0xBD(s0)      ; counter リセット
0x800BD25C  addi v0, v0, 1
0x800BD260  sh  v0, 0x94(s0)        ; ★waypoint index を進める★
```

∴ ★`+0xBD` = waypoint 待機の経過 tick / `+0xBF` = 待機中フラグ / `+0x94` = waypoint index★。
★可視性を表す field ではない★。

★worker3 の独立結論との一致★: worker3 は `0x800BCC20`(ai arm 側)で
「`+0xC0`==3 のとき `+0xBD` += 1、0x28 で 0 に戻る counter / default は何もしない」を確定した。
★別関数・別経路から、どちらも「counter であって可視 flag ではない」に到達している★。

### RAM 実測との整合【観測、twna01 4 素材】

| record | `+0xBD` | `+0xBF` | `+0xC0` | `+0xC1` | 読み(推論) |
|---|---|---|---|---|---|
| idx4(s9 YURA) | 6 / 8 / 18 / 26 | 1 | 0 | 0 | ★waypoint 待機中で tick が進んでいる★ |
| idx6(s11 TANE) | 6 / 8 / 23 / 23 | 1,1,0,0 | 0 | ★0,0,1,1★ | 待機 → `_9`/`_10` では待機解除 + `+0xC1`=1 |
| idx0-3, idx5 | 0 | 0 | 0 | 0 | waypoint 機構が一度も進んでいない |

★`+0xC0` は 28 record すべて 0★【観測】。

---

## 4. ★自分で出した反例: `+0xC1` は「見えた/見えない」と一致しない★

user は ★TANE(script11 = idx6)を「居た」★ と答えている。しかしその idx6 は
★`_9` / `_10` の 2 素材で `+0xC1` = 1★ =(§2 より)★update 全体を skip する latch が立っている★。

∴ ★「`+0xC1` != 0 = 見えない」は成立しない★。
同様に ★「`+0xBD` 非0 = 可視」も機構としては支持されない★(§3 = waypoint 進行度)。

★28/28 の相関は事実のまま。因果の読みだけが棄却された★。
★script10(TOKO)が原盤で表示されるかは、本 doc の範囲では未決定★。

---

## 5. ★母集団の限界(honest)★

1. ★本 scan は resident EXE(`0x80090800`〜`0x8013E000`)のみ★。
   ★overlay(`btl_rel` / `evl_rel` 等 `0x8005xxxx` 帯)は逆アセンブル対象外 = 未走査★。
2. pointer 畳み込み(base に `+0xBD` を足してから displacement 0 で store)は
   ★`addiu $x, $y, 0xBD/0xBF/0xC1` 形を全数検査 → 該当 0 件★(検出された 8 件は全て
   `addiu $x, $zero, 0x..` = 即値 load であって base 畳み込みではない)。
   ★ただし `addu` 経由の畳み込みは網羅していない★。
3. ∴ ★「writer 全数」は "resident EXE 内、displacement 形" に限った主張★。
4. ★次段の起点にも同じ盲点がある★: 「base 組立 site(`0x80145608` を lui/addiu で作る箇所)を数える」方式は
   ★record ptr を引数で受け取る関数を原理的に含まない★。
   次に `+0xC0` の writer を追うときは ★entity を loop する関数から呼ばれる leaf まで辿る★必要がある。

---

## 6. 副産物(記録)

- ★`+0xB4` = `tracking_range`★(JSON と一致、近接判定の半径)
- ★`+0x94` = waypoint index / `+0x84` 帯 = waypoint 配列★(`0x800BC3D0` が `+0x84[+0x94*2]` で
  command を読み、0/1/2 で `0x800BD1B0` / `0x800BD278(a2=2)` / `0x800BD278(a2=4)` に分岐)
- `0x800BD820(a0, a1)`: `a0 == -1` で ★全 entity loop★ して `+0xC1` = `a1`、
  `a0 >= 2` で ★index = `a0 - 2` の単体★に書く【観測】。★`a0` の意味(script id との対応)は未検証★
- audit §3-C の `0x8017Bxxx` 疑い: 本 scan で見た `lui 0x8017; addiu -0x4fb8` は
  ★`0x8016B048`(符号拡張)★であり、`0x8017B048` ではない。★doc 側の `0x8017B084` 記載が
  誤記という audit の推定を支持する材料★(断定はしない)
