# Runtime capture session 2026-07-25(PRESIDENT 直営、user 実操作)

user 実操作(real display DuckStation + gdb-multiarch remote)による watchpoint/BP session。
生 log = `runtime_capture_2026-07-25/`(wp_field_loader_*.log / bp_damage_*.log / wp_hp_1.log / memdump_1.log / ram_A.bin / ram_B.bin)。
claim 規律: 以下【観測】=log 直読、【推論】=未裏取り。

## 0. user 視覚 gate(review queue 3 件、全 PASS)

1. **facing 村 = PASS**(「改善されています」、YURA facing 含め解消確認)
2. **gallery 136 distinct = PASS**(「大丈夫なようです」、灰青/破損混入なし)
3. **HONEST_GAP_LEDGER = PASS**(scale interim 93% 許容 + 43 不生成裁定妥当)

→ 7/24 handoff の user-gated 項目のうち視覚 review は全消化。**凍結解除は視覚 gate 分のみ**。

## 1. field NPC loader = 静的 RE unblock 達成(本日最大成果)

> ★★訂正(同日 16:2x、worker1 反証 + boss1 bytes 独立確認、PRESIDENT 受理)★★:
> anchor `0x80147358` は **field NPC entity array ではなく psyq VAB(サウンドバンク)VH ヘッダ buffer の内部**。
> pointer table `0x80134230` = 9 slot の VH buffer 表(全 slot pBAV magic、slot8=`0x8014677c`、0x80147358 はその +0xBDC。
> VabHdr ps=5 → VH size 0x1420 bit 一致)。呼び先 chain = psyq SPU lib(SsVabOpenHead/SsVabTransBody 系)。
> ENTITY_ARRAY 節の 32-byte 周期の正体 = **VagAtr(tone 属性、32-byte struct)**。遷移時のみ発火 = per-scene VAB reload
> (既知 FAALL.VHB per-scene bank 知見と整合)。**本節の【観測】(trap PC/ra/register/dump bytes)は全て真、
> 誤っていたのは解釈**(「section copy dispatcher」「entity array」)。watchpoint 対象 addr 自体が
> 7/25 handoff §B の誤 anchor 由来 = 同 handoff の entity claim(stride 0xc4/type@+0x22 等)も出所再検証中。
> 真の field NPC array = 再同定 dispatch 進行中(worker1 (b)+worker3 敵対検証)。off-by-one 機構は本 path では説明不能。

- 【観測】watchpoint `0x80147358`(entity array)trap: 書込みは **BIOS byte-copy `0xbfc02b68`**(`lbu t6,0(a1)` loop)内。
  - field 遷移時: dst=`0x80147359`(=+1、trap 時点)/ src=`0x80010be9` / len 残=`0x43` / **ra=`0x800cf1a8`**
  - 【観測】field 歩行中 trap ゼロ、遷移の瞬間のみ発火(2 回再現)= loader 帰属
- 【観測】caller 周辺 disasm(memdump_1.log、live RAM 直読):
  - `0x800cf1a0: jal 0x80091450`(= memcpy wrapper、BIOS A0 系と推論)
  - 引数構成(disasm 直読): **a0(dst)=`[0x80134230 + idx*4]` の指す先** / a1(src)=s0+([s0]&~3)(=header word0)/ a2(len)=[s0+4]−[s0+0](=word1−word0)
  - 【推論】= 「map file の section 別 copy dispatcher」。idx は sp+104 の値。pointer table `0x80134230` が各 section の書込み先を保持
- 【観測】battle 突入時にも同経路で copy: len=`0x843`、**ra=`0x80108960`**(第 3 の call site)。battle 終了時は len=`0x43`+同 ra で field 復帰 copy
- 【観測】entity array live 実体 dump 取得(遷移直後、memdump_1.log ===ENTITY_ARRAY===): 先頭 0x44 byte ゼロ、以後 32-byte 周期らしき record 列(id 連番 0x1d..0x2a、`00c0..00c3` 座標様 field)【周期/型は推論、worker 検証要】
- staging buffer 生 bytes も同 log(===STAGING===)。
- **→ worker1 の loader RE(off-by-one/gating/scale 厳密化)は静的 trace で進行可能に**(7/25 handoff の「watchpoint 待ち」解消)

## 2. battle damage RE = 部分進展(HP addr 未確定)

- 【観測】`s_damageCheck`(VA 0x80056ca8)hbreak: **戦闘突入 +5〜6 秒に 2 call(sp 0x30 差=別 frame 連続)で 1 回だけ発火、per-attack では発火しない**(3 戦再現 + user「now」同期攻撃で hit ゼロの決定打)。caller **ra=`0x8005cab4`**(file offset `0x9FD4`)。args a0=`0x8016b084` / a1=`0x8016b0bc`(既知 static table。live HP struct でない=下記)
- 【観測】HP 候補 `0x80014536`(snapshot diff で唯一の −627 一致)は**偽陽性と確定**: 攻撃 100+92 後の live 直読=3620(期待 52493 と不一致)。0xD040→0xCDCD の fill-pattern 偶然
- 【観測】`0x8016b000-0x8016b2ff` は 599 ダメージ前後で bit 不変 = live battle HP はこの帯に無い
- 【観測】非同期 20 連写(1.5s 間隔)では単調減少系列ゼロ = 窓内に攻撃なしの公算
- 【観測】0x80173xxx-0x80174xxx 帯は A↔B 交互振動(display list 系 artifact)、delta 一致は全て偽
- user 報告 damage oracle(帰属 loose): 77/422(戦1)、599(戦3)、627/100/92/22/26/11(戦4 以降)
- **次手(pre-register)**: (a)同期厳密の連写(戦闘中宣言→60s 攻撃連打+実況)(b)ゼロなら **scratchpad `0x1F800000`**(main RAM 外 1KB、battle hot state 定番)を gdb で before/after (c)HP addr 確定→watchpoint→書込み PC→getDamagePoint

## 3. 測定器 gotcha(今日確立、次 session 必読)

- **DuckStation gdb stub は stop 報告に watchpoint 帰属を付けない** → gdb の `commands` 不発火。`while $n<N { continue; printf ... }` 構造が正
- **software `break` は不安定**(hit 後消失疑い + pc+4 ずれ)→ **`hbreak`(Z1)を使う**。Z2 hardware watch も対応
- **切断(kill/quit)で emulator 側 watch/BP が残存**(z-packet 削除が届かない)→ 別 session の stop が混入する。★次 session 開始前に **DuckStation 再起動で全 stale 掃除**推奨★
- **gdb 経由 2MB dump は不成立**(120s timeout)。**/proc/pid/mem 直読が正**(既存 live_ram.py 手法、2MB 一瞬・無停止)。ptrace_scope=0 必要(再起動で 1 に戻る)
- CD streaming 中は trap PC が polling loop(`0x80091e4x`、a0=sector 単調増)に化ける noise あり
- 環境変更した永続 state: `EnableGDBServer=true`(settings.ini)/ gdb-multiarch インストール済 / ptrace_scope=0(揮発)

## 4. 残タスク(user 依存)

1. battle HP addr 確定(§2 次手、user 同席 10 分)→ 以後 getDamagePoint は自律
2. field-model 実機 verify(Unity build + DEGIMON_FIELD_MODELS=1、7/25 handoff §B)
3. G2 default 化裁定(2 の後)

## 5. 自律で進められるもの(dispatch 対象)

- **worker1: field loader 静的 RE**(§1 の ra/table を起点に EXE 直読で orchestrator 全景 + entity record 型 + scale/type field の書込み元 → off-by-one 機構と scale 厳密化)。oracle = memdump_1.log の live dump
- **worker2: battle 側 RE 前進**(ra=0x8005cab4 → file 0x9FD4 周辺の caller 関数を btl_rel.bin 静的解析、s_damageCheck 引数 struct の意味付け、+6s engage call の位置づけ)
- 検証規範: 本 doc の【推論】を promote する場合は EXE/bytes 直読裏取り必須
