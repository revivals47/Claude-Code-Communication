set architecture mips:3000
set endian little
set confirm off
set pagination off
target remote 127.0.0.1:2345
printf "\n##### SITE A: 0x8005e318/0x8005e334 (btl+0xB838/0xB854) #####\n"
x/140i 0x8005e200
printf "\n##### SITE B: 0x8005e708/0x8005e724 (btl+0xBC28/0xBC44) #####\n"
x/140i 0x8005e600
printf "\n##### SITE C: 0x800607a4/0x800607c0 (btl+0xDCC4/0xDCE0) #####\n"
x/140i 0x80060680
printf "\n##### DRAIN CALLER: 0x80068388 area (btl+0x158A8) #####\n"
x/80i 0x80068300
quit
