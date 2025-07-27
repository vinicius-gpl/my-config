import Quickshell.Io
import QtQuick

Item {
    id: colorWal

    property string background: "black"
    property string foreground: "gray"
    property string cursor: "black"

    property string color0: "#120808"
    property string color1: "#5b4033"
    property string color2: "#632c1c"
    property string color3: "#65472a"
    property string color4: "#6d5339"
    property string color5: "#6d5342"
    property string color6: "#7d6851"
    property string color7: "#968c8c"
    property string color8: "#6a5757"
    property string color9: "#7A5645"
    property string color10: "#843B26"
    property string color11: "#875F39"
    property string color12: "#926F58"
    property string color13: "#A78B6C"
    property string color14: "#c3c1c1"
    property string color15: "#c3c1c1"

    Process {
        id: walColorsProcess
        command: ["bash", "-c", "cat $HOME/.cache/wal/colors.json"]

        stdout: StdioCollector {
            id: stdout

            onStreamFinished: {
                try {
                    let colors = JSON.parse(stdout.text);

                    colorWal.background = colors.special.background || colorWal.background;
                    colorWal.foreground = colors.special.foreground || colorWal.foreground;
                    colorWal.cursor = colors.special.cursor || colorWal.cursor;

                    colorWal.color0 = colors.colors.color0 || colorWal.color0;
                    colorWal.color1 = colors.colors.color1 || colorWal.color1;
                    colorWal.color2 = colors.colors.color2 || colorWal.color2;
                    colorWal.color3 = colors.colors.color3 || colorWal.color3;
                    colorWal.color4 = colors.colors.color4 || colorWal.color4;
                    colorWal.color5 = colors.colors.color5 || colorWal.color5;
                    colorWal.color6 = colors.colors.color6 || colorWal.color6;
                    colorWal.color7 = colors.colors.color7 || colorWal.color7;
                    colorWal.color8 = colors.colors.color8 || colorWal.color8;
                    colorWal.color9 = colors.colors.color9 || colorWal.color9;
                    colorWal.color10 = colors.colors.color10 || colorWal.color10;
                    colorWal.color11 = colors.colors.color11 || colorWal.color11;
                    colorWal.color12 = colors.colors.color12 || colorWal.color12;
                    colorWal.color13 = colors.colors.color13 || colorWal.color13;
                    colorWal.color14 = colors.colors.color14 || colorWal.color14;
                    colorWal.color15 = colors.colors.color15 || colorWal.color15;
                } catch (error) {
                    console.error("Erro ao interpretar colors.json do wal:", error);
                }
            }
        }

        running: true
    }
}
