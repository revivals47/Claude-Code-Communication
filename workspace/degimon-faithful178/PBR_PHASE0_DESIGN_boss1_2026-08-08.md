# placement re-baseline — Phase 0 設計 (boss1, 2026-08-08)

**dispatch**: PRESIDENT 裁定 7/25 の独立 dispatch 化 / user GO 2026-08-08
**scope**: ★oracle の再測定のみ。実装着手は禁止★(Phase 1 GO は PRESIDENT が出す)
**repo**: `/home/ken/Desktop/Digimon/degimon_world_remake` (main = a6fbcb6)
**worktree**: `../degimon_world_remake-pbr` (branch `track1/placement-rebaseline`) — 作成済
**禁止**: push / main 改変 / OFF-inert 破壊 / 推測での shift 有無決定 / twna family からの cross-family 一般化

claim 規律: 【観測】= 実行結果・bytes 直読・disasm 直読、【推論】= 未裏取り。裏取りのない数値は「未検証」と明示。

---

## 0. 判定の形式(PRESIDENT 指定)

報告は **「どちらが正しいか」ではなく「RAM bytes が何と一致したか」** の形で書く。
「shifted / unshifted」の 2 択に閉じず、★H4(両方誤り)を明示的な outcome として持つ★。

### 判定軸(PRESIDENT 08/08 追加分を含む全 4 軸)

| 軸 | 内容 | 担当 |
|---|---|---|
| (0) type↔pos pairing | index ベースで shifted / unshifted のどちらが RAM と一致するか | worker2 |
| (a) entity 数 | stream 先頭 halfword = JSON npcs 件数 と一致するか | worker3(静的) + worker2(RAM 側 live record 数) |
| (b) gating | `[0x8013541C + mapIdx*16].byte12 & 0x80` — OFF map は RAM 側に record 不在 | worker3 |
| (c) ★順序★ | JSON npcs 配列順 と RAM record index 順 が同一である保証は無い。崩れていれば shifted も unshifted も両方誤り | worker3(静的 stream 照合) + worker2(position-key 照合) |

★(c) が盲点である理由★: 7/23 triage(`unity/Assets/ViseAvatar/JSON_NPC_OFFBYONE_TRIAGE.md`)は **index ベース**で組まれている。
∴ Phase 0 の照合 key は **index でなく position 座標一致** を主とし、index 一致は副次確認に落とす。

---

## 1. 入力 spec(確定済 RE、a6fbcb6)

`docs/RE_field_entity_loader_2026-08-08.md` より【観測】:

- loader 本体 = VA `0x800bae54`。`a0` = halfword stream ptr、`a1` = map index
- 先頭 halfword = ★entity 数★(固定長走査ではない)
- gating: `[0x8013541C + a1*16].byte12 & 0x80` が 0 なら loop 全 skip
- array base `0x80145608` / stride `0xC4`(実命令列から直接確認 = 第 3 の独立経路)
- record: `type@+0x00`(s16, clear=0xFFFF) / `ai_type@+0xBC`(s8) / `pos.x,y,z@+0xA8,+0xAA,+0xAC`(s16) / `rot_y@+0xB0`(s16) / `+0xBE`=0 固定
- loader は stream を record 内で **連続読み**: idx0=type, idx1=ai_type, idx2..4=pos.xyz, idx5=?, idx6=rot_y, ...

★誤 base `0x80147358` + `+0x22` 読みは 7/25 に測定 artifact と確定★。7/23 triage §4 の struct 記述(base 0x147358 / type@+0x22 / pos@+0x6,8,a)は **その誤 anchor 時代のもの** = 引用禁止。

---

## 2. boss1 が既に確認した ground truth(workers はここから始めてよい)

### 2.1 利用可能な RAM 素材の実在【観測 = boss1 実行】

`Claude-Code-Communication/workspace/degimon-faithful178/runtime_capture_2026-07-25/`:
- `ram_A.bin` / `ram_B.bin` / `ram_live_1628_1.bin` / `_2.bin` / `_3.bin` = **各ちょうど 2097152 B = 生 PS1 RAM 2MB**
  → ★file offset 0 = `0x80000000`。prefix 補正 **不要**★(savestate ではない生 dump)
  → commit c8967fa の記述では ram_A/B の map = **mayo00**(boss1 未再確認 = 要裏取り)

`/home/ken/Desktop/Digimon/degimon_world_remake-f1c/workspace/f1c/`:
- `canon_baby_point.sav` / `canon_baselineC.sav` / `canon_care_seed_point.sav` = DuckStation savestate
  → ★prefix 0x1A62 補正が要る側★。現 `savestate_ram.py` は anchor から gp=0x8014686e と印字(= 未補正値)

`workspace/savestate_backup/`(各 worktree に存在):
- `slot3_day11.bak.bak` / `slot3_day12.sav.bak` / `slot4_day11.sav.bak` / `slot7_day12.sav.bak` = 各 ~1.9MB = **savestate 候補、未検証**

### 2.2 ★7/23 triage が使った twna01 savestate `_9/_1/_2/_10` は所在不明★【観測】

`~/.local/share/duckstation/savestates/` = **空**(dir mtime 7/12 04:53)。
`find` でも `*_9.sav` 相当は発見できず。

→ ★Phase 0 の当初想定「twna01 savestate 群を読み直す」は **素材が無い可能性が高い**★。
   これは honest blocker 候補。worker1 が全数確認し、無ければ「user に何を取ってもらうか」を具体化する。

### 2.3 mayo00 と思われる RAM の entity array 実測【観測 = boss1 実行、ram_A.bin】

base `0x80145608` / stride `0xC4` / type@+0x00 で走査した生値:

```
[ 0] type=   74 ai= 12 pos=(594,0,2347)   ry=3072
[ 1] type=   74 ai= 12 pos=(327,0,-1500)  ry=3072
[ 2] type=    3 ai= 16 pos=(-226,0,1688)  ry=3072
[ 3] type=   83 ai= 12 pos=(594,0,2347)   ry=3072
[ 4] type=   83 ai= 12 pos=(327,0,-1500)  ry=3072
[ 5..7] type=0xFFFF (clear sentinel)
[ 8] type=    0 ai=171 pos=(-785,35,-18)  ry=970
[ 9] type=65520 ai=221 pos=(-4,-1,1184)   ry=26
[10] type=  827 ai=  2 pos=(0,0,0)        ry=15
[11] type=65384 ...  [13..22] 値が構造化されていない
```

★注目点(仮説であって結論ではない)★:
- idx 0-4 は ai/ry が整った「本物らしい」5 record。idx 5-7 が clear sentinel、idx 8 以降は非構造化 = **stale 残骸**の疑い
- ★position が `p0,p1,p2,p0,p1` と周期 3 で反復し、type だけが `74,74,3 | 83,83` と変わる★
  → 「entity 数 = 3 で、idx 3,4 は前 load の残骸」か「entity 数 = 5 で同一 position に 2 体」か、**どちらかを bytes で決めること**
  → これは (a) entity 数軸と (c) 順序軸の両方に効く決定的材料。★推測で片付けない★
- ram_A / ram_B / ram_live_1628_* で idx 0-4 は完全一致、idx 10/11/21/22 のみ差分(= 動的領域)

---

## 3. worker 割り当て

### worker1 — RAM oracle infra + 素材全数 inventory
【worktree】`~/Desktop/Digimon/degimon_world_remake-pbr`(branch `track1/placement-rebaseline`)
【出力】`workspace/degimon-faithful178/PBR_P0_RAM_INVENTORY_worker1.md`(Claude-Code-Communication 側)

1. `workspace/tools/savestate_ram.py` の prefix 0x1A62 補正
   - `load_ram()` が **EXE 署名で prefix を実測**する方式(MASTER_TASKS 項目2 の修正案)
   - ★回帰確認: `SAVESTATE_TOOL_IMPACT_AUDIT.md`(ce5908b)の主要 anchor 12 件が **不変**であること★
   - ★変化するもの(印字 gp `0x8014686E` → `0x80144E0C` 等)は **明示的に列挙**★。静かに他 claim を壊さないこと
   - 生 2MB dump(`ram_*.bin`)は prefix 0 として同一 API で読めるようにする
2. RAM 素材の全数 inventory(§2.1 の 5 + 3 + 4 件、+ 他に見つかった全て)
   - 各 file について: prefix / anchor / 有効性 / **どの map か**(map index の在処を特定して読む。特定できなければ「未同定」と書く)
   - 各 file の entity array を base `0x80145608` / stride `0xC4` で全 record dump(type/ai/pos/ry/+0xBE)
3. ★`_9/_1/_2/_10` の所在を全数確認★。存在しないなら honest blocker として報告し、
   **user に依頼すべき savestate の具体仕様**(どの map でどの状態、何個)を書く

### worker2 — JSON 側 + 機械判定
【作業】read-only(git tree を改変しない)。参照は main tree で可
【出力】`workspace/degimon-faithful178/PBR_P0_ADJUDICATION_worker2.md` + 判定 script

1. worker1 が map 同定した RAM 素材について、対応する `extracted/maps/<map>/<map>.json` を読む
2. ★3 仮説を機械判定★(結果は「RAM bytes が何と一致したか」の形で):
   - H-unshifted: `RAM[i].type == json.npcs[i].type` かつ `RAM[i].pos == json.npcs[i].pos`
   - H-shifted:   `RAM[i].type == json.npcs[i+1].type` かつ `RAM[i].pos == json.npcs[i].pos`
   - ★H-poskey: index を捨て、**position 完全一致**で RAM record ↔ json entry を対応付け、その上で type を照合★
   - どれも成立しないなら ★H4 = 3 説とも棄却★ を明示的な結論として出す(それは失敗ではなく前進)
3. (a) 軸: RAM 側の有効 record 数 vs JSON npcs 件数。§2.3 の「5 か 3 か」を bytes で決着させる
4. ★母集団を数える★: 一致/不一致を「N 件中 M 件」で書く。少数一致から systematic を主張しない
5. ★cross-family 一般化禁止★。判定は「この map の bytes について」に限定して書く

### worker3 — stream 静的照合 + gating + 視覚反証の oracle 監査
【作業】read-only
【出力】`workspace/degimon-faithful178/PBR_P0_STREAM_GATING_worker3.md`

1. ★(c) 順序の決定的テスト(静的、RAM 不要)★
   - loader が読む halfword stream = map file のどの領域かを特定し、**生 `.map` bytes を loader の読み順(先頭 halfword=count、以降 record 内連続読み)で手 parse**
   - その結果と `extracted/maps/<map>/<map>.json` の npcs 配列を **順序込みで** 突き合わせる
   - ★これが一致すれば「stream 順 = JSON 順」が bytes で確定し、(c) が閉じる。一致しなければ順序仮定が崩れている★
   - 対象: twna01 を主、mayo00 を副(worker1 の map 同定に合わせる)
2. (a) 静的側: `.map` 先頭 halfword の実値 vs JSON npcs 件数(全 map で走査可能なら母集団つきで)
3. (b) gating: `0x8013541C` table を RAM dump から読み、observed map の byte12 & 0x80 を実測。
   OFF map があれば「RAM に record 不在」が実際に成り立つか確認
4. ★視覚反証の oracle 監査(必須・honest)★
   - MASTER_TASKS 項目5「(798,-1656) = 黄 creature」の **一次証拠を特定**せよ(どの画像 / どの観測 / 誰の report か)
   - その証拠が **何を実際に示しているか**を確認。座標の同定根拠、撮影が原盤か remake か、色判定の妥当性
   - ★「一致しても不一致でも honest 報告」。都合の良い側だけ採用しない★
   - 候補素材: `workspace/degimon-faithful178/orig_village_populated_ref.png` / `village_species_zoom.png` /
     `orig_tokomon_village_white_zoom.png` / `REVIEW_worker1_entity_rebase_worker3.md` / 7/23 triage doc の発見経緯 §冒頭

---

## 4. 共通規律(全 worker)

- ★実装着手禁止★。`EntityPlacer.cs` を含む Unity コードは **1 byte も触らない**
- 判断根拠は **savestate/RAM bytes 直読** か **EXE/loader disasm** のみ。position 推論・slot 仮定・「たぶんこう」は禁止
- 7/23 triage doc の §4 struct 記述(base 0x147358 / type@+0x22)は **誤 anchor 由来 = 引用禁止**。§1 の position→type 表も「誤 base で読んだ値」なので **oracle として使わない**(再測定対象そのもの)
- 使った tool 自身を疑う: 読み取り script は既知値(clear sentinel 0xFFFF、stride 0xC4)で self-check してから権威測定に使う
- 打ち切られた list / cap 飽和下での「不在」主張禁止
- 詰まったら 30 分以内に boss1 へブロッカー報告(材料添付)。勝手に scope を広げない

---

# 改訂履歴 (v0.1 → v0.2、2026-08-08 session 中)

本 doc は dispatch 開始時 (17:40) の設計。以下は session 中に **bytes で否定された箇所** の訂正記録。
後世が「なぜこの結論になったか」を re-discover できるよう、誤った版も残す。

## 訂正 1 — §2.2「twna01 savestate は所在不明」= 誤り (boss1)

**誤**: `~/.local/share/duckstation/savestates/` が空 → 素材が無い可能性が高い、user 依頼が要る。
**正**: DuckStation は **flatpak** ゆえ savestate は
`~/.var/app/org.duckstation.DuckStation/config/duckstation/savestates/` にある (PRESIDENT 指摘、boss1 が `ls` で実在確認)。
`SLPS-01797_1/_2/_9/_10.sav` ほか実在。**user 依頼は不要だった**。

★教訓★: ★不在 claim は「探索範囲が正しいこと」の確認とセットでないと成立しない★。
flatpak sandbox の path 規約を見落とした典型。→ [[feedback_absence_in_truncated_list]] と同型。

## 訂正 2 — §2.3「idx3,4 は前 load の残骸」= 誤り (boss1)

**誤**: position が p0,p1,p2,p0,p1 と周期 3 で反復 → idx3,4 は stale 残骸ではないか。
**正**: `mayo00.json` の digimon 配列に **同じ position 重複が実在** (idx0/3 が同座標で type74/83・script_id 5/7、
idx1/4 が同座標で type74/83・script_id 8/9)。**原盤データそのもの**。entity 数は 5 で決着。

## 訂正 3 — §2.3「idx8 以降は stale 残骸」= 誤り (boss1)

**正**: ★entity 配列の容量は 8 record★ (clear routine の loop 終端 `slti $at,$s0,8`、worker1/worker3 が独立に disasm 確認)。
idx8 以降は残骸ではなく **配列外**。boss1 が 24 record 走査して数えた「非0xFFFF=22」は **無効値** (配列外読み)。
→ 走査は **index 0..7 に限定**すること。

## 訂正 4 — 「村に JIJI は出ない / debug-gate 後 3 体」= 誤り (boss1)

**誤**: `DebugNpcScriptIds[twna01]={5,6,7,8}` を適用すれば通常表示は s9/s10/s11 の 3 体。原盤もそう見えるはず。
**正**: 原盤 capture (`orig_village_populated_ref.png`) には **creature が 9 体前後** 写っており、
白髪白ひげの老人 (ジジモンと見て矛盾しない) も居る。
真因 = ★街の住人は静的 entity array ではなく「勧誘フラグ + 繁栄度」の別サブシステム由来★。

論拠は **この順序** で読むこと (弱い論拠を主柱と誤読しないため):
1. ★第一 = 容量制約★: array 容量 8、twna01 は静的 7 record で占有済 → 9 体前後は**物理的に入らない**。**進行度に依存せず単独で成立**
2. 第二 = doc 引用: `EXTERNAL_RE_recruit_prosperity_2026-07-15.md` L19 / L111 / L116 / L173 (boss1 が verbatim 照合済)
3. 第三 = 自己整合: 進んだセーブで余分 record が出ていない。ただし **savestate が実際に進行済であることに依存する条件付き論拠**

★教訓 (PRESIDENT と boss1 が同一 session で同じ穴に落ちた)★:
★静的 placement データと、進行状態を含む実画面とを「同じ次元のもの」として扱った★。
PRESIDENT はジジモン推論で、boss1 は「debug-gate 後 3 体」で。→ [[feedback_state_which_dimension]]

## 訂正 5 — PRESIDENT 提示の「script_id = entity+0x65」= 誤り

record 全 0xC4 byte を u8/u16 で全 offset 走査しても json script_id 列と一致する offset は **該当なし**。
★loader は script_id を entity array に載せていない★ → (座標, script_id) の 3 つ組 join は **RAM から構成不能**。
PRESIDENT は「store を address 順に並べて stream index を推定した仮定自体が未検証だった」として撤回済。

## 訂正 6 — 黄creature の位置づけ

「反証が消えた」ではない。★別サブシステム (勧誘住人) の観測だったため、静的 placement の判定材料としては弁別力ゼロ★。
doc に「反証なし」と書くと後世が誤読するため、**除外理由まで書くこと**。

---

# 判定軸の最終形 (v0.2)

| 軸 | 結論 | 接地 |
|---|---|---|
| (0) pairing | ★unshifted★。shifted は 0 一致 | RAM placement subset が 6 素材 bit 一致・242 母集団で twna01 に一意 / worker2 が shift 量 k=-2..+3 全走査で k=0 以外 0 件 |
| (a) entity 数 | ★生.map 先頭 halfword★ | gate ON 223 map の raw count max=8、9 以上 0 件。★48 map (21.5%) が丁度 8 = 飽和ゆえ「8 で足りていた」は言えない★ |
| (b) gating | `flags & 0x80`、EXE 内静的 table | RAM dump 5 件すべてで EXE と byte 完全一致 = runtime 書換なし。OFF 21 map 実名列挙済 |
| (c) 順序 | ★file entry 順 == json 配列順★ | worker3 の独立 parse で 966 record / 23184 field 不一致 0、parse 終端 == tilemap_offset が 240 map で gap 0 |
| H5 (重複座標) | twna01 では反証 (座標 7/7 一意) | ただし ★73/211 map に座標重複が実在★ → position を一意 key として扱う前に必ず重複度を数える |

## 7/23 off-by-one = 測定 artifact (算術で零自由度)

7/23 struct (pos +0x6,+0x8,+0xa / rot +0xe / type +0x22) vs 8/8 disasm (pos +0xA8,+0xAA,+0xAC / rot +0xB0 / type +0x00):
- ★4 field すべて delta = 0xA2★ (over-determined)
- 同 frame で type を読むと 0xA2 + 0x22 = ★0xC4 = 1 stride = 次 record の +0x00★
- base も閉じる: `0x80147358 − 0x1A62 (prefix) = 0x801458F6 = 0x80145608 + 0xA2 + 3×0xC4 (余り 0)`

★ただし rot は無効ではない★: rot@+0xe は delta 0xA2 で +0xB0 に写る = **pos と同一 record**。
ずれていたのは type だけ。∴ ★facing 成果 (user PASS 済) は再取得不要・巻き戻し不要★。
無効なのは「その rot 値を shifted 説の**独立証拠**として使うこと」だけ (worker2 が循環として摘出)。

## 未測定 (「緑」と読み替えてはいけない)

- ★MGEN17 は 255-entry table に名前が無く map index で到達不能★ = count 未取得
- MGEN06-10 は生.map に 6/3/4/3/7 entity があるが json 0 件 = 抽出側 gap (別 issue)
- YAKA22 (gate OFF) は count 63 だが record parse 即破綻 = placement データではない疑い (gate OFF ゆえ loader は 1 byte も読まない)
- type を runtime 書換する経路の全数確認は未了 (7/25 watchpoint は 1 map・1 session の観測)

## 訂正 7 — 「gate ON = 218 / 空 entry 0 件」= 誤り (boss1)

**誤**: worker1 の `PBR_P0_map_index_table.tsv`(239 entry)を根拠に、worker3 の「gate ON 223 / 空 entry 11 件 / raw 989」を**3 件とも否定**した。
**正**: ★tsv は idx 0..238 で打ち切られていた★(最初の空 entry で走査停止)。EXE 直読 (PRESIDENT 指摘 → boss1 追認):

```
idx 238 TOPN01 0xCC ON
idx 239-246  空 8 件
★idx 247 MGEN06 / 248 MGEN07 / 249 MGEN08 = b12 0xD1 = ON★
idx 250-252  空 3 件
★idx 253 MGEN09 / 254 MGEN10 = 0xD1 = ON★
idx 255      5a 00 14 00 …  = 16B map record の体を成さない別データ
```

★全数集計 (idx 0..254 = 255 entry): 名前あり 244 / ON 223 / OFF 21 / 空 11 → 223+21+11 = 255★
∴ ★worker3 の 3 件はすべて正しかった★。不整合 B も `989 − 966 = 23 = MGEN06-10 の 6+3+4+3+7` で解消。

★教訓★: ★打ち切られた list を使って不在を主張した★ — [[feedback_absence_in_truncated_list]]。
真の失敗は ★連続性を全体性と読み替えたこと★。`0..238` に穴がないのを見て「これが全体だ」と判断したが、
★連続性は「範囲内に穴がない」ことしか言わず、「範囲が全体である」ことは言わない★。
さらに悪いことに、boss1 は worker3 に対して「あなたの数値も検証対象」と書きながら、
★自分が根拠にした list の完全性は検証していなかった★ = 飽和チェックを他人にだけ課した。

★この誤裁定を止めたのは worker2 の除外条項 X3b★ — 数値の一致 (23 と 23) を「説明できた」で流さず、
★母集団が違う = apples-to-apples でないと拒否し、「未解消なら land 不可」に格上げした★。
→ [[feedback_identity_is_not_evidence]] が実際に誤った判断を止めた実例として記録する価値がある。

### 帰結: 「MGEN06-10 は未使用 map ゆえ無害」は **不成立**

MGEN06-10 は ★gate ON★。原盤 loader は gate ON なら entity を load する。
生 `.map` に 23 entity があり json は 0 件 = ★gate ON の map で抽出が落ちている = 実害のある抽出 gap★。
理由付けは ★「gate ON だが抽出が落ちている、原因未特定」★ が正しい。

同時に ★boss1 が検出した latent bug (容量 8 の fail-fast が gating の外) の重要度も上がった★ —
MGEN06-10 が ON である以上、抽出 gap を直した瞬間に本当に通る path になる。assert は gating の内側 (commit 4ace328) で正しい。

### MGEN17

★map table (idx 0..254) には不在★。ただし ★ASCII `MGEN17` は EXE 別領域 file offset 606936 に実在★
(table 領域は 675356〜。YAKA01=675644 / YAKA21=675820 は table 内)。
∴ 「到達不能」と書くなら ★根拠は「table に無い」であって「EXE に無い」ではない★。

---

# boss1 が本 session で出した誤りの分類 (2 種)

| 種類 | 該当 | root cause |
|---|---|---|
| ★次元の取り違え★ | 訂正 4 (村に JIJI / 3 体) | 静的 placement データと、進行状態を含む実画面を同じ次元で扱った → [[feedback_state_which_dimension]] |
| ★打ち切り list での不在主張★ | 訂正 1 (flatpak path) / 訂正 7 (tsv 239) | 探索範囲・list 範囲が全体であることを検証せずに「無い」を主張 → [[feedback_absence_in_truncated_list]] |

★訂正 1 と訂正 7 は同じ穴に 2 度落ちている★。1 度目 (savestate) の直後に自分で
「不在 claim は探索範囲が正しいことの確認とセットでないと成立しない」と worker に伝達しておきながら、
2 度目 (tsv) では自分がそれを適用しなかった。★他人に課した規律を自分に適用する★のが本 session 最大の反省点。

## 訂正 8 — table 終端「255 entry」の根拠は**形状判断**であり未確定 (boss1 / PRESIDENT 双方)

訂正 7 で boss1 は idx 255 を「16B map record の体を成さない別データ」として table 終端と判断した。
★これは訂正 7 で失敗したのと同じ判断様式★ — 空 entry を終端と誤読したのと同型である。
MGEN06-10 が★空 8 件の後ろに実在した★以上、「変に見える」「garbage に見える」は終端の証拠にならない。

★「255 entry」も「256 entry」も、現時点では どちらも未確定★。

### 終端を決める正しい根拠 (優先順)

1. ★index の型幅★ — 現 map index (`gp-0x6ca6` = VA `0x8013E166`) を load する命令が `lb/lbu` か `lh/lhu` か
   - `u8` なら値域 0..255 = ★table は構造的に 256 entry★。idx 255 は「使われていない実在 slot」であって table 外ではない
   - `lhu` (worker1 の初報では `0x800EC47C` の `lhu`) なら ★256 で構造的に切れる根拠にはならない★ → 別の根拠が要る
   - loader `0x800BAE54` 内で index が mask/clamp される可能性も要確認
2. ★table 全体を走査する code の loop bound★ — あれば最善
3. ★後続データの開始 address★ (次の既知シンボル / 被参照 address) で物理上限を挟む
4. 形状 — ★根拠として最弱。使うなら「形状判断ゆえ未確定」と明示する★

★教訓★: 本 session で boss1 は ★同じ判断様式で 3 度躓いた★ (探索範囲の未確認 → list 打切り → 終端の形状判断)。
いずれも ★「境界をどう引いたか」自体を検証しなかった★ことが共通の根。
→ [[feedback_fabricate_in_incidental_fields]] (引いた線自体を検証せよ / 除外・filter は最も検証されない) が該当する。
