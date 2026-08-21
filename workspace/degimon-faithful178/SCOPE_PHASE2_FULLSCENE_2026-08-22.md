# Phase 2 スコープ設計(2026-08-22・boss1)★実装 GO 前のスコーピングのみ★

★user 決定 = option3(parked full-scene = 実プレイ見える化)へ進む・但し RE-first でスコープを先に測る★。
★本 doc は着手前の設計★ = ★実装しない・game code 非触・run 最小・push HOLD★。

## 0. 測る 3 点(PRESIDENT の指定)
1. ★(B) の中身★ = stic02 / fact02 を landed Stages 表(tri-state gate 表 #584-588)に投入するのに何が要るか。
   = ★9 map で済ませた段別腕突合(worker2 の逐語表 × worker3 の harness)を この 2 map で★ / ★何腕・record 添字対応が取れるか★ / ★placer が実際に置くことの live 確認の要否★。
2. ★draw 順の正体とサイズ★ = 『0x24 だけ実装しても絵は揃わない・本体は draw 順』の ★draw 順が具体的に何を指すか★
   = ★entity 配置順か★ / ★2026-07-17 の field 視覚 bug(中間 loading map 可視化)= 0x47 deferred semantics と同じ問題か別 problem か★
   ⇒ ★推測せず実測で切り分け★ / ★S / M / L で見積もり★。
3. ★RE-first で実装前に反証すべき前提の列挙★ = ★何を測れば手戻りを防げるか★。

## 1. 割り当て(worktree 隔離 + 敵対検証)
| worker | 的 | tree | 触るもの |
|---|---|---|---|
| worker1 | ★(2) draw 順の正体(EXE / script 側)★ = ★『draw 順』が指す対象を候補集合として全列挙 → 実測で切り分け★ / 0x47 deferred semantics との異同 / S・M・L | p2w1 | ★読取のみ(EXE / DG.SCN / log)★ |
| worker2 | ★(1) の原盤側★ = ★stic02 / fact02 の段別腕を逐語 decode(何腕・slot 集合)★ / 9 map 手順との差 / ★record 添字対応が原盤側で取れるか★ / S・M・L | p2w2 | ★読取のみ(DG.SCN / 表)★ |
| worker3 | ★(1) の remake 側★ = ★harness で record 添字対応・placer が実際に置くことの live 確認の要否★ + ★(2) の field 側★ = ★中間 loading map 可視化の再現条件を器で確かめる★ / S・M・L | 自 tree(phase1 branch と別) | ★読取 + run 最小(申告制)★ |
・★敵対検証★ = ★(1) は worker2(原盤)× worker3(remake)の 2 系統・突合は boss1★ / ★(2) は worker1(静的)× worker3(live)の 2 系統★。
・★各人が (3)『反証すべき前提』を自分の担当について必ず書く★ = ★boss1 が統合して 1 本にする★。

## 2. 出し方(全員共通・前 phase の型を踏襲)
・★S / M / L の見積りには根拠を添える★(何 map・何腕・何 site・何 run・どの器)。★根拠のない S/M/L は受け取りません★。
・★census は 件数 + どこ + tool 名 + 打ち切り + 飽和★ / ★予測を撃つ前に固定・外れはそのまま★ / ★推論と観測を区別★ / ★次元差は畳まない★ / ★数だけ渡さない★。
・★run が要るなら独断で撃たず 1 便(token は boss1 が直列化)★。★game code は 1 行も触らない★。

## 3. 不変(引き継ぎ)
★push HOLD★ / ★game code は local commit まで(本 phase では触らない)★ / ★引き渡し build 不可触(dll 98ae1499…3032・userbuild HEAD 152885f9)★ / ★README(c661db4・196 行)不動★ / ★park 全維持★ / ★視覚忠実は user 実視覚まで凍結★ / ★env-gate 既定 OFF★。

## 4. この doc の後
★PRESIDENT が Phase 2 の受理条件を事前登録する★ = ★3 点の持ち帰り(S/M/L + 根拠 + 反証すべき前提 + 推奨着手順)を見てから★。★実装 GO は出ていません★。
