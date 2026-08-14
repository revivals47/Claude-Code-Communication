# P2_WORKER1_STATE — worker1(EXE 直読)の現在地

## ★★先頭 30 行 = 現在地★★（★ここだけ読めば復帰できる形★）

★① 今何を追っているか（1 文）★
　★(b) は ★閉じました★ ⇒ ★★新規ゲームの [gp-0x6b78] 初期値 = ★50,000(0xC350)★★★（★0x80110BC8 ori → 0x80110BCC sw 0x1B4($s0) → 復元器 0x80110E30 の 0x80111000★）⇒ ★次は 器 × 事実の表★。

★② まだ boss1 に出していない観測★ = ★★0 件（v3-392 は #289 で送信済 / v3-393 は本便で送信）★★  ※過去分 = ★v3-392 = 初期値 50,000 / 初期名 しゅじんこう・デジモン / commit a937d39e★ = ★v3-392 = (b) の 3 型とも ★在った★ / ★初期値 50,000★ / ★初期名 = 名前表[0] ← 0x8013A13C「しゅじんこう」・partner ← 0x8013A14C「デジモン」★ / commit ★a937d39e★（p2w1）
　★算法 = 1 語ずつ capstone disasm(count=1) + lui/addiu 即値解決 + cp932 decode★ / ★母数 = 作られる絶対 address 1,677 種 / image 177,664 語★

★③ 次の 3 手（順番つき）★
　★1. 器 × 事実の表（P2_MATRIX_worker1.md）を GUARD/cap の列込みで仕上げる★（生成器 = w1_matrix.py・陽性対照つき）★← 次はこれ★
　★2. 上位 5 種の残り = 0x4C の kind 1..15 の要求元 / 0x57 の表 0x80157B38 の意味★
　★3. 0x56 が書く 4 cell（[gp-0x6ea7]/[gp-0x6ea6]/[gp-0x6ed1]/[gp-0x6ed0]）の同定★

★④ 使っている器と信用度★（★#286 で自分の陽性対照の欠陥を開示した表をそのまま★）
　★w1_lentab.py★ = ★高★（★既知 14 項と 14/14 一致 = 別便の手読みとの突合★）
　★w1_rw28.py / w1_desc_draw.py / w1_mode_len.py / w1_eval177.py★ = ★中〜高★（★1 語ずつ capstone(count=1) / 境界 4 通り + 共通 tail + 次 handler 頭★）
　★w1_matrix.py★ = ★中★（★#286 で ★読取失敗を空文字にする欠陥★ を自分で見つけ修正・陽性対照行を追加済★）
　★raw word decode（capstone 非依存）★ = ★最高★（★4 量で capstone と一致・母数 177,664 語★）
　★w1_win80.py★ = ★中★（★dst register しか追わない = move で見失う★ / この欠陥は #266 で開示済）
　★w1_render_reach.py ほか 20 行の except 握り潰し★ = ★低★（★未修正・使うときに再監査★）
　★私自身の bash 実行★ = ★中★（★2>/dev/null 実 redirect 31 件・実害 1 件は既訂正 / ★&& 連鎖の切断★ が実害の型★）

★⑤ 未解決の問い（★答えでなく問い★）★
　★Q1★ = ★★解決（v3-392）= 0x80110AE4 が save image の +0x1B4 に 50,000 を書き 復元器が [gp-0x6b78] へ★★
　★Q2★ ★0x56 が書く [gp-0x6ea7]/[gp-0x6ea6]/[gp-0x6ed1]/[gp-0x6ed0] は何の cell か★
　★Q3★ ★表 0x80157B38(stride 34) と 表 0x80163F60(stride 12 / 22 slot) の record の意味★
　★Q4★ ★0x4C 以外に kind 1..15 を要求する opcode は誰か★
　★Q5★ ★飛び越された区間（entry 177 の 3 区間）に別経路から入れるか★（★worker2 の座★）
　★Q6★ ★worker2 の帯 0x81-0x9F は ★他の site でも cp932 の 1 byte 目か★（★0x11DA の 1 例では text と確定・帯全体は null★）★

---

## ★以降 = 追記の索引★（★本体は degimon_world_remake-p2w1/workspace/degimon-faithful178/P2_DIFF_HARNESS_DESIGN_worker1.md（v3-xxx 節番号）★）

★引用 5 点（全項共通）★
・path = ★/home/ken/Desktop/Digimon/degimon_world_remake/extracted/slps_017_97.bin★（BASE 0x80090800 / ★177,664 語★）
・worktree = ★/home/ken/Desktop/Digimon/degimon_world_remake-p2w1★ / branch = ★track1/vm-spec-impl★ / ★p2w3 不参照★
・RAM = ★degimon_world_remake-f1c/workspace/f1c/oi3b_atrest/SLPS3_atrest_ram.bin★（sha256[:16] = ★7fa603a8fb515bbb★ / 2,097,152 byte / 0x80000000 起点）
・SCN = ★unity/Assets/StreamingAssets/dialogue/DG.SCN★（sha256[:16] = ★4d776b2c99755328★ / 読取のみ）
・算法 = ★1 語ずつ capstone disasm(count=1)★ / ★raw word decode(capstone 非依存)★ / ★DG.SCN byte 直読★

### ★確定した機構（索引）★
| 項 | 内容 | 節 |
|---|---|---|
| band | ★5 帯 / 100 語★（0x10-0x27 表 0x8011B0F8 / 0x28-0x3F 0x8011B1A0 / 0x46-0x58 0x8011B200 / 0x5A-0x5F 0x8011B24C / 0x64-0x7E 0x8011B3A0） | v3-322/377 |
| Len 表 | ★data 化済 = P2_LEN_EXE_worker1.tsv（git hash-object fb8086670e419e78462f449cf880cc2ef7e21e9d / 105 行）★ / ★固定 97 = 全部一意 / 可変長 3（0x10・0x19・0x1A）★ | v3-377 |
| 0x19 | ★Len = 1(opcode) + 1(handler 0x800EC714) + Σ項長 + 2(終端)★ / ★終端 = cond byte 0x19（BIOS A(0x14) longjmp）★ / ★抜け口は終端と mode 0x10・0x18 の転送の 2 つだけ★ | v3-364 |
| 0x19 項長 | ★0x00:4 / 0x08:4 / 0x10:4 / 0x18:4 / join(0x28・0x30・0x38):2 / 0x20 = sub 依存 6,6,4,4,6,8,2,2★ | v3-357 |
| 0x19 operand | ★sub0/1/4 = [id][op][u16] / sub2 = [id][否定flag] / sub3 = [mask][否定flag] / sub5 = [skip][op][u32]★ | v3-385 |
| 0x19 getter | ★sub0 = 0x800F53C8→表 0x8011B4A4(23 entry) / sub1 = [gp-0x6cec]+id/2+0xD4 の nibble / sub2 = 0x801040BC(flag) / sub3 = [0x80141D18]&mask / sub4 = 0x800CE2C8(表 0x80145F2C) / sub5 = [gp-0x6b78]★ | v3-370 |
| 比較器 | ★0x800F10B0 = cond&7 / 表 0x8011B170(6 entry) = ==,!=,>=,<=,>,< ★全部 unsigned★ / op6・7 は arm 無し★ | v3-371 |
| var 配列 | ★[gp-0x6cec] + idx + 0x159 の byte 配列 / 出入口は setter 0x800F0CD0・getter 0x800F0AC8 の ★2 本のみ★★ | v3-374 |
| 0x24 | ★var[A] := rand(0..B)（BIOS A(0x2F)）/ Len 4★ ⇒ ★mode 0x08 が読む配列と同一★ | v3-371 |
| 0x2B / 0x2A | ★[gp-0x6b78] -= / += （0 clamp / 999,999 clamp）/ Len 6★ / ★書く VM opcode はこの 2 本だけ★ | v3-366/385 |
| 0x16 / 0x13 | ★どちらも無条件（条件分岐 0 件 / 母数 24 語）★ / ★0x13 = call（0x800F0D58 で push）/ 0x16 = jump★ | v3-381 |
| [gp-0x6ccc] | ★いま実行中の entry の base（entry 単位）★ / ★operand は entry 先頭からの byte offset★ | v3-368 |
| 話者 | ★0x1B → [gp-0x6cbe] → 0x800F4200 → ★0x800F4DBC★ = 名前生成★ / ★0xFF→0 / 0xFD→index0 / 0xFC→RAM 0x8016B0EC / <200→record+0x00 / >=200→ptr 表 0x80136C74(6 件)★ | v3-362 |
| 名前表 | ★0x8013A924 / stride 52 / 180 entry / cp932★ / ★★[0] は player 名 slot（image の「しゅじんこう」は既定値・RAM は「けん」）★★ / ★書き手 = memcpy(0x8013A924, s0+0x467, 0x14) @0x80111048★ | v3-383/387 |
| 窓 | ★pool 0x801640B8 / stride 52 / ★slot 6★ / +0x00 anchor / +0x08 矩形 / +0x10 種別 byte（bit7 = anchor 付き描画）★ | v3-355 |
| 0x4A / 0x4C | ★0x4C = 表 0x80163F60(stride 12 / 22 slot)へ動作要求 / 0x4A = 完了待ち★ / ★駆動 0x800EC3AC → 実行 0x800EFC50（kind 表 0x8011B40C 16 entry）→ 完了で [0]=0xFF★ | v3-376/379 |
| 0x27 / 0x56 / 0x57 | ★0x27 = window slot を閉じる / 0x56 = 0xFD・0xFC・else の三分（gp 相対 store 4 件）/ 0x57 = 表 0x80157B38(stride 34)+0x2DD に 1 byte★ | v3-390 |
| 復元器 | ★0x80110E30(save 構造体 → RAM)★ / ★[gp-0x6b78] ← s0+0x1B4 / 名前表[0] ← s0+0x467 / partner 名 ← s0+0x47B / sub4 表 ← s0+0x40C★ | v3-387 |
| 走査型 | ★『0 件』の 4 家族 = ① 打ち切り ② 走査型の外 ③ 沈黙 ④ 連鎖の切断★ ⇒ ★0 件を出すときは型を明示★ | v3-359/387/388 |

### ★私が自分で訂正した主なもの（★再発防止の索引★）★
・★v3-349(b)『EXE に名前表は無い』→ 誤り（0x8013A924 に在る）★ = ★1 表が空なのを見て全体を語った★
・★#265 §4『bit 0x80 = 話者欄』→ 誤り（anchor 付き描画の選択）★
・★#277『0x57/0x56/0x27 は VM cell 書き 0』→ ★枠が handler 本体だった★（呼び先込みなら 0x56 は 4 件）★
・★#269『script base』→ ★entry base★（曖昧な語を 2 人に配った）★
・★v3-359 §5『母数を 162,130 に落とす』→ ★弱すぎ★ ⇒ ★raw decode で 177,664 を取り戻した★
・★v3-357『cond==0x19 は guard で異常終了』→ ★正常路の終端★
・★#277『0x4A = 対象 actor 指定』→ ★完了待ち★

### ★#293 で受領した事実（未消化・次に効く）★
・★vmtrace.py の記録 key は 11 要素 ⇒ ★stack だけが動いた遷移は記録されない★★（key に無い = fb_entry / bank_ptr / pad_b / stack）
・★t = host の経過秒（time.perf_counter）= game frame ではない ⇒ 同じ host 条件の対でしか比べられない★

### ★不変（全便で保持）★
★push しない / 完成 claim 凍結 / 共有 tree（degimon）読取のみ / p2w3 は触らない / 実行 trace は始めない / worker 間直送禁止 / STATE は送信ごと / backtick 不使用★
