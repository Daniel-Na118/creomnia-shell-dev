pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.components.controls
import qs.services
import qs.config

StyledRect {
    id: root

    required property DrawerVisibilities visibilities
    required property var panels
    required property Item wrapper

    readonly property int padding: Appearance.padding.small
    readonly property int innerHeight: Config.dock.height
    readonly property alias previewActive: dockApps.previewActive

    color: Colours.layer(Colours.palette.m3surfaceContainer, 1)
    radius: Appearance.rounding.large

    implicitWidth: dockRow.implicitWidth + padding * 2
    implicitHeight: innerHeight

    RowLayout {
        id: dockRow

        anchors.fill: parent
        anchors.margins: root.padding
        spacing: Appearance.spacing.small

        IconButton {
            id: pinButton

            Layout.alignment: Qt.AlignVCenter

            icon: "keep"
            toggle: true
            checked: root.wrapper.pinned
            type: IconButton.Tonal
            padding: Appearance.padding.small
            font.pointSize: Appearance.font.size.larger

            onClicked: root.wrapper.pinned = !root.wrapper.pinned
        }

        DockSeparator {
            Layout.fillHeight: true
            Layout.topMargin: root.padding
            Layout.bottomMargin: root.padding
        }

        DockApps {
            id: dockApps

            Layout.fillHeight: true

            iconSize: Config.dock.iconSize
            previewWindow: root.QsWindow.window
            dockContent: root
        }
    }
}
