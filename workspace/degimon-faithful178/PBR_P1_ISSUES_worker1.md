# PBR Phase 1 — 起票のみ / 本 dispatch で直さない issue (worker1, 2026-08-08)

本 dispatch(placement re-baseline)の scope 外だが、実装中に bytes で確認できた事項を起票する。
★いずれも本 dispatch では code を変更していない★。

claim 規律: 【観測】= bytes 直読 / disasm 直読 / 実行結果、【推論】= 未裏取り。

---

## ISSUE-1 ★ViseNpcBootstrap.cs の baked データが 7/23 artifact 由来★(変更提案 / user 視覚 gate 行き)

### 現状【観測 = `unity/Assets/ViseAvatar/ViseNpcBootstrap.cs` L64-66 直読】

twna01 の NPC 差替が座標 → 種族の対応を **hardcode** している:

| baked 座標 (x, z) | baked 種族 |
|---|---|
| `(-1372, -2991)` | TOKO |
| `(-103, -1623)` | YURA |
| `(798, -1656)` | TANE |

### RAM / JSON の実測値【観測】

twna01 = mapIdx 204。savestate 6 件(`_1.sav`/`_1.bak`/`_2.sav`/`_9.sav`/`_10.sav`/`_10.bak`)で
placement field(type / ai / pos.xyz / rot_y)が **bit 一致**。抽出 JSON `digimon[]` とも index どおり一致:

| idx | type | 種族 | pos (x, z) | rot_y | script_id |
|---|---|---|---|---|---|
| 0 | 117 | JIJI | (-161, -2451) | 3584 | 5 |
| 1 | 30 | TOKO | (-406, -2839) | 3072 | 6 |
| 2 | 117 | JIJI | (1054, -2877) | 1024 | 7 |
| 3 | 117 | JIJI | (-103, -1623) | 3900 | 8 |
| 4 | 43 | YURA | (-1372, -2991) | 3584 | 9 |
| 5 | 30 | TOKO | (798, -1656) | 512 | 10 |
| 6 | 44 | TANE | (-839, 2210) | 3072 | 11 |

※ 種族名は `data/species_model_codes.json`(`_source` = EXE `0x8013ce24` stride8)より: 30=TOKO / 43=YURA / 44=TANE / 117=JIJI

### 差分

| 座標 | baked | bytes 実測 | 判定 |
|---|---|---|---|
| `(-1372, -2991)` | TOKO | ★YURA(type 43)★ | 不一致 |
| `(798, -1656)` | YURA | ★TOKO(type 30)★ | 不一致 |
| `(-103, -1623)` | TANE | ★JIJI(type 117)★ | 不一致。かつ script_id 8 = `DebugNpcScriptIds["twna01"]` に含まれる |
| `(-839, 2210)` | (baked に無い) | TANE(type 44)、script_id 11 | baked が取りこぼしている |

★この 3 行は 7/23 の誤 anchor(`0x80147358` / `+0x22` 読み)時代の artifact を焼き込んだもの★【推論、ただし
座標と種族の対応が上表と系統的にずれている点は観測】。

### ★ずれているのは種族ラベルだけ。facing は 3 件とも正しい★【観測】

同 file L58-66 が baked している facing を、上表の `rot_y` と突き合わせた:

| baked 座標 | baked facing | その座標の RAM `rot_y` | 換算 (`ry*360/4096`) | 判定 |
|---|---|---|---|---|
| `(-1372, -2991)` | 315° | ★3584★ | 315.0° | ✅ 一致 |
| `(-103, -1623)` | 342.8° | ★3900★ | 342.77° | ✅ 一致 |
| `(798, -1656)` | 45° | ★512★ | 45.0° | ✅ 一致 |

∴ ★`pos` と `rot_y` は同一 record の対として正しく取れており、誤っていたのは `type` の対応だけ★。
**user PASS 済の facing 成果は再取得不要・巻き戻し不要**。
(無効なのは「この rot 値を shifted 説の *独立証拠* として引くこと」だけで、rot 値そのものは有効。)

### ★対応方針 = 本 dispatch では変更しない★

- ★この画は user PASS 済★。PASS の取消は user にしか決められない
- ∴ **変更提案として起票するに留め、user 視覚 gate に載せる**
- 提案内容: baked 表を撤去し、`EntityPlacer` の re-baseline 済 placement(= JSON/RAM 一致経路)へ一本化する
- ★視覚 gate で確認すべきこと★: 修正後に「村の見え方」が user の記憶する原盤と一致するか。
  一致しない場合は ★baked が正しく bytes 解釈が誤り★という可能性を H4 として残す(RAM が示すのは
  「静的 entity array の中身」であって「画面に出る全キャラ」ではない — ISSUE-3 参照)

### honest gap

- baked 値の一次出所(どの report / どの観測)は **未特定**。7/23 triage 由来と推定しているだけ【推論】
- 「PASS 済の画」が何を映していたかの一次証拠(screenshot)は本 issue では検証していない(worker3 の監査 scope)

---

## ISSUE-2 ★MGEN06-10 — gating ON の map で抽出が落ちている(実害あり)★

### 観測

- 抽出 JSON: `extracted/maps/mgen06..mgen10/*.json` の `digimon` 配列が ★0 件★【観測 = 242 map 全数走査】
- 生 `.map`: 6 / 3 / 4 / 3 / 7 = ★計 23 entity★ が存在【worker3 実測。worker1 は mgen06 の
  `count=6` を独自 heuristic で再現し追認、残 4 件は未自検証】
- ★MGEN06-10 は EXE の map table に実在し、5 件とも `byte12 = 0xD1` = ★gating ON★★
  【観測 = worker1 実測、idx 247/248/249/253/254】

### ★訂正(2026-08-08)★

本 issue の初版は「これらは map table に存在しない ⇒ 未使用 map ゆえ抽出が空でも実害なしの可能性」と書いていた。
★これは誤り★。原因は worker1 の `map_index_table.py` が ★最初の空 entry で走査を打ち切っていた★こと
(idx 239-246 が空 → その後ろの 247-249 / 253-254 を取りこぼした)。
memory `feedback_absence_in_truncated_list` そのもの。「未使用ゆえ実害なし」という理由付けは ★撤回する★。

### 現在の位置づけ

★gating ON の map で抽出が entity を落としている = 実害のある gap。原因は未特定★。

- 原盤 loader は gate ON なら entity を load する ⇒ 原盤では MGEN06-10 に NPC が出る
- remake は JSON が 0 件なので ★出ない★ = 忠実性の欠落
- ★latent bug との関係★: `EntityPlacer` の容量 8 fail-fast を gating の内側に置いた判断
  (boss1 査読の差し戻し)は、この抽出 gap を直した時に ★本当に通る path★ になるため重要度が上がった。
  assert の内側配置は維持が正しい。

### 対応

★本 dispatch では直さない★。抽出 pipeline を触ると placement re-baseline の回帰判定が交絡する。
別 dispatch で (a) 生 `.map` の実 entity を自分で全数 parse (b) 抽出が落ちる原因の特定。

### MGEN17 の扱い(別件、優先度 低)

- ★map table(idx 0..254)には不在★【観測】
- ただし ★EXE の別領域(file offset 0x942D8 = VA `0x80124AD8`)に `MGEN17.MAP` / `MGEN17.TFS` の
  ASCII が実在★し、そこは `MGEN16.MAP` / `MGEN16.TFS` と連続する ★file 名 table(stride 12)★
  【観測 = bytes 直読】。CD 上にも `map16/mgen17.map` が存在【観測】
- ∴ 「到達不能」と書くなら ★根拠は「map index table に entry が無い」であって「EXE に存在しない」ではない★。
  file 名 table には載っているので、★map index 以外の経路で参照される可能性は否定できていない★【honest gap】
- ★さらに強い限界★: 「warp から参照されない = 到達不能」も成立しない。
  worker3 の全数測定で ★gate ON 223 件のうち warp 被参照 0 の「実在 map」が 87 件 = 39%★。
  ∴ ★被参照 0 は「使われていない」の証拠にならない★。到達性を根拠にした判断は陽性側
  (「実際に参照されている」)だけが有効。

## ISSUE-4(★Phase 1 内で是正済★)map metadata の key 設計 — name ではなく index

★別 issue に逃がさず Phase 1 で直した★(PRESIDENT 裁定 2026-08-08)。記録として残す。

### 症状(発見の入口)

`YAKA25` の gating を worker1 の生成 script が ★誤って OFF★ にしていた。

### 根(症状ではなく)

★原盤の map 同一性は index で決まり、name は record の属性にすぎない★。実証【観測】:

| idx | name | numImg | flags | gating |
|---|---|---|---|---|
| 65 | YAKA25 | ★0★ | 0x44 | OFF |
| 232 | YAKA25 | ★2★ | 0xC4 | ★ON★ |

numImg は `.map` header の elements section slot 位置を決める ⇒ ★同じ `.map` から読める placement が変わる★。
∴ ★name が同じでも map としては別物★で、name は primary key になり得ない。

★到達性(warp 被参照)は採用根拠に含めない★: worker3 の全数測定で ★gate ON 223 件のうち
warp 被参照 0 の「実在 map」が 87 件 = 39%★。∴「参照されない」は「到達不能」をほぼ含意しない。
陽性側(idx232 が実際に参照されている)のみ有効で、★「idx65 は被参照 0 だから残骸」は主張できない★。
同じ理由で ★「空 slot への warp 参照が 0 件だから 255 slot 対応は不要」も成立しない★。

### ★3 tool が 3 通りの暗黙規則で動いていた★【観測】

| tool | name→index の暗黙規則 | YAKA25 の結果 | 判定 |
|---|---|---|---|
| `extracted/map_entries.json` の `name_to_id` | first-wins | 65 | ★誤り★ |
| `dwr_RE/tools/convert_map.py`(旧) | dict 挿入順 = last-wins | 232 | ★結果的に正。ただし偶然★ |
| `workspace/tools/gen_map_entity_gating.py`(初版) | first-wins | 65 | ★誤り★ |

★convert_map が正しい parse になっていたのは last-wins が偶然 idx232 を選んだからで、設計の正しさではない★。

### 是正

1. ★`data/map_index_table.json` を単一権威として新設★(`workspace/tools/gen_map_index_table.py`、EXE から生成)。
   index key。`name_to_index` は ★重複を明示規則 + 根拠つきで解決済★。未登録の重複は ★生成時に fail-fast★
2. `data/map_entity_gating.json` は ★権威の name-key 射影★に変更(重複解決を再発明しない)
3. `convert_map.py::load_map_entries()` を ★権威を引く実装★に変更。権威が無い場合の fallback でも
   ★重複を黙って潰さず警告★する
4. `EntityPlacer.cs` の comment に name key の caveat と YAKA25 の解決根拠を明記

### 検証【観測】

- 権威 file と既存 `extracted/map_entries.json` の突き合わせ: ★244 named entry × 10 field で不一致 0★
  (name / numImg / numObj / flags / hasDigimon / hasNoTimeCycle / soundId / doorsId / toiletId / loadingNameId)
- `convert_map.py` の新旧 `load_map_entries()` 出力差分: ★0 name★
  = ★抽出結果は変わらない(silent regression 無し)。変わったのは「規則が明示になった」点★
- ★honest★: `soundId = flags & 0x3F` は `0x1F` でも不一致 0(bit5 が全 entry で 0)。★mask 幅は未確定★

---

## ISSUE-3 ★勧誘で増える街の住人は現行 remake で原理的に再現できない★

### 観測

- `EntityPlacer` は ★静的 JSON(`map.Npcs`)しか見ない★【観測 = code 直読】。
  勧誘フラグを読む経路も、動的に NPC を追加する経路も存在しない
- 原盤 entity array の容量は ★8 record★【観測 = clear ルーチン `0x800BB994` の loop 上限 `slti $at,$s0,8`】
- twna01 は静的 7 record を既に占有している【観測 = RAM 6 素材 bit 一致】
- ∴ ★勧誘で増える住人は静的 entity array には入りようがない★(残 1 slot しかない)= **別サブシステム**
- `docs/EXTERNAL_RE_recruit_prosperity_2026-07-15.md` が繁栄度 / 勧誘フラグ駆動の街 NPC 出現を記述している
  【boss1 が verbatim 確認、worker1 は未直読 = 要裏取り】

### 含意

- 「原盤の村の画に何体写っているか」と「entity array に何 record あるか」は ★別の量★。
  ★entity array の record 数を『村の住人数』の oracle にしてはいけない★
- 逆に、placement re-baseline の回帰判定は ★静的 entity array の範囲に限定して行うのが正しい★
  (勧誘住人は本 dispatch の対象外)

### 対応

★別 issue。Phase 1 に混ぜない★。実装するなら勧誘フラグ read + 動的 NPC 追加経路の新設が要り、
placement とは独立した設計判断になる。

---

## 本 dispatch で **変更した** もの(参考、本 doc の対象外)

| file | 変更 |
|---|---|
| `unity/Assets/Scripts/Field/EntityPlacer.cs` | i+1 補正撤去 / map 単位 gating 適用 / 容量 8 の fail-fast / 根拠 comment 差替 |
| `data/map_index_table.json`(新規) | ★map metadata の単一権威★(index key、重複解決つき) |
| `data/map_entity_gating.json`(新規) | 権威の name-key 射影。gating OFF ★20 name★ |
| `workspace/tools/gen_map_index_table.py` / `gen_map_entity_gating.py`(新規) | 上記の生成 script |
| `dwr_RE/tools/convert_map.py` | `load_map_entries()` を権威引きへ(出力差分 0) |
| `workspace/tools/savestate_ram.py` / `map_index_table.py` / `entity_dump.py` | Phase 0 の oracle infra |

★`ViseNpcBootstrap.cs` は 1 byte も触っていない★。

---

## follow-up registry との対応(2026-08-08 closeout)

本 doc の issue は degimon repo の `workspace/MASTER_TASKS.md` 末尾
「★placement re-baseline (PBR) follow-up registry★」に ★FU-1〜FU-7 として登録済★。

| 本 doc | registry | 状態 |
|---|---|---|
| ISSUE-1(ViseNpcBootstrap baked) | ★FU-1★ | ★user 視覚 gate の回答待ち★。code は 1 byte も触っていない |
| ISSUE-2(MGEN06-10 抽出 gap) | ★FU-2★ | gate ON の map で抽出が落ちている。原因未特定 |
| ISSUE-3(勧誘住人) | (別サブシステム。registry 外) | Phase 1 に混ぜない |
| ISSUE-4(key 設計) | — | ★Phase 1 内で是正済★(単一権威 + 明示規則) |
| — | ★FU-3★ | `gp-0x6ca6` の writer 未特定(gp 相対 store 0 件、pointer 経由) |
| — | ★FU-4★ | commit 2799c4e の「Unity CS0 gate」の検証形式が不明 |
| — | ★FU-5★ | awakening RE ctx 3 値の現行体系での再照合 |
| — | ★FU-6★ | "story" ラベル汚染の doc 6 本 再点検 |
| — | ★FU-7★ | `_4/_5/_6/_7` 非再現の原因未特定(撤回 ≠ 解決) |

★本 dispatch は merge 済(main = 473ded8)だが user 視覚 gate は未消化 = 完成 claim なし★。
