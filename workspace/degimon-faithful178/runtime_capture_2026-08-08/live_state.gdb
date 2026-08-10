set architecture mips:3000
set endian little
set confirm off
set pagination off
target remote 127.0.0.1:2345
printf "=== CLOCK ===\n"
printf "DAY=%u %02u:%02u subtick=%u\n", *(unsigned short*)0x8013E2E0, *(unsigned short*)0x8013E298, *(unsigned short*)0x8013E29A, *(unsigned short*)0x8013E2E2
printf "map(gp-0x6ca6 相当)=%u\n", *(unsigned short*)0x8013E166
printf "=== entity array (type / pos) ===\n"
set $i=0
while $i < 8
  printf " idx%d type=%5u pos=(%6d,%6d)\n", $i, *(unsigned short*)(0x80145608+$i*0xC4), *(short*)(0x80145608+$i*0xC4+0xA8), *(short*)(0x80145608+$i*0xC4+0xAC)
  set $i=$i+1
end
printf "=== actor ptr table 0x8013CDB4 [0..15] ===\n"
set $j=0
while $j < 16
  printf " [%2d] %08x\n", $j, *(unsigned int*)(0x8013CDB4+$j*4)
  set $j=$j+1
end
quit
