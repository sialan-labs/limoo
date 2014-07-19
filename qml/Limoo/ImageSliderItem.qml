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

Item {
    id: item
    width: 100
    height: 62

    property string source
    property bool zoomed: privates.zoom != 1

    QtObject {
        id: privates

        property size imageSize: Limoo.imageSize(item.source)
        property real imageRatio: imageSize.width/imageSize.height
        property real itemRatio: item.width/item.height
        property real zoom: 1
        property real maximumZoom: (imageRatio>itemRatio? imageSize.width/item.width : imageSize.height/item.height)*4
        property bool largeImageLoadedOnce: false

        onZoomChanged: if( zoom > 1 ) largeImageLoadedOnce = true
    }

    Flickable {
        id: flick
        anchors.fill: parent
        contentWidth: width
        contentHeight: height
        flickableDirection: Flickable.HorizontalAndVerticalFlick
        interactive: privates.zoom != 1

        Item {
            width: flick.contentWidth
            height: flick.contentHeight

            LimooImage {
                id: img
                width: parent.width
                height: parent.height
                sourceSize: privates.zoom==1 && !privates.largeImageLoadedOnce? Qt.size(width,height) : privates.imageSize
                asynchronous: false
                source: privates.zoom==1 && !privates.largeImageLoadedOnce? "" : item.source
                fillMode: Image.PreserveAspectFit
                smooth: true
                visible: privates.zoom!=1
            }

            LimooImage {
                id: preview_img
                width: item.width
                height: item.height
                sourceSize: Qt.size(width,height)
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                smooth: true
                source: item.source
                visible: privates.zoom==1
            }

            MouseArea {
                id: marea
                hoverEnabled: true
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onDoubleClicked: Limoo.fullScreen = !Limoo.fullScreen
                onClicked: {
                    if (mouse.button == Qt.RightButton) {
                        var obj = main.showMenu("ImageMenu.qml", mapToItem(main,0,mouseY).y, 60*physicalPlatformScale )
                        obj.source = item.source
                        obj.menuX = mapToItem(main,mouseX,mouseY).x
                        return
                    }
                }

                onWheel: {
                    var point = Qt.point(wheel.x,wheel.y)
                    if (wheel.angleDelta.y > 0)
                        zoomIn(point);
                    else
                        zoomOut(point);
                }
            }
        }
    }

    ScrollBar {
        scrollArea: flick; height: flick.height; width: 8; orientation: Qt.Vertical
        anchors.right: flick.right; anchors.top: flick.top; color: "#ffffff"
    }
    ScrollBar {
        scrollArea: flick; width: flick.width; height: 8; orientation: Qt.Horizontal
        anchors.bottom: flick.bottom; anchors.left: flick.left; color: "#ffffff"
    }

    Text {
        id: zoom_percent
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 8*physicalPlatformScale
        text: Math.floor(100*paintedWidth/privates.imageSize.width) + "%"
        color: "#ffffff"
        opacity: 0
        visible: opacity != 0
        onOpacityChanged: if(opacity == 1) hide_zp_timer.restart()
        onTextChanged: if(img.paintedWidth!=0) opacity = 1
        style: Text.Outline
        styleColor: "#666666"

        property real paintedWidth: img.paintedWidth==0? preview_img.paintedWidth : img.paintedWidth

        Behavior on opacity {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
        }

        Timer {
            id: hide_zp_timer
            interval: 1000
            repeat: false
            onTriggered: zoom_percent.opacity = 0
        }
    }

    function zoomIn(point) {
        var newZ = privates.zoom*1.2
        if( newZ > privates.maximumZoom )
            newZ = privates.maximumZoom
        if( newZ < 1 )
            newZ = 1

        privates.zoom = newZ
        refreshZoom(point)
    }

    function zoomOut(point) {
        var newZ = privates.zoom/1.2
        if( newZ < 1 )
            newZ = 1

        privates.zoom = newZ
        refreshZoom(point)
    }

    function refreshZoom(point){
        var newW = preview_img.paintedWidth*privates.zoom
        var newH = preview_img.paintedHeight*privates.zoom
        if( newW<flick.width )
            newW = flick.width
        else
        if( newH<flick.height )
            newH = flick.height

        flick.resizeContent(newW, newH, point)
        flick.returnToBounds()
    }

    function unzoom() {
        if( privates.zoom == 1 )
            return

        privates.zoom = 1
        refreshZoom(Qt.point(0,0))
    }

    function rotateLeft() {
        preview_img.rotateLeft()
        img.rotateLeft()
    }

    function rotateRight() {
        preview_img.rotateRight()
        img.rotateRight()
    }
}
