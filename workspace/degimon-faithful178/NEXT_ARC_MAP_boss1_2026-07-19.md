# ③ladder完了後の見取り図(boss1、2026-07-19 — 次scoping上申の添付用draft)

status: DRAFT(OI-2収束後のscoping上申に添付)。PRESIDENT 06:35の(3)要請に応えるもの。

## 0. 現在地(landed資産の性質)

③ladder全段land。ただしland形態は★flag opt-in既定OFF+宣言gap★が中心=「decode/状態機構は忠実、user可視の実挙動はまだgapの内側」:
| 資産 | flag | user可視までの残gap |
|---|---|---|
| step3 MAPHEAD鎖 | OFF | (gate①arcでON側の一部はuser live PASS済) |
| step5 0x66 SCENE_DRIVER | OFF | ★B4 scene selector=stub(OI-3=3段目RE未了)★=ONでもsceneは動かない |
| step5 0x66 clear枝 | OFF | ★0x67-body=宣言gap(OI-2)★ |
| step4 0x46/0x79 registry | OFF | ★activate実体=宣言gap(OI-5)★=registryは動くがactorは出ない |
| O2(a) clamp populate | 常時 | ★H4-i(clampがpartnerを読む保証)=savestate判別待ち★ |

## 1. ★単一推奨の道筋: 「scene driver を本物にする」縦積み★

**目標milestone**: 0x66がONで実際にscene遷移を駆動し、scenario進行の一連(prologue→scene選択→遷移)が★user live実視覚で確認できる★状態。これが③ladderの成果を「decode忠実」から「挙動忠実」へ昇格させる最短のuser可視成果。

順序(依存順、各段は従来のp1→gate①→p3→検証→landフロー):
1. **OI-2: 0x67**(実行中、census最多698)— 0x66とpairで prologue末尾の完全忠実化+clear枝fall-through gap解消。
2. **OI-3: scene selector 3段目**(0x801066cc/descriptor表0x8013CDB4解釈)— ★B4 stubを実配線に昇格させる核心★。step3 MAPHEAD/RunScene資産との接続点。
3. **ON側統合検証→user live**: 0x66+0x67+selector配線をONにした scenario進行の実走(まずheadless oracle、最後にuser live=凍結解除判定)。

## 2. 並走line(独立、worker空き時に消化)

- **O2完成**: H4-i savestate判別(着信次第worker3即応)→(c)care-scene relay要否確定→care clamp完成判定(user live)。
- **OI-5**: registry activate実体(0x800a1348)RE — 0x46/0x79のgap解消+OI-6(id空間一致機構)も同時に解ける公算。
- **OI-7**: 全225静的走査(0x79上界)— 低コスト、機会あれば。

## 3. その先の新arc候補(PRESIDENT/user優先度裁定事項)

- **battle縦スライス**(survey済=W1BATTLE-0716 read-only見積、d9c7ff0)— scenario進行がuser liveに乗った後の最有力大型arc。
- **sprite-exact field-char RE**(memory記載の残項)/ menu+status UIの続き。
- push判断(全arc commit、user専権)= 適切なmilestone(例: scene driver user live PASS)後にuserへ確認するのが自然。

## 4. リスク/前提

- OI-3は3段目+descriptor表解釈=RE規模が読みにくい(H4開放)。p1の結果次第でscope再上申。
- ON側統合はfall-through偶然依存の既存cutscene挙動(step3裁定文脈)との相互作用に注意=統合検証はOFF-inert二重確認+段階ON(flag個別)で。
- 全landはpush HOLD/user live凍結の規範を維持したまま進める。
