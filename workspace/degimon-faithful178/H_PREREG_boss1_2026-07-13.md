# H 注入テスト — boss1 事前登録（★集計を見る前に固定。以後の変更は禁止★）

書いた時刻 = perturb run 走行中（16 target 中 8 本完了、pt_pert_08 書込中）。
★私はまだ pt_compare を一度も走らせていない。verdict 表は未見。★

## 1. 判定閾値（PRESIDENT 裁定を採用、以後動かさない）

target address ごとに:

- **INPUT** ⇔ 注入が適用され（`applied==1` ∧ `readback==new` ∧ `readback≠orig`）、かつ
  **同一 launch 集合の比較で PC 列 / state 書込列 / RNG 抽選列 の【どれか一つでも】変化**
- **NOT-SHOWN-INPUT** ⇔ 注入は適用されたが 3 列とも全 launch で完全一致
- **INVALID** ⇔ 注入が適用されていない（inert perturb を「定数」と誤読させない gate）
- **UNTESTED** ⇔ nlaunch=0

★「両方不変 = 非入力」は PRESIDENT 定義だが、私は verdict 名を **NOT-SHOWN-INPUT** とする★:
単一の注入値（1 byte、1 通り）で差が出なかっただけであり、**非入力の証明ではない**
（例: 閾値分岐で、たまたま同じ側に落ちる値を注入した場合）。**constant verdict は下限主張、INPUT verdict は上限主張ではない**。

## 2. ★私の N 予測（point estimate を先に確定）★

- **真入力 N = 14 / 16**（NOT-SHOWN-INPUT = 2 を見込む）
- 内訳予測: **state-only（PC 不変・書込のみ変化） ≥ 1 件**
  → ★state-only が 0 件で出たら、それ自体を疑う★（0x1B 型 = G の 0/469 の再演＝write 列が鈍い可能性）
- INVALID = 0（16 target 全て applied、sample 2 件で readback==new を実測済）
- NOT-SHOWN-INPUT の最有力候補 = **nlaunch が小さい 2 件**（`0x8013E114` nlaunch=4 / `0x8013E2E0` nlaunch=18）
  理由 = 露出 launch が少ない ⇒ 分岐に効く機会が構造的に少ない。★これは仮説であって観測ではない★

### worker2 予測（f1b 5fde527、pt_compare 内に埋込）との差分
- worker2: PC=11 / STATE-only=4 / CONST≤1 ⇒ N=15
- boss1: N=14。**私の方が 1 件辛い**。乖離が出た方向を finding として報告する。

## 3. ★H4（予測が外れる方向を両方開ける）★

- **N < 14 もあり得る**: image 外 RAM でも、当該 launch では分岐に効かない address がある（PRESIDENT 指摘）
- **N = 16 もあり得る**: 全件が効く
- ★どちらに転んでも閾値は動かさない。集計値に合わせて基準を書き換えたら、それが今日 PRESIDENT が捕まえた誤りの再演★

## 4. closure 3 条件（PRESIDENT 固定、boss1 は判定のみ）

1. (a) 16 の各 address が注入テストで**真入力と直接証明**された
2. (b) 16 が下限でない（**cap 非依存で EXACT**）
3. (c) **46-capture に 16 が全て含まれる**よう再構成された

★1 つでも欠けたら「閉じた」と言わない。P6（closure 残余 0）が非 0 なら closure 未達★

## 5. ★観測次元の honest mark（ツール監査で判明、報告に必ず添付）★

comparator が見ている「state 列」の正体を明記する（[[feedback_state_which_dimension]]）:

- **R1（確認済・実害限定）**: `segments()` が `(scn,key)` を dict キーにするため**重複 launch が上書き**される。
  baseline 1278 launch → 1275 distinct key、pt_pert_03 は 18 → 17。**重複キーは最後の 1 本しか比較されない**。
  → boss1 側の独立 comparator では **launch 連番 key** に是正して二重集計する。
- **R2（構造的な次元の狭さ）**: trace の record 種別は `launch / pcrec / var_w / flag_w / rng_draw / entry_done / gp / handler_len` のみ（baseline 実測 tally）。
  ⇒ ★「state 列」= eventBank の flag/var 書込のみ★。partner/care 構造体 `0x80141xxx`、item bitset `0x8016B084` 等
  **eventBank 外への store は stream に出ない**。よって「state 不変」は **「eventBank state 不変」の proxy**であり、
  非 eventBank state だけに効く address は NOT-SHOWN-INPUT に化ける。**これは今回の測定の既知の盲点として honest mark**。
- **R3（感度の限界）**: 注入値は address ごとに **1 通りのみ**（例 0x8013E2E0: orig=28 → new=227）。
  単一値で差ゼロ = 非入力の証明にならない（上記 verdict 名の根拠）。

## 6. 私が改善として足す観測次元（感度は上げるが閾値は変えない）

- **RNG 抽選列（`rng_draw`）を第 3 の比較列に追加**。worker3 の comparator は PC と flag/var のみを見ており、
  RNG 消費だけが変わる注入を取りこぼす。★これは判定を緩めるのでなく**厳しく**する方向（INPUT を見逃さない）★。
- 追加によって INPUT が増えた場合、**「PC/state のみ」での N も併記**して、どの列が効いたかを分離報告する。
