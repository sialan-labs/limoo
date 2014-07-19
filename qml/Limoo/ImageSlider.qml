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
import Qt.labs.folderlistmodel 2.1

Item {
    id: slider
    width: 100
    height: 62

    property string source
    property string currentItem
    property bool showHidden: false
    property variant filters

    ListView {
        id: list
        anchors.fill: parent
        orientation: Qt.Horizontal
        snapMode: ListView.SnapOneItem

        onFlickEnded: {
            var item = list.itemAt(width/2+contentX,height/2)
            if( !item )
                return

            slider.currentItem = item.source
            list.currentIndex = list.indexAt(width/2+contentX,height/2)
        }

        model: FolderListModel{
            showDirs: false
            showFiles: true
            showHidden: slider.showHidden
            sortField: FolderListModel.Name
            nameFilters: slider.filters
            folder: slider.source
            onFolderChanged: list.interactive = true
        }

        delegate: ImageSliderItem {
            id: item
            width: list.width
            height: list.height
            source: filePath
            onZoomedChanged: list.interactive = !zoomed

            Connections {
                target: list
                onContentXChanged: item.unzoom()
            }
        }
    }

    ScrollBar {
        scrollArea: list; width: list.width; height: 8; orientation: Qt.Horizontal
        anchors.bottom: list.bottom; anchors.left: list.left; color: "#ffffff"
    }

    Timer {
        id: current_timer
        interval: 20
        repeat: false
        onTriggered: setCurrentImmedietly(filePath)
        property string filePath
    }

    function setCurrent( filePath ) {
        current_timer.filePath = filePath
        current_timer.restart()
    }

    function setCurrentImmedietly( filePath ) {
        for( var i=0; i<list.model.count; i++ )
            if( list.model.get(i,"filePath") == filePath ) {
                list.positionViewAtIndex(i, ListView.Beginning)
                list.currentIndex = i
                return
            }
    }

    function moveToIndex( index ) {
        list.positionViewAtIndex(index, ListView.Beginning)
    }

    function rotateLeft() {
        var item = list.itemAt(list.width/2+list.contentX,list.height/2)
        if( !item )
            return

        item.rotateLeft()
    }

    function rotateRight() {
        var item = list.itemAt(list.width/2+list.contentX,list.height/2)
        if( !item )
            return

        item.rotateRight()
    }
}
