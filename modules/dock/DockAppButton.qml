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
    property int lastFocused: -1

    readonly property bool isSeparator: appEntry.appId === "SEPARATOR"
    readonly property var toplevels: appEntry.toplevels
    readonly property bool appIsActive: {
        for (const t of toplevels)
            if (t?.activated)
                return true;
        return false;
    }
    property var desktopEntry: DesktopEntries.heuristicLookup(appEntry.appId)

    implicitWidth: isSeparator ? Appearance.spacing.smaller : height

    Connections {
        function onApplicationsChanged(): void {
            root.desktopEntry = DesktopEntries.heuristicLookup(root.appEntry.appId);
        }

        target: DesktopEntries
    }

    Loader {
        anchors.fill: parent
        active: root.isSeparator

        sourceComponent: DockSeparator {}
    }

    Loader {
        anchors.fill: parent
        active: !root.isSeparator

        sourceComponent: StyledRect {
            id: btn

            color: stateLayer.containsMouse ? Colours.layer(Colours.palette.m3surfaceContainerHighest, 2) : "transparent"
            radius: Appearance.rounding.small

            Behavior on color {
                CAnim {}
            }

            StateLayer {
                id: stateLayer

                function onClicked(): void {
                    if (root.toplevels.length === 0) {
                        root.desktopEntry?.execute();
                        return;
                    }
                    root.lastFocused = (root.lastFocused + 1) % root.toplevels.length;
                    root.toplevels[root.lastFocused]?.activate();
                }
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.MiddleButton | Qt.RightButton
                hoverEnabled: true
                propagateComposedEvents: true

                onEntered: {
                    root.appListRoot.lastHoveredButton = root;
                    root.appListRoot.buttonHovered = true;
                    if (root.toplevels.length > 0)
                        root.lastFocused = root.toplevels.length - 1;
                }

                onExited: {
                    if (root.appListRoot.lastHoveredButton === root)
                        root.appListRoot.buttonHovered = false;
                }

                onClicked: event => {
                    if (event.button === Qt.MiddleButton)
                        root.desktopEntry?.execute();
                    else if (event.button === Qt.RightButton && (event.modifiers & Qt.AltModifier))
                        TaskbarApps.togglePin(root.appEntry.appId);
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
