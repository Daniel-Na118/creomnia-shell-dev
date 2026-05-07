pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland

Singleton {
    id: root

    property var windowList: []
    property var addresses: []
    property var windowByAddress: ({})
    property var workspaces: []
    property var workspaceIds: []
    property var workspaceById: ({})
    property var activeWorkspace: null
    property var monitors: []

    function toplevelsForWorkspace(workspace: int): var {
        return ToplevelManager.toplevels.values.filter(toplevel => {
            const address = `0x${toplevel.HyprlandToplevel?.address}`;
            const win = root.windowByAddress[address];
            return win?.workspace?.id === workspace;
        });
    }

    function clientForToplevel(toplevel: var): var {
        if (!toplevel || !toplevel.HyprlandToplevel)
            return null;
        const address = `0x${toplevel.HyprlandToplevel?.address}`;
        return root.windowByAddress[address];
    }

    function biggestWindowForWorkspace(workspaceId: int): var {
        const windowsInThisWorkspace = root.windowList.filter(w => w.workspace.id == workspaceId);
        return windowsInThisWorkspace.reduce((maxWin, win) => {
            const maxArea = (maxWin?.size?.[0] ?? 0) * (maxWin?.size?.[1] ?? 0);
            const winArea = (win?.size?.[0] ?? 0) * (win?.size?.[1] ?? 0);
            return winArea > maxArea ? win : maxWin;
        }, null);
    }

    function updateWindowList(): void {
        getClients.running = true;
    }

    function updateMonitors(): void {
        getMonitors.running = true;
    }

    function updateWorkspaces(): void {
        getWorkspaces.running = true;
        getActiveWorkspace.running = true;
    }

    function updateAll(): void {
        updateWindowList();
        updateMonitors();
        updateWorkspaces();
    }

    Component.onCompleted: updateAll()

    Connections {
        function onRawEvent(event: HyprlandEvent): void {
            if (["openlayer", "closelayer", "screencast"].includes(event.name))
                return;
            root.updateAll();
        }

        target: Hyprland
    }

    Process {
        id: getClients

        command: ["hyprctl", "clients", "-j"]

        stdout: StdioCollector {
            id: clientsCollector

            onStreamFinished: {
                root.windowList = JSON.parse(clientsCollector.text);
                const tempWinByAddress = {};
                for (let i = 0; i < root.windowList.length; ++i) {
                    const win = root.windowList[i];
                    tempWinByAddress[win.address] = win;
                }
                root.windowByAddress = tempWinByAddress;
                root.addresses = root.windowList.map(win => win.address);
            }
        }
    }

    Process {
        id: getMonitors

        command: ["hyprctl", "monitors", "-j"]

        stdout: StdioCollector {
            id: monitorsCollector

            onStreamFinished: {
                root.monitors = JSON.parse(monitorsCollector.text);
            }
        }
    }

    Process {
        id: getWorkspaces

        command: ["hyprctl", "workspaces", "-j"]

        stdout: StdioCollector {
            id: workspacesCollector

            onStreamFinished: {
                const rawWorkspaces = JSON.parse(workspacesCollector.text);
                root.workspaces = rawWorkspaces.filter(ws => ws.id >= 1 && ws.id <= 100);
                const tempWorkspaceById = {};
                for (let i = 0; i < root.workspaces.length; ++i) {
                    const ws = root.workspaces[i];
                    tempWorkspaceById[ws.id] = ws;
                }
                root.workspaceById = tempWorkspaceById;
                root.workspaceIds = root.workspaces.map(ws => ws.id);
            }
        }
    }

    Process {
        id: getActiveWorkspace

        command: ["hyprctl", "activeworkspace", "-j"]

        stdout: StdioCollector {
            id: activeWorkspaceCollector

            onStreamFinished: {
                root.activeWorkspace = JSON.parse(activeWorkspaceCollector.text);
            }
        }
    }
}
