#!/usr/bin/env python3
"""burst_ram.py — DuckStation の PS1 2MB RAM を 無停止で 連写する。

発注文 v0.2 (PRESIDENT #67 で確定) の観測手段。

なぜ連写か:
  /proc/<pid>/mem 直読は **無停止**（RUNTIME_SESSION_2026-07-25 §3: gdb 経由 2MB dump は
  120s timeout で不成立、/proc 直読が正、2MB 一瞬・無停止）。
  ∴ **edge（0x40 が立つ瞬間）は原理的に捉えられない。捉えられるのは state だけ。**
  ∴ 瞬間を狙うのではなく **時間軸を埋める**。1 回 1.7 ms（boss1 実測）なので 0.2 秒間隔で埋め切れる。

region 同定は live_ram.py と同一手法（ANCHOR 20 byte 署名）。手作業の base 同定は不要。

usage:
  burst_ram.py --out DIR [--interval 0.2] [--count 150] [--duration 30]
  burst_ram.py --selftest        # DuckStation 不要。読める部分だけ自己検査
前提:
  sudo sysctl kernel.yama.ptrace_scope=0   (再起動で 1 に戻る揮発設定)
"""
import sys, os, glob, time, argparse, hashlib, json

# live_ram.py と同一（degimon_world_remake*/workspace/tools/live_ram.py より）
ANCHOR = bytes([0x84,0x97,0x15,0x80, 0x84,0xf7,0x15,0x80, 0x84,0x17,0x16,0x80,
                0x84,0x37,0x16,0x80, 0x20,0x3a,0x16,0x80])
RAM_SIZE = 0x200000


def find_pid():
    hits = []
    for d in glob.glob('/proc/[0-9]*'):
        try:
            if 'duckstation' in open(d + '/comm').read():
                hits.append(int(os.path.basename(d)))
        except Exception:
            pass
    return hits


def open_ram(pid):
    """(mem_fd, host_base) を返す。live_ram.py open_ram と同一規則。"""
    mem = open(f"/proc/{pid}/mem", "rb", buffering=0)
    for line in open(f"/proc/{pid}/maps"):
        p = line.split()
        if len(p) < 2 or 'r' not in p[1] or 's' not in p[1]:
            continue
        a, b = p[0].split('-')
        a, b = int(a, 16), int(b, 16)
        if b - a < 0x200000 or b - a > 0x1000000:
            continue
        try:
            mem.seek(a)
            chunk = mem.read(b - a)
        except Exception:
            continue
        if ANCHOR in chunk:
            return mem, a
    mem.close()
    return None, None


def preflight():
    """発注前に user 側で失敗しうる点を先に全部出す。"""
    out = []
    try:
        scope = open('/proc/sys/kernel/yama/ptrace_scope').read().strip()
    except Exception:
        scope = '?'
    out.append(('ptrace_scope', scope, 'OK' if scope == '0' else
                'NG: sudo sysctl kernel.yama.ptrace_scope=0 が必要'))
    pids = find_pid()
    out.append(('duckstation pid', pids or '(なし)',
                'OK' if len(pids) == 1 else ('NG: 起動していない' if not pids else
                                             f'注意: {len(pids)} 件。--pid で指定')))
    return out, pids


def burst(pid, outdir, interval, count):
    mem, base = open_ram(pid)
    if mem is None:
        return None, 'ANCHOR 署名を含む region が見つからない（ゲーム未ロード / 版差）'
    os.makedirs(outdir, exist_ok=True)
    meta = {'pid': pid, 'host_base': hex(base), 'interval': interval,
            'count': count, 'anchor': ANCHOR.hex(), 'frames': []}
    t0 = time.time()
    for i in range(count):
        tgt = t0 + i * interval
        d = tgt - time.time()
        if d > 0:
            time.sleep(d)
        ts = time.time()
        mem.seek(base)
        data = mem.read(RAM_SIZE)
        path = os.path.join(outdir, f'ram_{i:04d}.bin')
        with open(path, 'wb') as f:
            f.write(data)
        meta['frames'].append({'i': i, 't': round(ts - t0, 4),
                               'sha256': hashlib.sha256(data).hexdigest()[:16]})
        print(f'\r{i+1}/{count}  t={ts-t0:6.2f}s', end='', file=sys.stderr)
    print(file=sys.stderr)
    mem.close()
    with open(os.path.join(outdir, 'burst_meta.json'), 'w') as f:
        json.dump(meta, f, indent=1, ensure_ascii=False)
    uniq = len({fr['sha256'] for fr in meta['frames']})
    return meta, f'OK: {count} 枚 / 相異 sha {uniq} 枚（相異 1 なら game 静止 or 読めていない）'


def selftest():
    """DuckStation 不要。read/write の実費と preflight だけ確かめる。"""
    print('== preflight ==')
    rows, pids = preflight()
    for k, v, s in rows:
        print(f'  {k:16} = {v}   -> {s}')
    print('== 2MB read+write の実費（/proc/self/mem、同一 syscall 経路） ==')
    import mmap
    buf = mmap.mmap(-1, RAM_SIZE * 2)
    buf.write(b'\xa5' * (RAM_SIZE * 2))
    addr = None
    for line in open('/proc/self/maps'):
        p = line.split()
        a, b = [int(x, 16) for x in p[0].split('-')]
        if b - a >= RAM_SIZE and 'rw-p' in p[1] and len(p) < 6:
            addr = a
            break
    t = time.time()
    with open('/proc/self/mem', 'rb', 0) as f:
        f.seek(addr)
        d = f.read(RAM_SIZE)
    r = (time.time() - t) * 1000
    tmp = '/tmp/_burst_selftest.bin'
    t = time.time()
    open(tmp, 'wb').write(d)
    w = (time.time() - t) * 1000
    os.remove(tmp)
    print(f'  read {r:.1f} ms + write {w:.1f} ms = {r+w:.1f} ms/枚')
    print(f'  -> 0.2s 間隔 150 枚（30 秒）= {(r+w)*150/1000:.2f} 秒 CPU / '
          f'{RAM_SIZE*150/1024/1024:.0f} MB')
    print('== 未検査（DuckStation 起動が要る） ==')
    print('  ANCHOR 署名による region 同定 / 実 RAM の読み取り / 会話中の内容')
    return 0 if all(s.startswith('OK') for _, _, s in rows) else 1


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--out')
    ap.add_argument('--interval', type=float, default=0.2)
    ap.add_argument('--count', type=int, default=150)
    ap.add_argument('--pid', type=int)
    ap.add_argument('--selftest', action='store_true')
    a = ap.parse_args()
    if a.selftest:
        return selftest()
    rows, pids = preflight()
    for k, v, s in rows:
        print(f'{k:16} = {v}   -> {s}', file=sys.stderr)
    if not a.out:
        print('--out DIR が要ります', file=sys.stderr)
        return 2
    pid = a.pid or (pids[0] if pids else None)
    if pid is None:
        return 2
    meta, msg = burst(pid, a.out, a.interval, a.count)
    print(msg, file=sys.stderr)
    return 0 if meta else 1


if __name__ == '__main__':
    sys.exit(main())
