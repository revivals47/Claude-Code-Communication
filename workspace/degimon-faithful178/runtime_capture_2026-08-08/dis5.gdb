set architecture mips:3000
set endian little
set confirm off
set pagination off
target remote 127.0.0.1:2345
printf "\n########## getDamagePoint = 0x8005d44c (btl_rel +0x0A96C) ##########\n"
x/300i 0x8005d44c
quit
