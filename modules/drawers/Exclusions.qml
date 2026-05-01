pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.components.containers
import qs.modules.bar as Bar
import qs.modules.dock as Dock

Scope {
    id: root

    required property ShellScreen screen
    required property Bar.BarWrapper bar
    required property Dock.Wrapper dock
    required property real borderThickness

    ExclusionZone {
        anchors.left: true
        exclusiveZone: root.bar.exclusiveZone
    }

    ExclusionZone {
        anchors.top: true
    }

    ExclusionZone {
        anchors.right: true
    }

    ExclusionZone {
        anchors.bottom: true
        exclusiveZone: root.dock.exclusiveZone
    }

    component ExclusionZone: StyledWindow {
        screen: root.screen
        name: "border-exclusion"
        exclusiveZone: root.borderThickness
        mask: Region {}
        implicitWidth: 1
        implicitHeight: 1
    }
}
