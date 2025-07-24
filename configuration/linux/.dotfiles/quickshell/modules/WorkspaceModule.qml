import Quickshell.Hyprland
import QtQuick

Rectangle {
    id: workspaceContainer
    width: 20
    height: 20
    radius: width / 2

    property int idNumber: 0
    property bool focused: false
    property bool active: false

    property color focusedColor: "green"
    property color focusedBorderColor: "blue"
    property color activeColor: "red"
    property color inactiveColor: "gray"

    visible: idNumber > 0
    color: focused ? focusedColor : active ? activeColor : inactiveColor

    border.width: focused ? 0 : 2
    border.color: focused ? "transparent" : focusedBorderColor

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            Hyprland.dispatch("workspace " + workspaceContainer.idNumber);
        }
    }
}
