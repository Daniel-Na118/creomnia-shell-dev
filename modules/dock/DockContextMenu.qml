pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.components
import qs.services
import qs.config

PopupWindow {
    id: root

    required property var anchorWindow
    required property Item anchorItem

    property var rows: []

    readonly property int rowHeight: 28
    readonly property int separatorHeight: 9
    readonly property int outerPadding: Appearance.padding.small
    readonly property int rowHPadding: Appearance.padding.normal
    readonly property int iconSize: 14
    readonly property int textIconSpacing: Appearance.spacing.small
    readonly property int minRowWidth: 160
    readonly property int maxRowWidth: 320
    readonly property int gapToItem: Appearance.padding.small

    function open() { visible = true; }
    function close() { visible = false; }

    function trigger(row) {
        if (!row || row.kind === "separator") return;
        close();
        if (typeof row.onTriggered === "function") row.onTriggered();
    }

    visible: false
    color: "transparent"
    implicitWidth: bg.implicitWidth
    implicitHeight: bg.implicitHeight

    anchor {
        window: root.anchorWindow
        item: root.anchorItem
        rect.x: 0
        rect.y: -root.gapToItem
        rect.width: root.anchorItem?.width ?? 0
        rect.height: 0
        gravity: Edges.Top
        edges: Edges.Bottom
        adjustment: PopupAdjustment.SlideX
    }

    StyledRect {
        id: bg

        anchors.fill: parent
        color: Colours.layer(Colours.palette.m3surfaceContainer, 2)
        radius: Appearance.rounding.normal

        implicitWidth: Math.min(root.maxRowWidth,
            Math.max(root.minRowWidth, menuColumn.implicitWidth + root.outerPadding * 2))
        implicitHeight: menuColumn.implicitHeight + root.outerPadding * 2

        Column {
            id: menuColumn

            x: root.outerPadding
            y: root.outerPadding
            width: bg.width - root.outerPadding * 2
            spacing: 0

            Repeater {
                model: root.rows

                Item {
                    id: rowItem

                    required property var modelData

                    readonly property bool isSeparator: modelData.kind === "separator"

                    width: menuColumn.width
                    implicitWidth: isSeparator
                        ? root.minRowWidth
                        : (root.rowHPadding * 2
                           + (modelData.iconSource ? root.iconSize + root.textIconSpacing : 0)
                           + rowLabel.implicitWidth)
                    implicitHeight: isSeparator ? root.separatorHeight : root.rowHeight

                    Rectangle {
                        visible: rowItem.isSeparator
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: root.rowHPadding - 4
                        anchors.rightMargin: root.rowHPadding - 4
                        height: 1
                        color: Qt.alpha(Colours.palette.m3onSurface, 0.12)
                    }

                    StyledRect {
                        visible: !rowItem.isSeparator
                        anchors.fill: parent
                        radius: Appearance.rounding.small
                        color: rowHover.containsMouse
                            ? Colours.layer(Colours.palette.m3surfaceContainerHighest, 2)
                            : "transparent"

                        Behavior on color {
                            CAnim {}
                        }

                        IconImage {
                            id: rowIcon

                            visible: !!rowItem.modelData.iconSource
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: root.rowHPadding
                            implicitSize: root.iconSize
                            source: rowItem.modelData.iconSource ?? ""
                        }

                        StyledText {
                            id: rowLabel

                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: rowIcon.visible ? rowIcon.right : parent.left
                            anchors.leftMargin: rowIcon.visible
                                ? root.textIconSpacing : root.rowHPadding
                            anchors.right: parent.right
                            anchors.rightMargin: root.rowHPadding
                            text: rowItem.modelData.label ?? ""
                            color: Colours.palette.m3onSurface
                            font.pointSize: Appearance.font.size.small
                            elide: Text.ElideRight
                        }

                        MouseArea {
                            id: rowHover

                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.LeftButton
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.trigger(rowItem.modelData)
                        }
                    }
                }
            }
        }
    }
}
