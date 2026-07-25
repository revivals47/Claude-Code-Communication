# VERIFY: runtime capture 2026-07-25 独立裏取り(worker3 / triple-grounding)

対象: `RUNTIME_SESSION_2026-07-25.md` の【観測】claim。
手法: 生 log / 生 binary からの独立再導出のみ。worker1/worker2 の中間成果は項目 (1)-(5) 完了まで非参照(独立性維持)。
read-only 検証。degimon repo 本体・他 worktree への書込みなし。

一次 source:
- `runtime_capture_2026-07-25/` 内の生 log(行番号で引用)
- `runtime_capture_2026-07-25/ram_A.bin` / `ram_B.bin`(各 2MB、main RAM 0x80000000 起点の raw image。offset = VA - 0x80000000)
- `/home/ken/Desktop/Digimon/degimon_world_remake/extracted/btl_rel.bin`(179412 bytes、read-only)

---

## 総括(3 値判定一覧)

| 項目 | 判定 |
|------|------|
| (1) wp log の 5 値(ra/dst/src/len残/battle ra+len) | **一致**(全値を log から再抽出) |
| (1-補) 「field 歩行中 trap ゼロ」 | **判定不能**(log に user 操作の注記なし。下記 §1.2) |
| (2) 0x0c024514 = jal 0x80091450 / 引数構成 | **一致**(機械語 1 命令ずつ検算) |
| (3) 0x9FD4 算術 / 0x9FCC = jal 0x80056ca8 | **一致**(実 bytes 確認、全 file 走査で caller 単一) |
| (4) ENTITY_ARRAY 周期 | **stride 0x20 = 支持 / stride 0xc4 = 反証**(自己相関、下記 §4) |
| (5) 戦闘突入 +6s / per-attack 非発火 / ra / args | **一致** |
| (5-★) 「2 call(sp 0x30 差 = 別 frame 連続)」 | **★矛盾★ = 実際は 1 call**(下記 §5.2) |
| (6) claim A(9-slot pBAV table) | **支持** |
| (6) claim B(slot8=0x8014677c、+0xBDC) | **支持** |
| (6) claim C(ps=5 / VH 0x1420) | **支持**(ただし「copy 長と一致」は表現要精密化、§6.3) |
| (6) claim D(VagAtr 構造) | **支持**(私の (4) 自己導出と完全整合、§6.4) |
| (6) claim E(SPU chain) | **到達性=支持 / 「psyq SPU ライブラリ系」=判定不能**(§6.5) |

**帰属レベルの最大所見**: §1 の「field NPC loader / entity array」帰属は誤り。0x80147358 は psyq **VAB(音源 bank)header 領域**の内部であり、BIOS copy は VAB VH のロードである(§6 で確定)。

---

## §1 検証項目 (1): wp_field_loader_*.log 直読

### 1.1 5 値の再抽出 = 全て一致

`wp_field_loader_4.log:22`(TRAP 1、15:40:25):
```
TRAP 1 pc=bfc02b68 ra=800cf1a8 a0=80147359 a1=80010be9 a2=00000043 a3=00000001
       v0=0000000c v1=8014677c t0=bfc02b50 t1=000000a8 s0=80010000 s1=80010018 mem=00000000
```
- ra=`0x800cf1a8` ✅ / dst a0=`0x80147359` ✅ / src a1=`0x80010be9` ✅ / len残 a2=`0x43` ✅
- 同一 pattern の再現: `bp_damage_2.log:23`(15:50:24)、`bp_damage_2.log:28`(15:50:29) → ra=0x800cf1a8 は session 全体で計 **3 回**

battle 側 `wp_field_loader_4.log:124`(TRAP 12、15:41:46): ra=`0x80108960` a2=`0x00000843` ✅
- 同 pattern 再現: `bp_damage_1.log:22`、`bp_damage_2.log:33`、`bp_damage_2.log:58`、`wp_hp_1.log:33`
- battle 終了側(len=0x43 + 同 ra): `wp_field_loader_4.log:133`、`bp_damage_1.log:37`、`bp_damage_2.log:48`、`bp_damage_2.log:73`、`wp_hp_1.log:22`、`wp_hp_1.log:77`

→ **一致**。5 値すべて log 実在。

### 1.2 「field 歩行中 trap ゼロ、遷移の瞬間のみ発火」= 判定不能

- `wp_field_loader_4.log` の 15:40:25-15:42:01 には **13 stop** が記録され、うち pc=bfc02b68 は 3 件のみ。残り 10 件は 0x80091e4x(CD polling、doc §3 が既知 noise と認定)、0x800b8ca0、0x8009dcf0、0x800ca5f8、0x00001830。
- log には user 操作(歩行/遷移)の時刻注記が無く、「歩行中」の window を log 単独で確定できない。加えて doc §3 の「切断で watch/BP 残存 → 別 session の stop 混入」gotcha により、非 bfc02b68 stop の帰属自体が不定。
- **log から言えること**: bfc02b68 の write path は burst せず離散的にのみ発火(log4=3 / bp_damage_2=4 / bp_damage_1=2 / wp_hp_1=3)。
- 「2 回再現」自体は `bp_damage_2.log:23,28` の 2 連で **一致**。

→ **判定不能**(反証ではない。log に必要な入力注記が無い)。

### 1.3 ★watchpoint semantics の重要 caveat(後続の全推論に効く)★

`wp_multi2.gdb` は `watch *(unsigned int*)0x80147358` = **word 単位 HW watch**。昇順 byte copy が 0x80147358..0x8014735b のどこかに最初に触れた時点で発火する。

したがって:
- **a0=0x80147359 は「copy が 0x80147358 から始まった」ことを意味しない**。開始 dst が 0x80147358 以下であれば、どこから始まっても a0=0x80147359 になる。
- a2=0x43 / 0x843 は **残長**であり総 copy 長ではない。総長 = (0x80147358 - dst開始) + 残長 + 1。

→ doc の表記(「len残=0x43」)はこの点で honest。ただし **開始 dst と総長は log から導出不能**。この caveat が §6 の VAB 解釈を可能にした。

---

## §2 検証項目 (2): memdump_1.log disasm 節の自力換算

### 2.1 jal encode = 一致

`memdump_1.log:66`: `0x800cf1a0: 0x0c024514`

自力換算(MIPS J-type): opcode = 0x0c024514 >> 26 = **3** = jal。
target = ((PC+4) & 0xF0000000) | ((word & 0x3FFFFFF) << 2)
= (0x800cf1a4 & 0xF0000000) | (0x0024514 << 2) = 0x80000000 | 0x0091450 = **0x80091450** ✅

逆算: 0x0C000000 | ((0x80091450 >> 2) & 0x3FFFFFF) = **0x0C024514** ✅(bit 一致)

`memdump_1.log:47` の gdb disasm(`jal 0x80091450`)と独立に一致。

### 2.2 引数構成 = 一致(機械語 1 命令ずつ検算、`memdump_1.log:62-66` の RAWBYTES から)

| VA | word | 自力 decode |
|----|------|------------|
| 0x800cf160 | 8fa20068 | `lw v0,0x68(sp)` (=104(sp)) ← **idx** |
| 0x800cf168 | 00021880 | `sll v1,v0,2` |
| 0x800cf16c | 3c028013 | `lui v0,0x8013` |
| 0x800cf170 | 24424230 | `addiu v0,v0,0x4230` → **0x80134230**(0x4230 < 0x8000 = lui 符号拡張トラップ無し) |
| 0x800cf174 | 00432021 | `addu a0,v0,v1` = table + idx*4 |
| 0x800cf178 | 8e020000 | `lw v0,0(s0)` |
| 0x800cf180 | 00021082 | `srl v0,v0,2` |
| 0x800cf184 | 00021080 | `sll v0,v0,2` → `[s0] & ~3` |
| 0x800cf188 | 02022821 | `addu a1,s0,v0` ← **src** |
| 0x800cf18c | 8e030004 | `lw v1,4(s0)` |
| 0x800cf190 | 8e020000 | `lw v0,0(s0)` |
| 0x800cf198 | 00623023 | `subu a2,v1,v0` ← **len = [s0+4] - [s0+0]** |
| 0x800cf19c | 8c840000 | `lw a0,0(a0)` ← **dst = *(0x80134230 + idx*4)**(「指す先」で正しい) |

→ doc の記述(a0 = `[0x80134230 + idx*4]` の指す先 / a1 = s0+([s0]&~3) / a2 = [s0+4]−[s0+0] / idx = sp+104)は **一致**。

### 2.3 追加観測(doc の【推論】を promote 可)

`ram_A.bin` から 0x80091450 を逆 assemble:
```
0x80091450: addiu t2,zero,0xa0
0x80091454: jr    t2
0x80091458: addiu t1,zero,0x2a
```
= PSX BIOS **A0 table trampoline、A(2Ah) = memcpy**。近傍 entry も 0x80091460→0x2b、0x80091470→0x2e と連番で整合。trap 地点 0xbfc02b68(BIOS ROM 内 `lbu t6,0(a1)` loop)は memcpy の byte loop 本体。

→ doc の【推論】「memcpy wrapper、BIOS A0 系」は **観測へ promote 可**。
※ 0x800cf110 の `jal 0x80091430` は A(1Fh)。機能名は未同定(推測を書かない)。

### 2.4 ★honest gap: STAGING 節は trap 時刻の src ではない★

`memdump_1.log:147`: `0x80010000: 0x00060005 0x00000003 ...`
→ §2.2 の式に代入すると a2 = [s0+4] − [s0+0] = 3 − 0x60005 = **負**、a1 = s0 + 0x60004 = buffer 外。

つまり memdump 採取時点の 0x80010000 は「copy 直前の header」状態ではない。`===STAGING===`/`===STAGING_HEAD===` を copy の src oracle として使うことは**できない**。memdump(15:4x)・wp log(15:40-15:42)・ram_A/B(16:0x)は**すべて別時刻**。

---

## §3 検証項目 (3): btl_rel.bin 直読

- 算術: `0x8005cab4 - 0x80052ae0` = **0x9FD4** ✅(load base 0x80052ae0 前提)
- 期待 encode: `0x0C000000 | ((0x80056ca8 >> 2) & 0x3FFFFFF)` = **0x0C015B2A**
- 実 bytes:

| file offset | word | decode |
|---|---|---|
| 0x9FC8 | 0xaf829250 | (sw) |
| **0x9FCC** | **0x0c015b2a** | **jal 0x80056ca8** ✅ |
| 0x9FD0 | 0x00000000 | nop(delay slot) |
| 0x9FD4 | 0x0c015d3b | jal 0x800574ec ← ra の着地点 |

→ ra 0x8005cab4 = jal(0x8005caac) + 8 で整合。**一致**。
→ 追加: 復帰直後がまた jal(0x800574ec)= 戻り先が連続 call 列であることも直読で確認。

**完全性**: btl_rel.bin 全域(179412 bytes、4-byte stride 全数走査)で word == 0x0C015B2A は **0x9FCC の 1 箇所のみ** → 本 overlay 内の caller は単一。
※ 未走査: main EXE / 他 overlay からの呼び出し、および jalr 間接呼び出し。「唯一の caller」とまでは主張しない。

---

## §4 検証項目 (4): ENTITY_ARRAY 周期の自己導出【claim A-E を読む前に freeze 済】

★制約遵守: dump 採取時の map は未知のため、特定 map の NPC 表との join は一切行っていない。bytes だけの自己相関 + 内部整合のみ。★

### 4.1 周期(自己相関、byte 単位)

`memdump_1.log` の `===ENTITY_ARRAY_0x80147358===` 節(0x200 bytes)を word 列から byte 列へ復元し、先頭 zero run を除いた 0x1BA bytes で stride 別の byte 一致率を測定:

| stride | 一致率 |
|---|---|
| **0x20 (32)** | **0.841** |
| 0x40 / 0x60 / 0x80 / 0xa0 / 0xc0 / 0xe0 / 0x100(= 0x20 の倍数) | 0.806 - 0.833 |
| 0x20 の倍数でない全 stride(最良 = 0xbe / 0x9e / 0x02 / 0x22) | **≤ 0.313** |
| **0xc4 (196)** | **0.276** |

→ **stride 0x20 = 支持**(倍数のみが高く、非倍数は chance level に落ちる = 単一周期の典型 signature)。
→ **stride 0xc4 = 反証**(0.276 は非倍数群の chance 帯 0.27-0.31 の内側。0xc4 は 0x20 の倍数でもない)。

### 4.2 field map(位相自由 = 周期 32 の各 residue が record 間で不変か)

ram_A の 13 周期分で residue 別に不変/可変を判定(framing を VA 0x8014739e 起点に取った場合の相対 offset):

```
+0x00 可変(0x50,0x5a,0x5f,0x64,0x6e,0x74,0x7d,0x7f...)   +0x01 不変 0x40
+0x02 可変(0x53-0x6b)                                     +0x03 不変 0x00
+0x04 可変・昇順(0x3c,0x3d,0x3e...)                       +0x05 +0x04 と常に同値
+0x06..+0x0b 不変 0x00(6 bytes)
+0x0c 不変 0xb1  +0x0d 不変 0xb2  +0x0e 不変 0xff  +0x0f 可変(0x80,0xa1,0xac,0xaf)
+0x10 可変(0xc8,0xde,0xc0)  +0x11 不変 0x5f
+0x12 (u16) block 内不変・block 毎に 0,1,2,3,4 と昇順
+0x14 (u16) record 毎に昇順(0x001d,0x001e,...)
+0x16/+0x18/+0x1a/+0x1c (u16) 不変 0x00c0 / 0x00c1 / 0x00c2 / 0x00c3
+0x1e (u16) 不変 0x0000
```

★重要★ 自己相関は**周期**を決めるが**位相**は決めない。4-byte 整列を課すと record 先頭は VA ...9c(上表の -2)側が自然(先頭 2 bytes が常時 0x0000 field になる)。

### 4.3 ★0x80147358 は array の先頭ではない★

memdump の 0x200 window は打ち切られた view であるため、ram_A/ram_B で前後に拡張して同一 layout(tag 0x00c0/0x00c1/0x00c2/0x00c3 の 4 半語)の連続範囲を全数走査:

- **下方向**: 0x80147358 **より下にも同一 layout の record が連続**。tag 健全な最下位 record = **VA 0x80146f9c**(その直前 0x80146f7c は tag が 0xffff = 非該当)。
- **上方向**: tag 健全な最上位 record 末尾 = **VA 0x8014799c**。
- **総 extent = 0x80146f9c .. 0x8014799c = 0xA00 bytes = 80 record**。
- +0x12 の block counter は 16 record ごとに 0,1,2,3,4 と変わる(block = 0x200 bytes = 16 record)。**5 block × 16 = 80** で extent と一致。

→ doc §1 の「**先頭 0x44 byte ゼロ、以後 32-byte 周期**」は array header の記述として**成立しない**。0x80147358 は record 列の**途中**。
→ 実測: memdump では 0x80147358..0x8014739d の **0x46 bytes** が zero(doc の「0x44」は真だが極大ではない)。ram_A では 0x80147358 = 0xc2(元の tag 値)で zero run は 0x80147359..0x8014739d の **0x45 bytes**。
→ ram_B では**同じ領域に record が生存**(+0x14 = 0x001b / 0x001c)。すなわち zero は array の固定 header ではなく、**状態依存の上書き痕**。

### 4.4 doc §1 の付随記述への影響

- 「id 連番 0x1d..0x2a」: memdump window(0x200)が打ち切った範囲での観測。実際の当該 block は **0x1d..0x2c の 16 個**(★打ち切られた list の不在は否定でない★)。
- 「`00c0..00c3` 座標様 field」: **反証**。当該 4 半語は 80 record **全てで byte 同一**の定数。座標であれば record 毎に変動するはずで、座標解釈は成立しない。

**(4) 自己導出の結論(freeze 時点)**: 周期 = 0x20 確定 / 0xc4 反証 / 80 record・16 record block 構造 / 定数 tag / 2 系統の昇順 counter(block 毎定数の counter と record 毎昇順の counter)。**この時点では構造の意味付けはしていない**(型は未確定として保留)。

---

## §5 検証項目 (5): bp_damage_*.log 直読

### 5.1 一致した項目

- caller ra=`0x8005cab4`: `bp_damage_1.log:27,32` / `bp_damage_2.log:38,43,63,68` ✅
- args a0=`0x8016b084` / a1=`0x8016b0bc`: 同行 ✅(全 hit で不変)
- **戦闘突入 +5〜6 秒**: 3 戦とも Δt = **6 秒ちょうど**(秒解像度)✅
  - `bp_damage_1`: 15:46:49(0x843 copy)→ 15:46:55(hit)
  - `bp_damage_2`: 15:50:46 → 15:50:52 / 15:52:22 → 15:52:28
- **per-attack 非発火**: ✅。各戦闘で 0x80056ca8 系 stop は 1 組のみ、user 同期攻撃の window でも増えない。
  - **完全性の確認**: `bp_damage.gdb` / `bp_damage2.gdb` は `while $n<60` cap。log の終端は HIT 4 / HIT 11 で **cap 飽和していない** → 「発火が無かった」を主張してよい(飽和下の不在主張ではない)。
  - ただし doc §3 の「切断で BP 残存」gotcha は逆向き(stale BP による**混入**)の risk として残る。

### 5.2 ★矛盾: 「2 call(sp 0x30 差 = 別 frame 連続)」は 1 call★

log の pair(`bp_damage_1.log:27,32`):
```
HIT 2 pc=80056ca8 ra=8005cab4 a0=8016b084 a1=8016b0bc a2=0 a3=0 v0=00000010 s0=66 s1=1 s2=5 sp=801ffe00
HIT 3 pc=80056cac ra=8005cab4 a0=8016b084 a1=8016b0bc a2=0 a3=0 v0=00000010 s0=66 s1=1 s2=5 sp=801ffdd0
```

**反証根拠 1(決定的)**: 2 件目の pc は **0x80056cac** であり、breakpoint を張った 0x80056ca8 **ではない**。関数の新規 call であれば必ず entry 0x80056ca8 で止まる。0x80056cac に BP は存在しないので、この stop は call entry ではありえない。

**反証根拠 2(sp 差の正体)**: btl_rel.bin 直読(file offset = VA − 0x80052ae0):

| VA | offset | word | decode |
|---|---|---|---|
| 0x80056ca8 | 0x41C8 | **0x27bdffd0** | **addiu sp,sp,-0x30** |
| 0x80056cac | 0x41CC | 0xafbf001c | sw ra,0x1c(sp) |
| 0x80056cb0 | 0x41D0 | 0xafb20018 | sw s2,0x18(sp) |

0x80056ca8 は関数 entry(frame size 0x30)。sp 差 0x801ffe00 − 0x801ffdd0 = **0x30** は prologue 命令の即値そのもの。他 register(ra/a0/a1/a2/a3/v0/s0/s1/s2)は **全て bit 一致** = 同一 frame の prologue 前後。

**反証根拠 3**: `bp_damage_2.gdb` は `hbreak`(Z1)を使用しているが同じ pair が出る → software break 固有の現象ではなく、DuckStation stub が BP 通過後に次命令で再 report する挙動。doc §3 が既知とした「pc+4 ずれ」がここに適用されていない。

→ **s_damageCheck の呼び出し回数は 1 戦につき 1 call**。doc §2 の「2 call」「別 frame 連続」は撤回が必要。結論部(「1 回だけ発火 / per-attack 非発火」)は影響を受けず、むしろ強化される。

### 5.3 帰属の訂正(§6 の結果を反映)

「戦闘突入」の時刻基準に使っている 0x843 copy は、§6 より **VAB battle bank(ps=5)のロード**である。時間関係の観測(bank 切替 → 6 秒後に s_damageCheck)は保存されるが、基準点の呼称は「戦闘突入」→「**battle 音源 bank 切替時刻**」に置き換わる。

---

## §6 追加項目: claim A-E の敵対検証(refute 目線)

★(4) の自己導出 freeze 後に実施。以下は全て ram_A.bin / ram_B.bin / log の直読。★

### 6.1 claim A(0x80134230 = 9-slot pointer table、全 slot 先頭 4 byte = pBAV magic)= **支持**

`ram_A.bin` offset 0x134230(= VA 0x80134230):

| slot | VA | 値 | 指す先 先頭 4 byte |
|---|---|---|---|
| 0 | 0x80134230 | 0x8014ff7c | 70 42 41 56 = `pBAV` |
| 1 | 0x80134234 | 0x8014ef7c | `pBAV` |
| 2 | 0x80134238 | 0x8014cf7c | `pBAV` |
| 3 | 0x8013423c | 0x8014bf7c | `pBAV` |
| 4 | 0x80134240 | 0x8014af7c | `pBAV` |
| 5 | 0x80134244 | 0x80149f7c | `pBAV` |
| 6 | 0x80134248 | 0x80148f7c | `pBAV` |
| 7 | 0x8013424c | 0x80147f7c | `pBAV` |
| 8 | 0x80134250 | 0x8014677c | `pBAV` |
| 9 | 0x80134254 | 0x00000000 | — (終端) |

ram_B.bin も **全 slot bit 一致**。

**refute 試行(境界の検証 = ★引いた線自体を検証★)**:
- 上端: slot9 = 0、slot10 = 0x1010、slot11 = 0xe800 → pointer ではない。9 で打ち切りは実 bytes に支持される。
- 下端: 0x80134230 より下(0x80134218-0x8013422c)は ASCII 文字列 `SOUND\SS` / `SOUND\SL` / `SOUND\SB`(NUL padding 付き)。pointer slot ではない。→ table が下方に伸びている可能性は**否定**される。
- magic の byte 順: メモリ上の実 bytes は 70 42 41 56 = 'p','B','A','V'(claim の表記どおり)。

→ **支持**。副産物として `SOUND\` 文字列の隣接は音源 subsystem 帰属の独立傍証。

### 6.2 claim B(slot8 = 0x8014677c、0x80147358 はその +0xBDC)= **支持**

- slot8 = 0x8014677c ✅(§6.1)
- 0x80147358 − 0x8014677c = **0xBDC** ✅
- **独立裏付け**: wp log の bfc02b68 trap **全件**で v1 = `8014677c`(`wp_field_loader_4.log:22,124,133` / `wp_hp_1.log:22,33,77`)。register が VAB base を保持している。

### 6.3 claim C(ps=5、VH = 2592+512*ps = 0x1420、copy 長と一致)= **支持**(ただし「一致」の語は要精密化)

`ram_A.bin` VA 0x8014677c の 32 bytes:
```
70424156 07000000 00000000 c0ca0300 eeee0500 42003c00 7f400000 ffffffff
form=pBAV ver=7 id=0 fsize=0x3cac0 reserved0=0xeeee ps=5 ts=66 vs=60 mvol=127 pvol=64
```
- **ps = 5**(u16 @ base+0x12)✅ ram_B も同一
- VH size = 2592 + 512×5 = 5152 = **0x1420** ✅

**「wp log の copy 長と一致」への refute**: log の a2 は 0x843 / 0x43 であり、**0x1420 という値は log のどこにも現れない**。文字どおりの「一致」は**不成立**。

**正しい整合式**(§1.3 の watchpoint semantics 適用):
```
0x1420(総長) − 0xBDC(base から watch 点までの距離) − 1(watch 点の byte 自身) = 0x843
```
= battle 側 a2(`wp_field_loader_4.log:124` ほか)と **bit 一致**。

→ **支持**。ただし主張は「copy 長と一致」ではなく「**残長と bit 整合**」と書くべき。

### 6.4 claim D(32-byte record = psyq VagAtr)= **支持**、私の (4) 自己導出と**完全整合**

VagAtr 表の理論位置 = VabHdr(0x20) + ProgAtr[128](0x800) = base + 0x820 = **0x80146f9c**、
表末尾 = +512×ps = +0xA00 = **0x8014799c**。

→ **§4.3 で私が bytes だけから独立に測った extent(0x80146f9c .. 0x8014799c、80 record)と byte 単位で一致**。位相も一致(私が 4-byte 整列で自然と判断した VA ...9c 側が正しい framing)。

record 先頭 = VA ...9c で decode(ram_A):

| # | VA | prior | mode | vol | pan | center | shift | min | max | vibW..pbmax | rsv1 | rsv2 | adsr1 | adsr2 | prog | vag | reserved[4] |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0x80146f9c | 0 | 0 | 100 | 64 | 96 | 0 | 60 | 60 | 全 0 | 177 | 178 | 0x80ff | 0x5fde | 0 | 1 | 192,193,194,195 |
| 1 | 0x80146fbc | 0 | 0 | 110 | 64 | 97 | 0 | 61 | 61 | 全 0 | 177 | 178 | 0x80ff | 0x5fde | 0 | 2 | 192,193,194,195 |
| 16 | 0x8014719c | 0 | 0 | 127 | 64 | 100 | 0 | 60 | 60 | 全 0 | 177 | 178 | 0x80ff | 0x5fde | 1 | 17 | 192,193,194,195 |
| 32 | 0x8014739c | 0 | 0 | 95 | 64 | 99 | 0 | 60 | 60 | 全 0 | 177 | 178 | 0xacff | 0x5fc8 | 2 | 29 | 192,193,194,195 |
| 79 | 0x8014797c | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 全 0 | 177 | 178 | 0x80ff | 0x5fc0 | 4 | 0 | 192,193,194,195 |

整合点(claim D の 3 条件 + α):
- **prog field**: 16 record ごとに 0,1,2,3,4 = 私の (4) が測った「block 内不変・block 毎昇順の counter」そのもの。ps=5 と一致。
- **vag index 連番**: 私の (4) の「record 毎昇順 counter」。
- **reserved[4]** = 192,193,194,195 (0x00c0-0x00c3) = 私の (4) の「全 record 定数 tag」。→ doc §1 の「座標様 field」は **反証**(§4.4)、正体は VagAtr.reserved。
- 付随整合: pan = 64(psyq の center 値)、mode = 0、shift/vib/por/pb = 全 0、min == max で record 毎に 1 半音ずつ昇順(chromatic key-split)、adsr1/adsr2 が psyq 典型値域。
- **ProgAtr 側の独立確認**: base+0x20 の ProgAtr[0..4].tones = 16,16,16,16,**2**、ProgAtr[5..] = 0、mvol=127、mpan=64 → プログラム数 5 で ps=5 と一致。record #79(prog=4 の 16 番目)が全 0 なのは prog4 の tones=2 と整合。
- **VAG offset table**(base+0x820+512×5 = 0x8014799c 以降、u16×256): 先頭から 60 個が非零、以降 0。**vs = 60 と一致**。→ §4.3 の「tag が 0x8014799c で切れる」観測とも整合。

→ **支持**。私の (4) 自己導出との**矛盾は 1 件も無い**。(4) は型を保留していたので、claim D は保留を埋める形で整合。

### 6.5 claim E(0x800cf1a0 を含む関数の呼び先 chain = psyq SPU ライブラリ系)= **分割判定**

**到達性 = 支持(観測)**:
- 0x800cf1a0 を含む関数の entry を ram_A 上で後方走査 → **0x800cf0e4**(`addiu sp,sp,-0x68`; `sw ra,0x1c(sp)`)
- `memdump_1.log:53` に `0x800cf1b8: jal 0x800db83c` が **log 直読で実在**
- ram_A の静的 BFS(entry 0x800cf0e4、direct jal のみ、depth ≤ 6、到達 62 関数)で **0x800db83c / 0x800db8c4 / 0x800dbcd8 いずれも到達** ✅

**「psyq SPU ライブラリ系」という同定 = 判定不能**:
- 到達 62 関数のいずれにも `lui reg,0x1f80`(SPU/IO MMIO page への参照)が **無い**。
- ただし ★不在は否定でない★: (a) RAM 全域 0x80010000-0x80160000 には同 pattern が **281 site** 存在する、(b) 私の BFS は **jalr(間接呼び出し)8 site を追跡していない** = 構造的に不完全、(c) symbol が無いので関数名同定の手段が無い。
- よって「SPU lib ではない」とは**言えず**、「SPU lib である」とも**言えない**。
- 周辺証拠(pBAV magic / VagAtr / `SOUND\SS`・`SOUND\SL`・`SOUND\SB` 文字列 / A(2Ah) memcpy による VH 転送)は「**音源 subsystem 帰属**」を強く支持する。SPU lib への同定はこれとは別の主張であり、未達。

→ **到達性 = 支持 / ライブラリ同定 = 判定不能**。

---

## §7 私独自の読み: field / battle bank 張り替え【推論】

★以下は【推論】。観測部分と分けて記載する。★

**観測**:
- field 側 copy(ra=0x800cf1a8)の残長 0x43 → 終端 = 0x80147358 + 1 + 0x43 = **0x8014739c**
- 0x8014739c − 0x8014677c(slot8 base)= **0xC20** = 2592 + 512×**1**
- battle 側 copy(ra=0x80108960)の残長 0x843 → 総長 0x1420 = 2592 + 512×**5**(§6.3 で検算済)
- ram_A / ram_B(いずれも 16:0x = battle HP hunt 中の採取)の VabHdr は **ps=5** = battle 側 bank
- memdump(15:4x = field 側 copy の後)では 0x80147359..0x8014739d が zero、ram_B では同領域に record(vag 0x1b / 0x1c)が生存

**推論**:
1. slot8(0x8014677c)は **field 用 VAB(ps=1、VH 0xC20)と battle 用 VAB(ps=5、VH 0x1420)を張り替える共通 slot**。2 種の ra(0x800cf1a8 / 0x80108960)は 2 つの呼び出し文脈に対応。
2. doc §1 の「先頭 0x44 byte ゼロ」= ps=1 bank の **VAG offset table 末尾の未使用分**(vs 個までしか埋まらない、§6.4 で ps=5 側の同構造を確認済)。array header ではない。
3. battle 終了時の len=0x43 + ra=0x80108960 の copy は field bank(ps=1)への復帰張り替え。

**未検証(promote 禁止)**:
- **dst 開始 address は log から導出不能**(§1.3)。「0x8014677c から始まる」は「終端 − VH size」による逆算であり、直接観測ではない。確定には copy 開始時点(または dst 開始の書込み)の追加計測が要る。
- ps=1 の VAB header 実体(field bank)は 3 dump のいずれにも残っていない(全て ps=5 状態)。ps=1 は算術からの逆算のみ。
- 「field 用 / battle 用」という用途 label は文脈(遷移時 / 戦闘突入時)からの帰属であり、bank の内容検証はしていない。

---

## §8 doc への訂正提案(まとめ)

| doc 箇所 | 現記述 | 訂正 |
|---|---|---|
| §1 見出し | 「field NPC loader = 静的 RE unblock 達成」 | **VAB(音源 bank)VH loader**。NPC loader ではない |
| §1 | 「watchpoint 0x80147358(entity array)」 | 0x80147358 = VAB slot8(0x8014677c)+0xBDC。entity array ではない |
| §1 | 「entity array live 実体 dump」 | psyq **VagAtr 表**(32B/record、16 record/program、ps=5 で 80 record) |
| §1 | 「id 連番 0x1d..0x2a」 | VagAtr.vag index。当該 block は 0x1d..0x2c(window 打ち切りによる過小) |
| §1 | 「`00c0..00c3` 座標様 field」 | VagAtr.**reserved[4]**(全 record 定数)。座標ではない |
| §1 | 「先頭 0x44 byte ゼロ」 | array header ではなく VAG offset table の未使用零。実測 zero run は 0x46(memdump)/ 0x45(ram_A) |
| §1 | 「memcpy wrapper、BIOS A0 系と**推論**」 | **観測へ promote 可**(0x80091450 = A0 trampoline、t1=0x2A = memcpy) |
| §2 | 「2 call(sp 0x30 差 = 別 frame 連続)」 | **1 call**。pc=0x80056cac は BP 非設置 address = call entry ではない。sp 差 0x30 = prologue `addiu sp,sp,-0x30` |
| §2 | 「戦闘突入 +5〜6 秒」 | 時間関係は保存(3 例とも 6s)。基準点の呼称は「battle 音源 bank 切替時刻」へ |
| §5 | worker1 dispatch 前提 | entity record 型 RE は前提不成立(boss1 にて再 scope 済) |

---

## §9 検証の限界(honest gap)

1. memdump(15:4x)/ wp log(15:40-15:42)/ ram_A・ram_B(16:0x)は **別時刻**。3 者を同一 state として結合してはならない。
2. `===STAGING===` 節は copy の src oracle として使えない(§2.4)。
3. dump 採取時の map は未知。指示どおり NPC 表との join は一切していない(§6 で VAB 帰属が確定したため join 自体が無意味になった)。
4. claim E の chain 解析は direct jal のみ。jalr 8 site 未追跡 = 構造的に不完全。
5. btl_rel.bin の caller 単一性は同 overlay 内のみ。main EXE / 他 overlay / jalr は未走査。
6. §7 は推論。dst 開始 address の直接観測が無い。
7. 本検証は log と binary の直読のみ。実機再現(user 操作)は行っていない。

---

## 付録: 再現手順

検証 script は `/tmp/claude-1000/.../scratchpad/` の chk3.py / chk24.py / chk4b-e.py / chk6.py / chkD.py / chkE*.py(session scratch、非永続)。要点は本 doc の表に全て転記済。再現には以下があれば足りる:

```python
# 例: claim A/B/C の再現
import struct
A=open("runtime_capture_2026-07-25/ram_A.bin","rb").read()
w=lambda va: struct.unpack_from("<I",A,va-0x80000000)[0]
u16=lambda va: struct.unpack_from("<H",A,va-0x80000000)[0]
for i in range(10):
    p=w(0x80134230+4*i); print(i,hex(p), A[p-0x80000000:p-0x80000000+4] if p else b"")
print("ps=",u16(0x8014677c+0x12), "VH=",hex(2592+512*u16(0x8014677c+0x12)))
print("resid=",hex(2592+512*u16(0x8014677c+0x12)-(0x80147358-0x8014677c)-1))  # -> 0x843
```

```python
# 例: (5) の prologue 直読
b=open("/home/ken/Desktop/Digimon/degimon_world_remake/extracted/btl_rel.bin","rb").read()
print(hex(struct.unpack_from("<I",b,0x41C8)[0]))  # 0x27bdffd0 = addiu sp,sp,-0x30
print(hex(struct.unpack_from("<I",b,0x9FCC)[0]))  # 0x0c015b2a = jal 0x80056ca8
```
