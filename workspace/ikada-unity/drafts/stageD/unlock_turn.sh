#!/bin/bash
# unlock_turn.sh - the player turn after the screen lock lifts (worker3, boss1 15:58; UNLOCK_TURN_PLAN_W3.md). DRY RUN ONLY:
# every check is read-only (git rev-parse / merge-base / merge-tree, pgrep, loginctl); the steps are printed, nothing is built,
# merged or launched. A stop line = exit 1. Order: 1 practice alone -> 2 (master + practice) + goal-band -> 3 (+ input-us).
# usage: unlock_turn.sh [--expect-practice SHA] [--expect-goal SHA] [--expect-input SHA]   (defaults = the shas of 15:58)
set -u
U=/home/ken/Documents/ikada-unity
P=${EXPECT_PRACTICE:-ea3919f}; G=${EXPECT_GOAL:-67a65c4}; I=${EXPECT_INPUT:-2d51b94}; M=${EXPECT_MASTER:-ba3de36}
R=0   # --rehearse: skip ONLY the lock / Runner.Worker guards (to run the git checks while the screen is locked), said on every stop line
while [ $# -gt 0 ]; do case $1 in --expect-practice) P=$2; shift;; --expect-goal) G=$2; shift;; --expect-input) I=$2; shift;; --rehearse) R=1;; esac; shift; done
say(){ echo "$(date +%H:%M:%S) $*"; }
stop(){ say "STOP: $*"; exit 1; }
seat=$(loginctl | awk '/seat0/{print $1; exit}')
say "HEAD $(loginctl show-session "$seat" -p LockedHint -p IdleHint | tr '\n' ' ')| Unity $(pgrep -xc Unity) | Runner.Worker $(pgrep -xc Runner.Worker) | dotnet $(pgrep -xc dotnet) | load $(cut -d' ' -f1-3 /proc/loadavg)"
if [ $R = 1 ]; then say "REHEARSAL: lock and Runner.Worker guards skipped (NOT a go signal)"; else
[ "$(loginctl show-session "$seat" -p LockedHint --value)" = no ] || stop "the screen is locked"
[ "$(pgrep -xc Runner.Worker)" = 0 ] || stop "a CI job is on this PC's runner"; fi
[ "$(pgrep -xc Unity)" = 0 ] || stop "a Unity is running"
[ "$(ps -eo comm | grep -c '^Ikada')" = 0 ] || stop "an Ikada player is running"
chk(){ local want=$1 ref=$2 got; got=$(git -C "$U" rev-parse --short=7 "$ref" 2>/dev/null) || stop "no $ref"; [ "$got" = "$want" ] || stop "$ref is $got, expected $want"; say "0 $ref = $got"; }
chk "$M" master; chk "$P" track1/practice; chk "$G" track1/goal-band; chk "$I" track2/input-us
for b in track1/practice track1/goal-band track2/input-us; do
  git -C "$U" merge-base --is-ancestor master "$b" || stop "$b is not on master"
done
for wt in "$U-track1" "$U-track2" "$U-track3"; do
  n=$(git -C "$wt" status --porcelain | wc -l); say "0 $wt porcelain $n ($(git -C "$wt" branch --show-current || true))"; [ "$n" = 0 ] || stop "$wt not clean"
done
# the merges each stage will make, tried in memory (git merge-tree, no tree touched): conflicts listed by file
mt(){ local out rc; out=$(git -C "$U" merge-tree --write-tree --name-only "$1" "$2" 2>&1); rc=$?
      say "merge-tree $1 + $2: rc $rc, conflicted: $(echo "$out" | sed -n '2,/^$/p' | grep -v '^$' | tr '\n' ' ')"; }
mt track1/practice track1/goal-band           # expected: ScreenRegistry.cs only (PS1/PS2 vs 06G), resolved as the union
mt track1/practice track2/input-us            # expected: none
mt track1/goal-band track2/input-us           # expected: none
say "DRY-RUN steps (each regress sees ONE new change):"
say " 1  track1/practice $P as is = $M + practice: REGRESS_LIVE=1 tools/regress_all.sh -> 15/15, input_test checks=91, mock 26/26 0 px, live logic = baseline"
say " 1b a practice-day live (the set HUD 「組 k/10」, the answer check after closing) if the host has the practice entry (W1) - else the editor mocks"
say "    -> PRESIDENT GO -> master <- track1/practice"
say " 2  master + track1/goal-band (ScreenRegistry.cs: keep both entries) -> regress 15/15 + editor 06G + player G (12-10 seed 1) / F (10-15 seed 1) 06"
say "    -> PRESIDENT GO -> master <- that tree"
say " 3  master + track2/input-us (pin 22e566a from master) -> regress: live 'logic sequence differs' EXPECTED, mock 26/26 0 px, input_test same"
say " 3b drafts/stageC/live_rebase.py dry-run (tag pre-us_) -> table to boss1 -> pictures to PRESIDENT -> GO -> --apply"
say " 3c regress again -> 15/15;  3d live F 10-15 seed 1 to 2830 s: the say at 2812.5 s = RefCheck F's 2812017 ms line (通りすがり 割れてから待ちすぎかも…)"
say "    -> PRESIDENT GO -> master <- that tree"
say "DRY-RUN: nothing built, merged or launched"
