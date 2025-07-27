import QtQuick
import QtQuick.Controls
import NotificationListener

ApplicationWindow {
    id: root
    visible: true
    width: 400
    height: 600

    ListView {
        id: notificationList
        anchors {
            top: parent.top
            right: parent.right
            margins: 10
        }
        width: 300
        height: parent.height
        spacing: 10
        model: ListModel {
            id: notificationModel
        }

        delegate: Rectangle {
            width: notificationList.width
            height: 100
            color: "#333333"
            radius: 5
            border.color: "#555555"

            Column {
                anchors {
                    fill: parent
                    margins: 10
                }
                spacing: 5

                Text {
                    text: appName
                    color: "white"
                    font.bold: true
                }
                Text {
                    text: summary
                    color: "white"
                    wrapMode: Text.Wrap
                    width: parent.width
                }
            }

            Timer {
                id: closeTimer
                interval: 5000
                running: true
                onTriggered: {
                    NotificationListener.CloseNotification(model.id);
                    notificationModel.remove(index);
                }
            }
        }
    }

    Connections {
        target: NotificationListener
        function onNotificationReceived(appName, icon, summary) {
            notificationModel.append({
                id: NotificationListener.nextId - 1,
                appName: appName,
                summary: summary
            });
        }
        function onNotificationClosed(id, reason) {
            for (var counter = 0; counter < notificationModel.count; counter++) {
                if (notificationModel.get(counter).id === id) {
                    notificationModel.remove(counter);
                    break;
                }
            }
        }
    }

    Component.onCompleted: {
        let info = NotificationListener.GetServerInformation();
        console.log("Server Info:", info[0], info[1], info[2], info[3]);
    }
}
