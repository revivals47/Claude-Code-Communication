set architecture mips:3000
set endian little
set confirm off
set pagination off
target remote 127.0.0.1:2345
printf "=== HP oracle candidates (static-derived, UNVERIFIED at runtime) ===\n"
printf "0x8016b0cc word=%u half=%u\n", *(unsigned int*)0x8016b0cc, *(unsigned short*)0x8016b0cc
printf "0x8016b0d0 word=%u half=%u\n", *(unsigned int*)0x8016b0d0, *(unsigned short*)0x8016b0d0
printf "=== context dump 0x8016b080..0x8016b100 ===\n"
x/32xw 0x8016b080
printf "=== entity array base 0x80145608 (stride 0xC4, type@+0) ===\n"
x/4xw 0x80145608
printf "types: %u %u %u %u %u\n", *(unsigned char*)0x80145608, *(unsigned char*)(0x80145608+0xC4), *(unsigned char*)(0x80145608+0x188), *(unsigned char*)(0x80145608+0x24C), *(unsigned char*)(0x80145608+0x310)
delete
quit
