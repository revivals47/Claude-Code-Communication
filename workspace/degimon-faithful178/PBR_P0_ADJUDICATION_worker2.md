# PBR Phase 0 — placement 機械判定 (worker2, 2026-08-08)

**scope**: oracle 再測定のみ。実装着手なし。Unity コードは 1 byte も触っていない
**成果物**: 本 doc + `pbr_p0_adjudicate.py` + `pbr_p0_crosscheck.py`(同 dir)
**claim 規律**:【観測】= 自分で実行した結果 / bytes 直読。【推論】= 未裏取り。他 worker からの受領値は出所を明記し、鵜呑みにせず再現した旨を書く。

> ★本 doc は「RAM bytes が何と一致したか」の記録であって、「shift 説の最終結論」ではない★。
> §7 の黄 creature 監査(worker3)が未了であり、`unshifted で決まり` とは書いていない。

---

## 0. 結論(1 段落)

> ★2026-08-08 追記: 判定母集団は 2 map → **6 map / 25 record** に拡大した(§7.3)。結論の向きは変わらず、`25/25` で H-unshifted 全一致・対抗仮説 0 件★

★RAM の field entity 配列は、測定した 2 map(mayo00 / twna01。★後に 6 map / 25 record へ拡大、§7.3★)において、`extracted/maps/<map>/<map>.json` の `digimon` 配列と **index をそのまま(shift 量 k=0)** 、`type` / `pos.xyz` / `rot_y` / `ai_type` の **4 field 全てで完全一致した**★。母集団 = digimon を持つ 211 map(総 966 entry)を全数走査し、この一致を満たす map は **各素材につき 1 件のみ**、`k=+1`(7/23 の shifted 説)を満たす map は **0 件**、`k=-2,-1,+2,+3` も **0 件**。あわせて、7/23 triage §1 の表を **同じ savestate の bytes から自由度ゼロで 4/4 行 bit 単位で再生成** でき、その表が savestate prefix `0x1A62` の未補正に起因する測定 artifact であることを確認した。★ただし黄 creature 視覚反証は本判定では解消していない(§7)★。

---

## 1. 材料と読み方【観測】

| 素材 | 種別 | prefix | 同定された map |
|---|---|---|---|
| `runtime_capture_2026-07-25/ram_A.bin` | 生 2MB dump | 0 | mayo00 |
| `ram_B.bin` / `ram_live_1628_{1,2,3}.bin` | 生 2MB dump | 0 | mayo00 |
| `savestates/SLPS-01797_{1,2,9,10}.sav` | DuckStation savestate | **0x1A62** | twna01 (index 204) |
| `SLPS-01797_{3,resume}.sav` | savestate | 0x1A62 | **twna13** (index 179) |
| `SLPS-01797_4.sav` | savestate | 0x1A62 | **frzl17** (index 136) |
| `SLPS-01797_5.sav` | savestate | 0x1A62 | **gias06b** (index 131) |
| `SLPS-01797_7.sav` | savestate | 0x1A62 | **mgen98** (index 222) |
| `SLPS-01797_6.sav` | savestate | 0x1A62 | ★除外: entity 配列が全 0 = load 未実行(§8)★ |

★§7.4 の訂正★: 本表の下 5 行は当初「未同定」と書いていたが誤り。**すべて同定でき、すべて H-unshifted で全一致した**。

**struct spec**(出所 = `docs/RE_field_entity_loader_2026-08-08.md` a6fbcb6、および worker1 disasm。★自分では disasm していないので受領値として扱い、bytes 側の self-check で妥当性を確認した★):
配列 base `0x80145608` / stride `0xC4` / **容量 8 record** / `type@+0x00`(u16, clear=0xFFFF) / `pos.x,y,z@+0xA8,+0xAA,+0xAC`(s16) / `rot_y@+0xB0`(s16) / `ai_type@+0xBC`(s8)

### 1.1 ★prefix 0x1A62 は推測でなく実測で決めた★【観測】

savestate は zstd 展開 blob の先頭 = `0x80000000` ではない。この prefix を取り違えたことが 7/23 の全ての誤りの根であるため、**推測で埋めず既知 bytes との差で実測**した:

- 生 2MB dump `ram_A.bin` 内の anchor(`gp-0x6cf8` の固定ポインタ 5 連)offset = **0x13E114**【観測】
- savestate 展開 blob 内の同 anchor offset = **0x13FB76**【観測】
- ∴ prefix = `0x13FB76 - 0x13E114` = **0x1A62**

独立 cross-validate: `ram_A.bin` の静的領域から 64 byte 列を 8 箇所抜き、blob 内で探索 → ★8 件中 3 件が hit し、hit した 3 件すべてが delta = 0x1A62★(残り 5 件は game state 差で内容自体が異なり非 hit = 想定内)。

### 1.2 script の self-check(権威測定の前)【観測】

`feedback_audit_your_own_tool` に従い、判定 script は既知値で self-check してから使用:

- **C1** record 数 = 8 = 容量【PASS】
- **C2** clear sentinel `0xFFFF@+0x00` の実在: ram_A=[5,6,7] / _9.sav=[7]【PASS】
- **C3** ★反証テスト★ base を `+stride/2` ずらすと sentinel hit が 3→0 / 1→0 に消える = stride 0xC4 の位相が偶然でない【PASS】
- **C4** live record の `pos.y` 逸脱 0 件 / `rot_y` が 0..4095 外 0 件【PASS】

---

## 2. 母集団【観測】

- 全 map = **242**
- `digimon` ≥ 1 件の map = **211**(31 map は 0 件)
- 総 entry = **966**
- ★JSON の key は `digimon`。dispatch 文言の `npcs` という key は実 file に存在しない★

---

## 3. 判定表 — mayo00 (`ram_A.bin`)【観測】

RAM record(index 0..7、容量内):

```
[0] type=   74 ai=12 pos=(594,0,2347)   ry=3072
[1] type=   74 ai=12 pos=(327,0,-1500)  ry=3072
[2] type=    3 ai=16 pos=(-226,0,1688)  ry=3072
[3] type=   83 ai=12 pos=(594,0,2347)   ry=3072
[4] type=   83 ai=12 pos=(327,0,-1500)  ry=3072
[5..7] type=0xFFFF  <clear>   ※ pos は残存(§5)
```

| 仮説 | 判定式 | 5/5 成立した map 数(母集団 211) |
|---|---|---|
| **H-unshifted (k=0)** | `RAM[i].type == json[i].type` かつ `RAM[i].pos == json[i].pos` | ★**1 件** = mayo00★ |
| H-shifted (k=+1) | `RAM[i].type == json[i+1].type` かつ pos は json[i] | **0 件** |
| H5 (k=-2,-1,+2,+3) | 同上、shift 量を変えて全走査 | **0 件**(4 通りすべて) |
| **4 field 全一致**(type/pos/ai/rot_y、index join) | | ★**1 件** = mayo00★ |

**H-poskey**(index を捨て position 完全一致で対応付け): mayo00 は ★座標重複 2 組★(json[0]/[3] と json[1]/[4] が同座標)。∴ position join は **原理的に一意化不能**。5 件中 5 件で type は候補集合内に入るが、★これは「一致した」のではなく「曖昧なまま矛盾しなかった」だけ★であり、証拠として index join より弱い。

**個別 shift の部分一致に注意**: 設計 doc 定義の H-shifted を record 単位で見ると type が 5 件中 2 件だけ一致する。これは `json[0].type == json[1].type == 74` と `json[3].type == json[4].type == 83` という **重複 type による偶然**であり、systematic の証拠ではない(`feedback_small_sample_generalization`)。

---

## 4. 判定表 — twna01 (`SLPS-01797_9.sav`、_1/_2/_10 も record bit 同一)【観測】

```
[0] type=117 ai=1 pos=(-161,0,-2451)  ry=3584
[1] type= 30 ai=1 pos=(-406,0,-2839)  ry=3072
[2] type=117 ai=1 pos=(1054,0,-2877)  ry=1024
[3] type=117 ai=1 pos=(-103,0,-1623)  ry=3900
[4] type= 43 ai=1 pos=(-1372,0,-2991) ry=3584
[5] type= 30 ai=1 pos=(798,0,-1656)   ry= 512
[6] type= 44 ai=1 pos=(-839,0,2210)   ry=3072
[7] type=0xFFFF pos=(-647,0,-3108) ry=2560   ※ 7/23 §4 が player(boy) slot と同定した座標
```

| 仮説 | 7/7 成立した map 数(母集団 211) |
|---|---|
| **H-unshifted (k=0)** | ★**1 件** = twna01★ |
| H-shifted (k=+1) | **0 件** |
| H5 (k=-2,-1,+2,+3) | **0 件**(4 通りすべて) |
| **4 field 全一致**(index join) | ★**1 件** = twna01★ |
| **H-poskey**(座標重複 **0 組** = position join 可) | ★**7/7 一致**★ |

★twna01 は座標重複ゼロゆえ index join と position join の **両方が独立に成立**し、★2 key の食い違いなし★。
★twna01 は shift の識別力も高い★: type 列 `[117,30,117,117,43,30,44]` に対し `k=+1` 期待列は `[30,117,117,43,30,44,-]` で、**6 個の比較可能 index のうち 5 個で両説が区別可能**(k=0/k=+1 が同値になるのは i=2 のみ)。∴ この一致は識別力の低さによるものではない。

**4 savestate 間の一致**: `_1`/`_2`/`_9`/`_10` で record 0..7 の raw 0xC4 byte が完全一致【観測】= 静的 NPC。単一素材の偶然ではない。

---

## 5. (a) entity 数の軸【観測 + 訂正】

### 5.1 ★自分の当初の判定法を格下げする★

私は当初「先頭から最初の `0xFFFF` sentinel までの record 数」を live 数として採った。mayo00=5 / twna01=7 が得られ、いずれも生 `.map` 先頭 halfword(worker3 実測)と一致した。
★しかしこの rule は権威ではない★: 配列容量が 8 で、entity 数が 8 の map では sentinel が 1 つも現れず、この rule は黙って「8」を返す。**下限を上限として提示してしまう**(`feedback_absence_in_truncated_list`)。
∴ **entity 数の権威は生 `.map` 先頭 halfword と loader disasm** とし、sentinel rule は *count < 8 のときのみ有効な整合チェック* に格下げする。boss1 経由の worker1 実測でも TWNA13 / MAYO01 / TWNA06 = 8 は cap 飽和で件数主張不可と確認済。

### 5.2 設計 doc §2.3 の「3 か 5 か」= ★5 で決着★、bytes による独立根拠【観測】

設計 doc は mayo00 の position が `p0,p1,p2,p0,p1` と周期 3 で反復する点から「entity 数 3 で idx3,4 は残骸」の可能性を挙げていた。これは **5** で決着する。boss1 も同結論(mayo00.json 自体に同座標ペアが実在)だが、私は独立に別ルートの bytes 証拠を得た:

- ★clear された record 5,6,7 の pos が残存しており、その `(pos, ai_type, rot_y)` が **twnb family の json[5],[6],[7] と index 揃いで 3/3 一致**★(242 map 走査、`pbr_p0_crosscheck.py` [C])
- twnb family の digimon 件数 = **8**
- ∴ 直前 load = twnb 系(8 体、record 0..7 を占有)→ mayo00 load が record 0..4 を上書きし、**残り 5,6,7 の type だけを 0xFFFF で clear**。clear 数 3 = 8 − 5 の算術と完全整合
- clear ルーチンは ★type にしか -1 を書かない★ため pos が残る(boss1 実測と一致、私の bytes でも確認)

→ 「idx3,4 が残骸」なら clear 痕は 3 でなく 5 個並ぶはずで、実際は 3 個。**entity 数 = 5 が 2 経路で確定**。

### 5.3 index 8 以降の扱い【訂正】

初回走査で私は 24 record を dump し idx 8 以降を「非構造化 stale 残骸」と書いた。★配列容量が 8(clear ルーチン `0x800BB994` の loop 上限 `s0<8`、worker1 disasm)である以上、idx 8 以降は配列外 = 別データ構造であり「残骸」ですらない★。判定表からは除外済で、script も index 0..7 に限定した。

---

## 6. ★7/23 off-by-one が測定 artifact であることの bit 単位再生成★【観測】

boss1 から算術(4 field 全て delta `0xA2`、`0xA2+0x22 = 0xC4` = 1 stride)を受領したが、鵜呑みにせず **実 savestate bytes 上で 7/23 の読み方を literal に再演**した。

7/23 の spec(base `0x80147358` を VA と誤認、`pos@+0x6,+0x8,+0xa` / `rot@+0xe` / `type@+0x22`)で `SLPS-01797_9.sav` を読むと:

| i | 再演で得た値 | 7/23 doc §1 の記載 | 一致 |
|---|---|---|---|
| 0 | (-103,-1623) rot3900 type=**43** | (-103,-1623) type=43 | ✔ |
| 1 | (-1372,-2991) rot3584 type=**30** | (-1372,-2991) type=30 | ✔ |
| 2 | (798,-1656) rot512 type=**44** | (798,-1656) type=44 | ✔ |
| 3 | (-839,2210) rot3072 type=**65535** | (-839,2210) type=0xFFFF | ✔ |

★4 行中 4 行を bit 単位で再生成★。自由度ゼロの算術:

```
0x80147358 − 0x1A62 = 0x801458F6
0x801458F6 − 0x80145608 = 0x2EE = 0xA2 + 3*0xC4  (余り 0)
pos : 0xA2 + 0x06 = 0xA8 = 真 pos.x offset   → 一致
rot : 0xA2 + 0x0E = 0xB0 = 真 rot_y offset   → 一致
type: 0xA2 + 0x22 = 0xC4 = ちょうど 1 stride → ★次 record の type@+0x00★
```

∴ 7/23 は **pos を record (i+3) から、type を record (i+4) から**読んでいた。両者が 1 record ずれているため「pos N の type は N+1」という観測則に見えた。base が真 record 3 から始まっていたことは、7/23 の表が twna01 の 7 体でなく **4 行しか無い**ことも同時に説明する。

→ ★7/23 §1 の position→type 表を oracle に使わない理由が bytes で裏取り済★。本判定でも同表は参照していない。

---

## 7. ★未解決 = 黄 creature 反証(honest gap)★

上記は 7/23 の **RAM 読みが artifact だった**ことを示すのみで、★視覚観測そのものを説明しない★。unshifted では:

- `(798,0,-1656)` = json[5] = **type 30 = トコモン(白)**
- 7/23 表 / shifted では同座標 = type 44 = タネモン

worker3 の元観測「(798,-1656) は黄 creature であって白トコモンではない」と **unshifted は衝突したままである**。`artifact が確定したから unshifted で決まり` という飛ばし方はしない。判断は worker3 の視覚 oracle 監査を待つ。

### 7.1 ★worker2 の追加発見: 「視覚 lock 3 点」は独立証拠ではない(循環)★【観測】

`EntityPlacer.cs` L119-121 のコメントが根拠として挙げる **「worker1 の twna01 視覚 lock 値(Toko3584 / Yura3900 / Tane512)」** は、一見すると shifted 説を 3/3 で支持する独立観測に見える。実際 unshifted と突き合わせると 3 点とも外れ、shifted と 3 点とも合う。

★しかしこの 3 値は 7/23 artifact 表を rotation で表現し直しただけである★【観測】:

| 7/23 §1 表の行 | その座標の json rot_y | 「視覚 lock」表記 |
|---|---|---|
| (-1372,-2991) → type30 トコモン | 3584 | Toko**3584** |
| (-103,-1623) → type43 ユラモン | 3900 | Yura**3900** |
| (798,-1656) → type44 タネモン | 512 | Tane**512** |

3 行とも 1:1 対応。∴ **artifact 表から導かれた値を artifact 表の裏付けに使う循環**であり、独立した証拠として数えてはならない(`feedback_identity_is_not_evidence` / `feedback_verify_the_oracle_not_just_the_match`)。

→ shifted 側に残る **真に独立な観測は worker3 の黄 creature 目視 1 点のみ**。それが 11 record 分(mayo00 5 + twna01 7、うち 4 savestate で bit 同一)の byte 一致と対峙している、というのが現在地。

### 7.2 worker3 監査への申し送り(worker2 からの具体的な確認軸)

1. 「(798,-1656)」という **world 座標はどう同定されたか**。原盤 screenshot の画面位置 → world 座標の逆変換が根拠なら、その変換自体が検証対象
2. unshifted ではタネモン(44)は `(-839,0,2210)` に居る。★これは他 6 体(z ≈ -1600..-3000)から大きく離れた +z 側★で、同一画面に写らない可能性がある。「黄が見えた/白が見えない」の判定範囲に入っていたか
3. json[3] `(-103,-1623)` は script_id 8 = **debug NPC** で通常非表示。観測画に何体写っていたか(7 体か、debug 除外で 6 体か)は shift 判定と独立に効く

---

### 7.3 ★判定母集団の拡大(2026-08-08 追記)— 2 map → 6 map / 25 record★【観測】

`gp-0x6ca6`(u16、map index の権威経路)を使うと、当初「未同定」とした素材がすべて同定できた。同定後に 4 field(type/ai_type/pos.xyz/rot_y)で index join した結果:

| map | 素材 | RAM record 数 | **H-unshifted 4 field 全一致** |
|---|---|---|---|
| mayo00 | `ram_A/B` + `ram_live_1628_{1,2,3}` | 5 | ★5/5★ |
| twna01 | `_1` / `_2` / `_9` / `_10` | 7 | ★7/7★ |
| **twna13** | `_3` / `_resume` | 8(★cap 飽和★) | ★8/8★ |
| **frzl17** | `_4` | 2 | ★2/2★ |
| **gias06b** | `_5` | 2 | ★2/2★ |
| **mgen98** | `_7` | 1 | ★1/1★ |
| **合計** | | | ★**25 / 25 record**★ |

★shift 量 k を変えた対抗仮説は依然として 0 件★。
★map 同定の独立性★: `6ca6` の index 値と、entity 配列の内容から独立に同定した map が **6 map すべてで一致**した(例: `_1/_2/_9/_10` → 204 = TWNA01)。2 つの独立経路が同じ答えを出している。

★ただし cross-family 一般化は依然しない★: 6 map は mayo / twna / frzl / gias / mgen の 5 family だが、母集団 223 gate-ON map のうち **6 map = 2.7%** にすぎない。

### 7.4 ★自分の測定 tool が誤った件(honest)★

§1 で「`_3`/`_4`/`_5`/`_6`/`_7` は 211 map のどれとも 4 field 一致せず未同定」と書いたのは、**その場限りの inline scan の出力**に基づいており、★同じ論理を再実行しても再現しない★(再実行では `_4` → frzl17 が正しく hit)。∴ ★当時の出力は信頼できず、「未同定」claim は撤回する★。

★撤回は解決ではない★。解決済と未解決を区別して残す:

| 素材 | 状態 | 内容 |
|---|---|---|
| `_3`(twna13) | ★原因判明★ | entity 8 件 = **cap 飽和**で sentinel が 1 つも現れず、当時の「最初の 0xFFFF まで」rule が配列外まで走って `live=12` と誤った。12 件一致する map が無いので 0 hit になった |
| **`_4` / `_5` / `_6` / `_7`** | ★**原因未特定のまま**★ | 同じ論理の再実行では正しく hit する。当時なぜ 0 件を出力したのか **特定できていない**。★「撤回したから解決」ではなく、未特定の残課題として残す★ |

`_3` の失敗は ★§5.1 で私自身が「cap 飽和時に破綻する」と書いた失敗モードに、私自身が実際に踏んでいた★もの。★規則を書くことと、それを自分に適用することは別★。

**教訓(最重要、再利用性が高い)**: self-check 付きの checked-in script(`pbr_p0_adjudicate.py`、容量 8 で打ち切り)は正しい答えを出し、**その場限りの inline scan は誤った**。→ ★権威測定を inline の使い捨て scan でやらない★。

## 8. ★一般化しない範囲(honest scope)★

- RAM bytes で判定できたのは ★6 map / 25 record のみ★(§7.3: mayo00 / twna01 / twna13 / frzl17 / gias06b / mgen98)。**gate ON 223 map の 2.7%** にすぎず、残り 217 map は RAM 素材が無く未検証
- ★`SLPS-01797_6` / `canon_baselineC` / `canon_care_seed_point` は entity 配列が全 0(clear の 0xFFFF ですらない)= entity load 未実行★。判定の分子にも分母にも入れていない
- ★`gp-0x6ca6 == 0` は「MAYO01(index 0)」と「未設定」を区別できない★ = map 同定 oracle の限界。index 0 単独を同定根拠にしない
- 上記 2 map の結果を twna family / 全 map に一般化していない。`RAM record index == .map entry 順` が構造的に成立するという loader disasm 根拠は worker1/worker3 側にあり、**私の bytes 判定はそれを 2 map で追認したにとどまる**
- 私は disasm を自分で読んでいない。loader / clear ルーチンに関する記述はすべて worker1 からの受領値であり、私の寄与は bytes 側の整合確認のみ

---

## 9. 成果物

| file | 内容 |
|---|---|
| `pbr_p0_adjudicate.py` | 生 2MB dump / savestate 両対応。self-check → 母集団走査 → shift 量 k 全走査 → H-poskey。index 0..7 限定 |
| `pbr_p0_crosscheck.py` | [A] map 同定の一意性 [B] 複数 dump の bit 比較 [C] clear 済 record の由来探索 [D] per-record fingerprint 探索 |

再現コマンド:
```
python3 pbr_p0_adjudicate.py runtime_capture_2026-07-25/ram_A.bin
python3 pbr_p0_adjudicate.py ~/.var/app/org.duckstation.DuckStation/config/duckstation/savestates/SLPS-01797_9.sav
python3 pbr_p0_crosscheck.py
```

**[D] の副産物**【観測】: json の `script_id` / `hp` / `mp` / `offense` 等は RAM record 0xC4 byte 内の **どの offset にも存在しない**(全 offset × u8/u16 × signed/unsigned 走査で全 record 共通の offset が 0 件)。唯一 `tracking_range` が `+0xB4`(u16)で全 5 record 一致。★∴ (座標, script_id) の 3 つ組 join は RAM 側から構成不能★ = join key は index と座標に限られる(boss1 の独立実測と一致)。
