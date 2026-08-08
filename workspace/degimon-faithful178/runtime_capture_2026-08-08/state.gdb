set architecture mips:3000
set endian little
set confirm off
set pagination off
target remote 127.0.0.1:2345
printf "hp=%u pendingDmg@80146126=%u pc=%08x\n", *(unsigned short*)0x8016b0d0, *(unsigned short*)0x80146126, $pc
printf "overlay probe @0x80068300: %08x %08x (garbage=battle overlay unloaded)\n", *(unsigned int*)0x80068300, *(unsigned int*)0x80068304
quit
