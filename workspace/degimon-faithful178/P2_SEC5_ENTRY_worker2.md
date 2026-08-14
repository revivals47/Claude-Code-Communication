# P2_SEC5_ENTRY_worker2 — ★③ section 番号体系の 突合 ／ ④ section へ 入る 経路★

★受領★ = boss1 #401 ③④ ／ ★測定時点★ = 2026-08-14 ／ ★★観測より 前★★

---

## ★1. ★★③ ★私の sec 5 と 彼の §5 は ★同じ 番号体系★★★★

```
 ★私の 器の 逐語（scn_core.sec_table_exe）★:
   ★body+2 から stride 4★ / ★★sid = u16(body[i])★ / ★off = u16(body[i+2])★★ / ★sid == 0xFFFF で 停止★
 ⇒ ★★∴ ★section 番号は ★私が 付けた 連番では なく ★file に 書かれた id★★★★
 ⇒ ★★∴ ★remake が 同じ 表を 読む なら ★同じ 番号体系★★★（★彼の 実装は 私は 見て いません = ★中継★★）
 ★★一意性（= 取り違えの 余地）★★:
   ★entry 109 で ★flag 1 を 立てる 0x1C は ★1 件だけ（pc 0x021E）★★ / ★その pc は ★sec 5（0x0202）の 直線 上★★
   ⇒ ★★∴ ★『flag_w = {1} の section』は ★sec 5 以外に ありません★★★（★他の section は 280 / 291★）
 ⇒ ★★∴ ★同じ 場所を 指して いる と 見て よい★★ / ★★但し ★彼の §5 の 定義（= 彼の 器の 出力）は 未読★★★
```

## ★2. ★★④ section へ 入る 経路 = ★私の 走査型では 0x17 まで 届きます★★★

```
 ★逐語（handler 0x17 = 0x800EC64C）★:
   ★jal 0x800F0D10（★2 半語を 取る★）★ → ★lhu 0x22($sp)★ → ★★jal 0x800F0988（loader）★★ → ★sw [gp-0x6ccc]★
   → ★lhu 0x24($sp)★ → ★★jal 0x800F0A4C（section 表 引き）★★ → ★★sw [gp-0x6cc8]（= PC）★★
 ⇒ ★★∴ ★0x17 = (entry id, section id) を 取り ★entry を load して section の pc へ 跳ぶ★★★（Len 6 と 自己整合）

 ★★全数（到達枠・全 225 entry）= ★137 件 / 相異なる (entry, section) = 38 種★★★
 ★parse の 妥当性★ = ★entry < 225 が 135 / 137★・★section < 256 が 135 / 137★・★entry 29 種 / section 20 種★
   （例 = ★(174,51)×52 / (221,51)×25 / (47,82)×8 / (201,5)×5★）
 ★★★∴ ★entry 109 を 指す 0x17 = ★0 件★★★★ ⇒ ★★∴ ★section 5 を 指す ものも 0 件★★
```

## ★3. ★★∴ 答え（1 行ずつ）★★★

```
 ★③★ = ★★同じ 番号体系（id は file 由来）★ / ★flag 1 を 立てる section は 一意 ⇒ 同じ 場所と 見てよい★★
 ★★④★★ = ★★私の 走査型（0x17 の 全数）では ★entry 109 に 入る 経路は 0 件★★★ ★［母数 未記載 2026-08-15］★この 行の 0 は ★母数が 添えて いません★★ ⇒ ★★未測定 に 落とします★★
   ⇒ ★★∴ ★残るのは ★DG.SCN の 外★★★ = ★map / event 側が ★loader 0x800F0988 を 直に 呼ぶ★ 経路★
   ⇒ ★★∴ ★それは EXE 側の 話 ⇒ ★私の 座で 追えます（次の 発注が 在れば）★★★
   ⇒ ★★但し ★0 件は 到達枠の 中の 0★★★（★生 byte で 0x17 が 現れる 位置は 数えて いません★） ★［母数 未記載 2026-08-15］★この 行の 0 は ★母数が 添えて いません★★ ⇒ ★★未測定 に 落とします★★
```

## ★4. ★引用 5 点★

```
 ★path★ = workspace/tools/{scn_core,w2_cov,exedis,w2_effect_cells}.py（p2w2）／ ★worktree★ = degimon_world_remake-p2w2
 ★branch★ = p2w2 作業 branch（★push なし★）／ ★sha★ = 本 doc の commit
 ★算法★ = ★section 表の 逐語（sid / off を file から）＋ 到達枠 walk で 0x17 を 全数＋operand を u16 2 本で parse★
```
