import Quickshell.Io
import QtQuick

import "../themes" as Themes

Item {
    id: icon
    width: 30
    height: 30

    property color textColor: "white"

    required property var icon
    required property var command

    Themes.FontFamily {
        id: fontFamily
    }

    Text {
        id: commandIcon
        text: icon.icon
        font.pixelSize: 20
        color: icon.textColor
        anchors.centerIn: parent
        font.family: fontFamily.defaultFont.family
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
