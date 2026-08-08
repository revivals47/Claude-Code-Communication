set architecture mips:3000
set endian little
set confirm off
set pagination off
target remote 127.0.0.1:2345
x/300i 0x800bafc0
quit
