# user 用 2 run（昼 / 夜）— MAYO00 の時刻分岐（worker3 / #553-C）

★★「完成」とは書きません★★ ／ ★これは ★見て頂くための run★ です★

## 1. 昼（12 時）

```
cd /tmp && DISPLAY=:1 \
DEGIMON_TIME_PLACEMENT=1 DEGIMON_START_HOUR=12 \
DEGIMON_FIELD_MODELS=1 VISE_AVATAR_MODE=on \
DEGIMON_INTRO_ENTRY=101 DEGIMON_BOOT_MAP=mayo00 DEGIMON_AUTOBOOT=1 \
DEGIMON_AUTOBOOT_SEC=25 DEGIMON_VISE_SHOTDIST=90 \
/tmp/claude-1000/-home-ken-Documents-Claude-Code-Communication/80ec2f42-6601-4a99-bac8-4f1b179013cb/scratchpad/build553/DegimonLive/DegimonLive.x86_64
```

## 2. 夜（22 時）

```
cd /tmp && DISPLAY=:1 \
DEGIMON_TIME_PLACEMENT=1 DEGIMON_START_HOUR=22 \
DEGIMON_FIELD_MODELS=1 VISE_AVATAR_MODE=on \
DEGIMON_INTRO_ENTRY=101 DEGIMON_BOOT_MAP=mayo00 DEGIMON_AUTOBOOT=1 \
DEGIMON_AUTOBOOT_SEC=25 DEGIMON_VISE_SHOTDIST=90 \
/tmp/claude-1000/-home-ken-Documents-Claude-Code-Communication/80ec2f42-6601-4a99-bac8-4f1b179013cb/scratchpad/build553/DegimonLive/DegimonLive.x86_64
```

## 3. ★期待される見え方（1 行）★

★★草地に 3 体 居ます。★中央左の 黄色い 1 体は 昼夜で 変わりません★。★右上寄りの 1 体★ と ★左下の 1 体★ の ★2 体だけが 入れ替わります★★

## 4. ★所要 / 終わり方★

- ★所要★ = ★約 25 秒★（`DEGIMON_AUTOBOOT_SEC=25`）
- ★終わり方★ = ★★自分で 閉じます★★（25 秒で 自動終了）。★途中で 止めるなら 窓を 閉じる か 端末で `Ctrl-C`★

## 5. ★見えづらい場合★

★`DEGIMON_VISE_SHOTDIST=90` を ★`40` に すると 寄ります★★（★但し 入れ替わる 2 体のうち ★1 体しか 画角に 入りません★）

## 6. ★私が 見ている もの（同 run の log）★

| 昼 12 時 | `type=3` / `type=83` / `type=83` |
| 夜 22 時 | `type=74` / `type=74` / `type=3` |
★log は ★species（`type=`）で 読んでください★★（`rec=` は 原盤 slot・`print_i=` は 印字添字）
