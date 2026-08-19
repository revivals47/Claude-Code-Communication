# PREREG_586C — ★(B) の 撃ち直し = ★打ち切りを 開示する★★（worker3 / #586-C）

★★撃つ前に commit します★★／★数値を 良くする ためでは なく ★打ち切りを 開示する ため★★
★land しません・push しません・user を 呼びません★／★「完成」「arc 完了」とも 書きません★
★README（`c661db4`・196 行）は 触りません★／★(c) は この 後★（★判定 3 値の 事前登録 `3348981` は 生かしたまま★）

---

## 0. ★★boss1 の 危険 5 件を ★私の器で 裏取りしました★（★受け売りに しません★）★★

| # | boss1 の 指摘 | ★私の器での 確認★ | 判定 |
|---|---|---|---|
| (1) | ★`var_w` を 出す site は 3 箇所だけ★・未実装 opcode は 原理的に 出せない | `DialogueRuntime.cs` の `TraceFx{T="var_w"}` は ★1041 / 1047 / 1054 の 3 箇所★（`0x1E` / `0x1F` / `0x20`）。★`0x57` は `UnsupportedOpcodeGate` 行き★ | ★正★ |
| (2) | ★VM-GATE 停止は `OpGuardHit` / `ContentEndGuardHit` の どちらも 立てない★ | `UnsupportedOpcodeGate`（1774-）は ★両 flag に 一切 触れません★。呼び元 1731 行 = `if (UnsupportedOpcodeGate(c,len)) { EmitPage(); State = Finished; return; }` | ★正★ |
| (3) | ★`_gateSeen` / `GateCount` は static・私の census に `W1AbReset()` 参照ゼロ★ | 1751 / 1759 / 1760 / 1763 行 = ★全部 `static`★・`W1AbReset()` は 存在。★私の `W3Var110Census.cs`（115 行）に 参照 0★ | ★正★ |
| (4) | WaitingChoice 37 / 57 は ★未踏部分★ | 私の census は `break` で 抜けて います（★選択の 先を 歩いて いません★） | ★正★ |
| (5) | ★陽性対照 7 個の うち 機能したのは 2 つだけ★ | `0x4A` / `0x6D` / `0x00` / `0x1F`(pass L) / `0x1C`(pass L) が 0 ⇒ ★検出器の 生存を 示すのは `0x6F=2` と `0xFE=12/16` の 2 つ★ | ★正★ |

⇒ ★★∴ ★前便の 「op guard 0 / content-end 0」は ★VM-GATE 停止が 0 という 意味では ありません★★★
⇒ ★★∴ ★pass L → pass B の 順で 走らせた ため ★B は 停止ゼロで 歩いた★★★（`_gateSeen` が 埋まった 後）
　 = ★★L 8,314 対 B 14,111 の 差に ★この 非対称が 混入して います★★★（★私の 器の 誤り★）

## 1. ★★撃つ もの（3 + 1 pass）★★

```
  ★各 pass の 前に `DialogueRuntime.W1AbReset()` を 呼ぶ★（= ★同条件に 揃える★）
  ★pass ごとに 印字★: GateCount（op → 回数）/ GateEntries（op → entry 集合の 数）/ GateSeenBandOut / GateSteps

  ★pass L★ = jump fall-through ＋ ★WaitingChoice で index 0 を 選んで 続行★
             ＋ ★「選択で 打ち切った entry 数」を 併記★（= `ConfirmChoiceIndex` が false を 返した 数）
             ＋ ★選択の 回数に cap（64/entry）★（★無限周回を 器で 止め、cap 到達数を 出す★）
  ★pass B★ = `BehavioralMode = true`（jump take）★選択は 従来どおり break★
  ★★pass N（★私の 追加★・boss1 の 3 点には 在りません）★★
           = ★`DialogueRuntime.W1AbNeverStop = true`★（★VM-GATE の 停止を 外す★）
           ⇒ ★★停止による 打ち切りが ★ゼロ★ の 被覆★★ = ★上界側の 1 本★
           ★限定★ = ★未対応 opcode の 後は ★宣言長に 依存した 推定 framing★★ ⇒ ★★L / B より 信頼度は 低い★★
             ⇒ ★N で 出た var_w を 単独では 採りません★（★L / B と 突き合わせて 差だけ 出します★）
```

## 2. ★★事前登録（★数が どう 動くかの 予測★）★★

| # | 予測 | 理由 | 結果 |
|---|---|---|---|
| ★Z1★ | ★pass B の step が ★下がる★（14,111 から）★ | ★reset で B も 初回停止する ように なる★ | (未) |
| ★Z2★ | ★pass L の step が ★上がる★（8,314 から）★ | ★選択で 続行する ぶん★ | (未) |
| ★Z3★ | ★`GateCount` が ★非空★★ | ★停止が 実在する なら 数が 出る★ | (未) |
| ★Z4★ | ★`idx=110` の `var_w` は ★L / B とも 0 のまま★★ | ★前便と 同じ★（★但し 今回は 打ち切りを 開示した 上での 0★） | (未) |
| ★Z5★ | ★pass N の step が 3 pass で ★最大★★ | ★停止を 外す ため★ | (未) |

### ★★外れ方（★先に 並べます★）★★
```
  ★甲★ ★idx=110 が 1 件以上★         ⇒ ★★「歩いた 範囲で 観測した」に 書き換え★★（★site 在り★・到達は 別に 分ける）
  ★乙★ ★GateCount が 空★             ⇒ ★★器を 疑う★★（★停止が 1 度も 走らない = boss1 (2) の 前提と 矛盾★）⇒ ★数を 出しません★
  ★丙★ ★pass B の step が 下がらない★ ⇒ ★`W1AbReset` が 効いて いない 疑い★ ⇒ ★★数を 出しません★★
  ★丁★ ★選択 cap（64）に 到達する entry が 在る★ ⇒ ★その 数を そのまま 出す★（★周回を 「歩いた」と 数えない★）
  ★戊★ ★pass N で だけ idx=110 が 出る★ ⇒ ★★「N の framing は 推定」ゆえ ★site 在りとは 書きません★★★
        ⇒ ★L / B で 再現するか を 次便の 的に します★
```

## 3. ★★書き方（#585-C §3 の 確定を 引き継ぎます）★★
```
  ★結論の 上限★ = ★「remake の VM で DG.SCN 225 entry を 歩いた ★範囲では★ var[110] への 書き込みを 観測しなかった」★
  ★書かない★   = ★「原盤が 書かない」★ / ★「script に site が 無い」★ / ★「remake は 書かない」★
  ★次元の 明示★ = ★これは ★我々の VM の 含有★ の 次元★（★未実装 opcode は 原理的に `var_w` を 出せません★）
  ★consistent は proof では ありません★（★自モデル由来の 値を 裏付けに 使わない★）
```

## 4. ★器 と 後始末（前回どおり）★
```
  Unity Editor batchmode ★1 本★ / -nographics / ★DISPLAY 不要・窓 0★ / -quit / ★error CS を 数える★
  出力 = /home/ken/Desktop/Digimon/w3_586c/（★/tmp 配下では ありません★）
  後始末 = ★script を 撤去★・★untracked を 元どおりに★・★`VBCSCompiler` 込みで after census を 0 に 戻してから 数える★
  ★保全★ = ★script と 結果を comms repo に commit★（★push は しません★）
```

## 5. ★母数 / 切るもの★
- ★pass = 3 本（L / B / N）★ ／ ★entry = 225★
- ★切るもの★ = ★(b) section 表の 全 (scn,key) を 入口にする★（★次の 1 本★）／ ★(c) の 枠つき decode★（★その 後★）
- ★切るもの★ = ★到達可能性★ / ★原盤側★ / ★実装変更★
