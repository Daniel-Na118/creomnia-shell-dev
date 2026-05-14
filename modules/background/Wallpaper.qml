pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.components
import qs.components.filedialog
import qs.components.images
import qs.services
import qs.config
import qs.utils

Item {
    id: root

    required property ShellScreen screen

    readonly property string monitorName: Hypr.monitorFor(screen)?.name ?? screen?.name ?? ""

    property string source: Wallpapers.currentFor(monitorName)
    property Image current
    property bool completed

    onSourceChanged: {
        if (!source)
            current = null;
        else if (current === one)
            two.update();
        else
            one.update();
    }

    Component.onCompleted: Qt.callLater(() => {
        if (source)
            one.update();
        completed = true;
    })

    Loader {
        asynchronous: true
        anchors.fill: parent

        active: root.completed && !root.source

        sourceComponent: StyledRect {
            color: Colours.palette.m3surfaceContainer

            Row {
                anchors.centerIn: parent
                spacing: Appearance.spacing.large

                MaterialIcon {
                    text: "sentiment_stressed"
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: Appearance.font.size.extraLarge * 5
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Appearance.spacing.small

                    StyledText {
                        text: qsTr("Wallpaper missing?")
                        color: Colours.palette.m3onSurfaceVariant
                        font.pointSize: Appearance.font.size.extraLarge * 2
                        font.bold: true
                    }

                    StyledRect {
                        implicitWidth: selectWallText.implicitWidth + Appearance.padding.large * 2
                        implicitHeight: selectWallText.implicitHeight + Appearance.padding.small * 2

                        radius: Appearance.rounding.full
                        color: Colours.palette.m3primary

                        FileDialog {
                            id: dialog

                            title: qsTr("Select a wallpaper")
                            filterLabel: qsTr("Image files")
                            filters: Images.validImageExtensions
                            onAccepted: path => Wallpapers.setWallpaper(path, root.monitorName)
                        }

                        StateLayer {
                            function onClicked(): void {
                                dialog.open();
                            }

                            radius: parent.radius
                            color: Colours.palette.m3onPrimary
                        }

                        StyledText {
                            id: selectWallText

                            anchors.centerIn: parent

                            text: qsTr("Set it now!")
                            color: Colours.palette.m3onPrimary
                            font.pointSize: Appearance.font.size.large
                        }
                    }
                }
            }
        }
    }

    Img {
        id: one
    }

    Img {
        id: two
    }

    component Img: CachingImage {
        id: img

        readonly property bool active: root.current === img

        function update(): void {
            if (path === root.source)
                root.current = this;
            else
                path = root.source;
        }

        anchors.fill: parent

        opacity: active ? 1 : 0
        scale: active ? 1 : (Wallpapers.showPreview ? 1 : 0.8)

        onStatusChanged: {
            if (status === Image.Ready)
                root.current = this;
        }

        Behavior on opacity {
            Anim {}
        }

        Behavior on scale {
            Anim {}
        }
    }
}
