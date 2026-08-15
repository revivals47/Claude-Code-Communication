# P2_ORI_PREREG_worker2 — ★ori / 加算合成を どこまで 数えるか（★測る前★）★

★受領★ = boss1 #627 ③／ ★書いた 時刻 = 測定の 前★／ ★emulator 非接触★

## ★問い★

```
 ★★map writer 3 本（0x800DF1A8 / 0x800DF7D0 / 0x80111DBC）の address を
   ★lui+addiu 以外の 形★ で 作る code が 在るか★★
```

## ★★★見る 形（★これを 数えます★）★★★

```
 ★① lui $r, HI            → r = HI<<16★
 ★② ori $r, $s, IMM       → r = s | IMM★（★lui+ori の 形★）
 ★③ addiu $r, $s, IMM     → r = s + IMM★（★既に 見た 形・再掲★）
 ★④ addu / add $d, $s, $t → d = s + t★（★両方 既知 定数の とき だけ★ = ★2 段 合成★）
 ★⑤ subu / sub $d, $s, $t → d = s - t★（★同上★）
 ★⑥ move（addu $d,$s,zero / or $d,$s,zero）→ 伝播★
 ★★窓★★ = ★64 命令★（★register の 有効期間★）／ ★jal で caller-saved を 破棄★
 ★母数★ = ★EXE image 全 177,664 命令 ＋ extracted 17 file 全語★
```

## ★★★見ない 形（★残る 穴として 先に 書きます★）★★★

```
 ★(a) ★memory から 読んだ 値★ を 起点に した 合成（lw → addiu 等）★
 ★(b) ★関数を 跨いで register で 渡された 値★（★窓の 外★）
 ★(c) ★shift（sll / srl）で 作る★・★mult / div 経由★
 ★(d) ★実行時にしか 決まらない 値★（index 等）との 加算
 ★★∴ ★これらは ★今回も 塞ぎません★★★
```

## ★★判定の 先出し★★

```
 ★★(P) 0 件だった ⇒ ★通りにくさ ② の 母数が 広がる だけ★★（★結論 不変・穴は 縮むが 消えない★）
 ★★(Q) 1 件でも 出た ⇒ ★『lui+addiu 0 件』は ★形の 選び方の 産物★ だった★★
   ⇒ ★★∴ ★出た site を 逐語で 出し ★その 値が 実際に 呼ばれ得るか★ を 別に 測ります★★
```
