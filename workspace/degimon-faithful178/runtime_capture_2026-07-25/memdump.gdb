set architecture mips:3000
set endian little
set confirm off
set pagination off
target remote 127.0.0.1:2345
echo ===CALLER_DISASM_0x800cf100===\n
x/48i 0x800cf100
echo ===CALLER_RAWBYTES===\n
x/64wx 0x800cf100
echo ===TRAP6_SITE_0x800b8c60===\n
x/48i 0x800b8c60
echo ===STAGING_0x80010b80===\n
x/96wx 0x80010b80
echo ===STAGING_HEAD_0x80010000===\n
x/32wx 0x80010000
echo ===ENTITY_ARRAY_0x80147358===\n
x/128wx 0x80147358
echo ===DONE===\n
detach
quit
