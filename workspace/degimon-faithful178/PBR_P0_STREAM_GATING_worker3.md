# PBR Phase 0 — stream 静的照合 / gating / 視覚反証 oracle 監査 (worker3, 2026-08-08)

**dispatch**: boss1 `PBR_PHASE0_DESIGN_boss1_2026-08-08.md` §3 worker3
**作業**: read-only。degimon repo の git tree は一切改変していない(commit/push なし、Unity コード不触)
**claim 規律**: 【観測】= bytes 直読 / disasm 直読 / 実行結果。【推論】= 未裏取り。裏取りのない数値は「未検証」と明示。

---

## 0. 結論(先出し)

| 軸 | 結論 | 根拠の種類 |
|---|---|---|
| (c) 順序 | ★**閉じた**。生 .map stream 順 = JSON `digimon` 配列順。966 record / 23184 field 中 不一致 **0**★ | disasm + bytes |
| (a) entity 数 | ★**閉じた**。権威 = .map 先頭 halfword。MAYO00=**5** / TWNA01=**7**★ | bytes |
| 配列容量 | ★**8 record**(clear loop `slti 8`)。loader 側に clamp は**無い**が gate ON 全 223 map の最大 = **8** ゆえ溢れは起きない★ | disasm + bytes 全数 |
| (b) gating | ★**閉じた**。gating table は EXE 内**静的**データ。RAM 5 dump と byte 完全一致★ | bytes |
| 黄creature | ★**別サブシステム(勧誘住人)由来ゆえ Phase 0 の判定材料から除外**★ — shifted/unshifted を弁別しない | doc + 構造論拠 + 画像 |

★H4 は開いたまま扱った★: (c) の照合は「index 順で一致するか」を**全 field で**問う形にしてあり、
「両方誤り」が出る余地を残した設計。結果として不一致 0 だったため H4 は棄却された(H4 が無かったのではなく、**試して出なかった**)。

---

## 1. 手法 — loader disasm から読み順を機械抽出(convert_map.py 非依存)

★`convert_map.py` は import も参照もしていない★(循環回避)。読み順は EXE 実命令列だけから起こした。

- disasm 元 = `extracted/slps_017_97.bin`(権威 `slps_017.97.orig` の text 部、load base **0x80090800**)。capstone MIPS32 LE
- ★非権威 `extracted/SLPS_017.97`(t_addr=0x80080000)は使っていない★ — 当該 VA は `cd cd cd cd` 埋めで、
  誤って使うと「命令に見えないゴミ」が出る。`README_EXE_PROVENANCE.md` の警告どおりだった【観測】

### 1.1 stream 消費の全列挙【観測】

`0x800bae54` の loop 内で `move $v0,$s0 / addiu $s0,$v0,2 / lh` = halfword 1 個消費。
その site を全数抽出し、直後の store 先を対応付けた:

| stream | store 先 | 意味 |
|---|---|---|
| (先頭 1 個) | `[sp+0x1c]` | ★entity 数★ |
| r0 | `arr1[i]+0x00` (sh) | type |
| r1 | `arr1[i]+0xBC` (sb) | ai_type |
| r2 / r3 / r4 | `+0xA8 / +0xAA / +0xAC` | pos.x / pos.y / pos.z |
| r5 | `+0xAE` | rot.x |
| r6 | `+0xB0` | ★rot_y★ |
| r7 | `+0xB2` | rot.z |
| r8 | `+0xB4` | tracking_range |
| r9 / r10 | `arr2[i]+0x64 / +0x65` (sb) | unk2 / ★script_id★ |
| r11-r14 | `s1+0x10/0x12/0x14/0x16` | hp / mp / max_hp / max_mp |
| r15-r18 | `s1+0x00/0x02/0x04/0x06` | offense / defense / speed / brains |
| r19 | `arr2[i]+0x60` | bits |
| r20 | `s1+0x1e` (sb) | charge_mode |
| r21 | `arr2[i]+0x62` (sb) | unk5 |
| r22-r25 | `s1+0x0c..0x0f` (sb) | moves[0..3] |
| r26-r29 | `s1+0x08..0x0b` (sb) | move_weights[0..3] |
| r30-r32 | `arr2[i]+0x58/0x5A/0x5C` | flee_position xyz |
| r33 | `[sp+0x1e]` | ★waypoint_count★ |
| r34-r41 | `arr1[i]+0x84+j*2` (j=0..7) | waypoint_speed[8] |
| 以降 | `arr1[i]+4+k*16 +0/+4/+8` (sw) | waypoints[k].xyz (k < waypoint_count) |

- `s1` = `arr2[i] + 0x38`
- arr2 base = `lui 0x8017 / addiu -0x4efc` → ★`0x8016B104`、stride `0x68`(= `((i*2+i)*4+i)*8` = 104)★【観測、本 session 新規】
- ★**1 record = 固定 42 halfword + 3 × waypoint_count**★
- ★loop index `s2` は 1 ずつ増加、stream は前進読みのみ。∴ **RAM record index 順 = stream 出現順** は disasm 上 零自由度**★

### 1.2 tool の self-check(「自分の道具を疑え」)

権威測定に使う前に:
- clear routine 側(`0x800bbafc`)が同一の `*196 + 0x80145608` 算術で `-1` を書くことを確認 → base/stride の独立再確認
- 既知値で当たり: `rot_y` が r6 = converter の `rotation[1]`、`twna01.json digimon[0].rotation = [0,3584,0]` と整合
- ★初回、私は spawn/warp block を 240 B と誤り count を 300/500 と読んだ★。生 halfword を直接見て
  `elements_off + 120` が正しいと判明(6 配列 × 10 halfword = 60 hw = **120 B**)。誤りは自己検出・訂正済

---

## 2. (c) 順序 — ★bytes で閉じた★

### 2.1 非循環 oracle: parse 終端 = `tilemap_offset`

record 長が誤っていれば、N record を読み切った終端は section 境界に落ちない。

★CD 上 `.map` 242 件中、parse 成立 **240 件すべてで `parse_end == tilemap_offset`(gap = 0 byte)**★【観測】

→ ★record 長 42+3wc は JSON と無関係に bytes で裏取りされた★。これは JSON との照合とは独立の証拠。

### 2.2 全 field 照合(index 順そのまま)

| 対象 | record | field | 不一致 |
|---|---|---|---|
| MAYO00 | 5 | 120 | ★0★ |
| TWNA01 | 7 | 168 | ★0★ |
| **全 map** | **966** | **23184** | ★**0**★ |

照合 field = type / ai_type / position / rotation / tracking_range / unk2 / script_id / unk3 /
hp / mp / max_hp / max_mp / offense / defense / speed / brains / bits / charge_mode / unk5 /
moves / move_weights / flee_position / waypoint_speed / waypoints(24 種)。

参考(type のみの shifted 対照): TWNA01 = unshifted **7/7** vs shifted **1/6**、MAYO00 = **5/5** vs **2/4**。

→ ★**生 .map stream 順 = JSON 配列順**★。boss1 の RAM 突合と併せ ★生 .map ⇔ JSON ⇔ RAM の三点が閉じた★。

### 2.3 実 record(bytes 直読)

**MAYO00**(先頭 halfword = ★5★)

| i | type | ai | pos | rot_y | script_id | wp |
|---|---|---|---|---|---|---|
| 0 | 74 | 12 | (594,0,2347) | 3072 | 5 | 2 |
| 1 | 74 | 12 | (327,0,-1500) | 3072 | 8 | 2 |
| 2 | 3 | 16 | (-226,0,1688) | 3072 | 6 | 2 |
| 3 | 83 | 12 | (594,0,2347) | 3072 | 7 | 2 |
| 4 | 83 | 12 | (327,0,-1500) | 3072 | 9 | 2 |

★position 重複(idx0/3、idx1/4)は原盤データ実在★ = boss1 の「残骸疑い撤回・5 で決着」を bytes で追認。
反証材料は出なかった(探して出なかった、という意味)。

**TWNA01**(先頭 halfword = ★7★)

| i | type | 種(EXE 直読) | pos | rot_y | script_id |
|---|---|---|---|---|---|
| 0 | 117 | ジジモン | (-161,0,-2451) | 3584 | 5 |
| 1 | 30 | トコモン | (-406,0,-2839) | 3072 | 6 |
| 2 | 117 | ジジモン | (1054,0,-2877) | 1024 | 7 |
| 3 | 117 | ジジモン | (-103,0,-1623) | 3900 | 8 |
| 4 | 43 | ユラモン | (-1372,0,-2991) | 3584 | 9 |
| 5 | ★30★ | ★トコモン★ | ★(798,0,-1656)★ | 512 | 10 |
| 6 | 44 | タネモン | (-839,0,2210) | 3072 | 11 |

種名は ★`slps_017.97.orig` file 0xAA924 / stride 52 / name@+0x00(SJIS) を直読★【観測、derived JSON 非経由】。
30=トコモン / 43=ユラモン / 44=タネモン / 117=ジジモン。boss1 の `species_model_codes.json`(EXE 0x8013ce24)と独立一致。

### 2.4 ★7/23 表が artifact であることの署名★

7/23 triage §1 の表を shifted 規則(`RAM[i].type = json[i+1].type`)で機械再現すると **完全に一致する**:

| 7/23 表の記載 | shifted 規則の出力 | 一致 |
|---|---|---|
| (-103,-1623) = ユラモン | json[4].type = 43 = ユラモン | ✅ |
| (-1372,-2991) = トコモン | json[5].type = 30 = トコモン | ✅ |
| (798,-1656) = タネモン | json[6].type = 44 = タネモン | ✅ |
| ★(-839,2210) = 0xFFFF(空)★ | json[7] が**存在しない** → clear sentinel を拾う | ✅ |

★最後の「空」は off-by-one の署名そのもの★ — 最終 record に後続が無いため type が clear 値 `0xFFFF` になる。
unshifted では (-839,2210) は タネモン(44)で、実在 entity。
∴ 7/23 表は「読み frame が 1 record ずれた RAM 読み」を過不足なく再現する = artifact 確定を静的側からも裏取り。

---

## 3. (a) entity 数 + 配列容量 — ★bytes で閉じた★

### 3.1 母集団 — ★走査範囲を明示する★

★**map table は idx 0..254 の 255 entry を全走査した**★(打ち切っていない)。
★最初の空 entry(idx 239)で走査を止めると MGEN06-10 を取りこぼす★ — 実際 2026-08-08 の中継で
239 打ち切りの tsv を根拠に本節の数値が一度否定されたが、EXE 直読で本節が正しいと確定した
(「打ち切られた list の不在は否定でない」)。★連続性は「範囲内に穴が無い」ことしか言わず「範囲が全体である」ことは言わない★。

**table 構造**【観測、bytes 直読】

| idx 範囲 | 内容 |
|---|---|
| 0 .. 238 | 名前あり 239 entry(穴なし) |
| ★239 .. 246★ | ★空 8 件★ |
| ★247 / 248 / 249★ | ★MGEN06 / MGEN07 / MGEN08(flags 0xD1 = **gate ON**)★ |
| ★250 .. 252★ | ★空 3 件★ |
| ★253 / 254★ | ★MGEN09 / MGEN10(flags 0xD1 = **gate ON**)★ |
| 255 以降 | ★16B map record として非整合★(name 欄が非 ASCII)= 別データ。∴ 配列 storage = idx 0..254 |

★集計: 名前あり **244** / gate ON **223** / gate OFF **21** / 空 **11** → 223+21+11 = **255** ぴったり★

### 3.1.0 ★table 終端 — 私の「lbu ⇒ 0..255」説は**撤回**。code 上の bound は存在しない★

★**訂正(2026-08-08、worker1 の指摘で自己反証)**★
私は一度「map index は `lbu` = 符号なし byte ⇒ 定義域 0..255 ⇒ table 上限の code 根拠」と報告した。
★これは誤り★。撤回する。

**誤った理由 = 走査対象の取り違え**:
私は ★`0x8013541C` を**組み立てる** site(22 件)★ だけを列挙した。
しかし ★loader `0x800bae54` に index を渡す caller は table base を組み立てない★ ので、
★私の走査は原理的にその経路を見られなかった★。母集団を「index を運ぶ全経路」でなく
「table base を作る site」に取ったことが誤りの正体(「sink を全列挙せよ」の適用先を間違えた)。

**実際の経路**【観測、disasm 再確認】:

| 位置 | 命令 | 幅 |
|---|---|---|
| `0x800EC47C` | `lhu $a0, -0x6ca6($gp)` → `jal 0x800DF7D0` | ★halfword★ |
| `0x800AC760` | `lh $a1, 0x2c($sp)` → `0x800AC764 jal 0x800BAE54` | ★halfword★ |
| loader 内 `0x800BAE80` | `lh $v0, 0x24($sp)` → `sll 4` | ★halfword、mask も clamp も無し★ |

★`jal 0x800BAE54` の caller は `0x800AC764` の **1 件のみ**★(全 text 走査)。
★`jal 0x800DF7D0` の caller は `0x800EC480` の **1 件のみ**★。
∴ loader に届く index は ★16bit のまま★。★worker1 の `PBR_P0_RAM_INVENTORY_worker1.md` §「map index は byte だから 256 で切れる = 不成立」が正しい★。

**では `lbu` site は何だったのか**:
`0x8013541C` を index する 22 site のうち、供給元を解決できたのは 11 件:

| 供給元 VA | load | site | ram_A..ram_live×5 の値 |
|---|---|---|---|
| ★`0x8013E07C`(gp-0x6d90)★ | `lbu` | `0x800AF2A8` / `0x800DF398` / `0x800E07D0` / `0x800EA72C` | ★109 = MAYO00★(5/5) |
| ★`0x801693B6`(lui 0x8017 −0x6c4a)★ | `lbu` | `0x8010E058` / `0x8010EDFC` / `0x8010FC78` | ★173 = TWNA07★(5/5) |
| stack(関数引数) | `lh`/`lw` | `0x800BAE80` / `0x800E0194` / `0x800E3F0C` / `0x800E425C` | — |

→ ★byte で読む site は実在するが、それらは loader 経路と別の読み手★。
★1 つの変数が byte で読まれることは、別の変数の定義域を縛らない★ — これが私の推論の穴だった。

**∴ table 終端の現状**: ★code は index を clamp しない★。
「255 で終わる」は依然 ★形状根拠のみ★(idx 0..254 が record 形状 / idx 255 は非整合)。
★code 上の bound は「存在しないことが分かった」= 未確定のまま★。

### 3.1.1 ★name の重複 1 組 — YAKA25★【観測、本 session 新規】

★名前あり 244 entry のうち `YAKA25` だけが 2 箇所に出る★ = distinct name は **243**。

| idx | numImg | numObj | flags | gate | header q | elements_off | 自己整合(parse 終端 == tilemap_off) |
|---|---|---|---|---|---|---|---|
| 65 | 0 | 0 | 0x44 | ★OFF★ | 0x04 | 0x100 | ★不成立★(count = 7636 = 範囲外) |
| ★232★ | 2 | 0 | 0xC4 | ★ON★ | 0x10 | 0x2057C | ★成立(count=0、gap 0)★ |

★`numImg` が違うと header 内の `elements_off` の位置が 12 byte ずれる★ため、
★どちらの entry で開くかで「同じ .map file から読める placement」が変わる★。
自己整合するのは ★idx 232 のみ★ ⇒ **idx 65 側の metadata は stale/誤り**【観測】。

★第 2 軸: 到達性(構造整合と直交)★【観測】 — CD 242 map の `warp_target_map` 全列挙:

| index | 被参照 | 参照元 |
|---|---|---|
| ★65★ | ★**0**★ | — |
| ★232★ | ★**1**★ | `YAKA11B` spawn slot 0 |

→ ★`idx 232` は **実際に warp から参照されている**(陽性の確認)★
⇒ 構造整合と合わせ ★`idx 232` が権威★。★「同名 2 map が両方生きている」事態ではない★ ⇒ 挙動問題への格上げは不要。

★**この軸の強さについての訂正(2026-08-08)**★
私は当初「idx65 被参照 0 ⇒ 到達不能な残骸」と書いたが、★**これは言い過ぎ**★。§4.5 のとおり
★実在する gate ON map の 39%(223 中 87 件)も warp 被参照 0★ である。
∴ ★「warp 被参照 0」は「到達不能」をほぼ含意しない★。
- ★有効なのは陽性側だけ★: 「idx232 は参照されている」は主張できる
- ★「idx65 は到達不能」は主張できない★。第 2 軸は ★片側のみの弱い証拠★に格下げする
- ★idx232 権威の主根拠は構造整合(自己整合するのは idx232 のみ)★のまま

参考: `YAKA01`(idx50) / `YAKA21`(idx61) は被参照 0 かつ ★.map file 自体が無い★ =
こちらは file 不在という独立の理由で残骸と判断できる。
★honest gap: scenario VM 経由の map 遷移は未調査★。

- 本 doc の全 parse は名前 key の last-wins で ★idx 232 を採用★しており、`convert_map.py` の `load_map_entries()` も
  同じ last-wins ⇒ 抽出済 json と一致する。**偶然一致ではなく同一規則**
- ★Phase 1 の hazard★: map を **index で** 引く実装にすると、idx 65 経由の YAKA25 は
  ★gate OFF かつ header 解釈違い★になる。「YAKA25 = NPC の出ない map」も
  ★到達 index 依存★であって map 固有の性質ではない

### 3.1.2 file と entry の突合【観測】

- CD 上 `.map` = **242**
- ★entry はあるが CD に .map が無い = 2 件: `YAKA01`(idx 50) / `YAKA21`(idx 61)★(いずれも gate OFF)
- ★CD にあるが entry が無い = 1 件: `MGEN17`★

検算: ★distinct 243 − (dir 無し 2) + (table 無し 1) = **242** = extracted dir 数 = CD .map 数★
(`extracted/maps/` の dir 集合と CD `.map` の名前集合は ★完全一致★【観測】)

### 3.1.2.1 ★「gate OFF かつ numImg=0 = stale slot の signature」説 → **棄却**★【観測】

boss1 仮説を全数で検定した。判定器は §2.1 の非循環 oracle(★その entry の numImg/numObj で header を解いて
parse 終端が `tilemap_off` に一致するか★)。

**(i) OFF かつ numImg=0 の entry = 8 件、うち file を持つ 6 件の判定**

| entry | idx | 自己整合 | 備考 |
|---|---|---|---|
| YAKA01 | 50 | — | ★file 無し = 判定不能★ |
| YAKA21 | 61 | — | ★file 無し = 判定不能★ |
| YAKA25 | 65 | ★False★ | count = 7636 = 範囲外 |
| FRZL05 | 92 | ★**True**★ | count=0, gap=0 |
| TUNN08_2 | 124 | ★**True**★ | count=0, gap=0 |
| MGEN14 | 229 | ★**True**★ | count=0, gap=0 |
| MGEN15 | 230 | ★**True**★ | count=0, gap=0 |
| MGEN16 | 231 | ★**True**★ | count=0, gap=0 |

→ ★6 件中 5 件が自己整合。「OFF かつ numImg=0」は stale の**十分条件でない**★

**(ii) 逆向き: file を持つ 244−2 = 242 entry を個別判定し、不成立を全数列挙**

| entry | idx | gate | numImg | 破綻 |
|---|---|---|---|---|
| YAKA22 | 62 | OFF | ★**3**★ | wp_count = -32640 |
| YAKA25 | 65 | OFF | 0 | count = 7636 |

→ ★`YAKA22` は numImg=3 で破綻 = 「numImg=0」は stale の**必要条件でもない**★

★∴ signature 説は両側から棄却★。numImg は判別に効かない。

**代わりに得られた不変条件**【観測】:
- ★不成立は 242 entry 中 **2 件のみ**、いずれも gate OFF★
- ★**gate ON の 223 entry は 223/223 すべて自己整合**★
→ Phase 1 が実際に使う集合(gate ON)では header 解釈が全数で裏取り済み。
  逆(gate OFF ⇒ 破綻)は成立しない(OFF 19 件中 17 件は自己整合)。

★`MGEN17` の正確な言い方★:
- ★map table(idx 0..254 全走査)に entry は無い★【観測】
- ★ただし ASCII `"MGEN17"` は EXE の**別領域**に実在★: `slps_017.97.orig` file offset ★`0x94AD8` / `0x94AE4`★
  (table 領域 = `0xA541C`..`0xA640C` の**外**)【観測】
- ∴ ★「map table に無い」は確定、「EXE に無い」は偽★。別機構(scenario 直接 load 等)からの参照可否は ★未調査 = 未検証★

### 3.2 raw count 全数分布(生 bytes、gate 無関係)

| count | map 数 |
|---|---|
| 0 | 24 |
| 1 | 33 |
| 2 | 22 |
| 3 | 26 |
| 4 | 30 |
| 5 | 20 |
| 6 | 29 |
| 7 | 8 |
| ★8★ | ★48★ |
| 63 | 1 (YAKA22) |

★gate ON(flags&0x80、loader が実際に回る)223 map のみ: **最大 = 8**、9 以上は 1 件も無し★
★gate ON 223 の raw 合計 = **989**★。内訳の照合は §3.5。

(母集団の対応: 名前あり entry 244 − .map 無し 2(YAKA01/YAKA21) = 242 entry に file がある。
そのうち ON 223 / OFF 19。`YAKA25` は idx 65=OFF と idx 232=ON の両方に出るため、
**entry 基準の OFF は 21、file 基準の OFF は 19、YAKA25 を idx 232 に解決した file 基準では 18**。
★3 つの数はすべて同じ bytes から出ており、違うのは母集団定義だけ★)

### 3.2.1 ★YAKA22 = 63 の offset 明示(worker1 相互検証用)★

| 項目 | 値 |
|---|---|
| table entry (idx 62) raw16 | `59 41 4b 41 32 32 00 00 00 00 03 00 44 0a 00 1b` |
| name / numImg / numObj / flags | `YAKA22` / 3 / 0 / ★0x44 = gate OFF★ |
| file | `CD/DEGIMON/map/map5/yaka22.map`(size `0x33BF2`) |
| header q | `4 + 4*3 + 0 + 4(obj_off) = 0x14` |
| `elements_off` | ★`0x31440`★ |
| `tilemap_off` | ★`0x314E2`★ |
| ★count halfword の file offset★ | ★`elements_off + 120` = `0x31440 + 0x78` = **`0x314B8`**★ |
| その 2 byte | `3f 00` → s16 = ★**63**★ |

★決定的な点: elements block の全長は `0x314E2 − 0x31440` = `0xA2` = **162 B**★
= spawn/warp 120 B + count 2 B + ★残り 40 B のみ★。
★63 record(最低でも 63×84 = 5292 B)は物理的に入らない★。
record0 の `wp_count`(r33)を読む位置は `0x314FC` で、これは既に ★`tilemap_off` を越えている★
(= tilemap を読んで `-32640` が出た)。

∴ ★`63` は「entity 数」ではなく、そもそも placement section が存在しない map の残バイト★【観測】。
かつ ★gate OFF ゆえ loader は 1 byte も読まない★ = 実行時に無害。

★実装への含意は数値ではなく control flow から出る★: assert を gating の**内側**に置く根拠は
「gate OFF なら loop 全 skip(`0x800baea4 beqz → 0x800bb500`)」であって、63 という数値ではない。

### 3.3 配列容量 = 8【観測、disasm】

- clear routine の loop 終端 = ★`0x800bbc00  slti $at, $s0, 8`★(8 record を `0xFFFF` で埋める)
- 別 loop(`0x800bbc54`)も `slti 8`
- 後述 §5 の 2 routine も `slti 8`
→ ★entity array 容量 = 8 record(`0x80145608` .. `0x80145608 + 8*0xC4` = `0x80145EC8`)★

★loader 側に clamp は無い★: loop 条件は `0x800bb4f4 slt $s2, [sp+0x1c]` のみ = ★stream の count halfword だけが上限★。
count > 8 の .map を食わせれば境界外へ書く。ただし原盤 shipped data では gate ON 最大 8 ゆえ ★実際には発生しない★。

→ **remake への含意**: clamp は忠実性の観点では不要(データ側が 8 以内)。
入れる場合も「原盤と挙動が変わる入力」は空集合なので忠実性を損なわない。推奨 = ★8 で assert し超過は data 異常として fail-fast★。

### 3.4 ★飽和 caveat(必読)★

★48 map(gate ON の 21.5%)が丁度 8 = cap に張り付いている★。
∴ bytes から言えるのは「**原盤データは 8 を超えない**」までで、
★「8 で足りていた / authoring 時に切り詰められていない」は**言えない**★(「打ち切られた list の不在は否定でない」と同型)。
Phase 1 でこの数字を引用する際は必ず飽和を併記すること。

### 3.5 json 件数との差分 — ★全数列挙(数値一致でなく map 名で)★

★gate ON 223 map を 1 件ずつ raw count と json 件数で照合した結果、不一致は次の 5 件が**すべて**★【観測】:

| map | idx | flags | raw | json | table 領域 |
|---|---|---|---|---|---|
| MGEN06 | 247 | 0xD1(★ON★) | 6 | ★0★ | sparse tail |
| MGEN07 | 248 | 0xD1(★ON★) | 3 | ★0★ | sparse tail |
| MGEN08 | 249 | 0xD1(★ON★) | 4 | ★0★ | sparse tail |
| MGEN09 | 253 | 0xD1(★ON★) | 3 | ★0★ | sparse tail |
| MGEN10 | 254 | 0xD1(★ON★) | 7 | ★0★ | sparse tail |

- ★連続領域 218 map の中に不一致は **0 件**★
- 合計差 = 6+3+4+3+7 = ★23★ = **989 − 966**
- ★これは「23 という数が合った」ではなく「差分 map を全数列挙したら 5 件でその和が 23 だった」★

**原因**: 抽出パイプラインが sparse tail の 5 entry を拾えていない
(`extracted/maps/mgen0*/` の json は `digimon: []`)。

★**「未使用 map ゆえ無害」は成立しない**★ — MGEN06-10 は ★gate ON★ なので、
原盤 loader はこの map に入れば entity を load する。∴ ★gate ON map における実害のある抽出 gap★。
Phase 1 で「json = 原盤 placement」と仮定する前に潰す必要がある。

**到達性について(断定しない)**【観測 + honest gap】:
- CD 242 map の spawn_points `warp_target_map` を生 bytes から全列挙 → ★idx 247/248/249/253/254 を指す warp は **0 件**★
- ★**訂正**: 私は一度「`extracted/warp_data.json` 側でも出現 0」と書いたが、★同 file は **8 map 分しか収録していない部分抽出**★
  であり、★打ち切られた list を根拠に不在を主張していた★。この論拠は撤回する(自分の claim にも同じ規律を適用)。
  有効な母集団は ★242 map 全数の生 bytes 列挙★のみ
- ただし ★warp は経路の 1 つに過ぎない★。scenario VM の map 遷移 opcode 経由の到達は ★未調査 = 未検証★
- ∴ ★「242 map の warp からは到達しない」までが観測。「未使用」「無害」は主張しない★

(参考: warp target で 239 以上を指すのは `YAKA22` の 1104 / 792 のみ。
これは §3.2.1 のとおり placement section 自体が存在しない map の残バイトで、json 側も同値 = 私の parser 側の誤りではない)

---

## 4. (b) gating — ★静的に閉じた(RAM 不要だった)★

★`map_entries.json` の `table_offset: "0xA541C"` = VA `0x80090800 + (0xA541C - 0x800)` = ★`0x8013541C`★★
= loader が `[0x8013541C + mapIdx*16].byte12 & 0x80` で読む gating table **そのもの**。

### 4.1 entry 構造(16 B)【観測、bytes 直読】

```
+0x00  name[10]  (ASCII, zero pad)
+0x0A  numMapImages
+0x0B  numMapObjects
+0x0C  ★flags(= loader の byte12)★
+0x0D  doorsId
+0x0E  toiletId
+0x0F  loadingNameId
```

### 4.2 tool audit

- EXE 生 byte12 vs `map_entries.json` の `flags` = ★255/255 一致★
- `hasDigimon` vs `flags & 0x80` = ★255/255 一致★
→ ★`convert_map.py` は既に gating を実装していた★(`hasDigimon` false → `digimon: []`)。
  ∴ gate OFF map で json が 0 件なのは**正しい**。§3.5 の MGEN06-10 は gate ON なので別問題。

### 4.3 runtime 書換の有無

`ram_A.bin` / `ram_B.bin` / `ram_live_1628_1,2,3.bin` の 5 dump すべてで、
`0x8013541C` から 255*16 = 4080 B が ★EXE と byte 完全一致(entry 差分 0 / byte12 差分 0)★【観測】

→ ★gating table は静的。scenario 進行で書き換わらない(少なくともこの 5 capture では)★

### 4.4 OFF map 一覧(flags & 0x80 == 0)

★entry 基準 = 21 件★:
`MAYO10`(13) / `YAKA01, YAKA11B, YAKA12, YAKA15, YAKA18, YAKA21, YAKA22, YAKA23, YAKA24, ★YAKA25(idx 65)★`(68) /
`KODA05`(5) / `FRZL05`(11) / `TUNN07_2, TUNN08_2, TUNN03_2`(66) / `OGRE04`(70) / `FACT05`(8) / `MGEN14, MGEN15, MGEN16`(81)

★注意 2 点★:
- `YAKA01` / `YAKA21` は ★CD に .map file が無い★(entry のみ)⇒ file 基準では 19 件
- ★`YAKA25` は idx 65 = OFF だが idx 232 = **ON**★(§3.1.1)。∴ ★「YAKA25 は NPC が出ない」は誤り★。
  到達 index 依存。名前 key で idx 232 に解決すると file 基準 OFF は 18 件

空 entry 11 件(idx 239-246, 250-252)は名前も flags も 0 = gate OFF 相当だが、
★上記 21 件とは別枠(未使用 slot)★として数えている。

### 4.5 ★空 slot への到達性 cross-check、および **warp oracle 自体の被覆率**★【観測】

boss1 の latent 指摘(remake の権威 table が 244 件で ★空 slot 11 個を持たない★ →
原盤は index 無検査で gate byte 0 → loop 全 skip = 静かに NPC なし / remake は ★lookup miss★ で挙動が違う)
に対する cross-check。母集団は ★全数★(部分抽出 file 不使用)。

**測定**: CD 242 map(table entry を持つ 241 map、spawn slot 2410 個、うち有効 468 個)の
`warp_target_map` を生 bytes から全列挙。

| 対象 | warp 被参照 |
|---|---|
| 空 slot idx 239-246 | 各 ★0★ |
| 空 slot idx 250-252 | 各 ★0★ |
| ★合計★ | ★**0 件**★ |

★ただし、この 0 はほとんど何も否定しない★ — ★**oracle 自体の被覆率を測ったため**★:

| 指標 | 値 |
|---|---|
| 参照された distinct index | ★150★ |
| 名前あり entry(distinct) | 243 |
| gate ON entry | 223 |
| ★うち warp 被参照 **0** の実在 map★ | ★**87 件 = 39%**★ |

例(実在する gate ON map なのに warp 被参照 0): `MAYO08B` / `MIHA03` / `MIHA04B` / `CHKA01` /
`GIAS06A` / `ICSA02`〜`ICSA08` …

★∴ 「warp から参照されない」は「到達不能」を意味しない★。
実在 map の 39% が同じ状態にあり、★別の遷移機構(scenario VM 等)が主要経路として存在する★ことを示している。

**含意**:
- ★boss1 の「255 slot 全部を持たせる」差し戻しは正しい★。
  「現データで発火しないから省略」の根拠として warp 被参照 0 は ★使えない★
- 私の §3.5「MGEN06-10 は warp から到達しない」も同じ限界を持つ。★測定としては有効、不在の証明としては無効★
- ★scenario VM の map 遷移経路の全列挙が、到達性を語るための前提★ = ★未調査 = honest gap★

(範囲外参照: `YAKA22#0 → 1104` / `YAKA22#1 → 792` の 2 件のみ。§3.2.1 のとおり同 map の elements block は
実体を持たないため、これは placement データではない残バイト)

これらの map では ★loop 全 skip = RAM に record が入らない★。
remake が gating を再現しないと、原盤で NPC が出ない map にも出る。

---

## 5. ★副産物: entity array に触る全 code site の列挙★【観測、本 session 新規】

「sink を全列挙せよ」に従い、EXE 全 text を word 走査して `lui 0x8014 + addiu 0x5608`(= base materialize)を全数抽出。

★base `0x80145608` を組み立てる site = 45 個 / 近接 **2 群**★

| 群 | 範囲 | 正体 |
|---|---|---|
| A | `0x800baedc .. 0x800bbe78`(38 site) | ★loader(populate)+ clear★ = 既知 |
| B | ★`0x800bd644 .. 0x800bd980`(7 site)★ | ★本 session 新規発見★ |

### 5.1 群 B の中身【観測、disasm】

**B-1: `0x800bd5c0` — script_id で slot を引いて位置を書き換える routine**
- 8 slot を走査し `arr2[slot]+0x65`(= ★loader が r10 で書いた script_id★)を引数 byte と比較
- 一致 slot について `entity[i].pos.x(+0xA8)` / `.pos.z(+0xAC)` を ★新しい値で上書き★し、
  同じ delta で waypoint 8 個を平行移動
→ ★**NPC 位置は runtime に書き換わりうる**。静的 .map の position は「初期状態」であって「常に見える位置」ではない★

**B-2: `0x800bd820` — actor 単位の flag(`+0xC1`)setter**
- `a0 = -1` で 8 slot 全部に broadcast、`a0 >= 2` で `entity[a0-2]+0xC1` に `a1` を書く
- `a0 == 0` / `a0 == 1` は **別サブシステム**を呼ぶ(`0x800ace24` / `0x800ebd48`)
→ ★actor id 空間 = {0, 1, 2..9} で、2 以降だけが field entity array★【観測】
→ ★**0 と 1 は entity array に載っていない別枠**★【観測】。
  「0=player / 1=partner」という割付は **【推論・未検証】**(分岐先 routine の中身は未解析)。

★この 2 点は §6 の「画に写る個体 ≠ entity array の record」を **code 側から**支える★。

---

## 6. ★視覚反証(798,-1656)黄creature の oracle 監査★

### 6.0 結論

★**別サブシステム(勧誘住人)由来ゆえ、Phase 0 の判定材料から除外する**★

★「反証は無かった」ではない★。観測自体は実在する原盤の画である。
除外の理由は ★観測対象のカテゴリが違った★ことにある(静的 map placement ではなく、勧誘フラグ駆動の街住人)。
この区別を落とすと後世が「視覚観測は当てにならない」と誤読するので、必ず理由まで残すこと。

### 6.1 一次証拠の特定【観測】

| 項目 | 内容 |
|---|---|
| 一次 doc | `workspace/degimon-faithful178/VISE_NPC_TOKO_scale_proxy.md`(★worker3 = 私自身、2026-07-23★) |
| 該当記述 | L88「_9 rendered frame = boy中央 + 緑TANEMON左 + 黄creature右」/ L94「critical species disconnect」/ L111「タネモン(798)実render=純黄(207,177,0)」/ L148「pure yellow 207,177,0」 |
| ★一次画像★ | `probe_sresume.png` / `orig_ss9`(= `_9` frame)= ★現存しない★。`find` で不在確認 |
| ★元 savestate★ | `SLPS-01797_9` = ★不在★(boss1 §2.2: `~/.local/share/duckstation/savestates/` は空) |

→ ★一次証拠は再測定不能★。以下はすべて **doc に記録された数値と記述**への監査であり、画素の再検証ではない【honest gap】。

### 6.2 帰属連鎖の破断(座標 → 個体)

「画中の黄い個体 = (798,-1656)」という帰属は、以下 2 段を通っていた。★どちらも後に撤回・失効している★:

1. **同 depth 論**: worker1 の当時の読みで player=(-103,-1623)、slot2=(798,-1656)、Z がほぼ同じ → 同 depth → 隣接個体 = slot2。
   → ★06:52 に player 同定が撤回★(実 player = (-647,-3108))。私自身が同 doc L103 に
   「★0.80x(boy vs 黄creature)は破棄★ … 旧『同depth』は誤 player 同定由来」と書いている。
2. **再帰属**: 同 doc L108-110 で「worker1 RAM ★+0x22★ type 直読」+「X 順一致(緑左/黄右)」で再度 (798,-1656) に結び付けた。
   → ★+0x22 読みは 8/8 に測定 artifact 確定★(§2.4 で静的側からも裏取り)。また X 順一致は ★投影計算ではない heuristic★。

★∴ 座標 → 個体の帰属は、投影で決まったことが一度も無い★。7/23 triage §6 の「position 推論で外し続けた」自認と同じ穴。

### 6.3 ★確認 loop だった(独立 2 証拠ではない)★

7/23 triage doc(`unity/Assets/ViseAvatar/JSON_NPC_OFFBYONE_TRIAGE.md`)冒頭、verbatim:

> **発見経緯**: 2a species verify 中、worker3 の視覚反証(「(798,-1656)=黄 creature≠私が claim した白トコモン」)を受け、
> position-match oracle を疑い RAM entity type field を直読 → json との系統的不一致を検出。

★視覚 claim が RAM 探索を起動し、その RAM 読み(誤 anchor)が視覚 claim を追認した★。
= 相互独立な 2 証拠ではなく ★1 本の確認 loop★。「oracle を検証せよ(一致でなく)」の典型。

### 6.4 色は shifted も unshifted も支持しない

記録値 (207,177,0) を原盤 texture(vise が disc から抽出、`/home/ken/Desktop/vise/extracted/textures/digimon/`)と突合【観測】:

| code | 原盤 tex 最頻色 | 観測色との距離 | ★観測色 ±10 の面積★ |
|---|---|---|---|
| `agum` | (222,189,0) | 19.2 | ★17.7%★ |
| `tane` | (148,132,99) | 123.7 | ★0.0%★ |
| `toko` | (197,181,181) | 181.3 | ★0.0%★ |
| `yura` | (214,214,189) | 192.7 | ★0.0%★ |

- unshifted の予測 = トコモン(白) → ★外す★
- shifted の予測 = タネモン(オリーブ/淡黄緑) → ★同じく外す★
★∴ この観測は 2 仮説を**弁別しない**★。片方だけを否定する datum ではなかった。
(同 doc L111 で私自身が「canonical 緑と乖離 = type read 二重確認推奨」と flag していたが、追わなかった。)

★caveat★: これは texture 色との比較であり、in-game の照明/dither/半透明枠を通した色ではない。
私は crop 単位の分類器も作ったが ★対照実験(白 Tokomon / ジジモン)で誤判定したため破棄した★(「自分の道具を疑え」)。
単一色比較のみを採用。

### 6.5 marker 説(boss1 提案)の検証 → ★棄却★

boss1 仮説 = 「7/23 の remake は NPC を黄 sphere marker で描いていた」。検証結果:

- ★marker の実在は確認★: 7/23 時点の `EntityPlacer.cs`(HEAD = `d04a9a2`, 06-17)は
  `GameObject.CreatePrimitive(Sphere)` + `Shader "Unlit/Color"` + `new Color(1f, 0.9f, 0.2f)` + `localScale 0.5`【観測】
  field-model 配線(`48f25ac`)は ★07-25 03:42★ = 7/23 には無い【観測】
- ★しかし当該観測には当てはまらない★:
  - marker は **Unlit** = 陰影ゼロの平坦 ★(255,230,51)★。記録値 (207,177,0) は全 channel で 48-51 ずれる。B は 51 → 0
  - 記録された形状記述 = 「白腹 / 赤眼」「Agumon 様 rookie」、かつ ★head_y と feet_y を分けて測っている★ = 球では不可能
  - `probe_sresume.png` は ★319x224 / software renderer★ = DuckStation の PS1 出力であって Unity render ではない
  - 元 savestate 名 `SLPS-01797_9` = ★原盤★の DuckStation savestate

→ ★marker 説は棄却。観測は原盤の画である★(boss1 も 18:03 に自ら取り下げ済)。

**併せて時系列の訂正**【観測】: `village_species_zoom.png`(7/23 12:22)は ★remake の 3D モデル render★
(TOKO 白 / YURA 紫 / TANE 緑、球ではない)。∴「7/23 の remake は marker しか描けなかった」は
**EntityPlacer の field 配置経路については真だが、render 一般については偽**。

### 6.6 現存画像の素性判定【観測】

| file | 素性 | 判定根拠 | marker 色 ±12 の pixel |
|---|---|---|---|
| `orig_village_populated_ref.png` | ★原盤 capture★ | ★sha256 = `/home/ken/Pictures/Screenshots/Screenshot from 2026-07-23 04-13-10.png` と完全一致★。window title "DigimonWorld (Japan)" / 320x240 / Vulkan / PS1 対話枠「けん「ヘ?」」 | ★0★ |
| `orig_tokomon_village_white_zoom.png` | 上記の zoom | 同 frame 由来。★白い兎耳 creature★ | 0 |
| `village_species_zoom.png` | ★remake render★ | 3 panel + キャプション "emissive=0.5 baked" | 0(cluster なし) |

★`orig_village_populated_ref.png` に marker 色は 1 pixel も無い★ = 球は写っていない。

### 6.7 ★除外の決定的理由 — 街住人は別サブシステム★

**doc 側**(`EXTERNAL_RE_recruit_prosperity_2026-07-15.md`、verbatim)【観測】:

> L116: 繁栄度システムが原盤忠実に動く。★加入判定・街NPC出現は下表のフラグ read で足りる★
> L19: 勧誘 = 加入 flag + 繁栄度加算 + ★ガード flag(未実装だと勧誘済 NPC が field 再出現)★
> L173: ★街 NPC ジジモン★は加入デジモンごとに「〇〇がここに来てな…」という1行を持ち

★さらに具体的な機構が同 doc L118-126 に存在★:

> ### opcode 0x75 = NPC スポーン（12B 固定、実RAM照合済み）
> `[0x75][char_id u8][x s16][y s16][z s16][dir s16][entity_flag u16]`
> 実証: slot3 の現在マップのエンティティ3体（グレイモン 0x2C2 / ベーダモン 0x2B3 / ティラノモン 0x2BA）が
> dg.scn 該当エントリの 0x75 オペランドと完全一致。

→ ★NPC は script(dg.scn)からも spawn される★ = map placement loader `0x800bae54` とは**別の書込み経路**。

**構造側(bytes、savestate 進行度に依存しない)**【観測】:

1. ★entity array 容量 = 8★(§3.3、disasm)
2. ★twna01 の静的 record = 7★(§2.3、bytes)→ 空きは ★1 slot★
3. ∴ 原盤画に写る 9 体前後は ★物理的に entity array に収まらない★
4. ★かつ RAM entity array は json 7 record と過不足なく一致していた★(boss1 実測)。
   住人が array に載るなら勧誘の進んだセーブで余分な record が出るはずだが、出ていない
5. ★§5.1 B-2 で actor id 0/1 が entity array 外の別サブシステムであることを code から確認済★

→ ★静的 map data = **初期状態**の記述。`orig_village_populated_ref.png` = **勧誘が進んだ後期セーブ**の画★。
★対象が違うものを突き合わせていた = category error★。

### 6.8 未解決として残すもの【honest】

- ★`orig_village_populated_ref.png` がどの map かは**機械的に同定していない**★
  (bg テンプレート照合に着手したが、判定材料として不要になったため boss1 指示で中止)。
  ∴ ★この画が twna01 であるとは、本 doc は主張しない★
- 画中個体の「勧誘住人 / 静的 NPC」内訳は ★未確定★。投影による画面座標 → ps1 座標の逆写像は実施していない
- 「actor 0 = player / actor 1 = partner」は ★推論、未検証★
- 一次画像 `probe_sresume.png` / `_9` savestate は ★不在★。(207,177,0) は doc の記録値であって再測定していない

---

## 7. 新規 issue(起票のみ、Phase 1 に混ぜないこと)

★**remake は勧誘住人を原理的に再現できない**★

`EntityPlacer` は静的 json の `digimon` 配列しか見ないため、
勧誘フラグ駆動で増える街住人(opcode `0x75` spawn 系)は ★1 体も出ない★。
= 「街が繁栄しても住人が増えない」未実装領域。

実装材料 = `EXTERNAL_RE_recruit_prosperity_2026-07-15.md`(加入フラグ 43 体表 / 繁栄度 = var[1] / opcode 0x75 の 12B 固定 layout)。
★Phase 1(placement re-baseline)とは scope が別★。独立 dispatch として起票を推奨。

---

## 8. Phase 1 へ引き渡す確定事項と注意

### 確定(bytes / disasm 接地)

1. entity 数の権威 = ★.map 先頭 halfword★。固定長走査は誤り
2. record = ★42 halfword + 3×waypoint_count★、index 順 = stream 順
3. type は ★`+0x00`、補正不要★。off-by-one は測定 artifact(静的側からも §2.4 で裏取り)
4. gating = ★`[0x8013541C + mapIdx*16].byte12 & 0x80`★、静的、EXE 直読可
5. 配列容量 = ★8★、gate ON 全 map の count ≤ 8

### ★必ず併記すべき caveat★

- ★48 map が count = 8 で飽和★ → 「8 が原盤の意図した上限」とまでは言えない(§3.4)
- ★map table は idx 0..254 の 255 entry 全走査。239 で打ち切ると MGEN06-10 を落とす★(§3.1)
- ★`MGEN17` は map table に entry が無い。ただし ASCII は EXE 別領域 `0x94AD8` に実在★。
  「map table に無い」は確定、「EXE に無い」「未使用」は ★未検証★(§3.1.2)
- ★`MGEN06-10` は **gate ON** なのに json が 0 件★ = 実害のある抽出欠落(§3.5)。
  ★「未使用ゆえ無害」は成立しない★。warp からの到達は 0 件だが scenario 経由は未調査
- ★`YAKA25` は table に 2 entry(idx 65=OFF / idx 232=ON)、`numImg` 違いで header 解釈が変わる★(§3.1.1)。
  map を index で引く実装にすると挙動が変わる Phase 1 hazard
- ★NPC 位置は runtime に書き換わりうる★(§5.1 B-1)。静的 position = 初期状態
- ★cross-family 一般化はしていない★。(c) の 966 record 照合は全 family を含むが、
  RAM 突合は mayo00 / twna 系のみ。「RAM と一致する」claim を他 family へ広げないこと

---

## 付録: 再現手順

```
# EXE(権威)
/home/ken/Desktop/Digimon/degimon_world_remake/extracted/slps_017.97.orig   # header 付き
/home/ken/Desktop/Digimon/degimon_world_remake/extracted/slps_017_97.bin    # text 部、load 0x80090800
# ★extracted/SLPS_017.97 は別 build。使わないこと★

# 生 .map(原盤 CD)
/home/ken/Desktop/Digimon/degimon/CD/DEGIMON/map/map*/[name].map

# RAM dump(生 2MB、offset 0 = 0x80000000、prefix 補正不要)
workspace/degimon-faithful178/runtime_capture_2026-07-25/ram_{A,B}.bin, ram_live_1628_{1,2,3}.bin

# 本 doc の parse script(scratchpad、tree 外)
/tmp/claude-1000/.../scratchpad/mapparse.py
  parse_map(path, table_entry) -> {count, recs, elements_off, stream_off, end, tilemap_off}
  stream_off = elements_off + 120   # spawn/warp = 6 配列 × 10 halfword
```

---

## 9. ★ViseNpcBootstrap との不整合 — open、未解消(直さないこと)★

### 9.1 事実

`unity/Assets/ViseAvatar/ViseNpcBootstrap.cs` L64-66(`DEGIMON_VISE_VILLAGE=1` 経路)は
★7/23 の artifact 由来の対応★のまま:

| bootstrap の現行配置 | 正(本 doc §2.3 の bytes / RAM 実測) |
|---|---|
| `TOKO` @ (-1372,-2991) | ★`YURA` @ (-1372,-2991)★ |
| `YURA` @ (-103,-1623) | ★(-103,-1623) は script_id 8 = debug NPC = 本来非表示★ |
| `TANE` @ (798,-1656) | ★`TOKO` @ (798,-1656)★ |
| ―(未配置) | ★`TANE` @ (-839,2210)★ |

★どちらが正か★: **RAM 実測側(右列)**。根拠 = 生 `.map` stream / JSON / RAM の三点一致(§2)+
species table 直読(§2.3)+ 7/23 表が shift 規則で完全再現できること(§2.4)。

### 9.2 現状の衝突しなさと、それでも open な理由

- `EntityPlacer`(post-merge)は `DEGIMON_FIELD_MODELS=1`、bootstrap は `DEGIMON_VISE_VILLAGE=1` と
  ★env gate が別★なので、既定では同時に走らない = ★実行時衝突は起きない★
- しかし ★同じ村について 2 つの答えを repo が保持している★状態であり、
  片方(bootstrap)は ★誤りと判明した対応★である

### 9.3 ★なぜ今直さないか★

★`village_faithful_facing.png` は user が PASS 済の画★であり、bootstrap を書き換えると ★その画が変わる★。
★PASS の取り消しは user にしか決められない★(`feedback_live_visual_verify_before_completion`)。
∴ ★変更は user 視覚 gate 込みの別 dispatch★(PRESIDENT 明示)。本 Phase では ★1 byte も触らない★。

### 9.4 follow-up 登録

★FU-1: `ViseNpcBootstrap.cs` の村配置を RAM 実測対応へ是正する★
- 前提: ★user が V5 で「差し替えてよい」と回答すること★
- 内容: TOKO/YURA/TANE の座標対応を右列へ / (-839,2210) の TANE を追加 / (-103,-1623) を除外(debug NPC)
- ★NO の場合は現行を維持し、本節を「user 判断により現行維持」として更新する★

---

## 10. ★user 実視覚 gate V1-V5 — 実行可能形(queue、close しない)★

出典 = `PBR_P1_REGRESSION_ORACLE_worker2.md` P10。本節は ★手順 / env / 期待 / 比較対象★ の 4 点を補って
★依頼が来たら即実行できる形★にしたもの。★AI worker は本項目を close できない★。

### 10.0 全 V 共通の前提

**build**: ★条件1(Unity CS0 gate)+ 条件2(merge)完了後の main から build したもの★。
★pre-merge build や `degimon_world_remake-f1b/workspace/build/DegimonLive`(旧 build)は使わない★。

**起動骨格**:
```bash
export DISPLAY=:1
cd <post-merge build dir>
DEGIMON_AUTOBOOT=1 DEGIMON_AUTOBOOT_SEC=600 \
DEGIMON_BOOT_MAP=<map> [他 env] \
./DegimonLive.x86_64 -screen-fullscreen 0 -screen-width 1280 -screen-height 720
```
- `DEGIMON_BOOT_MAP`(`FieldState.cs:124`)で ★任意 map へ直接入れる★(既定 `twna01`)
- 終了 = Alt+F4 / `DEGIMON_AUTOBOOT_SEC` 経過

**prefab 前提**【観測】: `YURA/TOKO/TANE/DOKU/MODO/AGUM/JIJI` は
`Resources/ViseNpc/*_Avatar.prefab` が ★全て実在★ = ★marker fallback(黄球)にはならない★。
★黄球が出たら、それ自体が異常★(prefab 解決失敗 or type 表の miss)。

### 10.0.1 ★★比較素材の選び方(全 V 共通・最重要)★★

★静的 entity array = **初期状態**。進行状態を含む実画面と同次元で比べてはならない★
(本 session で 4 回出た誤りの型。§6.7 参照)。

**進行度は測れる**【観測 = worker3 独立再現、boss1 実測と一致】:
- ★繁栄度 = var[1] @ `0x801638DE`(u8)★
- ★加入フラグ = bitmap @ `0x80163879`(bit idx = flag id、43 体分同定済)★
- 出典 = `EXTERNAL_RE_recruit_prosperity_2026-07-15.md`(同 doc は u16→u8 を自己訂正済。★u8 で読む★)

**全 savestate 20 件の実測**:

| savestate | map | 繁栄度 | ★加入体数(実測)★ |
|---|---|---|---|
| ★`SLPS-01797_1` / `_2` / `_9` / `_10`(+ `_1.bak` / `_10.bak`)★ | ★TWNA01★ | ★0★ | ★0 / 43★ |
| `_5` | GIAS06B | 19 | 13 |
| `_4.bak` | STIC02 | 19 | 13 |
| `_4` | FRZL17 | 22 | 15 |
| `_7` | MGEN98 | 54 | 27 |
| `_resume` | TWNA13 | 69 | 30 |
| `_3` | TWNA13 | 100 | ★43 / 43★ |
| `_6` / `canon_baselineC` / `canon_care_seed_point` | MAYO01 | 0 | 0 |
| `canon_baby_point` | ROOM08 | 0 | 0 |

★claim 水準が上がった点★: 加入体数は ★flag bitmap から直接読んだ実測★であり、
「繁栄度 0 ⇒ 加入 0」という ★加算則からの推論に依存しない★。
2 指標の整合も全数で確認: ★反例 0 件(繁栄度 0 かつ加入あり = 0 / 繁栄度>0 かつ加入 0 = 0)、かつ単調★。

★∴ V2 / V3 の比較素材 = `SLPS-01797_9.sav`(TWNA01 / ★繁栄度 0 / 加入 0 体★ / entity array = 静的 7 record 一致)★
代替可: `_1` / `_2` / `_10`(同条件)。

★使ってはいけない素材★:
- ★`orig_village_populated_ref.png`★ — ★静止画ゆえ繁栄度を測れず進行度不明★、かつ
  creature が 9 体前後写っており ★繁栄度 0 の状態と整合しない★(= 勧誘住人を含む後期セーブの画)
- ★進行度を測れない任意の screenshot★

### 10.0.2 ★先に書いておく「FAIL にしない事項」(user が迷わないように)★

1. ★原盤側に勧誘住人が写っていたら、それは判定対象外★(entity array 由来でないため)。見えたら ★報告のみ★
2. ★remake には勧誘住人が出ない(未実装、§7 起票済)★。∴ ★体数が原盤より少ないのは想定内 = FAIL 条件にしない★
3. ★debug NPC(twna01 の script_id 5/6/7/8)は remake で非表示★ = 想定内(原盤側も通常プレイでは出ない)
4. ★scale / facing / 色調 / 影 は V2・V3 の対象外★(別 arc)

---

### V1 — OFF-inert(変更が既定経路に漏れていないこと)

| 項目 | 内容 |
|---|---|
| **手順** | `DEGIMON_BOOT_MAP=twna01` で起動。★`DEGIMON_FIELD_MODELS` / `DEGIMON_DEBUG_NPCS` は設定しない★ |
| **env** | `DEGIMON_AUTOBOOT=1` `DEGIMON_AUTOBOOT_SEC=600` `DEGIMON_BOOT_MAP=twna01` |
| **期待** | ★NPC は黄色い球 marker が 3 個★(script_id 9/10/11)。PS1 (-1372,0,-2991) / (798,0,-1656) / (-839,0,2210)。<br>加えて spawn marker(水色)/ warp marker(橙赤)。★種族モデルは 1 体も出ない★ |
| **比較対象** | ★merge 直前 build の同 env capture★(= remake 同士の比較。進行度の概念なし) |
| **PASS** | marker の ★個数と位置が merge 前と同一★ |
| **FAIL** | marker が動く / 増減する / 3D モデルが出る |

### V2 — ★種族対応(shift 判定に残る唯一の独立観測)★

| 項目 | 内容 |
|---|---|
| **手順** | remake: `DEGIMON_BOOT_MAP=twna01` + `DEGIMON_FIELD_MODELS=1`。<br>原盤: DuckStation で ★`SLPS-01797_9.sav` を load★(繁栄度 0 / 加入 0) |
| **env** | `DEGIMON_AUTOBOOT=1` `DEGIMON_AUTOBOOT_SEC=600` `DEGIMON_BOOT_MAP=twna01` ★`DEGIMON_FIELD_MODELS=1`★ |
| **期待(remake、post-merge = unshifted)** | (-1372,0,-2991) = ★YURA(紫がかった殻/種子)★<br>(798,0,-1656) = ★TOKO(白い丸い body + 長い耳)★<br>(-839,0,2210) = ★TANE(緑の芽/葉)★ |
| **比較対象** | ★`SLPS-01797_9.sav`(繁栄度 0 / 加入 0 体)★。★`orig_village_populated_ref.png` は使わない★ |

★★事前登録した判定基準(後から作らない)★★ — ★原盤 `_9` の (798,-1656) に何が居るか★:

| 原盤で見えたもの | 支持する説 | 帰結 |
|---|---|---|
| ★白い body + 長い耳(TOKO)★ | ★unshifted★ | ★現 land が正★ |
| ★緑の芽/葉(TANE)★ | ★shifted★ | ★land 要再検討 → 即上申★ |
| ★上記どちらでもない第三の種★ | ★H4(両説棄却)★ | ★即上申★(失敗ではなく前進) |

★補助判定 1★ — (-1372,-2991):  紫の YURA → unshifted / 白い TOKO → shifted
★補助判定 2(集合レベル、最も見分けやすい)★ — ★紫の YURA が居るか★:
- unshifted 予測 = 白 TOKO 1 / 紫 YURA 1 / 緑 TANE 1 の ★3 種各 1 体★
- shifted 予測 = 白 TOKO 1 / 緑 TANE ★2 体★ / ★紫 YURA は 0 体★
→ ★「紫の個体が居るか居ないか」だけで 2 説が割れる★

### V3 — (-839,2210) の TANE

| 項目 | 内容 |
|---|---|
| **手順** | V2 と同一起動。★(-839,0,2210) は z が +側 = 他 3 体(z ≈ -1600〜-2991)と ★map の反対側★★ |
| **env** | V2 と同一 |
| **期待** | world 上 (-839,0,2210) に ★TANE(緑の芽)が 1 体★。現行 bootstrap 版では ★ここに何も居ない★ |
| **比較対象** | ★`SLPS-01797_9.sav`(繁栄度 0 / 加入 0)★ |
| **PASS** | TANE が居る |
| **★FAIL にしない★** | ★初期 framing に入らず画面外の可能性が高い★。★見えない = 不在と即断しない★。<br>スクロール/移動して確認できなければ ★「未確認」として残す★(FAIL にしない) |

### V4 — mayo00 の同座標 2 体

| 項目 | 内容 |
|---|---|
| **手順** | `DEGIMON_BOOT_MAP=mayo00` + `DEGIMON_FIELD_MODELS=1`。★mayo00 に debug NPC gate は無い = 5 体すべて出る★ |
| **env** | `DEGIMON_AUTOBOOT=1` `DEGIMON_AUTOBOOT_SEC=600` `DEGIMON_BOOT_MAP=mayo00` `DEGIMON_FIELD_MODELS=1` |
| **期待** | (594,0,2347) に ★DOKU(ドクネモン)と MODO(モドキベタモン)が **同座標で重なる**★<br>(327,0,-1500) にも ★同じ 2 種が重なる★<br>(-226,0,1688) に ★AGUM(アグモン)1 体★ |
| **比較対象** | ★数値 oracle = `ram_A.bin` / `ram_B.bin`(mayo00 の生 RAM、entity array 5 record 一致確認済)★ |
| **★素材の穴(honest)★** | ★視覚比較用の原盤 mayo00 capture は現存しない★。<br>必要なら user に mayo00 の savestate を 1 つ取ってもらう。★その savestate の繁栄度を測ってから oracle にする★。<br>★`_6` / `canon_baselineC` / `canon_care_seed_point` は MAYO0**1**(mayo00 ではない)+ entity array 全 0 = 使えない★ |
| **PASS** | 同座標 2 体の重なりが原盤と同じ見え方(前後関係を含む) |

### V5 — bootstrap 村 render を差し替えてよいか

| 項目 | 内容 |
|---|---|
| **手順** | 2 枚を並べる: ①現行 bootstrap 版(`DEGIMON_VISE_VILLAGE=1` 経路)②新 placement(V2 と同一 env) |
| **env** | ① `VISE_NPC_MODE=<既存設定>` + `DEGIMON_VISE_VILLAGE=1`(+ 必要なら `DEGIMON_VISE_VILLAGE_FACING`)<br>② `DEGIMON_BOOT_MAP=twna01` `DEGIMON_FIELD_MODELS=1` |
| **期待** | ①は §9.1 左列の配置(TOKO@-1372 / YURA@-103 / TANE@798)、②は右列(YURA@-1372 / TOKO@798 / TANE@-839) |
| **比較対象** | ★`village_faithful_facing.png`(user PASS 済、sha256 先頭 `732a630ec3c6`)★ |
| **判定** | ★user が「差し替えてよいか」を決める。AI は正否を判定しない★ |
| **NO の場合** | ★現行を維持し、§9.4 FU-1 を「user 判断により現行維持」として更新★ |

---

### 10.9 この gate の限界(先に明記)

- ★V1-V5 は AI worker が close できない★(`feedback_ai_worker_capability_boundary`)。
  headless capture / cargo 緑 / codex LGTM は ★代替にならない★
- ★V2 の原盤側観測は savestate 1 系統(繁栄度 0 の twna01)に依存★。
  他 map・他進行度への一般化はしない(cross-family 一般化禁止)
- ★V4 は原盤の視覚素材が無い★ = 現時点では ★数値 oracle 止まり★

---

## 11. ★user 実視覚 gate V2 / V2R — 最終形★

### 11.0 設計(PRESIDENT 裁定 2026-08-08 19:18 反映)

★**V2(原盤を見る)と V2R(remake を見る)は別物。順序は原盤が先**★

| | 見るもの | 何を検証するか |
|---|---|---|
| ★V2★ | ★原盤(DuckStation + `SLPS-01797_9`)★ | ★`.map` bytes → type id → species table → 画面上の実個体★ の **end-to-end**。<br>★bytes の決着が原盤の実ピクセルと出会う唯一の場所★ = 独立価値はここにある |
| ★V2R★ | ★remake(post-merge build)★ | ★完成 claim 凍結解除の要件★: 起動する / 3 体が正しい位置に出る / marker fallback も crash も無い |

★V2R は shift 判定にならない★: post-merge の remake は ★必ず unshifted を描く★ため、
remake を見て種を数えても ★実装の自己確認(同語反復)★ にしかならない。

### 11.1 ★訊き方 = 自由記述。選択肢も色語も種名も出さない★

★理由★: ★色語もモデル名も、我々のカテゴリを user に押し付ける★。
特に ★我々が確定した色は remake 側の色であり、原盤の色と一致する保証が無い★。
∴ ★原盤の観察を remake の色語で採点してはならない★。自由記述なら:
- 第三の種(H4)が出ても ★自然に捕まる★
- 我々の期待に user の言葉を寄せる圧力が ★かからない★

対応表の適用は ★我々が後から行う★(§11.4)。

### 11.2 ★blind は既に壊れている(取り繕わない)★

★PRESIDENT が直前の user 向けメッセージで「紫が居れば今回の実装が正しい」という対応表を開示済★。
∴ ★V2 は blind observation ではない★【事実として記録】。

★証拠力の非対称(重要)★:
- ★開示済みであることは「一致した場合」の証拠力を **下げる**★(期待に沿った報告が混じりうる)
- ★しかし「不一致だった場合」の証拠力は **下げない**★(開示された期待に逆らう報告は、むしろ強い)
→ ★∴ 一致しても「決定的」とは書かない。不一致なら額面どおり受け取る★

★pre-registration は別途成立★: 判定表は ★user 提示前に doc 化済★(§11.4)であり、
★後から基準を作っていないこと★ は blind の破れとは独立に有効。

---

### 11.3 ★user 提示文(そのまま渡せる形)★

#### 【先に】V2 — 原盤の村を見てください

**やること**
DuckStation で savestate ★`SLPS-01797_9`★ を load し、★はじまりの街(twna01)の村★ を見てください。

**質問(1 つだけです)**

### ★村に居る生き物を、見えたまま書いてください★

- ★何体居るか★
- ★それぞれどんな見た目か★(形・色・特徴を、思ったままの言葉で)

★選択肢はありません。我々の用語に合わせる必要もありません。★
★「わからない」「うまく言えない」も、そのまま書いてください。★
★スクリーンショットを添えていただけると確実です(任意)。★

**答えなくてよいこと**
1. ★村人(勧誘で増えるデジモン)が写っていても対象外★です
2. ★大きさ・向き・影・画質は今回の対象外★です
3. ★見慣れないものが居たら、判定せずそのまま書いてください★

---

#### 【V2 に回答をいただいた後】V2R — remake を起動して同じ村を見てください

**やること**
post-merge build を起動し、はじまりの街(twna01)の村を見てください。

**見ていただきたいこと(3 点)**
1. ★起動して村が表示されるか★
2. ★生き物が 3 体出ているか★(位置がバラバラでなく、村の中に配置されているか)
3. ★黄色い球★ が出ていないか — ★出ていたらそれは生き物ではなく **不具合** です。そのまま教えてください★

★V2R は「原盤とどちらが正しいか」を判断していただくものではありません★。
★動くこと・出ること・壊れていないことの確認★です。

---

### 11.4 ★採点用(user には見せない)★

★user 提示前に確定済 = pre-registration 成立★。適用は我々が後から行う。

**対応表(remake 側の色。★原盤の色と一致する保証は無い★)**

| 種 | code | remake での見え方 |
|---|---|---|
| トコモン | TOKO | 白い丸い体 + 長い耳 |
| ユラモン | YURA | 紫がかった殻 / 種 |
| タネモン | TANE | 緑の芽 / 葉 |

**位置 × 種の期待(unshifted = 今回の実装)**

| PS1 座標 | script_id | 期待する種 |
|---|---|---|
| (-1372, 0, -2991) | 9 | ★YURA★ |
| (798, 0, -1656) | 10 | ★TOKO★ |
| (-839, 0, 2210) | 11 | ★TANE★(map 反対側 = 画面外の公算) |

**判定(user の自由記述を我々が分類する)**

| user の記述から読み取れる構成 | 判定 |
|---|---|
| 白系 1 / ★紫系 1★ / 緑系 1 | ★unshifted(今回の実装)を支持★ — ★ただし §11.2 により「決定的」とは書かない★ |
| 白系 1 / 緑系 2 / ★紫系なし★ | ★shifted を支持 = 実装を見直す★ — ★開示された期待に逆らう報告ゆえ証拠力は減じない★ |
| 上のどちらでもない構成 / 第三の種 | ★H4(両説棄却)= 即上申★。★失敗ではなく前進★ |
| 記述が種を判別できる粒度に達しない | ★判定保留★。追加の pass を設計する(★無理に分類しない★) |

★分類は user にさせない★。★user の言葉を我々の語に翻訳した過程も doc に残すこと★(後から検証できるように)。

---

### 11.5 V1 / V3 / V4 / V5 の扱い(今回は同時提示しない)

- ★V3 = V2 回答後の別 pass★。理由は ★機構★: V2 の判定は ★「見えている集合の中に何が居るか」★ という集合レベルの観測に依存する。
  V3 の対象 (-839, 2210) は ★map の反対側(z が +側)★ で確認にスクロール / 移動が要り、
  ★user が探しに動くと「見えている集合」自体が変わって V2 の依存する同一性が壊れる★(PRESIDENT 採用済)
- V1 = ★remake 同士の比較★ → capture 差分で足り、user の目は不要
- V4 = ★原盤の視覚素材が無い★(素材依頼から始まる)
- V5 = ★V2 の結果で内容が変わる★ → V2 の後
