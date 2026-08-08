set architecture mips:3000
set endian little
set confirm off
set pagination off
target remote 127.0.0.1:2345
printf "\n##### POPULATE writer: 0x800baee8 #####\n"
x/120i 0x800bae00
printf "\n##### its CALLER: ra=0x800ac76c #####\n"
x/100i 0x800ac680
printf "\n##### CLEAR writer: 0x800bbb00 #####\n"
x/80i 0x800bba60
printf "\n##### CLEAR caller: ra=0x800dfa0c #####\n"
x/60i 0x800df980
printf "\n##### entity[0..3] raw #####\n"
x/16xw 0x80145608
quit
