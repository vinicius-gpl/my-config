pragma ComponentBehavior: Bound

import Quickshell.Hyprland
import QtQuick.Layouts
import Quickshell.Io
import Quickshell
import QtQuick

import "../modules" as Modules
import "../theme" as Theme

Variants {
    id: root
    model: Quickshell.screens

    delegate: PanelWindow {
        id: waybar
        implicitHeight: 30
        HyprlandWindow.opacity: 0.8

        property var modelData: modelData
        visible: modelData.name === "DP-2"

        anchors {
            top: true
            left: true
            right: true
        }

        Theme.WalManager {
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

                textColor: colorLoader.foreground
                icon: "\udb80\udcaf"
                command: ["blueman-manager"]
            }

            Modules.CommandModule {
                id: nmtui
                Layout.alignment: Qt.AlignVCenter

                textColor: colorLoader.foreground
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
                    required property HyprlandWorkspace modelData

                    Layout.alignment: Qt.AlignVCenter

                    idNumber: modelData.id
                    focused: modelData.focused
                    active: modelData.active

                    focusedColor: colorLoader.color15
                    focusedBorderColor: colorLoader.color3
                    activeColor: colorLoader.color15
                    inactiveColor: colorLoader.color1
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
                textColor: colorLoader.foreground
                icon: "\ue690"
                command: ["swaync-client", "-t", "-sw"]
            }

            Modules.DateModule {
                id: date
                textColor: colorLoader.foreground
            }

            RowLayout {
                id: update
                spacing: 1

                property string updatePackages: "0"

                Modules.CommandModule {
                    textColor: colorLoader.foreground
                    icon: "\uf487"
                    command: ["kitty", "--title", "update", "sh", "-c", "yay -Syu; echo Done - Press enter to exit; read"]
                }

                Text {
                    text: update.updatePackages === "0" ? "" : update.updatePackages
                    color: colorLoader.foreground
                    font.pixelSize: 20
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
                    interval: 2 * 60 * 1000
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
