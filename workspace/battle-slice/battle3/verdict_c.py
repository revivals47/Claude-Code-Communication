#!/usr/bin/env python3
# (c) 専用 — capture_c.gdb の 1 行を 人の言葉に直す
import sys
print("★準備できました。戦って、勝ってください。★", flush=True)
for line in sys.stdin:
    t = line.strip()
    if t.startswith("START_C "):
        print("★はじめました。★ " + t[8:], flush=True)
    elif t.startswith("WIN_SITE "):
        print("★★見つけました（勝った所）★★ " + t[9:], flush=True)
    elif t.startswith("WINS_CHANGE "):
        print("  ・（勝った回数が 変わりました: " + t[12:] + "）", flush=True)
    elif t.startswith("E088_CHANGE "):
        print("  ◆ 目印の値が 変わりました（" + t[12:] + "）", flush=True)
    elif t.startswith("TOTAL_STOPS_C "):
        print("★止まった回数 = " + t[14:] + " 回★", flush=True)
