# ★封緘★ cut178 の 0x4C / 0x4D の slot（PRESIDENT 側の値・worker1 の報告前に固定）

2026-09-13。**worker1 への dispatch（boss1 便 008）と同じ問いに対する私の答えを、照合前に封緘する**。
bias を避けるため **boss1 には数を渡していない**。worker1 の報告が出た時点で照合する。

**枠** = `entry178 = DG.SCN[0x82000..0x83800)` / `sha256 4d776b2c…5e5b` ／ pc は `entry.Raw` 内 absolute。
**operand 枠（handler 直読で確定）**:
- `0x4C` = `jal 0x800F0FF0`（PC+1 ＋ byte 2 本）⇒ `[4C][skip][b1=id][b2]` ⇒ **id = raw[pc+2]**
- `0x4D` = `jal 0x800F0EDC`(byte) ＋ `jal 0x800F1620`(s16) ⇒ `[4D][id][s16]` ⇒ **id = raw[pc+1]**（**skip byte 無し**）
- slot = `f_800F50A8(id)`: `0xFD`→0 / `0xFC`→1 / else = entity table 走査（**実行時依存**）／不一致 `0xFF` で **bail**

## op 0x4C — 母数 10/10 件（全数）

| pc | 生 byte | id | slot |
|---|---|---|---|
| 0x26 | 4C 00 0A FD | 0x0A | 実行時の entity table 依存（静的に決まらない） |
| 0x186 | 4C 00 FD 08 | 0xFD | slot 0（静的確定） |
| 0x206 | 4C 00 FD 0A | 0xFD | slot 0（静的確定） |
| 0x20E | 4C 00 FD 08 | 0xFD | slot 0（静的確定） |
| 0x326 | 4C 00 FD 0A | 0xFD | slot 0（静的確定） |
| 0x3E8 | 4C 00 FD 08 | 0xFD | slot 0（静的確定） |
| 0x5FA | 4C 00 08 FD | 0x08 | 実行時の entity table 依存（静的に決まらない） |
| 0x666 | 4C 00 FC FD | 0xFC | ★slot 1（静的確定）★ |
| 0x72E | 4C 00 FD 08 | 0xFD | slot 0（静的確定） |
| 0x91E | 4C 00 FC FD | 0xFC | ★slot 1（静的確定）★ |

- 実行時の entity table 依存（静的に決まらない） = **2 件**
- slot 0（静的確定） = **6 件**
- ★slot 1（静的確定）★ = **2 件**

## op 0x4D — 母数 4/4 件（全数）

| pc | 生 byte | id | slot |
|---|---|---|---|
| 0x22 | 4D FD 00 08 | 0xFD | slot 0（静的確定） |
| 0x552 | 4D 08 40 06 | 0x08 | 実行時の entity table 依存（静的に決まらない） |
| 0x65A | 4D FD 00 00 | 0xFD | slot 0（静的確定） |
| 0x12BA | 4D FD 00 00 | 0xFD | slot 0（静的確定） |

- slot 0（静的確定） = **3 件**
- 実行時の entity table 依存（静的に決まらない） = **1 件**

