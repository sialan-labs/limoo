import QtQuick 2.0
import SialanTools 1.0

Connections {
    target: Limoo
    signal refresh()

    onCurrentLanguageChanged: refresh()
    Component.onCompleted: refresh()
}
