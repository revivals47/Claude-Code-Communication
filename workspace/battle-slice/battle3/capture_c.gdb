# 3 戦目 (c) 専用 — ★勝利 site 0x800AEEC8 を 直接 捕まえる★（読むだけ・書き換えなし）
#
# ★なぜ これで 捕まるか（PRESIDENT #925-W ■2・逐語）★
#   0x800AEEBC  addi $v0, $v0, 1
#   0x800AEEC0  lui  $at, 0x8014
#   0x800AEEC4  sh $v0, 0x1d6c($at)      ⇒ 書く先 = ★0x80141D6C（勝利数）★
#   0x800AEEC8  sb $zero, -0x6d84($gp)   ← ★(c) の 目標★
#   0x800AEECC  jal 0x800A76A0
#   ⇒ ★勝利数は 増える = 値が変わる★ ⇒ ★data watchpoint で 止まる★
#   ⇒ ★止まった時の pc = 0x800AEEC8（sh の次）= 目標の命令 そのもの★
#   ★execution breakpoint を 使わない★（8/21 に DuckStation を 3 回 落とした）
#   ★memory を 書き換えない★（読むだけ を 維持）
#
# ★★watchpoint は 2 本だけ★★ = damage(0x80146126) は ★外す★
#   理由 = ★3 本同時は 未検証★（probe で確かめたのは 2 本まで）。
#          ★3 本目が 挿さらないと continue で 落ち、run 全体が 死ぬ★。
#   ★捨てるもの★ = HIT 行（①）／停止が減るので pad の密度も落ちる ⇒ ★(c) 専用と 割り切る★。
set architecture mips:3000
set endian little
set confirm off
set pagination off
set height 0
target remote 127.0.0.1:2345

set $e088 = *(unsigned char*)0x8013E088
set $wins = *(unsigned short*)0x80141D6C
printf "START_C e088=%u wins=%u hp=%u/%u\n", $e088, $wins, \
  *(unsigned short*)0x8016B0D0, *(unsigned short*)0x8016B0CC

watch *(unsigned short*)0x80141D6C
watch *(unsigned char*)0x8013E088

set $n = 0
while $n < 4000
  continue
  set $n = $n + 1

  # ★目標★: 勝利数が変わった停止で pc が 0x800AEEC8 なら それが 勝利 site そのもの
  if $pc == 0x800AEEC8
    printf "WIN_SITE pc=%08x ra=%08x wins=%u e088=%u\n", $pc, $ra, \
      *(unsigned short*)0x80141D6C, *(unsigned char*)0x8013E088
  end

  set $w = *(unsigned short*)0x80141D6C
  if $w != $wins
    printf "WINS_CHANGE %u->%u pc=%08x ra=%08x\n", $wins, $w, $pc, $ra
  end
  set $wins = $w

  set $now = *(unsigned char*)0x8013E088
  if $now != $e088
    printf "E088_CHANGE %u->%u pc=%08x ra=%08x\n", $e088, $now, $pc, $ra
  end
  set $e088 = $now
end
printf "TOTAL_STOPS_C %d\n", $n
delete
quit
