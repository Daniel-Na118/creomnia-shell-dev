pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Creomnia.Models
import qs.services
import qs.config
import qs.utils

Searcher {
    id: root

    readonly property string currentNamePath: `${Paths.state}/wallpaper/path.txt`
    readonly property string perMonitorPath: `${Paths.state}/wallpaper/per-monitor.json`
    readonly property list<string> smartArg: Config.services.smartScheme ? [] : ["--no-smart"]
    readonly property string primaryMonitorName: Hypr.monitors.values[0]?.name ?? ""

    property bool showPreview: false
    readonly property string current: showPreview ? previewPath : actualCurrent
    property string previewPath
    property string actualCurrent
    property bool previewColourLock
    property var perMonitor: ({})

    function setWallpaper(path: string, monitorName: string): void {
        if (!monitorName || monitorName === root.primaryMonitorName) {
            if (root.perMonitor[monitorName] !== undefined) {
                const next = Object.assign({}, root.perMonitor);
                delete next[monitorName];
                root.perMonitor = next;
                root._savePerMonitor();
            }
            actualCurrent = path;
            Quickshell.execDetached(["creomnia", "wallpaper", "-f", path, ...smartArg]);
        } else {
            const next = Object.assign({}, root.perMonitor);
            next[monitorName] = path;
            root.perMonitor = next;
            root._savePerMonitor();
        }
    }

    function clearWallpaper(monitorName: string): void {
        if (!monitorName || root.perMonitor[monitorName] === undefined)
            return;
        const next = Object.assign({}, root.perMonitor);
        delete next[monitorName];
        root.perMonitor = next;
        root._savePerMonitor();
    }

    function currentFor(monitorName: string): string {
        if (root.showPreview)
            return root.previewPath;
        if (monitorName && root.perMonitor[monitorName])
            return root.perMonitor[monitorName];
        return root.actualCurrent;
    }

    function _savePerMonitor(): void {
        Quickshell.execDetached(["mkdir", "-p", `${Paths.state}/wallpaper`]);
        perMonitorFile.setText(JSON.stringify(root.perMonitor, null, 2));
    }

    function preview(path: string): void {
        previewPath = path;
        showPreview = true;

        if (Colours.scheme === "dynamic")
            getPreviewColoursProc.running = true;
    }

    function stopPreview(): void {
        showPreview = false;
        if (!previewColourLock)
            Colours.showPreview = false;
    }

    list: wallpapers.entries
    key: "relativePath"
    useFuzzy: Config.launcher.useFuzzy.wallpapers
    extraOpts: useFuzzy ? ({}) : ({
            forward: false
        })

    IpcHandler {
        function get(monitor: string): string {
            return monitor ? root.currentFor(monitor) : root.actualCurrent;
        }

        function set(path: string, monitor: string): void {
            root.setWallpaper(path, monitor);
        }

        function clear(monitor: string): void {
            root.clearWallpaper(monitor);
        }

        function list(): string {
            return root.list.map(w => w.path).join("\n");
        }

        target: "wallpaper"
    }

    FileView {
        path: root.currentNamePath
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            root.actualCurrent = text().trim();
            root.previewColourLock = false;
        }
    }

    FileView {
        id: perMonitorFile

        path: root.perMonitorPath
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                const parsed = JSON.parse(text());
                root.perMonitor = (parsed && typeof parsed === "object") ? parsed : ({});
            } catch (e) {
                root.perMonitor = ({});
            }
        }
        onLoadFailed: err => {
            if (err === FileViewError.FileNotFound)
                root.perMonitor = ({});
        }
    }

    FileSystemModel {
        id: wallpapers

        recursive: true
        path: Paths.wallsdir
        filter: FileSystemModel.Images
    }

    Process {
        id: getPreviewColoursProc

        command: ["creomnia", "wallpaper", "-p", root.previewPath, ...root.smartArg]
        stdout: StdioCollector {
            onStreamFinished: {
                Colours.load(text, true);
                Colours.showPreview = true;
            }
        }
    }
}
