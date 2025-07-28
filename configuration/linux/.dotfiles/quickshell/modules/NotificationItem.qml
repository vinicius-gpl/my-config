import QtQuick
import QtQuick.Controls

Rectangle {
    id: notificationItem
    width: parent ? parent.width : 400
    height: childrenRect.height
    anchors.margins: 10
    color: "#333333"
    radius: 5

    property alias summary: summary.text
    property alias body: body.text
    property int index: -1

    Column {
        id: contentColumn
        width: parent ? parent.width : 400
        spacing: 10
        padding: 10

        Text {
            id: summary
            color: "white"
            text: "No Title"
            font.bold: true
            wrapMode: Text.Wrap
            width: parent.width
        }

        Text {
            id: body
            text: "No Body"
            color: "white"
            width: parent.width
            wrapMode: Text.Wrap
            textFormat: Text.PlainText
        }

        Button {
            text: "\uf467"
            width: 20
            height: 20
            font.pixelSize: 18

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: parent.clicked()
            }

            onClicked: {
                notificationItem.dismissClicked(notificationItem.index);
            }
        }
    }

    signal dismissClicked(int index)
}
