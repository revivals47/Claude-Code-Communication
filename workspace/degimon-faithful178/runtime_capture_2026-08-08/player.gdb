set architecture mips:3000
set endian little
set confirm off
set pagination off
target remote 127.0.0.1:2345
printf "=== player actor 0x8016B048 region ===\n"
x/32xw 0x8016b048
printf "\n=== entity records: type / pos.x,y,z / rot ===\n"
set $i=0
while $i < 7
  printf "idx%d type=%5u pos=(%6d,%6d,%6d) rot=%6d\n", $i, *(unsigned short*)(0x80145608+$i*0xC4), *(short*)(0x80145608+$i*0xC4+0xA8), *(short*)(0x80145608+$i*0xC4+0xAA), *(short*)(0x80145608+$i*0xC4+0xAC), *(short*)(0x80145608+$i*0xC4+0xB0)
  set $i=$i+1
end
quit
