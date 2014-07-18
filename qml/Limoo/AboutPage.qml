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

Rectangle {
    width: 100
    height: 62
    color: "#f5de32"

    Button {
        anchors.top: parent.top
        anchors.left: parent.left
        height: 46*physicalPlatformScale
        text: qsTr("Back")
        textColor: "#333333"
        highlightColor: "#44ffffff"
        icon: "files/go-previous.png"
        onClicked: main.back()
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
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Limoo")
            font.pointSize: 40*fontsScale
            font.family: globalFontFamily
            font.bold: true
            color: "#ffffff"

            Text {
                id: powered_txt
                anchors.right: parent.right
                anchors.left: parent.left
                anchors.top: parent.bottom
                font.pointSize: 12*fontsScale
                font.family: globalFontFamily
                font.bold: true
                color: "#ffffff"
                horizontalAlignment: Text.AlignRight
                text: qsTr("by Sialan Labs")
            }
        }
    }
}
