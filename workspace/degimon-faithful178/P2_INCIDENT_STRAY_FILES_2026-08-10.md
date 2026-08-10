# §89.5 CCC repo 直下の散乱 file — 由来特定・削除・規範追加(boss1、2026-08-10)

## 1. 結論

CCC repo 直下の untracked file は **9 件**(PRESIDENT 報告の 6 件 + 3 件)。**全件 0 byte**。
由来は shell の redirect 事故で正しい。ただし発生機構は **agent-send.sh の message 内 backtick による command substitution** であり、
**PRESIDENT が本便で自ら踏んだのと同一の禁則** (memory: feedback_agent_send_backtick)。

削除済。**巻き添え(既存 file の truncate)はゼロ**。

## 2. 実物一覧(削除前に全件 head で中身確認、全て size 0)

| file 名 | mtime (JST) | 発生元 session | 機構 |
|---|---|---|---|
| =count | 2026-07-19 08:53:13.706 | 62968a79 | backtick 内 `variant>=count` |
| +0x34 | 2026-08-09 20:42:55.138 | c1405719 | 未確定(下記 4 節) |
| 0x2A78 | 2026-08-09 21:00:24.238 | c1405719 | 未確定(下記 4 節) |
| 0x2a78 | 2026-08-09 22:36:19.780 | a82a5153 | backtick 内 `BR_IF_FALSE->0x2a78` |
| 0x2a9a | 2026-08-09 22:36:19.781 | a82a5153 | 同上(1 command で 2 file) |
| 0x0dd0 | 2026-08-09 22:39:29.364 | c829e386 | backtick 内 `var[0x1]>=0x32 ... ->0x0dd0` |
| =0x32 | 2026-08-09 22:39:29.364 | c829e386 | 同上(1 command で 2 file) |
| =4 | 2026-08-09 23:28:19.046 | 2ba1f410 | backtick 内 `>=4 && <8` |
| = | 2026-08-10 03:11:48.857 | c829e386 | backtick 内 `>= 0x16`(TEXT 終端規則の説明) |

## 3. 特定手順(走査範囲)

母集団 = `~/.claude/projects/-home-ken-Documents-Claude-Code-Communication/*.jsonl` 全 session transcript。
filter = `tool_use.name == "Bash"` かつ command に `agent-send` を含み、かつ backtick を含む行に redirect 形 `>` + 対象 token。
突合 = file mtime(JST) と transcript timestamp(UTC)を **秒単位で照合**。

- `=count`: transcript 2026-07-18T23:53:13.578Z ⇔ file 2026-07-19 08:53:13.706 JST = **同一秒、+0.13s**
- `0x2a78`/`0x2a9a`: 2026-08-09T13:36:19Z ⇔ 22:36:19.780/.781 JST = **同一秒、2 file が 1ms 差** = 1 command 内の 2 redirect
- `0x0dd0`/`=0x32`: 2026-08-09T13:39:29Z ⇔ 22:39:29.364 JST(**両 file の mtime が完全同値**)= 1 command 内の 2 redirect

∴ 7/9 は **秒単位一致で backtick 起因と確定**。

## 4. 未確定として残す 2 件(消さない限定)

`+0x34` と `0x2A78`(大文字)は、時刻が近接する agent-send command に backtick が **0 個**だった。
- 対抗仮説 = **受信側 pane が bash prompt に落ちていた**(session 落ち中に agent-send が届き、message 全体が shell command として実行された)。
  `+0x34` は file mtime が送信 tool 呼び出しの **+2.3 秒後** で、agent-send.sh の `sleep 0.3` + `sleep 2`(L69/L73)後の C-m と一致する。
- ただし決定的証拠は取れていない ⇒ **「この走査範囲では機構を確定できない」**と書く。「backtick が原因である」と 9 件まとめて言わない。

## 5. 巻き添え確認(誤上書き)

- tracked file で 0 byte なのは `workspace/degimon-faithful178/runtime_capture_2026-07-25/wp_field_loader_2.log` 1 件のみ。
  `git show HEAD:<path> | wc -c` = **0** ⇒ **commit 時点から 0 byte**。今回の事故による truncate ではない。
- working tree の変更は `pane-watchdog.sh`(+15/-1)と `PBR_P2_HANDOFF_2026-08-09.md` の 2 件のみで、いずれも内容を持つ正当な編集。
- 2026-08-09 20:00 以降に mtime を持つ file を全数列挙し、0 byte はこの 9 件のみであることを確認。

∴ **意図しない上書きは検出されない**(走査範囲 = CCC repo 配下、`.git` 除外、mtime 2026-07-18 以降)。

## 6. 追加した規範(全 agent へ再配布済)

1. **agent-send.sh の message で backtick を使わない**。raw byte / 命令列 / code は message に載せず、doc に書いて file:line で参照する。
   - 構造的理由: message は呼び出し側 shell の double quote 内で展開される。backtick 内の `>` `>=` `->` は **その場で redirect になる**。
2. **redirect を使う command は先に echo で確認する**(PRESIDENT 指示)。
3. **規範を配ることと、自分に当てることは別**。本件は「配った側が同じ穴に落ちた」4 例目。
   remedy は「次から気をつける」ではなく、**道具側で不可能にすること**(= message に raw を載せない運用)。
