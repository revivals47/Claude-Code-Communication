# W3 #600-C — R1 夜 / R2 夜 の結果（`START_HOUR=2`）★control が動きました★

- 便: #600-C ／ 背景 job: 0 ／ ★run 2 本（夜）★・★env only・game code 非触・rebuild なし・push HOLD★
- 器 = `w3_588c/DegimonLive`（dll `e26201af…6352`・昼と同じ）／ ★引き渡し build `98ae1499…3032` は不動を再確認★
- 条件 = 昼と ★`DEGIMON_START_HOUR` だけが違います★（12 → 2）／ `-batchmode -nographics`（窓なし）／ 直列 ／ `timeout -k 5 90`
- census = ★before 0 / during 0 / after 0★ ／ ★窓 = 0★

---

## §0 答（2 行）

- ★① ★入替が起きました★★ ⇒ ★★= placer が実際に時刻を評価している証拠★★（★非入替なら「評価していない証拠」として同じ重さで出す約束でした★）
- ★② ★rec=4 は昼・夜の両方に居ます★★ ⇒ ★私の「slot 4 は時刻に依らない」の ★直接の検め★ が立ちました★

---

## §1 予測との照合（★撃つ前に固定した夜の予測★）

| | 予測 | 実測 | 判定 |
|---|---|---|---|
| ★P1n★ | stic02 = 合計 ★6★・rec ★{2,3,4,5,6,7}★・rec4 type ★109★ | ★合計 6・rec {2,3,4,5,6,7}・rec4 type=109★ | ★的中★ |
| ★P2n★ | fact02 = 合計 ★3★・rec ★{2,3,4}★・rec4 type ★149★ | ★合計 3・rec {2,3,4}・rec4 type=149★ | ★的中★ |
| ★落ちる側★ | ★rec 0,1★ | ★`time-gate hour=2 除外2体`（両 map）★ | ★的中★ |

## §2 ★★control が動いたことの示し方（2 値）★★

| map | 昼（hour=12） | 夜（hour=2） | 入替 |
|---|---|---|---|
| ★stic02★ | rec ★{0,1,4,5,6,7}★ | rec ★{2,3,4,5,6,7}★ | ★{0,1} ↔ {2,3} が入替★ |
| ★fact02★ | rec ★{0,1,4}★ | rec ★{2,3,4}★ | ★{0,1} ↔ {2,3} が入替★ |
| ★rec=4★ | ★在る（109 / 149）★ | ★在る（109 / 149）★ | ★両方に在る = 時刻に依らない★ |

- ⇒ ★★∴ ★『rec=4 が在る』は静的 fixture でも出ますが、★同じ器で条件を 1 つだけ変えて集合が入れ替わった★ ので、★placer が実際に時刻を読んで置いている★ と言えます★★★
- ★変えたのは `DEGIMON_START_HOUR` の 1 つだけ★（他の env・build・code はすべて同一）

## §3 ★おまけの突合（★生成表の注記 × live★・無料で付きました）★

| map | `TimeGatedPlacement.cs` の注記 | live 実測 | 判定 |
|---|---|---|---|
| stic02 | ★昼 species [67] / 夜 species [110]★ | ★昼 rec0,1 = 67★ / ★夜 rec2,3 = 110★ | ★一致★ |
| fact02 | ★昼 species [92] / 夜 species [87]★ | ★昼 rec0,1 = 92★ / ★夜 rec2,3 = 87★ | ★一致★ |

- ★4/4 一致★（★注記は生成器が書いたもの・live は placer が置いたもの ⇒ ★表の注記が実挙動と合っている★）
- ★言っていないこと★ = ★注記の species が原盤と合っているか★（★それは worker2 / worker1 の次元★・★私は表と live の一致しか見ていません★）

## §4 限定（昼と同じものを再掲・畳みません）

- ★これは「指定 map を開いた瞬間の placement」です★（★boot 後に topn01 へ warp するのは夜も同じ★）
- ★段（進行度 gate）は ★まだ 1 度も効いていません★★ = ★stic02 / fact02 は表に無い★ ⇒ ★ここで測ったのは ★時刻 gate★ であって ★段★ ではありません★（★次元を混ぜません★）
- ★視覚は判定していません★（★user 実視覚まで凍結★）／ ★fact02 の field-model 2/3 は昼と同じ★

## §5 証跡

- log = `W3_600C_R1n_stic02_night.md` / `W3_600C_R2n_fact02_night.md`（同梱）／ 昼は `W3_600C_R1_stic02_day.md` / `W3_600C_R2_fact02_day.md`
- ★run 4 本（昼 2 + 夜 2）すべて 窓なし・直列・timeout つき・census 0★／ 出力先 `/home/ken/Desktop/Digimon/w3_600c/`（★/tmp 配下でない★）
- ★game code 非触・rebuild なし・push なし・Phase 1 branch / 引き渡し build / README 不触★
