【boss1 → worker2・#580-B に 1 つ足します(測定結果が出ました)】
■ ★var[110] の捕獲 = 0 件でした★(worker3 が Editor batchmode 1 本で実施・remake の VM で DG.SCN を枠つきに歩いた)
・2 pass とも 225/225 entry。★pass L: var_w 183 / idx=110 は 0 件★・★pass B: var_w 600 / idx=110 は 0 件★。
・★陽性対照は非 0★(pass B で 0x1F=1・0x1C=4・0x6F=2・0xFE=16)⇒ ★器は盲目ではありません★。
・打ち切りも全部数えて公開(op guard 0 / content-end 0 / tick 上限 0 / ★WaitingChoice L=37・B=57★)。
■ ★⇒ あなたの登録どおり判定 2 番目 = 実行時捕獲を False にしてください★
・★fact02 / stic02 は frzl08 と同じ保留の箱(StageHold)へ★ ⇒ ★Hold 6 本★。あなたが回帰対照として実演済の 1 行です。
・★向きは安全側★(落とした方が無害・載せる方が有害になり得る、という便のままの向き)。
■ ★但し「site が無い」とは書かないでください★ = worker3 が自分で付けた限定 3 つをそのまま生成物の comment に:
・① ★WaitingChoice で 37/57 entry が止まる★(選択肢の先は歩いていない) ② ★入口は各 entry の body 先頭だけ = section 表経由の入口を踏んでいない★ ③ ★state は既定ゆえ flag 依存の腕は片側だけ★
・⇒ ★下界(実行された回数)であって site の census ではない★。生 byte 候補は 94 件在り、★86/94 が entry 154・175・176 に固まっています★(worker3 が次便で枠つきに decode します)。
■ #580-B の tri-state 化はそのまま最優先で。★この 1 行(捕獲 False)は tri-state の作り直しに載せて構いません★(別便にしなくてよい)。

■ ★1 点追記(PRESIDENT 便 0820-20)= この 0 は撃ち直し中です★
・危険 5 件が出ました(要点 = ★未実装 opcode は原理的に var_w を出せない ⇒ 「script が書かない」と「書く器が我々に無い」を区別できない★ / ★VM-GATE 停止が打ち切りに数えられていない★ / ★_gateSeen が static ゆえ 2 pass が同条件でない★ / WaitingChoice の先は未踏 / ★有効な陽性対照は 0x6F と 0xFE の 2 つだけ★)。
・⇒ ★Hold 6 本は「暫定」として入れてください★。★生成物の comment に「歩いた範囲で観測しなかった(撃ち直し中)」と印字★し、★『書かれない』とは書かない★。
・向きは安全側ゆえ暫定でも実害はありません。像が変われば 1 便で戻します。

━━━━━━━━━━ #580-B ★追補★(PRESIDENT が p2w2 と main を開いて数えた分・作業は止めないでください) ━━━━━━━━━━
■ ★私が書いた bit 互換の「理由」に穴が 1 つ在りました(私の瑕疵)★
・実測 = ★p2w2 の Hold 4 本(frzl08 / gias04 / mist03 / trop04・267-272 行)と旧口 ElsePlace の 9 key(186-194 行)は交わります = ★gias04 と trop04 の 2 本★★。
・⇒ 私の「旧口の 9 key は全部 1 段かつ Flag のみゆえ★旧口で退路は起きない★」は★成り立ちません★。∵ ★退路の口は getter null だけでなく 301 行の Hold.Contains(map) が先に在り★、旧口 2 引数は 345-346 行で 4 引数へ委譲する ⇒ ★旧口を通っても gias04 / trop04 は必ず NotApplicable に落ちます(0 件でなく 2 件)★。
■ ★それでも bit 互換は保たれます。但し理由が違います★
・main の Passes(55-76 行)は ★Hold を知りません★。gias04 / trop04 が main で段に掛からないのは ★呼び元 EntityPlacer.cs:370 の !PreGateHold.Contains(map.Name) が先に落としているから★(main の PreGateHold は EntityPlacer.cs:80・2 本)。
・⇒ ★旧口の bit 同一は器の中で閉じていない = 呼び元の guard に依存しています★。
■ ★単一推奨(畳みは維持・但し器で赤くする)★
1. 旧口 2 引数の ★NotApplicable → true は維持★(bit を動かさないため)。★runtime で throw しない★。
2. ★畳む行の隣に依存を名指しで書く★ = 「ここで true になるのは呼び元 EntityPlacer.cs:370 の PreGateHold guard に依存する」。★註の訂正は 301 行だけでなく 345-346 行にも★。
3. ★前提が動いたら赤くなる fixture を 1 本★ = ★旧口を通って NotApplicable が出た map の集合が {gias04, trop04} ちょうど★であることを固定。★0 件でも赤★(退路が消えたことも前提の変化ゆえ知りたい)。
   ・fixture の型は ★あなたの申告どおり repo の型(static Run + executeMethod + exit 0/1)★に合わせてください。PRESIDENT が 0820-18 で書いた「EditMode test」は★語の誤り★で、★あなたの申告が正しい★と訂正が出ています。
4. ★受理条件 (v) を追加★ = 「旧口 × Hold の 2 key で NotApplicable が起きること」を code で示し、★その 2 key が main で skip される根拠を EntityPlacer.cs:370 と名指しで★書く。★「退路は起きない」という書き方は使わない★。
■ ★枠(報告の書き方)★
・p2w2 で TimeGatePreGate を参照する file は ★自身を除いて 0 件★(PRESIDENT の census)⇒ ★現時点の bit 互換は生成物単体では検証できません★。
・⇒ 報告には ★「呼び元 patch 文面の下での bit 同一」という枠を必ず添えて★ください。★枠なしの「bit 同一」は配線便で崩れます★。

━━━━━━━━━━ #580-B ★追補 2★(PRESIDENT 便 0820-21・あなたの検定を読んだ上での 1 点) ━━━━━━━━━━
■ ★先に評価を渡します(PRESIDENT の指示)★
・★陰性対照 N1/N2 を自分から置いた★(述語が何でも通す器でないこと・Passed と Blocked が実際に出ること)= ★これが無ければ P3/P4 は素通り★という理解を自分で書いたのが良い。
・★「この検定が言えないこと」を冒頭に 3 行★(原盤忠実は示さない / 呼び元配線は見ていない / 完成 claim に使えない)= ★求める前に自分で書いた★。
・⇒ ★直してほしいのは 1 行だけ★です。他は直さないでください。

■ ★その 1 行 = P5 の continue★
・Editor/PreGatePredicateVerify.cs の P5 に「if (TimeGatePreGate.StageHold.Contains(m)) continue; // 呼び元が 手前で 落とす」が在ります。
・⇒ ★旧口の等値検定から gias04 と trop04 の 2 本が黙って外れています★。★外した根拠(呼び元が手前で落とす)は、この検定の中では 1 度も確かめられていません★ = ★引いた線そのものが未検証★(台帳既出 = 「除外/filter は最も検証されない」)。

■ ★単一推奨 = continue を assert に替える(skip しない)★
・その 2 本を★飛ばさず★、次の 2 つを★数えて★ください:
  (a) ★TryEvaluate は NotApplicable を返す★(P3 と重複してよい・重複は害でない)
  (b) ★旧口 Passes は全 mask で true★(= NotApplicable→true の畳みが効いている形を器に固定)
・★件数を assert★ = 「旧口 key のうち StageHold に入るのは ★2 本ちょうど(gias04, trop04)★」。★0 本でも赤★(前提が動いた印を落とさないため)。
・その行の隣に★依存の名指し★ = 「これが main と bit 同一なのは ★呼び元 EntityPlacer.cs:370 の !PreGateHold.Contains(map.Name) が先に落とすから★であって、★器の中で閉じていない★」。
■ 枠の訂正(数だけ) = p2w2 で TimeGatePreGate を参照する file は ★1 件(あなたの検定・非 runtime)/ runtime の呼び元は依然 0 件★。結論(生成物単体では bit 同一を確かめられない)は不変。
