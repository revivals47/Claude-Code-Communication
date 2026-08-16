# W2 — field-character ★材料の 棚卸し★（boss1 #451-B / worker2 / 2026-08-16）

★★実装案は 書きません★★（#451-B §4）／ ★★工数も 見積もりません★★ ／ ★変換 pipeline は 走らせて いません★

★★4 軸の 母数申告 (6-de-11)★★:
| 軸 | 本便 |
|---|---|
| ★どこで★ | ★`/home/ken/Desktop/vise`★（★現物★）＋ ★`degimon_world_remake-{integ,p2w2,viseavatar}`★（★器★） |
| ★★どこを★★ | ★★全深度★★（★maxdepth を 切って いません★） |
| ★何で★ | ★拡張子★（`find -type f` → 拡張子で 集計）＋ ★source 直読★ |
| ★どの単位で★ | ★file★（★行でも 塊でも ありません★） |
★計測時刻★ = ★2026-08-16 15:30★ ／ ★vise 総 file = 38,903★

---

## 1. ★★§1 の 1 問への 答え = ★3D model です。sprite では ありません★★★

★★推測では なく ★source 直読★ で 答えます★★

### ★根拠 ①（★converter の 入力★・最も 強い）★
`vise/DW1ModelConverter/src/main.cpp:68`:
```
std::filesystem::path modelPath = dataPath / std::format("CHDAT/MMD{}/{}.MMD", id / 30, entry.filename);
```
`vise/DW1ModelConverter/README.md`:
> ★A tool that converts Digimon models … into ★gltf★ files, complete with texture and ★animation★★
> ★Not every property of the original ★TMD files★ could be translated properly into gltf★

⇒ ★★入力 = 原盤 ISO の `CHDAT/MMD{n}/*.MMD`（★TMD を 内包★）／ 出力 = `gltf`★★
⇒ ★★∴ 原盤の field character は ★3D polygon model★ です★★

### ★根拠 ②（★remake 側の 器★）★
`integ/unity/Assets/ViseAvatar/ViseAvatarController.cs:14`:
> ★`BOYS.fbx` から 作った prefab（instance 化して visual 子に する）★
`integ/unity/Assets/ViseAvatar/ViseNpcBootstrap.cs:88`:
> `Resources.Load<GameObject>($"ViseNpc/{code}_Avatar")`

⇒ ★★remake は 既に ★prefab を Instantiate★ して います★★（★板 sprite を 貼って いません★）

### ★根拠 ③（★『sprite』の 語の 出所★）★
`FieldManager.cs` の 当該 comment は ★★白 Capsule placeholder の 段落の 中★★ に 在ります:
> `// sprite-exact は 新規 field-character RE 後の 別 arc(W1B §1b)。今は marker(sphere)と 形/色で 判別可能な placeholder。`

⇒ ★★∴ 「sprite」は ★placeholder を 置いた 時点の 語彙★★★ = ★★vise 3D 継承（phase1/2）より ★前★ の 文★★
⇒ ★★∴ 我々の doc が 現物に 対して stale★★（★boss1 の 危惧は 当たって います・但し 向きは 「doc が 古い」★）

### ★★行番号も stale でした（★申告★）★★
boss1 の 指定 = `FieldManager.cs:503`。★実測★:
| tree | `sprite-exact` の 行 |
|---|---|
| `degimon_world_remake`（共有） | ★470★ |
| `p2w2` | ★470★ |
| `p2w3` | ★501★ |
| ★`integ`★ | ★★507★★ |
| ★`viseavatar`★ | ★★★行が ありません★★★ |
⇒ ★★∴ ★3D 化を した tree では この 文 自体が 消えて います★★★ = ★★最強の 証拠★★

### ★★∴ §1 = 閉じます★★
> ★★field character は ★3D model★（MMD/TMD → gltf → glb → FBX → Unity prefab）★★
> ★★「sprite を 貼る」案は ★現物に 反します★★★
⚠ ★但し 私が 答えたのは ★形式★ です★ — ★★『どこまで 忠実か』は 別問題★★（§4 の 穴 参照）

---

## 2. ★★在庫（★3 列★・③ が 肝）★★

| # | 材料 | ① 在る/無い | ② 形式 | ★★③ 読む器が 在るか★★ |
|---|---|---|---|---|
| 1 | ★原盤 model★ | ★★在る = 178★★ `extracted/mmd/mmd0-5/` | `.MMD`（TMD 内包） | ★★在る = `DW1ModelConverter`★★（★C++・src 直読で 確認★）／ ★★但し ★build 済 binary は 見つかりません★★ |
| 2 | ★変換 出力★ | ★在る = 178★ `DW1ModelConverter/output/digimon/` | `.gltf` | ★在る = Unity / `glb_to_fbx.py`★ |
| 3 | ★gltf 総数★ | ★在る = 505★（内訳 下記） | `.gltf` | 同上 |
| 4 | ★glb★ | ★在る = 177★ | `.glb` | ★在る = `vise/unity_remake/tools/glb_to_fbx.py`★ |
| 5 | ★FBX★ | ★在る = 356★ | `.fbx` | ★★在る = Unity native import★★（★remake が 現に 使用中★） |
| 6 | ★prefab★ | ★在る = 356★ | `.prefab` | ★★在る = `ViseNpcBootstrap`（`Resources.Load`）★★ |
| 7 | ★Animator★ | ★在る = 356★ | `.controller` | ★在る = Unity Animator★ |
| 8 | ★anim clip★ | ★在る = 9,690★ | `.anim` | ★在る = Unity★ |
| 9 | ★texture★ | ★在る = 1,499★ | `.png` | ★在る = Unity★ |
| 10 | ★原盤 ISO★ | ★★在る★★ `cd_extracted/degimon01.iso` ＋ `degimon.bin` ＋ `.cue` | ISO / BIN | ★在る = converter の 入力に できる★ |
| 11 | ★`.tmd`★ | ★在る = ★4 のみ★★ | `.tmd` | ★★— ★主線では ありません★★★（下記） |
| 12 | ★`.obj`★ | ★在る = 32★ | `.obj` | ★在る（汎用）★ ／ ★★中間物★★ |

### ★★boss1 の 前提を 1 つ 訂正します★★
> boss1 = 「★現物 = vise に `.tmd`★」
★実測★ = ★`.tmd` は ★4 本だけ★★ / ★★pipeline の 入力は `.MMD`（178 本）★★
⇒ ★★∴ `.tmd` 4 本は ★主線では ありません★★★（★converter が 読むのは `.MMD`★）
⇒ ★★∴「材料が 薄い」も「`.tmd` が 現物」も ★どちらも 実測と 合いません★★★

### ★gltf 505 の 内訳（★数の 出所を 割ります★）★
| 場所 | 件数 |
|---|---|
| `DW1ModelConverter/output/digimon` | ★178★ |
| `unity_remake/Assets/Models/Digimon_gltf_backup` | ★178★ |
| `unity_remake/Assets/Models/Digimon/LOD0` / `LOD1` / `LOD4` | ★30 × 3 = 90★ |
| （残） | 59 |
⇒ ★★178 は ★2 重に 数えて います★（output と backup）★★ = ★★505 は ★相異なる model 数では ありません★★★

---

## 3. ★★③ の 列で ★止まっている 1 件★★★（= ★棚卸しを 計画に 変える 情報★）

★★`DW1ModelConverter` は ★source は 在るが build 済 binary が 見つかりません★★★
・★在る★ = `src/*.cpp`（12 file）／ `CMakeLists.txt` ／ `cmake/CPM.cmake` ／ `.github/workflows`
・★在る★ = ★`output/digimon/` に 178 件★ ⇒ ★★過去に ★実際に 走った★ 証拠★★
・★見つからない★ = ★実行 binary / build ディレクトリ★
⇒ ★★∴ ★「出力は 在る」が「今 再実行できるか は 未確認」★★★
⇒ ★★= memory の 規範「★在る と 使える は 別★」が ★ここに 当たります★★★
★閉じ方の 札★ = ★実機★（★`cmake` して build すれば 判ります・★本便では 走らせません★（#451-B §4））★

---

## 4. ★★埋められなかった 穴（★札つき★）★★

| # | 穴 | 札 |
|---|---|---|
| 1 | ★★178 model の うち ★どれが field character か★ は 分けて いません★★ … ★converter は 「Digimon models」を 全部 出します★ ／ ★field / battle / menu の 別は ★未確認★★ | ★材料★ … ★`CHDAT` の 構成 or remake 側の 使用実績で 分けられます★ |
| 2 | ★★『3D model である』は 答えたが『どこまで 忠実か』は 答えて いません★★ … ★scale / orientation / anim / texture の 忠実度は 別★ | ★実機★ … ★★過去に user 目視 PASS が 在ります（phase1 BOYS / phase2 NPC）が、★それは その 範囲だけ★★ |
| 3 | ★`fbx` / `prefab` / `controller` が ★356★ で 揃う 理由 = ★未説明★★（★178 の 2 倍★） | ★材料★ … ★★数が 合う ことを 「揃って いる」と 読まない★★（★2 倍の 出所を 見て いません★） |
| 4 | ★`.anim` 9,690 の 内訳 未確認★ | ★材料★ |
| 5 | ★★converter が 再実行できるか 未確認★★（build 済 binary 不明） | ★実機★（§3） |
| 6 | ★vise 資産の ★素性 tier★ を 本便では 引き直して いません★ | ★材料★ … ★memory = ★3D キャラは 「強い（継承価値 高）」★・★進行系は 弱い★★ |
| 7 | ★★私は ★remake 側の 現状描画★ を ★実物で 見て いません★★★（source を 読んだだけ） | ★★実機★★ … ★★user 実視覚 gate は この arc の 完成条件★★（#451-B §5） |

---

## 5. ★(6-de-16) 申告★
★宣言★ = ★MMD 178 = mmd0..5 の 和★ ／ ★output/digimon ≤ MMD 総数★ ／ ★相異なる model ≤ gltf 総数★
★実測★ = ★30+30+29+29+30+30 = 178 ✔★ ／ ★178 ≤ 178 ✔★ ／ ★178 ≤ 505 ✔★
⇒ ★★破れ 0 本★★

★★∴ 本便で 決まった こと = ★§1（形式）だけ★★★。★★実装案は 書いて いません★★。
