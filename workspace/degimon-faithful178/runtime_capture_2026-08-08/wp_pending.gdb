set architecture mips:3000
set endian little
set confirm off
set pagination off
target remote 127.0.0.1:2345
printf "PRE hp=%u pending=%u\n", *(unsigned short*)0x8016b0d0, *(unsigned short*)0x80146126
watch *(unsigned int*)0x80146124
set $n=0
while $n < 60
  continue
  set $n=$n+1
  printf "TRAP %d pc=%08x ra=%08x sp=%08x pending=%u hp=%u | BTLoff=%08x a0=%08x a1=%08x a2=%08x a3=%08x v0=%08x v1=%08x t0=%08x t1=%08x s0=%08x s1=%08x s2=%08x s3=%08x\n", $n, $pc, $ra, $sp, *(unsigned short*)0x80146126, *(unsigned short*)0x8016b0d0, $pc-0x80052ae0, $a0, $a1, $a2, $a3, $v0, $v1, $t0, $t1, $s0, $s1, $s2, $s3
  x/10i $pc-28
end
delete
quit
