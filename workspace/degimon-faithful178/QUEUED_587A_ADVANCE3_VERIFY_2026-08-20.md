【background 監査 session → boss1/worker1・★#587-A 材料の自己裏取り(source 直読)★・★run 0 本★】

■ 0. 読んだ器と枠(★これを書かないと検算不能★)
・tree = `/home/ken/Desktop/Digimon/degimon_world_remake`(branch=main・**HEAD=6980befd**)。
・★対象 3 file は HEAD と byte 同一★(`git status --short` が空)= WIP 混入なし。
・line 番号は `/home/ken/.claude/jobs/d5b396d4/tmp/maintree` でも同一を確認(2 tree 一致)。
・★log は撃っていません★。R0_batch.log は既存 file(`/home/ken/Desktop/Digimon/w1_runs580a/R0_batch.log`・全 133 行)を読んだだけ。

■ 1. ★逐語一致した claim(訂正なし)★
・(a) ★Dialogue/ 配下に `#if` は 1 つも無い★ = `grep -rn '#if'` の hit file 数 **0**。⇒ player build 混入は真。
・(b) ★DialogueRuntime.cs:2171 は VerifyEntry の中★ = 直近の外側 signature は **:2162 `public static bool VerifyEntry(DialogueEntry entry, out int matchedChars, out int emittedChars, out int oracleChars)`**。行本体 = `if (rt.State == DialogueState.WaitingAdvance) rt.AdvanceInput();`。
・(c) ★TextboxView.cs:156 は StartScenario の中で無条件★ = **:153 `void StartScenario(DialogueEntry entry)`** の第 1 文が `DialogueRuntime.VerifyEntry(entry, out _, out _, out _);`、`_rt = new DialogueRuntime()` は **その次の行(:157)**。⇒ ★1 周目 = VerifyEntry の rt、2 周目 = live の _rt★ という割当は正しい。
・(d) ★VerifyOnStart:29 は既定 false で別口★ = `public bool VerifyOnStart = false;`(:29)、唯一の読み手が **:95 `if (VerifyOnStart)` → :96 の 2 本目の VerifyEntry**。⇒ 別口で正しい。
・(e) ★_gateSeen は static★ = **DialogueRuntime.cs:1751 `static readonly HashSet<byte> _gateSeen`**、消費は **:1777 `bool first = _gateSeen.Add(op);`**、reset は **:1764**(明示 call のみ)。⇒ ★VerifyEntry の rt と live の rt が同じ集合を共有★は真。
・(f) ★§2 の R0 逐語★ = 一致。並びも記述どおり(1 周目 `0x0A ... pc=0x29 ⇒ 停止(初回)` → `VerifyEntry 101: MISMATCH matchedChars=0 emitted=0 oracle=277 warns=1` → 2 周目 `Begin entry=101` → `InputLocked=true` → `0x0A ... ⇒ 記録のみ(2 回目以降、続行)` → `JUMP-SKIPPED narrow-mode op=0x18(TABLE) @pc=0x2A fall-through` → `UNSUPPORTED op=0x57 len=4 pc=0xA6 ⇒ 停止(初回)` → `scenario finished → OnFinished` → `InputLocked=false` → `[MOVE]`)。
  ・★軽微訂正★: 引用の行番号は **79-86 でなく 77-89**(75-90 の窓で採取)。中身は逐語一致。

■ 2. ★訂正 1 = 「呼び元が Editor のみ」は 4 site 中 2 site で偽(結論は不変)★
・全 Assets の `AdvanceInput()` call site は **18**。player build(非 Editor/)は **7** = TV:227 / TV:358 / DR:2171 / DR:2223 / DR:2266 / DR:2348 / DR:2462。
・★live 到達可能は 3★(TV:227=人間入力・TV:358=_autoAdvance・DR:2171=VerifyEntry 経由)⇒ ★boss1 の「3 つ」は正しい★。
・但し残り 4 の到達経路は 1 種類でない:
  - DR:2223 VerifyFlow ← `Editor/Gamma1bFlowSweep.cs:68` のみ ⇒ ★「Editor のみ」真★
  - DR:2266 FlowRunStartProbe ← `Editor/Gamma1bFlowSweep.cs:41` のみ ⇒ ★真★
  - DR:2348 VerifyNarrow ← `Editor/NarrowModeVerify.cs:52` **＋ DR:2382 `BatchVerifyNarrow`(= player build 側の file 内)** ⇒ ★「呼び元が Editor/ 配下のみ」は偽★。BatchVerifyNarrow 自身の呼び元は **コードベース中ゼロ = -executeMethod 専用**。
  - DR:2462 DumpSections ← **呼び元がコードベース中ゼロ**(`grep DumpSections` は宣言 :2427 の 1 hit のみ)⇒ ★「呼び元が Editor のみ」は偽(呼び元が無い)★。
・⇒ ★live で発火しない という結論は 4 site とも真★。偽なのは ★理由の方★。
・★型★ = boss1 が立てた「player build に入るか / live で呼ばれるか は別の量」に、★3 つ目の量「誰が呼ぶか(Editor file / 同 file 内の -executeMethod entry / 呼び元ゼロ)」★が要る。★「呼び元が Editor のみ」で切ると -executeMethod 専用 entry が漏れる★。

■ 3. ★訂正 2 = §4 の「同じ env の読み手が 2 つ」は真だが ★gate が非対称★★
・TextboxView.cs:98 = `_autoAdvance = Environment.GetEnvironmentVariable("DEGIMON_DIALOGUE_AUTOADVANCE") == "1";` ⇒ ★AutoBoot 条件なし★
・FieldState.cs:149-150 = `_autoAdvance = _ctx.AutoBoot && Environment.GetEnvironmentVariable("DEGIMON_DIALOGUE_AUTOADVANCE") == "1";` ⇒ ★AutoBoot 必須★(`AutoBoot` は GameManager.cs:54 = `DEGIMON_AUTOBOOT == "1"`)
・⇒ ★「advance 合成と quit 政策変更の 2 つが同時に入る」は AutoBoot な run に限って真★。非 AutoBoot なら ★advance 合成だけ★が入る。
・⇒ ★足す判断をされる場合の枠は 2 行★ = 「AUTOADVANCE を足した run である」＋★「DEGIMON_AUTOBOOT の値」★(これが 1 なら FieldState.cs:477-482 の quit 政策も同時に変わっている)。
・quit 政策の中身(FieldState.cs:477-482 逐語)= `if (_autoAdvance) { bool finished = _ctx.Dialogue != null && !_ctx.Dialogue.IsPlaying; if (finished) _afterFinishTimer += dt; if ((finished && _afterFinishTimer >= AutoAdvanceGraceSeconds) || _postWarpTimer >= AutoAdvanceCapSeconds) { ... Quitting. } }`

■ 4. ★訂正 3 = 「Input に触れない」は AUTOADVANCE 経路のみ真・Update 全体では既に触っている★
・boss1 の gate 引用「228-229」は実体 **:229**(:228 は空行)= `if (_autoAdvance && _rt.State == DialogueState.WaitingAdvance) AutoAdvanceTick();` ⇒ ★env と WaitingAdvance だけが gate★は真(手前で `_rt == null` は return 済)。
・★但し同じ Update() の 2 行上、:226-227 = `if (_rt.State == DialogueState.WaitingAdvance && AdvancePressed()) _rt.AdvanceInput();`★、`AdvancePressed()`(:296-302)は ★`Input.GetKeyDown(Space/Z/Return/KeypadEnter)`★ = ★毎 frame Input を叩いています★。
・⇒ ★「AUTOADVANCE を足せば batchmode で入力を poll するかに答えずに済む」という利点は成立しません★ = ★その question は AUTOADVANCE の有無に関わらず既に踏んでいる★(:226 は既存 code)。
・⇒ ★足さない推奨は弱まりません。むしろ「足す側の利点」が 1 つ消えます★。

■ 5. ★私が撃っていないこと / 判らないこと★
・★run 0 本★。compile も land も撃っていません。
・★§3 の候補 X(0x57 実装後の止め手)は列挙していません★ = worker1 の発注(★合わせにいかない★)を潰さないため意図的に手を付けていません。
・★R0 の 1 周目が「VerifyEntry の rt」だという割当は log の並びからの推論★(2 周目 Begin の後にだけ `InputLocked=true` が出る、という間接証拠)。★rt の identity を印字した log は無い★ = ★直接証拠ではありません★。潰すなら VerifyEntry 側の Begin に印を 1 つ足す(= compile 1 本)が要ります。
