# H3-A x-check 材料 index (worker3 → worker1、2026-07-14)

worker1 の独立 x-check 用。★独立性 protocol★: 共有層 = 本 index の raw artifact / record schema
(instrument 発行元) / prereg §A-4 の verdict 定義。独立層 = parse・diff・集計の実装(worker3 の
h3_compare.py / h3_final_table.py は f1c branch にあるが、★自前実装が動くまで読まない★こと。
per-layer 独立性宣言を成果物に含めるのは H2 §B-2 と同じ様式)。

## 検証対象 claim(worker3 正式表 = f1c branch commit 9254978、claim 骨子のみ転記)
| addr | scope | claim |
|---|---|---|
| 0x80141D18 | A | INPUT(0xFF:50/80 STATE+RNG / 0x01:43/80 STATE+RNG / 0x80:25/80 STATE、first-div 全て (1,254,0)) |
| 0x80141D3A | A | INPUT(0xFF:25/80 STATE のみ。0x00/0x07 は 0/80) |
| 0x80141D42 | A | NOT-SHOWN 窓内(3 値 0/80)+ v00 窓外 read +162 witness |
| 0x80141D54 | A | INPUT(0x00:5/80 first=(47,82) / 0xFF:75/80 / 0x51:73/80 ★PC-PATH 含む全次元★) |
| 0x8013E0F0 | A | INPUT(0x00:14 / 0xFF:76 / 0x02:80、全次元) |
| 0x8013CDBC | A | INPUT(0x84:75/80 CTX+STATE+RNG / 0x00:★80/80 = 窓内 15+launch 未到達 65★) |
| 0x8013DF8C | A | INPUT(実効 0xFF:80・79 / 実効{1,254}:80、全次元) |
| 0x80161E7C | B | UNMEASURED-by-method(発散 0、squash 12/12 全値: per-entry DMA が first read 前に上書き) |
| 0x80161FBC | B | UNMEASURED-by-method(同、squash 8/8) |
| 0x801640A4 | B | NOT-SHOWN(実効 {0x00,0x93} のみ、0xFF は orig=0xFF で bump 縮退) |
| 0x8013E0FC | B(−ctl) | UNMEASURED-by-method(write-first store squash 17/17) |
| 0x80145E5A | A(+ctl) | INPUT(60/60、PC-LEN+RAW+STATE+DONE) |

## raw artifacts(/tmp/claude-1000/dgtrace/)
- hot 28 run: h3_{d18,d3a,d42,d54,e0f0,cdbc,df8c}_{ctl,vXX}.jsonl(+ 同名 _tally.jsonl = DGLOADS 集計、
  perturb record は本体のみ)。sweep = a0_sweep80.txt(sweep_no0.txt の 16 行毎 stride 80 entry)、
  IDLE=200、frames=60000、EARLY 注入。
- rare 16 run: h3_{e7c,fbc,a4,e0fc}_{ctl,vXX}.jsonl + ★同名 .stderr(LAUNCH frame anchor)★、
  DGDMA=1 同乗。sweep = h3_sweep_{tag}.txt(構築元 = h3_anchor.stderr/jsonl + h3_anchor2.stderr/jsonl、
  再導出可)。
- controls: h3_pc_{ctl,pert}.jsonl(positive、pt_sweep_04)/ h3_repl_r{1,2}.jsonl(replicate 対)。
- 原点 dump: h3_origs_dump.jsonl(baseline A の launch 時 12 addr 値)/ b_dump_225.jsonl。

## savestate scope(重要)
- baseline A = 旧 SLPS-01797_3.sav(04:38:59 の user save で消失)。hot 28 run + positive control が A。
  A 指紋 = 各 launch record の init.ram_inputs 内 3 block(0x8013CDB8/0x8013DF8C/0x8013E0F0)。
- baseline B = preserved_slot3_sav_20260714_0439.sav(sha256 4aa92a9f…、read-only)。rare 16 run +
  replicate 対 + anchor 2 run が B。★A/B を跨ぐ run 比較は不可★(640A4 の read entry 数すら変わる)。

## data 形状の事実(実装は自由、これらを外すと数字が合わない)
1. launch record の (req_scn,req_key) は run 内で重複し得る → 出現順の occurrence index で key する
   (過去に boss1 が (scn,key) 単独 key の silent collapse を検出済 = 既知 fact)。
2. ★launch record が無いのに entry_done が出る entry がある★(launch marker 未到達。cdbc_v00 で
   65/80)。ctl に在って pert に無い launch の扱いは §A-4 の DONE 次元で判定すること。
3. 注入の実効値は env でなく perturb/perturb_early record の new が真(nv==orig のとき XOR bump 規則。
   df8c_v01 の実効 = {1,254}、a4_vFF の実効 = 0x00 等)。readback==new が applied の定義。
4. frame 番号は run 間で非可換(boot 長 offset)。cross-run 比較には使わない。rare の per-launch
   bracket は同 run の .stderr LAUNCH 行で取る。
5. rare の survival は store_t だけでは不足 — ★dma_w(device→RAM range)が target byte を cover
   するかを見る★(E7C/FBC は store 0 件のまま DMA で上書きされる)。
6. dia field は DGLOADS/DGWATCH 併設 run でのみ有効(本 batch は全 run DGLOADS 併設済)。
7. seq / tmask / tcnt は host 側 artifact(guest 由来次元に入れない — H2 確立)。
8. 次元の型分離(PC-PATH vs PC-LEN、CTX、RAW は len 非 null 時のみ、STATE=var_w+flag_w+struct_w、
   RNG、DONE=(events,last_op,reason))は W60_PREREG/H2 §12 の確立様式(共有層)。

## query 窓口
実装せず答えられる事実 query は worker3 へ(boss1 経由)。verdict の数字自体は自前実装で出してから突合。
