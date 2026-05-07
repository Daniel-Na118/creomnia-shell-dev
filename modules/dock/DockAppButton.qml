pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.components
import qs.services
import qs.config
import qs.utils

Item {
    id: root

    required property var appEntry
    required property Item appListRoot

    property real iconSize: 35
    property int countDotWidth: 10
    property int countDotHeight: 4
    property int cycleIdx: -1

    readonly property var toplevels: appEntry.toplevels

    function cycleNext(): void {
        if (root.toplevels.length === 0)
            return;
        let activeIdx = -1;
        for (let i = 0; i < root.toplevels.length; ++i) {
            if (root.toplevels[i]?.activated) {
                activeIdx = i;
                break;
            }
        }
        const start = activeIdx >= 0 ? activeIdx : root.cycleIdx;
        const next = (start + 1) % root.toplevels.length;
        root.cycleIdx = next;
        root.toplevels[next]?.activate();
    }

    function showContextMenu(): void {
        const rows = [];
        const iconSrc = Icons.getAppIcon(root.appEntry.appId, "image-missing");

        for (let i = 0; i < root.toplevels.length; ++i) {
            const t = root.toplevels[i];
            rows.push({
                kind: "row",
                label: t.title || root.appEntry.appId,
                iconSource: iconSrc,
                onTriggered: () => t.activate()
            });
        }
        if (root.toplevels.length > 0) rows.push({ kind: "separator" });

        if (root.desktopEntry?.actions?.length > 0) {
            for (let i = 0; i < root.desktopEntry.actions.length; ++i) {
                const a = root.desktopEntry.actions[i];
                rows.push({
                    kind: "row",
                    label: a.name || a.id,
                    iconSource: a.icon ? Icons.getAppIcon(a.icon, "image-missing") : "",
                    onTriggered: () => a.execute()
                });
            }
            rows.push({ kind: "separator" });
        }

        if (root.desktopEntry) {
            const hasWindows = root.toplevels.length > 0;
            if (!hasWindows || !root.desktopEntry.singleMainWindow) {
                const baseName = root.desktopEntry.name || root.appEntry.appId;
                rows.push({
                    kind: "row",
                    label: hasWindows ? "New Window – " + baseName : baseName,
                    iconSource: iconSrc,
                    onTriggered: () => root.desktopEntry.execute()
                });
            }
        }

        rows.push({
            kind: "row",
            label: root.appEntry.pinned ? "Unpin from Dock" : "Pin to Dock",
            iconSource: "",
            onTriggered: () => TaskbarApps.togglePin(root.appEntry.appId)
        });

        if (root.toplevels.length === 1) {
            rows.push({
                kind: "row",
                label: "Close",
                iconSource: "",
                onTriggered: () => root.toplevels[0].close()
            });
        }

        dockContextMenu.rows = rows;
        root.appListRoot.requestMenuOpen(dockContextMenu);
    }

    readonly property bool appIsActive: {
        for (const t of toplevels)
            if (t?.activated)
                return true;
        return false;
    }
    property var desktopEntry: DesktopEntries.heuristicLookup(appEntry.appId)

    implicitWidth: height

    Connections {
        function onApplicationsChanged(): void {
            root.desktopEntry = DesktopEntries.heuristicLookup(root.appEntry.appId);
        }

        target: DesktopEntries
    }

    DockContextMenu {
        id: dockContextMenu

        anchorWindow: root.appListRoot.previewWindow
        anchorItem: root

        onVisibleChanged: {
            if (!visible) root.appListRoot.notifyMenuClosed(dockContextMenu);
        }
    }

    Loader {
        anchors.fill: parent

        sourceComponent: StyledRect {
            id: btn

            color: stateLayer.containsMouse ? Colours.layer(Colours.palette.m3surfaceContainerHighest, 2) : "transparent"
            radius: Appearance.rounding.small

            Behavior on color {
                CAnim {}
            }

            StateLayer {
                id: stateLayer

                acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton

                function onClicked(event): void {
                    if (event.button === Qt.RightButton) {
                        root.showContextMenu();
                        return;
                    }
                    if (event.button === Qt.MiddleButton) {
                        root.desktopEntry?.execute();
                        return;
                    }
                    if (root.toplevels.length === 0) {
                        root.desktopEntry?.execute();
                        return;
                    }
                    if (root.toplevels.length === 1) {
                        root.toplevels[0]?.activate();
                        return;
                    }
                    root.cycleNext();
                }
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
                hoverEnabled: true

                onEntered: {
                    root.appListRoot.lastHoveredButton = root;
                    root.appListRoot.buttonHovered = true;
                }

                onExited: {
                    if (root.appListRoot.lastHoveredButton === root)
                        root.appListRoot.buttonHovered = false;
                }
            }

            IconImage {
                id: iconImage

                anchors.centerIn: parent
                anchors.verticalCenterOffset: -root.countDotHeight / 2

                source: Icons.getAppIcon(root.appEntry.appId, "image-missing")
                implicitSize: root.iconSize
            }

            RowLayout {
                anchors.top: iconImage.bottom
                anchors.topMargin: 2
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 3

                Repeater {
                    model: Math.min(root.toplevels.length, 3)

                    delegate: StyledRect {
                        radius: Appearance.rounding.full
                        implicitWidth: root.toplevels.length <= 3 ? root.countDotWidth : root.countDotHeight
                        implicitHeight: root.countDotHeight
                        color: root.appIsActive ? Colours.palette.m3primary : Qt.alpha(Colours.palette.m3onSurfaceVariant, 0.6)
                    }
                }
            }
        }
    }
}
