set architecture mips:3000
set endian little
set confirm off
set pagination off
target remote 127.0.0.1:2345
x/192wx 0x8016b000
quit
