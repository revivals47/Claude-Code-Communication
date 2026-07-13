# H3 PREREG — 因果 sprint（live-in 候補 10 件の値指定注入 + DG.SCN 225 等価構築確認）

boss1 / 2026-07-13。**worker 着手前に commit 固定**（採点は結果到着後、閾値・予測は以後 1 バイトも動かさない）。
user 裁定 = 推奨順序（①因果 sprint → ②capture 仕様 → ③実装 → ④cutscene 検証）。**H3 = まだ測定 phase**。

## 0. 規範（不変条項）

- **game code 実装ゼロ**（③着手時に PRESIDENT 再承認があるまで。C# repo への追記も原則ゼロ — 下記 B-3 の escalation 条項のみ例外候補）。
- push ゼロ / frozen `09fde5a` 不触 / cutscene 不触 / 閾値 = `aba590e`（1 launch でも PC/STATE/RNG/DONE/struct のいずれかが変われば INPUT）不動。
- **N=9 は下限。N の更新は本 prereg の INPUT verdict によってのみ**（それ以外の経路での昇格禁止）。
- 完走 claim = 3 点規則（件数 + sentinel + pane）。verdict には which-dimension / which-values-tested を必ず添える。no silent caps。
- 様式は H2 で確立済のものをそのまま使う（新発明なし）: per-target ctl/pert pair（sweep 構成 bit 一致・env のみ差）/ first-divergence 規則 / 全 target DGWATCH 同乗 / EARLY 注入 + readback assert（偽 NOT-SHOWN 製造機 guard）/ prereg + positive control / 集合比較（per-addr diff）。

## A. 注入テスト（worker3）

### A-0. 前段: per-addr read 幅の実測（measure-first、幅は捏造しない）

10 addr それぞれの **VM read 幅**を既存 data（final_run / loadt channel）から抽出。無ければ短 DGLOADT run 1 本。
**注入幅 = 実測 read 幅**（0x8015Fxxx w=4 の教訓: 幅は次元、byte 仮定禁止）。幅不明のまま注入した場合、その verdict は無効。

### A-1. 対象・注入値・選定根拠（値は per-addr、幅確定後に byte 表現を確定）

| addr | 正体（実測） | 注入値 | 選定根拠 |
|---|---|---|---|
| `0x80141D18` | stat struct sub3 **bitfield**（fwpc `0x800A988C`、読み 217k/窓内 6,929） | `0x00` / `0xFF` / `0x01` / `0x80` | bitfield ゆえ**単一 bit 粒度**（全消し/全立て/端 bit 2 点）。0x19 stat term の gate を跨ぐ設計 |
| `0x80141D3A` | stat struct（`0x800AECA8` 系が書く） | `0x00` / `0xFF` / orig+1 | 境界 2 点 + 最小摂動（等値 gate 跨ぎ漏れ対策） |
| `0x80141D42` | 同上 | 同上 | 同上 |
| `0x80141D54` | stat struct（fwpc `0x800AB6AC`） | 同上 | 同上 |
| `0x8013E0F0` | 未同定（fwpc `0x800E9A40`、読み 126k） | `0x00` / `0xFF` / orig+1 | 構造未知 = 境界 + 最小摂動の標準 3 点 |
| `0x8013CDBC` | **readerB の ptr table 域**（`0x8013CDB4`） | **table 内の別 slot 実測値** / `0x00` | ★構造由来: pointer には「別の valid pointer」が最強の gate 値★。0x00 = null → DONE/crash class 許容（DONE 差も INPUT） |
| `0x8013DF8C` | 未同定（fwpc `0x800B047C`） | `0x00` / `0xFF` / orig+1 | 標準 3 点 |
| `0x80161E7C` | script buffer への CPU write 先 | **`0xFD`** / `0x00` / `0xFF` | ★構造由来 gate 値: `0x800AF6AC` は `==0xFD` で 0 に書換える = **0xFD が唯一の判定値**★。0xFF=terminal 系 boundary |
| `0x80161FBC` | 同上 | 同上 | 同上 |
| `0x801640A4` | **0x46/0x79 registry**（8 slot 登録 table、fwpc `0x800F15E0`） | `0x00` / `0xFF` / **別 slot の実測値** | registry には「実在する登録値」が構造由来 gate。0x00=空 slot 相当 |

### A-2. 対照（pipeline の健全性を先に証明）

- **positive control = `0x80145E5A` に 255 注入**（N=9 の既知 INPUT、CF reader `0x800F3064` beqz 反転）。
  **これが INPUT にならなければ pipeline 故障 = batch 全体を無効とし、verdict を 1 件も採らない**。
- **negative control = `0x8013E0FC`**（rbw=0 = write-first scratch と分類済）に標準 3 点。
  **INPUT になったら rbw 分類の方が誤り** = 分類 pipeline の監査 finding として扱う（都合の悪い方に倒す）。

### A-3. 同乗 instrument（すべて既存 channel、新規実装なし）

- **全 target DGWATCH**（②の教訓: struct 次元未計装の再発防止）。
- **DGSTORE rider**: stat struct 4 件 + `0x80161E7C`/`FBC` に。目的 = **「注入値が最初の VM read まで生存したか」の実測**
  （0B9 の教訓: 注入即上書きは no-flip でなく UNMEASURED）。
- **EARLY 注入 + readback assert**（launch-marker 時点の適用値を読み戻して assert。boot 上書きなら偽 NOT-SHOWN 製造機、③実証済の手順）。
- `0x80161E7C`/`FBC` の run では **writer `0x800BB940` の store 先集合を DGSTORE で記録**（(c) self-modify 同定の実測材料。掘るのは同定まで、fix はしない）。

### A-4. verdict の定義（外れ方の事前固定）

- **INPUT** = first-divergence launch で PC/STATE/RNG/DONE/struct のいずれかが差 ∧ readback PASS ∧ 注入値が first read まで生存。
- **NOT-SHOWN** = **試した全値**で差ゼロ ∧ readback PASS ∧ 生存確認 PASS。（= この値集合では示されなかった、の下限主張。非入力の証明ではない）
- **UNMEASURED-by-method** = 注入値が first read 前に上書きされた（DGSTORE evidence）。NOT-SHOWN と峻別、derived-maintained 候補として ② の model 側へ。
- **BLOCKED** = harness/次元の構造的限界（per-dim で宣言）。
- crash/hang = **DONE 次元の差 = INPUT**（ただし 3 値中 1 値でも正常完走があること。全値 crash なら BLOCKED[injection-fragile] として宣言）。

### A-5. 予測（boss1、ここで固定。worker3 は自分の予測を着手 ack 時に固定すること）

- **INPUT = 7 件**: `0x80141D18` / `0x80141D3A` / `0x80141D42` / `0x8013E0F0` / `0x8013CDBC` / `0x80161E7C` / `0x80161FBC`。
- NOT-SHOWN or UNMEASURED = 3 件: `0x80141D54` / `0x8013DF8C` / `0x801640A4`。
- 追加予測: stat struct のうち **`0x80141D18` は UNMEASURED-by-method に落ちる risk 最大**（wcount 13,434 = 高頻度書込）—
  rbw=1 ゆえ EARLY 注入なら first read に先行できる、に賭けて INPUT 側に置く。外れたらこの行が外れの記録。
- positive control = INPUT / negative control = NOT-SHOWN。

## B. DG.SCN 225 等価構築確認（worker2 主担、worker1 独立系）

**問い**: C# は `0x8015F788..` の boot 構築 offset table（DG.SCN entry offset、index 1..225、昇順）+ `0x80161788`（lhu、225 回）と
**等価な情報を、等価な消費経路で持つか**。（3 条件 standard: file 由来 ∧ C# が同 file から同 table を導出 ∧ reader = VM の offset 解決に対応する consumer）

### B-1. 原盤側の基準 table 抽出（worker2）

④ dump + DGLOADT + final_run の既存 capture から 225 word 値を抽出（**新 run 不要の見込み。不足時のみ短 run**）。
`0x80161788` の lhu の意味論は静的 RE で同定（reader pc `0x800F0A78` = GetSectionOffset 内、既知 RE と突合）。

### B-2. C# 側の導出値（worker2 と worker1 の 2 系統、独立層を宣言してから）

- **worker2**: `DialogueDatabase` の parse を source 直読 → **同 algorithm を外部 python で逐語再現**（C# repo に 1 行も足さない）→ 225 entry の offset/base 列を出力。
- **worker1**: **DG.SCN file bytes から直接**（C# source を見ずに）header/table 仕様で独立導出。
- ★per-layer 独立性の宣言必須★: 両者が共有する層（file 自体 / entry 数 225 の既知 fact）と独立な層（parse 実装）を成果物に明記。
- **既知 trap を事前登録**（一致/不一致の誤読防止）: (i) `BodyStart = 4 + word0` の +4 ずれ前科 (ii) entry 226 = EOF sentinel off-by-one (iii) entry index ≠ map id (iv) **一定の系統差（+1/+4 等）は「convention 差」として記録** — 自動 PASS/FAIL にしない（unit を両側で導出してから diff）。

### B-3. 判定

- **225/225 offset 等価 ∧ consumer 対応（C# の entry/section 解決関数 ↔ 原盤 reader）が立つ** → DG.SCN 225 = (b) へ復帰（保留解除）。
- 部分一致/不一致 → per-entry diff list + どの層の差か（file/algorithm/convention）を宣言して**保留維持**。
- C# の**実行時**挙動でしか確認できない差が出た場合のみ、read-only Editor dump tool の追加を **PRESIDENT に個別 escalate**（勝手に足さない）。

## C. 割当・順序

- **worker3**（f1c、instrument 単独所有）: A-0 → A 系 batch（emulator run は worker3 で serialize、他 worker は run を起動しない）。
- **worker2**（f1b）: B-1/B-2(自系)/B-3 起草 + `0x800BB940`/`0x800AF6AC` の static RE（read-only、(c) 同定材料）。
- **worker1**（f1a）: B-2(独立系) + worker3 verdict の全次元 comparator x-check（bit-exact 収束の確立役）。
- A と B は独立 = 並行。dispatch は **worker composer の user 手動クリア確認後**（それまで送信停止継続）。

## D. 採点（結果到着後にこの節の下へ追記。上の本文は不変）

（未記入 — 固着）
