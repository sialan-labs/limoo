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
    id: basket
    width: list.count == 0? 0 : basket.visibleWidth
    height: 62
    color: "#111111"
    visible: width != 0

    property real visibleWidth: 100*physicalPlatformScale
    property alias count: list.count

    signal selected( string filePath )
    signal removed( string filePath )
    signal cleared()

    SystemPalette { id: myPalette; colorGroup: SystemPalette.Active }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
    }

    ListView {
        id: list
        anchors.top: parent.top
        anchors.bottom: clear_btn.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: basket.visibleWidth
        model: ListModel{}
        clip: true

        delegate: Item {
            id: item
            width: list.width
            height: width

            Rectangle {
                anchors.fill: parent
                color: myPalette.highlight
                radius: 3*physicalPlatformScale
                opacity: marea.pressed? 0.4 : highlightOpacity

                property real highlightOpacity: marea.containsMouse? 0.2 : 0

                Behavior on opacity {
                    NumberAnimation { easing.type: Easing.OutCubic; duration: 200 }
                }
            }

            ThumbnailImage {
                anchors.fill: parent
                anchors.margins: 8*physicalPlatformScale
                sourceSize: Qt.size(width,height)
                asynchronous: true
                fillMode: Image.PreserveAspectCrop
                source: filePath
                indicator: false
            }

            MouseArea {
                id: marea
                hoverEnabled: true
                anchors.fill: parent
                onClicked: basket.selected(filePath)
            }

            Button {
                anchors.top: item.top
                anchors.left: item.left
                icon: "files/edit-delete.png"
                highlightColor: myPalette.highlight
                visible: marea.containsMouse
                hoverEnabled: false
                onClicked: {
                    basket.removed(filePath)
                    list.model.remove(index,1)
                }
            }
        }
    }

    ScrollBar {
        scrollArea: list; height: list.height; width: 8
        anchors.right: list.right; anchors.top: list.top; color: "#ffffff"
    }

    Button {
        id: clear_btn
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        highlightColor: myPalette.highlight
        normalColor: "#0a0a0a"
        radius: 0
        onClicked: {
            var obj = main.showMenu("BasketActions.qml", mapToItem(main,0,height).y, 100*physicalPlatformScale )
            obj.basket = basket
            return
        }
    }

    function containt( filePath ) {
        for( var i=0; i<list.model.count; i++ )
            if( list.model.get(i).filePath == filePath )
                return true

        return false
    }

    function add( filePath ) {
        if( containt(filePath) )
            return

        list.model.append( {"filePath":filePath} )
        list.positionViewAtEnd()
    }

    function toList() {
        var result = new Array
        for( var i=0; i<list.model.count; i++ )
            result[i] = list.model.get(i).filePath

        return result
    }

    function clear() {
        list.model.clear()
        basket.cleared()
    }

    LanguageSwitcher {
        onRefresh: {
            clear_btn.text = qsTr("Actions")
        }
    }
}
