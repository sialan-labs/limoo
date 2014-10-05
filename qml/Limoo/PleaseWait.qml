import QtQuick 2.0
import SialanTools 1.0

Item {
    anchors.fill: parent

    Indicator {
        anchors.fill: parent
        Component.onCompleted: start()
    }
}
