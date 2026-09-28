# 07 の胸を灰で揃える（兄弟子・常連・島の船長）（worker3、boss1 06:48・PRESIDENT 06:5x。★script を書く前に登録★、2026-09-29 07:0x）

- 木: ikada-unity-track3、branch track3/bust-gray（master 466bd07f9ffc53a5e04a38c4a3048d8bbecea7f5 の上）。codex なし・PIL。
- 元の script（観測）: `tools/prep_art.py` の `bust_gray`（gen の絵 → alpha 254→255 → alpha の箱（>8）→ 上から 45% → `convert('LA')`（PIL の L = ITU-R 601-2 輝度）→ alpha を戻す → 512 に収める）。LICENSES.md:71 に「prep_art.py の再実行 = 0 px」。
- ★陽性対照（先に、観測）★: `bust_gray('mentor_try1')` を scratchpad に出して master の `mentor_bust_gray.png` と比べた = 512×342 同じ、差のある px 0 / 175,104。
- 04 の色の顔の元（観測、行の一致 = 平均誤差 0.00）: aniki_v1_crop = gen aniki_v1 の 15 行目から、joren_v1_crop = gen ★joren_r2_v1★ の 33 行目から（joren_v1 は誤差 15.05 = 別の人）、island_captain_v1_crop = gen island_captain_v1 の 66 行目から。

## 比（師匠の胸から、gen の座標、目盛り 20 px の拡大で読んだ = ±10 px）
| 人 | gen | 頭の上（alpha の箱） | 顎の下 | 頭の高さ | 顎の中心 x |
|---|---|---|---|---|---|
| 師匠 | mentor_try1 | 15 | 515 | 500 | 520 |
| 兄弟子 | aniki_v1 | 17 | 350 | 333 | 430 |
| 常連 | joren_r2_v1 | 38 | 450 | 412 | 548 |
| 島の船長 | island_captain_v1 | 59 | 488 | 429 | 450 |
- 師匠の胸の箱 = x 0〜1023・y 15〜699（= 高さ 684 = 頭の 1.368 倍、幅 1023 = 頭の 2.046 倍、顎の中心の左が幅の 0.508）。他の人 = 頭の高さの比 k = 頭/500 で同じ箱を縮め、上 = 頭の上、左 = 顎の中心 − 0.508 × 幅。灰と alpha と 512 は `bust_gray` と同じ（同じ関数の中で）。

## 予測（回す前）
- Q1 師匠に新しい関数（k=1）= 箱が (0,15,1023,699) で `mentor_bust_gray` と 0 px（★箱は作り方から同じになる = 恒等、灰・alpha・縮めの道の確かめだけ★）。
- Q2 3 人とも 512×342（箱の縦横比が師匠と同じ 1.496）。頭の高さ ÷ 画の高さ = 師匠と同じ 0.731（±10 px の読みの誤差 = ±0.02〜0.03）。
- Q3 独立の確かめ: portrait_crop_b16.py の crown（頭の幅の中央値、H の 3〜7%）の比 と 頭の高さの比 が ±15% で合う（帽子のつば・鉢巻の尾で crown は揺れる = 合わなければ その人の行を名指し）。
- Q4 回帰: mock と芦北の 07 は 師匠の胸のまま = 0 px（15/15）。変わるのは 兄弟子・常連・島の船長 が 07 の 1 人目の日だけ。撮り = 蒲江 G の 07 1 枚（兄弟子の灰の胸）。
