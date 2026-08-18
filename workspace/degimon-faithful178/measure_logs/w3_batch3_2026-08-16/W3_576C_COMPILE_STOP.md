# W3_576C — ★受理条件 (2) で 止まりました = compile が 通りません★（worker3 / #576-C）

事前登録 = `5bd63e2`（★撃つ前★）
★★直していません（直すのは boss1）★★／★land しません・push しません★／★user を 呼びません★
★★「完成」「arc 完了」「忠実に なった」とは 書きません★★
★★(a)(b)(c) は ★1 つも 測っていません★★★ = ★compile が 前提だからです★

## 0. ★測った 対象★
- ★degimon main ★`c05f5128`★ を ★detached checkout★★（#559-C と 同じ (6-de-4) の 形）
- ★私が 初めて 触ります★（boss1 は build も run も していない と 明記）
- ★測定後 ★`track/measure-fade-tile` に 復帰★・★差分 0 行★★

## 1. ★★compile = 失敗★★（`Aborting batchmode due to failure: Scripts have compiler errors.` / exit=1）

★error は ★2 種・4 行★★（★3 回 繰り返されるのは compile pass が 3 回 走るため★）:

### ★★欠陥① `TimeGatePreGate.cs:57` — ★空配列に 型が 無い★★★
```
Assets/Scripts/Field/TimeGatePreGate.cs(57,30): error CS0826: No best type found for implicitly-typed array
Assets/Scripts/Field/TimeGatePreGate.cs(57,30): error CS0029: Cannot implicitly convert type '?[]' to '(int, int)[]'
```
```csharp
57:                ["gias04"] = new[] {  },   // 終わり = ★未知 token 0x1E★
```
⇒ ★`new[] { }` は ★要素が 無いので 型を 推論できません★★（他の 行は `new[] { (140, 0) }` ゆえ通ります）
⇒ ★★∴ ★空になる のは `gias04` ただ 1 本★★★（file 内 全走査・`new[] {  }` は 1 件）
⇒ ★★∴ ★この file は 「生成物・手で 直さないでください」と 冒頭に 在ります★★
　⇒ ★★∴ ★直す場所は 生成器 `w2_gen_pregate.py` の 側だと 思われます★★（★判断は boss1★）
　⇒ ★参考★ = `new (int, int)[0]` なら 通ります（★私は commit していません★）

### ★★欠陥② `EntityPlacer.cs:411/412` — ★`elseSlots` の scope★★★
```
Assets/Scripts/Field/EntityPlacer.cs(411,24): error CS0103: The name 'elseSlots' does not exist in the current context
Assets/Scripts/Field/EntityPlacer.cs(412,73): error CS0103: The name 'elseSlots' does not exist in the current context
```
| 行 | 中身 |
|---|---|
| ★299-300★ | `TimeGateRule timeRule = null;` / `int hour = -1, timeGated = 0, preGated = 0;` = ★loop の 外★ |
| ★317★ | `if (map.Npcs != null && !loaderOff)` ← ★block が 開く★ |
| ★358★ | `HashSet<int> elseSlots = null;` ← ★★この block の 内側★★ |
| ★411-412★ | log 行が `elseSlots` を 読む ← ★★block の 外★★ |

⇒ ★★∴ ★`timeRule` / `preGated` は 「log 行まで 生かすため loop の 外側で 宣言」と comment 付きで 外に 在るのに
　`elseSlots` だけ 内側に 在ります★★★（★`preGated` は 外・`elseSlots` は 内 = ★対に なっていません★★）

## 2. ★★probe（★これは 直しでは ありません・commit していません★）★★

★問いは 1 つ★ = ★★「この 2 件で 全部か・後ろに まだ 隠れているか」★★
⇒ ★2 箇所だけ 当てて build し ★すぐ `git checkout --` で 戻しました★★（★差分 0 行を 確認済★）

```
[M437C] result=Succeeded out='…/build576probe/DegimonLive/DegimonLive.x86_64'
        size=489778136B errors=3 warnings=9
★error CS = 0 件★
```
⇒ ★★∴ ★compile を 止めているのは ★この 2 件だけ★★★★（★後ろに 別の compile error は 在りません★）
⇒ ★★但し 「boss1 が 当てる 直しが この probe と 同じ」とは 言えません★★ = ★直す形は boss1 の 判断★

★★限定★★ = ★`errors=3 warnings=9` の 中身は ★特定していません★★。
　log 内で `error` を 含む 非 CS 行は `[Licensing::Module] Error: Access token is unavailable` の 1 件のみ。
　★過去 build の 同じ欄と 比べていません★（★比較対象の log が 手元に 残っていません★）
　⇒ ★★∴ 「新しく 増えた 3 件」とも 「元から在る 3 件」とも 言いません★★

## 3. ★★(a)(b)(c) は 未測定★★

| 受理条件 | 状態 |
|---|---|
| (3) (a) `mayo00` 3 条件 | ★未測定★ |
| (4) (b) 陰性対照 5 map | ★未測定★ |
| (5) (c) 保留 2 map | ★未測定★ |

★★事前登録 `5bd63e2` は そのまま 生きています★★（★予測は 撃つ前に 書いてあります★）

## 4. ★★flag の 口（★受理条件 (3) の 明記・先に 出します★）★★

★序盤（`bit203 = 0`）★ = ★★注入 不要★★（`GameState.cs:482` = `readonly bool[] _flags` は 既定 全 0）
★進行後（`bit203 = 1`）★ = ★既存の口を 見つけました★:
```
FieldState.cs:525  string setFlags = System.Environment.GetEnvironmentVariable("DEGIMON_SET_FLAGS");
FieldState.cs:534  if (fl >= 0) { gs.SetFlag(fl, true); … }
```
★★⚠ 懸念（★測っていません・読んだだけ★）★★ = ★この block は `TriggerIntro` の `gs != null` 枝に 在り★、
　★その ★手前★ に `DEGIMON_INTRO_ENTRY` の 早期 `return`（`FieldState.cs:509-514`）が 在ります★
　⇒ ★私の harness は `DEGIMON_INTRO_ENTRY=101` を 使います★（★これが 無いと map が 流れます★）
　⇒ ★★∴ ★(甲) は 届かない 見込み★★（★見込みであって 測定では ありません — compile 前ゆえ 撃てていません★）
　⇒ ★★届かなければ ★私の branch にだけ★ env gate（既定 OFF）を 置き ★その旨を 明記して★ 撃ちます★★

## 5. ★母数 / 切ったもの★
- ★build ★2 本★★（① main `c05f5128` そのまま = ★失敗★ / ② probe = ★成功★）
- ★run（player）= ★0 本★★
- ★★切ったもの★★ = ★(a)(b)(c) 全部★・★flag 口の 実測★・★`errors=3` の 中身★
- ★元 savestate / `.bak` に 触っていません★ / ★`git add -A` を 使っていません★
