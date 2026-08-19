あなたは worker3 です。【boss1 dispatch #582-C-R(rebuild)】OS が 2026-08-20 00:40:57 に再起動し、あなたの context も tmux 履歴もゼロです。前提は全てこの本文に書きます。

■ 0. 何が起きたか(boss1 が器で確認した観測)
・#582-C の引き渡し build は消えました。find /tmp /home/ken/Desktop -maxdepth 6 -name 'build58*' が 0 件。出力先が /tmp 配下だったためです。
・source は無事。worktree /home/ken/Desktop/Digimon/degimon_world_remake-integ、branch track3/w3-582c-userbuild、HEAD 152885f9(boss1 が rev-parse で確認済)。origin/main は ca34f972 のまま。
・よって「前回 5/5 PASS」は消えた器の PASS です。使い回さないでください。

■ 1. タスク = 同じ HEAD 152885f9 からの rebuild と検収の撃ち直し
(a) 出力先を /tmp 配下にしないこと(再起動で 3 度目を失わないため)。
    workspace/build/ と build_handoff_444c/ は不可触。別 dir を新設し、その絶対 path を README に書くこと。
(b) byte の扱いは限定つき。我々は Unity 生成物の byte 再現性を測っていません。
    sha256 が前回値と不一致でも即 FAIL にしない。挙動同一 + 差分の在り処 を示して退くこと。一致した場合は傍証として扱う(証明ではない)。
(c) 検収 S1-S5 を全部撃ち直す。S5 は W3_MEASURE_FLAGS=203 を付けても何も起きないこと(印字ゼロ + 全行逐字同一)を再度示す。
(d) 測定用の口が無いことを、今回 build した source に対して grep し直す。実行した command 行と件数をそのまま貼ること。
    陽性対照を必ず添える(口が在る branch では同じ command が何件出るか)。陽性対照が拾えないなら件数を出さない。
(e) 実 GUI で確認。DISPLAY=:1 で窓(wmctrl 等)と [PLACE-SPECIES] の出力まで。
    ★注意★ 絵の忠実さの検証ではない。画面の 1 体の同定はしない。
    ★開始前に DegimonLive の process を数えること★。00:5x に 2 本見えて 1 分後に 0 本という不安定な観測があります。古い窓を新 build と取り違えないため、起動前後で数え、窓 id を明示すること(root 撮影は BadMatch ゆえ窓 id 指定)。
(f) README を更新。実体 = /home/ken/Documents/Claude-Code-Communication/workspace/degimon-faithful178/USER_RUN_README_581C_DRAFT.md
    §2 の path と sha を新 build に更新すること。
    さらに file 名が 581C のままで中身は #582-C です。名前と ticket の食い違いも直すこと(git mv で改名 + 本文中の 581C 表記も点検)。

■ 2. 不変(全部守ること)
・push しない。land は PRESIDENT の承認。
・「完成」「arc 完了」と書かない。
・git add -A 不使用(path 指定で add)。
・savestate と .bak は読取のみ。workspace/build と build_handoff_444c は不可触。
・agent-send は pipe しない。backtick とドル記号つき register 名は file 経由。
・compile を通さないものは land ではなく提案。Unity batchmode で error CS の件数まで示すこと。

■ 3. 報告の形(boss1 宛・agent-send.sh boss1)
・新 build の絶対 path と sha256、compile の error CS 件数
・S1-S5 の 5 本を撃ち直した結果(PASS/FAIL を 1 行ずつ + 根拠)
・(d) の grep 実行行・件数・陽性対照の件数
・(e) の process 計数(起動前/後)・窓 id・[PLACE-SPECIES] の行
・README の更新 commit と改名 commit の sha
・判らないことは判らないと書く。推測を観測として書かない。

doc を commit してから報告を送ってください(送信段で報告が消える事故が昨日 2 度あります)。着手 ack を先に 3 行で返してください。
