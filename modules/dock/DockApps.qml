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

    property real iconSize: 35
    property real spacing: 2

    property Item lastHoveredButton: null
    property bool buttonHovered: false

    function popupCenterXForButton(button: Item): real {
        if (!button || !root.previewWindow)
            return 0;
        return root.previewWindow.contentItem.mapFromItem(button, button.width / 2, 0).x;
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

    PopupWindow {
        id: previewPopup

        readonly property var appEntry: root.lastHoveredButton?.appEntry ?? null
        readonly property bool shouldShow: Config.dock.showPreviews && (popupMouseArea.containsMouse || root.buttonHovered) && (appEntry?.toplevels?.length ?? 0) > 0

        property bool show: false
        property real cachedCenterX: 0

        anchor {
            window: root.previewWindow
            adjustment: PopupAdjustment.None
            gravity: Edges.Top
            edges: Edges.Top
        }

        visible: popupBackground.opacity > 0
        color: "transparent"
        implicitWidth: root.previewWindow?.width ?? 1
        implicitHeight: popupMouseArea.implicitHeight

        onShouldShowChanged: updateTimer.restart()

        Connections {
            function onLastHoveredButtonChanged(): void {
                if (root.lastHoveredButton)
                    previewPopup.cachedCenterX = root.popupCenterXForButton(root.lastHoveredButton);
            }

            function onButtonHoveredChanged(): void {
                if (root.buttonHovered && root.lastHoveredButton)
                    previewPopup.cachedCenterX = root.popupCenterXForButton(root.lastHoveredButton);
                updateTimer.restart();
            }

            target: root
        }

        Timer {
            id: updateTimer

            interval: 100

            onTriggered: previewPopup.show = previewPopup.shouldShow
        }

        MouseArea {
            id: popupMouseArea

            anchors.bottom: parent.bottom
            x: previewPopup.cachedCenterX - width / 2

            implicitWidth: popupBackground.implicitWidth + Appearance.padding.normal * 2
            implicitHeight: Config.dock.maxWindowPreviewHeight + Appearance.padding.normal * 2
            hoverEnabled: true

            StyledRect {
                id: popupBackground

                readonly property int padding: Appearance.padding.small

                anchors.bottom: parent.bottom
                anchors.bottomMargin: Appearance.padding.normal
                anchors.horizontalCenter: parent.horizontalCenter

                opacity: previewPopup.show ? 1 : 0
                visible: opacity > 0
                clip: true
                color: Colours.layer(Colours.palette.m3surfaceContainer, 2)
                radius: Appearance.rounding.normal

                implicitHeight: previewRow.implicitHeight + padding * 2
                implicitWidth: previewRow.implicitWidth + padding * 2

                Behavior on opacity {
                    Anim {}
                }

                Behavior on implicitWidth {
                    Anim {}
                }

                Behavior on implicitHeight {
                    Anim {}
                }

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
