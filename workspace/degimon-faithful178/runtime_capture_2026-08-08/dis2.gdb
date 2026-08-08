set architecture mips:3000
set endian little
set confirm off
set pagination off
target remote 127.0.0.1:2345
printf "\n##### CAND getDamagePoint: 0x8005f1c0.. (btl+0xC6E0..) #####\n"
x/400i 0x8005f1c0
printf "\n##### CALLER: ra=0x80063804 (btl+0x10D24) #####\n"
x/160i 0x800636c0
printf "\n##### s_damageCheck init: 0x80056e00.. #####\n"
x/128i 0x80056e00
printf "\n##### damage_result struct @0x801460f8 #####\n"
x/20xw 0x801460f8
quit
