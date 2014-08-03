import QtQuick 2.0

Connections {
    target: Limoo
    signal refresh()

    onCurrentLanguageChanged: refresh()
    Component.onCompleted: refresh()
}
