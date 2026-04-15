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
                    onClicked: TodoService.clearAll()
                }
            }

            ListView {
                id: todoList
                Layout.fillWidth: true
                Layout.preferredHeight: contentHeight
                model: TodoService.todos
                spacing: Appearance.spacing.smaller
                clip: true
                interactive: false

                delegate: StyledRect {
                    width: todoList.width
                    implicitHeight: todoRow.implicitHeight + Appearance.padding.small * 2
                    color: Colours.layer(Colours.palette.m3surfaceContainer, 1)
                    radius: Appearance.rounding.small

                    RowLayout {
                        id: todoRow
                        anchors.fill: parent
                        anchors.margins: Appearance.padding.small
                        spacing: Appearance.spacing.small

                        IconButton {
                            icon: modelData.checked ? "check_box" : "check_box_outline_blank"
                            color: modelData.checked ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
                            onClicked: TodoService.toggleTodo(modelData.id)
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: modelData.text
                            font.strikeout: modelData.checked
                            color: modelData.checked ? Colours.palette.m3outline : Colours.palette.m3onSurface
                            elide: Text.ElideRight
                        }

                        IconButton {
                            icon: "delete"
                            color: Colours.palette.m3error
                            onClicked: TodoService.removeTodo(modelData.id)
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
                    onClicked: {
                        if (todoInput.text.trim() !== "") {
                            TodoService.addTodo(todoInput.text.trim());
                            todoInput.text = "";
                        }
                    }
                }
            }
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
                        opacity: mouseArea.containsMouse ? 0.2 : 1

                        Behavior on opacity {
                            Anim { duration: Appearance.anim.durations.small }
                        }
                    }

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: Appearance.spacing.large
                        opacity: mouseArea.containsMouse ? 1 : 0
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

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
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
                    spacing: Appearance.spacing.small

                    IconButton {
                        Layout.fillWidth: true
                        icon: "dark_mode"
                        toggle: true
                        checked: !Colours.light
                        onClicked: Colours.setMode(checked ? "dark" : "light")
                    }

                    IconButton {
                        Layout.fillWidth: true
                        icon: "volume_up"
                        toggle: true
                        checked: !Audio.muted
                        onClicked: {
                            if (Audio.sink && Audio.sink.audio) {
                                Audio.sink.audio.muted = !checked;
                            }
                        }
                    }

                    IconButton {
                        Layout.fillWidth: true
                        icon: "vpn_key"
                        toggle: true
                        checked: VPN.connected
                        onClicked: VPN.toggle()
                    }
                }

                SpinBoxRow {
                    Layout.fillWidth: true
                    label: qsTr("Pomodoro Time (min)")
                    value: Config.dashboard.pomodoroTime
                    min: 1
                    max: 60
                    onValueModified: value => {
                        Config.dashboard.pomodoroTime = value;
                        Config.save();
                    }
                }
            }
        }
    }
}

