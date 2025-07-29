import Quickshell.Hyprland
import QtQuick

Item {
    id: workspaceContainer
    implicitWidth: workspaceItem.visible ? workspaceItem.width : 0
    implicitHeight: workspaceItem.visible ? workspaceItem.height : 0

    property int idNumber: 0
    property bool focused: false
    property bool active: false

    property color focusedColor: "green"
    property color activeColor: "red"
    property color inactiveColor: "gray"

    Rectangle {
        id: workspaceItem
        radius: width / 2
        anchors.centerIn: parent
        width: workspaceContainer.focused ? 20 : workspaceContainer.active ? 20 : 16
        height: workspaceContainer.focused ? 20 : workspaceContainer.active ? 20 : 16
        visible: workspaceContainer.idNumber > 0
        color: workspaceContainer.focused ? workspaceContainer.focusedColor : workspaceContainer.active ? workspaceContainer.activeColor : workspaceContainer.inactiveColor

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                Hyprland.dispatch("workspace " + workspaceContainer.idNumber);
            }
        }
    }
}
