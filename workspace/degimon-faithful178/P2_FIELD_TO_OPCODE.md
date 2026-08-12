# field → 容疑 opcode 帰属表

**出所**: worker1 §259.3（既存同定の再編成。新規測定なし）。boss1 が共有 repo に収載。
**目的**: 打ち切り条件 ①「**説明不能な**状態遷移差 0」の**説明不能**を減らす。
**実体の場所**: `~/Documents/Claude-Code-Communication/workspace/degimon-faithful178/`。
⚠ `degimon_world_remake` 側にも**同名の空 dir** があり、worker2 が最初そちらを探して見つけられなかった。**repo 名を添えて配ること**。

> 差が出たとき「どの opcode 由来か」を言えなければ**説明不能のまま**。
> この表を引けば「説明不能」が「**この opcode が未実装だから**」に変わる。

**使い方**: 差が出た field を引く → 容疑 opcode 集合 → その opcode の実装状況（backlog 33 種）と突合。

---

| vmtrace の field | 動かす opcode（**容疑集合**） | 出所 |
|---|---|---|
| `pc` | **全 opcode** | — |
| `base` (`0x8013E140`) | `0x14` `0x17` (`0x800F0988`) / `0xFB`(deferred) | §243 / §226 |
| `entry` (`0x8013E138`) | `0x14` `0x17` (`0x800F0988` 内 `sh r17`) | §243.1 |
| **`fb_entry`** (`0x8013E136`) | **`0xFB` のみ**（operand1） | §225.2 |
| `depth` (`0x8013E12A`) | **push** = `0x13` `0x14`(tag1) / `0xFB`(tag3) / `0x4B` `0x7B` `0x58` `0x66`(tag4)<br>**pop** = `0x15` `0xFE` `0xFF` | §160 / §244 |
| `pending` (`0x8013E150`) | `0x10`(`0x800F41EC`) / `0x1A`(**renderer `0x800F4BC4`**) / `0x4A`(`0x800ED54C`) / `0x67`(`0x800EE9A4`) / **`0xFF` = VM 退出後処理** / **`0x64` = 下記**（11 site） | §255 / §260 / worker2 全数列挙 46 site |
| `stop` (`0x8013E15C`) | **→1**: `0x800EF4BC`(`0xFE` 経路) / **`0x800F08A8` = band 外 opcode 全部** / `0x800F2F88`<br>**→0**: `0x800F0208`(init) / **`0x800F317C`(slot 条件つき)** | §233 / §235 / §248 |
| `bank_ptr` (`0x8013E120`) | **VM session init のみ**（opcode 由来 **なし**） | §236.9 |
| **`FLAG_*`** (`0x80163879`) | **書き** = `0x1C`(SET) / `0x1D`(CLEAR)<br>**読み** = `0x19` の mode `0x00` | shipped comment + §251.2 |
| **`VAR_*`** (`0x801638DD`) | **書き** = `0x1E` `0x1F` `0x20` / `0x22` `0x25` `0x3F` `0x7B`(`0x800F0CD0`) / `0x2A` `0x2B`(金)<br>**`var[0]`** = VM 退出後処理<br>**読み** = `0x19` の mode `0x08` | §232.4 / §251 |
| `STACK_BASE` (`0x801639E0`) | 上記 push / pop opcode の record（+0 戻り PC / +4 entry / +6 tag / +7 section） | §157 / §160 |
| `pad_*` | **VM 外**（opcode 由来 なし） | vmtrace |
| `WIN_*` (`0x801640B8`) | **slot0-3 のみ**: `0x800F31F4` 経由 = **`0x27`(slot 単位)** / VM 退出後処理 `0x800F3114`(6 slot loop)<br>**`win[4]` / `win[5]` は窓ではない** — 別配列 B(`0x8016419C`) の B[0] の内側。**書き手 `0x800F1CD4`(件数+1) = opcode 由来なし** | §235.1 / §237 / **worker2 PBR_SLOT4_ALIAS** |

---

## 限定（worker1 が明記、そのまま保持）

1. **「容疑集合」であって確定ではない** — 同じ field を複数 opcode が動かす
2. ~~`0x64` の pending 書き site は個別に同定していない~~ → **解消**（§260、下記）
3. `0x2A` / `0x2B` の金 counter (`gp-0x6b78` = `0x8013E294`) は**出力されていない** —
   ただし **vmtrace の read 範囲(`0x8013E100`+`0x200`)の中にある**（worker2 訂正）。
   ∴ 障害は read コストではなく **vmtrace の sha 凍結**（v4 / v5 が流通中）。`FIELDS` に 1 行足すだけで済むが、**既存 run からは復元できない**
4. **`win[4]` / `win[5]` を引かないこと** — 窓ではない（上表参照）。引くと `0x27` を追って**何も見つからない**

## `pending = 0x64` の書き手（§260、限定 2 の解消）

worker1 が 11 site を containment で分類（**boss1 が中継した「8 site」は誤り。正しくは 11**）:

| containment | site 数 | 意味 |
|---|---|---|
| handler `0x800EDEDC` = **opcode `0x64`** | **6** | opcode 由来 |
| **CHOICE / menu cluster**（§236 / §238） | 3 | band handler の外 |
| 別 subsystem（未同定） | 2 | band handler の外 |

### 「実装済だが型が違う」3 例目

```
原盤 : 0x64 handler (0x800EDEDC) は pending = 0x64 を 6 経路で書く
remake: case OP_CASCADE(0x64) = StoryState(-0x6d90) の var-write のみ ⇒ pending を書かない
```

`pending != 0` なら **VM は何も実行せず返る**（§232.2）。
∴ **原盤は 0x64 の後 VM が止まり、remake は止まらない** = **挙動差の候補**。

**(462) により今は直さない。** ① が `pending` の差を指したら**即座に 0x64 に帰属できる**ことが成果。

| # | 例 | 状態 |
|---|---|---|
| 1 | `0x67`（実装済だが既定 OFF） | **既定 ON に修正済** |
| 2 | `0x14` / `0x17`（制御流のアーキ置換） | **意図的 ⇒ 記録のみ** |
| 3 | **`0x64`（pending を書かない）** | **未判定** |

## 関連する現在地（2026-08-12）

**打ち切り条件は 4 本**（PRESIDENT #105 (526)）— ② は完了条件から外れ、**継続計器 / backlog** に格下げ。

- ①『代表シナリオで**説明不能な**状態遷移差 0』/ ③『重要境界に自動回帰テスト』
- ④『**未分類かつ実行時到達が 0**』/ ⑤『連続 2 回のプレイ検証で新規差分なし』

**VM 単体の実装は完了**（PRESIDENT (527)）。backlog = 到達した未対応 **33 種**:

| | 種数 | 意味 |
|---|---|---|
| 実装可 | **0** | VM 内部 state だけで実装できるものは尽きた |
| semantics 未揃い | 5 | 読み元 / 変換表 / 型表が未同定（0x22 0x25 0x3F 0x7B 0x4A） |
| 保留 | 11 | **remake に書き先が無い**（entity / gfx / record table stride12） |
| 判らない | 17 | 1 hop では判定不能 |

**別枠**: band 外 2 種（EXE も停止 = 実装対象外）/ 0x0B データ由来 1 種（`0x6B`、target されない section）

∴ **差が出たら、この表で容疑 opcode を引き、backlog のどの欄にいるかを見る**。
「保留」なら書き先の新設が要る、「判らない」なら 2 hop 目が要る、と**次の一手が決まる**。
