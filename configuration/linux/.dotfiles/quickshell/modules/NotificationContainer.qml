import QtQuick
import Quickshell
import QtQuick.Layouts

import "../themes" as Themes

Rectangle {
    id: notificationContainer
    width: parent ? parent.width : 400
    implicitHeight: 130
    anchors.margins: 10
    color: backgroundContainer
    radius: 5

    property color backgroundContainer: "#333333"
    property color textColor: "white"
    property color buttonColor: "white"

    property alias summary: summary.text
    property alias body: body.text
    property alias icon: icon.source
    property string appDesktopEntry: ""
    property int itemIndex: 0

    property string desktopIconSource: ""

    Themes.FontFamily {
        id: fontFamily
    }

    Component.onCompleted: {
        Qt.callLater(() => {
            if (appDesktopEntry && appDesktopEntry !== "") {
                var entry = DesktopEntries.heuristicLookup(appDesktopEntry);
                if (entry && entry.icon !== "") {
                    desktopIconSource = entry.icon;
                    console.log("Resolved icon:", desktopIconSource);
                } else {
                    console.log("No icon in desktop entry, using appIcon:", icon);
                }
            } else {
                console.log("No desktopEntry, using appIcon:", icon);
            }
        });
    }

    RowLayout {
        id: contentLayout
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        Image {
            id: icon
            Layout.preferredWidth: 130
            Layout.fillHeight: true
            fillMode: Image.PreserveAspectFit
            source: notificationContainer.desktopIconSource !== "" ? notificationContainer.desktopIconSource : notificationContainer.icon
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
                        color: "black"
                        font.pixelSize: 15
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
                    font.pixelSize: 12
                    anchors.fill: parent
                    verticalAlignment: Text.AlignTop
                }
            }
        }
    }

    signal dismissClicked(int index)
}
