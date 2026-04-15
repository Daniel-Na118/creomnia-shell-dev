pragma ComponentBehavior: Bound

import ".."
import QtQuick
import qs.components
import qs.services
import qs.config

Item {
    id: root

    property string text: ""
    property alias placeholderText: inputField.placeholderText
    property var validator: null
    property bool readOnly: false
    property int horizontalAlignment: TextInput.AlignHCenter

    // Expose activeFocus through alias to avoid FINAL property override
    readonly property alias hasFocus: inputField.activeFocus

    signal textEdited(string text)

    signal editingFinished
    signal accepted()

    implicitWidth: 70
    implicitHeight: inputField.implicitHeight + Appearance.padding.small * 2

    onTextChanged: {
        if (inputField.text !== text) {
            inputField.text = text;
        }
    }

    StyledRect {
        id: container

        anchors.fill: parent
        color: inputHover.containsMouse || inputField.activeFocus ? Colours.layer(Colours.palette.m3surfaceContainer, 3) : Colours.layer(Colours.palette.m3surfaceContainer, 2)
        radius: Appearance.rounding.small
        border.width: 1
        border.color: inputField.activeFocus ? Colours.palette.m3primary : Qt.alpha(Colours.palette.m3outline, 0.3)
        opacity: root.enabled ? 1 : 0.5

        Behavior on color {
            CAnim {}
        }
        Behavior on border.color {
            CAnim {}
        }

        MouseArea {
            id: inputHover

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.IBeamCursor
            enabled: root.enabled

            onClicked: inputField.forceActiveFocus()
        }

        StyledTextField {
            id: inputField

            anchors.centerIn: parent
            width: parent.width - Appearance.padding.normal
            horizontalAlignment: root.horizontalAlignment
            validator: root.validator
            readOnly: root.readOnly
            enabled: root.enabled

            onTextChanged: {
                if (root.text !== text) {
                    root.text = text;
                }
                root.textEdited(text);
            }

            onEditingFinished: {
                root.editingFinished();
            }

            onAccepted: {
                root.accepted();
            }
        }
    }
}
