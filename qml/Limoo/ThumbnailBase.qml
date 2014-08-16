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

Column {
    id: item_base
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    anchors.margins: viewMode? 4*physicalPlatformScale : 20*physicalPlatformScale

    property string folderPath
    property string source
    property variant filter
    property bool preview: false

    ThumbnailImage {
        id: img
        width: viewMode? item.width - 8*physicalPlatformScale : item.width - 50*physicalPlatformScale
        height: viewMode? item.height - 8*physicalPlatformScale : item.height - 50*physicalPlatformScale
        anchors.horizontalCenter: parent.horizontalCenter
        sourceSize: Qt.size(width,height)
        asynchronous: true
        smooth: true
        fillMode: Image.PreserveAspectFit
        path: item_base.source
        indicator: !fpreview.visible

        FolderPreview {
            id: fpreview
            anchors.fill: parent
            filter: item_base.filter
            path: item_base.folderPath
            visible: item_base.folderPath.length!=0
        }
    }

    Text {
        id: txt
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WrapAnywhere
        text: fileName
        font.pixelSize: 11*fontsScale
        visible: !viewMode
        color: "#dddddd"
    }
}
