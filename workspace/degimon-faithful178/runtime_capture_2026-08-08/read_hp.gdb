set architecture mips:3000
set endian little
set confirm off
set pagination off
target remote 127.0.0.1:2345
printf "LIVE hp@8016b0d0=%u  mp@8016b0d2=%u  hpmax@8016b0cc=%u mpmax@8016b0ce=%u\n", *(unsigned short*)0x8016b0d0, *(unsigned short*)0x8016b0d2, *(unsigned short*)0x8016b0cc, *(unsigned short*)0x8016b0ce
printf "s0-struct 0x801460f8: +0x2E(hp mirror)=%u\n", *(unsigned short*)0x80146126
printf "PC=%08x\n", $pc
delete
quit
