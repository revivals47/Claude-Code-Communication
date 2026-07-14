# capture 仕様 draft v0.1（boss1、2026-07-14 12:5x。PRESIDENT GO = H3 close 承認と同時）

## 0. 目的・scope・規範

- **目的**: C# remake が実機と同じ挙動入力を持つための「実機 RAM 値の供給方式」を per-addr で確定する。
  H3 close で挙動入力は名前と evidence 付きの有限集合になった — 本 spec はそれを**実装可能な仕様**に変換する。
- **scope**: PRESIDENT 指定 4 点 = (a) N(A)=12 + B witness の per-addr taxonomy 仕分け
  (b) D42 write-back witness = 第一級（POST 次元 capture 化） (c) E7C/FBC = DGDMA 同乗前提
  (d) 実装欠落台帳 7 件との依存鎖整合。
- **規範**: 本 phase = 文書作業のみ。★game code 実装ゼロは③（実装 phase、別途裁定）まで不変★。
  push ゼロ / frozen 不触 / cutscene 不触（凍結解除 = user 裁定）継続。
- **本 draft の新規実測**: なし（新規 run ゼロ）。ただし §2 の writer profile は既存 artifact
  `rbw_tally.jsonl-3`（2026-07-13 08:59、baseline A・full-1278 sweep、dia live 証明済）を boss1 が直読して抽出
  （= 期待値でなく artifact 実測値。scope label: 窓 = full-1278 sweep、boot 期の write は窓外 = 「wcount=0」は
  『窓内 write ゼロ』であって『write が存在しない』の証明ではない）。

## 1. 三択 taxonomy の定義と判定基準（決定木）

| 方式 | 定義 | 適用条件 |
|---|---|---|
| **(i) 値 capture** | 実機 dump から per-addr の値を取得し、C# の初期化データとして台帳付きで輸入（provenance = どの dump のどの addr か明記） | causal INPUT ∧ 初期値が read される（rbw=1）∧ 意味論が値で完結（pointer でない） |
| **(ii) model** | C# が機構を実装して値を自前で導出・維持（capture しない） | derived/maintained class（read 前に必ず store = E0F0/0B9 型）∨ pointer 類（実機アドレスは C# 空間に存在しない）∨ 等価構築が確認済みの boot-built table（DG.SCN 225 の前例） |
| **(iii) savestate 輸入** | 連続領域を savestate から丸ごと初期値として輸入 | 連続 struct で member 個別の意味論解明を待たずに初期値一括供給が要る場合。★正典 savestate の裁定が前提（§7 裁定 1）★ |

**判定の順序**: ① 因果性（INPUT verdict があるか） → ② 上流 writer（fwpc / wcount、rbw artifact 実測） → ③ 意味論（RE evidence）。
③ の材料が無い addr は**判定保留 + 調査 task 化**（判定の捏造禁止 — 「線を引いたらその線自体を検証」規範）。

**重要な一般所見（§2 実測から）**: 対象 14 addr は**全件 rbw=1** = 初期値が必ず read される。
⇒ **「初期値の供給」は全件で必要**（capture か savestate 輸入）。「維持」は窓内 writer の有無で分かれる:
- **窓内 write ゼロ（3 件）**: 初期値供給だけで完結する可能性が高い（維持機構の実装不要かも — boot 期 write の有無は要確認）。
- **窓内 writer あり（11 件）**: 初期値供給 + **維持機構は C# model**（fwpc = 実装対象関数の入口が既知）の二段構え。

## 2. per-addr 仕分け表（(a) = N(A)12 + B witness 1 + live-in 10 突合）

### 2a. live-in 候補 10 件の H3 突合（完了宣言）

H2 close の live-in 候補 10 = stat struct 4（D18/D3A/D42/D54） + E0F0 + CDBC + DF8C + script-buffer write 2（E7C/FBC） + 640A4。
H3 で **10/10 全件処理済み**: INPUT 3（D18/D3A/D54） + witness 2（D42 = POST 次元 / CDBC = B scope） +
model 級 1（E0F0 = derived） + NOT-SHOWN 2（DF8C/640A4） + UNMEASURED 2（E7C/FBC = DMA squash）。残ゼロ。

### 2b. 仕分け表（writer profile = rbw_tally.jsonl-3 boss1 直読、2026-07-14）

| addr | verdict/scope | reads | 窓内 wcount | fwpc（第一 writer） | 意味論（evidence 有のみ） | ★三択判定★ |
|---|---|---|---|---|---|---|
| 0x80141D18 | INPUT(A) multi-dim | 217,089 | 13,434 | 0x800A988C（= sub3 bitfield、RE 済） | stat struct member | ★**(iii) struct 一括輸入 + 維持 = model**（fwpc 既知）★ |
| 0x80141D3A | INPUT(A) 閾値 gate 型 | 109,157 | 6 | 0x800ECFDC | stat struct member | 同上 |
| 0x80141D54 | INPUT(A+B、最堅) | 108,752 | 4 | 0x800AB6AC | stat struct member | 同上 |
| 0x80141D42 | NOT-SHOWN + POST witness | 178,946 | 1 | 0x800ECFDC | stat struct member | 同上（struct 同梱。検証は §3 の POST 次元で） |
| 0x8013E114 | INPUT(A) CTX | 8 | **0** | —（窓内 write 無し） | 未同定 | ★**(i) 値 capture 最有力**★（初期値のみで完結の可能性。boot 期 write 有無 = W-A） |
| 0x8016B084 | INPUT(A) RNG | 566,685 | **0** | —（同上） | 未同定（RNG 次元に効く） | 同上 |
| 0x8016B169 | INPUT(A) multi | 5,413 | **0** | —（同上） | 未同定 | 同上 |
| 0x8013E2DE | INPUT(A) state-only | 27,144 | 4 | 0x800ED154 | 未同定 | (i)+model 二段（保留 → W-A で fwpc の関数同定後確定） |
| 0x8013E2E0 | INPUT(A) 真分岐 1 含む | 32 | 4 | 0x800ED168 | 0x19 CheckFlag の分岐材料（H2 §3） | 同上 |
| 0x80145E5A | INPUT(A) 進行系 60/60 | 36,185 | 1,976 | 0x800CBC30 | 未同定（PC-LEN+RAW+DONE = 進行そのもの） | 同上（writer 多 = model 主体の見込み） |
| 0x8016B139 | INPUT(A) | 132,868 | 27,414 | 0x800BC3A4 | 未同定 | 同上 |
| 0x8016B3A9 | INPUT(A) | 133,015 | 27,451 | 0x800BC3A4（B139 と同一 writer） | 未同定 | 同上 |
| 0x8016B411 | INPUT(A) state-only(CTX+DONE) | 133,012 | 27,451 | 0x800BC3A4（同上） | 未同定 | 同上（B139/B3A9/B411 = 同一維持関数の 3 member = 1 実装で 3 件充足の見込み） |
| 0x8013CDBC | ★B witness★（count 非算入） | 280,052 | 3 | 0x800A1BF4 | pointer slot（0x8013CDB4 ptr table 域、alias 実証済） | ★**(ii) model 確定**★ — 実機 pointer は C# 空間に存在しない。C# 側対応 = 参照。existence witness の C# 対応物特定 = W-A |
| （参考）0x8013E0F0 | UNMEASURED = derived | — | — | （0B9 型、fwpc 0x800E9C74 系） | derived/maintained | ★**(ii) model 確定**（capture してはいけない — 実行時導出値）★ |
| （参考）0x801640A4 | NOT-SHOWN(B) | — | — | — | 0x46/0x79 registry | (ii) model（実行時構築）。boot 時初期内容のみ要確認（保留） |
| （参考）0x8013DF8C | NOT-SHOWN(B) | — | — | — | 未同定 | capture 対象外（挙動入力の証明なし。台帳残置） |

**即決 3 / 有力 3 / 二段 7 / 保留付き**。確定に足りない材料は 1 種類だけ — ★**W-A: fwpc の関数同定**★
（wpcs は数 addr 3 個以下に収束済み = 対象関数は高々 7 個。worker2 の静的 RE 1 dispatch 分）。
判定を先取りしない: W-A 完了後に v0.2 で全行確定させる。

## 3. (b) D42 POST 次元 capture 化 = 第一級

- **現状**: 全 trace channel = 窓内 only（H2 BLOCKED #3、唯一 ungated = DGSTORE）。
- **H3 実測（動機）**: 0xFF/0x65 注入時のみ target へ 80 件の write-back（ctl 0 件、A/B 両 baseline 再現）+ 窓外 read +162。
  = 因果反応は実在するが宣言済み BLOCKED 次元にしか出ない。
- **仕様**: instrument（dg_vmtrace）の比較次元に **POST-STATE**（窓外 read/write の per-launch 要約）を追加し、
  DGSTORE 同乗を D42 系 run の標準構成にする。★これは測定器変更であって game code ではない（規範内）★。
- **自分の道具を疑え条項（必須）**: 変更後の初回使用前に (1) P1 replica（同一注入 2 run bit 一致） (2) ctl-ctl 一致テスト
  (3) 非 vacuity assert（POST 次元が実際に信号を運ぶことを positive control で確認）を内蔵。
- **acceptance**: D42 が POST 込み次元で INPUT/NOT-SHOWN を再判定できること。H2 台帳の B441 再検証も同じ束で実施。

## 4. (c) E7C/FBC = DGDMA 同乗前提

- **現状**: UNMEASURED-by-method — per-entry script DMA が first read 前に注入値を squash（12/12・8/8、store_t 不可視）。
- **仕様**: rare 系 run の標準構成に DGDMA 同乗を昇格（H3 rare 設計の標準化）。測定窓 = 「DMA 完了後〜first read 前」。
  DMA payload 自体の摂動は file 内容摂動と等価になり得るため、実施可否は当該 run の prereg で個別宣言（silent 拡大禁止）。
- **前提 unknown（高優先）**: `0x800AF6AC` の 0xFD→0 機構の対象 s0 実体（script か record か）= H2 台帳から継続。
  同定完了まで E7C/FBC の三択判定は**保留**（self-modify 実在なら C# の script read-only 前提が崩れ、model 実装に直結）。
  実測 = DGSTORE rider（worker3）+ 静的突合（worker2）の既存手法で可。

## 5. (d) 実装欠落台帳 7 件との依存鎖整合

| # | gap | capture 仕様上の扱い | 依存鎖上の順序 |
|---|---|---|---|
| 1 | MAPHEAD.SCN（全段欠落） | ★taxonomy 外の第 4 類 = **file 導入 + reader 実装**★（値 capture でなく file-load への合流。C# に file が無いことが欠落の本体） | **鎖の始点 = 最初に実装**。消費 = GetSectionOffset scan（0x800F0A4C） |
| 2 | opcode 0x46/0x79 未実装 | 消費側実装。registry 640A4 = (ii) model（実行時構築） | MAPHEAD の後 |
| 3 | opcode 0x66 未実装 | 消費側実装。**DF70 の capture 方式 = 未定（W-B: DF70 の上流 writer 特定）** | DF70 capture → 0x66 消費の順 |
| 4 | 0x8015Fxxx boot-built table | DG.SCN 225 分は ★(ii) model 確定済み★（H3 close で C# 等価構築 225/225 実証 = capture 不要の前例）。残余部分の builder RE = 台帳継続 | 独立 |
| 5 | stat struct boot 初期値 | ★本 spec §2b で (iii) に確定★ — eef22cc の二択（savestate 輸入 vs boot model）は、H3 の causal 証明（4 件中 3 INPUT + 1 witness）により「輸入が必要」側で決着。boot model 化は fwpc 同定後の将来 refactor 選択肢として残す | 独立（先行実装可 = ③ の最初の一歩に適） |
| 6 | self-modify 疑い 2 addr（E7C/FBC） | §4。s0 同定まで判定保留 | 独立 |
| 7 | 待機 semantics（自然終端しない entry） | ★capture 仕様 scope 外と宣言★（値供給でなく実行挙動 = ⑤棚 4 op と同束、実装 phase の別 item） | — |

**★cutscene 凍結 flag★**: #1（MAPHEAD）と #3（0x66）は検証が覚醒 cutscene に接続する。
**実装と検証を分離** — 実装（③）は凍結に抵触しない、cutscene 実走による検証のみ user 裁定後（§7 裁定 2）。

## 6. acceptance / 検証計画（③ の gate、prereg は実装 phase で固着）

1. capture 実装 1 件ごとに: C# 側の値 = capture 台帳値の一致 assert（provenance 込み）+ 既存差分テスト手法（16 pair / 80 launch）で該当 addr の次元 FAIL 減少を確認。
2. 数値目標（state 列一致数の改善幅）は**実装 phase の prereg で固着**（本 draft では約束しない — 完成 claim 凍結規範）。
3. 全 run = immutable copy（perm 400）を DGSTATE に。P1 replica + ctl-ctl 一致テスト常設（H3 methodology 8 項の継承）。

## 7. 裁定要事項（PRESIDENT / user）

1. **★savestate 輸入の正典★**: A は消失。B = user play 進行後 = 「初期状態」としての適格性に疑義。
   **boss1 推奨 = fresh boot 直後の新規 dump を capture 正典に採用**（B は挙動検証用 baseline として継続使用、役割を分離）。
   ※ 採用時は stat struct の causal 証明が fresh boot 値でも成立するかの 1 対確認 run を ③ 冒頭に置く。
2. **実装と検証の分離**: MAPHEAD/0x66 は実装先行・cutscene 検証は凍結解除後、で進めてよいか（boss1 推奨 = 分離 OK）。
3. **W-A/W-B の位置づけ**: v0.2（確定版）の前提に含めるか（boss1 推奨 = 含める。判定材料なしで三択を確定しない）。

## 8. 単一推奨

★**W-A（fwpc 7 関数の同定、worker2 静的 RE）+ W-B（DF70 上流 writer）を 1 dispatch で先行 → 結果で §2b 全行を確定した
v0.2 を PRESIDENT 査読に出す**★。新規 run ゼロ〜最小（DGSTORE rider 1 本の可能性のみ）、game code ゼロ不変。
理由: 保留 7 行の確定材料は fwpc の関数同定 1 種類に収束しており、これを飛ばすと三択が assumption-based になる（measure-first）。

## 9. PRESIDENT 査読結果（2026-07-14 13:0x 受領、v0.1 = 方向承認）

- **裁定 (1) = 承認 + 条件**: fresh boot 直後の新規 dump を capture 正典に（B は挙動検証 baseline へ役割分離）。
  ★条件: 新正典は生成した瞬間から immutable（sha256 記録 + perm 400）+ 指紋台帳に**第 3 baseline として命名登録**
  （A 喪失の教訓の適用）。③冒頭の causal 証明 1 対確認 run（N の因果が新正典へ transfer するか）は必須のまま★。
- **裁定 (2) = 承認 + 条件**: 実装と cutscene 検証の分離 OK。★条件: MAPHEAD/0x66 の実装は**gate/flag で opt-in**とし、
  user 裁定の検証まで既定 OFF★ — scenario-0 解決の変更は fall-through 偶然に依存する現 cutscene 挙動を silent に変え得る。
  『実装 land ≠ 現挙動変更』を flag で構造保証（control-toggle 教訓の逆用 = 意図的に OFF で land。
  ⇒ ③実装時、flag の配線実在を grep+log で確認してから land する義務も同時に発生する点に注意）。
- **裁定 (3) = 承認**: W-A/W-B を v0.2 前提に含める。
- **単一推奨 = GO**: W-A（fwpc 7 関数の静的 RE、worker2）+ W-B（DF70 上流 writer）を 1 dispatch 先行 → v0.2。
  read-only RE = game code ゼロ規範内。

⇒ 次 action: worker2 へ W-A/W-B dispatch（本節追記と同時刻に発行）。v0.2 は W-A/W-B 結果で §2b 全行確定 + 本裁定条件を仕様本文へ反映。
