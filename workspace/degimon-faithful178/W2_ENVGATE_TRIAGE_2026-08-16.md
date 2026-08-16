# W2 — env gate 89 の 3 分類（boss1 #460-B / worker2 / 2026-08-16）

★母数★ = ★89★（boss1 / PRESIDENT 実測）⇒ ★★私も 1 回 数え直しました = 89 で 一致★★
　（算法 = `git grep -hoE 'GetEnvironmentVariable\("[A-Z0-9_]+"\)' main -- '*.cs'` → sort -u ／ DEGIMON 84 / VISE 5）

★★30 分で 切りました★★ = ★★全部を 精査して いません★★（#460-B §4）
★★分類は ★中身を 見て★ 決めました★★（名前は 手掛かりに 使い、★必ず 使用箇所を 読みました★）

---

## 0. ★★成果物 = (i) の 一覧★★（★ON に すると ★何が 見える ように なるか★ を 1 行★）

| # | env | ★ON に すると 見える ように なる もの★ | 根拠（逐語） |
|---|---|---|---|
| ★1★ | ★★`DEGIMON_FIELD_MODELS`★★ | ★★field の NPC が ★sphere marker → vise 3D モデル★ に 変わる★★ | `EntityPlacer.cs:159-165` ★「DEGIMON_FIELD_MODELS=1 で NPC を sphere marker → vise 3Dモデルに差替(default OFF=従来 marker=OFF-inert)」★ |
| ★2★ | ★`DEGIMON_VISE_VILLAGE`★ | ★村（2c-α）に ★Yura / Toko / Tane が RAM 実測位置に 立つ★★ | `ViseNpcBootstrap.cs:36` ★「2c-α村render: Yura/Toko/Tane を正RAM位置に配置(json bug非依存override)」★ |
| ★3★ | ★`VISE_AVATAR_MODE`★ | ★主人公が ★白 Capsule → BOYS 3D モデル★ に 変わる★（★user 実視覚 PASS 済の 系★） | `ViseAvatarBootstrap.cs` Boot 入口 ／ `ViseAvatarController.cs:14` `BOYS.fbx` prefab |
| ★4★ | ★`VISE_NPC_MODE`★ | ★NPC 側 vise 系の 入口（gallery / village / beside の 親 switch）★ | `ViseNpcBootstrap.cs` Boot 入口 |
| ★5★ | ★`DEGIMON_SCENE_AUDIO`★ | ★★scene 切替時の ★音★（0x66 → SelectSceneVariant → SceneAudioManager）★★ | `V4PlaySectionHook.cs:53` ★「DRIVER/WIRE/AUDIO flags 未設定 = 0x66→scene-audio chain 不完全」★ |
| ★6★ | ★`DEGIMON_SCENE_DRIVER`★ | ★同上 chain の 前段（scene driver）★ = ★5 と 3 点 set★ | 同上 |
| ★7★ | ★`DEGIMON_SCENE_WIRE`★ | ★同上 chain の 配線★ = ★5 と 3 点 set★ | 同上 |
| ★8★ | ★`DEGIMON_ACTOR_REGISTRY`★ | ★cutscene で ★0x46 / 0x79 の actor 指定★ が効く（= 誰が 喋る/動くか）★ | `DialogueRuntime.cs` ★「③step4: 0x46/0x79 actor-registry opt-in」★ |
| ★9★ | ★`DEGIMON_OP67`★ | ★cutscene の ★0x67 frame-yield★ が効く（= 進行の 区切り方が 原盤側に）★ | `DialogueRuntime.cs` ★「③0x67 frame-yield opt-in」★ |
| ★10★ | ★`DEGIMON_FAITHFUL_BODYSTART`★ | ★台詞 本文の ★開始位置★ が 忠実側に 変わる★ | `DialogueData.cs` ★`FaithfulBodyStart`★（docs/HANDOFF §D 参照） |
| ★11★ | ★`DEGIMON_FAITHFUL_SCENARIO_ZERO`★ | ★scenario の 0 値 扱いが 忠実側に（0xFE resolve chain に 現れる）★ | `ScenarioVM.cs` ★「効果は runtime chain(0xFE resolve の opcode path)にのみ現れる」★ |
| ★12★ | ★`DEGIMON_GAMEPLAY_JUMPS`★ | ★選択肢/分岐が ★gameplay 挙動 mode★ で 動く（0x18 selector）★ | `TextboxView.cs` ★`GameplayBehavioralMode`★（RE_0x18_selector doc） |
| ★13★ | ★`DEGIMON_WARP_EMIT`★ | ★★0x4B の warp emit が ON = ★実際に 場面が 移動する★★★ | `DialogueRuntime.cs` ★「DEGIMON_WARP_EMIT=1 で 0x4B emit を ON」★ |
| ★14★ | ★`DEGIMON_NPC_SCENARIO`★ | ★map ごとに 走る NPC scenario が 変わる★ | `FieldManager.cs` `NpcScenarioFor(mapName)` |

★★(i) = 14 件★★

### ★★(i) の 中で 一番 大きいのは #1 です★★
`DEGIMON_FIELD_MODELS` は ★★NPC 136 種の 配線 そのもの★★ で、依存も 実在します:
・`data/species_model_codes.json` = ★実在（3,199 byte）★
・`Resources/ViseNpc/{code}_Avatar` = ★実在 136 件★（本日 別便で 実測）
⇒ ★★∴ 「NPC を 3D に する」は ★作る のでは なく ON に する★ 公算が 高い★★
⚠ ★★但し 私は 走らせて いません★★（#460-B §4）⇒ ★★動くかは worker3 の 実測待ち★★

### ★★#1 の code が 私の 別便の 発見を 裏書きして います★★
`EntityPlacer.cs:200` = ★「prefab 欠(★E-prefix boss 等★)= marker fallback」★
⇒ ★私は asset 側から「`E` は 変種だが ★用途は 判らない★」と 書きました★
⇒ ★★code の comment は ★boss★ と 言って います★★
⇒ ★★但し これは ★comment であって 測定では ありません★★★ ⇒ ★★用途は 依然 未確定★★ と しておきます

---

## 1. ★分類の 件数（★総数だけ 出しません★）★

| 分類 | 件数 |
|---|---|
| ★(i) 機能が 隠れて いる★ | ★★14★★ |
| ★(ii) test / 撮影 / debug の hook★ | ★57★ |
| ★(iii) 単なる parameter★ | ★16★ |
| ★(iv) 判定不能★ | ★2★ |
| ★計★ | ★89★ |

### ★(iv) 判定不能 = 2 件（★0 を 埋めません★）★
| env | ★なぜ 判らないか★ |
|---|---|
| `DEGIMON_SCROLL_QUADMOVE` | ★★既定 = 有効★★（`FieldManager.cs`「既定 = 有効(未設定/0 以外)」）⇒ ★★『gate の 後ろに 隠れて いる』の 逆★★ = ★OFF に する ための gate★ ⇒ ★(i)-(iii) の どれでも ない★ |
| `DEGIMON_SET_FLAGS` | ★flag を 立てる = ★機能を 出す★ とも ★test 用 state 注入★ とも 読めます★（`FieldState.cs`「worker1 gp2 の live 検証用」= ★自称は 検証★ だが ★効果は 進行★） |

### ★(iii) の 例（★値を 渡すだけ★）★
`DEGIMON_CLOCK_SCALE` / `DEGIMON_BOOT_MAP` / `DEGIMON_AUTOBOOT_SEC` / `DEGIMON_WALK_DIR` /
`DEGIMON_VISE_SCALE` / `DEGIMON_VISE_EMISSIVE` / `DEGIMON_VISE_GALLERY_{COLS,SP,H,BASEZ,FACING}` /
`DEGIMON_VISE_BOY_OFFSET` / `DEGIMON_VISE_FIELD_RT_{BACK,TARGET}` / `VISE_NPC_{PREFAB,SCALE,SCRIPT}` ほか

---

## 2. ★★PRESIDENT の 名指し 2 件の 決算★★

| 名指し | 彼の 推測 | ★実測★ |
|---|---|---|
| `DEGIMON_SCENE_AUDIO` | 「音が gate の 後ろなら 別次元が 丸ごと 隠れて いる」 | ★★(i) で 合って います★★ … ★但し boss1 が 見たのは `_EXERCISE` 付きの ★別 env★★。★★2 つは 別物です★★（下記） |
| `DEGIMON_VISE_VILLAGE` | 「村 = NPC と 重なる 可能性」 | ★★(i)・重なります★★ … `ViseNpcBootstrap` 内で ★NPC 配線と 同じ file★ |

### ★★重要 = 名前が 似た 2 つが 別物でした★★
| env | 分類 | 逐語 |
|---|---|---|
| ★`DEGIMON_SCENE_AUDIO`★ | ★★(i)★★ | `V4PlaySectionHook.cs:52` ★実 chain: PlaySection→walker→0x66→SelectSceneVariant→SceneAudioManager★ |
| ★`DEGIMON_SCENE_AUDIO_EXERCISE`★ | ★★(ii)★★ | `SceneAudioExercise.cs:32` ★「scope = asset 検証のみ / 0x66 到達は非検証」★（boss1 実測） |

⇒ ★★∴ boss1 の 「彼の 推測は 外れ」は ★`_EXERCISE` の 側については 正しい★★★
⇒ ★★但し ★`_EXERCISE` の 無い 側が 別に 存在し、そちらは (i) です★★★
⇒ ★★∴ 「推測は 外れ」で 閉じると ★本物の (i) を 1 件 落とします★★★
⇒ ★★= ★名前が 似た 2 つを 1 つと 数えた★ 形★★（★私の 側も 危なかった★ — ★2 つ在ると 気づいたのは 89 の 一覧を 出した から★）

---

## 3. ★★埋められなかった 穴（札つき）★★

| # | 穴 | 札 |
|---|---|---|
| 1 | ★★30 分で 切った ⇒ (ii) 57 件は ★名前と 1 行の 文脈★ でしか 見て いません★★ | ★材料★ … ★★(ii) の 中に (i) が 埋もれて いる 可能性は 残ります★★（★`_EXERCISE` の 件が まさに その 形★） |
| 2 | ★★1 つも 走らせて いません★★ | ★実機★（#460-B §4・worker3 の 担当） |
| 3 | ★(i) 14 件の うち ★依存を 確認したのは #1 だけ★★ | ★材料★ … ★他 13 件は ★ON で 動くか 未確認★★ |
| 4 | ★`E` の 用途★ = code comment は「boss」と 言うが ★測定では ない★ | ★材料★ |
| 5 | ★★分類の 境界は 私が 引きました★★（(i)/(ii) の 線） | ★原理★ … ★★『test 用と 自称するが 効果は 進行』が 在る★★（(iv) の `DEGIMON_SET_FLAGS`） |

---

## 4. ★(6-de-16) 申告★
★宣言★ = ★(i)+(ii)+(iii)+(iv) = 89★ ／ ★(i) ≤ 89★ ／ ★DEGIMON 84 + VISE 5 = 89★
★実測★ = ★14+57+16+2 = 89 ✔★ ／ ★14 ≤ 89 ✔★ ／ ★84+5 = 89 ✔★
⇒ ★★破れ 0 本★★
