#!/usr/bin/env python3
"""battle HP hunt — DuckStation live RAM snapshot & damage-delta diff.
usage:
  battle_hp_hunt.py snap A          # 2MB snapshot -> ram_A.bin
  battle_hp_hunt.py snap B          # 2MB snapshot -> ram_B.bin
  battle_hp_hunt.py diff <damage>   # A vs B: u16/u32 が exactly <damage> 減った guest addr を列挙
live 判別 = live_ram.py 確立手法(anchor 署名を含む rw-s region、2MB..16MB、先頭=RAM base)。
"""
import sys, os, glob

ANCHOR = bytes([0x84,0x97,0x15,0x80, 0x84,0xf7,0x15,0x80, 0x84,0x17,0x16,0x80,
                0x84,0x37,0x16,0x80, 0x20,0x3a,0x16,0x80])
HERE = os.path.dirname(os.path.abspath(__file__))

def find_pid():
    for d in glob.glob('/proc/[0-9]*'):
        try:
            if open(d+'/comm').read().strip() == 'duckstation-qt':
                return int(os.path.basename(d))
        except Exception:
            pass
    return None

def open_ram():
    pid = find_pid()
    if not pid:
        raise SystemExit('duckstation-qt process not found')
    mem = open(f'/proc/{pid}/mem', 'rb', buffering=0)
    for line in open(f'/proc/{pid}/maps'):
        p = line.split()
        if len(p) < 2 or 'r' not in p[1] or 's' not in p[1]:
            continue
        a, b = p[0].split('-'); a = int(a, 16); b = int(b, 16)
        if b - a < 0x200000 or b - a > 0x1000000:
            continue
        try:
            mem.seek(a); chunk = mem.read(b - a)
        except Exception:
            continue
        pos = chunk.find(ANCHOR)
        if pos != -1:
            # anchor は guest 0x8013E114 付近の固定 pointer 表。base = region 先頭(live_ram.py 実測準拠)
            return mem, a
    raise SystemExit('anchor not found in any rw-s region (ptrace_scope? game running?)')

def snap(tag):
    mem, base = open_ram()
    mem.seek(base)
    data = mem.read(0x200000)
    path = os.path.join(HERE, f'ram_{tag}.bin')
    open(path, 'wb').write(data)
    print(f'snapshot {tag}: {len(data)} bytes from host 0x{base:x} -> {path}')

def diff(damage):
    A = open(os.path.join(HERE, 'ram_A.bin'), 'rb').read()
    B = open(os.path.join(HERE, 'ram_B.bin'), 'rb').read()
    n16 = n32 = 0
    for off in range(0, 0x200000 - 4, 2):
        a16 = int.from_bytes(A[off:off+2], 'little')
        b16 = int.from_bytes(B[off:off+2], 'little')
        if a16 - b16 == damage:
            print(f'u16 dec {damage}: guest 0x{0x80000000+off:08x}  {a16} -> {b16}')
            n16 += 1
        a32 = int.from_bytes(A[off:off+4], 'little')
        b32 = int.from_bytes(B[off:off+4], 'little')
        if a32 - b32 == damage and a32 < 100000:
            print(f'u32 dec {damage}: guest 0x{0x80000000+off:08x}  {a32} -> {b32}')
            n32 += 1
        if n16 + n32 > 200:
            print('...capped at 200 candidates (diff too noisy)')
            return
    print(f'total: u16={n16} u32={n32}')

if __name__ == '__main__':
    cmd = sys.argv[1]
    if cmd == 'snap':
        snap(sys.argv[2])
    elif cmd == 'diff':
        diff(int(sys.argv[2]))
