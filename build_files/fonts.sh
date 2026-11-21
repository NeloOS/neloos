#!/usr/bin/env bash
# Install the NeloOS UI font: Be Vietnam Pro (SIL Open Font License 1.1).
#
# Fedora does not package this font yet, so it is downloaded from the Google Fonts
# repository at a pinned commit and verified against be-vietnam-pro.sha256.
# To update: change COMMIT, download the files, and regenerate the checksum file
# with sha256sum.
set -euxo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMIT="c13390277dfb1fcc7415d84ef7ef9cfc1e52f8c1"
BASE_URL="https://raw.githubusercontent.com/google/fonts/${COMMIT}/ofl/bevietnampro"
DEST="/usr/share/fonts/be-vietnam-pro"
CHECKSUMS="${SCRIPT_DIR}/be-vietnam-pro.sha256"

mkdir -p "${DEST}"
cd "${DEST}"

while read -r _sum file; do
    curl --fail --silent --show-error --location --retry 3 -o "${file}" "${BASE_URL}/${file}"
done < "${CHECKSUMS}"

sha256sum --check --strict "${CHECKSUMS}"

mkdir -p /usr/share/licenses/be-vietnam-pro
mv OFL.txt /usr/share/licenses/be-vietnam-pro/OFL.txt
chmod 0644 "${DEST}"/*.ttf

fc-cache --force "${DEST}"
