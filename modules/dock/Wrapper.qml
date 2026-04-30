pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.components
import qs.services
import qs.config

Item {
    id: root

    required property ShellScreen screen
    required property DrawerVisibilities visibilities
    required property var panels

    property bool pinned: Config.dock.pinnedOnStartup
    readonly property bool launcherOpen: visibilities.launcher && Config.launcher.enabled
    readonly property bool shouldBeActive: Config.dock.enabled && !launcherOpen && (root.pinned || visibilities.dock)

    property real offsetScale: shouldBeActive ? 0 : 1

    visible: offsetScale < 1
    anchors.bottomMargin: (-implicitHeight - 5) * offsetScale
    implicitHeight: content.implicitHeight
    implicitWidth: content.implicitWidth || 400
    opacity: 1 - offsetScale

    Component.onCompleted: Qt.callLater(() => TaskbarApps)

    Behavior on offsetScale {
        Anim {
            duration: Appearance.anim.durations.expressiveDefaultSpatial
            easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
        }
    }

    Loader {
        id: content

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        active: root.shouldBeActive || root.visible

        sourceComponent: Content {
            visibilities: root.visibilities
            panels: root.panels
            wrapper: root
        }
    }
}
