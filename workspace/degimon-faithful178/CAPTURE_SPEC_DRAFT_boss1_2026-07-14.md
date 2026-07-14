# capture 仕様 draft（boss1。v0.1 = 2026-07-14 12:5x 提出 → PRESIDENT 方向承認 → v0.2-prep = 13:1x、裁定条件の本文反映。W-A/W-B 依存部分（§2b 保留 7 行）は worker2 結果待ち = v0.2 で確定）

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
| **(iii) savestate 輸入** | 連続領域を savestate から丸ごと初期値として輸入 | 連続 struct で member 個別の意味論解明を待たずに初期値一括供給が要る場合。★正典 = baseline C（§1b、裁定 1 で確定）★ |

### 1b. capture 正典 = baseline C（fresh boot 直後 dump。裁定 1 = 承認済、条件込みで確定）

- **定義**: 製品（C#）が再現すべき『初期』は boot/new-game であって測定 baseline ではない（PRESIDENT 裁定理由）。
  よって capture 正典 = **fresh boot 直後の新規 dump = baseline C と命名**。B（preserved 2026-07-14 save）は**挙動検証用 baseline に役割分離**（継続使用）。
- **★生成条項（A 喪失の教訓の適用、生成した瞬間から）★**:
  1. sha256 を記録し **perm 400（chmod a-w）を生成直後に適用**（rotation/user play への免疫）。
  2. **指紋台帳に第 3 baseline『C』として命名登録**（A の部分指紋台帳・B の sha 台帳と同列。probe 判別子 = A/B と同様に 12 注入 addr の orig 値で採取）。
- **★transfer 確認条項（必須）★**: ③冒頭に **causal 証明の 1 対確認 run** — N の因果（少なくとも stat struct の INPUT）が
  baseline C 上でも成立するかを確認してから capture 値を採用する（A→B の existence transfer と同じ規律を C にも適用）。

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

### 2b. 仕分け表 ★v0.2 = 全行確定★（writer profile = rbw_tally.jsonl-3 boss1 直読 + 維持機構 = worker2 W-A `6a78786`。
boss1 検算: 全 EA 算術 8/8 一致 + ★gp = 0x80144E0C が独立 4 claim（E2DE/E2E0/E114/DF70）で過剰決定的に一致 = PASS★）

| addr | verdict/scope | 維持機構（W-A 同定、値の由来） | ★三択判定（確定）★ |
|---|---|---|---|
| 0x80141D18 | INPUT(A) multi-dim | RMW bit clear（自現在値 AND 0xFFFFFFFD、絶対 EA store） | ★**(iii) struct 一括輸入（初期値）+ 維持 = model**★ |
| 0x80141D3A | INPUT(A) 閾値 gate 型 | ★opcode 0x36 handler(0x800ECF48)★: 現在値 − operand、**下限 −100 clamp**（gate 型 profile と機構整合） | 同上（維持 = **VM opcode 0x36 実装**） |
| 0x80141D42 | NOT-SHOWN + POST witness | 同 0x36 handler（D3A と同経路） | 同上（検証は §3 POST 次元） |
| 0x80141D54 | INPUT(A+B、最堅) | 現在値 − record(+0xa) 由来値。直後に D18 の bit test（record 実体 = 未同定 #2） | 同上 |
| 0x8013E114 | INPUT(A) CTX | ★**v0.1 判定を撤回・訂正**★（§2c）: = **gp-0x6cf8 = MAPHEAD buffer の pointer slot**。writer 0x800F0020 が定数 0x80159784（buffer 先頭）を格納。H2 の初差 CTX と機構一致（pointer ゆえ perturb で別 buffer 実行） | ★**(ii) model — pointer ⇒ 値 capture 不可、参照表現へ写像。台帳 #1 MAPHEAD 鎖に合流**★ |
| 0x8016B084 | INPUT(A) RNG | ★静的 BLOCKED★（EA 確定可能 store に 0 件。**飽和開示: 全 store 17,528 中 79% = pointer-base = 未探索** = 不在の証明ではない） | ★初期値 = **(i) 値 capture（baseline C）で確定**（rbw=1 = 供給は必須）。維持機構 = 未同定のまま台帳 #7（③前の実測分離策あり）★ |
| 0x8016B169 | INPUT(A) multi | 同上 | 同上 |
| 0x8013E2DE | INPUT(A) state-only | ★opcode 0x37 handler(0x800ED050)★: **operand をそのまま gp slot へ copy** | ★**(i) 初期値 capture + 維持 = VM opcode 0x37 実装**★（写経後は script が値源 = capture は初期値のみで足りる） |
| 0x8013E2E0 | INPUT(A) 真分岐 1 含む | 同 0x37 handler（operand 2 byte 目） | 同上 |
| 0x80145E5A | INPUT(A) 進行系 60/60 | ★record 配列（base 0x80145E48・stride 36）member +0x12 に**定数 0/2 を書く state machine**★（意味 = 未同定 #3） | ★**(i) 初期値 capture + 維持 = model（record 配列 + 状態遷移）**★ |
| 0x8016B139 | INPUT(A) | ★record member +0x35 に 0x800DEE24(s1,0x140,0xF0) 戻り値 xor 1 の bool★（同一 writer で 3 addr） | ★**(i) 初期値 capture + 維持 = model（1 実装で 3 件充足）**★ |
| 0x8016B3A9 | INPUT(A) | 同上（record 間隔 0x270/0x68 = stride は 3 点から一意に決まらない、と honest 開示） | 同上 |
| 0x8016B411 | INPUT(A) state-only(CTX+DONE) | 同上。★+0x34/+0x35 member = E7C/FBC annex の readerA/0x800BB940 と同 offset = RE 上の合流点（lead、断定なし）★ | 同上 |
| 0x8013CDBC | ★B witness★（count 非算入） | ★writer 0x800A1BF4 = **0x8013CDB4 base の u32 pointer 配列 index 2 に NULL を書く解放系**。readerB が [0x8013CDB4+(i+2)*4] で引く**まさにその table** = H3 alias 実証と 2 系統収束★ | ★**(ii) model 確定**（参照表現へ写像。C# 対応物特定は ③）★ |
| （参考）0x8013E0F0 | UNMEASURED = derived | （0B9 型） | ★**(ii) model 確定**（capture してはいけない）★ |
| （参考）0x801640A4 | NOT-SHOWN(B) | 0x46/0x79 registry | (ii) model（実行時構築）。boot 初期内容のみ要確認（保留） |
| （参考）0x8013DF8C | NOT-SHOWN(B) | — | capture 対象外（台帳残置） |

★**総括（v0.2 確定）**: 三択の分布 = **(iii) struct 一括輸入 4（stat struct、維持 model 込み）/ (i) 初期値 capture 8（うち 4 は維持 model 同定済・2 は VM opcode 実装が維持・2 は維持未同定）/ (ii) model 3（E114・CDBC・E0F0 = pointer/derived、capture 禁止側）**。
全 14 行に「初期値の供給元 = baseline C」が通底（全件 rbw=1 の帰結）。維持機構が VM opcode（0x36/0x37）である 4 件は、
★C# の当該 opcode 実装有無の確認が ③ の preflight★（未実装なら台帳 #2/#3 と同じ「消費側実装」に合流）。

★**脚注 = (i) 判定 8 件の前提を守る一般則（E114 事案から、PRESIDENT 指定で恒久化）**★:
**『窓内 write ゼロ』は【writer がいない】ではなく【writer が窓の外にいる】**。よって (i) 判定は「初期値 capture で足りる」
の意味であって「維持機構が存在しない」の主張ではない — 各行の ③ 実装時、初期値だけ供給して差分テストが FAIL するなら
窓外 writer（boot/イベント条件付き）を第一仮説にせよ。

### 2c. v0.1 → v0.2 の判定変更記録（Pattern 4: 撤回と理由を残す）

- ★**E114: 「(i) 値 capture 最有力」→ 「(ii) model」に撤回・訂正**★。
  v0.1 の根拠 = 「窓内 write ゼロ = 初期値だけで完結しそう」という **writer 不在からの推定**だった。
  W-A 実測 = writer は実在（0x800F0020、boot/init 期 = 窓外）し、**書くのは compile-time 定数の buffer address = pointer slot**。
  pointer は「値 capture 不可」規則（§1 決定木 (ii) 条件）に落ちる。
  **教訓 = 「窓内 write ゼロ」は『writer がいない』ではなく『writer が窓の外にいる』**（v0.1 §0 の scope 注記が自分に刺さった実例）。
  副産物: ★N(A) の INPUT 1 件（E114）が実装欠落台帳 #1（MAPHEAD 鎖）に直結した★ — 台帳 #1 の実装は N の 1 件を同時に充足する。
- B084/B169: 「(i) 最有力」→ **初期値 (i) は確定・維持機構は BLOCKED**（79% pointer-base 未探索の飽和開示付き）。
  ③前の分離策（新規 run 1 本、要承認）: boot〜窓頭の DGSTORE watch で writer を実測特定（静的の盲点 = pointer-base store を実測が補完）。

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
| 3 | opcode 0x66 未実装 | 消費側実装。★**W-B 結果（worker2 `6a78786`）: DF70 の writer = field/helper 域 2 件（0x800AE4E0 = flag bit 0x20 ∧ gp-0x6cb0==1 の条件付き / 0x800BC294）、値 = register(s1/s2) の signed byte 化 = 定数でも file copy でもない ⇒ 「file 合流」方式は材料上不支持**。s1/s2 の上流 = 未同定（台帳 #6）⇒ **DF70 = 初期値 (i) capture + 維持方式は s1/s2 同定まで保留**★ | DF70 capture → 0x66 消費の順 |
| 4 | 0x8015Fxxx boot-built table | DG.SCN 225 分は ★(ii) model 確定済み★（H3 close で C# 等価構築 225/225 実証 = capture 不要の前例）。残余部分の builder RE = 台帳継続 | 独立 |
| 5 | stat struct boot 初期値 | ★本 spec §2b で (iii) に確定★ — eef22cc の二択（savestate 輸入 vs boot model）は、H3 の causal 証明（4 件中 3 INPUT + 1 witness）により「輸入が必要」側で決着。boot model 化は fwpc 同定後の将来 refactor 選択肢として残す | 独立（先行実装可 = ③ の最初の一歩に適） |
| 6 | self-modify 疑い 2 addr（E7C/FBC） | §4。s0 同定まで判定保留 | 独立 |
| 7 | 待機 semantics（自然終端しない entry） | ★capture 仕様 scope 外と宣言★（値供給でなく実行挙動 = ⑤棚 4 op と同束、実装 phase の別 item） | — |

**★cutscene 凍結 flag（裁定 2 = 分離承認、条件込みで確定）★**: #1（MAPHEAD）と #3（0x66）は検証が覚醒 cutscene に接続する。
**実装と検証を分離** — 実装（③）は凍結に抵触しない、cutscene 実走による検証のみ user 裁定後。

**★opt-in flag 条項（裁定 2 の条件、③ 実装に対する拘束）★**:
- MAPHEAD/0x66 の実装は **gate/flag で opt-in とし、user 裁定の検証まで既定 OFF**。
  理由: scenario-0 解決の変更は、fall-through 偶然に依存する現 cutscene 挙動を silent に変え得る。
  『実装 land ≠ 現挙動変更』を flag で構造保証する（control-toggle 教訓の逆用 = 意図的に OFF で land）。
- **配線確認義務（同教訓の本来面）**: flag が実際にコード経路を gate していることを **grep 配線目視 + log 実測**で確認してから land
  （宣言だけの toggle は no-op — OFF で差ゼロに見えるのが no-op のせいであってはならない。ON/OFF 両側の実測を acceptance に含める）。

## 6. acceptance / 検証計画（③ の gate、prereg は実装 phase で固着）

1. capture 実装 1 件ごとに: C# 側の値 = capture 台帳値の一致 assert（provenance 込み）+ 既存差分テスト手法（16 pair / 80 launch）で該当 addr の次元 FAIL 減少を確認。
2. 数値目標（state 列一致数の改善幅）は**実装 phase の prereg で固着**（本 draft では約束しない — 完成 claim 凍結規範）。
3. 全 run = immutable copy（perm 400）を DGSTATE に。P1 replica + ctl-ctl 一致テスト常設（H3 methodology 8 項の継承）。

## 7. 裁定結果（PRESIDENT、2026-07-14 13:0x — v0.1 の裁定要 3 件は全て回答済み）

1. **承認 + 条件** → 本文 §1b に反映済み（baseline C = fresh boot 正典、immutable + 命名登録 + transfer 確認）。
2. **承認 + 条件** → 本文 §5 に反映済み（MAPHEAD/0x66 = flag opt-in 既定 OFF + 配線確認義務）。
3. **承認** → W-A/W-B は v0.2 の前提（worker2 dispatch 13:0x 発行済み、§8）。

**残る user 裁定事項は 1 件のみ**: cutscene 凍結解除（実走検証の時点。実装③はこれを待たない = flag OFF で land）。

## 8. 単一推奨

★**W-A（fwpc 7 関数の同定、worker2 静的 RE）+ W-B（DF70 上流 writer）を 1 dispatch で先行 → 結果で §2b 全行を確定した
v0.2 を PRESIDENT 査読に出す**★。新規 run ゼロ〜最小（DGSTORE rider 1 本の可能性のみ）、game code ゼロ不変。
理由: 保留 7 行の確定材料は fwpc の関数同定 1 種類に収束しており、これを飛ばすと三択が assumption-based になる（measure-first）。

**進行状況（13:1x 更新)**: PRESIDENT GO → worker2 へ dispatch 発行（13:0x、納期 15:30）→ 着手 ack 受領（13:1x、規範復唱込み）。
裁定条件 2 つは §1b/§5 へ反映済み（= v0.2 の W-A/W-B 非依存部分は先行完成。残 = §2b 保留 7 行 + §4 s0 判定の材料到着待ち）。

## 10. v0.2 確定（2026-07-14 13:4x。W-A/W-B = worker2 `6a78786` 納期前完了、boss1 検算 PASS で採用）

- **採用手続き**: boss1 が artifact 全文直読 → **独立検算 = EA 算術 8/8 一致 + gp 値の過剰決定的一致
  （E2DE/E2E0/E114/DF70 の 4 独立 claim が全て gp=0x80144E0C を導く）** → §2b 全行確定・§2c 撤回記録・§5 #3 更新。
- **worker2 の道具自己監査 2 件を methodology 台帳へ**（「自分の道具を疑え」の実践 2 例）:
  (1) displacement scan の false positive 2 件を自己捕捉（ALU dest reg を invalidate せず stale base 残留 → 厳格版 + 全 hit 手動 verify）
  (2) fn_entry 境界誤り（handler 24 件を飲み込み → **handler は $sp prologue を持たない ⇒ dispatch table entry を権威**に訂正）。
- **未同定台帳 7 件**（worker2 明示、推測で埋めていない）: ① 0x800F53C8（stat id→pointer） ② D54 record(+0xa) 実体
  ③ +0x12 member の意味 ④ 0x800DEE24（引数 0x140/0xF0） ⑤ CDBC NULL 化の呼出条件 ⑥ ★DF70 の s1/s2 上流★
  ⑦ ★B084/B169 の維持 writer（79% pointer-base 未探索 BLOCKED）★。⑥⑦のみ capture 方式に影響（他は ③ の実装詳細）。
- ★**③ 着手前の acceptance 前提（boss1 提案）**★:
  (a) taxonomy 判定を左右した 3 claim（E114 pointer slot / CDBC NULL writer / 0x37 copy）の **worker1 独立 spot x-check**
  （disasm 直読、2 実装収束の通常規律。v0.2 提出をこれで block はしない — ③ GO の前提に置く）。
  (b) C# の opcode 0x36/0x37 実装有無の確認（未実装なら台帳 #2/#3 と同じ消費側実装に合流）。
  (c) ⑥⑦ の分離策 = 各 1 本の実測（DGSTORE watch）を ③ 冒頭 or 直前に（新規 run につき個別承認）。

## 11. 手隙タスク成果（worker2 `f43cf88`、caller 静的列挙）+ v0.2 承認記録

- **DF70 writer の caller**: writer1 関数 0x800AE3DC = caller 3 件（うち 0x800E3DA0 = worker2 の過去 RE で warp routine と同定
  — ★本タスクでは未再検証、自過去 claim を裏付けに使わない caveat 付き★。正しければ「DF70 = map 遷移経路で書かれる =
  play 進行由来」候補だが未確定）/ writer2 関数 0x800BBEA8 = caller 1 件。★jalr（間接呼出）未探索 = caller 一覧は下限★。
- ★**構造 finding: writer2 の関数 0x800BBEA8 は W-A #7（B139/B3A9/B411 の +0x35 writer）と同一関数**★
  = 同じ機構が DF70 と record +0x35 の両方を書く ⇒ ③ で一方を model 化すれば他方も同実装で覆える可能性
  （★『同一関数内』=『同じ意味』ではない — 意味の同一性は未確認、と worker2 が自ら caveat★）。
- **v0.2 = PRESIDENT 承認（確定版採択、2026-07-14 14:0x）**。③着手前提 3 点承認、**(c) DGSTORE watch 2 run = 個別承認 GO**。
- ★**③実装 phase の規範（PRESIDENT 予告、prereg 前に固定）**★: ① worktree 隔離必須（複数 worker が unity repo に入るなら track 分離）
  ② MAPHEAD/0x66 = flag opt-in 既定 OFF land ③ small commits + 各 step で既存 headless verify（CutsceneVerify178 等）非退行
  ④ **完成 claim は user 実視覚まで凍結**（headless 緑は根拠にならない） ⑤ push ゼロ不変。
  GO 条件 = (a)(b)(c) 完了 + ③ prereg 固着の確認。

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
