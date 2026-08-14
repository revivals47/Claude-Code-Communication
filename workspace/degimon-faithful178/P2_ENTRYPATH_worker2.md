# P2_ENTRYPATH_worker2 — ★(a) section へ 入る ★EXE 側★ の 経路（sink 6 件の 出所 1 段）★

★受領★ = boss1 #407 ③(a) ／ ★測定時点★ = 2026-08-14 ／ ★★観測より 前★★

---

## ★1. ★★sink 6 件 = ★私の 走査でも 逐語 一致★★★（★中継の 確認では なく 自分の 読み★）

```
 ★6 件 とも ★lhu $a0, -0x6cd6($gp)★（= scenario）★ ⇒ ★★worker1 の 一覧と 一致★★
 ★内訳（包含関数）★ = ★0x800EF39C に 2 件（0x800EF3FC / 0x800EF468）★ / ★0x800AE3DC に 3 件★ / ★0x800BBEA8 に 1 件★
```

## ★2. ★★★loader を 呼ぶのは ★1 関数だけ★★★★

```
 ★0x800EF39C★ … ★★jal 0x800F0988（loader）＋ jal 0x800F0A4C（section 表 引き）を 持つ★★
 ★0x800AE3DC★ … ★jal 11 種・★loader を 呼びません★★
 ★0x800BBEA8★ … ★jal 11 種・★loader を 呼びません★★
 ⇒ ★★∴ ★『scenario を 読む』= ★entry を 読む★ では ありません★★★（★6 件 中 2 件だけが 入口★）
```

## ★3. ★★逐語（入口の 2 site）★★★

```
 ★★site 1 = 0x800EF3FC★★:
   ★800EF3FC  lhu $a0, -0x6cd6($gp)★（= scenario）→ ★★800EF400  jal 0x800F0988★★（loader）→ ★$s1 = entry base★
   ★800EF410  addiu $a1, $zero, 0xfe★ → ★★800EF414  jal 0x800F0A4C★★（section 表）→ ★800EF428-2C  [gp-0x6ccc] / [gp-0x6cc8] に 保存★
   ⇒ ★★∴ ★entry = scenario / section = ★0xFE（= 254）★★★
   ⇒ ★★∴ ★entry 109 の section 表に ★254 → 0x0038★ が 実在します★★（#399 の 13 本の 1 つ）
 ★★site 2 = 0x800EF468★★:
   ★800EF468  lhu $a0, -0x6cd6($gp)★ → ★800EF46C  jal 0x800F0988★ → ★800EF478  lbu $a1, 0x27($sp)★ → ★800EF480  jal 0x800F0A4C★
   ⇒ ★★∴ ★entry = scenario / section = ★呼び手が 持つ byte★★★（= ★sec 5 の ような 個別 section に 入れる 側★）
 ★どちらの site も 包含関数 = ★0x800EF39C★★ / ★その 呼び元 = ★0x800EC438 の 1 件★★ = ★★opcode 0xFE / 0xFF★★（#308 と 同じ）
```

## ★4. ★★∴ 入口の 形（★私の 走査型の 中で★）★★★

```
 ★★entry の 選択 = ★[gp-0x6cd6]（scenario）★★★ ⇒ ★★∴ ★entry 番号は ★script が 指定するのでは なく 状態変数★★★
 ★section の 選択★ = ★★既定 = 0xFE（254）★★ / ★個別 = 呼び手の byte★
 ⇒ ★★∴ ★#401 の『0x17 は entry 109 を 指さない』と 整合★★ = ★★entry は ★id を 書いた 命令★ では なく ★scenario★ で 決まる★★
 ⇒ ★★∴ ★live shot の scenario = 147★（header）★ ⇒ ★★『いま 載って いる entry は 147』と 読めます★★
   ⇒ ★★但し ★これは 私の 読みで あって ★観測での 確認は 未★★★（★entry 109 が 載る 条件は ★scenario が 109 に なる こと★ と 読めます★）
```

## ★5. ★★#407 ④ の 自己点検（map 名の 索引ずれ）★★★

```
 ★私の doc（P2_*worker2*.md）で ★map 名を 引用した もの = ★0 件★★★（grep） ★［母数 未記載 2026-08-15］★この 行の 0 は ★母数が 添えて いません★★ ⇒ ★★未測定 に 落とします★★
 ⇒ ★★∴ ★索引 1 ずれの 影響を 受ける 行は ★私の 側には ありません★★★
```

## ★6. ★引用 5 点★

```
 ★path★ = workspace/tools/{exedis,w2_effect_cells}.py（p2w2）／ ★worktree★ = degimon_world_remake-p2w2
 ★branch★ = p2w2 作業 branch（★push なし★）／ ★sha★ = 本 doc の commit
 ★算法★ = ★sink 6 件の 逐語 ＋ 包含関数の 呼び元 全走査（即値 jal）＋ 関数内 jal 集合で loader の 有無★
```
