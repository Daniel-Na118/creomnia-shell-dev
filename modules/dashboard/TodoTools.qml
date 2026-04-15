pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.components
import qs.components.controls
import qs.services
import qs.config
import qs.utils

Item {
    id: root

    implicitWidth: 600
    implicitHeight: mainLayout.implicitHeight + Appearance.padding.large * 2

    RowLayout {
        id: mainLayout
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Appearance.padding.large
        spacing: Appearance.spacing.large

        // Left Side: Todo List
        ColumnLayout {
            Layout.fillWidth: true
            Layout.preferredWidth: 280
            Layout.maximumWidth: 280
            Layout.alignment: Qt.AlignTop
            spacing: Appearance.spacing.normal

            RowLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.small

                StyledText {
                    Layout.fillWidth: true
                    text: qsTr("Todo List")
                    font.pointSize: Appearance.font.size.large
                    font.weight: 700
                    color: Colours.palette.m3primary
                }

                IconButton {
                    icon: "close"
                    visible: TodoService.todos.length > 0
                    implicitWidth: 24
                    implicitHeight: 24
                    onClicked: TodoService.clearAll()
                }
            }

            Repeater {
                model: TodoService.todos

                delegate: RowLayout {
                    id: delegateRoot
                    Layout.fillWidth: true
                    spacing: Appearance.spacing.small

                    StyledRect {
                        id: rect
                        Layout.fillWidth: true
                        implicitHeight: 40
                        color: (itemHover.hovered && modelData.checked) ? Colours.layer(Colours.palette.m3surfaceContainer, 3) : Colours.layer(Colours.palette.m3surfaceContainer, 2)
                        radius: Appearance.rounding.small
                        border.width: 1
                        border.color: Qt.alpha(Colours.palette.m3outline, 0.3)
                        
                        opacity: (itemHover.hovered && modelData.checked) ? 0.6 : 1
                        Behavior on opacity { Anim { duration: Appearance.anim.durations.small }}
                        Behavior on color { CAnim {} }

                        HoverHandler {
                            id: itemHover
                        }

                        StyledText {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.leftMargin: Appearance.padding.normal
                            anchors.rightMargin: Appearance.padding.normal
                            verticalAlignment: Text.AlignVCenter
                            text: modelData["text"] || ""
                            font.strikeout: modelData["checked"] || false
                            color: (modelData["checked"] || false) ? Colours.palette.m3outline : Colours.palette.m3onSurface
                            elide: Text.ElideRight
                        }
                    }

                    IconButton {
                        id: checkboxBtn
                        icon: (itemHover.hovered && (modelData["checked"] || false)) ? "close" : ((modelData["checked"] || false) ? "check_box" : "check_box_outline_blank")
                        toggle: false
                        checked: modelData["checked"] || false
                        implicitWidth: 28
                        implicitHeight: 28
                        onClicked: {
                            const todoId = modelData["id"];
                            if (itemHover.hovered && (modelData["checked"] || false)) {
                                TodoService.removeTodo(todoId);
                            } else {
                                TodoService.toggleTodo(todoId);
                            }
                        }
                    }
                }
            }

            RowLayout {
                spacing: Appearance.spacing.small
                Layout.fillWidth: true
                visible: TodoService.todos.length < 5

                StyledInputField {
                    id: todoInput
                    Layout.fillWidth: true
                    placeholderText: qsTr("Add a new task...")
                    
                    onAccepted: {
                        if (text.trim() !== "") {
                            TodoService.addTodo(text.trim());
                            text = "";
                        }
                    }
                }

                IconButton {
                    icon: "add"
                    implicitWidth: 28
                    implicitHeight: 28
                    onClicked: {
                        if (todoInput.text.trim() !== "") {
                            TodoService.addTodo(todoInput.text.trim());
                            todoInput.text = "";
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true }
        }

        // Right Side: Tools
        ColumnLayout {
            implicitWidth: 250
            Layout.alignment: Qt.AlignTop
            spacing: Appearance.spacing.large

            // Pomodoro Timer
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.small

                StyledText {
                    text: qsTr("Pomodoro Timer")
                    font.pointSize: Appearance.font.size.normal
                    font.weight: 700
                    color: Colours.palette.m3secondary
                }

                StyledRect {
                    Layout.fillWidth: true
                    implicitHeight: 140
                    color: Colours.layer(Colours.palette.m3surfaceContainer, 2)
                    radius: Appearance.rounding.normal

                    HoverHandler {
                        id: timerHover
                    }

                    StyledText {
                        id: timerDisplay
                        anchors.centerIn: parent
                        text: {
                            const mins = Math.floor(PomodoroService.timeLeft / 60).toString().padStart(2, '0');
                            const secs = (PomodoroService.timeLeft % 60).toString().padStart(2, '0');
                            return `${mins}:${secs}`;
                        }
                        font.pointSize: 48
                        font.family: Appearance.font.family.clock
                        font.weight: 600
                        color: Colours.palette.m3primary
                        opacity: timerHover.hovered ? 0.2 : 1

                        Behavior on opacity {
                            Anim { duration: Appearance.anim.durations.small }
                        }
                    }

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: Appearance.spacing.large
                        opacity: timerHover.hovered ? 1 : 0
                        visible: opacity > 0

                        Behavior on opacity {
                            Anim { duration: Appearance.anim.durations.small }
                        }

                        IconButton {
                            icon: PomodoroService.running ? "pause" : "play_arrow"
                            onClicked: PomodoroService.toggle()
                            type: IconButton.Tonal
                        }

                        IconButton {
                            icon: "restart_alt"
                            onClicked: PomodoroService.reset()
                            type: IconButton.Tonal
                        }
                    }
                }
            }


            // Quick Actions
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.small

                StyledText {
                    text: qsTr("Quick Actions")
                    font.pointSize: Appearance.font.size.normal
                    font.weight: 700
                    color: Colours.palette.m3secondary
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 25
                    Layout.bottomMargin: 20
                    spacing: 0

                    Item {
                        Layout.fillWidth: true
                        implicitHeight: darkModeBtn.implicitHeight

                        IconButton {
                            id: darkModeBtn
                            anchors.centerIn: parent
                            icon: "dark_mode"
                            toggle: false
                            checked: !Colours.light
                            type: IconButton.Tonal
                            radius: width / 2
                            onClicked: {
                                if (Colours.scheme !== "") {
                                    Colours.setMode(Colours.light ? "dark" : "light");
                                }
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        implicitHeight: muteBtn.implicitHeight

                        IconButton {
                            id: muteBtn
                            anchors.centerIn: parent
                            icon: checked ? "volume_up" : "volume_off"
                            toggle: false
                            checked: !Audio.muted
                            type: IconButton.Tonal
                            radius: width / 2
                            onClicked: {
                                if (Audio.sink && Audio.sink.audio) {
                                    Audio.sink.audio.muted = !Audio.sink.audio.muted;
                                }
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        implicitHeight: vpnBtn.implicitHeight

                        IconButton {
                            id: vpnBtn
                            anchors.centerIn: parent
                            icon: "vpn_key"
                            toggle: false
                            checked: VPN.connected
                            type: IconButton.Tonal
                            radius: width / 2
                            onClicked: {
                                if (VPN.enabled) {
                                    VPN.toggle();
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

