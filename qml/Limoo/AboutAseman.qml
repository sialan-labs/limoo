/*
    Copyright (C) 2014 Aseman
    http://aseman.co

    Sigram is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Sigram is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0
import AsemanTools 1.0
import "aseman-bubbles"

Item {
    id: auth
    width: 100
    height: 62

    property bool start: false

    onStartChanged: {
        if( start )
            sbbls.start()
        else
            sbbls.end()
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton | Qt.LeftButton
        hoverEnabled: true
        onWheel: wheel.accepted = true
    }

    Rectangle {
        anchors.fill: parent
        color: "#ffffff"
    }

    AsemanBubbles {
        id: sbbls
        anchors.fill: parent
        opacity: 0.8
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

    Column {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 80*physicalPlatformScale
        anchors.rightMargin: 80*physicalPlatformScale
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10*physicalPlatformScale

        Image {
            id: aseman_img
            anchors.horizontalCenter: parent.horizontalCenter
            width: 128*physicalPlatformScale
            height: width
            sourceSize: Qt.size(width,height)
            source: "files/aseman.png"
            fillMode: Image.PreserveAspectFit
            smooth: true
        }

        Text {
            id: slogo_txt
            anchors.horizontalCenter: parent.horizontalCenter
            text: "ASEMAN"
            font.weight: Font.Bold
            font.family: SApp.globalFontFamily
            font.pixelSize: 30*fontsScale
            color: "#333333"
        }

        Text {
            id: about_text
            anchors.left: parent.left
            anchors.right: parent.right
            wrapMode: Text.WordWrap
            font.family: SApp.globalFontFamily
            font.pixelSize: 11*fontsScale
            color: "#333333"
        }
    }

    Text {
        id: twitter
        anchors.right: parent.right
        anchors.bottom: website.top
        anchors.margins: 8*physicalPlatformScale
        font.family: SApp.globalFontFamily
        font.pixelSize: 10*fontsScale
        color: "#333333"

        MouseArea {
            anchors.fill: parent
            anchors.margins: -8*physicalPlatformScale
            cursorShape: Qt.PointingHandCursor
            onClicked: Qt.openUrlExternally("https://twitter.com/AsemanLabs")
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

        MouseArea {
            anchors.fill: parent
            anchors.margins: -8
            cursorShape: Qt.PointingHandCursor
            onClicked: Qt.openUrlExternally("http://aseman.co")
        }
    }

    LanguageSwitcher {
        onRefresh: {
            back_btn.text = qsTr("Back")
            website.text = qsTr("Aseman website")
            twitter.text = qsTr("Aseman twitter")
            about_text.text = Limoo.aboutAseman()
        }
    }
}
