# 0x67 (p2) 設計doc: u16-set + frame-yield 忠実実装(boss1 単一推奨、gate①上申用)

status: ★CLOSE(boss1委譲検収 land、2026-07-19 07:1x)★ — y1-y4=f1b land(57c6321/8cc9f2e/8e358ca/83c1874、push HOLD)。検証=★全条項literal充足★(f1 desync0/f2=361 pair u16 1:1(oracle強化=DG.SCN entry-pattern照合、prereg基準超過だが判定不変・開示済)/f3=(a)-(d)全assert+★(b)59長resume chain直接証拠★/f4 OFF-inert+care3系統+warning等集合)。worker1 review=APPROVE(blocker0)。字義未充足ゼロ=D4条件非発動。ON側=user live凍結維持。
(gate①GO=07:05、実装注意f3訂補済。初版status: 上申 07:0x)入力=OI2_0x67_RE_worker1.md(全長RE)+OI2_0x67_OPTRACE.md(worker3、11/11均一実測)+boss1 VM loop再入点disasm(本doc §1=PRESIDENT補足2の決着根拠)。三重接地。

## 0. 正premise(p1級確定)

- ★0x67 = Len4(op+skip1+u16)★: reader#1(0x800f0e6c)が u16 を [gp-0x6ca8]=0x8013E164 へ set。
- marker: sb 0x67 → [gp-0x6cbc]=0x8013E150(handler共通の last-op marker slot)。
- ★BIOS RestoreState(A0:0x14、0x800913c0)を jmp_buf=VM 0x80164068・ret=2 で無条件発火=longjmp★ → 以降(reader#2)=動的DEAD(OPTRACE 11/11、実装しない)。
- premise-check決着: 『u16 set+YIELD』=CONFIRM/『WAIT-N-FRAMES』=REFUTE(countdown無し。ただし下記のとおり1 frame境界は生む=folkloreの由来)。

## 1. ★yield意味論の決着=frame yield(PRESIDENT補足2の根拠disasm)★

boss1直読(2026-07-19、exedis):
1. **setjmp site**=VM run関数内 0x800F076C: `jal 0x800913b0`=★SaveState(A0:0x13)★(buf=0x80164068)。返値 s1 で分岐:
   - s1=0(初回)→ dispatch loop 0x800F0780(opcode fetch)へ。
   - ★s1=1 → 0x800F08C8→`beq s1,1→0x800f0764`=re-setjmp→loop継続=【同tick継続】★。
   - ★s1=2 → 0x800F08C8→(≠1,≠3)→0x800f0910→[gp-0x6cb0]check→0x800f0968/0x970=`lw $ra..jr $ra`=★VM run関数のreturn=【このtick終了=frame yield】★(次tickに再入しsetjmpから再開、script PCは0x67の4byte消費後=次opへ)。
   - s1=3 → finalize(0x800f3114+set-register)後にexit(変種)。
2. **通常handler共通epilogue 0x800EF318**=`RestoreState(buf,1)`=★ret=1=同tick継続★(全通常opはこれ)。
3. **0x67のみ ret=2** ⇒ ★0x67=『u16 set + このtickのVM実行を終了(frame yield)、次tickから継続』★。census『0x67→0x66固定ペア』=0x67がyieldし次tick冒頭で0x66、と整合。

## 2. ★単一推奨(実装形)★

- OP_FRAME_YIELD=0x67(命名は実装時裁量)、Len=4。flag opt-in既定OFF(新flag DEGIMON_OP67=1、同型pattern)。
- ON時: (Y1)skip1+u16消費→raw slot RawE164 へ格納 (Y2)marker raw slot RawE150=0x67 (Y3)★tick-yield=このtickのdispatch loopを終了(State=Running維持、PC=+4確定)、次tickで継続★。
  - ★Finished(0x66 c5型launch停止)でも plain break(同tick継続)でもない第3のexit=remake dispatch loopのtick境界機構で実装(worker2裁量、hang guard整合)★。
- OFF時: 現行bit不変(従来default break=同tick継続)。
- reader#2相当=実装しない(動的DEAD、docコメントで根拠明記)。0x800f0910側の[gp-0x6cb0]付随処理=scope外(VM run側の機構、opcode実装でない)。

## 3. (p4) 差分テスト prereg(p3着手時固着・事後改訂禁止)

- f1 decode: full sweep desync 0+Len4(0x67は既存oplen表で4=OFF decode不変を含む)。
- f2 raw slot: ON時 [OP67] log の u16 実値が stream byte と1:1(sample site指定=corpus流用+0x67高頻度siteから固定N=10 site を p3着手時に列挙固着)。
- f3 ★tick-yield挙動(PRESIDENT実装注意で訂補、固着)★: ON時、(a)『0x67 の直後opは★同tickで実行されない★』直接assert (b)★『次tickで★確実に再開★し直後opが実行される』直接assert★(yield成立だが再開が来ない永久停止をhang 0のみに依存させず、再開event自体をpositive assert) (c)hang/永久停止 0件 (d)0x66 c5 idle_stop(launch終了)との区別を log 次元で明示(0x67=yield-resume/0x66=stop)。
- f4 非退行: OFF bit不変([OP67] 0件+CutsceneVerify178 baseline)+care 3系統+ON warning⊆OFF(NEW=0)。
- 完成claim=user live凍結(ON側)。

## 4. 割当・land

worker2=p3実装/worker1=spec照合review/worker3=検証run。land=boss1委譲検収(gate②列挙外、step4 D4同条件=字義未充足の帰属判断はPRESIDENT裁定へ)。

## 5. open items
- OI-8: ret=3 変種の発火元と意味(本opcode scope外、VM run機構)。
- OI-4(flag#1意味論)/OI-3(selector 3段目)/OI-5b(spawn block)=継続。
