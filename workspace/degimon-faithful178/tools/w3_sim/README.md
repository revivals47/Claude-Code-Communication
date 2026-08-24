# w3_sim — run3 較正 sim の器（保存のみ・走らせていません）

## 0. これは何か / なぜ在るか
codex の checkpoint 査読（2026-08-25）の指摘 —
「I also did not find the simulator/analysis executable stored beside the result documents,
 so the gate is not independently reproducible from this workspace.」
の remedy。**worker3 が /home/ken/ に置いたまま commit していなかった器と出力を、boss1 が
そのまま（byte 無改変で）この場所に保存した**もの。

- 実行者 = boss1（copy と commit のみ）。**1 本も走らせていません**（不変 = run 0 本 / compile 0）。
- 原本 = /home/ken/w3*.py, /home/ken/w3*.out, /home/ken/w3chain.sh（mtime を保持して copy）。
- 原典の作者 = worker3。番号は boss1 → worker3 の便番号（#845-C / #847-C 等）。

## 1. sha256（保存時点＝2026-08-25 03:49）
```
0ffce4f3d602c213cf75ba72f4d494e5d56687106f57ca21a5007ddc64db1af0  w3gate.py
006a9e29265b32187ad7f25e31e3bdb7b646e966330206b84d546fe29565114c  w3gate.out
3025a121851aac0a9a9366b7fc13c82736410a3940c5342472f3c4944114e344  w3size.py
eeae23621ae34f73eef59c69aba4518698727163f147501dbed0b53c836c6415  w3size.out
cffe65088cf242109e00500b590f18f12beb98c680c81e7c0e00e05b19e56639  w3gate2.py
bb8649e834a2ecdff639e2d9a157369a78f4a6645df9ef8615fa48bc1841fe5c  w3gate2.out
165e4df8d2ec2099b809d2e8194872f6ca655d1bcfee3d94943206a8dc83868a  w3fresh.py
37537b049723a1add1413b3381d7cb95da75a046e64a2560d9ade4404110375d  w3fresh.out
55143fe2c8fcc15917b593b598a0817ae350b02672e20fcf41ea4d8b6cc8e274  w3L.py
f6a66133ee30549c40ce04680787758125efcdfe441a3dfdcf55146bc855ca3d  w3L.out
4e75bcb498f1bad51f71f9e1090a76c9c90c960fc11aa95f4b1f651bb9e2ba0f  w3chain.sh
```

## 2. どの器がどの数を出したか（seed を含む）
| 器 | seed | 反復 | 出力 | 報告された数 |
|---|---|---|---|---|
| w3gate.py | 8901 | size 300 / power 150・perm 200 | w3gate.out | size 0.010±0.011 / 0.007±0.009 / 0.013±0.013 / 0.003±0.007、**power 1.000（π=100% / 80%）** |
| w3size.py | 24601 | 1,200 | w3size.out | s7T3 unif 0.0108±0.0059 ほか（判定不能と読んだ回） |
| w3gate2.py | 777001 | 5,000・L=5 | w3gate2.out | hat 0.0052 / 0.0060 / 0.0078 / 0.0074、CP 上界 0.0080 / 0.0089 / 0.0111 / 0.0106 |
| w3fresh.py | **20260825**（gate2 との差分は seed 行と見出し行の 2 行のみ） | 5,000・L=5 | w3fresh.out | hat 0.0072 / 0.0072 / 0.0068 / 0.0084、CP 上界 0.0104 / 0.0104 / 0.0099 / 0.0118 |
| w3L.py | 1357 | 400 | w3L.out | L ∈ {5,10,20} の size と minp 中央（L=20 は size 0.0000 だが minp 中央 0.0547〜0.0746 = **vacuous**） |
| w3chain.sh | — | — | — | w3size.out の「完了」を待って w3L.py を起動するだけの連結（gate2 → fresh は連結していない） |

## 3. ★枠（frame）— ここで 1 段 落ちていました★
- **hat** = 経験 size の**点推定**（棄却率）。
- **U** = **Clopper-Pearson 片側上界**（Bonferroni 4 config ゆえ conf = 0.9875）。#847-C で確定した
  非劣性 gate（H0: p ≥ α+Δ, Δ=0.005）の判定量で、**U ≤ 0.015 なら合格**。
- ★boss1 が #849-C / #850-C で PRESIDENT・worker へ中継した「0.0080 / 0.0089 / 0.0111 / 0.0106」
  「0.0104 / 0.0104 / 0.0099 / 0.0118」は **U 列であって size（rate）ではありません**★。
  枠を添えずに数だけ渡したのは boss1 の落ち度（memory: 数値は枠を添えて書く）。
- ∴ codex の逐語「reported rates include 0.0111, 0.0106, 0.0104, and 0.0118」は、
  **boss1 が渡した label に基づく読み**であり、**この 4 数は rate ではなく上界**です。
- ★実際の点推定（w3gate2.out / w3fresh.out を直読）★:
  gate2 = 0.0052 / 0.0060 / 0.0078 / 0.0074、fresh = 0.0072 / 0.0072 / 0.0068 / 0.0084
  ⇒ **8 config すべて 0.01 未満**。「実測が 0.01 を 4 config とも超過」は**誤り**。

## 4. それでも残る codex の指摘（3 点は不変で有効）
1. **判定規則そのものは途中で変わった** — 初期の worker3 規則「size + MC ≤ 0.01」→ #847-C で
   「非劣性・CP 上界 ≤ 0.015（Δ=0.005）」。★但し時系列は #847-C 02:23 → gate2 02:30 → fresh 02:40 で、
   **バーの変更は当該 2 回の走行より前**★（∴「別途 preregister されない限り post-hoc」という
   条件節は、この 2 回に関しては満たされている。格 = 時刻による事実。判断は codex に委ねる）。
2. **fresh seed は Monte Carlo 再現性の確認**であって model 誤設定への頑健性ではない。
   exchangeability の破綻は audit 自身が認めている（sim は sim 内の null しか救えない）。
3. **power 1.000 は sim の仮定と効果量の下**での power であり、一般の非空虚性ではない。

## 5. 走らせ直す人へ
- 依存 = numpy のみ（scipy 非依存。二項 CDF と Clopper-Pearson は w3gate2.py 内に自前実装）。
- 同じ seed で同じ数が出るはず（未検証 = **boss1 は走らせていません**）。
- ★park 中の不変（run 0 本 / compile 0）に触れるため、走らせるには PRESIDENT の GO が要ります★。
