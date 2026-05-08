pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland
import Creomnia.Config
import qs.components
import qs.components.controls
import qs.services

StyledRect {
    id: root

    required property Toplevel toplevel

    color: stateLayer.containsMouse ? Colours.layer(Colours.palette.m3surfaceContainerHighest, 3) : "transparent"
    radius: Tokens.rounding.small

    implicitWidth: layout.implicitWidth + padding * 2
    implicitHeight: layout.implicitHeight + padding * 2

    readonly property int padding: Tokens.padding.small

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
        spacing: Tokens.spacing.smaller

        RowLayout {
            Layout.fillWidth: true
            Layout.maximumWidth: Config.dock.maxWindowPreviewWidth
            spacing: Tokens.spacing.smaller

            StyledText {
                Layout.fillWidth: true

                text: root.toplevel?.title ?? ""
                color: Colours.palette.m3onSurface
                font.pointSize: Tokens.font.size.small
                elide: Text.ElideRight
            }

            IconButton {
                icon: "close"
                type: IconButton.Text
                padding: 2
                font.pointSize: Tokens.font.size.normal

                onClicked: root.toplevel?.close()
            }
        }

        Item {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: screencopy.implicitWidth
            implicitHeight: screencopy.implicitHeight

            ScreencopyView {
                id: screencopy

                anchors.fill: parent
                captureSource: root.toplevel
                live: true
                paintCursor: false
                constraintSize: Qt.size(Config.dock.maxWindowPreviewWidth, Config.dock.maxWindowPreviewHeight)
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.toplevel?.activate()
            }
        }
    }
}
