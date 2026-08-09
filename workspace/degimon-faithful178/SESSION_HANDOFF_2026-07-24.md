# SESSION HANDOFF 2026-07-24 (boss1 実物確認版)

PRESIDENT依頼により、boss1 が実git/実file/実sha を直接確認(cited値でなく実read)して作成。
検証時刻=2026-07-24。全 sha は boss1 が `sha256sum`/`git rev-parse` で実採取。

---

## 1. ground truth (実git確認済)

### repo: degimon_world_remake (remote: https://github.com/revivals47/degimon_world_remake.git)

| 対象 | 実sha | 検証 |
|------|-------|------|
| **local main** | `7a87fba1ed32e56ef81ec2b54d16787ca62c8b4a` | `git rev-parse main` + worktree list authoritative。commit題「G1 land: 0x1A 可変長 / 0x75=12 / 0x55=8 + cutscene gate hardening」 |
| **remote origin/main** | `174afa92e10c578da7c9a1d1cb06c73c9ea30c1f` | PR #1 (trackF1B/event-oracle) merge, 2026-07-22 01:02 |
| **viseavatar/boys-poc** | `df7838a28e8e461671bd163855ad9d4caa71a7a1` | push済確認(`origin/viseavatar/boys-poc` が df7838a 含む) |
| **viseavatar/phase2-npc (現worktree HEAD)** | `df7838a…`(== boys-poc、**phase2 commitゼロ**) | 全 phase2 作業=**未commit**(下記) |

**★重要な訂正(measure-first catch)★**: PRESIDENT依頼文の「main=174afa9」は **remote origin/main** を指す。**local main は 7a87fba** で、両者は **diverge している**(`git merge-base --is-ancestor` 双方向 false=相互に非ancestor)。remote は PR#1 merge を含むが local main 7a87fba は含まず、local main は remote に無い commit を持つ。→ **将来 push/merge 時に divergence 解消が必要**。boss1 は自律範囲で reconcile しない(push=user専権)。

### worktree構成 (git worktree list 実採取、主要のみ)
- `degimon_world_remake` = 7a87fba [main] ← 共有本体、非改変厳守
- `degimon_world_remake-viseavatar` = df7838a [viseavatar/phase2-npc] ← **本session作業treeここ**
- 他多数(e152a/b/c, f1a/b/c, o2, sp3系, trackA3d/w, trackF/S/W 等)= 別arc、本handoff対象外

### phase2 worktree の未commit作業 (git status --porcelain = 307 entries)
- `M unity/Assets/ViseAvatar/ViseAvatarController.cs` = **boy modelScale 0.2→1.03 fix**(実grep確認: `public float modelScale = 1.03f;`、df7838a から 6 insert/3 delete、**未commit**)
- `?? unity/Assets/ViseAvatar/{AGUM,AIRD,…}/` + `?? unity/Assets/Resources/ViseNpc/` = 136 distinct model の prefab/asset 群(untracked、**未commit**)
- **∴ 136-model + scale fix の全成果は untracked/modified で worktree 内に存在、commit も push もしていない。main 非改変・push 未実施は厳守されている。**

### vise 資産 (実path確認)
- root=`/home/ken/Desktop/vise`(存在確認OK)
- 例: `/home/ken/Desktop/vise/unity_remake/Assets/Models/Digimon/BOYS.glb`(存在確認OK)
- 178種 .fbx+.glb+anim、DW1ModelConverter pipeline(game TMD由来=canonical保証)

---

## 2. 完了arc (本session、user PASS 済のものは凍結)

| arc | 内容 | 状態 |
|-----|------|------|
| scene audio | scene-switch音=FAALL.VHB per-scene bank+SEQ offset table、原盤capture | **main merge済**(別arc、参考) |
| avatar phase1 | BOYS 1体 3D化 PoC、native scale確定 | **push済**(boys-poc df7838a、user視覚gate PASS) |
| 2a TOKO | Tokomon単体3D化、scale=0.67x boy裁定 | **user PASS**(「だいたい同じぐらいのサイズ」) |
| camera-fidelity | 真因=boy modelScale が debunk値 0.2 出荷bug→**1.03 fix** | **user PASS**(実測~2%)。fix は phase2 worktree に**未commit**存在 |
| 2c-α 村3体 | twna01村 ユラモン/トコモン/タネモン 3D化 | **user gate PASS**「正しいです。全員後ろ向きなのが気になりますが正しい」。色fix(灰青→emission floor)+facing含む |

---

## 3. 自律成果 (user不在中、boss1 gate済・user視覚gate待ち=queue)

- **136 distinct-appearance model 3D化完成**: 124 unique base + 12 variant new-look。
  - 43 変種 = **sha一致(texture同一=視覚複製)ゆえ不生成のhonest裁定**(worker3 sha実比較で峻別、padding回避=user「細かすぎ」忌避準拠)。
  - 全9 batch を boss1直視gate PASS(全fidelity次元照合、灰青washout・破損混入ゼロ)。
- review package (workspace/degimon-faithful178/、実sha):
  | file | sha256(先頭) |
  |------|------|
  | USER_REVIEW_QUEUE.md | `7ef84eee4c1f` |
  | HONEST_GAP_LEDGER.md | `9fcf11897687` |
  | gallery_INDEX_136models.png | `73be582f7eeb` |
  | WATCHPOINT_gdb_procedure.md | `4b435bf21b50` |
  - (注: gallery個別batch sha は USER_REVIEW_QUEUE.md 内表に集約済)

---

## 4. user復帰時 gated (自律不可、user-session必須=実測確定)

- **(b) placement loader RE + (c) faithful scale source** = 両方 DuckStation write-watchpoint(entity array 0x80147358 / scale適用site)で解消。
- feasibility 実測: GDB server 実在するが **headless :1 で DuckStation emulation 走行不能→port 未listen→自律不可**(worker3 実測確定)。
- ∴ **user が real display で DuckStation(EnableGDBServer=true)+game走行** させれば、準備済 **WATCHPOINT_gdb_procedure.md**(gdb watch→continue→info reg pc→bt)で非対話 trap PC 取得可。→ loader PC → worker1 即RE / scale適用site → 完全faithful scale。
- 同枠: 他map roster/facing/species = savestate 待ち(生接地=twna01+variant のみ)。

---

## 5. user判断待ち (review queue + 節目)

優先順(USER_REVIEW_QUEUE.md 準拠):
1. **facing村**(village_faithful_facing.png `732a630ec3c6`)= 前回queue先頭。★**YURA facing が正面か要確認**(未確証、下記gap)★。
2. **gallery 136 distinct**(gallery_INDEX_136models.png `73be582f7eeb`、9 batch一望)= 灰青/破損混入無しか。
3. **HONEST_GAP_LEDGER** = 数値正確性(scale 93% interim 許容か、43不生成裁定妥当か)。
4. **watchpoint session**(user操作、placement/scale unblock)。
その他: **push 判断**(boys-poc land後の要否、local/remote main divergence解消含む)/ **2b Partner** 着手可否 / **json loader off-by-one fix** 適用(loader RE後、実装前 PRESIDENT node上申必須=species poison回避)。

---

## 6. honest gap 3層 (HONEST_GAP_LEDGER.md 準拠、過大表示禁止)

- **A (asset/pipeline)** = 全種可(136 distinct 3D化実証、43=視覚複製で同pipeline即生成可)。
- **B (placement)** = 村3種=RAM authoritative(json bug非依存でbaked)/ **全map=loader RE 従属(gated)**。
- **C (scale)** = **native-uniform interim ~93%**(visible body 0.574/total 0.622 vs faithful 0.67)。**baby 0.67x のみ user 裁定確定**、他tier は interim。完全faithful=残~1.1x per-species factor(watchpoint/原盤frame従属)。
- 未確証(要 user 視覚): **TOKO glow(emission過剰か)** / **YURA facing(正面向きか)**。
- controller: 代表30種 full / bulk 106種 = model-only(anim controller skip、honest gap、placement時に該当種 full-build可)。

---

## 7. 規範 (全arc不変、boss1 厳守中)

- **push = user 専権(HOLD)** / **main 非改変** / **worktree 隔離** / **OFF-inert**(env-gate、default no-op、既存bit不変) / **完成claim = user 実視覚まで凍結** / **measure-first 生oracle**(自モデル導出値でなく raw bytes 独立decode) / **両次元gate**(position×appearance) / **prior-art継承**(vise=game-derived、再導出ゼロ) / **PRESIDENT memory = 提案制**(subagent直接編集禁止、agent-send提案)。

---

## 8. 保留memory訂正 (生bytes待ち、現値維持)

- **care table base = 0x8012E2C4(現値維持)**。worker1 提案 0x8013E2C4 は **算術矛盾**(lui 0x8013 + addiu -0x1d3c = 0x8012E2C4 で原値に戻る)ゆえ **却下、生 disasm bytes 裏取りまで現値 0x8012E2C4 を維持**。PRESIDENT の relay-hold が memory poison を阻止した案件。訂正版こそ未検証=raw-bytes gate 前は memory 反映しない。

---

**作成: boss1 (実物確認込み)。push HOLD / main 非改変 不変。本doc は次session/PRESIDENT/user復帰の単一起点。**
