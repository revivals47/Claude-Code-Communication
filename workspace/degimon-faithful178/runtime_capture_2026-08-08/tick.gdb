set architecture mips:3000
set endian little
set confirm off
set pagination off
target remote 127.0.0.1:2345
printf "pc=%08x freerun@80141D4C=%u  bd4=0x%02x bd6=0x%02x\n", $pc, *(unsigned int*)0x80141D4C, *(unsigned char*)(0x80145608+4*0xC4+0xBD), *(unsigned char*)(0x80145608+6*0xC4+0xBD)
quit
