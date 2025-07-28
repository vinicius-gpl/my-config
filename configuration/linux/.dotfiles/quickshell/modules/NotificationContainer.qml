import QtQuick
import QtQuick.Layouts

import "../themes" as Themes

Rectangle {
    id: notificationContainer
    width: parent ? parent.width : 400
    implicitHeight: 130
    anchors.margins: 10
    color: backgroundContainer
    radius: 5

    Themes.FontFamily {
        id: fontFamily
    }

    property color backgroundContainer: "#333333"
    property color textColor: "white"
    property color buttonColor: "white"

    property alias summary: summary.text
    property alias body: body.text
    property alias icon: icon.source
    property int itemIndex: 0

    RowLayout {
        id: contentLayout
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        Image {
            id: icon
            source: notificationContainer.icon
            Layout.preferredWidth: 60
            Layout.fillHeight: true
            fillMode: Image.PreserveAspectFit
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 5

            RowLayout {
                Layout.fillWidth: true

                Text {
                    id: summary
                    color: notificationContainer.textColor
                    text: "No Title"
                    font.bold: true
                    elide: Text.ElideRight
                    font.family: fontFamily.defaultFont.family
                    font.pixelSize: 15
                    Layout.fillWidth: true
                }

                Rectangle {
                    id: pseudoButton
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                    radius: 5
                    color: notificationContainer.buttonColor
                    Layout.alignment: Qt.AlignRight | Qt.AlignTop

                    Text {
                        anchors.centerIn: parent
                        text: "\uf467"
                        color: notificationContainer.textColor
                        font.pixelSize: 18
                        font.family: fontFamily.defaultFont.family
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: notificationContainer.dismissClicked(notificationContainer.itemIndex)
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: notificationContainer.backgroundContainer
                clip: true

                Text {
                    id: body
                    text: "No body"
                    color: notificationContainer.textColor
                    wrapMode: Text.WrapAnywhere
                    font.pixelSize: 14
                    anchors.fill: parent
                    verticalAlignment: Text.AlignTop
                }
            }
        }
    }

    signal dismissClicked(int index)
}
