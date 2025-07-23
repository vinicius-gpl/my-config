import Quickshell.Io
import QtQuick

Item {
    id: colorWal

    property string background: "#000000"
    property string focusedColor: "#1E90FF"
    property string activeColor: "#32CD32"
    property string inactiveColor: "#555555"
    property string textColor: "black"

    Process {
        id: walColorsProcess
        command: ["bash", "-c", "cat $HOME/.cache/wal/colors.json"]

        stdout: StdioCollector {
            id: stdout

            onStreamFinished: {
                try {
                    console.log("🎨 Wal colors:\n" + stdout.text);
                    let colors = JSON.parse(stdout.text);

                    colorWal.background = colors.special.background || colorWal.background;
                    colorWal.focusedColor = colors.colors.color1 || colorWal.focusedColor;
                    colorWal.activeColor = colors.colors.color11 || colorWal.activeColor;
                    colorWal.inactiveColor = colors.colors.color14 || colorWal.inactiveColor;
                    colorWal.textColor = colors.special.foreground || colorWal.textColor;
                } catch (error) {
                    console.error("Erro ao interpretar colors.json do wal:", error);
                }
            }
        }

        running: true
    }
}
