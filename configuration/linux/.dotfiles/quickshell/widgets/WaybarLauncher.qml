pragma ComponentBehavior: Bound

import Quickshell.Hyprland
import QtQuick.Layouts
import Quickshell.Io
import Quickshell
import QtQuick

import "../modules" as Modules
import "../themes" as Themes

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

        Themes.WalManager {
            id: colorManager
        }

        Themes.FontFamily {
            id: fontFamily
        }

        Rectangle {
            id: panelBackground
            anchors.fill: parent
            color: colorManager.background
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

                textColor: colorManager.foreground
                icon: "\udb80\udcaf"
                command: ["blueman-manager"]
            }

            Modules.CommandModule {
                id: nmtui
                Layout.alignment: Qt.AlignVCenter

                textColor: colorManager.foreground
                icon: "\uF1EB"
                command: ["kitty", "--title", "nmtui", "nmtui"]
            }
        }

        Rectangle {
            id: rowWorkspace
            radius: 5
            border.width: 2
            color: colorManager.color2
            border.color: colorManager.color6
            anchors.centerIn: parent
            width: workspaceRow.implicitWidth + 16
            height: workspaceRow.implicitHeight + 8

            Row {
                id: workspaceRow
                spacing: 10
                anchors.centerIn: parent

                Repeater {
                    model: Hyprland.workspaces

                    delegate: Modules.WorkspaceModule {
                        anchors.verticalCenter: parent.verticalCenter

                        required property HyprlandWorkspace modelData

                        idNumber: modelData.id
                        focused: modelData.focused
                        active: modelData.active

                        focusedColor: colorManager.color15
                        activeColor: colorManager.color15
                        inactiveColor: colorManager.color14
                    }
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
            spacing: 25
            anchors.margins: 20
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            Modules.CommandModule {
                id: swaync
                textColor: colorManager.foreground
                icon: "\ue690"
                command: ["swaync-client", "-t", "-sw"]
            }

            Modules.DateModule {
                id: date
                textColor: colorManager.foreground
            }

            RowLayout {
                id: update
                spacing: 1

                property string updatePackages: "0"

                Modules.CommandModule {
                    textColor: colorManager.foreground
                    icon: "\udb80\udfd4"
                    command: ["kitty", "--title", "update", "sh", "-c", "yay -Syu; echo Done - Press enter to exit; read"]
                }

                Text {
                    text: update.updatePackages === "0" ? "" : update.updatePackages
                    color: colorManager.foreground
                    font.pixelSize: 20
                    font.family: fontFamily.defaultFont.family
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
