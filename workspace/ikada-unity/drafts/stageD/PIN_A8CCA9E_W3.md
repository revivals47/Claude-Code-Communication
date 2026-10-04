# Unity の番の支度: track3/logic-a8cca9e（worker3, boss1 14:45, ★git と code だけ・Unity なし★）
- 木: ~/Documents/ikada-unity-track3。branch = master a54294f から track3/logic-a8cca9e。① track3/practice-unify（bd777d6・cd6e945）を merge ② pin_0230.sh で ikada-sim a54294f の pin 2750f49 → ★a8cca9e073f610aef8fd0aff9c42e4870b26117f★（API 0.24.0）、--table refcheck_16.table（11 値 = ikada-sim a8cca9e の pc/tools/Ikada.RefCheck/README.md:13-14・:73 の #16 の行 = 4/20 × 4・7/20 × 4 は #15 と同じ、E′ 22c6a62031cd12ed・F 9bbcb0c4c815700f・G 2f47f7ed5507cc1c）③ Page.PracticeSelect。

## 予測（git の前・Unity の番の前, 動かさない）
- merge: 衝突 0（practice-unify は c5125b3 = master の 1 つ前の祖先から、master a54294f の差 = okiami-word f8c622d の mock の字だけ = 重ならない見込み）。
- pin の dry: manifest 1 + lock 2、★新しい字 0〜5 字★（練習の設定の頁の字は 練習の統合で logic に入った = 2750f49 以降の新しい字がありうる。「外道」の 外・道 は 既に焼き済みの見込み）。
- ③ Page.PracticeSelect: merge の後 Unity の Assets の参照 = ★0★（cd6e945 の LivePractice は 名を使わない）→ ★Unity 側で消す物なし★、logic の enum の値の消しは worker1 の次の版で出来る（値は明示 Day = 3・Info = 4 = 消しても番号は動かない見込み）。
- Unity の番で見る画（boss1 の門の後）:
  - 題の 練習 → ★練習の選びの頁（8 つの drill の列）が出ず、すぐ支度の板★（GameFlow.cs:177-185 at a8cca9e）。
  - 練習の日の一時停止 = ★5 行★: 続ける／セーブする（ストーリーだけ）／今日は上がる／題の画面へ戻る（セーブしない）／★練習の設定（次の投から）★（DayFlow.Pause.cs:96-98）。
  - 練習の設定の頁 = ★5 行（戻るの行なし, 戻るは BackLong）★（PRACTICE_UNIFY_U_W3.md §2）、結果 1 枚（LivePractice の free/set/winter のどれか 1 つ）。
  - refcheck_probe（player の中の RefCheck）11 本: ★#16 の表で 11 本とも一致★（4/20 × 4・7/20 × 4 は #15 から不変、E′・F・G は #16 の新しい値）。陰性対照: #15 の E′ de7c35fa97dcd962・F 7328cadbac53d44e・G 5ecb4be4e588f985 は ★FAIL★。
  - 小アジ: G（12/10 蒲江）の日に 日誌の釣果の行の末が「小アジ　N cm（外道）」（Words.Gedo）・小アジのファイト 1 尾 約 20〜30 s・ドラグの音なし。
