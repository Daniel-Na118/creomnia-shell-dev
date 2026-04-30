pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland
import qs.components
import qs.components.controls
import qs.services
import qs.config

StyledRect {
    id: root

    required property Toplevel toplevel

    color: stateLayer.containsMouse ? Colours.layer(Colours.palette.m3surfaceContainerHighest, 3) : "transparent"
    radius: Appearance.rounding.small

    implicitWidth: layout.implicitWidth + padding * 2
    implicitHeight: layout.implicitHeight + padding * 2

    readonly property int padding: Appearance.padding.small

    StateLayer {
        id: stateLayer

        function onClicked(): void {
            root.toplevel?.activate();
        }
    }

    ColumnLayout {
        id: layout

        anchors.fill: parent
        anchors.margins: root.padding
        spacing: Appearance.spacing.smaller

        RowLayout {
            Layout.fillWidth: true
            Layout.maximumWidth: Config.dock.maxWindowPreviewWidth
            spacing: Appearance.spacing.smaller

            StyledText {
                Layout.fillWidth: true

                text: root.toplevel?.title ?? ""
                color: Colours.palette.m3onSurface
                font.pointSize: Appearance.font.size.small
                elide: Text.ElideRight
            }

            IconButton {
                icon: "close"
                type: IconButton.Text
                padding: 2
                font.pointSize: Appearance.font.size.normal

                onClicked: root.toplevel?.close()
            }
        }

        ScreencopyView {
            Layout.alignment: Qt.AlignHCenter

            captureSource: root.toplevel
            live: true
            paintCursor: true
            constraintSize: Qt.size(Config.dock.maxWindowPreviewWidth, Config.dock.maxWindowPreviewHeight)
        }
    }
}
