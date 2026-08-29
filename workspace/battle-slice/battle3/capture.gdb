# 3 戦目 次 run — ①③④⑤⑥⑦ を 1 回で採る（読むだけ・ゲームは書き換えません）
# ★execution breakpoint は使わない★(hbreak は overlay 上で emulator を落とす。2026-08-21 に 3 回)
#
# 番地の出所（全部 doc から引き写し・推測ゼロ）
#   ① watchpoint 0x80146126 = 2026-08-21 の生 log 1 行目 逐語
#      frame  = RE_battle_getDamagePoint 第8節 ※注（sp+0x44 skill / sp+0x80 攻撃側 / s1 防御側 / sp+0x3c damage）
#      actor +0x38/+0x3a = 同 §19.2 ／ actor +0x00 = species（RE_battle_ai_skeleton §33-3）
#      base_stats 0x8013A924 stride 52 / +0x1E..+0x20 = 属性 3 本（FOUNDATION 250 行）
#      wazaTbl    0x801325C0 stride 16 / +0x09 = 技属性（FOUNDATION 197・362 行）
#   ③ 0x8013E088 が 1→0 になる瞬間の PC ／ ④ 0x8016B084・0x8016B104 各 104 byte
#   ⑤ 0x801406E8 の 128 slot ／ ⑥ 0x8016B0D0（味方 HP 現在）／ ⑦ 0x801692A1（bit 0x02）
#      = FOUNDATION §8.31 の 依頼 7 点
#   ★2026-08-29 の probe で ①③の watchpoint 2 本同時と ④⑤⑥⑦ の read を 実測で確認済★
#   ★但し ③が「発火するか」は 未確認★（張れることまで）。発火しなければ この run で判ります。
set architecture mips:3000
set endian little
set confirm off
set pagination off
set height 0
target remote 127.0.0.1:2345

set $e088 = *(unsigned int*)0x8013E088
set $dumped = 0
printf "START e088=%u hp=%u/%u flag69=%02x\n", $e088, \
  *(unsigned short*)0x8016B0D0, *(unsigned short*)0x8016B0CC, *(unsigned char*)0x801692A1

watch *(unsigned short*)0x80146126
watch *(unsigned int*)0x8013E088

set $n = 0
while $n < 4000
  continue
  set $n = $n + 1

  # ③ 0x8013E088 の 1 → 0
  set $now = *(unsigned int*)0x8013E088
  if $e088 == 1 && $now == 0
    printf "E088_1TO0 pc=%08x ra=%08x\n", $pc, $ra
  end
  set $e088 = $now

  # ① damage tuple ＋ ⑥⑦ を毎回
  if $pc == 0x8005e31c
    set $atkp = *(unsigned int*)($sp + 0x80)
    set $defp = $s1
    set $skill = *(unsigned int*)($sp + 0x44)
    set $row = 0x801325C0 + 16 * $skill
    set $sps = *(unsigned short*)($defp + 0x00)
    set $bs  = 0x8013A924 + 52 * $sps
    printf "HIT dmg=%u skill=%u elem=%u atk=%u def=%u species=%u attr=%u,%u,%u row=%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x\n", \
      *(unsigned int*)($sp + 0x3c), $skill, *(unsigned char*)($row + 0x09), \
      *(unsigned short*)($atkp + 0x38), *(unsigned short*)($defp + 0x3a), $sps, \
      *(unsigned char*)($bs + 0x1e), *(unsigned char*)($bs + 0x1f), *(unsigned char*)($bs + 0x20), \
      *(unsigned char*)($row+0), *(unsigned char*)($row+1), *(unsigned char*)($row+2), *(unsigned char*)($row+3), \
      *(unsigned char*)($row+4), *(unsigned char*)($row+5), *(unsigned char*)($row+6), *(unsigned char*)($row+7), \
      *(unsigned char*)($row+8), *(unsigned char*)($row+9), *(unsigned char*)($row+10), *(unsigned char*)($row+11), \
      *(unsigned char*)($row+12), *(unsigned char*)($row+13), *(unsigned char*)($row+14), *(unsigned char*)($row+15)
    printf "HP hp=%u max=%u flag69=%02x\n", *(unsigned short*)0x8016B0D0, \
      *(unsigned short*)0x8016B0CC, *(unsigned char*)0x801692A1

    # ④⑤ は ★最初の HIT で 1 度だけ★（毎回だと量が多すぎる・状態の snapshot ゆえ 1 度で足りる）
    if $dumped == 0
      set $dumped = 1
      echo DUMP_B084\n
      x/26xw 0x8016B084
      echo DUMP_B104\n
      x/26xw 0x8016B104
      echo DUMP_REG\n
      x/128xw 0x801406E8
      echo DUMP_END\n
    end
  end
end
delete
quit
