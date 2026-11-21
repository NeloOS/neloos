# NeloOS

**An operating system for Vietnamese users, ready to work with AI.**

[Tiếng Việt](README.vi.md)

NeloOS is based on [Fedora Kinoite](https://fedoraproject.org/atomic-desktops/kinoite/)
(KDE Plasma, atomic edition) and is shipped as a bootable container image using
[bootc](https://bootc-dev.github.io/bootc/).

The name comes from *Nelumbo*, the scientific name of the lotus genus.

> Status: **Alpha**. The foundation is being built; not ready for daily work yet.

## What's included

- KDE Plasma on Fedora 45 with atomic updates: if an update breaks, roll back to the previous version.
- Vietnamese input (fcitx5 + Unikey) enabled out of the box on Wayland (Ctrl+Space toggles English/Vietnamese).
- Vietnamese language packs and Office-compatible fonts (Carlito, Caladea, Liberation).
- Vietnamese UI language and Vietnam time zone by default (changeable during install).
- NeloOS look: jade color scheme, Be Vietnam Pro font, a Windows-like taskbar
  (Start button, pinned apps, system tray, clock).
- Flathub enabled in Discover.
- NeloOS branding: OS name, logo, wallpaper, lock screen.

## Repository layout

```
.
├── Containerfile          # NeloOS image definition
├── build_files/           # Build-time scripts: packages, fonts, theme, branding
├── system_files/          # Files copied as-is into / of the image
│   ├── etc/xdg/           #   KDE defaults (input method, fonts, colors, logo)
│   ├── etc/skel/          #   config for new users (fcitx5)
│   └── usr/share/         #   look-and-feel, color scheme, wallpaper package
├── branding/              # Logo and wallpaper as SVG (rendered to PNG at build time)
├── disk_config/           # Installer ISO and VM disk configs
├── .github/workflows/     # GitHub Actions: build the image, build the ISO
├── docs/                  # Developer documentation
└── Makefile               # Local build and test commands
```

## Build and test

See [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md).

In short:

```bash
sudo dnf install podman qemu-kvm edk2-ovmf make
make qcow2     # build the image and create a VM disk
make run-vm    # boot NeloOS in a VM (login: nelo / nelo)
```

## Updating an installed system

```bash
sudo bootc upgrade     # download the new version, applied on next boot
sudo bootc rollback    # go back to the previous version if something breaks
```

## Contributing

Contributions are welcome from anywhere. Code, comments, commit messages and
developer docs are in English; everything users see is Vietnamese first.

## License and trademarks

- Source code: [Apache-2.0](LICENSE). Exceptions are listed in [NOTICE](NOTICE).
- Logo, wallpaper: CC-BY-SA-4.0, see [branding/README.md](branding/README.md).
- The NeloOS name and logo: see [TRADEMARKS.md](TRADEMARKS.md). Redistributed
  derivatives must use a different name and logo.

NeloOS is an independent remix of Fedora and is not sponsored or endorsed by the
Fedora Project. Fedora is a trademark of Red Hat, Inc.
