# DuckStation GDB watchpoint 手順 (worker3, 2026-07-24)

## 目的
entity array書込みPC(=loader)を live write-watchpoint で trap → loader RE + scale適用site を非対話で取得。

## feasibility実測結果(measure-first)
- ✓ DuckStation GDB server 実在(strings + settings key `EnableGDBServer`/`GDBServerPort=2345`、gdb_server.cpp)。
- ✓ network namespace = host共有(host から flatpak port 到達可)。
- ✓ CLI: `-statefile <sav>` / `-batch` / `-fastboot` 対応。gdb=/usr/bin/gdb 有。
- ✓ flatpak filesystem: game dir は portal経由(`/run/user/1000/doc/.../degimon`)、`--filesystem=/home/ken/Desktop/Digimon:ro` で grant可。
- ✗ ★headless :1 で DuckStation emulation が走行に至らず★: savestate-load / fresh-boot 両方で黒画面 + ★port 2345 が一度もlistenせず★(gdb connect timeout、/proc netns 確認でも 0x0929 無)。GDB serverはemulation走行時に起動する設計ゆえ、走行しない=server起動せず。
- ∴THIS環境(非対話・headless :1)では watchpoint 実行不可 = ★環境境界(DuckStation-qtがreal display/compositorを要する)★。Unity buildは自前Vulkan captureで:1描画可だが、DuckStation-qtのrender pathは:1で不成立。

## 結論
- watchpoint path は ★architecturally viable だが user-session-gated★: user が real display で DuckStation を EnableGDBServer=true + game走行 させれば、下記gdb scriptが非対話attachでwatchpoint→trap PC取得可能。
- 自律capability単独では突破不可(headless DuckStation走行不能)。

## user-session時の手順(即実行可)
1. settings.ini: `[Debug]` の `EnableGDBServer = true`(port 2345)。DuckStation再起動。
2. user が degimon を起動 + 対象map savestate load(entity populated)、または map遷移直前state。
3. 別terminalで下記(map遷移をuserが起こす直前/直後にcontinue):
```
gdb -batch \
  -ex 'target remote 127.0.0.1:2345' \
  -ex 'watch *0x80147358' \
  -ex 'continue' \
  -ex 'info registers pc' \
  -ex 'backtrace'
```
- trap時のPC = entity array書込みPC(loader候補)。map-load trigger時にtrapすればloader確定。
- ★注: loader は map-load 1回writeゆえ、watchpoint設定後に map遷移をuserが起こす必要(mid-map staticではtrapせず)。scale適用siteも同様に該当addressへwatchpointで取得可。
4. Z2(hardware watch)対応確認: gdbが 'Hardware watchpoint' と表示すれば stub がZ2対応。'Watchpoint'(software=single-step)なら低速だが機能はする。

## worker1 unblock
- 上記trap PCで loader RE(register-base間接writeの実行site)を静的traceせず直接取得可。
- render-path scale source も、scale適用が疑われるaddressへ同手順でwatchpoint→適用PC取得で(A)深trace unblock。
