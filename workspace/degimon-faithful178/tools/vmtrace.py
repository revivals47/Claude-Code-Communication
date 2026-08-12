#!/usr/bin/env python3
"""vmtrace.py — 原盤 VM の ★状態遷移 trace★ を 高頻度で 採る（worker2 / track2/trace-oracle）

★burst_ram.py との 違い★:
  burst_ram.py は 1 frame ごとに ★2MB 全読み★ してから digest する。
  本 tool は ★WATCH が 載る page だけ★ を 読む。

  ★実測（本 PC、300 回平均、/proc/self/mem）★:
      2MB 全読み  = 0.388 ms
      4KB 1 page = 0.0014 ms
      4KB 2 page = 0.0029 ms      ← ★134 倍 安い★
  ⇒ ∴ ★5 Hz → 1 kHz★ にしても 読取コストは 元の 1/40。
     60 秒 = 60,000 sample × 約 96 byte = ★約 6 MB★（burst の 600 MB に対し 1/100）

★∴ これが (465) の 母数問題に 効く 理由★:
  VM は frame 単位(約 60 Hz)で yield する。0.2 秒 sampling では ★12 frame に 1 回★ しか 見えない。
  1 kHz なら ★1 frame あたり 約 16 sample★ ⇒ ★frame 単位の 状態遷移を 取りこぼさない★。
  ★但し 命令単位では ない★: 1 ms に PS1 は 約 33,000 命令 進む。
  ⇒ ∴ ★捉えられるのは 「frame 境界の state」であって「命令列」では ありません★。

★未同定（本 tool では まだ 採れない）★:
  - ★入力(pad)の address★ … 入力が 揃わないと remake と 比較しても 差の 帰属が できない
  - ★flag / scenario 変数の address★ … 比較軸 5 が 空になる
  ⇒ ∴ ★どちらも 観測発注の 前提★。設計便で 上申する。

usage:
  vmtrace.py --out trace.jsonl [--hz 1000] [--duration 60]
  vmtrace.py --selftest          # DuckStation 不要
前提: sudo sysctl kernel.yama.ptrace_scope=0
"""
import sys, os, glob, time, json, argparse, struct

RAM = 0x80000000
PAGE = 4096

# gp = 0x80144E0C。VM 変数群は 0x8013E120-0x8013E15C = ★64 byte / 同一 page★
VM_LO = 0x8013E100
VM_LEN = 0x200        # ★0x8013E100-0x8013E2FF。pad(0x8013E2C0-C8)まで ★同一 page = 追加コスト 0★★
WIN_LO = 0x80164000          # win0-5 の +14（0x801640B8 + i*0x34 + 0x14）
WIN_LEN = 0x300
STK_LO = 0x80163780          # stack base 0x80163784、record 8 byte
STK_LEN = 0x2A0             # ★0x80163780-0x80163A1F。stack(+4..) と ★flag 配列(+0xF5+..)★ を 1 read で★
# ★flag 配列★（EXE 直読: 0x800F0C74 → jal 0x800F191C）
#   byte = *(gp-0x6cec) + (id >> 3) + 0xF5   /   bit = id & 7
#   *(gp-0x6cec) = 0x8013E120 の 値 = 0x80163784 ⇒ ★flag base = 0x80163879★
#   ★窓 423 byte の 上限は ★次の 既知 base 0x80163A20★ であって code の 範囲検査では ない（未読）★
# ★bank 668 byte の 区画（既存 RE + remake EventOracle.cs:117 と 一致）★
#   +0x0D4..0x0F5 stats(nibble) / ★+0x0F5..0x159 flags 100 byte★ / +0x159..0x259 vars 256 byte
#   ★+0x25C.. call-stack record(8 byte)★
FLAG_BASE = 0x80163879        # bank+0xF5
FLAG_LEN = 100                # ★423 では ありません（前版は vars と 末尾を 混ぜていました）★
VAR_BASE = 0x801638DD         # bank+0x159
VAR_LEN = 256
STACK_BASE = 0x801639E0       # bank+0x25C

FIELDS = [                   # (名前, VA, size)
    ("stop",      0x8013E15C, 4),
    ("pending",   0x8013E150, 1),
    ("pc",        0x8013E144, 4),
    ("base",      0x8013E140, 4),
    ("entry",     0x8013E138, 2),
    ("fb_entry",  0x8013E136, 2),
    ("depth",     0x8013E12A, 2),
    ("bank_ptr",   0x8013E120, 4),   # ★bank base（stack では ない）★
    # ★pad（EXE 直読で 同定: button mask を test する 81 site の 出所を 全数集計）★
    ("pad_held",  0x8013E2C0, 4),   # gp-0x6B4C / ★43 site が ここを test★
    ("pad_b",     0x8013E2C4, 4),   # gp-0x6B48 / 4 site
    ("pad_edge",  0x8013E2C8, 4),   # gp-0x6B44 / 25 site / ★burst 300 frame で e ⊆ held が 300/300★
    # ★★PRESIDENT (589) で 追加★★: ★`VM_LO 0x8013E100 + VM_LEN 0x200` の 内側 ⇒ ★追加 read ゼロ★★
    #   ★★但し ★これが map index か どうかは ★未検証★★★（★出すのは 只だが ★意味は まだ 無い★★）
    #   ★かつ ★既撮り 4 本には 遡及しません★（★jsonl に 出るのは FIELDS で 抽出した 語だけ★）⇒ ★v5 から 入ります★
    ("map",       0x8013E166, 2),
]


def find_pid():
    for d in glob.glob("/proc/[0-9]*"):
        try:
            if "duckstation" in open(d + "/comm").read():
                return int(os.path.basename(d))
        except Exception:
            pass
    return None


def find_base(fd, pid):
    """live_ram.py と同じ ANCHOR 署名で PS1 RAM の host base を 同定する。"""
    ANCHOR_VA = 0x8013E114        # ★burst dump で 全 2MB 走査 ⇒ 出現 1 箇所★
    ANCHOR = bytes([0x84, 0x97, 0x15, 0x80, 0x84, 0xf7, 0x15, 0x80,
                    0x84, 0x17, 0x16, 0x80, 0x84, 0x37, 0x16, 0x80,
                    0x20, 0x3a, 0x16, 0x80])
    for line in open(f"/proc/{pid}/maps"):
        p = line.split()
        if len(p) < 2 or "r" not in p[1]:
            continue
        lo, hi = (int(x, 16) for x in p[0].split("-"))
        if hi - lo < 0x200000:
            continue
        try:
            blob = os.pread(fd, min(hi - lo, 0x400000), lo)
        except OSError:
            continue
        i = blob.find(ANCHOR)
        if i >= 0:
            return lo + i - (ANCHOR_VA - RAM)    # ★ANCHOR VA = 0x8013E114（dump 実測、1 箇所のみ）★
    return None


def sample(fd, host):
    vm = os.pread(fd, VM_LEN, host + (VM_LO - RAM))
    win = os.pread(fd, WIN_LEN, host + (WIN_LO - RAM))
    stk = os.pread(fd, STK_LEN, host + (STK_LO - RAM))
    r = {}
    for name, va, sz in FIELDS:
        o = va - VM_LO
        r[name] = int.from_bytes(vm[o:o + sz], "little")
    r["win"] = [win[(0x801640B8 + i * 0x34 + 0x14) - WIN_LO] for i in range(6)]
    d = min(r["depth"], 8)
    # ★stack は bank+0x25C（remake GameState.cs:632 の 自称 + burst 33 frame で tag=4/+7=0xFF を 確認）★
    #   ★bank+0 では ありません（私の 初版は 604 byte ずれていました）★
    r["stack"] = [list(struct.unpack_from("<IHBB", stk,
                  (STACK_BASE - STK_LO) + 8 * i)) for i in range(d)]
    r["flags"] = stk[FLAG_BASE - STK_LO: FLAG_BASE - STK_LO + FLAG_LEN].hex()
    r["vars"] = stk[VAR_BASE - STK_LO: VAR_BASE - STK_LO + VAR_LEN].hex()
    return r


def run(out, hz, duration):
    pid = find_pid()
    if pid is None:
        sys.exit("duckstation が 見つかりません")
    fd = os.open(f"/proc/{pid}/mem", os.O_RDONLY)
    host = find_base(fd, pid)
    if host is None:
        sys.exit("ANCHOR 不一致: RAM base を 同定できません")
    dt = 1.0 / hz
    n = int(duration * hz)
    t0 = time.perf_counter()
    prev = None
    kept = 0
    late = 0          # ★予定 slot を 過ぎてから 撮った sample 数 = ★取りこぼしの 直接指標★★
    taken = 0
    with open(out, "w") as f:
        f.write(json.dumps({"pid": pid, "host": host, "hz": hz,
                            "duration": duration, "fields": [x[0] for x in FIELDS]}) + "\n")
        for i in range(n):
            tgt = t0 + i * dt
            if time.perf_counter() > tgt + dt:
                late += 1
            while time.perf_counter() < tgt:
                pass
            r = sample(fd, host)
            taken += 1
            r["t"] = round(time.perf_counter() - t0, 6)
            # ★変化した sample だけ 書く★（state 遷移 trace なので 冗長行は 不要）
            key = (r["pc"], r["base"], r["entry"], r["stop"], r["pending"],
                   r["depth"], r["pad_held"], r["pad_edge"], tuple(r["win"]),
                   r["flags"], r["vars"])
            if key != prev:
                f.write(json.dumps(r) + "\n")
                kept += 1
                prev = key
        # ★footer: 分母を 後段に 渡す（★一致率を 出す前に 分母を 見せる★）★
        f.write(json.dumps({"footer": True, "requested": n, "taken": taken,
                            "kept": kept, "late": late,
                            "elapsed": round(time.perf_counter() - t0, 6)}) + "\n")
    os.close(fd)
    print(f"sample 要求 {n} / 実施 {taken} / 記録 {kept} 行 / ★slot 遅延 {late}★ / {time.perf_counter()-t0:.2f} s")


def selftest():
    import mmap, ctypes
    buf = mmap.mmap(-1, 0x200000)
    buf.write(b"\x00" * 0x200000)
    addr = ctypes.addressof(ctypes.c_char.from_buffer(buf))
    fd = os.open("/proc/self/mem", os.O_RDONLY)
    t = time.perf_counter()
    for _ in range(200):
        sample(fd, addr)
    ms = (time.perf_counter() - t) / 200 * 1000
    os.close(fd); buf.close()
    print(f"selftest: 1 sample = {ms:.4f} ms ⇒ 上限 約 {int(1000/ms)} Hz")
    print(f"  ∴ 1 kHz なら 占有率 {ms*100:.1f}%")


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--out")
    ap.add_argument("--hz", type=int, default=1000)
    ap.add_argument("--duration", type=float, default=60)
    ap.add_argument("--selftest", action="store_true")
    a = ap.parse_args()
    if a.selftest:
        selftest()
    elif a.out:
        run(a.out, a.hz, a.duration)
    else:
        ap.print_help()
