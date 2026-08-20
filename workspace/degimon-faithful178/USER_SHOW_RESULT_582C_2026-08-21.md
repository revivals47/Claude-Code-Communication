# user 手番の結果 — field-model 引き渡し build(#582-C)を見せた(2026-08-21)

PRESIDENT が user に mayo00 の field-model build を見せた記録。handoff 2026-08-19/20 §2 の
「開いている user 手番 1 件」を実施したもの。★status は器に訊く★の原則で、以下は器と user 応答の実測。

## 実施内容
- build = `/home/ken/Desktop/Digimon/w3_build582r/DegimonLive/DegimonLive.x86_64`(disk 実在確認、走行前 player 0)
- README = `workspace/degimon-faithful178/USER_RUN_README_582C_DRAFT.md` §3 手順どおり
- 昼: `DEGIMON_START_HOUR=12`、夜: `DEGIMON_START_HOUR=22`、両方 `DEGIMON_BOOT_MAP=mayo00 AUTOBOOT_SEC=60`

## 器の側(PRESIDENT 実測)
- 窓 = `DISPLAY=:1` に `0x01a00008 unity`(昼・夜とも)。player proc exe = 新 build と一致
- `[PLACE-SPECIES] map=mayo00 idx=109 rec=2 type=3 script_id=6` → **合計 1 体**(昼・夜とも同一)
- crash/excode = なし(§5-4 の既知落ち方は再現せず)

## user 応答(観測、逐語)
- 昼「見えた」/ 夜「見えた」= ★窓が出て mayo00 に 1 体立っていることを user 実視覚で確認★

## 額面(過大表示しない・handoff §5 準拠)
- 通ったのは handoff §2 の条件② = ★実 GUI で窓と `[PLACE-SPECIES]` が出る(絵の判定ではない)★。
- ★新規開始 mayo00 = 昼夜とも species 3 が 1 体・変わらないのも仕様★(README §1)を user 実視覚で確認した、まで。
- ★「完成」「arc 完了」とは書かない★。突き合わせは mayo00 1 map のみ・他 map は「表どおり」の自己整合(handoff §5-1)。
- 進行後の 2 体入れ替わりは ★見せていない★(注入口を渡さない、handoff §2)。

## 残(未変更)
- push HOLD(origin/main=ca34f972 不動)/ land は PRESIDENT 承認 / README は draft(査読前)。
- 次 phase registry(2026-08-20)の park 札は不変。
