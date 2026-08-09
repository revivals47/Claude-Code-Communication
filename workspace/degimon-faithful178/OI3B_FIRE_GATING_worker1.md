# OI-3b (C) scene switcher 発火 gating 条件 静的 RE — worker1

**date**: 2026-07-19 / worker1 / ★read-only 静的 EXE RE(コード変更ゼロ)、cutoff 規範(2-3反復)、promote 禁止★
**material**: EXE=slps_017_97.bin(headerless dump、BASE=0x80090800、tool=scratchpad mdis.py/xref.py capstone MIPS)。gp=0x80144E0C。
**PS-EXE header 実測**: slps_017.97.orig=t_addr 0x80090800/t_size 0xad800→text 0x80090800..0x8013e000(観測、header parse)。
**規律**: 観測(disasm/hex/xref paste)/推論/honest gap 区分。値/addr は直読のみ額面。

---

## 0. 結論(単一表)★boss1 主仮説(0x8005ca7c gate)は命令順序で REFUTE、真 gate は別軸★

| # | 問い | 結論 | 次元 |
|---|---|---|---|
| A | 0x8005ca7c==-1 が switcher 非到達を gate するか | ★NO(REFUTE)★。0x8005ca7c は selector 内で dispatch 0x80105be4(switcher 内包)**より後**に実行=switch を gate しない。s0 は post-switch カメラ/座標 phase 分岐 | 観測(命令順序) |
| A' | 0x8005ca7c の実体解析可否 | ★不能(この静的 EXE に非収録)★。0x8005ca7c < text base 0x80090800=両 PS-EXE の範囲外(低位 segment/別 load) | 観測(header) |
| B | switcher 0x800cfdf0 の真 fire/no-op gate | record∈[1,0x21] かつ (record,variant)≠current(gp-0x6da2,gp-0x6da0)→FIRE。同一→return1(no-op、無[SCENE-SWITCH])。範囲外→return0 | 観測(disasm) |
| C | 0x800cfec4(0x66→selector間)の役割 | ★scene RESET★=teardown 後 gp-0x6da0(current variant)=-1。0x66 handler が selector 直前で**必ず**呼ぶ→variant-check が常に相違→switcher は毎回 FIRE | 観測(disasm+xref) |
| D | ∴ 非決定「(33,1) 出たり出なかったり」の真因 | switch 自体は毎回発火。**どの variant か**が state 依存。(33,1) vs (33,0) の分岐 determinant=★[0x80163784+0x253]=0x801639D7★(scenario work buffer byte)× partner form | 観測(chain)+推論(非決定帰属) |
| E | busy flag gp-0x6b26 | selector entry で SET / phase 分岐前に CLEAR(同一 call 内)。40+ reader=遷移中の他系統抑止・再入防止 signal。**当該 switch の fire/no-fire を gate しない** | 観測(xref) |

---

## 1. selector 0x800aeca8 全長再走(観測)★H4: 0x8005ca7c は switcher より後★

単一 caller=0x800ee7fc(0x66 handler、xref 確定)。構造(観測):
```
800aeca8 entry:
  800aecc4  sb 1, gp-0x6b26           ; ★busy flag SET=1★
  800aecc8-d0c  struct 0x8017b04c の +0x78/7c/80 → 0x8014_1fd8/dc/e0 保存(現coords)
  800aed10  jal 0x800e3940 / 800aed18 jal 0x800bde30 / 800aed20 jal 0x800e9a40  ; setup
  800aed2c  a0=s2; jal 0x80107258      ; ★param-list(gp-0x6bf4 flag をここで SET、§5)★ → s1
  800aed40  a0=s2,a1=s1; jal 0x80105be4 ; ★scene-id dispatch=switcher 0x800cfdf0 を内包(§5)★
  800aed48  jal 0x8005ca7c → v0         ; ★switch より後★
  800aed50-5c  v0 を byte 符号拡張 → s0
  800aed60  sb zero, gp-0x6b26          ; ★busy flag CLEAR=0★
  800aed68  bne s0,-1,0x800aedbc        ; s0==-1→fall-through(0x800aed70)/ s0≠-1→0x800aedbc
  [0x800aed70 s0==-1] 0x1d42-=0x1e,0x1d40-=0x14, a0=-1 jal 0x800ebd48, gp-0x6d84=1 → exit
  [0x800aedbc] bnez s0,0x800aee24 ; s0==0→0x800aedc4(0x1d42-=a,0x1d40-=6,0x1d3a+=2,jal 0x800ab7b8)→exit
  [0x800aee24] bne s0,1,exit  ; s0==1→0x800aee30(jal 0x800f1698/0x800e01c0、struct 0x78-84→coords、jal 0x800ebd48/0x800ab7b8)→exit
```
- ★核心★: switcher を呼ぶ 0x80105be4 は 0x800aed40(=0x8005ca7c 0x800aed48 より前)。∴ **0x8005ca7c の戻り s0 は switch 判定に一切関与しない**。s0∈{-1,0,1} は switch 完了後の**カメラ/座標 phase**(0x1d40/0x1d42/0x1d3a=表示座標系、0x800ebd48/0x800ab7b8/0x800f1698=描画/カメラ task)を選ぶだけ。
- ★H4(仮説の外)★: boss1 主仮説「jal 0x8005ca7c→s0、s0==-1 で switcher 非到達(retry/座標調整枝)」は、**s0==-1 枝が座標調整なのは正しい**が、それは switch **後**の phase であって switch を skip させる gate ではない。命令順序が反証。

## 2. switcher 0x800cfdf0 の真 gate(観測、決定的)

```
800cfdf0(a0=record=s0, a1=variant=s1):
  800cfe08 blez s0,0x800cfe1c          ; record<=0 → invalid
  800cfe10 slti at,s0,0x22 ; bnez at,0x800cfe28 ; record<0x22 → valid
  800cfe1c v0=0; b 0x800cfeac           ; ★INVALID → return 0★
  800cfe28 v0=[gp-0x6da2](lh)           ; current record
  800cfe30 bne s0,v0,0x800cfe54         ; record 相違 → SWITCH
  800cfe38 v0=[gp-0x6da0](lh)           ; current variant
  800cfe40 bne s1,v0,0x800cfe54         ; variant 相違 → SWITCH
  800cfe48 v0=1; b 0x800cfeac           ; ★同一(record,variant) → return 1(NO-OP)★
  800cfe54 jal 0x800cf074 / 800cfe5c jal 0x800cf0a8   ; teardown
  800cfe64 v0=[gp-0x6da2]; 800cfe6c beq v0,s0,skip     ; record 変化時のみ
  800cfe78 a0=s0; jal 0x800cf400         ; ★CD file load(record 変化時のみ)★
  800cfe88 sh s0, gp-0x6da2              ; current record 更新
  800cfe94 sh s1, gp-0x6da0              ; current variant 更新 → finalize → return
```
- ★C# SceneSwitch(GameState.cs)と 1:1★: record<=0||>=0x22→0 / record==RawE06A&&variant==RawE06C→1 / else 更新→2。gp-0x6da2=RawE06A(current record)、gp-0x6da0=RawE06C(current variant)。
- ★fire/no-op を分ける唯一の runtime state=current(gp-0x6da2, gp-0x6da0)★。

## 3. 0x800cfec4 = scene RESET(観測、item 3)

```
800cfec4: jal 0x800cf074 / jal 0x800cf0a8   ; teardown(§2 と同型)
800cfedc: v0=-1 ; sh v0, gp-0x6da0           ; ★current variant = -1★(record gp-0x6da2 は不変)
          jr ra
```
- caller(xref)=7 sites: **0x800ee7f0(=0x66 handler、selector 0x800ee7fc の直前)** / 0x800f0dc8 / 0x800f16f8 / 0x800f17a4 / 0x800f1828 / 0x80105108 / 0x80105944。
- ★効果★: reset 後 current=(gp-0x6da2=stale, gp-0x6da0=-1)。次の switcher(0x21,variant) は variant∈{0,1,2,3}≠-1 ゆえ **variant-check が必ず相違→FIRE 強制**。record が stale で 0x21 と異なれば CD load も伴う。

## 4. 0x66 handler 0x800ee72c の制御フロー(観測)★reset+selector は無条件到達★

```
800ee72c a0=sp+0x43; jal 0x800f0edc          ; local state 初期化
800ee738-758 gp-0x6ce0(global counter)++ (cap 0x270f)  ; 分岐は増分 skip のみ、合流
800ee75c a0=0xfa(250); jal 0x800f0ac8 → v0    ; ★script byte 読取(§5)★
800ee768 [sp+0x43]=v0
800ee774 beqz v0,0x800ee7f0                   ; ★v0==0 → 直行 reset+selector★
800ee77c [sp+0x43]=0xfb(251); b 0x800ee7dc    ; else state=251 で loop へ
  [loop 0x800ee78c..0x800ee7e8] state 251→253 を jal 0x800f0ac8/0x800f50a8/0x800f0cd0 で処理
800ee7e8 bnez (state<0xfe) → 0x800ee78c        ; state<254 で loop
800ee7f0 jal 0x800cfec4                        ; ★scene RESET★
800ee7f8 a0=[gp-0x6d08](slot idx); 800ee7fc jal 0x800aeca8  ; ★selector★
```
- ★0x800ee72c–0x800ee800 に早期 jr $ra 無し(観測)★。beqz 直行路も loop 路(state 254 で fall-through)も **必ず 0x800ee7f0(reset)→0x800ee7fc(selector)** に到達。∴ **1 回の 0x66 実行内で switch は必ず発火**(handler が起動する限り)。
- beqz(v0=0x800f0ac8(250))は「直行 vs loop(script cmd 251-253 再生)」の分岐であって、switch の有無ではない(両者 switch)。

## 5. dispatch 0x80105be4 入力源 + variant 決定機構(観測)★真の非決定軸★

dispatch は全 form/flag/slot ケースで switcher を呼ぶ(6 call site: 0x80105c54/ca4/d5c/d74/d9c/db4、skip 路なし=観測)。variant を決める入力(観測):

| 入力 RAM | 由来(観測) | variant への効果(§1表 OI-3a と整合) |
|---|---|---|
| current-slot form | `[gp-0x6dec]`(base、writer 0x80118ef8)+0x66d → descriptor 0x8013cdb4[form] 2重 deref | ==0x73 → **variant 3**(0x80105c40) |
| flag **gp-0x6bf4** | writer=**0x801072ac 単一**(param-list 内) | ==1 → **variant 0**(0x80105c8c) |
| slot index | `[gp-0x6d08]`(writer 0x800f021c=`[gp-0x6e9c]` byte) | ∉[2,0xa) で別枝 |
| E104-slot actor form | descriptor 経由 | <0x43 or ≥0x70 → variant 1 / [0x43,0x70) → table[form-0x43]@0x801389E8 |

★flag gp-0x6bf4 の set 条件(0x801072a0)★:
```
801072a0 a0=0xfa(250); 801072a4 jal 0x800f0ac8 → v0 ; 801072ac sb v0, gp-0x6bf4
```
= **flag = 0x800f0ac8(250) の戻り** = 0x66 handler の beqz(0x800ee774)が test するのと**同一 byte**。

★0x800f0ac8(N) の実体(観測)★:
```
800f0ac8: v1=a0(byte); v0=[gp-0x6cec](script base ptr); v0=[v0+v1+0x159](lbu); jr ra
```
= `[ [gp-0x6cec] + N + 0x159 ]`。N=250 → offset 0x253。
★gp-0x6cec の値(観測、writer 0x800f0044 単一)★: `lui 0x8016; addiu 0x3784` = **0x80163784**(静的 work buffer 群の 1、隣接 0x8016f784/0x80161784/0x80163a20 と一括 init)。
∴ determinant byte = **0x80163784 + 0x253 = 0x801639D7**。

★機構★:
- `[0x801639D7]`==1 → flag gp-0x6bf4=1 → dispatch が **variant 0 強制** → **(33,0)**(handler は loop 路)。
- `[0x801639D7]`==0 → handler 直行、flag=0 → variant は form 由来 → partner form が range なら **(33,1)**。
- ==その他 → flag=その他(≠1)→ variant は form 由来(loop 路)。

## 6. busy flag gp-0x6b26(観測、item 2)

- writer: 0x800aecc4(selector entry=1)/0x800aed60(clear=0)/0x80105e88/0x801064f4/0x800ac3c4/0x80115bb0。
- reader: 40+ 箇所(VM/input/actor/描画系に分散、`lb`)。= ★「scene 遷移中」抑止 signal★(遷移窓で他系統が動くのを止める、再入防止)。
- ★当該 switch の fire/no-op を gate しない★: selector 内で SET→(param-list+dispatch+phase)→CLEAR が同一 call で完結。switcher の判定(§2)は gp-0x6b26 を読まない(観測)。
- honest gap: 別 setter(0x80105e88 等)が併走 scene op を示す→gp-0x6b26==1 中に 0x66 が来た場合の再入挙動は未走査(cutoff)。

## 7. 結論=(33,x)を決定的に発火させる注入可能 RAM 状態集合(item 4)

★switch 自体は 0x66 handler 到達で毎回発火(§3-4)★。worker3 capture trigger が制御すべき state:

| 軸 | RAM(注入可能) | (33,1) を出す条件 |
|---|---|---|
| ① 0x66 到達 | scenario PC / section state(VM が 0x66 opcode を実行する section へ進行) | 0x66 が起動する(未起動なら何も出ない=非決定の「出ない」側の主因候補) |
| ② variant=1 分岐 byte | **0x801639D7**(=[gp-0x6cec 0x80163784 + 0x253]) | **≠1**(==1 なら (33,0) 強制) |
| ③ current-slot form | `[gp-0x6dec]`+0x66d → descriptor 0x8013cdb4 | **≠0x73**(==0x73 なら (33,3)) |
| ④ slot index | `[gp-0x6d08]`(←[gp-0x6e9c]) | **∈[2,0xa)** |
| ⑤ E104-slot form | descriptor 経由 actor form | <0x43 or ≥0x70(→1 直) / [0x43,0x70) で table[form-0x43]==1 |
| ⑥ current scene(fire vs CD load) | gp-0x6da2(record)/gp-0x6da0(variant) | reset で gp-0x6da0=-1 化ゆえ fire は保証。gp-0x6da2≠0x21 なら CD reload も |

★非決定「同一 launch bit でも (33,1) 出たり出なかったり」の帰属(推論)★: ①②③⑤ は launch state の「bit 集合」に**含まれていない可能性が高い動的 RAM**(特に ②=0x801639D7 scenario work buffer、③⑤=descriptor 動的 record)。これらが capture 対象外なら同一 launch bit でも分岐が変わる=worker3 隔離の「隠れ入力 class」の実体。→ ★capture 時に ①-⑥ を明示 dump/注入すれば決定化★(hidden-input completeness oracle の適用)。

## 8. honest gap / cutoff(promote 禁止)

- ★0x8005ca7c 実体=解析不能(text 非収録、§0-A')★。s0 が -1/0/1 のどれを返すかの機構は別 segment ゆえ静的追跡不可→**switch gate でないため本 task には不要**(post-switch phase のみ)。必要なら full RAM dump(worker3 DuckStation)で 0x8005ca7c 領域を採取。
- 0x801639D7 が **どの script/操作で 1 になるか**(scenario writer)=4-5段目 cutoff。worker3 が 0x66 発火時点で 0x801639D7 を dump するのが最短(注入 oracle)。
- 0x800f0cd0/0x800f50a8(loop 路 script cmd 処理)が form/flag/scene state を mutate するか=未走査 cutoff(直行 vs loop で最終 variant が変わりうるか未確定)。
- gp-0x6b26==1 中の 0x66 再入挙動=未走査(§6)。
- descriptor 0x8013cdb4 の record が dynamic に何を指すか=worker3 実測領域(OI3A_DESCRIPTOR_RAM_RE 参照)。

## 9. 自己訂正 trail(H4、feedback_hypothesis_space_openness)

boss1 主仮説(0x8005ca7c==-1 で switcher 非到達)を **measure-first(命令順序直読)で REFUTE**。0x8005ca7c は実在し s0==-1 枝は座標調整だが、それは switch **後**の phase であり gate ではない(§1)。真 gate は (a)switcher 内 same-scene check(§2)+(b)reset による -1 強制(§3)+(c)dispatch の variant 計算(§5)の 3 層。非決定は「switch の有無」でなく「variant 値」の軸(§7)。boss1 仮説の「retry/座標調整枝」観察自体は正しく、解釈(gate)のみ訂正。
