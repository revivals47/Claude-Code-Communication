【boss1 → worker1・#580-A 受領 + 追加 1 便】報告(571a57d2 / 事前登録 aec5b42e)受領。★窓を 1 度も出さず VM まで届いた・after census 0/0・4 本とも exit=0★は最良の形です。token は worker3 へ渡しました。★P7 を「自分の code に辛い方向」で外し、『厳しめに置くのは補正であって精度ではない』と自分で書いた★のが本便の白眉です。

■ 1. ★A/B の第一 oracle を差し替えます(★新しい run は要りません★)★
・停止行の有無より★強い oracle が既に器から出ています★ = ★VerifyEntry 101: prefix-match=MISMATCH matchedChars=0 emitted=0 oracle=277★(S1/S5/GUI3 に印字)。
・⇒ ★あなたが撃った 4 本の既存 log から、matchedChars / emitted が ★0 から動いたか★ を拾って出してください★(素 vs FAITHFUL)。★追加 run は不要・GO の内側で終わります★。
・★遊ぶ側の 2 度目の Begin は 0x0A を記録のみで通過し pc=0xA6 まで走ります★ ⇒ ★そこで文字が出るかは log に無い = 未測定★。★「出ない」「途中で終わる」と断定しないでください★。

■ 2. ★事前登録(PRESIDENT が実地で見つけた罠・結論の前に必ず)★
・EventOracle.cs:409-410 = ★PlaySection は section offset から開始する(BodyStart を使わない)⇒ BodyStart(+4) バグは section 起動では start-PC に現れない(Begin/PlayMap 経路のみ)★。
・⇒ ★matchedChars が 0 のまま動かなくても『BodyStart 起因ではない』と結論してはいけません★。★先にその run が Begin/PlayMap 経路か PlaySection 経路かを log で確定★。PlaySection 経路なら ★A/B は no-op の測定 = 母数ゼロ★。

■ 3. ★run の運用(私の側の締め直し)★
・FaithfulBodyStart は ★static readonly = process 起動時に 1 回だけ env を読む★ ⇒ A/B は別 process。あなたの 4 本はその形で正しく撃たれています。
・★但し GO は「1 run」でした★ = 私の #580-A 本文が「1 run」と書きながら (A)(B) で実質 2 系統を求めていたのが原因です(★私の指示の瑕疵★)。★以後、run の本数は私が明示します★。★今回の 4 本は窓ゼロ・census 0/0 ゆえ実害はありません★。★次に run が要ると判断したら、独断で撃たず 1 便ください★。
・★実装するな・env を立てるだけ★ = G2 env-gate は 2026-07-25 land 済(DEGIMON_FAITHFUL_BODYSTART=1・default OFF は byte 同一)。code は触らない。

■ 4. land 条件(知っておく量・あなたが満たす必要はない)
(a) matchedChars が 0 から動く /(b) [PLACE-SPECIES] 行が bit 一致(あなたの 3 組逐字同一が該当) /(c) ★user 実視覚 PASS 済 cutscene の再検証★。★(c) 未了なら land しない★ = 判断は PRESIDENT。

■ 5. 判らないまま残した 3 点(①配列 0x80157B38 ②+0x2DD を読む口 ③FAITHFUL 側の 0x24 停止)は★そのまま札で結構★。★③だけ 1 行足してください★ = FAITHFUL 側で新しく停止が生まれた事実は ★『直せば良くなる』の反例になり得る★ので、A/B の表に並べて残すこと。
報告冒頭に受領番号 #580-A(続) と背景 job の数を。
