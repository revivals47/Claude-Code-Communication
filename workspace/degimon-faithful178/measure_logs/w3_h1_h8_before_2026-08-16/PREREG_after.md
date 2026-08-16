# ★after を撮る前の 事前登録★（worker3 / #441-C）2026-08-16

★これは run より前に commit しています★（★後から書けば 事前登録では ありません★）。
★worker1 の harness 側の結果（before PASS4/FAIL1 → after PASS5/FAIL0）は 読んでいます★。
★★合わせません。player build 側は 別物です★★。

## 1. ★本命の予想★

★★`WARP_DEST(0x4B menu-idx)` は before で h-8 が ★出ていない★（counter=20 到達 / rt# 不変）★★
⇒ ★∴ after でも ★出ない★ と予想します★ = ★★この経路では before/after で 差が出ないのが正しい★★。
⇒ ★差が出たら それは 修正の 副作用★。

| # | 予想（★撮る前★） |
|---|---|
| P1 | `[H8] ★★落ちた★★` は after でも ★0 件★ |
| P2 | counter は ★1→20 で 到達★（`[H8] ★到達★` が 1 件） |
| P3 | ★counter の 読み値 20 / tick 序数 21 は 不変★（= 閾値は 修正で 変わらない） |
| P4 | ★frame の 対応も 不変★（queue frame=14 / fire frame=34 / `[SCRIPTWARP] fire` の Δ(frame)=1） |
| P5 | (A) 自動 warp は ★Δ(frame)=1 のまま★（修正は 0x4B pending の 話で auto-warp を 通らない） |
| P6 | ★rt# の 通し番号は 3 のまま★（★hash の値は run 跨ぎで 無意味ゆえ 比べません★） |
| P7 | C / C2 は ★同じ理由（`UNSUPPORTED op=0x6C` entry=178 pc=0x1A）で 撮れない★ |
| P8 | ★印字 tag の集合は before と 同一★（= 観測器が 合流で 落ちていない） |

★P8 が 崩れたら 挙動の話を しません★ = ★★観測器が 落ちたと 判定します★★（boss1 #441-C item 2）。

## 2. ★★これが外れたら 前進（H4 を開けておく）★★

- ★P1 が 崩れる（after で 落ちた が 出る）★ ⇒ ★修正が この経路に 副作用を 持った★ = ★重要★
- ★P2/P3 が 崩れる★ ⇒ ★閾値か 駆動が 変わった★ ⇒ ★忠実性の 主張に 直接 効く★
- ★P7 の 理由が 変わる★ ⇒ ★★それ自体が 発見★★（別の場所で 止まるなら 到達性が 動いた）
- ★after にだけ 在る tag★ ⇒ ★修正が 足した印字★ ⇒ ★増えた分を 列挙して 申告する★

## 3. ★測り方（before と同じ枠に 揃える）★

★同じ 7 本・同じ呼び方・同じ env・同じ順★: ①ctl ②A ②b A' ③B ③b B' ④C ⑤C2
★反復対照（A/A' と B/B'）は after でも 撮る★。
★比べてよいのは★ = ★counter / tick 序数 / frame / Δ(frame) / rt# の 通し番号 / tag 集合★
★比べてはいけないもの★ = ★object-identity hash の 値★（`RuntimeHelpers.GetHashCode` は process 内限定）
