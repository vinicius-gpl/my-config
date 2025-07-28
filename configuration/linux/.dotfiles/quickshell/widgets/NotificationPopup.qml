import QtQuick
import Quickshell
import Quickshell.Services.Notifications

import "../modules" as Modules

Variants {
    id: root
    model: Quickshell.screens

    delegate: PanelWindow {
        id: toplevel
        implicitHeight: 0

        property var modelData: modelData
        visible: modelData.name === "DP-2"

        anchors {
            top: true
            left: true
            right: true
        }

        NotificationServer {
            id: notificationServer
            imageSupported: true
            bodySupported: true
            actionsSupported: true
            keepOnReload: true

            onNotification: notification => {
                notification.tracked = true;
                console.log("Received notification:", notification.summary, notification.body);

                notificationListModel.append({
                    summary: notification.summary,
                    body: notification.body,
                    id: notification.id
                });

                if (notificationListModel.count > 5) {
                    notificationListModel.remove(0);
                }

                popup.removeNotificationAfterTimeout(notification.id);
            }
        }

        PopupWindow {
            id: popup
            color: "transparent"
            visible: notificationListModel.count > 0

            implicitWidth: 400
            implicitHeight: Math.min(notificationListView.contentHeight + 20, Screen.height * 0.8)

            anchor.window: toplevel
            anchor.rect: Qt.rect(0, toplevel.height, 0, 0)

            ListModel {
                id: notificationListModel
            }

            function removeNotificationAfterTimeout(id) {
                var timer = Qt.createQmlObject('import QtQuick 2.0; Timer { interval: 5000; repeat: false; running: true }', popup);
                timer.triggered.connect(function () {
                    for (var counter = 0; counter < notificationListModel.count; ++counter) {
                        if (notificationListModel.get(counter).id === id) {
                            notificationListModel.remove(counter);
                            break;
                        }
                    }
                    timer.destroy();
                });
            }

            ListView {
                id: notificationListView
                anchors.fill: parent
                model: notificationListModel
                spacing: 10
                topMargin: 10
                leftMargin: 10
                rightMargin: 10
                bottomMargin: 10

                delegate: Modules.NotificationItem {
                    summary: model.summary
                    body: model.body
                    index: index

                    onDismissClicked: {
                        notificationListModel.remove(index);
                    }
                }
            }
        }
    }
}
