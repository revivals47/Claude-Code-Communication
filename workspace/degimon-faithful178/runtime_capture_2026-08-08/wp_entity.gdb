set architecture mips:3000
set endian little
set confirm off
set pagination off
target remote 127.0.0.1:2345
printf "PRE entity[0].type=%u  word=%08x\n", *(unsigned char*)0x80145608, *(unsigned int*)0x80145608
watch *(unsigned int*)0x80145608
set $n=0
while $n < 40
  continue
  set $n=$n+1
  printf "TRAP %d pc=%08x ra=%08x sp=%08x type0=%u | a0=%08x a1=%08x a2=%08x a3=%08x v0=%08x v1=%08x t0=%08x s0=%08x s1=%08x s2=%08x s3=%08x s4=%08x\n", $n, $pc, $ra, $sp, *(unsigned char*)0x80145608, $a0, $a1, $a2, $a3, $v0, $v1, $t0, $s0, $s1, $s2, $s3, $s4
  x/12i $pc-32
end
delete
quit
