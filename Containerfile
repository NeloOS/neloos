# NeloOS – a Linux desktop operating system.
# Based on Fedora Kinoite (KDE Plasma, atomic) and booted with bootc.

ARG FEDORA_VERSION=45
ARG BASE_IMAGE=quay.io/fedora-ostree-desktops/kinoite

# ---------------------------------------------------------------------------
# Stage 1: render branding (SVG -> PNG), so the repo only keeps SVG sources.
# ---------------------------------------------------------------------------
FROM registry.fedoraproject.org/fedora:${FEDORA_VERSION} AS assets

RUN dnf install -y librsvg2-tools && dnf clean all

COPY branding/ /src/

RUN set -eux; \
    mkdir -p /out/wallpaper /out/logo; \
    for size in 1920x1080 2560x1440 3840x2160; do \
        rsvg-convert -w "${size%x*}" -h "${size#*x}" /src/wallpaper.svg -o "/out/wallpaper/${size}.png"; \
    done; \
    rsvg-convert -w 1920 -h 1080 /src/wallpaper.svg -o /out/wallpaper/screenshot.png; \
    for px in 64 128 256 512; do \
        rsvg-convert -w "$px" -h "$px" /src/logo.svg -o "/out/logo/logo-${px}.png"; \
    done

# ---------------------------------------------------------------------------
# Stage 2: the NeloOS system image.
# ---------------------------------------------------------------------------
FROM ${BASE_IMAGE}:${FEDORA_VERSION}

# Image metadata. "source" links the package on ghcr.io to the GitHub repository.
LABEL org.opencontainers.image.title="NeloOS" \
      org.opencontainers.image.description="A Linux desktop operating system" \
      org.opencontainers.image.source="https://github.com/neloos/neloos" \
      org.opencontainers.image.licenses="Apache-2.0"

# System configuration: /etc/xdg (KDE defaults), /etc/skel (new-user config),
# the NeloOS look-and-feel, color scheme and wallpaper package.
COPY system_files/ /

# Branding rendered in stage 1.
COPY --from=assets /out/wallpaper/ /usr/share/wallpapers/NeloOS/contents/images/
COPY --from=assets /out/logo/ /usr/share/neloos/
COPY branding/logo.svg /usr/share/neloos/logo.svg
# The icon (Start button, small sizes) uses the simplified small-size variant.
COPY branding/logo-small.svg /usr/share/icons/hicolor/scalable/apps/neloos-logo.svg

# Install packages and apply branding.
COPY build_files/ /tmp/build_files/
RUN /tmp/build_files/build.sh && rm -rf /tmp/build_files

# Check that the image follows bootc conventions.
RUN bootc container lint
