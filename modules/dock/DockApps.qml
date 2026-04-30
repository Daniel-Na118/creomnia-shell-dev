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
        onTriggered: previewPopup.show = previewPopup.shouldShow
    }

    PopupWindow {
        id: previewPopup

        readonly property var appEntry: root.lastHoveredButton?.appEntry ?? null
        readonly property bool shouldShow: Config.dock.showPreviews && root.lastHoveredButton !== null && (popupHover.containsMouse || root.buttonHovered) && (appEntry?.toplevels?.length ?? 0) > 0

        property bool show: false

        onShouldShowChanged: showTimer.restart()

        anchor {
            window: root.previewWindow
            item: root.dockContent
            rect.x: root.lastHoveredButton ? root.lastHoveredButton.mapToItem(root.dockContent, 0, 0).x : 0
            rect.y: -(Appearance.padding.normal + 7)
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

        MouseArea {
            id: popupHover

            anchors.fill: parent
            hoverEnabled: true
        }

        StyledRect {
            id: popupBackground

            readonly property int padding: Appearance.padding.small

            color: Colours.layer(Colours.palette.m3surfaceContainer, 2)
            radius: Appearance.rounding.normal
            implicitHeight: previewRow.implicitHeight + padding * 2
            implicitWidth: previewRow.implicitWidth + padding * 2

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
