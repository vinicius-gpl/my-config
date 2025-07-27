import Quickshell
import QtQuick

import "../modules" as Modules

Variants {
    id: root
    model: Quickshell.screens

    delegate: Item {
        Modules.NotificationListener {}
    }
}
