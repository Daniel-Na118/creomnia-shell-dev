pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
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
    property bool buttonHovered: false
    property var activeMenu: null

    readonly property bool previewActive: previewPopup.show

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

    Timer {
        id: showTimer

        interval: 80
        onTriggered: previewPopup.show = true
    }

    Timer {
        id: hideTimer

        interval: 250
        onTriggered: previewPopup.show = false
    }

    PopupWindow {
        id: previewPopup

        readonly property var appEntry: root.lastHoveredButton?.appEntry ?? null
        readonly property bool shouldShow: Config.dock.showPreviews && root.lastHoveredButton !== null && (popupHover.containsMouse || root.buttonHovered) && (appEntry?.toplevels?.length ?? 0) > 0 && root.activeMenu === null

        property bool show: false

        onShouldShowChanged: {
            if (shouldShow) {
                hideTimer.stop();
                showTimer.restart();
            } else if (popupHover.containsMouse) {
                showTimer.stop();
            } else {
                showTimer.stop();
                hideTimer.restart();
            }
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

        visible: show && root.lastHoveredButton !== null
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
