# トコモンNPC scale — user視覚gate package (worker3, 2026-07-23)

## 成果物(render) — ★k訂正済: 1.82→1.55(可視pixel基準)★
- ★`toko_k155_visible_anchor.png`★ = トコモンを覚醒field(twna01)に k=1.55 で配置=正立+feet接地+game-camera(framing封印)。
- ★`boy_toko_INGAME_v2.png` / `user_package_v3_ingame_zoom.png`★ = ★両bootstrap同時enable→BOYS(k1.03)+TOKO(k1.55)を実game内で同depth(同Z)隣接配置→単一game-camera 1 frame★=2-panel合成でない真の(a)単一frame。feet同一地面整列。可視0.917(body)。
- ★可視pixel: BOYS=206px / TOKO(k1.55)=189px → 0.917≈0.92 target★。

### k訂正の経緯 (honest)
- 当初k=1.82は★bounds比(TOKO3.26/BOYS3.55=0.917)★基準。だがBOYS Renderer.boundsが可視heightより~18%膨張(不可視renderer/bounds artifact、in-game描画は正常)。
- ∴bounds基準k=1.82は可視ではTOKO=boyの1.08倍(過大)。★Koromon0.92xは可視pixel比ゆえ可視基準が正→k=1.55★(2 grounding方式で一致検証)。
- 旧`user_package_toko_scale.png`(2-zoom並置)=PRESIDENT差し戻し(丸bodyのTOKOが幅で大に誤読)→v2 feetalignedで解消。

## scale決定の根拠(実測confirmed)
- ★原盤はbaby Digimonを ~一定height(~0.9x boy)へ normalize している=実測確証★:
  - H2(mesh比例: mesh大きいほどrender大)= **決定的に否定**(原盤TANEMONは視覚的に明確にboyより小、mesh1.99x=1.49x予測と真逆)。
  - H1(全baby ~一定normalize ~0.9x)= **確定**(Koromon0.92 / TANEMON~0.9 / 複数種一致)。
- ∴トコモン(In-Training/baby_II段階)も同normalize帯 ~0.9x → k_TOKO=1.03×0.92/0.52≈1.82。

## ★honest gap(透明性、必読)★
- ★トコモン自体は原盤で直接測定していない★: boy+トコモン同depth可視の原盤frameが既存savestateに無い(全frame scan済=白トコモン可視ゼロ)。
- target~0.92xは★同tier In-Training anchor(Koromon 0.92x=clean depth補正済測定)接地★=同段階grounding。
- 過去のsize誤同定(mesh-unit比で1.6x→実測0.52x訂正)を踏まえ、『Tokomon特定frame実測でなく同段階grounding』を透明markとして明示。
- ★耳の曖昧さ★: k=1.55はTOKO **body**=0.92x boy(Koromon=丸blob無耳anchor基準)。TOKOは耳が有りboy頭頂付近まで突出。耳含む総silhouetteで0.92xにするなら更に小(k~1.22)。原盤トコモン直接未測定ゆえ耳分は未確定=user視覚判断。
- ★user視覚=decisive裁定器★: size違和感あれば user-assist savestate(トコモン可視地点)で精密pin可能(path C)。

## 判断待ち
user視覚gate: この0.92x(Koromon anchor)でトコモンが原盤同様に見えるか。OK→2a完成。違和感→user savestateで精密測定。

## ★★TOKO scale CLOSE (PRESIDENT裁定, 2026-07-23)★★
- ★close spec=『比』: TOKO body = boy 0.67x (body基準、camera非依存)★。user知覚裁定(耳vs body微調整=『細かすぎ』ゆえbody採用でclose)。
- 絶対k≈1.13=★current-camera provisional★(k=1.55×0.67/0.92)。camera arcでboy絶対k変更時、★0.67比維持でTOKO絶対k再導出★(camera従属)。
- final render=toko_k113_FINAL_ratio067.png(game-camera、正立、feet接地-0.031)。
- honest gap: 耳込total=body+33%=silhouette自然に大きめ=原盤の姿。私のpixel測定は0.63〜1.0に振れた(depth/foreshorten/Jijimon-proxy交絡)ゆえ、user perception(0.67 body)を裁定器として採用。
- 残backlog(別issue): json species bug / 背面facing polish / remake-camera-fidelity gap(覚醒camera原盤不一致=camera arcで対応)。
