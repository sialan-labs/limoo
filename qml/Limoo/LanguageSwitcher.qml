import QtQuick 2.0
import AsemanTools 1.0

Connections {
    target: Limoo
    signal refresh()

    onCurrentLanguageChanged: refresh()
    Component.onCompleted: refresh()
}
