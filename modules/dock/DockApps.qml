pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.components
import qs.components.containers
import qs.services
import qs.config

Item {
    id: root

    required property var previewWindow
    required property Item dockContent

    property real iconSize: 35
    property real spacing: 2

    property Item lastHoveredButton: null
    property var activeMenu: null

    readonly property bool previewActive: previewPopup.show || previewPopup.hovered
    readonly property bool menuActive: activeMenu !== null

    function requestMenuOpen(menu): void {
        if (activeMenu && activeMenu !== menu) activeMenu.close();
        activeMenu = menu;
        showTimer.stop();
        hideTimer.stop();
        previewPopup.show = false;
        menu.open();
    }

    function notifyMenuClosed(menu): void {
        if (activeMenu === menu) activeMenu = null;
    }

    function onButtonHover(button, entered): void {
        if (entered) {
            const hasWindows = (button?.appEntry?.toplevels?.length ?? 0) > 0;
            if (hasWindows) {
                lastHoveredButton = button;
                hideTimer.stop();
                if (activeMenu === null && Config.dock.showPreviews)
                    showTimer.restart();
            } else {
                showTimer.stop();
                if (lastHoveredButton !== null)
                    hideTimer.restart();
            }
        } else if (lastHoveredButton === button) {
            showTimer.stop();
            hideTimer.restart();
        }
    }

    implicitWidth: listView.implicitWidth

    StyledListView {
        id: listView

        anchors.fill: parent

        orientation: ListView.Horizontal
        spacing: root.spacing
        interactive: false
        implicitWidth: contentWidth

        model: ScriptModel {
            objectProp: "appId"
            values: TaskbarApps.apps
        }

        delegate: DockAppButton {
            required property var modelData

            appEntry: modelData
            appListRoot: root
            iconSize: root.iconSize
            height: listView.height
        }

        Behavior on implicitWidth {
            Anim {
                duration: Appearance.anim.durations.small
            }
        }
    }

    HyprlandFocusGrab {
        active: root.activeMenu !== null
        windows: root.activeMenu ? [root.previewWindow, root.activeMenu] : [root.previewWindow]
        onCleared: root.activeMenu?.close()
    }

    Timer {
        id: showTimer

        interval: 80
        onTriggered: {
            if (root.activeMenu)
                return;
            if ((root.lastHoveredButton?.appEntry?.toplevels?.length ?? 0) > 0)
                previewPopup.show = true;
        }
    }

    Timer {
        id: hideTimer

        interval: 120
        onTriggered: {
            if (!previewPopup.hovered)
                previewPopup.show = false;
        }
    }

    PopupWindow {
        id: previewPopup

        readonly property var appEntry: root.lastHoveredButton?.appEntry ?? null
        readonly property bool hovered: popupHover.containsMouse

        property bool show: false

        onHoveredChanged: {
            if (hovered)
                hideTimer.stop();
            else
                hideTimer.restart();
        }

        anchor {
            window: root.previewWindow
            item: root.dockContent
            rect.x: root.lastHoveredButton ? root.lastHoveredButton.mapToItem(root.dockContent, 0, 0).x : 0
            rect.y: -(Appearance.padding.normal + 3)
            rect.width: root.lastHoveredButton?.width ?? 0
            rect.height: 0
            gravity: Edges.Top
            edges: Edges.Bottom
            adjustment: PopupAdjustment.SlideX
        }

        visible: (show || hovered) && root.lastHoveredButton !== null && (appEntry?.toplevels?.length ?? 0) > 0 && root.activeMenu === null
        color: "transparent"
        implicitWidth: popupBackground.implicitWidth
        implicitHeight: popupBackground.implicitHeight

        StyledRect {
            id: popupBackground

            readonly property int padding: Appearance.padding.small

            anchors.fill: parent
            color: Colours.layer(Colours.palette.m3surfaceContainer, 2)
            radius: Appearance.rounding.normal
            implicitHeight: previewRow.implicitHeight + padding * 2
            implicitWidth: previewRow.implicitWidth + padding * 2

            MouseArea {
                id: popupHover

                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.NoButton

                RowLayout {
                    id: previewRow

                    anchors.centerIn: parent
                    spacing: Appearance.spacing.small

                    Repeater {
                        model: ScriptModel {
                            values: previewPopup.appEntry?.toplevels ?? []
                        }

                        delegate: WindowPreview {
                            required property var modelData

                            toplevel: modelData
                        }
                    }
                }
            }
        }
    }
}
