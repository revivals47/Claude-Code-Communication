# 敵対 review: worker1 `RE_field_entity_array_rebase_2026-07-25.md` (commit aeb1138)

reviewer: worker3 / refute 目線 / read-only(worker1 worktree・degimon repo への書込みゼロ)
一次 source: `runtime_capture_2026-07-25/ram_live_1628_1.bin`(live RAM、2MB、offset = VA−0x80000000)、`ram_A/ram_B.bin`、`extracted/maps/*/*.json`(main repo)、live RAM 上の実 code(capstone 逆 assemble)

## 総括

| # | 対象 | 判定 |
|---|---|---|
| 1 | base `0x80145608` / stride `0xC4` | **支持(code で確定、統計不要)** |
| 2 | record 型(+0x00 type / +0xA8 pos / +0xB0 rot_y / +0xBC ai_type / +0xB4 trk) | **支持(writer の store offset と一致)** |
| 3 | off-by-one = 測定 artifact(0x1C+0xA8=0xC4) | **支持(算術完全一致)** |
| 4 | mayo00 自己同定 5/5 | **支持(私の独立再測で 25/25)** |
| 5 | twna13 の 3 variant 同点の扱い | **支持(JSON 直読で同一性を確認、honest mark 妥当)** |
| 6 | 経路 A の算術(0x147358→0x801458F6) | **支持**(ただし収束の**文言**は要修正、§B) |
| 7 | savestate prefix `0x1A62` の数値 | **判定不能**(.sav 不在。ただし**方法は非循環**、§E) |
| **A** | §3「type 一致 20/20 vs 旧仮説 3/17」 | **★要修正★ 比較が strawman = discriminator でない** |
| **B** | §1「経路 A の点は経路 B lattice の record 境界そのもの」 | **★要修正★ 位相の取り違え** |
| **C** | §7「writer code 未特定 / 参照 44 は主に read・AI 側」 | **★要修正★ 反証(STORE 34 / LOAD 10、writer = 0x800bae54)** |
| **D** | §2「+0x04 = x(home/spawn)」「+0x0C = z」 | **★要修正★ 5 record 中 1 件で不一致 = over-generalization** |
| 8 | §6 未解決 signal の扱い | **適切**(ただし静的に詰められる、§F) |

---

## 支持された項目(独立再測の根拠)

### 1. stride 0xC4 と base 0x80145608 は ★実 code で確定★(統計論争は不要)

`0x800bae54` の関数内、配列参照の直前:

```
0x800baec4: sll  v0, s2, 3      ; v0 = k*8
0x800baec8: sub  v1, v0, s2     ; v1 = 7k
0x800baecc: sll  v0, v1, 3      ; v0 = 56k
0x800baed0: sub  v0, v0, v1     ; v0 = 49k
0x800baed4: sll  v1, v0, 2      ; v1 = 196k = 0xC4 * k   ★
0x800baed8: lui  v0, 0x8014
0x800baedc: addiu v0, v0, 0x5608 ; 0x80145608(0x5608 < 0x8000 = lui 符号拡張補正不要)
0x800baee0: addu v0, v0, v1
0x800baee4: sh   a0, 0(v0)       ; record[k] + 0x00 へ store
```

⇒ **stride = 0xC4、base = 0x80145608 は逆 assemble から直接読める**。lattice の統計的強さを論じる必要が無い。

**参考: 私の自己相関手法での再測**(boss1 要求項目)。region = `[0x80145608, +8*0xC4]`:

| window | stride 0xC4 の一致率 | 順位 |
|---|---|---|
| 8 record | **0.875** | **319 候補中 1 位** |
| 6 record | **0.850** | **319 候補中 1 位** |

2 位以下は 0x1(0.825)、0xc5/0xc3(0.80、周期の裾)。⇒ 統計的にも 1 位で支持。ただし window が 8 record しかなく倍数(0x188)の検定力は無い。**code 側証拠の方が上位**。

### 2. record 型 = writer の store offset と一致(★doc の型表より強い接地★)

`0x80145608` を lui+addiu で参照する site を全走査(45 site)し load/store 分類:

| site | 命令 | 対応 field |
|---|---|---|
| 0x800baed8 | `sh a0, 0(v0)` | **+0x00 = type** |
| 0x800baf14 | `sb a0, 0xbc(v0)` | **+0xBC = ai_type** |
| 0x800baf44 / 74 / a4 | `sh a0, 0xa8/0xaa/0xac(v0)` | **+0xA8/AA/AC = pos x/y/z** |
| 0x800bafd4 | `sh a0, 0xae(v0)` | +0xAE |
| 0x800bb004 / 34 | `sh a0, 0xb0/0xb2(v0)` | **+0xB0 = rot_y** |
| 0x800bb064 | `sh a0, 0xb4(v0)` | **+0xB4 = tracking_range** |
| 0x800bb38c | `sb zero, 0xbe(v0)` | +0xBE clear |

source は `lh a0,(v0); addiu s0,v0,2` の**逐次 u16 stream**(= map file の entities section を順読み)。⇒ doc の型表は **writer 側から独立に裏取りされる**。

### 3. off-by-one = artifact の算術(完全一致)

- 旧 base = 新 record + **0xA2**(実測: 旧 base 0x801458F6、新 record3 = 0x80145854)
- 旧 `pos@+0x6` → 0xA2+0x06 = **+0xA8** = 新 pos ✓
- 旧 `type@+0x22` → 0xA2+0x22 = **+0xC4** = **次 record の +0x00** ✓

⇒ doc §0-3 の「0x1C + 0xA8 = 0xC4」は正しい。**機構説明として成立**。

### 4. mayo00 自己同定 = 私の独立再測で 25/25

`ram_live_1628_1.bin`、record k = 0x80145608 + k*0xC4:

| k | type | pos(+0xA8) | rot_y(+0xB0) | trk(+0xB4) | ai(+0xBC) | json |
|---|---|---|---|---|---|---|
| 0 | 74 | (594,0,2347) | 3072 | 1000 | 12 | 全一致 ✓ |
| 1 | 74 | (327,0,-1500) | 3072 | 1000 | 12 | 全一致 ✓ |
| 2 | 3 | (-226,0,1688) | 3072 | 2000 | 16 | 全一致 ✓ |
| 3 | 83 | (594,0,2347) | 3072 | 1000 | 12 | 全一致 ✓ |
| 4 | 83 | (327,0,-1500) | 3072 | 1000 | 12 | 全一致 ✓ |

5 field × 5 record = **25/25**。position だけでなく 5 field 全てが一致するので、2 位 twnb24 3/8(position のみ)との差は doc の記載以上に大きい。**多重度の懸念は mayo00 については解消**。

position の全 RAM 走査でも lattice は等差:`0x801456b0, 0x80145774, 0x80145838, 0x801458fc, 0x801459c0`(差 = 0xC4 × 4)✓

### 5. twna13 の同点扱い = ★explanation を独立検証済★

doc は「NPC data を共有する map variant 群」と説明するが doc 内に検証が無い。JSON 直読で追試:

```
twna13 n=8  sig=[(43,(-162,0,-2352),1),(159,...),(160,...),(168,...),(129,...),(131,...),(147,...),(146,...)]
twna10 n=8  == twna13
twna07 n=8  == twna13
twna04 n=8  == twna13
twna01 n=7  != twna13
```

⇒ type/position/ai_type まで**完全同一**。同点は data 共有によるもので、honest mark は妥当、結論に影響しないという doc の判断も妥当。**支持**。

### 6. 静的参照カウント

| target | 私の実測(live RAM) | doc |
|---|---|---|
| 0x80145608 | **45 site** | 44 |
| 0x801456AA | **0** | 0 ✓ |
| 0x801456B0 | **0** | — |
| 0x80147358 | **0** | 0 ✓ |

45 vs 44 は lui→addiu 間の許容命令数など走査 heuristic の差。矛盾ではない(doc は EXE file、私は live RAM)。**支持**。

### 7. ai_type の code 側接地

```
0x800bbf54: lb    v0, 0xbc(s0)
0x800bbf5c: sltiu at, v0, 0x13        ; < 19
0x800bbf68: lui   v1, 0x8012
0x800bbf6c: addiu v1, v1, -0x53dc     ; jump table 0x8011AC24
0x800bbf80: jr    v0
```
`lb v0,0xc0(s0)` / `lb v0,0xc1(s0)` も実在 ⇒ struct が +0xC1 まで及ぶことと整合。**支持**。

---

## ★要修正★

### A. §3「type 一致 20/20 vs 旧仮説 3/17」は **strawman** で、discriminator になっていない(最重要)

doc の「旧仮説」列が実際に採点しているのは **「新 base の type」vs json[N+1]** である。私の再計算:

- mayo00: 新 type = 74,74,3,83,83。json[k+1] = 74,3,83,83 → 一致は k=0,k=3 の **2/4** = **doc の 2/4 と一致** ⇒ 採点式が上記であることが確定。

しかし**本来の旧仮説**は「**旧** base 読み(pos@+0x6 / type@+0x22)の値」vs json[N+1] である。これを採点すると:

- mayo00: 旧読み type = record{k+1}+0x00 = 74,3,83,83 vs json[k+1] = 74,3,83,83 → **4/4**
- twna01: doc **自身の §4 表**の「旧読み」列 = 30,117,117,43,30,44 vs json[1..6] = 30,117,117,43,30,44 → **6/6**

⇒ **§3 と §4 が同一 doc 内で矛盾している**(§3 は twna01 の旧仮説を 1/6 と記すが、§4 の表は 6/6 を示す)。

**帰結**: 「20/20 vs 3/17」は同一 bytes を 2 通りの framing で読んだ結果の**言い換え**であり、どちらの framing が正しいかを判定しない。母数(20 vs 17)の公平性以前に、**比較の設計自体を訂正**する必要がある。

**真の discriminator は doc 内に既にある**ので、結論は揺らがない。以下に置換を提案:
1. 静的参照 45 vs 0(§6)— 決定的
2. `lb 0xbc(s0)` + switch 上限 0x13(§7)— s0 が新 base のときのみ ai_type と整合
3. writer の store offset(本 review §2)— **最強**
4. k=6 の内部矛盾(position 有・type 0xFFFF)が新読みで解消

### B. §1「経路 A が与えた 0x801458F6 は、経路 B の lattice の record 境界そのもの(0x801456AA + 3×0xC4)」は位相の取り違え

- 算術自体は正: 0x801456AA + 3×0xC4 = 0x801458F6 ✓
- しかし **0x801456AA は record 境界ではない**。record 境界 = 0x80145608 + k×0xC4 であり、0x801456AA = record + **0xA2**(= position − 6 = 旧 framing の base 位相)。
- 正しい表現: 「経路 A の点は、経路 B の position lattice 点のちょうど **6 byte 手前**に落ちる(= 旧 framing の pos@+0x6 と整合)」。
- record 境界を確定したのは **EXE 参照**(doc §1 後段)であり経路 A ではない。doc 後段は正しいので、**収束の文言のみ修正**すれば足りる。
- なお収束の証拠力自体は本物(a priori 1/196)。

### C. §7 の honest gap「writer code 未特定」「lui 参照 44 箇所は主に read/AI 側」は **反証**

45 site を load/store 分類した実測:

| 種別 | 件数 |
|---|---|
| **STORE** | **34** |
| LOAD | 10 |
| 判定不能 | 1 |

- 「主に read/AI 側」は誤り。**多数派は store**。
- populate loop = **`0x800bae54`**(先頭参照 0x800baed8 が `sh a0,(v0)`、source は逐次 u16 stream)。
- ⇒ §7 の第 1 gap は**既に手元 data で閉じている**。doc は自分の証拠を過小評価している。

### D. §2「+0x04 = x(home/spawn 系)」「+0x0C = z(home/spawn 系)」は over-generalization

mayo00 実測:

| k | json pos | +0x04 | +0x0C | 判定 |
|---|---|---|---|---|
| 0 | (594,0,2347) | 594 | 2347 | 一致 |
| 1 | (327,0,-1500) | 327 | -1500 | 一致 |
| **2** | **(-226,0,1688)** | **1968** | **1705** | **★不一致★** |
| 3 | (594,0,2347) | 594 | 2347 | 一致 |
| 4 | (327,0,-1500) | 327 | -1500 | 一致 |

- 不一致の k=2 は **ai_type=16 / tracking_range=2000** = 唯一の移動系個体。一致する 4 件は静止個体で +0xA8 と同値になっているだけ。
- さらに loader は `0x800bb9fc / 0x800bba28 / 0x800bba54` で **+0x04 / +0x08 / +0x0C に `sw zero`** を書く path を持つ ⇒ map file 由来の静的 home 値という読みと整合しない。
- ⇒ 「home/spawn 系」帰属は**未接地**。runtime field(移動目標 / 前 frame 位置等)の可能性。doc の接地欄「mayo00 で json x と一致」は 5 件中 4 件のみであり、**honest mark 化が必要**。

---

## 判定不能

### E. savestate frame prefix `0x1A62`(循環性の検討込み)

**数値は判定不能**: DuckStation savestate(`.sav`)が現環境に存在しない(`-fnl/workspace/savestate_backup/` は `.mcd` と `.sav.bak` のみ、`.sstate` は全 disk 走査で 0 件)。frame 抽出と署名検索を再現できない。

**循環性の判定 = 循環していない**:
1. prefix は **EXE 署名**(headerless `.bin` 先頭 0x400 B)を frame 内で検索し、PS-X EXE header の `t_addr = 0x80090800` 直読と突き合わせて決めている。決定に entity 配列も map JSON も使っていない。
2. その後の検証対象(経路 B の lattice、record 型、mayo00 自己同定)は **live RAM(`/proc/pid/mem`、savestate 非経由)** で測られている。異なる取得経路。
3. 算術チェック: `0x92262 − 0x90800 = 0x1A62` ✓
4. **独立整合**: `0x147358 − 0x1A62 = 0x1458F6`、そして `0x801458F6 + 6 = 0x801458FC` は私が live RAM で実測した position lattice 点と**一致**(§4)。savestate 由来の値が savestate を使わない測定の格子に乗るのは a priori 1/196 ⇒ 実質的裏付けあり。

⇒ 数値の再測は user/worker1 側の .sav 提供待ち。**方法論的な瑕疵は無い**。

---

## §6(未解決の反対 signal)の扱い = 適切。ただし静的に詰められる

- 「**配列 load は忠実**」と「**描画が record k の type を使うか**」を分離した honest gap の切り方は正しい。falsify 条件(原盤の個体色)も明示されており規範に適合。
- **補強材料(私の追試)**: `0x800bb544` は `record[k] + 0x00` を `lh` して引数の type と比較し、一致時に actor ptr 配列 `0x8013CDB4` の **(k+2)** entry を引く。
  ```
  0x800bb560-70: v1 = k * 0xC4
  0x800bb580:    lh v0, (0x80145608 + v1)     ; record[k].type
  0x800bb588:    beq s1, v0, ...              ; 引数 type と比較
  0x800bb59c:    addi v0, s0, 2               ; k + 2
  0x800bb5a8:    addiu v0, v0, -0x324c        ; 0x8013CDB4[k+2]
  ```
  ⇒ **entity record k ↔ actor slot k+2** の対応が code 側に存在し、slot0/1 = `0x8016B048`/`0x8016B084`(doc §5-B の player/partner)と整合。
- これは model 選択 path 本体ではないので §6 を閉じはしないが、**user 視覚確認より先に、LOAD 10 site の中から「+0x00 を読んで model を選ぶ関数」を特定する**方が安く確実。§6 を「user 待ち」から「静的 RE で閉じる」に格上げできる。

---

## 私の担当分(VAB 側)との整合確認(boss1 要求項目)

| 私の測定 | 領域 | worker1 の測定 | 領域 | 整合 |
|---|---|---|---|---|
| 周期 0x20(VagAtr) | `0x80146f9c .. 0x8014799c` | stride 0xC4 | `0x80145608 ..` | **領域が交わらない = 矛盾なし** |
| stride 0xC4 = 0.276(反証) | **VAB window 内のみ**の測定 | stride 0xC4 = 正 | entity 領域 | **矛盾なし**(私の反証は window scope 付き。scope 外へ一般化していない) |
| watchpoint semantics caveat(word watch では dst 開始・総長が不定) | wp log | — | savestate/live 直読 | **依存関係なし** |

**追加で提供できる制約(§7「最大 record 数未確定」への寄与)**:
VAB slot8 の buffer 先頭は `0x8014677c`(私の検証 §6.1-6.2 で確定)。entity 配列が連続かつ VAB buffer と重ならないなら、
`(0x8014677c − 0x80145608) / 0xC4 = 0x1174 / 0xC4 = 22.79` ⇒ **最大 22 record**。
(前提: 両者が隣接 region で、間に他 object が無いこと。上限の**必要条件**であり実際の配列長ではない。)

---

## 修正要求(boss1 経由・優先度順)

1. **§3 の比較を撤回・置換**(A)。「20/20 vs 3/17」を根拠から外し、静的参照 45 vs 0 / `lb 0xbc(s0)` / writer store offset / sentinel 整合の 4 点に置き換える。§3 と §4 の内部矛盾も解消。
2. **§7 の gap 1 を閉じる**(C)。writer = `0x800bae54`、STORE 34 / LOAD 10 を記載。
3. **§2 の +0x04/+0x0C の接地を honest mark 化**(D)。mayo00 k=2 の反例と `sw zero` path を明記。
4. **§1 の収束文言を修正**(B)。「record 境界そのもの」→「position lattice 点の 6 byte 手前 = 旧 framing の base 位相」。
5. (任意)§7 の最大 record 数に上限 22 を追記、§6 に actor slot = k+2 の対応と静的 close 手順を追記。

**結論は維持**: base `0x80145608` / stride `0xC4` / off-by-one = 測定 artifact という 3 本柱はいずれも **code 側から独立に裏取りでき、反証は見つからなかった**。要修正 4 件はすべて**論証の書き方**と**過小・過大評価**の問題であり、結論を覆すものではない。
