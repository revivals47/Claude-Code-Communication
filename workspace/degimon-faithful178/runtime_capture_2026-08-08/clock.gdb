set architecture mips:3000
set endian little
set confirm off
set pagination off
target remote 127.0.0.1:2345
printf "DAY=%u  %02u:%02u   subtick=%u  pc=%08x\n", *(unsigned short*)0x8013E2E0, *(unsigned short*)0x8013E298, *(unsigned short*)0x8013E29A, *(unsigned short*)0x8013E2E2, $pc
quit
