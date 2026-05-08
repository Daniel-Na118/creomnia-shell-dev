pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Wayland
import Creomnia.Config
import qs.config as QsConfig

Singleton {
    id: root

    function isPinned(appId: string): bool {
        return Config.dock.pinnedApps.indexOf(appId) !== -1;
    }

    function togglePin(appId: string): void {
        if (root.isPinned(appId))
            Config.dock.pinnedApps = Config.dock.pinnedApps.filter(id => id !== appId);
        else
            Config.dock.pinnedApps = Config.dock.pinnedApps.concat([appId]);
        QsConfig.Config.save();
    }

    property list<var> apps: {
        const map = new Map();

        const pinnedApps = Config.dock.pinnedApps ?? [];
        for (const appId of pinnedApps) {
            const key = appId.toLowerCase();
            if (!map.has(key))
                map.set(key, {
                    pinned: true,
                    toplevels: []
                });
        }

        const ignoredRegexes = (Config.dock.ignoredAppRegexes ?? []).map(p => new RegExp(p, "i"));

        for (const toplevel of ToplevelManager.toplevels.values) {
            const appId = toplevel.appId ?? "";
            if (!appId || ignoredRegexes.some(re => re.test(appId)))
                continue;
            const key = appId.toLowerCase();
            if (!map.has(key))
                map.set(key, {
                    pinned: false,
                    toplevels: []
                });
            map.get(key).toplevels.push(toplevel);
        }

        const values = [];
        for (const [key, value] of map)
            values.push(appEntryComp.createObject(root, {
                appId: key,
                toplevels: value.toplevels,
                pinned: value.pinned
            }));
        return values;
    }

    component TaskbarAppEntry: QtObject {
        required property string appId
        required property list<var> toplevels
        required property bool pinned
    }

    Component {
        id: appEntryComp

        TaskbarAppEntry {}
    }
}
