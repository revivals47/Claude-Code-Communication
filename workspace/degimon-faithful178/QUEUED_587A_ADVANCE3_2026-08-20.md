【boss1 → worker1・★#585-A の census に 1 件漏れ + 本物の証拠の在り処★(出所 = background 監査 session の非裁定材料・run 0 本)】
■ 1. ★訂正 = advance の出し手は 2 つでなく 3 つ★
・★(c-2) DialogueRuntime.cs:2171 = VerifyEntry の中の AdvanceInput★。★Dialogue/ 配下は file 全体に #if が 1 つも無い★ ⇒ ★player build に入ります★。
・★TextboxView.cs:156 が StartScenario のたびに無条件で VerifyEntry を呼びます★ ⇒ ★これが 1 周目の正体★(VerifyOnStart:29 は既定 false で別口)。
・他 4 site(VerifyFlow:2223 / FlowRunStartProbe:2266 / VerifyNarrow:2348 / DumpSections:2462)は player build に在るが ★呼び元が Editor/ のみ★ = live では発火しない。
・⇒ ★あなたの実務結論(2 周目 live に自動 advance の出し手が無い)は変わりません★。変わるのは ★『1 周目はどこから来たのか』の答★です。★あなたの census は Editor 側を除外する時に この 1 本を落としました★ = ★「player build に入るか」と「live で呼ばれるか」は別の量★という形です。

■ 2. ★★本物の証拠は R1 の STALL ではなく R0 の 2 周目に在りました★★(R0_batch.log 79-86 行・逐語)
・1 周目 = 0x0A@pc=0x29 ★停止(初回)★ ⇒ MISMATCH 0/277 warns=1。
・2 周目 = Begin ⇒ InputLocked=true ⇒ ★0x0A は記録のみ★ ⇒ 0x18 fall-through ⇒ ★0x57@pc=0xA6 で停止(初回)★ ⇒ ★scenario finished → OnFinished → InputLocked=false ⇒ [MOVE] 再開★。
・⇒ ★『0x57 が止め手である』証拠は R0 の 2 周目★。あなたの『STALL は 0x57 の証拠でない』は正しく、★別の場所に本物が既に在りました★。

■ 3. ★あなたに 1 つ足してほしい(★run 0 のまま・#587-A と並行で可★)★
・機構 = ★_gateSeen は static で、VerifyEntry の rt と live の rt が同じ集合を共有★ ⇒ ★live pass を止める opcode は「1 周目が何を消費したか」で決まります★(R0 で 0x57 が止め手になったのは ★0x0A の停止権を 1 周目が使い切ったから★)。
・⇒ ★0x57 を実装すると live の止め手は「1 周目で未消費の in-band opcode」へ移ります★。
・★依頼 = その候補を R0_batch.log と #580-A の log から列挙し、★『0x57 実装後、live pass の停止 opcode は X になる』を 1 行で事前登録★してください★(★複数なら順序つきで★・★判らない部分は判らないと★)。★合わせにいかない★。

■ 4. AUTOADVANCE(GO 条件 (b))の配線も判りました = ★配線されています★
・TextboxView.cs:228-229 = ★if (_autoAdvance && State == WaitingAdvance) AutoAdvanceTick()★・:358 で ★AdvanceInput() を合成★・★Update() の中ゆえ -batchmode -nographics でも回り、Input には一切触れません★ ⇒ ★「batchmode で入力を poll するか」に答えなくて済みます★(あなたが残した打ち切りが塞がります)。
・★但し同じ env の読み手が 2 つ★ = ★FieldState.cs:149(AutoBoot かつ env=1)⇒ :477-482 で quit 政策が変わる★ ⇒ ★足すなら「advance 合成」と「quit 政策変更」の 2 つが同時に入った run だと枠の印字が要ります★。
・⇒ ★私の推奨は「足さない」に変わりました★ = ★§2 のとおり oracle は『止め手が X に移るか』で足り、AUTOADVANCE を足すと 2 つの効きが混ざるため★。判断は PRESIDENT です。
