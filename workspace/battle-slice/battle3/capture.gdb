# 3 戦目 ① — damage が出るたび 1 行 印字する（読むだけ・ゲームは書き換えない）
# 出所: watchpoint 0x80146126 = 2026-08-21 の生 log の 1 行目 逐語
#       frame 値      = docs/RE_battle_getDamagePoint_2026-08-08.md 第8節 の ※注
#         sp+0x44=skill / sp+0x80=攻撃側ptr / s1=防御側ptr / sp+0x3c=damage
#       actor +0x38=攻撃側 stat / +0x3a=防御側 stat  (同 doc §19.2)
#       actor +0x00 = species index (RE_battle_ai_skeleton §33-3: stats[actor->w00])
#       base_stats 0x8013A924 stride 52 / +0x1E,+0x1F,+0x20 = 属性 3 本
#         (FOUNDATION 250 行: m[i] = 属性byte(+0x1E+i)==0xFF ? 10 : matrix[element*7+属性])
#       wazaTbl 0x801325C0 stride 16 / +0x09 = 技の属性(element)  (FOUNDATION 197・362 行)
# ★execution breakpoint は使わない★(hbreak は overlay 上で emulator を落とす。2026-08-21 に 3 回)
set architecture mips:3000
set endian little
set confirm off
set pagination off
target remote 127.0.0.1:2345

watch *(unsigned short*)0x80146126
set $n = 0
while $n < 2000
  continue
  set $n = $n + 1
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
  end
end
delete
detach
quit
