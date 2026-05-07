#!/usr/bin/env bash
#
# track-golden-rebless env factor collector.
#
# Run this on both work-PC (tlcr) and home-PC (ken if exists) to gather the
# inputs that determine cosmic-text + swash + tiny-skia rendering output.
# The script is read-only — it never writes goldens or modifies fonts.
#
# Usage:
#   bash workspace/track-golden/collect-env.sh > /tmp/env-$(hostname)-$(date +%Y%m%d).txt
#
# Then attach the output to track-golden step 3 doc (env-diff.md).

set -uo pipefail

section() {
    echo
    echo "=== $1 ==="
}

section "host"
echo "hostname: $(hostname)"
echo "user: $(whoami)"
echo "date: $(date -Iseconds)"

section "OS / kernel"
lsb_release -a 2>/dev/null | grep -E "Distributor|Description|Release|Codename"
echo "uname: $(uname -a)"

section "rust toolchain"
rustc -V 2>&1
cargo -V 2>&1

section "locale"
locale | grep -E "^LANG|^LANGUAGE|^LC_CTYPE|^LC_ALL"

section "session / desktop"
echo "XDG_SESSION_TYPE=${XDG_SESSION_TYPE:-unset}"
echo "WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-unset}"
echo "XDG_CURRENT_DESKTOP=${XDG_CURRENT_DESKTOP:-unset}"
echo "DISPLAY=${DISPLAY:-unset}"

section "fc-match sans-serif"
fc-match -v sans-serif 2>&1 | grep -E "family:|fullname:|file:|index:|fontversion:" | head -10

section "fc-match monospace"
fc-match -v monospace 2>&1 | grep -E "family:|fullname:|file:|index:|fontversion:" | head -10

section "fonts-noto-cjk apt package"
dpkg -l fonts-noto-cjk fonts-noto-cjk-extra 2>&1 | grep -E "^ii|^un" | head -5

section "freetype / fontconfig apt package"
dpkg -l libfreetype6 fontconfig 2>&1 | grep -E "^ii" | head -5

section "NotoSansCJK-Regular.ttc file metadata"
NOTO_TTC=$(find /usr/share/fonts -name "NotoSansCJK-Regular.ttc" 2>/dev/null | head -1)
if [ -n "$NOTO_TTC" ]; then
    ls -lL "$NOTO_TTC"
    echo "sha256: $(sha256sum "$NOTO_TTC" | awk '{print $1}')"
else
    echo "NotoSansCJK-Regular.ttc NOT FOUND"
fi

section "user-level fontconfig override"
ls -la ~/.config/fontconfig/ 2>/dev/null | head -10 || echo "no ~/.config/fontconfig/"
ls -la ~/.fonts.conf 2>/dev/null || echo "no ~/.fonts.conf"

section "GPU"
lspci -nnk 2>&1 | grep -A2 -iE "vga|3d" | head -10

section "Vulkan"
which vulkaninfo 2>&1 | head -1 || echo "vulkaninfo not in PATH"
which vkcube 2>&1 | head -1 || echo "vkcube not in PATH"
dpkg -l "libvulkan*" 2>&1 | grep -E "^ii" | head -5 || echo "no libvulkan*"
vulkaninfo --summary 2>&1 | grep -E "deviceName|driverName|GPU id" | head -5 || true

section "current golden_widgets observation (no bless)"
echo "Run separately when worker3 verify cadence permits:"
echo "  cd <GUI_kit-track-golden worktree> && cargo test --test golden_widgets --no-fail-fast 2>&1 | grep 'differing'"
echo "Expected on tlcr (PR #70 pre-bless values, 5/5 confirmed):"
echo "  label_default_win10        314 px / max delta 255"
echo "  button_default_win10       124 px / max delta 178"
echo "  vstack_default_win10        58 px / max delta 178"
echo "  window_frame_default_win10 637 px / max delta 192"
echo "  window_frame_default_win95 198 px / max delta 250"
