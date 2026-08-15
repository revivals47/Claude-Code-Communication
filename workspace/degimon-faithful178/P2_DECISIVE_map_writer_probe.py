#!/usr/bin/env python3
"""決定実験: 原盤で「誰が map cell を書くか」を 1 回で採る。

■ 何を確かめるか
  remake は opcode 0x4B を「直接 warp」として実装しているが、原盤の 0x4B の arm
  (0x800ED774..0x800ED7EC・31 語) には map を変える store も、それに届く即値 jal も
  1 つも無い(worker2 #572: 解決済み辺 6,783 の範囲で 0 本・未解決 jalr 98 は開示)。
  ∴「item 22 → section 1245 → ??? → map が変わる」の ??? が未確認のまま。
  静的解析で 98 の間接辺を解くより、原盤で実際に止める方が安い(PRESIDENT #1837)。

■ 停止点(boss1 #1849 提供・出所 worker2 #529 = EXE 全 177,664 命令の全走査)
  ★これは image 内の全数 = 下界★。overlay からも書き得る(未確認)。
  A 0x800DFAFC  opcode 0xFB の第2 operand & 0xFF を書く
  B 0x80111DF0  0x800E4A08 の返り値 & 0xFF を書く(到達 = opcode 0x64 の operand 54)
  C 0x800DF2A0  定数 204 を書く(script から届かない = EXE 内部経路)
  S 0x800CD39C  section 1245 を呼ぶ唯一の site(前回 hit 実績あり・a1=0x4DD)

■ 読み方(★実験前に固定★ = boss1 #1849 ④。事後に解釈を作らない)
  A が先に hit      → remake の解釈と同じ(0x4B 由来の何かが 0xFB に化ける)
  B が hit          → 選択器 0x800E4A08 が走っている = 我々の静的結論と別の路
  C のみ            → 初期化だけ
  どれも hit せず map が変わる → overlay か未解決 jalr

■ 使い方
  --selftest   接続せず packet 組立だけ検証(★emulator に触らない★)
  --run        実際に接続する(★user 同意後のみ★。attach は emulator を止める)
"""
import socket, sys, time

HOST, PORT = '127.0.0.1', 2345
SITES = {
    0x800DFAFC: ('A', 'opcode 0xFB の operand を書く'),
    0x80111DF0: ('B', '0x800E4A08 の返り値を書く(0x64/54 経路)'),
    0x800DF2A0: ('C', '定数 204 を書く(EXE 内部)'),
    0x800CD39C: ('S', 'section 1245 の唯一の呼び site'),
}
# MIPS 標準 g-packet: r0..r31(32) sr lo hi bad cause pc → pc は index 37
PC_INDEX = 37


def csum(body: bytes) -> bytes:
    return f'{sum(body) & 0xff:02x}'.encode()


def pack(cmd: str) -> bytes:
    b = cmd.encode()
    return b'$' + b + b'#' + csum(b)


class Rsp:
    def __init__(self, sock):
        self.s = sock

    def send(self, cmd: str) -> str:
        self.s.sendall(pack(cmd))
        return self.recv()

    def recv(self, timeout=30) -> str:
        self.s.settimeout(timeout)
        buf = b''
        while True:
            ch = self.s.recv(1)
            if not ch:
                raise IOError('接続が閉じました')
            if ch == b'+':          # ack は読み飛ばす
                continue
            if ch == b'$':
                buf = b''
                continue
            if ch == b'#':
                self.s.recv(2)       # checksum 2 桁
                self.s.sendall(b'+')
                return buf.decode('ascii', 'replace')
            buf += ch


def parse_regs(hexstr: str):
    """g-packet を u32 little-endian の list に。"""
    n = len(hexstr) // 8
    out = []
    for i in range(n):
        w = hexstr[i * 8:(i + 1) * 8]
        out.append(int.from_bytes(bytes.fromhex(w), 'little'))
    return out


def selftest():
    print('=== selftest(接続なし) ===')
    assert pack('g') == b'$g#67', pack('g')
    for addr in SITES:
        p = pack(f'Z0,{addr:x},4')
        print(f'  {SITES[addr][0]} 0x{addr:08x} → {p.decode()}')
    regs = parse_regs('01000000' + '02000000' * 36 + 'fcfa0d80')
    assert len(regs) == 38, len(regs)
    assert regs[PC_INDEX] == 0x800DFAFC, hex(regs[PC_INDEX])
    print(f'  g-packet 解釈 OK(38 語・pc index {PC_INDEX} = 0x{regs[PC_INDEX]:08x})')
    print('  ★emulator には 一切 触れて いません★')


def run():
    print(f'=== 接続 {HOST}:{PORT}(★attach は emulator を止めます★) ===')
    s = socket.create_connection((HOST, PORT), timeout=10)
    r = Rsp(s)
    try:
        print('  停止理由:', r.send('?'))
        for addr, (tag, desc) in SITES.items():
            resp = r.send(f'Z0,{addr:x},4')
            ok = (resp == 'OK')
            print(f'  Z0 {tag} 0x{addr:08x} → {resp!r} {"" if ok else "★設定できません★"}')
            if not ok:
                print('  ⚠ breakpoint が設定できないので中止します(器が効いていない)')
                return
        print('\n  ★ここで user に「オートパイロットを使ってください」と伝える★')
        print('  待機中(最大 300 秒)...')
        r.s.sendall(pack('c'))
        stop = r.recv(300)
        print(f'  停止: {stop!r}')

        regs = parse_regs(r.send('g'))
        pc = regs[PC_INDEX] if len(regs) > PC_INDEX else None
        hit = SITES.get(pc)
        print(f'\n  レジスタ {len(regs)} 語  pc = {pc:#010x}' if pc else f'  レジスタ {len(regs)} 語')
        if hit:
            print(f'  ★hit = {hit[0]}★ {hit[1]}')
            print(f'  ra = {regs[31]:#010x}   a0 = {regs[4]:#010x}   a1 = {regs[5]:#010x}   a2 = {regs[6]:#010x}')
            print(f'  ∴ 呼び元は ra = {regs[31]:#010x}(この番地の直前の jal が書き手)')
        else:
            # ★器の自己監査★: pc が停止点と合わないなら PC_INDEX の仮定が誤り
            print('  ⚠ pc が停止点と一致しません = PC_INDEX の仮定が誤りの可能性')
            for i, w in enumerate(regs):
                if w in SITES:
                    print(f'    → index {i} が停止点に一致(0x{w:08x}) = 真の pc index はここ')
    finally:
        try:
            for addr in SITES:
                r.send(f'z0,{addr:x},4')     # breakpoint 解除
            r.s.sendall(pack('c'))           # ★必ず再開させる★
            print('\n  breakpoint 解除 + 実行再開を送りました')
        except Exception as e:
            print(f'  ⚠ 後始末に失敗: {e}(DuckStation 側で手動再開が要ります)')
        s.close()


if __name__ == '__main__':
    if '--run' in sys.argv:
        run()
    else:
        selftest()
