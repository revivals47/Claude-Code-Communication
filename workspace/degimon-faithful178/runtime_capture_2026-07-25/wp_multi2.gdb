set architecture mips:3000
set endian little
set confirm off
set pagination off
target remote 127.0.0.1:2345
watch *(unsigned int*)0x80147358
set $n=0
while $n < 40
  continue
  set $n=$n+1
  printf "TRAP %d pc=%08x ra=%08x a0=%08x a1=%08x a2=%08x a3=%08x v0=%08x v1=%08x t0=%08x t1=%08x s0=%08x s1=%08x mem=%08x\n", $n, $pc, $ra, $a0, $a1, $a2, $a3, $v0, $v1, $t0, $t1, $s0, $s1, *(unsigned int*)0x80147358
  x/4i $pc-8
end
detach
quit
