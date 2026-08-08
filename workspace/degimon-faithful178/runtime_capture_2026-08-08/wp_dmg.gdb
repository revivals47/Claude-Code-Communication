set architecture mips:3000
set endian little
set confirm off
set pagination off
target remote 127.0.0.1:2345
printf "PRE hp_cur=%u mp_cur=%u hp_max=%u\n", *(unsigned short*)0x8016b0d0, *(unsigned short*)0x8016b0d2, *(unsigned short*)0x8016b0cc
watch *(unsigned int*)0x8016b0d0
set $n=0
while $n < 40
  continue
  set $n=$n+1
  printf "TRAP %d pc=%08x ra=%08x sp=%08x hp=%u mp=%u | BTLoff=%08x a0=%08x a1=%08x a2=%08x a3=%08x v0=%08x v1=%08x t0=%08x s0=%08x s1=%08x s2=%08x\n", $n, $pc, $ra, $sp, *(unsigned short*)0x8016b0d0, *(unsigned short*)0x8016b0d2, $pc-0x80052ae0, $a0, $a1, $a2, $a3, $v0, $v1, $t0, $s0, $s1, $s2
  x/8i $pc-20
end
delete
quit
