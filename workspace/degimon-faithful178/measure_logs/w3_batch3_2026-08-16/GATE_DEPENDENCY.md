# ★gate の 依存関係 列★（worker3 / #477-C (5)）— ★値の 出所を 各行に 添えます★

★★なぜ この列が 要るか★★ = ★今回の 事故が ★まさに この列が 無かったために★ 起きました★
= ★`DEGIMON_VISE_VILLAGE=1` だけでは ★1 bit も 動かない★★（★早期 return★）。

★値は 推測では ありません★ = ★早期 return と 読取順を code で 確かめて 入れました★。
★tree★ = `degimon_world_remake-integ`（`track/measure-fade-tile`）

| gate | 単独で 効くか | 何と 一緒に 要るか | 出所（file:行） |
|---|---|---|---|
| ★`VISE_AVATAR_MODE`★ | ★★効く（既定 ON）★★ | — / 退路 `=0` | `ViseAvatar/ViseAvatarBootstrap.cs:19-27` |
| ★`DEGIMON_VISE_SHOT`★ | 効く | — （★`ViseAvatarBootstrap` と `ViseNpcBootstrap` の ★両方★ が 読みます★） | `ViseAvatarBootstrap.cs:20` / `ViseNpcBootstrap.cs:20` |
| ★★`DEGIMON_VISE_VILLAGE`★★ | ★★★効かない★★★ | ★★`VISE_NPC_MODE` / `DEGIMON_VISE_SHOT` / `DEGIMON_VISE_GALLERY` の ★どれか 1 つ★ が 要る★★ | ★早期 return = `ViseNpcBootstrap.cs:19-23`★ ／ village を 読むのは ★その後の `:36`★ |
| `DEGIMON_VISE_GALLERY` | 効く | — | `ViseNpcBootstrap.cs:21-23` |
| `VISE_NPC_MODE` | 効く（Runner 生成） | ★marker 差替まで 至るには ＋`VISE_NPC_PREFAB` ＋`VISE_NPC_SCRIPT`★ | `ViseNpcBootstrap.cs:19` / 差替条件 = `:137`（`anchor != null && prefabPath != ""`） |
| ★`DEGIMON_FIELD_MODELS`★ | ★効く★ | — | `Scripts/Field/EntityPlacer.cs:165` |
| ★`DEGIMON_TILE_5179`★ | ★効く（既定 ON）★ | 退路 `=0` | `Flow/TileBand5179.cs:25` |
| ★`DEGIMON_MAP_LOADER`★ | ★効く（既定 ON）★ | 退路 `=0` | `Flow/MapLoaderBinding.cs:34` |
| ★`DEGIMON_WARP_EMIT`★ | ★効く（既定 ON）★ | 退路 `=0` | `Dialogue/DialogueRuntime.cs:628` |
| ★`DEGIMON_SCENE_DRIVER`★ | 効く（既定 OFF） | — | `Dialogue/DialogueRuntime.cs:631` |
| ★`DEGIMON_SCENE_WIRE`★ | ★★単独では 無意味★★ | ★`SCENE_DRIVER` が 要る★ | 依存の 宣言 = `DialogueRuntime.cs:660`（`_sceneWire && !_sceneDriver` で 警告） |
| ★`DEGIMON_SCENE_AUDIO`★ | ★★単独では 無意味★★ | ★`SCENE_WIRE`（∴ `SCENE_DRIVER` も）が 要る★ | 依存の 宣言 = `DialogueRuntime.cs:664` |
| `DEGIMON_SCENE_AUDIO_EXERCISE` | 効く | ★但し 実 game path は 通しません★（asset 検証のみ） | `Scripts/Audio/SceneAudioExercise.cs:23` ／ 自己申告 = 同 file の START log |

## ★この表が 見ていない こと（母数の 申告）★
1. ★★網羅では ありません★★ = ★本便までに 私が 実際に 触った gate だけ★
　（★worker2 が「(ii) 57 件は 精査していない」と 申告済★ = ★残りは 未調査★）
2. ★「効く」= ★その gate の 経路に 入る★ という 意味★ で ★画面/音に 出るか は 別★
　（例: `VISE_VILLAGE` は 座標が twna01 由来ゆえ ★他 map では 画角外★）
3. ★依存は ★code の 宣言★ と ★私の 実測★ の 両方から★:
　・`SCENE_*` の 依存 = ★code の 宣言★（★実測では 3 つ ON でも 鳴らなかった★ = #461-C）
　・`VISE_VILLAGE` の 依存 = ★実測★（`x_c` = SHOT も MODE も 無しで ★village place 0 行★）
