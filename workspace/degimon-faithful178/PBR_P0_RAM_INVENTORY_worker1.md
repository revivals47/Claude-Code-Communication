# PBR Phase 0 — RAM oracle infra + 素材全数 inventory (worker1, 2026-08-08)

**dispatch**: placement re-baseline Phase 0 / ★oracle 再測定のみ、実装着手なし★
**worktree**: `~/Desktop/Digimon/degimon_world_remake-pbr` (branch `track1/placement-rebaseline`)
**触ったもの**: `workspace/tools/savestate_ram.py`(修正) / `workspace/tools/map_index_table.py`(新規) / `workspace/tools/entity_dump.py`(新規)。
★Unity コードは 1 byte も触っていない★。RAM 素材はすべて read-only で開いた。

claim 規律: 【観測】= bytes 直読 / disasm 直読 / 実行結果、【推論】= 未裏取り。

---

## 0. 結論(先出し)

1. **tool 修正完了**。`savestate_ram.py` は RAM image 起点(prefix)を ★実測★ するようになった。savestate = `0x1A62` / 生 2MB dump = `0`。同一 API で両方読める。回帰は §1.2 に実測で列挙(class-A の gp 相対値は **bit 一致**)。
2. ★**map 自己同定の手段を確立**★ — 伝聞に頼らず、どの素材がどの map かを bytes/disasm で決められるようになった(§2)。
   - `0x8013541C` の table は gating table であると同時に ★**map 名 table**★(各 16B record の `+0x00..+0x09` が ASCII map 名。★idx 0..254 の 255 slot = 名前あり 244 / 空 11★ — §2.1 訂正参照)
   - 現在 map index = ★`gp-0x6ca6` = VA `0x8013E166`(halfword)★。loader へ渡る `a1` の出所そのもの
   - **`0x801693B6`(persistent scene-id)は map index ではない**。多数の素材で不一致 → ★map 同定に使ってはいけない★
3. **素材は 28 件すべて実在・全数 inventory 済**(§3)。★ただし map 同定は 24/28。残 4 file(3 素材系統)は entity array が全 0 = ★MAYO01 ではない★(§2.5)★。★7/23 triage の `_9/_1/_2/_10` は実在し、自己同定でも `mapIdx=204 = TWNA01`★。「所在不明」は flatpak sandbox path の見落としで、**撤回**(§5)。
4. ★**entity 配列の容量 = 8 record**★(clear ルーチン `0x800BB994` の loop 上限 `slti $at,$s0,8`)【観測 = disasm】。
   → boss1 §2.3 の「idx 8 以降が非構造化」は stale 残骸ではなく ★単に配列外★。
   → loader 側に clamp は無い(loop 条件は stream 先頭 halfword のみ)= `count > 8` なら配列外へ溢れ書きする構造。
5. ★**clear は `type(+0x00)` を 0xFFFF にするが `pos/ry/ai` は書かない**★【観測 = disasm、store 全列挙】。
   → `type=0xFFFF` の record に載っている pos/ry/ai は ★前 map load の残骸★。**pos だけを見る oracle は map 境界を越えて誤読する**。
   → 一方、`clear → loader` は 1 本道(§4.3)なので、**非 0xFFFF の record は今回 load で書かれたもの**。
6. entity 数は断定しない(boss1 指示)。RAM 側の観測は「**非 0xFFFF だった record 数**」のみ。★8/8 に飽和した素材が 4 系統あり、そこでは 8 は下限であって entity 数ではない★(§3 表)。飽和していないのは TWNA01=7 / MAYO00=5 / ROOM08=4 / FRZL17=2 / GIAS06B=2 / MGEN98=1。

---

## 1. savestate_ram.py の prefix 実測化

### 1.1 何をどう直したか

旧実装は「decompress した frame の offset 0 == VA `0x80000000`」と仮定していた。実際の RAM image は frame の `0x1A62` から始まる(`SAVESTATE_TOOL_IMPACT_AUDIT.md` ce5908b §1)。

新実装は起点を **2 経路で実測**し、切り出した 2MB を返す:

| 経路 | 方法 | 期待 |
|---|---|---|
| P1 `exe-sig` | `extracted/slps_017_97.bin` の先頭 `0x400` B を frame 内検索 → `off - 0x90800` | 主経路 |
| P2 `anchor-sig` | `ANCHOR`(= gp-0x6cf8)を検索 → `off - 0x13E114` | EXE が無い時の予備 |

両者が食い違えば stderr に警告を出す(= ★道具自身の self-check★)。実測 28 件すべてで **P1 = P2**、警告ゼロ。

さらに `--selftest` を追加した。権威測定の前に既知不変量だけで検算する:

```
$ python3 workspace/tools/savestate_ram.py --selftest <file>
  [selftest] EXE image head 0x1000 一致: OK
  [selftest] ANCHOR VA = 0x8013e114 (期待 0x8013e114): OK
```

生 2MB dump(`ram_*.bin`)は同一 API で `prefix=0` として読める(自動判別)。

### 1.2 ★回帰確認(実測)★

`SLPS-01797_9.sav`(TWNA01)で新旧 tool を突き合わせた実測結果。

**(A) class-A = gp 相対 read** — 旧 tool でも bytes は正しかった系統。★全 5 項目 bit 一致★:

| 項目 | 新 | 旧 | 判定 |
|---|---|---|---|
| scenario (gp-0x6cd6) | 0x95 | 0x95 | **SAME** |
| ★旧ラベル "story"★ (gp-0x6d90) | 0xdacc | 0xdacc | **SAME**(bytes は同じ。★ただしラベルが誤り★ — §2.4)|
| dialoguePC (gp-0x6cc8) | 0x80162134 | 0x80162134 | **SAME** |
| scriptBase (gp-0x6ccc) | 0x80161784 | 0x80161784 | **SAME** |
| eventBankPtr (gp-0x6cec) | 0x80163784 | 0x80163784 | **SAME** |

`slot3_day12.sav.bak` でも同様に 5/5 SAME(scenario=0x93 / gp-0x6d90 u16=0xdaac / PC=0x80162eb3 / sbase=0x80161784 / bank=0x80163784)。

★重要な限定(2026-08-08 追記)★: この "SAME" が assert しているのは ★新旧 tool が同じ address の同じ bytes を読んでいる★
ことだけで、★ラベルの正しさは一切 assert していない★。実際 `gp-0x6d90` の "story" ラベルは ★誤り★だった(§2.4)。

**(B) ★明示的に変わるもの★**(静かに壊さないための列挙):

| 変わるもの | 旧 | 新 |
|---|---|---|
| 印字される gp ラベル | `0x8014686E` | ★`0x80144E0C`★ |
| ANCHOR の VA ラベル | (印字なし / frame offset ベース) | `0x8013E114` |
| **真 VA を渡したときの bytes** | 6754 B ずれた別物 | ★正しい bytes★ |

**(C) 主要 anchor 12 件**(audit §3-A)— *address claim の grounding は不変*。変わるのは「tool に真 VA を渡したときに返る bytes」だけで、それは旧が誤り・新が正。新 tool の read が構造的に妥当であることを bytes で示す:

| address | 名称 | 新 tool の read(先頭 16B、`_9.sav`)| 旧 tool の同 VA read | 妥当性の根拠 |
|---|---|---|---|---|
| `0x8013CDB4` | actor ptr table | `48 b0 16 80 84 b0 16 80 00 00 00 00 ...` | `83 8a 83 82 83 93 ...`(Shift-JIS 文字列) | ★`0x8016B048` / `0x8016B084` = player struct / CareForm slot1 の pointer が並ぶ★ = 別経路 RE と一致 |
| `0x8013E03A` | battle frame counter | `00 00 ...`(戦闘外) | `00 00 00 00 1c 00 ...` | 戦闘外なので 0。判定材料としては弱い(honest) |
| `0x8013E120` | eventBank ptr var | `84 37 16 80 20 3a 16 80 ...` | `ff ff ff ff ...` | ANCHOR 5 連ポインタの末尾 2 個と一致 |
| `0x80145608` | field entity 配列 | `75 00 00 00 0a 00 ...` | `00 00 00 00 ...` | `type=0x75=117` = §3 の TWNA01 idx0 と一致 |
| `0x8014677C` | VAB slot8 VH buffer | `70 42 41 56 07 00 00 00 ...` | `08 38 ff 04 ...` | ★`70 42 41 56` = `"pBAV"` = **VAB header magic "VABp" の LE**★。buffer 同定が bytes で立つ |
| `0x80161784` | scriptBase / DG.SCN dest | `34 00 fe 00 34 00 36 00 ...` | `00 00 ... 5c 53 43 4e 5c 4d`(`\SCN\M`) | dialoguePC(`0x80162134`)が同帯を指す |
| `0x80163784` | event bank | `3a 3b 3c 3d 3e 3f 00 00 ...` | `0d 00 81 75 ...`(Shift-JIS) | eventBankPtr の値 `0x80163784` と一致 |
| `0x801640A4` | 0x46/0x79 registry | `ff ff ff ff ...` | `82 b7 82 ac ...`(Shift-JIS) | 未登録 = clear 値 |
| `0x801693B6` | persistent scene-id | `cc 00 09 00 ...` → byte `0xcc`=204 | `00 00 ...` | §2.3 参照(map index ではない) |
| `0x8016B048` | player struct | `00 00 00 00 c4 60 1b 80 ...` | `00 00 ...` | actor ptr table `0x8013CDB4` の指す先と一致 |
| `0x8016B084` | CareForm slot1 | `03 00 00 00 a8 bf 19 80 ...` | `00 00 ...` | 同上 |
| `0x80147358` | ★旧 entity anchor(誤)★ | `00 00 ...` | `00 00 00 00 00 00 99 ff ...` | 旧 tool の同 VA read と、新 tool の `VA-0x1A62` read が **bit 一致** = audit の class-C 判定(frame offset を VA と誤称)を追認 |

★★ 旧 tool の「`VA-0x1A62` を渡した read」が新 tool の真 VA read と一致したのは 12 件中 `0x80147358` の **1 件のみ** ★★ — 「旧 doc に残る `0x80147358` 系の数値だけが frame offset 起源」という audit の結論と整合する【観測】。

独立な裏取り 2 件:
- `0x8014677C` の新 read が ★VAB magic `"VABp"`★ を返した(旧 read は返さない)
- 旧 tool の同 VA read は複数の anchor で **Shift-JIS の会話文** を返している = 明らかに別領域を掴んでいた

★静かに壊さないための注意★: 過去 doc / log に残る「savestate から真 VA を渡して読んだ bytes」は **新 tool では別の値になる**。これは新が正、旧が誤。gp 相対経路で得た値(上表 A)は変わらない。

---

## 2. ★map 自己同定の方法(本 Phase の再利用可能な成果)★

### 2.1 map 名 table = gating table

loader `0x800BAE54` の gating 判定:

```
800BAE88  sll  $v1, $v0, 4          ; mapIdx * 16
800BAE8C  lui  $v0, 0x8013
800BAE90  addiu $v0, $v0, 0x541c    ; 0x8013541C
800BAE94  addu $v0, $v0, $v1
800BAE98  lb   $v0, 0xc($v0)        ; byte12
800BAEA0  andi $v0, $v0, 0x80
800BAEA4  beqz $v0, 0x800bb500      ; loop 全 skip
```

この table の record を bytes で開くと、先頭 10 B が **ASCII map 名**だった【観測】:

```
idx   0  8013541c  4d 41 59 4f 30 31 00 00 00 00 | 03 00 80 00 | 01 00   "MAYO01"
idx 172  80135edc  54 57 4e 41 30 36 00 00 00 00 | 02 02 8c 00 | 09 2b   "TWNA06"
idx 204  801360dc  54 57 4e 41 30 31 00 00 00 00 | 02 02 8c 00 | 09 2b   "TWNA01"
```

- ★entry 数 = idx 0..254 の 255 slot(名前あり 244 / 全 0 の穴 11)★

  ★★訂正(2026-08-08、boss1 査読 + PRESIDENT 指摘)★★: 本 doc の初版は ★239★ と書いていた。
  これは tool が「最初の空 entry で走査を打ち切った」ためで ★誤り★。実際には
  ★空 entry の後ろに実 entry がある★:

  | idx | 内容 |
  |---|---|
  | 239-246 | 空(8 件) |
  | ★247 MGEN06 / 248 MGEN07 / 249 MGEN08★ | b12=`0xD1` = ★gating ON★ |
  | 250-252 | 空(3 件) |
  | ★253 MGEN09 / 254 MGEN10★ | b12=`0xD1` = ★gating ON★ |

  これは memory `feedback_absence_in_truncated_list` そのもの(打ち切られた list の不在を否定に使った)。
  ★連続性(0..238 に穴が無いこと)は「範囲内に穴が無い」しか言わず「範囲が全体である」とは言わない★。

  ### ★終端をどう決めたか(根拠の種類 = 「後続シンボル」。形状判断ではない)★

  EXE 全体の `lui+addiu` 由来の絶対 address を全数抽出し、`0x8013541C` の直後に来る
  ★独立に参照される address★ を求めた【観測 = disasm 全数走査】:

  ```
  0x8013640C   (= 0x8013541C + 0xFF0 = 16 * 255)   site 0x800E4CB8
  ```

  さらに `0x8013640C` は `sll $v1,$v0,3` = ★stride 8★ で index される **別構造**
  (`0x800E4CB0`〜`0x800E4CC0`)。∴ map table は `[0x8013541C, 0x8013640C)` に収まり、
  ★idx 0..254 の 255 slot★。

  ### ★不採用にした根拠(記録。同じ穴に落ちないため)★

  | 却下した根拠 | 理由 |
  |---|---|
  | 空 entry で打ち切る | ★今回の誤りそのもの★。空の後ろに実 entry があった |
  | 「idx 255 は map record の体を成さないから終端」 | ★形状判断★。空を終端と誤読したのと同型。証拠にならない |
  | 「map index は byte だから 256 で切れる」 | ★不成立★。loader へ渡る index は `0x800EC47C lhu -0x6ca6($gp)` = ★halfword★、loader `0x800BAE54` 側も `lh $v0,0x24($sp)` → `sll 4` で ★mask も clamp もしない★。byte で読む site(`0x800AF2A8 lbu -0x6d90($gp)`)は **別変数** |

  ### ★index の型幅 — 22 site 全数の実測(boss1 依頼の (2) の cross-check)★【観測 = disasm】

  `0x8013541C` を組み立てる site を EXE 全走査で ★22 件★抽出し、各 site が index をどの命令で得ているかを調べた:

  | index の入手経路 | 件数 | 例 |
  |---|---|---|
  | `lbu` (unsigned byte) | ★7★ | `0x800AF2A8` / `0x800DF398` / `0x800E07D0` / `0x800EA72C` = `-0x6d90($gp)`、`0x8010E058` 他 3 = `0x801693B6` |
  | ★`lh` (signed halfword)★ | ★3★ | ★`0x800BAE80`(= loader 本体、a1 を stack から読み直す)★ / `0x800E0194` / `0x800E425C` |
  | 関数引数 `move $sX, $a0` | 3 | `0x800DF7E4`(map load 関数)他 |
  | 上記 `s0` の再利用(同一関数内) | 9 | `0x800DF878`〜`0x800DFA54` |

  ★worker3 の「調べた全 site が lbu / lh・lhu の site はゼロ」とは食い違う★。
  ★loader 本体 `0x800BAE90` の site は `lh` である★(`0x800BAE68 sw a1,0x24(sp)` → `0x800BAE80 lh v0,0x24(sp)`)。
  さらに loader へ届く値の出所 `0x800EC47C` は ★`lhu`★。

  ∴ ★「index が byte だから table は 256 slot」は成立しない★。byte で読む site は
  `-0x6d90`(現在 map)と `0x801693B6`(永続 map)という ★別変数★で、それらの定義域が 0..255 なのは事実だが、
  ★loader 経路は halfword★なので table 長の根拠にはならない。

  ### ★終端の書き方(形状で引かないための両論)★

  - ★確定している上限★: 後続の独立参照シンボル `0x8013640C` により `[0x8013541C, 0x8013640C)` = ★16 × 255★
  - ★実効 entry★: idx 0..254 に実データ(名前あり 244 / 空 11)。★idx 254 = MGEN10 まで詰まっている★
  - ★未確定★: 「論理長が 255 なのか、それ以外か」は ★決められていない★。
    確定しているのは ★物理 extent だけ★ — `0x8013640C` が別 table(stride 8)の base である以上、
    map record 用の領域は ★255 entry 分ちょうど(余り 0)★。
  - ★「構造的に 256 slot」という表現は撤回★。その根拠だった「index が byte」は §2.2 の実測で
    ★不成立★(loader 経路は halfword)。
  - ★形状(「idx 255 は record に見えない」)は終端の根拠に使っていない★
  - ★もし byte 経路が 255 を渡せば `0x8013640C` の別 table を map record として読むことになる★が、
    原盤にそのような入力があるかは ★未確認★

  ### ★name は primary key ではない(PRESIDENT 裁定、実測で追認)★

  ★同 name `YAKA25` が 2 entry 存在する★【観測】:

  | idx | numImg(+0x0A) | numObj | flags(+0x0C) | gating |
  |---|---|---|---|---|
  | 65 | ★0★ | 0 | 0x44 | OFF |
  | 232 | ★2★ | 0 | 0xC4 | ★ON★ |

  → 名前あり ★244★ / distinct name ★243★。numImg は `.map` header の elements section slot 位置を
  決めるので ★同じ .map から読める placement が変わる★ = ★name が同じでも map としては別物★。
  ★正は idx 232★【観測 = worker1 が生 `.map` で再現】: idx232 解釈で `elements_off=0x2057C` /
  `count=0` / block 長 `0x7A`(= `0x78` header + 2B count)= ★gap 0 で自己整合★。
  idx65 解釈は `count=7636 / 4364` で ★範囲外★。∴ idx65 の metadata は stale。

  ★残る未確定★: 「table 全体を走査する loop bound を持つ code」は ★見つけられていない★。
  後続シンボルによる上限は物理的な上限であって「255 が意図された論理長」の証明ではない。
  ただし idx 254 まで実 entry(MGEN10)が詰まっているので、少なくとも ★255 未満で切ることはできない★。
- `byte12 & 0x80` が 0 の map = ★21 件★:
  `MAYO10(8) / YAKA01(50) / YAKA11B(53) / YAKA12(54) / YAKA15(57) / YAKA18(60) / YAKA21(61) / YAKA22(62) / YAKA23(63) / YAKA24(64) / YAKA25(65) / KODA05(84) / FRZL05(92) / TUNN07_2(122) / TUNN08_2(124) / TUNN03_2(126) / OGRE04(130) / FACT05(156) / MGEN14(229) / MGEN15(230) / MGEN16(231)`
  → ★worker3 の (b) gating 軸の母集団はこれ(★名前あり 244 中 21★、gating ON 223)★。全数出力は `PBR_P0_map_index_table.tsv`(本 commit 同梱、`workspace/tools/map_index_table.py --tsv` で再生成可)

`extracted/maps/` との突き合わせ【観測、★255 slot 版で取り直し★】。★検算が閉じる★:

```
名前あり 244 − 重複 1(YAKA25) = distinct 243
distinct 243 − (table にあるが dir 無し 2) + (dir はあるが table 無し 1) = ★242 = extracted dir 数★ ✓
```

- table にあるが dir 無し: ★`YAKA01(idx50, OFF, numImg=0)` / `YAKA21(idx61, OFF, numImg=0)`★
- `extracted/maps/` にあるが table に無い: ★`mgen17` の 1 件のみ★
- ★仮説(未検証)★: `YAKA01` / `YAKA21` / `YAKA25(idx65)` は ★3 件とも gate OFF かつ numImg=0★。
  「OFF かつ numImg=0」が stale/placeholder slot の signature かもしれない。★断定しない★
- ★訂正★: 初版は `mgen06..mgen10` も「table 不在」と書いていたが ★誤り★。
  ★MGEN06-10 は idx 247-249 / 253-254 に実在し、いずれも gating ON★(打ち切り走査の巻き添え)

### 2.2 現在 map index の在処

```
800EC47C  lhu  $a0, -0x6ca6($gp)     ; ★= VA 0x8013E166★
800EC480  jal  0x800df7d0            ; map load (a0 = map index)
```

`0x800DF7D0` は `a0` を `s0` に置き、そのまま `0x8013541C + s0*16` の gating 参照にも `0x800AC588` の `a1` にも使う。`0x800AC588` はそれを `[sp+0x2c]` に積み、`0x800AC760` で `lh $a1,0x2c($sp)` → `0x800AC764 jal 0x800BAE54`。
∴ ★`0x8013E166` の値 = loader に渡る map index そのもの★【観測 = disasm、途中に別代入なし】。

`gp-0x6ca6` への **write は 1 箇所のみ**(`0x800EC44C` で `addiu $a1,$gp,-0x6ca6` としてアドレスを `0x800F0D10` に渡す = scenario/map の組で書き込む経路)。他の 20+ 参照はすべて `lhu` = read【観測 = disasm 全数 grep】。

### 2.3 ★訂正: `0x801693B6` も map index だった(別変数)★

★初版は「`0x801693B6` は map index ではない。map 同定に使ってはいけない」と書いた。半分誤り★。

正しくは ★3 つの別変数がいずれも map index を保持している★【観測 = disasm】:

| 変数 | VA | 幅 | 役割 | table を引く site |
|---|---|---|---|---|
| `gp-0x6ca6` | `0x8013E166` | ★u16★ | ★要求 map index★(map load 関数 `0x800DF7D0` の引数、`0x800EC47C lhu`) | (loader へ a1 として届く) |
| `gp-0x6d90` | `0x8013E07C` | ★u8★ | ★現在 map index★(load 完了時に `0x800DFAFC` が `andi s0,0xff; sb` で確定) | `0x800AF2A8` / `0x800DF398` / `0x800E07D0` / `0x800EA72C` |
| `0x801693B6` | — | ★u8★ | ★永続側の map index★(save data 帯) | `0x8010E068` / `0x8010EE0C` / `0x8010FC88`(`lui at,0x8017; lbu -0x6c4a(at)` = `0x801693B6`) |

3 者が食い違うのは ★別の意味の map index だから★であって、どれかが map index でないからではない。
★placement 検証で使うべきは `gp-0x6ca6`(loader に実際に届く値)★。本 doc の全 inventory はこれで同定している。

### 2.4 ★`savestate_ram.py` の "story" ラベルは誤りだった(汚染範囲つき)★

旧実装: `story = u16(ram, gp-0x6d90)`。★2 重に誤り★【観測 = disasm】:

1. ★型が違う★ — この変数は byte。writer 3 site はすべて `sb`
   (`0x800DF2A0` = 定数 0xCC 書込み / `0x800DFAFC` = map load 内 / `0x80111DF0` = story cascade)。
   u16 で読むと ★隣の別変数 `gp-0x6d8f` を巻き込む★
2. ★意味が違う★ — 中身は story 進度ではなく ★map index★。
   `0x800DFAFC` は map load 関数 `0x800DF7D0` の中で `andi v0,s0,0xff; sb v0,-0x6d90(gp)`(s0 = load した map index)。
   4 site が `lbu` → `sll 4` → `0x8013541C + v*16` で ★map table を引いている★

★「story-state」という既存ラベルの出所も説明がつく★: `0x80111DF0` は story-flag cascade `0x800E4A08` の
戻り値を同じ byte に書く。∴ ★cascade は「story から行き先 map を選ぶ」もの★で、変数の型自体は map index。
`docs/EVENT_MODEL_consolidated_2026-06-16.md` の「default 0xcc=204」も、★0xCC = 204 = TWNA01 の map index★
と読むと一貫する。

★汚染範囲(grep 実施)★:
- `workspace/tools/savestate_ram.py` の印字ラベル → ★本 commit で修正★
  (`mapIdx_req(gp-0x6ca6,u16)` / `mapIdx_cur(gp-0x6d90,u8)` と明示)
- 本 doc の §1.2 回帰表 / 付録 28 件の dump ヘッダ → ★本 commit で修正★
- `docs/PHASE2_storystate_reader_enumeration_2026-07-04.md` / `docs/EVENT_MODEL_consolidated_2026-06-16.md` /
  `docs/FOUNDATION_CORRECTION_event_system_2026-06-16.md` / `docs/PHASE2_driver_design_prep_2026-07-04.md` /
  `docs/KEYSTONE_*` / `workspace/MASTER_TASKS.md` が `-0x6d90` を「story-state / current-event-id」と記述
  → ★本 dispatch の scope 外。値は正しく読めているのでラベル問題だが、`-0x6d90` を story 進度そのものとして
  扱った推論があれば再点検が要る★。別 issue として上申する

### 2.5 ★訂正: 3 素材は「MAYO01」ではない(entity load 未実行)★

初版は `SLPS-01797_6.sav` / `_6.bak` / `canon_baselineC.sav` / `canon_care_seed_point.sav`(★4 file / 3 素材系統★)を
`mapIdx 0 = MAYO01` と同定した。★これは誤り★。

#### 【観測】entity array が ★全 0★

| file | array 全 0 | `gp-0x6ca6`(要求) | `gp-0x6d90`(現在) |
|---|---|---|---|
| `SLPS-01797_6.sav` / `_6.bak` | ★はい★ | 0 | 0 |
| `canon_baselineC.sav` | ★はい★ | 0 | 0 |
| `canon_care_seed_point.sav` | ★はい★ | 0 | ★204★ |

★全 0 は clear の `0xFFFF` ですらない★ = ★clear ルーチンも loader も一度も走っていない★。

#### 【既確定事実からの推論】= MAYO01 ではない

新しい仮定は入れていない。前提はすべて既確定:

1. `idx 0 = MAYO01` / `b12 = 0x80` / ★gate ON★【観測 = EXE table 直読】
2. `mayo01.json` の `digimon` = ★8 件★【観測 = worker1 実測】
3. gate ON なら loader は loop を回して populate する【観測 = disasm】

∴ ★通常プレイで MAYO01 に居る savestate なら array は 8 record 埋まっているはず★。
全 0 はそれと ★両立しない★。

→ ★結論(推論): これらは MAYO01 ではなく、entity load 未実行の状態(boot / new game / 遷移途中のいずれか)★。
→ ★`6ca6 = 0` は「MAYO01」ではなく「未設定」と読むのが整合的★。
  (`canon_care_seed_point` は `6d90 = 204` を持つが、「`6ca6` 未設定・`6d90` が前 map を保持」は ★推論★。断定しない)

#### ★反証条件★

★MAYO01 在住が独立に確認できる素材で、かつ array が全 0 のものが 1 件でも出れば本推論は棄却★。

#### 教訓

★N 択を出すときは必ず「どれでもない」を含める★(memory `feedback_hypothesis_space_openness` の実運用形)。
今回は 3 択目に「どちらとも一致しない → 素材を oracle から外す」が用意されていたため、
★2 択なら「どちらかに寄せた」答えが出ていたところを、素材の欠陥(array 全 0)として検出できた★。

---

## 3. RAM 素材 全数 inventory

対象 28 件。すべて新 tool で読め、self-check(EXE head 一致 / ANCHOR VA 一致)は 28/28 OK。

★map 同定は 24/28★。残 4 file(`SLPS-01797_6.sav` / `_6.bak` / `canon_baselineC.sav` / `canon_care_seed_point.sav`
= 3 素材系統)は ★entity array が全 0★ で、表の「MAYO01」は ★誤り。§2.5 参照★。

★注意★: 「非0xFFFF数」列が **8 = cap 飽和**の素材は、8 が entity 数ではなく ★下限★ である(打ち切られた list の飽和)。

#### flatpak savestates (DuckStation 実体)

| file | mtime | size | prefix | mapIdx | map 名 | gating byte12 | 非0xFFFF数/8 | sha256(先頭16) |
|---|---|---|---|---|---|---|---|---|
| `SLPS-01797_1.sav` | 2026-06-17 00:44 | 1821579 | 0x1a62 | 204 | **TWNA01** | 0x8c ON | 7 | `1b3ce9b2b292c9f1` |
| `SLPS-01797_1.bak` | 2026-06-16 03:05 | 1822121 | 0x1a62 | 204 | **TWNA01** | 0x8c ON | 7 | `89f5c2a8b66d29dd` |
| `SLPS-01797_2.sav` | 2026-06-16 03:08 | 1823082 | 0x1a62 | 204 | **TWNA01** | 0x8c ON | 7 | `5806a23ca8dc6df6` |
| `SLPS-01797_9.sav` | 2026-06-17 00:59 | 1807302 | 0x1a62 | 204 | **TWNA01** | 0x8c ON | 7 | `2428aaeabf4e8322` |
| `SLPS-01797_10.sav` | 2026-06-17 02:31 | 1821670 | 0x1a62 | 204 | **TWNA01** | 0x8c ON | 7 | `986f3a63b959a3d4` |
| `SLPS-01797_10.bak` | 2026-06-17 02:19 | 1820815 | 0x1a62 | 204 | **TWNA01** | 0x8c ON | 7 | `c2a889ad3e8dbbf1` |
| `SLPS-01797_3.sav` | 2026-07-17 05:14 | 1984244 | 0x1a62 | 179 | **TWNA13** | 0x8c ON | 8★飽和★ | `98b5f52cb3d7b571` |
| `SLPS-01797_3.bak` | 2026-07-17 05:00 | 1988879 | 0x1a62 | 179 | **TWNA13** | 0x8c ON | 8★飽和★ | `67e046ed9afe32ba` |
| `SLPS-01797_resume.sav` | 2026-06-23 04:42 | 1945912 | 0x1a62 | 179 | **TWNA13** | 0x8c ON | 8★飽和★ | `68b23c59beb171b6` |
| `SLPS-01797_4.sav` | 2026-06-18 04:34 | 1727844 | 0x1a62 | 136 | **FRZL17** | 0xcf ON | 2 | `1c6bd5a196a05d64` |
| `SLPS-01797_4.bak` | 2026-06-18 04:14 | 1911557 | 0x1a62 | 139 | **STIC02** | 0x8a ON | 8★飽和★ | `f5ccdf5bb6b43ef2` |
| `SLPS-01797_5.sav` | 2026-06-18 04:04 | 1860615 | 0x1a62 | 131 | **GIAS06B** | 0x83 ON | 2 | `d7b6f282ede3925d` |
| `SLPS-01797_6.sav` | 2026-07-05 17:13 | 892517 | 0x1a62 | 0 | **MAYO01** | 0x80 ON | 8★飽和★ | `bd8a07b7f9d31809` |
| `SLPS-01797_6.bak` | 2026-07-05 17:12 | 882593 | 0x1a62 | 0 | **MAYO01** | 0x80 ON | 8★飽和★ | `17e49bff59e938a8` |
| `SLPS-01797_7.sav` | 2026-06-23 04:06 | 2018986 | 0x1a62 | 222 | **MGEN98** | 0xd1 ON | 1 | `3efb44f28f9521c1` |
| `SLPS-01797_7.bak` | 2026-06-23 04:05 | 1965540 | 0x1a62 | 222 | **MGEN98** | 0xd1 ON | 1 | `ecd3feb1f464eb34` |

#### runtime_capture 2026-07-25 生 2MB dump

| file | mtime | size | prefix | mapIdx | map 名 | gating byte12 | 非0xFFFF数/8 | sha256(先頭16) |
|---|---|---|---|---|---|---|---|---|
| `ram_A.bin` | 2026-07-25 16:09 | 2097152 | 0x0 | 109 | **MAYO00** | 0x80 ON | 5 | `fdf3eb7a55327717` |
| `ram_B.bin` | 2026-07-25 16:09 | 2097152 | 0x0 | 109 | **MAYO00** | 0x80 ON | 5 | `4f12f2270a03dc9e` |
| `ram_live_1628_1.bin` | 2026-07-25 16:28 | 2097152 | 0x0 | 109 | **MAYO00** | 0x80 ON | 5 | `43187d664e23f7dc` |
| `ram_live_1628_2.bin` | 2026-07-25 16:28 | 2097152 | 0x0 | 109 | **MAYO00** | 0x80 ON | 5 | `9343a4a497b89e0d` |
| `ram_live_1628_3.bin` | 2026-07-25 16:28 | 2097152 | 0x0 | 109 | **MAYO00** | 0x80 ON | 5 | `a8d397315407baf0` |

#### f1c canon savestate

| file | mtime | size | prefix | mapIdx | map 名 | gating byte12 | 非0xFFFF数/8 | sha256(先頭16) |
|---|---|---|---|---|---|---|---|---|
| `canon_baby_point.sav` | 2026-07-15 06:13 | 1456287 | 0x1a62 | 218 | **ROOM08** | 0xcc ON | 4 | `5299b757012c9759` |
| `canon_baselineC.sav` | 2026-07-15 03:06 | 915130 | 0x1a62 | 0 | **MAYO01** | 0x80 ON | 8★飽和★ | `df15dc7bcc2320ba` |
| `canon_care_seed_point.sav` | 2026-07-15 05:00 | 955257 | 0x1a62 | 0 | **MAYO01** | 0x80 ON | 8★飽和★ | `508c04661d6eb0a6` |

#### workspace/savestate_backup

| file | mtime | size | prefix | mapIdx | map 名 | gating byte12 | 非0xFFFF数/8 | sha256(先頭16) |
|---|---|---|---|---|---|---|---|---|
| `slot3_day11.bak.bak` | 2026-08-08 17:40 | 1967037 | 0x1a62 | 172 | **TWNA06** | 0x8c ON | 8★飽和★ | `3e8e4e8b215e32d4` |
| `slot3_day12.sav.bak` | 2026-08-08 17:40 | 1917416 | 0x1a62 | 172 | **TWNA06** | 0x8c ON | 8★飽和★ | `32b668a129c11f89` |
| `slot4_day11.sav.bak` | 2026-08-08 17:40 | 1967037 | 0x1a62 | 172 | **TWNA06** | 0x8c ON | 8★飽和★ | `3e8e4e8b215e32d4` |
| `slot7_day12.sav.bak` | 2026-08-08 17:40 | 1914312 | 0x1a62 | 172 | **TWNA06** | 0x8c ON | 8★飽和★ | `4aba7feb935948bf` |
---

## 4. ★entity 配列の構造的性質(disasm 直読、本 Phase の新規)★

### 4.1 容量 = 8 record

clear ルーチン `0x800BB994`(runtime trap 11 の pc `0x800BBB00` を含む関数)の外側 loop:

```
800BBBFC  addi  $s0, $s0, 1
800BBC00  slti  $at, $s0, 8        ; ★s0 < 8★
800BBC04  bnez  $at, 0x800bb9ac
800BBC18  jr    $ra
```

`s0` は record index(`0x80145608 + s0*0xC4` のアドレス算術に使われる)。
∴ ★**配列は 8 record = `0x80145608` .. `0x80145E07`**★。

**含意**: boss1 §2.3 の「idx 8 以降は値が構造化されていない = stale 残骸の疑い」は棄却。**idx 8 以降は配列外の別データ**であり、entity として解釈してはいけない。実測でも `idx8/idx9` は多くの素材で全 0、`ram_A.bin` では別構造のデータ(§付録)。

### 4.2 ★clear が書かない field(pos/ry/ai は残る)★

clear ルーチンの store を全列挙【観測 = `0x800BB994`〜`0x800BBC18` の逆アセンブル全走査】:

| 書く offset | 命令 | 値 |
|---|---|---|
| `+0x00`〜`+0x7F` | 内側 loop(`s1 < 8`、16B stride)の `sw $zero, 0/4/8/0xc($v0)` | 0 |
| `+0x00` | `sh $a0, ($v0)`(a0 = -1) | ★0xFFFF★ |
| `+0x84` | `sh $a0` | 0 |
| `+0x94` | `sh $zero` | 0 |
| `+0xB6` / `+0xB8` | `sh $a0` | 0 |
| `+0xBA` | `sh $zero` | 0 |
| `+0xBD` / `+0xBF` | `sb $zero` | 0 |
| `+0xC0` | `sb $a0` | 0 |
| (別 base)`[0x8013CDB4 + (s0+2)*4]` の指す先 `+0x34` | `sb $zero` | 0 | (= actor ptr table 経由。entity record 外) |

★**書かれない**: `+0xA8` / `+0xAA` / `+0xAC`(pos.x/y/z)、`+0xB0`(rot_y)、`+0xBC`(ai_type)、`+0xAE` / `+0xB2` / `+0xB4` / `+0xBE`★

**bytes による追認**【観測】: `type=0xFFFF` の record にも整った pos/ry/ai が載っている。
例 `SLPS-01797_9.sav`(TWNA01)idx7 = `type=0xFFFF, ai=1, pos=(-647,0,-3108), ry=2560`。
例 `ram_A.bin`(MAYO00)idx5/6/7 = `type=0xFFFF` だが pos=(-234,0,2509)/(-148,0,-2892)/(-55,0,-2051)。

**含意(★oracle 設計に直結★)**:
- ★`type` を見ずに `pos` だけで record の有効性を判断する oracle は、前 map の残骸を掴む★
- 逆に、`type != 0xFFFF` の record は **今回の load で loader が書いたもの**(§4.3)

### 4.3 clear → loader は 1 本道

| jal | 呼出し元 | 件数 |
|---|---|---|
| `jal 0x800BB994`(clear) | `0x800DFA04` | ★1★ |
| `jal 0x800AC588` | `0x800DFA24` | ★1★ |
| `jal 0x800BAE54`(loader) | `0x800AC764` | ★1★ |

【観測 = 全 EXE 逆アセンブルの grep、いずれも caller が唯一】

- `0x800DFA04`(clear)→ `0x800DFA24`(populate 側)の間は **分岐なしの直線コード**【観測】
- `0x800AC588` 内で `0x800AC764` を跨いで飛ぶ分岐は **無い**【観測 = 区間内の分岐先を全走査】

∴ ★map load ごとに **必ず** 8 record 全部が `type=0xFFFF` にされてから populate される★。
「前 load の record が type 付きで生き残る」ことは構造的に起きない。

### 4.4 loader に clamp が無い

```
800BAE74  lh   $v0, ($v0)        ; stream 先頭 halfword
800BAE7C  sh   $v0, 0x1c($sp)    ; = loop 上限
...
800BB4EC  lh   $v0, 0x1c($sp)
800BB4F4  slt  $at, $s2, $v0     ; s2 < count のみ。★8 との比較は無い★
800BB4F8  bnez $at, 0x800baeb8
```

∴ `count > 8` の map があれば **配列外へ溢れ書きする**。実測 28 素材では溢れの痕跡なし(飽和した素材でも idx8 は全 0)【観測】。
→ ★remake 側は「clamp するのか / 溢れさせるのか」を**明示的に決めて書く**必要がある(黙ってどちらかにしない)★。

### 4.5 entity 数についての立場(★断定しない★)

- RAM から直接取れるのは「非 `0xFFFF` だった record 数」だけ。stream 先頭 halfword は `.map` file 側にしかない
- §4.3 より「非 0xFFFF 数 = 今回 load で書かれた record 数」までは言える【観測ベース】
- ただし ★load 後に runtime が `type` を書き換える経路があれば崩れる★。7/25 の watchpoint session では `0x80145608` word への writer は clear と populate の 2 種のみだったが、これは **1 map・1 session の観測**であり全数ではない【honest gap】
- ★cap 8 に飽和した素材(TWNA13 / MAYO01 / TWNA06 / STIC02)では 8 は下限★
- ∴ **決着は worker3 の生 `.map` 手 parse との交差**でつける

---

## 5. ★savestate 所在 — 全数確認結果(「不明」claim の撤回)★

### 5.1 撤回

設計 doc §2.2 の「`_9/_1/_2/_10` は所在不明 = honest blocker 候補」は ★**誤り。撤回する**★。
原因: DuckStation が **flatpak** で動いているため、savestate は `~/.local/share/duckstation/` ではなく flatpak sandbox 下にある。

★実在 path★:
```
/home/ken/.var/app/org.duckstation.DuckStation/config/duckstation/savestates/
```

`~/.local/share/duckstation/savestates/` は空(= sandbox 外の残骸 dir)。★探索範囲が誤っていたのであって、素材は最初から存在した★。

### 5.2 教訓(process へ)

**不在 claim(「素材が無い」「到達不能」)は、★探索範囲が正しいことの確認とセット★でないと成立しない。**
今回は flatpak の path 規約(`~/.var/app/<app-id>/config/`)の見落とし。
再発防止の具体手順: アプリ由来の設定/データを探すときは
`ls ~/.var/app/ | grep -i <app>` を **必ず** `~/.local/share` と併せて確認する。

### 5.3 user への savestate 依頼 → ★不要(保留)★

必要な素材(twna01 = mapIdx 204)は ★6 件実在し、6 件すべてで placement field(type/ai/pos/ry)が bit 一致★【観測、§3 / §6】。
★現時点で user に追加取得を依頼する必要はない★。

将来もし追加が要る場合の仕様は以下(記録のみ、今回は発注しない):
- **どの map**: gating OFF の map(例 `FRZL05` / `OGRE04` / `FACT05`)を 1 件 — (b) gating 軸の陽性対照として「RAM に record 不在」を実測するため
- **どの状態**: その map に入って **移動が落ち着いた at-rest** で保存(遷移途中は stale mirror を掴む、memory `feedback_live_re_atrest_not_mid_transition`)
- **何個**: 1 map につき 1 個で足りる(entity 配列は load 時に確定するため)

---

## 6. worker2 / worker3 への引き渡し

| 提供物 | 中身 |
|---|---|
| `workspace/tools/savestate_ram.py`(修正) | prefix 実測 + `--selftest`。savestate / 生 dump 共通 API |
| `workspace/tools/map_index_table.py`(新規) | map index → 名前 / gating。`--tsv` で ★idx 0..254 全 255 slot(空 slot も行として出す)★ |
| `workspace/tools/entity_dump.py`(新規) | entity 配列全 record dump(cap 8、飽和フラグ付き) |
| `PBR_P0_map_index_table.tsv` | ★255 slot★ の index / name / byte10-15 / gate。★終端の根拠を header に明記★ |
| 本 doc 付録 | 28 素材 × 8 record + 配列外 2 record の全 dump |

### worker2 向け(判定軸 (0)/(a)/(c))

- ★TWNA01 の placement field は **6 素材で bit 一致**★(`_1.sav` / `_1.bak` / `_2.sav` / `_9.sav` / `_10.sav` / `_10.bak`)【観測】
  - 一致するのは ★loader が書く placement subset(`type` / `ai` / `pos.xyz` / `rot_y`)★
  - ★record 全体(0xC4 B)の sha256 は 6 件とも別値★ = `+0x58`〜`+0x80` 帯などに **runtime 可変**な field がある。
    ∴「record 丸ごとの一致」を oracle にしてはいけない。★比較は placement subset に限定すること★
- 照合に使える map は ★TWNA01(mapIdx 204、非飽和 7)/ MAYO00(109、非飽和 5)★ が第一候補。TWNA13 / MAYO01 / TWNA06 / STIC02 は **cap 飽和**なので (a) 軸には使えない
- ★`type=0xFFFF` の record を「pos が入っているから有効」と扱わないこと★(§4.2)
- index→json の join は map 名(`extracted/maps/<lowercase>`)経由。★`YAKA01`/`YAKA21` は dir 不在、`mgen17` のみ table 不在。`mgen06..10` は table に実在(idx 247-249/253-254、gating ON)★

### worker3 向け(判定軸 (b) + 視覚反証監査)

- ★gating OFF = 名前あり 244 中 21 entry(ON 223)★ + ★空 slot 11 件も gate OFF 相当★(flags=0 ⇒ bit7 立たず)
  = ★index ベースでは 32 / 255★。ただし ★name に射影すると 20★
  (`YAKA25` は重複 entry のうち採用側 idx232 が ON のため。棄却した idx65 が OFF 側だった)
- ★`.map` の count field は gate ON の map でのみ意味を持つ★。gate OFF の map ではその領域が
  loader に読まれないので、そこを count と読んでも ★残バイト★ にすぎない
  (実例 `YAKA22`: `0x314B8` = `3f 00` = 63 だが block 長 `0xA2` = 162B しかなく 63 record は入らない
   【観測 = worker1 が生 `.map` で再現】)
- ★MASTER_TASKS 項目5 の座標 `(798, -1656)` は TWNA01 の idx5 に実在★ — `type=30 / ai=1 / ry=512`【観測、TWNA01 の 6 素材で一致】。
  「黄 creature」の一次証拠監査はこの record を対象にすればよい
- gating table の byte10/11/13/14/15 も TSV に出してある(`0x800DF99C` は byte11、`0x800DFA3C` は byte13 を読む = 別用途)

---

## 6.5 ★本 phase の教訓(process へ)★

1. ★不在 claim は「探索範囲が正しいこと」の確認とセットでのみ成立する★
   — flatpak の path 規約(`~/.var/app/<app-id>/config/`)見落としで「savestate 所在不明」と誤報告した。
2. ★打ち切られた list の不在を否定に使わない★
   — map table を「最初の空 entry」で打ち切り、空の後ろにある MGEN06-10(idx 247-249 / 253-254)を落とした。
   ★連続性(0..238 に穴なし)は「範囲内に穴がない」しか言わず「範囲が全体である」とは言わない★。
3. ★境界を形状で引かない★
   — 「idx 255 は record に見えない」は終端の根拠にならない(2 と同型)。根拠は ★被参照 + 構造の相違★
   (`0x8013640C` が stride 8 の別構造として `0x800E4CB8` から参照される)に置くこと。
4. ★N 択を出すときは必ず「どれでもない」を含める★(memory `feedback_hypothesis_space_openness` の実運用形)
   — 3 択目に「どちらとも一致しない → 素材を oracle から外す」があったため、★2 択なら「どちらかに寄せた」
   答えが出ていたところを、素材の欠陥(entity array 全 0)として検出できた★(§2.5)。
5. ★grep 済 diff は条件行を落とすので、構造判断は実ファイルで行う★
   — filter 済 diff を見て fail-fast の配置をバグと誤認しかけた事例(boss1 自戒、共有)。
6. ★「緑」が何を assert しているかを毎回書く★
   — 「新旧 tool で bit 一致」は ★同じ address の同じ bytes★ しか assert せず、
   ★ラベルの正しさは assert しない★。実際 `gp-0x6d90` の "story" ラベルは誤りだった(§2.4)。
7. ★同じ規則を 2 箇所に持たない★
   — name→index の暗黙規則が 3 tool で 3 通りになっていた(§2.4 / ISSUE-4)。単一権威に集約する。

---

## 7. honest gap(本 doc で **やっていない**こと)

1. ★entity 数を決めていない★。RAM 側は「非 0xFFFF 数」だけ。決着は生 `.map` との交差(worker3 / worker2)
2. ★`type` を runtime に書き換える経路の全数確認をしていない★。7/25 の watchpoint は 1 map・1 session の観測。「非 0xFFFF 数 = load 時 count」は **その前提の上**でのみ成立
3. `0x801693B6` が何であるかは **未同定**。「map index ではない」ことだけ示した
4. `0x8013E166`(map index)への write 経路(`0x800F0D10` 経由)の意味は未解析。read 側が loader 引数そのものであることのみ確認
5. gating byte12 の bit 7 以外(`0x8c` の `0x0c` など)、byte10/11/13/14/15 の意味は未解析
6. `extracted/maps` と table の差分(`YAKA01`/`YAKA21` の dir 不在、`mgen17` の table 不在)の原因は未調査
9. ★map table の「論理長」を与える loop bound を持つ code は未発見★。255 は後続シンボルによる物理上限
7. record の未同定 field(`+0x58`〜`+0x80` / `+0xAE` / `+0xB2` / `+0xB4`)は今回も未解析。dump には生値を出してある
8. `_4.sav` と `_4.bak` は **別 map**(FRZL17 / STIC02)。同一 slot でも `.bak` は前世代なので、slot 番号で map を語ることはできない【観測】

---

## 付録 A. 素材別 entity 配列 全 record dump

各素材につき idx0..7(配列内)+ idx8/9(★配列外、参考★)。
`0xFFFF(clear)` の行の pos/ry/ai は ★前 load の残骸★(§4.2)。

### SLPS-01797_1.sav
- kind=savestate prefix=0x1a62 (exe-sig)  sha256(file)=1b3ce9b2b292c9f1
- mapIdx(gp-0x6ca6 = 0x8013E166) = 204 -> **TWNA01**  gating byte12=0x8c &0x80=ON
- scenario(gp-0x6cd6)=149 / mapIdx_req(gp-0x6ca6,u16)=204 / mapIdx_cur(gp-0x6d90,u8)=204 / mapIdx_persist(0x801693B6,u8)=204

| idx | type | ai | pos(x,y,z) | +0xAE | ry | +0xB2 | +0xB4 | +0xBE |
|---|---|---|---|---|---|---|---|---|
| 0 | 117 | 1 | (-161,0,-2451) | 0 | 3584 | 0 | 1000 | 0 |
| 1 | 30 | 1 | (-406,0,-2839) | 0 | 3072 | 0 | 1000 | 0 |
| 2 | 117 | 1 | (1054,0,-2877) | 0 | 1024 | 0 | 0 | 0 |
| 3 | 117 | 1 | (-103,0,-1623) | 0 | 3900 | 0 | 0 | 0 |
| 4 | 43 | 1 | (-1372,0,-2991) | 0 | 3584 | 0 | 0 | 0 |
| 5 | 30 | 1 | (798,0,-1656) | 0 | 512 | 0 | 0 | 0 |
| 6 | 44 | 1 | (-839,0,2210) | 0 | 3072 | 0 | 0 | 0 |
| 7 | 0xFFFF(clear) | 1 | (-647,0,-3108) | 0 | 2560 | 0 | 0 | 0 |
| 8 ← ★配列外(cap=8)★ | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |
| 9 ← ★配列外(cap=8)★ | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |

- ★RAM 側で非 0xFFFF だった record 数 = 7 / cap 8★  (先頭から連続)

### SLPS-01797_1.bak
- kind=savestate prefix=0x1a62 (exe-sig)  sha256(file)=89f5c2a8b66d29dd
- mapIdx(gp-0x6ca6 = 0x8013E166) = 204 -> **TWNA01**  gating byte12=0x8c &0x80=ON
- scenario(gp-0x6cd6)=149 / mapIdx_req(gp-0x6ca6,u16)=204 / mapIdx_cur(gp-0x6d90,u8)=204 / mapIdx_persist(0x801693B6,u8)=204

| idx | type | ai | pos(x,y,z) | +0xAE | ry | +0xB2 | +0xB4 | +0xBE |
|---|---|---|---|---|---|---|---|---|
| 0 | 117 | 1 | (-161,0,-2451) | 0 | 3584 | 0 | 1000 | 0 |
| 1 | 30 | 1 | (-406,0,-2839) | 0 | 3072 | 0 | 1000 | 0 |
| 2 | 117 | 1 | (1054,0,-2877) | 0 | 1024 | 0 | 0 | 0 |
| 3 | 117 | 1 | (-103,0,-1623) | 0 | 3900 | 0 | 0 | 0 |
| 4 | 43 | 1 | (-1372,0,-2991) | 0 | 3584 | 0 | 0 | 0 |
| 5 | 30 | 1 | (798,0,-1656) | 0 | 512 | 0 | 0 | 0 |
| 6 | 44 | 1 | (-839,0,2210) | 0 | 3072 | 0 | 0 | 0 |
| 7 | 0xFFFF(clear) | 1 | (-647,0,-3108) | 0 | 2560 | 0 | 0 | 0 |
| 8 ← ★配列外(cap=8)★ | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |
| 9 ← ★配列外(cap=8)★ | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |

- ★RAM 側で非 0xFFFF だった record 数 = 7 / cap 8★  (先頭から連続)

### SLPS-01797_2.sav
- kind=savestate prefix=0x1a62 (exe-sig)  sha256(file)=5806a23ca8dc6df6
- mapIdx(gp-0x6ca6 = 0x8013E166) = 204 -> **TWNA01**  gating byte12=0x8c &0x80=ON
- scenario(gp-0x6cd6)=149 / mapIdx_req(gp-0x6ca6,u16)=204 / mapIdx_cur(gp-0x6d90,u8)=204 / mapIdx_persist(0x801693B6,u8)=204

| idx | type | ai | pos(x,y,z) | +0xAE | ry | +0xB2 | +0xB4 | +0xBE |
|---|---|---|---|---|---|---|---|---|
| 0 | 117 | 1 | (-161,0,-2451) | 0 | 3584 | 0 | 1000 | 0 |
| 1 | 30 | 1 | (-406,0,-2839) | 0 | 3072 | 0 | 1000 | 0 |
| 2 | 117 | 1 | (1054,0,-2877) | 0 | 1024 | 0 | 0 | 0 |
| 3 | 117 | 1 | (-103,0,-1623) | 0 | 3900 | 0 | 0 | 0 |
| 4 | 43 | 1 | (-1372,0,-2991) | 0 | 3584 | 0 | 0 | 0 |
| 5 | 30 | 1 | (798,0,-1656) | 0 | 512 | 0 | 0 | 0 |
| 6 | 44 | 1 | (-839,0,2210) | 0 | 3072 | 0 | 0 | 0 |
| 7 | 0xFFFF(clear) | 1 | (-647,0,-3108) | 0 | 2560 | 0 | 0 | 0 |
| 8 ← ★配列外(cap=8)★ | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |
| 9 ← ★配列外(cap=8)★ | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |

- ★RAM 側で非 0xFFFF だった record 数 = 7 / cap 8★  (先頭から連続)

### SLPS-01797_9.sav
- kind=savestate prefix=0x1a62 (exe-sig)  sha256(file)=2428aaeabf4e8322
- mapIdx(gp-0x6ca6 = 0x8013E166) = 204 -> **TWNA01**  gating byte12=0x8c &0x80=ON
- scenario(gp-0x6cd6)=149 / mapIdx_req(gp-0x6ca6,u16)=204 / mapIdx_cur(gp-0x6d90,u8)=204 / mapIdx_persist(0x801693B6,u8)=204

| idx | type | ai | pos(x,y,z) | +0xAE | ry | +0xB2 | +0xB4 | +0xBE |
|---|---|---|---|---|---|---|---|---|
| 0 | 117 | 1 | (-161,0,-2451) | 0 | 3584 | 0 | 1000 | 0 |
| 1 | 30 | 1 | (-406,0,-2839) | 0 | 3072 | 0 | 1000 | 0 |
| 2 | 117 | 1 | (1054,0,-2877) | 0 | 1024 | 0 | 0 | 0 |
| 3 | 117 | 1 | (-103,0,-1623) | 0 | 3900 | 0 | 0 | 0 |
| 4 | 43 | 1 | (-1372,0,-2991) | 0 | 3584 | 0 | 0 | 0 |
| 5 | 30 | 1 | (798,0,-1656) | 0 | 512 | 0 | 0 | 0 |
| 6 | 44 | 1 | (-839,0,2210) | 0 | 3072 | 0 | 0 | 0 |
| 7 | 0xFFFF(clear) | 1 | (-647,0,-3108) | 0 | 2560 | 0 | 0 | 0 |
| 8 ← ★配列外(cap=8)★ | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |
| 9 ← ★配列外(cap=8)★ | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |

- ★RAM 側で非 0xFFFF だった record 数 = 7 / cap 8★  (先頭から連続)

### SLPS-01797_10.sav
- kind=savestate prefix=0x1a62 (exe-sig)  sha256(file)=986f3a63b959a3d4
- mapIdx(gp-0x6ca6 = 0x8013E166) = 204 -> **TWNA01**  gating byte12=0x8c &0x80=ON
- scenario(gp-0x6cd6)=149 / mapIdx_req(gp-0x6ca6,u16)=204 / mapIdx_cur(gp-0x6d90,u8)=204 / mapIdx_persist(0x801693B6,u8)=204

| idx | type | ai | pos(x,y,z) | +0xAE | ry | +0xB2 | +0xB4 | +0xBE |
|---|---|---|---|---|---|---|---|---|
| 0 | 117 | 1 | (-161,0,-2451) | 0 | 3584 | 0 | 1000 | 0 |
| 1 | 30 | 1 | (-406,0,-2839) | 0 | 3072 | 0 | 1000 | 0 |
| 2 | 117 | 1 | (1054,0,-2877) | 0 | 1024 | 0 | 0 | 0 |
| 3 | 117 | 1 | (-103,0,-1623) | 0 | 3900 | 0 | 0 | 0 |
| 4 | 43 | 1 | (-1372,0,-2991) | 0 | 3584 | 0 | 0 | 0 |
| 5 | 30 | 1 | (798,0,-1656) | 0 | 512 | 0 | 0 | 0 |
| 6 | 44 | 1 | (-839,0,2210) | 0 | 3072 | 0 | 0 | 0 |
| 7 | 0xFFFF(clear) | 1 | (-647,0,-3108) | 0 | 2560 | 0 | 0 | 0 |
| 8 ← ★配列外(cap=8)★ | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |
| 9 ← ★配列外(cap=8)★ | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |

- ★RAM 側で非 0xFFFF だった record 数 = 7 / cap 8★  (先頭から連続)

### SLPS-01797_10.bak
- kind=savestate prefix=0x1a62 (exe-sig)  sha256(file)=c2a889ad3e8dbbf1
- mapIdx(gp-0x6ca6 = 0x8013E166) = 204 -> **TWNA01**  gating byte12=0x8c &0x80=ON
- scenario(gp-0x6cd6)=149 / mapIdx_req(gp-0x6ca6,u16)=204 / mapIdx_cur(gp-0x6d90,u8)=204 / mapIdx_persist(0x801693B6,u8)=204

| idx | type | ai | pos(x,y,z) | +0xAE | ry | +0xB2 | +0xB4 | +0xBE |
|---|---|---|---|---|---|---|---|---|
| 0 | 117 | 1 | (-161,0,-2451) | 0 | 3584 | 0 | 1000 | 0 |
| 1 | 30 | 1 | (-406,0,-2839) | 0 | 3072 | 0 | 1000 | 0 |
| 2 | 117 | 1 | (1054,0,-2877) | 0 | 1024 | 0 | 0 | 0 |
| 3 | 117 | 1 | (-103,0,-1623) | 0 | 3900 | 0 | 0 | 0 |
| 4 | 43 | 1 | (-1372,0,-2991) | 0 | 3584 | 0 | 0 | 0 |
| 5 | 30 | 1 | (798,0,-1656) | 0 | 512 | 0 | 0 | 0 |
| 6 | 44 | 1 | (-839,0,2210) | 0 | 3072 | 0 | 0 | 0 |
| 7 | 0xFFFF(clear) | 1 | (-647,0,-3108) | 0 | 2560 | 0 | 0 | 0 |
| 8 ← ★配列外(cap=8)★ | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |
| 9 ← ★配列外(cap=8)★ | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |

- ★RAM 側で非 0xFFFF だった record 数 = 7 / cap 8★  (先頭から連続)

### SLPS-01797_3.sav
- kind=savestate prefix=0x1a62 (exe-sig)  sha256(file)=98b5f52cb3d7b571
- mapIdx(gp-0x6ca6 = 0x8013E166) = 179 -> **TWNA13**  gating byte12=0x8c &0x80=ON
- scenario(gp-0x6cd6)=147 / mapIdx_req(gp-0x6ca6,u16)=179 / mapIdx_cur(gp-0x6d90,u8)=179 / mapIdx_persist(0x801693B6,u8)=173

| idx | type | ai | pos(x,y,z) | +0xAE | ry | +0xB2 | +0xB4 | +0xBE |
|---|---|---|---|---|---|---|---|---|
| 0 | 43 | 1 | (-162,0,-2352) | 0 | 3584 | 0 | 1000 | 0 |
| 1 | 159 | 1 | (-2075,0,-3200) | 0 | 2560 | 0 | 1000 | 0 |
| 2 | 160 | 1 | (1513,0,-3350) | 0 | 1024 | 0 | 0 | 0 |
| 3 | 168 | 1 | (-1466,0,-2589) | 0 | 3900 | 0 | 0 | 0 |
| 4 | 129 | 1 | (240,0,-4007) | 0 | 3900 | 0 | 0 | 0 |
| 5 | 131 | 1 | (-2486,0,-2909) | 0 | 3072 | 0 | 0 | 0 |
| 6 | 147 | 1 | (-256,0,2226) | 0 | 3072 | 0 | 0 | 0 |
| 7 | 146 | 1 | (2842,0,1455) | 0 | 1024 | 0 | 0 | 0 |
| 8 ← ★配列外(cap=8)★ | 0 | -85 | (-785,35,-18) | -1 | 970 | -275 | -636 | 6 |
| 9 ← ★配列外(cap=8)★ | 65520 | -35 | (-4,-1,1184) | -49 | 26 | 0 | -3 | 0 |

- ★RAM 側で非 0xFFFF だった record 数 = 8 / cap 8★  (先頭から連続)

### SLPS-01797_3.bak
- kind=savestate prefix=0x1a62 (exe-sig)  sha256(file)=67e046ed9afe32ba
- mapIdx(gp-0x6ca6 = 0x8013E166) = 179 -> **TWNA13**  gating byte12=0x8c &0x80=ON
- scenario(gp-0x6cd6)=147 / mapIdx_req(gp-0x6ca6,u16)=179 / mapIdx_cur(gp-0x6d90,u8)=179 / mapIdx_persist(0x801693B6,u8)=173

| idx | type | ai | pos(x,y,z) | +0xAE | ry | +0xB2 | +0xB4 | +0xBE |
|---|---|---|---|---|---|---|---|---|
| 0 | 43 | 1 | (-162,0,-2352) | 0 | 3584 | 0 | 1000 | 0 |
| 1 | 159 | 1 | (-2075,0,-3200) | 0 | 2560 | 0 | 1000 | 0 |
| 2 | 160 | 1 | (1513,0,-3350) | 0 | 1024 | 0 | 0 | 0 |
| 3 | 168 | 1 | (-1466,0,-2589) | 0 | 3900 | 0 | 0 | 0 |
| 4 | 129 | 1 | (240,0,-4007) | 0 | 3900 | 0 | 0 | 0 |
| 5 | 131 | 1 | (-2486,0,-2909) | 0 | 3072 | 0 | 0 | 0 |
| 6 | 147 | 1 | (-256,0,2226) | 0 | 3072 | 0 | 0 | 0 |
| 7 | 146 | 1 | (2842,0,1455) | 0 | 1024 | 0 | 0 | 0 |
| 8 ← ★配列外(cap=8)★ | 0 | -85 | (-785,35,-18) | -1 | 970 | -275 | -636 | 6 |
| 9 ← ★配列外(cap=8)★ | 65520 | -35 | (-4,-1,1184) | -49 | 26 | 0 | -3 | 0 |

- ★RAM 側で非 0xFFFF だった record 数 = 8 / cap 8★  (先頭から連続)

### SLPS-01797_resume.sav
- kind=savestate prefix=0x1a62 (exe-sig)  sha256(file)=68b23c59beb171b6
- mapIdx(gp-0x6ca6 = 0x8013E166) = 179 -> **TWNA13**  gating byte12=0x8c &0x80=ON
- scenario(gp-0x6cd6)=147 / mapIdx_req(gp-0x6ca6,u16)=179 / mapIdx_cur(gp-0x6d90,u8)=179 / mapIdx_persist(0x801693B6,u8)=173

| idx | type | ai | pos(x,y,z) | +0xAE | ry | +0xB2 | +0xB4 | +0xBE |
|---|---|---|---|---|---|---|---|---|
| 0 | 43 | 1 | (-162,0,-2352) | 0 | 3584 | 0 | 1000 | 0 |
| 1 | 159 | 1 | (-2075,0,-3200) | 0 | 2560 | 0 | 1000 | 0 |
| 2 | 160 | 1 | (1513,0,-3350) | 0 | 1024 | 0 | 0 | 0 |
| 3 | 168 | 1 | (-1466,0,-2589) | 0 | 3900 | 0 | 0 | 0 |
| 4 | 129 | 1 | (240,0,-4007) | 0 | 3900 | 0 | 0 | 0 |
| 5 | 131 | 1 | (-2486,0,-2909) | 0 | 3072 | 0 | 0 | 0 |
| 6 | 147 | 1 | (-256,0,2226) | 0 | 3072 | 0 | 0 | 0 |
| 7 | 146 | 1 | (2842,0,1455) | 0 | 1024 | 0 | 0 | 0 |
| 8 ← ★配列外(cap=8)★ | 0 | -85 | (-785,35,-18) | -1 | 970 | -275 | -636 | 6 |
| 9 ← ★配列外(cap=8)★ | 65520 | -35 | (-4,-1,1184) | -49 | 26 | 0 | -3 | 0 |

- ★RAM 側で非 0xFFFF だった record 数 = 8 / cap 8★  (先頭から連続)

### SLPS-01797_4.sav
- kind=savestate prefix=0x1a62 (exe-sig)  sha256(file)=1c6bd5a196a05d64
- mapIdx(gp-0x6ca6 = 0x8013E166) = 136 -> **FRZL17**  gating byte12=0xcf &0x80=ON
- scenario(gp-0x6cd6)=124 / mapIdx_req(gp-0x6ca6,u16)=136 / mapIdx_cur(gp-0x6d90,u8)=136 / mapIdx_persist(0x801693B6,u8)=118

| idx | type | ai | pos(x,y,z) | +0xAE | ry | +0xB2 | +0xB4 | +0xBE |
|---|---|---|---|---|---|---|---|---|
| 0 | 57 | 1 | (400,0,1400) | 0 | 0 | 0 | 1000 | 0 |
| 1 | 149 | 1 | (400,0,1400) | 0 | 0 | 0 | 1000 | 0 |
| 2 | 0xFFFF(clear) | 12 | (213,0,915) | 0 | 0 | 0 | 500 | 0 |
| 3 | 0xFFFF(clear) | 12 | (1677,0,1574) | 0 | 0 | 0 | 500 | 0 |
| 4 | 0xFFFF(clear) | 12 | (-1312,0,-3261) | 0 | 0 | 0 | 500 | 0 |
| 5 | 0xFFFF(clear) | 2 | (1834,0,-1784) | 0 | 512 | 0 | 500 | 0 |
| 6 | 0xFFFF(clear) | 12 | (-135,0,-122) | 0 | 0 | 0 | 500 | 0 |
| 7 | 0xFFFF(clear) | 12 | (837,0,2232) | 0 | 3072 | 0 | 600 | 0 |
| 8 ← ★配列外(cap=8)★ | 0 | -85 | (-785,35,-18) | -1 | 970 | -275 | -636 | 6 |
| 9 ← ★配列外(cap=8)★ | 65520 | -35 | (-4,-1,1184) | -49 | 26 | 0 | -3 | 0 |

- ★RAM 側で非 0xFFFF だった record 数 = 2 / cap 8★  (先頭から連続)

### SLPS-01797_4.bak
- kind=savestate prefix=0x1a62 (exe-sig)  sha256(file)=f5ccdf5bb6b43ef2
- mapIdx(gp-0x6ca6 = 0x8013E166) = 139 -> **STIC02**  gating byte12=0x8a &0x80=ON
- scenario(gp-0x6cd6)=127 / mapIdx_req(gp-0x6ca6,u16)=139 / mapIdx_cur(gp-0x6d90,u8)=139 / mapIdx_persist(0x801693B6,u8)=44

| idx | type | ai | pos(x,y,z) | +0xAE | ry | +0xB2 | +0xB4 | +0xBE |
|---|---|---|---|---|---|---|---|---|
| 0 | 67 | 12 | (0,0,-800) | 0 | 2807 | 0 | 1000 | 2 |
| 1 | 67 | 12 | (-360,0,-2161) | 0 | 2807 | 0 | 1000 | 2 |
| 2 | 110 | 12 | (479,0,-217) | 0 | 0 | 0 | 300 | 0 |
| 3 | 110 | 12 | (-273,0,-1634) | 0 | 0 | 0 | 300 | 0 |
| 4 | 109 | 2 | (217,0,-2203) | 0 | 0 | 0 | 1000 | 0 |
| 5 | 110 | 1 | (237,0,-1248) | 0 | 0 | 0 | 300 | 0 |
| 6 | 110 | 1 | (1089,0,-2909) | 0 | 0 | 0 | 300 | 0 |
| 7 | 110 | 1 | (-970,0,-2155) | 0 | 0 | 0 | 300 | 0 |
| 8 ← ★配列外(cap=8)★ | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |
| 9 ← ★配列外(cap=8)★ | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |

- ★RAM 側で非 0xFFFF だった record 数 = 8 / cap 8★  (先頭から連続)

### SLPS-01797_5.sav
- kind=savestate prefix=0x1a62 (exe-sig)  sha256(file)=d7b6f282ede3925d
- mapIdx(gp-0x6ca6 = 0x8013E166) = 131 -> **GIAS06B**  gating byte12=0x83 &0x80=ON
- scenario(gp-0x6cd6)=119 / mapIdx_req(gp-0x6ca6,u16)=131 / mapIdx_cur(gp-0x6d90,u8)=131 / mapIdx_persist(0x801693B6,u8)=44

| idx | type | ai | pos(x,y,z) | +0xAE | ry | +0xB2 | +0xB4 | +0xBE |
|---|---|---|---|---|---|---|---|---|
| 0 | 118 | 1 | (-491,0,1906) | 0 | 300 | 0 | 100 | 0 |
| 1 | 118 | 1 | (302,0,1338) | 0 | 300 | 0 | 100 | 0 |
| 2 | 0xFFFF(clear) | 12 | (-851,0,-2123) | 0 | 3072 | 0 | 500 | 0 |
| 3 | 0xFFFF(clear) | 12 | (-751,0,1732) | 0 | 0 | 0 | 300 | 0 |
| 4 | 0xFFFF(clear) | 12 | (-860,0,-522) | 0 | 0 | 0 | 500 | 0 |
| 5 | 0xFFFF(clear) | 12 | (-851,0,-2123) | 0 | 3072 | 0 | 500 | 0 |
| 6 | 0xFFFF(clear) | 1 | (-927,0,2387) | 0 | 3072 | 0 | 0 | 0 |
| 7 | 0xFFFF(clear) | 1 | (2842,0,1200) | 0 | 1024 | 0 | 0 | 0 |
| 8 ← ★配列外(cap=8)★ | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |
| 9 ← ★配列外(cap=8)★ | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |

- ★RAM 側で非 0xFFFF だった record 数 = 2 / cap 8★  (先頭から連続)

### SLPS-01797_6.sav
- kind=savestate prefix=0x1a62 (exe-sig)  sha256(file)=bd8a07b7f9d31809
- mapIdx(gp-0x6ca6 = 0x8013E166) = 0 -> **MAYO01**  gating byte12=0x80 &0x80=ON
- scenario(gp-0x6cd6)=65535 / mapIdx_req(gp-0x6ca6,u16)=0 / mapIdx_cur(gp-0x6d90,u8)=0 / mapIdx_persist(0x801693B6,u8)=204

| idx | type | ai | pos(x,y,z) | +0xAE | ry | +0xB2 | +0xB4 | +0xBE |
|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |
| 1 | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |
| 2 | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |
| 3 | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |
| 4 | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |
| 5 | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |
| 6 | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |
| 7 | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |
| 8 ← ★配列外(cap=8)★ | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |
| 9 ← ★配列外(cap=8)★ | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |

- ★RAM 側で非 0xFFFF だった record 数 = 8 / cap 8★  (先頭から連続)

### SLPS-01797_6.bak
- kind=savestate prefix=0x1a62 (exe-sig)  sha256(file)=17e49bff59e938a8
- mapIdx(gp-0x6ca6 = 0x8013E166) = 0 -> **MAYO01**  gating byte12=0x80 &0x80=ON
- scenario(gp-0x6cd6)=65535 / mapIdx_req(gp-0x6ca6,u16)=0 / mapIdx_cur(gp-0x6d90,u8)=0 / mapIdx_persist(0x801693B6,u8)=204

| idx | type | ai | pos(x,y,z) | +0xAE | ry | +0xB2 | +0xB4 | +0xBE |
|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |
| 1 | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |
| 2 | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |
| 3 | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |
| 4 | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |
| 5 | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |
| 6 | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |
| 7 | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |
| 8 ← ★配列外(cap=8)★ | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |
| 9 ← ★配列外(cap=8)★ | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |

- ★RAM 側で非 0xFFFF だった record 数 = 8 / cap 8★  (先頭から連続)

### SLPS-01797_7.sav
- kind=savestate prefix=0x1a62 (exe-sig)  sha256(file)=3efb44f28f9521c1
- mapIdx(gp-0x6ca6 = 0x8013E166) = 222 -> **MGEN98**  gating byte12=0xd1 &0x80=ON
- scenario(gp-0x6cd6)=196 / mapIdx_req(gp-0x6ca6,u16)=222 / mapIdx_cur(gp-0x6d90,u8)=222 / mapIdx_persist(0x801693B6,u8)=19

| idx | type | ai | pos(x,y,z) | +0xAE | ry | +0xB2 | +0xB4 | +0xBE |
|---|---|---|---|---|---|---|---|---|
| 0 | 136 | 1 | (-400,0,3400) | 0 | 0 | 0 | 300 | 0 |
| 1 | 0xFFFF(clear) | 12 | (1919,0,358) | 0 | 3072 | 0 | 700 | 0 |
| 2 | 0xFFFF(clear) | 12 | (39,0,815) | 0 | 3072 | 0 | 400 | 0 |
| 3 | 0xFFFF(clear) | 12 | (-156,0,2529) | 0 | 3072 | 0 | 0 | 0 |
| 4 | 0xFFFF(clear) | 12 | (1139,0,3491) | 0 | 3072 | 0 | 300 | 0 |
| 5 | 0xFFFF(clear) | 12 | (-156,0,2529) | 0 | 3072 | 0 | 0 | 0 |
| 6 | 0xFFFF(clear) | 1 | (30,0,3217) | 0 | 0 | 0 | 300 | 0 |
| 7 | 0xFFFF(clear) | 1 | (2842,0,1455) | 0 | 1024 | 0 | 0 | 0 |
| 8 ← ★配列外(cap=8)★ | 0 | -85 | (-785,35,-18) | -1 | 970 | -275 | -636 | 6 |
| 9 ← ★配列外(cap=8)★ | 65520 | -35 | (-4,-1,1184) | -49 | 26 | 0 | -3 | 0 |

- ★RAM 側で非 0xFFFF だった record 数 = 1 / cap 8★  (先頭から連続)

### SLPS-01797_7.bak
- kind=savestate prefix=0x1a62 (exe-sig)  sha256(file)=ecd3feb1f464eb34
- mapIdx(gp-0x6ca6 = 0x8013E166) = 222 -> **MGEN98**  gating byte12=0xd1 &0x80=ON
- scenario(gp-0x6cd6)=196 / mapIdx_req(gp-0x6ca6,u16)=222 / mapIdx_cur(gp-0x6d90,u8)=222 / mapIdx_persist(0x801693B6,u8)=19

| idx | type | ai | pos(x,y,z) | +0xAE | ry | +0xB2 | +0xB4 | +0xBE |
|---|---|---|---|---|---|---|---|---|
| 0 | 136 | 1 | (-400,0,3400) | 0 | 0 | 0 | 300 | 0 |
| 1 | 0xFFFF(clear) | 12 | (1919,0,358) | 0 | 3072 | 0 | 700 | 0 |
| 2 | 0xFFFF(clear) | 12 | (39,0,815) | 0 | 3072 | 0 | 400 | 0 |
| 3 | 0xFFFF(clear) | 12 | (-156,0,2529) | 0 | 3072 | 0 | 0 | 0 |
| 4 | 0xFFFF(clear) | 12 | (1139,0,3491) | 0 | 3072 | 0 | 300 | 0 |
| 5 | 0xFFFF(clear) | 12 | (-156,0,2529) | 0 | 3072 | 0 | 0 | 0 |
| 6 | 0xFFFF(clear) | 1 | (30,0,3217) | 0 | 0 | 0 | 300 | 0 |
| 7 | 0xFFFF(clear) | 1 | (2842,0,1455) | 0 | 1024 | 0 | 0 | 0 |
| 8 ← ★配列外(cap=8)★ | 0 | -85 | (-785,35,-18) | -1 | 970 | -275 | -636 | 6 |
| 9 ← ★配列外(cap=8)★ | 65520 | -35 | (-4,-1,1184) | -49 | 26 | 0 | -3 | 0 |

- ★RAM 側で非 0xFFFF だった record 数 = 1 / cap 8★  (先頭から連続)

### ram_A.bin
- kind=raw prefix=0x0 (exe-sig)  sha256(file)=fdf3eb7a55327717
- mapIdx(gp-0x6ca6 = 0x8013E166) = 109 -> **MAYO00**  gating byte12=0x80 &0x80=ON
- scenario(gp-0x6cd6)=101 / mapIdx_req(gp-0x6ca6,u16)=109 / mapIdx_cur(gp-0x6d90,u8)=109 / mapIdx_persist(0x801693B6,u8)=173

| idx | type | ai | pos(x,y,z) | +0xAE | ry | +0xB2 | +0xB4 | +0xBE |
|---|---|---|---|---|---|---|---|---|
| 0 | 74 | 12 | (594,0,2347) | 0 | 3072 | 0 | 1000 | 0 |
| 1 | 74 | 12 | (327,0,-1500) | 0 | 3072 | 0 | 1000 | 2 |
| 2 | 3 | 16 | (-226,0,1688) | 0 | 3072 | 0 | 2000 | 0 |
| 3 | 83 | 12 | (594,0,2347) | 0 | 3072 | 0 | 1000 | 0 |
| 4 | 83 | 12 | (327,0,-1500) | 0 | 3072 | 0 | 1000 | 0 |
| 5 | 0xFFFF(clear) | 1 | (-234,0,2509) | 0 | 3072 | 0 | 0 | 0 |
| 6 | 0xFFFF(clear) | 1 | (-148,0,-2892) | 0 | 2048 | 0 | 0 | 0 |
| 7 | 0xFFFF(clear) | 12 | (-55,0,-2051) | 0 | 3072 | 0 | 0 | 0 |
| 8 ← ★配列外(cap=8)★ | 0 | -85 | (-785,35,-18) | -1 | 970 | -275 | -636 | 6 |
| 9 ← ★配列外(cap=8)★ | 65520 | -35 | (-4,-1,1184) | -49 | 26 | 0 | -3 | 0 |

- ★RAM 側で非 0xFFFF だった record 数 = 5 / cap 8★  (先頭から連続)

### ram_B.bin
- kind=raw prefix=0x0 (exe-sig)  sha256(file)=4f12f2270a03dc9e
- mapIdx(gp-0x6ca6 = 0x8013E166) = 109 -> **MAYO00**  gating byte12=0x80 &0x80=ON
- scenario(gp-0x6cd6)=101 / mapIdx_req(gp-0x6ca6,u16)=109 / mapIdx_cur(gp-0x6d90,u8)=109 / mapIdx_persist(0x801693B6,u8)=173

| idx | type | ai | pos(x,y,z) | +0xAE | ry | +0xB2 | +0xB4 | +0xBE |
|---|---|---|---|---|---|---|---|---|
| 0 | 74 | 12 | (594,0,2347) | 0 | 3072 | 0 | 1000 | 0 |
| 1 | 74 | 12 | (327,0,-1500) | 0 | 3072 | 0 | 1000 | 2 |
| 2 | 3 | 16 | (-226,0,1688) | 0 | 3072 | 0 | 2000 | 0 |
| 3 | 83 | 12 | (594,0,2347) | 0 | 3072 | 0 | 1000 | 0 |
| 4 | 83 | 12 | (327,0,-1500) | 0 | 3072 | 0 | 1000 | 0 |
| 5 | 0xFFFF(clear) | 1 | (-234,0,2509) | 0 | 3072 | 0 | 0 | 0 |
| 6 | 0xFFFF(clear) | 1 | (-148,0,-2892) | 0 | 2048 | 0 | 0 | 0 |
| 7 | 0xFFFF(clear) | 12 | (-55,0,-2051) | 0 | 3072 | 0 | 0 | 0 |
| 8 ← ★配列外(cap=8)★ | 0 | -85 | (-785,35,-18) | -1 | 970 | -275 | -636 | 6 |
| 9 ← ★配列外(cap=8)★ | 65520 | -35 | (-4,-1,1184) | -49 | 26 | 0 | -3 | 0 |

- ★RAM 側で非 0xFFFF だった record 数 = 5 / cap 8★  (先頭から連続)

### ram_live_1628_1.bin
- kind=raw prefix=0x0 (exe-sig)  sha256(file)=43187d664e23f7dc
- mapIdx(gp-0x6ca6 = 0x8013E166) = 109 -> **MAYO00**  gating byte12=0x80 &0x80=ON
- scenario(gp-0x6cd6)=101 / mapIdx_req(gp-0x6ca6,u16)=109 / mapIdx_cur(gp-0x6d90,u8)=109 / mapIdx_persist(0x801693B6,u8)=173

| idx | type | ai | pos(x,y,z) | +0xAE | ry | +0xB2 | +0xB4 | +0xBE |
|---|---|---|---|---|---|---|---|---|
| 0 | 74 | 12 | (594,0,2347) | 0 | 3072 | 0 | 1000 | 0 |
| 1 | 74 | 12 | (327,0,-1500) | 0 | 3072 | 0 | 1000 | 0 |
| 2 | 3 | 16 | (-226,0,1688) | 0 | 3072 | 0 | 2000 | 0 |
| 3 | 83 | 12 | (594,0,2347) | 0 | 3072 | 0 | 1000 | 0 |
| 4 | 83 | 12 | (327,0,-1500) | 0 | 3072 | 0 | 1000 | 0 |
| 5 | 0xFFFF(clear) | 1 | (-234,0,2509) | 0 | 3072 | 0 | 0 | 0 |
| 6 | 0xFFFF(clear) | 1 | (-148,0,-2892) | 0 | 2048 | 0 | 0 | 0 |
| 7 | 0xFFFF(clear) | 12 | (-55,0,-2051) | 0 | 3072 | 0 | 0 | 0 |
| 8 ← ★配列外(cap=8)★ | 0 | -85 | (-785,35,-18) | -1 | 970 | -275 | -636 | 6 |
| 9 ← ★配列外(cap=8)★ | 65520 | -35 | (-4,-1,1184) | -49 | 26 | 0 | -3 | 0 |

- ★RAM 側で非 0xFFFF だった record 数 = 5 / cap 8★  (先頭から連続)

### ram_live_1628_2.bin
- kind=raw prefix=0x0 (exe-sig)  sha256(file)=9343a4a497b89e0d
- mapIdx(gp-0x6ca6 = 0x8013E166) = 109 -> **MAYO00**  gating byte12=0x80 &0x80=ON
- scenario(gp-0x6cd6)=101 / mapIdx_req(gp-0x6ca6,u16)=109 / mapIdx_cur(gp-0x6d90,u8)=109 / mapIdx_persist(0x801693B6,u8)=173

| idx | type | ai | pos(x,y,z) | +0xAE | ry | +0xB2 | +0xB4 | +0xBE |
|---|---|---|---|---|---|---|---|---|
| 0 | 74 | 12 | (594,0,2347) | 0 | 3072 | 0 | 1000 | 0 |
| 1 | 74 | 12 | (327,0,-1500) | 0 | 3072 | 0 | 1000 | 0 |
| 2 | 3 | 16 | (-226,0,1688) | 0 | 3072 | 0 | 2000 | 0 |
| 3 | 83 | 12 | (594,0,2347) | 0 | 3072 | 0 | 1000 | 0 |
| 4 | 83 | 12 | (327,0,-1500) | 0 | 3072 | 0 | 1000 | 0 |
| 5 | 0xFFFF(clear) | 1 | (-234,0,2509) | 0 | 3072 | 0 | 0 | 0 |
| 6 | 0xFFFF(clear) | 1 | (-148,0,-2892) | 0 | 2048 | 0 | 0 | 0 |
| 7 | 0xFFFF(clear) | 12 | (-55,0,-2051) | 0 | 3072 | 0 | 0 | 0 |
| 8 ← ★配列外(cap=8)★ | 0 | -85 | (-785,35,-18) | -1 | 970 | -275 | -636 | 6 |
| 9 ← ★配列外(cap=8)★ | 65520 | -35 | (-4,-1,1184) | -49 | 26 | 0 | -3 | 0 |

- ★RAM 側で非 0xFFFF だった record 数 = 5 / cap 8★  (先頭から連続)

### ram_live_1628_3.bin
- kind=raw prefix=0x0 (exe-sig)  sha256(file)=a8d397315407baf0
- mapIdx(gp-0x6ca6 = 0x8013E166) = 109 -> **MAYO00**  gating byte12=0x80 &0x80=ON
- scenario(gp-0x6cd6)=101 / mapIdx_req(gp-0x6ca6,u16)=109 / mapIdx_cur(gp-0x6d90,u8)=109 / mapIdx_persist(0x801693B6,u8)=173

| idx | type | ai | pos(x,y,z) | +0xAE | ry | +0xB2 | +0xB4 | +0xBE |
|---|---|---|---|---|---|---|---|---|
| 0 | 74 | 12 | (594,0,2347) | 0 | 3072 | 0 | 1000 | 0 |
| 1 | 74 | 12 | (327,0,-1500) | 0 | 3072 | 0 | 1000 | 0 |
| 2 | 3 | 16 | (-226,0,1688) | 0 | 3072 | 0 | 2000 | 0 |
| 3 | 83 | 12 | (594,0,2347) | 0 | 3072 | 0 | 1000 | 0 |
| 4 | 83 | 12 | (327,0,-1500) | 0 | 3072 | 0 | 1000 | 0 |
| 5 | 0xFFFF(clear) | 1 | (-234,0,2509) | 0 | 3072 | 0 | 0 | 0 |
| 6 | 0xFFFF(clear) | 1 | (-148,0,-2892) | 0 | 2048 | 0 | 0 | 0 |
| 7 | 0xFFFF(clear) | 12 | (-55,0,-2051) | 0 | 3072 | 0 | 0 | 0 |
| 8 ← ★配列外(cap=8)★ | 0 | -85 | (-785,35,-18) | -1 | 970 | -275 | -636 | 6 |
| 9 ← ★配列外(cap=8)★ | 65520 | -35 | (-4,-1,1184) | -49 | 26 | 0 | -3 | 0 |

- ★RAM 側で非 0xFFFF だった record 数 = 5 / cap 8★  (先頭から連続)

### canon_baby_point.sav
- kind=savestate prefix=0x1a62 (exe-sig)  sha256(file)=5299b757012c9759
- mapIdx(gp-0x6ca6 = 0x8013E166) = 218 -> **ROOM08**  gating byte12=0xcc &0x80=ON
- scenario(gp-0x6cd6)=163 / mapIdx_req(gp-0x6ca6,u16)=218 / mapIdx_cur(gp-0x6d90,u8)=218 / mapIdx_persist(0x801693B6,u8)=204

| idx | type | ai | pos(x,y,z) | +0xAE | ry | +0xB2 | +0xB4 | +0xBE |
|---|---|---|---|---|---|---|---|---|
| 0 | 117 | 1 | (2,0,445) | 0 | 4000 | 0 | 1000 | 0 |
| 1 | 30 | 1 | (518,0,529) | 0 | 283 | 0 | 1000 | 0 |
| 2 | 1 | 1 | (-496,0,228) | 0 | 3500 | 0 | 1000 | 0 |
| 3 | 131 | 1 | (-496,0,228) | 0 | 3500 | 0 | 1000 | 0 |
| 4 | 0xFFFF(clear) | 1 | (-1372,0,-2991) | 0 | 3584 | 0 | 0 | 0 |
| 5 | 0xFFFF(clear) | 1 | (480,0,-1680) | 0 | 0 | 0 | 0 | 0 |
| 6 | 0xFFFF(clear) | 1 | (-839,0,2210) | 0 | 3072 | 0 | 0 | 0 |
| 7 | 0xFFFF(clear) | 1 | (-647,0,-3108) | 0 | 2560 | 0 | 0 | 0 |
| 8 ← ★配列外(cap=8)★ | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |
| 9 ← ★配列外(cap=8)★ | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |

- ★RAM 側で非 0xFFFF だった record 数 = 4 / cap 8★  (先頭から連続)

### canon_baselineC.sav
- kind=savestate prefix=0x1a62 (exe-sig)  sha256(file)=df15dc7bcc2320ba
- mapIdx(gp-0x6ca6 = 0x8013E166) = 0 -> **MAYO01**  gating byte12=0x80 &0x80=ON
- scenario(gp-0x6cd6)=65535 / mapIdx_req(gp-0x6ca6,u16)=0 / mapIdx_cur(gp-0x6d90,u8)=0 / mapIdx_persist(0x801693B6,u8)=204

| idx | type | ai | pos(x,y,z) | +0xAE | ry | +0xB2 | +0xB4 | +0xBE |
|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |
| 1 | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |
| 2 | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |
| 3 | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |
| 4 | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |
| 5 | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |
| 6 | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |
| 7 | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |
| 8 ← ★配列外(cap=8)★ | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |
| 9 ← ★配列外(cap=8)★ | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |

- ★RAM 側で非 0xFFFF だった record 数 = 8 / cap 8★  (先頭から連続)

### canon_care_seed_point.sav
- kind=savestate prefix=0x1a62 (exe-sig)  sha256(file)=508c04661d6eb0a6
- mapIdx(gp-0x6ca6 = 0x8013E166) = 0 -> **MAYO01**  gating byte12=0x80 &0x80=ON
- scenario(gp-0x6cd6)=65535 / mapIdx_req(gp-0x6ca6,u16)=0 / mapIdx_cur(gp-0x6d90,u8)=204 / mapIdx_persist(0x801693B6,u8)=204

| idx | type | ai | pos(x,y,z) | +0xAE | ry | +0xB2 | +0xB4 | +0xBE |
|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |
| 1 | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |
| 2 | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |
| 3 | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |
| 4 | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |
| 5 | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |
| 6 | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |
| 7 | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |
| 8 ← ★配列外(cap=8)★ | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |
| 9 ← ★配列外(cap=8)★ | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |

- ★RAM 側で非 0xFFFF だった record 数 = 8 / cap 8★  (先頭から連続)

### slot3_day11.bak.bak
- kind=savestate prefix=0x1a62 (exe-sig)  sha256(file)=3e8e4e8b215e32d4
- mapIdx(gp-0x6ca6 = 0x8013E166) = 172 -> **TWNA06**  gating byte12=0x8c &0x80=ON
- scenario(gp-0x6cd6)=147 / mapIdx_req(gp-0x6ca6,u16)=172 / mapIdx_cur(gp-0x6d90,u8)=172 / mapIdx_persist(0x801693B6,u8)=44

| idx | type | ai | pos(x,y,z) | +0xAE | ry | +0xB2 | +0xB4 | +0xBE |
|---|---|---|---|---|---|---|---|---|
| 0 | 43 | 1 | (-162,0,-2352) | 0 | 3584 | 0 | 1000 | 0 |
| 1 | 159 | 1 | (-2075,0,-3200) | 0 | 2560 | 0 | 1000 | 0 |
| 2 | 160 | 1 | (1513,0,-3350) | 0 | 1024 | 0 | 0 | 0 |
| 3 | 168 | 1 | (-1466,0,-2589) | 0 | 3900 | 0 | 0 | 0 |
| 4 | 129 | 1 | (240,0,-4007) | 0 | 3900 | 0 | 0 | 0 |
| 5 | 131 | 1 | (-2486,0,-2909) | 0 | 3072 | 0 | 0 | 0 |
| 6 | 164 | 1 | (-927,0,2387) | 0 | 3072 | 0 | 0 | 0 |
| 7 | 146 | 1 | (2842,0,1200) | 0 | 1024 | 0 | 0 | 0 |
| 8 ← ★配列外(cap=8)★ | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |
| 9 ← ★配列外(cap=8)★ | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |

- ★RAM 側で非 0xFFFF だった record 数 = 8 / cap 8★  (先頭から連続)

### slot3_day12.sav.bak
- kind=savestate prefix=0x1a62 (exe-sig)  sha256(file)=32b668a129c11f89
- mapIdx(gp-0x6ca6 = 0x8013E166) = 172 -> **TWNA06**  gating byte12=0x8c &0x80=ON
- scenario(gp-0x6cd6)=147 / mapIdx_req(gp-0x6ca6,u16)=172 / mapIdx_cur(gp-0x6d90,u8)=172 / mapIdx_persist(0x801693B6,u8)=44

| idx | type | ai | pos(x,y,z) | +0xAE | ry | +0xB2 | +0xB4 | +0xBE |
|---|---|---|---|---|---|---|---|---|
| 0 | 43 | 1 | (-162,0,-2352) | 0 | 3584 | 0 | 1000 | 0 |
| 1 | 159 | 1 | (-2075,0,-3200) | 0 | 2560 | 0 | 1000 | 0 |
| 2 | 160 | 1 | (1513,0,-3350) | 0 | 1024 | 0 | 0 | 0 |
| 3 | 168 | 1 | (-1466,0,-2589) | 0 | 3900 | 0 | 0 | 0 |
| 4 | 129 | 1 | (240,0,-4007) | 0 | 3900 | 0 | 0 | 0 |
| 5 | 131 | 1 | (-2486,0,-2909) | 0 | 3072 | 0 | 0 | 0 |
| 6 | 164 | 1 | (-927,0,2387) | 0 | 3072 | 0 | 0 | 0 |
| 7 | 146 | 1 | (2842,0,1200) | 0 | 1024 | 0 | 0 | 0 |
| 8 ← ★配列外(cap=8)★ | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |
| 9 ← ★配列外(cap=8)★ | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |

- ★RAM 側で非 0xFFFF だった record 数 = 8 / cap 8★  (先頭から連続)

### slot4_day11.sav.bak
- kind=savestate prefix=0x1a62 (exe-sig)  sha256(file)=3e8e4e8b215e32d4
- mapIdx(gp-0x6ca6 = 0x8013E166) = 172 -> **TWNA06**  gating byte12=0x8c &0x80=ON
- scenario(gp-0x6cd6)=147 / mapIdx_req(gp-0x6ca6,u16)=172 / mapIdx_cur(gp-0x6d90,u8)=172 / mapIdx_persist(0x801693B6,u8)=44

| idx | type | ai | pos(x,y,z) | +0xAE | ry | +0xB2 | +0xB4 | +0xBE |
|---|---|---|---|---|---|---|---|---|
| 0 | 43 | 1 | (-162,0,-2352) | 0 | 3584 | 0 | 1000 | 0 |
| 1 | 159 | 1 | (-2075,0,-3200) | 0 | 2560 | 0 | 1000 | 0 |
| 2 | 160 | 1 | (1513,0,-3350) | 0 | 1024 | 0 | 0 | 0 |
| 3 | 168 | 1 | (-1466,0,-2589) | 0 | 3900 | 0 | 0 | 0 |
| 4 | 129 | 1 | (240,0,-4007) | 0 | 3900 | 0 | 0 | 0 |
| 5 | 131 | 1 | (-2486,0,-2909) | 0 | 3072 | 0 | 0 | 0 |
| 6 | 164 | 1 | (-927,0,2387) | 0 | 3072 | 0 | 0 | 0 |
| 7 | 146 | 1 | (2842,0,1200) | 0 | 1024 | 0 | 0 | 0 |
| 8 ← ★配列外(cap=8)★ | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |
| 9 ← ★配列外(cap=8)★ | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |

- ★RAM 側で非 0xFFFF だった record 数 = 8 / cap 8★  (先頭から連続)

### slot7_day12.sav.bak
- kind=savestate prefix=0x1a62 (exe-sig)  sha256(file)=4aba7feb935948bf
- mapIdx(gp-0x6ca6 = 0x8013E166) = 172 -> **TWNA06**  gating byte12=0x8c &0x80=ON
- scenario(gp-0x6cd6)=147 / mapIdx_req(gp-0x6ca6,u16)=172 / mapIdx_cur(gp-0x6d90,u8)=172 / mapIdx_persist(0x801693B6,u8)=44

| idx | type | ai | pos(x,y,z) | +0xAE | ry | +0xB2 | +0xB4 | +0xBE |
|---|---|---|---|---|---|---|---|---|
| 0 | 43 | 1 | (-162,0,-2352) | 0 | 3584 | 0 | 1000 | 0 |
| 1 | 159 | 1 | (-2075,0,-3200) | 0 | 2560 | 0 | 1000 | 0 |
| 2 | 160 | 1 | (1513,0,-3350) | 0 | 1024 | 0 | 0 | 0 |
| 3 | 168 | 1 | (-1466,0,-2589) | 0 | 3900 | 0 | 0 | 0 |
| 4 | 129 | 1 | (240,0,-4007) | 0 | 3900 | 0 | 0 | 0 |
| 5 | 131 | 1 | (-2486,0,-2909) | 0 | 3072 | 0 | 0 | 0 |
| 6 | 164 | 1 | (-927,0,2387) | 0 | 3072 | 0 | 0 | 0 |
| 7 | 146 | 1 | (2842,0,1200) | 0 | 1024 | 0 | 0 | 0 |
| 8 ← ★配列外(cap=8)★ | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |
| 9 ← ★配列外(cap=8)★ | 0 | 0 | (0,0,0) | 0 | 0 | 0 | 0 | 0 |

- ★RAM 側で非 0xFFFF だった record 数 = 8 / cap 8★  (先頭から連続)

