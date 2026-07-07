# Live-verify batch — 2026-07-07 (Fable window session 成果の user 実機確認)

> **目的**: 本 session で land した機能のうち、自動テストでは判定できない「実機で見ないと分からない」項目を user が上から順に消化するための 1 枚手順書。各項に **PASS/FAIL + 違和感 memo** を記入 (memo が v2 調整の入力になる)。
> **所要**: Part A ≈ 15 分 (multiline merge-gate + gamma) / Part B ≈ 20 分 (packaging + fidelity + screenshot)。時間が無ければ **Part A だけでも可** (Part B は次 session に回せる)。
> **前提の起動元**: 断りない限り main clone `~/Documents/hayate-kit-testruct` (HEAD 57c1953 = multiline #88 + K8 #94 込み)。初回のみ `cargo build -p testruct-ui -j1` で ~数分、以後は即起動。

---

## Part A — multiline text edit 本体 + gamma (merge-gate、最優先 ≈15 分)

### 起動 (この 1 コマンドを端末で)
```bash
cd ~/Documents/hayate-kit-testruct && cargo run -p testruct-ui -j1 -- --answer-sheet fukuoka
```
※ `--answer-sheet fukuoka` はテキスト入りの解答用紙 (既定 kokugo はテキスト無し空枠でフォント確認に不向き、07-07 finding)。

### A-1. 複数行編集の基本 + IME 候補窓 【所要 5 分・最重要】
1. 縦書き or 横書きのテキスト要素を**ダブルクリック** → 画面中央にパネル + 背景が暗転すれば modal 起動 OK。
2. **日本語入力**して変換 → **候補窓が入力中の caret 位置に出て追従するか** (= kit #323 の新 ImeRect 経路の**実機初検証**、要注目)。
3. **★R-1 観察**: 変換候補の窓が **二重に出ていないか** (アプリ自前の候補窓 + fcitx5/mozc のシステム候補窓が両方見えたら FAIL 相当 — memo に「二重」と記録)。
4. **Enter で改行が入る**こと (確定でなく改行 = B-1 の新挙動)、**Ctrl+Enter で確定**して modal が閉じ、本文に反映されること。

- PASS / FAIL: ____   候補窓追従: ____   二重表示: 有 / 無   memo: __________

### A-2. wrap 行の caret 移動 【所要 3 分】
1. modal 内で幅を超える**長い一行**を入力 → 自動で折り返すこと。
2. ↑↓ で caret が動く。**破綻 (caret 消失 / 描画乱れ / crash) が無ければ PASS**。
   ※ ↑↓ が「折返し行」でなく「論理行」単位で飛ぶのは**仕様内** (K-h 未実装、FAIL ではない)。

- PASS / FAIL: ____   memo: __________

### A-3. 縦書き要素の往復 【所要 3 分】
1. **縦書き**のテキスト要素をダブルクリック → 編集面は**横書き**で開く (Mac と同じ、正常)。
2. 改行を入れて Ctrl+Enter で確定 → canvas 上で**再び縦書き (複数列)** に描き直されること。
3. もう一度開く → 改行構造が保持されていること。

- PASS / FAIL: ____   memo: __________

### A-4. modal UI の印象 【所要 2 分・veto 機会】
中央パネル + 暗転 + 「Enter=改行 / Ctrl+Enter=確定」の操作感を試して、**違和感があれば memo に**。方式そのものへの反対 (in-place の方が良い等) は PRESIDENT 判断へ上げる材料になる。細かい見た目 (パネル幅 / ヒント文言 / フォント) は v2 で調整可。

- 印象 (◎○△): ____   memo: __________

### A-5. 表セル編集が変わっていないこと 【所要 2 分・回帰】
1. **表**のセルをダブルクリック → 従来どおり**セル内の単一行 overlay** (中央 modal ではない) が開くこと。
2. セル編集中は **Enter=確定** のまま (B-2 不変)。数式要素のダブルクリックも従来どおり数式エディタが開くこと。

- PASS / FAIL: ____   memo: __________

### A-6. gamma α ランプ目視 【所要 3 分・default ON 化の判断材料】
gamma-correct blend (`HAYATE_LINEAR_BLEND`) を ON/OFF で並べて見比べる。**AA エッジの太り / 半透明の濁り** が ON で改善して見えるかが判断材料 (改善なら default ON 化を検討)。
```bash
# 2 端末 or 順番に。同じ文書を OFF と ON で起動して見比べる
cd ~/Documents/hayate-kit-testruct
cargo run -p testruct-ui -j1 -- --answer-sheet fukuoka                    # OFF (現行既定)
HAYATE_LINEAR_BLEND=1 cargo run -p testruct-ui -j1 -- --answer-sheet fukuoka   # ON
```
※ 半透明の重なり・薄い文字のエッジで差が出やすい (ベタ塗りでは差が出ない)。もし home-PC の `gamma_test.testruct` (α ランプパターン) が手元にあればそれが最も判定しやすい。

- ON で改善 / 変化なし / 悪化: ____   default ON 化したい？ はい / いいえ / 保留   memo: __________

---

## Part B — packaging + fidelity + screenshot (≈20 分、次 session 回し可)

### B-1. AppImage 実操作 4 項 【所要 9 分】
> ✅ **AppImage 最終再生成済** (worker3 2026-07-07 18:05): 下記 path の実体は
> **main `ffe308b` のビルド** (kit `3cc13c0`) — finding 1 (複数行揃え #97) +
> finding 2 (縦書きトグル #96) + **finding 3 (縦書き回転字形 PDF #98)** /
> K4→K9 描画 (#90,#94,#95) / 白紙起動 + 未保存確認 dialog (#93) の
> **本日全 land 分収束の単一 artifact**。full headless smoke 5 項は 76d34e8
> 時点で PASS 済 + 差分 (描画系のみ) 後の白紙起動 smoke 再 PASS (全px白)。
> そのまま B-1 に着手可。

checklist 本体 = `packaging/appimage/smoke-checklist.md`。AppImage 実体:
```
~/Documents/hayate-kit-testruct-track3/target/appimage/hayate-kit-testruct-0.1.0-x86_64.AppImage
```
(再生成は track3 worktree で `./scripts/build-appimage.sh`。appimagetool は work-PC 導入済)

1. **ダブルクリック起動**: ファイルマネージャで AppImage をダブルクリック → ウィンドウが開くこと (実行権が無ければ付与手順も体験・記録)。端末でなく GUI 経路で起動するのが本丸。
2. **フォント picker 切替**: Inspector で 角ゴ → 丸ゴ → 明朝、書体が目視で変わること (豆腐 □ が出たら FAIL)。※テキストは `--answer-sheet fukuoka` 文書か手入力で。
3. **保存往復**: 名前を付けて保存 → 終了 → 再起動 → 開く で同じ見た目。
4. **印刷**: メニュー → 印刷 → PDF が生成され xdg-open で viewer が開くこと。

- 1:__ 2:__ 3:__ 4:__   memo: __________

### B-2. gradient VK 実機 (K4/#324) 【所要 3 分】
多段グラデ塗りが Vulkan 実機で正しく出るか (CPU golden は緑、実機 VK は目視)。図形を作り塗りにグラデを指定 → **linear / radial**、さらに **角丸四角 / 楕円 / polygon (三角・星等)** の各形状で**バンディング (縞) なく滑らかに**出れば PASS。形状の縁で mask がはみ出さないこと。

- linear:__ radial:__ 角丸:__ 楕円:__ polygon:__   memo: __________

### B-3. K8 半透明 overlap (#94) 【所要 2 分】
図形の **opacity を下げて 2 つ重ねる** → 重なり部が「真の alpha 合成」で自然に透けること (以前の色 alpha 畳み込みでは濁っていた箇所)。SaveLayer 経路の実機確認。

- PASS / FAIL: ____   memo: __________

### B-4. README screenshot 3 枚撮影 【所要 5 分】
R-2 #92 で placeholder path 確保済。以下 3 枚を撮って所定 path に置く (撮影後、README の HTML コメントを外して差し込む docs-only 作業 — worker に振ってよい)。
- `docs/images/main-window.png` — 解答用紙を開いたメイン画面
- `docs/images/answer-sheet-builder.png` — 解答用紙ビルダーのダイアログ (挿入メニュー →「解答用紙を編集…」)
- `docs/images/pdf-export.png` — PDF 出力を PDF ビューアで開いた状態

- 撮影: main:__ builder:__ pdf:__

---

## B-5. K9 分 (worker2 追記 17:07 — #327 `d826caa` + 配線 #95 `9b37287` land 済、user 実施可)

### B-5a. 影の Gaussian blur + σ 較正 【所要 3 分】
影付き shape (Inspector で影トグル ON、blur 既定 4) が **柔らかいボケ縁** で出るか (以前は offset のみの硬い影)。Mac の同文書と見比べ、ボケ幅が近いか — `SHADOW_BLUR_TO_SIGMA = 0.5` (σ = blur/2 初期値、testruct render.rs) が較正対象で、広すぎ/狭すぎなら memo に「×N 倍感」を残す → worker が定数更新 + doc 固定 (K9 裁定 #4)。

- blur 出る:__ Mac 比:__ (ちょうど / 広い / 狭い)   memo: __________

### B-5b. 半透明テキスト 【所要 2 分】
text 要素の opacity を下げる (または文字色 alpha < 1) → 文字が**真に透ける**か (以前は alpha drop で不透明のまま)。横書き + 縦書きの両方。

- 横:__ 縦:__   memo: __________

### B-5c. 注意 (gamma 判断への入力)
`HAYATE_LINEAR_BLEND=1` では**影 blur が skip され offset-only になる** (blur render pass の UNORM 固定 = 既存全画面 blur と同制約)。A-6/gamma default ON 化の判断にはこの制約を織り込むこと。

---

## 記入後の扱い
- 各項の FAIL / 違和感 memo を boss1 へ渡す → root-fix dispatch or v2 調整 backlog へ。
- multiline (Part A-1〜A-5) の FAIL は #88 の post-merge veto に相当 (方式 veto は PRESIDENT、細部は v2)。
- gamma (A-6) の結果は default ON 化 (handoff §B-3 / 07-03b D-1) の判断入力。**B-5c の「linear 時は影 blur が消える」制約も同判断に含めること (worker2)。**
