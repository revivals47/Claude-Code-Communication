# P2_REGION_LOADER_worker2 — ★region → loader の 255 行 表（★w3 が そのまま 使えます★）★

★受領★ = boss1 #675 ④ ／ ★測定時点★ = 2026-08-15 ／ ★emulator 非接触・EXE と DG.SCN の 直読のみ★
★成果物★ = ★`P2_REGION_LOADER_worker2.tsv`（header 1 行 ＋ ★region 255 行★）★

## ★0. 列の 意味★

| 列 | 中身 | 出所 |
|---|---|---|
| `region_id` | 0..254 | ★opcode `0xFB` の ★第 2 operand★★（entry 0 の 256 section・0..254 の 連番） |
| `map_name` | 名 | ★EXE 名表 `0x8013541C` / stride 16 / 255 slot★（台帳 §8.2） |
| `loader_entry` | DG.SCN の entry 番号 | ★opcode `0xFB` の ★第 1 operand★★ |
| `loader_sections` | その entry が 持つ section id の 全列 | DG.SCN の 先頭表 |
| `has_81_86` | 1 / 0 | ★script-warp 帯を 持つか★ |
| `sections_81_86` | 実在する id | 同上 |

## ★1. ★★検算（★出す 前に★）★★★

```
 ★region の 抜け = ★0 件★★（0..254 が 全部 `0xFB` header を 持つ）
 ★名が 空の slot = ★11 件 = 239-246 / 250-252★★ ⇒ ★★台帳 §8.2 の『空 slot 11 = index 239-246 / 250-252』と ★逐字 一致★★★
 ★相異なる loader = ★198★★ / ★loader が 81-86 を 持つ region = ★99 / 255★★
```

## ★2. ★★★off-by-one 検定（★台帳 (6-at) が 名指しで 警告して いる 型★）★★★★

```
 ★台帳 (6-at)★ = ★『名前表は op2 = region − 1 で索く』は ★worker1 の parse の 産物★・★原盤に off-by-one は 無い★★
 ⇒ ★∴ ★私も 同じ 罠に 掛かって いないか 検めました★★

 ★検定★ = ★★loader 149 を 持つ region は ★1 件だけ = 204 = TWNA01★★★
   ★remake の 唯一の 束縛 = ★twna01 → scenario 149★★ ⇒ ★★一致★★
   ★もし −1 ずれなら★ = ★TWNA01 は region 203 → loader ★148★★ ⇒ ★★remake の 149 と 食い違う★★
 ⇒ ★★∴ ★ずれは 在りません★★ = ★★∴ ★外部の 1 点が ★私の 索き方★ を 検定しました★★★
```

## ★3. ★★使い方（w3 向け）★★★

```
 ★★原盤の 軸★★ = ★`PlayMapSection(★loader_entry★, ★tile 値★)`★
 ★★remake の 現状★★ = ★`PlayMapSection(★現 map の registry id★, tile 値)`★
 ⇒ ★★∴ ★地図 → region_id さえ 決まれば ★loader_entry は この 表で 引けます★★★
 ★例★ = ★TWNB01 = region 180 → loader ★148★ → section ★81, 82★ を 持つ★
        （★remake の 180 引きでは entry 180 = [51, 77, 254] = 不在★）
```

## ★4. ★★決めない もの★★★

```
 ★★① ★地図名 → region_id の 対応★ は ★EXE 名表の 索き★ です★ = ★remake の 地図 file 名と 同一かは ★w3 が 検めて ください★★
 ★★② ★section 81-86 の 中身が 移動を 起こすか★★ = ★★未測定★★（★#670 ③ の GO が 生きて います★）
 ★★③ ★実行時に [gp-0x6cd6] が 本当に この 値を 持つか★★ = ★静的な 鎖まで★（★live は ④(b)★）
```
