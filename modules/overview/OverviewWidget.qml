pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.components
import qs.components.effects
import qs.services
import qs.config

Item {
    id: root

    required property ShellScreen screen
    required property bool overviewOpen

    readonly property HyprlandMonitor monitor: Hypr.monitorFor(screen)
    readonly property var monitorData: HyprlandData.monitors.find(m => m.id === root.monitor?.id) ?? null
    readonly property int effectiveActiveWorkspaceId: Math.max(1, Math.min(100, monitor?.activeWorkspace?.id ?? 1))
    readonly property int workspacesShown: Config.overview.rows * Config.overview.columns
    readonly property int workspaceGroup: Math.floor((effectiveActiveWorkspaceId - 1) / workspacesShown)

    readonly property real overviewScale: Config.overview.scale
    readonly property real workspaceImplicitWidth: {
        if (!monitor || !monitorData)
            return 0;
        const transformVertical = (monitorData.transform % 2) === 1;
        const usable = transformVertical ? (monitor.height - (monitorData.reserved?.[0] ?? 0) - (monitorData.reserved?.[2] ?? 0)) : (monitor.width - (monitorData.reserved?.[0] ?? 0) - (monitorData.reserved?.[2] ?? 0));
        return usable * overviewScale / monitor.scale;
    }
    readonly property real workspaceImplicitHeight: {
        if (!monitor || !monitorData)
            return 0;
        const transformVertical = (monitorData.transform % 2) === 1;
        const usable = transformVertical ? (monitor.width - (monitorData.reserved?.[1] ?? 0) - (monitorData.reserved?.[3] ?? 0)) : (monitor.height - (monitorData.reserved?.[1] ?? 0) - (monitorData.reserved?.[3] ?? 0));
        return usable * overviewScale / monitor.scale;
    }
    readonly property real largeWorkspaceRadius: Appearance.rounding.large
    readonly property real smallWorkspaceRadius: Appearance.rounding.small
    readonly property real workspaceSpacing: 5
    readonly property real workspaceNumberSize: 250 * (monitor?.scale ?? 1)
    readonly property int workspaceZ: 0
    readonly property int windowZ: 1
    readonly property int windowDraggingZ: 99999

    property int draggingFromWorkspace: -1
    property int draggingTargetWorkspace: -1

    function getWsRow(ws: int): int {
        const normalRow = Math.floor((ws - 1) / Config.overview.columns) % Config.overview.rows;
        return Config.overview.orderBottomUp ? Config.overview.rows - normalRow - 1 : normalRow;
    }

    function getWsColumn(ws: int): int {
        const normalCol = (ws - 1) % Config.overview.columns;
        return Config.overview.orderRightLeft ? Config.overview.columns - normalCol - 1 : normalCol;
    }

    function getWsInCell(ri: int, ci: int): int {
        return (Config.overview.orderBottomUp ? Config.overview.rows - ri - 1 : ri) * Config.overview.columns + (Config.overview.orderRightLeft ? Config.overview.columns - ci - 1 : ci) + 1;
    }

    implicitWidth: overviewBackground.implicitWidth + 20
    implicitHeight: overviewBackground.implicitHeight + 20

    Elevation {
        anchors.fill: overviewBackground
        radius: overviewBackground.radius
        z: -1
        level: 3
    }

    Rectangle {
        id: overviewBackground

        readonly property real padding: 10

        anchors.fill: parent
        anchors.margins: 10

        implicitWidth: workspaceColumnLayout.implicitWidth + padding * 2
        implicitHeight: workspaceColumnLayout.implicitHeight + padding * 2
        radius: root.largeWorkspaceRadius + padding
        color: Colours.palette.m3surfaceContainer

        Column {
            id: workspaceColumnLayout

            z: root.workspaceZ
            anchors.centerIn: parent
            spacing: root.workspaceSpacing

            Repeater {
                model: Config.overview.rows

                Row {
                    id: row

                    required property int index

                    spacing: root.workspaceSpacing

                    Repeater {
                        model: Config.overview.columns

                        Rectangle {
                            id: workspace

                            required property int index

                            readonly property int colIndex: index
                            readonly property int rowIndex: row.index
                            readonly property int workspaceValue: root.workspaceGroup * root.workspacesShown + root.getWsInCell(rowIndex, colIndex)
                            readonly property color defaultWorkspaceColor: Colours.palette.m3surfaceContainerLow
                            readonly property color hoveredWorkspaceColor: Colours.palette.m3surfaceContainerHigh
                            readonly property color hoveredBorderColor: Colours.palette.m3primary
                            readonly property bool workspaceAtLeft: colIndex === 0
                            readonly property bool workspaceAtRight: colIndex === Config.overview.columns - 1
                            readonly property bool workspaceAtTop: rowIndex === 0
                            readonly property bool workspaceAtBottom: rowIndex === Config.overview.rows - 1

                            property bool hoveredWhileDragging: false

                            implicitWidth: root.workspaceImplicitWidth
                            implicitHeight: root.workspaceImplicitHeight
                            color: hoveredWhileDragging ? hoveredWorkspaceColor : defaultWorkspaceColor
                            topLeftRadius: (workspaceAtLeft && workspaceAtTop) ? root.largeWorkspaceRadius : root.smallWorkspaceRadius
                            topRightRadius: (workspaceAtRight && workspaceAtTop) ? root.largeWorkspaceRadius : root.smallWorkspaceRadius
                            bottomLeftRadius: (workspaceAtLeft && workspaceAtBottom) ? root.largeWorkspaceRadius : root.smallWorkspaceRadius
                            bottomRightRadius: (workspaceAtRight && workspaceAtBottom) ? root.largeWorkspaceRadius : root.smallWorkspaceRadius
                            border.width: 2
                            border.color: hoveredWhileDragging ? hoveredBorderColor : "transparent"

                            StyledText {
                                anchors.centerIn: parent

                                text: workspace.workspaceValue
                                font.pixelSize: root.workspaceNumberSize * root.overviewScale
                                font.weight: Font.DemiBold
                                color: Qt.alpha(Colours.palette.m3onSurface, 0.2)
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            MouseArea {
                                anchors.fill: parent

                                acceptedButtons: Qt.LeftButton

                                onPressed: {
                                    if (root.draggingTargetWorkspace === -1) {
                                        const v = Visibilities.getForActive();
                                        if (v)
                                            v.overview = false;
                                        Hypr.dispatch(`workspace ${workspace.workspaceValue}`);
                                    }
                                }
                            }

                            DropArea {
                                anchors.fill: parent

                                onEntered: {
                                    root.draggingTargetWorkspace = workspace.workspaceValue;
                                    if (root.draggingFromWorkspace === root.draggingTargetWorkspace)
                                        return;
                                    workspace.hoveredWhileDragging = true;
                                }
                                onExited: {
                                    workspace.hoveredWhileDragging = false;
                                    if (root.draggingTargetWorkspace === workspace.workspaceValue)
                                        root.draggingTargetWorkspace = -1;
                                }
                            }
                        }
                    }
                }
            }
        }

        Item {
            id: windowSpace

            anchors.centerIn: parent
            implicitWidth: workspaceColumnLayout.implicitWidth
            implicitHeight: workspaceColumnLayout.implicitHeight

            Repeater {
                model: ScriptModel {
                    values: ToplevelManager.toplevels.values.filter(toplevel => {
                        const address = `0x${toplevel.HyprlandToplevel?.address}`;
                        const win = HyprlandData.windowByAddress[address];
                        return root.workspaceGroup * root.workspacesShown < win?.workspace?.id && win?.workspace?.id <= (root.workspaceGroup + 1) * root.workspacesShown;
                    })
                }

                OverviewWindow {
                    id: window

                    required property var modelData

                    readonly property string address: `0x${modelData.HyprlandToplevel.address}`
                    readonly property var winData: HyprlandData.windowByAddress[address]
                    readonly property var winMonitor: HyprlandData.monitors.find(m => m.id === winData?.monitor)
                    readonly property int workspaceColIndex: root.getWsColumn(winData?.workspace.id)
                    readonly property int workspaceRowIndex: root.getWsRow(winData?.workspace.id)
                    readonly property real xWithinWorkspaceWidget: Math.max((winData?.at[0] - (winMonitor?.x ?? 0) - (winMonitor?.reserved[0] ?? 0)) * root.overviewScale, 0)
                    readonly property real yWithinWorkspaceWidget: Math.max((winData?.at[1] - (winMonitor?.y ?? 0) - (winMonitor?.reserved[1] ?? 0)) * root.overviewScale, 0)
                    readonly property real minRadius: Appearance.rounding.small
                    readonly property bool atLeft: workspaceColIndex === 0
                    readonly property bool atRight: workspaceColIndex === Config.overview.columns - 1
                    readonly property bool atTop: workspaceRowIndex === 0
                    readonly property bool atBottom: workspaceRowIndex === Config.overview.rows - 1
                    readonly property real distanceFromLeftEdge: xWithinWorkspaceWidget
                    readonly property real distanceFromRightEdge: root.workspaceImplicitWidth - (xWithinWorkspaceWidget + targetWindowWidth)
                    readonly property real distanceFromTopEdge: yWithinWorkspaceWidget
                    readonly property real distanceFromBottomEdge: root.workspaceImplicitHeight - (yWithinWorkspaceWidget + targetWindowHeight)

                    toplevel: modelData
                    monitorData: winMonitor
                    overviewScale: root.overviewScale
                    overviewOpen: root.overviewOpen
                    widgetMonitor: HyprlandData.monitors.find(m => m.id === root.monitor?.id)
                    windowData: winData
                    xOffset: (root.workspaceImplicitWidth + root.workspaceSpacing) * workspaceColIndex
                    yOffset: (root.workspaceImplicitHeight + root.workspaceSpacing) * workspaceRowIndex
                    topLeftRadius: Math.max(((atLeft && atTop) ? root.largeWorkspaceRadius : root.smallWorkspaceRadius) - Math.max(distanceFromLeftEdge, distanceFromTopEdge), minRadius)
                    topRightRadius: Math.max(((atRight && atTop) ? root.largeWorkspaceRadius : root.smallWorkspaceRadius) - Math.max(distanceFromRightEdge, distanceFromTopEdge), minRadius)
                    bottomLeftRadius: Math.max(((atLeft && atBottom) ? root.largeWorkspaceRadius : root.smallWorkspaceRadius) - Math.max(distanceFromLeftEdge, distanceFromBottomEdge), minRadius)
                    bottomRightRadius: Math.max(((atRight && atBottom) ? root.largeWorkspaceRadius : root.smallWorkspaceRadius) - Math.max(distanceFromRightEdge, distanceFromBottomEdge), minRadius)
                    z: Drag.active ? root.windowDraggingZ : (root.windowZ + (winData?.floating ? 1 : 0) + (winData?.fullscreen ?? 0) * 2)
                    Drag.hotSpot.x: width / 2
                    Drag.hotSpot.y: height / 2

                    Timer {
                        id: updateWindowPosition

                        interval: Config.overview.arbitraryRaceConditionDelay
                        repeat: false
                        running: false
                        onTriggered: {
                            window.x = Math.round(window.xWithinWorkspaceWidget + window.xOffset);
                            window.y = Math.round(window.yWithinWorkspaceWidget + window.yOffset);
                        }
                    }

                    MouseArea {
                        id: dragArea

                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                        drag.target: parent

                        onEntered: window.hovered = true
                        onExited: window.hovered = false
                        onPressed: mouse => {
                            root.draggingFromWorkspace = window.winData?.workspace.id ?? -1;
                            window.pressed = true;
                            window.Drag.active = true;
                            window.Drag.source = window;
                            window.Drag.hotSpot.x = mouse.x;
                            window.Drag.hotSpot.y = mouse.y;
                        }
                        onReleased: {
                            const targetWorkspace = root.draggingTargetWorkspace;
                            window.pressed = false;
                            window.Drag.active = false;
                            root.draggingFromWorkspace = -1;
                            if (targetWorkspace !== -1 && targetWorkspace !== window.winData?.workspace.id) {
                                Hypr.dispatch(`movetoworkspacesilent ${targetWorkspace}, address:${window.winData?.address}`);
                                updateWindowPosition.restart();
                            } else {
                                if (!window.winData?.floating) {
                                    updateWindowPosition.restart();
                                    return;
                                }
                                const percentageX = Math.round((window.x - window.xOffset) / root.workspaceImplicitWidth * 100);
                                const percentageY = Math.round((window.y - window.yOffset) / root.workspaceImplicitHeight * 100);
                                Hypr.dispatch(`movewindowpixel exact ${percentageX}% ${percentageY}%, address:${window.winData?.address}`);
                            }
                        }
                        onClicked: event => {
                            if (!window.winData)
                                return;
                            if (event.button === Qt.LeftButton) {
                                const v = Visibilities.getForActive();
                                if (v)
                                    v.overview = false;
                                Hypr.dispatch(`focuswindow address:${window.winData.address}`);
                                event.accepted = true;
                            } else if (event.button === Qt.MiddleButton) {
                                Hypr.dispatch(`closewindow address:${window.winData.address}`);
                                event.accepted = true;
                            }
                        }
                    }
                }
            }

            Rectangle {
                id: focusedWorkspaceIndicator

                readonly property int rowIndex: root.getWsRow(root.effectiveActiveWorkspaceId)
                readonly property int colIndex: root.getWsColumn(root.effectiveActiveWorkspaceId)
                readonly property bool atLeft: colIndex === 0
                readonly property bool atRight: colIndex === Config.overview.columns - 1
                readonly property bool atTop: rowIndex === 0
                readonly property bool atBottom: rowIndex === Config.overview.rows - 1

                x: (root.workspaceImplicitWidth + root.workspaceSpacing) * colIndex
                y: (root.workspaceImplicitHeight + root.workspaceSpacing) * rowIndex
                z: root.windowZ
                width: root.workspaceImplicitWidth
                height: root.workspaceImplicitHeight
                color: "transparent"
                topLeftRadius: (atLeft && atTop) ? root.largeWorkspaceRadius : root.smallWorkspaceRadius
                topRightRadius: (atRight && atTop) ? root.largeWorkspaceRadius : root.smallWorkspaceRadius
                bottomLeftRadius: (atLeft && atBottom) ? root.largeWorkspaceRadius : root.smallWorkspaceRadius
                bottomRightRadius: (atRight && atBottom) ? root.largeWorkspaceRadius : root.smallWorkspaceRadius
                border.width: 2
                border.color: Colours.palette.m3primary

                Behavior on x {
                    Anim {}
                }

                Behavior on y {
                    Anim {}
                }

                Behavior on topLeftRadius {
                    Anim {}
                }

                Behavior on topRightRadius {
                    Anim {}
                }

                Behavior on bottomLeftRadius {
                    Anim {}
                }

                Behavior on bottomRightRadius {
                    Anim {}
                }
            }
        }
    }
}
