# step3 設計判断 doc(boss1 起案、2026-07-15 09:4x → PRESIDENT gate ①)

材料 = worker2 STEP3_PREDESIGN(`a1360a8`+用語峻別 `363850d`、data/EXE 直読裏取り済)+ v0.2 §5 台帳 #1 + 裁定 2(flag opt-in)。
scope = MAPHEAD 鎖の実装方針。★実装 land 自体は gate ②(PRESIDENT go を land 前に)= 本 doc は方針の裁定★。

## 単一推奨: 「provision + dispatch + 配線」の最小忠実形(新規 parse 実装ゼロ)+ 単一 feature flag 背後

1. **MAPHEAD.SCN provision**: bit-exact で StreamingAssets に導入(DG.SCN と同列)。加工なし。
2. **GetEntryBase(scenario) dispatch 新設**: scenario==0 → MAPHEAD entry base / それ以外 → 既存 DG.SCN 経路。
   ★これが N の 1 件(E114 = MAPHEAD buffer pointer slot)の C# 対応そのもの★(pointer→参照表現への写像、v0.2 (ii) 判定の実装)。
3. **section 解決 = 既存 `GetSectionTable` 再利用**(worker2 が EXE 0x800F0A4C 全長 RE と bit-identical を確認済)
   = ★新規 parse 実装ゼロ。書くのは provision・dispatch・0xFE resolve 配線・Boot shortcut 置換のみ★。
4. **feature flag**: 単一 bool(仮称 `FaithfulScenarioZero`)、★既定 OFF★。
   - OFF = 現行経路 bit 不変(MAPHEAD を load すらしない)。acceptance = OFF で全 gate 緑 + CutsceneVerify178 baseline 一致。
   - ON = 新経路。acceptance = ★4-hop chain の trace log(178§0x36→0x4B(218)→MAPHEAD§218 0xFB(163)→resolve→163§0x36
     0x17 JMP→178§0x37→0x4B(204,0xFF))が worker2 の data 直読地図と一致★(= headless log 検証。cutscene 実走・視覚は凍結)。
   - ★配線確認義務(裁定 2 条件)★: flag が実際に経路を gate していることを grep 目視 + ON/OFF 両側 log 実測で。
5. **用語峻別の継承**: worker2 finding『覚醒 chain は game event flags 非依存(New Game 全ゼロで到達)』は
   ON 側 acceptance の設計を単純化する(preset 不要)が、★feature flag 既定 OFF の条件とは無関係(別物)★。

## 実装時の検証点(推論で埋めない、worker2 open items 継承)

- ★BodyStart 規約★: DG.SCN = 4+Word0 / MAPHEAD = Word0 直(=1128 = subtable 終端と整合)の可能性 —
  **実装時に実測確認**(281×4+2+2=1128 の算術は worker2 確認済、実 data で最終確認)。
- 0x4B の section 内位置 full trace / 0xFB↔0xFE 順序 = 実装後の trace log で確認(発明しない)。
- ★覚醒の視覚忠実度 = user 実視覚まで凍結★(chain PC 一致 ≠ 視覚 PASS、memory の『見た目 PASS≠忠実』教訓)。

## file 境界の更新(明示)

worker2 の境界に DialogueDatabase.cs(provision/dispatch)+ Boot 系(shortcut 置換、flag 配線)を追加。
worker3(instrument)・worker1(検証 doc)との交差なし。

## acceptance(gate ② の材料)

- OFF: 全 gate 緑(care 19/19+golden 37+bulk 89+datetime 16+tail 9+baseline_c_verify 12+CutsceneVerify178 baseline 一致)。
- ON: 4-hop trace log = data 直読地図と一致 + OFF↔ON 切替の log 実測(配線証明)。
- land は gate ②(PRESIDENT go)を経る。cutscene 実走検証はしない(user 凍結解除後の別 phase)。
