# Developing NeloOS

## 1. Set up your machine

You need a Fedora machine (or any Linux with podman) with KVM.

```bash
sudo dnf install podman qemu-kvm edk2-ovmf make
```

Keep **at least 30GB free**: the image is about 7.5GB and exists in both your user
storage and root's storage, plus the VM disk and the ISO.

## 2. Main commands

| Command | What it does | Time (rough) |
|---|---|---|
| `make build` | Build the image without sudo. Use it to check the Containerfile | 5–15 min the first time |
| `make shell` | Open a shell inside the built image to inspect files | instant |
| `make qcow2` | Build the image, copy it into root's storage, then create a VM disk with NeloOS preinstalled | 10–20 min |
| `make run-vm` | Boot the VM from the qcow2 disk. Log in as `nelo` / `nelo` | instant |
| `make iso` | Create the installer ISO at `output/bootiso/install.iso` | 15–30 min |
| `make run-iso` | Test-install from the ISO onto an empty virtual disk, like a real install | |
| `make clean` | Delete the `output/` directory | |

Change the Fedora release: `make build FEDORA_VERSION=44`.

**Fastest way to test:** `make qcow2 && make run-vm`. The qcow2 disk is an already
installed system, so you skip the installer.

The Plasma panel layout is applied only on a user's first login. To see layout
changes, recreate the VM disk with `make qcow2`.

## 3. Where to change things

| To change | Edit |
|---|---|
| Preinstalled packages | `build_files/build.sh`, the `PACKAGES` array |
| OS name, version info | `build_files/branding.sh` |
| Logo, wallpaper | `branding/logo.svg`, `branding/wallpaper.svg` |
| Color scheme | `system_files/usr/share/color-schemes/NeloOS.colors` (copied into `/etc/xdg/kdeglobals` at build time by `build_files/theme.sh`) |
| UI font, font sizes | `system_files/etc/xdg/kdeglobals`; font files are downloaded by `build_files/fonts.sh` |
| Default language, time zone | `build_files/build.sh`, section 3 |
| Default theme, icons, cursor | `system_files/usr/share/plasma/look-and-feel/org.neloos.desktop/contents/defaults` |
| Desktop and taskbar layout | `.../org.neloos.desktop/contents/layouts/org.kde.plasma.desktop-layout.js` |
| Apps pinned in the Start Menu | `system_files/etc/xdg/kicker-extra-favoritesrc` |
| Vietnamese input method | `system_files/etc/xdg/kwinrc`, `system_files/etc/skel/.config/fcitx5/profile`, `system_files/etc/xdg/plasma-workspace/env/neloos-input-method.sh` |

### Principles

- **Change defaults only, never override user choices.** Files in `/etc/xdg` are
  KDE's system defaults. Anything users set themselves (in `~/.config`) always wins.
- **`/etc/skel` only applies to newly created users.** Existing users do not get
  these changes.
- **Things that integrate deeply with the system go into the image**: drivers,
  input methods, fonts, codecs. **User applications are Flatpaks**: browsers,
  office suites, chat apps.
- **Packages that install into `/opt`** (third-party vendor software) need special
  handling, because on atomic systems `/opt` points to `/var/opt`.
- **English for code, comments and commit messages; Vietnamese first for
  anything users see** (UI strings, user docs, website).

## 4. CI/CD (GitHub Actions)

- **`build.yml`** builds the image and pushes it to `ghcr.io/<org>/neloos`.
  Pushing to `main` does not build anything.
  - **Release:** push a version tag. `git tag v0.1.0 && git push origin v0.1.0`
    publishes the image as `0.1.0` and `latest`. Installed machines follow
    `latest`, so they only get tagged releases.
  - **Test build:** run the workflow manually from the Actions tab. It publishes
    `testing` only. To try it on a machine: `sudo bootc switch ghcr.io/<org>/neloos:testing`.
- **`build-iso.yml`** runs manually from the Actions tab. The ISO is uploaded to
  that run's Artifacts and kept for 7 days.

After the first image is pushed, go to **GitHub > Packages > neloos > Package
settings** and set the visibility to **Public**, so installed machines can pull
updates.

## 5. Test checklist

The three biggest risks, to verify in a VM first and then on real hardware:

**Vietnamese typing**
- [ ] Ctrl+Space toggles English/Vietnamese; Telex produces correct diacritics
- [ ] Typing works in Kate, Dolphin (renaming a file), Konsole
- [ ] Typing works in Firefox, Chromium (Flatpak), LibreOffice (Flatpak)
- [ ] Typing works in an Electron app (e.g. VSCodium)
- [ ] No repeated characters or lost diacritics when typing fast

**Office documents**
- [ ] `.docx`, `.xlsx`, `.pptx` files made on Windows open without broken fonts or shifted lines
- [ ] Print to PDF and compare with the Windows version

**Digital signatures**
- [ ] A digital-signature USB token from a Vietnamese certificate authority is detected when plugged in
- [ ] Signing works on the e-tax (thuế điện tử) or social insurance (BHXH) portals

**System**
- [ ] `sudo bootc upgrade`, reboot: the machine runs the new version
- [ ] `sudo bootc rollback`, reboot: the machine is back on the previous version
- [ ] Settings > About this System shows the NeloOS name and logo
- [ ] Wallpaper and lock screen are NeloOS's

**Look and feel**
- [ ] Vietnamese UI, clock in Vietnam time, dates as dd/mm/yyyy
- [ ] Jade accent color (selection, buttons, links); Be Vietnam Pro renders all diacritics
- [ ] Taskbar: Start button is the NeloOS logo; Dolphin, browser, Discover are pinned
- [ ] Is 10pt too large? (Be Vietnam Pro is wider than Noto Sans)
