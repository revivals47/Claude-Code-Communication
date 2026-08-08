set architecture mips:3000
set endian little
set confirm off
set pagination off
target remote 127.0.0.1:2345
printf "\n### loop terminator 0x800bb4d0-0x800bb520 ###\n"
x/24i 0x800bb4d0
printf "\n### function head 0x800bae40 ###\n"
x/12i 0x800bae40
printf "\n### CLEAR writer 0x800bbb00 ###\n"
x/24i 0x800bbac0
quit
