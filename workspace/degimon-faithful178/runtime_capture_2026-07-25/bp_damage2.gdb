set architecture mips:3000
set endian little
set confirm off
set pagination off
target remote 127.0.0.1:2345
watch *(unsigned int*)0x80147358
delete
hbreak *0x80056ca8
set $n=0
while $n < 60
  continue
  set $n=$n+1
  printf "HIT %d pc=%08x ra=%08x a0=%08x a1=%08x a2=%08x a3=%08x v0=%08x s0=%08x s1=%08x s2=%08x sp=%08x\n", $n, $pc, $ra, $a0, $a1, $a2, $a3, $v0, $s0, $s1, $s2, $sp
end
detach
quit
