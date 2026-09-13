# cut178 未対応 opcode 11 種 — handler 直読 sweep / boss1 集約 1 枚（2026-09-13）

**dispatch** = PRESIDENT #931（裁定① gate ON 据え置き / 裁定② baseline 3 値の known-good 格下げ）
**性格** = ★RE のみ。実装していない / gate 既定を変えていない / commit・push なし / 実機未接続 / comms は読取のみ★
**3 worktree の tip 不動** = p2w1 `a86e1b2b` / p2w2 `4f02c681` / p2w3 `f7d60c27`（いずれも untracked 追加のみ）

---

## 0. 換算の宣言（本書のすべての番地に適用）

- **EXE** = `/home/ken/Desktop/Digimon/degimon/extracted/slps_017_97.bin`
  `sha256 db26754d97f4673f881bd52494c29fbfafa9cdeed32817db76bc1465565c3e27` / 710,656 byte
  **base = 0x80090800 / file_off = ram - 0x80090800**（PS-EXE header 無しの raw dump）
- **Len / handler VA の出所** = `degimon_world_remake-assy/workspace/degimon-faithful178/P2_LEN_EXE_worker1.tsv`
  **HEAD blob = `5f18d9094ab6b66ca25c47b4f8fa38ff60a9d540`**
  ※ FOLLOWUP doc / WORKER2_STATE が引く `fb808667…` は**旧版 blob**。boss1 が両 blob を diff し
  **本 sweep の 11 op は全 11 行 bit 同一**（差分は 0xFB 行の追記と見出し 3 行のみ）。**以後 5f18d909 で引く。**
- **便（= 出現）の出所** = `comms/workspace/battle-slice/logs/cut178_ab_20260913/treatment.log`
  gate 到達列 **176 件・entry=178・pc 巻き戻り 0 回・pc 重複 0 件** ⇒ **index を実行順の出所に使える**
  ★**この列は skip run（`W1_GATE_NEVERSTOP=1`）の上の観測**。op を実装すれば flow は変わりうる ⇒
  **順序・operand に関する claim はすべて「skip 挙動に限る」**★

---

## 1. headline（★3 つ組。1 つの分数に畳まない★）

> **(A) op = 8 種 / その op の出現合計 = 84 件 / (A) の直接根拠になった便 = 75 件**

- **(A) op 8 種** = `0x29` `0x34` `0x22` `0x2B` `0x23`（低帯）＋ `0x4A` `0x4C` `0x4F`（帯 0x46-0x58）
- **(C)+札** = `0x4D`(4 件中 1) / `0x56`(87 件・**未決**) / `0x6C`(1 件は引用＋補強)
- ★**(A) は「飛ばすと進行が変わりうる」であって「変わる」ではない**★

**∴ 裁定② への回答** = ★**「11 種すべて演出ゆえ skip は同じ絵」は実測で消えた**★。
baseline `66/1601/0x1315` は**飛ばした中に進行を決める op が 8 種混ざっていた上の値**。
★ただし「これらを実装すれば 3 値が動く」とは書かない（測っていない）★

---

## 2. 11 種の表

**枠の凡例** = `ABS`絶対番地 / `PTR`pointer-base / `GP`gp 相対 / `STK`stack 一時

| op | 件数 | handler VA | Len | 消費 byte の内訳 | 読む operand | ★書く先（番地＋枠）★ | ★読み手★ | ★判定★ | 列B（直接根拠の便） | 格 |
|---|---|---|---|---|---|---|---|---|---|---|
| `0x29` | 58 | `0x800ECB60` | 4 | 1 + `0x800F0FF0`[+3] | b1=itemId, b2=個数 | 在庫 `0x80145F2C`+i / +0x1E+i / +0x3C+i, `0x80145F86`（**ABS**） | **op 0x19** → `0x800CE2C8` → 比較器 → PC 書換 | **(A)** | **58/58**（bail 0 件） | 観測確定（worker2＋boss1） |
| `0x34` | 8 | `0x800ECDD4` | 4 | 1 + `0x800F0EA4`[+3] | cellId, s16 | cell table（`0x800F53C8` selector・23 cell・**ABS** `0x8016B0BC`…） | **op 0x19** getter idx0（`0x800F5334`/`0x800F5378`） | **(A)** | **8/8**（cellId 0x00-0x07） | 観測確定（worker2＋boss1） |
| `0x22` | 1 | `0x800EC90C` | 2 | 1 + `0x800F0EDC`[+1] | b | event var bank `*(gp-0x6cec)+0x159`（**PTR**）※handler 自身は書かず callee `0x800F0CD0` が書く | **op 0x19** get-var `0x800F0AC8`（同 base・同 disp） | **(A)** | 1/1 | 観測確定（worker2＋boss1） |
| `0x2B` | 1 | `0x800ECBD4` | 6 | 1 + `0x800F1230`[+5] | — | 所持金 `gp-0x6B78`（**GP**） | **op 0x19** term getter idx5 `0x800F5750` → 比較器 `0x800F10B0` の **a1** | **(A)** | 1/1 | 観測確定（worker2） |
| `0x23` | 1 | `0x800EC944` | 2 | 1 + `0x800F0EDC`[+1] | b | `0x80145F86`（在庫占有数・**ABS**） | `0x800CE2C8` の loop 尽き → **return 0** が比較器に入る値そのもの | **(A)** | 1/1 | 観測確定（worker2） |
| `0x4A` | 3 | `0x800ED53C`<br>bound `..0x800ED770` | 2 | 1 + `0x800F0EDC`[+1] | operand(=待ち対象) | mode `gp-0x6cbc`=0x4A / wait 引数 `gp-0x6d00`=**解決済 slot index**（**GP**） | router `0x800F0748`（mode!=0 なら PC を進めず return） | **(A)** | **3/3**（全 arm が `0x800ED754` に合流＝operand 非依存） | 観測確定（PRESIDENT＋boss1＋worker1） |
| `0x4C` | 10 | `0x800ED7F0` | 4 | 1 + `0x800F0FF0`[+3] | id(pc+2), b2 | record table `0x80163F60`+slot*12 に `[0]=0`(tag0)（**ABS**） | (R3) router の **yield gate** `0x800F06C8`/`0x800F0718` | **(A)** | **1/10**（`0x666`→`0x676` の対） | 観測確定（3 系統） |
| `0x4F` | 2 | `0x800ED994` | 6 | 1 + `0x800F0EDC`[+1] + `0x800F1660`[+4] | b, s16 x, s16 y | 固定 slot `0x80163FD8`(=slot10) に `[0]=6` `[3]=b` `[4]=x` `[6]=y`（**ABS**） | 同上 (R3) ／ tag6 executor `0x800EFD94` → `0x800E35CC` | **(A)** | **2/2**（実行順 index 4→5 / 59→60 で 0x4A と隣接） | 観測確定（worker1） |
| `0x4D` | 4 | `0x800ED864` | 4 | 1 + `0x800F0EDC`[+1] + `0x800F1620`[+2] | id(pc+1), s16 | 同 table に `[0]=1` `[1]=id` `[4]=s16`（**ABS**） | 同上 (R3) | **(C)+札** | **0/4**<br>※3 件は「登録行為＋cut178 では 0x4A の待機対象でない」と判定済 / 1 件(`0x552`)が (C) | 観測確定（3 系統） |
| `0x56` | 87 | `0x800EDC84` | 4 | 1 + `0x800F0FF0`[+3] | b1=actor 選択子, b2=anim id | actor+0x0C.. の **anim block**（+0x22=anim / +0x1C=1 / +0x24=1 / +0x1E,+0x20=frame）（**ABS**(#0/#1) / **PTR**(slot2..9)） | **未決** — depth1/ABS 形では flow 側 0 件 | **(C)+札** | 87/87 が同一行為（3 arm・差は actor のみ） | **保留** |
| `0x6C` | 1 | `0x800EEB40` | 8 | 1 + `0x800F0EDC`[+1] + `0x800F1660`[+4] + `0x800F1078`[+2] | id, s16 x, s16 y, byte-pair | 同 table に `[0]=8`(tag8) ほか（**ABS**） | 同上 (R3) | (B) 行為＋**0x4A の待機対象たりうる** | — | 引用（先行 doc）＋ worker3 検算 |

**`0x56` の 3 arm（母数 87/87・skip byte 全件 0x00）** — `0x800EFA24` が b1 で 3 分岐:

| arm | b1 | 件数 | 経路 | actor 実体 |
|---|---|---|---|---|
| FD | `0xFD` | **16** | `0x800AF3A0` → `0x800C9CBC` | `0x8016B048`（actor #0） |
| FC | `0xFC` | **2** | `0x800EBF18` → `0x800C9CBC` | `0x8016B084`（actor #1） |
| else | 0x05/0x08/0x0A/0x06/0x07/0x0C | **69** | `0x800BD4BC` → `0x800C9CBC` | `0x8016B104` + i*0x68 を `+0x65==b1` で走査 |

---

## 3. 機構 — 「登録 → 待機 → 完了 → 解除」（★本 sweep の中心成果★）

```
 登録 op (0x4C/0x4D/0x4F/0x6C/0x6E…)
   └─ f_800F50A8(id) で slot を解決 → record table 0x80163F60 + slot*12 に [0]=tag を書く（armed）
 待機 op (0x4A / 0x66)
   └─ mode gp-0x6cbc = 0x4A  ＋  wait 引数 gp-0x6d00 = 解決済 slot index
   └─ router 0x800F0748: mode != 0 の間 ★script PC(gp-0x6cc8) を進めず return★
 executor (poll loop 0x800EC394 → tag dispatcher 0x800EFC50 → tag16 arm)
   └─ 述語が成立したら 0x800AF3A0 / 0x800EBF18 / 0x800BD4BC を撃ち
   └─ ★0x800EFFEC addiu $v0,$zero,0xff / 0x800EFFF0 sb $v0,($s0) = slot を disarm★
   └─ 述語が不成立なら 0x800EFF6C beqz $s1 で ★disarm せず return = armed 継続★
 解除 (R3)
   └─ router 0x800F06C8 / 0x800F0718 が slot[0]==0xFF を見て sb zero,-0x6cbc(gp) ⇒ PC が進み出す
```

**★「完了」の定義（PRESIDENT 指定の核・worker3 が確定）★**
`0x800AFD94(id, target, axis, step)` = **per-frame の 1 座標 stepper**
初回 `delta=(target-cur)/step` を `gp-0x6ea0` へ・in-progress `gp-0x6eb8`=1・**return 0**／
毎 frame `*coord += delta` → `0x800A1CA4` → `0x800A1C10`／
到達時 `0x800AFF14 sw $s2,($s1)`=**target に clamp**・`sb zero,-0x6eb8(gp)`・**return 1**
⇒ **「完了」= 対象 entity の 1 座標が target に到達すること**（軸は a2 で `+0x78/+0x7C/+0x80` の 3 択）

### ★★実装 spec に直接効く 3 件★★

1. **hang の責任は「完了 writer」ではなく「target まで座標を毎 frame 動かす stepper」**
   remake が座標を動かさない限り述語は永久に 0 → slot は disarm されず → **0x4A/0x66 の wait が永久に解けない**
   （boss1 が便 005 で「完了 writer を実装しないと hang」と書いたのは**責任の所在が誤り**。PRESIDENT も自 doc を訂正）
2. **`f_800F50A8` は「空きスロット index 取得」ではない**（worker3 の retro-sweep で自 doc `SPEC_0x4A_conditional_vm_2026-06-17.md` を訂正）
   正 = **id → actor index の解決器。slot は actor に固定で空き pool ではない。同 actor に 2 回書けば上書き**
   値域 = `0xFD→0 / 0xFC→1 / entity 一致→i+2 (2..9) / 不一致→0xFF`
   ⇒ ★**「空き pool を探す」実装を書いたら原盤と違う**★
3. **実装の単位は op 個別でなく subsystem 一括**
   登録(0x4C/0x4D/0x4F/0x6C) ＋ 待機(0x4A) ＋ executor/disarm ＋ per-frame stepper ＋ 条件評価器(0x19 系) ＋ event var bank / item 在庫

---

## 4. 器と marker（★述語でなく番地集合で持つ★）

**yield marker の確定** — `jal 0x800913C0` **到達は yield ではない**（handler の正常終了も同じ命令を通る:
band epilogue `0x800ED410` / `0x800ECA98` が `a1=1` の longjmp）。**a1 で分ける**:

| a1 | 件数 | 意味 | 番地 |
|---|---|---|---|
| 1 | **10** | handler 正常終了（**全 arm が通る＝判別力ゼロ・数えるな**） | `800EC494 800ECA98 800ED410 800EDD68 800EDE70 800EF324 800EF43C 800EF540 800EF654 800EF690` |
| **2** | **23** | **真の yield**（dispatch loop 離脱）＝ **(A) の第 4 条件** | `800EC510 800EC788 800ECA84 800ED76C 800EDF60 800EE10C 800EE1B8 800EE1E8 800EE204 800EE248 800EE270 800EE38C 800EE48C 800EE4B4 800EE5F0 800EE624 800EE98C 800EE9B4 800EF164 800EF4A8 800EF4CC 800F061C 800F08B8` |
| 3 | 3 | 特殊 path → `0x800F3114` → task table `0x801640B8`(6 entry) → **mode に 0xFF**（全 slot 空き待ち） | `800ED7E8 800EDD54 800EE90C` |

**母数 36 / 探索窓 = 直前 8 命令 / ④ 不明 0 件** ⇒ ★**PRESIDENT・boss1・worker1・worker3 の 4 系統で番地まで一致**★

**cell の区別（★数の隣に cell 名と番地を必ず書く★）** — gp 相対形・全走査:

| cell | 用途 | store | load |
|---|---|---|---|
| `gp-0x6cbc` | **mode**（router `0x800F0748` が読む） | **46**（clear 28 / 非zero 18） | 10 |
| `gp-0x6d00` | **wait 引数**（解決済 slot index） | **2**（`0x800ED75C`=0x4A / `0x800EE974`=0x66） | 4 |
| `gp-0x6d10` | 待ち条件（v==0x19） | **23** | 3 |
| `gp-0x6d57` | 待ち条件（v==0x1A） | **gp 相対形 0** / ★**アドレス取得形 3**★（`800E4400` `800E4454` `800FF1C4` = `addiu a1,gp,-0x6d57` → `jal 0x801044AC`） | — |

---

## 5. closure 条件（PRESIDENT #931-P6 ⑦）の充足

| 条件 | 状況 |
|---|---|
| 11 種すべてに母数欄 | ✅ |
| marker = 23 番地集合（述語を書かない） | ✅ 3 worker とも内蔵 |
| 探索窓の明示 | ✅（closure depth・lexical bound・a1 窓） |
| ④ の件数 | ✅ |
| 陽性対照 | ✅ 各 lane |
| **陰性対照** | ✅ ただし worker2 が**自分の陰性対照 2 本を不適格と自己申告**（真ラベルが (B) でない対照は対照でない） |
| (B) に「0x4A の待機対象か」欄 | ✅（(B) は `0x6C` のみ） |
| ④ に札 | ✅ |

---

## 6. ④ + 札（★札なしの ④ は無い★）

| # | 未決事項 | 札 |
|---|---|---|
| Q1 | **`0x56`(87) の決め手** = anim block(+0x1C/+0x1E) 読み手の **depth 2** と **PTR 形 slot2..9 の 8 実体**（現 census は ABS 形 19 件/8 関数・actor 実体 2/10・depth1） | **材料**（像内で閉じる） |
| Q2 | `0x56` 閉包内の**間接辺 19 件 = BIOS A0 thunk 3 本**（`0x80091420`=A0(0x1B) / `0x80091450`=A0(0x2A) / `0x80091470`=A0(0x2E)）。書き先が呼び出し側の pointer 引数ゆえ**原理的には slot 表にも書きうる** | **材料**（call site の a0 静的読み）＋**実機/BIOS dump** |
| Q3 | `0x4C` 2 件・`0x4D` 1 件の id が**実行時の entity table 依存**（「slot 2..9 **or** `0xFF` で bail」の 2 値のまま残置） | **実機 or runtime** |
| Q4 | event var bank の**範囲 alias 未排除**（`+0x0D4` nibble bank の script 由来でない呼び元で a0 上限未確定） | **材料** |
| Q5 | `0x4F` の (x,y) が動かす対象（`0x801AB490/94/98` の素性）。★**「camera」と呼ぶのは早い**★ | **材料** |
| Q6 | tag `0x0A`(書き手 0 件) / tag `0x0B`(2 op) の使い分け | **材料** |
| Q7 | `0x8016B100` が独立 byte であること（actor #2 base=`0x8016B0C0` の実在は stride からの外挿） | **材料**（格 = RE grade） |
| Q8 | **11 種の外にも (A) が居る可能性** — `0x2D/0x2E/0x2F/0x30` が 0x19 getter idx1 の読む nibble flag bank(`+0x0D4`) の書き手/読み手の疑い | **材料**（次 scope 候補） |

---

## 7. ★器の欠陥と訂正の記録（4 人全員が踏んだ）★

**この sweep で結論を左右した器の欠陥は 7 件。すべて陽性/陰性対照を課した後に出た。**

| # | 誰 | 欠陥 | 効果 |
|---|---|---|---|
| 1 | worker1 | 閉包器の DANGER 集合が **gp cell だけ・yield が最初から入っていなかった** | 「0x56 は flow 到達 0 件」が**未検定**だった |
| 2 | worker1 | arm を TSV word 数で切り**末尾 b の共通 epilogue を追っていなかった** | 同上（1 との合成） |
| 3 | worker1 | **compare chain 末尾の else 枝を読み落とし**（`0x800ED744` の `jal 0x800f50a8`・`0x800ED750` の上書き） | `0x4C/0x4D` を誤って (C) に降格 → boss1 が直読で差し戻し |
| 4 | worker2 | 閉包器が **arm を飲み込み**関数境界を越えた | gp cell 列挙が汚染 |
| 5 | worker2 | 変位ゼロの `sb $v0,($s1)` を**例外で沈黙して捨てていた** | `0x29`/`0x22` が**偽陰性**で出ていた |
| 6 | worker3 | reach 器が**無条件 b の後に fall-through** して隣 handler を飲み込み | 15 op に偽陽性 |
| 7 | **boss1** | **caveat の非対称** — 肯定に但し書きを付け**否定に付けなかった**／「bank に触る口は 2 つだけ」（実際は cell と bank の取り違え）／「WAITMODE writer 2 件」を**同じ便で mode cell の話と矛盾**させた | 否定が「無い」と読まれて探索が止まる |
| 8 | PRESIDENT | `800EBF9C` を FC arm の内と読みかけた（**bound で自力停止**）／「yield の口 36 件」（実は longjmp 総数）／「slot 10 は 0x4F の専有」（**過大**・自己撤回） | — |

**★boss1 の claim に対する自己 grep 全当たり（14 便）= 欠陥 4 件★**

| | claim | 実態 |
|---|---|---|
| D1 | 「bank に触る口は 2 つだけ」 | **17 行**（load 16 + pointer 設定 sw 1）。2 つなのは **bank ではなく disp 0x159 の cell** |
| D2 | 「`0x800CE5B4` は leaf・実効番地 4 つだけ」 | 器は **lui+addiu 形と base+disp 形だけ**。pointer-base 未走査 |
| D3 | 「呼び元 5 件」「longjmp 36 件」 | **jal/j の直接形だけ**（全走査 jal 7,455 / j 1,501 / **jalr 98** / **jr 1,673**） |
| D4 | 「bail 0 件」「skip 全件 0x00」 | **skip run の上の観測**に限る |

**★D5 = 限定が探索を生かした実例（2 件）★**
- `gp-0x6d57` に「**この形では** 0 件」と限定を付けた → worker3 が残り 2 形を当て **別形で 3 件実在**
- worker1 が「0 件」を「**直接 jal で辿れる範囲での** 0 件」に自ら狭め → **BIOS A0 thunk 19 辺**が露出

⇒ ★**限定は衒学ではなく探索を生かす装置**。「◯◯だけ」と書いたら器の形の限定を必ず添える★

**★型（規律として）★**
- marker は「その命令に届くか」でなく**届いた時の引数まで**で定義する（共通 epilogue を通る呼びは判別力ゼロ）
- 陽性対照は**特異度を検定しない** ⇒ **陰性対照を 1 本**置く。ただし**真ラベルが (B) でない対照は対照でない**
- 関数は `jr ra` で **bound を取ってから**引く／chain は**最後の bne の飛び先**まで追う／同じ stack slot を 2 回読む code は**間の store を数える**
- **数の隣に cell 名と番地**を書く（mode / wait 引数 / 待ち条件 を混ぜない）
- **pc の大小は実行順ではない** ⇒ 順序は gate 到達列の index を出所にする（かつ skip run 限定）
- **baseline 一致を (B) の根拠に引かない**（baseline 自体が同じ skip 挙動の上で blessed されている ⇒ 一致は構造的に自明）

---

## 8. 成果物の所在

| lane | 成果物 | 行数 |
|---|---|---|
| worker1（帯 0x46-0x58） | `degimon_world_remake-p2w1/workspace/p2_opcode_sweep_20260913/W1_RANGE46_58_SWEEP.md` | 661 |
| worker2（低帯 2 帯） | `degimon_world_remake-p2w2/workspace/p2_opcode_sweep_20260913/W2_LOWBAND_SWEEP.md` | 714 |
| worker3（sink census） | `degimon_world_remake-p2w3/workspace/p2_opcode_sweep_20260913/W3_SINK_CENSUS.md` | — |
| boss1（本書） | `Desktop/Digimon/p2_sweep_aggregate/P2_OPCODE_SWEEP_20260913_AGGREGATE.md` | — |

いずれも **untracked**。★3 tree とも tip 不動・tracked 変更 0 件★

---

# 付録 A — spec / 実装 phase で積み上がった型（2026-09-13 追記）

> ★★本付録は ★型★ であって ★証拠ではない★。★数・番地を引くときは §1-8 と 各 worker の成果物から引け★★
> （型は **移植可能だが証拠ではない**／観測は **証拠だがその場限り**。★混ぜて引くと「型だから正しい」になる★ — PRESIDENT #931-P24 ③）

RE sweep 本体（§1-8）の後、spec 化と段 1-3 実装で**さらに 8 件の型**が出た。
いずれも**誰かが実際に踏んだ**もので、思弁ではない。

## A-1. ★件数を引くときは母数を必ず添える★（独立項目・本 sweep で 4 回）

**同じ器でも母数が違えば数が違う。** 数だけを引くと、後から検める人が必ず食い違う。

| # | 数 | 母数の差 | 誰が |
|---|---|---|---|
| 1 | `0x56` = (B) | 3 arm 中 **else の 69/87 しか読んでいなかった** | worker1 |
| 2 | ImplementedOps | **main 32 種 / assy 36 種** | boss1（tree を混ぜた） |
| 3 | `grep -c` の N 件 | **行数であって出現数ではない**（`0x80163F60` = 4 行 / 5 出現） | worker1 が発見 |
| 4 | facade の CS0433 34 件 | **Editor 込み 120 file 構成**。非 Editor 77 file なら 0 件 | PRESIDENT（母数を書かず） |

⇒ **件数・0 件・「だけ」には、器の形と母数を必ず添える。**

## A-2. ★test に焼き付けてはいけないのは「退路」だけではない — 「過剰な分類」も★

- **退路の焼き付け**（boss1 裁定 2）= `test(6)「entity 有 / liveness 無 → NotFound」`が
  **「分からない」と「居ない」の畳みを PASS として仕様に固定**していた。
- **過剰分類の焼き付け**（worker1 が自分で発見）= 全 skip の入力に `NotFoundScanIncomplete` を期待していたが、
  **liveness が 1 本も無い = 走査対象が存在しない ⇒ `TableNotInstalled` が正**。
  ⇒ 主 assert を**要件そのもの**（`IsDefinitiveAbsence == false`）に置き、**分類は副次に降格**。

⇒ **test は「要件」を assert する。分類（どの記号で返すか）は実装の自由度として残す。**
⇒ 併せて **「code を test に合わせて曲げていない」と明示する**（逆向きの事故を先に否定する）。

## A-3. ★退路が「正常動作」に化ける点を探せ★

`NotInstalled` を **大域判定**（`actors.InstalledCount == 0 && entities.InstalledCount == 0`）にしていたため、
**部分投入のとき「まだ投入されていない」と「その id は居ない」が再び 1 記号に畳まれていた。**

決め手は畳みそのものではなく、**hang 検出器を誤診させる経路**:

```
provisional な NotFound → 登録 op が bail → 登録されない → 0x4A が永久に待つ
→ 検出器は NO_SLOT / ResolverBailed0xFF を出す → これは spec で「正常動作」と註されている
⇒ 本物の bug を 検出器が「正常」と読む
```

**検出器が区別するために作られた、まさにその点で退路が pass に化ける。**

**切り方**: per-slot 化は採らない — 任意の id がどの slot に入るかは事前に決まらず**原理的に分けきれない**。
**分けられるのは「走査が完全か」だけ** ⇒ そこだけを正直に返す（`NotFoundScanIncomplete` + `IsDefinitiveAbsence`）。
⇒ **「分けられないもの」と「分けられるもの」を先に切り分ける**（無理な分解を避ける）。

## A-4. ★権威は宣言するだけでなく「同定」せよ★

boss1 は「実装対象は main」と**仮定した**だけで provenance を見なかった。実際の走行元は **assy**（main より **1,573 commits ahead**）。
**確かめる手は在った**（`provenance.txt` に `assy_HEAD=1e2179e2`）。**worker2 はそれを見て独立に正解に着いた。**

⇒ **「実装対象」は推定するな。走らせた器の provenance から同定せよ。**
⇒ **phase が変わると権威の所在が変わる**（RE = EXE で tree 非依存 / spec = code で tree 依存）。**phase 移行時に宣言し直す。**

## A-5. ★lane を分けると、統合側にしか見えない穴ができる★

worker1 と worker3 が**同時に**「`0x800F0CD0` は未同定」と返したが、**worker2 が同定済**だった。
両者は自分の lane で正しく、**それでも全体では誤った**。

⇒ **「私が知らない」と「誰も知らない」を 1 記号に畳むな**（[[2 つの不在を 1 記号に畳むな]] の lane 版）。
⇒ **「未同定」と書く前に、他 lane の成果を照会する。照会先は人ではなく「1 枚」に。**

## A-6. ★訂正は append では足りない — 本文行を書き換える★

worker1 は A3-3 で正しく差し替えたのに **A-1 の要約表を古いまま残していた**。
**実装者が最初に読むのは要約表**なので、①0x4A の実装が在ると誤解 ②「置換」という誤った作業単位 ③stale な行番号 を招く。

⇒ **訂正したら該当行を grep で全当たりし、本文を書き換えるまでを 1 手とする。**
⇒ worker1 の自認が的確 — **「規律として知っていながら、今回まさにそれを踏んだ」**。**規範は知っているだけでは発火しない。**

## A-7. ★「0 件」の前に、探索形そのものを陽性対照で検定する★

boss1 は (a) を「`i*0x3C` の**乗算**」で探して 0 件を得て、そのまま報告しかけた。
**真の stride 反復は `addiu $s0,$s0,0x68` = pointer advance で、乗算として現れない** — 探索形が**原理的に見つけられない器**だった。

⇒ **既知の真の事例がどの形で書かれているかを先に見てから、その形で探す。**
⇒ 派生: **`grep -E` に `\|` を書くと literal pipe**（boss1 の偽 0 件）／**pattern を狭く書くと偽陰性**（boss1 3 回）。
⇒ **「claim が合わない」と思ったら、まず自分の pattern を疑う**（緩い pattern で 1 回引き直してから相手を疑う）。

## A-8. ★偶然の的中を手柄にしない★

- boss1 の `±0x3C` census が広かったのは**器が `addi` を含んでいたから**で、**形を広く取る設計をしたからではない**。
- boss1 が「L2125 の禁止は解除できる」と書いたのは**結果的に正しかったが、根拠を持たずに書いた**（根拠は worker2 の成果）。

⇒ **当たったかどうかと、手順を踏んだかどうかは別に記録する。**

---

## 付録 B — 実装 phase の現況（2026-09-13 時点・★未完成★）

| | |
|---|---|
| worktree | `degimon_world_remake-vmslot` / branch `track1/vm-slot-impl` / 起点 assy `1e2179e2` |
| 完了 | 段 1（data 構造）/ 段 2（slot 解決器・4 値）/ 段 3（stepper + hang 検出器） |
| 未着手 | 段 4（登録 op）/ 段 5（`0x4A` + **`0x18` heuristic 撤去を同 commit**）/ 段 6 |
| compile gate | **(i-a) D = Roslyn 全 surface・error CS 0**（対照 2 本つき・facade 不参照）／**(i-b) Unity batchmode は cut178 再走時に 1 度** |
| 対照実測 | 陰性（正常 run）UNKNOWN 0 / 陽性（stepper 無効化）NO_STEPPER が出た |

★**cut178 は 1 度も走らせていない**★ ⇒ **hang が起きていないのは健全の証拠ではない = 実際に配線が無い**
（worker1 自身が事前登録の「期待される失敗③」に該当中と申告）。

★**完成 claim は user 実視覚まで凍結。「動いた」と誰も書いていない。**★
