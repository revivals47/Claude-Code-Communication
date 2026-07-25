set architecture mips:3000
set endian little
set confirm off
set pagination off
target remote 127.0.0.1:2345
watch *(unsigned short*)0x80014536
set $n=0
while $n < 30
  continue
  set $n=$n+1
  printf "TRAP %d pc=%08x ra=%08x a0=%08x a1=%08x a2=%08x a3=%08x v0=%08x v1=%08x t0=%08x t1=%08x s0=%08x s1=%08x s2=%08x hp=%d\n", $n, $pc, $ra, $a0, $a1, $a2, $a3, $v0, $v1, $t0, $t1, $s0, $s1, $s2, *(unsigned short*)0x80014536
  x/6i $pc-16
end
detach
quit
