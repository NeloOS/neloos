// Default NeloOS desktop layout, familiar to Windows users:
//   [Start (NeloOS logo)] [pinned apps + open windows ......] [system tray] [clock] [show desktop]
//
// Differences from Plasma's default panel: no virtual desktop pager, and the
// taskbar spans the full width instead of floating. Later, an "Ask Nelo" box
// will be added right after the Start button.

var panel = new Panel;
panel.location = "bottom";
panel.floating = false;

// Same height as Plasma's default panel (an even number that fits the task manager icons).
panel.height = 2 * Math.ceil(gridUnit * 2.5 / 2);

// Ultra-wide screens: cap the taskbar at a 21:9 ratio, like Plasma does.
var maximumAspectRatio = 21 / 9;
var geo = screenGeometry(panel.screen);
var maximumWidth = Math.ceil(geo.height * maximumAspectRatio);
if (geo.width > maximumWidth) {
    panel.alignment = "center";
    panel.minimumLength = maximumWidth;
    panel.maximumLength = maximumWidth;
}

// Start button with the NeloOS logo.
var kickoff = panel.addWidget("org.kde.plasma.kickoff");
kickoff.currentConfigGroup = ["General"];
kickoff.writeConfig("icon", "neloos-logo");

// Apps pinned to the taskbar: file manager, web browser, app store.
var tasks = panel.addWidget("org.kde.plasma.icontasks");
tasks.currentConfigGroup = ["General"];
tasks.writeConfig("launchers", [
    "preferred://filemanager",
    "preferred://browser",
    "applications:org.kde.discover.desktop"
]);

panel.addWidget("org.kde.plasma.marginsseparator");
panel.addWidget("org.kde.plasma.systemtray");
panel.addWidget("org.kde.plasma.digitalclock");
panel.addWidget("org.kde.plasma.showdesktop");

// Use the NeloOS wallpaper on the desktop.
var desktopsArray = desktopsForActivity(currentActivity());
for (var j = 0; j < desktopsArray.length; j++) {
    desktopsArray[j].wallpaperPlugin = "org.kde.image";
}
