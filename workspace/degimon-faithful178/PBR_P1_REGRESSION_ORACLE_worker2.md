# PBR Phase 1 — 回帰 oracle(land 合否基準)worker2, 2026-08-08

**位置づけ**: ★実装より先に「何が緑なら land 可か」を固定する doc★(PRESIDENT item 6)。実装後に基準を作らない。
**性質**: 本 doc は **判定基準であって結論ではない**。shift 説の是非は `PBR_P0_ADJUDICATION_worker2.md` に記録した bytes 判定に依り、本 doc はそれを回帰で守る仕組みを定める。
**前提**: 判定対象は ★remake の静的 placement のみ★。

**曖昧語の禁止**: 「概ね」「ほぼ」「問題なし」「動作確認済」は pass 条件に使わない。すべて **N 件中 M 件** か **bit 一致 / 不一致** で書く。

---

## 0. oracle の定義域と権威

### 0.1 ★oracle は placement subset に限定する★

| 項目 | 値 |
|---|---|
| **oracle 対象 field** | `type` / `ai_type` / `pos.x` / `pos.y` / `pos.z` / `rot_y` の **6 値のみ** |
| **oracle 対象 index** | record **0..7**(配列容量 8) |
| **oracle にしないもの** | ★record 丸ごと 0xC4 byte の sha256★ |

★理由(worker1 実測)★: twna01 の 6 素材(`_1.sav` / `_1.bak` / `_2.sav` / `_9.sav` / `_10.sav` / `_10.bak`)で **placement subset は bit 一致**するが、**record 全体の sha256 は 6 件とも別値**。`+0x58`〜`+0x80` 帯等に runtime 可変 field が存在する。
∴ 丸ごと比較を oracle にすると **runtime 変動で常時赤になる偽陽性 oracle** になる。

### 0.2 権威の序列(上が強い)

1. **生 `.map` bytes**(entity 数 = 先頭 halfword、entry 内容)— 最終権威
2. **loader / clear ルーチンの disasm**(`0x800bae54` / `0x800BB994`)— 挙動の権威
3. **RAM 実測**(★6 map / 25 record のみ存在: mayo00 / twna01 / twna13 / frzl17 / gias06b / mgen98 = gate ON 223 map の 2.7%★)— 1・2 の追認
4. `extracted/maps/*/*.json` — 1 の派生物。★§2.1 の同値性が緑である間のみ oracle として使ってよい★

★7/23 triage doc(`JSON_NPC_OFFBYONE_TRIAGE.md`)§1 の position→type 表、および §4 の struct 記述(base `0x147358` / `type@+0x22`)は測定 artifact であり、権威序列に**入らない**★。

---

## 1. 母集団(すべての「N 件中 M 件」の分母)

★以下はすべて worker2 が EXE を直読して独立に再現済★(`extracted/slps_017_97.bin`、table VA `0x8013541C` = file `0xA4C1C`、16 B stride、entry `+0`= map 名 ASCII 8 B、`+12` bit7 = gate)。受領値の丸呑みではない。

| 量 | 値 | 検算 |
|---|---|---|
| map table 範囲 | **idx 0..254 = 255 entry** ★終端は被参照シンボル 0x8013640C で確定。「255 か 256 slot 末尾未使用か」のみ未決(§1.6 / X14)★ | `0xFF0 / 16 = 255.0 余り 0` |
| うち map 名あり entry | **244** | |
| **gate ON**(`+12 & 0x80` ≠ 0) | **223** | |
| **gate OFF** | **21** | |
| 空 entry | **11**(idx 239-246 / 250-252) | ★223 + 21 + 11 = **255** ぴったり★ |
| 一意な map 名 | **243** | 244 entry − 重複 1 件(§1.3) |
| json map dir | **242** | `243 − 2(YAKA01/YAKA21 抽出なし) + 1(MGEN17) = 242` ✔ |
| `digimon` ≥ 1 件の json map | **211** | |
| **json entry 総数** | **966** | |
| **raw entry 総数**(gate ON 223 map) | **989** | worker3 実測(受領) |
| raw count 分布(ON 223 map) | 0→7 / 1→33 / 2→22 / 3→26 / 4→30 / 5→20 / 6→29 / 7→8 / **8→48** / 9 以上→**0** | worker3 実測(受領) |
| 配列容量 | **8**(clear loop `slti 8`) | worker1 / worker3 が独立に disasm 確認 |

### 1.1 ★数値不整合 A / B は解消済(経緯を残す)★

- **不整合 A(解消)**: `gate ON = 223 / OFF = 21 / 空 = 11` で **合計 255 = table 全長**。★当初 boss1 から中継された「ON = 218」は誤り★で、worker3 の 223 が正しかった。
- **不整合 B(解消)**: ★`966 json entry は全て gate ON map 由来であり、gate OFF 21 map の json entry は 0 件★【worker2 実測】。∴ 989 と 966 は **同じ母集団(gate ON)を見ており apples-to-apples**。`989 − 966 = 23 = MGEN06-10 の raw 合計 (6+3+4+3+7)` は偶然ではなく実質的な一致。 ★［母数 未記載 2026-08-15］★この 行の 0 は ★母数が 添えて いません★★ ⇒ ★★未測定 に 落とします★★

★解消の経緯 — この誤りがどう混入したか(再発防止のため残す)★:
誤裁定の根拠は `PBR_P0_map_index_table.tsv` だったが、★その tsv は idx 0..238 の 239 entry で打ち切られていた★(最初の空 entry で走査停止)。tsv の **連続性(0..238 に穴なし)を見て「全体だ」と判断した**のが誤り。★連続性は「範囲内に穴が無い」ことしか言わず、「範囲が全体である」ことは言わない★(`feedback_absence_in_truncated_list`)。
実際、打ち切り位置 idx 239 の直後 **idx 247-249 = MGEN06/07/08、idx 253-254 = MGEN09/10 が存在し、いずれも gate ON** だった。

### 1.2 table 末尾の決め方(自分の tool を疑う)【観測】

「map 名らしさ」を緩く判定すると `Z` / `C` / `K` / `^` のような **1 文字 ASCII が名前として通り**、table 末尾が idx 298 まで伸びる(worker2 の初回走査で実際に発生)。
★map 名の実体は `[A-Z]{4}[0-9]{2}[A-Z0-9_]*` であり、これで判定すると合致する最大 idx = **254**★。idx 255 以降(`Z`/`C`/`K`… )は 16 B 境界にも揃っておらず別データ。∴ table = idx 0..254。

### 1.3 ★`YAKA25` の重複は症状であって根ではない — 根は pipeline 全体の key 設計★【観測】

entry layout(worker2 が bytes で確認): `+0..7` = map 名 ASCII / **`+10` = numImg** / `+12` bit7 = gate

| idx | 名前 | `+10` numImg | `+12` | gate |
|---|---|---|---|---|
| 65 | YAKA25 | **0** | `0x44` | **OFF** |
| 232 | YAKA25 | **2** | `0xC4` | **ON** |

★同一 map 名が、異なる `numImg` と異なる gate を持つ 2 entry として存在する★。
numImg が違えば **elements_off が 12 byte ずれ、同じ `.map` から読める placement が変わる**(PRESIDENT 裁定)。∴ ★名前が同じでも map としては別物★。

→ ★原盤における map の同一性は **index** で決まり、**name は属性にすぎない**★。
一方 pipeline は `extracted/maps/<name>/<name>.json` という ★name-keyed data model★ になっている。
∴ **「gating の key を index にする」で止めると同じ穴が別 tool で再発する**。★Phase 1 の scope に pipeline 全体の key 設計是正を含める(別 issue に逃がさない)★。

### 1.4 table と json 抽出の差分(母集団を閉じる)【観測】

| 区分 | map | idx | gate | numImg |
|---|---|---|---|---|
| table にあるが dir 無し | `YAKA01` | 50 | OFF | 0 |
| table にあるが dir 無し | `YAKA21` | 61 | OFF | 0 |
| dir はあるが table 無し | `MGEN17` | — | — | — |

検算: `名前あり 244 − 重複 1(YAKA25) = distinct 243` → `243 − 2 + 1 = 242` = json map dir 数 ✔ ★母集団は閉じている★
`YAKA01` / `YAKA21` は gate OFF ゆえ P1 の分母(gate ON 223 map)に影響しない。

### 1.5 ★「OFF かつ numImg=0 が stale slot の signature」仮説 — 測定した結果 **成立しない**★【観測】

boss1 から「YAKA01 / YAKA21 / YAKA25(idx65) は 3 件とも gate OFF かつ numImg=0。これが placeholder slot の signature かもしれない(★断定するな★)」と申し送りがあったので、★断定せず母集団を数えた★:

| 条件 | 件数 |
|---|---|
| OFF かつ numImg=0 | **8 / 21 OFF map** |
| OFF かつ numImg≠0 | 13 / 21 |
| **ON かつ numImg=0** | **32 / 223 ON map** |
| numImg=0(全体) | 40 / 244 |

`OFF ∧ numImg=0` に該当する 8 件 = `YAKA01`(50) / `YAKA21`(61) / `YAKA25`(65) / `FRZL05`(92) / `TUNN08_2`(124) / `MGEN14`(229) / `MGEN15`(230) / `MGEN16`(231)。
★このうち json dir が無いのは `YAKA01` / `YAKA21` の 2 件のみで、残り 6 件には dir が存在する★。さらに numImg=0 は ON 側にも 32 件あり珍しくない。

→ ★仮説は棄却:「OFF かつ numImg=0」は dir 不在を選び出さない(8 件中 2 件しか該当しない)。stale/placeholder の signature としては使えない★。
これは失敗ではなく前進であり、★この signature を根拠にした map 除外・分類を実装に入れてはならない★(除外条項 X13)。

### 1.6 ★table 終端 = 被参照シンボルで確定。ただし「255 か 256 slot の末尾未使用か」は未確定★

**確定した部分**【worker1 権威 table metadata + worker2 検算】:
- ★終端の根拠 = 直後の**独立参照シンボル** `0x8013640C`(参照 site `0x800E4CB8`、そこは **stride 8 の別構造**)★ = ★被参照 + 構造の相違による根拠★であり、形状判断より強い
- 物理 extent 検算(worker2): `0x8013640C − 0x8013541C = 0xFF0 = 4080 byte`、`4080 / 16 = 255.0 余り 0` → ★255 entry ちょうど★
- ★index の型幅は上限の根拠にならない★: loader へ渡るのは `lhu` = halfword で、`mask も clamp も無い`(P1c)。∴ 「型幅が 1 byte だから 256 まで」式の推論は使わない

**未確定として残す部分**: ★論理長が 255 なのか、256 slot 確保で末尾 1 slot 未使用なのか★ は区別できていない。
本 doc の `ON 223 / OFF 21 / 空 11 / 名前あり 244` は ★idx 0..254 を母集団とした値★であり、この区別が付いたら再検算する(X14)。

---

### 1.7 ★oracle 素材から除外する 3 件(entity load 未実行)★【観測】

| 素材 | `gp-0x6ca6` | entity 配列 | 除外理由 |
|---|---|---|---|
| `SLPS-01797_6.sav` | **0** | ★全 0★ | clear の `0xFFFF` ですらない = ★entity load 未実行★ |
| `canon_baselineC.sav` | — | ★全 0★ | 同上 |
| `canon_care_seed_point.sav` | — | ★全 0★ | 同上 |

★`_6.sav` の `6ca6 = 0` を「MAYO01 に居る」と読んではならない★: `MAYO01`(idx 0)は **gate ON かつ json 8 件**なので、「MAYO01 に居る」なら 8 record が populate されているはずで、全 0 と両立しない。
∴ ★`6ca6 == 0` は「MAYO01」と「未設定」を区別できない★ — これは map 同定 oracle の**限界**として記録する(X15)。
この 3 件は判定の分子にも分母にも入れない(X16)。

### 1.8 ★gating OFF の「entry 基準 21」と「name 基準 20」の差★

- ★entry 基準 = **21**★(`+12` bit7 = 0 の table entry 数)
- ★name 基準 = **20**★(`YAKA25` は idx 232 = ON を採用するため OFF 集合から外れる)
- ★差分 = `{YAKA25}` の 1 件で、これが今回の key 設計修正そのもの★

素朴に name 集合で数えると 21 になる。★どちらの基準で数えたかを併記せずに「OFF は N 件」と書かない★。

---

## 2. pass 条件(すべて機械判定)

各条件に **判定手順**と、★その緑が何を assert しているか★(= 何を assert していないか)を付す。

### P1. placement 正当性 — 全 map の 6 値一致

- **手順**: gate ON の全 map について、remake の placement dump `(mapName, i, type, ai_type, pos.x, pos.y, pos.z, rot_y)` を生成し、生 `.map` を loader の読み順で parse した oracle 表と **index join** で突合
- **pass**: 不一致 **0 件 / 総 raw entry 989 件**。map 単位では **0 map / 223 map** が不一致
- **報告形式**: 必ず「N 件中 M 件」。map 名と index を伴わない「全部一致」表記は不可
- **join key**: ★index が第一 key★。position は独立 cross-check に留める(★座標重複が 211 map 中 73 map に存在し、そこでは position join が原理的に一意化不能★)
- **2 key の食い違いが出た場合**: それは失敗ではなく ★発見★。握り潰さず報告する
- ★この緑が assert すること★: remake の配置が生 `.map` と同じ index 対応・同じ 6 値であること
- ★assert **しない**こと★: 画面に何体見えるか / 見た目が原盤と同じか / 種族モデルが正しく描画されるか

### P1b. ★gating 判定と placement 走査が **同一の map index** から導かれていること★

- **根拠**: loader 内で ★gating も placement も同一の `a1` 由来★(`lb [0x8013541C + a1*16 + 12] and 0x80` の `a1` と、entity populate の `a1` が同一レジスタ)
- **pass**: remake 側で、gate 判定に使う map 識別子と placement 走査に使う map 識別子が ★同一の値から導出されている★こと(code 上で 1 本の変数に遡れる)
- **fail**: 2 つが別 source を引いている(例: gate は table 引き、placement は file 名引き)
- ★この緑が assert すること★: gate と placement が原理的に食い違えない構造になっていること
- ★assert **しない**こと★: 現在のデータで両者がたまたま一致していること(YAKA25 のように name が衝突すると黙って割れる)

### P1c. ★map index の権威経路★(参考仕様、実装の照合先)

【観測 = worker2 が savestate 10 件で検証】loader の `a1` に届くのは ★`gp-0x6ca6`(u16)経路★: ★［母数 未記載 2026-08-15］★この 行の 0 は ★母数が 添えて いません★★ ⇒ ★★未測定 に 落とします★★

```
0x800EC47C  lhu a0,-0x6ca6(gp)  →  0x800DF7D0 → 0x800DFA20 → 0x800AC588
0x800AC760  lh a1               →  jal 0x800BAE54 (loader)     ※ mask も clamp も無し
```

★「loader/gating は `gp-0x6d90`」は誤り★(boss1 第 11 報の訂正を反映)。`6d90`(u8)は**別の読み手**であり、両者は map index の mirror。
worker2 実測: savestate 10 件すべてで `6ca6` と `6d90` は同値、かつ `6ca6` の値が table index として ★entity 配列の内容から独立同定した map と一致★(例: `_1/_2/_9/_10` → 204 = TWNA01、`_3/_resume` → 179 = TWNA13)。 ★［母数 未記載 2026-08-15］★この 行の 0 は ★母数が 添えて いません★★ ⇒ ★★未測定 に 落とします★★

### P2. json ↔ raw 同値性(P1 で json を oracle 代用する場合の前提)

- **手順**: 966 json entry と生 `.map` parse を 6 値 + index で突合
- **pass**: 不一致 **0 件 / 966 entry**(worker3 が 966 record / 23184 field で不一致 0 を確認済 = 受領値。★Phase 1 でも再実行して緑を確認する。過去の緑を引用しない★)
- **★MGEN06-10 の扱い(明示的例外 = 実害のある抽出 gap)★**: 生 `.map` に 6/3/4/3/7 = 計 **23 entry** があるが json は **0 件**。
  ★これら 5 map は gate ON である★(idx 247/248/249 = MGEN06/07/08、idx 253/254 = MGEN09/10、いずれも `+12 = 0xD1`)【worker2 実測】。
  ∴ ★「未使用 map ゆえ無害」という理由付けは誤りであり、使用しない★。正しくは ★**gate ON の map で抽出が落ちている = 実害のある抽出 gap、原因未特定**★。
  → ★これら 5 map では json を oracle として使用禁止★。P1 は生 `.map` 側を oracle とする。抽出 gap の修正は **Phase 1 の scope 外 = 別 issue として起票**(ただし「無害」と書いて閉じない)
- ★この緑が assert すること★: json が生 `.map` の忠実な派生であること(MGEN06-10 を除く)

### P2b. ★`numImg` は table entry(index)由来であること★

- **pass**: 実装が `numImg` を ★`[0x8013541C + mapIdx*16] + 10` から読む★こと
- **fail(oracle 無効)**: `.map` file の内容から **推定**している / **map 名から引いている**
- ★理由 — 偶然の成功を設計の正しさと誤読しないため★: 現 `convert_map` が YAKA25 で正しい parse になっていたのは、★name-keyed 辞書の last-wins が偶然 idx 232(numImg=2)を選んだから★であって、**設計として正しかったからではない**。entry 順が変われば黙って壊れる
- ★この緑が assert すること★: numImg の出所が index 由来であること
- ★assert **しない**こと★: 現状の出力が偶然合っているかどうか(合っていても設計は不正)

### P3. entity 数

- **手順**: 各 map の配置数 = **生 `.map` 先頭 halfword** と一致するか
- **pass**: 不一致 **0 map / 223 map**
- ★固定長走査でないことの assert★: 実装が「常に 8 件走査して sentinel で打ち切る」形になっていないこと。**先頭 halfword を読んでその件数だけ回している**ことを code 上で確認する(grep + 実行 log 双方)
- ★sentinel 数え上げを entity 数の根拠にしてはならない★: 配列容量 8 ゆえ count=8 の map では sentinel が 1 つも出ず、この方法は **下限を上限として報告する**(`feedback_absence_in_truncated_list`)
- ★**count field は gate ON map でのみ意味を持つ**(PRESIDENT 指示)★: gate OFF map の当該位置は placement section が存在せず、読める値は **残バイト**であって entity 数ではない。
  実例: `YAKA22` の当該 halfword = **63** だが、★elements block 全長 0xA2 = 162 B に 63 record は物理的に入らない★。∴ これを「raw count 63」と呼ぶこと自体が不正確(PRESIDENT も自身の呼称が不正確だったと明示)。
  → ★OFF map の count 値を分布・統計・最大値の議論に混ぜないこと★
- ★この緑が assert すること★: 件数が先頭 halfword 由来であること
- ★assert **しない**こと★: 「8 で足りていた」こと(§3 除外条項 X4 参照)

### P4. 配列容量 8 — ★silent clamp 禁止★(★2026-08-10 T2-C で「停止」→「skip + 診断」に改訂。PRESIDENT 追認済★)

- **手順**: 実装に `count <= 8` の判定を置く
- **pass(旧、2026-08-08〜08-10)**: ~~count > 8 を与えたとき ★例外 / 明示 error で停止★~~
- **★pass(現、2026-08-10 改訂)★**: count > 8 を与えたとき ★★① 例外を投げず続行し ② NPC を 1 体も置かず(★8 件に clamp しない★) ③ `PlacementAnomaly` に機械可読で記録し ④ `LogError` を出す★★
- ★改訂の理由★: ★`throw` は `Place()` を中断し、caller は誰も catch しない(★`FieldManager.cs:484` の手前に `try` が 1 つも無いことを全数確認★)★ ⇒ ★field load ごと落ちる★ ⇒ ★★user 実視覚 gate が実行できなくなる★★。★完成判定を user 視覚に凍結している以上、★視覚検証を止める防御は本末転倒★★
- ★禁止の中身は変わっていない★: ★2026-08-08 裁定が禁じたのは **silent** であること★。★改訂後も LogError + Anomalies の 2 系統に残すので silent ではない★
- ★**skip も忠実ではない**★: 原盤は ★配列外へ溢れ書きする未定義動作★。★skip も clamp も等しく原盤に無い挙動★ ⇒ ★skip 採用は忠実性の主張ではない★。clamp でなく skip を採る根拠は ★誤りの見え方★ = ★clamp は正常に見えて通ってしまう / skip は map が空になり視覚 gate に必ず現れる★
- **根拠**: 配列容量は 8(disasm 確定)だが ★loader 側に clamp は無い★(loop 条件は先頭 halfword のみ、worker1 disasm)。∴ 「データが 8 以下だから安全」であって「loader が守っている」のではない。remake 側は ★この振る舞いを明示的に決める★ 側に立つ
- **test**: `Editor/EntityPlacerSkipVerify.cs`。★合成入力 5 件(陰性 3 / 陽性 2)、境界の内(entity 8 / MapIndex 254)と外(9 / 255)を両方★。★2026-08-10 実行: 5/5 PASS(前提検査つき)★
- ★この緑が assert すること★: ★溢れが silent に握り潰されないこと★ / ★★clamp されていないこと(placed=8 なら不合格)★★
- ★★この緑が assert **しない** こと★★: ★skip が原盤忠実であること★ / ★実データでこの条項が発火するか(現状 ★latent★、実データの 8 超は 0 件)★

### P5. gating(`flags & 0x80`)

- **手順**: `[0x8013541C + mapIdx*16].byte12 & 0x80` が 0 の map で NPC 配置数 = 0、≠0 の map で先頭 halfword 通りの配置
- **pass**: OFF ★entry 基準 21 件★全件で 0 体、ON **223 entry** で P3 と整合。★name 基準では OFF は 20 件(§1.8)。どちらで数えたか併記すること★ ★［母数 未記載 2026-08-15］★この 行の 0 は ★母数が 添えて いません★★ ⇒ ★★未測定 に 落とします★★
- ★key は map index。map 名で引かないこと★: `YAKA25` は idx 65(OFF)と idx 232(ON)の **2 entry に存在する**(§1.3)。名前 key だとどちらを採ったかで結果が黙って変わる
- **OFF 21 map 実名**【worker2 が EXE 直読で列挙】: `MAYO10` / `YAKA01` / `YAKA11B` / `YAKA12` / `YAKA15` / `YAKA18` / `YAKA21` / `YAKA22` / `YAKA23` / `YAKA24` / `YAKA25`(idx 65) / `KODA05` / `FRZL05` / `TUNN07_2` / `TUNN08_2` / `TUNN03_2` / `OGRE04` / `FACT05` / `MGEN14` / `MGEN15` / `MGEN16`
- ★この緑が assert すること★: gate flag が配置有無を制御していること

### P6. ★debug-gate と gating は別機構 — 混同禁止★

2 つの独立した機構であり、**それぞれ独立に判定する**。片方の緑をもう片方の根拠にしない。

| 機構 | 実体 | 単位 | 出所 |
|---|---|---|---|
| **gating** | `flags & 0x80`(`0x8013541C` table) | **map** 単位で全 NPC の有無 | EXE table |
| **debug-gate** | `EntityPlacer.DebugNpcScriptIds` = `{"twna01": {5,6,7,8}}` | **script_id** 単位で個別 NPC | `FINDING_scenario149_section_bleed_debug_npcs_2026-06-17.md` / 攻略本 |

- **pass**: (a) gate OFF map で 0 体、(b) `DEGIMON_DEBUG_NPCS` 未設定時に twna01 の script_id 5/6/7/8 が placement から除外され、`=1` で再出現する。**両方を別々に測る**
- ★この緑が assert すること★: 2 機構がそれぞれ意図通り効くこと
- ★assert **しない**こと★: 除外後の体数が原盤の見た目と一致すること(§4 参照 — 対象外)

### P7. OFF-inert(env 未設定時の無変更)

- **手順**:
  1. 変更前 HEAD で、`DEGIMON_FIELD_MODELS` / `DEGIMON_DEBUG_NPCS` を **未設定**にして placement dump を全 223 map 分生成 → `before.txt`
  2. 変更後 HEAD で同一手順 → `after.txt`
  3. `sha256sum before.txt after.txt` を比較
- **pass**: ★2 file の sha256 が一致★(= 出力 byte 完全同一)
- **注意**: dump に時刻 / path / 実行順などの非決定要素を含めないこと。含まれると sha が常時変わり **この条件が永久に測れなくなる**
- ★この緑が assert すること★: env 未設定経路の出力が 1 byte も変わっていないこと
- ★assert **しない**こと★: env 設定時の経路が正しいこと

### P8. Unity ビルド

- **pass**: **CS0 系 error = 0 件** ★［母数 未記載 2026-08-15］★この 行の 0 は ★母数が 添えて いません★★ ⇒ ★★未測定 に 落とします★★
- ★この緑が assert すること★: compile が通ること。★correctness は一切 assert しない★

### P9. `ViseNpcBootstrap` の baked データ

`ViseNpcBootstrap.cs` L64-66 は 7/23 artifact をそのまま焼き込んでいる【boss1 実測、worker2 が座標・roster で照合】:

| | 現行 baked | 生 `.map` / json / RAM が示す値 |
|---|---|---|
| `(-1372,-2991)` | TOKO | ★YURA(type 43)★ |
| `(-103,-1623)` | YURA | ★JIJI(type 117)。かつ script_id 8 = debug NPC = 本来非表示★ |
| `(798,-1656)` | TANE | ★TOKO(type 30)★ |
| `(-839,2210)` | (配置なし) | ★TANE(type 44)★ |

roster は EXE 由来で確定: `type30=TOKO / 43=YURA / 44=TANE / 117=JIJI`(`data/species_model_codes.json`、`_source` = EXE `0x8013ce24`)。

- **pass 条件**: ★この 3 行を Phase 1 で勝手に書き換えて緑としない★。
  **user PASS 済の画を無断で変えないこと**。 ★【2026-08-09 注記】この「PASS」は **我々が提示した画像に対する user の判断**であり、★user は remake を操作していない★(user 証言)。★PASS を無効化するものではなく、何を PASS したのかを正確にするための注記★★ 判定は次の 2 段:
  1. **doc 上の起票**: 上表の差分を「変更提案」として明記する(= 本節がその起票)
  2. **user 視覚 gate に載せる**(P10)。★PASS の取り消しは user にしか決められない★
- ★この緑が assert すること★: 差分が可視化され、user 判断に載ったこと
- ★assert **しない**こと★: 差分を適用してよいこと

### P10. ★user 実視覚 gate(AI worker は検証不可 — queue 化し、close しない)★

AI worker は GUI の見た目を検証できない(`feedback_ai_worker_capability_boundary`)。★本項目は「未消化」のまま残り、close は user のみが行える★。

user に見てもらう内容(具体):

| # | map / 操作 | 期待画 | 判定してほしいこと |
|---|---|---|---|
| V1 | twna01 に入る(`DEGIMON_DEBUG_NPCS` 未設定) | 静的 NPC の配置 | 変更前と比べて **配置が動いていないこと**(OFF-inert の目視裏取り) |
| **V2** | ★**原盤**★ — DuckStation + `SLPS-01797_9` | 原盤 twna01 の画面 | ★`(798,-1656)` に居る個体★。★訊き方は自由記述: 選択肢も色語も種名も出さない★(期待値の提示は priming、かつ色は remake 側の色で原盤と一致する保証がない)。★検証するのは `.map` bytes → type id → species table → 原盤の実個体 の end-to-end★ = shift 判定に残る 1 点の独立観測 |
| **V2R** | ★**remake**★ — twna01、`DEGIMON_FIELD_MODELS=1` | remake の描画 | ★shift 判定ではなく動作確認★(完成 claim 凍結解除の要件)。★post-merge の remake は必ず unshifted を描くので、shift については同語反復★。★★⚠ 前提変更あり: これは **user にとって初めての remake 操作**になる。手順は「起動済の画を見る」ではなく「起動から」書き直すこと★★ |
| V3 | twna01、`DEGIMON_FIELD_MODELS=1` | 同上 | `(-839,2210)` に ★TANE が居るか★(unshifted なら居る。現 baked では未配置) |
| V4 | mayo00 に入る | 5 体の配置 | 同座標に 2 体重なる箇所(`(594,0,2347)` と `(327,0,-1500)`)が原盤と同じ見え方か |
| V5 | `ViseNpcBootstrap` 村 render(P9 適用案) | 変更提案の画 | ★現行 PASS 済の画と差し替えてよいか★。NO なら現行を維持。★**⚠ 前提変更あり**: 「現行 PASS 済の画」は user が操作した結果ではなく我々の提示画★ |

- **pass**: user が各項目に明示的に OK / NG を返すこと。★AI 側の headless capture / cargo 緑 / codex LGTM は本項目の代替にならない★(`feedback_live_visual_verify_before_completion`)

#### ★★P10-pre. V-gate の**前提条件** — `Anomalies` が空でなければ user に出さない(2026-08-10 PRESIDENT 条件、T2-C 追認の唯一の条件)★★

★★V1-V5 のいずれかを user に見せる前に、必ず以下を確認する。★1 つでも満たさなければ user に出さない★★★

| # | 確認 | 方法 | 満たさない場合 |
|---|---|---|---|
| ★**Pre-1**★ | ★★`EntityPlacer.Anomalies` が **空**★★ | ★対象 map を load した後に count を読む / batch log に `[PLACE-ANOMALY]` が ★1 行も無い★ ことを確認★ | ★★user に出さない★★。★先に抽出側を直す★ |
| ★**Pre-2**★ | ★`map_entity_gating.json` が StreamingAssets に ★存在する★★ | ★`[PLACE-GATE] … 不在` が log に出ていないこと★ | ★出さない★。`gen_map_entity_gating.py` → `provision_curated_data.py` を実行 |
| ★**Pre-3**★ | ★対象 map の `MapIndex` が ★OFF list に無い★(= 原盤で NPC が湧く map)★ | ★表の `entity_loader_off_indices` を直読★ | ★★出さない★★ — ★OFF map を見せると「NPC が居ない」が ★正常なのか異常なのか user に区別できない★★ |

★★理由(PRESIDENT、逐語)★★:
> ★『user は remake を操作したことがない ⇒ ★NPC ゼロの map を見せたら「remake が壊れている」と受け取る★』★

★★∴ 本前提条件が守る対象は ★実装ではなく ★user の観測★ である★★:
- ★T2-C の skip は「異常時に map が空になる」挙動★。★これは我々にとっては ★異常の可視化★ だが、★user にとっては ★remake の不具合★ にしか見えない★★
- ⇒ ★★★skip を「異常が見える方に間違える」設計にした以上、★その「見える」先を user にしてはならない★★★★ —
  ★見せる相手は ★我々★(log と Anomalies)であって、★user 視覚 gate は ★異常が無い状態でだけ★ 使う★
- ★★これを守らないと、★V-gate の NG が「配置が違う」なのか「異常で空になった」なのか ★分離できなくなる★★★ = ★user の 1 回の観測を無駄にする★

★★記録義務★★: ★V-gate を実施したときは、★Pre-1〜3 の確認結果を同じ報告に併記する★★。★『確認した』ではなく ★何を見てそう言えるか★(log の該当行 / count の値)を書く★。

---

## 3. ★除外条項(BLOCKING)— 全 pass 条件が緑でも land しない★

「緑の定義」だけでは、★想定外の赤を緑と誤認する余地★が残る。以下は **緑を上書きする**。

### 3.1 全条件が緑でも land しない

| # | 条件 | 理由 |
|---|---|---|
| **X1** | ★P10(user 実視覚 gate)が未消化★ | 完成 claim は user 実視覚まで凍結。headless / build 緑は根拠にならない |
| **X2** | ★黄 creature 由来の未決事項が残っている★ | `PBR_P0_ADJUDICATION_worker2.md` §7。V2 が未回答なら shift の独立反証が未処理のまま |
| **X3** | ★worktree 外(共有 `~/Desktop/Digimon/degimon_world_remake`)に変更が漏れている★ / ★push が発生している★ | 保全は commit、push は個別承認事項 |
| **X3b** | ~~`§1.1` の数値不整合 A / B が未解消~~ → ★**解消済**(§1.1)★。ただし **本条項は残す**: 今後 `223 + 21 + 11 = 255` / `243 − 2 + 1 = 242` の検算が崩れたら land 不可 | 母集団が閉じていない状態で「N 件中 N 件」を主張できない |
| **X3c** | ★pipeline の **どこか** で map を **name で primary key** にしている★(gating に限らない。`extracted/maps/<name>/<name>.json` という data model 自体を含む) | ★map の同一性は index で決まり name は属性★(§1.3)。`YAKA25` は同名で numImg 0/2・gate OFF/ON の別 map。name key は黙って別 map を掴む。★gating だけ index 化しても他 tool で再発するので、pipeline 全体が対象★ |

### 3.2 ★「測定できていない」を「緑」と読み替えてはならない項目★

| # | 事実 | 誤読 | 正しい扱い |
|---|---|---|---|
| **X4** | 48 map が raw count = 8 = ★配列容量と同値 = 飽和★ | 「最大 8 だった」→「8 で足りている」 | ★飽和は上限の証明ではない★。9 以上が無いことは *観測範囲で* 言えるだけ。P4 の fail-fast で守る |
| **X5** | **MGEN17** は ★map table(idx 0..254)に名前が無い★ = map index 経由で到達不能 = count 未取得。★ただし ASCII 文字列 `MGEN17` は EXE の別領域 file offset **606936 (0x942D8)** に実在する★(table 範囲 `0xA4C1C..0xA5C0C` の外)【worker2 実測】 | 「問題が出なかった = pass」/「EXE に存在しない」 | ★未測定であって pass ではない★。かつ ★「到達不能」の根拠は「**table に無い**」であって「**EXE に無い**」ではない★ — この 2 つを混同しない。honest gap として残し、緑の分母から除外したことを明記する |
| **X6** | RAM 実測が存在するのは ★mayo00 / twna01 の 2 map のみ★ | 「RAM で裏取り済」 | 残り 209 map は RAM 未取得。生 `.map` 権威での照合であることを明記し、cross-family 一般化をしない |
| **X7** | `_3` / `_resume` / `_4` / `_5` / `_6` / `_7` savestate は 211 map のどれとも 4 field 一致せず ★未同定★ | 「一致しなかった = 反証」 | 未同定素材は判定の分子にも分母にも入れない |
| **X13** | 「OFF かつ numImg=0」= stale/placeholder slot ★という仮説は測定の結果棄却された★(該当 8 件中 dir 不在は 2 件のみ、numImg=0 は ON 側にも 32 件、§1.5) | 「signature で stale slot を弾ける」 | ★この signature を根拠にした map 除外・分類を実装に入れない★。使うなら別途 signature を測り直す |
| **X14** | table 終端は被参照シンボル `0x8013640C` で確定(§1.6)。★ただし「論理長 255」か「256 slot の末尾未使用」かは未確定★ | 「255 slot で完全に確定」 | ★この区別が未決であることを明記したまま使う★。決着したら `223 / 21 / 11 / 244` を再検算する |
| **X15** | ★`gp-0x6ca6 == 0` は「MAYO01(idx 0)」と「未設定」を区別できない★ | 「index 0 だから MAYO01 に居る」 | ★index 0 単独を map 同定の根拠にしない★。entity 配列の内容など独立な証拠と併せる |
| **X16** | ★entity 配列が全 0(clear の 0xFFFF ですらない)= entity load 未実行★の素材(§1.7) | 「配置 0 体 = gate OFF の証拠」/「その map に居る」 | ★oracle 素材から除外する★。load 未実行状態は placement について何も語らない |
| **★X17★** | ★★`map_entity_gating.json` が StreamingAssets に不在だと、`IsEntityLoaderOff` は ★全 map で false★ を返す = ★全 map が gate ON に見える★★★【2026-08-10 worker2 実測、batch log `[PLACE-GATE] … 不在`】 | ★「gate ON の map で測った」★ / ★「gating が適用されている」★ | ★★「表が在って ON」と「表が無いから ON」は ★別物★★★。★gating に関わる測定は ★表の存在を先に実測してから★ 行う★。★表は `StreamingAssets/*` = 意図的 gitignore で、★`gen_map_entity_gating.py` → `provision_curated_data.py` を踏むまで存在しない★(設計どおりだが、★踏み忘れの唯一の信号が log 1 行の LogWarning★)。★T2-C 1 回目はこれで前提を偽造されたまま 5/5 PASS した★ |
| **★X18★** | ★★`PlacementAnomaly` が記録されている状態の画面★★(map が空 / NPC が欠けている) | ★「配置が原盤と違う」= 忠実性の反証★ | ★★異常による skip と、配置の誤りを ★同じ画で判定してはならない★★★。★P10-pre を満たさない画は oracle 素材にしない★。★user の 1 回の観測を、原因不明の空 map に使わない★ |

### 3.3 ★oracle 自体が無効になる条件(結果を破棄する)★

| # | 条件 | 措置 |
|---|---|---|
| **X8** | record 丸ごと 0xC4 byte の sha256 を比較に使っていた | ★その比較結果は無効★。placement subset に限定して再実行(§0.1) |
| **X9** | ★7/23 artifact 表由来の値★を根拠に使っていた | ★無効★。対象 = §1 の position→type 表、§4 の struct(base `0x147358` / `type@+0x22`)、および ★それを言い換えた派生値★(§5 参照) |
| **X10** | savestate を prefix 未補正(`0x1A62`)で読んでいた | ★無効★。prefix は既知 bytes との差で実測する。推測で埋めない |
| **X11** | 走査が index 8 以降に及んでいた | ★配列外 = 別データ構造★。その range の値は entity ではない。0..7 に限定して再実行 |
| **X12** | 「一致した map が 1 件」を母集団を示さずに報告していた | ★無効★。242 / 211 / 966 のどれを分母にしたかを必ず併記 |

---

## 4. ★街の住人は entity array 由来ではない(= 表示体数は oracle の対象外)★

原盤 capture(`orig_village_populated_ref.png`)には creature が **9 体前後**写っている。これを静的 placement の pass 条件にしてはならない。論拠を **強い順**に置く:

1. ★第一論拠 = 容量制約(構造制約、単独で結論を支える)★
   entity 配列の容量は **8**(clear loop `slti 8`、worker1 / worker3 が独立に disasm 確認)。twna01 は静的 7 record で占有済。
   ∴ ★9 体前後は物理的に配列に入らない★。**この論拠はゲーム進行度に一切依存しない**。
2. **第二論拠 = 一次 doc の記述**
   `EXTERNAL_RE_recruit_prosperity_2026-07-15.md`(boss1 が verbatim 照合済): L116「加入判定・★街 NPC 出現は下表のフラグ read で足りる★」/ L19「ガード flag(未実装だと勧誘済 NPC が field 再出現)」/ L173「★街 NPC ジジモン★」
   = 街の住人は ★勧誘フラグ駆動の別サブシステム★。
3. **第三論拠 = 自己整合(★条件付き★)**
   進んだセーブでも RAM entity 配列に余分な record が出ない(worker2 実測: twna01 = 7 record で json と過不足なく一致)。
   ★この論拠は「その savestate が実際に勧誘進行済であること」に依存する条件付き論拠であり、単独では結論を支えない★。

**帰結**: remake の `EntityPlacer` が再現するのは ★静的 placement のみ★。勧誘住人は **未実装領域 = 別 issue** として note に留め、★「表示体数」を pass 条件に入れない(TBD ですらなく対象外)★。

---

## 5. ★rot の切り分け — facing 成果は巻き戻さない★

混同すると **user PASS 済の facing まで巻き戻す事故**になるため、明確に分ける。 ★【2026-08-09 注記】この「PASS」は **我々が提示した画像に対する user の判断**であり、★user は remake を操作していない★(user 証言)。★PASS を無効化するものではなく、何を PASS したのかを正確にするための注記★★

- 7/23 struct の `rot@+0x0e` は delta `0xA2` を足すと ★`+0xB0` = 真の `rot_y` offset に一致★。同様に `pos@+0x06` → `+0xA8` に一致。
  ∴ ★pos と rot は同一 record から読まれており、両者の対応は正しい★。
- ずれていたのは ★`type` だけ★: `0xA2 + 0x22 = 0xC4` = ちょうど 1 stride = **隣の record の type**。
- ∴ ★facing 成果(user PASS 済、`Toko 315° / Yura 342.8° / Tane 45°` = ry 3584 / 3900 / 512)は再取得不要・巻き戻し不要★。 ★【2026-08-09 注記】この「PASS」は **我々が提示した画像に対する user の判断**であり、★user は remake を操作していない★(user 証言)。★PASS を無効化するものではなく、何を PASS したのかを正確にするための注記★★

**無効なのは 1 点のみ** — ★「その rot 値を shifted 説の独立証拠として使うこと」★:

`EntityPlacer.cs` L119-121 のコメントが挙げる「twna01 視覚 lock 値(Toko3584 / Yura3900 / Tane512)」は、unshifted と 3 点とも外れ shifted と 3 点とも合うため独立証拠に見える。しかし ★これは 7/23 artifact 表を rotation で言い換えたものである★【worker2 実測】:

| 7/23 §1 表の行 | その座標の json `rot_y` | 「視覚 lock」表記 |
|---|---|---|
| `(-1372,-2991)` → type30 トコモン | 3584 | Toko**3584** |
| `(-103,-1623)` → type43 ユラモン | 3900 | Yura**3900** |
| `(798,-1656)` → type44 タネモン | 512 | Tane**512** |

3 行とも 1:1 対応 = ★artifact 表から導いた値を artifact 表の裏付けに使う循環★。

→ **Phase 1 で `EntityPlacer.cs` のコメントを書き換える際、この根拠を消せるよう本節を引用すること**(X9 の適用対象)。
→ 削るのは ★「視覚 lock が shifted を支持する」という主張★のみ。★facing の数値そのものは残す★。

---

## 6. 教訓(次に同じ穴に落ちないための記録)

### 6.1 ★権威測定を inline の使い捨て scan でやらない(本 session で最も再利用性が高い)★

同一の判定を 2 通りで実施したところ、★self-check 付きの checked-in script(`pbr_p0_adjudicate.py`)は正答を出し、その場限りの inline scan は誤答を出した★。
inline scan は savestate 5 件について「211 map のどれとも一致せず未同定」と出力したが、★同じ論理を再実行しても再現しない★。実際には 4 件すべてが同定でき、すべて全一致した(P0 §7.3)。

- `_3`(twna13)の誤りは ★cap 飽和(entity 8 件 = 容量 8 なので sentinel が出ない)で走査が配列外へ抜けた★ことが原因と特定
- ★`_4`/`_5`/`_6`/`_7` の非再現は **原因未特定のまま**★。★「撤回したから解決」ではない★

★そして この cap 飽和の失敗モードは、私自身が P0 §5.1 に「count == 8 では sentinel が現れず、この rule は下限を上限として報告する」と **先に書いていた**★。
= ★規則を書くことと、それを自分に適用することは別★。本 session で PRESIDENT / boss1 / worker2 が繰り返した型そのもの。

→ **運用規範**: 権威測定は ★self-check 付き・容量境界を明示した checked-in script★ で行い、その場限りの inline scan の出力を doc に載せない。

### 6.2 静的データと実画面を同じ次元で扱わない

★同一 session 内で PRESIDENT と boss1 が同じ誤りに落ちた★ — **静的 placement データ**と、**進行状態を含む実画面**とを ★同じ次元のものとして扱った★(PRESIDENT はジジモン推論で、boss1 は「debug-gate 後 3 体」の計算で)。
`feedback_state_which_dimension`: 「一致 / 不一致 / 緑」は ★どの次元で見たかを明記しないと、射影で本体を語ることになる★。placement(静的 7 record)と画面(勧誘住人込み 9 体前後)は別次元であり、片方の数でもう片方を検算してはならない。

### 6.3 ★「数値の一致は説明ではない」が、実際に誤った裁定を止めた★

`989 − 966 = 23` が `MGEN06-10` の raw 合計 `23` と一致したとき、これを「説明できた」として流すことができた。本 doc は流さず、★「989 は ON 223 map、966 は全 242 map の集計で分母が違う = apples-to-apples でない」として拒否し、除外条項 X3b に格上げした★。

その結果として EXE table の全数再走査が行われ、★根拠にしていた `PBR_P0_map_index_table.tsv` が idx 0..238 で打ち切られていたこと★、★打ち切りの直後に MGEN06-10(いずれも gate ON)が存在すること★、★gate ON の正しい値は 223 であり中継された 218 が誤りだったこと★ が判明した。

**教訓**: 一致した数値は、★分母が同じであることを確認して初めて証拠になる★。分母を確認しないまま一致を根拠にすると、たまたま正しい結論に着いても過程は無根拠のままになる(`feedback_identity_is_not_evidence` / `feedback_correct_conclusion_not_excuse_process`)。
なお ★最終的に不整合 B は実質的な一致だった★(966 は全て gate ON map 由来で、分母は最初から揃っていた)。★正しい結論を疑ったことが無駄だったのではなく、疑ったからこそ tsv 打ち切りという別の実バグが出た★ — これが「訂正は自動的に改善ではない」の裏返しの実例。

### 6.4 oracle を使う前に、その oracle の被覆率を測る

`gate ON 223 map 中 87 map が warp 被参照 0` という測定と、memory の 3 機構調査(twna01 incoming 0)との関係は、★**互いに矛盾しないことを確認した**という水準であって、87 件の到達経路を個別に確かめたわけではない★。

この水準の区別が、既存 claim の根拠強度の訂正に波及した(PRESIDENT が memory を更新):
- ★結論(twna01 incoming 0)は据え置き★
- ★「この 3 機構で全 sink」という網羅性は未検証★
- ★spawn-warp 単独の被参照数は到達性 oracle として弱い(39%)★ / ★機構 1 だけの不在 claim は今後採用しない★
- 規範: ★「oracle を使う前に、その oracle の被覆率を測る」★

---

## 7. land 判定チェックリスト

```
[ ] P1  placement 6値一致        0件不一致 / 989 raw entry, 0 map / 223 map
[ ] P1b gating と placement       ★同一 map index から導出されている(別 source なら land 不可)★
[ ] P1c index 権威経路            gp-0x6ca6(u16) 経路。6d90 は別の読み手(mirror)
[ ] P2  json ↔ raw 同値          0件不一致 / 966 entry(MGEN06-10 は明示除外)
[ ] P2b numImg の出所            table entry(index)+10 由来。file 推定 / name 引き は oracle 無効
[ ] P3  entity数 = 先頭halfword   0 map 不一致 / 223 map、固定長走査でないこと code 確認
                                  ★count field は gate ON map でのみ意味を持つ(OFF の値は残バイト)★
[ ] P4  容量8 fail-fast           count=9 合成入力で停止、silent clamp 無し
[ ] P5  gating flags&0x80         OFF 21 map 全件 0体 / ON 223 map(★key = map index。map 名禁止★)
[ ] P6  debug-gate 独立判定       未設定=4体除外 / =1 で再出現、gating と別々に測定
[ ] P7  OFF-inert                 before/after の dump sha256 一致
[ ] P8  Unity CS0 error           0 件 ★［母数 未記載 2026-08-15］★この 行の 0 は ★母数が 添えて いません★★ ⇒ ★★未測定 に 落とします★★
[ ] P9  ViseNpcBootstrap 差分      起票済(適用は user 判断)
[ ] P10 user 実視覚 gate          V1-V5 に user の明示回答  ★AI では close 不可★

除外条項(1つでも該当すれば land 不可):
[ ] X1 user視覚未消化  [ ] X2 黄creature未決  [ ] X3 worktree外変更/push
[ ] X3b 母集団の検算崩れ(223+21+11=255 / 243-2+1=242)
[ ] X3c pipeline のどこかで map を name で primary key にしている(gating に限らない)
[ ] X4 飽和を上限扱い  [ ] X5 MGEN17を pass扱い  [ ] X6 2map を全map扱い  [ ] X7 未同定素材を計上
[ ] X8 record丸ごとsha  [ ] X9 artifact由来値の使用  [ ] X10 prefix未補正  [ ] X11 index8以降走査
[ ] X12 母集団なしの件数報告  [ ] X13 棄却済 signature(OFF∧numImg=0)で map 分類
[ ] X14 255/256slot 末尾未使用の区別を未決のまま確定扱い
[ ] X15 6ca6==0 を MAYO01 と断定  [ ] X16 entity配列 全0 素材を oracle に計上
```
