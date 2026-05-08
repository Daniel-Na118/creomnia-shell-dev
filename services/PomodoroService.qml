pragma Singleton

import QtQuick
import Quickshell
import Creomnia
import Creomnia.Config

Singleton {
    id: root

    property int timeLeft: GlobalConfig.dashboard.pomodoroTime * 60
    property bool running: false

    function toggle(): void {
        running = !running;
    }

    function reset(): void {
        running = false;
        timeLeft = GlobalConfig.dashboard.pomodoroTime * 60;
    }

    Connections {
        target: GlobalConfig.dashboard
        function onPomodoroTimeChanged() {
            if (!root.running) {
                root.reset();
            }
        }
    }

    Timer {
        id: timer
        interval: 1000
        repeat: true
        running: root.running

        onTriggered: {
            if (root.timeLeft > 0) {
                root.timeLeft--;
            } else {
                root.running = false;
                Toaster.toast(qsTr("Pomodoro Finished"), qsTr("Time to take a break!"), "timer");
            }
        }
    }
}
