# step5 (p2) 設計doc: opcode 0x66 忠実実装(boss1 単一推奨、gate①上申用)

status: ★CLOSE(gate② land承認、PRESIDENT 2026-07-19 06:10)★ — c1-c5+O2(a)=f1b land(0bc6516..6256eaa+a430ce9、push HOLD)。検証=全条項充足(d1改訂3項/d2字義/d3/d4/OFF 3系統/(vi)訂正追認)。ON側user可視挙動=user live凍結維持。残=OI-2(0x67)/OI-3(selector 3段目)/OI-4(flag#1)/宣言gap(final_run)/B1 count wording。
(初版status: 上申 gate①裁定待ち 2026-07-19 04:5x)入力=STEP5_P1_RE_worker2.md(p1+§8 addendum、boss1裏取り済)+ STEP5_P1_XCHECK_worker1.md(blind x-check ★Q1-Q4 全CONFIRM・DIFFゼロ★、addendum flag#1 gate も worker1 独立CONFIRM=二重独立成立)。

## 0. 正premise(p1で確定、旧labelの訂正)

- ★0x66 = scene遷移/story前進 driver★(handler 0x800EE72C、opcode総長2=operand 1byte)。
- ★PREREG §1 step5 の旧label『0x66(DF70消費)』は誤premise★: handler+呼出先1段に DF70(真slot=0x8013DF70)アクセス無し(scope限定、2段以深未測定)。census『warp class』も REFUTE 方向。挙動観測(直前0x67固定ペア/直後op無し/idle_stop 464/464)は正。
- DF70 reader 未解決=★open item として起票のみ★(step5 の値源設計から DF70 を除外。PREREG §6-2 の維持裁定は writer 側実測として有効なまま、消費側の帰属だけ取り下げ)。
- 実行実測: 464回/463 entry、prologue 末尾(0x1B→0x1A→0x27→0x67→0x66)に1回=検証母数463。

## 1. handler 忠実仕様(観測ベース、実装の対象面)

| block | EXE 実測 | 忠実度クラス |
|---|---|---|
| B1 operand fetch | 1byte 消費+PC前進(0x800f0edc)。operand は local に格納(後続で上書き=semantic 未確定) | ★実装(decode 忠実の核)★ |
| B2 progress counter | E12C(gp-0x6ce0)halfword ++、9999 飽和 | 実装(raw slot) |
| B3 var-list loop | var[0xfa]起点で 0xfb.. を反復処理(register set 系) | 構造実装+semantic gap宣言 |
| B4 scene selector | 0x800cfec4→0x800aeca8(arg=E104 halfword)。camera 3語 copy+param-list start(0x80107258=+0x66c/+0x670 init、CONFIRM)+scene-id dispatch(0x80105be4)→結果code | ★宣言gap(下記 D2)★ |
| B5 結果 -1 枝 | retry counter(0x8016B100)--、0で座標reset、script label 0x4de へ PC seek、exit | 構造実装(raw slot+seek) |
| B6 結果非-1 枝 | ==0 で座標copy block→merge: ★event-flag#1 bit test(0x800f0c74→0x800f191c、addendum確定)★。set=action(0x800bd820(-1,1))+exit / clear=scene state init→★0x67 handler へ構造 fall-through(正規分岐)★ | flag gate=実装、fall-through=D1 |

remake 側の既存 infra 接地(boss1 直読): event-flag bank は C# GameState が EXE 0x800f191c と同型 model で保持(DialogueRuntime.cs:170)=flag#1 read は既存 API で可。var bank も同様。0x66/0x67 は現在未実装(dispatch switch 20件に無し)。

## 2. 設計判断点と★単一推奨★

### D1: scope = 0x66 単独 vs 0x66+0x67 pair
- 事実: fall-through は flag#1 clear 時の正規分岐で、0x67 handler 本体を実行する。しかし ★0x67 自身の全長RE(規範7)は未実施★。
- ★推奨=Option S: 0x66 単独★。fall-through 枝は『branch 分類まで忠実(flag#1 gate で2分岐を判別・log)+ 0x67-body 実行は宣言gap(loud log)』。0x67 実装は次 opcode 候補(698実行=最多)として ladder 次段へ(その時 pair 完成)。
- 理由: 規範7(実装前全長RE)を 0x67 に対して守ったまま step5 を進められる唯一の形。census 動的挙動(両枝とも trace 上は停止で終わる: set枝=exit、clear枝=0x67 body の set+YIELD)とも整合し、over-claim なし。
- 代替=Option P(pair 同時): 0x67 全長RE を p1 追補してから両方実装。忠実度は上がるが step 肥大。ladder 順序で得られるものを先取りしない。

### D2: scene selector(B4)の扱い
- ★推奨=宣言gap★: selector の scene-id dispatch を remake scene 機構(RunScene 等)へ配線するのは、descriptor 表 0x8013CDB4 の解釈と3段目(0x801066cc)RE が未了のため★発明になる=禁止★。ON 時は『selector 到達を loud log(E104 実値付き)+ 結果 code は成功系として B6 へ』の構造 stub とし、gap を doc/log 両方で宣言。
- 配線は follow-up(3段目RE 完了後の別 step)。

### D3: 値源
- DF70 は step5 から除外(§0)。B2/B5 の counter は新規 raw slot model(E12C/B100、baseline C 台帳方式)。

## 3. 実装形(PREREG 規範準拠)

- ★flag opt-in・既定OFF★(PREREG §2-2、land=PRESIDENT gate②)。OFF=現行 bit 不変。
- OP_SCENE_DRIVER = 0x66、Len=2 を oplen 表/walker にも反映(decode 忠実=463 entry の walker desync 恒久解消)。
- ON 時: B1-B2-B3(構造)-B4(宣言gap stub)-B5/B6(flag#1 gate 2分岐+各exit)。全branch に loud log。
- 配線確認義務: grep 目視+log 実測、ON/OFF 両側 acceptance。
- worker 割当: worker2=C# 実装(p3)、worker1=spec 照合 review、worker3=検証 run(O2 測定と直列化)。

## 4. (p4) 差分テスト prereg(★2026-07-19 05:0x p3着手時固着・以後改訂禁止=PRESIDENT 補足②★)

### gate①裁定記録(PRESIDENT 05:05)
- ★GO承認(D1/D2/D3/実装形/d1-d4/OI-1〜4 全採用)★。
- ★補足要件(p3)★: clear枝の宣言gap stub の exit 意味論=★YIELD相当を保証★し、ON時に walker が hang/desync しない(実測『両枝とも trace 上停止で終わる』と同型 exit)ことを ★d2 assert の一部に含める★。

### ★revision history(Pattern 4、PRESIDENT裁定 2026-07-19 05:55)★
- **d1 改訂(裁定(A)承認)**: 旧条項『full sweep で walker desync 0件。0x66 到達 463 launch entry を全 cover』→ ★新条項『decode忠実度3項: (i)desync 0 (ii)1回/launch+直前0x67固定ペア構造一致 (iii)Len=2』★。
  - 改訂理由: 『463全cover』は census 次元(実プレイ savestate+jump-taken)固有の到達集合で、remake sweep(fresh state+narrow mode)とは 0x19条件分岐426/0x17=27/0x18=4 の state 駆動分岐により原理的に一致不能(STEP5_D1_RECONCILE_worker2.md、測定確定)。『115 distinct』は集計artifact(非unique local index)で実態=500 launch・全1回/launch。
  - ★宣言gap((A)条件2)★: census 正本 final_run.jsonl(464/463)は disk 上に不在(boss1 実査: real_traces/ に derived txt と sweep_225.jsonl.gz(444/444)のみ)→ ±20 の絶対数照合は宣言gapとして添付。構造(1回/launch・0x67ペア)は sweep_225 で同一確認済。
- **d2 是正(裁定(B)承認)**: 条項は不変。★現実装(c3 break=dispatch継続)が『直後op非実行』条項に未充足と判明(post-0x66 に 0x1c SetFlag 等を 0xFE まで余剰実行=実バグrisk)→ 実装side是正 = c5(ON時のみ・両枝とも launch 停止の exit 忠実化)+ re-sweep★。re-sweep は『0x66後に実行された後続op種別=ゼロ件』を直接 assert に含める((B)条件2)。

### run-level条項(vi)の訂正記録(boss1裁定 2026-07-19 06:0x、開示)
- re-sweep dispatch時に boss1 が追加した run-level 条項『ON/OFF pre-existing warning 一致』は、★c5 の early-stop(post-0x66 非実行)が OFF 側でのみ到達していた警告 5 件(0x16 loop-guard、target 5 site 特定済)を ON 側で除去する意図効果を考慮しない boss1 の mis-spec★。
- 訂正後条項=『★ON warning 集合 ⊆ OFF warning 集合(NEW ON warning=0件)★』→ 実測 ON17 ⊆ OFF22(除去5=全て post-0x66 0x16 loop、追加0)=★充足★。除去5件は d2 fix の直接傍証(post-0x66 code が実行されなくなった)。
- 本条項は設計doc §4 固着項(d1-d4/非退行)の外の run-level 追加項ゆえ boss1 委譲権限内で訂正、PRESIDENT へ開示(gate②上申に含む)。worker3 の literal 未充足報告(実質green宣言拒否)=規律どおり。

### 固着目標値(d1のみ上記裁定で改訂、他は不変・以後改訂禁止)
- d1 decode: full sweep(1,278 entry 母集団、census 同窓)で walker desync ★0件★。0x66 到達 463 launch entry を全 cover。
- d2 exit: ON時、0x66 実行 464/464 相当の全 site で『直後に op を実行しない』(set枝=exit / clear枝=stub 後 YIELD相当 exit)。★hang/無限loop 0件★(PRESIDENT補足)。
- d3 counter: E12C model 増分=0x66 実行回数と1:1(464)、9999 飽和条件を実装(飽和到達は本 corpus では非発生見込み=発生時は loud log)。
- d4 flag 分岐: flag#1 set/clear の分岐 log が全実行で排他に1:1(両枝同時・無分類 0件)。
- 非退行: 既存 headless verify(CutsceneVerify178 等)緑 + care harness 19/19 緑 + ★OFF側=現行 bit 不変★。
- 完成 claim=user live 実視覚まで凍結。

## 5. open items(起票のみ)
- OI-1: ★RESOLVED(2026-07-19 worker1 census、boss1 disasm裏取り済)★ — DF70 直接reader=2件のみ。核心=0x800F0214(fn 0x800F0188 section-init)が `lb DF70 → sh E104(0x8013E104)` 転写=★0x66 は E104 経由で DF70 値を間接消費★(census『0x66=DF70消費』は挙動として真・直接アクセスREFUTEも真=供給が section-init 経由の間接だった)。真経路=DF70→E104→scene selector。C# 設計影響なし(B4 stub は E104 log のまま正、DF70→E104 供給鎖は engine 側=宣言gap域)。残=pointer-base 間接readのゼロ証明不可(honest gap)+struct配列0x8016B104意味論(別arc)。
- OI-2: ★RE+OPTRACE完了(2026-07-19 06:4x)★ — 0x67=『u16 set(reader#1、Len4)+ BIOS RestoreState/longjmp(0x800913c0=A0:0x14、jmp_buf=VM 0x80164068)で VM loop へ yield-continue』。reader#2=動的DEAD(11/11、静的無条件callだがlongjmpで非到達)。★遡及insight: 0x66 clear枝の『0x67 handlerへのfall-through』も直前0x800EE98Cの同一longjmp callにより動的DEAD=census idle_stopの機構的説明。c5の両枝launch停止=原盤実挙動に一致(Option S宣言gapは実質解消、実装対象でなかった)★。0x67実装=次opcode scoping上申へ。
- OI-3: scene selector 3段目(0x801066cc/descriptor 表 0x8013CDB4 解釈)RE → D2 配線 step。
- OI-4: flag#1 の story event 意味論(flag-name 表未同定)。
