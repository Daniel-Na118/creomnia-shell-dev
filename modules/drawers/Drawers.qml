pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.services
import Creomnia.Config

Variants {
    model: Screens.screens

    Scope {
        id: scope

        required property ShellScreen modelData

        Exclusions {
            screen: scope.modelData
            bar: content.bar
            dock: content.dock
            borderThickness: Config.border.thickness
        }

        ContentWindow {
            id: content

            screen: scope.modelData
        }
    }
}
