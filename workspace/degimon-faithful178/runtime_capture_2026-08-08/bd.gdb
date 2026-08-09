set architecture mips:3000
set endian little
set confirm off
set pagination off
target remote 127.0.0.1:2345
printf "idx type +0xBD +0xBE +0xBF +0xC1 | pc=%08x\n", $pc
set $i=0
while $i < 7
  printf "%d  %5u  0x%02x  0x%02x  0x%02x  0x%02x\n", $i, *(unsigned short*)(0x80145608+$i*0xC4), *(unsigned char*)(0x80145608+$i*0xC4+0xBD), *(unsigned char*)(0x80145608+$i*0xC4+0xBE), *(unsigned char*)(0x80145608+$i*0xC4+0xBF), *(unsigned char*)(0x80145608+$i*0xC4+0xC1)
  set $i=$i+1
end
quit
