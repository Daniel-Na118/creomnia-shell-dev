pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import qs.services
import qs.config

Scope {
    id: root

    function open(): void {
        const v = Visibilities.getForActive();
        if (v)
            v.overview = true;
    }

    function close(): void {
        const v = Visibilities.getForActive();
        if (v)
            v.overview = false;
    }

    function toggle(): void {
        const v = Visibilities.getForActive();
        if (v)
            v.overview = !v.overview;
    }

    function isOpen(): bool {
        return Visibilities.getForActive()?.overview ?? false;
    }

    function cycle(direction: int): void {
        Hypr.dispatch(`workspace ${direction > 0 ? "e+1" : "e-1"}`);
    }

    Variants {
        model: Screens.screens

        PanelWindow {
            id: panelWindow

            required property ShellScreen modelData

            readonly property HyprlandMonitor monitor: Hypr.monitorFor(modelData)
            readonly property bool isFocused: Hypr.focusedMonitor?.id === monitor?.id
            readonly property var visibilities: Visibilities.screens.get(monitor) ?? null
            readonly property bool overviewOpen: (visibilities?.overview ?? false) && Config.overview.enabled

            screen: modelData
            visible: overviewOpen
            color: "transparent"

            WlrLayershell.namespace: "creomnia-overview"
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.keyboardFocus: overviewOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            anchors.top: true
            anchors.bottom: true
            anchors.left: true
            anchors.right: true
            mask: Region {
                item: panelWindow.overviewOpen ? overviewLoader : null
            }

            HyprlandFocusGrab {
                id: focusGrab

                active: panelWindow.overviewOpen && panelWindow.isFocused
                windows: [panelWindow]

                onCleared: root.close()
            }

            Item {
                anchors.fill: parent

                focus: panelWindow.overviewOpen

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        root.close();
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Left) {
                        Hypr.dispatch("workspace r-1");
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Right) {
                        Hypr.dispatch("workspace r+1");
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Tab) {
                        if (event.modifiers & Qt.ShiftModifier)
                            root.cycle(-1);
                        else
                            root.cycle(1);
                        event.accepted = true;
                    }
                }

                Loader {
                    id: overviewLoader

                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top

                    active: panelWindow.overviewOpen

                    sourceComponent: OverviewWidget {
                        screen: panelWindow.modelData
                        overviewOpen: panelWindow.overviewOpen
                    }
                }
            }
        }
    }

    IpcHandler {
        function toggle(): void {
            root.toggle();
        }

        function open(): void {
            root.open();
        }

        function close(): void {
            root.close();
        }

        function cycleNext(): void {
            root.cycle(1);
        }

        function cyclePrev(): void {
            root.cycle(-1);
        }

        target: "overview"
    }
}
