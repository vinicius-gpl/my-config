import Quickshell.Io
import QtQuick

Item {
    id: dateContainer
    width: 50
    height: 30

    property color textColor: "white"

    function updateTime() {
        dateRunner.running = true;
    }

    Text {
        id: clock
        text: "..."
        font.pixelSize: 20
        anchors.centerIn: parent
        color: dateContainer.textColor

        Timer {
            id: updateTimer
            interval: 1000
            running: true
            repeat: true
            onTriggered: dateContainer.updateTime()
        }

        Process {
            id: dateRunner
            command: ["date", "+%H:%M:%S"]
            stdout: StdioCollector {
                onStreamFinished: clock.text = this.text.trim()
            }
        }
    }
}
