#!/usr/bin/env bash
# Make the NeloOS color scheme the system-wide default.
#
# Setting ColorScheme=NeloOS alone is not enough: KDE reads the actual colors from
# the [Colors:*] groups in kdeglobals. So the color groups are copied from the
# color scheme file into /etc/xdg/kdeglobals (the system defaults). If a user picks
# other colors in System Settings, their ~/.config/kdeglobals still takes precedence.
#
# The only file to edit when changing colors: /usr/share/color-schemes/NeloOS.colors
set -euxo pipefail

SCHEME="/usr/share/color-schemes/NeloOS.colors"
KDEGLOBALS="/etc/xdg/kdeglobals"

{
    echo
    echo "# ---- Generated from ${SCHEME} at image build time, do not edit ----"
    # Copy every group except [General] (already in kdeglobals), skipping comments.
    awk '
        /^\[/ { keep = ($0 != "[General]") }
        /^#/  { next }
        keep  { print }
    ' "${SCHEME}"
} >> "${KDEGLOBALS}"
