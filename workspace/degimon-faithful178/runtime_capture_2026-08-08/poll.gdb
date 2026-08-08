set architecture mips:3000
set endian little
set confirm off
set pagination off
target remote 127.0.0.1:2345
printf "SAMPLE hp=%u mp=%u hpmax=%u pc=%08x\n", *(unsigned short*)0x8016b0d0, *(unsigned short*)0x8016b0d2, *(unsigned short*)0x8016b0cc, $pc
quit
