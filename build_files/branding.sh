#!/usr/bin/env bash
# Rename the operating system to NeloOS.
#
# Note: ID=fedora and VERSION_ID are kept on purpose. Many tools
# (bootc-image-builder, Anaconda, dnf) rely on them to identify the system.
# Only the user-facing names change, following Fedora's "Remix" trademark guidelines.
set -euxo pipefail

FEDORA_VERSION="${1:-$(rpm -E %fedora)}"
PROJECT_URL="https://github.com/neloos/neloos"

# /usr/lib/os-release is usually a symlink into /usr/lib/os.release.d/, so edit the real file.
OS_RELEASE="$(realpath /usr/lib/os-release)"

set_os_release() {
    local key="$1" value="$2"
    if grep -q "^${key}=" "${OS_RELEASE}"; then
        sed -i "s|^${key}=.*|${key}=\"${value}\"|" "${OS_RELEASE}"
    else
        echo "${key}=\"${value}\"" >> "${OS_RELEASE}"
    fi
}

set_os_release NAME             "NeloOS"
set_os_release PRETTY_NAME      "NeloOS ${FEDORA_VERSION} (Alpha)"
set_os_release LOGO             "neloos-logo"
set_os_release DEFAULT_HOSTNAME "neloos"
set_os_release HOME_URL         "${PROJECT_URL}"
set_os_release DOCUMENTATION_URL "${PROJECT_URL}/tree/main/docs"
set_os_release SUPPORT_URL      "${PROJECT_URL}/issues"
set_os_release BUG_REPORT_URL   "${PROJECT_URL}/issues"

# Shown on KDE's "About this System" page.
ln -sf /usr/share/neloos/logo-256.png /usr/share/pixmaps/neloos-logo.png

# Refresh the icon cache so LOGO=neloos-logo can be found.
gtk-update-icon-cache -f /usr/share/icons/hicolor 2>/dev/null || true
