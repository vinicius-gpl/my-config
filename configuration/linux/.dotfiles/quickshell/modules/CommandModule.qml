import Quickshell.Io
import QtQuick

Item {
    id: icon
    width: 30
    height: 30

    property color textColor: "white"

    required property var icon
    required property var command

    Text {
        id: commandIcon
        text: icon.icon
        font.pixelSize: 20
        color: icon.textColor
        anchors.centerIn: parent
    }

    Process {
        id: commandRunner
        command: icon.command
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: commandRunner.running = true
    }
}
