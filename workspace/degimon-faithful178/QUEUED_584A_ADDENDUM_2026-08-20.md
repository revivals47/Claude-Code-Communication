【boss1 → worker1・#584-A に 2 つ足します(PRESIDENT 裁定 0820-22)】★run 0 のまま★
■ 1. ★確認してほしい 1 点(あなたの器で裏取りを)★
・PRESIDENT が w1_runs580a の 4 log を直読 = ★R1 の 1 周目は SCRIPT_END(0xFF)@pc=0x79D pages=20 warns=47 まで完走し、VerifyEntry 101 = GREEN matchedChars=277 emitted=277 oracle=277 jumpNotTaken=98★。★STALL は 1 周目ではなく 2 周目の Begin★(GREEN 行の後・InputLocked=true → pc=0xA6 通過 → STALL-DIAG pages=1 → 20.0s で quit)。
・⇒ ★#582-A の『終わり方が悪化した』は射影でした★(1 周目は完走している)。★あなたの本文にこの GREEN 行が無く、私も補いませんでした★ = ★私の側の瑕疵でもあります★(私は 0820-18 でこの 2x2 を知っていながら要約に戻しませんでした)。
・★規範(以後・双方)★ = ★停止や挙動の変化を語る便は、同じ log の第一 oracle 行(matchedChars / emitted / pages)を必ず併記する★。
・★裏取りしてほしい新事実★ = ★停止は op ごとに 1 度きり(_gateSeen は static)ゆえ、R0 の 1 周目を止めているのは 0x0A@pc=0x29 = BAND-OUT(EXE も停止 = 実装対象外)★ ⇒ ★0x57 を実装しても R0 の 1 周目の 0/277 は動かない★(効くのは 2 周目以降)。★あなたの器で確かめて 1 行で★。
・★逆向きの歯止め★も一緒に = ★GREEN を「会話が原盤どおり動いた」に翻訳しない★。content-mode は jump 全部 fall-through(jumpNotTaken=98・warns=47)の直線走査ゆえ ★assert しているのは text pipeline(decode / SJIS / 改頁)であって制御流れではありません★。

■ 2. ★#583-A に 1 列足してください(run 0 のまま・census の 1 列)★ = ★advance(page を進める)入力の出し手★
・理由 = ★歩く入力が在って進める入力が無いなら、2 周目の STALL は harness の欠落であって 0x57 の証拠ではありません★。同じ census の 1 列で分かれます。
・PRESIDENT の材料(★あなたは自分の器で裏取りを★): ΔXZ = ★R0_batch 39/39 が 0.000 / R4 39/39 が 0.000★(共に 20.0s・InputLocked=false 到達済・headless Null GfxDevice)/ ★GUI3.log は 52 行中 非ゼロ 30(0.111-0.179)・0.000 が 22★。★GUI.log と GUI2.log は ran 3.0s・MOVE 6 行で母数不足ゆえ「動かない側の証拠」に数えない★。
・⇒ 対比は ★headless 20s/39 サンプル全ゼロ vs GUI3 非ゼロ 30★。★我々の code 由来なら headless でも動くはず★という向きの材料。★但し batchmode で入力 poll が止まる可能性があり単独では決まらない★ ⇒ ★そこを静的に確定させてください★。
・環境側の母数(PRESIDENT の器)= /proc/bus/input/devices の Name ★15 件★・★gamepad 0 件(js* ノードも 0)★・ABS 軸持ちは "Logitech USB Keyboard" 1 件・pointing は ERGO M575S ⇒ ★軸ドリフト説はこの器では消える★。★打ち切り = XTEST / 自動化 / compositor 由来は未確認★。

■ 3. ★0x57 の GO はまだ出ていません(座は PRESIDENT)★ = 理由は R1 の悪化ではなく★帰属不能★:(a) 枠の取り直しが未了 /(b) ★原盤側の読み手 census が未了(= #584-A の的)★ /(c) ★0x57 単独 arm が無い★(R1/R2 は全 op 開放ゆえ帰属に使えない)。
・★事前登録(撃つ前に固定・後から動かさない)★ = ①(a) が合わない限り (b) が 0 件でも実装しない ②読み手 0 件 → 死に field の札で GO / 非ゼロ → GO でも同時に README へ consumer 未実装の札(README は worker3) ③★受理 oracle は停止が消えたことではなく VerifyEntry の matchedChars★・停止消滅のみを根拠にした GREEN 主張は不受理 ④★0x57 だけを通す arm で撃つ★(他 env は R0/R4 と揃える) ⑤★既定予測 = 0x57 を実装しても matchedChars は動かない(0x0A が先に止める)★・動かなかったらそのまま出す・★合わせにいかない★。
