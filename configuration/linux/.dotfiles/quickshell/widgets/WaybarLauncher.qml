import Quickshell.Hyprland
import QtQuick.Layouts
import Quickshell.Io
import Quickshell
import QtQuick

import "../modules" as Modules
import "../colors" as Colors

Variants {
    id: root
    model: Quickshell.screens

    delegate: PanelWindow {
        id: waybar
        implicitHeight: 30
        HyprlandWindow.opacity: 0.6

        property var modelData: modelData
        visible: modelData.name === "DP-2"

        anchors {
            top: true
            left: true
            right: true
        }

        Colors.ColorLoader {
            id: colorLoader
        }

        Rectangle {
            id: panelBackground
            anchors.fill: parent
            color: colorLoader.background
        }

        RowLayout {
            id: rowRight
            spacing: 15
            anchors.margins: 20
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            Modules.CommandModule {
                id: bluetooth
                Layout.alignment: Qt.AlignVCenter
                textColor: colorLoader.textColor
                icon: "\udb80\udcaf"
                command: ["blueman-manager"]
            }

            Modules.CommandModule {
                id: nmtui
                Layout.alignment: Qt.AlignVCenter
                textColor: colorLoader.textColor
                icon: "\uF1EB"
                command: ["kitty", "--title", "nmtui", "nmtui"]
            }
        }

        RowLayout {
            id: rowWorkspace
            spacing: 10
            anchors.centerIn: parent
            anchors.verticalCenter: parent.verticalCenter

            Repeater {
                model: Hyprland.workspaces

                delegate: Modules.WorkspaceModule {
                    Layout.alignment: Qt.AlignVCenter

                    idNumber: modelData.id
                    focused: modelData.focused
                    active: modelData.active

                    focusedColor: colorLoader.focusedColor
                    activeColor: colorLoader.activeColor
                    inactiveColor: colorLoader.inactiveColor
                }
            }

            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: Hyprland.refreshWorkspaces()
            }

            Connections {
                target: Hyprland
                function onRawEvent(event) {
                    if (event.name === "workspace") {
                        console.log("Workspace changed:", event.data);
                        Hyprland.refreshWorkspaces();
                    }
                }
            }
        }

        RowLayout {
            id: rowLeft
            spacing: 20
            anchors.margins: 20
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            Modules.CommandModule {
                id: swaync
                Layout.alignment: Qt.AlignVCenter
                textColor: colorLoader.textColor
                icon: "\ue690"
                command: ["swaync-client", "-t", "-sw"]
            }

            Modules.DateModule {
                id: date
                Layout.alignment: Qt.AlignVCenter
                textColor: colorLoader.textColor
            }

            RowLayout {
                id: update
                spacing: 1

                property string updatePackages: "0"

                Modules.CommandModule {
                    textColor: colorLoader.textColor
                    icon: "\udb80\udfd4"
                    command: ["kitty", "--title", "update", "sh", "-c", "yay -Syu; echo Done - Press enter to exit; read"]
                }

                Text {
                    text: update.updatePackages === "0" ? "0" : update.updatePackages
                    color: colorLoader.textColor
                    font.pixelSize: 18
                }

                Process {
                    id: checkupdate
                    command: ["bash", "-c", "checkupdates | wc -l"]

                    stdout: StdioCollector {
                        id: stdout
                        onStreamFinished: {
                            try {
                                update.updatePackages = stdout.text.trim();
                            } catch (error) {
                                console.error(error);
                            }
                        }
                    }

                    running: true
                }

                Timer {
                    interval: 5 * 60 * 1000
                    running: true
                    repeat: true
                    onTriggered: {
                        checkupdate.running = false;
                        checkupdate.running = true;
                    }
                }
            }
        }
    }
}
