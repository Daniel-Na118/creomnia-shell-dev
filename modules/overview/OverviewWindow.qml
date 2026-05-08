pragma ComponentBehavior: Bound

import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import Creomnia.Config
import qs.components
import qs.services
import qs.utils

Item {
    id: root

    required property var toplevel
    required property var windowData
    required property var monitorData
    required property var widgetMonitor
    required property real overviewScale
    required property bool overviewOpen

    property real xOffset: 0
    property real yOffset: 0

    property real topLeftRadius: 0
    property real topRightRadius: 0
    property real bottomLeftRadius: 0
    property real bottomRightRadius: 0

    property bool hovered: false
    property bool pressed: false

    readonly property int widgetMonitorId: widgetMonitor?.id ?? -1
    readonly property real widthRatio: {
        if (!monitorData || !widgetMonitor)
            return 1;
        const widgetWidth = (widgetMonitor.transform & 1) ? widgetMonitor.height : widgetMonitor.width;
        const monitorWidth = (monitorData.transform & 1) ? monitorData.height : monitorData.width;
        return (widgetWidth * monitorData.scale) / (monitorWidth * widgetMonitor.scale);
    }
    readonly property real heightRatio: {
        if (!monitorData || !widgetMonitor)
            return 1;
        const widgetHeight = (widgetMonitor.transform & 1) ? widgetMonitor.width : widgetMonitor.height;
        const monitorHeight = (monitorData.transform & 1) ? monitorData.width : monitorData.height;
        return (widgetHeight * monitorData.scale) / (monitorHeight * widgetMonitor.scale);
    }
    readonly property real initX: Math.max((windowData?.at[0] - (monitorData?.x ?? 0) - (monitorData?.reserved[0] ?? 0)) * widthRatio * overviewScale, 0) + xOffset
    readonly property real initY: Math.max((windowData?.at[1] - (monitorData?.y ?? 0) - (monitorData?.reserved[1] ?? 0)) * heightRatio * overviewScale, 0) + yOffset
    readonly property real targetWindowWidth: (windowData?.size[0] ?? 0) * overviewScale * widthRatio
    readonly property real targetWindowHeight: (windowData?.size[1] ?? 0) * overviewScale * heightRatio

    readonly property bool centerIcons: Config.overview.centerIcons
    readonly property real iconGapRatio: 0.06
    readonly property real iconToWindowRatio: centerIcons ? 0.35 : 0.15
    readonly property real iconToWindowRatioCompact: 0.6
    readonly property bool compactMode: Tokens.font.size.smaller * 4 > targetWindowHeight || Tokens.font.size.smaller * 4 > targetWindowWidth
    readonly property string iconPath: Icons.getAppIcon(windowData?.class ?? "", "image-missing")

    x: initX
    y: initY
    width: targetWindowWidth
    height: targetWindowHeight
    opacity: windowData?.monitor === widgetMonitorId ? 1 : 0.4
    layer.enabled: true
    layer.effect: OpacityMask {
        maskSource: Rectangle {
            width: root.width
            height: root.height
            topLeftRadius: root.topLeftRadius
            topRightRadius: root.topRightRadius
            bottomRightRadius: root.bottomRightRadius
            bottomLeftRadius: root.bottomLeftRadius
        }
    }

    Behavior on x {
        Anim {}
    }

    Behavior on y {
        Anim {}
    }

    Behavior on width {
        Anim {}
    }

    Behavior on height {
        Anim {}
    }

    ScreencopyView {
        id: windowPreview

        anchors.fill: parent

        captureSource: root.overviewOpen ? root.toplevel : null
        live: true

        Rectangle {
            anchors.fill: parent

            topLeftRadius: root.topLeftRadius
            topRightRadius: root.topRightRadius
            bottomRightRadius: root.bottomRightRadius
            bottomLeftRadius: root.bottomLeftRadius
            color: root.pressed ? Qt.alpha(Colours.palette.m3primary, 0.5) : root.hovered ? Qt.alpha(Colours.palette.m3primary, 0.3) : "transparent"
            border.color: Qt.alpha(Colours.palette.m3outline, 0.12)
            border.width: 1
        }

        Image {
            id: windowIcon

            readonly property real baseSize: Math.min(root.targetWindowWidth, root.targetWindowHeight)
            readonly property real iconSize: baseSize * (root.compactMode ? root.iconToWindowRatioCompact : root.iconToWindowRatio)

            anchors.top: root.centerIcons ? undefined : parent.top
            anchors.left: root.centerIcons ? undefined : parent.left
            anchors.centerIn: root.centerIcons ? parent : undefined
            anchors.margins: baseSize * root.iconGapRatio

            source: root.iconPath
            width: iconSize
            height: iconSize
            sourceSize: Qt.size(iconSize, iconSize)

            Behavior on width {
                Anim {}
            }

            Behavior on height {
                Anim {}
            }
        }
    }
}
