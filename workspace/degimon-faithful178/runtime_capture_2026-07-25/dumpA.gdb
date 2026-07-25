set architecture mips:3000
set endian little
set confirm off
set pagination off
target remote 127.0.0.1:2345
dump binary memory ram_A.bin 0x80000000 0x80200000
quit
