# VISE_AVATAR scale = DuckStation原盤実測 (worker3、2026-07-22、measure-first)

## 結論: native scale (k≈1.0、範囲1.0〜1.4) が正解。従来のk=0.2はframing-camera artifact。

## measure-first所見 (視覚guessをground truthが訂正)
- ★原盤DuckStation _1: boy pixel高さ=~55px/224=0.245 screen高さ★(regtest -dumpframes、twna01町field、boy=緑tunnel建物前)。
- ★remake game-camera geometry (live log): eye=(0,86,-119)/fwd=(0,-0.6,0.8)/fov=7.57°/boy depth=117.5u → boy深度でscreen縦=15.55 world units★。
  - native boy(3.45u)=3.45/15.55=0.222 screen ≈ 原盤0.245 (比0.91) → 逆算k≈1.1。boss1独立検算一致。
- ★game-camera projection複製render (DEGIMON_VISE_GAMECAM=1、fov7.57/depth117) 実測★: k=1でboy~0.18screen、原盤0.245と比較→k≈1.0〜1.4範囲。★視覚: k=1で地面/grass比が適正=原盤proportion一致★。

## framing camera artifact (なぜ従来k=0.2に誤誘導されたか)
- 従来のPoC/A-B shotは全て★framing camera(boyから2.2u近接、fov45°)★。ここでscreen縦=1.82 world units → native boy=1.9×screen(overflow=巨大)、k=0.2で0.38(fit)。
- 一方game camera(far、depth117、fov7.57°)=native boy 0.22screen(適正)。
- ∴★framing camera(近接)が game camera比で boyを ~8.5倍巨大化★=user『5倍過大』+A/B判定(k0.15)は この誤camera artifact。=measure-firstがframing-shot視覚guessを訂正。

## camera不変anchorの論理 (free-roam blocked でも scale確定可能)
- ★pixel比/screen比(camera-matched projection)で幾何裏取り=native boyのfree-roam実render(awakening cutscene blocked)が撮れなくても scale確定できる★。
- boy screen-fraction を game-matched projection(fov/depth複製)で測る = 原盤の boy screen-fraction と直接比較可能 = camera距離非依存の anchor。
- ∴free-roam実render裏取りは phase1.5扱いで可、phase1 scaleは本measurementで確定。

## 精度caveat (honest)
- boy screen-fraction比 = camera/depth完全一致が前提。原盤boy(tunnel前)とremake boy(spawn=water area)は★map位置=depth差あり★=±誤差。
- ∴精密kは1.0〜1.4の範囲、★native(k=1.0)が自然な既定値かつ原盤measurement誤差内★。単一anchor(boy screen比)ゆえ、複数feature/同depth地面markingでの再確認が理想(honest gap)。
- 確定的なのは: ★k≈native範囲(1.0-1.4)、k=0.2は~6x誤り(framing artifact)★。

## 成果物
- VISE_AVATAR_scale_ORIG_vs_gamecam_k1.png = ★決定的: 原盤 vs remake game-cam k=1(screen高さ720正規化、boy比直接比較=roughly一致)★
- gproj_k_compare.png = remake game-cam k=0.8/1.0/1.2 boy size比較

## 精密測定による範囲収束 (2026-07-22 追記、single-anchor caveat緩和)
- ★原盤/remake両boyを同一method(gray beanie上端〜feet下端、grass/water bg除去)で精密測定★:
  - 原盤_1 boy frac=0.290 / remake game-cam k=1 boy frac=0.281
  - ★best-estimate k = 0.290/0.281 = 1.03 ≈ native(1.0)★
- 前report範囲1.0-1.4の上限1.4は★測定method不一致(原盤0.245 vs remake0.18を別methodで測った)の産物★。consistent測定で ★k範囲 1.0-1.4 → ~1.0(native)に収束★。
- ∴native(k=1.0)が幾何(k≈1.1)+精密pixel(k≈1.03)+視覚composite の3系統で確定。depth差±は残るが point estimate ~1.0。
