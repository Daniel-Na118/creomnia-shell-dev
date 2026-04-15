pragma Singleton

import QtQuick
import Quickshell
import Creomnia
import qs.config

Singleton {
    id: root

    property int timeLeft: Config.dashboard.pomodoroTime * 60
    property bool running: false

    function toggle(): void {
        running = !running;
    }

    function reset(): void {
        running = false;
        timeLeft = Config.dashboard.pomodoroTime * 60;
    }

    Connections {
        target: Config.dashboard
        function onPomodoroTimeChanged(): {
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
