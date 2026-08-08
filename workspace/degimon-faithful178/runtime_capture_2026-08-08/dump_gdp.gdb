set architecture mips:3000
set endian little
set confirm off
set pagination off
target remote 127.0.0.1:2345
dump binary memory live_getdamagepoint.bin 0x8005d44c 0x8005d82c
quit
