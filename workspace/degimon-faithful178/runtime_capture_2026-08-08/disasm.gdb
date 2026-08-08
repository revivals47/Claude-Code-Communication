set architecture mips:3000
set endian little
set confirm off
set pagination off
target remote 127.0.0.1:2345
printf "\n===== CALLER in battle overlay: around 0x800683b0 (btl_rel +0x158d0) =====\n"
x/220i 0x80068100
printf "\n===== HP DRAIN routine: 0x80102f00-0x80103080 =====\n"
x/100i 0x80102f00
printf "\n===== stat struct 0x8016b0bc =====\n"
x/24xw 0x8016b0bc
printf "\n===== mirror struct 0x801460f8 =====\n"
x/24xw 0x801460f8
quit
