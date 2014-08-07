import QtQuick 2.0

Item {
    id: inc_pass
    anchors.fill: parent

    signal finished()

    MouseArea {
        anchors.fill: parent
        onClicked: hideSubMessage()
    }

    Text {
        id: title_lbl
        anchors.centerIn: parent
        font.pointSize: 20*fontsScale
        font.weight: Font.Normal
        font.family: globalFontFamily
        color: "#333333"
    }

    LanguageSwitcher {
        onRefresh: {
            title_lbl.text = qsTr("Incorrect Password!")
        }
    }

    Timer {
        interval: 1000
        onTriggered: {
            hideSubMessage()
            inc_pass.finished()
        }
        Component.onCompleted: start()
    }
}
