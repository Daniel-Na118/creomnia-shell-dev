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
    implicitHeight: 400

    RowLayout {
        anchors.fill: parent
        anchors.margins: Appearance.padding.large
        spacing: Appearance.spacing.large

        // Left Side: Todo List
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Appearance.spacing.normal

            StyledText {
                text: qsTr("Todo List")
                font.pointSize: Appearance.font.size.large
                font.weight: 700
                color: Colours.palette.m3primary
            }

            RowLayout {
                spacing: Appearance.spacing.small
                Layout.fillWidth: true

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

            ListView {
                id: todoList
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: TodoService.todos
                spacing: Appearance.spacing.smaller
                clip: true

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
        }

        // Right Side: Tools
        ColumnLayout {
            implicitWidth: 250
            Layout.fillHeight: true
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
                    implicitHeight: 120
                    color: Colours.layer(Colours.palette.m3surfaceContainer, 2)
                    radius: Appearance.rounding.normal

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: Appearance.spacing.small

                        StyledText {
                            id: timerDisplay
                            Layout.alignment: Qt.AlignHCenter
                            text: {
                                const mins = Math.floor(pomodoroTimer.timeLeft / 60).toString().padStart(2, '0');
                                const secs = (pomodoroTimer.timeLeft % 60).toString().padStart(2, '0');
                                return `${mins}:${secs}`;
                            }
                            font.pointSize: Appearance.font.size.huge
                            font.family: Appearance.font.family.clock
                            color: Colours.palette.m3primary
                        }

                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: Appearance.spacing.small

                            IconButton {
                                icon: pomodoroTimer.running ? "pause" : "play_arrow"
                                onClicked: pomodoroTimer.running = !pomodoroTimer.running
                            }

                            IconButton {
                                icon: "restart_alt"
                                onClicked: {
                                    pomodoroTimer.running = false;
                                    pomodoroTimer.timeLeft = 25 * 60;
                                }
                            }
                        }
                    }

                    Timer {
                        id: pomodoroTimer
                        interval: 1000
                        repeat: true
                        running: false
                        property int timeLeft: 25 * 60

                        onTriggered: {
                            if (timeLeft > 0) {
                                timeLeft--;
                            } else {
                                running = false;
                                // Maybe add a notification here
                            }
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
                    spacing: Appearance.spacing.small
                    Layout.fillWidth: true

                    ToggleRow {
                        Layout.fillWidth: true
                        label: qsTr("Dark Mode")
                        checked: !Colours.light
                        toggle.onToggled: Colours.setMode(checked ? "dark" : "light")
                    }
                }
            }

            Item { Layout.fillHeight: true }
        }
    }
}
