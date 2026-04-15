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
                    id: delegateRoot
                    width: todoList.width
                    implicitHeight: 35 // Match StyledInputField height
                    color: Colours.layer(Colours.palette.m3surfaceContainer, 2)
                    radius: Appearance.rounding.small
                    border.width: 1
                    border.color: Qt.alpha(Colours.palette.m3outline, 0.3)
                    
                    opacity: delegateMouseArea.containsMouse && modelData.checked ? 0.6 : 1
                    Behavior on opacity { Anim { duration: Appearance.anim.durations.small }}

                    MouseArea {
                        id: delegateMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Appearance.padding.normal
                        anchors.rightMargin: Appearance.padding.small
                        spacing: Appearance.spacing.small

                        StyledText {
                            Layout.fillWidth: true
                            Layout.preferredWidth: 0 // Crucial for elide to work in Layouts
                            text: modelData.text
                            font.strikeout: modelData.checked
                            color: modelData.checked ? Colours.palette.m3outline : Colours.palette.m3onSurface
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                        }

                        IconButton {
                            icon: (delegateMouseArea.containsMouse && modelData.checked) ? "close" : (modelData.checked ? "check_box" : "check_box_outline_blank")
                            color: (delegateMouseArea.containsMouse && modelData.checked) ? Colours.palette.m3error : (modelData.checked ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant)
                            type: IconButton.Text
                            onClicked: {
                                if (delegateMouseArea.containsMouse && modelData.checked) {
                                    TodoService.removeTodo(modelData.id);
                                } else {
                                    TodoService.toggleTodo(modelData.id);
                                }
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

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
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
                    spacing: 0

                    Item {
                        Layout.fillWidth: true
                        implicitHeight: darkModeBtn.implicitHeight

                        IconButton {
                            id: darkModeBtn
                            anchors.centerIn: parent
                            icon: "dark_mode"
                            toggle: true
                            checked: !Colours.light
                            type: IconButton.Tonal
                            onClicked: {
                                if (Colours.scheme !== "") {
                                    Colours.setMode(checked ? "dark" : "light");
                                } else {
                                    checked = !checked; 
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
                            icon: Audio.muted ? "volume_off" : "volume_up"
                            toggle: true
                            checked: !Audio.muted
                            type: IconButton.Tonal
                            onClicked: {
                                if (Audio.sink && Audio.sink.audio) {
                                    Audio.sink.audio.muted = !checked;
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
                            toggle: true
                            checked: VPN.connected
                            type: IconButton.Tonal
                            onClicked: {
                                if (VPN.enabled) {
                                    VPN.toggle();
                                } else {
                                    checked = !checked;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

