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
import org.sialan.limoo 1.0
import SialanTools 1.0

Item {
    id: details
    anchors.fill: parent

    property string source

    MouseArea {
        anchors.fill: parent
        onClicked: hideSubMessage()
    }

    Column {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10*physicalPlatformScale
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10*physicalPlatformScale

        Image {
            id: preview
            anchors.horizontalCenter: parent.horizontalCenter
            width: 256*physicalPlatformScale
            height: width*3/4
            sourceSize: Qt.size(width,height)
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            source: path_handler.output

            PathHandler {
                id: path_handler
                input: details.source
            }
        }

        Text {
            id: name_txt
            anchors.horizontalCenter: parent.horizontalCenter
            text: Limoo.fileName(details.source)
            color: "#000000"
            wrapMode: Text.WrapAnywhere
            font.pixelSize: 19*physicalPlatformScale
            font.bold: true
        }

        Text {
            id: dimension_txt
            anchors.horizontalCenter: parent.horizontalCenter
            text: img_size.width + "x" + img_size.height
            color: "#000000"
            font.pixelSize: 11*physicalPlatformScale

            property size img_size: Limoo.imageSize(details.source)
        }

        Text {
            id: size_txt
            anchors.horizontalCenter: parent.horizontalCenter
            text: Math.floor(Limoo.fileSize(details.source)/(1024)) + "KB"
            color: "#000000"
            font.pixelSize: 11*physicalPlatformScale
        }
    }

    function hide() {
    }
}
