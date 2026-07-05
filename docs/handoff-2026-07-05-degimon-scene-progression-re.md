# Handoff — 2026-07-05 home-PC — Degimon scene-progression RE (worker1) + live-session 台本 ready

Digimon World 1 (SLPS-01797) faithful remake. worker1 = RE authority. This session: scene-progression
sprint (P3-C) RE + the live-session 台本. **P3-C LANDED (degimon main 267a252).** Next = a bundled
user-assisted DuckStation session drives the faithful-178 pin; worker1 on RE-interpret standby.

## worktree / branch
- `/home/ken/Desktop/Digimon/degimon_world_remake-sp3re` @ `track/scene-prog-re` (base main 4729041,
  HEAD **77051db**). RE docs live here (`docs/SCENEPROG_*`, `docs/P3B_*`, `docs/LIVE_SESSION_*`).
- EXE: `/home/ken/Desktop/Digimon/degimon/extracted/slps_017_97.bin` (ovldis base 0x80090800).
  DG.SCN: `.../extracted/DG.SCN`. venv/ovldis under `degimon_world_remake/workspace`.

## what landed / was grounded (P3-C)
1. **②/(c) scene-progression driver — full chain PINNED**: section-load (0x800f0150/0188) → 0x800F02EC
   → 0x800E3DA0 → **transition fn 0x800E3FA0(a0=target)** = `(current -0x6d90, target)` event-detail
   (-0x6d8f) table + **invoke entry0.section[target]** (0x800f0150); chains via -0x7780 (caller2
   0x800E4234 re-transitions). **entry14 fires at target=14** (data-driven; driver-reach PROVEN).
2. **NewGame init 0x80110AE4**: bzero save struct (0xf00) + seed **scene(+0x49a)=204**, money=50000,
   slots; **NO flag preset (all flags 0)**. ⇒ **remake `GameState.NewGame` g1 preset (SetFlag
   dc/d6/dd/f6) is FABRICATION → removed** (FOUNDATION-correction; live-178 read was post-awakening).
3. **awakening-178 linchpin = NEGATIVE** (exhaustive static): (a) 149.sec54 JMP178 = FALSE (worker3+
   worker2 c85203b: 149 section-254 early-RETURN @0x66; ACTIVATE starts at section 0xFE=254);
   (b) scene-transition 204→238 = ABSENT (full table 0x800E3FA0 has neither 0xcc nor 0xee);
   (c) 238/178 immediate = ABSENT overlay-wide. ⇒ faithful 178 trigger not statically pinnable →
   **live-RE handoff**. (faithful 178 = entry0.sec238 ACTIVATE 178 @0x3518, per worker3.)

## live-session 台本 (confirmed-ready) — the deliverable in flight
`sp3re docs/LIVE_SESSION_bundle_awakening_chapter_2026-07-05.md` (HEAD 77051db) — **4-item bundle, one
user DuckStation session**, order: awakening(fresh new-game) → entry14(same playthrough) → raise →
status. No undetermined addrs.
- **Ch.1 awakening-178 trigger (BP capture)** — BP **0x800f0988** (LoadScenario, a0=scenario;
  **a0=0xB2(178) hit → capture `ra`/caller** = the linchpin) + 0x800f0150 / 0x800f0188; flag[0x37] @
  **0x8016387F bit 0x80**. ra region → trigger: 0x800ef3e0/0x800EC448 = **sec238 fb** / 0x800EC64C =
  149.sec54 JMP / else = intro-player.
- **Ch.2 entry14 e1-set (flag-observe)** — observe flag[0xE1] @ **0x80163895 bit 0x02** (0→1) after
  full entry14 dialogue → SET_FLAG(0xE1) @~entry14+0xA62. **Caveat (worker3)**: section-254 warps to
  frzl12 (map96) *before* @0xA62 → @0xA62 needs a section-switch branch; write-watchpoint resolves the
  path. Confirms cascade 0x800E4A08 → 179 (the P3-B 178→179 gate) live.
- #3 (A) VRAM F1-F6 (`trackA3d docs/A_vram_session_plan_2026-07-04.md`); #4 praise/scold
  (`docs/CAPTURE_praise_scold_watchpoint_2026-06-23.md`).

## NEXT ACTIONABLE (worker1, on RE-interpret standby)
- **Live-session started** (boss1 guides user directly). When the **awakening BP-capture ra** arrives:
  immediately RE-interpret → **which trigger** (sec238 fb / 149.sec54 / intro-player) → write the
  **faithful-178 spec** (if sec238: remake implements scene-238 ACTIVATE-178 at the captured path).
  Also interpret flag[0x37] state + the 204→…→178 load-sequence.
- entry14 e1-set: interpret the observed flag[0xE1] 0→1 + the @0xA62 section-reach path.

## norms (unchanged)
RE-first / 捏造ゼロ / honest-gap classified / worktree isolation / trackF etc. re-baseline to current
main (stale caution) / agent-send from `/home/ken/Documents/Claude-Code-Communication` only, no
backtick/`!`/`$()`. Comms: boss1-mediated; worker1↔worker3 direct for live-session coordination
(boss1-sanctioned). Land protocol: mcs leaf → merged-tree CS0=0 (boss1) → PRESIDENT diff + live view →
ff; push on user instruction only.

## key addresses (quick ref)
scenario-VM: walk-loop 0x800f0748; opcodes 0x13/14/15/16/17 (0x800EC528/57C/5E4/624/64C); 0xFB
ACTIVATE 0x800EC448 (ctx→-0x6d90 bookkeeping; start section **0xFE**); deferred-load 0x800ef3e0;
call-stack [-0x6cec]+0x25c depth -0x6ce2; LoadScenario 0x800F0988; GetSectionTable 0x800f0a4c. cascade
0x800E4A08 (flags dc/d6/dd/e1/f6 → 168-179) → -0x6d90 via 0x80111DF0. flag store 0x80163784 (+0xf5
bits): flag[0x37]=0x8016387F bit0x80, flag[0xE1]=0x80163895 bit0x02. scene var 0x8016B001 (save/boot
only; save-load 0x801110A8). transition fn 0x800E3FA0; warp 0x47=0x800ED4A0→0x800bb544.
