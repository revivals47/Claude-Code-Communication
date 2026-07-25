# 学び 5 件 — 2026-07-25 自律RE session(boss1 close doc、PRESIDENT承認)

対象 session: field NPC loader / battle caller 静的RE dispatch(worker1/2/3、commit 9本 push HOLD)。
既存 feedback memory と重複する項目は pointer に留める(散逸防止)。

## 1. sink 全列挙は 4 形態(jal / j / materialize / data word)

worker2 が caller 探索で「0x801088c8 は caller ゼロ」と一度誤検出した実例。jal と full-word pointer
だけ走査し、**materialize(lui+addiu)を見落とした**。LO=0x88c8 が符号拡張されるため lui は
0x8010 でなく **0x8011**(HI+1 補正)——lui トラップが「探す側」にも刺さる。
- 波及: 参照走査を根拠に「唯一の caller」「reader は 1 箇所」と主張する時は、走査した形態を
  doc に明記する(worker3 (3a) 指摘: 絶対参照走査は register 経由の record ptr 読みを原理的に写さない)。
- 既存 memory: feedback_enumerate_all_sinks_not_just_branches / reference_mips_lui_sign_extension_trap の合流点。

## 2. word watchpoint は dst 開始 addr・総長を写さない

DuckStation gdb stub の word watch は、word 内のどの byte に触れても同じ addr を報告する。
trap 時の a0/a2 は「その瞬間の cursor / 残長」であり、**copy の開始 dst・総長は log から導出不能**。
本 session では 0x843/0x43 を「copy 長」と読んだ誤りが 2 doc に伝播していた(実体は残長、
実長は VabHdr 式から 0x1420/0xC20)。watchpoint log を根拠にする全推論の前提 caveat。
- 一次記録: VERIFY_runtime_capture_2026-07-25.md §1.3。

## 3. freeze→開示の独立検証設計は収束を「証拠」に変える

worker3 に (4) 自己導出を先に完了・freeze させてから worker1 の claim を開示した(出所も伏せた)。
結果、先入観なしの自己導出(32-byte 周期、実在 extent)が VagAtr 理論位置と byte 単位一致し、
**三者独立の収束そのものが証拠になった**。§6 検証でも同型(worker3 の lead → worker1 実装 →
worker3 refute check)。多重 view は「同じものを二度見る」のではなく「盲検で測って突合する」時に最も効く。

## 4. strawman / 恒等式は証拠でない — 検出 2 例

- 「20/20 vs 3/17」: 採点式が「新 base の type vs json[N+1]」で、新 base が忠実である以上
  旧仮説は定義上ほぼ当たる = tautology。同一 bytes の framing 差の言い換えで discriminator になっていなかった。
  真の discriminator(writer store offset / 静的参照 45vs0 / lb+switch 上限 / sentinel 整合)に置換。
- 「EXE 全体で 1 箇所」: 走査手法の限定なしの全称主張(→ 学び 1 と同根)。
- 比較の「式」自体を検証対象にする。既存 memory: feedback_identity_is_not_evidence /
  feedback_fabricate_in_incidental_fields(引いた線自体を検証)の実例追加。

## 5. verify-the-oracle 実例 — snapshot ペアの同一性を先に測る

ram_A/B を「同一戦闘の前後ペア」と仮定した snapshot diff oracle が破綻していた:
battle frame counter が A=1104→B=320 と**減少**(同一戦闘内は単調増加)= 別戦闘。
このため「-627 完全一致」filter が実差 -3 の真の HP(0x8016b0d0)を落とし、「この帯に HP 無し」
という反証まで生んだ。**diff を取る前に、2 標本が比較可能である根拠(単調 counter 等の内部時計)を測る**。
- 既存 memory: feedback_verify_the_oracle_not_just_the_match の実例追加。
- 同根の boss1 自身の教訓: ptrace_scope=1 から「/proc/pid/mem 不可」を推論で relay しかけた
  (実測では read 可能 = bwrap 配下で yama 非実効)。期待値を観測扱いしない、は relay 側にも適用される。

## 参照

- 成果 doc: degimon repo track1/track2 worktree の RE_vab_loader_orchestrator / RE_field_entity_array_rebase /
  RE_battle_damagecheck_caller + 各 REVIEW doc
- 検証 doc: VERIFY_runtime_capture_2026-07-25.md(585 行)
- 次 phase: MASTER_TASKS.md「2026-07-25 自律RE session 次 phase registry」
