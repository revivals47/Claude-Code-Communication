set architecture mips:3000
set endian little
set confirm off
set pagination off
target remote 127.0.0.1:2345
printf "\n##### SITE A function head: 0x8005dd00-0x8005e300 #####\n"
x/256i 0x8005dd00
quit
