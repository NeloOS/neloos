#!/usr/bin/env bash
# Main NeloOS build script, run from the Containerfile.
set -euxo pipefail

FEDORA_VERSION="$(rpm -E %fedora)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---------------------------------------------------------------------------
# 1. Packages baked into the image
#    Rule: only things that integrate deeply with the system go into the image.
#    User applications (browser, office suite, chat...) are installed as Flatpaks.
# ---------------------------------------------------------------------------
PACKAGES=(
    # Vietnamese input: fcitx5 + Unikey (Telex/VNI), launched by KWin on Wayland
    fcitx5
    fcitx5-unikey
    fcitx5-qt
    fcitx5-qt6
    fcitx5-gtk
    # Input method settings tool. kcm-fcitx5 (the System Settings page) is not used
    # yet: the F45 build still links against the old libPlasma.so.7 and cannot be
    # installed (as of 2026-11).
    fcitx5-configtool

    # Vietnamese locale, spell-checking dictionaries and translations
    glibc-langpack-vi
    langpacks-vi

    # Fonts metric-compatible with Microsoft Office fonts, so .docx/.xlsx layouts
    # do not shift:
    #   Carlito ~ Calibri, Caladea ~ Cambria,
    #   Liberation ~ Arial / Times New Roman / Courier New
    google-carlito-fonts
    google-crosextra-caladea-fonts
    liberation-fonts-all
)

dnf install -y "${PACKAGES[@]}"

# ---------------------------------------------------------------------------
# 2. Flathub: the main app source for Discover / Nelo Store
# ---------------------------------------------------------------------------
mkdir -p /etc/flatpak/remotes.d
curl --fail --silent --show-error --location \
    --retry 3 \
    -o /etc/flatpak/remotes.d/flathub.flatpakrepo \
    https://dl.flathub.org/repo/flathub.flatpakrepo

# ---------------------------------------------------------------------------
# 3. Vietnamese defaults: Vietnamese UI language, Vietnam time zone.
#    The installer (Anaconda) still lets users choose; their choice wins.
# ---------------------------------------------------------------------------
echo 'LANG=vi_VN.UTF-8' > /etc/locale.conf
ln -sf ../usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime

# ---------------------------------------------------------------------------
# 4. Look and feel: Be Vietnam Pro font, NeloOS color scheme, branding
# ---------------------------------------------------------------------------
"${SCRIPT_DIR}/fonts.sh"
"${SCRIPT_DIR}/theme.sh"
"${SCRIPT_DIR}/branding.sh" "${FEDORA_VERSION}"

# ---------------------------------------------------------------------------
# 5. Cleanup: leave no caches in the image (keeps bootc container lint clean)
# ---------------------------------------------------------------------------
dnf clean all
rm -rf /var/cache/dnf /var/cache/libdnf5 /var/lib/dnf/repos /var/log/dnf* \
    /var/cache/ibus /var/cache/ldconfig/aux-cache /run/dnf /tmp/* || true
