# ★remake 側の 遷移（原盤の 2 段構えの 載せ先）現況調査★（boss1 #437-C ＋ 追加 ⑤）

★測定時点 = 2026-08-16 00:2x（`date` 実測）★ / ★器 = source 直読 ＋ grep のみ（★実装して いません★ / ★走らせて いません★）★
★★語の 規律★★ = ★私は 見つけた ものを ★『fade』と 呼びません★★ = ★★『何を する code か』で 書きます★★（w2 も 原盤側を ★0..160 の 値★ としか 書いて いません = 同じ 硬さで 並べます）

---

## 0. ★★∴ 先に 答え★★

```
★★① warp の 前後に ★時間を 使う 処理★ は ★1 つも 在りません★★★ = ★★唯一の『間』= ★1 frame★★（次 frame flush）
★★② 画面を 覆う / 明るさを 変える 器 = ★0 件★★★（★範囲は §4 に 申告★）
★★③ VISMAP coalesce は ★別物★★★ = ★render の 間引き★ であって ★時間の 引き延ばし では ない★
★★④ ∴ ★載せ先は ★空き地★★★ = ★★『既存の 器に 足す』では なく『新しい 器を 置く』話に なります★★
```

## 1. ★★∴ ① warp が 起きる とき 何が 走るか（★全列挙・code で 追える 範囲★）★★

```
★(1) 発火★ = `DetectWarpTrigger`(tile 110-119) / `DetectImmediateScriptTrigger`(51-79) / `DetectScriptTrigger`(80-109) / `0x47`・`0x4B` の emit
★(2) queue★ = `FieldManager._warpPending = true` ＋ ★`_pendingFrame = Time.frameCount`★（★同 frame では flush しない★）
★(3) flush★ = 次の `Update` 冒頭 `if (_warpPending && Time.frameCount > _pendingFrame)` ⇒ `WarpRequested?.Invoke(...)`
★(4) 受け★ = `GameManager.HandleWarp` = ★registry guard → `MapLoader.LoadById`（★同期 load★）→ `FieldPresenter.HandleMapLoaded`★
★(5) 構築★ = `BuildField` = ★`TeardownField()`（旧 field を 即 破棄）→ camera 生成 → backdrop → entity 配置 → player 配置★
⇒ ★★∴ ★(2)→(3) の ★1 frame★ を 除いて ★待ち・補間・暗転は ★0★★★★
★★∴ 紛らわしい もの 1 つ★★ = ★`_cam.backgroundColor = Color.black`（`FieldManager.cs:480`）★
　⇒ ★これは ★毎 field の 常時 背景★（`clearFlags = SolidColor`）= ★遷移用では ありません★（★teardown 中に 黒が 見える 副作用は 在り得ます が ★意図された 演出では ない★★）
```

## 2. ★★∴ ② 既に 在る 器の 全数（★名前 / 置き場 / 使用箇所★）★★

```
★(a) 名前に fade / 暗転 / blackout を 持つ 実装★ = ★★0 件★★
★(b) `SceneTransition`（`State/SceneTransition.cs`）★ = ★★scene id の 定数と bind だけ★★（`Unbound=-1` / `SceneBoot=204` / `SceneAwakening=238`）
　⇒ ★★∴ ★名前に transition が 入って いますが ★画面効果では ありません★★★ = ★★(6-ck) 看板は 鈍い★★
★(c) 画面を 覆え る `OnGUI` を 持つ class★ = ★4 本★（`UI/SelectionMenu` / `Dialogue/TextboxView` / `UI/StatusScreenController` / `Flow/GameFlow`）
　⇒ ★★どれも warp 経路から 呼ばれません★★（呼び元 = menu / dialogue / status 画面）
★(d) coroutine・時間待ち★ = ★`StartCoroutine` / `WaitForSeconds` = ★非 Editor で 0 件★★
★(e) 時間補間★ = ★`Lerp` の 実装 = ★0 件★★（`FieldScroll.cs:5` に ★『deadzone/lerp 無し = 直接 clamp follow』★ と 明記）
★(f) ★使われて いない もの★（★別に 数えます★）★:
　★`mode`（`0x47` の 3rd byte = transition-mode flag）★ = ★queue → `HandleWarp` まで ★verbatim で 運ばれる★★ が
　　★★consumer は ★log 1 行だけ★★★（`Debug.Log($"[WARP] -> … mode={mode}")`）⇒ ★★∴ ★宣言は 在るが 実体が 無い★★
　★`_fieldReturnShotCountdown = 20`（`TextboxView.cs:257`）★ = ★screenshot 用の 20 frame 待ち★ = ★★遷移では ありません★★
```

## 3. ★★∴ ③ VISMAP coalesce は 同じ ものか★★

```
★私の 判断★ = ★★別物★★。★理由 3 つ★:
　★(i) ★目的★ = ★cutscene 中に ★中間 render を 出さない★★（`FieldManager.cs:205-222`）= ★★間引き★★ / ★暗転や 待ちでは ない★
　★(ii) ★条件★ = ★`IsCutsceneSettled`（dialogue の settle）or ★flag clear★★ = ★★時間では なく 状態★★（★frame 数を 数えません★）
　★(iii) ★対象★ = ★覚醒 cutscene のみ★（`AwakeningCutsceneActive`）= ★通常 warp は 通りません★
★★∴ 但し ★形は 近い★★★ = ★『pending を 立てて ★後で 1 度だけ consume★』★ = ★原盤の 『pending を 立てて 条件が 揃った tick で clear』と ★同じ 骨格★★
　⇒ ★★∴ ★載せ先を 探すなら ★ここが 一番 近い★★★（★但し ★通常 warp 用の 分岐は 今 在りません★★）
```

## 4. ★★∴ ④ 『無い』の 範囲 申告（§8.1）★★

```
★見た 範囲★:
　★① 非 Editor の `.cs` = ★56 本 全部★（`find unity/Assets/Scripts -name "*.cs" -not -path "*/Editor/*"`）
　★② 語 = `fade` / `暗転` / `blackout` / `crossfade` / `transition` / `alpha` / `Color.black` / `fullscreen` /
　　　　 `StartCoroutine` / `WaitForSeconds` / `yield return` / `Lerp` / `CanvasGroup` / `deltaTime *`（★14 語★・大小文字 無視）
　★③ scene / prefab = ★138 file★（`*.unity` / `*.prefab`）
★★見つかった 唯一の hit★★ = ★`Scenes/Main.unity:32` の ★`m_FlareFadeSpeed: 3`★★
　⇒ ★★Unity の `RenderSettings` の 既定 field★★（★lens flare の 減衰★）= ★★遷移とは 無関係★★
★★対照（器が 空振りして いない ことの 検定）★★ = ★`Main.unity` の ★`m_Script` = 0 個★★
　⇒ ★★∴ ★scene に MonoBehaviour が ★1 つも 置かれて いません★★★（★全部 `RuntimeInitializeOnLoadMethod` で runtime 生成★）
　⇒ ★★∴ ★『scene に 隠れて いる』可能性も 潰しました★★
★★∴ 見て いない 範囲（★正直に★）★★ = ★`Assets/Editor` 配下★ / ★`Packages/`★ / ★shader の 中身（`Degimon/BackdropBackground`）★
```

## 5. ★★∴ ⑤ 由来（★原盤 由来か 独自か★）★★

```
★★∴ 器が ★0 件★ なので ★帰属すべき 対象が 在りません★★★ ⇒ ★★∴ 代わりに ★関連する 痕跡 3 件★ の 由来を 出します★★

| # | もの | 由来 | 根拠（1 行） |
|---|---|---|---|
| 1 | ★`DialogueRuntime.cs:1383` の honest-mark★『(b) ★即時 load(20-frame timer warp / fade var[6] style ★未忠実★)★、trackA §10.3-10.4』 | ★★原盤 RE 参照 あり★★ | ★comment に ★原盤 doc の 節番号★ が 書いて あります★ ⇒ ★★∴ ★remake は ★原盤に 2 段構えが 在る ことを 知って いて『未実装』と 明記して いました★★★ |
| 2 | ★`TextboxView.cs:257` の `_fieldReturnShotCountdown = 20`★ | ★★独自（検証用）★★ | ★comment = ★『20 frame 後(IsFinished で textbox 非表示 + field render settle)』★ = ★screenshot の タイミング取り★・★原盤 参照 なし★ |
| 3 | ★`mode`（0x47 3rd byte）の verbatim carry★ | ★原盤 由来（値の 出所）★ / ★★但し 使い道は 未定★★ | ★`IDialogueFacade.cs:65` = ★『transition-mode flag(verbatim carry、semantics は worker2 interpreter で 確定)』★ = ★★意味は 保留のまま 運んで いる★★ |

★★∴ ∴ 結論（★決めません★）★★ = ★★『remake に ★独自の fade は 在りません★・★原盤の 2 段構えは 未実装と 明記済★』★★
　⇒ ★★∴ ★『消すのか 合わせるのか』の 分岐は ★発生しません★★★ = ★★合わせる 側だけ★★（★但し ★合わせるか どうか★ は PRESIDENT の 判断★）
★★∴ 私が 言わない こと★★ = ★★『原盤の [0x8013DF88] 0..160 が ★画面の 明るさ★ だ』★★（★w2 は そう 書いて いません★ = ★★値と 呼ばれ方だけ★★）
```
