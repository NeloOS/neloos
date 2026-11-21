# Environment variables for the fcitx5 input method in KDE Plasma (Wayland) sessions.
#
# On Wayland, KWin already launches fcitx5 (see /etc/xdg/kwinrc) and Wayland apps
# type through the text-input protocol. As recommended by fcitx5, do NOT set
# GTK_IM_MODULE here. Only these are needed:
#   - XMODIFIERS: for X11 apps running under XWayland (many Electron apps)
#   - QT_IM_MODULES: Qt 6.7+ tries Wayland first, then falls back to fcitx
export XMODIFIERS=@im=fcitx
export QT_IM_MODULES="wayland;fcitx"
