/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

    Limoo is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Limoo is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0
import SialanTools 1.0

Rectangle {
    width: 100
    height: 62
    color: "#ececec"

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton | Qt.LeftButton
        hoverEnabled: true
        onWheel: wheel.accepted = true
    }

    Button {
        id: back_btn
        anchors.top: parent.top
        anchors.left: parent.left
        height: 40*physicalPlatformScale
        textColor: "#333333"
        highlightColor: "#44ffffff"
        icon: "files/go-previous.png"
        onClicked: main.back()
    }

    Image {
        anchors.left: parent.horizontalCenter
        anchors.bottom: parent.bottom
        width: 200*physicalPlatformScale
        height: 200*physicalPlatformScale
        sourceSize: Qt.size(width,height)
        source: "files/balloons.png"
    }

    Button {
        id: donate_btn
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 70*physicalPlatformScale
        width: 240*physicalPlatformScale
        fontSize: 10*fontsScale
        height: 42*physicalPlatformScale
        normalColor: "#339DCC"
        highlightColor: "#336BCC"
        onClicked: Qt.openUrlExternally("http://labs.sialan.org/donate")
    }

    Column {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        Image {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 256*physicalPlatformScale
            height: width
            sourceSize: Qt.size(width,height)
            fillMode: Image.PreserveAspectFit
            source: "files/icon.png"
        }

        Text {
            id: limoo_txt
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 40*fontsScale
            font.family: SApp.globalFontFamily
            font.bold: true
            color: "#333333"
        }

        Text {
            id: about_text
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 80*physicalPlatformScale
            anchors.rightMargin: 80*physicalPlatformScale
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            font.family: SApp.globalFontFamily
            font.pixelSize: 12*fontsScale
            color: "#333333"
        }

        Item {
            width: 10
            height: 50*physicalPlatformScale
        }
    }

    Text {
        id: home_btn
        anchors.right: parent.right
        anchors.bottom: website.top
        anchors.margins: 8*physicalPlatformScale
        font.family: SApp.globalFontFamily
        font.pixelSize: 10*fontsScale
        color: "#333333"
        text: qsTr("HomePage")

        MouseArea {
            anchors.fill: parent
            anchors.margins: -8*physicalPlatformScale
            cursorShape: Qt.PointingHandCursor
            onClicked: Qt.openUrlExternally("http://labs.sialan.org/projects/limoo")
        }
    }

    Text {
        id: website
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 8*physicalPlatformScale
        font.family: SApp.globalFontFamily
        font.pixelSize: 10*fontsScale
        color: "#333333"
        text: "Limoo " + Limoo.version()
    }

    LanguageSwitcher {
        onRefresh: {
            back_btn.text = qsTr("Back")
            donate_btn.text = qsTr("Donate us (Sialan Labs)")
            limoo_txt.text = qsTr("Limoo")
            home_btn.text = qsTr("HomePage")
            about_text.text = Limoo.aboutLimoo()
        }
    }
}
